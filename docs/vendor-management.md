# Vendor Management – Intrawelt S.a.s.

Registro fornitori IT e contratti attivi. Owner: Alessio Sopranzi.  
Aggiornato: giugno 2026.

---

## Vianova S.p.A. – ISP e telefonia

| Campo | Valore |
|-------|--------|
| Tipologia | ISP primario, PBX cloud, linee dati |
| Contratto | FTTO 1 Gbps + Ponte Radio backup + Telefonia cloud |
| Inizio servizio dati | Gennaio 2026 (migrazione da TIM completata) |
| Inizio servizio telefonia | Aprile 2024 |
| Costo indicativo | 984 €/mese (linea dati + telefonia) |
| IP pubblici | Pool 193.124.241.x/28 (14 IP utilizzabili) |
| Hardware fornito | Router Vianova R-1000 x2 (HSRP), UPS-700 |
| SLA | [TBC] |
| Contatto tecnico | [TBC] |
| Nota storica | Decisione migrazione da TIM: 10/12/2024 (Alessandro). Hardware: 31/12/2025. Primo appuntamento tecnico: 02/02/2026. TIM contratto cessato: luglio 2025. |

**Evoluzione rapporto:**

| Data | Evento |
|------|--------|
| Apr 2024 | Prima fattura Vianova (solo telefonia) |
| 10/12/2024 | Decisione di migrare anche la linea dati da TIM a Vianova |
| 20/01/2025 | Sopralluogo TIM per FTTO (infrastruttura Vianova usa rete fisica TIM) |
| 31/12/2025 | Consegna hardware Vianova (router, UPS) |
| 02/02/2026 | Primo appuntamento tecnico Vianova per attivazione dati |
| Mag 2025 | TIM ADSL dismessa fisicamente |
| Lug 2025 | Contratto TIM cessato completamente |

---

## Zyxel – Firewall e switch

| Campo | Valore |
|-------|--------|
| Tipologia | Firewall UTM + Switch managed L2/L3 + AP WiFi |
| Prodotti | USG FLEX 500, XGS2220-54HP (P2), XGS2220-30HP (PT, apr 2026) |
| Gestione | Zyxel Nebula cloud portal (zero-touch) |
| Licenze | Nebula Pro Pack (UTM: BPP, CIP, sandbox, SSL inspection, IP reputation) |
| Supporto | Daniele Colò (Punto Informatica) tramite portale Nebula |
| Scadenza licenza | [TBC] |
| Note | XGS2220-30HP installato 08/05/2026. AP gestiti Nebula. Firmware AP 0-9-1 (tetto) basato su Debian 7 EOL – aggiornamento urgente. |

---

## Punto Informatica – Partner hardware e RMM

| Campo | Valore |
|-------|--------|
| Tipologia | Partner hardware, NinjaOne RMM, supporto infrastructure |
| Contatto principale | Daniele Colò |
| SLA hardware | 2 ore (accordo verbale) |
| RMM | NinjaOne – gestione centralizzata endpoint remoti |
| Ambito | Fornitura hardware (NAS, server, switch, AP), manutenzione |
| Modalità fatturazione | [TBC] |

---

## NinjaOne – RMM

| Campo | Valore |
|-------|--------|
| Tipologia | Remote Monitoring and Management |
| Vendor RMM | NinjaOne (gestito da Daniele Colò / Punto Informatica) |
| Funzioni attive | Monitoring endpoint, remote access, patching, alerting |
| Endpoint gestiti | Tutte le postazioni Windows aziendali + server |
| Integrazione | Bitdefender GravityZone (alert correlati) |
| Costo | Incluso nel rapporto con Punto Informatica [TBC] |

---

## Bitdefender – Endpoint Security

| Campo | Valore |
|-------|--------|
| Prodotto | GravityZone Business Security Enterprise |
| Funzionalità attive | AV, EDR, XDR, exploit defense, network attack defense |
| Funzionalità pianificate | Risk Management + Patch Management (modulo VA interno) |
| Licenze | [TBC] – tutte le postazioni Windows + server |
| Console | GravityZone cloud console |
| Integrazione | NinjaOne RMM |

---

## Seeweb – IaaS Cloud

| Campo | Valore |
|-------|--------|
| Tipologia | Infrastructure as a Service (cloud VE) |
| Servizi | VM cloud, hosting siti web aziendali |
| Connessione | VPN site-to-site IPsec IKEv1 (PSE-SEEWEB, peer 37.9.228.x) |
| Endpoint cloud | domv.intrawelt.com e altri |
| Costo | [TBC] |
| Note | VPN tunnel always-on. Aggressive mode IKEv1 – valutare upgrade a IKEv2 per sicurezza. |

---

## Microsoft – M365 e Azure

