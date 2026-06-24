# Helpdesk Operations – Intrawelt S.a.s.

Procedure operative helpdesk IT. Owner: Alessio Sopranzi.
Aggiornato: giugno 2026.

---

## T-Rex (Odoo ERP Gestionale)

### Cos'è T-Rex

T-Rex è il gestionale di project management e workflow traduzioni di Intrawelt,
basato su **Odoo** e ospitato da **OpenForce** (partner Odoo).

Accesso: via browser (URL produzione gestito da OpenForce).  
Ambiente di test: disponibile (URL separato).  
Chat interna: "T-Rex | All PM" su Microsoft Teams.

**Egetrad**: vecchio gestionale precedente (usato fino al 2021). Ora solo archivio statico.
VM Ubuntu su Proxmox (192.168.20.5), porta 8080 pubblica e privata.
Regola firewall `EGETRAD_WEB` da disabilitare quando dismessa definitivamente (task_27).

### Apertura ticket con OpenForce

OpenForce è il fornitore di supporto Odoo/T-Rex.

1. Inviare mail a `intrawelt@openforce.it` con oggetto = breve descrizione problema
2. OpenForce crea un ticket dal messaggio (con pre-validazione)
3. Risposta arriva da `portal@openforce.it` – rispondere su quella stessa mail
4. Le risposte via mail vengono registrate nel portale front-end Odoo
5. Per ticket specifici fatturazione: mettere in CC il referente OpenForce dedicato

**Note operative:**
- OpenForce lavora sullo stesso sistema Odoo che usiamo: i ticket sono visibili come "opportunità" nel front-end
- Le mail inviate a portal vengono registrate sul chatter (visibile a tutti i follower del ticket)
- Non usare portal@openforce.it per comunicazioni generali: solo per rispondere a ticket aperti

### Migrazione T-Rex (task_3, task_82)

| Campo | Dettaglio |
|-------|-----------|
| Stato | Bloccata, 0% – PRIORITY 1 |
| Stima | 120h di supporto tecnico verso OpenForce |
| Scopo | Migrazione gestionale a nuova versione o nuova architettura |
| Dipendenza | Completare formazione T-Rex (task_1), allineamento test/prod (task_92) |
| GroupShare migration | Separata: target primavera 2026 (task_82, 20h) |

### T-Rex – Sblocco ricezione mail IMAP (procedura periodica)

Fonte: `Helpdesk_T-Rex/Mancata Ricezione Mail Gestionale TRex_Odoo.docx`

Il server IMAP di T-Rex perde periodicamente la connessione alle caselle di posta in arrivo.
Sintomo: mail non ricevute nel gestionale nonostante arrivino nelle caselle Outlook.

**Procedura sblocco (ripetibile manualmente):**

1. Aprire browser in modalità **Incognito**.
2. Accedere a T-Rex con account admin: `tvezeni@intrawelt.com` (o altro admin).
3. Navigare a: `https://intrawelt.openforce.it/web?debug=1#menu_id=107&action=121`
   → ri-autenticarsi con le stesse credenziali.
4. Andare su **Ricezione → Edit Settings**.
5. Inserire credenziali server IMAP della casella principale (`trex@intrawelt.com` /
   `[redacted]`) → cliccare **Preleva Ora**.
6. Aprire nuova finestra incognito con:
   `https://intrawelt.openforce.it/web?debug=1#id=2&action=121&model=fetchmail.server&view_type=form&menu_id=`
7. Ri-autenticarsi (tvezeni@intrawelt.com) → **Edit Settings** casella opportunità
   (`opportunita@intrawelt.com` / `[redacted]`) → **Preleva Ora**.

Entrambe le caselle di posta in arrivo risultano sbloccate. Causa profonda: bug noto
Odoo/OpenForce; non è stata identificata una soluzione strutturale permanente.

### T-Rex – CSRF Token invalido e batch upload fallito (procedura pulizia sessione)

