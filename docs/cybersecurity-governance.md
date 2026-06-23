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
