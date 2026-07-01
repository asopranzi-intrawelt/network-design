# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 7811e93 (HEAD al 01/07/2026, tutto committato e pushato)
Data snapshot:         2026-07-01
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | PENDING-FIRST-COMMIT | da ancorare (toccata solo per anonimizzazione IP, contenuto sostanziale invariato dal 2026-06-22) |
| design-and-security.md | PENDING-FIRST-COMMIT | da ancorare |
| deployment.md | PENDING-FIRST-COMMIT | da ancorare (idem STACK.md) |
| dev-testing.md | PENDING-FIRST-COMMIT | da ancorare |
| current-work.md | 2026-07-01 | aggiornata questa sessione |
| roadmap.md | 2026-07-01 | aggiornata questa sessione (Fase 3 a micro-step, Fase 3bis anonimizzazione) |

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
