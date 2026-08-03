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

**Estensione del 03/08/2026, ed e' la correzione che pesa piu' di tutte in questa sezione.**
Il censimento chiuso a 54HP rientrato nel piano di gestione mostra che le porte con lista
esplicita non sono una ma **quattro**, e la piu' importante non era stata considerata:

| Apparato e porta | Ruolo | VLAN ammesse |
|---|---|---|
| 54HP porta 33 | uplink verso il firewall | `1, 40, 90` |
| 54HP porta 41 | access point Piano 1 | `1, 40, 90` |
| 54HP porta 45 | access point Piano 2 | `1, 40, 90` |
| 30HP porta 1 | access point Piano Terra | `1, 40, 90` |
| 54HP porta 51 | dorsale verso il Piano Terra | `all` |
| 30HP porta 29 | dorsale verso il Piano 2 | `1, 2, 40, 90` |

La porta 33 e' l'uplink a 1 Gbps verso il firewall, e ammette `1, 40, 90` ma **non la VLAN 2**:
architetturalmente corretto, perche' la fonia non passa dal firewall per progetto, ed e' la
prima volta che quel fatto viene misurato invece che dedotto. Ma ne segue che **la VLAN 30 va
aggiunta anche alla porta 33**, non solo alla 29. Vale la pena capire bene il modo in cui
questo intervento fallirebbe senza quel passo, perche' e' il piu' ingannevole di tutti: la
VLAN 30 esisterebbe sugli switch, le stampanti prenderebbero il tag, i frame arriverebbero
fino al 54HP e verrebbero scartati sull'ultimo salto, quello verso il gateway. Il segmento
non risulterebbe isolato, risulterebbe **morto**, e il sintomo per gli utenti sarebbe "le
stampanti non rispondono piu'" dopo un intervento che ogni verifica lato switch dichiarerebbe
riuscito. La diagnosi partirebbe dal posto sbagliato per almeno mezz'ora.

Ne segue anche una nota di metodo per i segmenti successivi di M22: la lista delle porte da
estendere si rilegge dallo snapshot **prima** di ogni sotto-step, non si assume dal precedente.
Fra il 15/07 e il 03/08 quel numero e' passato da zero a una a quattro senza che nessuno
cambiasse deliberatamente una lista: e' cambiato come effetto collaterale di altri interventi.

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

### Censimento eseguito: snapshot del 27/07/2026, Piano Terra completo

