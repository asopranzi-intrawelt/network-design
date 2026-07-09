# Work-log

> Append-only, in ordine cronologico inverso (la voce piu recente in alto). Ogni passo
> significativo di codice e ogni intervento manuale rilevante lascia una voce con data, file
> toccati, motivo e commit di riferimento.

## 2026-07-09 — Coda BASSA della checklist ingestione chiusa (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/ingestion-checklist.md (tutte le
voci BASSA verificate e chiuse), docs/business-continuity-disaster-recovery.md
(§Vademecum urgenze, §Storage e backup NAS HERO/Azure), docs/GAP-TBC.md
(#109/ENV-001 RAEE), docs/cybersecurity-governance.md (§Procedura di audit
mailbox via eDiscovery), docs/runbook-anomalie.md (NAS-001), docs/sviluppo-interno.md
(Cheshire Cat espanso, nuove voci Google Antigravity e Notes con
relazioni/Obsidian, Tool AI coding assistance espanso), _notes/.anonymization-map.md
(Persona-S nuova, Persona-M nome proprio scoperto, nuove coppie IP)
Motivo: su richiesta dell'utente, percorse in ordine tutte le ~25 voci BASSA
residue della checklist (ALTA/MEDIA erano gia' a zero). La maggioranza si e'
rivelata fuori scope (contabilita', HR, marketing vendor, tutorial generici
non specifici a Intrawelt) o gia' coperta altrove, ma sono emersi cinque fatti
sostanziali: runbook di emergenza a 9 casi con scala di reperibilita' (da
`_planning_ferie_lunghe.xlsx`), replica NAS HERO su Azure Blob via QNAP
HBS/QuDedup, gap ambientale RAEE mai risolto, procedura legale di audit
mailbox via M365 Purview eDiscovery (art.4 Statuto Lavoratori/GDPR), e
quattro studi di tooling AI mai implementati (Cheshire Cat, Google
Antigravity, Obsidian vs IT Glue, Claude Subagents). Verificato anche che
`intraweb2_1osxen.pdf`/`intraweb_wx7v5r.pdf` (1506+415 pagine) sono i report
Nessus grezzi del 06/11/2025 alla base del VA Onova gia' sintetizzato in
vulnerability-assessment-nov2025.md: nessuna nuova ingestione necessaria.
Corretti anche due IP reali non anonimizzati trovati per caso in
business-continuity-disaster-recovery.md (192.168.90.33 pre-esistente da
sessione precedente, e due miei stessi nuovi inserimenti prima della
correzione) — bug di bookkeeping isolato, non la Fase B completa: un grep
esteso su tutto `docs/` conferma che il resto del repository (helpdesk,
timeline storica, SCENIA) resta con IP reali non anonimizzati, esattamente
come previsto dalla Fase B non ancora iniziata (roadmap.md). La coda BASSA
e' ora chiusa; restano solo le due attese esterne (PORT-TAGGING, fonte
IntraLino su VM).

## 2026-07-08 — Rimossa scrittura verso E:\projects, nuova regola di confine (sessione 9)

Commit: PENDING (da fare manualmente)
File toccati: scripts/Build-TimelineSvg.ps1 (rimosso parametro -MkDocsAsset,
-NoCopy e il blocco Copy-Item finale), CLAUDE.md (nuova sezione "Confine con
E:\projects", sezione "Script timeline SVG" aggiornata), .claude/context/STACK.md
(riga Build-TimelineSvg.ps1 aggiornata)
Motivo: l'utente ha segnalato che questo repository non deve scrivere dentro
`E:\projects` (sito MkDocs dei progetti personali); la direzione corretta e'
che sia quel progetto a leggere l'asset da qui, non il contrario. Lo script
ora scrive solo `docs/infrastructure-timeline/timeline.svg` in questo repo.
Nota: la copia gia' esistente in `E:\projects\docs\company\assets\network-timeline.svg`
(scritta dalle sessioni precedenti prima di questa correzione) resta
orfana finche' l'utente non predispone un meccanismo di lettura dal lato
E:\projects; non toccata da questa sessione perche' fuori dall'albero di
D:\network-design.

## 2026-07-08 — sync-context: bump timbri last-verified a HEAD (sessione 9)

Commit: PENDING (da fare manualmente)
File toccati: .claude/context/STACK.md, deployment.md, design-and-security.md,
dev-testing.md, roadmap.md, current-work.md (frontmatter last-verified),
.claude/memory/index.md (commit di riferimento e tabella di stato)
Motivo: sync-context ha rilevato che tutte le sei schede avevano contenuto
gia' coerente con HEAD (347f79c) ma il timbro last-verified era rimasto
disallineato per un errore di bookkeeping nelle sessioni precedenti (il
timbro veniva impostato al commit precedente a quello che conteneva davvero
la modifica: es. design-and-security.md portava 594ec07 ma il contenuto v4
risale al successivo 0e4b837). Nessuna modifica di contenuto, solo
riallineamento dei timbri e del riferimento in memory/index.md, fermo dal
07/07/2026 a 68216f0.

## 2026-07-08 — Token MCP Proxmox creato e verificato (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati: .claude/memory/decisions.md (esito ADR-007), .gitignore
(pattern .env/.env.* aggiunti, mancavano), .env creato in radice (backup
umano del segreto, non tracciato, valutazione rischio in ADR-008)
Motivo: completata la procedura ADR-007. Token `mcp-readonly` creato su
root@pam con privilege separation e ruolo PVEAuditor su `/`; le tre
variabili PROXMOX_URL/TOKEN_NAME/TOKEN_VALUE impostate nel registro HKCU
dell'utente via setx (il valore del secret e' stato letto dal .env locale
via script PowerShell per evitare di farlo transitare in chiaro nella
chat). Verifica di autenticazione: GET /nodes -> 200, nodo pve online,
senza mai stampare il token. Resta il riavvio di Claude Code per il
reload del server MCP `proxmox`.

