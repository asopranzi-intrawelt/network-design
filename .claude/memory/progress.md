# Work-log

> Append-only, in ordine cronologico inverso (la voce piu recente in alto). Ogni passo
> significativo di codice e ogni intervento manuale rilevante lascia una voce con data, file
> toccati, motivo e commit di riferimento.

## 2026-07-01 — M1: correzione guidata regole firewall allow->deny (sessione 6)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/firewall-zyxel-usg-flex-500-live.conf (nuovo — changelog incrementale live del firewall)
  - docs/firewall-zyxel-usg-flex-500.md (FW-001/FW-002 marcate corrette, FW-011 aggiornata, callout di stato)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce datata 01/07/2026)
  - docs/infrastructure-timeline/GAP-TBC.md (item 54/55 risolti)
  - .claude/context/roadmap.md (M1 marcato Fatto, stato riepilogativo Fase 3 aggiornato)
Motivo: eseguito M1 della roadmap Fase 3, guidando l'utente passo-passo dentro la
Web UI del firewall Zyxel USG FLEX 500 con verifica su screenshot Screenpresso a
ogni passaggio (11 screenshot, screenshot_01.png-screenshot_15.png). Corretta la
regola `Blocco_Gruppo_IP_Phishing_Elisa` (allow->deny, log alert, rimosso
193.124.241.5/IP_09_phishing_2026_Elisa dal gruppo Bad_IP_Phishing_Elisa_2026,
confermato a 11 membri totali) e la regola gemella `malicious_IP_12052025`
(allow->deny). Entrambe verificate scritte sul dispositivo senza necessita' di
un Apply separato. Introdotto su richiesta esplicita dell'utente un changelog
incrementale (`firewall-zyxel-usg-flex-500-live.conf`) che traccia 1:1, con
riferimento agli screenshot, ogni modifica live applicata via GUI, distinto dal
config target del 05/06/2026 (mai applicato in blocco). Rilevate due regole non
censite (BLOCCO_IP_SOSPETTI, EGETRAD_WEB_TEST) da riconciliare in seguito.
Aggiunto anche il gap NEB-001 (switch Nebula segnalati offline in modo
intermittente pur con rete dati funzionante, foto app Nebula dell'utente) con
ipotesi di correlazione a FW-008 (WAN_TRUNK/wan2 morto); nuovi micro-step M20
(diagnosi log) e M21 (ricontrollo dopo M7) in roadmap.md.
Prossimo micro-step: M2 (verifica console seriale/iLO, conferma 802.1Q) o M20
(diagnosi Nebula) a scelta dell'utente.

## 2026-07-01 — Ingestione "[TBC] Diagramma di rete e analisi firewall, centralino" + roadmap ottimizzazione (sessione 5)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/firewall-zyxel-usg-flex-500.md (stato applicazione, sei fasi, registro diagrammi, FW-011/FW-012)
  - docs/network-diagram.md (nota discrepanza NET-007, riferimento diagrammi)
  - docs/telefono-pbx-voip.md (provisioning Vianova Area Clienti, Vianova One, TEL-001)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voci datate 29/05, 05/06, 09/06)
  - docs/infrastructure-timeline/GAP-TBC.md (item 61/63 risolti, nuovi 97-100, totale 100)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce TBC ingestita, nota riallineamento)
  - .claude/context/roadmap.md (Fase 2 sostanzialmente completa, nuova Fase 3 a 19 micro-step M1-M19, rinumerazione Fase 4/5)
  - .claude/context/current-work.md (riscritto: focus Fase 3, domande aperte/risolte)
  - .claude/context/diagrams/firewall-dmz-2026/ (8 file drawio/svg archiviati, risolve FW-010)
