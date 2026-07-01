---
last-verified: 2026-07-01
---

# Roadmap e fasi del progetto

## Fase 0 - Inizializzazione (COMPLETATA)

- Struttura progetto e template `.claude/` canonica
- Script snapshot Proxmox v3 integrato
- Snapshot infrastruttura v3 come baseline corrente
- Due layer documentali (narrativo + tecnico) configurati
- Primo commit e push su git@github-corp:asopranzi-intrawelt/network-design.git

## Fase 1 - Ricostruzione storia della rete (COMPLETATA)

Documento Word principale (ARCHITETTURA SERVER-CLOUD-LINEE 20052026.docx) ingestato
con strategia a disclosure progressiva. Estratte 12 sezioni prioritarie.

Output prodotto in `docs/infrastructure-timeline/`:
- 2023-baseline.md: stato di partenza pre-IT-manager
- 2024-infra.md: ottobre-dicembre 2024
- 2025-q1-server-vianova.md: gennaio-marzo 2025
- 2025-q2-migrazione-tim-vianova.md: aprile-giugno 2025 (switch WAN, tunnel SEEWEB)
- 2025-q3-q4.md: luglio-dicembre 2025
- 2026-switch-piano-terra.md: gennaio-giugno 2026
- GAP-TBC.md: 53 TBC censiti con fonte probabile

Credenziali e IP pubblici anonimizzati per repo pubblico su GitHub.

Documenti Word secondari da ingestare (rimandati a Fase 2):
- Mappatura porte fisiche
- Telefono-PBX
- ZYXEL FIREWALL e VPN
- [TBC] Diagramma di rete

## Fase 2 - Documentazione stato corrente (SOSTANZIALMENTE COMPLETATA)

Obiettivo: documentare in modo completo la rete attuale integrando snapshot Proxmox
con configurazioni switch, firewall, AP e NAS. Produrre un diagramma di rete completo.

Steps:

1. **Fatto.** Documenti Word secondari della cartella ARCHITETTURA SERVER-CLOUD-LINEE
   ingestati (Telefono-PBX, ZYXEL FIREWALL e VPN, licenze). Il documento
   "[TBC] Diagramma di rete e analisi firewall, centralino" (cartella separata in
   radice progetto, non OneDrive) e' stato ingestato integralmente il 01/07/2026:
   vedi `docs/infrastructure-timeline/ingestion-checklist.md` e i riferimenti
   incrociati in `docs/firewall-zyxel-usg-flex-500.md`, `docs/network-diagram.md`,
   `docs/telefono-pbx-voip.md`.

2. Ri-eseguire lo script Get-ProxmoxSnapshot.ps1 per aggiornare lo stato VM/bridge
   (output in output/, non versionato). **Da rifare** prima di iniziare la Fase 3,
   perche' i micro-step su Proxmox richiedono lo stato corrente reale, non quello
   della v3 storica.

