# Cybersecurity Governance – Intrawelt S.a.s.

Cronologia e stato delle attività di sicurezza informatica. Copre il periodo 2024-2026.
Owner: Alessio Sopranzi. Aggiornato: giugno 2026.

---

## Timeline eventi di sicurezza

### 2024

| Data | Evento | Dettaglio |
|------|--------|-----------|
| Giu 2024 | Installazione Bitdefender GravityZone | Deployment completo su tutti gli endpoint Windows. EDR/XDR attivo. |
| Ago 2024 | Analisi firewall USG FLEX 500 | Prima analisi approfondita configurazione firewall: policy, VPN, UTM. |
| Ott 2024 | VA interno Bitdefender | First scan con modulo Risk Management GravityZone. |

### 2025 – Q1 e Q2

| Data | Evento | Dettaglio |
|------|--------|-----------|
| Feb 2025 | Cambio gruppo di continuità | Sostituzione UPS principale. |
| 18/04/2025 | Riunione Serafino ISO 27001 | Prima consulenza strutturata ISO 27001. Identificazione: disciplinare lavoratori, politica password, badge sala server, formazione phishing come prerequisiti immediati. Serafino consiglia CISSP come percorso certificativo. |
| Mag 2025 | Phishing notes e documentazione | Documentazione protezione phishing/spoofing (SPF, DKIM, DMARC). Miniguida per utenti (gruppo Teams). |
| Mag 2025 | Data protection procedure | Stesura procedura protezione dati (GDPR alignment). |

### 2025 – Q3

| Data | Evento | Dettaglio |
|------|--------|-----------|
| 17/09/2025 | Email Microsoft MFA enforcement | Microsoft comunica obbligo MFA per account Azure admin dal 01/10/2025. |
| 19/09/2025 | Analisi account Azure admin | Identificati 4 account con ruoli Azure: asopranzi, anasini, tvezeni, atrovato. Test MFA su tvezeni (già configurato → ok) e atrovato (non configurato → scollegato da tutte le risorse MS). |
| 19/09/2025 | Decisione MFA rolling | Rinviare configurazione per account non precedentemente impostati: Microsoft applica enforcement automaticamente da 01/10/2025, ma solo per operazioni Azure (non Office 365). |
| 01/10/2025 | MFA enforcement attivo | Microsoft attiva enforcement. Account Azure admin devono completare setup MFA al primo login. |

### 2025 – Q4

| Data | Evento | Dettaglio |
|------|--------|-----------|
| 06/11/2025 | VA non credenzialato Onova | Vulnerability Assessment esterno perimetro interno. 8 anomalie trovate (2 CRITICHE, 3 ALTE, 3 MEDIE). Report completo: docs/vulnerability-assessment-nov2025.md. |
| Nov 2025 | Piano intervento rete | Documento piano intervento rete post-VA (marcato "COMPLETAMENTE DA AGGIORNARE" a feb 2026). |
| Dic 2025 | Bitdefender Risk Management | Valutazione attivazione modulo Patch Management + VA interno continuo. |

### 2026 – Q1

| Data | Evento | Dettaglio |
|------|--------|-----------|
| 19/01/2026 | Call informativa Proelium | Incontro con Luca Battistini e Luca Ruggeri (Proelium, nata 2025). Presentazione servizi PT esterno (black-box), graybox web app, piattaforma SaaS report. Costo indicativo VA: ~2.000€ + IVA per 3 gg. PT esterno quotazione da fare. |
| Q1 2026 | Executive summary PT | Documento di valutazione strategia sicurezza: Bitdefender + PT esterni come approccio ibrido. |
| Feb 2026 | Physical security stub | Documento sicurezza fisica (da espandere). |
| Mar 2026 | Piano attività sicurezza 2026 | [TBC] |

### 2026 – Q2

| Data | Evento | Dettaglio |
|------|--------|-----------|
| Mag 2026 | Audit interno pianificato | Pianificato audit interno pre-certificazione ISO 27001. |
| Giu 2026 | Audit esterno pianificato | Pianificato audit esterno da ente accreditato per certificazione ISO 27001:2022. |

---

## Bitdefender GravityZone – Stato implementazione

