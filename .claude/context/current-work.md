---
last-verified: 2026-06-23
---

# Lavoro corrente: Fase 4 – GAP-TBC e timeline complete

## Stato

**Fase 4 COMPLETATA.** GAP-TBC aggiornato a 95 voci. Timeline biennale completa
con tutti gli eventi cybersecurity, SCENIA, IntraLino, Proelium.
Commit da fare manualmente dall'utente (tutte le sessioni 1-4 insieme).

## File prodotti in Fase 3

| File | Stato | Note |
|------|-------|------|
| `docs/network-diagram.md` | Completo | Topologia ASCII: FW, switch, NAS, AP, VLAN, DMZ, VPN |
| `docs/runbook-anomalie.md` | Completo | FW-001, FW-002, DMZ VLAN 201, AP Debian7, UPS guest |
| `docs/vendor-management.md` | Completo | Vianova, Zyxel, Punto Info, NinjaOne, Bitdefender, Seeweb, M365, Onova, Proelium, RWS, QNAP, Aruba, Serafino |
| `docs/design-and-security.md` | Completo | SoA ISO27001:2022 Annex A (tutti i controlli A.5-A.18) |
| `docs/cybersecurity-governance.md` | Completo | Timeline sicurezza 2024-2026: MFA, VA, ISO27001, Bitdefender |
| `docs/scenia-project.md` | Completo | Timeline SCENIA ott2024-giu2026, stack, DPA v1.7, gap sicurezza |
| `docs/sviluppo-interno.md` | Completo | IntraLino (Ollama+ChromaDB+n8n), scripting, automazioni |
| `scripts/Check-SecurityAnomalies.ps1` | Completo | Check FW-001, FW-002, UPS, EOL, Proxmox snapshot, MFA |
| `.mcp.json` | Completo | ProxmoxMCP (uvx proxmox-mcp, 192.168.20.11:8006, PROXMOX_PASSWORD runtime) |
| `.claude/rules/git-commands-format.md` | Aggiornato | PowerShell only (rimosso bash) |
| `.claude/rules/git-identity-and-repo.md` | Aggiornato | PowerShell only (rimosso bash) |
| `.claude/PROJECT-SYSTEM.md` | Aggiornato | Wipe script PowerShell (rimosso sh POSIX) |

## Documenti IT ingestati in Fase 3

| File | Output | Dimensione |
|------|--------|------------|
| ARCHITETTURA SERVER-CLOUD-LINEE 20052026.docx | .tmp-docx-ARCHITETTURA/ | 10240 par, 91 TBC |
| data_protection.txt | .tmp-docx-CYBERSEC/ | 74 par |
| bitdefender_protezione_lan.txt | .tmp-docx-CYBERSEC/ | 203 par |
| iso27001_state_of_art.txt | .tmp-docx-CYBERSEC/ | 20 par |
| riunione_serafino_18042025.txt | .tmp-docx-CYBERSEC/ | 52 par |
| piano_intervento_rete.txt | .tmp-docx-CYBERSEC/ | 168 par |
| phishing_notes.txt | .tmp-docx-CYBERSEC/ | 58 par |
| va_executive_summary.txt | .tmp-docx-VA/ | 8 par |
| pentest_executive_summary.txt | .tmp-docx-VA/ | 10 par |
| va_esterno_proelium_19012026.txt | .tmp-docx-VA/ | 11 par |
| mfa_action_plan.txt | .tmp-docx-HELPDESK/ | 62 par |
| onboarding_outboarding.txt | .tmp-docx-HELPDESK/ | 76 par |
| meetings_with_aidapt.txt | .tmp-docx-SCENIA/ | 2027 par |
| implementazione.txt (IntraLino) | .tmp-docx-INTRALINO/ | 3790 par |
| SCENIA/SECURITY/DPA/CLAUDE.md | letto direttamente | 89 righe |
| SCENIA/SECURITY/DPA/DPA_ScenIA_Intrawelt_v1.0_bozza.md | letto parzialmente | 669 righe |

## Ancora da ingestare (priorità)

| Documento | Priorità | Note |
|-----------|----------|------|
| _Piano_Attivita_IT_v3.xlsx | ALTA | Timeline biennale attività – Excel COM |
| SCENIA/Documento Riepilogativo Call AIDAPT 27042026.docx | MEDIA | Milestone specifiche aprile 2026 |
| Intrawelt_Report_Risk_Priority (classe 10,20,30).docx | MEDIA | Solo intro estratta, mancano sezioni |
| Helpdesk_T-Rex/TREX.docx | MEDIA | T-Rex/Odoo timeline |
| Helpdesk_MIcrosoft 365/MICROSOFT 365.docx | MEDIA | M365 operations |
| Helpdesk_RWS-Groupshare-Studio/STUDIO-RWS-GROUPSHARE.docx | MEDIA | GroupShare procedure |
| myZYXEL - 18122025.docx (3.5MB) | BASSA | Log/export Zyxel Nebula |
| BCD_2026.docx | MEDIA | Business Continuity |
| PSGSI Politica Sicurezza Informazioni.docx | MEDIA | ISO27001 input |

## Da creare ancora

| File | Priorità | Prerequisito |
|------|----------|-------------|
| `docs/helpdesk-operations.md` | ALTA | Leggere STUDIO-RWS-GROUPSHARE, MICROSOFT 365, TREX |
| Aggiornare GAP-TBC.md | MEDIA | Nuovi gap trovati (MFA, ISO, phishing rule) |

## Anomalie confermate in Fase 3 (aggiunte a FW-*)

| ID | Fonte | Aggiunto a |
|----|-------|-----------|
| FW-001 | VA Onova nov 2025 | runbook-anomalie.md, Check-SecurityAnomalies.ps1 |
| FW-002 | VA Onova nov 2025 | runbook-anomalie.md, Check-SecurityAnomalies.ps1 |
| UPS-001 | VA Onova nov 2025 | runbook-anomalie.md |
| EOL-001 | VA Onova nov 2025 | network-diagram.md |
| EOL-002 | VA Onova nov 2025 | network-diagram.md |
| AP-001 | VA Onova nov 2025 | runbook-anomalie.md |
| SCENIA gap | DPA Allegato II | scenia-project.md |

## Prossimi step

1. Commit manuale utente (Alessio)
2. Leggere _Piano_Attivita_IT_v3.xlsx via Excel COM per timeline attività biennale
3. Ingestare TREX.docx, MICROSOFT 365.docx, STUDIO-RWS-GROUPSHARE.docx
4. Scrivere docs/helpdesk-operations.md
5. Aggiornare GAP-TBC.md con nuove voci
6. Aggiornare timeline/ con eventi SCENIA, IntraLino, cybersec