Fonte: `Helpdesk_T-Rex/Problema CSRF Token T_Rex.docx`  
Incidente: **19/02/2026** — Chiara Ippoliti segnala a Tommaso Vezeni.

**Sintomi:**
- Batch upload file XML analisi bloccato (caricamento infinito)
- Alert "Session expired (invalid CSRF token)" in vista preventivi
- Problema limitato a una singola postazione; stampa preventivi fallisce se eseguita
  subito dopo altra stampa

**Causa:** sessione utente Odoo corrotta (sessioni duplicate/scadute, service worker
obsoleto) → CSRF token invalidato → richieste POST batch non autorizzate.
Il caricamento singolo funziona perché non genera richieste simultanee/sequenziali ravvicinate.

**Procedura risoluzione:**

1. **Chiudi tutte le tab T-Rex** (Odoo usa sessioni persistenti: tab datate sovrascrivono
   token recenti). Logout completo (in alto a destra → "Esci").
2. Chiudi completamente il browser (inclusi processi in background).
3. **Pulizia cookie/cache sito specifico:** navigare a `https://trex.intrawelt.com/`,
   click sull'icona lucchetto nella barra → "Impostazioni sito" → "Elimina dati"
   (rimuove solo cookie/cache di quel dominio).
4. **Pulizia avanzata DevTools:** F12 → scheda "Application" → "Storage" → "Clear site data".
5. **Flush DNS:** aprire prompt comandi come Amministratore → `ipconfig /flushdns`.

**Risultato:** al primo accesso successivo Odoo ricostruisce sessione, token CSRF validi,
cache JS e service worker. L'utente deve reinserire le proprie credenziali.

---

## Microsoft 365

### Accesso admin

Portal M365: `https://admin.cloud.microsoft/#/homepage`  
Account admin: asopranzi@intrawelt.com (MFA obbligatorio dal 01/10/2025)  
Entra ID admin: `https://entra.microsoft.com`

**Tenant**: intrawelt.com  
**Exchange**: Exchange Online (cloud, non on-premise)  
**SharePoint gruppi**: IT, Sito del team, Projects, Resources

### Apertura ticket Microsoft

