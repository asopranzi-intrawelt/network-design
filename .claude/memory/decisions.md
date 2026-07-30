# Registro decisioni architetturali

> ADR-lite append-only. Ogni decisione entra come voce numerata. Non si cancella,
> non si riscrive: quando superata, si aggiunge una nuova voce che la dichiara superata.

## ADR-001 — Adozione sistema portabile di progetto

Data: 2026-06-22
Stato: attiva

Contesto: progetto complesso che integra script, documentazione storica, snapshot
infrastrutturale, documentazione ISO27001 e design di rete. Serve un sistema di
contesto strutturato e recuperabile da qualsiasi sessione.

Decisione: adottare il template portabile da `E:\template-claude-developing` con
la struttura `.claude/` canonica, le regole modulari e le skill di riconciliazione.

Conseguenze: ogni passo significativo aggiorna le schede di contesto e il work-log.
Il progetto e' completamente recuperabile da un clone.

## ADR-002 — Due layer documentali: narrativo locale e tecnico versionato

Data: 2026-06-22
Stato: attiva

Contesto: il progetto richiede sia documentazione tecnica strutturata (schede, diagrammi,
timeline Markdown) sia spiegazioni narrative dettagliate (storyline, contesto storico,
ragionamenti), che sono voluminose e personali.

Decisione: layer narrativo in `_notes/` (ignorato da git, locale), layer tecnico in
`.claude/context/` e `docs/` (versionato). Stessa separazione di `CLAUDE.local.md`
vs `CLAUDE.md`.

Conseguenze: i documenti voluminosi, i diario, i resoconti e i file Word grezzi restano
locali. Le schede strutturate, i diagrammi e la timeline degli interventi vanno in git.

## ADR-003 — Angolo ISO27001 sulla documentazione

Data: 2026-06-22
Stato: attiva

Contesto: la rete Intrawelt gestisce infrastruttura critica. La documentazione deve
essere utilizzabile come base per un ISMS e per audit di sicurezza.

Decisione: adottare la struttura ISO27001 come angolo della documentazione di sicurezza
di rete. Ogni intervento di rete viene documentato con: obiettivo, impatto sulla
sicurezza, controlli coinvolti (con riferimento ai controlli ISO27001 Annex A),
rischi residui. Un agent dedicato (`iso27001-reviewer`) verifica l'aderenza.

Conseguenze: la documentazione tecnica ha un campo aggiuntivo di controlli ISO27001.
Non si impone un ISMS completo: si adotta il vocabolario e la struttura per rendere
la documentazione compatibile con un futuro audit.

## ADR-004 — Ingestione progressiva dei documenti Word

Data: 2026-06-22
Stato: attiva

Contesto: la documentazione storica della rete esiste in documenti Word potenzialmente
molto voluminosi (fino a 1000 pagine). Leggerli per intero brucerebbe contesto inutilmente.

Decisione: usare la skill `docx-ingest` con la disclosure progressiva a tre livelli
descritta in `rules/token-economy.md`. Il documento viene estratto su disco in
`_notes/.tmp-docx-<nome>/` una sola volta, poi si accede per sezioni mirate.
Un manifesto con hash e data di modifica evita riletture di documenti non cambiati.

Conseguenze: i Word grezzi restano in `_notes/` ignorati da git. I mirror Markdown
curati (versione leggibile del contenuto rilevante) vanno in `docs/` versionati.

## ADR-005 — Script Get-ProxmoxSnapshot integrato in questo progetto

Data: 2026-06-22
Stato: attiva

Contesto: lo script era nel progetto separato `proxmox-snapshot` (C:\Scripts\proxmox-snapshot).
Quel progetto viene archiviato e la repo remota eliminata.

Decisione: lo script viene spostato in `scripts/Get-ProxmoxSnapshot.ps1` di questo
progetto. E' il tool operativo per aggiornare lo snapshot dell'infrastruttura.

Conseguenze: unico repository per tutto il network design. La storia del progetto
proxmox-snapshot non viene portata: l'output prodotto (snapshot v3) e' la base di
partenza, la storia di sviluppo dello script e' archiviata localmente.

## ADR-006 — Output script ignorato da git

Data: 2026-06-22
Stato: attiva

Contesto: i file in `output/` contengono dettagli completi dell'infrastruttura (IP,
MAC, nomi VM, configurazioni di rete, storage). Sono potenzialmente sensibili.

Decisione: `output/` e' ignorato da git. I file si generano a runtime e si usano
come contesto nella sessione. Non si versionano mai.

Conseguenze: ogni sessione che richiede il contesto Proxmox aggiorna lo snapshot
eseguendo lo script prima di lavorare.

## ADR-007 — MCP Proxmox: token API PVEAuditor sul pacchetto proxmox-mcp esistente

