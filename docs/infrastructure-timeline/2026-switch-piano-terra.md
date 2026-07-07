# 2026 - Gennaio-Giugno: phishing, switch Piano Terra, NAS INTRA2, dorsale 10 Gbps

## 19/01/2026 - Primo ingaggio Proelium (task_47 cybersecurity)

Proelium Law Firm (studio legale con expertise cybersecurity/GDPR) viene ingaggiato
per supporto su conformità NIS2 e data protection. Referente: avvocato Proelium.
Primo documento prodotto: analisi NIS2 applicabilità a Intrawelt (PMI settore
servizi di traduzione → valutazione soggetto critico / importante).

Parallelo con Consulente-ISO27001-1 (ISO 27001): due percorsi distinti, coordinati da Alessio.

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
- **persona-i@intrawelt.com** (Persona-I): regola inbox sospetta trovata tramite PowerShell EXO
- **persona-c@intrawelt.com** (Martina): email arrivate il 14/01/2026 scomparse dall'inbox (es. notifica cambio SDI da Sollini Gino srl)
- **persona-j@intrawelt.com**: email arrivate ma non visibili (possibile quarantena)

### Analisi Purview (Microsoft Defender/Compliance)

Rilevata attività "**MailRedirect**" su info@intrawelt.com:
- Operazione: `Set-InboxRule` (modifica regola posta in arrivo)
- Regola modificata: intercetta email da `procurement.it@bayer.com` con oggetto contenente "ordine d'acquisto", applica categoria "Inoltro OK", inoltra a tre indirizzi interni, ferma elaborazione altre regole.
- ClientIP: **203.0.113.5** (indirizzo IP pubblico Intrawelt → modifica dall'interno della rete o VPN). NON un attaccante esterno.

Purview classifica qualsiasi regola che inoltra messaggi come "RISKYACTIVITY MailRedirect" anche se legittima.

### Regola sospetta su Persona-I (PowerShell ExchangeOnline)

```powershell
Connect-ExchangeOnline
Get-InboxRule -Mailbox persona-i@intrawelt.com | Format-List
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
50 TB/mese data transfer, Ubuntu 22.04 LTS, IP <IP-SCENIA-VPS-PROD>).

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

## 19/02/2026 - CSRF Token T-Rex/Odoo (Persona-F)

Fonte: `Helpdesk_T-Rex/Problema CSRF Token T_Rex.docx`

Persona-F segnala a Persona-E: batch upload XML analisi in T-Rex bloccato
(caricamento infinito) + alert "Session expired (invalid CSRF token)" + stampa preventivi
fallisce se eseguita subito dopo altra stampa. Problema specifico della postazione di
Chiara; gli altri utenti non riscontrano problemi.

Diagnosi: sessione Odoo corrotta → CSRF invalido → richieste POST batch non autorizzate.
Risoluzione: pulizia completa sessione browser (logout, chiusura browser, eliminazione
cookie/cache dominio trex.intrawelt.com, DevTools Clear site data, ipconfig /flushdns).
Procedura operativa completa in helpdesk-operations.md §T-Rex CSRF Token.

## 23/03/2026 – Analisi blocco traffico centralino (Vianova / USG FLEX 500)

Fonte: `ARCHITETTURA SERVER-CLOUD-LINEE/ZYXEL FIREWALL e VPN/Ricerca Blocco Traffico in uscita per centralino.docx`
Trigger: mail da referente-vianova-1@myofficegroup.it (Vianova/MyOffice) del 23/03/2026 con richiesta di verifica.

Analisi su Zyxel USG FLEX 500: verifica se il firewall blocca il traffico VoIP/SIP del centralino Panasonic.

**IP e porte verificate (Address + Service Objects creati):**

| Subnet / IP | Porta / Range | Protocollo |
|-------------|---------------|------------|
| <RANGE-VIANOVA-SIP-1> | TCP 5061 | SIP |
| <RANGE-VIANOVA-SIP-1> | UDP 20000–40000 | RTP media |
| <RANGE-VIANOVA-SIP-2> | TCP 5039 | — |
| <IP-VIANOVA-MGMT> | TCP 433 | — |
| <IP-VIANOVA-SIP-3> | TCP 5222 | — |
| <IP-VIANOVA-MEDIA-1> | TCP 6050, UDP 6050 | — |
| <RANGE-VIANOVA-MEDIA-2> | TCP 14000–14999, UDP 15000–15999 | — |

**Esito:** nessuna Security Policy blocca le subnet sopra in uscita; i log
(`Monitor → Log`) non riportano alcun blocco per nessuno degli IP/porte verificati.
Conclusione: il firewall USG FLEX 500 **non è la causa** del problema centralino.

## 04/03/2026 - Meeting Odoo portale SCENIA (Referente-OpenForce-1, OpenForce)

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

Porta verso QNAP QSW-1208-8c: connessione a 10 Gbps solo per Persona-G
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
4. Rimesso in DHCP: 10.61.10.10 (assegnato dal DHCP server firewall, classe .10).

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

## 11/05/2026 - Architettura sicurezza VPS SCENIA: Cloudflare Zero Trust (con Collaboratore-Esterno-1)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §Ragionamento con Fabio architettura sicurezza VPS

Decisione architetturale presa il 11/05/2026 in riunione con Collaboratore-Esterno-1.

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
- cloudflared installato su VPS staging (<IP-SCENIA-VPS-STAGING>) via apt GPG key
- Porte 80/443 chiuse con `ufw deny`; accesso SSH consentito solo da IP Intrawelt
  e IP Fabio (<IP-COLLABORATORE-ESTERNO>)
- Nginx proxy su porta 80 → Next.js porta 3000

**DNS scenia.it (stato al momento del setup):**
| Dominio | A record | Ruolo |
|---------|----------|-------|
| scenia.it | <IP-SCENIA-VPS-PROD> | Sito istituzionale (one-page) |
| portal.scenia.it | <IP-SCENIA-VPS-PROD> | Portale produzione (Trados Accelerate) |
| contact.scenia.it | <IP-SCENIA-VPS-PROD> | Landing form contatti (design Attilio) |
| staging-portal.scenia.it | <IP-SCENIA-VPS-STAGING> | Portale staging (proxato Cloudflare) |

**Produzione:** cloudflared tunnel pianificato anche per VPS produzione nella fase
successiva. Fail2Ban attivo su entrambe le VPS (ban IP dopo 3-4 tentativi SSH falliti).
Mailtrap usato per email transazionale (form contatto, webhook portale).
Lynis come tool di auditing OS della VPS.

Repository sicurezza: github.com/Intrawelt-SaaS/security (README con dettaglio setup).

## 29/05/2026 - Interventi Voice VLAN e fibra NAS

### NAS INTRA2 - migrazione da Ethernet a fibra 10GbE

Il NAS INTRA2 (QNAP TS-435XeU-4G, 10.61.20.177) viene migrato dalla scheda
Ethernet (Adapter 4, 2.5GbE) alla scheda fibra 10GbE (Adapter 1). Procedura:
disabilitare la scheda Ethernet, assegnare lo stesso IP statico alla scheda fibra
via DHCP poi configurazione statica, disconnettere fisicamente il cavo Ethernet.
[TBC: IP di management durante la migrazione era 10.61.10.210:8080 - verificare
configurazione definitiva Adapter 1 10GbE]. Job di backup PC-ALESSIO testato e
funzionante dopo la migrazione.

### Voice VLAN 2 - configurazione Nebula

Configurazione Voice VLAN sui due switch Zyxel via Nebula (nebula.zyxel.com).

**Telefoni attivi e posizione**:
- Persona-A: Yealink SIP-T34W (Piano Terra, XGS2220-30HP, porte 21/23)
- Persona-B: Yealink SIP-T34W (Piano Terra)
- Persona-C: Yealink SIP-T34W (Piano Terra)
- Persona-D: Yealink SIP-T31G (Piano 2, XGS2220-54HP, porte 3/5 PoE)
- Sala-1: Yealink SIP-T31G (Piano 2, XGS2220-54HP, porta 44 PoE)

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

## 29/05/2026 - Analisi configurazione Zyxel USG FLEX 500

Fonte: `Analisi_Zyxel_USG_FLEX_500.docx`, backup `startup-config.conf` datato
19/05/2026 (2215 righe, firmware ZLD 5.42(ABUJ.1)).

Prima analisi strutturata del file di configurazione del firewall: porte fisiche
e port-grouping (P4/P5/P6 in bridge L2 sotto lan1, nonostante le etichette logiche
lan2/dmz), interfacce WAN/LAN/DMZ, VPN (due tunnel IPsec verso lo stesso peer
SEEWEB, VPN remote-access IKEv2, SSL VPN), NAT/virtual server, security policy
e UTM. Individuate dieci anomalie (FW-001 - FW-010), la piu' critica delle quali
e' la regola `Blocco_Gruppo_IP_Phishing_Elisa` con `action allow` invece di
`deny`, introdotta durante la remediation dell'incidente phishing del
13-15/01/2026: la regola, essendo la prima valutata dal motore, fa passare
indisturbato qualunque traffico dagli undici IP della lista invece di bloccarlo.
Dettaglio completo delle dieci anomalie in `docs/firewall-zyxel-usg-flex-500.md`.

Parallelamente viene prodotta un'analisi comparativa su come collocare
correttamente una VM Proxmox in DMZ (`zyxel-dmz-proxmox.md` e i diagrammi
`dmz_con_trunk.svg` / `dmz_senza_trunk.svg`, archiviati in
`.claude/context/diagrams/firewall-dmz-2026/`): la porta DMZ del firewall (P7)
e' oggi fisicamente isolata dal segmento su cui e' collegato Proxmox, quindi
una VM raggiunta via NAT ma con IP in subnet LAN non e' realmente in DMZ, e'
un host LAN con port forwarding. Le due opzioni valutate sono un secondo cavo
dedicato da P7 a una seconda NIC del server (scartata: rigida, consuma porte,
non scala) e un trunk 802.1Q che porta la VLAN DMZ sullo stesso cavo fisico
gia' usato dalla LAN, smistata poi da un bridge Proxmox VLAN-aware. La seconda
opzione e' quella adottata nel piano di revisione del 05/06/2026.

## 05/06/2026 - Piano di revisione rete DMZ/Proxmox (sei fasi)

Fonte: `Revisione_Rete_DMZ_Proxmox.docx`, `Piano_Operativo_Migrazione.docx`,
`LE SEI FASI.txt`.

Il piano operativo traduce l'anomalia FW-001 e l'architettura DMZ a trunk in
una sequenza di sei fasi con applicazione dal seriale del firewall, ciascuna
con un proprio punto di ritorno esplicito: Fase 0 corregge subito, via GUI e
senza attendere la finestra di manutenzione, la regola phishing (allow -> deny,
rimozione dell'IP del firewall stesso dal gruppo); Fase 1 prepara backup,
verifica fisicamente console seriale e accesso iLO, e conferma il prerequisito
non ancora validato che lo switch XGS2220-54HP supporti 802.1Q; le Fasi 2 e 3
configurano VLAN 201 sullo switch e bridge VLAN-aware su Proxmox a impatto
nullo sulla produzione (nessun cavo ancora spostato); la Fase 4 posa il cavo
da P7 e valida la catena L2 con `arping`/`tcpdump` prima di toccare il firewall,
spiegando perche' un ping ordinario possa legittimamente non rispondere in
quel momento; la Fase 5 applica la configurazione aggiornata dalla console
seriale con una doppia rete di protezione, lo startup-config precedente resta
intatto finche' la verifica non e' conclusa, piu' un meccanismo di
`lastgood` automatico lato firewall; la Fase 6 verifica nell'ordine in cui gli
utenti se ne accorgerebbero (prima la navigazione LAN, poi la SSL VPN, poi il
tunnel IPsec, poi il raggiungimento della VM DMZ), consolida con 48 ore di
osservazione log e chiude con le pulizie fisiche del cablaggio provvisorio.

Il file `startup-config.conf` datato 05/06/2026 e conservato con il piano
contiene gia' in testa un changelog che descrive gli otto interventi previsti
(rimozione WAN_TRUNK e delle rotte statiche legate a LAN2, correzione delle due
regole allow->deny, attivazione della zona DMZ senza pool DHCP, pubblicazione
web via `wan1:2`): e' la configurazione target preparata per il caricamento
in Fase 5, **non** un backup post-applicazione. Alla data del 01/07/2026 la
Fase 0 (fix della regola phishing) non risulta ancora eseguita sul dispositivo
fisico: verificato con l'utente che l'intera sequenza resta da applicare nella
prossima finestra di manutenzione. La regola `Blocco_Gruppo_IP_Phishing_Elisa`
con `action allow` e' quindi ancora attiva in produzione: vedi runbook-anomalie.md
e la nuova priorita' assegnata in `.claude/context/roadmap.md`.

## 09/06/2026 - Provisioning utente e app Vianova One (centralino cloud)

Fonte: screenshot cartella `08062026 (steps)`, mail `Messagistica centrale
telefonica.eml` (09/06/2026, telefonia@myofficegroup.it).

Riunione con myOffice/Vianova per la migrazione al centralino cloud (Alessia
Referente-Vianova-1). Nella stessa giornata Alessio esegue due interventi operativi
concreti, indipendenti dal piano di revisione firewall.

Sullo switch Nebula (MAC `AA:BB:CC:00:00:01`) vengono rinominate e riconfigurate
due porte: la porta 8, rinominata "Vianova DHCP server fonia", passa da Voice
VLAN con PVID 1 a PVID 2 (traffico voce nativo, non piu' solo dati con voice
overlay); la porta 3, rinominata "SIP-T34W Persona-A", resta Voice
VLAN con PVID 1. [TBC: lo switch con questo MAC ha 54 porte visibili nel
pannello Nebula, compatibile solo con lo XGS2220-54HP di Piano 2, ma
`interventi 29052026.docx` (11 giorni prima) colloca esplicitamente Persona-A
con il suo T34W su Piano Terra, switch XGS2220-30HP porte 21/23, e riserva le
porte 3/5/44 del Piano 2 ai due T31G di Persona-D e Sala-1. L'etichetta
sulla porta 3 e' quindi probabilmente un errore di etichettatura, non un
reale spostamento fisico: da verificare con Alessio prima di consolidare la
mappatura IP/MAC dei telefoni, gap GAP-TBC #67/#99.]

Sul portale Area Clienti Vianova (areaclienti.vianova.it) Alessio crea un
nuovo utente, Persona-E (reparto IT), profilo "Base", senza privilegi di
amministratore Area Clienti ne' di amministratore PBX Centrex. L'invito viene
inviato via mail alle 10:46, il link di conferma ha validita' 15 giorni;
Persona-E completa la registrazione lo stesso giorno impostando password e
numero di cellulare per il 2FA via SMS. Viene inoltre scaricato l'installer
di Vianova One (`VianovaOneInstaller-1.4.0.6.exe`), l'app unificata di
comunicazione (chiamate, chat, videoconferenza) inclusa nella licenza
Collaboration UC, per verificarne il funzionamento su una seconda postazione
oltre a quella di Alessio.

Separatamente, lo stesso giorno myOffice (Referente-MyOffice-1, reparto
Telefonia) chiede via mail il testo dei messaggi da caricare sulla centrale
telefonica cloud: un messaggio GIORNO, a scelta tra un semplice messaggio di
attesa ("SIETE IN LINEA CON INTRAWELT, SIETE PREGATI DI ATTENDERE, GRAZIE",
con eventuale sottofondo musicale e squillo su uno o piu' interni dopo 3-4
squilli) oppure un IVR con instradamento per reparto ("PREMERE 1 PER
L'AMMINISTRAZIONE, PREMERE 2 PER IL COMMERCIALE"), e un messaggio NOTTE con gli
orari di apertura. **Decisione ancora aperta**: alla data del 01/07/2026 non
risulta una risposta di Alessio a myOffice su quale testo/modalita' adottare;
vedi gap aperto in GAP-TBC.md.

---

## 01/07/2026 - M1: correzione guidata delle due regole allow->deny

Fonte: sessione guidata passo-passo sulla GUI del firewall, con screenshot
Screenpresso a ogni passaggio. Dettaglio riga per riga in
`docs/firewall-zyxel-usg-flex-500-live.conf`.

Eseguita la Fase 0 del piano del 05/06/2026, indipendentemente dal resto della
sequenza a sei fasi (che resta da applicare). Sulla regola
`Blocco_Gruppo_IP_Phishing_Elisa` (Policy Control, riga 1): action corretta da
`allow` a `deny`, log impostato su `log alert`, e l'oggetto
`IP_09_phishing_2026_Elisa` (203.0.113.5, l'IP pubblico del firewall stesso)
rimosso dal gruppo `Bad_IP_Phishing_Elisa_2026`, che nel frattempo si conferma
composto da undici membri (IP_01-IP_11). Sulla regola gemella
`malicious_IP_12052025` (riga 4): action corretta da `allow` a `deny`, il log
era gia' attivo. Entrambe le modifiche si sono rivelate scritte immediatamente
sul dispositivo al click di OK sul dialogo di modifica, senza richiedere un
Apply separato sulla pagina Policy Control. Verificato su due screenshot
indipendenti per ciascuna modifica (prima e dopo).

Osservazione incidentale: la lista delle security policy mostra due regole non
ancora censite in `docs/firewall-zyxel-usg-flex-500.md`, `BLOCCO_IP_SOSPETTI`
(riga 7, action reject) e `EGETRAD_WEB_TEST` (riga 11): da includere nel
prossimo giro di riconciliazione della scheda, non urgente.

## Aprile-Giugno 2026 - Redesign sito intrawelt.com

Cappelli Design (referente Referente-CappelliDesign-1) avvia il redesign del sito intrawelt.com.
Piattaforma: WordPress. Gestore IT: Persona-E.

10/04/2026: Cappelli Design inizia a condividere contenuti per il nuovo sito.
Creato utente WordPress `marketing_cappelli` con ruolo Editor → escalato a Amministratore
per consentire l'export dei contenuti (blog, news).

20/04/2026: richiesta ambiente di test (copia 1:1 del sito attuale) da parte di Cappelli.
Ambiente test creato su infrastruttura IT Intrawelt.

Primo rilascio escluse: Ricerca, Solution Finder, slider homepage azienda,
modulo richiesta consulenza; pagine "Certificazioni" e "Policy" (aggiunte in scope ma
fuori dal primo rilascio). Tempistiche secondo rilascio: TBD.

## 07/05/2026 - Guasto NAS INTRA2 e sostituzione

Il NAS INTRA2 (QNAP TS-451U, 10.61.20.177) subisce un guasto. L'apparato viene
sostituito con un QNAP TS-435XeU-4G. I 4 dischi da 8 TB (RAID 5) installati a
gennaio 2025 vengono migrati nel nuovo chassis. L'indirizzo IP rimane 10.61.20.177.

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

## Gennaio-Aprile 2026 - SCENIA sviluppo full-stack (Collaboratore-Esterno-1)

Sviluppo principale su branch con Collaboratore-Esterno-1 (collaboratore esterno, modello
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
e il Titolare del trattamento ScenIA. Collaboratore-Esterno-1 (AIDAPT) come sub-processor.

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

Riunione con Referente-Vianova-1 (myOffice) per la migrazione al centralino cloud Vianova.
La Voice VLAN 2 configurata il 29/05/2026 è propedeutica: i Yealink T31G/T34W
supportano SIP diretto verso il centralino cloud eliminando la dipendenza dal
Panasonic KX-NCP1000 fisico. Dettaglio operativo della stessa giornata (provisioning
utente Area Clienti, Vianova One, decisione IVR ancora aperta) nella sezione
"09/06/2026 - Provisioning utente e app Vianova One" sopra.

[TBC: piano di numerazione definitivo, configurazione Patton SmartNode durante
la transizione, timeline attivazione numeri cloud.]

## Stato della rete a giugno 2026

### Topologia

WAN: Vianova FTTO 1 Gbps simmetrica nominale. IP pubblici: 203.0.113.x/28
(gateway .1, IP WAN Intrawelt .5). Backup: Vianova ponte radio Line Recovery
Standard (100 Mbps download, 20 Mbps upload). Failover automatico con mantenimento
IP pubblici via HSRP tra Router R-1000 principale e Router R-1000 backup.

Switch Vianova S-1000 distribuisce: una porta dati verso WAN1 del firewall Zyxel,
una porta per la linea fonia VoIP.

Firewall: Zyxel USG FLEX 500. IP LAN: 10.61.20.1. Porta verso switch Piano 2:
1 Gbps rame (collo di bottiglia fisico per l'uscita WAN). VPN SSL: 203.0.113.x:443.

Switch Piano 2: Zyxel XGS2220-54HP (48 porte GbE PoE++ + 6 SFP+ 10 Gbps, L3,
Nebula). Porta 33: firewall 1 Gbps rame. Porta SFP+ 52: dorsale verso Piano Terra
10 Gbps fibra (operativa dall'08/05/2026). HP ProLiant DL380 Gen10 (Proxmox VE
8.3.4, 10.61.20.11:8006, iLO5 10.61.20.9). NAS HERO (.169), NAS INTRA (.168),
NAS INTRA2 (.177 TS-435XeU-4G), NAS INTRA3 (.172 vuoto), NAS documenti (.170).

Switch Piano Terra: Zyxel XGS2220-30HP (24 porte GbE PoE+ + 4 SFP+ 10 Gbps, L3,
Nebula, installato aprile 2026). Uplink SFP+: 10 Gbps verso Piano 2 (operativo
dall'08/05/2026). IP management: 10.61.10.10 (DHCP classe .10 del firewall).

Cloud SEEWEB (tunnel IPsec operativo dal 24/06/2025):
Firewall OPNsense: 10.77.116.1 (user1 / [redacted]).
WINGROUPSHARE: 10.77.116.3 (Windows Server, GroupShare Trados, Cobian Backup, RDP
Administrator / [redacted], WAN: 192.0.2.x).
WINSRV2019: 10.77.116.4 (Windows Server 2019, desktop remoti DTP e PM, utente analisi1).

### Lavori aperti

Rimozione DHCP server classe .90 (configurazione residua dallo switch Piano Terra
vecchio).
VLAN tagging fonia Piano Terra: VLAN 2 per i due telefoni IP fisici, riconoscimento
OUI da MAC address in Nebula.
Wi-Fi su VLAN separata dalla classe .10.
Completamento implementazione nuova fonia Vianova (centralino cloud).
Dismissione HP G5 (VMware ESXi fisico) e migrazione VM su Proxmox.
Restituzione materiale TIM (Huawei AR651W, AR1220E, Taurus Bond): ancora in sede.

## 16-17/06/2026 – Mancata consegna mail Eni VIPA (Power Platform Flow)

Fonte: `_DA SISTEMARE (Alessio)/Analisi mail/marsk-17062026/analisi-problema-consegna.md`
(Claude Code M365 trace analysis, 17/06/2026)

**Mittente**: `ADM_DWIT_TEST_POWERPLATFORM@enispa.onmicrosoft.com` (Eni Power Automate Flow)
IP sorgente: `<IP-ENI-AZURE-SOURCE>` (Azure Cloud), Tenant Eni: `c16e514b-893e-4a01-9a30-b8fef514a650`
**Destinatario**: `enivipa@intrawelt.com` (+ `persona-d@intrawelt.com` in parallelo scoperto da trace)
**Oggetto tipo**: `Traduzione per [Nome Cognome] - [ID]` (richieste VIPA)

**Episodi di mancata consegna:**
- 16/06/2026 ore 13:15–13:35 IT: 7 mail mancanti (6 persone fisiche destinatarie delle traduzioni; i cognomi restano nel documento sorgente locale, non qui)
- 17/06/2026 ore 15:57 IT: ulteriori mail non arrivate

**Indagine M365 (EAC Message Trace):**
- Trace con filtro "Tutti gli stati" eseguito su finestra 16/06 11:00–17/06 16:30 UTC
- Risultato: 18 righe, tutte complete; le mail mancanti **assenti** dal trace
- Conclusione: le mail non hanno mai raggiunto i server Microsoft di intrawelt.com

**Conclusione: problema lato Eni** (Power Platform Flow intermittente).
Prove da comunicare a Eni VIPA: trace M365 "tutti gli stati" non le mostra + gap orari precisi.
Eni deve verificare log esecuzione Power Automate per le run degli orari anomali.

## 06/07/2026 - GroupShare 2020: upgrade SR1 -> SR2+CU15 necessario, bloccato sul download

Fonte: `Helpdesk_T-Rex/aggiornamento groupshare/groupshare-upgrade-handoff.md`
(handoff sessione Claude.ai del 06/07/2026). Il documento sorgente contiene
credenziali in chiaro (accessi firewall Seeweb, ESXi, VM, SQL `sa`): non sono
riportate qui e il file va trattato come materiale riservato (stesso gap
SEC-007 del password manager mai implementato).

Una traduttrice cliente, aggiornata a Trados Studio 2026 (build 19.0.0.3043),
non apre piu' i progetti dal portale `gs.intrawelt.com`: errore "versione del
server non piu' supportata". Il server e' GroupShare 2020 SR1 build 15.1.12529
sulla VM WINGROUPSHARE (Windows Server 2019, 8 vCPU, 64 GB RAM, 250 GB disco)
su host ESXi 7.0 U2 nel cloud Seeweb, raggiunto via VPN IPsec sulla rete
remota 10.77.116.0/24 (firewall .1, host ESXi .2, VM .3; IP pubblico della VM
mappato su 192.0.2.121). Causa accertata da documentazione RWS: Studio 2026
interroga la API REST MultiTerm v2 (`/api/multiterm/v2`), introdotta solo in
GroupShare 2020 SR2 CU14; SR1 espone solo le API v1, quindi il client
conclude che il server non sia supportato. Non e' un problema di rete,
firewall, credenziali o IIS. Gli altri clienti, ancora su Studio 2024 o
precedenti, non sono impattati, ma lo saranno a ogni upgrade client.

Percorso stabilito: upgrade a SR2 e poi CU15 (requisito minimo per Studio
2026; le CU sono cumulative, SR2 -> CU15 diretto). Compatibilita' confermata
con WinServer 2019 + IIS 10; SR2 migra da solo i compatibility level SQL e
il runtime .NET da 6 a 8; retrocompatibile con Studio 2022/2024. Piano
operativo pronto: snapshot ESXi `Pre-upgrade-GroupShare-SR2` (con memoria,
~70 GB richiesti sul datastore), backup dei sei database SQL (SDLSystem,
TMServiceSystem, TMContainer, MTMaster, WebHooks, CPSService), annotazione
del codice licenza, installazione SR2, poi CU15, verifica finale su portale
e Swagger. Workaround per la traduttrice non ancora attivato (pacchetto
`.sdlppx`/`.sdlrpx` offline).

Stato al 06/07: **bloccato sul download dell'installer SR2**. Tre tentativi
falliti sul portale RWS (redirect loop su gateway.sdl.com, account aziendale
RWS di Persona-E senza download visibili, invito al nuovo Account Portal mai
arrivato a persona-e@intrawelt.com); email a support@rws.com pronta nel
documento sorgente, da inviare. Rischio: la criticita' si estende a ogni
cliente che aggiorna a Studio 2026.
