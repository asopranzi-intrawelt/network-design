# Runbook Anomalie di Rete e Sicurezza – Intrawelt

Runbook operativi per le anomalie documentate in GAP-TBC.md e VA 2025.
Ogni runbook segue lo stesso schema: Verifica → Impatto → Fix → Verifica post-fix.

---

## FW-001: Regola Blocco_Gruppo_IP_Phishing_Elisa con action=ALLOW

**Severity**: CRITICA  
**Origine**: VA Onova nov 2025, confermato analisi manuale  
**Stato**: APERTO

### Contesto
La regola di sicurezza perimetrale `Blocco_Gruppo_IP_Phishing_Elisa` esiste sulla USG FLEX 500 per bloccare un gruppo di IP associati a campagne phishing/spoofing verso Elisa/gruppo. L'azione è configurata come `ALLOW` invece di `DENY`, rendendo la regola completamente inoperante.

### Verifica pre-fix

```powershell
# 1. Verifica tramite CLI SSH al firewall (o export config XML)
#    Accedere alla Web GUI: https://10.61.20.1:443 (o IP mgmt FW)
#    Security Policy > Firewall Rules > cerca "Phishing_Elisa"
#    Verificare il campo Action (deve essere DROP o REJECT, non ALLOW)

# 2. Verifica export configurazione
#    Maintenance > Configuration > Export
#    Aprire XML e cercare:
#    <action>allow</action> dentro il blocco <name>Blocco_Gruppo_IP_Phishing_Elisa</name>
```

### Procedura fix

1. Accedere alla Web GUI USG FLEX 500 come Admin
2. Navigare: `Security Policy > Policy Control > IPv4 Rules`
3. Trovare la regola `Blocco_Gruppo_IP_Phishing_Elisa`
4. Cliccare Modifica (matita)
5. Campo `Action`: cambiare da `Allow` a `Deny`
6. Salvare e applicare
7. **Non** riavviare il firewall (cambio applicato in live)

**Alternativa CLI (SSH):**
```
configure
security-policy ipv4 name "Blocco_Gruppo_IP_Phishing_Elisa"
action deny
commit
exit
```

### Verifica post-fix

```powershell
# Testare da postazione interna che un IP del gruppo sia irraggiungibile:
# 1. Estrarre un IP dal gruppo "Gruppo_IP_Phishing_Elisa" dalla Web GUI
# 2. Da cmd/PS: Test-NetConnection -ComputerName <IP_dal_gruppo> -Port 80
#    Atteso: TCP connection timeout (non refused) = firewall droppat

# 3. Verificare log firewall che compaia DROP per quel gruppo
#    Monitor > Log > Firewall: filtrare per rule name phishing
```

### Rollback
Se la modifica blocca traffico legittimo (falso positivo), ripristinare `Action = Allow` e aprire ticket di analisi gruppo IP per revisionare la composizione del gruppo.

---

## FW-002: Switch management su VLAN Guest (10.61.90.37)

**Severity**: CRITICA  
**Origine**: VA Onova nov 2025  
**Stato**: APERTO

### Contesto
L'interfaccia di management dello switch (Zyxel XGS2220-54HP o XGS2220-30HP) è raggiungibile sull'IP 10.61.90.37, che appartiene alla VLAN 90 (Guest/IoT). Chiunque sulla VLAN Guest può raggiungere e tentare di amministrare lo switch.

### Verifica pre-fix

```powershell
# Da rete LAN (VLAN 20):
Test-NetConnection -ComputerName 10.61.90.37 -Port 443
# Se risponde: switch management esposto su VLAN guest

# Verifica accesso web: aprire browser su https://10.61.90.37
# Non deve essere raggiungibile dalla VLAN utenti (e tanto meno dalla VLAN guest)
```

### Procedura fix