Data: 2026-07-08
Stato: attiva (in attesa del token, creazione manuale dell'utente)

Contesto: `.mcp.json` configurava `uvx proxmox-mcp` (PyPI 0.1.0) con
host/utente/password, ma quel pacchetto autentica solo via token API
(`PROXMOX_URL`, `PROXMOX_TOKEN_NAME/VALUE`) e ha una safety policy che, per
un difetto di path del pacchetto installato, blocca ogni tool. Alternative
valutate: (A) sostituire il server con ProxmoxMCP-Plus da GitHub; (B) tenere
il pacchetto gia' in cache e sistemare autenticazione e safety.

Decisione: approccio B. Un token API dedicato con ruolo PVEAuditor
(sola lettura) su `/`, `PROXMOX_ALLOW_DANGER=true` per scavalcare la safety
client-side difettosa: l'enforcement di sola lettura si sposta dal client al
server Proxmox, che rifiuta ogni scrittura con 403 a livello di permessi.
Motivazioni: il token API serve comunque in entrambi gli approcci; B non
aggiunge dipendenze git esterne ne' migrazioni; il controllo dei permessi
lato Proxmox e' piu' robusto di una policy client aggirabile. I valori reali
(URL con IP, nome e segreto del token) vivono solo nelle variabili d'ambiente
utente della macchina, mai nel file tracciato: `.mcp.json` usa l'espansione
`${ENV}` (era stato committato con l'IP reale in chiaro: bonificato il file
vivo, la storia si riscrive in Fase B).

Vincolo esplicito: `PROXMOX_ALLOW_DANGER=true` e' accettabile SOLO finche'
il token resta PVEAuditor. Se in futuro si assegnano privilegi di scrittura
al token (per le sessioni di design attivo), riportare ALLOW_DANGER a false
e gestire la conferma per operazione.

Conseguenze: per attivare l'MCP servono, una tantum: token su Proxmox
(Datacenter > Permissions > API Tokens, utente root@pam, token id
`mcp-readonly`, privilege separation attiva; poi Permissions > Add > API
Token Permission su `/` con ruolo PVEAuditor e propagate) e tre variabili
d'ambiente utente Windows: PROXMOX_URL (https://<ip-nodo>:8006/api2/json),
PROXMOX_TOKEN_NAME (root@pam!mcp-readonly), PROXMOX_TOKEN_VALUE (il segreto
mostrato alla creazione). Riavviare Claude Code per il reload MCP.

**Esito 08/07/2026: token creato e verificato.** Le tre variabili sono nel
registro HKCU dell'utente; test di autenticazione GET /nodes riuscito
(200, nodo pve online, uptime coerente) senza mai stampare il segreto.
Resta da riavviare Claude Code perche' il server MCP `proxmox` legga le
variabili e diventi operativo nella sessione.

## ADR-008 — Schema a due token Proxmox: MCP in sola lettura, scrittura "a finestra" per gli script

Data: 2026-07-08
Stato: attiva (integra ADR-007; il token di scrittura si crea solo alla
ripresa della Fase 3)

Contesto: alla domanda dell'utente se avesse senso dare al token MCP anche
la scrittura, per poter eseguire da questa macchina gli interventi di
network design via script, la valutazione e' partita da una asimmetria
concreta tra i due canali di accesso all'API Proxmox.

Ragionamento, come argomentato in sessione. Il token di ADR-007 alimenta il
server MCP, cioe' un canale sempre acceso e disponibile all'agente in ogni
sessione, su qualunque cosa si stia lavorando. Su quel canale e' stato
deciso ALLOW_DANGER=true perche' la safety client-side del pacchetto e'
rotta: non esiste piu' nessun livello di conferma tra una chiamata tool e
l'API. Con PVEAuditor questo e' innocuo per costruzione (ogni scrittura
muore con 403 lato Proxmox). Con un token di scrittura, invece, una
chiamata sbagliata — un errore dell'agente, un'allucinazione su un VMID, o
nel caso peggiore una prompt injection veicolata da un documento ingerito —
diventerebbe un delete_instance o un power_control eseguito senza che
nessuno chieda niente (il tool delete_instance esiste nella lista esposta).
Un canale ambientale con scrittura root e zero conferme non e' coerente con
la postura del resto del progetto, dove perfino i commit git sono manuali.

Il caso d'uso della scrittura e' pero' legittimo e non richiede quel
canale: quando riprende la Fase 3, gli script che scrivono (creare la VM
DMZ di M9, attivare il firewall cluster di M15, configurare i bridge
VLAN-aware di M5 via API /nodes/pve/network) sono azioni deliberate,
lanciate esplicitamente, che passano dai prompt di permesso della sessione
e che l'utente rivede. Per quelle la soluzione pulita e' un secondo token
separato, da creare quando servira': utente dedicato (per esempio
automation@pve, non root), ruolo scopato al necessario (PVEVMAdmin o un
ruolo custom, eventualmente limitato al pool interessato) e soprattutto la
scadenza impostata — Proxmox permette di dare ai token una data di expiry,
quindi il token di scrittura puo' vivere solo per la finestra degli
interventi. Quel token lo useranno gli script via variabili d'ambiente
proprie, senza mai entrare in .mcp.json.

Decisione: due chiavi con due raggi d'azione. L'MCP resta l'occhio in sola
lettura sempre disponibile per le sessioni di design; la chiave di
scrittura esiste solo quando c'e' un intervento pianificato, con perimetro
e scadenza. Capacita' operative invariate, nessun canale di scrittura non
presidiato acceso ventiquattro ore al giorno. L'utente ha confermato lo
schema ("quindi ok") l'08/07/2026.

Alternativa considerata e scartata: un unico token di scrittura da subito.
Sarebbe accettabile solo con utente non-root dedicato, ruolo limitato con
expiry, e accettando che ogni tool MCP diventi eseguibile senza conferma;
scartata perche' il beneficio (evitare la creazione di un secondo token al
momento del bisogno) non ripaga il rischio del canale ambientale.

## ADR-009 — Script Get-NebulaSnapshot.ps1: API REST Zyxel Nebula, chiave in sola lettura

Data: 2026-07-14
Stato: attiva

Contesto: per identificare fisicamente gli access point WiFi (AP-001,
NET-005) serve sapere quale MAC address e' collegato a quale porta di
quale switch. Gli AP non compaiono come dispositivi gestiti
nell'organizzazione Nebula (verificato dall'utente il 14/07/2026), ma gli
switch si', ed espongono comunque la tabella MAC L2 per porta
indipendentemente dalla marca del dispositivo collegato — non serve che
l'AP stesso sia Zyxel.

Decisione: script dedicato `scripts/Get-NebulaSnapshot.ps1`, stesso
pattern di `Get-ProxmoxSnapshot.ps1` (nessuna dipendenza da un MCP
esistente: a differenza di Proxmox, non risulta un server MCP pronto per
Nebula). Autenticazione con una singola chiave API Nebula (header
`X-ZyxelNebula-API-Key`), risolta nell'ordine parametro -&gt; variabile
d'ambiente NEBULA_API_KEY -&gt; prompt SecureString a runtime, mai scritta
su disco.