## 2026-07-08 — ADR-008: schema a due token Proxmox (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati: .claude/memory/decisions.md (ADR-008)
Motivo: l'utente ha chiesto se il token MCP dovesse avere anche la
scrittura per gli script di network design; ragionamento tracciato per
esteso nell'ADR come argomentato in sessione. Esito: MCP resta PVEAuditor
sola lettura (canale ambientale senza conferme per la safety rotta);
scrittura con secondo token a finestra (automation@pve, ruolo minimo,
expiry) alla ripresa della Fase 3. Confermato dall'utente. Token
mcp-readonly creato sulla GUI (passo 1); restano permesso PVEAuditor
(passo 2) e variabili d'ambiente (passo 3), poi riavvio di Claude Code.

## 2026-07-08 — Correzione date Bitdefender, timeline SVG con aree di competenza, diagramma fonia VLAN 100 (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/cybersecurity-governance.md (correzione confermata dall'utente: il
    deploy Bitdefender era registrato "giu 2024" ma e' avvenuto in autunno
    2025, dopo la sottoscrizione del 15/09/2025; righe spostate al Q4 2025
    con nota di correzione; VA interno Bitdefender marcato [TBC] fine 2025)
  - docs/infrastructure-timeline/2024-infra.md (sezione Bitdefender rimossa)
    e 2025-q3-q4.md (sezione ricollocata in autunno 2025, con bonifica di
    tre IP reali che conteneva: due Seeweb -> 10.77.116.3/.4, uno LAN ->
    10.61.20.13)
  - scripts/Build-TimelineSvg.ps1 (v2: perimetro dal 2024 — ingresso IT
    manager, come chiesto; esclusi 2023-baseline e intestazioni senza data;
    otto aree di competenza con tavolozza categoriale validata dataviz,
    legenda con conteggi, tag testuale per evento cosi' l'identita' non e'
    solo colore) + timeline.svg rigenerata (121 interventi dal 2024,
    verificata al render) e ricopiata su E:\projects
  - docs/firewall-zyxel-usg-flex-500.md (tabella diagrammi: registrato
    rete_fonia_voip_08072026_2.drawio-claudio.drawio prodotto dall'utente —
    VLAN 100 fonia, zona VOICE su ge5, DHCP firewall, SIP ALG off, PoE
    priority, 5 step hitless; nota refuso modelli GS2220 vs XGS2220;
    convergenza con M11/M12 rispetto a FW-012)
  - docs/network-diagram.md (riga VLAN 100 target in tabella; nota 08/07
    aggiornata col diagramma fonia)
  - .claude/context/diagrams/firewall-dmz-2026/rete_stato_target_08072026.drawio
    (nota interna: VLAN fonia = 100, rimando al diagramma dell'utente)
Motivo: feedback utente pre-commit — timeline piu' dettagliata con
interventi e skill, date sbagliate (Bitdefender), perimetro dal suo
ingresso (2024); piu' il nuovo diagramma fonia consegnato dall'utente.

## 2026-07-08 — Timeline SVG auto-rigenerata per repo e sito progetti (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - scripts/Build-TimelineSvg.ps1 (nuovo: parser deterministico delle
    intestazioni `## data - titolo` dei sei file timeline, ordinamento
    cronologico, SVG verticale a bande per anno; sostituzione nomi legacy
    da _notes/.svg-name-replacements.txt privato; guard-rail IP
    non-placeholder; copia verso E:\projects)
  - docs/infrastructure-timeline/timeline.svg (nuovo, versionato: 136
    eventi 2021-2026, verificato al render — zero nomi reali, zero IP)
  - CLAUDE.md (sezione Script timeline SVG), .claude/context/STACK.md (riga)
  - .claude/settings.local.json (secondo hook SessionStart: rigenerazione
    a ogni avvio, "si aggiorna sempre" come chiesto dall'utente)
  - E:\projects\docs\company\network-infrastructure-documentation{,.en,.es}.md
    (sezione Timeline con l'immagine assets/network-timeline.svg — fuori
    repo, sito MkDocs progetti) + assets/network-timeline.svg (copia)
  - _notes/.svg-name-replacements.txt (nuovo, privato),
    _notes/.anonymization-map.md (Referente-Vianova-2, Referente-BioStar2-1,
    Persona-Q, Persona-R; cognome Consulente-ISO27001-1 ora noto)
Motivo: richiesta utente 08/07 — la timeline aggiornata deve essere un SVG
sempre aggiornato, anonimizzato, accessibile in E:\projects nel progetto
"Progettazione e documentazione della rete aziendale". Nota di design: i
sorgenti legacy contengono ancora nomi reali (Fase B pendente), quindi
l'anonimizzazione dell'artefatto avviene in generazione con mappa privata;
l'SVG e' piu' pulito dei sorgenti finche' la Fase B non chiude.

## 2026-07-08 — Snapshot v4 riconciliato + decisione MCP (ADR-007) + bonifica .mcp.json (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/design-and-security.md (scheda portata dallo snapshot
    v3 al v4: nodo 48 core/125.4 GB con upgrade RAM confermato, LAN /19,
    inventario 8 VM con VM602 "Intralino" e VM810, storage PROGRAMMAZIONE
    nuovo, nove backup schedule, firewall cluster ancora inattivo)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce
    08/07/2026 snapshot v4 con delta rispetto alla v3)
  - docs/infrastructure-timeline/GAP-TBC.md (#106 RICONCILIATO: VM effimere
    rimosse, 810 sostituisce 809; #107 aggiornato: .58/.60 confermati NON
    VM del nodo; #108 nuovo SRV-003: stato cluster riporta IP nodo = iLO5;
    totale 108)
  - .claude/context/roadmap.md (Fase 2 step 2 fatto: snapshot v4)
  - .mcp.json (bonificato: conteneva l'IP reale del nodo in un file
    TRACCIATO del repo pubblico; ora tutte le variabili si espandono da
    env utente; riscritto per l'autenticazione a token del pacchetto)
  - .claude/memory/decisions.md (ADR-007: approccio B, token API
    PVEAuditor sul pacchetto proxmox-mcp esistente, ALLOW_DANGER=true
    accettabile solo con token di sola lettura)
  - CLAUDE.md (Nota MCP riscritta: rimando ad ADR-007)
  - _notes/.git-filter-replacements.txt (regola IP nodo per la Fase B:
    .mcp.json in storia con valore reale)
Motivo: l'utente ha eseguito Get-ProxmoxSnapshot.ps1 (v4, 08/07 10:35) e
ha chiesto di scegliere e documentare l'approccio MCP. Nota: lo snapshot
v4 conferma in campo l'ordine RAM del 14/11/2025 ingerito stamattina dalla
cartella PROXMOX. Il token API e le tre env restano da creare (utente).

## 2026-07-08 — Diagnosi MCP Proxmox non funzionante (sessione 8, continua)

Commit: PENDING (nessun file tracciato modificato oltre a questa voce)
Tentata la lettura live dell'inventario Proxmox (riconciliazione gap
#106/#107) via server MCP `proxmox` di `.mcp.json`, con ok esplicito
dell'utente alla sola lettura. Esito: inutilizzabile per due difetti
indipendenti del pacchetto risolto da `uvx proxmox-mcp` (0.1.0, non e'
ProxmoxMCP-Plus): (1) la safety policy carica `config/safety_policy.json`
da un PROJECT_ROOT sbagliato per un pacchetto installato, il file non
esiste, la lista safe_tools resta vuota e OGNI tool viene bloccato; il
bypass `confirmed=true` non passa perche' i tool non dichiarano quel
parametro nello schema e il client lo scarta. (2) Il pacchetto autentica
solo via token API (`PROXMOX_URL`, `PROXMOX_TOKEN_NAME/VALUE`) mentre
`.mcp.json` fornisce `PROXMOX_HOST/USER/PASSWORD`: anche superata la
safety, il client non si connetterebbe. `PROXMOX_PASSWORD` non e' nemmeno
presente nell'ambiente della shell. Rimedi possibili: sostituire il
pacchetto con il ProxmoxMCP-Plus vero, oppure creare un token API su
Proxmox e riscrivere `.mcp.json` con le env giuste (piu' safety_policy.json
nel PROJECT_ROOT del pacchetto). Nel frattempo la via canonica resta
`scripts/Get-ProxmoxSnapshot.ps1` eseguito dall'utente (M18): chiesto.

## 2026-07-08 — Diagramma target rev 08/07 (secondo trunk PT-P2) + ingestione BASSA infrastrutturali (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/diagrams/firewall-dmz-2026/rete_stato_target_08072026.drawio
    (nuovo, su richiesta utente: secondo trunk 802.1Q tra XGS2220-30HP Piano
    Terra e XGS2220-54HP Piano 2 con VLAN dati del Piano Terra + VLAN fonia;
    ID VLAN non fissati, nota NET-008/TEL-002 nel diagramma)
  - docs/firewall-zyxel-usg-flex-500.md (riga nuova nella tabella diagrammi)
  - docs/network-diagram.md (nota aggiornamento target 08/07 sotto la
    tabella VLAN)
  - docs/infrastructure-timeline/2025-q2-migrazione-tim-vianova.md
    (§04-10/04/2025 VM601/applyconfiguration/postinstall; §11-12/06/2025
    scanner Canon C5840 con Referente-MyOffice-2)
  - docs/infrastructure-timeline/2025-q3-q4.md (§14/11/2025 saturazione RAM
    pve, ordine 64GB, quotazione DL380 G10 ricondizionato; §01/12/2025 VM205
    spazio esaurito, script vm_disk_alert e Postfix send-only sul nodo)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md
    (§Febbraio-Aprile 2026 esercizio Proxmox: vzdump lock 16/02 con
    inventario VM dai log, freeze VM 15/04, arrivo GPU e transceiver;
    §03-23/04/2026 NinjaOne backup/Archiver)
  - docs/infrastructure-timeline/GAP-TBC.md (#106 aggiornato: VM101
    confermata da qemu-101.log 12/02/2025; popolazione VM piu' ampia dello
    snapshot v3, riconciliazione a M18)
  - docs/infrastructure-timeline/ingestion-checklist.md (PROXMOX
    riclassificata da BASSA e ingerita; Ninjaone backup e scanner [x];
    QNAP cloud, Sharepoint, sostituzione RAM, 2 txt vuoti SKIP)
  - _notes/.anonymization-map.md (Referente-MyOffice-2)
Motivo: richiesta utente 08/07 (nuova revisione del diagramma target con il
secondo trunk, poi prosecuzione ingestione). La cartella PROXMOX era
sotto-classificata: conteneva eventi di esercizio mai tracciati. Config
mailer Postfix e appunti debian-odoo non letti (possibili credenziali).
Fonti solo-screenshot lasciate nel sorgente e marcate SKIP.

## 2026-07-08 — MEDIA preesistenti completate: Veeam, Odoo restore, Appina, Pi-hole, Proelium (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/2025-q1-server-vianova.md (§17/01-05/02/2025
    Veeam Agent: nuova politica backup postazioni verso NAS INTRA2, recovery
    media .iso, monitoraggio NinjaOne su evento 190)
  - docs/business-continuity-disaster-recovery.md (paragrafo backup
    postazioni in §Storage e backup; bonifica IP Seeweb reale -> 10.77.116.3)
  - docs/infrastructure-timeline/2025-q2-migrazione-tim-vianova.md
    (§28/05/2025 restore dump Odoo 12 in locale, precauzioni anti-invio
    posta da ambiente di test)
  - docs/infrastructure-timeline/2025-q3-q4.md (§03/11/2025 studio API Odoo
    per CRM con OpenForce; §18/12/2025 studio Pi-hole mai implementato;
    bonifica del percorso UNC del NAS reale -> 10.61.20.177)
  - docs/helpdesk-operations.md (tre sezioni Odoo: ambiente di sviluppo
    locale e restore, audit attivita' utente v12, studio API CRM)
  - docs/vendor-management.md (Proelium: preventivo P220126 22/01/2026 solo
    VA, 1.200 EUR/2gg o triennale 3.100 EUR, scaduto non accettato; dettaglio
    metodologia dalla call 19/01; bonifica IP Seeweb -> 10.77.116.3)
  - docs/infrastructure-timeline/GAP-TBC.md (#105/SEC-011 esteso a
    Veeam_DRAFT.pdf e transcript Odoo 28/05)
  - docs/infrastructure-timeline/ingestion-checklist.md (6 voci MEDIA [x],
    riepilogo: MEDIA esaurite, resta BASSA; Regolamento rev1.pdf era gia'
    coperto dal .docx)
  - .claude/context/roadmap.md (Fase 1bis: fonte IntraLino su VM da contesto
    utente; tabella riepilogativa allineata: 1bis corrente, Fase 3 sospesa)
  - .claude/context/current-work.md (step 4 chiuso, domanda aperta IntraLino
    VM), _notes/.anonymization-map.md (Referente-OpenForce-2, IP 10.61.10.57,
    residui bonificati, credenziali mai copiate),
    _notes/.tmp-docx-odoo-restore/ (estrazione transcript)
Motivo: prosecuzione Fase 1bis su richiesta utente. Nota utente 08/07
recepita in roadmap: IntraLino come progetto aziendale si documentera' dalla
documentazione Claude che vive su una VM (contesto che l'utente fornira');
le sezioni IntraLino attuali valgono come parziali. Fonti lette a costo
minimo: mirror graphify-out per Odoo v12, eml via parser Python, PDF Veeam
e preventivo Proelium letti una volta, transcript 7 MB estratto con
python-docx in _notes. Credenziali nei sorgenti mai riportate (gap #105).

## 2026-07-07 — Delta MEDIA completato: ABBYY, Checklist/call SCENIA, benchmark IntraLino (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/2025-q1-server-vianova.md (§Migrazione
    licenze ABBYY FineReader 15, 27/02-24/03/2025: contesto acquisto 2021 e
    SMUA mai rinnovata, ticket supporto, errore LM v16, attivazione sul
    nuovo server, decisione 21/03 di dismettere il vecchio licserver,
    rollout ~18 postazioni con utente guest)
  - docs/infrastructure-timeline/2024-infra.md (voce 06/11/2024: falso
    allarme licenza ABBYY, licenza trial pescata oltre le 5 concurrent)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (§Benchmark DoE
    IntraLino maggio-luglio 2026: C1/C2/C3, GPU RTX 5060 Ti installata
    08/06, embedder bge-m3 fisso dal 04/06, report differenziali 29/06,
    C4 Qwen3-14B fuori benchmark su ambiente test :4443)
  - docs/scenia-project.md (§Call AIDAPT 06/07/2026 Qdrant/KB, §Checklist
    operativa caricamento nuovo customer, riga timeline Fase 3 aggiornata)
  - docs/infrastructure-timeline/GAP-TBC.md (#105 SEC-011 credenziali in
    chiaro in ABBYY.docx; #106 SRV-001 hostname alternati e VM101 vs VM100;
    #107 SRV-002 host IntraLino .58/.60 dichiarati VM ma .58 con hardware
    fisico, assenti dallo snapshot v3; totale 107)
  - docs/infrastructure-timeline/ingestion-checklist.md (4 voci MEDIA [x],
    riepilogo: delta MEDIA esaurito)
  - .claude/context/current-work.md (step 3 chiuso, prossimo blocco MEDIA
    preesistenti), _notes/.anonymization-map.md (Persona-O/P,
    Referente-Novadys/ABBYY/AIDAPT, IP .58/.60/.114/.8/.170),
    _notes/.manifest-docx.json e _notes/.tmp-docx-abbyy/ (estrazione ABBYY)
Motivo: prosecuzione Fase 1bis su richiesta utente ("Procedi"). Metodo:
ABBYY.docx (17 MB, 166 immagini) estratto una volta con python-docx (42 KB
testo) e manifesto anti-rilettura creato; per IntraLino letti solo lo stato
progetto, la guida C4 e le conclusioni dei due report (disclosure
progressiva); i file di credenziali della cartella n8n mai aperti. Tutto il
nuovo contenuto tracciato e' anonimizzato (10.61.x, Persona-X); password,
seriali licenze e lista nominativa postazioni restano solo nei sorgenti.

## 2026-07-07 — Sync-context post 594ec07 + ingestione revisione WindTre e BitLocker endpoint (sessione 8)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/*.md (bump last-verified 1ad2cb7 -> 594ec07 su tutte e sei
    le schede, dimenticato nei commit 6e1d4b6..594ec07; current-work.md
    aggiornata: voci ALTA chiuse, prossimo blocco delta MEDIA)
  - .claude/memory/index.md (commit di riferimento 594ec07, tabella schede,
    punto di ripresa riscritto)
  - docs/cybersecurity-governance.md (timeline Q3 2026: BitLocker endpoint
    attivo dal 03/07 con escrow chiavi su NinjaOne, revisione WindTre;
    nuova sezione §Revisione chiarimenti WindTre RFQ 10714 06-07/07;
    raccordo endpoint nella sezione Crittografia dati a riposo; riga
    WindTre della tabella questionari aggiornata)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce WindTre [x],
    riepilogo priorita': ALTA vuota, MEDIA aggiornata)
