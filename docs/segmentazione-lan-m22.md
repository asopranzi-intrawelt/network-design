# Segmentazione reale della LAN interna (M22) — documento di design

> Documento di progetto del micro-step M22 della Fase 3 (`.claude/context/roadmap.md`),
> aperto il 27/07/2026. Non e' un progetto nuovo: e' la continuazione, sul fronte interno,
> del lavoro di segmentazione che questo repository documenta da giugno — la DMZ 201
> pianificata il 05/06/2026, la VLAN 40 della Wi-Fi staff applicata il 16/07, la VLAN 90
> degli ospiti resa funzionante il 22/07, la VLAN 2 della fonia sistemata il 23/07. Da
> quegli interventi eredita la convenzione di indirizzamento, l'idioma di configurazione
> verificato sul dispositivo reale, gli script di scrittura sugli switch e le lezioni di
> change management pagate in campo. Tiene insieme tre livelli: concettuale (perche', e
> cosa la segmentazione compra davvero), tecnico (disegno target, matrice dei flussi,
> sintassi reale), operativo (passi verificabili con rollback). Nulla di quanto segue e'
> stato applicato alla rete: e' un progetto, e lo dichiara riga per riga.

## Su cosa si innesta: gli artefatti che esistono gia'

Prima di aggiungere qualcosa conviene sapere cosa c'e', perche' quasi tutta
l'infrastruttura di questo progetto e' gia' stata costruita per altri segmenti e va
riusata, non reinventata.

| Artefatto esistente | Cosa fornisce a M22 |
|---|---|
| `docs/firewall-zyxel-usg-flex-500.md` §Architettura DMZ pianificata (05/06/2026) | Il principio della topologia a stella (nessun segmento in serie, tutti bracci paralleli con centro nel firewall) e l'idioma di configurazione dell'interfaccia con `type internal` e `mtu 1500`, verificato sul dispositivo |
| Stessa scheda, §Fase A rete Wi-Fi (M13a) | Il precedente completo di creazione di un segmento nuovo: interfaccia `vlan40` con `ip dhcp-pool`, parametri DHCP realmente applicati via GUI (percorso `Edit VLAN > Show Advanced Settings > DHCP Setting`), zona dedicata assegnata dal menu a tendina, forma reale della `secure-policy`, e la nota che tutte le porte fisiche del firewall sono gia' assegnate — una VLAN nuova va legata come interfaccia taggata al port-group `lan1` esistente, non a una porta libera |
| Stessa scheda, §Sequenza di applicazione: le sei fasi | Il metodo di intervento: backup datato prima, un cambiamento per volta, verifica nell'ordine di impatto utente, finestra di osservazione dopo |
| `.claude/rules/anonymization.md` e la pratica della VLAN 40 | La convenzione di indirizzamento del progetto: **l'ottetto coincide con l'ID VLAN** (VLAN 40 -> `10.61.40.0/24`), che rende il piano di indirizzamento autoesplicativo e va estesa ai segmenti nuovi |
| `scripts/Set-NebulaWifiVlan.ps1` (ADR-010) | Scrittura del PVID e delle liste VLAN sulle porte degli switch via API Nebula, con dry-run di default, conferma testuale per `-Apply` e selettore `-Only Trunk\|Access\|All`: e' esattamente lo strumento che serve per spostare porte a gruppi in modo ripetibile e tracciato |
| `scripts/Get-NebulaSnapshot.ps1` (ADR-009) e `output/nebula-snapshot.json` | La fotografia porta-per-porta dei due switch, PVID, liste VLAN ammesse e tabella MAC di livello 2: e' la base del censimento |
| `.claude/context/diagrams/firewall-dmz-2026/rete_stato_target_08072026.drawio` | Il diagramma target vigente, che contiene gia' la DMZ 201 access su P7, il trunk 802.1Q verso Proxmox e la zona guest su ge7/P8: M22 aggiunge segmenti a *questo* disegno, e la revisione successiva del drawio nascera' quando il primo segmento sara' applicato |
| `.claude/context/diagrams/firewall-dmz-2026/rete_stato_attuale_17072026.drawio` | Lo stato attuale, che pero' porta ancora l'etichetta di porta della dorsale invertita e i due telefoni come non funzionanti: da rivedere alla prossima revisione (vedi §Debito sui diagrammi) |
| `docs/mappatura-porte-fisiche.md` | La corrispondenza tra prese a muro e ruolo dichiarato, incluse le prese marcate "Stampante" piano per piano: e' il punto di partenza per sapere quante porte toccare, con la cautela documentata che le etichette risultano permutate in modo sistematico dal rilievo 2020 |
| `docs/network-diagram.md` §Segmentazione VLAN | La tabella VLAN di riferimento, che M22 estende |

