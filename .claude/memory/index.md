# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 34a9dd7 (HEAD al 07/07/2026, working tree con modifiche da committare)
Data snapshot:         2026-07-07
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | 34a9dd7 | ancorata il 2026-07-07, contenuto invariato |
| design-and-security.md | 34a9dd7 | ancorata il 2026-07-07, corretti IP privati reali residui (subnet server) |
| deployment.md | 34a9dd7 | ancorata il 2026-07-07, contenuto invariato |
| dev-testing.md | 34a9dd7 | ancorata il 2026-07-07, corretto IP iLO reale residuo |
| current-work.md | 34a9dd7 | allineata (aggiornata dal commit di chiusura del 01/07) |
| roadmap.md | 34a9dd7 | ancorata il 2026-07-07, corretti IP reali e un nome proprio (M9, M10, M12) |

## Punto di ripresa

Sessione chiusa il 01/07/2026 con working tree pulito (`git status` senza
modifiche pendenti, HEAD 7811e93, pushato). Racconto narrativo completo e
convenzioni operative in `_notes/RESUME-PROMPT.md`: leggerlo subito dopo
questo file per il contesto esteso prima di agire.

In sintesi: **M1 fatto** (due regole firewall corrette allow->deny, changelog
in `docs/firewall-zyxel-usg-flex-500-live.conf`). **Anonimizzazione Fase A
fatta** (repository pubblico confermato via API GitHub; IP/MAC/nomi propri
sostituiti nel perimetro network-design + file di contesto con lo stesso IP
Proxmox; convenzione in `.claude/rules/anonymization.md`, sempre da applicare
a ogni nuova scrittura). Prossima azione concreta, a scelta dell'utente: **M2**
(verifica console seriale/iLO, prerequisito 802.1Q) oppure **M20** (diagnosi
intermittenza Nebula, indipendente). Nessuna delle due e' stata ancora avviata.

Fase B (anonimizzazione del resto del repository, SCENIA/cybersecurity/helpdesk/
timeline storica) e' tracciata in `roadmap.md` come Fase 3bis ma non iniziata:
e' un workstream a parte, non da fare in coda a un'altra sessione. La
riscrittura della storia git (`_notes/.git-filter-replacements.txt`, non
versionato) resta rimandata a dopo la Fase B, per un solo force-push invece
di due.

Invocare `sync-context` quando si riprende a lavorare su STACK.md,
design-and-security.md, deployment.md o dev-testing.md, per ancorarne i
`last-verified` rimasti a `PENDING-FIRST-COMMIT`.
