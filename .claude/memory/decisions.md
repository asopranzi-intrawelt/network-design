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
