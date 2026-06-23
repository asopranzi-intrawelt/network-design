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
- [ ] `Problema DHCP kickout Elisa/` — MEDIA (correlato a incidente gen 2026)
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
- [ ] `Telefono-PBX/` (×6 doc) — MEDIA (config centralino Vianova, Yealink)
- [ ] `ZYXEL XGS2220/` (×3 doc) — MEDIA (config switch Piano Terra e Piano 2)
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
- [ ] docs autenticazione (MFA, SSO, policy) — MEDIA

### Business Continuity e Disaster Recovery
- [x] `Caity_BCP (1).pdf` → già ingestionato (via SCENIA/SECURITY/DPA) → scenia-project.md SLA
- [x] `Caity_DRP (4).pdf` → già ingestionato → scenia-project.md
- [ ] altri doc BCP/DRP interni Intrawelt — ALTA

### Cybersec/Privacy (GDPR e Contratti)
- [ ] `Confidentiality_Segretezza/` — ALTA (NDA template con clienti)
- [ ] `GDPR-Privacy/` — ALTA (informative privacy, DPA clienti)
- [ ] `Informative/` — ALTA (informative trattamento)
- [ ] `Procedura_Data_Breach/` — ALTA (procedura notifica violazione dati art.33 GDPR)
- [ ] `Procedura_Esercizio_Diritti_Interessati/` — ALTA
- [ ] `Regolamento_utilizzo_sistemi_informatici/` — vedi sotto
- [ ] `SubResponsabili Intrawelt/` — ALTA (registro sub-responsabili)

### Regolamento utilizzo sistemi informatici
- [x] `Regolamento Intrawelt per l'utilizzo degli strumenti informatici_rev1.docx` → 201 § estratti — documento ESISTE. Gap ISO-001 aggiornato in GAP-TBC: mancano firme in Registro_accettazione
- [ ] `Registro_accettazione.docx` — ALTA (verifica quante firme raccolte)

### Documenti NinjaOne
- [ ] `Privacy policy NinjaOne` — MEDIA (DPIA input)

### _QUESTIONARI FORNITORI
- [ ] questionari sicurezza clienti B2B — ALTA (supply chain compliance)

### _VA e Pentest assessment
- [x] `Onova VA Nov 2025` → vulnerability-assessment-nov2025.md (8 criticità)
- [ ] `Proelium preventivo PT` — MEDIA (metadata già in vendor-management.md)

### Phising and spoofing protection
- [ ] doc protezione phishing/spoofing — MEDIA

### Criptare dati a riposo / Operation security
- [ ] procedure cifratura, hardening — MEDIA

### _ 📜 GDPR E ISO27001
- [x] Serafino ISO 27001 gap analysis 18/04/2025 — in 2025-q3-q4.md (metadata)
- [ ] documentazione gap analysis completa — MEDIA

### Varie (root Cybersec)
- [ ] `Physical Security.docx` — vedi _DA SISTEMARE (stesso file)
- [ ] `[TBC] Data deletion and disposal.docx` — MEDIA (GDPR retention)
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
- [ ] `Procedura_firma_digitale.docx` — MEDIA (procedura completa GoSign Pro)
- [!] eventuali file credenziali — MAI INGESTIRE

---

## Helpdesk_Internal ticketing Intrawelt (old) — 1 file

- [ ] vecchio sistema ticketing — BASSA

---

## Helpdesk_MIcrosoft 365 — 7 file

- [x] `MICROSOFT 365.docx` (49 MB) → estratto completo → 2026-switch-piano-terra.md, vendor-management.md
- [ ] `Problema Delega Caselle.docx` — MEDIA (correlato incidente phishing gen 2026)
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
- [ ] `Configurazione server IMAP in Odoo.docx` — MEDIA
- [ ] `Mancata Ricezione Mail Gestionale TRex_Odoo.docx` — MEDIA
- [ ] `Problema CSRF Token T_Rex.docx` — MEDIA
- [ ] `2022-10-20_Gestione_bolli_magazzino/` — BASSA
- [ ] `Cambio sequenze fatturazione anno nuovo/` — BASSA
- [ ] `TREX tour/` — BASSA
- [ ] `cheklist-interventi (old).docx` — BASSA
- [ ] `Interrogare attività utente specifico in Odoo.docx` — MEDIA
- [ ] `102025 - Note migrazione gestionale.txt` — ALTA (call Favale, note migrazione T-Rex)
- [ ] `2026-01-21_Monitoraggio_app_T-Rex.xlsx` — MEDIA
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
- [ ] `BREVE GUIDA PER LA CONNESSIONE DA REMOTO ALLA VPN AZIENDALE.pdf` — BASSA
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
- [ ] `FAQ portale AI.docx` — MEDIA (FAQ utenti SCENIA)
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
- [ ] `Allegati.docx` — ALTA (allegati DPA)
- [ ] `Elenco SubResponsabili Intrawelt.docx` — ALTA
- [ ] `SaaS security.docx` (9.8 MB) — ALTA
- [ ] `che tipo di dati DI PERSONE FISICHE trattiamo.txt` — ALTA (DPIA input)
- [ ] `Checklist_Sicurezza_Dropdown.xlsx` — MEDIA
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
- [x] `00_Aprile 2025/` → scenia_sep2025_base_stabile.txt (PARZIALE: 200/764 §)
- [ ] `01_Maggio 2025/` — MEDIA
- [ ] `02_Giugno 2025/` — MEDIA
- [ ] `03_Luglio 2025/` — MEDIA
- [ ] `04_Agosto 2025/` — MEDIA
- [ ] `05_Settembre 2025/` — MEDIA
- [ ] `06_Ottobre 2025/` — MEDIA
- [ ] `07_Novembre 2025/` — MEDIA
- [ ] `08_Dicembre 2025/` — MEDIA
- [ ] `09_Gennaio 2026/` — MEDIA
- [ ] `10_Febbraio 2026/` — MEDIA
- [ ] `11_Marzo 2026/` — MEDIA
- [ ] `12_Aprile 2026/` — MEDIA
- [ ] `13_Maggio 2026/` — MEDIA (più recente)
- [ ] `_GESTIONE OUTSOURCING CON F.GIORGINI/` — ALTA (contratto/gestione Fabio Giorgini)

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
- [ ] `Notes (thinking lab) 12012026.docx` — MEDIA (note tecniche Alessio)
- [ ] `Progetto ENI ruolini (nov24)/` — ALTA (contesto IntraPanel/ENIVIPA)
- [ ] `[TBC] PASSWORD MANAGER/` — ALTA (gap SEC-007 in GAP-TBC)
- [ ] `[TBC] SERVER DNS PERSONALIZZATO/` — MEDIA
- [ ] `[TBC] STUDIO - CLAUDE SUBAGENTS/` — BASSA
- [ ] `[TBC] STUDIO - CHERSHIRE CAT/` — BASSA
- [ ] `OpenProject/` — MEDIA (project management interno)
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
- [ ] `Integrazione Odoo - portale/` — ALTA (blocco attuale task_3)
- [ ] `Integrazione Odoo - centralino cloud vianova/` — ALTA (integrazione PBX Vianova)
- [ ] `Appina per query gestionale, webhook (2025)/` — MEDIA
- [ ] `Odoo_12/28052025 - Risoluzione fix.docx` (7 MB) — MEDIA (storia bug pre-migrazione)
- [ ] `[TBC] STUDIO - INTEGRAZIONE ODOO NINJAONE (RMM).txt` — MEDIA
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
