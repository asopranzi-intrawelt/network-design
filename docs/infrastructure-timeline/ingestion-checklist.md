# Checklist Ingestion Documenti IT – Intrawelt

Cartella sorgente: `C:\Users\Utente\OneDrive - Intrawelt S.a.s\Documenti - IT`  
Aggiornato: 2026-07-07 | Owner: Alessio Sopranzi

Controllo del drift: `scripts/Check-OneDriveDelta.ps1` confronta la cartella con una
baseline locale (`_notes/.onedrive-manifest.json`, non versionata) e viene eseguito
automaticamente a ogni avvio di sessione (hook SessionStart in `settings.local.json`).
Quando il report segnala variazioni, le voci rilevanti si registrano qui e si riesegue
lo script con `-UpdateBaseline`. Baseline corrente: 2026-07-07.

Legenda: `[x]` estratto | `[ ]` da fare | `[-]` skip intenzionale | `[!]` mai ingestire (credenziali)

Eccezione di anonimizzazione dichiarata (vedi `.claude/rules/anonymization.md`):
i nomi di file e cartelle tra backtick sono percorsi letterali della cartella
OneDrive sorgente e restano verbatim anche quando contengono nomi propri,
perche' un placeholder li renderebbe introvabili. La prosa descrittiva fuori
dai percorsi usa i placeholder.

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
- [x] `Analisi mail/marsk-17062026/analisi-problema-consegna.md` → 2026-switch-piano-terra.md §16-17/06/2026 (7 mail Eni VIPA Power Platform Flow mai arrivate a M365, conclusione: problema lato Eni, trace M365 "tutti stati" non le mostra)
- [-] `Analisi mail/problema Ahmed 23032026/` — Yahoo domain filtering issue, solo immagini screenshot, nessun doc testuale estraibile
- [-] `Analisi mail/aggiornamento export mail/` — immagini e .eml (eliminazione Pasquale da Azure, Adobe annullamento) — BASSA, già documentato in timeline
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
- [x] `Mappatura porte fisiche/` → docs/mappatura-porte-fisiche.md riscritto completo (07/07/2026): `porte_fisiche_via_pescolla_2.xlsx` estratto integrale via openpyxl (4 fogli, colonna "nome porta attuale" con permutazioni etichette) + `intrawelt rete dati.pdf` letto come immagini (rilievo manoscritto Luciani Impianti 20/08/2020, 3 pagine). Nessuna info VLAN/tagging nelle fonti → resta la nota PORT-TAGGING. La voce compariva come `ZYXEL XGS2220/ (×3 doc)`: quella cartella non esiste piu' sotto ARCHITETTURA (verificato 07/07/2026).
- [x] `[TBC] Diagramma di rete e analisi firewall, centralino/` (root progetto, non OneDrive — 29052026, 05062026, 08062026 (steps)) → firewall-zyxel-usg-flex-500.md, network-diagram.md, telefono-pbx-voip.md, 2026-switch-piano-terra.md, GAP-TBC.md #97-100, diagrammi in `.claude/context/diagrams/firewall-dmz-2026/` (01/07/2026 — cartella sorgente da eliminare dopo conferma utente, era marcata [TBC] esplicitamente per completa ingestione e cancellazione)
- [x] `ZYXEL FIREWALL e VPN/myZYXEL - 18122025.docx` → 2025-q3-q4.md §18/12/2025 ZYXEL licenze (USG FLEX 500 Gold Security Pack S232L12101347, XGS2220-54HP S242L06000292, procedura rinnovo Nebula/myZyxel)
- [x] `ZYXEL FIREWALL e VPN/Ricerca Blocco Traffico in uscita per centralino.docx` → 2026-switch-piano-terra.md §23/03/2026 (7 subnet VoIP verificate, nessun blocco firewall, causa non USG FLEX 500)
- [x] `ZYXEL FIREWALL e VPN/BREVE GUIDA PER LA CONNESSIONE DA REMOTO ALLA VPN AZIENDALE.docx` → helpdesk-operations.md §VPN (203.0.113.5, SecuExtender, ncognome, 2FA email, RDP)
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
- [x] `Privacy Policy - NinjaOne RMM Management_rev1.docx` → helpdesk-operations.md §NinjaOne RMM §Politica trasparenza RMM (Request Confirmation policy, log sessioni, accesso consensuale, uso per manutenzione asincrona)