1. Da `admin.cloud.microsoft` → Supporto → Nuova richiesta di servizio
2. Per Azure: canale separato tramite portale Azure (non l'admin M365)
3. Cronologia ticket: `admin.cloud.microsoft → Home → Cronologia richiesta di servizio`

**Caso precedente**: ticket #2411131420003269 (nov 2024) – fattura Azure non visibile nel portale M365;
il caso è passato a Microsoft Azure team dopo chiamata del 14/11/2024.

### SharePoint e OneDrive

| Gruppo | Contenuto |
|--------|-----------|
| IT | Documenti IT, appunti procedurali, eredità documentazione Pasquale |
| Projects | Memorie di traduzione TM + MultiTerm (link OneDrive locale) |
| Resources | Strumenti condivisi (TOOLS folder sincronizzato su OneDrive locale) |

Percorso locale sincronizzato: `C:\Users\Alessio Sopranzi\OneDrive - Intrawelt S.a.s\Documenti – IT`

### Gestione caselle posta (Exchange Online)

| Attività | Stato | Note |
|----------|-------|------|
| Pulizia cassette postali utenti | In corso (0%) | Analisi spazio per utente in progress |
| Retention policy | Da definire | Piano Exchange 2: 100GB primary + 1.5TB archive con espansione auto |
| Backup .pst su NAS | Pianificato | Dipende da task_61 (backup posta) |
| Aggiornamento deleghe | Da fare | File 2025-09-01_Aggiornamento_caselle_posta.xlsx su SharePoint |
| Licenze e account | Da fare | Pulizia licenze non necessarie (task_62) |
| Phishing analisi | Da fare | Tracciamento mail sospette (caso Alessia Nasini maggio 2025) |

### Account utenti dimessi

**Pasquale e Giordano** (task_34): Mail chiuse da Microsoft in settembre 2025.
Cleanup dettagliato pendente (molti servizi/account terzi associati alle loro mail).
File di analisi: `mail_pasquale_giordano_analisi 23042025.xlsx`.
Esempio da gestire: Heroku richiede pass attraverso le loro mail.

**Francesca**: Cartella OneDrive allineata dopo uscita (task_91, completata entro 08/09/2025).
Flussi SCENIA/Trados che dipendevano dal suo account: da ripristinare (task_97).

### Azure MFA (task_65)

- Deadline: 01/10/2025 – completata (enforcement Microsoft attivo)
- Account coinvolti: asopranzi, anasini, tvezeni, atrovato
- Documentazione: docs/cybersecurity-governance.md + _notes/.tmp-docx-HELPDESK/mfa_action_plan.txt

---

## RWS GroupShare e Trados Studio

### GroupShare

Server: WINGROUPSHARE (IP LAN: 10.1.116.3, sotto Seeweb firewall cloud)  
VM parallela: WINSRV2019 (IP LAN: 10.1.116.4, sotto Seeweb firewall cloud)  
Accesso remoto: VPN RemoteAccess_Wiz (IKEv2) o SSL VPN → poi RDP/browser

**Problemi storici documentati:**
- Post-migrazione provider (TIM → Vianova): GroupShare inaccessibile fino a risoluzione ticket Seeweb. Causa: cambio configurazione LAN/WAN non replicata correttamente (task_9).
- Ticket Seeweb ha portato via tempo significativo prima di risoluzione.

**Migrazione GroupShare (task_82):**
- Target: primavera 2026 (potenzialmente già in ritardo a giugno 2026)
- Stima: 20h – PRIORITY 2
- Operazione "molto impegnativa" secondo nota nel piano attività

### Trados Studio

**Problemi tipici:**
- Disconnessione licenze: solitamente non è un problema server (vedi caso Tommaso Duranti 07/04/2025)
- Repair licenza: procedura documentata in Helpdesk_RWS-Groupshare-Studio/STUDIO-RWS-GROUPSHARE.docx
- Time licenza: 8h stima per troubleshooting (task_71)

---

## Timbracartellini (BioStar)

| Campo | Dettaglio |
|-------|-----------|
| Sistema | BioStar (lettore impronte digitali) |
| Dispositivo | 192.168.20.199 (switch Piano Terra, port 0-10-1) |
| VLAN | LAN utenti (VLAN 20) |
| Tempo speso | ~1 mese netto nei 2 anni (task_83) |
| Tipo attività | Varie problematiche hardware/software, gestione badge |

---

## Onboarding / Outboarding

**Procedura completa:** `_notes/.tmp-docx-HELPDESK/onboarding_outboarding.txt`

### Onboarding nuovo dipendente

1. Creare account M365: `ncognome@intrawelt.com` (es. tvezeni@intrawelt.com)
2. Password casuale, licenza "Microsoft Power Automate Free" (o equivalente base)
3. SharePoint: Projects → Documents → INTERSCAMBIO → crea cartella Nome_Cognome
4. Collegare cartella SharePoint su OneDrive del dipendente (Add Shortcut)
5. Account T-Rex (se PM)
6. Account GroupShare/Trados Studio (se traduttore/PM)
7. NinjaOne: agent su macchina
8. Registrare in registro onboarding (Mantis/ticket interno)

**Caso esempio (Greta Cavalieri, 14/11/2024):**
- Ticket Mantis #1428, aperto 13/11/2024 da Alessia Nasini
- Postazione preparata (PC), account M365 creato, Trados Studio installato

### Outboarding

1. Disabilitare account M365 immediatamente
2. Cambiare tutte le password dei servizi condivisi associati
3. Revocare accessi NAS, GroupShare, T-Rex, NinjaOne
4. Valutare delega casella mail (con tracciamento IT)
5. Aggiornare registro deleghe mail (2025-09-01_Aggiornamento_caselle_posta.xlsx)
6. Per dipendenti con accesso a servizi terzi (es. Heroku): procedura specifica per ogni servizio

---

## NinjaOne RMM

| Funzione | Dettaglio |
|----------|-----------|
| Monitoring | Tutte le postazioni Windows |
| Remote access | Accesso remoto controllato alle macchine |
| Patch management | Aggiornamenti software (da completare – task_14) |
| Alert | Da configurare su Teams (documentazione ufficiale disponibile – task_112) |
| Inventario | Monitoraggio periodico hardware (task_111) |
| Backup cloud | In valutazione (task_113) |
| Accessi | Da definire chi ha accesso a cosa (task_114) |
| Notifiche Telegram | Da configurare (task_43) |

**Attività helpdesk quotidiane NinjaOne:**
- Monitoraggio macchine (task_77)
- Troubleshooting patch/update
- Installazione software da remoto
- Supporto utenti (task_73)

---

## Helpdesk quotidiano

| Tipo attività | Frequenza | Note |
|---------------|-----------|------|
| Troubleshooting vario | Quotidiano | Stampe, scanner, programmi, postazioni (task_73) |
| Supporto connessione VPN | Su richiesta | Guida utente disponibile (BREVE GUIDA VPN) |
| Ticket verso Microsoft/Seeweb | Su richiesta | Worst case: 3 mesi/4h settimana (ticket AWS) |
| Compilazione questionari clienti | Occasionale | Solo Fidelity ha richiesto >20h (task_74) |
| Manutenzione hardware | Occasionale | task_69 |
| Web scraping preventivi | Occasionale | task_70 |
| Gestione turni Teams | 2x/anno | Inserimento turni pianificazione |

---

## Infrastruttura Seeweb e GroupShare – problemi noti

**Ticket Amazon AWS** (task_51): ha impegnato 3 mesi consecutivi a 4h/settimana default.  
**Ticket Seeweb** (task_9): dopo migrazione TIM → Vianova, GroupShare (10.1.116.3) non raggiungibile.
Risoluzione: Seeweb ha replicato la configurazione LAN che Alessio aveva già configurato manualmente.
Documentata in note SYSADMIN del piano attività.

---

## IntraLino – Assistente IT Interno (RAG Chatbot)

IntraLino è l'assistente virtuale IT di Intrawelt. È un chatbot RAG addestrato sui documenti
tecnici IT interni (la stessa `Documenti - IT` folder che stiamo ingestionando).

**Caratteristiche:**
- Nome: IntraLino, "assistente IT personale targato Intrawelt"
- Funzione: risolvere problemi IT comuni, guide passo-passo, escalation al team IT se necessario
- Training: documenti tecnici IT Intrawelt (errori comuni, procedure, policy, VPN, stampanti, Outlook, password)
- Admin mode: se loggato come admin, fornisce soluzioni complete senza suggerire escalation
- Architettura: RAG (Retrieval-Augmented Generation) su Qdrant/Zep (Zep abbandonato mar 2026)
- Stato: avviato fine 2024 con UNIMC/VRAI Lab; Zep abbandonato 25/03/2026; architettura attuale TBC

**Knowledge base:** profilo addestramento (`IntraLino_profilo_addestramento.docx`):
IntraLino sa rispondere su: errori Outlook, connessione VPN aziendale, stampante, reset password,
problemi comuni IT aziendali. Non accede direttamente al PC utente, non modifica configurazioni avanzate.

**Gap:** migrazione RAG post-Zep non documentata in dettaglio (stack attuale da confermare).

---

## ENI Servizi (ENIVIPA) – Procedura fatturazione mensile

### Cos'è

ENI Servizi è un ufficio ENI che commissiona traduzioni a Intrawelt. A fine mese invia un
file `.xls` con il riepilogo degli ordini del periodo → Intrawelt genera il report corretto
tramite IntraPanel e lo resubmits con eventuali correzioni → poi fattura.

### IntraPanel – App React/Flask (PC-GIORDANO)

**RISCHIO CRITICO**: L'app è installata su `PC-GIORDANO` (account Giordano, ex-dipendente).
Giordano è uscito dall'azienda; l'app non ha mai sido migrata. Stato: presumibilmente ancora
accessibile ma non presidiata. Backlog: task_27 (manutenzione app). Da migrare urgentemente.

| Componente | Dettaglio |
|------------|-----------|
| Frontend | React, `npm start`, porta localhost:3000 |
| Backend | Flask (`flask_service.py`), progetto `odoo_service` su PyCharm |
| IDE necessario | VsCode (frontend) + PyCharm (backend), su PC-GIORDANO |
| Output | Report `.xlsx` con foglio "Control" aggiunto al file ENI originale |
| Storico report | Desktop PC-Tommaso → cartella "Report Eni" |

**Procedura mensile:**
1. ENI invia file `.xls` ogni primo del mese → convertire in `.xlsx`
2. Aprire VsCode: `cd frontend` → `cd` → `npm start`
3. Aprire PyCharm: eseguire `flask_service.py`
4. Caricare `.xlsx` su localhost:3000 → "Update Report" → attendere
5. Scaricare report aggiornato e inviarlo ad ENI tramite PM

**Check nel foglio "Control":**
- Colonna I: check transito (lingua di transito coincide?)
- Colonna X: check urgenza (discrepanza tra ENI e TREX?)
- Colonna AG: VERO = importo totale diverso dal nostro in TREX → da sistemare

**Flusso di validazione:**
Alessia confronta file intermedio vs TREX (export xlsx ordini per ID) → segnala discrepanze
a ENI → ENI valida → Intrawelt fattura. Attenzione: export TREX mostra solo pagina attiva
(es. 80/114 invece di 114/114 → usare paginazione o export completo).

### Procedura VIPA – Inserimento richieste in T-Rex (Wizard)

Fonte: `Helpdesk_T-Rex/Storico ticket/2022-11-23_EniVipa/ENI_VIPA_Guida_inserimento_SO.docx`

1. App Vendite → **Create request service** → form dedicato per ruolini VIPA
2. Caricare file `.xls` (ruolini) + file `.docx` associato per ogni ruolino
3. **Verify request files** → riepilogo dati ruolino → **Send**
4. `Services Request Customer`: richieste in stato **Draft** (azzurro)
5. Filtrare/raggruppare per lingua source, lingua target, richiedente
6. Selezionare gruppo richieste → **Generate SO** → caricare analisi XML Trados Studio → **Create SO**
7. Verificare dati SO: Cliente = Eniservizi S.p.A., Richiedente (match anagrafica), Riferimento cliente = N° richiesta ruolino
8. Aggiungere riga Imposta di bollo 16€ se richiesta asseverazione (quantità = 0, valorizzata a consegna)
9. **Conferma** SO → stato Ordine di Vendita → progetto creato automaticamente
10. Assegnare task interni/esterni direttamente (NO Suggested Freelance per VIPA)
    - Task traduzione: dati tecnici già inseriti dall'XML Trados
    - Task asseverazione/legalizzazione (Doubinina, Mansour): UdM = 1 Documento per listino fornitore
11. Fine mese: creazione PO per rendicontazione traduttori

**Nota:** se il Richiedente non è in anagrafica, crearlo come nuovo contatto e associarlo a Eniservizi S.p.A.
Il campo Nome Progetto duplicato per stessa persona in più ruolini → fix in sviluppo (aggiunge tipo documento).

---

## Odoo 18 – Scope migrazione T-Rex (task_3)

Analisi flussi condotta con Openforce (novembre 2025). Moduli da migrare da Odoo 12 a Odoo 18:

| Modulo | Flusso/attività principale |
|--------|---------------------------|
| CRM e Sales | Lead → Opportunità → Preventivo → Ordine; permessi commerciali; reportistica periodo |
| Prodotti/Servizi | Tabelle lingue, settori, UM; listini vendita e fornitore |
| Task | Classificazione tags; gestione vincoli; dati tecnici; assegnazione freelance per skill |
| Acquisti/PO | Attributi su righe; nuovo calcolo listini; fatturazione passiva |
| Project | Fasi per creazione PO e fatturazione; forecast; multi-project-manager |
| Risorse umane | Profilo freelance: skill, lavori da accettare, valutazione; candidatura |
| Pannello clienti | Richiesta preventivi con file da tradurre; accesso materiale tradotto |
| Amministrazione | Validazione anagrafica; fatturazione; pagamenti; solleciti; export Unicredit |
| Portale Freelancer | Area caricamento file (Intrawelt ↔ fornitore); chiusura progetti |

**Stato:** Analisi flussi completata (scaletta nov 2025). Openforce ha preventivato i costi.
Migrazione bloccata su task_3 (120h, PRIORITY 1). Dipende da task_1 (formazione T-Rex).

---

## Odoo – Integrazione portale SCENIA (04/03/2026)

Fonte: `Sviluppo_T-Rex (Odoo)/Integrazione Odoo - portale/Notes - Meeting integrazione Odoo - portale 04032026.txt`
Referente OpenForce: Susanna Ortini.

**Esigenza**: il portale SaaS SCENIA (clienti autenticati) deve creare SO in T-Rex/Odoo
quando un cliente avvia una richiesta di traduzione con servizi aggiuntivi (freelancer).

**Approccio tecnico**:
- Protocol: Odoo xml-rpc (standard, nessun modulo aggiuntivo)
- Auth: login con credenziali Odoo obbligatorio per ogni operazione (security layer nativo)
- Utente servizio: `asopranzi@intrawelt.com` come account dedicato (compromise tra utente
  per ogni PM vs. account admin anonimo; evita licenze aggiuntive)
- Test env: `intrawelt-test.openforce.it`, db: `test_intrawelt` [credenziali in env var, non qui]
- Warning migrazione: xml-rpc deprecato da v19, rimosso da v20 → pianificare json-rpc in futuro

**Flusso SO dal portale**:
1. Cliente loggato nel portale avvia richiesta
2. Portale chiama API Odoo → crea SO con dati: cliente, servizio mappato, coppie linguistiche, PM
3. PM riceve notifica in T-Rex → assegna task interni/freelancer
4. Fatturazione: tramite Budget Order (BO) concordato offline per clienti enterprise;
   primo periodo: BO inserito manualmente dal PM assegnato

**CRM website**: stesso approccio xml-rpc per CTA del nuovo sito intrawelt.com (Cappelli Design,
apr 2026) → crea opportunità Odoo CRM. Redirect area riservata clienti (Odoo) → da mantenere
nel nuovo sito come semplice link.

Documenti correlati nel folder:
- `wrapper per creare SO in Odoo da portale.docx` (231 KB): wrapper tecnico xml-rpc
- `Case study con GIT FORK.docx` (546 KB): case study sviluppo collaborativo fork+PR
- `xml_rpc.py`, `odoo_meta.js`: script test connessione
- `odoo-xmlrpc-ts` (npm): package TypeScript per Odoo xml-rpc

---

## Odoo – Studio integrazione NinjaOne RMM (TBC, post-migrazione)

Fonte: `Sviluppo_T-Rex (Odoo)/[TBC] STUDIO - INTEGRAZIONE ODOO NINJAONE (RMM).txt`

Idea esplorata da Alessio Sopranzi (nota interna, nessuna data; indicato "post migrazione
gestionale" come prerequisito). Obiettivo: integrare NinjaOne RMM con Odoo per
centralizzare dati IT nel gestionale.

Possibili flussi:
- **API + webhook**: NinjaOne API REST → script Python → Odoo JSON-RPC (endpoint, patch,
  inventario HW/SW, alert → ticket Odoo o moduli custom asset management)
- **Automazione via middleware**: Python/PowerShell; alert critici NinjaOne → ticket
  automatici Odoo via script o webhook intermediari
- **Reporting centralizzato**: aggregare dati NinjaOne in Odoo (SLA compliance, asset
  lifecycle, performance IT)

Stato: **TBC** — da studiare con Fabio Giorgini + OpenForce dopo migrazione Odoo 12→18.

---

## Odoo – Studio integrazione centralino cloud Vianova (in analisi, 2026)

Fonte: `Sviluppo_T-Rex (Odoo)/Integrazione Odoo - centralino cloud vianova/Notes.txt`

**Obiettivo**: aggancio Vianova UCC al CRM Odoo — chiamate inbound/outbound come eventi
contestualizzati (log, notifiche, recupero contatto in tempo reale).

**Stato**: nessun connettore nativo ufficiale Odoo-Vianova (verificato 2026).
Integrazione tecnicamente realizzabile via due modalità:

| Modalità | Descrizione | Note |
|----------|-------------|------|
| IP PBX + SIP Trunk | PBX intermedio (SIP-compatibile) collegato a Vianova via SIP Trunk; Odoo dialoga con il PBX via websocket SIP/WebRTC | Architettura più robusta; Odoo nativo SIP; Vianova fornisce SIP Trunk (IP-based o registrato, SIP/TLS, SRTP) |
| API REST Vianova | Integrazione eventi chiamata, click-to-call, screen-pop via API REST Vianova (endpoint OpenAPI su help.vianova.io) | Più flessibile ma richiede sviluppo custom; docs su https://help.vianova.io/docs/api-documentation |

Prerequisiti Odoo lato SIP: provider SIP esponga server accessibile via websocket +
supporto WebRTC (vedi docs.odoo.com/18.0/applications/productivity/voip).

Dipendenza: in attesa di migrazione centralino fisico Panasonic → Vianova UCC (cloud),
documentata in `telefono-pbx-voip.md` e `2026-switch-piano-terra.md`.

---

## OpenProject – Gantt tool interno (VM205)

Fonte: `Sviluppo_interno, scripting (IT on FIRE)/OpenProject/`

**Strumento**: OpenProject (self-hosted) su **VM205** (Ubuntu, Proxmox).  
**URL interno**: `http://openproject.local:9001`  
**Utilizzo**: project management interno, Gantt chart attività IT.

Utenti configurati: asopranzi@intrawelt.com (alesop95), atrovato@intrawelt.com, tvezeni@intrawelt.com.

**Note operative:**
- Invitare membro da: `http://openproject.local:9001/projects/<nome>/members`
- Si possono mettere WATCHERS su attività per notifiche mail
- Modifiche di massa: CTRL + seleziona più task → tre pallini → "Modifica di massa"
- Viste personalizzate con filtri salvabili

**Evento infrastrutturale**: 13/10/2025 disk resize VM205 (file `13102025_disk_resize.7z`).

---

## Incidente DHCP kickout Elisa (rete pubblica / TP-Link AC600)

Fonte: `_DA SISTEMARE (Alessio)/Problema DHCP kickout Elisa/` (file di testo vuoti, info nei nomi)

Due note nel folder:
1. "fare prova con TP LINK ac 600 e capire perchè kickout" — dispositivo TP-Link AC600
   (adattatore WiFi consumer) ha probabilmente generato un proprio DHCP server in LAN,
   causando conflitto con il DHCP del firewall Zyxel.
2. "Elena si è messa in rete pubblica e quindi per questo è andata in DHCP" — utente
   connessa involontariamente alla rete "pubblica" (VLAN guest) invece che alla LAN
   aziendale, ricevendo IP dal DHCP di quella rete.

Nessuna data documentata nel folder. Correlato al gap DHCP ancora aperto (rimozione
DHCP server classe .90 pendente come da GAP-TBC.md e 2026-switch-piano-terra.md).

---

## Software rimozione prioritaria (task_14)

Presenti su alcune macchine: **AnyDesk**, **TeamViewer** e altri software di accesso remoto non presidiati.  
Rischio: vulnerabilità sfruttabile → accesso non autorizzato alla macchina da remoto.  
Azione: rimuovere da tutte le macchine dove non necessario, tramite NinjaOne.