| Funzionalità | Stato | Note |
|--------------|-------|------|
| Antivirus / Anti-malware | Attivo | Tutti gli endpoint |
| EDR (Endpoint Detection & Response) | Attivo | Alert correlati con NinjaOne |
| XDR (Extended Detection & Response) | Attivo | |
| Network Attack Defense | Attivo | |
| Exploit Defense | Attivo | |
| Sandbox Analyzer | Attivo (cloud) | |
| Risk Management (VA interno) | Pianificato | Modulo da attivare |
| Patch Management | Pianificato | Modulo da attivare |
| Email Security | [TBC] | Exchange Online – da verificare integrazione |

**Protezione LAN documentata in:**  
`_notes/.tmp-docx-CYBERSEC/bitdefender_protezione_lan.txt` (203 paragrafi)

---

## Vulnerability Assessment – Onova (06/11/2025)

**Scope:** Perimetro interno, non credenzialato.  
**Metodologia:** Scan automatizzato + analisi manuale.  
**Report completo:** `docs/vulnerability-assessment-nov2025.md`

### Anomalie principali

| ID | Dispositivo | Severità | Stato |
|----|-------------|----------|-------|
| FW-001 | Regola Phishing_Elisa action=ALLOW | CRITICA | Aperto |
| FW-002 | Switch management su VLAN Guest (.90.37) | CRITICA | Aperto |
| UPS-001 | UPS Emerson Liebert su VLAN Guest (.90.33) | ALTA | Aperto |
| EOL-001 | MyHome Server CentOS 7.6 EOL (.90.40) | ALTA | Aperto |
| EOL-002 | Bticino citofono Linux 2.6 EOL (.90.41) | MEDIA | Aperto |
| AP-001 | AP tetto 0-9-1 Debian 7 EOL | ALTA | Aperto |
| VPN-001 | PSE-SEEWEB IKEv1 aggressive mode | MEDIA | Da valutare upgrade IKEv2 |
| FW-003 | Virtual server inutilizzati attivi (7 disabilitati) | BASSA | Aperto |

---

## Protezione phishing e spoofing

**Documentazione:** `_notes/.tmp-docx-CYBERSEC/phishing_notes.txt` (58 paragrafi)

Controlli implementati:
- SPF record sul dominio intrawelt.com
- DKIM configurato su Exchange Online
- DMARC in modalità [TBC – policy reject o quarantine?]
- Filtri anti-spam Exchange Online
- Regola firewall `Blocco_Gruppo_IP_Phishing_Elisa` (action=ALLOW → BUG FW-001)
- Miniguida phishing condivisa su gruppo Teams da Alessio

Gap:
- FW-001: regola phishing inoperante (action=ALLOW)
- Formazione strutturata anti-phishing non erogata a tutti i dipendenti
- Simulazioni phishing non eseguite

---

## Percorso certificativo personale (Alessio)

| Certificazione | Stato | Note |
|----------------|-------|------|
| CompTIA Security+ SY0-701 | In corso | Studio in autonomia |
| ISO/IEC 27001 Foundation | In corso | Parallelo alla preparazione aziendale |
| CISSP | Pianificato (lungo termine) | Consiglio di Serafino come riconoscimento formale |

---

## GDPR e data protection

**Procedura data protection:** `_notes/.tmp-docx-CYBERSEC/data_protection.txt` (74 paragrafi)

Punti chiave emersi dalla riunione Serafino (18/04/2025):
- Metadati email: max 21 giorni (vincolo garante)
- Disciplinare lavoratori: in preparazione (gestione sistemi informativi, chiavette USB, accesso Internet)
- File .pst ex-dipendenti: politica conservazione 10 anni per dati patrimoniali
- Delega caselle email: tracciare operazione IT, risposta con indirizzo del delegato
- Risposta automatica "fuori sede": da automatizzare con approvazione turni
- Dispositivi personali BYOD: politica da formalizzare
- Badge accesso sala server: da implementare (doppio valore: security + ISO 27001)

**DPIA SCENIA:** Prodotta nel 2026 per il progetto SCENIA (AI translation platform).

---

## Registro Sub-Responsabili del Trattamento (GDPR Art. 28)

Fonte: `Cybersec & IT Governance/Privacy (GDPR e Contratti)/SubResponsabili Intrawelt/`
`Elenco SubResponsabili Intrawelt.docx` — documento formale, aggiornato 2025-2026.

