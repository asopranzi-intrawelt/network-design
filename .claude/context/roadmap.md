---
last-verified: 2026-06-22
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

## Fase 2 - Documentazione stato corrente (CORRENTE)

Obiettivo: documentare in modo completo la rete attuale integrando snapshot Proxmox
con configurazioni switch, firewall, AP e NAS. Produrre un diagramma di rete completo.

Steps:

1. Ingestare documenti Word secondari nella cartella ARCHITETTURA SERVER-CLOUD-LINEE
   Priorita': ZYXEL FIREWALL e VPN (configurazione firewall), Mappatura porte fisiche,
   Telefono-PBX, Diagramma di rete.

2. Ri-eseguire lo script Get-ProxmoxSnapshot.ps1 per aggiornare lo stato VM/bridge
   (output in output/, non versionato).

3. Documentare configurazione switch Zyxel via Nebula:
   XGS2220-54HP Piano 2: VLAN, porte, trunk, uplink verso firewall e Piano Terra.
   XGS2220-30HP Piano Terra: VLAN tagging fonia, uplink SFP+, DHCP class .10.

4. Documentare configurazione firewall Zyxel USG FLEX 500:
   Zone, interfacce (WAN1 Vianova, WAN2 dismessa), policy control attive,
   tunnel IPsec SEEWEB, VPN SSL (porte, certificato, utenti attivi).

5. Documentare NAS fleet: stato RAID, capacita', job backup, versioni firmware.

6. Produrre `docs/network-diagram.md` con diagramma ASCII della topologia corrente.

7. Completare gap analysis ISO27001 Annex A (aggiornare design-and-security.md).

## Fase 3 - Piano interventi futuri (DA PIANIFICARE)

Steps:
1. Attivare firewall Proxmox con policy di default DROP
2. Risolvere i TBC aperti nel GAP-TBC.md (screenshot, sezioni incomplete)
3. VLAN tagging Piano Terra: completare fonia e Wi-Fi segregato
4. Dismissione HP G5 (VMware ESXi) e migrazione VM su Proxmox
5. Migrazione centralino cloud Vianova (nuova fonia)
6. Patch management documentato (Proxmox, switch Nebula, firewall, NAS firmware)
7. Procedure backup e disaster recovery formali

## Fase 4 - Documentazione ISO27001 operativa (DA PIANIFICARE)

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
| Fase 2 | IN CORSO | Alta |
| Fase 3 | Da pianificare | Media |
| Fase 4 | Da pianificare | Media |