**Percorso di navigazione reale per generare la chiave (14/07/2026,
verificato sul campo dopo un'ora di ricerca — non e' dove la
documentazione ufficiale suggerisce)**: in Nebula Control Center, icona
"..." (tre puntini) nella barra in alto, NON l'icona a ingranaggio (quella
e' solo dark mode/lingua) ne' l'avatar utente (quello e' solo "Manage
account"/sign out, porta al portale myZyxel generale) ne' "Organization-wide
manage" (quello contiene Organization settings, Cloud authentication,
ecc., niente API). Dal menu dei tre puntini: **"My devices & services"**
-&gt; scheda **"NCC OpenAPI Key"** -&gt; pulsante "Generate". Richiede la
licenza Nebula Professional Pack sui dispositivi dell'organizzazione (gia'
presente su entrambi gli switch Intrawelt, confermato dalla pagina
License & inventory). La stessa vista "My devices & services" mostra
anche l'inventario completo dei dispositivi mai posseduti dall'account,
inclusi due USG20-VPN dismessi non risultanti in altre liste (vedi
correzione in `2025-q3-q4.md`).
Endpoint usati verificati contro la documentazione ufficiale
(zyxelnetworks.github.io/NebulaOpenAPI) il 14/07/2026: organizations,
sites, sites/devices, ports-status, port-settings, l2-mac-table (GET); un
solo endpoint POST (v2/sw-clients) tentato a scopo aggiuntivo con schema
del body non documentato con certezza, quindi in try/catch con warning
invece che hard-fail se fallisce.

Conseguenze: stesso perimetro di sicurezza dei token Proxmox (ADR-007) —
singola chiave, nessuna scrittura di segreti su disco, output in
`output/nebula-snapshot.json` e `output/nebula-config.md` (ignorati da
git, stessa convenzione di ADR-006). La chiave usata e' quella
amministrativa esistente dell'utente su Nebula (nessuna decisione di
scopare un ruolo/utente dedicato come per Proxmox, perche' l'uso previsto
e' solo lettura via i soli endpoint GET/POST elencati, non gestione
dispositivi).

Conseguenze: alla ripresa della Fase 3 si crea automation@pve con token a
scadenza e ruolo minimo per i micro-step interessati; gli script operativi
leggeranno credenziali da variabili d'ambiente dedicate (per esempio
PROXMOX_AUTOMATION_*), distinte da quelle MCP. Il segreto del token MCP
vive solo nelle variabili d'ambiente utente della macchina (registro HKCU),
mai in file del repository, mai nella chat di sessione.

Integrazione 08/07/2026 (richiesta utente): come backup umano del segreto
e' accettato un file `.env` locale nella radice del progetto, aggiunto a
`.gitignore` insieme al pattern `.env.*` (prima non era coperto: senza
questa aggiunta un `git add .` lo avrebbe pubblicato). Valutazione del
rischio residuo: il file sta su disco cifrato at-rest (BitLocker attivo
dal 03/07/2026), non e' letto da alcuno script, le regole deny della
sessione ne bloccano la lettura all'agente; resta esposto a malware o
utenti locali della macchina e finisce nei backup Veeam del disco. Per un
token in sola lettura PVEAuditor il danno massimo e' la divulgazione
dell'inventario infrastrutturale, e il token si revoca/rigenera in un
minuto: rischio accettato. Per il futuro token di scrittura questo backup
NON e' accettabile: solo password manager personale o nessuna copia.

## ADR-010 — Script Set-NebulaWifiVlan.ps1: scrittura Nebula senza token scopato, limite scoperto sulla creazione VLAN, canale firewall diverso da Nebula

Data: 2026-07-15
Stato: attiva

Contesto: per M13a (Fase A rete Wi-Fi, isolamento delle tre porte AP gia'
localizzate su una VLAN dedicata) serve uno script che scriva davvero sui
due switch Nebula, non solo li legga. Il precedente di riferimento e'
ADR-008 (Proxmox): due token separati, uno di sola lettura sempre acceso,
uno di scrittura scoped e a scadenza creato solo alla finestra di
intervento. Verificato che questo schema non si trasferisce a Nebula cosi'
com'e', per un motivo strutturale dell'API Nebula stessa, non per scelta di
postura: la chiave API Nebula (verificato il 15/07/2026 contro
zyxelnetworks.github.io/NebulaOpenAPI e la Community Zyxel) e' scopata per
amministratore, non per ruolo — condivide gli stessi permessi dell'account
Nebula che l'ha generata, senza un equivalente del ruolo PVEAuditor di sola
lettura. Non esiste quindi un secondo token "di scrittura scoped" da creare
a tempo: c'e' una sola chiave, con gli stessi permessi ovunque venga usata.

Decisione: la mitigazione si sposta dal livello del token al livello dello
script. `Set-NebulaWifiVlan.ps1` gira sempre in dry-run (stampa il piano,
nessuna richiesta inviata) a meno che non venga passato esplicitamente
`-Apply`, e anche con `-Apply` chiede una conferma testuale a runtime
("CONFERMA", maiuscolo) prima di inviare le POST reali — stesso principio
di deliberazione esplicita di ADR-008, applicato dove l'API non offre un
equivalente struttura di permessi da scopare.

Limite scoperto durante la stesura (15/07/2026, da due fetch indipendenti
della documentazione ufficiale): l'API Nebula non espone nessun endpoint
per *creare* una VLAN a livello di sito o di switch, solo
`POST /{siteId}/sw/{devId}/port-settings` per assegnare una VLAN a una
porta (`portVid`, `allowedVLAN`). **Corretto lo stesso giorno dopo verifica
diretta a schermo** (non solo da documentazione): il campo PVID nel
pannello "Update port" della GUI Nebula e' testo libero, non un menu
vincolato a VLAN preesistenti. Non serve quindi nessun passo di creazione
preliminare, ne' da API ne' da GUI: scrivere l'ID su una prima porta e'
sufficiente, la VLAN esiste da quel momento. L'assenza di un endpoint di
"creazione VLAN" nell'API rispecchia semplicemente il fatto che in Nebula
le VLAN sui switch non sono oggetti site-wide con vita propria, sono un
effetto collaterale dell'uso su una porta - non un passo mancante da
compensare a mano.

