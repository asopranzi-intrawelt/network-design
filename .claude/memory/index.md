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

M1 della roadmap (Fase 3) completato il 01/07/2026: regole
`Blocco_Gruppo_IP_Phishing_Elisa` e `malicious_IP_12052025` corrette da allow
a deny via GUI, guidato passo-passo con verifica screenshot, changelog in
`docs/firewall-zyxel-usg-flex-500-live.conf`. Prossima azione concreta: M2
(verifica console seriale/iLO, conferma 802.1Q su XGS2220-54HP), oppure il
nuovo micro-step segnalato dall'utente sull'intermittenza Nebula degli switch
(vedi `context/roadmap.md`, da inserire nella tabella micro-step).

Cartella sorgente "[TBC] Diagramma di rete e analisi firewall, centralino"
eliminata dall'utente dopo l'ingestione completa (contenuto integralmente
riversato in docs/ e in `context/diagrams/firewall-dmz-2026/`).

In sospeso: commit di tutte le modifiche di questa sessione (sessioni 5 e 6),
a cura dell'utente. Comandi git proposti nella chat, non ancora eseguiti al
momento di questo snapshot.

Invocare `sync-context` alla prossima sessione per verificare drift tra
STACK.md/design-and-security.md/deployment.md/dev-testing.md e il codice reale,
e per ancorare i `last-verified` rimasti a `PENDING-FIRST-COMMIT`.