Motivo: ingestione completa della cartella non tracciata "[TBC] Diagramma di rete e
analisi firewall, centralino" (tre snapshot datati 29/05, 05/06, 08/06/2026), su
richiesta esplicita dell'utente di completarla e poi cancellarla. Confermato con
l'utente che il piano di correzione firewall del 05/06/2026 e' una configurazione
target preparata, non ancora applicata al dispositivo fisico: le anomalie critiche
(regola phishing action=allow) restano aperte in produzione. Prodotta una roadmap
tracciata a micro-step (Fase 3) per l'ottimizzazione di Proxmox e del firewall,
sostituendo la Fase 3 generica precedente. Allineamento a
E:\template-claude-developing verificato (gap: skill init-project-system/onboard
e cartella templates/ mancanti) ma importazione rimandata su richiesta dell'utente.
Segnalata nella checklist di ingestione la deriva tra il "Riepilogo priorita'" e
le spunte reali, come richiesto dall'utente per riprendere l'ingestione OneDrive
IT in modo ordinato quando la Fase 3 sara' chiusa.
Cartella sorgente "[TBC] Diagramma di rete e analisi firewall, centralino" non
ancora eliminata: in attesa di conferma finale dell'utente a fine sessione.

## 2026-06-23 — Aggiornamento GAP-TBC e timeline (sessione 4)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/GAP-TBC.md (aggiunto TBC 68-95: NET, SEC, SCENIA, ISO)
  - docs/infrastructure-timeline/2024-infra.md (aggiunti: Bitdefender, SCENIA start, IntraLino)
  - docs/infrastructure-timeline/2025-q3-q4.md (aggiunti: Serafino, SCENIA→AIDAPT, MFA, Onova VA)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (aggiunti: Proelium, IntraLino Zep, SCENIA DPA, myOffice riunione)
Motivo: completamento ingestion — tutti gli eventi dal Piano Attività IT v3.xlsx e dai
documenti SCENIA/DPA sono ora mappati nelle timeline. GAP-TBC completo: 95 voci.

## 2026-06-22 — Feature batch e ingestion IT folder (sessione 3)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/network-diagram.md (nuovo - topologia ASCII completa)
  - docs/runbook-anomalie.md (nuovo - FW-001, FW-002, DMZ, AP, UPS runbook)
  - docs/vendor-management.md (nuovo - tutti i fornitori IT)
  - docs/design-and-security.md (nuovo - SoA ISO27001:2022 Annex A completa)
  - docs/cybersecurity-governance.md (nuovo - timeline 2024-2026 sicurezza)
  - docs/scenia-project.md (nuovo - timeline SCENIA + AIDAPT + DPA status)
  - docs/sviluppo-interno.md (nuovo - IntraLino RAG + scripting)
  - scripts/Check-SecurityAnomalies.ps1 (nuovo - check automatico anomalie)
  - .mcp.json (nuovo - ProxmoxMCP-Plus configurazione)
  - .claude/rules/git-commands-format.md (PowerShell only)
  - .claude/rules/git-identity-and-repo.md (PowerShell only)
  - .claude/PROJECT-SYSTEM.md (wipe script PowerShell)
Motivo: implementazione tutte 6 le feature proposte + 2 doc aggiuntivi timeline
biennale (cybersec-governance, scenia-project, sviluppo-interno).
Ingestion: ARCHITETTURA (10240 par), VA/PT, MFA plan, ISO27001 state, Serafino,
phishing, DPA/DPIA ScenIA, IntraLino Implementazione.docx, MEETINGS WITH AIDAPT.docx.
Template: allineati a Windows PowerShell 5.1 (rimossi blocchi bash/POSIX).

## 2026-06-22 — Inizializzazione del progetto

Commit: PENDING-FIRST-COMMIT
File toccati: tutta la struttura iniziale.
Motivo: creazione del progetto network-design. Struttura `.claude/` canonica dal template
portabile. Script Get-ProxmoxSnapshot.ps1 spostato da C:\Scripts\proxmox-snapshot.
Diagramma network-topology.mmd copiato dallo snapshot v3 di proxmox-snapshot.
Regole e skill copiate dal template. ADR 001-006 registrate. Due layer documentali
(narrativo locale + tecnico versionato). Angolo ISO27001. Skill docx-ingest per
ingestione progressiva dei Word. Agent iso27001-reviewer.
Identita git: asopranzi / asopranzi@intrawelt.com via alias SSH github-corp.
Remote: da configurare su git@github-corp:asopranzi-intrawelt/network-design.git