1. Accedere allo switch via Nebula cloud portal (https://nebula.zyxel.com)
2. Selezionare il dispositivo switch
3. Navigare a `Configure > Switch > Management`
4. Cambiare `Management VLAN` da VLAN 90 a VLAN 10 (Management/Server)
5. Impostare `Management IP`: scegliere un IP in 10.61.10.0/24 (es. 10.61.10.10)
6. Applicare la configurazione via Nebula (zero-touch)

**In alternativa (accesso locale prima della modifica):**
- CLI locale: `ip management vlan 10 ip 10.61.10.10 mask 255.255.255.0`
- Aggiornare DNS/documentazione con il nuovo IP di management

**Regola firewall da aggiungere:**
- Source: VLAN 10 (10.61.10.0/24), Destination: 10.61.10.10, Port: 443/22 → ALLOW
- Source: qualsiasi altra VLAN, Destination: 10.61.10.10 → DENY

### Verifica post-fix

```powershell
# Da VLAN Guest (o test simulato):
Test-NetConnection -ComputerName 10.61.10.10 -Port 443
# Atteso: timeout/reset (firewall blocca)

# Da VLAN management (10.61.10.x):
Test-NetConnection -ComputerName 10.61.10.10 -Port 443
# Atteso: risposta (OK)
```

---

## FW-003: DMZ VLAN 201 – Setup e isolamento

**Severity**: MEDIA (pianificato, non urgente)  
**Origine**: Design review, raccomandazione VA  
**Stato**: PIANIFICATO – Q3 2026

### Contesto
Non esiste un segmento DMZ fisico o logico. I server pubblici (se esistenti) o i servizi esposti risiedono nella stessa VLAN utenti/server. La VLAN 201 è pianificata come DMZ per isolare servizi pubblicati da internet.

### Architettura target

```
Internet → Firewall (NAT/policy) → VLAN 201 (DMZ: 10.61.201.0/24)
                                              ↓ solo policy esplicite
                                      VLAN 20 (LAN interna)
```

### Procedura di setup VLAN 201

**Fase 1 – Firewall USG FLEX 500**

1. GUI: `Network > Interface > Add`
   - Name: `dmz201`
   - Type: VLAN
   - VLAN ID: 201
   - Parent: `lan1` (bridge P4/P5/P6)
   - IP/Mask: 10.61.201.1/24
   - DHCP: Server (pool 10.61.201.10-100)
   - Zone: DMZ (creare zona se non esiste)

2. Regole firewall da aggiungere:
   - `WAN → DMZ`: DENY di default, ALLOW solo porte pubblicate (80, 443)
   - `DMZ → LAN`: DENY di default, ALLOW solo connessioni necessarie (es. DB specifico)
   - `LAN → DMZ`: ALLOW per management (porta 22/443 da VLAN 10 solo)
   - `DMZ → WAN`: ALLOW (per aggiornamenti) con log

**Fase 2 – Switch XGS2220-54HP**

Via Nebula:
1. Creare VLAN 201
2. Impostare la porta verso il server DMZ come `untagged VLAN 201`
3. La porta verso il firewall (porta 33) resta trunk (tutte le VLAN tagged)

**Fase 3 – Proxmox (se VM in DMZ)**

1. Abilitare `bridge-vlan-aware` su `vmbr0`:
   ```
   # /etc/network/interfaces su host Proxmox
   bridge-vlan-aware yes
   bridge-vids 2-4094
   ```
2. Alla VM in DMZ: assegnare interface con `vlan tag = 201`
3. La VM riceverà IP da DHCP VLAN 201 (10.61.201.x)

### Verifica

```powershell
# Da VM in DMZ: verificare routing e isolamento
# Ping verso LAN (10.61.20.1) deve essere bloccato dal firewall
# Ping verso internet deve funzionare (se regola lo permette)
Test-NetConnection -ComputerName 10.61.20.1 -Port 80
# Atteso: timeout (firewall DMZ→LAN deny)
```

---

## FW-004: Rimozione configurazione WAN_TRUNK residua (TIM dismessa)

**Severity**: BASSA  
**Origine**: Analisi post-migrazione Vianova  
**Stato**: APERTO

### Contesto
Dopo la dismissione completa della connettività TIM (luglio 2025), rimangono configurazioni residue nel firewall (WRR load balancing, oggetti TIM) che potrebbero causare confusione e route incorrette in caso di ripristino errato.

### Procedura fix

1. GUI: `Network > Interface`: verificare che WAN2 non sia più configurata con IP TIM
2. `Network > Policy Route`: rimuovere eventuali regole che referenziano l'interfaccia TIM/WAN_TRUNK
3. `Network > Trunk`: rimuovere o disabilitare WAN_TRUNK se esiste
4. `Object > Address`: eliminare oggetti address con IP TIM pubblici
5. Eseguire backup configurazione prima di ogni modifica

---

## AP-001: Access Point con Debian 7 (EOL), NON gestiti da Nebula

**Severity**: ALTA
**Origine**: VA Onova nov 2025; smentita ipotesi Nebula confermata il 14/07/2026
**Stato**: APERTO

### Contesto
Almeno tre dei cinque access point WiFi noti (0-9-1 tetto e altri due non
ancora localizzati con precisione) girano un firmware basato su Debian 7
(EOL dal 2018, Dropbear SSH aperto), con MAC vendor Ubiquiti rilevato
dalla scansione. **Verificato il 14/07/2026**: nessuno di questi AP
compare nell'organizzazione Nebula gia' usata per i due switch Zyxel —
smentisce la precedente ipotesi "AP gestiti Nebula" (`vendor-management.md`
corretta di conseguenza). La gestione reale di questi dispositivi non e'
identificata: potrebbero essere in modalita' standalone (nessun
controller) o adottati da un controller UniFi non ancora localizzato.
Questo blocca anche il progetto di rete ospiti (NET-005): senza un modo
noto di gestirli centralmente non si puo' creare in modo affidabile un
secondo SSID taggato su VLAN.

**Aggiornamento 14/07/2026**: una scansione live dell'intera classe
Guest (10.61.90.1-254, Advanced IP Scanner) non mostra piu' nessuno dei
dispositivi noti dalla VA di novembre 2025 agli stessi indirizzi — ne'
i tre presunti AP (.34/.35/.38), ne' lo switch di management (.37), l'UPS
(.33), il server MyHome (.40) o il citofono Bticino (.41). La classe
oggi risulta popolata da dispositivi diversi (vendor MAC HPE, Xiaomi,
MSI, Pegatron, ASUS — coerenti con telefoni/laptop, non con
infrastruttura). **Non e' verificato se questo significhi che i problemi
precedenti sono stati risolti** (dispositivi spostati altrove) o
semplicemente che erano spenti/non raggiungibili al momento della
scansione, o che hanno cambiato IP in 8 mesi: da chiarire prima di
considerare chiuso NET-001/FW-002/UPS-001/AP-001. Per gli AP in
particolare, dato che non sono raggiungibili ai vecchi indirizzi, il modo
piu' affidabile per localizzarli ora e' controllare via Nebula i dettagli
delle porte switch a cui sono fisicamente collegati (mappatura nota:
0-7-1, 0-9-1, 1-8-1, 2-5-1, 2-7-1) invece di cercarli per IP: lo switch,
essendo Zyxel/Nebula, mostra MAC e stato del link per porta
indipendentemente dal fatto che il dispositivo collegato non sia Zyxel.

