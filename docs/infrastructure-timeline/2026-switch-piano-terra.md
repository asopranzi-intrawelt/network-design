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

## Febbraio-Aprile 2026 - Esercizio Proxmox: lock vzdump, freeze VM ricorrente, arrivi hardware

Fonte: `_DA SISTEMARE (Alessio)/PROXMOX/` (note datate, ingerite l'08/07/2026).

Il 16/02/2026 il backup notturno della VM809 (TESTNEWEGETRAD, disco 258 GB su
storage SERVIZI, destinazione NAS_HERO, snapshot zstd, keep-last=5) fallisce
con "can't acquire lock '/var/run/vzdumplock' - got timeout". La diagnosi
esclude un job concorrente (`ps` pulito) e punta a un lock orfano lasciato da
un job interrotto; i dump risultano comunque presenti sulla share di backup.
I log in `/var/log/vzdump/` di quella data fotografano la popolazione VM in
backup a febbraio 2026: 100, 201-205, 601, 602, 801-803, 809, 900-902, piu'
un log della VM101 datato febbraio 2025 (conferma che la VM101 e' esistita:
vedi gap #106). L'inventario e' piu' ampio di quello dello snapshot v3 di
giugno 2026: la riconciliazione VM per VM e' rimandata al re-run dello
snapshot (M18).

Il 15/04/2026, in chat con Persona-H, viene discussa una VM che a intervalli
di uptime si blocca completamente e accetta solo lo stop forzato dal nodo
(escluse cause lato SPICE); il titolo della nota indica come pista il cambio
del driver della scheda video. Nella stessa chat Persona-H annuncia
l'arrivo della scheda video e del transceiver 10 Gbit: con ogni probabilita'
sono i componenti montati nelle settimane successive (connettori SFP+ della
dorsale sostituiti l'08/05/2026; GPU RTX 5060 Ti installata l'08/06/2026
sull'host Ollama di IntraLino, vedi sezione Benchmark DoE).

## 03-23/04/2026 - NinjaOne: attivazione backup e nota Archiver

Fonte: `_DA SISTEMARE (Alessio)/Ninjaone backup/` (quasi solo screenshot).
Il 03/04/2026 prima attivazione del modulo backup NinjaOne con auto-discover
di tutte le postazioni; il 23/04/2026 call di onboarding utenze. Nota
operativa dalla call: con la modalita' Archiver (backup in tempo reale) i
dati archiviati non si possono eliminare autonomamente come con i backup
schedulati, serve un ticket al supporto; il numero di account da collegare
viene ridotto secondo licenze disponibili.

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

## Maggio-Luglio 2026 - Benchmark DoE IntraLino (C1/C2/C3), GPU RTX 5060 Ti e test C4

Fonte: `Sviluppo_interno, scripting (IT on FIRE)/Qdrant + Ollama + Ubuntu + n8n
self-hosting/_File Benchmark e implement/` (stato progetto, guide, due report
differenziali). Contenuto anonimizzato secondo `.claude/rules/anonymization.md`;
la cartella sorgente contiene anche file di credenziali, mai riportati.

Il benchmark applica un impianto DoE[^1] alla pipeline RAG[^2] self-hosted
IntraLino per isolare due fattori: l'impatto della GPU a parita' di modello
(C1, CPU con llama3.2:3B, contro C2, GPU con lo stesso modello) e l'impatto
del modello a parita' di hardware (C2 contro C3, llama3.1:8b). Il confronto
diretto C1-C3 e' vietato dalla metodologia perche' varierebbe due fattori
insieme. Le misure quantitative (matrice A: TTFT, throughput, durata, CPU,
RAM, VRAM, latenza embedding) interrogano Ollama in isolamento; quelle
qualitative (matrice B: aderenza, coerenza, recall@k, preferenza pairwise)
attraversano la pipeline completa e sono affidate a un panel di 5 valutatori
con stimoli anchor ripresentati in cieco per misurare la deriva di giudizio.

L'infrastruttura sotto benchmark e' su due host della LAN: l'host Ollama
(10.61.20.58, Ubuntu 25.04, i7-7700, 16 GB RAM, Ollama su porta 11500) e lo
stack Docker IntraLino (10.61.20.60, hostname `intralino`: n8n con workflow
LangChain, Qdrant 1.17.1, backend Node.js, nginx con TLS da CA privata, UFW
su 22/80/443). La fonte descrive i due host come "due VM Proxmox" ma
attribuisce alla .58 hardware fisico dedicato, incluso l'alloggiamento
fisico della GPU: incoerenza da verificare (gap #107).

Passi salienti. Il 04/06/2026 l'embedding viene affidato al modello dedicato
bge-m3 (1024 dimensioni), fisso per tutte le casistiche: tra C2 e C3 cambia
solo il modello di generazione e la collezione Qdrant resta invariata, senza
re-ingest. L'08/06/2026 viene installata la GPU RTX 5060 Ti 16 GB GDDR7
sull'host Ollama (driver NVIDIA 595.71.05, CUDA 13.2, uso in generazione
verificato). Il 29/06/2026 vengono prodotti i due report differenziali
quantitativi: a parita' di modello la GPU porta un guadagno di ordine di
grandezza statisticamente significativo su tutte le metriche; il passaggio
da 3B a 8B costa circa il doppio in tempo per token e memoria video senza
penalizzare la reattivita'. Le sezioni qualitative dei report restano da
compilare dopo le sessioni del panel (valutatori non ancora reclutati).

Tra il 30/06 e il 02/07/2026 si aggiunge la casistica esplorativa C4
(Qwen3-14B), dichiaratamente fuori dal benchmark DoE: per non toccare lo
stato C3 della produzione viene allestito sulla .60 un ambiente di test
parallelo (stack nginx e backend dedicati su porta 4443, con JWT secret
separato da quello di produzione), cosi' la raccolta C4 avviene interamente
sul test e la produzione resta invariata.

[^1]: *DoE*, Design of Experiments - impianto sperimentale che varia un solo
fattore per confronto, cosi' che le differenze misurate siano attribuibili a
quel fattore e non a cambiamenti concomitanti.
[^2]: *RAG*, Retrieval-Augmented Generation - architettura in cui il modello
linguistico genera risposte a partire da frammenti di documenti recuperati da
un archivio vettoriale, qui Qdrant.

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

## 07/07/2026 - Tagging VLAN sui due switch per il centralino cloud: intervento in corso

Fonte: comunicazione verbale dell'utente in sessione, 07/07/2026. Le evidenze
dell'intervento (16 screenshot, 2 foto, una nota testuale con estratto chat
delle 13:14-13:17) sono salvate in `_notes/[TBC] screenshot e note myoffice/`,
non versionate: il racconto completo e la documentazione strutturata
dell'intervento arriveranno a lavori conclusi, quando tutti gli endpoint
(telefoni inclusi) funzioneranno (vedi nota PORT-TAGGING in
`ingestion-checklist.md`).

Dalla nota testuale emerge intanto l'architettura della LAN telefonica, che
chiude la domanda aperta FW-012 sulla funzione della porta 8: la LAN telefoni
Vianova non e' raggiungibile dalla LAN aziendale, per progetto. Il DHCP
server e il gateway della LAN telefonica sono forniti da Vianova e connessi
untagged alla porta 8 dello switch, senza passare per il firewall; i
telefoni prendono l'indirizzo dal DHCP Vianova; Vianova stabilisce una VPN
verso myOffice come sede per arrivare alla porta 8. Caso di riferimento
citato: presso un altro cliente myOffice la VPN saturava la banda e i
telefoni cadevano, e li' myOffice entra attraverso il firewall raggiungendo
i telefoni come oggetto IP; e' l'anomalia da tenere presente come rischio
noto dell'architettura.

Due fatti osservati oggi, gia' registrati come gap:

Primo (NET-008, GAP-TBC #102): su entrambi gli switch XGS2220 la VLAN ID 1
non puo' assumere valore Tx tagging sulla dorsale: quando la si tagga, gli
endpoint Windows collegati allo switch perdono le connessioni di rete verso
il NAS-HERO (10.61.20.169), senza alcuna modifica al file hosts degli
endpoint. La causa non e' ancora compresa. Ipotesi da verificare, non
confermata: la VLAN 1 e' la native/untagged della dorsale, e taggarla in
uscita produce un native VLAN mismatch sul lato ricevente che separa a
livello 2 gli endpoint dal NAS; in quel caso il file hosts non c'entra
perche' il guasto e' di inoltro, non di risoluzione dei nomi.

Secondo (TEL-002, GAP-TBC #103): i telefoni del piano inferiore collegati
attraverso il vano ascensore non passano le VLAN, causa non compresa.
[TBC: topologia esatta del tratto che attraversa il vano ascensore, da
chiarire con il racconto finale.]

## 17/07/2026 - Chiarita la topologia dorsale/QNAP, aggiornati i diagrammi

Fonte: comunicazione verbale dell'utente in sessione, corroborata da uno
screenshot del pannello porte Nebula dello switch XGS2220-54HP.

Chiarita la topologia fisica tra i due switch Piano Terra/Piano 2 e il QNAP
QSW-1208-8c, che restava ambigua nelle fonti precedenti (la sostituzione dei
connettori SFP+ dell'08/05/2026 descriveva il vecchio connettore dorsale come
posizionato "sopra al QNAP", lasciando aperta l'ipotesi che il QNAP fosse un
hop intermedio sul collegamento switch-switch). Confermato: dallo switch
XGS2220-54HP (Piano 2) partono due fibre SFP+ 10 Gbps separate, la porta 52
verso lo switch XGS2220-30HP (Piano Terra, dorsale diretta, trunk 802.1Q con
VLAN dati Piano Terra untagged e VLAN 2 fonia tagged) e la porta 51 verso il
QNAP QSW-1208-8c, che resta un ramo a parte per NAS fleet e le postazioni a
10 Gbps, invariato rispetto a prima. Il secondo collegamento diretto PT<->P2,
pianificato l'08/07/2026 (vedi sopra), risulta oggi attivo.

Confermato anche, sulla porta 8 del 54HP (Vianova DHCP fonia, PVID 2,
FW-012), che una seconda porta dello stesso switch, la porta 6, condivide lo
stesso PVID 2: il ruolo di questa porta non e' confermato, il pannello
d'insieme di Nebula mostra solo velocita'/PoE/uplink per porta, non il PVID
assegnato. Resta aperto anche il sintomo di TEL-002: i due telefoni IP del
Piano Terra, collegati a porte dello switch XGS2220-30HP stesso (non solo al
tratto del vano ascensore come descritto il 07/07), non risultano visibili
neppure dopo la conferma del trunk diretto; non e' chiaro se il sintomo
precede o segue l'attivazione di quel collegamento.

Aggiornati di conseguenza: `GAP-TBC.md` (NET-008 #102, TEL-002 #103 e nuova
voce #116), `docs/network-diagram.md` (topologia ASCII e VLAN), e i
diagrammi in `.claude/context/diagrams/firewall-dmz-2026/` — nuovo
`rete_stato_attuale_17072026.drawio` con la topologia corrente, note di
aggiornamento aggiunte a `rete_stato_attuale_29052026.drawio`,
`rete_stato_target_08072026.drawio` e `rete_fonia_voip_08072026_2.drawio-claudio.drawio`
per marcare cosa e' confermato e cosa resta un target non applicato
(in particolare la fonia su VLAN 100/DHCP-firewall di quest'ultimo, mai
realizzata: l'implementazione reale usa VLAN 2 e DHCP Vianova sulla porta 8).

## 17-20/07/2026 - GroupShare (Seeweb): certificato HTTPS scomparso, ripristinata solo la connettivita' HTTP

Fonte: `handoff-SSL.md`, comunicato dall'utente. Continua il filone
GroupShare aperto il 06/07/2026 (vedi voce sotto): stesso ambiente Seeweb
(VM WINGROUPSHARE, rete remota 10.77.116.0/24, IP pubblico 192.0.2.121),
ma un incidente distinto — non piu' l'incompatibilita' applicativa con
Studio 2026, bensi' la sparizione del binding/certificato HTTPS.

Il 17/07/2026 il portale `https://gs.intrawelt.com` e' diventato
irraggiungibile sulla 443 (`ERR_CONNECTION_TIMED_OUT`), confermato sia da
un client sulla LAN Intrawelt sia da rete esterna, mentre la porta 80
rispondeva regolarmente — non un problema di trust del certificato, la
connessione TCP non arrivava proprio a destinazione. Diagnosi condotta da
Alessio Sopranzi con Persona-E (referente RWS/GroupShare) e Persona-H
(Punto Informatica) sulla VM stessa: nessun listener sulla 443, nessun
binding SSL registrato, nessun certificato pubblico per il dominio nello
store (solo il certificato interno `identity.sdl.com`, non toccato), sito
IIS "SDL Server" con solo binding HTTP. Causa radice: certificato e binding
HTTPS rimossi o mai ricreati, probabilmente alla scadenza del certificato
precedente.

Scelto win-acme (Let's Encrypt) per il ripristino automatico (certificato +
binding 443 + rinnovo periodico), con un problema iniziale risolto (il
binding HTTP esistente senza host header impediva a win-acme di identificare
il sito) ma **il percorso non e' stato portato a termine**: per sbloccare
subito i Project Manager, bloccati con i client Trados Studio, si e'
ripristinata la sola connettivita' HTTP normale, non la cifratura HTTPS. Il
traffico verso il portale GroupShare, incluse le credenziali applicative,
viaggia oggi in chiaro. Registrato come gap **SEC-015** (`GAP-TBC.md` #117)
e in `design-and-security.md` §A.13.2; dettaglio tecnico completo con
diagnosi e comandi in `docs/runbook-anomalie.md` §SEC-015. Il completamento
del binding HTTPS via win-acme resta il fix identificato ma non applicato.

## 08/07/2026 - Snapshot infrastruttura v4: RAM raddoppiata, storage PROGRAMMAZIONE, VM Intralino

Eseguito `Get-ProxmoxSnapshot.ps1` sul nodo (primo re-run dopo la v3;
output non versionato in `output/`). Delta rispetto alla v3: la RAM del
nodo e' passata a 125.4 GB totali, conferma in campo dell'ordine dei 64 GB
aggiuntivi del 14/11/2025; e' comparso lo storage lvmthin PROGRAMMAZIONE
(1.5 TB) con il pool risorse "Programmazione"; la VM602 e' stata rinominata
da ITdeveloping a "Intralino" (running, 200 GB su PROGRAMMAZIONE); la
VM810 "TESTNEWEGETRADBOOT" (260 GB, running) sostituisce la VM809 dei log
di febbraio; la VM803 e le VM effimere dei log vzdump (101, 201, 601,
801-803, 809, 900-902) non esistono piu'. Nove job di backup schedulati
scaglionati verso NAS_INTRA piu' un secondo job della VM100 verso NAS_HERO.
Invariati: firewall cluster inattivo senza regole, bridge non VLAN-aware
(M5 non applicato), LAN unica /19 su vmbr0. Aperto il gap #108 (lo stato
cluster riporta come IP del nodo l'indirizzo della iLO5). Riconciliati i
gap #106 (popolazione VM) e #107 (gli host IntraLino .58/.60 non sono VM
del nodo). Scheda `design-and-security.md` aggiornata alla v4.

## 16/07/2026 - Fase A Wi-Fi (M13a): applicata, incidente di 15 minuti, ripristinata

Applicata la segmentazione Wi-Fi staff pianificata il 15/07 (VLAN 40,
decisione Fase A/Fase B di NET-005/AP-001): interfaccia dedicata sul
firewall USG FLEX 500 (con pool DHCP), zona e regole di sicurezza
create e verificate, poi le tre porte switch dei tre access point noti
(PianoTerra, PianoPrimo, PianoSecondo) spostate una alla volta sulla
nuova VLAN tramite script dedicato, ciascuna verificata subito dopo via
rilettura diretta dello switch.

Entro pochi minuti dall'ultima porta applicata, la rete Wi-Fi ha smesso
di essere visibile del tutto (non solo irraggiungibile) su due
dispositivi diversi, mentre i dati letti dallo switch (collegamento
fisico attivo, alimentazione PoE, impostazioni di porta corrette)
non mostravano alcuna anomalia — segno che il problema viveva
nell'access point stesso, non nello switch. Dato che i tre access point
restano inaccessibili (credenziali perse, nessuna dashboard, vedi
AP-001), non è stato possibile determinare la causa esatta. Ripristinate
le tre porte alla configurazione precedente con lo stesso strumento
usato per applicarle: servizio Wi-Fi confermato tornato entro un quarto
d'ora dalla prima segnalazione.

La configurazione lato firewall (interfaccia, zona, DHCP, regole di
sicurezza) resta applicata e valida per un nuovo tentativo. L'episodio
rafforza, con una prova pratica, la decisione già presa di pianificare
la sostituzione dei tre access point invece di continuare a farli
convivere con altri interventi di rete. Dettaglio tecnico completo in
`docs/runbook-anomalie.md` §NET-005.

## 20/07/2026 - Fase B Wi-Fi: scelto il preventivo Punto Informatica per 3 AP Zyxel

Ricevuto e scelto un preventivo di Punto Informatica (17/07/2026) per tre
access point Zyxel NWA130BE-EU0101, Wi-Fi 7 (802.11be) tri-radio, gestibili
in NebulaFlex standalone o cloud-managed dalla stessa organizzazione
Nebula gia' in uso per i due switch. La quantita' di tre unita' copre le
tre ubicazioni AP staff/guest gia' mappate (PianoTerra, PianoPrimo,
PianoSecondo), coerente con il piano multi-SSID (staff + guest sullo
stesso AP) gia' deciso il 15/07/2026. L'AP EsternoIrrigazione (centrale
irrigazione tetto) resta fuori scope, decisione separata non ancora presa.
Importo, sconto e riferimento del documento non riportati per policy di
anonimizzazione (`.claude/rules/anonymization.md`). Acquisto e consegna non
ancora confermati. Dettaglio completo in `docs/runbook-anomalie.md`
§AP-001; roadmap aggiornata (M13b).