| Fornitore | Attività | Dati | Ubicazione | Scadenza DPA |
|-----------|----------|------|-----------|--------------|
| Microsoft Ireland Operations Ltd. (Dublino, IE) | M365, Azure | Email, documenti, file | Data center EU (IE, NL) | 2027 (rinnovo annuale; sottoscritto 2018) |
| Bitdefender | EDR/XDR endpoint security | File di sistema, traffico rete, dati nei dispositivi | EU + paesi terzi (GDPR compliant) | 2026 (rinnovo annuale; sottoscritto 15/09/2025) |
| NinjaOne LLC (Oldsmar FL, USA) | RMM, patching, backup remoto | Inventario SW, log attività, dati nei dispositivi | USA + altre regioni (GDPR/HIPAA) | 2027 (rinnovo annuale; sottoscritto 2026) |
| Zyxel / Nebula | Firewall, switch, AP (cloud mgmt Nebula) | Config rete, log, IP/MAC | AWS Irlanda + repliche | 2027 (rinnovo annuale; sottoscritto 2020) |
| RWS Holdings plc (Chalfont St Peter, UK) | Trados, GroupShare, Language Weaver | File da tradurre, TM, glossari, metadati | EU + UK (adequacy EU→UK val. 27/12/2031) | 2027 (rinnovo annuale) |
| Odoo SA (Ramillies, BE) | ERP/CRM, fatturazione, contratti | Dati aziendali, clienti, fatture | Data center EU (BE, FR) | 2028 (rinnovo triennale; sottoscritto 19/09/2019) |
| QNAP Cloud | NAS cloud backup | File, log, config, accessi remoti | Data center globali (13 sedi, incluse EU e USA) | 2027 (rinnovo annuale) |
| Seeweb Srl (Frosinone, IT) | Hosting, cloud server, housing | Dati di sistema, backup, config | Italia e Svizzera | N/A (sottoscritto 26/09/2014, in corso) |
| Openforce Srls (Pedaso FM, IT) | Implementazione/personalizzazione Odoo ERP | Dati contabili, ordini, fatture, CRM | Server cloud EU (Odoo Enterprise) | 2027 (rinnovo annuale; sottoscritto 24/05/2018) |
| Punto Informatica SNC (Porto San Giorgio, IT) | Vendita HW/SW, assistenza tecnica | Dati cliente, ordini, fatture | Server locali/gestionali interni | 2026 (rinnovo annuale; sottoscritto 01/02/2025) |
| Eter Biometric Technologies Srl (Modena, IT) | Sistemi biometrici, controllo accessi, presenze | Dati biometrici, log presenze, accessi | Server locali o cloud EU | 2027 (rinnovo annuale; sottoscritto 2020) |

Nota: AIDAPT S.r.l. (sub-processor SCENIA) documentato separatamente in `docs/scenia-project.md`
(DPA SCENIA Art. 28 v1.7 in negoziazione a giugno 2026).

---

## Procedura Data Breach

Fonte: `Cybersec & IT Governance/Privacy (GDPR e Contratti)/Procedura_Data_Breach/`
Documento principale: `PROCEDURA DATA BREACH INTRAWELT_X.docx` (82 KB)
Registro: `Registro_Data_Breach.xlsx`; Modello notifica: `Modello notifica Data Breach.pdf`

### 4 fasi operative

1. **Identificazione e indagine preliminare**: ricezione segnalazione via Allegato A
   (Modulo comunicazione interna), valutazione se breach effettivo, registrazione univoca.
2. **Risk assessment**: valutazione gravità con Allegato B (Modulo rischio), individua:
   (a) misure correttive immediate; (b) necessità notifica Garante (art. 33); 
   (c) necessità comunicazione interessati (art. 34).
3. **Notifica all'Autorità Garante**: entro 72h se probabile rischio per diritti/libertà
   delle persone fisiche (art. 33 GDPR). Titolare: Alessandro Potalivo.
4. **Comunicazione agli interessati**: se rischio elevato (art. 34); comunicazione diretta
   (no newsletter), chiara e trasparente.

### Soglie di notifica
- Art. 33 (→ Garante): rischio non trascurabile per i diritti degli interessati.
- Art. 34 (→ interessati): rischio elevato per i diritti degli interessati.