**Strumento disponibile (14/07/2026)**: `scripts/Get-NebulaSnapshot.ps1`
interroga l'API REST ufficiale di Nebula e produce in `output/nebula-config.md`
la tabella MAC L2 per porta di ogni switch — lo stesso controllo del passo
2 sotto, ma per l'intera organizzazione in un colpo solo invece che porta
per porta a mano nel portale (vedi ADR-009). Richiede una chiave API
Nebula: icona "..." nella barra in alto di Nebula Control Center > "My
devices & services" > scheda "NCC OpenAPI Key" > Generate (percorso non
ovvio, vedi ADR-009 per il dettaglio di dove NON si trova).

**RISOLTO — tre AP localizzati per porta (14/07/2026)**: eseguito lo
script, incrociata la tabella MAC L2 di entrambi gli switch con l'elenco
delle porte trunk (per scartare le voci viste solo di riflesso attraverso
il dorsale). Risultato, tre dispositivi con lo stesso MAC vendor Ubiquiti
gia' noto dalla VA, ciascuno su una porta non-trunk (collegamento fisico
diretto, non dorsale):

| AP | Switch | Porta | Note |
|---|---|---|---|
| Ubiquiti #1 | XGS2220-54HP (Piano 2) | 41 | Non in trunk (le porte trunk di questo switch sono 49-54) |
| Ubiquiti #2 | XGS2220-54HP (Piano 2) | 45 | Idem |
| Ubiquiti #3 | XGS2220-30HP (Piano Terra) | 1 | Visto anche su XGS2220-54HP porta 52, che pero' e' la porta trunk verso il dorsale: conferma che il collegamento reale e' sul Piano Terra, non sul Piano 2 |

Corrispondenza con le cinque ubicazioni fisiche note
(`mappatura-porte-fisiche.md`: Piano Terra 0-7-1, tetto 0-9-1, Piano 1
1-8-1, CED 2-5-1, esterno tetto 2-7-1): **risolta il 15/07/2026** grazie
al nome LLDP configurato su ciascun dispositivo, letto dalla vista
Nebula "Clients" (esportazione CSV):

| Nome LLDP | MAC | IP attuale | Switch / porta | Ubicazione plausibile |
|---|---|---|---|---|
| PianoTerra | AA:BB:CC:00:00:27 | 10.61.10.200 | XGS2220-30HP porta 1 | Piano Terra (0-7-1) |
| PianoPrimo | AA:BB:CC:00:00:25 | 10.61.10.201 | XGS2220-54HP porta 41 | Piano 1 (1-8-1) |
| PianoSecondo | AA:BB:CC:00:00:26 | 10.61.10.202 | XGS2220-54HP porta 45 | CED o esterno tetto (2-5-1 / 2-7-1, ambiguo tra i due) |
| EsternoIrrigazione | AA:BB:CC:00:00:28 | 10.61.10.243 | XGS2220-30HP porta 4 | Tetto/irrigazione (0-9-1) |

**Correzione 15/07/2026**: la sessione precedente aveva classificato
EsternoIrrigazione come "vendor diverso dagli altri tre" per il prefisso
MAC differente. Riscontro diretto sul referto Nessus originale della VA
Onova (fonte: `Intrawelt_remediation_checklist_2026-05-15_15-00.html`,
righe indicate dall'utente) smentisce questo: il dispositivo e' descritto
esplicitamente come "gemello hardware" degli altri due (stesso Debian 7 +
Dropbear SSH), quindi e' Ubiquiti come gli altri tre — il prefisso MAC
diverso riflette solo un lotto/periodo di produzione diverso, non un
vendor diverso. Il referto conferma anche le tre corrispondenze IP del
06/11/2025: 10.61.90.34 = EsternoIrrigazione, 10.61.90.35 =
PianoTerra, 10.61.90.38 = PianoSecondo. **PianoPrimo (AA:BB:CC:00:00:25,
oggi .201) non compare in nessuna fingerprint di quello scan**: o era
spento/scollegato il 06/11/2025, o e' stato installato/ricollegato dopo
quella data — non deducibile da nessuna fonte disponibile, resta [TBC].

**Dashboard web: confermato assente, non solo "non trovato".** Lo scan
Nessus originale (non credenziale, quindi affidabile per il solo elenco
porte aperte) riporta come unica porta TCP aperta su questi host la 22
(Dropbear SSH). Coerente con i tentativi falliti su 443 (connessione
rifiutata) e 8443 (stesso esito) di questa sessione: questi dispositivi
non hanno mai avuto un'interfaccia web di gestione raggiungibile in rete,
non e' un problema di percorso o porta sbagliata.

**Accesso SSH: raggiunto ma non autenticato.** Superata la negoziazione
crittografica (host key + MAC algorithm obsoleti, richiede
`-o HostKeyAlgorithms=+ssh-rsa,ssh-dss -o MACs=+hmac-sha1`), le
credenziali di fabbrica `ubnt`/`ubnt` risultano cambiate. Nessuna
credenziale alternativa trovata nel vault interno (`accesso_server_accounts_vari.xls`,
oggi su NAS INTRA2 dopo la dismissione di HPX1400) ne' in nessun
documento gia' ingerito in questo progetto. Nessun controller UniFi
individuato sulla rete. **Reset di fabbrica valutato e rimandato**: e'
l'unica via per rientrare, ma disconnette all'istante tutti i client
Wi-Fi collegati in quel momento a quell'AP specifico — non eseguito
perche' disruptivo durante l'orario operativo, non per motivi tecnici.

### Decisione architetturale — segmentazione in due fasi (15/07/2026)

Dato che i tre AP legacy non sono raggiungibili senza un reset
disruptivo, la via d'accesso per risolvere sia NET-005 (isolamento Wi-Fi
dalla LAN management) sia il progetto rete ospiti (M13) passa dallo
switch/firewall, non dagli AP — quel livello e' interamente sotto
controllo (Nebula + Zyxel USG FLEX 500), indipendentemente da cosa gli
AP sanno fare.

