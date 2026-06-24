# Checklist Ingestion Documenti IT – Intrawelt

Cartella sorgente: `C:\Users\Utente\OneDrive - Intrawelt S.a.s\Documenti - IT`  
Aggiornato: 2026-06-23 | Owner: Alessio Sopranzi

Legenda: `[x]` estratto | `[ ]` da fare | `[-]` skip intenzionale | `[!]` mai ingestire (credenziali)

---

## Root

- [x] `_Piano_Attivita_IT_v3.xlsx` — riferito in contesto sessione
- [ ] `_planning_ferie_lunghe.xlsx` — BASSA priorità

---

## _DA SISTEMARE (Alessio) — 697 file

- [x] `analisi PHISING (e outlook-related)/dettagli attività elisa.docx` → phish_elisa_debug.txt (218 §) → 2026-switch-piano-terra.md
- [x] `analisi PHISING (e outlook-related)/notes analisi martina.docx` → phish_martina_notes.txt (118 §) → 2026-switch-piano-terra.md
- [x] `analisi PHISING (e outlook-related)/dettaglio anasini.docx` → phish_anasini_dettaglio.txt (4 §) → 2026-switch-piano-terra.md
- [x] `Physical Security.docx` → physical_security.txt (1 § placeholder, documento vuoto)
- [ ] `Analisi mail/` — MEDIA priorità (analisi messaggi sospetti)
- [x] `Problema DHCP kickout Elisa/` → helpdesk-operations.md §Incidente DHCP (TP-Link AC600 DHCP conflict, utente rete pubblica; nessuna data documentata)
- [ ] `PROXMOX/` — BASSA (già gestito in C:\Scripts\proxmox-snapshot)
- [ ] `QNAP cloud/` — BASSA
- [ ] `Ninjaone backup/` — BASSA
- [ ] `Problema spazio esaurito su Sharepoint/` — BASSA
- [ ] `sistemare risoluzione problema scanner/` — BASSA
- [ ] `sostituzione RAM server/` — BASSA
- [ ] `cache outlook Giuseppe 16052025.docx` — BASSA
- [ ] `prendi da chat con Tommaso D.txt` — BASSA
- [ ] `prendi da chat Tommy e Ale i messaggi Pinnati.txt` — BASSA
- [-] `_TreeSize Free Esporta - Resources.pdf` — skip (report TreeSize, non documentazione)

---

## ARCHITETTURA SERVER-CLOUD-LINEE — 127 file