**Scoperta operativa piu' rilevante, dallo stesso giro di verifica**:
applicare in un solo colpo sia le porte trunk sia le tre porte AP e'
rischioso, perche' il firewall non ha ancora un'interfaccia/DHCP per la
nuova VLAN nel momento in cui gira lo script - spostare il PVID di un AP
live su quella VLAN lo scollegherebbe finche' il firewall non e' pronto.
`Set-NebulaWifiVlan.ps1` ha percio' un parametro `-Only` (`Trunk` |
`Access` | `All`) per applicare prima solo i trunk (innocuo), poi il piano
firewall a mano, e infine le porte AP una alla volta con verifica.

Nota collegata sul firewall (stessa sessione, stessa domanda dell'utente
"ci connettiamo anche al firewall via API"): il firewall USG FLEX 500 non
compare tra i dispositivi Nebula dell'organizzazione (`nebula-config.md`
mostra solo i due switch, nessun dispositivo di tipo GW/FIREWALL) — gira in
modalita' standalone/classica ZLD, non adottato in Nebula. L'endpoint
Nebula per l'interfaccia gateway (`GET /{siteId}/gw/{devId}/interface-settings`)
esiste solo per firewall Nebula-adottati e comunque risulta di sola
lettura nella documentazione consultata: non e' applicabile qui in nessun
verso. L'unico canale scriptabile verso questo firewall resta quello gia'
in uso per l'accesso amministrativo, SSH con 2FA (`firewall-zyxel-usg-flex-500.md`
riga 373): un canale che richiede comunque un umano per il secondo fattore
a ogni sessione, quindi non automatizzabile end-to-end come Nebula. La via
praticabile e' uno script "generatore" che produce il blocco di comandi
CLI ZLD da incollare in una sessione SSH gia' autenticata, non uno script
che si autentica e scrive da solo — coerente con la postura del progetto
dove anche i commit restano un'azione umana deliberata.