Motivo: ripresa sessione con sync-context (schede con frontmatter mai
bumpato dopo 1ad2cb7 ma contenuti gia' coerenti; solo current-work e index
davvero stale). Il delta OneDrive di avvio (2 nuovi + 1 modificato, tutti
WindTre Busta Tecnica _WIP) coincideva con la prima voce MEDIA: ingerita
dalle due NOTA-INTERNA (fonti .md, nessun docx da estrarre). Fatti chiave:
BitLocker full-disk XTS-AES 128 su tutti gli endpoint dal 03/07 (migliora
righi 77/190/191 annex), SCC nuove ex art. 46 GDPR con 4 sub-responsabili
extra-SEE (RWS/UK, NinjaOne/USA, QNAP e Zyxel/Taiwan), correzione del
file-base dell'annex (prima revisione applicata a copia non allineata).
Consegna a WindTre attesa entro il 08/07. Baseline OneDrive da aggiornare
con -UpdateBaseline a valle del triage.

## 2026-07-07 — Ingestione delta SCENIA: Allegati A-L, DPIA compilata, Risposte AIDAPT (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/scenia-project.md (Fase 3 estesa a 29/06-06/07; nuove sezioni: DPIA
    stato 02/07 con necessita'/proporzionalita' compilate, Risposte Tecniche
    AIDAPT con nota di riconciliazione retention 7/10gg vs 60gg e breach 48h
    vs EDPB, Allegati separati A-L con contenuti F/H/I/J; bonifica nomi reali
    residui: Persona-A, Collaboratore-Esterno-1, Persona-N nuova, IP
    collaboratore rimosso)
  - docs/infrastructure-timeline/ingestion-checklist.md (2 voci ALTA [x]:
    delta SCENIA e Risposte Tecniche, trovate negli estratti DPA/extracted/)
  - _notes/.anonymization-map.md (Persona-N), _notes/.git-filter-replacements.txt
