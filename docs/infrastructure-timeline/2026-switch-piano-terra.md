# 2026 - Gennaio-Giugno: phishing, switch Piano Terra, NAS INTRA2, dorsale 10 Gbps

## 19/01/2026 - Primo ingaggio Proelium (task_47 cybersecurity)

Proelium Law Firm (studio legale con expertise cybersecurity/GDPR) viene ingaggiato
per supporto su conformità NIS2 e data protection. Referente: avvocato Proelium.
Primo documento prodotto: analisi NIS2 applicabilità a Intrawelt (PMI settore
servizi di traduzione → valutazione soggetto critico / importante).

Parallelo con Serafino (ISO 27001): due percorsi distinti, coordinati da Alessio.

## Gennaio-Marzo 2026 - IntraLino: sviluppo architettura n8n stabile

Stack IntraLino si consolida:
- Ollama (llama3.2, porta 11500, systemd service)
- ChromaDB (porta 8000, persistent store)
- n8n 2.12.3 (Docker, orchestratore workflow)

Script prodotti nel periodo: GroupShare TM export, data manipulation, Proxmox
snapshot (C:\Scripts\proxmox-snapshot), security anomaly checker (v1).

Integrazione Zep per memoria persistente tentata e abbandonata il 25/03/2026:
il nodo n8n ufficiale Zep era già deprecato; alternativa community
(n8n-nodes-zep-v3) non adottata per instabilità.
Stack rimasto: ChromaDB + Ollama + n8n (senza memoria persistente tra sessioni).

## 12/01/2026 - Notes thinking lab: studio Thinking Machines / Tinker API

Fonte: `Sviluppo_interno, scripting (IT on FIRE)/Notes (thinking lab) 12012026.docx`

Ricerca tecnica personale di Alessio su infrastruttura AI avanzata. Documento analizza
Thinking Machines (fondata 2025 da Mira Murati, ex-CTO OpenAI; investitori: a16z, Nvidia,
AMD, Cisco) e il loro prodotto flagship **Tinker API** (fine-tuning e training LLM).

Punti chiave del documento:

- **Tinker API**: primitivi Python (`forward_backward()`, `optim_step()`, `sample()`,
  `save_state()`) per definire custom training loop con GPU cluster managed by Thinking
  Machines. Supporta modelli da 1B a 235B parametri (inclusi MoE e vision-language).
  Fine-tuning via **LoRA** (layer adapter, non modifica pesi base → multi-tenant efficiente).
- **Output**: pesi esportabili per deploy su propri backend SaaS o inference endpoint.

Case study elaborato nel documento: **Enterprise Technical Documentation SaaS**
con n8n + Ollama + Tinker:
- Dataset: manuali tecnici, API reference, procedure operative con metadata per
  dipartimento/sistema.
- Pipeline: n8n gestisce preprocessing e ingestion automatica dei documenti aggiornati.
- Fine-tuning incrementale: LoRA su Tinker triggered da n8n su nuovi documenti.
- Deploy: pesi esportati come inference endpoint; RAG via Ollama in LAN per query
  real-time; interfaccia utente per ingegneri/operations.

Rilevanza per IntraLino roadmap: questo studio documenta il ragionamento su come
evolvere IntraLino (attualmente ChromaDB + Ollama + n8n) verso fine-tuning specializzato
su documentazione tecnica Intrawelt, senza dipendenza da API cloud esterne.

## 13-15/01/2026 - Incidente phishing/compromissione regole Exchange

### Account coinvolti e sintomi

Tre account coinvolti in modo diverso:
- **emonterubbianesi@intrawelt.com** (Elisa): regola inbox sospetta trovata tramite PowerShell EXO
- **mrenzi@intrawelt.com** (Martina): email arrivate il 14/01/2026 scomparse dall'inbox (es. notifica cambio SDI da Sollini Gino srl)
- **anasini@intrawelt.com**: email arrivate ma non visibili (possibile quarantena)

### Analisi Purview (Microsoft Defender/Compliance)