**Fase A — segmentazione della Wi-Fi esistente, nessun hardware nuovo,
eseguibile subito.** Le tre porte gia' localizzate (XGS2220-30HP porta 1,
XGS2220-54HP porte 41 e 45) vengono configurate come access port su una
VLAN dedicata al traffico Wi-Fi staff, isolata dalla VLAN 10 management
tramite ACL sul firewall. E' comportamento 802.1Q standard lato switch:
il traffico che entra da quella porta fisica viene taggato nella VLAN
scelta indipendentemente da cosa fa l'AP a monte — l'AP non deve sapere
nulla di VLAN, non richiede nessuna configurazione su di esso. Risolve
NET-005 senza toccare i tre dispositivi legacy.

**Fase B — sostituzione pianificata, non affiancamento.** L'opzione
"aggiungere un solo AP Zyxel nuovo dedicato al solo guest, lasciando i
tre Ubiquiti a fare lo staff" e' stata scartata: se comunque serve
comprare hardware Zyxel/Nebula per avere il guest, non ha senso lasciare
in produzione tre dispositivi EOL dal 2018, non gestibili, non
aggiornabili, e con la password sconosciuta anche per l'uso attuale (se
mai servisse cambiarla — es. dopo un incidente di sicurezza o
un'uscita di personale — oggi non sarebbe possibile senza un reset). La
via piu' difendibile, anche in ottica ISO 27001 (A.8.8 Management of
technical vulnerabilities, gia' un gap aperto in `design-and-security.md`),
e' pianificare la sostituzione di tutti e quattro i punti (i tre esistenti
+ quello nuovo previsto per il guest) con AP Zyxel Nebula: multi-SSID
nativo (staff + guest sullo stesso AP fisico, ciascuno taggato sulla
propria VLAN), DPPSK per gli ospiti, gestione e aggiornamento firmware
dallo stesso pannello gia' in uso per gli switch. La Fase A resta valida
e utile anche in questo scenario: e' il modo in cui, da subito, il
traffico Wi-Fi attuale smette di condividere la VLAN di management,
mentre la Fase B (investimento hardware) si pianifica con calma senza
lasciare aperto nel frattempo il gap di isolamento.

### Procedura fix

1. **Fase A (subito, nessun acquisto)**: creare la VLAN Wi-Fi staff sui
   due switch via Nebula, impostare le porte 1 (XGS2220-30HP) e 41/45
   (XGS2220-54HP) come access port su quella VLAN, aggiungere le regole
   ACL sul firewall USG FLEX 500 per negare l'accesso da quella VLAN
   verso la VLAN 10 management (stesso pattern gia' usato per
   Guest→LAN deny).
2. **Fase B (pianificata)**: preventivo per 3-4 AP Zyxel Nebula (uno per
   ciascuna ubicazione fisica gia' mappata, piu' l'eventuale copertura
   guest), sostituzione graduale dei tre Ubiquiti EOL, configurazione
   multi-SSID (staff + guest) con VLAN tagging e DPPSK nativi.

### Correzioni emerse eseguendo Fase A (15/07/2026)

Verificato a schermo che il PVID sulla porta di uno switch Nebula e' un
campo di testo libero: non serve creare la VLAN da nessuna parte prima,
scriverla su una porta e' sufficiente (corretta un'ipotesi opposta scritta
in giornata in ADR-010).

Verificato sui dati reali di entrambi gli switch che ogni porta controllata
finora — comprese le sei porte 49-54 del 54HP marcate "trunk" e la porta 29
del 30HP verso il dorsale (marcata `trunk: false` ma non per questo meno
permissiva) — ha `allowedVLAN: ["all"]`: lascia gia' passare qualunque VLAN
taggata. Conseguenza pratica: la VLAN 40 attraversera' gia' la dorsale tra i
due switch senza bisogno di nessuna modifica esplicita sui trunk, l'unico
intervento reale resta sulle tre porte AP (PVID + restringere il loro
`allowedVLAN` da "all" a vuoto, per un isolamento effettivo e non solo
cosmetico).

**Effetto collaterale non risolto da Fase A, da tenere a mente**: questo
`allowedVLAN: "all"` universale significa che, oggi, qualunque dispositivo
capace di inviare frame 802.1Q taggati su una qualsiasi porta dei due
switch potrebbe gia' iniettare traffico in una VLAN arbitraria, VLAN 10
management inclusa — non e' una protezione che Fase A introduce o rimuove,
e' un limite di postura L2 preesistente su tutta la rete, piu' ampio del
perimetro Wi-Fi. Irrigidire `allowedVLAN` porta per porta su tutta la rete
(non solo sulle tre porte AP) sarebbe un intervento di hardening a parte,
di scala paragonabile a un audit completo delle porte fisiche: non
bloccante per Fase A, ma da registrare come possibile voce futura in
`design-and-security.md`/`GAP-TBC.md` quando si affrontera' la Fase 5 ISO27001.
3. Se in futuro si trovasse comunque un modo per entrare nei tre AP
   legacy (nuova credenziale scoperta, controller UniFi individuato) prima
   della Fase B, valutare se vale la pena configurarli come "solo staff,
   isolati" (Fase A li rende comunque sicuri anche senza login) invece di
   investire tempo per farci convivere un secondo SSID che il firmware
   EOL potrebbe non supportare comunque bene.