Motivo: voce ALTA del delta 23/06-07/07. Metodo token-economy: usati gli
estratti .md gia' presenti in DPA/extracted/ (INDEX, diff tra le due versioni
DPIA invece di rilettura integrale: 64 righe cambiate), python-docx per i
soli 4 allegati non ancora coperti (F/H/I/J). Resta da ingerire la call
AIDAPT del 06/07 (MEDIA). Dati personali del referente privacy (telefono,
anagrafica completa) lasciati solo nel sorgente.

## 2026-07-07 — Tagging in corso (gap 102-104), architettura LAN telefoni, audit crittografia (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce 07/07/2026:
    tagging VLAN in corso sui due switch, evidenze in _notes, architettura LAN
    telefoni Vianova dalla nota utente)
  - docs/infrastructure-timeline/GAP-TBC.md (#102 NET-008: VLAN 1 non taggabile
    sulla dorsale senza perdere NAS-HERO, ipotesi native VLAN mismatch da
    verificare; #103 TEL-002: telefoni via vano ascensore non passano le VLAN;
    #104 SEC-010: password archivi cifrati in chiaro; #98 FW-012 funzione
    confermata; totale 104)
  - docs/firewall-zyxel-usg-flex-500.md (FW-012 confermata: DHCP+gateway
    Vianova untagged su porta 8, isolati dal firewall, VPN Vianova->myOffice)
  - docs/cybersecurity-governance.md (nuova sezione Crittografia dati a riposo
    da AUDIT_INVENTORY.md: due schemi paralleli VeraCrypt/.z 2009-2022,
    password in chiaro su filesystem, azioni P0/P1/P2; dettagli di derivazione
    password NON riportati, repo pubblico)
  - docs/infrastructure-timeline/ingestion-checklist.md (AUDIT_INVENTORY [x],
    nota PORT-TAGGING aggiornata: racconto a lavori conclusi)
  - .claude/context/roadmap.md (M11 parziale), .claude/context/current-work.md