- [x] `ARCHITETTURA.docx` (300 MB) → estratto completo → network-design/ (base dell'intero progetto)
- [x] `Telefono-PBX/` → telephony-pbx.md (centralino Panasonic KX-TDA100, procedure deviazione standard/gruppo, intercetta gruppo, segreteria personale, IVR messaggi bilingue, softphone opzioni; Centralino.doc = .doc non estraibile)
- [ ] `ZYXEL XGS2220/` (×3 doc) — MEDIA (config switch Piano Terra e Piano 2)
- [x] `ZYXEL FIREWALL e VPN/myZYXEL - 18122025.docx` → 2025-q3-q4.md §18/12/2025 ZYXEL licenze (USG FLEX 500 Gold Security Pack S232L12101347, XGS2220-54HP S242L06000292, procedura rinnovo Nebula/myZyxel)
- [x] `ZYXEL FIREWALL e VPN/Ricerca Blocco Traffico in uscita per centralino.docx` → 2026-switch-piano-terra.md §23/03/2026 (7 subnet VoIP verificate, nessun blocco firewall, causa non USG FLEX 500)
- [x] `ZYXEL FIREWALL e VPN/BREVE GUIDA PER LA CONNESSIONE DA REMOTO ALLA VPN AZIENDALE.docx` → helpdesk-operations.md §VPN (193.124.241.5, SecuExtender, ncognome, 2FA email, RDP)
- [-] `USG20/` — BASSA/skip (legacy, sostituito da USG FLEX 500)
- [ ] altri doc architettura (AP WiFi, VLAN tables, UPS) — BASSA (già coperto in ARCHITETTURA.docx)

---

## Cartella_riservata_IT — 18 file

- [!] `Email_Usr-Pwd_Office365.xlsx` — MAI INGESTIRE (credenziali in chiaro)
- [!] `Pwd_Ftp_e_TM_server.xlsx` — MAI INGESTIRE
- [!] `accesso_server_accounts_vari.xlsx` — MAI INGESTIRE
- [!] tutti gli altri file — MAI INGESTIRE

---

## Certificati — 28 file

- [ ] certificati SSL/TLS — BASSA priorità (gestiti da AWS/Azure Certificate Manager)
- [ ] certificati firma digitale — già in vendor-management.md (INFOCERT)

---

## Cybersec & IT Governance — 3734 file

### Access Authentication
- [x] `Configurazione-PC-Password.docx` → cybersecurity-governance.md §Policy Password e Gestione PC (admin+standard user, screen lock 5 min, pwd 6 mesi, min 8 chars, history 5)
- [-] `Regolamento Intrawelt per l'utilizzo degli strumenti informatici_rev1.pdf` — MEDIA (regolamento aziendale sistemi IT)
- [-] `Gestione PC e Password/` subfolder — duplicati/varianti degli stessi doc

### Business Continuity e Disaster Recovery
- [x] `Caity_BCP (1).pdf` → già ingestionato (via SCENIA/SECURITY/DPA) → scenia-project.md SLA
- [x] `Caity_DRP (4).pdf` → già ingestionato → scenia-project.md
- [x] `BCD_2026.docx` → cybersecurity-governance.md §BCP 2026 (Comitato Crisi 4 ruoli, sedi primaria/secondaria, T-BOND failover 3 linee, UPS 15 min, DR cloud M365/SharePoint/T-Rex, Punto Informatica SLA 2h, 6 fasi recovery, revisione biennale)

### Cybersec/Privacy (GDPR e Contratti)
- [x] `Confidentiality_Segretezza/` → cybersecurity-governance.md §NDA Framework (6 template: standard, interpreting, ENG, ENG rev, ITA, TUV_draft)
- [x] `GDPR-Privacy/` → cybersecurity-governance.md §NDA Framework (OpenForce NDA 09/04/2021, 5 Nomina sub-responsabili agenti, Procedura Diritti Interessati 4ward s.r.l., canale privacy@intrawelt.it)
- [-] `Informative/` — vecchi template GDPR 2018 (.doc non estraibili + dati anagrafici clienti/fornitori sensibili), skip
- [x] `Procedura_Data_Breach/` → cybersecurity-governance.md §Procedura Data Breach (4 fasi, soglie 72h Garante, registro breach)
- [x] `Procedura_Esercizio_Dirittti_Interessati/` (nota: typo 3 t nel nome) → cybersecurity-governance.md §Procedura Esercizio Diritti Interessati (6 diritti GDPR, 3 fasi operativa, canale privacy@intrawelt.it, 1 mese risposta, firmata 25/05/2018)
- [x] `Regolamento_utilizzo_sistemi_informatici/` → cybersecurity-governance.md §Regolamento utilizzo sistemi (firmato 19/04/2021; Registro_accettazione gap ISO-001: 0/21 firme)
- [x] `SubResponsabili Intrawelt/Elenco SubResponsabili Intrawelt.docx` → cybersecurity-governance.md §Registro Sub-Responsabili (11 fornitori: Microsoft, Bitdefender, NinjaOne, Zyxel, RWS, Odoo SA, QNAP, Seeweb, OpenForce, Punto Informatica, Eter)

### Regolamento utilizzo sistemi informatici
- [x] `Regolamento Intrawelt per l'utilizzo degli strumenti informatici_rev1.docx` → 201 § estratti — documento ESISTE. Gap ISO-001 aggiornato in GAP-TBC: mancano firme in Registro_accettazione
- [x] `Registro_accettazione.docx` → cybersecurity-governance.md §Registro utilizzo sistemi (0/21 firme — gap ISO-001 confermato; prima versione 19/04/2021)

### Documenti NinjaOne
- [ ] `Privacy policy NinjaOne` — MEDIA (DPIA input)

### _QUESTIONARI FORNITORI
- [x] `Questionario Cybersecurity ENI/` → cybersecurity-governance.md §Questionari B2B + timeline 29/04/2025
- [x] `Fidelity/` ESR questionnaire (8 sezioni) → cybersecurity-governance.md §Questionari B2B
- [x] `LB Research/` DPA checklist → cybersecurity-governance.md §Questionari B2B
- [x] `WindTre/` RFQ 10714 (gara traduzioni specialistiche) → cybersecurity-governance.md §Questionari B2B
- [-] `.claude/` folder — skip (questionnaire-compiler skill files, metadati strumento AI)
- [-] altri link e bozze — SKIP (derivati dalle compilazioni sopra)

### _VA e Pentest assessment
- [x] `Onova VA Nov 2025` → vulnerability-assessment-nov2025.md (8 criticità)
- [ ] `Proelium preventivo PT` — MEDIA (metadata già in vendor-management.md)

### Phising and spoofing protection
- [x] `Notes.docx` → cybersecurity-governance.md §Email Authentication DMARC (DMARC configurato su intrawelt.com, RUA ricevuti da Microsoft/Google/Aruba/Mimecast/Yahoo/GMX/Terna/ESA/Amazon SES, novembre 2025)
- [-] DMARC .eml report files — dati operativi, info già estratta da Notes.docx

### Data protection
- [x] `Data protection/Data protection.docx` → cybersecurity-governance.md §Data Protection Statement (DPO status, retention 1-3yr NAS, BYOD vietato, gap: no TLS 1.2, no DLP endpoint, no log encryption, no full disk encryption)
- [-] `Data protection/Architecture Diagram Intrawelt.jpeg` — immagine, info già in network-design
- [-] `Data protection/Data flow Diagram Intrawelt.jpeg` — immagine, info già in docs

### Procedura Data Breach
- [x] `Procedura Data Breach INTRAWELT.docx` → cybersecurity-governance.md §Procedura Data Breach (4 fasi, Allegato A+B, registro)
- [x] `Registro_Data_Breach.xlsx` → cybersecurity-governance.md §Registro Data Breach + 2023-baseline.md §05/04/2021 (scheda 001: ransomware Server Axios, Aruba Enterprise, no notifica Garante)
- [-] `Modello notifica Data Breach.pdf` — modello PDF, info già in procedura
- [-] `Data Branch-bando.docx` — Q&A sub-contractor questionnaire, derivato dalla procedura principale

### Criptare dati a riposo / Operation security
- [-] `2. Manuale SGIQA rev. 1 del 12.01.2024 firmato.pdf` (6.6 MB) — manuale SGIQA qualità/ambiente, fuori scope IT
- [-] `risposte.docx` (23 KB) — risposte questionario, skip

### _ 📜 GDPR E ISO27001
- [x] `riunione_con_Serafino 18042025.docx` → 2025-q3-q4.md §18/04/2025 (espanso: 12 action item operativi, email metadata 21gg, badge sala server, CISSP, Exchange policy)
- [x] `PSGSI POLITICA DELLA SICUREZZA DELLA INFORMAZIONI rev. 1 16.10.2025.docx` → cybersecurity-governance.md §SGSI (scope: Networking/SI/SaaS/Servizi; 5 obiettivi: CIA+Conformità+Miglioramento; processo risk management 4 step; milestone ISO 27001)
- [x] `_GDPR compliance/DPA (3rd party providers).xlsx` → cybersecurity-governance.md nota (4 provider: Microsoft, QNAP, Seeweb, Odoo — registro semplificato)
- [-] `Miscellaneous/` — link, lnk, email, file vuoti, link a risorse esterne
- [-] `_ISO27001/27001.it.pdf` — copia standard ISO (non documentazione interna)
- [-] `_ISO27001/ISO27001 CHECKLIST_rev4.xlsm` — template checklist esterno, info già in gap analysis
- [-] `DORA (brief GPT explanation).docx` — nota informativa, non documentazione operativa
- [-] altri link e PDF normativi — skip (informativo, non operativo)

### Varie (root Cybersec)
- [ ] `Physical Security.docx` — vedi _DA SISTEMARE (stesso file)
- [-] `[TBC] Data deletion and disposal.docx` — documento vuoto (1 § solo "Per il momento non sembra ci siano documentazioni in merito")
- [ ] `Creazione e Setup Ambiente di Test sito Intrawelt.docx` — già in creazione_ambienti.txt
- [ ] `RAEE.docx` — BASSA
- [-] `_ 🧰 Resources/` — SKIP (libri/guide esterni)
- [-] `Linee guida per lo sviluppo codice.pdf` — BASSA
- [-] `Polizza_intrawelt_Generali.pdf` — non IT

---

## ENIVIPA — 104.620 file (prevalentemente dati raw ENI, non documentazione)

- [x] `procedura ENI.docx` → enivipa_servizi.txt (651 §) → helpdesk-operations.md (IntraPanel, PC-GIORDANO)
- [-] `dati raw xls/xlsx` (104.000+ file) — SKIP intenzionale (dati billingENI, non documentazione IT)
- [ ] eventuali procedure aggiuntive (da verificare se esistono doc non-dati) — BASSA

---

## Helpdesk_ABBYY — 11 file

- [-] tutto — SKIP (prevalentemente screenshot, non documentazione operativa utile)

---

## Helpdesk_Amministrazione(IT) — 27 file

- [ ] procedure amministrative IT — BASSA priorità

---

## Helpdesk_INFOCERT — 8 file

- [x] `infocert.docx` (45 §) → infocert.txt → vendor-management.md (metadata, NO credenziali)
- [!] `Procedura_firma_digitale.docx` — FILE CONTIENE CREDENZIALI in chiaro (username, password, PIN) → helpdesk-operations.md §Firma Digitale Remota (solo procedura, senza credenziali)
- [!] eventuali file credenziali — MAI INGESTIRE

---

## Helpdesk_Internal ticketing Intrawelt (old) — 1 file

- [ ] vecchio sistema ticketing — BASSA

---

## Helpdesk_MIcrosoft 365 — 7 file

- [x] `MICROSOFT 365.docx` (49 MB) → estratto completo → 2026-switch-piano-terra.md, vendor-management.md
- [-] `Problema Delega Caselle.docx` — file non in locale (OneDrive-only)
- [ ] altri sub-doc — BASSA

---

## Helpdesk_NinjaOne — 16 file

- [x] setup NinjaOne — estratto via ARCHITETTURA.docx → vendor-management.md
- [-] `NinjaOne Encrypted Backup.docx` (16 MB) — SKIP (prevalentemente screenshot)
- [ ] altri doc operativi NinjaOne — BASSA

---

## Helpdesk_Onboarding — 4 file

- [ ] procedure onboarding nuovo dipendente — MEDIA (ISO-001)

---

## Helpdesk_PC formatting — 142 file

- [ ] procedure formattazione/provisioning PC — BASSA

---

## Helpdesk_RWS-Groupshare-Studio — 153 file

- [x] `STUDIO-RWS-GROUPSHARE.docx` (39 MB) → estratto completo → vendor-management.md
- [ ] sub-procedure Trados/GroupShare — BASSA (coperte in STUDIO consolidato)

---

## Helpdesk_T-Rex — 208 file

- [x] `TREX.docx` (44 MB) → estratto completo → helpdesk-operations.md (sistema tour operator)
- [x] `Storico ticket - case-studies/2022-11-23_EniVipa/ENI_VIPA_Guida_inserimento_SO.docx` → helpdesk-operations.md §Procedura VIPA in T-Rex (wizard, SO, task, fine mese PO)
- [ ] `Storico ticket - case-studies/` altri file (prevalentemente JPG/allegati) — BASSA (archivio storico immagini)
- [-] `Configurazione server IMAP in Odoo.docx` — file non in locale (OneDrive-only)
- [x] `Mancata Ricezione Mail Gestionale TRex_Odoo.docx` → helpdesk-operations.md §T-Rex Sblocco IMAP (procedura periodica: sblocco token ricezione mail, 2 caselle trex/opportunita)
- [x] `Problema CSRF Token T_Rex.docx` → helpdesk-operations.md §T-Rex CSRF Token + 2026-switch-piano-terra.md §19/02/2026 (Chiara Ippoliti, batch upload XML fallito, sessione corrotta)
- [ ] `2022-10-20_Gestione_bolli_magazzino/` — BASSA
- [ ] `Cambio sequenze fatturazione anno nuovo/` — BASSA
- [ ] `TREX tour/` — BASSA
- [ ] `cheklist-interventi (old).docx` — BASSA
- [ ] `Interrogare attività utente specifico in Odoo.docx` — MEDIA
- [x] `102025 - Note migrazione gestionale.txt` → 2025-q3-q4.md §Ottobre 2025 migrazione T-Rex (timeline Jan-Mar 2026, OpenForce fasi)
- [x] `2026-01-21_Monitoraggio_app_T-Rex.xlsx` → helpdesk-operations.md §Matrice permessi Odoo (sheet PERMESSI 46×13: moduli vs ruoli, analisi pre-migrazione; sheet Dati non estratto per encoding error)
- [-] `PROCEDURA PER AUTOFATTURE.pdf` — BASSA

---

## Helpdesk_Timbracartellini — 1031 file

- [ ] procedure timbrature — BASSA/skip (dati operativi HR, non documentazione IT)

---

## IntraLino_Knowledge — 7 file

- [x] timeline IntraLino — estratto via altri doc → 2024-infra.md, 2026-switch-piano-terra.md
- [x] `IntraLino_profilo_addestramento.docx` → helpdesk-operations.md §IntraLino: chatbot IT RAG, trained on IT docs, admin mode, knowledge base
- [-] `IntraLino_profilo_addestramento.pdf` — stessa fonte, skip
- [ ] `Backup postazioni di lavoro con Veeam_DRAFT.pdf` — MEDIA (procedura backup workstation)
- [-] `BREVE GUIDA PER LA CONNESSIONE DA REMOTO ALLA VPN AZIENDALE.pdf` — PDF version, .docx già processato
- [ ] `Nas Hero Irraggiungibile.pdf` — BASSA (troubleshooting NAS)

---

## Miscellaneous procedure e utilities — 187 file

- [ ] procedure miscellaneous — BASSA

---

## OpenAI — 271 file

- [ ] ricerche/note OpenAI — BASSA (materiale ricerca, non ops)

---

## Ricerche — 4 file

- [ ] doc ricerche mercato — BASSA (non documentazione IT ops)

---

## SCENIA — 21.542 file

### Root SCENIA (file)
- [x] `MEETINGS WITH AIDAPT.docx` (76 MB) → estratto completo → scenia-project.md
- [x] `Documento Riepilogativo Call AIDAPT 27042026.docx` → metadata in scenia-project.md
- [x] `FAQ portale AI.docx` → scenia-project.md §FAQ portale ScenIA (10 FAQ: formati, sicurezza, crediti, PIM, coesistenza traduttori, ROI)
- [ ] `script .docx` — MEDIA
- [!] `APIKEY_mailtrap.txt` — MAI INGESTIRE (API key)
- [!] `Credenziali e Info Utili Ambiente Staging e Produzione.txt` — MAI INGESTIRE
- [!] `Credenziali e Info Utili Ambiente Staging.txt` — MAI INGESTIRE
- [!] `Credenziali.xlsx` — MAI INGESTIRE
- [!] `Deepl Api Key.txt` — MAI INGESTIRE
- [!] `flowhandlar trados credenziali.txt` — MAI INGESTIRE
- [!] `TestAPIKeys.txt` — MAI INGESTIRE
- [!] `Token connettore Cloudflare.txt` — MAI INGESTIRE
- [-] `Loghi AIDAPT.zip` — SKIP (asset grafici)
- [-] `logo-dx-text-black.png` — SKIP

### SCENIA/SECURITY/DPA
- [x] `Meeting 27.05.2026.docx` → dpa_meeting_270526.txt (53 §) → scenia-project.md
- [x] `edpb_dpia_template_2026_v1_en.docx` → dpia_scenia_2026.txt (61 §, struttura EDPB)
- [x] `Caity_BCP (1).pdf` → scenia-project.md SLA
- [x] `Caity_DRP (4).pdf` → scenia-project.md
- [x] `Questionario_AIDAPT_misure_sicurezza_2026-06-11.md` → già in repo D:\network-design
- [x] `DPA_ScenIA_Intrawelt_v1.0_bozza.md` → già in repo D:\network-design
- [x] `Questionario_AIDAPT_PRECOMPILATO_2026-06-11.md` → scenia-project.md §30 punti (1✅ 11⚠️ 18❌)
- [x] `Memo_AIDAPT_notifica_violazioni_2026-06-11.md` → scenia-project.md §Memo Notifica Violazioni
- [x] `Intrawelt_dati_e_misure_da_fornire_2026-06-11.md` → scenia-project.md §Dati Intrawelt per DPA
- [x] `Domande_interne_Intrawelt_2026-06-11.md` → scenia-project.md (dati anagrafici compilati: sede, P.IVA, foro Fermo)
- [x] `DPIA_SCENIA_2026.docx` → template EDPB vuoto (solo intestazioni sezioni, contenuto non compilato nel file principale — lavorazione in copia backup .BACKUP_2026)
- [x] `Allegati.docx` → scenia-project.md §SLA service credits (Allegato E), §Change Control (Allegato G), §Sub-processor (Allegato K), §Descrizione Servizio (Allegato B: workflow, 2 modalità traduzione, Vector Store, logging, limiti)
- [-] `Elenco SubResponsabili Intrawelt.docx` (SCENIA/SECURITY/DPA) — duplicato del registro già in cybersecurity-governance.md §Registro Sub-Responsabili (estratto dalla cartella Privacy root)
- [x] `SaaS security.docx` (9.6 MB) → scenia-project.md §Infrastruttura VPS Aruba, §Domini scenia.it, §Security Architecture (Cloudflare Zero Trust), §CVE History; 2026-switch-piano-terra.md §13/02/2026 ticket Aruba, §Gen-Feb 2026 CVE patch, §11/05/2026 Cloudflare
- [-] `che tipo di dati DI PERSONE FISICHE trattiamo.txt` — file non in locale (OneDrive-only)
- [x] `Checklist_Sicurezza_Dropdown.xlsx` → scenia-project.md §Checklist Sicurezza SCENIA (4 sezioni: A)applicativa 15 item, B)operativa 19 item, C)governance dato 13 item, D)LLM security 12 item — tutti "Da fare")
- [-] `edpb_dpia_template_explainer_2026_v1_en.pdf` — SKIP (EDPB guide ufficiale, non interno)
- [-] `en_304223v020101p.pdf` — SKIP (ETSI standard ufficiale)