### Monitoraggio eventi
- ICT: addetti Sistemi Informativi (Alessio Sopranzi) segnalano al Titolare.
- Fisico: chiunque rilevi violazione fisic (furto dispositivi, scasso archivi) segnala al Titolare.

### Documentazione obbligatoria
Ogni breach (anche sotto soglia notifica) va registrato nel Registro Data Breach con:
n. scheda, data, luogo, cause, banche dati coinvolte, tipologia dati, conseguenze,
piano intervento, esito notifiche.

Gap attuale: procedura non ancora integrata con la catena notifica SCENIA
(Titolare ScenIA → AIDAPT 48h vs. art. 33 GDPR 72h — vedi scenia-project.md §DRP §6).

---

## Questionari sicurezza clienti B2B

Fonte: `Cybersec & IT Governance/_QUESTIONARI FORNITORI/`
Gestione attiva tramite skill `questionnaire-compiler` (`.claude/skills/questionnaire-compiler/`).

| Cliente | Questionario | Data | Stato |
|---------|-------------|------|-------|
| ENI Servizi S.p.A. | Questionario Cyber Security B (xlsx) | 29/04/2025 | Compilato (Questionario_B_alesop 29042025.xlsx) |
| Fidelity Investments | ESR questionnaire (8 sezioni: ISO27001, PT, VA, asset mgmt, DLP, password, logging, 3rd party) | Set/Ott 2025 | Compilato (.fi.docx versions); Issues log 30/09/2025 |
| LB Research | FT_DP_017_03 Checklist (Sub)Responsabile + Nomina + Allegati (DPA, Data flow, BCD) | 2025-2026 | In corso/completato |
| Wind Tre / RFQ 10714 | Busta Tecnica: Information Security Annex Part II + AI Questionnaire + SLA requirements | 2026 (rev 28/05/2026) | In corso gara traduz. specialistiche |
| ACEA | Documenti gara (link) | 2025 | — |
| BCE | Link esterno | 2025 | — |
| Advice Pharma | Link esterno | 2025 | — |
| Elena (fornitore) | 2 domande (feb 2026): accesso con user/pass; procedura sicurezza dati cliente | Feb 2026 | Completato |

I questionari compilati costituiscono evidenza dell'implementazione ISO 27001 e del
livello di maturità security dichiarato verso i clienti. Wind Tre (RFQ 10714) è la
gara piu' significativa per volume e complessita' (busta tecnica + commerciale + legale).

---

## Registro utilizzo sistemi informatici – stato firme

Fonte: `Cybersec & IT Governance/Regolamento utilizzo sistemi informatici/Registro_accettazione.docx`
Documento: lista di 21 dipendenti + 4 righe vuote per nuovi assunti.
Prima versione inviata: 19/04/2021 come allegato email.
File disponibile su: `\\192.168.20.170\utili\Privacy\Regolamento utilizzo sistemi informatici\`

**Stato attuale (verificato giugno 2026): 0 firme su 21 dipendenti elencati.**

Tutti i campi FIRMA e DATA sono vuoti per:
Apollonio Luigi, Bartolucci Elena, Carlacchiani Marcello, Cenerini Marika, Coppola Luigi,
Guidali Fabio, Kaemmer Oliver, Mandolesi Giordano, Marini Marsk, Marini Sergio,
Martellini Sonia, Martinelli Mery, Monterubbianesi Elisa, Nasini Alessia, Natale Joanne,
Nazziconi Alessia, Ripa Roberta, Scattolini Sara, Sconciafurno Pasquale, Stasi Daniel,
Stratmann Ulrike.

Gap: ISO-001 confermato ad alta priorità. Necessaria campagna di raccolta firme formale.
Vedi GAP-TBC.md riga ISO-001 per dettaglio.

---

## Incident Response – Gap

Non esiste un processo formale di incident response. In caso di incidente, il flusso attuale è:
- Rilevamento via Bitdefender alert o NinjaOne
- Escalation informale ad Alessio
- Intervento diretto senza playbook strutturato

**Da sviluppare per ISO 27001:**
- Classificazione incidenti (P1/P2/P3)
- Playbook per ransomware, phishing successo, data breach
- Comunicazione al garante entro 72h in caso di data breach (GDPR art. 33)
- Post-mortem strutturato