Motivo: l'utente ha eseguito il 07/07 gli interventi di tagging (racconto
completo rimandato a endpoint funzionanti; evidenze in
`_notes/[TBC] screenshot e note myoffice/`: 16 screenshot, 2 foto, note.txt).
Tracciati subito i fatti noti e ingerita la prima voce MEDIA del delta
(audit crittografia dati a riposo).

## 2026-07-07 — Ingestione completa Mappatura porte fisiche (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/mappatura-porte-fisiche.md (riscritto completo: prima era un estratto
    parziale con nomi propri e IP reali)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce marcata [x])
  - .claude/context/current-work.md (stato e NET-007 aggiornati)
Motivo: prima voce ALTA della Fase 1bis. Estratto integrale deterministico di
porte_fisiche_via_pescolla_2.xlsx (openpyxl: 4 fogli; rispetto all'estratto
precedente mancavano Piano 0 uffici 2-4 completi, Piano 1 uffici 4-6, la
colonna "nome porta attuale" e i totali) e lettura visiva del PDF (scansione
del rilievo manoscritto "Prese dati" di Luciani Impianti, 20/08/2020, tre
pagine, convertite in PNG con PyMuPDF: e' la fonte originale della mappatura,
con la colonna "attuale" delle etichette permutate e i "da fare" mai chiusi).
Scoperte: permutazione sistematica delle etichette dal 2020 mai ricorretta
(rafforza NET-007 come errore di etichettatura); discrepanza xlsx/PDF sul
numero porte Ufficio 2 Piano 0 (13 vs 14, nuovo TBC); nessuna informazione
VLAN/tagging nelle fonti (la nota PORT-TAGGING resta in attesa dell'input
utente). Anonimizzazione applicata: nomi uffici -> Persona-A/Persona-B, nomi
delle postazioni Ufficio 4 Piano 0 lasciati solo nel sorgente, IP -> 10.61.x.