| Campo | Valore |
|-------|--------|
| Servizi | Microsoft 365, Exchange Online, SharePoint, Teams, Azure AD/Entra ID |
| Tenant | intrawelt.com |
| Admin globale | asopranzi@intrawelt.com |
| Azure admin | asopranzi, anasini, tvezeni, atrovato |
| MFA enforcement | Attivo su account Azure admin da 01/10/2025 |
| Mail server | Exchange Online (Microsoft, non on-premise) |
| Storage mail | Metadati: 21gg max (vincolo garante) |
| Note | Politica archiviazione da rivedere. Regolamento uso sistemi informativi da produrre. |

---

## Onova S.p.A. – VA non credenzialato

| Campo | Valore |
|-------|--------|
| Tipologia | Vulnerability Assessment esterno |
| Servizio erogato | VA non credenzialato perimetro interno/esterno |
| Data | 06/11/2025 |
| Report | docs/vulnerability-assessment-nov2025.md |
| Criticità trovate | 8 (di cui 2 CRITICHE, 3 ALTE) |
| Costo | [TBC] |
| Note | Unica VA formale effettuata finora. Anomalie non ancora tutte risolte. |

---

## Proelium – Penetration Test (valutazione)

| Campo | Valore |
|-------|--------|
| Tipologia | Penetration Test esterno (in valutazione) |
| Contatti | Luca Battistini, Luca Ruggeri |
| Fondazione | 2025 |
| Specializzazione | Application security web, external PT, internal PT |
| Incontro | 19/01/2026 (call informativa) |
| Costo stimato VA | ~2.000 € + IVA (3 giorni, perimetro non grande) |
| Servizio | Black-box external: enumerazione asset, servizi esposti, brute force, web compromise |
| Piattaforma | SaaS proprietaria per report, track vulnerabilità, storico |
| Stato | Non ancora ingaggiato. Decisione subordinata a piano budget 2026. |

---

## RWS / SDL – GroupShare (Trados)

| Campo | Valore |
|-------|--------|
| Tipologia | Piattaforma CAT (Computer-Aided Translation) |
| Prodotto | GroupShare (server traducenti, project management) |
| Server | WINGROUPSHARE – IP 10.1.116.3 (raggiungibile via LAN/VPN) |
| Accesso remoto | VPN IKEv2 (RemoteAccess_Wiz) o SSL VPN |
| Note | Integrazione con workflow traduzione Intrawelt. Gestione utenti PM e traduttori. |

---

## QNAP – NAS

| Campo | Valore |
|-------|--------|
| Tipologia | NAS storage (hardware) |
| Dispositivi | HERO (192.168.20.169), INTRA (192.168.20.168), INTRA2 (10GbE, .177), INTRA3 (.172), DOC (.170 – HP HPX1400) |
| Storage policy | HERO = backup secondario; INTRA/INTRA2 = produzione; DOC = documenti |
| Backup | [TBC] – schema backup definito in business-continuity-disaster-recovery.md |

---

## Aruba – DNS e domini

| Campo | Valore |
|-------|--------|
| Tipologia | Registrar DNS, hosting domini |
| Domini gestiti | intrawelt.com, intrawelt.it [TBC altri] |
| DNS | [TBC] – Aruba o Microsoft DNS? |

---

## Openforce – Sviluppo T-Rex / Odoo

| Campo | Valore |
|-------|--------|
| Tipologia | Sviluppo software (ERP Odoo, T-Rex) |
| Progetto | T-Rex: sistema gestione tour (migrazione/sviluppo Odoo 18) |
| Stato | [TBC] – in sviluppo 2025-2026 |
| Note | Fatture Odoo generate in formato italiano (fattura elettronica). |

---

## Serafino – Consulenza ISO 27001

| Campo | Valore |
|-------|--------|
| Tipologia | Consulente esterno ISO/IEC 27001 |
| Incontro iniziale | 18/04/2025 |
| Roadmap proposta | Gap analysis → ISMS design → audit interno → audit esterno |
| Certificazione personale parallela | ISO 27001 Foundation + CompTIA Security+ SY0-701 (Alessio) |
| Note | Consulente suggerisce CISSP come riconoscimento formale. Disciplinare lavoratori da produrre come primo step. |

---

## Yealink – Telefoni IP

| Campo | Valore |
|-------|--------|
| Tipologia | Terminali VoIP |
| Modelli | T34W (Piano Terra: Potalivo 1-1, Martellini 1-2, Renzi 0-x), T31G (Piano 2: Marini, Sala Conero) |
| VLAN | Voice VLAN 2, LLDP-MED, CoS 5, DSCP EF (46) |
| Integrazione PBX | Cloud Vianova (transizione in corso da centralino fisico) |

---

## MyOffice – [TBC]

| Campo | Valore |
|-------|--------|
| Tipologia | [TBC] |
| Servizi | [TBC] |
| Note | Da documentare |
