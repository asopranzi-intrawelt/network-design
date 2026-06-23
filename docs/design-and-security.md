# Design e Sicurezza – Intrawelt S.a.s.

Documento di governance della sicurezza IT. Contiene l'analisi dei principi di design,
la Statement of Applicability ISO/IEC 27001:2022 e il piano di implementazione.

Owner: Alessio Sopranzi. Aggiornato: giugno 2026.

---

## Principi di design

| Principio | Stato | Note |
|-----------|-------|------|
| Segmentazione di rete (VLAN) | Parziale | VLAN 10/20/90 attive. VLAN DMZ 201 pianificata. |
| Least privilege | Parziale | Admin Azure limitati a 4 account. Permessi locali da rivedere. |
| Defense in depth | Parziale | Firewall UTM + Bitdefender EDR. Manca IDS/IPS interno. |
| MFA su account critici | Attivo | Azure admin (asopranzi, anasini, tvezeni, atrovato) da 01/10/2025. |
| Backup 3-2-1 | Parziale | NAS multipli. Schema formale in BC/DR doc. |
| Patch management | Pianificato | Bitdefender Risk Management + Patch Management (da attivare). |
| Log centralizzato | Parziale | Firewall log + Bitdefender. SIEM non presente. |
| VA periodico | Attivo | VA nov 2025 (Onova). Cadenza annuale pianificata. |

---

## Statement of Applicability – ISO/IEC 27001:2022 Annex A

Nota: la SoA è la dichiarazione formale di quali controlli ISO27001 sono applicabili, implementati o esclusi.
Stato: pre-gap analysis (la gap analysis formale è pianificata entro fine 2025, da aggiornare con Serafino).

### Legenda

| Stato | Significato |
|-------|-------------|
| SI – Completo | Controllo implementato e verificato |
| SI – Parziale | Controllo in parte implementato, gap residui |
| NO – Escluso | Controllo non applicabile (motivazione richiesta) |
| PIANIFICATO | Controllo da implementare nella roadmap |

---

### A.5 – Politiche per la sicurezza delle informazioni

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.5.1 | Politiche per la sicurezza delle informazioni | SI | Parziale | Nessuna policy formale pubblicata. Disciplinare lavoratori in preparazione (Serafino 18/04/2025). |
| A.5.2 | Ruoli e responsabilità per la sicurezza delle informazioni | SI | Parziale | Alessio = IT manager. Ruoli non formalizzati. |

---

### A.6 – Organizzazione della sicurezza delle informazioni

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.6.1 | Sicurezza delle informazioni nel project management | SI | Parziale | SCENIA: DPIA prodotta. Altri progetti non coperti. |
| A.6.2 | Lavoro a distanza e telelavoro | SI | Parziale | VPN attiva. Policy uso device personali da formalizzare. |
| A.6.3 | Separazione dei compiti | SI | Parziale | Struttura piccola, separazione limitata. |

---

### A.7 – Sicurezza delle risorse umane

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.7.1 | Screening | SI | NO – Non attivo | Background check non formalizzato. |
| A.7.2 | Termini e condizioni di lavoro | SI | Parziale | Contratto lavoro presente. Non include clausole sicurezza IT specifiche. |
| A.7.3 | Consapevolezza, educazione e formazione | SI | Parziale | Microcorso phishing Teams (Alessio). Formazione strutturata non presente. |
| A.7.4 | Processo disciplinare | SI | Parziale | Non formalizzato per sicurezza IT. |
| A.7.5 | Responsabilità dopo la cessazione del rapporto | SI | Parziale | Procedura offboarding presente (onboarding_outboarding.md). Revoca accessi M365 documentata. |

---

### A.8 – Gestione degli asset

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.8.1 | Inventario degli asset | SI | Parziale | Inventario NAS, server, switch in architettura doc. Non strutturato come registro asset formale. |
| A.8.2 | Classificazione delle informazioni | SI | NO – Non attivo | Classificazione dati non formalizzata. |
| A.8.3 | Gestione dei supporti | SI | Parziale | Chiavette USB da disabilitare (Serafino). Politica da definire. |
| A.8.10 | Cancellazione delle informazioni | SI | Parziale | Offboarding: cancellazione account. Cancellazione dati da dispositivi non documentata. |

---

### A.9 – Controllo degli accessi

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.9.1 | Politica di controllo degli accessi | SI | Parziale | Accessi distinti per utente. Policy formale non prodotta. |
| A.9.2 | Gestione dell'identità degli utenti | SI | SI – Parziale | Active Directory / Entra ID. Onboarding documentato. |
| A.9.3 | Autenticazione degli utenti | SI | SI – Parziale | MFA Azure admin attivo. MFA per tutti gli utenti non attivo. |
| A.9.4 | Diritti di accesso privilegiato | SI | Parziale | 4 account Azure admin identificati. Account locali admin non censiti. |
| A.9.5 | Autenticazione sicura | SI | SI – Parziale | Password policy M365 attiva. Robustezza criteri da rivedere (Serafino). |
| A.9.6 | Gestione delle password | SI | Parziale | Password manager non adottato aziendalmente. |
| A.9.7 | Controllo degli accessi ai sistemi e alle applicazioni | SI | Parziale | Firewall policy, VLAN segmentation. Accessi applicativi non documentati. |

---

### A.10 – Crittografia

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.10.1 | Crittografia | SI | Parziale | VPN IPsec attiva. BitLocker su endpoint? [TBC]. Crittografia NAS [TBC]. |

---

