# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 1ad2cb7 (HEAD al 07/07/2026, working tree con modifiche da committare)
Data snapshot:         2026-07-07
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | 1ad2cb7 | allineata |
| design-and-security.md | 1ad2cb7 | allineata (bonifica IP inclusa in 1ad2cb7) |
| deployment.md | 1ad2cb7 | allineata |
| dev-testing.md | 1ad2cb7 | allineata (bonifica IP inclusa in 1ad2cb7) |
| current-work.md | 1ad2cb7 | riscritta il 07/07: pivot su Fase 1bis (ingestione OneDrive) |
| roadmap.md | 1ad2cb7 | aggiornata il 07/07: Fase 3 sospesa, nuova Fase 1bis corrente |

## Punto di ripresa

Aggiornato il 07/07/2026 (sessione 7, in corso). **Pivot deciso dall'utente:
la Fase 3 operativa (M2/M20) e' sospesa; la fase corrente e' la 1bis, ripresa
dell'ingestione OneDrive IT** per costruire la timeline cronologica completa
dei due anni di ristrutturazione della rete. Dettaglio operativo in
`.claude/context/current-work.md`; stato ingestione e priorita' in
`docs/infrastructure-timeline/ingestion-checklist.md` (riallineata 07/07).

Fatto in questa sessione: ancoraggio schede e bonifica anonimizzazione dei
file vivi `.claude/` e degli otto diagrammi (commit 1ad2cb7); creato
`scripts/Check-OneDriveDelta.ps1` con baseline in `_notes/.onedrive-manifest.json`
e hook SessionStart in `settings.local.json` (il delta OneDrive arriva in
contesto a ogni avvio); delta 23/06-07/07 triato in checklist; ingestita la
voce GroupShare SR2+CU15 (timeline 06/07/2026).

Attesa dall'utente la nota PORT-TAGGING (tagging dei due switch per la
migrazione al centralino cloud): chiederla quando l'analisi cronologica
arriva a quel punto, dopo aver ingerito `Mappatura porte fisiche/`.

M1 resta l'unico micro-step Fase 3 chiuso. Fase B anonimizzazione (Fase 3bis)
non iniziata; riscrittura storia git rimandata a dopo la Fase B
(`_notes/.git-filter-replacements.txt` pronto, esteso il 07/07 con gli
username VPN).