## 2026-07-07 — Pivot su ingestione OneDrive: gestione delta, hook di avvio, GroupShare (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - scripts/Check-OneDriveDelta.ps1 (nuovo: confronto deterministico della cartella
    OneDrive IT con baseline locale; esclusioni per dati raw/artefatti; baseline
    creata il 07/07 con 44.515 file in _notes/.onedrive-manifest.json, non versionata)
  - .claude/settings.local.json (non versionato: hook SessionStart che esegue lo
    script a ogni avvio, delta riportato in contesto automaticamente)
  - docs/infrastructure-timeline/ingestion-checklist.md (data e nota drift, voce
    ZYXEL XGS2220 corretta in "Mappatura porte fisiche" ALTA, sezione Delta
    23/06->07/07 triata, nota PORT-TAGGING, riepilogo priorita' rigenerato)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (nuova voce 06/07/2026:
    upgrade GroupShare 2020 SR1->SR2+CU15 bloccato su download RWS, da handoff con
    credenziali in chiaro NON riportate; corretti 6 cognomi reali residui nella
    voce Eni VIPA del 16-17/06)
  - .claude/context/roadmap.md (Fase 3 SOSPESA, nuova Fase 1bis CORRENTE)
  - .claude/context/current-work.md (riscritta: focus Fase 1bis, nota PORT-TAGGING)
  - .claude/memory/index.md (punto di ripresa, ancoraggi a 1ad2cb7)
  - frontmatter schede bumpato a 1ad2cb7 (commit dell'utente con ancoraggio+bonifica)
  - _notes/.anonymization-map.md (IP pubblico WINGROUPSHARE, host Seeweb per ruolo,
    nota cognomi Eni)
Motivo: decisione utente del 07/07: sospendere la Fase 3 operativa e completare
prima la timeline cronologica dei due anni di lavoro sulla rete ingerendo il
resto di OneDrive IT. Il delta 23/06->07/07 (checklist ferma al 23/06) e' stato
rilevato, triato in checklist e coperto per la voce ALTA (GroupShare); il
controllo del drift diventa strutturale con script + hook SessionStart. La
questione del tagging porte dei due switch (migrazione centralino cloud) non
e' ancora emersa per intero dai documenti: tracciata come nota PORT-TAGGING,
dettagli attesi dall'utente al momento giusto dell'analisi cronologica.

## 2026-07-07 — Ancoraggio schede e bonifica anonimizzazione file vivi .claude/ (sessione 7)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/STACK.md, deployment.md, design-and-security.md, dev-testing.md,
    current-work.md, roadmap.md (frontmatter `last-verified` ancorato a 34a9dd7;
    per le prime quattro era il primo ancoraggio da PENDING-FIRST-COMMIT)
  - .claude/context/design-and-security.md (subnet server reale -> 10.61.20.0/24)
  - .claude/context/dev-testing.md (IP iLO reale -> 10.61.1.71)
  - .claude/context/roadmap.md (M9: IP DMZ e IP pubblico -> placeholder; M10: nome
    proprio -> Persona-A; M12: IP switch management -> 10.61.90.37)
  - .claude/memory/progress.md (due IP pubblici reali nelle voci del 01/07 -> placeholder)
  - .claude/rules/anonymization.md (l'esempio della convenzione usava la coppia
    reale/placeholder vera, rivelando la mappatura: sostituito con valori fittizi)
  - .claude/memory/index.md (commit di riferimento e tabella schede)
  - .claude/context/diagrams/firewall-dmz-2026/ (2 drawio su 8 file: username
    reali delle utenze VPN del firewall -> persona-a/b/e/k/l, IP peer Seeweb
    -> 192.0.2.27, subnet remota Seeweb -> 10.77.116.x; sostituzione
    deterministica via script Python, verificata a zero residui)
  - _notes/.anonymization-map.md (voce iLO, utenze VPN, elenco correzioni odierne)
  - _notes/.git-filter-replacements.txt (regole per gli username delle utenze VPN)
Motivo: sync-context a inizio sessione (passo 0, primo ancoraggio). Durante
l'ancoraggio trovati valori reali residui nei file "vivi" sotto `.claude/`,
fuori dal perimetro Fase A del 01/07: corretti al tip secondo la regola di
anonimizzazione (la storia git li conserva; la pulizia resta demandata alla
riscrittura unica post-Fase B, il file di sostituzioni copre tutti i valori).
Gli username delle utenze VPN nei diagrammi erano candidati all'eccezione
operativa dei nomi oggetto letterali, ma su decisione esplicita dell'utente
sono stati anonimizzati come tutto il resto: la traduzione per operare sulla
GUI reale sta nella mappa privata. Restano verbatim, come da eccezione gia'
dichiarata, i soli nomi regola/oggetto contenenti "Elisa" e le caselle
funzionali (mailer@, it@).

## 2026-07-01 — Anonimizzazione Fase A: perimetro network-design (sessione 6, continua)

Commit: PENDING (da fare manualmente)
File toccati (sostituzione deterministica via script, non a mano):
  - docs/firewall-zyxel-usg-flex-500.md, docs/firewall-zyxel-usg-flex-500-live.conf
  - docs/network-diagram.md, docs/telefono-pbx-voip.md
  - docs/infrastructure-timeline/2026-switch-piano-terra.md, GAP-TBC.md
  - CLAUDE.md, .claude/context/STACK.md, .claude/context/deployment.md
  - .claude/context/diagrams/network-topology.mmd
  - .claude/context/diagrams/firewall-dmz-2026/ (8 file drawio/svg)
  - .claude/rules/anonymization.md (nuovo, tracciato: convenzione per sessioni future)
  - _notes/.anonymization-map.md (nuovo, NON tracciato: mappatura reale)
  - _notes/.git-filter-replacements.txt (nuovo, NON tracciato: preparazione riscrittura storia)
Motivo: verificato che il repository e' pubblico su GitHub (HTTP 200 via API non
autenticata). Trovati IP pubblici reali (i blocchi WAN, oggi mappati sui
placeholder 203.0.113.x e 198.51.100.x), IP privati
RFC1918 reali, un MAC address reale e oltre venti occorrenze di nomi propri di
dipendenti e referenti esterni nei file del perimetro network-design attivo,
alcuni presenti da sessioni precedenti a questa. Con conferma esplicita
dell'utente: repository resta pubblico, anonimizzazione completa (inclusi IP
privati e nomi host) da qui in avanti, riscrittura della storia git pianificata
ma rimandata a dopo la Fase B (audit dell'intero repository, registrata come
Fase 3bis in roadmap.md) per evitare due round separati di force-push.
Eccezione deliberata: i nomi di oggetto firewall reali che contengono "Elisa"
restano verbatim per fedelta' operativa (necessari per guidare i prossimi
micro-step sulla GUI); le menzioni narrative della stessa persona sono
anonimizzate in "Persona-I". Il nome e l'email dell'utente (Alessio/asopranzi)
restano reali, coerentemente con il fatto che sono gia' nei metadati di ogni
commit git.
Verificato con grep case-insensitive su tutti i file toccati: nessun residuo.