### Verifica

```powershell
# Fase A completata, da un client Wi-Fi staff:
ipconfig
# Atteso: IP nella nuova VLAN Wi-Fi staff, non piu' nella /19 di management

Test-NetConnection -ComputerName 10.61.10.1 -Port 443
# Atteso: timeout/reset (isolamento dalla LAN management funzionante)
```

### Incidente 16/07/2026: le tre porte AP interrompono l'SSID quando ritaggate

**Sequenza applicata** (dopo che il lato firewall era gia' pronto e
verificato: interfaccia `vlan40`, zona `WIFI_STAFF`, DHCP, security policy
in ordine corretto): le tre porte AP spostate una alla volta con
`Set-NebulaWifiVlan.ps1 -Only Access -ApName <nome> -Apply`, ciascuna
verificata subito dopo via rilettura API (`portVid`/`allowedVLAN` corretti)
e, per PianoTerra, anche via tabella MAC L2 (il MAC reale dell'AP
comparuto taggato VLAN 40). Tutti e tre gli esiti tecnici a livello switch
erano positivi.

**Sintomo**: entro pochi minuti dall'ultima porta applicata, l'SSID
"intrawelt" e' sparito completamente dalla scansione Wi-Fi — non solo non
raggiungibile, proprio assente dall'elenco delle reti visibili.
Confermato con **due dispositivi diversi** (uno smartphone, un portatile
con scheda di rete diversa): nessuno dei due vedeva la rete, escludendo un
problema del singolo dispositivo o della sua cache di scansione. Un primo
sospetto (cache di scansione Android dopo aver dimenticato la rete) e'
stato scartato dalla prova con "Add network" manuale (SSID + password
corretti, hidden network) che non ha comunque prodotto connessione.

**Diagnostica lato switch durante l'incidente** (rieseguito
`Get-NebulaSnapshot.ps1`): tutti e tre i collegamenti fisici switch-AP
risultavano `linkSpeed: AUTO_1000M` (link up, PoE attivo) e i
`port-settings` mostravano correttamente `portVid: 40,
allowedVLAN: ["40"]` su tutte e tre le porte — nessuna anomalia visibile
dal lato switch. La tabella MAC L2 mostrava perfino il MAC del client di
test taggato VLAN 40 su una delle porte, prova che per una finestra breve
il collegamento aveva effettivamente funzionato. Il quadro tecnico
disponibile (link, tag, DHCP pronto) non giustificava da solo la sparizione
dell'SSID: la spiegazione piu' plausibile e' che gli AP stessi — non lo
switch — abbiano smesso di trasmettere, per una ragione non verificabile
dato che questi tre dispositivi restano inaccessibili (credenziali perse,
nessuna dashboard, vedi §AP-001).

**Rollback**: `Set-NebulaWifiVlan.ps1 -Only Access -VlanId 1 -Apply`
(tutte e tre le porte insieme, per massimizzare la velocita' di ripristino
data la situazione live), verificato dallo script stesso
(`portVid` tornato a 1 su tutte e tre) e confermato empiricamente:
l'SSID e' ritornato visibile e connettibile entro pochi minuti, sullo
stesso dispositivo di test.

**Ipotesi principale, non confermata**: il principio teorico alla base di
Fase A — "il tagging 802.1Q e' una responsabilita' dello switch, l'access
point non deve sapere nulla della VLAN sottostante" — e' corretto per
hardware moderno, ma evidentemente non ha retto per questi tre AP Ubiquiti
del 2011-2013. Ipotesi plausibili, nessuna verificabile senza accesso al
dispositivo: (a) l'AP ha un proprio indirizzo IP di management statico
configurato per la vecchia subnet, e perdere la raggiungibilita' del
proprio gateway a un livello piu' basso ha innescato un comportamento di
failsafe che disabilita il radio; (b) il firmware datato richiede un
riavvio per rinegoziare correttamente il collegamento dopo un cambio di
VLAN nativa, e il rollback e' arrivato prima che un eventuale riavvio
spontaneo potesse verificarsi; (c) un comportamento di firmware non
documentato e specifico di questa generazione di hardware.

**Conseguenze per la roadmap**: rafforza, con una prova pratica non solo
teorica, la decisione gia' presa per Fase B (sostituzione invece di
affiancamento, vedi sopra) — questi AP si sono dimostrati fragili anche a
un intervento di rete che avrebbe dovuto essere per loro completamente
trasparente. La configurazione lato firewall (interfaccia, zona, DHCP,
security policy) resta applicata e valida: non e' stata rollbackata, e
sara' riusabile sia per un nuovo tentativo Fase A con una procedura piu'
prudente (presenza fisica a un AP alla volta, finestra di osservazione
piu' lunga prima di dichiarare il tentativo riuscito, eventuale
power-cycle manuale dell'AP dopo il cambio) sia per la Fase B (gli AP
Zyxel Nebula sostitutivi useranno la stessa VLAN 40). Da valutare anche
un meccanismo alternativo che non richieda di toccare il PVID della porta
AP, ad esempio la funzione "Layer 2 Isolation" vista nel menu Network del
firewall ma mai esplorata.

### Secondo tentativo (16/07/2026, stesso giorno): scoperta di inaffidabilita' nella sincronizzazione Nebula-switch