### _QUESTIONARI FORNITORI
- [x] `Questionario Cybersecurity ENI/` → cybersecurity-governance.md §Questionari B2B + timeline 29/04/2025
- [x] `Fidelity/` ESR questionnaire (8 sezioni) → cybersecurity-governance.md §Questionari B2B
- [x] `LB Research/` DPA checklist → cybersecurity-governance.md §Questionari B2B
- [x] `WindTre/` RFQ 10714 (gara traduzioni specialistiche) → cybersecurity-governance.md §Questionari B2B
- [-] `.claude/` folder — skip (questionnaire-compiler skill files, metadati strumento AI)
- [-] altri link e bozze — SKIP (derivati dalle compilazioni sopra)

### _VA e Pentest assessment
- [x] `Onova VA Nov 2025` → vulnerability-assessment-nov2025.md (8 criticità)
- [x] `Proelium preventivo PT` → vendor-management.md §Proelium (dettaglio call 19/01 e preventivo P220126: solo VA, 1.200 €/2gg o triennale 3.100 €, scaduto non accettato) (08/07/2026)

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

- [x] `ONBOARDING_OUTBOARDING.docx` → helpdesk-operations.md §Onboarding/Offboarding (M365 account ncognome@, SharePoint INTERSCAMBIO, Trados, T-Rex via Fabio, NinjaOne rinomina PC; 09/01/2025 trigger; casi reali: Greta Cavalieri 14/11/2024, Aurora Golino 21/01/2025, Rosy Bartuccio 14/03/2025) — file sorgente CONTIENE credenziali, NON ingestate
- [-] `graphify-out/converted/ONBOARDING_OUTBOARDING_dc2b858c.md` — conversione graphify con credenziali in chiaro, non versionare

---

## Helpdesk_PC formatting — 142 file

- [ ] procedure formattazione/provisioning PC — BASSA

---

## Helpdesk_RWS-Groupshare-Studio — 153 file

- [x] `STUDIO-RWS-GROUPSHARE.docx` (39 MB) → estratto completo → vendor-management.md
- [ ] sub-procedure Trados/GroupShare — BASSA (coperte in STUDIO consolidato)

---

## Helpdesk_T-Rex — 208 file

- [x] `aggiornamento groupshare/groupshare-upgrade-handoff.md` (delta 06/07/2026) → 2026-switch-piano-terra.md §06/07/2026 (upgrade GroupShare SR1→SR2+CU15, bloccato su download RWS). ATTENZIONE: il sorgente contiene credenziali in chiaro, ingestita solo la parte tecnica.

- [x] `TREX.docx` (44 MB) → estratto completo → helpdesk-operations.md (sistema tour operator)
- [x] `Storico ticket - case-studies/2022-11-23_EniVipa/ENI_VIPA_Guida_inserimento_SO.docx` → helpdesk-operations.md §Procedura VIPA in T-Rex (wizard, SO, task, fine mese PO)
- [ ] `Storico ticket - case-studies/` altri file (prevalentemente JPG/allegati) — BASSA (archivio storico immagini)
- [-] `Configurazione server IMAP in Odoo.docx` — file non in locale (OneDrive-only)
- [x] `Mancata Ricezione Mail Gestionale TRex_Odoo.docx` → helpdesk-operations.md §T-Rex Sblocco IMAP (procedura periodica: sblocco token ricezione mail, 2 caselle trex/opportunita)
- [x] `Problema CSRF Token T_Rex.docx` → helpdesk-operations.md §T-Rex CSRF Token + 2026-switch-piano-terra.md §19/02/2026 (Persona-F, batch upload XML fallito, sessione corrotta)
- [ ] `2022-10-20_Gestione_bolli_magazzino/` — BASSA
- [ ] `Cambio sequenze fatturazione anno nuovo/` — BASSA
- [ ] `TREX tour/` — BASSA
- [ ] `cheklist-interventi (old).docx` — BASSA
- [x] `Interrogare attività utente specifico in Odoo (v12).docx` → helpdesk-operations.md §Odoo 12 Audit attivita' utente (letto dal mirror graphify-out/converted) (08/07/2026)
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
- [x] `Backup postazioni di lavoro con Veeam_DRAFT 05_02_2025.pdf` → 2025-q1-server-vianova.md §Veeam Agent + business-continuity-disaster-recovery.md §Storage e backup + gap #105 esteso (password in chiaro nel PDF) (08/07/2026)
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
- [-] `script .docx` — SKIP (file 0 byte, non sincronizzato da OneDrive)
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
- [x] `Risposte Tecniche ai Requisiti di Sicurezza.docx` → trovato come estratto in `SCENIA/SECURITY/DPA/extracted/Risposte Tecniche ... AIDAPT.md` → scenia-project.md §Risposte Tecniche AIDAPT (07/07/2026)
- [x] `Re_ Call per smarcare punti security.eml` → scenia-project.md §Change Control (thread Jan 28 – Feb 20 2026: CR process, release trimestrale 4×/anno, canale help@caity.it, 7gg preavviso, changelog post-rilascio — fonte primaria per Allegato G DPA)
- [-] `Caity_BCP, Caity_DRP, Caity_SLA.pdf` — già ingestionati
- [-] `Intrawelt__documento_tecnico_.pdf` — BASSA (overview tecnica base)
- [-] `RispostaMail Sicurezza.pdf` — MEDIA (allegato al thread già ingestionato via eml)

