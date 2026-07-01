---
last-verified: 2026-07-01
---

# Lavoro corrente: Fase 3 - Ottimizzazione Proxmox e firewall

## Stato

**M1 completato (01/07/2026).** Le due regole firewall critiche
(`Blocco_Gruppo_IP_Phishing_Elisa`, `malicious_IP_12052025`) sono state
corrette da `allow` a `deny` via GUI, guidate passo-passo con verifica
screenshot, e l'IP pubblico del firewall e' stato rimosso dal gruppo
`Bad_IP_Phishing_Elisa_2026`. Dettaglio 1:1 in
`docs/firewall-zyxel-usg-flex-500-live.conf`, il changelog incrementale del
firewall live. Il resto del piano di revisione DMZ/firewall (Fasi 1-6 del
05/06/2026) resta da applicare.

Aggiunto in corsa il gap **NEB-001**: gli switch Nebula risultano offline in
modo intermittente sul pannello cloud pur con rete dati funzionante, ipotesi
principale legata a FW-008 (WAN_TRUNK/wan2 morto). Nuovi micro-step M20/M21.

Racconto completo della sessione e convenzioni operative stabilite (workflow
screenshot, changelog live, un commit per micro-step) in
`_notes/RESUME-PROMPT.md`, da leggere per la ripresa narrativa oltre a questo
file.

Ingestione "[TBC] Diagramma di rete e analisi firewall, centralino" COMPLETATA
e cartella sorgente eliminata (01/07/2026). La roadmap (`.claude/context/roadmap.md`,
Fase 3) e' tracciata a 21 micro-step (M1-M21); M1 fatto, M2 e M20 sono i
prossimi due, indipendenti tra loro.

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

1. M2 (verifica console seriale/iLO, conferma 802.1Q su XGS2220-54HP) oppure
   M20 (diagnosi intermittenza Nebula, indipendente da M2) — a scelta
   dell'utente, entrambi guidati passo-passo con screenshot come M1.
2. Rieseguire `Get-ProxmoxSnapshot.ps1` per fotografare lo stato Proxmox
   corrente prima di procedere con M4-M5 (VLAN/bridge).
3. Alla chiusura di ogni micro-step: aggiornare la riga corrispondente in
   `roadmap.md`, appendere una voce a `memory/progress.md`, aggiornare
   `firewall-zyxel-usg-flex-500-live.conf` se il micro-step tocca il
   firewall, e lasciare che l'utente esegua il commit dedicato a quello step.
4. Nota di verita': lo stato "fatto/da fare" delle schede vive in
   `memory/index.md` e nel log di `memory/progress.md`, non nelle spunte di
   questo file.