Prima di riprovare su tutti e tre gli AP, si e' deciso un test mirato e
piu' prudente su un solo AP (PianoTerra): applicare la VLAN, forzare
subito un riavvio PoE da remoto (nuovo parametro `-PowerCycle` dello
script, spegne/riaccende `pseEnabled`), e osservare piu' a lungo prima di
giudicare. Per eliminare l'ambiguita' gia' notata (un client Wi-Fi puo'
agganciare un AP diverso da quello sotto test), creato anche uno script
dedicato (`Set-ApTestIsolation.ps1`) per spegnere temporaneamente il PoE
degli altri due AP durante il test.

**Due scoperte, entrambe indipendenti dal comportamento degli AP stessi**:

1. La scrittura su PianoTerra e' stata inizialmente rifiutata in modo
   silenzioso (risposta `200 OK` dall'API, ma la rilettura immediata
   mostrava ancora il valore vecchio) — non un errore, un ritardo di
   propagazione fra il cloud Nebula e lo switch fisico. Un secondo
   tentativo, con un retry a backoff crescente aggiunto allo script, ha
   avuto successo ed e' stato verificato correttamente.
2. Pochi minuti dopo, senza alcuna azione esterna, **la porta di
   PianoTerra e' tornata da sola al valore precedente** (`portVid` da 40 a
   1). Nello stesso momento, la tabella MAC dello switch mostrava che
   PianoPrimo e PianoSecondo — su cui avevamo appena impostato
   `pseEnabled: false` per isolare il test, confermato dalla rilettura API
   — **erano in realta' ancora pienamente funzionanti**: il telefono di
   test, dopo aver dimenticato e reinserito la rete da capo, si e'
   ricollegato proprio a PianoPrimo, il cui MAC compariva regolarmente
   nella tabella MAC dello switch.

**Conclusione**: il canale di scrittura verso questi due switch tramite
Nebula OpenAPI non e' affidabile quanto assunto — non solo per
l'heartbeat/dashboard (gia' noto come NEB-001), ma per le scritture di
configurazione stesse, che possono non restare stabili nel tempo o non
tradursi in un effetto fisico reale (il caso del PoE). Continuare a
testare da remoto in queste condizioni rischia di produrre altri falsi
segnali invece di risposte affidabili. Ripristinato il PoE di PianoPrimo/
PianoSecondo per sicurezza (anche se sembravano non averlo mai perso).
Decisione in sospeso con l'utente su come procedere: le opzioni sul
tavolo sono un test con presenza fisica reale (nessun affidamento su API
per la diagnosi), un'indagine piu' approfondita di NEB-001 prima di
continuare (es. aprire un ticket con il supporto Zyxel viste due prove
concrete di scritture non affidabili), oppure accettare che questi tre AP
EOL non sono un buon bersaglio per interventi di rete da remoto e
dare priorita' alla Fase B. **Scelto: approfondire NEB-001.**

### Approfondimento NEB-001 (16/07/2026): trovata una causa concreta e localizzata

Interrogati due endpoint Nebula OpenAPI non ancora usati nel progetto
(`connectivity`, storico online/offline; `event-logs`, log eventi) tramite
il nuovo script `Get-NebulaConnectivityHistory.ps1`. Risultati:

Nessuno dei due switch risulta mai offline nelle ultime 24 ore secondo lo
storico di connettivita' — esclude, almeno per come Nebula la misura, che
il canale cloud si sia disconnesso durante i nostri test.