### A.11 – Sicurezza fisica e ambientale

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.11.1 | Perimetro di sicurezza fisica | SI | Parziale | CED con accesso fisico. Badge lettore impronte (BioStar, .20.199). Accesso sala server con badge da implementare (Serafino). |
| A.11.2 | Protezione dell'ambiente fisico | SI | Parziale | UPS Emerson Liebert attivo. Fotovoltaico (2025). Cambiato gruppo continuità feb 2025. |

---

### A.12 – Sicurezza operativa

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.12.1 | Procedure operative documentate | SI | Parziale | Runbook anomalie (questo progetto). Procedure cambio gestione non complete. |
| A.12.2 | Protezione dal malware | SI | SI – Completo | Bitdefender GravityZone EDR/XDR su tutti gli endpoint. |
| A.12.3 | Backup | SI | Parziale | NAS fleet attiva. Schema 3-2-1 non verificato formalmente. |
| A.12.4 | Registrazione e monitoraggio | SI | Parziale | Firewall log, Bitdefender alert. SIEM non presente. |
| A.12.5 | Controllo del software in esercizio | SI | Parziale | NinjaOne patching. Software non autorizzato: policy da produrre. |
| A.12.6 | Gestione delle vulnerabilità tecniche | SI | Parziale | VA nov 2025 (Onova). Patch management Bitdefender pianificato. |
| A.12.7 | Considerazioni sull'audit dei sistemi informatici | SI | NO – Non attivo | Audit trail formale non presente. |

---

### A.13 – Sicurezza delle comunicazioni

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.13.1 | Gestione della sicurezza delle reti | SI | Parziale | Firewall UTM, VLAN segmentation. Switch mgmt su VLAN guest (ANOMALIA FW-002). |
| A.13.2 | Trasferimento delle informazioni | SI | Parziale | VPN per accesso remoto. File transfer tramite SharePoint/Teams. Policy non formale. |

---

### A.14 – Acquisizione, sviluppo e manutenzione dei sistemi

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.14.1 | Sicurezza nei processi di sviluppo | SI | Parziale | SCENIA: requisiti sicurezza AIDAPT documentati. Sviluppo interno IntraLino: sicurezza ad-hoc. |
| A.14.2 | Sicurezza dei servizi di sviluppo e supporto | SI | Parziale | Repository GitHub. CI/CD non formalizzato. |
| A.14.3 | Dati di test | SI | Parziale | Uso dati reali in test [TBC – da verificare]. |

---

### A.15 – Relazioni con i fornitori

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.15.1 | Sicurezza delle informazioni nelle relazioni con i fornitori | SI | Parziale | Vendor tracker (vendor-management.md). DPA con Microsoft. DPA con altri fornitori [TBC]. |
| A.15.2 | Gestione della fornitura di servizi | SI | Parziale | Monitoraggio informale. SLA Vianova [TBC]. |

---

### A.16 – Gestione degli incidenti di sicurezza delle informazioni

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.16.1 | Gestione degli incidenti di sicurezza delle informazioni | SI | NO – Non attivo | Processo di incident response non formalizzato. Da sviluppare come parte del ISMS. |

---

### A.17 – Aspetti della sicurezza delle informazioni nella gestione della continuità operativa

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.17.1 | Continuità della sicurezza delle informazioni | SI | Parziale | BC/DR doc presente. Piano test BC non eseguito. |
| A.17.2 | Ridondanze | SI | Parziale | NAS ridondati, doppio WAN (Vianova + Ponte Radio). |

---

### A.18 – Conformità

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.18.1 | Conformità a requisiti legali e contrattuali | SI | Parziale | GDPR: DPIA SCENIA prodotta. Disciplinare lavoratori da produrre. |
| A.18.2 | Riesame della sicurezza delle informazioni | SI | NO – Non attivo | Riesame formale non pianificato. Da includere in ISMS. |

---

## Roadmap ISO 27001:2022

| Fase | Periodo | Attività | Stato |
|------|---------|----------|-------|
| 0 – Awareness | Apr 2025 | Incontro Serafino, valutazione consulenza | Completato |
| 1 – Gap Analysis | Fine 2025 | Analisi gap rispetto ai controlli Annex A | In corso |
| 1b – Formazione | 2025-2026 | CompTIA Security+ SY0-701 + ISO 27001 Foundation (Alessio) | In corso |
| 2 – ISMS Design | Q1-Q2 2026 | Progettazione ISMS, politiche, procedure | In corso |
| 3 – Disciplinare | Q2 2026 | Regolamento gestione sistemi informativi lavoratori | Pianificato |
| 4 – Audit interno | Mag 2026 | Audit interno pre-certificazione | Pianificato |
| 5 – Audit esterno | Giu-Lug 2026 | Certificazione da ente accreditato | Pianificato |

**Prerequisiti identificati da Serafino (18/04/2025):**
- Disciplinare lavoratori (gestione sistemi informativi)
- Politica password robusta
- Badge accesso sala server
- Formazione phishing per tutti i dipendenti
- Politica chiavette USB e dispositivi personali

---

## Postura di sicurezza – Sintesi

| Area | Livello attuale | Target ISO27001 |
|------|----------------|-----------------|
| Endpoint protection | ALTO (Bitdefender EDR/XDR) | Mantenere |
| Perimetro rete | MEDIO (Firewall UTM + VLAN) | Aggiungere DMZ, correggere anomalie |
| Gestione identità | MEDIO (AD + MFA parziale) | MFA per tutti, PAM |
| Governance policy | BASSO | Produrre policy set completo |
| Incident response | ASSENTE | Sviluppare playbook |
| VA/PT cadenza | MEDIO (annuale) | Mantenere + PT annuale |
| Formazione | BASSO | Programma strutturato |
| Backup/BC | MEDIO | Verificare e testare formalmente |
