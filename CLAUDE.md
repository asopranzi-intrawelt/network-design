# network-design

> Istruzioni di team, versionate. Indice del progetto e procedura di ripresa.
> Le preferenze personali vivono in `CLAUDE.local.md`, ignorato da git, non qui.

## Cos'e' questo progetto

Progetto di documentazione e progettazione della rete Intrawelt. Raccoglie la storia
completa degli interventi infrastrutturali di rete, lo snapshot corrente dell'infrastruttura
Proxmox, la documentazione del firewall e degli altri componenti, e definisce gli step
di intervento futuri. La documentazione segue un doppio layer: narrativo (locale, in
`_notes/`) per le spiegazioni dettagliate e la storyline, e tecnico (versionato, in
`.claude/context/`) per i documenti strutturati. Il progetto adotta un angolo ISO27001
per la documentazione della sicurezza di rete.

## Procedura di ripresa in una sessione nuova

Leggere per primo `.claude/memory/index.md` (branch, commit di riferimento, stato schede,
punto di ripresa). Leggere poi `.claude/context/current-work.md` se c'e' una feature
attiva. Invocare la skill `sync-context` per verificare il drift tra schede e codice.
Leggere solo le schede pertinenti al task, mai tutte insieme. Per documenti Word voluminosi
usare la skill `docx-ingest` che applica la disclosure progressiva (livello 1: TOC, livello
2: sezioni chiave, livello 3: sezione completa su richiesta).

## Due layer documentali

Il layer narrativo vive in `_notes/`, ignorato da git: contiene spiegazioni dettagliate,
diario operativo, resoconto esteso, trascrizioni e materiale grezzo. Non va in git perche'
e' narrativo, personale e spesso voluminoso.

Il layer tecnico vive in `.claude/context/` e `docs/`, versionato: contiene le schede
strutturate con frontmatter di riconciliazione, i diagrammi, la timeline degli interventi
in formato Markdown, la documentazione ISO27001. E' la fonte di verita' recuperabile da
un clone.

## Script Proxmox

`scripts/Get-ProxmoxSnapshot.ps1` interroga l'API REST di Proxmox VE (IP reale in
`_notes/.anonymization-map.md`, non qui: repo pubblico) e produce lo snapshot completo
dell'infrastruttura in `output/proxmox-snapshot.json` e `output/proxmox-config.md`.
L'output e' ignorato da git (dati infrastrutturali sensibili). Eseguire dalla radice
del progetto passando l'host reale a `-ProxmoxHost` (vedi `.claude/rules/anonymization.md`).

## Script di controllo delta OneDrive

`scripts/Check-OneDriveDelta.ps1` confronta la cartella OneDrive "Documenti - IT"
con una baseline locale (`_notes/.onedrive-manifest.json`, ignorata da git perche'
contiene nomi di file reali) e riporta file nuovi, modificati ed eliminati rispetto
all'ultimo triage della checklist di ingestione
(`docs/infrastructure-timeline/ingestion-checklist.md`). Gira automaticamente a ogni
avvio di sessione tramite hook SessionStart in `.claude/settings.local.json` (non
versionato, percorsi di macchina). Dopo aver registrato in checklist le variazioni
segnalate, rieseguirlo con `-UpdateBaseline`.

## Indice dei file satellite tracciati

Memoria e meta-stato, sotto `.claude/memory/`, letti sempre a inizio sessione.

```
.claude/memory/index.md       snapshot e tabella di sincronizzazione, da leggere per primo
.claude/memory/progress.md    work-log append-only di passi e riconciliazioni
.claude/memory/decisions.md   registro ADR-lite delle decisioni architetturali
```

Schede tecniche, sotto `.claude/context/`, con frontmatter di riconciliazione.

```
.claude/context/STACK.md                stack, script, ruolo architetturale dei file
.claude/context/design-and-security.md  paradigmi ISO27001, sicurezza di rete
.claude/context/deployment.md           esecuzione script, aggiornamento snapshot
.claude/context/dev-testing.md          verifica output snapshot, casi limite
.claude/context/current-work.md         feature attiva, definition of done
.claude/context/roadmap.md              fasi del progetto, timeline interventi
.claude/context/diagrams/               topologie di rete e diagrammi infrastrutturali
```

Documentazione strutturata, sotto `docs/`.

```
docs/infrastructure-timeline/   storia cronologica degli interventi di rete
```

Regole modulari caricate su necessita', sotto `.claude/rules/`.

```
.claude/rules/interaction-style.md     stile di documentazione e di risposta (caricare sempre)
.claude/rules/token-economy.md         pratiche di risparmio di contesto (caricare sempre)
.claude/rules/git-identity-and-repo.md profili SSH, identita git, bootstrap del remoto
.claude/rules/manual-screenshots.md    flusso di cattura screenshot per verifica visiva
.claude/rules/anonymization.md         anonimizzazione IP/MAC/nomi propri (repo pubblico, caricare sempre)
```

Skill richiamabili, sotto `.claude/skills/`.

```
.claude/skills/sync-context/    verifica drift schede vs codice; usare a inizio sessione
.claude/skills/repo-status/     riepilogo branch, commit recenti, diff non committato
.claude/skills/git-sync/        aggiorna contesto dopo un git pull o merge
.claude/skills/docx-ingest/     ingestione progressiva di documenti Word voluminosi
```

Agent specializzati, sotto `.claude/agents/`.

```
.claude/agents/iso27001-reviewer/   verifica aderenza ISO27001 della documentazione
```

## Vincoli di team

Le operazioni di git add, commit e push restano sempre manuali dell'utente. L'identita'
git e' impostata a livello locale del repo secondo `.claude/rules/git-identity-and-repo.md`.
Lo stile di documentazione e' quello di `.claude/rules/interaction-style.md`. Lo standard
di sistema completo e' in `.claude/PROJECT-SYSTEM.md`.

## Nota MCP

ProxmoxMCP-Plus (interrogazione Proxmox in tempo reale) e' valutabile in questo progetto
per le sessioni di design attivo. Configurazione: creare `.mcp.json` in radice quando
necessario, mai sotto `.claude/`. Non configurato nella fase attuale.