Il log eventi del 30HP (switch di PianoTerra) mostra esattamente i due
eventi PoE del nostro power-cycle (porta 1 disabilitata, poi "Delivering
Power" 12 secondi dopo, coerente con l'attesa dello script) seguiti da due
brevi flap di link, plausibilmente il boot dell'AP stesso — nessuna
anomalia, tutto coerente con le nostre azioni.

Il log eventi del 54HP (switch di PianoPrimo e PianoSecondo) non contiene
**nessun** evento per le porte 41 o 45 in tutta la finestra di 24 ore,
nonostante le scritture PoE fatte oggi — ma contiene **migliaia** di
eventi di link flap sulla **porta 46** (su/giu' ogni 14-16 secondi,
ciascuno con ricalcolo STP), una porta senza alcun dispositivo
documentato. Verificato che al momento del controllo quella porta
risultava effettivamente `OFFLINE`. Registrato come nuovo gap **NET-010**
(`GAP-TBC.md`).

**Identificato dall'utente**: la porta 46 ospita il PC che fa girare
Ollama (10.61.20.58, la stessa macchina ambigua di SRV-002/#107 — GPU
dedicata, sistema operativo Linux, finora non chiaro se fisica o VM),
confermato raggiungibile via HTTP sulla porta 11500 ("Ollama is running")
nonostante il link flap continuo. La causa del flap non e' ancora nota
(ipotesi: Energy Efficient Ethernet/risparmio energetico della scheda di
rete, ASPM PCIe, driver, cavo) — da controllare direttamente sull'host con
`ethtool` (non Gestione Dispositivi Windows, ipotesi iniziale errata
corretta dall'utente) prima di considerare risolto NET-010.

**Interpretazione**: il problema non e' (solo) una sincronizzazione cloud
generica inaffidabile — e' plausibilmente specifico del 54HP, dove una
porta guasta o mal collegata genera churn continuo (flap + STP) che
probabilmente degrada l'affidabilita' delle altre operazioni su quello
stesso switch (le scritture su porta 41/45 che non hanno "attecchito").
Il 30HP, senza questa anomalia, si e' comportato in modo pulito e
prevedibile sulle stesse identiche operazioni (VLAN + power-cycle su
PianoTerra). Non spiega pero' del tutto la "reversione" della VLAN vista
su PianoTerra: il log eventi di Nebula non sembra tracciare i cambi di
VLAN/PVID come categoria di evento (solo link, PoE, STP, salvataggi di
configurazione), quindi la sua assenza non conferma ne' esclude una
reversione reale — resta un'ipotesi aperta, distinta dal problema di
porta 46 e piu' facilmente spiegabile con una lettura cache-stale lato
Nebula che con un vero cambio non richiesto.

**Prossimo passo consigliato**: diagnosticare la porta 46 del 54HP (cavo,
dispositivo collegato, eventuale loop) prima di fidarsi di nuove scritture
su quello switch — quindi prima di riprovare su PianoPrimo/PianoSecondo.
PianoTerra, sul 30HP che si e' mostrato pulito, resta un candidato piu'
ragionevole per un eventuale nuovo tentativo con osservazione prolungata,
indipendentemente dalla porta 46.

---

## UPS-001: UPS Emerson Liebert su VLAN Guest

**Severity**: ALTA  
**Origine**: VA Onova nov 2025  
**Stato**: APERTO

### Contesto
L'UPS (Emerson Liebert IntelliSlot, IP 10.61.90.33, porta gestione 6004) è sulla VLAN Guest. Un attaccante sulla rete WiFi guest potrebbe raggiungere la console di gestione UPS e causare shutdown non autorizzato dell'infrastruttura.

### Procedura fix

1. Spostare l'interfaccia di rete del modulo IntelliSlot su VLAN 10 (Management)
2. Assegnare IP in 10.61.10.0/24 (es. 10.61.10.20)
3. Aggiornare regole firewall: solo VLAN 10 può raggiungere l'UPS
4. Testare notifiche SNMP/mail dell'UPS dopo la modifica

---

## NET-005: Wi-Fi "intrawelt" senza isolamento, nessuna rete ospiti

**Severity**: ALTA
**Origine**: task_47 (Piano Attività IT v3.xlsx); confermato live il 14/07/2026
**Stato**: APERTO — Fase A tentata e ripristinata il 16/07/2026, vedi "Incidente 16/07/2026" piu' sotto

### Contesto

La Wi-Fi aziendale "intrawelt" non è su una VLAN dedicata: i client che si
connettono ricevono un indirizzo nella stessa classe /19 della VLAN 10
(Management/Server), con gateway e subnet mask coerenti con la LAN
interna, non con un segmento isolato.

### Evidenza live (14/07/2026)

Un PC esterno non censito in NinjaOne si è connesso alla Wi-Fi "intrawelt"
e ha ottenuto in DHCP l'indirizzo 10.61.10.247 (subnet mask 255.255.224.0,
gateway 10.61.10.1) — esattamente la stessa VLAN/subnet della rete di
management, non un segmento separato. MAC AA:BB:CC:00:00:21 (vendor
Intel). Conferma diretta che oggi qualunque dispositivo che si connette
alla Wi-Fi ottiene di fatto accesso alla stessa rete su cui vivono switch,
server e infrastruttura di gestione.

### Verifica pre-fix

```powershell
# Da un dispositivo connesso alla Wi-Fi "intrawelt":
ipconfig
# Atteso oggi (anomalia): indirizzo in 10.61.10.0/19, stesso gateway della LAN management
# Atteso dopo il fix: indirizzo in una VLAN Wi-Fi dedicata, isolata da .10/.20/.90
```

### Procedura fix (sequenza consigliata)

1. Identificare con certezza il modello reale degli access point (marca/
   modello non confermato nella documentazione, vedi nota in
   `GAP-TBC.md` NET-005): il modo più rapido è controllare se compaiono
   come dispositivi nell'organizzazione Nebula già usata per gli switch
   (https://nebula.zyxel.com) — se sì, sono Zyxel gestiti dallo stesso
   portale; se no, verificare fisicamente l'etichetta su uno dei cinque AP
   noti (porte 0-7-1, 0-9-1, 1-8-1, 2-5-1, 2-7-1).
2. Eseguire prima M12 (roadmap): spostare fuori dalla VLAN 90 i quattro
   dispositivi di infrastruttura che oggi la occupano per errore (switch
   management, UPS, MyHome server, citofono Bticino) — non riusarla per il
   traffico ospiti finché resta contaminata da infrastruttura critica.
3. Decidere la VLAN di destinazione per la Wi-Fi aziendale (non
   necessariamente .10: vedi nota architetturale in `current-work.md`) e
   crearla se non esiste già.
4. Sul pannello di gestione AP (Nebula o equivalente): creare un secondo
   SSID per gli ospiti, taggato sulla VLAN 90 ripulita; abilitare
   isolamento client-to-client e, se disponibile, captive portal e
   bandwidth limit per SSID.
5. Sullo switch: la porta a cui è collegato ogni AP passa da access a
   trunk, per portare sia la VLAN Wi-Fi aziendale sia la VLAN 90 guest,
   entrambe tagged, lasciando all'AP il compito di assegnare il tag in
   base all'SSID scelto dal client.
6. Sul firewall: confermare Guest→LAN deny (già presente), aggiungere
   Guest→WAN allow esplicita e Guest→DMZ deny quando la DMZ sarà attiva.

### Verifica post-fix

```powershell
# Da un client connesso al nuovo SSID ospiti:
ipconfig
# Atteso: indirizzo nella VLAN guest ripulita, non nella /19 di management

Test-NetConnection -ComputerName 10.61.10.1 -Port 443
# Atteso: timeout/reset (isolamento dalla LAN management funzionante)
```

---

## NAS-001: NAS HERO irraggiungibile

**Severity**: BASSA
**Origine**: nota IntraLino_Knowledge, senza data
**Stato**: procedura nota, nessuna causa root documentata

### Contesto
NAS HERO (10.61.20.169) risulta talvolta irraggiungibile dalla rete, con un
popup di errore di connessione al tentativo di accesso. Nessuna causa root
e' documentata nella fonte.

### Procedura fix
1. Individuare il NAS in sala server (spia rossa sotto il pulsante di
   accensione se in stato di errore).
2. Spegnimento: tenere premuto il pulsante di accensione.
3. Attendere il completamento dello spegnimento.
4. Riavvio: premere nuovamente il pulsante di accensione e attendere il
   ripristino del sistema e delle connessioni di rete.
5. Verificare dalla propria postazione che il NAS sia di nuovo accessibile.

---

## NAS-002: Unita' di rete mappate (`net use`) invisibili in Esplora risorse

**Severity**: BASSA
**Origine**: sessione operativa 16/07/2026 (side-note durante il micro-step M13a)
**Stato**: risolto

### Contesto
Due unita' di rete mappate con `net use` verso condivisioni del NAS-INTRA2
(10.61.20.177) — `U:` sulla condivisione "utili(new)" (7,46 TB liberi su
21,5 TB) e `A:` su un'altra condivisione dello stesso NAS usata da
Persona-A e Persona-B — risultavano confermate "OK" dal comando `net use`
ma Esplora risorse non le trovava ("Impossibile trovare U:").

### Causa
*UAC token splitting*[^2]: la PowerShell usata per la mappatura era aperta
come amministratore (titolo finestra "Amministratore: Windows PowerShell").
Un processo elevato e un processo non elevato dello stesso utente
Windows mantengono due sessioni di rete separate per motivi di sicurezza:
le unita' mappate in un contesto (la PowerShell elevata) non sono visibili
nell'altro (Explorer, che gira sempre non elevato). `net use` confermava la
connessione perche' verificava solo il proprio contesto elevato.

### Fix
Rieseguire le stesse mappature `net use` da una PowerShell o CMD **non**
elevata (aperta normalmente, senza "Esegui come amministratore").

### Regola pratica
Le mappature di rete vanno sempre fatte da una shell non elevata, a meno
che non debbano essere usate anche da applicazioni elevate che richiedono
esplicitamente quelle stesse unita'.

[^2]: *UAC*, User Account Control — il meccanismo di Windows che separa i
privilegi di un processo amministrativo da quelli di un processo utente
standard nella stessa sessione di accesso.

---

## VM-001: Disco pieno (100%) su VM sito WordPress aziendale (10.61.20.23)

**Severity**: ALTA
**Origine**: sessione operativa 10/07/2026
**Stato**: risolto (mitigazione + rimedio strutturale eseguiti)

### Contesto
La VM che serve il sito WordPress aziendale (10.61.20.23, containerizzato,
con MySQL e servizi accessori) e' risultata con il filesystem radice
(`/dev/sda2`, 32G) al 100% di utilizzo e 0 byte disponibili, con conseguente
fallimento di operazioni base (scrittura su `~/.ssh/authorized_keys`,
`npm cache clean`). Causa principale: cache di snapd
(`/var/lib/snapd/cache`) cresciuta fino a 4,7G senza mai essere ripulita.
Contributori minori: cache npm utente (~3G, non ripulita per mancanza di
spazio), un file gia' cancellato ma ancora aperto da un processo Claude Code
(238MB non liberabili finche' il processo non chiude il file).

### Verifica pre-fix
```
df -h /
sudo du -xh --max-depth=2 / 2>/dev/null | sort -rh | head -25
sudo du -sh /var/lib/snapd/cache
```

### Procedura fix
1. Svuotare la cache di snapd. Attenzione: la directory non e' leggibile
   dall'utente non privilegiato, quindi il carattere jolly va espanso
   *dentro* la shell di root — `sudo rm -rf /var/lib/snapd/cache/*` fallisce
   silenziosamente perche' il glob si espande nella shell utente prima che
   `sudo` entri in gioco, e la shell utente non puo' leggere la directory:
   ```
   sudo find /var/lib/snapd/cache -mindepth 1 -delete
   ```
2. Verificare lo spazio recuperato:
   ```
   sudo du -sh /var/lib/snapd/cache
   df -h /
   ```

### Verifica post-fix
Spazio libero passato da 0 a ~237M. Sufficiente per operazioni minime, non
un margine di sicurezza duraturo su una VM di produzione con MySQL attivo.

### Rimedio strutturale (eseguito il 10/07/2026)
237M restava insufficiente per una VM di produzione: un backup o un log
spike l'avrebbero riportata rapidamente a 0. Si e' scoperto che il disco
virtuale era gia' provisionato a 64G in Proxmox, ma la partizione/filesystem
guest ne usava solo 32G (32G non allocati in coda al disco, nessuna modifica
lato Proxmox necessaria). Shutdown/Start della VM, poi dentro la VM:
```
sudo growpart /dev/sda 2
sudo resize2fs /dev/sda2
```
Risultato: `/dev/sda2` passato da 32G a 63G, spazio libero da ~237M a 32G
(48% di utilizzo). Rimane comunque valido, come miglioria futura non
urgente, rimuovere le revisioni snap disabilitate rimaste (`snap list --all`,
poi `sudo snap remove <nome> --revision=<rev>` per ogni riga con nota
"disabilitato") per liberare ulteriore margine.

---

*Runbook aggiornato: luglio 2026. Owner: Alessio Sopranzi.*
