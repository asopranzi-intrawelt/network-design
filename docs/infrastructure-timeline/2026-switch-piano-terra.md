# 2026 - Gennaio-Giugno: phishing, switch Piano Terra, NAS INTRA2, dorsale 10 Gbps

## 19/01/2026 - Primo ingaggio Proelium (task_47 cybersecurity)

Proelium Law Firm (studio legale con expertise cybersecurity/GDPR) viene ingaggiato per supporto su conformità NIS2 e data protection. Referente: avvocato Proelium. Primo documento prodotto: analisi NIS2 applicabilità a Intrawelt (PMI settore servizi di traduzione → valutazione soggetto critico / importante).

Parallelo con Consulente-ISO27001-1 (ISO 27001): due percorsi distinti, coordinati da Alessio.

## Gennaio-Marzo 2026 - IntraLino: sviluppo architettura n8n stabile

Stack IntraLino si consolida:
- Ollama (llama3.2, porta 11500, systemd service)
- ChromaDB (porta 8000, persistent store)
- n8n 2.12.3 (Docker, orchestratore workflow)

Script prodotti nel periodo: GroupShare TM export, data manipulation, Proxmox snapshot (C:\Scripts\proxmox-snapshot), security anomaly checker (v1).

Integrazione Zep per memoria persistente tentata e abbandonata il 25/03/2026: il nodo n8n ufficiale Zep era già deprecato; alternativa community (n8n-nodes-zep-v3) non adottata per instabilità. Stack rimasto: ChromaDB + Ollama + n8n (senza memoria persistente tra sessioni).

## 12/01/2026 - Notes thinking lab: studio Thinking Machines / Tinker API

Fonte: `Sviluppo_interno, scripting (IT on FIRE)/Notes (thinking lab) 12012026.docx`

Ricerca tecnica personale di Alessio su infrastruttura AI avanzata. Documento analizza Thinking Machines (fondata 2025 da Mira Murati, ex-CTO OpenAI; investitori: a16z, Nvidia, AMD, Cisco) e il loro prodotto flagship **Tinker API** (fine-tuning e training LLM).

Punti chiave del documento:

- **Tinker API**: primitivi Python (`forward_backward()`, `optim_step()`, `sample()`, `save_state()`) per definire custom training loop con GPU cluster managed by Thinking Machines. Supporta modelli da 1B a 235B parametri (inclusi MoE e vision-language). Fine-tuning via **LoRA** (layer adapter, non modifica pesi base → multi-tenant efficiente).
- **Output**: pesi esportabili per deploy su propri backend SaaS o inference endpoint.

Case study elaborato nel documento: **Enterprise Technical Documentation SaaS** con n8n + Ollama + Tinker:
- Dataset: manuali tecnici, API reference, procedure operative con metadata per dipartimento/sistema.
- Pipeline: n8n gestisce preprocessing e ingestion automatica dei documenti aggiornati.
- Fine-tuning incrementale: LoRA su Tinker triggered da n8n su nuovi documenti.
- Deploy: pesi esportati come inference endpoint; RAG via Ollama in LAN per query real-time; interfaccia utente per ingegneri/operations.

Rilevanza per IntraLino roadmap: questo studio documenta il ragionamento su come evolvere IntraLino (attualmente ChromaDB + Ollama + n8n) verso fine-tuning specializzato su documentazione tecnica Intrawelt, senza dipendenza da API cloud esterne.

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
- Creata regola firewall "Blocco_Gruppo_IP_Phishing_Elisa" sul Zyxel USG FLEX 500 → ma la regola aveva erroneamente `action=ALLOW` invece di `DENY` (gap FW-001)
- Analisi malware: file `Malware-List_2026-01-13_2026-01-15_UTC.xlsx` (lista IP/domini bloccati)
- Email scomparse: verificato che Alessandro stava eliminando da info (auto-quarantena)

### Lezioni apprese

- Le regole di posta M365 non sono tutte visibili da Outlook → monitorare via Purview periodicamente
- La regola firewall FW-001 deve essere corretta (action=DENY); vedi docs/runbook-anomalie.md
- Necessità di formazione anti-phishing per tutti i dipendenti (gap ISO-003)

## 13/02/2026 - Ticket Aruba: analisi backup e WAF VPS SCENIA

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §Ticket Aruba

Alessio apre ticket Aruba ARU-340414, ID **18346774A** per chiarire le opzioni di backup e WAF della VPS di produzione SCENIA (O2A4: 4 vCPUs, 8 GB RAM, 80 GB storage, 50 TB/mese data transfer, Ubuntu 22.04 LTS, IP <IP-SCENIA-VPS-PROD>).

**Risposta Aruba su backup VPS:**
- SWITCH OFF SERVER = spegnimento, RESET = riavvio, INIZIALIZZA = reset a stato iniziale (perde tutti i dati).
- Limite 25 TB/mese = somma traffico in entrata + in uscita.
- Backup disponibili tramite guida: kb.cloud.it/public-cloud/backup/cloud-backup.aspx

**Risposta Aruba su WAF (27/02/2026, ticket ID 18401201A):**
- WAF su VPS non supportato da Aruba (le VPS sono macchine standalone senza rete virtuale configurabile).
- WAF disponibile solo su server dedicati VMware con firewall Pfsense/Fortinet FortiGate 40F.
- Soluzione dichiarata da Aruba: "per VPS usare soluzioni open-source per gestione custom."

Decisione post-ticket: ModSecurity v3 + OWASP valutato ma abbandonato (troppo pesante su risorse). Cloudflare Free come soluzione alternativa (vedi sezione 11/05/2026).

## Gennaio-Febbraio 2026 - CVE patch SCENIA (React / Next.js)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §CVE tracking

### CVE-2025-66478 (React/Next.js – critical 10.0, gen 2026)

Server-side vulnerability in React.js tracked as CVE-2025-55182 (React) e CVE-2025-66478 (Next.js). Remediazione: migrazione alla versione patchata + rotazione di tutte le credenziali. Completata fine gennaio 2026. Rilevato tramite advisory nextjs.org/blog/CVE-2025-66478.

### CVE-2026-23864 (Next.js DoS – feb 2026)

Vulnerabilità in React Server Components App Router: deserializzazione HTTP non limitata → incremento incontrollato CPU, out-of-memory, crash Node.js → DoS remoto senza prerequisiti. Fix: aggiornamento Next.js a ≥ 16.1.5.

### CVE-2025-59471 (Next.js Image Optimizer – feb 2026)

Image Optimizer self-hosted scarica l'intero file remoto in memoria via arrayBuffer() prima di validare → memory bomb. Attacco: fornire file immagine enorme. Fix: Next.js ≥ 16.1.5 (streaming + controllo dimensioni).

Processo di rilevamento: `pnpm audit` eseguito periodicamente. Prisma dependency vulnerability rilevata nella stessa sessione.

## 19/02/2026 - CSRF Token T-Rex/Odoo (Persona-F)

Fonte: `Helpdesk_T-Rex/Problema CSRF Token T_Rex.docx`

Persona-F segnala a Persona-E: batch upload XML analisi in T-Rex bloccato (caricamento infinito) + alert "Session expired (invalid CSRF token)" + stampa preventivi fallisce se eseguita subito dopo altra stampa. Problema specifico della postazione di Chiara; gli altri utenti non riscontrano problemi.

Diagnosi: sessione Odoo corrotta → CSRF invalido → richieste POST batch non autorizzate. Risoluzione: pulizia completa sessione browser (logout, chiusura browser, eliminazione cookie/cache dominio trex.intrawelt.com, DevTools Clear site data, ipconfig /flushdns). Procedura operativa completa in helpdesk-operations.md §T-Rex CSRF Token.

## 23/03/2026 – Analisi blocco traffico centralino (Vianova / USG FLEX 500)

Fonte: `ARCHITETTURA SERVER-CLOUD-LINEE/ZYXEL FIREWALL e VPN/Ricerca Blocco Traffico in uscita per centralino.docx` Trigger: mail da referente-vianova-1@myofficegroup.it (Vianova/MyOffice) del 23/03/2026 con richiesta di verifica.

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

**Esito:** nessuna Security Policy blocca le subnet sopra in uscita; i log (`Monitor → Log`) non riportano alcun blocco per nessuno degli IP/porte verificati. Conclusione: il firewall USG FLEX 500 **non è la causa** del problema centralino.

## 04/03/2026 - Meeting Odoo portale SCENIA (Referente-OpenForce-1, OpenForce)

Pianificazione integrazione portale SaaS SCENIA → creazione SO in T-Rex/Odoo. Protocollo: xml-rpc standard Odoo (no moduli aggiuntivi). Utente servizio: asopranzi@intrawelt.com (dedicato, senza licenza aggiuntiva). Ambiente test: intrawelt-test.openforce.it. Warning: xml-rpc deprecato da v19, rimosso da v20 → migrare a json-rpc in futuro. Dettagli tecnici: docs/helpdesk-operations.md §Integrazione portale SCENIA.

## Febbraio-Aprile 2026 - Esercizio Proxmox: lock vzdump, freeze VM ricorrente, arrivi hardware

