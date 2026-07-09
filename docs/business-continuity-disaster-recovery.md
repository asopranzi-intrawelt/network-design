# Business Continuity e Disaster Recovery

Fonte: BCD_2026.docx (revisione 2026).
Politica di riferimento: PSGSI rev.1, 16/10/2025.
Standard: ISO/IEC 27001:2022.

---

## Struttura organizzativa

### Comitato di Gestione Crisi

| Ruolo | Nome |
|-------|------|
| Responsabile tecnico (RSGSI) | Alessio Sopranzi |
| Responsabile di produzione | Alessia Nasini |
| Direzione aziendale | Alessandro Potalivo, Sonia Martellini |

Responsabile Continuita' Operativa (RCO): contatta tutte le figure del Comitato,
redige la relazione per i clienti coinvolti nell'evento.

### Sedi

- Sede primaria: Via Pescolla 2A, Porto Sant'Elpidio (FM)
- Sede secondaria (DR): Via Elpidiense 14, Porto Sant'Elpidio (FM)

---

## Piano di Continuita' Operativa (BCP)

### Scenari di attivazione

- Indisponibilita' sede primaria per eventi atmosferici, allagamenti, incendi.
- Indisponibilita' energia elettrica prolungata.
- Indisponibilita' connettivita' internet prolungata.

Interruzioni parziali e temporanee senza perdita di dati non richiedono
attivazione del piano.

### Connettivita'

Tre linee internet indipendenti su tecnologie diversificate (affasciate con T-BOND).
Il failover e' automatico: l'IP pubblico non cambia anche con una o due linee inattive.
Router portatili alimentabili con powerbank disponibili per emergenze.

Vianova FTTO 1 Gbps + ponte radio Line Recovery Standard (100/20 Mbps) + WAN2 TIM
(disconnessa fisicamente da maggio 2025, contratto cessato luglio 2025). Da aggiornare:
il terzo link e' ora solo il ponte radio come backup; TIM e' dismessa.

### UPS e alimentazione

UPS alimentano: server, NAS, apparati hardware centralizzati (centralino).
Autonomia: ~15 minuti.
[TBC: modelli UPS, numero di UPS, potenza. Da VA: Emerson Liebert IntelliSlot
Web Card su 10.61.90.33 (management UPS).]

### PC portatili

Disponibili per continuita' operativa. Preconfigurati con software e accessi.
Autonomia: ~2 ore per unita'. Batterie verificate settimanalmente.

### Assistenza hardware