Rilevata attività "**MailRedirect**" su info@intrawelt.com:
- Operazione: `Set-InboxRule` (modifica regola posta in arrivo)
- Regola modificata: intercetta email da `procurement.it@bayer.com` con oggetto contenente "ordine d'acquisto", applica categoria "Inoltro OK", inoltra a tre indirizzi interni, ferma elaborazione altre regole.
- ClientIP: **193.124.241.5** (indirizzo IP pubblico Intrawelt → modifica dall'interno della rete o VPN). NON un attaccante esterno.

Purview classifica qualsiasi regola che inoltra messaggi come "RISKYACTIVITY MailRedirect" anche se legittima.

### Regola sospetta su Elisa (PowerShell ExchangeOnline)

```powershell
Connect-ExchangeOnline
Get-InboxRule -Mailbox emonterubbianesi@intrawelt.com | Format-List
```

Due regole trovate **non visibili da Outlook Classic Windows 11** (solo via EXO PowerShell):
- Regola "Junk": marca messaggio come Letto, sposta in "Cronologia conversazioni", ferma elaborazione.

### Remediation

- Regola sospetta rimossa via PowerShell EXO
- Creata regola firewall "Blocco_Gruppo_IP_Phishing_Elisa" sul Zyxel USG FLEX 500
  → ma la regola aveva erroneamente `action=ALLOW` invece di `DENY` (gap FW-001)
- Analisi malware: file `Malware-List_2026-01-13_2026-01-15_UTC.xlsx` (lista IP/domini bloccati)
- Email scomparse: verificato che Alessandro stava eliminando da info (auto-quarantena)

### Lezioni apprese

- Le regole di posta M365 non sono tutte visibili da Outlook → monitorare via Purview periodicamente
- La regola firewall FW-001 deve essere corretta (action=DENY); vedi docs/runbook-anomalie.md
- Necessità di formazione anti-phishing per tutti i dipendenti (gap ISO-003)

## 13/02/2026 - Ticket Aruba: analisi backup e WAF VPS SCENIA

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §Ticket Aruba

Alessio apre ticket Aruba ARU-340414, ID **18346774A** per chiarire le opzioni di
backup e WAF della VPS di produzione SCENIA (O2A4: 4 vCPUs, 8 GB RAM, 80 GB storage,
50 TB/mese data transfer, Ubuntu 22.04 LTS, IP 80.211.141.50).

**Risposta Aruba su backup VPS:**
- SWITCH OFF SERVER = spegnimento, RESET = riavvio, INIZIALIZZA = reset a stato
  iniziale (perde tutti i dati).
- Limite 25 TB/mese = somma traffico in entrata + in uscita.
- Backup disponibili tramite guida: kb.cloud.it/public-cloud/backup/cloud-backup.aspx

**Risposta Aruba su WAF (27/02/2026, ticket ID 18401201A):**
- WAF su VPS non supportato da Aruba (le VPS sono macchine standalone senza rete
  virtuale configurabile).
- WAF disponibile solo su server dedicati VMware con firewall Pfsense/Fortinet FortiGate 40F.
- Soluzione dichiarata da Aruba: "per VPS usare soluzioni open-source per gestione custom."

Decisione post-ticket: ModSecurity v3 + OWASP valutato ma abbandonato (troppo pesante
su risorse). Cloudflare Free come soluzione alternativa (vedi sezione 11/05/2026).

## Gennaio-Febbraio 2026 - CVE patch SCENIA (React / Next.js)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §CVE tracking

### CVE-2025-66478 (React/Next.js – critical 10.0, gen 2026)

Server-side vulnerability in React.js tracked as CVE-2025-55182 (React) e
CVE-2025-66478 (Next.js). Remediazione: migrazione alla versione patchata + rotazione
di tutte le credenziali. Completata fine gennaio 2026. Rilevato tramite advisory
nextjs.org/blog/CVE-2025-66478.

### CVE-2026-23864 (Next.js DoS – feb 2026)

Vulnerabilità in React Server Components App Router: deserializzazione HTTP non
limitata → incremento incontrollato CPU, out-of-memory, crash Node.js → DoS remoto
senza prerequisiti. Fix: aggiornamento Next.js a ≥ 16.1.5.

### CVE-2025-59471 (Next.js Image Optimizer – feb 2026)

Image Optimizer self-hosted scarica l'intero file remoto in memoria via arrayBuffer()
prima di validare → memory bomb. Attacco: fornire file immagine enorme.
Fix: Next.js ≥ 16.1.5 (streaming + controllo dimensioni).

Processo di rilevamento: `pnpm audit` eseguito periodicamente. Prisma dependency
vulnerability rilevata nella stessa sessione.

## 04/03/2026 - Meeting Odoo portale SCENIA (Susanna Ortini, OpenForce)

Pianificazione integrazione portale SaaS SCENIA → creazione SO in T-Rex/Odoo.
Protocollo: xml-rpc standard Odoo (no moduli aggiuntivi). Utente servizio: asopranzi@intrawelt.com
(dedicato, senza licenza aggiuntiva). Ambiente test: intrawelt-test.openforce.it.
Warning: xml-rpc deprecato da v19, rimosso da v20 → migrare a json-rpc in futuro.
Dettagli tecnici: docs/helpdesk-operations.md §Integrazione portale SCENIA.

## Aprile 2026 - Installazione switch Piano Terra: Zyxel XGS2220-30HP

### Stato pre-installazione

Fino ad aprile 2026 il Piano Terra e' gestito da due apparati separati:
ZYXEL GS1900-24 (managed, L2, 24 porte GbE): switch principale degli endpoint.
Cisco (router fisico) con adattatore PoE esterno: gestisce alcuni AP e la porta
verso 0-R-18.

Connessioni fisiche del Cisco: porta su patch panel 0.8.1 con patch verso 0.9.1
(dove sta un AP esterno), adattatore PoE verso porta 0.7.1 (AP), terza porta
diretta verso 0-R-18.

L'uplink dal Piano Terra al Piano 2 e' su rame a 1 Gbps, che e' il limite fisico
della connessione tra i due piani.

### Motivazione funzionale

L'installazione e' propedeutica al progetto di migrazione fonia con centralino
cloud Vianova. Il nuovo switch Zyxel XGS2220-30HP permette VLAN tagging nativo:
VLAN 2 dedicata ai telefoni IP fisici (fonia), VLAN 1 (o altra) per i dati.
Il riconoscimento OUI dal MAC address del telefono permette di buttare il
dispositivo automaticamente sulla VLAN telefonica.

Vantaggi rispetto alla configurazione precedente:
Il Cisco puo' essere rimosso (lo switch nuovo e' Layer 3 e gestisce il routing
inter-VLAN). L'adattatore PoE separato del Cisco viene eliminato (lo switch nuovo
ha PoE+ integrato su tutte le 24 porte RJ45, IEEE 802.3at, budget 400 W totali).
L'uplink verso il Piano 2 passa da 1 Gbps rame a 10 Gbps fibra SFP+ (dorsale).