## Livello concettuale: cosa compra una VLAN, e cosa no

### La differenza tra convenzione di indirizzamento e confine

La LAN Intrawelt usa da anni una convenzione leggibile: le postazioni prendono indirizzi
nella classe `.10`, i server e le VM nella `.20`, le stampanti nella `.30`. A prima
lettura sembra una rete segmentata in tre parti. Non lo e', e la ragione sta in un solo
numero: la subnet mask. Tutti gli host hanno `/19`, una maschera che copre l'intervallo
da `10.61.0.0` a `10.61.31.255` e quindi include per costruzione tutte e tre le classi.
Per un host, "essere nella stessa rete" significa esattamente una cosa: che l'indirizzo
di destinazione cade dentro la propria maschera. Quando cade dentro, il pacchetto non
viene mandato al gateway ma consegnato direttamente al destinatario tramite ARP[^1] sul
livello 2, e nessun apparato di livello 3 lo vede passare. Il firewall, che e' il punto
dove vivono le policy, non e' sul percorso.

Da qui la prima acquisizione concettuale, che vale la pena tenere ferma perche' e'
controintuitiva: le regole del firewall tra `lan1`, `lan1:1` e `lan1:2` non hanno alcun
effetto, non perche' siano scritte male, ma perche' non esiste traffico che passi per il
firewall tra quelle tre classi. Il firewall e' il portiere di un palazzo dove tutti gli
appartamenti comunicano da porte interne che il portiere non vede. E' questo che
`GAP-TBC.md` #114 (NET-009) registra come gap, ed e' per questo che il gap non si chiude
con una regola in piu'.

### Cosa cambia con un tag 802.1Q

Una VLAN[^2] separa i domini di broadcast sullo switch. Ogni frame che entra da una porta
*access* viene marcato con l'identificatore della VLAN configurata su quella porta, il
PVID[^3], e da quel momento lo switch lo inoltra solo verso porte della stessa VLAN. Sui
collegamenti tra switch i frame viaggiano *tagged* su una porta *trunk*, cosi' che piu'
VLAN condividano lo stesso cavo restando separate. Il tag e' quattro byte aggiunti
all'intestazione Ethernet: non costa banda apprezzabile e non richiede che l'endpoint
sappia nulla di VLAN, perche' e' lo switch a metterlo e a toglierlo. E' la ragione per cui
una stampante, un telefono IP o un access point legacy funzionano su una porta access
taggata dallo switch — con l'eccezione istruttiva del 16/07/2026, quando i tre AP Ubiquiti
EOL hanno smesso di trasmettere l'SSID al cambio di VLAN nativa sulla loro porta, a
dimostrazione che "l'endpoint non deve sapere nulla" e' vero in generale ma non su
qualunque hardware (`runbook-anomalie.md` §AP-001).

Perche' due VLAN si parlino serve un dispositivo di livello 3 con un piede in entrambe:
qui il firewall, che ospita un'interfaccia con l'indirizzo di gateway per ciascuna VLAN.
E qui sta il guadagno vero: *tutto* il traffico tra un segmento e l'altro attraversa il
firewall, quindi diventa filtrabile, registrabile e negabile per default. La
segmentazione non e' un fine, e' il modo di rendere applicabili le policy che si vogliono
scrivere.

