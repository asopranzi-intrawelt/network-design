# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 207690c (HEAD al 01/07/2026; modifiche di questa sessione non ancora committate)
Data snapshot:         2026-07-01
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante cinque commit successivi (fino a 207690c, 24/06/2026).
Il riferimento e' stato riportato a HEAD in questa sessione; da qui in avanti
va aggiornato a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | PENDING-FIRST-COMMIT | da ancorare (nessuna modifica sostanziale dal 2026-06-22, ma il commit va ancorato) |
| design-and-security.md | PENDING-FIRST-COMMIT | da ancorare |
| deployment.md | PENDING-FIRST-COMMIT | da ancorare |
| dev-testing.md | PENDING-FIRST-COMMIT | da ancorare |
| current-work.md | 2026-07-01 | aggiornata questa sessione |
| roadmap.md | 2026-07-01 | aggiornata questa sessione (Fase 3 a micro-step) |

## Punto di ripresa

Ingestione della cartella "[TBC] Diagramma di rete e analisi firewall,
centralino" completata il 01/07/2026 (vedi `memory/progress.md`). Roadmap di
ottimizzazione Proxmox/firewall tracciata in `context/roadmap.md`, Fase 3,
19 micro-step (M1-M19). Prossima azione concreta: M1, correzione della regola
firewall `Blocco_Gruppo_IP_Phishing_Elisa` (action allow -> deny), operazione
manuale dell'utente sulla GUI del firewall, non delegabile all'agente.

In sospeso: conferma finale dell'utente per la cancellazione della cartella
sorgente "[TBC] Diagramma di rete e analisi firewall, centralino" (contenuto
integralmente riversato in docs/ e in `context/diagrams/firewall-dmz-2026/`).
In sospeso anche il commit di tutte le modifiche di questa sessione, a cura
dell'utente.

Invocare `sync-context` alla prossima sessione per verificare drift tra
STACK.md/design-and-security.md/deployment.md/dev-testing.md e il codice reale,
e per ancorare i `last-verified` rimasti a `PENDING-FIRST-COMMIT`.