### Hardware installato

Zyxel XGS2220-30HP-EU0101F:
24 porte GbE RJ45 con PoE+ (IEEE 802.3at).
4 porte SFP+ 10 Gbps per uplink e dorsale.
Budget PoE: 400 W.
Consumo massimo dichiarato: 477 W (di cui 400 W PSE).
Alimentazione: 100-240 V, 50-60 Hz.
Layer 3: routing statico + inter-VLAN.
Gestione cloud: Nebula (stesso sito del Piano 2 XGS2220-54HP).
Pannello frontale: porte RJ45 per accesso con PoE+ a sinistra, porte SFP+ uplink
a destra, porta console per gestione locale.
Quick Setup Guide: download.zyxel.com/QSG/Nebula-managed-switch-QSG.pdf
(redirect a Nebula-managed-switch-QSG.pdf).

### Osservazioni architetturali da Nebula pre-installazione

Stato rilevato da Nebula per lo switch Zyxel XGS2220-54HP al Piano 2 (aprile 2026):

Porta 33 verso il firewall Zyxel USG FLEX 500: Speed 1G/Auto (Copper), Type Trunk
port con PVID 1, Allowed VLANs All. Questa porta e' il collo di bottiglia fisico
dell'uscita WAN e del routing centrale: tutta la rete, pur avendo backbone interno
a 10 Gbps tra switch, e' instradata verso il firewall attraverso una singola porta
a 1 Gbps. LLDP (Link Layer Discovery Protocol) attivo.

Porta 52 verso Piano Terra (uplink preesistente): Speed 10G/Auto (SFP+), configurata
come trunk con tutte le VLAN ammesse. Questa porta e' gia' predisposta per 10 Gbps
ma la velocita' effettiva dipende dal transceiver e dal dispositivo collegato all'altra
estremita'. Al momento del rilevamento Nebula la porta vede ancora lo switch vecchio
Piano Terra.

Porta verso QNAP QSW-1208-8c: connessione a 10 Gbps solo per Marcello Carlacchiani
(collegamento dedicato al suo workstation).