3. **Fatto.** Configurazione switch Zyxel via Nebula documentata in
   `docs/network-diagram.md` e `docs/infrastructure-timeline/2026-switch-piano-terra.md`
   (XGS2220-54HP Piano 2, XGS2220-30HP Piano Terra installato aprile 2026,
   dorsale 10 Gbps operativa dall'08/05/2026).

4. **Fatto, ma piano non applicato.** Configurazione firewall Zyxel USG FLEX 500
   documentata in dettaglio in `docs/firewall-zyxel-usg-flex-500.md` (zone,
   interfacce, VPN, NAT, security policy, dieci anomalie FW-001/FW-010). Il piano
   di correzione a sei fasi (05/06/2026) resta da applicare: vedi Fase 3.

5. NAS fleet: stato RAID, capacita', job backup, versioni firmware. **Parziale**,
   copre solo gli eventi puntuali della timeline (guasto/sostituzione INTRA2,
   migrazione a fibra 10GbE). Inventario sistematico rimandato.

6. **Fatto.** `docs/network-diagram.md` con diagramma ASCII della topologia corrente.
   Consolidamento in Mermaid versionato (`context/diagrams/network-topology.mmd`)
   rimandato alla fine della Fase 3, per aggiornarlo una sola volta con lo stato
   finale invece che a ogni micro-intervento (vedi nota "Diagramma vivo" sotto).

7. Completare gap analysis ISO27001 Annex A (aggiornare design-and-security.md).
   Non ancora ripreso in questa sessione.

## Fase 3 - Ottimizzazione Proxmox e firewall: roadmap a micro-step (CORRENTE)

Obiettivo: applicare le correzioni e le ottimizzazioni identificate dall'analisi
firewall/DMZ/Proxmox, un micro-step alla volta, con commit e aggiornamento di
`memory/progress.md` a ogni step chiuso. Ogni riga della tabella e' un intervento
singolo, verificabile, con un solo esito atteso: non si passa alla riga successiva
finche' quella corrente non e' verificata o esplicitamente rimandata con nota.

### Diagramma vivo

In parallelo a ogni micro-step, `docs/network-diagram.md` e la tabella diagrammi
di `docs/firewall-zyxel-usg-flex-500.md` si aggiornano con una nota testuale del
cambiamento (non un nuovo diagramma renderizzato a ogni step, per non consumare
token inutilmente). Il diagramma Mermaid consolidato in
`.claude/context/diagrams/network-topology.mmd` si rigenera una sola volta, a
fine Fase 3, riflettendo lo stato finale post-ottimizzazione; i drawio/svg
intermedi restano come riferimento storico in `context/diagrams/firewall-dmz-2026/`.

### Version control

Ogni micro-step chiuso corrisponde a un commit separato (manuale, a cura
dell'utente secondo `.claude/rules/git-commands-format.md`), cosi' che la
storia git rispecchi la sequenza degli interventi fisici sulla rete e non un
unico commit cumulativo di fine fase.

### Micro-step tracciati

| # | Intervento | Priorita' | Gap/fonte | Dipendenza | Stato |
|---|-----------|-----------|-----------|------------|-------|
| M1 | Correggere `Blocco_Gruppo_IP_Phishing_Elisa` (allow -> deny) e `malicious_IP_12052025` (allow -> deny) via GUI firewall, fuori finestra di manutenzione | CRITICA | FW-001, FW-002 (Fase 0 del piano) | Nessuna | **Fatto 01/07/2026** |
| M2 | Verificare fisicamente console seriale (115200 baud) e accesso iLO; confermare supporto 802.1Q su XGS2220-54HP | ALTA | Fase 1 del piano | M1 | Da fare |
| M3 | Backup datato di firewall e switch prima di ogni modifica strutturale | ALTA | Fase 1 del piano | M2 | Da fare |
| M4 | Configurare VLAN 201 sullo switch Piano 2 (P7 access, porta Proxmox trunk) | ALTA | Fase 2 del piano, FW-009 | M3 | Da fare |
| M5 | Configurare bridge-vlan-aware su Proxmox (`ifreload -a` da iLO), VM di test con tag 201 | ALTA | Fase 3 del piano | M4 | Da fare |
| M6 | Cablare P7 verso lo switch, validare L2 con `arping`/`tcpdump` | ALTA | Fase 4 del piano | M5 | Da fare |
| M7 | Caricare la configurazione target dal seriale (rimozione WAN_TRUNK, rimozione LAN2 e rotte statiche, attivazione DMZ, pubblicazione web `wan1:2`) | CRITICA | Fase 5 del piano, FW-004, FW-008, FW-009 | M6 | Da fare |
| M8 | Verifica post-applicazione nell'ordine di impatto utente (LAN, SSL VPN, IPsec, VM DMZ) + 48h di osservazione log | ALTA | Fase 6 del piano | M7 | Da fare |
| M9 | Prima VM DMZ operativa (nginx reverse proxy 192.168.201.10, esposta su 193.124.241.3) | MEDIA | Piano_Operativo_Migrazione.docx | M8 | Da fare |
| M10 | Verificare quale switch ospita realmente la porta del telefono di Alessandro Potalivo (contraddizione Piano 2 vs Piano Terra) prima di chiudere la mappatura IP/MAC telefoni | MEDIA | NET-007, GAP-TBC #67 | Nessuna (indipendente dal piano firewall) | Da fare |
| M11 | Verificare la funzione della porta 8 riconfigurata "Vianova DHCP server fonia" (PVID 2) e valutare se sostituisce la rimozione del DHCP server classe .90 | MEDIA | FW-012 | M10 | Da fare |
| M12 | Rimuovere il DHCP server residuo classe .90 e spostare lo switch di management (192.168.90.37) sulla VLAN corretta | ALTA | NET-001, NET-004, NET-005 | M11 | Da fare |
| M13 | Segmentare la VLAN Wi-Fi "intrawelt" dalla classe .90, isolamento reale da LAN/management | MEDIA | NET-005 | M12 | Da fare |
| M14 | Aggiornare le VPN IPsec da IKEv1/AES-128/SHA-1/DH2 a parametri correnti; chiarire se PSE-SEEWEB e WIZ_VPN sono transizione o residuo | MEDIA | FW-006, FW-007 | M8 | Da fare |
| M15 | Attivare firewall Proxmox con policy di default DROP | MEDIA | Fase 3 originale (roadmap storica) | M9 | Da fare |
| M16 | Dismissione HP G5 (VMware ESXi) e migrazione VM residue su Proxmox | MEDIA | GAP-TBC #10, #195 (sec-007) | Indipendente | Da fare |
| M17 | Rispondere a myOffice sul testo IVR (giorno: attesa semplice o instradamento reparti; notte: orari) e completare la migrazione centralino cloud | MEDIA | TEL-001, GAP-TBC #47 | Indipendente (traccia telefonia, non firewall) | Da fare |
| M18 | Rigenerare `output/proxmox-snapshot.json` con `Get-ProxmoxSnapshot.ps1` per fotografare lo stato Proxmox post-M5/M16 | ALTA | Fase 2 step 2 | M5, M16 | Da fare |
| M19 | Consolidare il diagramma Mermaid finale (`network-topology.mmd`) con lo stato post-ottimizzazione e riconciliare tutte le schede tecniche coinvolte | BASSA (fine fase) | Chiusura Fase 3 | M1-M18 | Da fare |
| M20 | Diagnosticare l'intermittenza "offline" degli switch su Nebula (rete dati funzionante, solo il canale di gestione cade): raccogliere orari degli eventi offline da Nebula e correlarli con i log del firewall (failover wan2, eventi SSL inspection sul traffico verso il cloud Zyxel) | MEDIA | NEB-001 | Nessuna (diagnosi indipendente da M1-M9) | Da fare |
| M21 | Ricontrollare M20 dopo l'esecuzione di M7 (rimozione WAN_TRUNK): se l'intermittenza sparisce, FW-008 era la causa; se persiste, approfondire l'ipotesi SSL inspection | MEDIA | NEB-001 | M7, M20 | Da fare |

## Fase 4 - Piano interventi futuri residui (DA PIANIFICARE)

Steps non coperti dalla Fase 3, da pianificare dopo la chiusura dei micro-step
sopra:
1. Patch management documentato (Proxmox, switch Nebula, firewall, NAS firmware)
2. Procedure backup e disaster recovery formali
3. Inventario sistematico NAS fleet (RAID, capacita', firmware)
4. Ripresa dell'ingestione della cartella OneDrive IT (sospesa su richiesta
   esplicita dell'utente per dare priorita' alla Fase 3; vedi nota di
   riallineamento in `ingestion-checklist.md`)

## Fase 5 - Documentazione ISO27001 operativa (DA PIANIFICARE)

Steps:
1. Statement of Applicability per i controlli Annex A di rete
2. Risk assessment per i gap identificati (A.8.20, A.8.22, A.8.16, A.5.37, A.8.8)
3. Procedure operative per interventi ricorrenti (backup, patching, accessi VPN)
4. Incident response per scenari rilevanti (basato su evento phishing 08/01/2026)

## Stato riepilogativo

| Fase | Stato | Priorita' |
|---|---|---|
| Fase 0 | COMPLETATA | Alta |
| Fase 1 | COMPLETATA | Alta |
| Fase 2 | Sostanzialmente completata (residuo: NAS fleet, ISO27001 Annex A) | Alta |
| Fase 3 | CORRENTE — 19 micro-step tracciati, M1 completato 01/07/2026 (fix regola phishing via GUI), M2 successivo | Critica |
| Fase 4 | Da pianificare | Media |
| Fase 5 | Da pianificare | Media |