### SCENIA/SECURITY/Condivisione con AIDAPT
- [x] `a), b), c), d)/a) sicurezza applicativa.txt` → scenia-project.md §Requisiti Sicurezza a/b/c/d
- [x] `a), b), c), d)/b) sicurezza operativa.txt` → scenia-project.md
- [x] `a), b), c), d)/c) governance del dato.txt` → scenia-project.md
- [x] `a), b), c), d)/d) LLM security e governance.txt` → scenia-project.md
- [x] `a), b), c), d)/Notes for a),b),c),d).txt` → scenia-project.md (nota responsabilità AIDAPT)
- [x] `call 27-05-2026 DPIA.docx` → note DPIA con Lorenzo: nuova rotta traduzione senza spezzettamento, System Card, art.9 risk, scope DPIA, data minimization via organization_id
- [x] `Commenti security parte relativa ad AIDAPT.docx` → note review Alessio: ISO 27001 §A.8.13 retention configurabilità, ZDR evidenza richiesta, AWS non isolamento fisico ma segregazione account, rate limiting pending
- [x] `Documento riassuntivo security.docx` → formalizzazione requisiti sicurezza (§2 sicurezza applicativa, §3 operativa, §4 governance, §5 LLM)
- [x] `Requisiti di Sicurezza, Governance del Dato e Architettura.docx` → versione ampliata stessa struttura; entrambi già sintetizzati in scenia-project.md §Requisiti Sicurezza a/b/c/d
- [ ] `Risposte Tecniche ai Requisiti di Sicurezza.docx` — ALTA (risposte AIDAPT — file non trovato in Condivisione, cercare in File condivisi da AIDAPT)
- [ ] `Re_ Call per smarcare punti security.eml` — MEDIA
- [-] `Caity_BCP, Caity_DRP, Caity_SLA.pdf` — già ingestionati
- [-] `Intrawelt__documento_tecnico_.pdf` — BASSA (overview tecnica base)
- [-] `RispostaMail Sicurezza.pdf` — MEDIA