### Configurazione Nebula post-installazione

Accesso Nebula: nebula.zyxel.com/cc/ui/index.html#/66e2c72407a81ccfe505a296/
66e2c739dae741bea731bec4/site-wide/monitor/dashboard

Al primo accesso dopo l'installazione:
Il LAN IP dello switch Piano Terra appena montato e' diverso rispetto allo switch
Piano 2. Lo switch Piano Terra ha preso la classe .90 invece della .10.

Causa: il vecchio switch Piano Terra era ancora connesso tramite la porta P8 del
firewall (che faceva da DHCP server per la classe .90). Il collegamento fisico
passava: Piano Terra (vecchio switch) su patch panel, poi patch verso P8 del
firewall Zyxel, poi dalla P8 andava sulla porta 39 dello switch Piano 2. Quando
staccata la patch da P8, lo switch Piano Terra si e' disconnesso dalla dashboard
admin Nebula.

Procedura di risoluzione:
1. Staccata la patch dalla porta P8 del firewall (verificata anche su Nebula
   Configure > Switch ports dello switch Piano 2, porta 40).
2. Staccata la fibra tra Piano Terra e Piano 2, poi riattaccata.
3. Lo switch Piano Terra prende ora la classe .10 (DHCP server del firewall).
4. Rimesso in DHCP: 192.168.10.10 (assegnato dal DHCP server firewall, classe .10).

Dettaglio porta 30 dello switch Piano Terra (uplink SFP+):
Configurata come uplink. Attiva a 10 Gbps verso il Piano 2.
Il vecchio switch Piano Terra era rimasto attaccato (andava a 1 Gbps) mentre il
nuovo switch Piano Terra ha l'SFP+ a 10 Gbps. Il connettore temporaneo lasciato
era quello vecchio (proveniente dallo switch dismesso).

