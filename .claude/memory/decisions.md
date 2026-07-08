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