Punto Informatica (Daniele Colo'): contratto SLA 2 ore per guasti bloccanti.
Intervento da remoto e/o on-site. Fornisce anche PC sostitutivi per sede secondaria.

### Vademecum urgenze (runbook operativo, da verificare la data)

Foglio "Vademecum urgenze" trovato in `_planning_ferie_lunghe.xlsx`, senza
data propria; il file nel suo complesso copre i calendari ferie estate e
natale 2025, quindi il runbook e' presumibilmente coevo. Distingue guasti
bloccanti, da affrontare subito, da tutto il resto, rimandabile.

- Router principale Vianova guasto: chiamare Vianova; resta attiva la
  connessione di backup (ponte radio), e in ultima istanza una vDSL.
- Anche il router di backup guasto: chiamare Vianova.
- Firewall guasto: chiamare Punto Informatica per un firewall di scorta.
- Uno switch guasto: stessa procedura del firewall.
- Un gruppo di continuita' (UPS) guasto: bypass elettrico manuale, si
  riprende a lavorare senza continuita'.
- Una postazione di lavoro guasta (o un suo componente hardware): Punto
  Informatica tiene pronto un PC sostitutivo, sotto garanzia se applicabile;
  soluzione piu' rapida nel frattempo e' far lavorare la persona su un altro
  utente su un altro computer, dato che i job di backup Veeam sulle
  postazioni sono aggiornati (`\\10.61.20.177\Backup_Ufficio\BackupPDL`).
- NAS HERO (documenti) guasto: servirebbe la rottura di due dischi
  contemporaneamente (stato sano al momento della stesura); esistono due job
  di backup. Per lavorare nel frattempo si mappa NAS INTRA2 (.177) come NAS
  documenti (`\\10.61.20.177\Backup_Ufficio\BackupNasHero\daily_hero_to_intra2\latest\Documenti`),
  con prestazioni ridotte.
- Virtualizzatore Proxmox guasto: esiste un backup completo di tutte le VM
  su NAS INTRA (`\\10.61.20.168\Backup\dump`). Procedura di emergenza: si
  rimette in funzione un vecchio PC ("marsk") con il backup del nodo
  Proxmox (pve), gia' verificato funzionante, per ripristinare prima il
  nodo e poi le VM necessarie dalla procedura interna di backup di Proxmox.
- Guasto a monitor, stampante, tastiera e periferiche simili: non
  bloccante, sostituzione senza urgenza.

Scala di reperibilita' per le urgenze, se non c'e' nessuno in sede: prima
Alessio Sopranzi o Persona-E (da verificare se Tommaso Vezeni o Tommaso
Duranti: la fonte non specifica il cognome), poi Persona-H (Daniele Colo'),
infine Persona-S (Edoardo, cognome non noto dalla fonte), sempre in zona.

---

## Piano di Disaster Recovery (PDR)

### Storage e backup

Dati locali: NAS fleet (HERO .169, INTRA .168, INTRA2 .177, INTRA3 .172, documenti .170).
Dati cloud: Microsoft SharePoint (1000 GB), Outlook online.
Piattaforme: GroupShare (WINGROUPSHARE 10.77.116.3), T-Rex (Odoo, raggiungibili online).
Amazon: per backup e servizi cloud aggiuntivi.

NAS HERO replica inoltre offsite su Azure Blob Storage tramite un job QNAP
Hybrid Backup Sync (HBS) con l'opzione QuDedup abilitata: il backup viene
salvato in formato deduplicato (struttura `.qdff` con sottocartelle `dedup/`
e `filedesc/`, database SQLite `QNAPHybridBackupSync_full_XXX.db` per
l'indice), caricato per intero nel container blob `nashero` dello storage
account `backnashero` (resource group `backupqnaphero`, sottoscrizione
Azure del tenant `intrawelt.com`). Il ripristino di un backup `.qdff` puo'
avvenire direttamente da HBS su un NAS QNAP configurato con lo stesso job,
oppure offline tramite il "QuDedup Extract Tool" ufficiale QNAP, senza
richiedere il NAS originale.

Postazioni di lavoro: da febbraio 2025 ogni postazione fisica ha un job
giornaliero Veeam Agent (community, Entire computer, retention 7 giorni,
incrementale) verso il NAS INTRA2, con recovery media `.iso` per il
ripristino bare-metal su hardware diverso o VM e monitoraggio dello stato
del servizio via NinjaOne. Dettaglio in
`infrastructure-timeline/2025-q1-server-vianova.md`.

Il dettaglio delle procedure di backup e' nel documento "Data protection.pdf".
DR per email e SharePoint e' garantito da Microsoft.
DR per GroupShare e T-Rex e' garantito dai rispettivi provider.

### Attivazione sito DR

1. Dichiarazione crisi da parte del RCO.
2. Mobilitazione Comitato di Gestione Crisi.
3. Valutazione gravita' evento.
4. Eventuale trasferimento a Via Elpidiense 14 con infrastrutture trasportabili.
5. Assistenza Punto Informatica per configurazione hardware.
6. Ripristino connettivita' internet (prerequisito per tutti i servizi cloud).
7. Rientro alla sede primaria deciso dal Comitato.

### Prerequisito critico DR

L'erogazione del servizio dipende dalla connettivita' internet per accedere a
GroupShare, T-Rex, Microsoft 365. Il ripristino della connessione e' la prima
azione del piano DR.

---

## Politica di Sicurezza (PSGSI rev.1, 16/10/2025)

### Scope SGSI

- Networking
- Sistemi Informativi
- Sviluppo e gestione soluzioni SaaS
- Servizi

### Obiettivi CIA

- Riservatezza: accesso solo al personale autorizzato.
- Integrita': dati protetti da modifiche non autorizzate.
- Disponibilita': servizi accessibili su richiesta in accordo con i contratti.
- Conformita': GDPR, ISO 27001:2022, requisiti legali e contrattuali.
- Miglioramento continuo: audit interni ed esterni, riesame periodico.

### Ruolo GDPR

Intrawelt opera prevalentemente come Titolare del trattamento.
In via residuale come Responsabile del trattamento.
Le nomine a responsabile ex art. 28 GDPR sono stipulate con i fornitori IT.

### Processi SGSI attivi

- Risk assessment: identificazione, valutazione, trattamento, monitoraggio.
- Incident reporting: tutto il personale segnala eventi negativi al RSGSI (Alessio Sopranzi).
- Audit interni ed esterni: periodicita' da definire.
- Riesame periodico del piano: almeno ogni due anni.

---

## Gap analysis ISO27001 (stato giugno 2026)

| Controllo | Descrizione | Stato | Note |
|-----------|-------------|-------|------|
| A.5.29 | Business Continuity | Parziale | BCP/PDR documentati, test periodici non documentati |
| A.5.30 | Ridondanza IT | Parziale | 3 linee (ora 2 attive: FTTO + radio), UPS 15min, nessun generatore |
| A.8.13 | Backup | Parziale | Procedure backup in "Data protection.pdf" (non analizzato in questo progetto) |
| A.7.11 | Supporti di continuita' (UPS) | Parziale | UPS presenti, autonomia 15min, nessun generatore |
| A.5.24 | Incident management | Gap | Processo segnalazione esiste (RSGSI), procedure formali non documentate |
| A.6.1 | Screening | [TBC] | Non documentato |
| A.5.2 | Ruoli sicurezza | Parziale | RSGSI = Alessio Sopranzi, ruoli BCP definiti, SoA non completato |