Il progetto ha tre precedenti in casa, e vanno usati come riferimento invece di ragionare
in astratto. La VLAN 40 della Wi-Fi staff ha mostrato che una VLAN nuova si aggancia allo
stesso port-group fisico della LAN come interfaccia taggata, senza cavi nuovi. La VLAN 90
degli ospiti ha mostrato, con la vicenda del SNAT[^4] mancante del 22/07, che una VLAN
nuova e' una rete nuova a tutti gli effetti e non un sottoinsieme di quella vecchia: il
mascheramento automatico verso Internet dipende dal campo `Interface Type`
dell'interfaccia, `internal` lo ottiene e `general` no. La VLAN 2 della fonia ha mostrato
il terzo tassello, quello che riguarda direttamente M22: una VLAN non attraversa un trunk
solo perche' esiste. Il 23/07 la fonia si fermava al Piano Terra perche' la porta 29 dello
XGS2220-30HP aveva `Allowed VLANs = 1, 40, 90`, una lista esplicita in cui la VLAN 2 non
compariva, e i frame venivano scartati all'ingresso.

Quest'ultimo punto **corregge un'affermazione ancora presente nella scheda firewall**
(§Fase A, nota del 15/07/2026: "ogni porta di entrambi gli switch ha `allowedVLAN: all`,
qualunque VLAN taggata attraversa gia' ogni collegamento"). Era vero allo snapshot del
15/07 ed e' falso oggi: il trunk lato Piano Terra porta una lista esplicita. Per M22 ne
segue una conseguenza operativa non negoziabile: ogni ID VLAN nuovo va aggiunto
esplicitamente alla lista della porta 29 del 30HP, altrimenti il segmento funzionera' al
Piano 2 e sara' invisibile al Piano Terra, con un sintomo identico a quello dei telefoni.

### I tre limiti da dichiarare subito

Il primo limite e' che una VLAN non protegge dentro se stessa: due PC nello stesso
segmento si parlano come prima, e se il rischio e' il movimento laterale tra postazioni
servono altri controlli (isolamento di porta, 802.1X, EDR). La segmentazione riduce il
raggio d'azione, non lo azzera.

Il secondo e' che non sostituisce l'autenticazione: mettere il pilota della VM208 in un
segmento dedicato riduce chi puo' raggiungere la sua pagina di login, non rende quel
login piu' robusto.

Il terzo, il piu' rilevante per il caso stampanti, e' che la segmentazione non governa i
flussi *applicativi* dei dati. Una stampante confinata nella propria VLAN puo' continuare
a scrivere in scan-to-folder verso la cartella di un PC, se la policy lo consente e la
share esiste. La VLAN decide chi puo' parlare con chi, la politica di destinazione decide
dove finiscono i documenti: sono due controlli distinti e questo progetto deve produrli
entrambi. Per l'angolo ISO27001: A.8.22 segregazione nelle reti per il primo, A.8.3
restrizione di accesso alle informazioni e A.5.14 trasferimento delle informazioni per il
secondo.

## Deep-dive tecnico: il disegno target

### I segmenti

Cinque segmenti interni nuovi o riorganizzati, piu' quelli che esistono gia' o sono
pianificati altrove. Gli ID seguono la convenzione del progetto (ottetto = ID VLAN) e non
collidono con gli ID in uso (1, 2, 40, 90) ne' con quelli gia' riservati (100 fonia
target, 201 DMZ). Restano da confermare formalmente, ma la convenzione li rende quasi
obbligati.

| Segmento | VLAN | Subnet prevista | Contenuto | Perche' separato | Difficolta' |
|---|---|---|---|---|---|
| Postazioni | 10 | `10.61.10.0/24` | PC fisici e notebook cablati | E' la popolazione piu' numerosa e piu' esposta: quasi ogni incidente parte da qui | Media: tutto in DHCP, ma molte porte e ogni errore e' immediatamente visibile all'utente |
| Server e VM | 20 | `10.61.20.0/24` | Server fisici, VM Proxmox di infrastruttura, NAS fleet | Contiene dati e servizi di autenticazione: e' il segmento da proteggere, non quello da cui proteggersi | Alta: indirizzi statici, file `hosts`, unita' mappate, license server, job di backup, l'host Proxmox stesso |
| Stampanti e MFP | 30 | `10.61.30.0/24` | Stampanti di rete e multifunzione con scansione | Firmware raramente aggiornato, credenziali di fabbrica frequenti, servizi non necessari esposti; e' anche il punto dove i documenti scansionati entrano nel filesystem | **Bassa**: nessun host che si autentica, nessuna sessione utente, rollback immediato |
| Servizi applicativi interni | 50 | `10.61.50.0/24` | VM che pubblicano applicazioni interne (VM208 e successive) | Sono i soli host interni che espongono deliberatamente porte a una platea ampia: vanno raggiunti, non devono raggiungere | Media, e dipende da M5: richiede il bridge Proxmox VLAN-aware, lo stesso prerequisito della DMZ |
| IoT e OT | 60 | `10.61.60.0/24` | UPS, domotica, citofono, centrale irrigazione, sensori | Dispositivi senza patching e spesso senza autenticazione, storicamente finiti sulla VLAN 90 per errore | Bassa in numero, media in ricognizione: prima bisogna trovarli tutti |

### Il segmento che il censimento fa emergere: la gestione degli apparati

C'e' un sesto candidato che non era nella lista iniziale e che va deciso prima di
scrivere il piano di indirizzamento, perche' altrimenti si eredita nel disegno nuovo
un difetto del disegno vecchio. Oggi la gestione degli apparati di rete non ha un posto
proprio: l'interfaccia di gestione dello switch del Piano Terra sta nella classe `.10`,
cioe' nello stesso segmento delle postazioni (verificato il 23/07/2026), mentre la iLO5
del server sta su `10.61.1.71`, in una classe che nessun documento di questo progetto
descrive come segmento (gap SRV-003, `GAP-TBC.md` #108). Il risultato e' che una
postazione compromessa vede oggi il piano di gestione degli switch, che e' il tipo di
adiacenza che una segmentazione dovrebbe eliminare per prima.

Le strade sono due. La prima e' un segmento di gestione dedicato, che contiene
l'interfaccia di gestione dei due switch, la iLO, gli access point e l'interfaccia di
amministrazione del firewall, raggiungibile solo dalle postazioni IT dichiarate; e' la
scelta corretta dal punto di vista del controllo di accesso privilegiato (A.9.4) e ha il
vantaggio di essere piccola, perche' gli apparati sono pochi e tutti noti. La seconda e'
includere la gestione nel segmento server, che e' meno rigoroso ma riduce di uno il
numero di segmenti da governare. La prima e' la raccomandazione di questo documento;
la scelta resta dell'IT Manager perche' cambia il conteggio dei segmenti deciso il 27/07.
Va tenuta presente la lezione del 23/07: la gestione degli switch viaggia oggi sulla VLAN
nativa dei dati, quindi *spostarla* significa toccare la VLAN di gestione degli apparati
mentre si e' collegati attraverso di essa, che e' l'operazione che ha prodotto il
blackout del piano di gestione del core switch. Va fatta per ultima, non per prima, e con
un accesso alternativo pronto (console seriale, M2 ancora aperto).

Segmenti con cui il disegno deve convivere senza toccarli: VLAN 2 fonia (telefoni,
DHCP e gateway del fornitore, isolata dal firewall), VLAN 40 Wi-Fi staff (accesso pieno
alla LAN per decisione ADR-014, da rileggere a segmentazione fatta), VLAN 90 ospiti (SNAT
esplicito e uscita sola WAN), VLAN 100 fonia target (zona VOICE su ge5, pianificata
l'08/07 e non applicata), VLAN 201 DMZ (M4-M9, non attivata), VLAN 1 nativa sui trunk, da
svuotare progressivamente.

Il diagramma target dei segmenti e delle relazioni e' versionato in
`.claude/context/diagrams/segmentazione-target-m22.mmd`.

### La matrice dei flussi

E' la parte che vale il progetto: senza matrice, "segmentare" degenera in un elenco di
regole scritte in emergenza il giorno della migrazione. La tabella dichiara cosa deve
essere permesso; tutto il resto e' negato per default con log, che e' la postura opposta a
quella attuale.

| Da \ Verso | PC (10) | Server (20) | Stampanti (30) | Servizi app (50) | IoT/OT (60) | WAN |
|---|---|---|---|---|---|---|
| **PC (10)** | — | SMB, HTTPS, servizi di dominio | IPP/9100 stampa, HTTPS di gestione solo dalle postazioni IT | HTTPS | negato | consentito |
| **Server (20)** | negato salvo gestione remota dichiarata | — | negato | DB, SMTP, LDAP/OIDC verso i soli servizi dichiarati | negato | consentito (aggiornamenti) |
| **Stampanti (30)** | **negato** — e' il fix di rete dello scan-to-folder verso le cartelle utente | SMB **solo** verso la share di scansione dedicata | — | negato | negato | negato salvo firmware e servizi cloud del produttore, da decidere |
| **Servizi app (50)** | negato | DB, SMTP, LDAP/OIDC verso i soli server dichiarati | negato | — | negato | consentito in uscita per aggiornamenti |
| **IoT/OT (60)** | negato | negato salvo raccolta dati dichiarata | negato | negato | — | negato salvo cloud del fornitore dichiarato |
| **Wi-Fi staff (40)** | come PC | come PC | come PC | come PC | negato | consentito |
| **Guest (90)** | negato | negato | negato | negato | negato | consentito via SNAT (gia' applicato) |

Due righe invertono un'abitudine e vanno lette con attenzione. Le stampanti verso i PC
negate sono il fix di rete del problema scan-to-folder: la multifunzione non puo' piu'
scrivere in una cartella condivisa di una postazione perche' non la raggiunge. I server
verso i PC negati sono meno intuitivi ma piu' importanti: un server compromesso che non
puo' iniziare connessioni verso le postazioni perde la strada piu' comoda per propagarsi.

### Sintassi di riferimento, nell'idioma verificato del dispositivo

Non si inventa una forma nuova: si riusa quella gia' applicata per la VLAN 40 e per la
DMZ, che e' verificata su questo firewall. L'interfaccia del segmento stampanti, primo
segmento in ordine di intervento, ha questa forma.

```
interface vlan30
  ip address 10.61.30.1 255.255.255.0
  type internal
  mtu 1500
  ip dhcp-pool PRINT30_POOL start 10.61.30.10 count 100 lease 2
```

L'applicazione reale avviene via GUI, non in SSH, per la stessa ragione documentata in
M13a: il firewall non espone API REST in modalita' standalone e l'accesso SSH ha 2FA che
richiede un umano a ogni sessione. Il percorso e' `Configuration > Network > Interface >
VLAN > Add`, con la porta base `lan1` (tutte le porte fisiche sono gia' assegnate, quindi
il segmento nasce come interfaccia taggata sullo stesso cavo della LAN) e i parametri
DHCP dietro `Show Advanced Settings > DHCP Setting`, che e' un link non espanso di
default. Sul campo `Interface Type` la scelta va motivata invece di essere copiata:
`internal` porta con se' il mascheramento automatico verso la WAN, e per un segmento
stampanti che nella matrice non ha uscita su Internet, `general` sarebbe piu' coerente con
il principio del minimo privilegio — a costo di dover dichiarare esplicitamente tutto
quello che deve funzionare, come e' successo alla guest. La decisione va presa
consapevolmente al momento della creazione e annotata nella scheda firewall.

Le regole seguono la forma delle `secure-policy` gia' applicate, con il numero da
scegliere come primo libero *prima* di qualunque regola generica di uscita, perche' il
motore si ferma alla prima corrispondenza (la lezione di FW-001).

```
secure-policy N
 name PRINT30_to_LAN1_deny
 from PRINT30
 to LAN1
 sourceip any
 destinationip any
 action deny
 log alert
```

Il nome della zona va confermato su `Configuration > Object > Zone` al momento
dell'intervento e assegnato dal menu a tendina alla creazione dell'interfaccia: sbagliare
la zona invalida la regola senza produrre alcun errore visibile.

Lato switch la scrittura e' scriptabile e va fatta con lo strumento che esiste, in
dry-run prima e con `-Apply` solo dopo aver letto il diff:

```powershell
# Prima i trunk, poi le porte access: mai il contrario.
.\scripts\Set-NebulaWifiVlan.ps1 -Only Trunk   # verifica ed estensione delle liste VLAN ammesse
.\scripts\Set-NebulaWifiVlan.ps1 -Only Access  # spostamento delle porte, a gruppi
```

Lo script e' nato per la VLAN 40 e va parametrizzato per accettare l'ID VLAN e l'elenco
di porte come argomenti: e' l'unica modifica di codice prevista da questo micro-step, ed
e' preferibile a una sessione manuale nella GUI Nebula perche' lascia un log applicativo
(`output/nebula-apply-log-*.json`) di cosa e' stato scritto e quando.

## Livello operativo: censimento, poi le stampanti

### Perche' il censimento viene prima

Nessuna porta si sposta prima di sapere cosa c'e' attaccato. Non e' burocrazia: e' la
differenza tra spostare una stampante e scoprire in produzione che su quella porta c'era
anche un lettore di badge. Il censimento e' anche la condizione posta dall'IT Manager il
27/07/2026 per decidere la strategia di indirizzamento (vedi §Il nodo dell'indirizzamento).

### Cosa e' gia' ricavabile dai dati in casa

Dallo snapshot Nebula del 21/07/2026 (`output/nebula-snapshot.json`, non versionato) si
legge la configurazione porta per porta di entrambi gli switch e, per il solo XGS2220-54HP,
la tabella MAC di livello 2. Il quadro utile a M22 e' questo: sul 54HP le porte access
sono 49 con PVID 1 e cinque con PVID 2 (porte 3, 5, 6, 8 e 44, cioe' telefoni e apparati
Vianova, coerenti con la ricostruzione del 23/07); tutte e sei le porte a 10 Gbps sono
trunk con lista `all`; ventotto porte hanno MAC appresi. L'identificazione per prefisso
di produttore fa emergere almeno un apparato di stampa Canon sulla porta 18 e un apparato
Kyocera appreso *attraverso* il trunk, quindi fisicamente al Piano Terra. La maggior parte
dei prefissi non e' attribuibile senza una tabella OUI[^5] completa, che offline non c'e':
quei dispositivi restano da identificare.

Due limiti dello snapshot cambiano il piano e vanno dichiarati. E' anteriore agli
interventi del 23/07, quindi non contiene le porte telefono del 30HP portate su PVID 2 ne'
la lista VLAN esplicita sulla porta 29; e per lo XGS2220-30HP la tabella MAC e' assente
(`l2_mac_table` nullo), cioe' manca proprio per il Piano Terra, dove vive la maggior parte
delle postazioni e delle stampanti.

### Cosa resta da raccogliere, e come

Il primo passo e' uno snapshot Nebula nuovo, posteriore al 23/07 e con la tabella MAC di
entrambi gli switch. Lo script e' in sola lettura e richiede la chiave API, in mano
all'IT Manager (ADR-009).

```powershell
.\scripts\Get-NebulaSnapshot.ps1
```

Il secondo sono tre informazioni che vivono solo sul firewall e vanno lette dalla GUI:
gli ambiti DHCP attivi con i rispettivi intervalli, le riserve DHCP per MAC, e gli
oggetti indirizzo che referenziano host statici. Gli ambiti e le riserve stanno in
`Configuration > Network > Interface`, aprendo `lan1` e i suoi alias; gli oggetti in
`Configuration > Object > Address`, dove e' gia' aperto il task di pulizia delle voci
stale verso la vecchia subnet staff, che conviene chiudere nello stesso passaggio.

Il terzo e' il censimento degli host con indirizzo statico o scritto a mano in una
configurazione, che e' la domanda a cui e' appeso il resto del progetto. Le fonti da
incrociare esistono gia' tutte in questo repository o sono raggiungibili: il NAS fleet e i
suoi indirizzi (`vendor-management.md` §QNAP), i riferimenti nelle unita' di rete mappate
(`runbook-anomalie.md` §NAS-002), i file `hosts` delle postazioni, di cui sono noti almeno
due usi deliberati (la redirezione di `intrawelt.com` verso la VM206 e la risoluzione del
portale sulla VM208, che non ha DNS di LAN — gap SEC-016), le VM Proxmox con IP statico
(interrogabili via MCP o dallo snapshot), le stampanti configurate con indirizzo fisso
sulle postazioni, i job di backup verso i NAS e i license server.

### Il primo intervento: le stampanti

L'ordine e' stato scelto dall'IT Manager il 27/07/2026: si parte dal segmento con
accoppiamento minimo, usando soltanto switch e firewall, senza toccare la rete del nodo
Proxmox. Il motivo tecnico e' che una stampante non ha sessioni utente da interrompere,
non e' un client di dominio, non tiene connessioni di lunga durata e, se qualcosa va
storto, si riporta la porta al PVID precedente e torna come prima. Il motivo di metodo e'
che questo primo giro valida l'intera catena — interfaccia, DHCP, zona, policy, trunk,
porta access — su un carico dove l'errore costa una stampa in coda, non il lavoro di un
ufficio.

La sequenza, un passo per volta e senza sovrapposizioni, nell'ordine delle sei fasi gia'
adottato per il firewall.

1. **Backup datato** della configurazione del firewall e della configurazione degli
   switch prima di qualunque modifica (e' il micro-step M3, ancora aperto: qui diventa
   prerequisito non rinviabile).
2. **Interfaccia e DHCP** sul firewall: `vlan30` come sopra, con la scelta di
   `Interface Type` motivata e annotata, ambito DHCP con intervallo dedicato, DNS
   coerenti con quelli gia' usati per gli altri segmenti.
3. **Zona e policy**: zona dedicata, poi le regole della matrice — PC verso stampanti su
   IPP e 9100, stampanti verso la sola share di scansione, tutto il resto negato con log,
   inserite prima di qualunque regola generica di uscita.
4. **Share di scansione dedicata** sul NAS e riconfigurazione delle destinazioni di
   scansione delle multifunzione. Questo passo precede lo spostamento delle porte:
   altrimenti si sposta una stampante che non sa piu' dove scrivere, e si attribuisce alla
   VLAN un guasto che e' di configurazione applicativa.
5. **Trunk**: aggiungere l'ID 30 alla lista delle VLAN ammesse della porta 29 del 30HP
   (passo obbligatorio, vedi la lezione della VLAN 2), verificando a schermo; sul 54HP la
   porta 51 e' su `All` e non richiede modifiche, e su quel core switch la lista esplicita
   resta deliberatamente non introdotta perche' il rischio supera il beneficio. Regola non
   negoziabile appresa il 23/07 al costo di un blackout del piano di gestione: il PVID e'
   un valore singolo, la lista sta solo in `Allowed VLANS`.
6. **Una porta stampante per volta** su access con PVID 30: verificare che l'apparato
   prenda indirizzo nel nuovo ambito, che una stampa di prova esca, che una scansione
   arrivi nella share dedicata e che il tentativo di scrivere in una cartella di
   postazione ora fallisca. Solo dopo passare alla successiva.
7. **Pulizia**, a migrazione completa: rimuovere riserve e oggetti indirizzo diventati
   inutili sulla vecchia convenzione `.30`, e togliere il vecchio ambito solo quando
   nessun apparato lo usa piu'.

Criterio di rollback, uniforme su tutti i passi: se un apparato non prende indirizzo entro
due tentativi DHCP, si riporta quella singola porta al PVID precedente e si indaga a
freddo, senza proseguire con le altre. Il rollback e' sempre una sola modifica su una sola
porta, che e' precisamente il motivo per cui si procede una porta alla volta.

### Il nodo dell'indirizzamento, deliberatamente aperto

Restano due strade e la scelta e' rimandata al censimento, perche' dipende da quanti host
hanno un indirizzo statico o scritto a mano.

La prima e' *rinumerare per classe*: le tre convenzioni diventano tre VLAN con subnet
`/24` vere. Il disegno finale e' pulito, ma ogni host statico va toccato e ogni
riferimento a un indirizzo dentro un file `hosts`, una unita' mappata, un job di backup o
una licenza va trovato prima, non dopo.

La seconda e' *affiancare e svuotare*: la `/19` resta come segmento legacy, ogni VLAN
nuova nasce con la propria subnet, i dispositivi si spostano a gruppi e il legacy si
restringe fino a sparire. Non c'e' un momento di rottura, ed e' lo stesso pattern con cui
sono nate la VLAN 40 e la VLAN 90; il costo e' che per un periodo la rete e' doppia, con
due gateway da tenere a mente. Va notato che il segmento stampanti nasce cosi' in ogni
caso: `10.61.30.0/24` con gateway `.30.1` convive con la vecchia convenzione `.30` dentro
la `/19` fino a quando l'ultima stampante non e' migrata.

## Debito sui diagrammi

I diagrammi vigenti non riflettono ancora tre fatti accertati, e la correzione va fatta
in un colpo solo alla prossima revisione invece che a ogni micro-step, come stabilito
dalla nota "Diagramma vivo" della roadmap. Lo stato attuale rev 17/07 porta l'etichetta
della dorsale sulla porta sbagliata (la dorsale e' la 51, il ramo QNAP la 52) e i due
telefoni del Piano Terra come non funzionanti, mentre la parte di rete e' risolta dal
23/07. Nessun diagramma contiene la VM208 ne' il fatto che pubblichi 80 e 443 sulla LAN
piatta. La topologia Proxmox in `network-topology.mmd` e' ferma allo snapshot del
19/06/2026: elenca la VM803 rimossa, attribuisce a VM205 un indirizzo che lo snapshot v4
non conferma e non contiene VM207 con il suo ruolo attuale ne' VM208. Il consolidamento e'
M19, a fine Fase 3; fino ad allora vale questa nota come dichiarazione esplicita di
disallineamento.

## Stato e prossime decisioni

Deciso: l'ordine di attacco (stampanti per prime, solo switch e firewall), il numero e la
natura dei segmenti target (cinque, con IoT/OT separato), il rinvio della scelta di
indirizzamento al censimento.

Da decidere, nell'ordine in cui servira': se aggiungere un sesto segmento di gestione
degli apparati (raccomandato, vedi §Il segmento che il censimento fa emergere) oppure
tenere la gestione dentro il segmento server; conferma formale degli ID VLAN 10/20/30/50/60;
`Interface Type` del segmento stampanti (`internal` per uniformita' o `general` per minimo
privilegio); destinazione esatta della share di scansione sul NAS; se il segmento
stampanti debba avere una qualche uscita verso Internet per firmware e servizi cloud del
produttore; strategia di indirizzamento dopo il censimento.

Da fare prima di toccare la rete: snapshot Nebula nuovo, lettura degli ambiti e delle
riserve DHCP dal firewall, censimento degli host statici, backup datato di firewall e
switch (M3), parametrizzazione di `Set-NebulaWifiVlan.ps1` per ID VLAN e porte arbitrarie.

[^1]: *ARP*, Address Resolution Protocol - protocollo con cui un host, dovendo consegnare
un pacchetto a un indirizzo IP che ritiene nella propria rete, chiede in broadcast quale
indirizzo MAC risponde per quell'IP e consegna il frame direttamente a quello.

[^2]: *VLAN*, Virtual Local Area Network - suddivisione logica di uno switch in piu'
domini di broadcast indipendenti, identificati da un numero trasportato
nell'intestazione del frame secondo lo standard IEEE 802.1Q.

[^3]: *PVID*, Port VLAN Identifier - la VLAN assegnata ai frame che entrano da una porta
privi di tag; su una porta access e' la VLAN dell'endpoint, su un trunk e' la VLAN nativa.

[^4]: *SNAT*, Source Network Address Translation - riscrittura dell'indirizzo sorgente di
un pacchetto in uscita, necessaria perche' un host con indirizzo privato riceva le
risposte da Internet.

[^5]: *OUI*, Organizationally Unique Identifier - i primi tre byte di un indirizzo MAC,
assegnati dallo IEEE a un produttore; permettono di risalire al costruttore di un
dispositivo dal solo MAC.