### SCENIA/Sviluppo full-stack (snapshot mensili)
- [x] `00_Aprile 2025/` → 2025-q3-q4.md §02-11/04 SCENIA VM601 setup + Codepen/ER prototipi (txt files; screenshots non estratti)
- [-] `01_Maggio 2025/` — SKIP (solo HTML frontend templates + screenshots, no text docs)
- [-] `02_Giugno 2025/` — SKIP (solo screenshots)
- [-] `03_Luglio 2025/` — SKIP (solo screenshots)
- [-] `04_Agosto 2025/` — SKIP (solo screenshots)
- [x] `05_Settembre 2025/` → 2025-q3-q4.md §SCENIA luglio-set milestones (pipeline.md + PULIZIA BASE STABILE.docx: Persona-N calls aug 25/29, PR #1 merged sep 8, base stabile sep 10, commit 44537be)
- [-] `06_Ottobre 2025/` — SKIP (solo screenshots)
- [-] `07_Novembre 2025/` — SKIP (solo screenshots)
- [-] `08_Dicembre 2025/` — SKIP (solo screenshots)
- [-] `09_Gennaio 2026/` — SKIP (solo screenshots)
- [-] `10_Febbraio 2026/` — SKIP (solo screenshots)
- [-] `11_Marzo 2026/` — SKIP (solo screenshots)
- [-] `12_Aprile 2026/` — SKIP (solo screenshots)
- [x] `13_Maggio 2026/` → 2026-switch-piano-terra.md §SCENIA gen-apr 2026 dev (8 cluster: files_storage, translation_form_ui, email_mjml, sessions, estimate_planner, trados, cors, admin_users; changelog mar-apr 2026)
- [x] `_GESTIONE OUTSOURCING CON F.GIORGINI/` → 2025-q3-q4.md §Ottobre 2025 onboarding Collaboratore-Esterno-1 (fork+PR model, branch strategy, cost analysis Render/Netlify/S3, proposta 29/10/2025)

### SCENIA/File condivisi da AIDAPT
- [x] `Caity_BCP, Caity_DRP, Caity_SLA.pdf` → già ingestionati
- [-] altri file — SKIP (prevalentemente .sdlxliff file di progetto traduzione RWS Trados; non IT ops. File non-traduzione: attività_unimc.xlsx, Intrawelt-CAITY.pdf, presentazione intrawelt Alborino.pdf — BASSA)

### SCENIA/Ricerca Unimc
- [x] `Benchmark Study per Intrawelt.docx` → scenia-project.md §Ricerca UNIMC – Benchmark ScenIA (metodologia: 140+ coppie ling., high/low-resource split, metriche COMET-22/XCOMET-XL/BLEU, nota data leakage)
- [-] paper accademici (6 PDF: BLASER META, Experts Errors Context, ecc.) — SKIP (letteratura esterna, non IT ops)

### SCENIA/analisi knowledgebase
- [x] `metriche_documenti_25-05-2026.json` → scenia-project.md §Knowledge Base ScenIA Metriche (snapshot Vector Store Qdrant 25/05/2026: document_id, language, argument, organization_id, chunks)

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
- [x] `Progetto ENI ruolini (nov24)/` → 2024-infra.md §Novembre 2024 app desktop (Python/PyQt6, pipeline Word→Excel per T-Rex, 12-19 nov 2024, Persona-N)
- [x] `[TBC] PASSWORD MANAGER/` → cybersecurity-governance.md §Studio Password Manager (Vaultwarden Docker LAN, gap SEC-007 non implementato)
- [x] `[TBC] SERVER DNS PERSONALIZZATO/` → 2025-q3-q4.md §18/12/2025 Studio Pi-hole (studio mai implementato) (08/07/2026)
- [ ] `[TBC] STUDIO - CLAUDE SUBAGENTS/` — BASSA
- [ ] `[TBC] STUDIO - CHERSHIRE CAT/` — BASSA
- [x] `OpenProject/` → helpdesk-operations.md §OpenProject VM205 (openproject.local:9001, 3 utenti, disk resize 13/10/2025)
- [x] `Script e Documentazione per Export Giornaliero Automatico TM GROUPSHARE/` → 2025-q3-q4.md §03-04/11/2025 + helpdesk-operations.md §Automazione export TM GroupShare (v1.0.0 03/11, v1.1.0 04/11; PS+AHK+MigratingTMs, NAS \\10.61.20.177, gs.intrawelt.com, daily 02:00)
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
- [x] `Integrazione Odoo - portale/` → helpdesk-operations.md §Integrazione portale SCENIA + 2026-switch-piano-terra.md §04/03/2026 (meeting Referente-OpenForce-1: xml-rpc, user asopranzi, deprecation v19/v20)
- [x] `Integrazione Odoo - centralino cloud vianova/` → helpdesk-operations.md §Studio centralino (2 modalità: SIP Trunk + IP PBX vs API REST Vianova; nessun connettore nativo)
- [x] `Appina per query gestionale, webhook (2025)/` → 2025-q3-q4.md §03/11/2025 Studio API CRM + helpdesk-operations.md §Odoo Studio API CRM (solo thread email in cartella, app mai sviluppata) (08/07/2026)
- [x] `Odoo_12/28052025 - Risoluzione problema restore/` (transcript meet 7 MB) → 2025-q2-migrazione-tim-vianova.md §28/05/2025 restore + helpdesk-operations.md §Odoo 12 Ambiente di sviluppo locale; estratto in _notes/.tmp-docx-odoo-restore/ (08/07/2026)
- [x] `[TBC] STUDIO - INTEGRAZIONE ODOO NINJAONE (RMM).txt` → helpdesk-operations.md §Odoo-NinjaOne RMM TBC (API REST + webhook Python, post-migrazione Odoo)
- [-] `Odoo_12/Sviluppo Odoo Alessio.docx` (62 MB) — SKIP (impraticabile, prevalentemente screenshot)
- [-] `VIDEOs/` — SKIP (multimedia)

---

## Delta 23/06 -> 07/07/2026 (triage del 07/07/2026)

File nuovi o modificati dopo lo snapshot del 23/06, rilevati con
`Check-OneDriveDelta.ps1` (esclusi artefatti graphify-out, cache, mirror scraping).

- [x] `Helpdesk_T-Rex/aggiornamento groupshare/groupshare-upgrade-handoff.md` — ingestita (vedi sezione Helpdesk_T-Rex)
- [x] `Cybersec/Criptare dati a riposo/AUDIT_INVENTORY.md` → cybersecurity-governance.md §Crittografia dati a riposo + GAP-TBC #104/SEC-010 (07/07/2026; dettagli di derivazione password NON riportati nel repo, restano nel sorgente)
- [x] `Cybersec/_QUESTIONARI FORNITORI/WindTre/Busta Tecnica/` → cybersecurity-governance.md §Revisione chiarimenti WindTre RFQ 10714 + timeline Q3 (BitLocker endpoint 03/07, revisione 06-07/07) + §Crittografia (raccordo endpoint). Ingerite le due NOTA-INTERNA; copre anche il delta OneDrive del 07/07 (Annex Part II 2026-07-06.xlsx nuovo, NOTA-INTERNA 07/07 nuova, NOTA-INTERNA 06/07 modificata/superata)
- [x] `Helpdesk_ABBYY/ABBYY.docx` → 2025-q1-server-vianova.md §Migrazione licenze ABBYY (27/02-24/03/2025) + 2024-infra.md voce 06/11/2024 + GAP-TBC #105/SEC-011 (credenziali in chiaro nel sorgente) e #106/SRV-001 (hostname alternati, VM101 vs VM100). Estratto testo in _notes/.tmp-docx-abbyy/, manifesto docx creato (07/07/2026)
- [x] `SCENIA/SECURITY/Allegati/` (A-K separati) + `SCENIA/SECURITY/DPA/` aggiornamenti → scenia-project.md §Allegati A-L, §DPIA stato 02/07, §Risposte Tecniche AIDAPT, Fase 3 timeline (07/07/2026; estratti F/H/I/J via python-docx, DPIA via diff tra versioni extracted/)
- [x] `SCENIA/Checklist caricamento nuovo customer su Scenia.docx` → scenia-project.md §Checklist operativa caricamento nuovo customer (07/07/2026)
- [ ] `SCENIA/Documentazione scenia/` (6 manuali utente/admin IT/EN) — BASSA (manuali prodotto)
- [x] `SCENIA/Useful Resources/call aidapt 6.7.2026.docx` → scenia-project.md §Call AIDAPT 06/07/2026 + timeline Fase 3 (contenuto tecnico Qdrant/KB, nessun tema DPA nella call) (07/07/2026)
- [x] `Sviluppo_interno/Qdrant + Ollama + Ubuntu + n8n/_File Benchmark e implement/` → 2026-switch-piano-terra.md §Benchmark DoE IntraLino + GAP-TBC #107/SRV-002 (07/07/2026; fonti lette: CLAUDE_STATO_PROGETTO.md, GUIDA_test_C4_qwen.md, conclusioni dei due report differenziali; file credenziali della cartella MAI letti ne' riportati). Restano non ingerite le guide Parte_1-3 e Implementazione.docx (17 MB): dettaglio implementativo n8n/Docker, riclassificato BASSA
- [-] `Miscellaneous/Web scraping - Downloaded Web sites/` — SKIP (mirror di un sito esterno, non IT ops)

## Nota PORT-TAGGING (in attesa di input utente, aggiornata 07/07/2026 pomeriggio)

Il tagging delle porte dei due switch (XGS2220-54HP Piano 2, XGS2220-30HP
Piano Terra) per la migrazione al centralino cloud Vianova e' **in corso**:
l'utente ha eseguito interventi il 07/07/2026 e ha salvato le evidenze in
`_notes/[TBC] screenshot e note myoffice/` (16 screenshot, 2 foto e una nota
testuale; non versionati, da analizzare al momento del racconto — dalla nota
e' gia' stata estratta l'architettura della LAN telefoni, vedi timeline
07/07/2026 e FW-012). Il racconto completo arrivera' **a lavori conclusi**, quando
tutti gli endpoint (telefoni inclusi) funzioneranno. Nel frattempo sono
tracciati i fatti gia' noti: voce 07/07/2026 in
`2026-switch-piano-terra.md`, gap NET-008 (VLAN 1 non taggabile sulla
dorsale senza perdere connettivita' verso NAS-HERO) e TEL-002 (telefoni via
vano ascensore non passano le VLAN) in GAP-TBC #102/#103. `Mappatura porte
fisiche/` e' stata ingestita (nessuna informazione VLAN nelle fonti).

## Riepilogo priorità (rigenerato 07/07/2026 dallo stato reale delle spunte)

| Priorità | Da fare |
|----------|---------|
| ALTA | nessuna voce aperta (Mappatura porte fisiche, Risposte Tecniche AIDAPT e delta SCENIA ingeriti il 07/07) |
| MEDIA | nessuna voce aperta: delta ingerito il 07/07, preesistenti ingerite l'08/07 (Proelium, Interrogare Odoo, Odoo_12 restore, Appina, SERVER DNS, Veeam DRAFT; il Regolamento rev1.pdf era gia' coperto dal .docx ingerito) |
| BASSA | tutto il resto (PROXMOX, QNAP cloud, NinjaOne, PC formatting, ticketing old, RAEE, OpenAI, Ricerche, manuali Scenia, ecc.) |
| SKIP | Cartella_riservata_IT e ogni file credenziali, dati raw ENIVIPA, Timbracartellini, ABBYY screenshot, TEST/, VIDEOs/, Web scraping, Sviluppo Odoo Alessio.docx 62MB |
