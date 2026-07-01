---
last-verified: 2026-07-01
---

# Lavoro corrente: Fase 3 - Ottimizzazione Proxmox e firewall

## Stato

**Ingestione "[TBC] Diagramma di rete e analisi firewall, centralino" COMPLETATA
(01/07/2026).** La cartella (radice progetto, non OneDrive) copriva tre snapshot
datati (29/05, 05/06, 08/06 "steps") dell'analisi firewall Zyxel USG FLEX 500,
del piano di revisione DMZ/Proxmox e del provisioning del centralino cloud
Vianova. Contenuto integralmente riversato nella documentazione tecnica; la
cartella sorgente resta in attesa di conferma finale dell'utente per la
cancellazione (era marcata [TBC] esplicitamente per essere ingestita e rimossa).

La roadmap di ottimizzazione (`.claude/context/roadmap.md`, Fase 3) e' ora
tracciata a 19 micro-step (M1-M19), a partire dalla correzione critica della
regola firewall `Blocco_Gruppo_IP_Phishing_Elisa` (M1), ancora attiva in
produzione con `action allow` invece di `deny`.

## File toccati in questa sessione (01/07/2026)

| File | Modifica |
|------|----------|
| `docs/firewall-zyxel-usg-flex-500.md` | Stato "piano non applicato", sei fasi dettagliate, registro diagrammi, anomalie FW-011/FW-012 |
| `docs/network-diagram.md` | Nota discrepanza porta Potalivo (NET-007), riferimento diagrammi archiviati |
| `docs/telefono-pbx-voip.md` | Provisioning Area Clienti Vianova, Vianova One, decisione IVR aperta (TEL-001) |
| `docs/infrastructure-timeline/2026-switch-piano-terra.md` | Voci datate 29/05, 05/06, 09/06 sostituiscono i TBC precedenti |
| `docs/infrastructure-timeline/GAP-TBC.md` | Item 61/63 risolti, nuovi item 97-100 |
| `docs/infrastructure-timeline/ingestion-checklist.md` | Voce ingestione TBC, nota di riallineamento sul riepilogo priorita' stale |
| `.claude/context/roadmap.md` | Fase 2 marcata sostanzialmente completa, nuova Fase 3 a micro-step, rinumerazione Fase 4/5 |
| `.claude/context/diagrams/firewall-dmz-2026/` | 8 file drawio/svg archiviati dalla cartella TBC |

## Domande aperte risolte in questa sessione

- Il file `startup-config.conf` del 05/06/2026 e' una configurazione **target
  preparata**, non un backup post-applicazione: confermato con l'utente. Le
  anomalie critiche del firewall restano aperte in produzione.
- Allineamento a `E:\template-claude-developing`: skill `init-project-system`,
  `onboard` e cartella `templates/` mancanti, importazione **rimandata** su
  richiesta esplicita dell'utente per dare priorita' all'ottimizzazione di rete.

## Domande aperte non risolte

- Contraddizione porta/switch del telefono di Alessandro Potalivo (NET-007,
  M10 in roadmap).
- Testo IVR per il centralino cloud non ancora comunicato a myOffice (TEL-001,
  M17 in roadmap).
- Funzione esatta della porta 8 riconfigurata "Vianova DHCP server fonia"
  (FW-012, M11 in roadmap).

## Prossimi step

1. Eseguire M1 (correzione regola phishing) — richiede accesso GUI firewall,
   operazione dell'utente, non delegabile all'agente.
2. Rieseguire `Get-ProxmoxSnapshot.ps1` per fotografare lo stato Proxmox
   corrente prima di procedere con M4-M5 (VLAN/bridge).
3. Alla chiusura di ogni micro-step: aggiornare la riga corrispondente in
   `roadmap.md`, appendere una voce a `memory/progress.md`, e lasciare che
   l'utente esegua il commit dedicato a quello step.
4. Nota di verita': lo stato "fatto/da fare" delle schede vive in
   `memory/index.md` e nel log di `memory/progress.md`, non nelle spunte di
   questo file.