Conseguenze: nessun nuovo segreto da gestire (si riusa la stessa chiave
Nebula gia' generata per ADR-009); il rischio di scrittura accidentale e'
mitigato da dry-run di default + conferma testuale, non da un perimetro di
permessi ridotto sul token, perche' l'API non lo consente. Il log di ogni
applicazione reale si scrive in `output/nebula-apply-log-fase-a.json`
(ignorato da git, stessa convenzione degli altri output infrastrutturali).

**Scoperta con un tentativo reale (16/07/2026)**: il primo `-Apply` su
`-Only Access` (porta 1, PianoTerra) e' stato rifiutato dall'API con
`422 INVALID_ALLOWED_VLAN` — `allowedVLAN: []` (lista vuota, il tentativo
di access strict "zero VLAN taggate") non e' un valore accettato. Nessuna
scrittura parziale: il rifiuto e' stato pulito, la porta e' rimasta nello
stato precedente. Corretto lo script per inviare `allowedVLAN: [VlanId]`
(la sola VLAN nativa della porta) invece della lista vuota: non ottiene
l'isolamento "zero VLAN taggate" originariamente cercato, ma resta
comunque piu' stretto del valore preesistente "all" su tutte le altre
VLAN. Conferma indiretta che il dry-run-by-default di ADR-010 ha fatto
esattamente il suo lavoro: un errore di questo tipo, scoperto al primo
`-Apply` reale invece che ipotizzato a tavolino, e' stato innocuo perche'
isolato a una singola porta con conferma testuale esplicita, non propagato
a tutte e tre le porte AP in un colpo solo.

**Incidente del 16/07/2026 e nuovo parametro -PowerCycle**: applicate le
tre porte AP, l'SSID Wi-Fi e' sparito del tutto entro pochi minuti (vedi
`runbook-anomalie.md` §NET-005 "Incidente 16/07/2026" per il resoconto
completo) — rollback immediato a VLAN 1, servizio ripristinato in circa
un quarto d'ora. Causa non determinata con certezza (AP inaccessibili),
ma il pattern osservato (funziona subito dopo il cambio, cade dopo
qualche minuto) suggerisce uno stato residuo lato AP che scade invece di
re-inizializzarsi sulla VLAN nuova. Aggiunto un parametro `-PowerCycle`
allo script: dopo aver scritto la nuova VLAN su una porta AP, spegne e
riaccende il PoE di quella porta (`pseEnabled` false poi true, pausa di 10
secondi), forzando un riavvio a freddo dell'AP gia' sulla VLAN corretta —
un test mirato dell'ipotesi, eseguibile da remoto senza presenza fisica.
Da usare un AP alla volta, con osservazione prolungata (minuti, non
secondi) prima di giudicare l'esito, coerente con la lezione
dell'incidente.

**Secondo tentativo, nuovo problema (16/07/2026, stesso giorno)**: il
retry su PianoTerra ha risposto `200 OK` alla scrittura ma la rilettura
immediata mostrava ancora `portVid: 1` — nessun errore, semplicemente non
ancora applicato. Coerente con NEB-001 (intermittenza nota tra il canale
cloud Nebula e gli switch fisici): un `200 OK` conferma che il cloud ha
accettato la richiesta, non che l'abbia gia' spinta sul dispositivo.
Corretto lo script con un retry a backoff crescente (3, 5, 8, 12 secondi)
sulla verifica invece di un solo controllo immediato. Il power-cycle non
e' scattato (gated su verifica riuscita), quindi nessun impatto reale su
PianoTerra da questo tentativo.

## ADR-011 — Riscrittura storia git fuori piano: deroga puntuale per richiesta CIRST esterna

Data: 2026-07-17
Stato: attiva

Contesto: il CIRST (team di incident response) di Fibercop ha contattato
direttamente l'utente segnalando che l'indirizzo email reale del proprio
tecnico (Referente-Fibercop-1) era leggibile in un commit del repository
pubblico, con richiesta di rimozione di tutti i riferimenti. Verifica
effettuata nella sessione: la mail era presente nel file tracciato
`docs/infrastructure-timeline/2025-q1-server-vianova.md` (il nome era gia'
correttamente sostituito con il placeholder `Referente-Fibercop-1`, la mail
in parentesi era stata dimenticata) e propagata in `timeline.svg`
(generato dal sorgente). Presente nella storia dal commit `dda1945` fino
all'HEAD corrente (`af4cad4`).

Il piano esistente (vedi `roadmap.md`, sezione Fase B) prevede un solo
round di riscrittura storia, a Fase B completata, per evitare due force-push
separati. Questa e' una richiesta di terze parti esterna e con scadenza
implicita (compliance/GDPR lato fornitore), a differenza del resto degli
elementi in coda in Fase B che sono audit interni senza pressione esterna.

Decisione: derogare al piano "un solo round" ed eseguire subito, fuori
sequenza, un round di `git filter-repo` mirato alla sola voce Fibercop
(`_notes/.git-filter-replacements.txt`, voce contrassegnata priorita' alta),
invece di attendere la chiusura di Fase B. Il resto delle voci accumulate
nel file di sostituzioni resta per il round successivo a Fase B completata.

Conseguenze: due round di force-push invece di uno (costo accettato per
rispondere alla richiesta esterna), con re-clone locale obbligatorio dopo
ciascuno. Il file tracciato e l'SVG sono gia' stati corretti nella sessione
corrente indipendentemente dalla riscrittura storia. Il caso apre inoltre
un precedente: una richiesta esterna con scadenza puo' giustificare una
deroga puntuale al piano "un solo round", da valutare caso per caso se si
ripresenta.

**Esito 17/07/2026**: eseguito con un file di sostituzioni dedicato
(`_notes/.git-filter-replacements-fibercop-only.txt`), non quello cumulativo
di Fase B, per non toccare premature altre voci non ancora audit-ate. Una
prima scansione mirata alla sola stringa dell'email `.com` si e' rivelata
incompleta: una scansione successiva su tutta la storia (`git log --all -p`
filtrato sul nome, non solo pickaxe `-S`) ha trovato una seconda mail reale
mai individuata prima (dominio `.it`, diverso dal `.com` gia' noto) e
diverse occorrenze del nome completo in chiaro risalenti al gennaio 2025,
mai toccate dalla sweep di anonimizzazione precedente. Ha incluso anche una
svista introdotta in questa stessa ADR: il testo sopra citava inizialmente
il nome reale invece del placeholder, corretto dallo stesso round di
riscrittura. File di sostituzioni finale: due varianti email verso indirizzi
placeholder sullo stesso dominio reale del fornitore (coerente con la
mappatura gia' in uso altrove nel corpus) e due regole sul nome, ordinate
dalla piu' specifica (nome e cognome) alla piu' generica (solo cognome).
Verifica esaustiva post-riscrittura su tutta la storia: zero occorrenze
residue del nome o delle mail reali. Force-push eseguito
(`74347f6..900ac26` su `main`), working tree locale risincronizzato via
`git reset --hard origin/main` dopo aver messo in sicurezza ogni modifica
pendente. Resoconto completo passo-passo in
`_notes/incidente-fibercop-2026-07-17.md` (narrativo, non
versionato). Fork del repository verificato assente su GitHub il 17/07/2026
(pagina "Forks" del repo, screenshot alla mano).

**Secondo incidente, stesso giorno**: il paragrafo "Esito" originale conteneva
esso stesso un dato reale scritto per errore nell'atto di documentare la
bonifica (corretto in un commit successivo, senza bisogno di citarlo di
nuovo qui). Ha richiesto un terzo e poi un quarto round della stessa
procedura sullo stesso file di sostituzioni (esteso con una regola
case-insensitive di chiusura, per una variante di maiuscole sfuggita alle
regole letterali). Force-push finale: `2ad5485..ab0c2a3` su `main`.
Verifica di chiusura ripetuta su due clone indipendenti e freschi (non i
mirror di lavoro usati per la riscrittura): zero occorrenze in 58 commit.
Dettaglio completo in `_notes/incidente-fibercop-2026-07-17.md`, inclusa
la lezione sul meta-livello (documentare un leak non e' un'eccezione alla
regola di anonimizzazione).

## ADR-012 — Fase B Wi-Fi: modello e quantita' AP scelti (Zyxel NWA130BE-EU0101 x3)

Data: 2026-07-20
Stato: attiva

Contesto: la Fase B (sostituzione dei tre AP Ubiquiti EOL, decisione
architetturale del 15/07/2026, vedi `runbook-anomalie.md` §AP-001) restava
senza un modello di hardware concreto. L'utente ha ricevuto un preventivo
da Punto Informatica (partner hardware gia' noto) per tre access point
Zyxel NWA130BE-EU0101, Wi-Fi 7 (802.11be) tri-radio, gestibili in
NebulaFlex (standalone o cloud-managed dalla stessa organizzazione Nebula
gia' in uso per i due switch Zyxel).

Decisione: adottare questo preventivo per la Fase B. La quantita' di tre
unita' resta coerente con il piano gia' scritto (un AP per ciascuna delle
tre ubicazioni staff/guest gia' mappate — PianoTerra, PianoPrimo,
PianoSecondo — multi-SSID staff+guest sullo stesso dispositivo fisico,
invece di un quarto AP guest dedicato). L'AP EsternoIrrigazione (centrale
irrigazione sul tetto, non copertura Wi-Fi per il personale) resta
esplicitamente fuori scope da questo preventivo: la sua eventuale
sostituzione, se necessaria, e' una decisione separata non ancora presa.

Conseguenze: importo, sconto e riferimento del documento del preventivo
non entrano in nessun file tracciato, per policy di anonimizzazione
(`.claude/rules/anonymization.md`, sezione dati amministrativi e
commerciali) — solo il fatto tecnico (vendor, modello, specifiche,
quantita', ambito) e' documentato in `runbook-anomalie.md` §AP-001,
`vendor-management.md` §Punto Informatica, `2026-switch-piano-terra.md` e
`roadmap.md` (M13b). Acquisto effettivo e consegna non confermati in
questa sessione. Resta aperta l'ambiguita' di ubicazione fisica di
PianoSecondo (CED vs esterno tetto), non risolvibile senza sopralluogo, e
indipendente da questa decisione di modello/quantita'.

## ADR-013 — GroupShare: priorita' alla disponibilita' (HTTP) sulla cifratura (HTTPS), fix completo rimandato

Data: 2026-07-20
Stato: attiva

Contesto: il 17/07/2026 il portale Trados GroupShare (`gs.intrawelt.com`,
VM su Seeweb) ha perso il binding/certificato HTTPS (dettaglio tecnico
completo in `runbook-anomalie.md` §SEC-015): la porta 443 non rispondeva,
mentre la 80 (HTTP) restava funzionante. I Project Manager, i cui client
Trados Studio puntano al portale, sarebbero rimasti bloccati fino al
completamento del fix HTTPS (win-acme, gia' identificato ma con un primo
tentativo fallito per un binding senza host header).

Decisione: invece di completare il percorso win-acme prima di riattivare
il servizio, si e' scelto di ripristinare subito la sola connettivita' HTTP
per sbloccare i PM, rimandando il ripristino della cifratura.

Conseguenze: il traffico verso il portale GroupShare, incluse le
credenziali applicative, viaggia oggi in chiaro — gap di sicurezza aperto
(SEC-015, `GAP-TBC.md` #117; `design-and-security.md` §A.13.2, controllo
Annex A.13.2 Trasferimento delle informazioni). Il fix corretto (binding
HTTPS con host header + win-acme) resta identificato e non applicato: da
completare come azione separata, non implicita in questa decisione. La
decisione e' un compromesso esplicito disponibilita'-contro-cifratura,
non una chiusura del problema.

## ADR-014 — Wi-Fi staff con accesso completo alla LAN: isolamento rimosso per scelta, rischio accettato

Data: 2026-07-22 (consolidata il 23/07/2026)
Stato: attiva

Contesto: il micro-step M13a era nato per isolare la Wi-Fi aziendale dalla LAN
interna, perche' NET-005 aveva evidenziato che un dispositivo non censito
connesso alla Wi-Fi otteneva un indirizzo nella stessa `/19` su cui vivono
switch, server e infrastruttura di gestione. Il 16/07/2026 l'isolamento e' stato
realizzato lato firewall con la regola `WIFI_STAFF_to_LAN1_deny`. Con la messa
in opera dei due SSID distinti (staff e ospiti, entrambi protetti da password) e
il funzionamento della rete ospiti su VLAN 90 con SNAT esplicito, il quadro e'
cambiato: la rete non fidata esiste ed e' separata, mentre lo SSID staff serve
i dispositivi aziendali che devono lavorare come le postazioni cablate, NAS
compreso.

Decisione: portare la regola da `deny` ad `allow` (rinominata
`WIFI_STAFF_to_LAN1_allow`), dando alla Wi-Fi staff accesso completo alla LAN, e
mantenere l'isolamento solo sulla rete ospiti, la cui regola di uscita e' stata
contestualmente ristretta da destinazione `any` a sola WAN. Verificato in campo:
un dispositivo sullo SSID staff raggiunge il NAS, un client ospite naviga e non
raggiunge la LAN interna.

Conseguenze: NET-005 resta aperto, ma cambia natura — da difetto da correggere a
**rischio accettato** in modo consapevole, ed e' cosi' che va letto nelle
schede (`runbook-anomalie.md` §NET-005 aggiornamento 22-23/07/2026,
`design-and-security.md` §A.13.1). Il rischio residuo e' che un dispositivo
staff compromesso abbia la stessa visibilita' di un PC cablato, cioe' l'intera
`/19`; la mitigazione non e' un'ACL sulla Wi-Fi ma la segmentazione reale delle
tre classi della LAN piatta, che e' il micro-step M22 (NET-009). La decisione e'
reversibile a costo nullo riportando l'azione della regola a `deny`, e va
rivalutata quando M22 sara' pianificato: a segmentazione fatta, "accesso come una
postazione cablata" significhera' accesso a un segmento delimitato, non a tutta
la rete.

## ADR-019 — Scansioni su NAS in SMB con un account di servizio; scartato il server FTP sulle postazioni

Data: 2026-07-30
Stato: attiva

Contesto: le undici destinazioni di scansione censite sulle due multifunzione puntano tutte
a cartelle condivise di singole postazioni, con le credenziali di quelle postazioni
memorizzate negli apparati (SEC-020). Poiche' l'RMM ruota le password locali di Windows ogni
trenta giorni, quelle destinazioni sono anche una manutenzione ricorrente. L'IT Manager ha
formulato due alternative concrete: portare le scansioni su una cartella del NAS con un
utente di servizio dedicato, mantenendo SMB e cambiando solo il percorso nelle rubriche;
oppure installare un server FTP su ciascuna postazione, limitarlo a una cartella di
scansione e cambiare protocollo nelle rubriche.

Decisione: la prima. Le scansioni vanno su NAS-INTRA2 in **SMB**, con un unico **account di
servizio locale del NAS** come sola credenziale memorizzata negli apparati, e ciascun utente
raggiunge la propria cartella con la propria utenza NAS, tipicamente tramite una scorciatoia
sul desktop.

Motivazioni, e sono quattro indipendenti. La destinazione dei dati cambia: i documenti
smettono di depositarsi sugli endpoint e finiscono su uno spazio presidiato con backup noto,
che e' il problema per cui l'intervento esiste — la seconda alternativa cambiava il protocollo
del trasporto e lasciava i dati dove sono. La superficie di attacco non cresce: un server FTP
su ogni postazione sarebbe un servizio in ascolto su ogni endpoint, raggiungibile da tutta la
LAN piatta, esattamente dove si sta lavorando per ridurre. Il trasporto resta cifrabile e
autenticato: le prove del 30/07 hanno dimostrato che entrambe le multifunzione parlano SMB 2
o superiore, mentre FTP in chiaro trasporterebbe credenziali e documenti in chiaro. E la
manutenzione diventa nulla invece di moltiplicarsi: un account di servizio locale del NAS sta
fuori dal perimetro di rotazione dell'RMM, mentre la seconda alternativa avrebbe richiesto di
installare, aggiornare e configurare un server su ciascuna macchina.

Conseguenze e vincoli. L'account di servizio ha la sola scrittura sulle cartelle di
destinazione e nessun privilegio amministrativo sul NAS; va verificato che nessuna politica di
scadenza password lo riporti dentro il problema. Le rubriche delle multifunzione conservano
una sola credenziale, quella del servizio, e le destinazioni restano espresse per **indirizzo**
e non per nome, perche' quegli apparati non hanno alcun server DNS configurato. L'isolamento
tra utenti si ottiene dai permessi del NAS e non dalle credenziali degli apparati: la
disposizione delle cartelle che lo realizza e' quella decisa il 30/07/2026, sette condivisioni
nascoste una per destinatario, scelta per evitare la riscrittura massiva di permessi che
l'alternativa a cartella unica con sottocartelle avrebbe richiesto su questo NAS. Restano
agganciati R9, l'account di servizio al posto delle utenze nominali, e R10, la regola di
conservazione sulla cartella.

## ADR-018 — Nomi interni su un sottodominio del dominio aziendale, risolto solo dal DNS interno

Data: 2026-07-30
Stato: attiva

Contesto: la verifica dell'ambito DHCP del 30/07/2026 ha mostrato che i client ricevono
come primo server DNS il firewall stesso, quindi un resolver interno esiste e manca solo
il contenuto. Prima di pubblicare i primi record serviva scegliere il suffisso, e la
ricognizione dei nomi interni in uso ha rivelato tre convenzioni diverse, due delle quali
sul suffisso `.local` che e' riservato a mDNS dallo standard e percio' non risolvibile in
modo prevedibile via DNS unicast (NET-014, `GAP-TBC.md` #131). La scelta era quindi tra un
suffisso di uso privato, come il `.lan` gia' adottato per il portale della VM208, e un
sottodominio del dominio pubblico che l'azienda possiede.

Decisione dell'IT Manager: **i nomi interni vivono su un sottodominio del dominio
aziendale**, nella forma `<host>.int.<dominio-aziendale>`, con i record pubblicati
**soltanto** sul DNS interno del firewall e mai sul DNS pubblico. E' una configurazione a
orizzonte separato: lo stesso dominio risponde con nomi diversi a chi interroga da dentro e
a chi interroga da fuori, e da fuori quei nomi semplicemente non esistono.

Motivazioni, in ordine di peso. La prima e' che un dominio di cui l'azienda e' titolare non
collidera' mai con nulla, mentre un suffisso inventato puo' diventare un giorno un dominio di
primo livello reale e trasformare una rete funzionante in una rete che risolve nomi altrui.
La seconda, che e' il vero guadagno, riguarda i certificati: per un nome sotto un dominio
posseduto e' possibile ottenere un certificato da un'autorita' pubblica tramite la
validazione che usa un record DNS, **senza esporre il servizio su Internet**. Ne segue che il
portale interno della VM208, oggi servito da una CA interna la cui radice va importata a mano
su ogni postazione, potrebbe passare a un certificato pubblicamente riconosciuto: SEC-016 si
chiude per intero invece che a meta'.

Conseguenze e vincoli operativi. I record di indirizzo vanno solo sul firewall: pubblicarli
anche sul DNS pubblico esporrebbe l'indirizzamento interno senza alcun beneficio. Il
beneficio sui certificati ha una dipendenza da dichiarare: la validazione via DNS richiede di
poter creare un record di testo sulla zona **pubblica** del dominio, quindi richiede accesso
al DNS pubblico presso il fornitore che lo ospita — non richiede invece nessun record di
indirizzo pubblico. Chi interroga un resolver esterno non risolvera' quei nomi, ed e'
corretto: i client VPN funzionano perche' la VPN distribuisce il firewall come DNS, mentre la
rete ospiti, che riceve DNS pubblici, non li risolvera' — anche questo e' voluto. Resta
invece un caso da correggere e non da accettare, emerso proprio da questa decisione: la Wi-Fi
staff riceve oggi DNS pubblici, quindi non risolverebbe i nomi interni; e' diventato un
sotto-passo di R12. Infine i due nomi `.local` esistenti sono un debito da migrare a questa
convenzione (intervento R13), creando il nome nuovo prima di rimuovere il vecchio.

## ADR-017 — Snapshot NinjaOne in sola lettura: la gestione endpoint entra nel perimetro del network design

Data: 2026-07-30
Stato: attiva

Contesto: gli endpoint di questa rete non sono gestiti a mano ma da un RMM
distribuito, NinjaOne, che applica policy, script e automazioni e che ruota le
password locali ogni trenta giorni. La conseguenza pratica e' emersa il 30/07/2026
lavorando su R8: qualunque credenziale di postazione memorizzata in un apparato di
rete — come quelle che le due multifunzione conservano per scrivere nelle cartelle
condivise degli utenti — si rompe alla rotazione successiva, quindi il difetto di
SEC-020 non e' solo di sicurezza ma anche di fragilita' strutturale. Piu' in
generale, progettare segmentazione, indirizzamento e flussi senza sapere cosa l'RMM
fa a quegli endpoint significa progettare a occhi chiusi. L'IT Manager ha indicato
che la connessione alle API di NinjaOne e' gia' attiva in un progetto interno
separato, da cui riusare il pattern di autenticazione.

Decisione: la gestione endpoint entra nel perimetro documentale di questo progetto,
ma **solo in lettura e solo come fotografia**. Aggiunto lo script
`scripts/Get-NinjaSnapshot.ps1`, che si autentica con il flusso OAuth2 client
credentials, interroga in best-effort gli endpoint di inventario, policy, script e
interrogazioni diagnostiche, e produce `output/ninjaone-snapshot.json` piu' un
riepilogo Markdown. Nessuna operazione di scrittura, nessuna esecuzione di script
remoti, nessuna modifica di policy: quelle restano nell'interfaccia dell'RMM e in
mano a chi lo gestisce.

Vincoli sulle credenziali, che sono la parte piu' importante di questa decisione
perche' **le credenziali API appartengono al provider MSP** che gestisce l'RMM e non
al progetto. Lo scope richiesto e' di sola lettura (`monitoring`) e non va esteso a
scope di scrittura: se un giorno servisse scrivere, sara' una decisione separata con
credenziali proprie. Il segreto non viene mai scritto su disco dallo script ne'
passato in chiaro sulla riga di comando: si risolve da parametro, poi da variabile
d'ambiente utente, infine da prompt a runtime come SecureString, lo stesso schema
adottato per Proxmox in ADR-007/008 e per Nebula in ADR-009. Nel repository non
esiste e non deve esistere alcun file con quei valori: `.env` e `.env.*` sono
ignorati da git e non vengono letti da questo script.

Conseguenze: lo snapshot contiene nomi host, utenti connessi e indirizzi reali,
quindi vive in `output/`, che e' ignorato da git, e nulla di quel contenuto entra in
un file tracciato senza passare per `.claude/rules/anonymization.md`. In cambio il
progetto guadagna tre cose concrete: l'inventario delle policy e degli script che
agiscono sugli endpoint, che va conosciuto prima di cambiare rete sotto di loro; il
veicolo per il ri-puntamento massivo delle code di stampa previsto da M22b, perche'
l'RMM e' lo strumento con cui si distribuisce uno script a tutte le postazioni; e
l'interrogazione delle interfacce di rete per dispositivo, che e' la fonte piu'
rapida per il censimento degli indirizzi statici richiesto da M22a e che
sostituisce, dove risponde, un lavoro manuale postazione per postazione.

## ADR-016 — Il quarto AP EOL entra in scope: sostituzione o eliminazione dell'EsternoIrrigazione

Data: 2026-07-28
Stato: attiva. Supera, limitatamente a questo punto, la clausola "fuori scope" di
ADR-012 e la nota corrispondente del micro-step M13b.

Contesto: ADR-012 (20/07/2026) aveva scelto tre access point Zyxel per sostituire i
tre Ubiquiti EOL che coprono personale e ospiti, escludendo esplicitamente il quarto,
"EsternoIrrigazione", perche' non serve copertura Wi-Fi per le persone ma la centrale
di irrigazione sul tetto, e la sua eventuale sostituzione era una decisione separata
non ancora presa. La sostituzione dei tre e' avvenuta ed e' stata verificata in campo
il 27/07/2026: i tre AP nuovi sono in servizio e i tre vecchi sono scomparsi dalle
tabelle MAC. Il quadro percio' e' cambiato in un punto sostanziale. Finche' erano
quattro, il problema dei dispositivi con Debian 7 e Dropbear SSH era una condizione
diffusa e la sua mitigazione passava per un progetto di sostituzione; oggi e' un
singolo apparato, su una porta nota, con un ruolo circoscritto — cioe' un problema
finito, che si chiude invece di gestirlo.

Decisione: portare in scope la bonifica del quarto AP come micro-step M13c, con otto
sotto-passi tracciati in `roadmap.md`, e trattarla come intervento a se' stante e non
come appendice di M13b. La decisione non prescrive l'esito tecnico: la prima opzione
da valutare e' l'eliminazione dell'access point, se la centrale di irrigazione
espone una porta Ethernet raggiungibile dal cavo che arriva al tetto, perche' toglie
insieme un apparato fuori supporto e un salto radio; solo se il collegamento deve
restare wireless si acquista un apparato per esterni gestito.

Conseguenze: il rischio residuo della classe (sistema operativo fuori supporto dal
2016 su un host non gestibile e non filtrabile dentro la LAN piatta) e' ora tracciato
come gap singolo SEC-018 (`GAP-TBC.md` #124) invece che come nota dentro AP-001, e ha
un micro-step assegnato. Due dipendenze da tenere presenti: la passphrase della rete
radio attuale non e' recuperabile, quindi l'intervento comporta per costruzione la
riconfigurazione della centrale di irrigazione, e questo puo' richiedere il fornitore
dell'impianto; e la collocazione finale del dispositivo, o del suo sostituto, e' nel
segmento IoT/OT di M22c, quindi M13c e M22 si incontrano al passo M13c-8. Fino a
quel momento il dispositivo resta nella LAN piatta e l'unica mitigazione disponibile
e' a livello di switch, non di firewall.

## ADR-015 — Perimetro documentale delle VM applicative: asset di rete qui, avanzamento software nei loro progetti

Data: 2026-07-27
Stato: attiva

Contesto: sul nodo Proxmox girano due VM che ospitano progetti software interni
con repository, documentazione e sistema di contesto propri (VM207 website-analyst,
VM208 pilota Portale Asset IT), e la loro popolazione e' destinata a crescere. La
ricognizione del 27/07/2026 ha mostrato il rischio di due derive opposte:
ignorarle, e allora questo repository descrive una rete che non contiene i servizi
che vi girano davvero, oppure duplicarne lo stato di avanzamento, e allora la
documentazione diverge dai progetti originali appena questi fanno un commit.

Decisione: questo repository documenta le VM applicative come *asset di rete* e
si fermano li'. Rientrano nel perimetro l'esistenza della VM nell'inventario, le
sue risorse, il bridge e il segmento su cui e' attestata, le porte e i servizi
che espone, i flussi verso NAS o servizi esterni, la postura di sicurezza e i
gap che ne derivano. Restano fuori dal perimetro le fasi di sviluppo, le
decisioni architetturali applicative, lo stato dei test e la pianificazione delle
feature: quelli vivono nei rispettivi repository, che hanno una propria memoria di
progetto. Il riferimento incrociato e' per nome e ruolo, mai per copia dei
contenuti.

Conseguenze: quando una VM applicativa cambia qualcosa che tocca la rete (nuova
porta pubblicata, cambio di bridge, nuovo flusso verso un NAS o verso Internet,
esposizione dietro la DMZ), la modifica va registrata qui; quando avanza solo il
software, no. La verifica periodica avviene alla riconciliazione dell'inventario
Proxmox, cioe' al prossimo `Get-ProxmoxSnapshot.ps1` (M18) e a ogni ricognizione
live come quella del 27/07. Corollario operativo: l'accesso SSH alle VM e' uno
strumento diagnostico legittimo per questo progetto, perche' e' l'unico modo di
sapere quali porte una VM espone davvero, e non un'intrusione nel progetto
ospitato.