## 2026-07-01 — M1: correzione guidata regole firewall allow->deny (sessione 6)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/firewall-zyxel-usg-flex-500-live.conf (nuovo — changelog incrementale live del firewall)
  - docs/firewall-zyxel-usg-flex-500.md (FW-001/FW-002 marcate corrette, FW-011 aggiornata, callout di stato)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce datata 01/07/2026)
  - docs/infrastructure-timeline/GAP-TBC.md (item 54/55 risolti)
  - .claude/context/roadmap.md (M1 marcato Fatto, stato riepilogativo Fase 3 aggiornato)
Motivo: eseguito M1 della roadmap Fase 3, guidando l'utente passo-passo dentro la
Web UI del firewall Zyxel USG FLEX 500 con verifica su screenshot Screenpresso a
ogni passaggio (11 screenshot, screenshot_01.png-screenshot_15.png). Corretta la
regola `Blocco_Gruppo_IP_Phishing_Elisa` (allow->deny, log alert, rimosso
203.0.113.5/IP_09_phishing_2026_Elisa dal gruppo Bad_IP_Phishing_Elisa_2026,
confermato a 11 membri totali) e la regola gemella `malicious_IP_12052025`
(allow->deny). Entrambe verificate scritte sul dispositivo senza necessita' di
un Apply separato. Introdotto su richiesta esplicita dell'utente un changelog
incrementale (`firewall-zyxel-usg-flex-500-live.conf`) che traccia 1:1, con
riferimento agli screenshot, ogni modifica live applicata via GUI, distinto dal
config target del 05/06/2026 (mai applicato in blocco). Rilevate due regole non
censite (BLOCCO_IP_SOSPETTI, EGETRAD_WEB_TEST) da riconciliare in seguito.
Aggiunto anche il gap NEB-001 (switch Nebula segnalati offline in modo
intermittente pur con rete dati funzionante, foto app Nebula dell'utente) con
ipotesi di correlazione a FW-008 (WAN_TRUNK/wan2 morto); nuovi micro-step M20
(diagnosi log) e M21 (ricontrollo dopo M7) in roadmap.md.
Prossimo micro-step: M2 (verifica console seriale/iLO, conferma 802.1Q) o M20
(diagnosi Nebula) a scelta dell'utente.

## 2026-07-01 — Ingestione "[TBC] Diagramma di rete e analisi firewall, centralino" + roadmap ottimizzazione (sessione 5)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/firewall-zyxel-usg-flex-500.md (stato applicazione, sei fasi, registro diagrammi, FW-011/FW-012)
  - docs/network-diagram.md (nota discrepanza NET-007, riferimento diagrammi)
  - docs/telefono-pbx-voip.md (provisioning Vianova Area Clienti, Vianova One, TEL-001)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voci datate 29/05, 05/06, 09/06)
  - docs/infrastructure-timeline/GAP-TBC.md (item 61/63 risolti, nuovi 97-100, totale 100)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce TBC ingestita, nota riallineamento)
  - .claude/context/roadmap.md (Fase 2 sostanzialmente completa, nuova Fase 3 a 19 micro-step M1-M19, rinumerazione Fase 4/5)
  - .claude/context/current-work.md (riscritto: focus Fase 3, domande aperte/risolte)
  - .claude/context/diagrams/firewall-dmz-2026/ (8 file drawio/svg archiviati, risolve FW-010)
