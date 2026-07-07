# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 68216f0 (HEAD al 07/07/2026, sync schede + WindTre; delta MEDIA in commit successivo)
Data snapshot:         2026-07-07
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | 594ec07 | allineata |
| design-and-security.md | 594ec07 | allineata |
| deployment.md | 594ec07 | allineata |
| dev-testing.md | 594ec07 | allineata |
| current-work.md | 594ec07 | aggiornata da sync-context: voci ALTA chiuse, prossimo blocco delta MEDIA |
| roadmap.md | 594ec07 | allineata (M11 parziale registrato in 552d96c) |

## Punto di ripresa

Aggiornato il 07/07/2026 (sessione 7, in corso). **Pivot deciso dall'utente:
la Fase 3 operativa (M2/M20) e' sospesa; la fase corrente e' la 1bis, ripresa
dell'ingestione OneDrive IT** per costruire la timeline cronologica completa
dei due anni di ristrutturazione della rete. Dettaglio operativo in
`.claude/context/current-work.md`; stato ingestione e priorita' in
`docs/infrastructure-timeline/ingestion-checklist.md` (riallineata 07/07).

Fatto nelle sessioni del 07/07: gestione delta OneDrive con hook di avvio e
ingestione GroupShare (6e1d4b6); mappatura porte fisiche completa da rilievo
2020 e xlsx 2026 (6d65a87); tagging in corso con gap 102-104, architettura
LAN telefoni Vianova e audit crittografia (552d96c); delta SCENIA con
Allegati A-L, DPIA compilata e Risposte Tecniche AIDAPT (594ec07); sync
schede e revisione WindTre con BitLocker endpoint (68216f0); tutte le voci
MEDIA del delta ingerite in sessione 8 (ABBYY, Checklist/call SCENIA,
benchmark IntraLino, gap 105-107). Prossimo blocco: MEDIA preesistenti in
ordine cronologico delle fonti (elenco in current-work.md, step 3).

La nota PORT-TAGGING (tagging dei due switch per la migrazione al centralino
cloud) resta in attesa: il racconto completo arriva a lavori conclusi, quando
gli endpoint telefonici funzioneranno; le evidenze sono gia' raccolte in
`_notes/[TBC] screenshot e note myoffice/`.

M1 resta l'unico micro-step Fase 3 chiuso. Fase B anonimizzazione (Fase 3bis)
non iniziata; riscrittura storia git rimandata a dopo la Fase B
(`_notes/.git-filter-replacements.txt` pronto, esteso il 07/07 con gli
username VPN).