Fonte: `_DA SISTEMARE (Alessio)/PROXMOX/` (note datate, ingerite l'08/07/2026).

Il 16/02/2026 il backup notturno della VM809 (TESTNEWEGETRAD, disco 258 GB su storage SERVIZI, destinazione NAS_HERO, snapshot zstd, keep-last=5) fallisce con "can't acquire lock '/var/run/vzdumplock' - got timeout". La diagnosi esclude un job concorrente (`ps` pulito) e punta a un lock orfano lasciato da un job interrotto; i dump risultano comunque presenti sulla share di backup. I log in `/var/log/vzdump/` di quella data fotografano la popolazione VM in backup a febbraio 2026: 100, 201-205, 601, 602, 801-803, 809, 900-902, piu' un log della VM101 datato febbraio 2025 (conferma che la VM101 e' esistita: vedi gap #106). L'inventario e' piu' ampio di quello dello snapshot v3 di giugno 2026: la riconciliazione VM per VM e' rimandata al re-run dello snapshot (M18).

Il 15/04/2026, in chat con Persona-H, viene discussa una VM che a intervalli di uptime si blocca completamente e accetta solo lo stop forzato dal nodo (escluse cause lato SPICE); il titolo della nota indica come pista il cambio del driver della scheda video. Nella stessa chat Persona-H annuncia l'arrivo della scheda video e del transceiver 10 Gbit: con ogni probabilita' sono i componenti montati nelle settimane successive (connettori SFP+ della dorsale sostituiti l'08/05/2026; GPU RTX 5060 Ti installata l'08/06/2026 sull'host Ollama di IntraLino, vedi sezione Benchmark DoE).

## 03-23/04/2026 - NinjaOne: attivazione backup e nota Archiver

Fonte: `_DA SISTEMARE (Alessio)/Ninjaone backup/` (quasi solo screenshot). Il 03/04/2026 prima attivazione del modulo backup NinjaOne con auto-discover di tutte le postazioni; il 23/04/2026 call di onboarding utenze. Nota operativa dalla call: con la modalita' Archiver (backup in tempo reale) i dati archiviati non si possono eliminare autonomamente come con i backup schedulati, serve un ticket al supporto; il numero di account da collegare viene ridotto secondo licenze disponibili.

## Aprile 2026 - Installazione switch Piano Terra: Zyxel XGS2220-30HP

### Stato pre-installazione

Fino ad aprile 2026 il Piano Terra e' gestito da due apparati separati: ZYXEL GS1900-24 (managed, L2, 24 porte GbE): switch principale degli endpoint. Cisco (router fisico) con adattatore PoE esterno: gestisce alcuni AP e la porta verso 0-R-18.

Connessioni fisiche del Cisco: porta su patch panel 0.8.1 con patch verso 0.9.1 (dove sta un AP esterno), adattatore PoE verso porta 0.7.1 (AP), terza porta diretta verso 0-R-18.

L'uplink dal Piano Terra al Piano 2 e' su rame a 1 Gbps, che e' il limite fisico della connessione tra i due piani.

### Motivazione funzionale

L'installazione e' propedeutica al progetto di migrazione fonia con centralino cloud Vianova. Il nuovo switch Zyxel XGS2220-30HP permette VLAN tagging nativo: VLAN 2 dedicata ai telefoni IP fisici (fonia), VLAN 1 (o altra) per i dati. Il riconoscimento OUI dal MAC address del telefono permette di buttare il dispositivo automaticamente sulla VLAN telefonica.

Vantaggi rispetto alla configurazione precedente: Il Cisco puo' essere rimosso (lo switch nuovo e' Layer 3 e gestisce il routing inter-VLAN). L'adattatore PoE separato del Cisco viene eliminato (lo switch nuovo ha PoE+ integrato su tutte le 24 porte RJ45, IEEE 802.3at, budget 400 W totali). L'uplink verso il Piano 2 passa da 1 Gbps rame a 10 Gbps fibra SFP+ (dorsale).

### Hardware installato

Zyxel XGS2220-30HP-EU0101F: 24 porte GbE RJ45 con PoE+ (IEEE 802.3at). 4 porte SFP+ 10 Gbps per uplink e dorsale. Budget PoE: 400 W. Consumo massimo dichiarato: 477 W (di cui 400 W PSE). Alimentazione: 100-240 V, 50-60 Hz. Layer 3: routing statico + inter-VLAN. Gestione cloud: Nebula (stesso sito del Piano 2 XGS2220-54HP). Pannello frontale: porte RJ45 per accesso con PoE+ a sinistra, porte SFP+ uplink a destra, porta console per gestione locale. Quick Setup Guide: download.zyxel.com/QSG/Nebula-managed-switch-QSG.pdf (redirect a Nebula-managed-switch-QSG.pdf).

### Osservazioni architetturali da Nebula pre-installazione

Stato rilevato da Nebula per lo switch Zyxel XGS2220-54HP al Piano 2 (aprile 2026):

Porta 33 verso il firewall Zyxel USG FLEX 500: Speed 1G/Auto (Copper), Type Trunk port con PVID 1, Allowed VLANs All. Questa porta e' il collo di bottiglia fisico dell'uscita WAN e del routing centrale: tutta la rete, pur avendo backbone interno a 10 Gbps tra switch, e' instradata verso il firewall attraverso una singola porta a 1 Gbps. LLDP (Link Layer Discovery Protocol) attivo.

Porta 52 verso Piano Terra (uplink preesistente): Speed 10G/Auto (SFP+), configurata come trunk con tutte le VLAN ammesse. Questa porta e' gia' predisposta per 10 Gbps ma la velocita' effettiva dipende dal transceiver e dal dispositivo collegato all'altra estremita'. Al momento del rilevamento Nebula la porta vede ancora lo switch vecchio Piano Terra.

Porta verso QNAP QSW-1208-8c: connessione a 10 Gbps solo per Persona-G (collegamento dedicato al suo workstation).

### Configurazione Nebula post-installazione

Accesso Nebula: nebula.zyxel.com/cc/ui/index.html#/66e2c72407a81ccfe505a296/ 66e2c739dae741bea731bec4/site-wide/monitor/dashboard

Al primo accesso dopo l'installazione: Il LAN IP dello switch Piano Terra appena montato e' diverso rispetto allo switch Piano 2. Lo switch Piano Terra ha preso la classe .90 invece della .10.

Causa: il vecchio switch Piano Terra era ancora connesso tramite la porta P8 del firewall (che faceva da DHCP server per la classe .90). Il collegamento fisico passava: Piano Terra (vecchio switch) su patch panel, poi patch verso P8 del firewall Zyxel, poi dalla P8 andava sulla porta 39 dello switch Piano 2. Quando staccata la patch da P8, lo switch Piano Terra si e' disconnesso dalla dashboard admin Nebula.

Procedura di risoluzione:
1. Staccata la patch dalla porta P8 del firewall (verificata anche su Nebula Configure > Switch ports dello switch Piano 2, porta 40).
2. Staccata la fibra tra Piano Terra e Piano 2, poi riattaccata.
3. Lo switch Piano Terra prende ora la classe .10 (DHCP server del firewall).
4. Rimesso in DHCP: 10.61.10.10 (assegnato dal DHCP server firewall, classe .10).

Dettaglio porta 30 dello switch Piano Terra (uplink SFP+): Configurata come uplink. Attiva a 10 Gbps verso il Piano 2. Il vecchio switch Piano Terra era rimasto attaccato (andava a 1 Gbps) mentre il nuovo switch Piano Terra ha l'SFP+ a 10 Gbps. Il connettore temporaneo lasciato era quello vecchio (proveniente dallo switch dismesso).

Sulla porta 29 dello switch Piano Terra nuovo: attaccato il convertitore (slot SFP+ vuoto al momento dell'ispezione). Il convertitore vecchio e' visibile come "non si parla" con quello gia' presente sopra al QNAP QSW-1208-8c al Piano 2. Necessaria sostituzione di entrambi i connettori SFP+.

Situazione DHCP: il problema e' che se sta attaccato il cavo della classe .90 e si spengono e riaccendono gli switch senza VLAN taggate si crea un conflitto. Rimozione del DHCP server classe .90 e' pendente come task (vedi GAP-TBC.md).

## 11/05/2026 - Architettura sicurezza VPS SCENIA: Cloudflare Zero Trust (con Collaboratore-Esterno-1)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` §Ragionamento con Fabio architettura sicurezza VPS

Decisione architetturale presa il 11/05/2026 in riunione con Collaboratore-Esterno-1.

**Scelta: Cloudflare Free + cloudflared tunnel (al posto di ModSecurity WAF locale)**

Motivazione:
- ModSecurity su VPS staging già causava degrado prestazioni.
- ModSecurity richiede configurazione manuale delle rule; Cloudflare ha DDoS, caching, image optimization incluse nel piano gratuito.
- Con cloudflared tunnel le porte 80/443 della VPS vengono chiuse (ufw deny): unico canale di comunicazione HTTP è Cloudflare → IP del server mascherato. Attacco DDoS diretto all'IP del server viene bloccato a monte.

**Setup staging (eseguito):**
- Account Cloudflare: dash.cloudflare.com (piano Free)
- Zero Trust: scenia.cloudflareaccess.com (team name)
- NS delegati a Cloudflare: kaiser.ns.cloudflare.com, tara.ns.cloudflare.com (già delegati da Register.it)
- cloudflared installato su VPS staging (<IP-SCENIA-VPS-STAGING>) via apt GPG key
- Porte 80/443 chiuse con `ufw deny`; accesso SSH consentito solo da IP Intrawelt e IP Fabio (<IP-COLLABORATORE-ESTERNO>)
- Nginx proxy su porta 80 → Next.js porta 3000

**DNS scenia.it (stato al momento del setup):**
| Dominio | A record | Ruolo |
|---------|----------|-------|
| scenia.it | <IP-SCENIA-VPS-PROD> | Sito istituzionale (one-page) |
| portal.scenia.it | <IP-SCENIA-VPS-PROD> | Portale produzione (Trados Accelerate) |
| contact.scenia.it | <IP-SCENIA-VPS-PROD> | Landing form contatti (design Attilio) |
| staging-portal.scenia.it | <IP-SCENIA-VPS-STAGING> | Portale staging (proxato Cloudflare) |

**Produzione:** cloudflared tunnel pianificato anche per VPS produzione nella fase successiva. Fail2Ban attivo su entrambe le VPS (ban IP dopo 3-4 tentativi SSH falliti). Mailtrap usato per email transazionale (form contatto, webhook portale). Lynis come tool di auditing OS della VPS.

Repository sicurezza: github.com/Intrawelt-SaaS/security (README con dettaglio setup).

## 29/05/2026 - Interventi Voice VLAN e fibra NAS

### NAS INTRA2 - migrazione da Ethernet a fibra 10GbE

Il NAS INTRA2 (QNAP TS-435XeU-4G, 10.61.20.177) viene migrato dalla scheda Ethernet (Adapter 4, 2.5GbE) alla scheda fibra 10GbE (Adapter 1). Procedura: disabilitare la scheda Ethernet, assegnare lo stesso IP statico alla scheda fibra via DHCP poi configurazione statica, disconnettere fisicamente il cavo Ethernet. [TBC: IP di management durante la migrazione era 10.61.10.210:8080 - verificare configurazione definitiva Adapter 1 10GbE]. Job di backup PC-ALESSIO testato e funzionante dopo la migrazione.

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
- LLDP-MED e' preferito a OUI perche' la negoziazione e' bidirezionale e non richiede gestione manuale della lista OUI.
- CoS 802.1p: 5 (valore standard IEEE per voce RTP).
- DSCP: 46 (EF - Expedited Forwarding, RFC 3246). [TBC: default Nebula mostra 44, verificare se e' stato modificato a 46.]

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

La configurazione e' propedeutica alla migrazione al centralino cloud Vianova: i telefoni Yealink possono operare in SIP direttamente senza passare dal centralino fisico Panasonic KX-NCP1000.

## 29/05/2026 - Analisi configurazione Zyxel USG FLEX 500

Fonte: `Analisi_Zyxel_USG_FLEX_500.docx`, backup `startup-config.conf` datato 19/05/2026 (2215 righe, firmware ZLD 5.42(ABUJ.1)).

Prima analisi strutturata del file di configurazione del firewall: porte fisiche e port-grouping (P4/P5/P6 in bridge L2 sotto lan1, nonostante le etichette logiche lan2/dmz), interfacce WAN/LAN/DMZ, VPN (due tunnel IPsec verso lo stesso peer SEEWEB, VPN remote-access IKEv2, SSL VPN), NAT/virtual server, security policy e UTM. Individuate dieci anomalie (FW-001 - FW-010), la piu' critica delle quali e' la regola `Blocco_Gruppo_IP_Phishing_Elisa` con `action allow` invece di `deny`, introdotta durante la remediation dell'incidente phishing del 13-15/01/2026: la regola, essendo la prima valutata dal motore, fa passare indisturbato qualunque traffico dagli undici IP della lista invece di bloccarlo. Dettaglio completo delle dieci anomalie in `docs/firewall-zyxel-usg-flex-500.md`.

Parallelamente viene prodotta un'analisi comparativa su come collocare correttamente una VM Proxmox in DMZ (`zyxel-dmz-proxmox.md` e i diagrammi `dmz_con_trunk.svg` / `dmz_senza_trunk.svg`, archiviati in `.claude/context/diagrams/firewall-dmz-2026/`): la porta DMZ del firewall (P7) e' oggi fisicamente isolata dal segmento su cui e' collegato Proxmox, quindi una VM raggiunta via NAT ma con IP in subnet LAN non e' realmente in DMZ, e' un host LAN con port forwarding. Le due opzioni valutate sono un secondo cavo dedicato da P7 a una seconda NIC del server (scartata: rigida, consuma porte, non scala) e un trunk 802.1Q che porta la VLAN DMZ sullo stesso cavo fisico gia' usato dalla LAN, smistata poi da un bridge Proxmox VLAN-aware. La seconda opzione e' quella adottata nel piano di revisione del 05/06/2026.

## 05/06/2026 - Piano di revisione rete DMZ/Proxmox (sei fasi)

Fonte: `Revisione_Rete_DMZ_Proxmox.docx`, `Piano_Operativo_Migrazione.docx`, `LE SEI FASI.txt`.

Il piano operativo traduce l'anomalia FW-001 e l'architettura DMZ a trunk in una sequenza di sei fasi con applicazione dal seriale del firewall, ciascuna con un proprio punto di ritorno esplicito: Fase 0 corregge subito, via GUI e senza attendere la finestra di manutenzione, la regola phishing (allow -> deny, rimozione dell'IP del firewall stesso dal gruppo); Fase 1 prepara backup, verifica fisicamente console seriale e accesso iLO, e conferma il prerequisito non ancora validato che lo switch XGS2220-54HP supporti 802.1Q; le Fasi 2 e 3 configurano VLAN 201 sullo switch e bridge VLAN-aware su Proxmox a impatto nullo sulla produzione (nessun cavo ancora spostato); la Fase 4 posa il cavo da P7 e valida la catena L2 con `arping`/`tcpdump` prima di toccare il firewall, spiegando perche' un ping ordinario possa legittimamente non rispondere in quel momento; la Fase 5 applica la configurazione aggiornata dalla console seriale con una doppia rete di protezione, lo startup-config precedente resta intatto finche' la verifica non e' conclusa, piu' un meccanismo di `lastgood` automatico lato firewall; la Fase 6 verifica nell'ordine in cui gli utenti se ne accorgerebbero (prima la navigazione LAN, poi la SSL VPN, poi il tunnel IPsec, poi il raggiungimento della VM DMZ), consolida con 48 ore di osservazione log e chiude con le pulizie fisiche del cablaggio provvisorio.

Il file `startup-config.conf` datato 05/06/2026 e conservato con il piano contiene gia' in testa un changelog che descrive gli otto interventi previsti (rimozione WAN_TRUNK e delle rotte statiche legate a LAN2, correzione delle due regole allow->deny, attivazione della zona DMZ senza pool DHCP, pubblicazione web via `wan1:2`): e' la configurazione target preparata per il caricamento in Fase 5, **non** un backup post-applicazione. Alla data del 01/07/2026 la Fase 0 (fix della regola phishing) non risulta ancora eseguita sul dispositivo fisico: verificato con l'utente che l'intera sequenza resta da applicare nella prossima finestra di manutenzione. La regola `Blocco_Gruppo_IP_Phishing_Elisa` con `action allow` e' quindi ancora attiva in produzione: vedi runbook-anomalie.md e la nuova priorita' assegnata in `.claude/context/roadmap.md`.

## 09/06/2026 - Provisioning utente e app Vianova One (centralino cloud)

Fonte: screenshot cartella `08062026 (steps)`, mail `Messagistica centrale
telefonica.eml` (09/06/2026, telefonia@myofficegroup.it).

Riunione con myOffice/Vianova per la migrazione al centralino cloud (Alessia Referente-Vianova-1). Nella stessa giornata Alessio esegue due interventi operativi concreti, indipendenti dal piano di revisione firewall.

Sullo switch Nebula (MAC `AA:BB:CC:00:00:01`) vengono rinominate e riconfigurate due porte: la porta 8, rinominata "Vianova DHCP server fonia", passa da Voice VLAN con PVID 1 a PVID 2 (traffico voce nativo, non piu' solo dati con voice overlay); la porta 3, rinominata "SIP-T34W Persona-A", resta Voice VLAN con PVID 1. [TBC: lo switch con questo MAC ha 54 porte visibili nel pannello Nebula, compatibile solo con lo XGS2220-54HP di Piano 2, ma `interventi 29052026.docx` (11 giorni prima) colloca esplicitamente Persona-A con il suo T34W su Piano Terra, switch XGS2220-30HP porte 21/23, e riserva le porte 3/5/44 del Piano 2 ai due T31G di Persona-D e Sala-1. L'etichetta sulla porta 3 e' quindi probabilmente un errore di etichettatura, non un reale spostamento fisico: da verificare con Alessio prima di consolidare la mappatura IP/MAC dei telefoni, gap GAP-TBC #67/#99.]

Sul portale Area Clienti Vianova (areaclienti.vianova.it) Alessio crea un nuovo utente, Persona-E (reparto IT), profilo "Base", senza privilegi di amministratore Area Clienti ne' di amministratore PBX Centrex. L'invito viene inviato via mail alle 10:46, il link di conferma ha validita' 15 giorni; Persona-E completa la registrazione lo stesso giorno impostando password e numero di cellulare per il 2FA via SMS. Viene inoltre scaricato l'installer di Vianova One (`VianovaOneInstaller-1.4.0.6.exe`), l'app unificata di comunicazione (chiamate, chat, videoconferenza) inclusa nella licenza Collaboration UC, per verificarne il funzionamento su una seconda postazione oltre a quella di Alessio.

Separatamente, lo stesso giorno myOffice (Referente-MyOffice-1, reparto Telefonia) chiede via mail il testo dei messaggi da caricare sulla centrale telefonica cloud: un messaggio GIORNO, a scelta tra un semplice messaggio di attesa ("SIETE IN LINEA CON INTRAWELT, SIETE PREGATI DI ATTENDERE, GRAZIE", con eventuale sottofondo musicale e squillo su uno o piu' interni dopo 3-4 squilli) oppure un IVR con instradamento per reparto ("PREMERE 1 PER L'AMMINISTRAZIONE, PREMERE 2 PER IL COMMERCIALE"), e un messaggio NOTTE con gli orari di apertura. **Decisione ancora aperta**: alla data del 01/07/2026 non risulta una risposta di Alessio a myOffice su quale testo/modalita' adottare; vedi gap aperto in GAP-TBC.md.

---

## 01/07/2026 - M1: correzione guidata delle due regole allow->deny

Fonte: sessione guidata passo-passo sulla GUI del firewall, con screenshot Screenpresso a ogni passaggio. Dettaglio riga per riga in `docs/firewall-zyxel-usg-flex-500-live.conf`.

Eseguita la Fase 0 del piano del 05/06/2026, indipendentemente dal resto della sequenza a sei fasi (che resta da applicare). Sulla regola `Blocco_Gruppo_IP_Phishing_Elisa` (Policy Control, riga 1): action corretta da `allow` a `deny`, log impostato su `log alert`, e l'oggetto `IP_09_phishing_2026_Elisa` (203.0.113.5, l'IP pubblico del firewall stesso) rimosso dal gruppo `Bad_IP_Phishing_Elisa_2026`, che nel frattempo si conferma composto da undici membri (IP_01-IP_11). Sulla regola gemella `malicious_IP_12052025` (riga 4): action corretta da `allow` a `deny`, il log era gia' attivo. Entrambe le modifiche si sono rivelate scritte immediatamente sul dispositivo al click di OK sul dialogo di modifica, senza richiedere un Apply separato sulla pagina Policy Control. Verificato su due screenshot indipendenti per ciascuna modifica (prima e dopo).

Osservazione incidentale: la lista delle security policy mostra due regole non ancora censite in `docs/firewall-zyxel-usg-flex-500.md`, `BLOCCO_IP_SOSPETTI` (riga 7, action reject) e `EGETRAD_WEB_TEST` (riga 11): da includere nel prossimo giro di riconciliazione della scheda, non urgente.

## Aprile-Giugno 2026 - Redesign sito intrawelt.com

Cappelli Design (referente Referente-CappelliDesign-1) avvia il redesign del sito intrawelt.com. Piattaforma: WordPress. Gestore IT: Persona-E.

10/04/2026: Cappelli Design inizia a condividere contenuti per il nuovo sito. Creato utente WordPress `marketing_cappelli` con ruolo Editor → escalato a Amministratore per consentire l'export dei contenuti (blog, news).

20/04/2026: richiesta ambiente di test (copia 1:1 del sito attuale) da parte di Cappelli. Ambiente test creato su infrastruttura IT Intrawelt.

Primo rilascio escluse: Ricerca, Solution Finder, slider homepage azienda, modulo richiesta consulenza; pagine "Certificazioni" e "Policy" (aggiunte in scope ma fuori dal primo rilascio). Tempistiche secondo rilascio: TBD.

## 07/05/2026 - Guasto NAS INTRA2 e sostituzione

Il NAS INTRA2 (QNAP TS-451U, 10.61.20.177) subisce un guasto. L'apparato viene sostituito con un QNAP TS-435XeU-4G. I 4 dischi da 8 TB (RAID 5) installati a gennaio 2025 vengono migrati nel nuovo chassis. L'indirizzo IP rimane 10.61.20.177.

[TBC: dettagli del guasto TS-451U (tipo di errore, log QNAP), procedura esatta di migrazione dischi nel nuovo chassis TS-435XeU-4G, eventuali problemi riscontrati, screenshot del nuovo NAS operativo con RAID ricostruito.]

## 08/05/2026 - Sostituzione connettori SFP+: dorsale a 10 Gbps operativa

I due connettori SFP+ (quello sullo switch Piano Terra e quello sullo switch Piano 2) erano incompatibili tra loro: il connettore vecchio dallo switch Piano Terra dismesso non si parlava con quello gia' installato sopra al QNAP QSW-1208-8c al Piano 2.

Acquistati due nuovi connettori SFP+ compatibili. Procedura di sostituzione:

1. Inserito il primo connettore nuovo sullo switch Piano Terra (XGS2220-30HP).
2. Inserito il secondo connettore nuovo sullo switch Piano 2 (XGS2220-54HP, lato che va verso il QNAP QSW-1208-8c).
3. Spostata la patch fibra sul Piano Terra verso il nuovo connettore.
4. Impostazione su Nebula del connettore nuovo su entrambi gli switch.

Risultato: la dorsale Piano Terra - Piano 2 negozia e comunica a 10 Gbps (confermato da Nebula: Speed 10G, full duplex, su entrambe le porte SFP+ coinvolte).

---

## Gennaio-Aprile 2026 - SCENIA sviluppo full-stack (Collaboratore-Esterno-1)

Sviluppo principale su branch con Collaboratore-Esterno-1 (collaboratore esterno, modello fork + PR). Snapshot repository analizzato: staging 27/02/2026 → main 22/04/2026 (analisi prodotta in 13_Maggio 2026 / analysis-output/).

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

Breaking change 11/03/2026: aggiunta variabile d'ambiente STORAGE_PATH per configurare il path del filesystem condiviso; nginx `proxy_buffering off` per upload grandi; chmod 750 sulle directory storage.

ER diagram: diagrammaER 18052025.png (18/05/2025, primo schema E/R definitivo); note database e diagramma.docx (evoluzione successiva).

28/05/2026: studio integrazione Odoo-SCENIA documentato in `studio_integrazione Odoo 28052026.docx` (cartella odoo-related del progetto).

## Maggio-Giugno 2026 - SCENIA DPA e DPIA ScenIA

### DPA ScenIA v1.0 → v1.7

Redazione del Data Processing Agreement (GDPR Art. 28) tra Intrawelt (Processor) e il Titolare del trattamento ScenIA. Collaboratore-Esterno-1 (AIDAPT) come sub-processor.

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

Pending: completare placeholder Parti, negoziare massimali responsabilità, inviare questionario tecnico a AIDAPT (confermato gap VA/PT).

### DPIA ScenIA

Documento DPIA in corso (template EDPB v1.0 2026). Sezioni [DA COMPLETARE]: validazione tecnica AIDAPT, dati del Titolare, misure di mitigazione residuali. Previste completamento entro luglio 2026.

Standard di riferimento: ETSI EN 304 223 V2.1.1 (AI security, adottato 08/12/2025), citato in DPA Allegato II.

## 09/06/2026 - Riunione myOffice: migrazione centralino cloud Vianova

Riunione con Referente-Vianova-1 (myOffice) per la migrazione al centralino cloud Vianova. La Voice VLAN 2 configurata il 29/05/2026 è propedeutica: i Yealink T31G/T34W supportano SIP diretto verso il centralino cloud eliminando la dipendenza dal Panasonic KX-NCP1000 fisico. Dettaglio operativo della stessa giornata (provisioning utente Area Clienti, Vianova One, decisione IVR ancora aperta) nella sezione "09/06/2026 - Provisioning utente e app Vianova One" sopra.

[TBC: piano di numerazione definitivo, configurazione Patton SmartNode durante la transizione, timeline attivazione numeri cloud.]

## Stato della rete a giugno 2026

### Topologia

WAN: Vianova FTTO 1 Gbps simmetrica nominale. IP pubblici: 203.0.113.x/28 (gateway .1, IP WAN Intrawelt .5). Backup: Vianova ponte radio Line Recovery Standard (100 Mbps download, 20 Mbps upload). Failover automatico con mantenimento IP pubblici via HSRP tra Router R-1000 principale e Router R-1000 backup.

Switch Vianova S-1000 distribuisce: una porta dati verso WAN1 del firewall Zyxel, una porta per la linea fonia VoIP.

Firewall: Zyxel USG FLEX 500. IP LAN: 10.61.20.1. Porta verso switch Piano 2: 1 Gbps rame (collo di bottiglia fisico per l'uscita WAN). VPN SSL: 203.0.113.x:443.

Switch Piano 2: Zyxel XGS2220-54HP (48 porte GbE PoE++ + 6 SFP+ 10 Gbps, L3, Nebula). Porta 33: firewall 1 Gbps rame. Porta SFP+ 52: dorsale verso Piano Terra 10 Gbps fibra (operativa dall'08/05/2026). HP ProLiant DL380 Gen10 (Proxmox VE 8.3.4, 10.61.20.11:8006, iLO5 10.61.20.9). NAS HERO (.169), NAS INTRA (.168), NAS INTRA2 (.177 TS-435XeU-4G), NAS INTRA3 (.172 vuoto), NAS documenti (.170).

Switch Piano Terra: Zyxel XGS2220-30HP (24 porte GbE PoE+ + 4 SFP+ 10 Gbps, L3, Nebula, installato aprile 2026). Uplink SFP+: 10 Gbps verso Piano 2 (operativo dall'08/05/2026). IP management: 10.61.10.10 (DHCP classe .10 del firewall).

Cloud SEEWEB (tunnel IPsec operativo dal 24/06/2025): Firewall OPNsense: 10.77.116.1 (user1 / [redacted]). WINGROUPSHARE: 10.77.116.3 (Windows Server, GroupShare Trados, Cobian Backup, RDP Administrator / [redacted], WAN: 192.0.2.x). WINSRV2019: 10.77.116.4 (Windows Server 2019, desktop remoti DTP e PM, utente analisi1).

### Lavori aperti

Rimozione DHCP server classe .90 (configurazione residua dallo switch Piano Terra vecchio). VLAN tagging fonia Piano Terra: VLAN 2 per i due telefoni IP fisici, riconoscimento OUI da MAC address in Nebula. Wi-Fi su VLAN separata dalla classe .10. Completamento implementazione nuova fonia Vianova (centralino cloud). Dismissione HP G5 (VMware ESXi fisico) e migrazione VM su Proxmox. Restituzione materiale TIM (Huawei AR651W, AR1220E, Taurus Bond): ancora in sede.

## 16-17/06/2026 – Mancata consegna mail Eni VIPA (Power Platform Flow)

Fonte: `_DA SISTEMARE (Alessio)/Analisi mail/marsk-17062026/analisi-problema-consegna.md` (Claude Code M365 trace analysis, 17/06/2026)

**Mittente**: `ADM_DWIT_TEST_POWERPLATFORM@enispa.onmicrosoft.com` (Eni Power Automate Flow) IP sorgente: `<IP-ENI-AZURE-SOURCE>` (Azure Cloud), Tenant Eni: `c16e514b-893e-4a01-9a30-b8fef514a650` **Destinatario**: `enivipa@intrawelt.com` (+ `persona-d@intrawelt.com` in parallelo scoperto da trace) **Oggetto tipo**: `Traduzione per [Nome Cognome] - [ID]` (richieste VIPA)

**Episodi di mancata consegna:**
- 16/06/2026 ore 13:15–13:35 IT: 7 mail mancanti (6 persone fisiche destinatarie delle traduzioni; i cognomi restano nel documento sorgente locale, non qui)
- 17/06/2026 ore 15:57 IT: ulteriori mail non arrivate

**Indagine M365 (EAC Message Trace):**
- Trace con filtro "Tutti gli stati" eseguito su finestra 16/06 11:00–17/06 16:30 UTC
- Risultato: 18 righe, tutte complete; le mail mancanti **assenti** dal trace
- Conclusione: le mail non hanno mai raggiunto i server Microsoft di intrawelt.com

**Conclusione: problema lato Eni** (Power Platform Flow intermittente). Prove da comunicare a Eni VIPA: trace M365 "tutti gli stati" non le mostra + gap orari precisi. Eni deve verificare log esecuzione Power Automate per le run degli orari anomali.

## Maggio-Luglio 2026 - Benchmark DoE IntraLino (C1/C2/C3), GPU RTX 5060 Ti e test C4

Fonte: `Sviluppo_interno, scripting (IT on FIRE)/Qdrant + Ollama + Ubuntu + n8n
self-hosting/_File Benchmark e implement/` (stato progetto, guide, due report
differenziali). Contenuto anonimizzato secondo `.claude/rules/anonymization.md`;
la cartella sorgente contiene anche file di credenziali, mai riportati.

Il benchmark applica un impianto DoE[^1] alla pipeline RAG[^2] self-hosted IntraLino per isolare due fattori: l'impatto della GPU a parita' di modello (C1, CPU con llama3.2:3B, contro C2, GPU con lo stesso modello) e l'impatto del modello a parita' di hardware (C2 contro C3, llama3.1:8b). Il confronto diretto C1-C3 e' vietato dalla metodologia perche' varierebbe due fattori insieme. Le misure quantitative (matrice A: TTFT, throughput, durata, CPU, RAM, VRAM, latenza embedding) interrogano Ollama in isolamento; quelle qualitative (matrice B: aderenza, coerenza, recall@k, preferenza pairwise) attraversano la pipeline completa e sono affidate a un panel di 5 valutatori con stimoli anchor ripresentati in cieco per misurare la deriva di giudizio.

L'infrastruttura sotto benchmark e' su due host della LAN: l'host Ollama (10.61.20.58, Ubuntu 25.04, i7-7700, 16 GB RAM, Ollama su porta 11500) e lo stack Docker IntraLino (10.61.20.60, hostname `intralino`: n8n con workflow LangChain, Qdrant 1.17.1, backend Node.js, nginx con TLS da CA privata, UFW su 22/80/443). La fonte descrive i due host come "due VM Proxmox" ma attribuisce alla .58 hardware fisico dedicato, incluso l'alloggiamento fisico della GPU: incoerenza da verificare (gap #107).

Passi salienti. Il 04/06/2026 l'embedding viene affidato al modello dedicato bge-m3 (1024 dimensioni), fisso per tutte le casistiche: tra C2 e C3 cambia solo il modello di generazione e la collezione Qdrant resta invariata, senza re-ingest. L'08/06/2026 viene installata la GPU RTX 5060 Ti 16 GB GDDR7 sull'host Ollama (driver NVIDIA 595.71.05, CUDA 13.2, uso in generazione verificato). Il 29/06/2026 vengono prodotti i due report differenziali quantitativi: a parita' di modello la GPU porta un guadagno di ordine di grandezza statisticamente significativo su tutte le metriche; il passaggio da 3B a 8B costa circa il doppio in tempo per token e memoria video senza penalizzare la reattivita'. Le sezioni qualitative dei report restano da compilare dopo le sessioni del panel (valutatori non ancora reclutati).

Tra il 30/06 e il 02/07/2026 si aggiunge la casistica esplorativa C4 (Qwen3-14B), dichiaratamente fuori dal benchmark DoE: per non toccare lo stato C3 della produzione viene allestito sulla .60 un ambiente di test parallelo (stack nginx e backend dedicati su porta 4443, con JWT secret separato da quello di produzione), cosi' la raccolta C4 avviene interamente sul test e la produzione resta invariata.

[^1]: *DoE*, Design of Experiments - impianto sperimentale che varia un solo fattore per confronto, cosi' che le differenze misurate siano attribuibili a quel fattore e non a cambiamenti concomitanti.
[^2]: *RAG*, Retrieval-Augmented Generation - architettura in cui il modello linguistico genera risposte a partire da frammenti di documenti recuperati da un archivio vettoriale, qui Qdrant.

## 06/07/2026 - GroupShare 2020: upgrade SR1 -> SR2+CU15 necessario, bloccato sul download

Fonte: `Helpdesk_T-Rex/aggiornamento groupshare/groupshare-upgrade-handoff.md` (handoff sessione Claude.ai del 06/07/2026). Il documento sorgente contiene credenziali in chiaro (accessi firewall Seeweb, ESXi, VM, SQL `sa`): non sono riportate qui e il file va trattato come materiale riservato (stesso gap SEC-007 del password manager mai implementato).

Una traduttrice cliente, aggiornata a Trados Studio 2026 (build 19.0.0.3043), non apre piu' i progetti dal portale `gs.intrawelt.com`: errore "versione del server non piu' supportata". Il server e' GroupShare 2020 SR1 build 15.1.12529 sulla VM WINGROUPSHARE (Windows Server 2019, 8 vCPU, 64 GB RAM, 250 GB disco) su host ESXi 7.0 U2 nel cloud Seeweb, raggiunto via VPN IPsec sulla rete remota 10.77.116.0/24 (firewall .1, host ESXi .2, VM .3; IP pubblico della VM mappato su 192.0.2.121). Causa accertata da documentazione RWS: Studio 2026 interroga la API REST MultiTerm v2 (`/api/multiterm/v2`), introdotta solo in GroupShare 2020 SR2 CU14; SR1 espone solo le API v1, quindi il client conclude che il server non sia supportato. Non e' un problema di rete, firewall, credenziali o IIS. Gli altri clienti, ancora su Studio 2024 o precedenti, non sono impattati, ma lo saranno a ogni upgrade client.

Percorso stabilito: upgrade a SR2 e poi CU15 (requisito minimo per Studio 2026; le CU sono cumulative, SR2 -> CU15 diretto). Compatibilita' confermata con WinServer 2019 + IIS 10; SR2 migra da solo i compatibility level SQL e il runtime .NET da 6 a 8; retrocompatibile con Studio 2022/2024. Piano operativo pronto: snapshot ESXi `Pre-upgrade-GroupShare-SR2` (con memoria, ~70 GB richiesti sul datastore), backup dei sei database SQL (SDLSystem, TMServiceSystem, TMContainer, MTMaster, WebHooks, CPSService), annotazione del codice licenza, installazione SR2, poi CU15, verifica finale su portale e Swagger. Workaround per la traduttrice non ancora attivato (pacchetto `.sdlppx`/`.sdlrpx` offline).

Stato al 06/07: **bloccato sul download dell'installer SR2**. Tre tentativi falliti sul portale RWS (redirect loop su gateway.sdl.com, account aziendale RWS di Persona-E senza download visibili, invito al nuovo Account Portal mai arrivato a persona-e@intrawelt.com); email a support@rws.com pronta nel documento sorgente, da inviare. Rischio: la criticita' si estende a ogni cliente che aggiorna a Studio 2026.

## 07/07/2026 - Tagging VLAN sui due switch per il centralino cloud: intervento in corso

Fonte: comunicazione verbale dell'utente in sessione, 07/07/2026. Le evidenze dell'intervento (16 screenshot, 2 foto, una nota testuale con estratto chat delle 13:14-13:17) sono salvate in `_notes/[TBC] screenshot e note myoffice/`, non versionate: il racconto completo e la documentazione strutturata dell'intervento arriveranno a lavori conclusi, quando tutti gli endpoint (telefoni inclusi) funzioneranno (vedi nota PORT-TAGGING in `ingestion-checklist.md`).

Dalla nota testuale emerge intanto l'architettura della LAN telefonica, che chiude la domanda aperta FW-012 sulla funzione della porta 8: la LAN telefoni Vianova non e' raggiungibile dalla LAN aziendale, per progetto. Il DHCP server e il gateway della LAN telefonica sono forniti da Vianova e connessi untagged alla porta 8 dello switch, senza passare per il firewall; i telefoni prendono l'indirizzo dal DHCP Vianova; Vianova stabilisce una VPN verso myOffice come sede per arrivare alla porta 8. Caso di riferimento citato: presso un altro cliente myOffice la VPN saturava la banda e i telefoni cadevano, e li' myOffice entra attraverso il firewall raggiungendo i telefoni come oggetto IP; e' l'anomalia da tenere presente come rischio noto dell'architettura.

Due fatti osservati oggi, gia' registrati come gap:

Primo (NET-008, GAP-TBC #102): su entrambi gli switch XGS2220 la VLAN ID 1 non puo' assumere valore Tx tagging sulla dorsale: quando la si tagga, gli endpoint Windows collegati allo switch perdono le connessioni di rete verso il NAS-HERO (10.61.20.169), senza alcuna modifica al file hosts degli endpoint. La causa non e' ancora compresa. Ipotesi da verificare, non confermata: la VLAN 1 e' la native/untagged della dorsale, e taggarla in uscita produce un native VLAN mismatch sul lato ricevente che separa a livello 2 gli endpoint dal NAS; in quel caso il file hosts non c'entra perche' il guasto e' di inoltro, non di risoluzione dei nomi.

Secondo (TEL-002, GAP-TBC #103): i telefoni del piano inferiore collegati attraverso il vano ascensore non passano le VLAN, causa non compresa. [TBC: topologia esatta del tratto che attraversa il vano ascensore, da chiarire con il racconto finale.]

## 17/07/2026 - Chiarita la topologia dorsale/QNAP, aggiornati i diagrammi

Fonte: comunicazione verbale dell'utente in sessione, corroborata da uno screenshot del pannello porte Nebula dello switch XGS2220-54HP.

Chiarita la topologia fisica tra i due switch Piano Terra/Piano 2 e il QNAP QSW-1208-8c, che restava ambigua nelle fonti precedenti (la sostituzione dei connettori SFP+ dell'08/05/2026 descriveva il vecchio connettore dorsale come posizionato "sopra al QNAP", lasciando aperta l'ipotesi che il QNAP fosse un hop intermedio sul collegamento switch-switch). Confermato: dallo switch XGS2220-54HP (Piano 2) partono due fibre SFP+ 10 Gbps separate, una verso lo switch XGS2220-30HP (Piano Terra, dorsale diretta, trunk 802.1Q con VLAN dati Piano Terra untagged e VLAN 2 fonia tagged) e una verso il QNAP QSW-1208-8c, che resta un ramo a parte per NAS fleet e le postazioni a 10 Gbps, invariato rispetto a prima. Il secondo collegamento diretto PT<->P2, pianificato l'08/07/2026 (vedi sopra), risulta oggi attivo.

Correzione del 23/07/2026 su questa stessa voce: l'assegnazione delle due fibre annotata oggi era invertita. La vista di dettaglio della porta in Nebula, che espone il vicino LLDP, mostra che la dorsale verso il Piano Terra e' la **porta 51** del 54HP e il ramo verso il QNAP e' la **porta 52**. La sostanza della topologia, cioe' due fibre indipendenti e il QNAP fuori dalla dorsale, resta confermata; cambia solo l'etichetta delle porte, che pero' conta quando si mette mano alla configurazione.

Confermato anche, sulla porta 8 del 54HP (Vianova DHCP fonia, PVID 2, FW-012), che una seconda porta dello stesso switch, la porta 6, condivide lo stesso PVID 2: il ruolo di questa porta non e' confermato, il pannello d'insieme di Nebula mostra solo velocita'/PoE/uplink per porta, non il PVID assegnato. Resta aperto anche il sintomo di TEL-002: i due telefoni IP del Piano Terra, collegati a porte dello switch XGS2220-30HP stesso (non solo al tratto del vano ascensore come descritto il 07/07), non risultano visibili neppure dopo la conferma del trunk diretto; non e' chiaro se il sintomo precede o segue l'attivazione di quel collegamento.

Aggiornati di conseguenza: `GAP-TBC.md` (NET-008 #102, TEL-002 #103 e nuova voce #116), `docs/network-diagram.md` (topologia ASCII e VLAN), e i diagrammi in `.claude/context/diagrams/firewall-dmz-2026/` — nuovo `rete_stato_attuale_17072026.drawio` con la topologia corrente, note di aggiornamento aggiunte a `rete_stato_attuale_29052026.drawio`, `rete_stato_target_08072026.drawio` e `rete_fonia_voip_08072026_2.drawio-claudio.drawio` per marcare cosa e' confermato e cosa resta un target non applicato (in particolare la fonia su VLAN 100/DHCP-firewall di quest'ultimo, mai realizzata: l'implementazione reale usa VLAN 2 e DHCP Vianova sulla porta 8).

## 17-20/07/2026 - GroupShare (Seeweb): certificato HTTPS scomparso, ripristinata solo la connettivita' HTTP

Fonte: `handoff-SSL.md`, comunicato dall'utente. Continua il filone GroupShare aperto il 06/07/2026 (vedi voce sotto): stesso ambiente Seeweb (VM WINGROUPSHARE, rete remota 10.77.116.0/24, IP pubblico 192.0.2.121), ma un incidente distinto — non piu' l'incompatibilita' applicativa con Studio 2026, bensi' la sparizione del binding/certificato HTTPS.

Il 17/07/2026 il portale `https://gs.intrawelt.com` e' diventato irraggiungibile sulla 443 (`ERR_CONNECTION_TIMED_OUT`), confermato sia da un client sulla LAN Intrawelt sia da rete esterna, mentre la porta 80 rispondeva regolarmente — non un problema di trust del certificato, la connessione TCP non arrivava proprio a destinazione. Diagnosi condotta da Alessio Sopranzi con Persona-E (referente RWS/GroupShare) e Persona-H (Punto Informatica) sulla VM stessa: nessun listener sulla 443, nessun binding SSL registrato, nessun certificato pubblico per il dominio nello store (solo il certificato interno `identity.sdl.com`, non toccato), sito IIS "SDL Server" con solo binding HTTP. Causa radice: certificato e binding HTTPS rimossi o mai ricreati, probabilmente alla scadenza del certificato precedente.

Scelto win-acme (Let's Encrypt) per il ripristino automatico (certificato + binding 443 + rinnovo periodico), con un problema iniziale risolto (il binding HTTP esistente senza host header impediva a win-acme di identificare il sito) ma **il percorso non e' stato portato a termine**: per sbloccare subito i Project Manager, bloccati con i client Trados Studio, si e' ripristinata la sola connettivita' HTTP normale, non la cifratura HTTPS. Il traffico verso il portale GroupShare, incluse le credenziali applicative, viaggia oggi in chiaro. Registrato come gap **SEC-015** (`GAP-TBC.md` #117) e in `design-and-security.md` §A.13.2; dettaglio tecnico completo con diagnosi e comandi in `docs/runbook-anomalie.md` §SEC-015. Il completamento del binding HTTPS via win-acme resta il fix identificato ma non applicato.

## 08/07/2026 - Snapshot infrastruttura v4: RAM raddoppiata, storage PROGRAMMAZIONE, VM Intralino

Eseguito `Get-ProxmoxSnapshot.ps1` sul nodo (primo re-run dopo la v3; output non versionato in `output/`). Delta rispetto alla v3: la RAM del nodo e' passata a 125.4 GB totali, conferma in campo dell'ordine dei 64 GB aggiuntivi del 14/11/2025; e' comparso lo storage lvmthin PROGRAMMAZIONE (1.5 TB) con il pool risorse "Programmazione"; la VM602 e' stata rinominata da ITdeveloping a "Intralino" (running, 200 GB su PROGRAMMAZIONE); la VM810 "TESTNEWEGETRADBOOT" (260 GB, running) sostituisce la VM809 dei log di febbraio; la VM803 e le VM effimere dei log vzdump (101, 201, 601, 801-803, 809, 900-902) non esistono piu'. Nove job di backup schedulati scaglionati verso NAS_INTRA piu' un secondo job della VM100 verso NAS_HERO. Invariati: firewall cluster inattivo senza regole, bridge non VLAN-aware (M5 non applicato), LAN unica /19 su vmbr0. Aperto il gap #108 (lo stato cluster riporta come IP del nodo l'indirizzo della iLO5). Riconciliati i gap #106 (popolazione VM) e #107 (gli host IntraLino .58/.60 non sono VM del nodo). Scheda `design-and-security.md` aggiornata alla v4.

## 16/07/2026 - Fase A Wi-Fi (M13a): applicata, incidente di 15 minuti, ripristinata

Applicata la segmentazione Wi-Fi staff pianificata il 15/07 (VLAN 40, decisione Fase A/Fase B di NET-005/AP-001): interfaccia dedicata sul firewall USG FLEX 500 (con pool DHCP), zona e regole di sicurezza create e verificate, poi le tre porte switch dei tre access point noti (PianoTerra, PianoPrimo, PianoSecondo) spostate una alla volta sulla nuova VLAN tramite script dedicato, ciascuna verificata subito dopo via rilettura diretta dello switch.

Entro pochi minuti dall'ultima porta applicata, la rete Wi-Fi ha smesso di essere visibile del tutto (non solo irraggiungibile) su due dispositivi diversi, mentre i dati letti dallo switch (collegamento fisico attivo, alimentazione PoE, impostazioni di porta corrette) non mostravano alcuna anomalia — segno che il problema viveva nell'access point stesso, non nello switch. Dato che i tre access point restano inaccessibili (credenziali perse, nessuna dashboard, vedi AP-001), non è stato possibile determinare la causa esatta. Ripristinate le tre porte alla configurazione precedente con lo stesso strumento usato per applicarle: servizio Wi-Fi confermato tornato entro un quarto d'ora dalla prima segnalazione.

La configurazione lato firewall (interfaccia, zona, DHCP, regole di sicurezza) resta applicata e valida per un nuovo tentativo. L'episodio rafforza, con una prova pratica, la decisione già presa di pianificare la sostituzione dei tre access point invece di continuare a farli convivere con altri interventi di rete. Dettaglio tecnico completo in `docs/runbook-anomalie.md` §NET-005.

## 20/07/2026 - Fase B Wi-Fi: scelto il preventivo Punto Informatica per 3 AP Zyxel

Ricevuto e scelto un preventivo di Punto Informatica (17/07/2026) per tre access point Zyxel NWA130BE-EU0101, Wi-Fi 7 (802.11be) tri-radio, gestibili in NebulaFlex standalone o cloud-managed dalla stessa organizzazione Nebula gia' in uso per i due switch. La quantita' di tre unita' copre le tre ubicazioni AP staff/guest gia' mappate (PianoTerra, PianoPrimo, PianoSecondo), coerente con il piano multi-SSID (staff + guest sullo stesso AP) gia' deciso il 15/07/2026. L'AP EsternoIrrigazione (centrale irrigazione tetto) resta fuori scope, decisione separata non ancora presa. Importo, sconto e riferimento del documento non riportati per policy di anonimizzazione (`.claude/rules/anonymization.md`). Acquisto e consegna non ancora confermati. Dettaglio completo in `docs/runbook-anomalie.md` §AP-001; roadmap aggiornata (M13b).

## 20/07/2026 - Fix errore 657rx: app M365 bloccate dopo reset password (workplace join orfano)

Intervento di helpdesk su una postazione Windows con account locale: dopo il reset della password Microsoft 365 dell'utente, tutte le app Microsoft (OneDrive, Teams, Office) hanno smesso di autenticare con l'errore 657rx / `0x80090016 NTE_BAD_KEYSET` (sub status 6008), seguito da un popup fuorviante sul TPM (`Keyset non esistente`, `0x8009000D`). Il login falliva a prescindere dalla password appena impostata.

La diagnosi con `dsregcmd /status` ha isolato la causa: non la password e nemmeno il TPM (`TpmProtected : NO`, chiave nel Software KSP), ma una registrazione "Accesso aziendale o scolastico" (workplace join) vecchia e orfana, con certificato di dispositivo datato 2017 e keyset software corrotto. Le app passano dal broker AAD, che tentava di autenticarsi con quella chiave di dispositivo inaccessibile invece che con la password, fallendo sempre. Un account Windows locale temporaneo confermava il login M365 funzionante, circoscrivendo il guasto al profilo utente e non alla macchina.

Rimossa la registrazione orfana (`dsregcmd /leave`, poi eliminazione manuale del certificato MS-Organization-Access dallo store certificati utente e della chiave `HKCU\...\WorkplaceJoin`), riavviata la postazione e verificato `WorkplaceJoined : NO`, il nuovo login M365 ha ricreato una registrazione pulita (`WamDefaultSet : YES`, certificato con data recente) e le app hanno ripreso ad autenticare. Resta come igiene consigliata la rimozione dell'eventuale record di dispositivo orfano lato Entra ID (portale Dispositivi), a chiudere il ciclo di vita della vecchia identita'. Procedura riproducibile completa, con codici errore e passaggi accessori, in `docs/runbook-anomalie.md` §END-001; nota di igiene delle identita' di dispositivo in `design-and-security.md` §A.9.2.

## 22/07/2026 - Wi-Fi ospiti su VLAN 90: navigazione ripristinata (SNAT mancante)

La rete Wi-Fi ospiti (SSID `Intrawelt (GUEST)`, VLAN 90, servita in multi-SSID dal nuovo access point Zyxel insieme all'SSID staff su VLAN 40) presentava un guasto netto: i client si agganciavano e prendevano regolarmente un indirizzo sulla `10.61.90.0/24` dal DHCP dell'interfaccia guest del firewall (`.90.1`), ma non navigavano. Confermato sia via Wi-Fi sia via cavo, collegando un portatile a una porta dello switch Piano Terra messa temporaneamente in access sulla VLAN 90: segno che il difetto era comune all'intera VLAN 90, non dell'access point ne' del tagging dell'SSID.

La diagnosi ha proceduto per esclusione, a strati. Il livello 2 verso il gateway era integro: l'ARP del client risolveva il MAC dell'interfaccia guest del firewall, quindi il pacchetto arrivava all'apparato. La security policy permetteva l'uscita: la regola `GUEST_Outgoing` (dalla zona guest verso qualsiasi destinazione) era attiva, e nel log del firewall, filtrato sull'IP del client verso `8.8.8.8` durante un ping continuo, non compariva alcun drop. La tabella NAT conteneva solo virtual server e la tabella Policy Route era vuota. Ne restava una sola spiegazione: il SNAT mancante.

Sullo ZLD il mascheramento verso la WAN e' automatico solo per le interfacce LAN di fabbrica; la guest, interfaccia aggiunta in seguito, ne restava fuori, quindi i pacchetti uscivano con IP sorgente privato e la risposta non poteva tornare. Creato l'oggetto indirizzo `GUEST_SUBNET` e una policy route `GUEST_SNAT` con SNAT `outgoing-interface` sulla sola subnet guest. Applicata, il portatile ha ottenuto risposta dal ping verso `8.8.8.8` e i dispositivi sull'SSID ospiti hanno ripreso a navigare. Da rilevare, la VLAN 90 risulta ormai ripulita dall'infrastruttura che vi era finita per errore (management degli switch, UPS, server domotica, vecchi AP): oggi ospita solo il gateway del firewall e client di tipo laptop/telefono, cioe' e' finalmente una vera rete ospiti.

Restano aperti due affinamenti, non urgenti. Il primo e' di segmentazione: restringere la regola `GUEST_Outgoing` dalla destinazione `any` alla sola WAN (la guest oggi potrebbe raggiungere anche le zone interne), meglio sul firewall che sull'access point, perche' su Nebula il toggle Guest Network fa isolamento L2 ma su una rete VLAN va aggiunto a mano il MAC del gateway alla lista, pena la perdita del gateway stesso. Il secondo riguarda la staff: la `vlan40` naviga gia', quindi non le manca il SNAT (il firewall la mascher a automaticamente); resta solo da riportarla all'indirizzamento reale. Dettaglio tecnico in `firewall-zyxel-usg-flex-500.md` §Policy Route (SNAT).

Aggiornamento allo stesso 22/07/2026, due chiusure. Prima: la `vlan40` staff e' stata riportata all'indirizzamento corretto della classe interna (nel modello documentale resta `10.61.40.x`; i valori reali stanno in `_notes/` per policy di anonimizzazione), con il DHCP riallineato alla nuova subnet, e la Wi-Fi staff ha continuato a navigare senza interventi. Seconda, ed e' la piu' importante: e' stato chiarito il perche' la staff navigasse senza SNAT esplicito e la guest no. La differenza e' il campo `Interface Type` dell'interfaccia sul firewall: la `vlan40` staff e' di tipo `internal`, la `vlan90` guest e' di tipo `general` (entrambe VLAN sulla stessa porta base `lan1`). Il firewall Zyxel applica il mascheramento automatico verso la WAN solo al traffico che esce da un'interfaccia `internal`; la guest, essendo `general`, non lo riceve, ed e' per questo che ha richiesto la policy route `GUEST_SNAT`. Che la staff abbia continuato a navigare anche dopo il cambio di subnet dimostra che il mascheramento automatico dipende dal tipo di interfaccia, non dall'indirizzo. Per una rete ospiti tenere la guest come `general` con SNAT esplicito e' anche la scelta piu' sicura, perche' il firewall non la tratta come rete interna fidata. Dettaglio in `firewall-zyxel-usg-flex-500.md` §Policy Route (SNAT).

---

## 21/07/2026 - Nasce la VM208 "portaleAsset": pilota interno del portale ISO27001 sulla LAN

Sul nodo Proxmox viene creata la decima macchina virtuale, `portaleAsset` (VMID 208): quattro core, 8 GB di RAM con balloon a 4 GB, disco da 100 GB sullo storage SERVIZI, avvio automatico all'accensione del nodo, guest agent attivo e console grafica. Ospita il pilota interno di un portale di supporto operativo alla ISO/IEC 27001:2022, un progetto software con repository e documentazione propri che fino a quel momento girava solo sulla postazione di sviluppo.

Il fatto rilevante per la rete non e' la VM in se' ma dove viene attestata: il bridge `vmbr0`, cioe' la LAN unica `/19` dei servizi, la stessa su cui vivono postazioni, stampanti e server. Dal 22/07 lo stack del pilota pubblica su TCP/80 e TCP/443 di tutte le interfacce, identity provider incluso, e la NIC ha il flag `firewall=1` a livello Proxmox che pero' non produce alcun effetto perche' il firewall di cluster resta inattivo e senza regole. E' la prima volta che un servizio applicativo interno viene esposto in questo modo sulla rete piatta, e trasforma la mancata segmentazione da rischio teorico in requisito concreto per il micro-step M22 (vedi `GAP-TBC.md` #118/NET-011).

Nello stesso giorno vengono registrati su Nebula i tre access point Zyxel NWA130BE acquistati per la Fase B, con i nomi di sito "AP piano terra", "AP Piano 1" e "AP Piano 2" (dettaglio in `runbook-anomalie.md` §AP-001).

---

## 23/07/2026 - Telefoni IP del Piano Terra: parte di rete risolta, e la dorsale era documentata invertita

Ripreso TEL-002, il sintomo aperto dal 07/07: i due telefoni IP del Piano Terra non si registrano, mentre quelli del Piano 2 funzionano. La diagnosi e' partita dall'apparato che funziona invece che da quello rotto, che e' il modo piu' rapido di ottenere una specifica: sul 54HP un telefono operativo sta su una porta Access con PVID 2, il DHCP e il gateway della fonia di Vianova stanno anch'essi su una porta Access PVID 2, e sulla porta 6, il cui ruolo era rimasto aperto dal 17/07, c'e' un dispositivo voce Grandstream dello stesso fornitore, coerentemente su PVID 2. Sul 54HP, quindi, la VLAN 2 e' la rete della fonia e il tag lo mette lo switch tramite il PVID: Vianova e' semplicemente un endpoint untagged su quella VLAN, non un apparato che tagga.

La verifica di dettaglio delle porte ha prodotto anche una correzione di topologia che la documentazione portava invertita da giorni. Il vicino LLDP dichiarato sulla porta 51 del 54HP e' lo switch del Piano Terra: la dorsale e' quella, non la 52, che e' invece il ramo verso il QNAP. La conseguenza immediata e' che l'ipotesi di partenza andava scartata, perche' quel trunk ammetteva `All` e portava quindi anche la VLAN 2 verso il basso.

La causa vera era dall'altra parte, ed era doppia. Il trunk lato Piano Terra, la porta 29 del 30HP, aveva `Allowed VLANs` uguale a `1, 40, 90`: la VLAN 2 della fonia non era nella lista e veniva scartata all'ingresso dello switch, quindi la fonia arrivava fino al Piano Terra e li' si fermava. E le due porte dei telefoni, la 13 e la 23, erano Access con PVID 1, cioe' sulla VLAN dati. Corretti entrambi i difetti, la tabella MAC del 30HP mostra i due apparecchi sulla VLAN 2 alle rispettive porte e il MAC VRRP del gateway Vianova raggiungibile sulla VLAN 2 attraverso la porta 29: la parte switch e VLAN di TEL-002 e' risolta e verificata.

Resta aperto il solo livello DHCP, perche' i due telefoni non ottengono un lease. L'ipotesi principale e' che il provisioning per MAC non sia mai stato eseguito lato Vianova/myOffice per questi due apparecchi; l'alternativa e' un DHCP snooping che scarta le offerte in arrivo dal trunk se la porta non e' marcata come trusted. Il test decisivo, non ancora eseguito, e' collegare un portatile a una porta del 30HP in Access PVID 2: se non ottiene un indirizzo il problema e' lato switch, se lo ottiene il problema e' il provisioning del fornitore. L'email al fornitore e' pronta.

### Incidente della stessa giornata: PVID non valido sul trunk, il core switch cade dal cloud

Durante l'intervento la porta 51 del 54HP e' stata salvata con i due campi invertiti, cioe' con la lista `1,2,40,90` nel campo PVID, che accetta un valore singolo, e `All` nel campo delle VLAN ammesse. Con il controllo della VLAN di gestione attivo, un PVID non valido sul trunk fa perdere allo switch la VLAN di management: il 54HP e' comparso offline in Nebula, con tutte le porte grigie e i sensori non disponibili. Il piano dati ha continuato a funzionare, perche' uno switch Zyxel commuta anche senza il cloud, e l'apparato si e' riconnesso da solo poco dopo il salvataggio della configurazione corretta, senza riavvio e senza interruzione reale per gli utenti.

Da qui due acquisizioni che valgono oltre l'episodio. La prima e' una regola operativa: su questi trunk il PVID e' sempre un valore singolo e la lista delle VLAN va solo nel campo `Allowed VLANS`. La seconda e' una correzione documentale: la gestione dei due switch viaggia sulla VLAN nativa dei dati, la classe `.10`, e non sulla VLAN 90 come indicava FW-002 in una versione datata, ed e' esattamente per questo che un PVID rotto sul trunk porta con se' il piano di gestione. Sul core switch si e' scelto di lasciare la porta 51 su `Allowed VLANs = All`, che funziona e passa la VLAN 2, rinunciando per ora alla lista esplicita: su un apparato centrale il rischio della modifica supera il beneficio della restrizione.

### Wi-Fi: la staff diventa rete piena, la guest resta isolata

Nella stessa giornata si e' consolidata la postura Wi-Fi decisa il 22/07. La regola `WIFI_STAFF_to_LAN1_deny` e' passata ad `allow`: la Wi-Fi staff ha accesso completo alla LAN, NAS compreso, come una postazione cablata, perche' i due SSID sono distinti e protetti da password e la rete non fidata e' la guest. Specularmente, la regola di uscita della guest e' stata ristretta da destinazione `any` a sola WAN. Entrambe le cose sono state verificate in campo. L'effetto documentale e' che NET-005 resta aperto come rischio accettato e non come difetto residuo, e la sua chiusura si sposta su M22, la segmentazione reale della LAN piatta (vedi `runbook-anomalie.md` §NET-005, aggiornamento 22-23/07/2026).

---

## 27/07/2026 - Ricognizione delle VM applicative: l'inventario Proxmox passa a dieci macchine

Sessione di riallineamento documentale, senza modifiche alla rete. Interrogato direttamente il nodo Proxmox e ispezionate via SSH le due VM piu' recenti, per capire cosa girasse davvero su una rete che nel frattempo aveva accumulato servizi non censiti.

Il nodo e' in salute e scarico: 48 core al 4 per cento, 96.7 GiB di RAM occupati su 125.4, 68 giorni di uptime, nulla di cambiato su storage, job di backup e stato del firewall rispetto allo snapshot v4 dell'08/07. Le macchine virtuali sono pero' diventate dieci, nove in esecuzione piu' la 203 che e' un template fermo: il conteggio a nove scritto nelle schede era superato dalla nascita della VM208 del 21/07. Emersa anche una correzione anagrafica sulla VM207, documentata come "nuova" il 13/07/2026 mentre il metadato di creazione della sua configurazione la data all'08/02/2025: era nuova alla documentazione, non all'infrastruttura.

Le due VM ospitano progetti software distinti, con repository e cicli di vita propri, che in questo progetto interessano come asset di rete. La VM207 esegue un servizio di estrazione di contenuti da siti web: backend sotto systemd con utente di servizio dedicato, in ascolto in HTTP non cifrato sulla porta 8000 legata al proprio indirizzo di LAN, dati su un disco separato e una condivisione del NAS-INTRA2 montata in CIFS con un account di servizio dedicato, che e' la scelta corretta. Attivo e verificato dal 23/07. La VM208 esegue il pilota del portale ISO27001, con database, cache, identity provider, API e reverse proxy in container: l'endpoint di prontezza risponde correttamente e il servizio e' pubblicato in HTTPS sulla LAN.

Dalla ricognizione sono nati quattro gap tracciati in `GAP-TBC.md`: l'esposizione del pilota sulla LAN piatta senza filtro interposto (#118/NET-011), la catena di fiducia costruita a mano con file `hosts` e CA interna importata macchina per macchina (#119/SEC-016), un parametro di console VNC su tutte le interfacce nella configurazione della VM207 insieme a un file di credenziali in chiaro nella home (#120/SRV-005), e l'assenza di una regola su dove viva il codice prodotto su asset aziendali, dato che uno dei due repository pubblica anche verso l'account GitHub personale di un collaboratore (#121/SEC-017). Registrate le voci corrispondenti nella Statement of Applicability (`design-and-security.md` §A.9.7, §A.10.1, §A.13.1, §A.14.2) e la riconciliazione dell'inventario in `.claude/context/design-and-security.md`.

Delimitato anche il perimetro documentale, perche' la domanda si riproporra' a ogni nuovo progetto interno: questo repository documenta le VM come asset di rete, cioe' che cosa espongono, su quale segmento e con quale postura di sicurezza, mentre lo stato di avanzamento del software resta nei rispettivi progetti (vedi ADR-015).

### Stessa giornata: aperto il design della segmentazione interna (M22)

Nella seconda parte della sessione si e' passati dal riallineamento al progetto, aprendo il documento di design del micro-step M22 (`docs/segmentazione-lan-m22.md`) con il diagramma target versionato in `.claude/context/diagrams/segmentazione-target-m22.mmd`. Il documento e' scritto su tre livelli, come richiesto per questo progetto: concettuale, per spiegare perche' una convenzione di ottetto non e' un confine di sicurezza e cosa un tag 802.1Q compra davvero; tecnico, con il disegno target a cinque segmenti, la matrice dei flussi consentiti e la sintassi di configurazione nell'idioma gia' verificato su questo firewall; operativo, con la sequenza passo per passo, la verifica e il criterio di rollback.

Il principio adottato e' che il design non riparte da zero ma si innesta su quello che questo progetto ha gia' costruito: il precedente completo della VLAN 40 (interfaccia taggata sullo stesso port-group `lan1`, DHCP applicato dalla sezione nascosta della GUI, zona dedicata assegnata a mano), la lezione della VLAN 90 sul campo `Interface Type` e il mascheramento automatico, la convenzione di indirizzamento in cui l'ottetto coincide con l'ID VLAN, gli script Nebula in lettura e scrittura, e i due diagrammi drawio di stato attuale e target come base grafica.

Tre correzioni sono emerse proprio dal confronto con il materiale esistente, e sono la prova che rileggere prima di scrivere serve. La scheda firewall affermava, sulla base dello snapshot del 15/07, che ogni porta di entrambi gli switch avesse `allowedVLAN: all` e che quindi qualunque VLAN nuova attraversasse gia' i collegamenti: non e' piu' vero dal 23/07, perche' il trunk lato Piano Terra porta ora una lista esplicita, e per M22 ne segue un passo obbligatorio in piu'. La tabella VLAN del diagramma di rete invertiva il ruolo delle classi `.10` e `.20` rispetto alla configurazione reale del firewall, dove `lan1` e' la rete delle postazioni con il proprio pool DHCP e `lan1:1` quella dei server e dei NAS. Ed e' emerso un sesto segmento candidato che nella lista iniziale non c'era: la gestione degli apparati, che oggi vive nella stessa classe delle postazioni per lo switch del Piano Terra e su una classe `.1` mai descritta come segmento per la iLO del server, cioe' esattamente l'adiacenza che una segmentazione dovrebbe eliminare per prima.

Il primo passo operativo e' il censimento (M22a): uno snapshot Nebula posteriore al 23/07 con la tabella MAC di entrambi gli switch, la lettura degli ambiti DHCP e delle riserve dalla GUI del firewall, e l'inventario degli host con indirizzo statico o scritto a mano, che e' la condizione posta per scegliere tra rinumerare le classi e affiancare segmenti nuovi svuotando il legacy.

### Censimento M22a, prima meta' (27/07/2026, ore 14:54): il Piano Terra parla, il Piano 2 no

Lo snapshot e' stato raccolto ed e' arrivato asimmetrico, in modo istruttivo. Lo switch del Piano Terra ha risposto a tutto: trenta porte di configurazione e una tabella MAC di cinquantotto voci, cioe' esattamente il dato che mancava nella raccolta del 21/07. Lo switch del Piano 2 ha risposto sulla configurazione delle sue cinquantaquattro porte ma ha rifiutato la tabella MAC con `422 DEVICE_IS_OFFLINE`: e' fuori dal piano di gestione, a quattro giorni dall'episodio del 23/07 quando ci era finito per un PVID non valido sul trunk e ne era uscito da solo. Il piano dati risulta integro, perche' nella tabella del Piano Terra compaiono MAC del Piano 2 appresi attraverso la dorsale, ma il censimento resta a meta' e la seconda parte va ripresa a switch rientrato (registrato come nuova occorrenza di NEB-001, `runbook-anomalie.md`).

Dalla meta' che c'e' sono uscite tre notizie che valgono piu' del censimento stesso.

La prima e' che **i tre access point Zyxel della Fase B non sono solo registrati, sono installati e in servizio**. Quello del Piano Terra e' appreso sulla porta 1 del 30HP, e quelli del Piano 1 e del Piano 2 sono appresi attraverso la dorsale, quindi attestati sul 54HP e online. Dei quattro Ubiquiti legacy nella tabella MAC ne resta uno solo, l'EsternoIrrigazione sulla porta 4: i tre sostituiti sono spariti, coerentemente con una sostituzione avvenuta. La roadmap dava M13b come "hardware consegnato, installazione da fare": era superata dai fatti.

La seconda e' che la porta 1 del 30HP, che era una porta access, e' ora un **trunk** che porta la VLAN 1 e la VLAN 40, con due client Wi-Fi appresi sulla 40 con MAC randomizzati. Detto in altri termini: l'isolamento della Wi-Fi staff che il micro-step M13a aveva tentato sui vecchi access point, ottenendo solo di farli smettere di trasmettere, e' oggi operativo sul nuovo hardware. Non e' stato "risolto" il problema di allora — e' stato sostituito l'hardware che lo causava, che era esattamente la decisione presa il 15/07/2026.

La terza e' un residuo: la porta 19 dello stesso switch e' ancora configurata come access con **PVID 90**, cioe' nella rete ospiti. E' l'avanzo del test cablato del 22/07, quando ci era stato collegato un portatile per verificare che il difetto della VLAN 90 non fosse specifico del Wi-Fi, e risultava riportato a PVID 1 a fine test. La configurazione dice il contrario. Al momento la porta non ha link, quindi non c'e' impatto in atto, ma una presa a muro che consegna chi si collega direttamente in rete ospiti e' una segmentazione al contrario, e va chiusa prima di aggiungere segmenti nuovi (`GAP-TBC.md` #123).

Sul fronte del censimento vero e proprio, il Piano Terra risulta con una stampante Kyocera identificata con certezza sulla porta 6, i due telefoni ancora correttamente sulla VLAN 2 alle porte 13 e 23, la dorsale sulla porta 29 a 10 Gbps con tutte e quattro le VLAN ammesse, dodici porte con un solo MAC appreso ciascuna ancora da attribuire per ruolo, e undici porte libere, che sono capacita' piu' che sufficiente per migrare a gruppi senza scollegare nulla.

Registrato infine un fatto di sicurezza che era stato verificato il 23/07 e mai scritto in un file tracciato: sul 30HP il DHCP Server Guard, che e' il nome Zyxel del DHCP snooping, e l'IP source guard sono entrambi disattivati. La verifica era nata per scagionare lo switch dal sospetto di scartare le offerte DHCP della fonia, e in quel senso e' servita, ma lascia il fatto che nessuna protezione impedisce a un dispositivo collegato a una presa di rispondere a una richiesta DHCP e dirottare i client su gateway e DNS arbitrari — su una LAN piatta, i client dell'intera `/19`. L'attivazione non e' gratuita e va pianificata dentro M22 segmento per segmento, marcando trusted il solo trunk verso il firewall: attivarla in blocco senza quella accortezza scarta le offerte legittime, che e' precisamente il tranello ipotizzato per i telefoni muti (NET-012, `GAP-TBC.md` #122).

---

## 28/07/2026 - L'ultimo access point EOL entra in scope, e il vincolo di continuita' diventa progetto

Due decisioni dell'IT Manager chiudono la giornata precedente e ne aprono una nuova.

La prima riguarda il quarto access point Ubiquiti, quello che serve la centrale di irrigazione sul tetto. Il preventivo di Fase B lo aveva escluso perche' non serve copertura Wi-Fi per le persone, e la decisione era registrata come "fuori scope, scelta separata non ancora presa". Con i tre AP nuovi in servizio, quella scelta e' stata presa: si sostituisce anche lui, come micro-step a se' stante M13c (ADR-016). Il motivo non e' estetico. Finche' erano quattro, i dispositivi con Debian 7 e Dropbear SSH erano una condizione diffusa e la loro bonifica era un progetto; oggi e' un singolo apparato, su una porta nota, con un ruolo circoscritto — cioe' un problema finito, che si chiude invece di gestirlo. Il rischio residuo e' registrato come gap dedicato SEC-018 (`GAP-TBC.md` #124) invece di restare una nota dentro AP-001.

L'intervento e' stato scomposto in otto sotto-passi tracciati, perche' quattro fatti accertati lo rendono meno banale di una sostituzione di apparato. Il collegamento al tetto e' cablato, non un ponte radio: il rilievo fisico registra un patch intermedio nel locale caldaia, quindi l'AP e' alimentato in PoE dalla porta 4 e il client radio e' la centrale. La porta 4 negozia a 100 Mbps mentre le porte delle postazioni dello stesso switch vanno a 1 Gbps, e va chiarito se il limite sia l'eta' dell'apparato o la tratta stessa, perche' nel secondo caso un apparato nuovo resterebbe strozzato. La passphrase della rete radio attuale non e' recuperabile, perche' l'AP e' inaccessibile: l'SSID si legge con una scansione, la chiave no, quindi l'intervento comporta per costruzione la creazione di una rete nuova e la riconfigurazione della centrale, con il possibile coinvolgimento del fornitore dell'impianto. E la prima opzione da valutare non e' un access point nuovo ma nessun access point: se la centrale espone una porta Ethernet raggiungibile dal cavo che arriva al tetto, il collegamento diventa cablato e l'apparato fuori supporto sparisce invece di essere sostituito. Il collaudo, per la stessa logica del canary usata altrove, non e' la raggiungibilita' IP della centrale ma la partenza di un ciclo di irrigazione reale, e il vecchio apparato non si smaltisce prima di quella verifica.

La seconda decisione e' un vincolo posto sulla segmentazione: mettere le mani alle VLAN non deve rompere niente, e un PC deve continuare a raggiungere una stampante e un NAS. Tradotto in progetto, ha prodotto una sezione dedicata del documento di design. Segmentare non rompe il routing, che si autorizza con una regola; rompe la scoperta basata su broadcast e rompe ogni riferimento scritto per indirizzo IP quando quell'indirizzo cambia. Su questa rete i riferimenti per indirizzo sono la norma, perche' non esiste un DNS interno: unita' di rete mappate, voci nei file `hosts`, job di backup, license server, code di stampa. Da qui la regola d'oro della migrazione, che riscrive l'ordine in modo non ovvio: si spostano i client, non gli endpoint referenziati. Un PC che cambia indirizzo non rompe niente, perche' nessuno lo cerca per indirizzo; un NAS che cambia indirizzo rompe insieme le mappature di tutte le postazioni, i backup e le voci `hosts`. I server restano quindi fermi fino all'ultimo, e un PC migrato raggiunge il NAS non migrato come traffico instradato che la matrice consente: il servizio continua e il controllo si aggiunge.

L'eccezione, dichiarata invece di essere scoperta in corsa, riguarda proprio il primo segmento scelto: la stampante e' essa stessa un endpoint referenziato, perche' ogni coda di stampa punta al suo indirizzo. L'accoppiamento minimo delle stampanti e' a livello di rete, non a livello applicativo. L'ordine non cambia, perche' resta il posto giusto dove sbagliare, ma il piano guadagna un passo prima dello spostamento: rilevare come sono configurate le code, dato che le tre configurazioni possibili hanno costi diversi — una coda che passa da un server di stampa non richiede di toccare nessun PC, una coda diretta Standard TCP/IP si ri-punta una volta e conviene puntarla a un nome invece che a un indirizzo, una coda WSD non si ri-punta affatto e va ricreata, perche' si appoggia alla scoperta broadcast che il confine di livello 3 taglia.

### Rilevamento delle code di stampa e baseline funzionale (28/07/2026)

Il rilevamento e' stato eseguito nel pomeriggio su una postazione reale e ha dato una risposta netta: nessun server di stampa, nessuna coda WSD, code dirette Standard TCP/IP che puntano all'indirizzo dell'apparato. Siamo quindi nel caso intermedio, quello che richiede di ri-puntare le code una volta per postazione. Due dettagli abbassano il costo rispetto alla stima peggiore: le code sono installate per piano e non tutte su tutte le postazioni, quindi il lavoro e' la somma delle code effettivamente presenti e va misurato sull'inventario dell'RMM invece che stimato; e sulla postazione esaminata convivono due porte verso lo stesso indirizzo, una orfana e una in uso, cioe' la traccia di un ri-puntamento gia' avvenuto in passato con lo stesso metodo che useremo noi.

Identificate due multifunzione. La Kyocera del Piano Terra e' stata riconosciuta per correlazione tra la tabella MAC dello snapshot e il nome host di fabbrica dell'apparato, che Kyocera deriva dagli ultimi tre byte del MAC: e' l'apparato sulla porta 6 dello switch del Piano Terra. La Canon del Piano 1 e' nota dalla coda di stampa, mentre la sua porta fisica resta da attribuire perche' serve la tabella MAC del 54HP.

Presa anche la baseline funzionale, che e' l'unico riferimento con cui giudicare le misure dopo la migrazione: dalla classe delle postazioni entrambe le multifunfioni rispondono sulla porta di stampa RAW, la Kyocera risponde al ping con latenza nulla e la rotta verso di lei ha *next hop* nullo, cioe' consegna diretta sullo stesso livello 2 — la conferma operativa che oggi il firewall non e' sul percorso, che e' esattamente il difetto NET-009. Dopo la migrazione le stesse misure devono dare ping e porta 9100 ancora funzionanti e next hop diventato il gateway del segmento: e' quel cambiamento a dimostrare che il traffico ora passa dal firewall.

La verifica ha fatto emergere una trappola che il piano non aveva previsto. Su questa rete **mDNS funziona**, e le stampanti pubblicano un proprio nome nel dominio `.local`: sarebbe il nome piu' comodo a cui puntare le code, ed e' quello sbagliato, perche' mDNS si risolve in multicast dentro un dominio di broadcast e cessa di funzionare appena la stampante finisce in un segmento diverso. Ri-puntare le code a un nome `.local` produrrebbe code che funzionano oggi e si rompono il giorno della migrazione, cioe' sposterebbe il guasto in avanti invece di eliminarlo. Il nome da usare deve essere risolvibile in unicast, e in assenza di un DNS di LAN la strada disponibile e' una voce `hosts` distribuita dallo stesso RMM. Ne segue anche un controllo in piu' da fare sull'inventario delle code: verificare se qualcuna punta gia' a un nome `.local`, perche' quelle sono le prime a rompersi e nessuno se ne accorgerebbe fino al primo tentativo di stampa.

A chiudere la giornata, la lettura della configurazione di rete della multifunzione del Piano Terra dal suo pannello di amministrazione. Tre esiti cambiano il piano e uno lo tranquillizza. L'indirizzo e' **statico sull'apparato**, quindi l'inferenza fatta dall'assenza di un ambito DHCP sulla classe stampanti era corretta, e ne segue che conviene convertirlo in riserva DHCP *prima* di migrare: si paga una volta la conversione e da quel momento ogni cambio di indirizzo e' una modifica sul firewall invece di un intervento sulla macchina. L'apparato **non ha nessun server DNS ne' WINS configurato**, quindi non risolve nomi: le destinazioni di scansione devono essere indirizzi e non nomi, e questo va sapputo prima di progettare la share di scansione. E il pannello dichiara che le modifiche di rete si applicano solo dopo l'invio **e un riavvio della rete o del dispositivo**, cioe' il cambio di indirizzo comporta una breve indisponibilita' da mettere in finestra e non da fare a stampa in corso. Il dato che tranquillizza e' la maschera: `255.255.224.0`, cioe' una `/19` coerente con la rete piatta, quindi il sospetto di una `/24` mal configurata e' rientrato e non c'e' un difetto preesistente da sanare prima della migrazione.

Due scoperte collaterali dello stesso pannello. La prima e' che Bonjour e' attivo, il che conferma dal lato apparato il comportamento mDNS misurato dalla postazione, e va disabilitato come irrobustimento perche' dopo la segmentazione non serve a nessuno e resta solo come annuncio in multicast. La seconda e' piu' utile: l'apparato dispone di una funzione di **filtro IP** propria, quindi l'accesso amministrativo si puo' restringere alle sole postazioni IT subito, senza attendere la segmentazione e senza dipendere dal firewall, che sulla LAN piatta non vede quel traffico. E' il controllo compensativo che mancava a SEC-019: riduce la platea da tutta la `/19` a due indirizzi al costo di una configurazione.

---

## 29/07/2026 - Le scansioni finiscono sui PC: misurato, e aperto il registro dei micro-interventi

Letta voce per voce la rubrica delle destinazioni di scansione della multifunzione del Piano Terra. Il risultato trasforma in misura quello che il gap NET-009 registrava come osservazione dell'IT Manager: **tutte e quattro** le destinazioni configurate sono cartelle di rete SMB su porta 445 e puntano a condivisioni di **singole postazioni**, con percorsi del tipo `SCANNER`. Nessuna punta a un NAS, nessuna e' di tipo e-mail, i campi FTP sono vuoti. Per ciascuna voce l'apparato conserva nome utente e password di accesso alla condivisione, e in almeno un caso l'utenza e' il nome e cognome di una persona fisica invece di un account di servizio.

Ne derivano quattro problemi indipendenti, e vale la pena separarli perche' hanno rimedi diversi. Il primo e' di governo dei dati: i documenti scansionati, che tipicamente contengono dati personali, si depositano su endpoint invece che su uno spazio presidiato con backup noto. Il secondo e' di affidabilita' e non di sicurezza: la scansione funziona solo se quella postazione e' accesa e la condivisione attiva. Il terzo e' che la multifunzione diventa un deposito di credenziali di accesso a share aziendali, e questo pesa molto piu' del previsto perche' il suo pannello amministrativo e' protetto dalle credenziali di fabbrica ed e' raggiungibile da tutta la LAN piatta. Il quarto e' che un'utenza nominale usata da un apparato non e' attribuibile a nessuno e si rompe silenziosamente il giorno in cui quella persona lascia l'azienda. Registrato come SEC-020 (`GAP-TBC.md` #126) e come aggiornamento misurato di NET-009.

La conseguenza sul progetto di segmentazione e' doppia. Da un lato dimensiona il lavoro nascosto di M22b: la riga "stampanti verso postazioni negato" della matrice dei flussi non e' una restrizione teorica, e' la disattivazione di quattro destinazioni realmente in uso, e spostare la porta della stampante senza preparare le sostitutive farebbe perdere la scansione a quattro persone in modo silenzioso, perche' la macchina accetta il lavoro e poi fallisce l'invio. Dall'altro, ed e' la scoperta utile, quel lavoro **non ha bisogno della segmentazione**: creare la share dedicata sul NAS e spostarvi le destinazioni si puo' fare subito, sulla rete piatta, senza toccare nessuna VLAN e senza finestra di manutenzione.

### Aperto il registro dei micro-interventi di robustezza

Da questa osservazione e' nato un artefatto nuovo, `docs/interventi-robustezza.md`, su indicazione dell'IT Manager. Le analisi di questo progetto producono due tipi di risultato: difetti strutturali, che richiedono progetto, finestre e coordinamento, e difetti puntuali che si scoprono guardando dentro un apparato per un'altra ragione — una credenziale di fabbrica mai cambiata, un annuncio multicast inutile, una porta rimasta in una VLAN di test, un campo descrittivo vuoto. Il secondo tipo ha un rapporto tra riduzione del rischio e costo altissimo e un rischio di rompere qualcosa quasi nullo, ma tenuto insieme ai micro-step strutturali finisce per aspettare indefinitamente.

Il registro li raccoglie con una regola di ammissione esplicita, che e' l'unica cosa che impedisce a un contenitore del genere di diventare una lista di lavori arretrati: un intervento entra solo se non richiede finestre di manutenzione, non tocca il piano dati di apparati centrali e ha un rollback di una sola azione. Nove voci alla data di apertura, da R1 a R9: cambio delle credenziali di fabbrica della multifunzione e conservazione nel password manager, filtro IP sull'apparato come controllo compensativo dove il firewall non arriva, disabilitazione di Bonjour, compilazione del campo Posizione, ripristino della porta 19 dello switch del Piano Terra da PVID 90 a PVID 1, rimozione delle porte di stampa orfane sulle postazioni, conversione delle stampanti da indirizzo statico a riserva DHCP, spostamento delle destinazioni di scansione su una share dedicata del NAS, e sostituzione dell'utenza nominale con un account di servizio. Ognuna con motivo, procedura, verifica, criterio di rollback e stato; una sola, la conversione a riserva DHCP, comporta pochi minuti di indisponibilita' perche' l'apparato richiede il riavvio della rete per applicare il cambio.

### Requisito dell'IT Manager sulla share di scansione, e la tensione che risolve

Nella stessa giornata e' arrivato il requisito che disegna R8: gli utenti hanno gia' accesso a NAS-INTRA2 e a due cartelle di primo livello di NAS-HERO, quindi l'accesso esistente si sfrutta invece di crearne uno nuovo, ma nella nuova cartella dedicata alle scansioni ciascuno deve vedere **soltanto la propria sottocartella**.

Il requisito sembra banale e non lo e', perche' entra in tensione diretta con l'altro obiettivo. Se l'isolamento tra utenti lo si ottenesse facendo scrivere l'apparato con le credenziali di ciascun utente, come avviene oggi verso le postazioni, la multifunzione dovrebbe conservare al proprio interno le credenziali personali di tutti: si peggiorerebbe esattamente il problema di SEC-020, su una macchina il cui pannello ha ancora le credenziali di fabbrica. La separazione va quindi ottenuta dai permessi del NAS e non dalle credenziali dell'apparato: un solo account di servizio, unica credenziale memorizzata nella multifunzione, con la sola scrittura sulle sottocartelle, e i permessi degli utenti definiti sul NAS in modo che ciascuno acceda solo alla propria. L'utente non usa mai la credenziale dell'apparato e l'apparato non usa mai quella dell'utente: sono due percorsi distinti verso la stessa cartella.

Il rischio residuo va dichiarato invece di essere nascosto, perche' e' la prima cosa che un auditor chiederebbe: l'account di servizio puo' scrivere in tutte le sottocartelle, quindi chi ne ottenesse la credenziale potrebbe depositare file nella cartella di chiunque. Non puo' pero' leggere le scansioni altrui, se il NAS consente di concedergli la sola scrittura, ed e' questa asimmetria a fare la differenza rispetto a oggi, dove l'apparato conserva credenziali con accesso completo a cartelle di postazioni. Il rischio passa da lettura e scrittura su endpoint a sola scrittura su una cartella presidiata, e viene ridotto ulteriormente dagli interventi R1 e R2, che chiudono la via d'accesso al pannello dove quella credenziale e' memorizzata.

Registrate nello stesso passaggio tre cose che il disegno porta con se'. La scelta del NAS non e' neutra: NAS-HERO e' replicato fuori sede su archiviazione cloud, quindi scegliendolo le scansioni erediterebbero una copia esterna — vantaggio di continuita' e insieme un fatto da verificare rispetto a quanto dichiarato agli interessati, non da decidere implicitamente con una scelta di cartella. Il dubbio sul dialetto SMB dell'apparato si risolve da se' con i dati gia' raccolti, perche' le destinazioni attuali sono condivisioni di postazioni Windows 11, dove SMB versione 1 e' disabilitato di default, e le scansioni funzionano: l'apparato parla gia' SMB 2 o superiore. E serve una regola di conservazione sulla cartella nuova, aggiunta come intervento R10, perche' una cartella di scansioni senza scadenza diventa in pochi mesi un archivio documentale parallelo, non censito e pieno di dati personali, e una soglia si stabilisce molto piu' facilmente su una cartella vuota che su tre anni di documenti.

Deciso nella stessa giornata il NAS di destinazione: **NAS-INTRA2**, coerentemente con la raccomandazione — se le scansioni hanno una scadenza, replicarle fuori sede sarebbe un costo di riservatezza senza un beneficio di continuita' reale. Ne e' seguita la domanda operativa vera, cioe' come si separano gli accessi *dentro* una cartella condivisa, dato che per impostazione predefinita chi accede a una cartella condivisa vede tutto il suo contenuto. La risposta e' che si fa, con due strade native e una da scartare. La prima e' abilitare le autorizzazioni avanzate per cartella, opzione del pannello dei privilegi dell'apparato, che rende assegnabili i permessi anche alle sottocartelle dal gestore file: soddisfa il requisito mantenendo una sola cartella di primo livello e scala con gli utenti, al prezzo di un'impostazione globale da attivare deliberatamente e da verificare prima, perche' la presenza di cartelle condivise nominative suggerisce che una gestione granulare sia gia' in uso. La seconda e' creare una cartella condivisa per utente, spostando la separazione al livello dove i permessi esistono sempre: piu' semplice e robusta, al prezzo di allungare una lista di condivisioni che ne conta gia' tredici. La strada da scartare, ed e' istruttivo il perche', e' usare le cartelle personali che l'apparato offre nativamente: sono isolate per costruzione, ma scrivervi dall'esterno richiede privilegi amministrativi sul NAS, quindi la multifunzione dovrebbe conservare una credenziale amministrativa — si risolverebbe il problema degli utenti creandone uno molto piu' grande sull'apparato.

### Verifica sul NAS: autorizzazioni avanzate disattivate, e due cose viste per strada

Verificato lo stesso giorno sul pannello di controllo dell'apparato, alla scheda delle autorizzazioni avanzate delle cartelle condivise: **entrambe le caselle sono deselezionate**, sia quella delle autorizzazioni per cartella e sottocartella sia quella del supporto Windows ACL. Oggi i permessi vivono quindi solo a livello di cartella condivisa, e chi accede a una condivisione vede tutto il suo contenuto: il requisito di separazione per utente richiede di attivare la prima delle due opzioni, oppure di ripiegare sulle cartelle condivise separate. La seconda casella va lasciata dov'e', perche' cambia il modello di permessi verso quello NTFS e ha senso solo appoggiandosi a un dominio.

Registrato anche un comportamento da provare in campo prima di migrare le destinazioni, invece di fidarsi della documentazione del produttore: quando un utente ha permesso su una sottocartella ma non sulla condivisione che la contiene, l'accesso per percorso diretto funziona ma l'elenco della condivisione puo' essere negato. Per gli utenti e' esattamente il comportamento desiderato; per l'account di servizio della multifunzione, che si connette alla condivisione e poi scende nella sottocartella, va verificato che la connessione non richieda un permesso che non ha — altrimenti la scansione fallisce con un errore che sul display non dice nulla di utile.

Due fatti visti per strada nella stessa sessione, entrambi tracciati perche' non erano cercati e sono piu' significativi del motivo per cui si era aperto quel pannello. Il primo: la cartella condivisa del backup ufficio contiene **14,37 TB su circa 3,45 milioni di cartelle e 1,86 milioni di file**, cioe' da sola quasi tutta la capacita' utile dell'apparato, e non c'e' nel progetto nessuna fonte che dica cosa contenga, se sia protetta da una copia propria o sia soltanto la destinazione di copie altrui, e quanto tempo richiederebbe un ripristino selettivo con quel numero di oggetti (gap STOR-001, `GAP-TBC.md` #127; rilevante per A.8.13 e per il tempo di ripristino dichiarato nel piano di continuita'). Il secondo: l'interfaccia di amministrazione dell'apparato risponde con lentezza marcata, con attese di decine di secondi per cambiare sezione, mentre il servizio file resta pienamente reattivo — registrato come NAS-003 in `runbook-anomalie.md`, con la mole di oggetti come ipotesi principale, la dotazione hardware come seconda e un job in corso come terza, da escludere per prima perche' e' la piu' facile da verificare. Conta perche' R8 richiede diversi passaggi in quella interfaccia e la stima dei tempi passa da minuti a decine di minuti.

### La spunta che non era una spunta: raccomandazione capovolta

Spuntando la casella delle autorizzazioni avanzate, prima di applicare, l'apparato ha mostrato un dialogo di conferma che ha cambiato la decisione: all'attivazione **tutte le autorizzazioni delle sottocartelle vengono impostate come quelle delle cartelle principali**, con un'operazione che puo' richiedere diversi minuti in funzione del numero di file e cartelle da elaborare. Non e' quindi un interruttore di configurazione, e' una riscrittura massiva di permessi su tutto il volume — e la nota scritta poche ore prima in questo stesso progetto, secondo cui l'attivazione non avrebbe modificato nulla, era sbagliata. Corretta nel documento di design con la ragione, perche' un errore corretto senza spiegazione torna alla sessione successiva.

Con i numeri veri il confronto tra le due strade si capovolge. Su questo apparato l'inizializzazione attraverserebbe un albero da circa cinque milioni di oggetti, su hardware con 4 GB di RAM e CPU ARM, mentre serve le condivisioni di lavoro e con il pannello di amministrazione gia' lento: durata imprevedibile, da misurare e non da stimare, e comunque da eseguire fuori orario. C'e' anche una conseguenza di lungo periodo meno visibile: dopo l'inizializzazione ogni sottocartella porta permessi espliciti propri, quindi la gestione diventa granulare **e** manuale, e modificare il permesso di una condivisione non si propaga piu' implicitamente al suo contenuto. Molto piu' potente e molto piu' facile da sbagliare.

Decisione presa: per quattro destinatari si creano **quattro cartelle condivise**, una per ciascuno, con i permessi assegnati dove esistono nativamente. Quattro righe in piu' in una lista che ne conta dodici, nessuna impostazione globale toccata, nessuna riscrittura su milioni di oggetti, intervento eseguibile subito e in orario di lavoro — cioe' dentro la regola di ammissione del registro dei micro-interventi, che la strada delle autorizzazioni avanzate non rispetta piu'. Quella strada resta corretta se e quando i destinatari diventeranno molti o se si adottera' il modello per sottocartella come standard del NAS, e in quel caso sara' un intervento a se', pianificato fuori orario e con la durata misurata su una prova. La differenza non e' tecnica ma di ordine di grandezza: quattro utenti non giustificano una riscrittura di permessi su cinque milioni di oggetti.

Registrato infine il metodo di verifica, perche' l'IT Manager ha fatto notare che tutte le prove si possono eseguire dalla propria postazione: e' vero, e la ragione e' che quello che conta e' l'identita' con cui si apre la connessione, non il computer da cui si parte. La prova positiva e' montare la propria condivisione con le credenziali del destinatario e scrivere un file; la prova negativa, che e' quella che dimostra il requisito, e' tentare la condivisione di un altro destinatario con le stesse credenziali e ricevere un rifiuto. Con un dettaglio di Windows che fa perdere tempo se non lo si sa: verso lo stesso server non si possono tenere aperte contemporaneamente connessioni con identita' diverse, e il tentativo restituisce un errore di conflitto di sessione che sembra un problema di permessi e non lo e', quindi prima di ogni prova con un'altra utenza va chiusa la sessione precedente.

---

## 30/07/2026 - Censimento chiuso su entrambe le multifunzione: sette destinatari, e una deviazione dichiarata

Letta anche la rubrica della seconda multifunzione, la Canon del Piano 1, su richiesta dell'IT Manager di fare la stima globale prima di committare qualunque decisione. La richiesta era giusta nel merito e non solo nel metodo: il disegno dimensionato su quattro destinatari e' una cosa, lo stesso disegno su sette e' un'altra, e la scelta della strategia dipendeva esattamente da quel numero.

Prima cosa, una particolarita' del modello che a colpo d'occhio fa sembrare il censimento un lavoro enorme quando non lo e'. La rubrica di quell'apparato espone un elenco personale, cinquanta elenchi per gruppi di utenti, dieci elenchi indirizzi e un elenco per amministratori: sessantadue contenitori, tutti creati a vuoto dal firmware. La colonna dei conteggi lo dice a chiare lettere, perche' riportano tutti zero destinazioni tranne l'elenco a selezione veloce, che ne contiene sette. Tutta la rubrica utile della macchina sta in un solo elenco.

Le sette voci sono **sette su sette cartelle di rete SMB verso condivisioni di postazioni**, nessuna e-mail e nessun FTP, con il campo del percorso vuoto perche' la condivisione e' gia' nel campo host. Il totale sui due apparati e' quindi undici destinazioni, che si riducono a **sette destinatari distinti**: le quattro voci della Kyocera sono un sottoinsieme delle sette della Canon, che aggiunge tre persone non censite al Piano Terra. Il fronte scan-to-folder e' percio' totale su entrambe le macchine, non una particolarita' di una delle due.

Tre fatti nuovi che il primo censimento non poteva mostrare. Due destinazioni su sette puntano alla postazione per **nome NetBIOS** invece che per indirizzo: funzionano perche' la risoluzione NetBIOS avviene in broadcast dentro il dominio di livello 2, e sono le prime due che si romperebbero attraversando un confine instradato — terza forma della stessa trappola dopo mDNS sulle stampanti e l'assenza di un DNS interno, e conferma che su questa rete la risoluzione dei nomi e' interamente affidata al broadcast. Le utenze nominali memorizzate sono **due**, una per apparato, quindi la sostituzione con un account di servizio non affronta un caso isolato. E su tutte e sette le voci la **conferma della destinazione prima dell'invio e' disattivata**, cioe' oggi una selezione sbagliata dal display deposita documenti nella cartella di un'altra persona senza alcun passaggio che permetta di accorgersene: difetto indipendente dalla rete, tracciato come intervento R11.

### La deviazione dalla regola, dichiarata invece che nascosta

Sette destinatari sono uno oltre la soglia di sei che era stata fissata *prima* di conoscere il numero, proprio per non piegare il numero alla soluzione preferita. Applicando la regola alla lettera si dovrebbe passare alle autorizzazioni per sottocartella e rimandare tutto a un intervento fuori orario. La regola aveva pero' una ragione dichiarata e non era un numero magico: il costo delle cartelle condivise separate e' che la lista delle condivisioni diventa illeggibile. Su questo apparato quel costo e' eliminabile, perche' ogni cartella condivisa ha l'opzione che la nasconde dalla navigazione di rete restando raggiungibile per percorso diretto.

Decisione: **sette cartelle condivise nascoste**, una per destinatario. Nessuna impostazione globale toccata, nessuna riscrittura di permessi su cinque milioni di oggetti, intervento che resta dentro la regola di ammissione del registro dei micro-interventi. Il costo accettato e' che il modello non scala elegantemente: alla decina di destinatari, o quando si voglia adottare i permessi per sottocartella come standard del NAS, si passera' all'altra strada come intervento pianificato. La soglia della regola resta a sei per il caso generale: qui e' stata superata di uno con una mitigazione specifica e verificabile, e la deviazione e' scritta nel registro invece di essere coperta riscrivendo la soglia a posteriori.

### La questione del protocollo: FTP, SMB, e una premessa che vale piu' del progetto

Chiuso il censimento, l'IT Manager ha posto la domanda successiva sotto forma di due strade: portare le scansioni sul NAS usando FTP invece di SMB, nel presupposto che le multifunzione parlino soltanto SMB versione 1 e che quella versione non sia accettabile; oppure installare un server FTP su ciascuna postazione e cambiare protocollo nelle rubriche, lasciando le destinazioni dove sono.

La seconda strada e' stata scartata con quattro ragioni indipendenti dalla versione di SMB. Non risolve il problema per cui l'intervento esiste, perche' i documenti continuerebbero a depositarsi sulle postazioni: cambierebbe il trasporto, non la destinazione dei dati. Aggiunge un servizio in ascolto su ogni endpoint, allargando la superficie di attacco esattamente dove si sta lavorando per ridurla, e su una LAN piatta quel servizio e' raggiungibile da chiunque. Moltiplica la manutenzione per il numero di postazioni e mantiene la dipendenza dal fatto che quel PC sia accesso. E il protocollo in chiaro trasporterebbe credenziali e documenti in chiaro sulla rete.

La prima strada ha il disegno giusto — il NAS come destinazione, che e' esattamente R8 — ma poggia su una premessa non ancora verificata, e la verifica conta piu' della scelta del protocollo. Se gli apparati parlano SMB 2 o superiore, si va sul NAS in SMB e la questione FTP non si pone. Se parlano davvero solo SMB versione 1 e le scansioni verso le postazioni funzionano, allora il fatto rilevante non e' la multifunzione: e' che **SMB versione 1 risulta abilitato sulle postazioni**, cioe' un protocollo dismesso e vettore di famiglie di malware note e' attivo sugli endpoint aziendali — un gap piu' grave di quello che si stava chiudendo.

Registrata anche una correzione di metodo su quanto scritto il giorno prima. Il dubbio era stato dato per risolto deducendo che, poiche' le destinazioni sono condivisioni di postazioni Windows 11 dove la versione legacy e' disabilitata per impostazione predefinita, gli apparati dovevano necessariamente parlare SMB 2 o superiore. La deduzione vale solo se su quelle postazioni nessuno ha riattivato il protocollo legacy, cosa non scontata in un parco cresciuto per stratificazioni: e' stata percio' declassata da fatto a ipotesi da misurare. La misura si fa in tre modi indipendenti, tutti a costo nullo — leggere il dialetto negoziato dalle sessioni SMB della postazione subito dopo una scansione di prova, leggere le impostazioni di protocollo degli apparati, alzare a SMB 2 la versione minima accettata dal NAS e osservare chi smette di funzionare — e l'ordine di preferenza del protocollo e' stato fissato prima di conoscere l'esito: SMB 2 o 3 come prima scelta, FTP esplicito su TLS solo per un apparato che non possa superare la versione legacy, FTP in chiaro solo come debito dichiarato e registrato come gap.

La prima misura, eseguita subito sulla postazione dell'IT Manager, ha dato un esito che restringe molto il campo. Su quella postazione il protocollo legacy non e' attivo — la funzione opzionale di Windows risulta disabilitata e la configurazione del servizio riporta la versione 1 disattivata e la versione 2 attiva — e la sessione osservata in quel momento negoziava dialetto 3.1.1, quindi tra Windows e Windows la rete lavora gia' sulla versione piu' recente. Poiche' entrambe le multifunzione hanno una destinazione proprio su quella postazione, e un apparato che parlasse solo la versione legacy non riuscirebbe nemmeno a connettersi, la conclusione e' che se quelle due destinazioni funzionano gli apparati parlano necessariamente SMB 2 o superiore: la premessa che motivava la proposta FTP cade, e la verifica residua e' una scansione di prova per apparato verso quella postazione.

Due osservazioni collaterali dallo stesso output, tracciate perche' piccole e facili da perdere. La firma SMB non e' richiesta sulla postazione, quindi e' un irrobustimento candidato da valutare quando si sara' certi che nessun client legacy resti in giro. E la sessione osservata proveniva da un'altra postazione autenticandosi con un account **locale** della postazione dell'IT Manager: un account locale condiviso tra macchine e' comodo e opaco, perche' l'accesso non risulta attribuibile a una persona, e va chiarito a cosa serve prima di decidere se sostituirlo. Chiarito subito dall'IT Manager: e' un accesso deliberato e noto, concesso a un collega verso un disco interno di quella macchina. Resta annotato non come anomalia ma perche' una configurazione del genere, se non scritta da nessuna parte, in due anni diventa inspiegabile.

### Esito definitivo: entrambi gli apparati scrivono in SMB, e un vincolo nuovo che pesa sul disegno

Le due scansioni di prova verso la cartella della postazione dell'IT Manager sono riuscite: la multifunzione del Piano Terra ha depositato il proprio PDF, quella del Piano 1 — comandata a distanza dallo strumento di controllo remoto del produttore invece che dal display fisico — ha depositato il proprio nella stessa cartella, vuoto perche' la prova e' stata fatta senza foglio, cosa che non inficia il risultato dato che si stava verificando la connessione e non l'immagine. Poiche' su quella postazione il protocollo legacy e' disattivato, **entrambi gli apparati parlano necessariamente SMB 2 o superiore**: la proposta FTP e' archiviata, le sette condivisioni si configureranno in SMB. Guadagnata anche un'informazione operativa: la multifunzione del Piano 1 e' pilotabile a distanza, quindi le prove dei passi successivi si fanno dalla postazione senza salire al piano.

L'IT Manager ha poi posto un vincolo che vale oltre questo intervento e che e' stato registrato come contesto trasversale del progetto: gli endpoint non sono gestiti a mano ma da un RMM distribuito che applica policy, script e automazioni e **impone la rotazione della password locale ogni trenta giorni**. Le conseguenze per il design di rete sono tre. La prima riguarda direttamente le scansioni: qualunque credenziale di postazione memorizzata in un apparato ha una vita massima di trenta giorni, quindi le undici destinazioni censite non sono solo un problema di protezione dei dati ma una manutenzione ricorrente che si rompe da sola a ogni rotazione — e questo capovolge il modo di presentare l'intervento, che non chiede uno sforzo in cambio di rischio ridotto ma elimina un lavoro ripetuto e in piu' riduce il rischio. La seconda e' che l'RMM e' il veicolo con cui si distribuiscono modifiche massive alle postazioni, quindi il ri-puntamento delle code di stampa, una voce `hosts` o una CA interna si progettano come script distribuito e non come giro fisico. La terza e' che le policy agiscono sugli endpoint mentre la rete cambia sotto di loro, e prima di modificare indirizzamento o segmentazione va saputo cosa quelle policy fanno.

Da qui una decisione di perimetro, ADR-017: la gestione endpoint entra nella documentazione di questo progetto **in sola lettura e come fotografia**. Aggiunto lo script `scripts/Get-NinjaSnapshot.ps1`, che si autentica con il flusso OAuth2 client credentials riusando il pattern gia' verificato in un progetto interno separato, interroga in best-effort inventario, policy, script, automazioni e interrogazioni diagnostiche, e scrive uno snapshot in `output/`. Nessuna scrittura, nessuna esecuzione remota di script, nessuna modifica di policy. Il vincolo piu' importante non e' tecnico: le credenziali API appartengono al provider MSP che gestisce l'RMM, quindi lo scope e' di sola lettura, non va esteso, e nel repository non esiste alcun valore — il segreto si risolve da variabile d'ambiente o da prompt a runtime, come gia' per Proxmox e per Nebula. Fra gli endpoint interrogati ce n'e' uno che serve subito a un altro fronte: l'interrogazione delle interfacce di rete per dispositivo, che dove risponde sostituisce il censimento manuale degli indirizzi statici richiesto da M22a.

### Primo snapshot RMM: tre esiti, uno dei quali e' un problema che ci siamo creati

Lo snapshot e' stato eseguito subito e ha prodotto tre risultati di natura diversa.

Il primo e' un difetto dello script, corretto in giornata: con la modalita' rigorosa attiva, la lettura di una proprieta' assente su un oggetto JSON solleva un'eccezione, e l'API omette i campi nulli invece di riportarli vuoti. Lo snapshot JSON era gia' stato scritto, il riepilogo Markdown no. Sistemato con una lettura difensiva delle proprieta' e con l'unwrap delle interrogazioni diagnostiche, che non ritornano un array ma un oggetto con i risultati e un cursore di paginazione — motivo per cui i conteggi mostravano tutti "1 elemento".

Il secondo e' il problema che ci siamo creati lanciandolo: l'istanza dell'RMM e' quella multi-tenant del provider MSP, e senza filtro la raccolta ha restituito **99 dispositivi appartenenti a 26 organizzazioni**, cioe' l'inventario di venticinque aziende terze clienti dello stesso provider. Non e' un difetto dell'istanza ma una conseguenza naturale di una chiave multi-tenant usata senza restringere l'ambito, ed e' un problema di minimizzazione: questo progetto non ha titolo per detenere quei dati. Aggiunto allo script un filtro per organizzazione attivo per default, con un interruttore esplicito per disattivarlo che va usato solo con una ragione dichiarata; lo snapshot non filtrato va rigenerato e cancellato. Registrato come SEC-022 (`GAP-TBC.md` #129).

Il terzo e' il risultato che serviva, ed e' doppio. Sul fronte del censimento, per la sola organizzazione Intrawelt l'interrogazione delle interfacce ha dato 1381 righe di adattatori su 26 dispositivi, riducibili a 75 indirizzi IPv4 distinti: ventisei nella classe delle postazioni con maschera `/19` e gateway della classe stessa, quattro su altri segmenti aziendali (due server, due sulla VLAN 40 della Wi-Fi staff, conferma indipendente che quel segmento e' in uso), undici in una classe domestica con gateway `.1.1` che sono le reti di casa dei portatili fuori sede e non vanno confuse con indirizzi interni, e il resto adattatori virtuali e di VPN. Manca solo la distinzione statico/dinamico, che l'interrogazione non riporta e che si chiude leggendo le riserve DHCP dal firewall.

Sul fronte identita', il dato piu' importante della giornata: i 26 dispositivi gestiti sono **tutti standalone**, in workgroup, **senza alcun dominio**. Quattordici workstation con un workgroup aziendale, dieci con quello predefinito di Windows, un server in workgroup, una postazione Linux. Non e' una curiosita': e' la causa comune di quattro fatti che il progetto aveva tracciato separatamente. Ogni accesso tra sistemi usa credenziali locali memorizzate, ed e' il meccanismo con cui le multifunzione conservano le password delle condivisioni degli utenti. Quelle credenziali, essendo utenze locali di Windows, hanno vita massima trenta giorni per la policy dell'RMM. Non esiste risoluzione nomi interna, quindi si dipende dal broadcast e dai file `hosts` distribuiti a mano, che e' precisamente cio' che rende fragile ogni segmentazione. E non e' possibile alcuna separazione degli accessi basata su identita'. Registrato come SEC-021 (`GAP-TBC.md` #128).

### Rendere la scansione immune alla rotazione, non solo meno esposta

Alla luce di quel dato, la richiesta dell'IT Manager — una soluzione totalmente indipendente dal cambio password, non una che riduca il problema — ha una risposta precisa e una che non e' disponibile oggi.

La risposta disponibile parte da cosa ruota davvero: la policy dell'RMM agisce sulle utenze **locali di Windows**, non sugli altri sistemi. Quindi ogni credenziale memorizzata che sia un'utenza di postazione scade, e ogni credenziale che appartenga a un sistema fuori da quel perimetro no. Il disegno immune ha due gambe e vanno rese immuni entrambe: l'account di servizio della multifunzione deve essere un'**utenza locale del NAS**, verificando che sul NAS non sia attiva una politica di scadenza che lo riporti dentro il problema da un'altra porta; e l'accesso di ciascuna persona alla propria cartella deve usare anch'esso un'**utenza locale del NAS**, salvata una volta nelle credenziali di Windows, che sopravvive a tutte le rotazioni perche' e' gestita da chi amministra il NAS e non dall'RMM. Il costo e' una seconda password per persona, digitata una volta.

La risposta strutturalmente superiore sarebbe non memorizzare alcuna credenziale, lasciando che l'autenticazione integrata di un servizio di directory dia l'accesso con il ticket della sessione di lavoro: il cambio password diventerebbe un non-evento perche' non ci sarebbe nessun segreto salvato da aggiornare. Oggi non e' percorribile, perche' quel servizio non esiste (SEC-021). Vale registrare che introdurlo chiuderebbe in un colpo quattro fronti aperti — le credenziali memorizzate, l'assenza di DNS interno, la dipendenza dal broadcast per NetBIOS e mDNS, la distribuzione a mano dei file `hosts` — ma e' un progetto con impatto organizzativo e non un intervento di rete, e nel frattempo la coppia di utenze locali del NAS rende la scansione immune senza dipendere da esso.

### Chiusura del censimento M22a, e due scoperte dal firewall che valgono di piu'

Letto dalla GUI del firewall l'ambito DHCP della rete delle postazioni e l'elenco completo delle interfacce. Il censimento si chiude per aritmetica: l'ambito parte dall'indirizzo `.200` con dimensione 55, quindi copre `.200-.254`, e incrociandolo con i ventisei indirizzi della classe postazioni censiti dall'RMM restano **ventidue indirizzi statici o riservati**, da `.17` a `.95`, e **quattro dentro l'ambito DHCP**. Il ventidue e' la corroborazione indipendente piu' pulita ottenuta finora in questo progetto, perche' coincide esattamente con i ventidue PC dichiarati come oggetto indirizzo nella configurazione del firewall, contati da una fonte completamente diversa; va invece corretto l'intervallo documentato per quegli statici, che la scheda riportava come `.18-.84` mentre la misura dice `.17-.95`. Per il piano di migrazione significa che quattro postazioni cambiano indirizzo gratis, seguendo il DHCP, e ventidue richiedono un tocco a testa — da spendere convertendole in riserve, cosi' che l'indirizzo torni governato dal firewall e ogni cambio successivo sia centrale.

La prima scoperta smentisce un'affermazione che questo progetto ha ripetuto piu' volte: non e' vero che sulla LAN non esista risoluzione nomi interna. L'ambito DHCP distribuisce come primo server DNS **il firewall stesso**, con secondo e terzo assenti e i campi WINS vuoti. Esiste quindi un resolver, ed e' un apparato che governiamo: quello che manca non e' il servizio, sono i record. Poiche' il firewall ZLD puo' ospitare record di indirizzo propri, i nomi interni si possono pubblicare li' senza introdurre un dominio e senza toccare gli endpoint, che gia' interrogano lui. E' la via piu' economica per chiudere la dipendenza dal broadcast — mDNS e NetBIOS, la trappola incontrata tre volte in questa stessa settimana — e per ri-puntare le code di stampa a un nome invece che a un indirizzo, rendendo gratuiti tutti gli spostamenti futuri. Tracciata come intervento R12, con la nota di sequenza che va fatta **prima** di M22b, per non ri-puntare le code due volte.

La seconda e' una lezione documentale. L'elenco delle interfacce conta quattordici voci, e accanto a quelle in servizio ne convivono alcune residue: fra queste un'interfaccia denominata `guest` su una `/24` appartenente a un blocco di indirizzi estraneo al piano documentale, che non e' la rete ospiti funzionante — quella dal 22/07 e' la `vlan90` agganciata a `lan1` — ma il residuo dell'epoca in cui la guest era una porta fisica. Insieme a `lan2`, gia' data per dismessa, e a due interfacce senza indirizzo, forma un insieme da bonificare (FW-013, `GAP-TBC.md` #130). Il rischio che creano non e' operativo ma interpretativo, e questo progetto lo ha appena sperimentato: leggendo l'elenco senza sapere quale interfaccia sia viva si attribuisce alla rete ospiti una subnet che non usa piu'.

### Inizio dell'esecuzione: R12, e un difetto nei nomi interni gia' in uso

Chiuso il censimento, l'IT Manager ha chiesto di procedere per passi, documentando ciascuno. Il primo passo scelto e' R12, la pubblicazione dei nomi interni sul DNS del firewall, perche' e' a rischio nullo e perche' e' prerequisito di tutto il resto: i nomi che crea servono al ri-puntamento delle code di M22b e alle destinazioni di scansione di R8, e crearli dopo significherebbe rifare quelle configurazioni due volte.

Prima di scrivere un solo record e' emerso un difetto nei nomi interni gia' in uso. La ricognizione mostra tre convenzioni convissute nel tempo: un servizio su `<nome>.intrawelt.local`, un altro su un nome breve seguito da `.local`, e il portale della VM208 su `.intrawelt.lan`. Il problema non e' l'incoerenza ma il suffisso: **`.local` e' riservato a mDNS** dallo standard che lo definisce, quindi i sistemi operativi lo risolvono interrogando il multicast e non il DNS unicast. Pubblicare quei nomi su un server DNS produce un comportamento che dipende dall'ordine dei risolutori del singolo client — funziona su una macchina e non sull'altra — e cessa comunque di funzionare attraversando un confine di livello 3, cioe' proprio cio' che la segmentazione introduce. E' la terza forma della stessa trappola in una settimana, dopo l'annuncio Bonjour delle multifunzione e le destinazioni di scansione per nome NetBIOS, con la differenza che qui e' incorporata nella scelta del nome. Registrato come NET-014 (`GAP-TBC.md` #131) e come intervento R13 di migrazione, subordinato alla scelta del suffisso.

La scelta del suffisso e' quindi diventata il primo sotto-passo, e non e' una formalita'. Un suffisso di uso privato come `.lan`, gia' adottato per il portale della VM208, e' semplice e non collide con mDNS, ma non e' un nome di cui l'azienda sia titolare: nessuna autorita' di certificazione pubblica potra' emettere certificati per quei nomi, quindi i servizi interni in HTTPS continueranno a dipendere da una CA interna distribuita a mano — che e' il gap SEC-016. Un sottodominio del dominio pubblico aziendale, con i record pubblicati solo sul DNS interno, costa una riga di convenzione in piu' e in cambio non collidera' mai con nulla e rende ottenibile un certificato pubblicamente riconosciuto tramite validazione via record DNS, senza esporre il servizio su Internet: SEC-016 si chiuderebbe per intero invece che a meta'. Scelta compiuta dall'IT Manager: **il sottodominio del dominio aziendale**, nella forma `<host>.int.<dominio>`, con i record solo sul DNS interno del firewall e mai su quello pubblico. Razionale e vincoli in ADR-018. Due conseguenze da tenere insieme: il beneficio sui certificati non richiede alcun record di indirizzo pubblico ma richiede di poter creare un record di testo sulla zona pubblica del dominio presso il fornitore che la ospita, quindi va verificato quell'accesso prima di prometterselo; e i due nomi `.local` esistenti diventano un debito da migrare a questa convenzione, con il nome nuovo creato prima di rimuovere il vecchio.

La decisione ha anche fatto emergere un passo che non era nel piano. I client cablati ricevono il firewall come DNS e risolveranno i nomi nuovi senza interventi, ma la **Wi-Fi staff no**: il suo ambito DHCP, configurato il 16/07/2026, distribuisce due resolver pubblici, quindi un dispositivo staff non risolverebbe ne' il NAS ne' le stampanti ne' il portale interno. La nota che lo prevedeva era gia' scritta nella scheda firewall al momento della creazione di quell'ambito, ed e' ora diventata un sotto-passo: impostare il firewall come primo DNS di quel segmento, coerentemente con la postura di ADR-014 che tratta la Wi-Fi staff come una postazione cablata. Sulla rete ospiti invece non si tocca nulla, perche' e' corretto che un ospite non risolva i nomi interni. I client VPN ricevono gia' il firewall come DNS, quindi guadagnano la risoluzione dei nomi interni anche da remoto: e' un beneficio che nessun file `hosts` distribuito a mano ha mai garantito.

Procedura completa dei quattro sotto-passi, elenco dei nomi pienamente qualificati e verifiche in `docs/interventi-robustezza.md` §R12.

### Correzione di priorita' nella stessa giornata: R12 non era un prerequisito

Presentando il piano, R12 era stato messo in testa all'esecuzione e descritto come prerequisito degli altri interventi. L'IT Manager ha obiettato con una domanda semplice — perche' lo stiamo facendo, e cosa c'entra con la questione delle stampanti — e l'obiezione era fondata: **non c'entra**. Le destinazioni di scansione devono essere indirizzi in ogni caso, perche' le multifunzione non hanno alcun server DNS configurato e un nome non lo risolverebbero; e lo spostamento delle stampanti in un segmento dedicato si fa ri-puntando le code al nuovo indirizzo, come si e' sempre fatto qui.

C'e' un secondo elemento che rendeva la priorita' sbagliata e che era stato omesso: in questa azienda la pratica consolidata e' modificare il file `hosts` di ogni endpoint quando serve. Con quel punto di partenza il guadagno immediato di un record DNS e' nullo per un singolo spostamento, perche' la voce `hosts` costa lo stesso lavoro del ri-puntamento diretto; e un record DNS **non** sostituisce le voci esistenti, dato che il file locale ha precedenza, quindi per ottenere il beneficio bisognerebbe anche ripulirle su ogni postazione. Il lavoro non diminuisce, si sposta.

R12 resta valido ma indipendente, e le sue motivazioni vere sono altre tre, tutte estranee alle stampanti: chiudere la dipendenza dal broadcast che rendera' fragile la segmentazione, arrestare la proliferazione non inventariata delle voci `hosts`, e aprire la strada al certificato pubblico per il portale interno grazie alla convenzione di ADR-018. La sequenza corretta mette percio' al primo posto R8 con R9 e R10, cioe' le scansioni sul NAS, che sono il problema da cui tutto e' partito e non dipendono da nulla.

---

## 31/07-03/08/2026 - Scansioni sul NAS: intervento eseguito su tutte e sette le postazioni

Esecuzione manuale, una persona alla volta, del primo intervento del registro di robustezza: le destinazioni di scansione delle due multifunzione passano dalle cartelle condivise delle postazioni a sette condivisioni nascoste sul NAS-INTRA2, ciascuna permessa al solo destinatario e all'account di servizio.

Lato NAS l'impianto e' stato costruito e verificato prima di toccare gli apparati. L'account di servizio ha il **solo** privilegio di condivisione file Microsoft, con applicazioni e altri protocolli negati: il dialogo di creazione lo proponeva con accesso illimitato alle applicazioni e con lettura e scrittura su due cartelle estranee, e togliere quei valori predefiniti e' stato il primo lavoro. Il criterio password del NAS non prevede scadenza periodica, e questo e' il fatto che rende l'account **immune alla rotazione a trenta giorni** imposta dall'RMM sulle utenze locali di Windows: era la condizione su cui poggiava tutto il disegno, e ora e' verificata e non assunta. Le sette condivisioni sono nascoste dalla navigazione — accorgimento di ordine e non di sicurezza, dichiarato come tale — con accesso ospite negato. L'isolamento e' stato provato in campo, con l'utenza di un destinatario respinta sulla cartella di un altro, e la scrittura dell'account di servizio provata su tutte e sette.

Lato apparati sono state riconfigurate quattordici voci di rubrica, sette per macchina, di cui tre create da zero sul Piano Terra perche' quella rubrica conosceva solo quattro destinatari contro i sette dell'altra. Tutte usano la stessa credenziale di servizio e mai quella dell'utente: ne segue che l'isolamento tra persone lo garantiscono i permessi del NAS e non la stampante, con il rischio residuo dichiarato che chi sta al pannello puo' scegliere la destinazione di un altro — mitigato dalla conferma prima dell'invio, che si trova nello stesso dialogo e va spuntata nel passaggio.

Lato postazioni ogni utente ha un collegamento sul desktop verso la propria cartella, non un'unita' di rete mappata: le lettere su queste macchine sono scarse e gia' occupate, e un collegamento non si riconnette all'accesso ne' produce attese quando il NAS non risponde. La distribuzione avviene con uno script versionato che sceglie da se' se scrivere il percorso per indirizzo o per nome, perche' le credenziali di Windows sono memorizzate per forma della destinazione e su queste postazioni la pratica e' mista; e che rifiuta di creare il collegamento se l'utente connesso non accede davvero alla cartella, usando come controllo di correttezza la stessa asimmetria dei permessi che protegge i documenti.

Tre inciampi hanno insegnato piu' del percorso liscio. Il primo: lo script, lanciato con la condivisione di un'altra persona, creava obbediente il collegamento sbagliato — da cui la verifica di accesso preventiva. Il secondo: su una postazione l'accesso falliva nonostante i permessi corretti, e la causa non era ne' l'elevazione della sessione, prima ipotesi, ne' i permessi, verificati: la cassaforte credenziali di quell'utente era **vuota**, quindi Windows tentava l'accesso con l'utenza locale della macchina, che sul NAS non esiste. Il terzo, scoperto subito dopo: la memorizzazione da riga di comando vale **solo per la sessione corrente**, e lo dichiara lei stessa nell'elenco — un intervento che sembra riuscito il giorno in cui si fa e si rompe al primo riavvio, che e' il modo peggiore di sbagliare. La credenziale permanente si crea dall'interfaccia.

Stato: sette postazioni funzionanti. Restano due code, entrambe registrate: verificare che su ogni macchina la credenziale sia permanente e non di sessione, e **rimuovere le vecchie condivisioni di scansione dalle postazioni con le credenziali che le servivano** — ed e' quest'ultima che chiude SEC-020, non la creazione delle cartelle nuove, perche' finche' quelle condivisioni esistono il percorso e i segreti sono ancora li'.

---

## 31/07/2026 - Consegnato un gateway FXS per la fonia analogica dell'ascensore

Fatto rilevato il 03/08/2026 dal delta OneDrive, non da una comunicazione in sessione, e
verificato leggendo il documento di trasporto in
`IT + Administration - Documenti\MyOffice\Transizione centralino cloud 2026\DDT del gateway
FXS (ascensore)`.

myOffice ha consegnato un **Grandstream HT-812 v2**, adattatore telefonico analogico con due porte FXS e router NAT Gigabit, in un'unita' sola: trasporto datato 01/07/2026, ricevuta controfirmata il 31/07/2026. Importi e riferimenti dei documenti amministrativi restano fuori dai file tracciati.

L'apparato colma un vuoto tipico di questo genere di migrazione, e vale la pena nominarlo perche' e' il genere di dettaglio che si scopre a lavori iniziati: un centralino cloud parla SIP e non ha porte analogiche, mentre il telefono di emergenza di un ascensore e' un apparecchio analogico e un obbligo di sicurezza, non un interno negoziabile. Un adattatore che presenti una porta FXS al telefono e parli SIP verso il cloud e' quindi l'unico modo di portarlo sul nuovo impianto. **L'attribuzione all'ascensore viene dal nome della cartella e non da una fonte tecnica**: e' coerente ma va confermata con il fornitore, perche' nessun documento del progetto descrive finora il telefono dell'ascensore come endpoint di rete e la funzione dell'apparato potrebbe essere piu' ampia.

Tre questioni di rete restano aperte prima dell'installazione e sono registrate nella scheda di telefonia: su quale segmento si attesta l'apparato, se la sua funzione di router NAT va disabilitata — un secondo NAT interno e' causa classica di audio unidirezionale e, su una LAN piatta, un apparato che distribuisce indirizzi per conto proprio e' anche un rischio di conflitto DHCP — e come si colloca fisicamente rispetto al vano ascensore, che e' lo stesso tratto a cui era stato attribuito il primo sintomo di TEL-002. Va inoltre chiarito il rapporto con il Patton SmartNode 5551, che e' l'attuale gateway con porte FXS e FXO: se l'HT-812 ne assorbe una funzione, se lo sostituisce, o se convivono durante la transizione.

Dettaglio in `docs/telefono-pbx-voip.md` §Gateway FXS consegnato per il telefono dell'ascensore.

## 31/07/2026 - Preventivo per l'access point da esterno di M13c e per un UPS nuovo

Secondo fatto rilevato il 03/08/2026 dal triage del delta OneDrive rimasto arretrato dal 15/07, e non da una comunicazione in sessione: un preventivo di Punto Informatica datato 31/07/2026 propone due apparati, entrambi rilevanti per la rete e nessuno dei due finora censito. Ordine e consegna non confermati per nessuno dei due; importi e riferimenti dei documenti restano fuori dai file tracciati.

Il primo e' un **Zyxel WBE530-EU0101F**, access point da esterno Wi-Fi 7 tri-radio con PoE 802.3at, due porte LAN da 1/2,5 Gbps e gestione NebulaFlex Pro sulla stessa organizzazione Nebula degli switch. E' l'hardware che M13c cercava per sostituire l'ultimo access point Ubiquiti fuori supporto, quello che serve la centrale di irrigazione sul tetto. La sua comparsa dice pero' anche qualcosa che il progetto non aveva ancora scritto: la scelta fra sostituire l'apparato e eliminarlo cablando la centrale, che ADR-016 lasciava esplicitamente aperta con l'eliminazione come prima opzione da valutare, sta di fatto andando verso la sostituzione. Va formalizzata come decisione, con la sua ragione, invece di essere dedotta a posteriori da un documento commerciale.

Ne segue anche una promozione di priorita' che vale la pena spiegare, perche' e' un caso in cui l'ordine dei passi decide se si spendono bene dei soldi. La porta 4 del 30HP, quella del vecchio apparato, negozia a 100 Mbps mentre le porte delle postazioni dello stesso switch vanno a 1 Gbps, e il sotto-passo M13c-5 esisteva per chiarire se il limite fosse l'eta' dell'apparato o la tratta cablata verso il tetto. Finche' l'apparato candidato era ignoto la domanda era di igiene; ora che il candidato ha due porte da 2,5 Gbps, se il limite e' il cavo si acquista una capacita' che il collegamento non potra' mai portare. La verifica costa un portatile al posto del terminale e cinque minuti, e va fatta prima dell'ordine: M13c-5 e' stato quindi promosso ad ALTA. Da chiarire prima dell'ordine anche il grado di protezione contro acqua e polvere, che il preventivo non dichiara e che per un montaggio sul tetto e' il parametro che decide la durata.

Il secondo apparato e' un **UPS rack Addpower TP130N-1500**, line interactive da 1500 VA e 1350 W, convertibile tower/rack 19", otto prese IEC. Il documento non dice se sostituisca l'Emerson Liebert attuale o se lo affianchi. Il punto rilevante per la rete e' che la comunicazione di serie e' USB e seriale RS232, mentre la scheda SNMP Ethernet e' opzionale: prenderla significa avere un nuovo host di rete, da collocare direttamente nel segmento IoT/OT di M22c con la gestione restretta alle postazioni IT — cioe' l'occasione di non ripetere l'errore che UPS-001 documenta, un apparato di infrastruttura finito nella rete ospiti e rimasto li' per anni. Non prenderla significa rinunciare al monitoraggio in rete dell'alimentazione, che e' una perdita di capacita' e non un risparmio neutro, e va detto come tale perche' il piano di continuita' presuppone di sapere in che stato sia l'UPS. Da rifare in ogni caso il conto dell'autonomia sul carico reale, dato che i 116 minuti dichiarati dal produttore valgono su un carico da PC e monitor mentre il carico vero e' server, NAS e centralino.

Dettaglio in `docs/runbook-anomalie.md` §AP-001 (aggiornamento 03/08/2026) e §UPS-001 (aggiornamento 03/08/2026); sotto-passi in `.claude/context/roadmap.md` M13c-5 e M13c-6.

---

## 03/08/2026 - Il 54HP e' rientrato: censimento M22a chiuso, e quattro correzioni

Rieseguito lo snapshot Nebula, fermo al 27/07 da quando il 54HP aveva risposto `422 DEVICE_IS_OFFLINE` sulla tabella MAC lasciando il censimento a meta'. Questa volta **entrambi gli switch hanno risposto su tutto**: configurazione delle porte e tabella MAC di livello 2, per un totale di sessantanove voci sul 54HP e sessantatre sul 30HP. Il censimento di M22a si chiude quindi con la seconda meta' che mancava, e la lezione operativa e' quella gia' scritta il 27/07 e ora confermata: non serviva forzare nulla sull'apparato, e' rientrato da solo.

Un guasto nuovo, di natura diversa e da non confondere con NEB-001: l'endpoint best-effort della lista client (`sw-clients`) risponde ora `404 Not Found` su **entrambi** gli switch, mentre la tabella MAC di livello 2 arriva correttamente. NEB-001 e' un apparato fuori dal piano di gestione; questo e' uno schema di richiesta che l'API non accetta piu', quindi va trattato come manutenzione dello script e non come anomalia di rete. Non ha impatto sul censimento, perche' il dato che serviva viene dall'altro endpoint.

### La configurazione reale delle porte, e le liste che il design dava per aperte

Questo e' il risultato che cambia il piano di M22b. Il design partiva dalla convinzione, fondata sullo snapshot del 15/07, che ogni porta avesse `allowedVLAN: all` e che quindi una VLAN nuova attraversasse gia' tutti i collegamenti; il 23/07 quella nota era stata corretta per **una** porta, il trunk lato Piano Terra. La misura di oggi dice che le porte con lista esplicita sono **quattro**, e fra queste c'e' quella che conta piu' di tutte.

| Apparato e porta | Ruolo | PVID | VLAN ammesse |
|---|---|---|---|
| 54HP porta 33 | uplink verso il firewall | 1 | `1, 40, 90` |
| 54HP porta 41 | access point Piano 1 | 1 | `1, 40, 90` |
| 54HP porta 45 | access point Piano 2 | 1 | `1, 40, 90` |
| 54HP porta 51 | dorsale verso il Piano Terra | 1 | `all` |
| 30HP porta 1 | access point Piano Terra | 1 | `1, 40, 90` |
| 30HP porta 29 | dorsale verso il Piano 2 | 1 | `1, 2, 40, 90` |

La porta 33 e' l'uplink a 1 Gbps verso il firewall, e ammette `1, 40, 90` ma **non la VLAN 2**: e' architetturalmente corretto, perche' la fonia non passa dal firewall per progetto, ed e' la prima volta che quel fatto viene misurato invece che dedotto. Ma ne segue un prerequisito di M22b che il documento di design non elencava: **la VLAN 30 delle stampanti va aggiunta anche alla porta 33**, altrimenti il segmento nuovo esiste sullo switch, i pacchetti arrivano fino al 54HP e poi non raggiungono mai il gateway sul firewall. Un segmento senza gateway non e' un segmento isolato, e' un segmento morto, e il sintomo si presenterebbe come "le stampanti non rispondono piu'" a intervento apparentemente riuscito. Le porte da toccare per M22b sono quindi due: la 29 del 30HP e la **33** del 54HP.

### Quattro correzioni alla documentazione

La prima riguarda la porta 1 del 30HP, quella dell'access point del Piano Terra: la voce del 27/07 la descriveva come trunk con VLAN 1 e 40. Porta invece **1, 40 e 90**, e non e' un dettaglio, perche' la 90 e' esattamente cio' che serve all'SSID ospiti del multi-SSID. La descrizione precedente era incompleta, non sbagliata, ma incompleta in un modo che avrebbe fatto sospettare un difetto dove non c'e'.

La seconda e' che le tre porte dei tre access point nuovi — la 1 del 30HP e la 41 e 45 del 54HP — hanno **configurazione identica**, trunk con `1, 40, 90`. Il progetto non lo aveva mai scritto: e' la conferma che la sostituzione di Fase B e' stata fatta in modo uniforme e che la postura di ADR-014 e' applicata allo stesso modo sui tre punti radio.

La terza chiude una contraddizione aperta dal 01/07/2026 (M10, GAP-TBC #67 e #99). Le posizioni dei cinque telefoni IP risultano, dalla tabella MAC, **tre sul Piano 2** alle porte 3, 5 e 44 e **due sul Piano Terra** alle porte 13 e 23, tutte e cinque sulla VLAN 2. La documentazione sosteneva il contrario, tre apparecchi al Piano Terra e due al Piano 2, e trattava l'etichetta "SIP-T34W" sulla porta 3 del 54HP come probabile errore di etichettatura. **Non era un errore**: sul Piano 2 c'e' davvero un terzo apparecchio, ed e' la distribuzione documentata a essere sbagliata. Corroborato in modo indipendente dal piano di numerazione ingerito oggi, che conta esattamente cinque interni di tipo IP. M10 si chiude.

La quarta e' un dettaglio che vale per la fonia: la porta 8 del 54HP mostra tre indirizzi sulla VLAN 2, uno dei quali e' un **MAC virtuale VRRP**. Conferma diretta di quanto ipotizzato il 23/07, cioe' che il gateway della fonia di Vianova lavora in ridondanza, e spiega perche' nella tabella del Piano Terra quel MAC compaia attraverso la dorsale.

### Due difetti nuovi e una osservazione fisica

Il primo difetto e' una porta in uno stato incoerente: la **porta 21 del 30HP** ha PVID 1 e `allowedVLAN` uguale a `2`, cioe' ammette solo la VLAN 2 taggata mentre consegna il traffico non taggato sulla VLAN 1, che nella lista non c'e'. E' il residuo della configurazione Voice VLAN del 29/05, quando quella porta ospitava un telefono. Oggi e' senza link, quindi non c'e' impatto in atto, ma chi vi collegasse un portatile non avrebbe rete e la causa sarebbe tutt'altro che evidente dal sintomo. E' la stessa famiglia della porta 19 rimasta su PVID 90 (intervento R5): prese a muro in uno stato che nessuno ha voluto. Tracciato come **NET-015**, da chiudere insieme a R5 con lo stesso giro.

Il secondo e' minore ma della stessa natura: la **porta 30 del 30HP**, il secondo slot SFP+ oggi non usato, ammette la sola VLAN 1. Se un giorno vi si attestasse un secondo collegamento fra i piani, scarterebbe tutte le VLAN taggate e il guasto somiglierebbe a quello di TEL-002. Non e' un difetto in atto, e' una trappola per il futuro, e costa una riga sistemarla quando si tocchera' la porta 29.

L'osservazione fisica riguarda tre porte che negoziano a **10 Mbps** su switch gigabit: la 5 e la 22 del 30HP e la 25 del 54HP. Su hardware di questa classe un collegamento a 10 Mbps e' quasi sempre un cavo danneggiato, una coppia interrotta o un apparato molto vecchio, non una scelta. Va identificato cosa c'e' collegato prima di attribuirlo all'eta' dell'apparato, perche' se sono cavi vale la pena sistemarli mentre si mette mano al cablaggio per M22. Registrato come **NET-016**.

Sulla porta 4 del 30HP, quella che porta al tetto, la misura conferma il link a 100 Mbps e mostra **quattro indirizzi appresi**, uno dei quali e' un MAC di tipo localmente amministrato, cioe' la forma tipica di un indirizzo randomizzato.

**Correzione dello stesso giorno, e vale la pena spiegare l'errore invece di limarlo.** La prima lettura di questo dato, scritta poche ore prima, diceva che il quadro era "coerente con un access point ancora in servizio e con client agganciati". E' una spiegazione che regge, ma non era l'unica e nemmeno la piu' probabile: **quattro indirizzi dietro una sola porta sono la firma di uno switch**, non necessariamente di un access point con clienti. L'IT Manager ha poi dichiarato che dietro quella porta, prima della centrale di irrigazione, esiste effettivamente **un apparato di commutazione**, installato in una sessione di lavoro precedente e mai documentato in questo repository. La misura conteneva quindi l'impronta di un dispositivo che il progetto non conosceva, e l'ipotesi scelta era quella che confermava il modello esistente invece di metterlo in dubbio. Registrato come NET-017.

Il fatto ha una conseguenza diretta e sfavorevole su M13c, ed e' meglio saperla adesso: se la porta 4 alimenta uno switch e non direttamente l'access point, la negoziazione a 100 Mbps potrebbe essere l'uplink di quello switch, e in quel caso **sostituire l'access point non rimuove il collo di bottiglia**, perche' il limite vive un salto prima. Il sotto-passo M13c-5, promosso ad ALTA il 03/08 proprio per misurare quella tratta, cambia quindi domanda: non "e' il cavo o l'apparato vecchio" ma "che cosa c'e' fra la porta 4 e la centrale, e quale dei tre elementi impone i 100 Mbps".

Tutti i MAC e gli indirizzi reali di questa ricognizione restano fuori da questo file per policy di anonimizzazione: vivono nello snapshot in `output/`, ignorato da git, e la mappatura in `_notes/.anonymization-map.md`.

### Telefoni: la parte di rete e' chiusa su tutti e cinque

Correzione arrivata dall'IT Manager nella stessa giornata e poi corroborata dalla misura. Tutti e cinque i Yealink sono collegati e **ciascuno sta su una porta che prende correttamente la VLAN della fonia**; il lavoro e' stato completato in sessioni di lavoro precedenti, non tutte tracciate in questo repository. La tabella MAC concorda, perche' i cinque indirizzi compaiono tutti sulla VLAN 2.

La descrizione che questo progetto portava — "i due apparecchi del Piano Terra hanno la parte di rete risolta ma non ottengono un lease dal DHCP" — era una fotografia corretta al 23/07 che ha smesso di esserlo senza che nulla la contraddicesse. E' il tipo di obsolescenza silenziosa che il protocollo delle fonti (`.claude/rules/fonti-e-riallineamento.md`) esiste per intercettare: non un errore, un'affermazione giusta che nessuno aveva piu' verificato. Resta da confermare il solo livello applicativo, cioe' che ogni apparecchio si registri e chiami, verificabile dal display che mostra l'interno. Dettaglio in `runbook-anomalie.md` §TEL-002.

---

## 03-04/08/2026 - La catena WAN ricostruita: tre percorsi Internet, e il ponte radio non tocca il firewall

L'IT Manager ha scaricato il `startup-config.conf` del firewall e descritto la catena fisica del rack di sinistra del Piano 2. Le due fonti insieme chiudono una domanda che questo progetto portava aperta da luglio e ne correggono una risposta che era sbagliata.

Il file di configurazione resta in `_notes/`, non versionato: contiene utenze VPN nominative, chiavi pre-condivise dei tunnel IPsec e community SNMP. Da qui si riportano solo fatti di topologia, con gli indirizzi nel modello documentale.

### La catena, dall'antenna al firewall

Dall'antenna sul tetto un cavo scende a un iniettore PoE, che entra nella porta ETH10 di una router board **Mikrotik RB2011UiAS-RM**; dalla ETH1, che e' PoE, si va alla porta 1 del primo router **Vianova R-1000**, la cui porta 2 raggiunge la porta 1 di un **secondo R-1000**, che sulla propria porta xDSL porta una **linea VDSL**. Entrambi i router sono attestati sulle porte 7 e 8 dello switch **Vianova S-1000**, che sdoppia la consegna: la porta 4 va alla P2 del firewall, che e' `wan1`, e la porta 1 va alla porta 8 dello switch XGS2220-54HP.

### Tre fatti nuovi, di cui uno corregge una nostra affermazione ripetuta

**I percorsi verso Internet sono tre e non due.** Fibra come primario, ponte radio come primo backup, linea VDSL come secondo. La VDSL non compariva in nessun documento del progetto.

**Il ponte radio non tocca il firewall, e `wan2` non e' il ponte radio.** Il failover vive interamente dentro gli apparati del fornitore, che consegnano al firewall una sola porta dati. L'interfaccia `wan2` sulla P3 ha indirizzo e gateway configurati verso la **linea TIM dismessa** e non ha alcuno `shutdown`: e' un residuo, non un backup. Questa scheda e il diagramma di rete sostenevano il contrario da settimane, e l'errore era nostro e non del dispositivo — la scheda del firewall riportava correttamente `P3 = wan2` mentre il diagramma ASCII diceva `P2 = wan2`, e nessuno aveva riconciliato le due.

**La porta 8 del 54HP si spiega, ed e' la fonia.** Lo S-1000 manda i dati al firewall e la voce alla porta 8 dello switch, che la smista sulla VLAN 2. E' la ragione del PVID 2 su quella porta, del MAC virtuale VRRP dei router del fornitore che vi compare nella tabella MAC, e del fatto che la LAN telefonica non passi dal firewall per progetto (FW-012). Il traffico dati rientra invece come LAN e raggiunge il firewall dalla porta 33.

### Cosa il file di configurazione ha aggiunto per conto proprio

Quattro **indirizzi pubblici aggiuntivi** sono definiti sull'interfaccia `wan1` e sono tutti spenti. Non e' un difetto ma una risorsa: il micro-step M9 prevede di pubblicare la prima macchina in DMZ su un indirizzo pubblico, e quell'indirizzo esiste gia' configurato, quindi l'intervento e' riattivarne uno invece di richiederlo al fornitore.

Le **tabelle dei record DNS sono vuote**, con due soli inoltri verso resolver pubblici. Corregge quanto scritto il 30/07, cioe' che il firewall ospitasse gia' record interni: quella deduzione nasceva da una risposta con suffisso `.local` ottenuta interrogando il resolver, e la configurazione dimostra che la risposta non veniva dal firewall ma dal client, che risolve `.local` in multicast per conto proprio. L'intervento R12 crea quindi i primi record e non si innesta su una zona esistente, e il difetto di NET-014 e' piu' netto di come era descritto: i due nomi `.local` non sono pubblicati da nessuna parte, esistono solo come annuncio multicast.

La zona **DMZ ha un proprio ambito DHCP** da duecento indirizzi, mentre il piano del 05/06 prevedeva la DMZ senza pool. Da decidere prima di M4-M9 e non dopo, perche' in una DMZ gli host pubblicati vogliono indirizzi statici o riservati: le regole di NAT e le policy li referenziano, e un pool dinamico le rende fragili.

Confermata infine la corrispondenza fisica del port-grouping riga per riga, con una differenza rispetto a quanto la scheda riportava: la porta 8 del firewall appartiene al gruppo `reserved` e non a `guest`, e il gruppo `guest` non ha **alcuna** porta assegnata. L'interfaccia `guest` residua di FW-013 e' quindi configurazione viva e inerte insieme — ha un ambito DHCP attivo su una `/24` di blocco estraneo, ma nessuno puo' raggiungerla perche' non ha porte. Il rischio resta interpretativo, con l'aggravante che un cavo collegato un giorno la riattiverebbe.

### Due apparati non censiti, e la lezione che si ripete

Il Mikrotik e l'iniettore PoE non erano in nessun documento (NET-018, #137). Dell'iniettore l'IT Manager ha confermato il 04/08 che e' sotto il gruppo di continuita', quindi un'assenza di rete elettrica non spegne il backup radio: la domanda si chiude in positivo. Del Mikrotik non si conosce proprieta', amministratore ne' credenziali, e sta sul percorso del backup di linea — un apparato in cui nessuno riesce a entrare, posizionato li', si scopre inaccessibile nel momento in cui la linea primaria e' giu'. E' esattamente lo schema di AP-001, dove quattro access point sono rimasti inaccessibili per anni finche' non e' servito toccarli. Tracciato come intervento R17, con il vincolo di chiedere al fornitore e **non** tentare accessi a tentativi su un apparato in produzione sul backup.

### Interventi resi tracciabili nella stessa giornata

Su indicazione dell'IT Manager, che ha chiesto che ogni intervento identificato risulti tracciato e non resti un dettaglio dentro un gap, sono state aggiunte quattro voci al registro dei micro-interventi — R15 la porta 21 incoerente, R16 la ricognizione delle tre porte a 10 Mbps, R17 il Mikrotik, R18 il censimento dell'inverter fotovoltaico — ed e' stato esplicitato il contenuto di M7, che ora nomina una per una le rimozioni previste sul firewall, compreso lo **spegnimento di `wan2`**, invece di riassumerle in una parentesi.

## 13/07/2026 - VM207: dimensionamento corretto, e l'enigma anagrafico si spiega

Voce ricostruita il 03/08/2026 da due documenti di handoff prodotti in una sessione di lavoro diversa da questa e datati 13/07/2026. Erano invisibili al controllo del delta perche' si trovano dentro una cartella che la lista di esclusione scartava come mirror di siti esterni: l'esclusione era corretta quando fu scritta e ha smesso di esserlo quando quella cartella e' stata riusata per altro. Il difetto e' stato corretto nello script, non aggirato a mano.

La VM207, che questo progetto documenta come asset di rete per il servizio di estrazione di contenuti che espone sulla LAN, e' stata **ridimensionata** prima del primo avvio: memoria da 8 a 16 GiB con ballooning disattivato per garantirla, processori da 4 a 6 core con tipo CPU portato a `host`, controller da LSI a VirtIO SCSI single, e soprattutto l'aggiunta di un **secondo disco da 96 GB dedicato ai dati**, separato dai 32 GB di sistema, per isolare l'archivio crescente delle estrazioni. Rete su bridge `vmbr3`, storage `SERVIZI` confermato LVM-thin, discard attivo su entrambi i dischi. Primo avvio eseguito e riuscito il 13/07/2026.

Il fatto che interessa la rete non e' il dimensionamento in se' ma la sua somma: sedici GiB garantiti senza ballooning e sei core sono capacita' sottratta in modo permanente al nodo, e vanno tenuti presenti quando si valuta se il nodo regge i carichi futuri. Il resto e' progetto applicativo e resta nel suo repository, secondo il perimetro di ADR-015.

**L'enigma anagrafico si chiude.** La ricognizione del 27/07 aveva registrato una contraddizione non spiegata: la VM207 era documentata come nuova al 13/07/2026 mentre il metadato di creazione della sua configurazione la datava all'08/02/2025, e la conclusione provvisoria era "nuova alla documentazione, non all'infrastruttura". La spiegazione e' nel handoff: la VM e' un **clone di un template** con il sistema operativo gia' installato, quindi porta con se' la data del proprio progenitore. Non c'era nessuna incoerenza da sanare.

Restano due voci hardware che al 13/07 erano dichiarate da applicare e il cui stato non e' noto: `cache = No cache` e `IO thread` su entrambi i dischi. Vanno verificate alla prossima lettura del nodo, perche' incidono su prestazioni e integrita' e non sull'esposizione di rete.
