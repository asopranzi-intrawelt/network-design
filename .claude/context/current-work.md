---
last-verified: 2026-07-01
---

# Lavoro corrente: Fase 3 - Ottimizzazione Proxmox e firewall

## Stato

**Sessione chiusa il 01/07/2026 con working tree pulito** (HEAD 7811e93,
pushato). Due blocchi di lavoro completati in questa sessione, entrambi
descritti per esteso in `_notes/RESUME-PROMPT.md`.

**M1 completato.** Le due regole firewall critiche
(`Blocco_Gruppo_IP_Phishing_Elisa`, `malicious_IP_12052025`) sono state
corrette da `allow` a `deny` via GUI, guidate passo-passo con verifica
screenshot, e l'IP pubblico del firewall e' stato rimosso dal gruppo
`Bad_IP_Phishing_Elisa_2026`. Dettaglio 1:1 in
`docs/firewall-zyxel-usg-flex-500-live.conf`, il changelog incrementale del
firewall live. Il resto del piano di revisione DMZ/firewall (Fasi 1-6 del
05/06/2026) resta da applicare.

**Anonimizzazione Fase A completata.** Il repository e' pubblico su GitHub
(verificato via API). IP pubblici/privati, MAC address e nomi propri reali
sono stati sostituiti con placeholder nel perimetro network-design attivo
(sei file `docs/` piu' `CLAUDE.md`, `STACK.md`, `deployment.md`,
`network-topology.mmd` e gli 8 diagrammi in `context/diagrams/firewall-dmz-2026/`).
Convenzione vincolante per ogni nuova scrittura in `.claude/rules/anonymization.md`
(caricare sempre): niente IP reali, niente MAC reali, niente nomi propri
completi nei file tracciati. La mappatura reale vive in
`_notes/.anonymization-map.md`, mai versionata. Fase B (il resto del
repository: SCENIA, cybersecurity, helpdesk, timeline storica) e' tracciata
come Fase 3bis in `roadmap.md` ma non iniziata: workstream a parte.

Aggiunto in corsa il gap **NEB-001**: gli switch Nebula risultano offline in
modo intermittente sul pannello cloud pur con rete dati funzionante, ipotesi
principale legata a FW-008 (WAN_TRUNK/wan2 morto). Nuovi micro-step M20/M21.

## Prossimi step

1. M2 (verifica console seriale/iLO, conferma 802.1Q su XGS2220-54HP) oppure
   M20 (diagnosi intermittenza Nebula, indipendente da M2) — a scelta
   dell'utente, entrambi guidati passo-passo con screenshot come M1.
2. Ogni nuova scheda o voce di timeline scritta da qui in avanti segue
   `.claude/rules/anonymization.md`: placeholder per IP/MAC/nomi, mai il
   valore reale, verificato con un grep mirato prima di considerare il passo
   chiuso.
3. Rieseguire `Get-ProxmoxSnapshot.ps1` per fotografare lo stato Proxmox
   corrente prima di procedere con M4-M5 (VLAN/bridge); l'output resta
   ignorato da git (dati reali, mai da anonimizzare in un file non tracciato).
4. Alla chiusura di ogni micro-step: aggiornare la riga corrispondente in
   `roadmap.md`, appendere una voce a `memory/progress.md`, aggiornare
   `firewall-zyxel-usg-flex-500-live.conf` se il micro-step tocca il
   firewall, e lasciare che l'utente esegua il commit dedicato a quello step.
5. Nota di verita': lo stato "fatto/da fare" delle schede vive in
   `memory/index.md` e nel log di `memory/progress.md`, non nelle spunte di
   questo file. Il racconto esteso vive in `_notes/RESUME-PROMPT.md`.

## Domande aperte non risolte

- Contraddizione porta/switch del telefono di Persona-A (NET-007, M10 in
  roadmap): probabile errore di etichettatura, non spostamento fisico reale.
- Testo IVR per il centralino cloud non ancora comunicato a myOffice (TEL-001,
  M17 in roadmap).
- Funzione esatta della porta 8 riconfigurata "Vianova DHCP server fonia"
  (FW-012, M11 in roadmap).
- Allineamento a `E:\template-claude-developing`: skill `init-project-system`,
  `onboard` e cartella `templates/` mancanti, importazione rimandata su
  richiesta esplicita dell'utente.