Lo snapshot nuovo e' stato raccolto dall'IT Manager il 27/07/2026 alle 14:54 con
`Get-NebulaSnapshot.ps1`. L'esito e' asimmetrico e va letto per quello che e': il
XGS2220-30HP del Piano Terra ha risposto a tutto, con 30 porte di configurazione e una
tabella MAC di 58 voci; il XGS2220-54HP del Piano 2 ha risposto sulla configurazione
delle 54 porte ma ha rifiutato la lettura della tabella MAC con `422 DEVICE_IS_OFFLINE`,
cioe' e' fuori dal piano di gestione (nuova occorrenza di NEB-001, `GAP-TBC.md` #101). Il
censimento e' quindi **completo per il Piano Terra e mancante per il Piano 2**, e la
seconda meta' va ripresa quando il 54HP torna gestibile.

Quadro del Piano Terra, che e' il piano da cui parte l'intervento sulle stampanti.

| Porta | Configurazione | Link | Cosa c'e' | Rilevanza per M22 |
|---|---|---|---|---|
| 1 | **trunk**, PVID 1 | 1 Gbps, PoE attivo | Access point Zyxel NWA130BE "AP piano terra", piu' due client Wi-Fi sulla VLAN 40 con MAC randomizzati | La porta e' stata convertita da access a trunk e porta VLAN 1 e VLAN 40: e' la Fase A realizzata sul nuovo hardware invece che sui vecchi AP |
| 4 | access, PVID 1 | 100 Mbps, PoE attivo | Access point Ubiquiti "EsternoIrrigazione" (unico dei quattro legacy ancora in rete) | **Portato in scope il 28/07/2026** come micro-step M13c (ADR-016, gap SEC-018): e' un Debian 7 non gestibile sulla LAN piatta. Destinazione finale il segmento IoT/OT, oppure la sparizione dell'apparato se la centrale di irrigazione si puo' cablare. La negoziazione a 100 Mbps mentre le altre porte vanno a 1 Gbps e' un indizio da verificare sulla tratta verso il tetto |
| 6 | access, PVID 1 | 1 Gbps | Apparato di stampa Kyocera | **Prima porta stampante identificata con certezza**: e' un candidato del primo giro di M22b |
| 13, 23 | access, PVID 2 | 1 Gbps | I due telefoni Yealink del Piano Terra | Conferma che il fix del 23/07 tiene; nessun impatto su M22 |
| 19 | access, **PVID 90** | nessun link | Nulla collegato | Residuo del test cablato del 22/07 mai ripristinato: una presa che consegna in rete ospiti (`GAP-TBC.md` #123) |
| 29 | **trunk**, PVID 1, Allowed `1,2,40,90` | 10 Gbps | Dorsale verso il Piano 2, 38 MAC appresi su quattro VLAN | E' la porta dove va aggiunto ogni ID VLAN nuovo: senza quello il segmento non arriva al Piano Terra |
| 2, 3, 5, 8, 10-12, 14, 16, 18, 20, 22 | access, PVID 1 | da 10 Mbps a 1 Gbps | Un solo MAC appreso ciascuna: postazioni e apparati da attribuire | Sono le porte che il censimento deve ancora attribuire per ruolo, incrociando `mappatura-porte-fisiche.md` |
| 9, 15, 17, 21, 24-28, 30 | access, PVID 1 | nessun link | Libere | Capacita' disponibile: undici porte, sufficienti per gestire una migrazione a gruppi senza scollegare nulla |

Tre acquisizioni che cambiano il piano piu' di quanto sembri. La prima e' che **i tre
access point Zyxel della Fase B sono fisicamente installati e in servizio**, non solo
registrati: quello del Piano Terra e' appreso sulla porta 1 del 30HP, e quelli del Piano 1
e del Piano 2 sono appresi attraverso la dorsale, quindi sono attestati sul 54HP e
online. La seconda e' che dei quattro access point Ubiquiti legacy nella tabella MAC ne
resta uno solo, l'EsternoIrrigazione: i tre sostituiti non compaiono piu', coerentemente
con una sostituzione avvenuta. La terza e' che la porta 1, che era access, e' ora un trunk
che porta la VLAN 40: l'isolamento della Wi-Fi staff che M13a aveva tentato e ripristinato
sui vecchi AP e' operativo sul nuovo hardware, ed e' il motivo per cui i due SSID
funzionano.

Sulla domanda specifica della localizzazione degli AP per prefisso Ubiquiti, che era il
metodo usato il 14/07 per trovarli, l'esito oggi e' questo: l'unico MAC Ubiquiti presente
e' quello dell'EsternoIrrigazione sulla porta 4 del 30HP. I tre AP legacy di Piano Terra,
Piano 1 e Piano 2 non sono piu' nelle tabelle MAC, e per confermarlo definitivamente sul
Piano 2 serve la tabella del 54HP, oggi non leggibile.

### Cosa era ricavabile dallo snapshot precedente

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

Due limiti di quello snapshot ne hanno motivato la ripetizione: era anteriore agli
interventi del 23/07, quindi non conteneva le porte telefono del 30HP portate su PVID 2
ne' la lista VLAN esplicita sulla porta 29, e per lo XGS2220-30HP la tabella MAC era
assente, cioe' mancava proprio per il Piano Terra. La raccolta del 27/07 ha colmato
esattamente quel buco, invertendo pero' l'asimmetria: ora manca il Piano 2.

### Code di stampa: rilevate il 28/07/2026, sono code dirette per indirizzo

Rilevamento eseguito su una postazione reale con `Get-Printer` e `Get-PrinterPort`. Esito
netto: **non esiste un server di stampa e non ci sono code WSD**. Le code sono dirette
"Standard TCP/IP" e puntano all'indirizzo della stampante, con il nome di porta nella forma
`IP_<indirizzo>`. Siamo quindi nel caso intermedio dei tre previsti: spostare una stampante
in un segmento nuovo cambia il suo indirizzo, e ogni postazione che la usa va toccata una
volta per ri-puntare la coda.

Due dettagli del rilevamento cambiano la stima del lavoro, entrambi in meglio. Il primo e'
che **le code sono installate per piano e non tutte su tutti**: la postazione esaminata ha
la sola multifunzione del proprio piano, non l'intero parco. Il costo del ri-puntamento non
e' quindi numero di PC per numero di stampanti, ma la somma delle code effettivamente
installate, e va misurata sull'inventario dell'RMM invece che stimata. Il secondo e' che
sulla stessa postazione convivono **due porte verso lo stesso indirizzo**, una nella forma
`IP_<indirizzo>` e una nella forma `IP_2_<indirizzo>`, con la coda attiva che usa la
seconda: e' la traccia di un ri-puntamento gia' avvenuto in passato, fatto creando una
porta nuova invece di modificare quella esistente. La porta orfana e' innocua ma va
inclusa nella pulizia, perche' altrimenti alla prossima migrazione ci si trovano tre porte
per due indirizzi e non si capisce piu' quale sia viva.

Ne segue la raccomandazione operativa, che era gia' nel piano e ora ha una base misurata:
il ri-puntamento si fa una volta sola e conviene farlo **verso un nome** invece che verso
un indirizzo, distribuendo il nome con lo stesso RMM che distribuira' lo script. Da quel
momento ogni spostamento successivo di una stampante non tocca nessuna postazione, perche'
cambia solo cio' a cui il nome punta. E' il primo caso concreto in cui l'assenza di
risoluzione nomi interna (gap SEC-016) si traduce in lavoro manuale ripetuto.

### Le stampanti identificate

| Apparato | Indirizzo | Dove | Come e' stato identificato |
|---|---|---|---|
| Multifunzione Kyocera TASKalfa 2552ci | `10.61.30.10` | Piano Terra, porta 6 del XGS2220-30HP, access PVID 1, 1 Gbps | Correlazione tra la tabella MAC dello snapshot del 27/07 e il nome host di fabbrica dell'apparato, che Kyocera deriva dagli ultimi tre byte del MAC: i due coincidono |
| Multifunzione Canon DXC 5840 | `10.61.30.133` | Piano 1 (dalla denominazione della coda) | Coda di stampa sulla postazione esaminata il 28/07; porta fisica non ancora attribuita, richiede la tabella MAC del 54HP |

La correlazione nome host - MAC merita una nota di igiene documentale, perche' e' un caso
non ovvio della regola di anonimizzazione: il nome di fabbrica di questi apparati
*contiene* meta' del MAC reale, quindi scriverlo per esteso in un file tracciato
equivarrebbe a pubblicare il MAC che la regola impone di sostituire. Nei file tracciati si
cita percio' il modello e la forma del nome, non il nome stesso; la corrispondenza completa
sta nella mappa privata.

### Accesso amministrativo alle multifunzione, e perche' riguarda M22

Entrambe le multifunzione hanno un pannello amministrativo web raggiungibile dalla LAN, e
l'accesso e' disponibile: la Kyocera espone Command Center RX su HTTPS, con redirezione
automatica dalla porta 80, la Canon la propria Remote UI. Le credenziali non sono scritte
qui ne' in nessun altro file di questo repository, che e' pubblico, e vanno conservate nel
password manager aziendale sulla VM202 — e' la stessa igiene che i gap SEC-007, SEC-010 e
SEC-011 chiedono per tutti i segreti operativi oggi sparsi nel filesystem.

Un fatto emerso proprio da questa verifica va pero' trattato come parte del progetto e non
come nota a margine: la Kyocera e' protetta dalla **coppia di credenziali di fabbrica** del
produttore, quella documentata pubblicamente per la sua linea (gap SEC-019,
`GAP-TBC.md` #125). Riguarda M22 direttamente, per due motivi. Il primo e' che il pannello
amministrativo di una multifunzione governa indirizzamento, protocolli esposti e rubrica
delle destinazioni di scansione, cioe' esattamente le cose che questo micro-step va a
cambiare. Il secondo, piu' importante ai fini della protezione dei dati, e' che una
destinazione di scansione verso una cartella di rete richiede le credenziali di accesso a
quella condivisione, e l'apparato le conserva al proprio interno: un accesso
amministrativo con password di fabbrica e' quindi anche una strada verso le credenziali di
un account che scrive su una share aziendale. Ne segue che il cambio della credenziale di
fabbrica non e' un'attivita' separata da rimandare, ma va fatto nello stesso passaggio in
cui si riconfigurano le destinazioni di scansione, perche' e' la stessa schermata e lo
stesso apparato.

Sul metodo, una nota utile per il futuro: il pannello della Kyocera non e' interrogabile da
riga di comando. La radice risponde ma ogni percorso interno restituisce errore, perche'
Command Center RX e' un'applicazione a frame guidata da JavaScript che si aspetta la propria
sequenza di richieste; ne' l'aggiunta di una sessione ne' un User-Agent da browser cambiano
l'esito. La lettura dei valori di rete di questi apparati resta quindi un'operazione
manuale, da pannello web o da display, e va messa in conto nel tempo dell'intervento invece
di sperare in uno script.

### Configurazione di rete della Kyocera, letta dal pannello il 28/07/2026

Lettura diretta da Command Center RX, `Impostazioni di rete > TCP/IP`. E' la
configurazione di partenza dell'apparato che apre il primo giro di M22b, e va conosciuta
riga per riga perche' meta' di queste voci cambia con la migrazione e l'altra meta' decide
*come* si puo' migrare.

| Voce | Valore attuale | Cosa comporta per M22b |
|---|---|---|
| TCP/IP | On | — |
| **DHCP** | **Off** | Indirizzamento **statico sull'apparato**: l'inferenza fatta dall'assenza di un ambito DHCP sulla classe stampanti e' confermata. Il giorno della migrazione l'indirizzo va cambiato sul pannello, a meno di convertire prima in riserva DHCP |
| Auto-IP | Off | Nessun rischio di indirizzi 169.254 in caso di DHCP assente |
| Indirizzo IP | `10.61.30.10` | Diventera' un indirizzo nel nuovo segmento |
| **Subnet mask** | **255.255.224.0** | E' una `/19`, coerente con la LAN piatta: **nessun difetto preesistente di maschera**, il sospetto e' rientrato. Con la migrazione diventera' una `/24` |
| Gateway predefinito | `10.61.30.1` | E' l'alias `lan1:2` del firewall, non il gateway della classe postazioni: l'apparato e' gia' configurato per uscire dal firewall, che semplifica il passaggio al gateway del nuovo segmento |
| Nome dominio | vuoto | — |
| **Server DNS** | selezionato "usa i seguenti", ma **entrambi i campi vuoti** | L'apparato **non risolve nomi**. Conseguenza diretta: le destinazioni di scansione devono essere indirizzi IP, non nomi, e lo stesso vale per qualunque riferimento a un NAS. Se in futuro si vuole usare un nome, va prima configurato un server DNS sull'apparato |
| **Server WINS** | selezionato "usa i seguenti", entrambi vuoti | Nessuna risoluzione nomi NetBIOS: conferma la riga precedente sul lato condivisioni SMB |
| Nome host | da impostazione dispositivo (nome di fabbrica derivato dal MAC) | Resta invariato; e' il nome che compare in mDNS |
| IPv6 | Off | Semplifica: un solo piano di indirizzamento da migrare |
| **Bonjour** | **On**, con nome di servizio `Kyocera TASKalfa 2552ci` | E' la conferma dal pannello del comportamento mDNS misurato dalla postazione. Da disabilitare come parte dell'irrobustimento: dopo la segmentazione non serve piu' a nessuno, perche' non attraversa il confine, e resta solo come annuncio in multicast |
| **Filtri IP (IPv4)** | disponibili, non ispezionati | **E' una mitigazione immediata disponibile oggi**: l'apparato puo' limitare da quali indirizzi accetta connessioni, quindi l'accesso amministrativo si puo' restringere alle sole postazioni IT senza attendere la segmentazione (vedi SEC-019) |
| Stampanti logiche | disponibili, non ispezionate | Da controllare al momento del ri-puntamento: se sono in uso, cambiano le porte a cui puntano le code |
| IPSec | Off | Nessuna cifratura del traffico verso l'apparato; irrilevante nel breve, da annotare per A.8.24 |

Due elementi operativi che il pannello stesso dichiara e che vanno nel piano. Il primo e'
che le modifiche a questa pagina si applicano solo dopo `Invia` **e un riavvio della rete o
del dispositivo**: cambiare indirizzo non e' istantaneo e comporta una breve
indisponibilita' dell'apparato, quindi va fatto in una finestra dichiarata e non a stampa in
corso. Il secondo, minore ma utile, e' che il campo `Posizione` dell'apparato e' vuoto:
compilarlo con l'ubicazione fisica reale costa nulla e rende l'inventario leggibile dal
pannello stesso, che e' il punto in cui lo si consulta quando si e' davanti alla macchina.

La conseguenza piu' importante di tutta questa lettura riguarda pero' l'ordine dei passi.
Poiche' l'apparato ha indirizzo statico e non risolve nomi, la strada piu' pulita non e'
cambiare l'indirizzo a mano il giorno della migrazione, ma **convertirlo prima in riserva
DHCP** nell'ambito del nuovo segmento: si crea l'ambito, si registra la riserva per MAC, si
porta l'apparato da statico a DHCP, e da quel momento ogni cambio di indirizzo futuro e'
una modifica sul firewall e non un intervento sull'apparato. E' lo stesso principio del
ri-puntamento delle code verso un nome: si paga una volta la conversione e si smette di
pagare a ogni cambiamento.

### Le destinazioni di scansione, lette il 29/07/2026: quattro su quattro verso postazioni

La rubrica della multifunzione del Piano Terra e' stata letta voce per voce. L'esito e'
netto e conferma per misura quello che NET-009 registrava come osservazione: **tutte e
quattro** le destinazioni configurate sono cartelle di rete SMB su porta 445 e puntano a
condivisioni di **singole postazioni** nella classe delle postazioni, con percorsi del tipo
`SCANNER` o `Scanner_<nome>`. Nessuna punta a un NAS, nessuna e' di tipo e-mail, i campi
FTP sono vuoti su tutte. Per ciascuna voce l'apparato conserva nome utente e password di
accesso alla condivisione, e in almeno un caso l'utenza e' il nome e cognome di una persona
fisica invece di un account di servizio.

| Destinazione | Tipo | Host | Percorso | Utenza memorizzata |
|---|---|---|---|---|
| Postazione di Persona-D | SMB (cartella) | `10.61.10.19` | `SCANNER` | utenza generica |
| Postazione di Persona-E | SMB (cartella) | `10.61.10.74` | `Scanner` | utenza generica |
| Postazione di Persona-C | SMB (cartella) | `10.61.10.20` | `SCANNER` | **nome e cognome della persona** |
| Postazione dell'IT Manager | SMB (cartella) | `10.61.10.73` | `Scanner_<nome>` | utenza generica |

Questo dato cambia due cose nel piano, una in peggio e una in meglio.

In peggio, dimensiona il lavoro nascosto di M22b: la riga "stampanti verso postazioni
negato" della matrice dei flussi non e' una restrizione teorica, e' la disattivazione di
quattro destinazioni di scansione realmente in uso. Se si spostasse la porta della
stampante senza preparare le destinazioni sostitutive, quattro persone perderebbero la
scansione lo stesso giorno, e la perderebbero in modo silenzioso: la macchina accetta il
lavoro e poi fallisce l'invio. Il passo "share di scansione prima dello spostamento" era
gia' nel piano ed e' confermato come vincolante.

In meglio, e questo e' il punto piu' utile emerso oggi, quel passo **non ha bisogno della
segmentazione**. Creare la share dedicata sul NAS, spostarvi le quattro destinazioni e
verificarle si puo' fare adesso, sulla rete piatta, senza toccare nessuna VLAN e senza
finestra di manutenzione: il beneficio di governo dei dati arriva subito e il giorno della
migrazione quel fronte e' gia' chiuso. E' stato quindi staccato dal micro-step strutturale e
tracciato come intervento non bloccante R8 nel registro
`docs/interventi-robustezza.md`, con R9 per la sostituzione dell'utenza nominale con un
account di servizio.

Un dettaglio che conferma la coerenza di tutto il quadro: le destinazioni sono indirizzi e
non nomi, come deve essere, perche' l'apparato non ha alcun server DNS ne' WINS configurato
(vedi la lettura della configurazione di rete sopra). Quando le destinazioni si spostano sul
NAS, va usato l'indirizzo del NAS per la stessa ragione.

**Censimento chiuso il 29-30/07/2026 su entrambe le multifunzione.** La Canon del Piano 1 ha
sette destinazioni registrate nel proprio elenco a selezione veloce, e sono sette su sette
cartelle di rete SMB verso condivisioni di postazioni: nessuna e-mail, nessun FTP. Il totale
sui due apparati e' quindi undici destinazioni che si riducono a **sette destinatari
distinti**, perche' le quattro della Kyocera sono un sottoinsieme delle sette della Canon.
Rilevanza per M22b: le regole della matrice dovranno reggere sette percorsi e non quattro, e
la preparazione delle destinazioni sostitutive dimensiona il lavoro preliminare in modo
proporzionato.

Due aggravanti della seconda rubrica che toccano direttamente il progetto di segmentazione.
Due destinazioni su sette puntano alla postazione per **nome NetBIOS** invece che per
indirizzo: funzionano oggi perche' la risoluzione NetBIOS avviene in broadcast dentro il
dominio di livello 2, e sono le prime due che si romperebbero attraversando un confine
instradato — terza forma della stessa trappola dopo mDNS sulle stampanti e l'assenza di un DNS
interno, e conferma che su questa rete la risoluzione nomi e' interamente affidata al
broadcast. E su tutte e sette le voci la **conferma della destinazione prima dell'invio e'
disattivata**, quindi oggi una selezione sbagliata dal display deposita documenti nella
cartella di un'altra persona senza alcun passaggio che permetta di accorgersene: e' un difetto
indipendente dalla rete, tracciato come intervento R11.

Il censimento non era completo con la sola macchina del Piano Terra: la seconda multifunzione,
la Canon del Piano 1, ha una rubrica indipendente e andava letta prima di dimensionare
l'intervento,
perche' i due insiemi di destinatari si **uniscono** e non si sommano — chi lavora su due
piani puo' comparire in entrambe. Il conteggio complessivo dei destinatari distinti e' anche
il criterio che decide la strategia di R8 tra cartelle condivise separate e autorizzazioni
per sottocartella, con la soglia fissata a sei prima di conoscere il numero, per non piegare
il numero alla soluzione preferita (vedi `docs/interventi-robustezza.md` §Passo zero). Nota
tecnica emersa provando: nemmeno il pannello della Canon e' interrogabile da riga di comando,
perche' la sua pagina di autenticazione cifra la password nel browser combinandola con un
*challenge* di sessione e una chiave pubblica RSA — motivo diverso da quello della Kyocera,
stesso esito, e conferma che l'inventario di questi apparati resta un lavoro manuale da
mettere in conto nei tempi.

### Baseline funzionale pre-migrazione, misurata il 28/07/2026

Le misure prese *prima* di cambiare qualcosa sono l'unico riferimento con cui giudicare le
misure prese dopo. Questa e' la baseline delle due multifunzione dalla postazione dell'IT
Manager, che sta nella classe delle postazioni.

| Misura | Kyocera `10.61.30.10` | Canon `10.61.30.133` | Cosa dimostra |
|---|---|---|---|
| Ping | risponde, RTT 0 ms | non misurato | Raggiungibilita' L3 di base |
| TCP 9100 (stampa RAW) | connessione riuscita | connessione riuscita | E' la misura che conta: una stampante puo' ignorare il ping e stampare benissimo, quindi la porta di stampa e' il vero test |
| NextHop della rotta | `0.0.0.0` | idem per costruzione | Consegna diretta sullo stesso livello 2, cioe' la conferma operativa che oggi il firewall non e' sul percorso (NET-009) |
| Risoluzione del nome | risponde il nome mDNS `<nome di fabbrica>.local` | non verificata | **Su questa rete mDNS funziona**, e questo apre la trappola descritta sotto |

Dopo la migrazione le stesse quattro misure vanno rifatte con un'attesa diversa e
dichiarata: ping e TCP 9100 devono continuare a riuscire, il NextHop deve diventare
l'indirizzo del gateway del segmento delle postazioni — ed e' proprio quel cambiamento a
dimostrare che il traffico ora attraversa il firewall — e la risoluzione mDNS **deve**
smettere di funzionare, perche' e' basata su multicast e non attraversa un confine di
livello 3.

### La trappola mDNS nel ri-puntamento delle code

Il piano prevede di ri-puntare le code verso un nome invece che verso un indirizzo, per
rendere gratuiti gli spostamenti futuri. La misura di oggi mostra che su questa rete un
nome esiste gia' ed e' comodo, quello mDNS[^7] in `.local` pubblicato dall'apparato stesso:
sarebbe la scelta piu' rapida ed e' esattamente quella sbagliata, perche' mDNS si risolve
via multicast dentro un dominio di broadcast e cessa di funzionare nel momento in cui la
stampante finisce in un segmento diverso. Ri-puntare le code al nome `.local` significa
costruire una coda che funziona oggi e si rompe il giorno della migrazione, cioe' spostare
il guasto in avanti invece di eliminarlo.

Il nome da usare deve essere risolvibile in unicast: una voce `hosts` distribuita
dall'RMM, che e' la strada immediatamente disponibile perche' non esiste un DNS di LAN
(gap SEC-016), oppure un record in un servizio di risoluzione nomi interno se e quando
verra' introdotto. Da qui una conseguenza sull'inventario delle code da estrarre
dall'RMM: non basta contare le code, va anche verificato se qualcuna punta gia' a un nome
`.local`, perche' quelle sono le prime a rompersi e non se ne accorgerebbe nessuno fino al
primo tentativo di stampa.

### Censimento degli indirizzi: chiuso in gran parte dallo snapshot RMM del 30/07/2026

L'interrogazione delle interfacce di rete per dispositivo dell'RMM ha restituito, per la sola
organizzazione Intrawelt, 1381 righe di adattatori su 26 dispositivi gestiti, che si
riducono a **75 indirizzi IPv4 distinti su 25 dispositivi**. E' il censimento che si voleva
evitare di fare postazione per postazione, e la sua lettura aggregata dice tre cose.

Ventisei indirizzi stanno nella classe delle postazioni con maschera `/19` e gateway
`10.61.10.1`: sono le macchine in sede, coerenti con `lan1` del firewall, e sono la
popolazione che M22e dovra' spostare. Quattro indirizzi stanno su altri segmenti aziendali,
due nella classe dei server e due nella VLAN 40 della Wi-Fi staff, che e' la conferma
indipendente che quel segmento e' in uso. Undici indirizzi stanno in una classe `192.168.1.x`
con gateway `.1.1`: non sono rete aziendale, sono le reti domestiche dei portatili fuori sede,
e vanno esclusi dal censimento invece di essere confusi con indirizzi interni. Il resto sono
adattatori virtuali e di VPN, riconoscibili perche' hanno gateway nullo o maschere estranee al
piano aziendale.

Un limite metodologico va dichiarato, perche' e' esattamente la domanda a cui il censimento
doveva rispondere: l'interrogazione riporta l'indirizzo **corrente**, non se sia statico o
assegnato dal DHCP. La distinzione si chiude incrociando questi indirizzi con l'ambito DHCP
del firewall — che parte da `10.61.10.200` con 55 assegnazioni — e con le riserve: gli
indirizzi in sede che cadono fuori da quell'intervallo sono statici o riservati, coerentemente
con i ventidue PC dichiarati come oggetto indirizzo nella configurazione del firewall. Resta
quindi da leggere dalla GUI del firewall un solo dato, le riserve, e il censimento e' completo.

### Censimento chiuso: 22 statici e 4 dinamici sulle postazioni (30/07/2026)

L'ultimo dato mancante e' arrivato dalla verifica diretta dell'ambito DHCP di `lan1` sul
firewall: intervallo che parte da `10.61.10.200` con dimensione 55, quindi da `.200` a `.254`,
lease di due giorni. Incrociandolo con i ventisei indirizzi della classe postazioni censiti
dall'RMM, la ripartizione si chiude per aritmetica e senza aprire una postazione:

| Insieme | Numero | Dove cadono |
|---|---|---|
| Indirizzi **fuori** dall'ambito DHCP, quindi statici o riservati | **22** | da `.17` a `.95` |
| Indirizzi **dentro** l'ambito DHCP | **4** | `.206`, `.208`, `.209`, `.248` |

Il numero 22 e' la corroborazione indipendente piu' pulita ottenuta in questo progetto:
coincide esattamente con i ventidue PC dichiarati come oggetto indirizzo nella
configurazione del firewall, contati da una fonte completamente diversa. Va invece corretto
l'intervallo documentato per quegli statici, che la scheda firewall riportava come `.18-.84`
mentre la misura mostra `.17-.95`.

Cosa significa per il piano di migrazione. Per quattro postazioni il cambio di indirizzo e'
gratuito: seguono il DHCP e non richiedono alcun intervento sulla macchina. Per ventidue
serve un tocco a testa, ed e' qui che si decide la strategia — convertirle in **riserve** nel
nuovo ambito, cosi' che l'indirizzo torni a essere governato dal firewall e ogni cambio
successivo sia centrale, invece di ripetere la configurazione statica sulla macchina. E'
la stessa scelta fatta per le stampanti in R7, per la stessa ragione: si paga una volta la
conversione e si smette di pagare a ogni cambiamento.

Resta un solo raffinamento, non bloccante: sapere quante di quelle ventidue siano statiche
*sull'apparato* e quante siano gia' riserve DHCP sul firewall. Cambia solo la quantita' di
lavoro manuale del giorno della migrazione, non il disegno, e si legge dalla tabella delle
assegnazioni statiche nello stesso dialogo dell'ambito.

### Cosa resta da raccogliere, e come

Il primo elemento e' la tabella MAC del XGS2220-54HP, che completa il censimento sul
Piano 2 e permette anche di chiudere la verifica sui tre access point legacy. Richiede che
lo switch sia tornato gestibile da Nebula: la lettura si ripete con lo stesso script, in
sola lettura, senza toccare la configurazione.

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
5. **Code di stampa**: rilevare su una postazione reale come sono configurate (server di
   stampa, coda diretta Standard TCP/IP, coda WSD), poi predisporre il ri-puntamento —
   nome invece di indirizzo dove possibile, script NinjaOne come veicolo — e riservare
   l'indirizzo di ogni stampante per MAC nel nuovo ambito DHCP, cosi' che l'indirizzo sia
   stabile e governato dal firewall invece che digitato sul pannello dell'apparato.
6. **Trunk, due porte e non una** (corretto il 03/08/2026): aggiungere l'ID 30 alla lista
   delle VLAN ammesse della porta 29 del 30HP **e della porta 33 del 54HP**, verificando a
   schermo entrambe. La 29 e' la dorsale e la sua necessita' era gia' nota dalla lezione
   della VLAN 2; la 33 e' l'uplink verso il firewall e ammette `1, 40, 90`, quindi senza
   quel passo il segmento nuovo non raggiunge mai il proprio gateway — il segmento non
   risulta isolato, risulta morto, e il sintomo e' "le stampanti non rispondono" dopo un
   intervento che ogni verifica lato switch dichiara riuscito. La porta 51 del 54HP e' su
   `All` e non richiede modifiche, e su quel core switch la lista esplicita resta
   deliberatamente non introdotta perche' il rischio supera il beneficio. Regola non
   negoziabile appresa il 23/07 al costo di un blackout del piano di gestione: il PVID e'
   un valore singolo, la lista sta solo in `Allowed VLANS`.
7. **Una porta stampante per volta** su access con PVID 30: verificare che l'apparato
   prenda indirizzo nel nuovo ambito, che una stampa di prova esca, che una scansione
   arrivi nella share dedicata e che il tentativo di scrivere in una cartella di
   postazione ora fallisca. Solo dopo passare alla successiva.
8. **Pulizia**, a migrazione completa: rimuovere riserve e oggetti indirizzo diventati
   inutili sulla vecchia convenzione `.30`, e togliere il vecchio ambito solo quando
   nessun apparato lo usa piu'.

Criterio di rollback, uniforme su tutti i passi: se un apparato non prende indirizzo entro
due tentativi DHCP, si riporta quella singola porta al PVID precedente e si indaga a
freddo, senza proseguire con le altre. Il rollback e' sempre una sola modifica su una sola
porta, che e' precisamente il motivo per cui si procede una porta alla volta.

### Requisito vincolante: non si rompe niente, e un PC continua a raggiungere stampante e NAS

E' un requisito posto esplicitamente dall'IT Manager e va trattato come tale, non come
buon senso implicito. Vale la pena capire *cosa* esattamente rischia di rompersi, perche'
non e' il routing: quello si autorizza con una regola e funziona. Segmentare rompe altre
due cose, e sono entrambe prevedibili.

La prima e' la **scoperta basata su broadcast**. Dentro un dominio di broadcast i
meccanismi che trovano le cose da soli funzionano: la sezione Rete di Esplora risorse, la
scoperta WSD[^6] delle stampanti, mDNS/Bonjour. Attraversando un confine di livello 3
smettono, perche' i broadcast non vengono inoltrati. Non si rompe l'accesso, si rompe il
*trovare da soli*: una share raggiunta per percorso `\\indirizzo\condivisione` continua a
funzionare, una raggiunta cliccando su un'icona apparsa in Rete no.

La seconda, che e' quella che conta davvero qui, e' che **ogni riferimento scritto per
indirizzo IP si rompe quando quell'indirizzo cambia**. Su questa rete i riferimenti per
indirizzo sono la norma e non l'eccezione: le unita' di rete mappate con `net use` verso i
NAS, le voci nei file `hosts` delle postazioni (che qui sono un meccanismo in uso
deliberato, non un residuo — vedi NAS-HERO e il portale sulla VM208), i job di backup, i
license server, e le code di stampa. Non esiste un DNS di LAN che faccia da livello di
indirezione (gap SEC-016): questo e' il vero moltiplicatore di costo di qualunque
rinumerazione.

Da qui la regola d'oro della migrazione, che riscrive l'ordine in modo non ovvio: **si
spostano i client, non gli endpoint referenziati**. Un PC che cambia indirizzo non rompe
niente, perche' nessuno lo cerca per indirizzo; un NAS che cambia indirizzo rompe
simultaneamente le unita' mappate di tutte le postazioni, i job di backup e le voci
`hosts`. Ne segue che NAS e server restano dove sono fino all'ultimo passo possibile, e
che l'accesso da un PC migrato verso un NAS non migrato e' semplicemente traffico
instradato che la matrice dei flussi consente (SMB da PC verso server): il PC continua a
raggiungere il NAS, con il firewall in mezzo che ora puo' vederlo e registrarlo, che e'
tutto il guadagno dell'operazione. E' anche il motivo per cui M22e, i segmenti postazioni
e server, viene per ultimo e non per primo.

Le stampanti sono l'eccezione a questa regola, ed e' giusto guardarla in faccia: una
stampante *e'* un endpoint referenziato, perche' ogni coda di stampa punta al suo
indirizzo. Spostarla nel segmento nuovo significa cambiarle indirizzo, e quindi rompere la
coda su ogni PC che la usa, a meno di fare una delle tre cose seguenti. La verifica
preliminare, che decide tutto, e' come sono configurate le code oggi: se passano da un
server di stampa, spostare la stampante non tocca nessun PC, perche' cambia solo il tratto
server-stampante; se sono code dirette "Standard TCP/IP" verso l'indirizzo, ogni PC va
toccato una volta; se sono code WSD, non si ri-puntano affatto e vanno ricreate come
TCP/IP, perche' WSD si appoggia proprio alla scoperta broadcast che il confine L3 taglia.
In questo repository non risulta documentato nessun server di stampa, quindi l'ipotesi di
lavoro e' code dirette, da confermare su una postazione reale prima di procedere.

Con code dirette le strade sono due, e conviene la seconda. Ri-puntare le code
centralmente con uno script distribuito via NinjaOne, che e' l'RMM gia' in uso su tutti gli
endpoint, e' il percorso piu' rapido e ha un costo una volta sola. Introdurre invece un
nome per ogni stampante e puntare le code al nome — un DNS interno, o in mancanza di quello
una voce `hosts` distribuita dallo stesso RMM — costa quasi lo stesso oggi e rende gratuiti
tutti gli spostamenti futuri, oltre a chiudere in parte il gap SEC-016 sulla risoluzione
nomi fatta a mano. E' la scelta che rende la rete piu' facile da cambiare la prossima
volta, che dopo questo progetto e' un criterio che vale piu' della rapidita'.

Terza cosa che va comunicata invece che scoperta: lo **scan-to-folder verso le cartelle
utente smette di funzionare per progetto**, non per errore. E' l'obiettivo dichiarato della
riga "stampanti verso PC negato" della matrice. Per questo la share di scansione sul NAS e
la riconfigurazione delle destinazioni sulle multifunzione precedono lo spostamento delle
porte, e per questo agli utenti va detto dove finiranno le scansioni prima che se ne
accorgano da soli.

Ultimo elemento, che e' anche il precedente da non ripetere: il 07/07/2026 taggare la VLAN 1
sulla dorsale fece perdere agli endpoint Windows l'accesso al NAS-HERO, senza che nessun
file `hosts` fosse cambiato (NET-008, `GAP-TBC.md` #102). La causa non e' mai stata isolata
con certezza, l'ipotesi resta un native VLAN mismatch sul trunk. La lezione operativa e'
che su questa rete **il traffico verso i NAS e' il canary**: ogni passo di M22 si verifica
con una lettura e una scrittura su una share NAS, non con un ping, perche' il ping
sopravvive a difetti che SMB non sopravvive.

### Verifica funzionale di ogni passo

La stessa checklist per ogni porta spostata, da eseguire prima di passare alla successiva.
Non e' una formalita': e' cio' che rende il rollback una decisione di trenta secondi invece
di un'indagine.

| Verifica | Esito atteso | Perche' |
|---|---|---|
| Indirizzo assunto dall'apparato | Nel nuovo ambito DHCP del segmento | Conferma che il PVID e' attivo e il DHCP del firewall risponde attraverso il trunk |
| Gateway del proprio segmento | Risponde | Conferma che l'interfaccia sul firewall e' su e la VLAN attraversa la dorsale |
| Lettura **e** scrittura su una share NAS | Entrambe riuscite | E' il canary di questa rete (NET-008): il ping non basta |
| Stampa di prova dalla postazione di riferimento | Esce | Verifica la regola PC verso stampanti e la coda ri-puntata |
| Scansione verso la share dedicata | Arriva nella share | Verifica la nuova destinazione e la regola stampanti verso server |
| Scansione verso una cartella di postazione | **Fallisce** | E' la conferma che l'obiettivo di sicurezza e' raggiunto, non un difetto |
| Navigazione Internet, dove prevista dalla matrice | Coerente con la matrice | Verifica il mascheramento e la regola di uscita |

### Due pulizie da fare prima, e una decisione che il censimento ha aperto

Il censimento ha fatto emergere due residui da chiudere prima di aggiungere segmenti
nuovi, perche' sono entrambi difetti dello stesso tipo di quelli che M22 vuole eliminare.
Il primo e' la porta 19 del 30HP, ancora su PVID 90: e' una presa del Piano Terra che
consegna chi si collega direttamente nella rete ospiti, cioe' una segmentazione al
contrario, e va riportata a PVID 1 (`GAP-TBC.md` #123). Il secondo e' la pagina 2 degli
oggetti indirizzo del firewall, mai verificata, dove possono restare riferimenti alla
vecchia subnet staff: la pulizia va fatta nello stesso passaggio in cui si leggono gli
oggetti per il censimento, perche' e' la stessa pagina.

La decisione aperta riguarda invece le protezioni di livello 2 sul DHCP. La verifica del
23/07 ha stabilito che sul 30HP il DHCP Server Guard, che e' il nome Zyxel del DHCP
snooping, e l'IP source guard sono entrambi disattivati (`GAP-TBC.md` #122, NET-012).
Questo significa che oggi qualunque dispositivo collegato a una presa puo' rispondere a
una richiesta DHCP e dirottare i client su un gateway e un DNS arbitrari, senza che lo
switch se ne accorga, e su una LAN piatta l'effetto e' l'intera `/19`. Il meccanismo vale
la spiegazione perche' e' il tranello classico di questa funzione: lo snooping accetta le
risposte DHCP solo dalle porte marcate *trusted* e le scarta da tutte le altre, quindi se
si attiva senza marcare come trusted la porta da cui arrivano le offerte legittime — che
su un segmento servito dal firewall e' il trunk — si finisce per bloccare il DHCP vero e
i client non prendono indirizzo. E' esattamente l'ipotesi che avevamo formulato per i
telefoni muti prima di scartarla. La proposta e' quindi di abilitare snooping e IP source
guard **contestualmente a ciascun segmento nuovo**, marcando trusted il solo trunk verso
il firewall, invece di attivarli in blocco sulla rete piatta: segmento per segmento la
lista delle porte trusted e' corta, verificabile e reversibile.

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

[^7]: *mDNS*, multicast DNS - meccanismo di risoluzione nomi senza server in cui ogni
dispositivo risponde per il proprio nome nel dominio `.local` a una richiesta inviata in
multicast sulla rete locale; per costruzione non attraversa un router, quindi funziona
dentro un segmento e cessa di funzionare tra segmenti diversi.

[^6]: *WSD*, Web Services for Devices - meccanismo Windows con cui una stampante viene
scoperta e installata automaticamente annunciandosi in rete; si appoggia a messaggi
multicast/broadcast e quindi non funziona attraverso un confine di livello 3, a differenza
di una coda "Standard TCP/IP" che punta a un indirizzo e continua a funzionare instradata.