### SCENIA/Sviluppo full-stack (snapshot mensili)
- [x] `00_Aprile 2025/` → 2025-q3-q4.md §02-11/04 SCENIA VM601 setup + Codepen/ER prototipi (txt files; screenshots non estratti)
- [-] `01_Maggio 2025/` — SKIP (solo HTML frontend templates + screenshots, no text docs)
- [-] `02_Giugno 2025/` — SKIP (solo screenshots)
- [-] `03_Luglio 2025/` — SKIP (solo screenshots)
- [-] `04_Agosto 2025/` — SKIP (solo screenshots)
- [x] `05_Settembre 2025/` → 2025-q3-q4.md §SCENIA luglio-set milestones (pipeline.md + PULIZIA BASE STABILE.docx: Francesca Caricchia calls aug 25/29, PR #1 merged sep 8, base stabile sep 10, commit 44537be)
- [-] `06_Ottobre 2025/` — SKIP (solo screenshots)
- [-] `07_Novembre 2025/` — SKIP (solo screenshots)
- [-] `08_Dicembre 2025/` — SKIP (solo screenshots)
- [-] `09_Gennaio 2026/` — SKIP (solo screenshots)
- [-] `10_Febbraio 2026/` — SKIP (solo screenshots)
- [-] `11_Marzo 2026/` — SKIP (solo screenshots)
- [-] `12_Aprile 2026/` — SKIP (solo screenshots)
- [x] `13_Maggio 2026/` → 2026-switch-piano-terra.md §SCENIA gen-apr 2026 dev (8 cluster: files_storage, translation_form_ui, email_mjml, sessions, estimate_planner, trados, cors, admin_users; changelog mar-apr 2026)
- [x] `_GESTIONE OUTSOURCING CON F.GIORGINI/` → 2025-q3-q4.md §Ottobre 2025 onboarding Giorgini (fork+PR model, branch strategy, cost analysis Render/Netlify/S3, proposta 29/10/2025)

### SCENIA/File condivisi da AIDAPT
- [x] `Caity_BCP, Caity_DRP, Caity_SLA.pdf` → già ingestionati
- [ ] altri file — MEDIA

### SCENIA/Ricerca Unimc
- [ ] documenti ricerca UNIMC/VRAI Lab — MEDIA

### SCENIA/analisi knowledgebase
- [ ] analisi knowledge base SCENIA — MEDIA

### SCENIA/BUGFIX
- [ ] log bugfix — BASSA

### SCENIA varie
- [-] `TEST/` — SKIP (file .xliff/.sdlxliff test traduzione)
- [-] `Graphics/` — SKIP (asset design)
- [-] `VIDEOs/` — SKIP (multimedia)
- [-] `Useful Resources/` — BASSA/skip (link esterni)

---

## Sviluppo_interno, scripting (IT on FIRE) — 12.655 file

- [x] `creazione ambienti.docx` → creazione_ambienti.txt (133 §) → vendor-management.md (Cappelli Design)
- [x] `IntraPanel/flask_service.py` → via enivipa_servizi.txt → helpdesk-operations.md (SEC-009)
- [x] `Notes (thinking lab) 12012026.docx` → 2026-switch-piano-terra.md §12/01/2026 (ricerca Thinking Machines/Tinker API, LoRA fine-tuning, case study n8n+Ollama+Tinker SaaS)
- [x] `Progetto ENI ruolini (nov24)/` → 2024-infra.md §Novembre 2024 app desktop (Python/PyQt6, pipeline Word→Excel per T-Rex, 12-19 nov 2024, Francesca Caricchia)
- [x] `[TBC] PASSWORD MANAGER/` → cybersecurity-governance.md §Studio Password Manager (Vaultwarden Docker LAN, gap SEC-007 non implementato)
- [ ] `[TBC] SERVER DNS PERSONALIZZATO/` — MEDIA
- [ ] `[TBC] STUDIO - CLAUDE SUBAGENTS/` — BASSA
- [ ] `[TBC] STUDIO - CHERSHIRE CAT/` — BASSA
- [x] `OpenProject/` → helpdesk-operations.md §OpenProject VM205 (openproject.local:9001, 3 utenti, disk resize 13/10/2025)
- [ ] `Script e Documentazione per Export Giornaliero.../` — MEDIA
- [ ] `TOOL AI coding assistance/` — BASSA
- [-] `Qdrant + Ollama + Ubuntu + n8n self-hosting/` — BASSA (ricerca esterna)
- [-] `[studying] Automazione bozza per commerciali/` — BASSA
- [-] `_aborted/` — SKIP

---

## Sviluppo_NinjaOne — 29 file

- [ ] script NinjaOne — BASSA

---

## Sviluppo_Proxmox — 1 file

- [x] già gestito in C:\Scripts\proxmox-snapshot — SKIP

---

## Sviluppo_T-Rex (Odoo) — 10.541 file

- [x] `Odoo_18/2025-11-24_Scaletta.docx` → odoo18_scaletta.txt (25 §) → helpdesk-operations.md
- [x] `Odoo_18/2025-11-24_Scaletta_flussi.docx` → odoo18_flussi.txt (52 §) → helpdesk-operations.md
- [x] `Integrazione Odoo - portale/` → helpdesk-operations.md §Integrazione portale SCENIA + 2026-switch-piano-terra.md §04/03/2026 (meeting Susanna Ortini: xml-rpc, user asopranzi, deprecation v19/v20)
- [x] `Integrazione Odoo - centralino cloud vianova/` → helpdesk-operations.md §Studio centralino (2 modalità: SIP Trunk + IP PBX vs API REST Vianova; nessun connettore nativo)
- [ ] `Appina per query gestionale, webhook (2025)/` — MEDIA
- [ ] `Odoo_12/28052025 - Risoluzione fix.docx` (7 MB) — MEDIA (storia bug pre-migrazione)
- [x] `[TBC] STUDIO - INTEGRAZIONE ODOO NINJAONE (RMM).txt` → helpdesk-operations.md §Odoo-NinjaOne RMM TBC (API REST + webhook Python, post-migrazione Odoo)
- [-] `Odoo_12/Sviluppo Odoo Alessio.docx` (62 MB) — SKIP (impraticabile, prevalentemente screenshot)
- [-] `VIDEOs/` — SKIP (multimedia)

---

## Riepilogo priorità

| Priorità | Da fare |
|----------|---------|
| ALTA | Regolamento utilizzo sistemi, SCENIA/SECURITY/Condivisione .docx ×5, DPIA_SCENIA_2026.docx, Questionario_PRECOMPILATO.md, Memo/Intrawelt_dati/Domande.md, Storico ticket T-Rex, Integrazione Odoo portale, Progetto ENI ruolini, _GESTIONE OUTSOURCING F.GIORGINI |
| MEDIA | Privacy GDPR e Contratti, IntraLino_profilo_addestramento, snapshot SCENIA mensili, FAQ portale AI, Commenti/Documento riassuntivo security, mail incidente IMAP/CSRF |
| BASSA | tutto il resto |
| SKIP | Cartella_riservata_IT, credenziali SCENIA root, ABBYY, NinjaOne backup, TEST/, dati raw ENIVIPA, VIDEO/, Sviluppo Odoo Alessio.docx 62MB |