Motivo: ingestione completa della cartella non tracciata "[TBC] Diagramma di rete e
analisi firewall, centralino" (tre snapshot datati 29/05, 05/06, 08/06/2026), su
richiesta esplicita dell'utente di completarla e poi cancellarla. Confermato con
l'utente che il piano di correzione firewall del 05/06/2026 e' una configurazione
target preparata, non ancora applicata al dispositivo fisico: le anomalie critiche
(regola phishing action=allow) restano aperte in produzione. Prodotta una roadmap
tracciata a micro-step (Fase 3) per l'ottimizzazione di Proxmox e del firewall,
sostituendo la Fase 3 generica precedente. Allineamento a
E:\template-claude-developing verificato (gap: skill init-project-system/onboard
e cartella templates/ mancanti) ma importazione rimandata su richiesta dell'utente.
Segnalata nella checklist di ingestione la deriva tra il "Riepilogo priorita'" e
le spunte reali, come richiesto dall'utente per riprendere l'ingestione OneDrive
IT in modo ordinato quando la Fase 3 sara' chiusa.
Cartella sorgente "[TBC] Diagramma di rete e analisi firewall, centralino" non
ancora eliminata: in attesa di conferma finale dell'utente a fine sessione.

## 2026-06-23 — Aggiornamento GAP-TBC e timeline (sessione 4)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/GAP-TBC.md (aggiunto TBC 68-95: NET, SEC, SCENIA, ISO)
  - docs/infrastructure-timeline/2024-infra.md (aggiunti: Bitdefender, SCENIA start, IntraLino)
  - docs/infrastructure-timeline/2025-q3-q4.md (aggiunti: Serafino, SCENIA→AIDAPT, MFA, Onova VA)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (aggiunti: Proelium, IntraLino Zep, SCENIA DPA, myOffice riunione)
Motivo: completamento ingestion — tutti gli eventi dal Piano Attività IT v3.xlsx e dai
documenti SCENIA/DPA sono ora mappati nelle timeline. GAP-TBC completo: 95 voci.

## 2026-06-22 — Feature batch e ingestion IT folder (sessione 3)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/network-diagram.md (nuovo - topologia ASCII completa)
  - docs/runbook-anomalie.md (nuovo - FW-001, FW-002, DMZ, AP, UPS runbook)
  - docs/vendor-management.md (nuovo - tutti i fornitori IT)
  - docs/design-and-security.md (nuovo - SoA ISO27001:2022 Annex A completa)
  - docs/cybersecurity-governance.md (nuovo - timeline 2024-2026 sicurezza)
  - docs/scenia-project.md (nuovo - timeline SCENIA + AIDAPT + DPA status)
  - docs/sviluppo-interno.md (nuovo - IntraLino RAG + scripting)
  - scripts/Check-SecurityAnomalies.ps1 (nuovo - check automatico anomalie)
  - .mcp.json (nuovo - ProxmoxMCP-Plus configurazione)
  - .claude/rules/git-commands-format.md (PowerShell only)
  - .claude/rules/git-identity-and-repo.md (PowerShell only)
  - .claude/PROJECT-SYSTEM.md (wipe script PowerShell)
Motivo: implementazione tutte 6 le feature proposte + 2 doc aggiuntivi timeline
biennale (cybersec-governance, scenia-project, sviluppo-interno).
Ingestion: ARCHITETTURA (10240 par), VA/PT, MFA plan, ISO27001 state, Serafino,
phishing, DPA/DPIA ScenIA, IntraLino Implementazione.docx, MEETINGS WITH AIDAPT.docx.
Template: allineati a Windows PowerShell 5.1 (rimossi blocchi bash/POSIX).

## 2026-06-22 — Inizializzazione del progetto

Commit: PENDING-FIRST-COMMIT
File toccati: tutta la struttura iniziale.
Motivo: creazione del progetto network-design. Struttura `.claude/` canonica dal template
portabile. Script Get-ProxmoxSnapshot.ps1 spostato da C:\Scripts\proxmox-snapshot.
Diagramma network-topology.mmd copiato dallo snapshot v3 di proxmox-snapshot.
Regole e skill copiate dal template. ADR 001-006 registrate. Due layer documentali
(narrativo locale + tecnico versionato). Angolo ISO27001. Skill docx-ingest per
ingestione progressiva dei Word. Agent iso27001-reviewer.
Identita git: asopranzi / asopranzi@intrawelt.com via alias SSH github-corp.
Remote: da configurare su git@github-corp:asopranzi-intrawelt/network-design.git