Sulla porta 29 dello switch Piano Terra nuovo: attaccato il convertitore (slot
SFP+ vuoto al momento dell'ispezione). Il convertitore vecchio e' visibile come
"non si parla" con quello gia' presente sopra al QNAP QSW-1208-8c al Piano 2.
Necessaria sostituzione di entrambi i connettori SFP+.

Situazione DHCP: il problema e' che se sta attaccato il cavo della classe .90 e
si spengono e riaccendono gli switch senza VLAN taggate si crea un conflitto.
Rimozione del DHCP server classe .90 e' pendente come task (vedi GAP-TBC.md).

## 11/05/2026 - Architettura sicurezza VPS SCENIA: Cloudflare Zero Trust (con Fabio Giorgini)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §Ragionamento con Fabio architettura sicurezza VPS

Decisione architetturale presa il 11/05/2026 in riunione con Fabio Giorgini.

**Scelta: Cloudflare Free + cloudflared tunnel (al posto di ModSecurity WAF locale)**

Motivazione:
- ModSecurity su VPS staging già causava degrado prestazioni.
- ModSecurity richiede configurazione manuale delle rule; Cloudflare ha DDoS,
  caching, image optimization incluse nel piano gratuito.
- Con cloudflared tunnel le porte 80/443 della VPS vengono chiuse (ufw deny):
  unico canale di comunicazione HTTP è Cloudflare → IP del server mascherato.
  Attacco DDoS diretto all'IP del server viene bloccato a monte.

**Setup staging (eseguito):**
- Account Cloudflare: dash.cloudflare.com (piano Free)
- Zero Trust: scenia.cloudflareaccess.com (team name)
- NS delegati a Cloudflare: kaiser.ns.cloudflare.com, tara.ns.cloudflare.com
  (già delegati da Register.it)
- cloudflared installato su VPS staging (93.186.255.24) via apt GPG key
- Porte 80/443 chiuse con `ufw deny`; accesso SSH consentito solo da IP Intrawelt
  e IP Fabio (95.236.26.239)
- Nginx proxy su porta 80 → Next.js porta 3000

**DNS scenia.it (stato al momento del setup):**
| Dominio | A record | Ruolo |
|---------|----------|-------|
| scenia.it | 80.211.141.50 | Sito istituzionale (one-page) |
| portal.scenia.it | 80.211.141.50 | Portale produzione (Trados Accelerate) |
| contact.scenia.it | 80.211.141.50 | Landing form contatti (design Attilio) |
| staging-portal.scenia.it | 93.186.255.24 | Portale staging (proxato Cloudflare) |

**Produzione:** cloudflared tunnel pianificato anche per VPS produzione nella fase
successiva. Fail2Ban attivo su entrambe le VPS (ban IP dopo 3-4 tentativi SSH falliti).
Mailtrap usato per email transazionale (form contatto, webhook portale).
Lynis come tool di auditing OS della VPS.

Repository sicurezza: github.com/Intrawelt-SaaS/security (README con dettaglio setup).

## 29/05/2026 - Interventi Voice VLAN e fibra NAS

### NAS INTRA2 - migrazione da Ethernet a fibra 10GbE

Il NAS INTRA2 (QNAP TS-435XeU-4G, 192.168.20.177) viene migrato dalla scheda
Ethernet (Adapter 4, 2.5GbE) alla scheda fibra 10GbE (Adapter 1). Procedura:
disabilitare la scheda Ethernet, assegnare lo stesso IP statico alla scheda fibra
via DHCP poi configurazione statica, disconnettere fisicamente il cavo Ethernet.
[TBC: IP di management durante la migrazione era 192.168.10.210:8080 - verificare
configurazione definitiva Adapter 1 10GbE]. Job di backup PC-ALESSIO testato e
funzionante dopo la migrazione.

### Voice VLAN 2 - configurazione Nebula

Configurazione Voice VLAN sui due switch Zyxel via Nebula (nebula.zyxel.com).

**Telefoni attivi e posizione**:
- Alessandro Potalivo: Yealink SIP-T34W (Piano Terra, XGS2220-30HP, porte 21/23)
- Sonia Martellini: Yealink SIP-T34W (Piano Terra)
- Martina Renzi: Yealink SIP-T34W (Piano Terra)
- Marsk Marini: Yealink SIP-T31G (Piano 2, XGS2220-54HP, porte 3/5 PoE)
- Sala Conero: Yealink SIP-T31G (Piano 2, XGS2220-54HP, porta 44 PoE)

**Configurazione Voice VLAN**:
- VLAN ID: 2 (voce).
- Metodo: LLDP-MED (entrambi i modelli Yealink T31G e T34W supportano LLDP-MED).
- LLDP-MED e' preferito a OUI perche' la negoziazione e' bidirezionale e non
  richiede gestione manuale della lista OUI.
- CoS 802.1p: 5 (valore standard IEEE per voce RTP).
- DSCP: 46 (EF - Expedited Forwarding, RFC 3246). [TBC: default Nebula mostra 44,
  verificare se e' stato modificato a 46.]

**Configurazione porta telefono** (porte 21, 23 Piano Terra; porte 3, 5, 44 Piano 2):
```
Type: Access
VLAN type: Voice VLAN (LLDP-MED)
PVID: 1  (traffico dati untagged)
LLDP: Enabled
```

**Porte PC** (28 porte Piano Terra, configurate via selezione multipla):
```
Type: Access
VLAN type: None
PVID: 1
```
[TBC: verificare che il salvataggio delle 28 porte sia avvenuto correttamente.]

**Porta uplink fibra SFP+**: Trunk con VLAN dati (untagged) + VLAN 2 voce (tagged).

La configurazione e' propedeutica alla migrazione al centralino cloud Vianova:
i telefoni Yealink possono operare in SIP direttamente senza passare dal
centralino fisico Panasonic KX-NCP1000.

### Con myOffice 09/06/2026 - centralino cloud

Incontro con myOffice/Vianova il 09/06/2026 per la migrazione al centralino cloud.
[TBC: steps, piano di numerazione, configurazione Patton SmartNode durante
la transizione, timeline. Alessio ha screenshot nella cartella steps.]

---

## Aprile-Giugno 2026 - Redesign sito intrawelt.com

Cappelli Design (referente Anna Caruso) avvia il redesign del sito intrawelt.com.
Piattaforma: WordPress. Gestore IT: Tommaso Vezeni.

10/04/2026: Cappelli Design inizia a condividere contenuti per il nuovo sito.
Creato utente WordPress `marketing_cappelli` con ruolo Editor → escalato a Amministratore
per consentire l'export dei contenuti (blog, news).

20/04/2026: richiesta ambiente di test (copia 1:1 del sito attuale) da parte di Cappelli.
Ambiente test creato su infrastruttura IT Intrawelt.

Primo rilascio escluse: Ricerca, Solution Finder, slider homepage azienda,
modulo richiesta consulenza; pagine "Certificazioni" e "Policy" (aggiunte in scope ma
fuori dal primo rilascio). Tempistiche secondo rilascio: TBD.

## 07/05/2026 - Guasto NAS INTRA2 e sostituzione

Il NAS INTRA2 (QNAP TS-451U, 192.168.20.177) subisce un guasto. L'apparato viene
sostituito con un QNAP TS-435XeU-4G. I 4 dischi da 8 TB (RAID 5) installati a
gennaio 2025 vengono migrati nel nuovo chassis. L'indirizzo IP rimane 192.168.20.177.

[TBC: dettagli del guasto TS-451U (tipo di errore, log QNAP), procedura esatta
di migrazione dischi nel nuovo chassis TS-435XeU-4G, eventuali problemi riscontrati,
screenshot del nuovo NAS operativo con RAID ricostruito.]

## 08/05/2026 - Sostituzione connettori SFP+: dorsale a 10 Gbps operativa

I due connettori SFP+ (quello sullo switch Piano Terra e quello sullo switch Piano 2)
erano incompatibili tra loro: il connettore vecchio dallo switch Piano Terra dismesso
non si parlava con quello gia' installato sopra al QNAP QSW-1208-8c al Piano 2.

Acquistati due nuovi connettori SFP+ compatibili. Procedura di sostituzione:

1. Inserito il primo connettore nuovo sullo switch Piano Terra (XGS2220-30HP).
2. Inserito il secondo connettore nuovo sullo switch Piano 2 (XGS2220-54HP, lato
   che va verso il QNAP QSW-1208-8c).
3. Spostata la patch fibra sul Piano Terra verso il nuovo connettore.
4. Impostazione su Nebula del connettore nuovo su entrambi gli switch.

Risultato: la dorsale Piano Terra - Piano 2 negozia e comunica a 10 Gbps
(confermato da Nebula: Speed 10G, full duplex, su entrambe le porte SFP+ coinvolte).

---

## Gennaio-Aprile 2026 - SCENIA sviluppo full-stack (Fabio Giorgini)

Sviluppo principale su branch con Fabio Giorgini (collaboratore esterno, modello
fork + PR). Snapshot repository analizzato: staging 27/02/2026 → main 22/04/2026
(analisi prodotta in 13_Maggio 2026 / analysis-output/).

8 cluster funzionali sviluppati nel periodo:

| Cluster | Descrizione principale |
|---------|----------------------|
| A - files_storage | Upload file con BusboyAdapter (multipart/preservazione dir), buildFileTree utility, STORAGE_PATH env var (breaking change 11/03/2026: chmod 750, nginx proxy_buffering) |
| B - translation_form_ui | Form traduzione lato frontend TypeScript |
| C - email_mjml | Template email MJML |
| D - sessions_hydration | Gestione sessioni e hydration state |
| E - estimate_summary_planner | Preventivi, sommari, planner traduzioni |
| F - trados_integration | Integrazione API Trados RWS (SDLXLIFF → API → progetto) |
| G - contactus_cors | Modulo "Contact us", configurazione CORS |
| H - admin_users | Gestione utenti admin, permessi |

Breaking change 11/03/2026: aggiunta variabile d'ambiente STORAGE_PATH per
configurare il path del filesystem condiviso; nginx `proxy_buffering off` per
upload grandi; chmod 750 sulle directory storage.

ER diagram: diagrammaER 18052025.png (18/05/2025, primo schema E/R definitivo);
note database e diagramma.docx (evoluzione successiva).

28/05/2026: studio integrazione Odoo-SCENIA documentato in
`studio_integrazione Odoo 28052026.docx` (cartella odoo-related del progetto).

## Maggio-Giugno 2026 - SCENIA DPA e DPIA ScenIA

### DPA ScenIA v1.0 → v1.7

Redazione del Data Processing Agreement (GDPR Art. 28) tra Intrawelt (Processor)
e il Titolare del trattamento ScenIA. Fabio Giorgini (AIDAPT) come sub-processor.

Versioni DPA:
- v1.1 (08/06/2026): prima bozza condivisa con AIDAPT
- v1.2-v1.5: revisioni su Allegato II (TOMs), TOC, definizioni
- v1.6 (10/06/2026): aggiornamento Allegato II con gap confermati da AIDAPT
- v1.7 (11/06/2026): bozza corrente; Allegato II gap confermati:
  - SAST/DAST nella CI/CD: assente (confermato AIDAPT)
  - VA/Penetration test: mai eseguiti (confermato)
  - Qdrant audit log: non configurato (confermato)
  - API rate limiting: non implementato (ETA incerta)
  - Zero Data Retention Azure OpenAI: attivo (confermato)
  - KMS dedicato AWS Organization: attivo

Pending: completare placeholder Parti, negoziare massimali responsabilità,
inviare questionario tecnico a AIDAPT (confermato gap VA/PT).

### DPIA ScenIA

Documento DPIA in corso (template EDPB v1.0 2026). Sezioni [DA COMPLETARE]:
validazione tecnica AIDAPT, dati del Titolare, misure di mitigazione residuali.
Previste completamento entro luglio 2026.

Standard di riferimento: ETSI EN 304 223 V2.1.1 (AI security, adottato 08/12/2025),
citato in DPA Allegato II.

## 09/06/2026 - Riunione myOffice: migrazione centralino cloud Vianova

Riunione con Alessia Liberati (myOffice) per la migrazione al centralino cloud Vianova.
La Voice VLAN 2 configurata il 29/05/2026 è propedeutica: i Yealink T31G/T34W
supportano SIP diretto verso il centralino cloud eliminando la dipendenza dal
Panasonic KX-NCP1000 fisico.

[TBC: piano di numerazione definitivo, configurazione Patton SmartNode durante
la transizione, timeline attivazione numeri cloud.]

## Stato della rete a giugno 2026

### Topologia

WAN: Vianova FTTO 1 Gbps simmetrica nominale. IP pubblici: 193.124.241.x/28
(gateway .1, IP WAN Intrawelt .5). Backup: Vianova ponte radio Line Recovery
Standard (100 Mbps download, 20 Mbps upload). Failover automatico con mantenimento
IP pubblici via HSRP tra Router R-1000 principale e Router R-1000 backup.

Switch Vianova S-1000 distribuisce: una porta dati verso WAN1 del firewall Zyxel,
una porta per la linea fonia VoIP.

Firewall: Zyxel USG FLEX 500. IP LAN: 192.168.20.1. Porta verso switch Piano 2:
1 Gbps rame (collo di bottiglia fisico per l'uscita WAN). VPN SSL: 193.124.241.x:443.

Switch Piano 2: Zyxel XGS2220-54HP (48 porte GbE PoE++ + 6 SFP+ 10 Gbps, L3,
Nebula). Porta 33: firewall 1 Gbps rame. Porta SFP+ 52: dorsale verso Piano Terra
10 Gbps fibra (operativa dall'08/05/2026). HP ProLiant DL380 Gen10 (Proxmox VE
8.3.4, 192.168.20.11:8006, iLO5 192.168.20.9). NAS HERO (.169), NAS INTRA (.168),
NAS INTRA2 (.177 TS-435XeU-4G), NAS INTRA3 (.172 vuoto), NAS documenti (.170).

Switch Piano Terra: Zyxel XGS2220-30HP (24 porte GbE PoE+ + 4 SFP+ 10 Gbps, L3,
Nebula, installato aprile 2026). Uplink SFP+: 10 Gbps verso Piano 2 (operativo
dall'08/05/2026). IP management: 192.168.10.10 (DHCP classe .10 del firewall).

Cloud SEEWEB (tunnel IPsec operativo dal 24/06/2025):
Firewall OPNsense: 10.1.116.1 (user1 / [redacted]).
WINGROUPSHARE: 10.1.116.3 (Windows Server, GroupShare Trados, Cobian Backup, RDP
Administrator / [redacted], WAN: 212.35.202.x).
WINSRV2019: 10.1.116.4 (Windows Server 2019, desktop remoti DTP e PM, utente analisi1).

### Lavori aperti

Rimozione DHCP server classe .90 (configurazione residua dallo switch Piano Terra
vecchio).
VLAN tagging fonia Piano Terra: VLAN 2 per i due telefoni IP fisici, riconoscimento
OUI da MAC address in Nebula.
Wi-Fi su VLAN separata dalla classe .10.
Completamento implementazione nuova fonia Vianova (centralino cloud).
Dismissione HP G5 (VMware ESXi fisico) e migrazione VM su Proxmox.
Restituzione materiale TIM (Huawei AR651W, AR1220E, Taurus Bond): ancora in sede.
