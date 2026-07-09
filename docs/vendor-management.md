# Vendor Management – Intrawelt S.a.s.

Registro fornitori IT e contratti attivi. Owner: Alessio Sopranzi.  
Aggiornato: giugno 2026.

---

## Vianova S.p.A. – ISP e telefonia

Due migrazioni distinte verso lo stesso fornitore, in due fasi separate:
la linea dati (fibra FTTO, sostituzione di TIM) nel 2025, e il centralino
cloud (PBX, sostituzione del sistema telefonico tradizionale) tra fine 2025
e il 2026. La prima e' conclusa e ampiamente documentata; la seconda e'
**in corso** ed e' l'oggetto della nota PORT-TAGGING riservata al racconto
completo a lavori conclusi (vedi `current-work.md`).

| Campo | Valore |
|-------|--------|
| Tipologia | ISP primario, PBX cloud, linee dati |
| Contratto | FTTO 1 Gbps + Ponte Radio backup + Telefonia cloud |
| Inizio servizio telefonia (tradizionale) | Aprile 2024 |
| Migrazione linea dati (TIM → Vianova) | Marzo-Luglio 2025, completata (dettaglio in `2025-q2-migrazione-tim-vianova.md`) |
| Migrazione centralino cloud (PBX → Vianova UCC) | In corso da dicembre 2025, non ancora conclusa |
| Costo | Dato amministrativo, non riportato (vedi `.claude/rules/anonymization.md`) |
| IP pubblici | Pool 193.124.241.x/28 (14 IP utilizzabili) |
| Hardware fornito (linea dati) | Router Vianova R-1000 x2 (HSRP), UPS-700 |
| SLA | [TBC] |
| Contatto tecnico | Referente-Vianova-3 (Samuele Sbacco, Key Account Manager), Referente-Vianova-4 (Federico Benetton, Sales Manager) |
| Offerta commerciale (linea dati) | Proposta scritta datata 07/02/2024, tramite il partner My Office/Centro Ufficio Group (Referente-Vianova-1, Vianova Specialist). Canone a due voci (rete fissa FTTO 1Gbps a progetto + opzione traffico flat), contributo di installazione escluso da questa scheda per policy. Durata pluriennale con tacito rinnovo, disdetta a preavviso; penale di recesso anticipato |

**Evoluzione rapporto — linea dati (2024-2025, conclusa):**

| Data | Evento |
|------|--------|
| Apr 2024 | Prima fattura Vianova (solo telefonia tradizionale) |
| 10/12/2024 | Decisione di migrare anche la linea dati da TIM a Vianova |
| 20/01/2025 | Sopralluogo TIM per FTTO (infrastruttura Vianova usa rete fisica TIM) |
| 29/03-01/04/2025 | Consegna hardware Vianova (router R-1000, UPS) — vedi `2025-q2-migrazione-tim-vianova.md` |
| 07/04/2025 | Primo appuntamento tecnico Vianova per attivazione dati |
| Mag 2025 | TIM ADSL dismessa fisicamente |
| Lug 2025 | Contratto TIM cessato completamente (disdetta 15/05/2025, router Huawei non ancora restituiti) |

**Evoluzione rapporto — centralino cloud (dic. 2025-2026, in corso):**

| Data | Evento |
|------|--------|
| 31/12/2025 | Consegna hardware per il centralino cloud (switch/telefoni, dettaglio in `2026-switch-piano-terra.md` e vendor-management.md §Punto Informatica) |
| 02/02/2026 | Primo appuntamento tecnico Vianova per l'attivazione del centralino cloud |
| 13/03/2026 | Acquisto switch Piano Terra Zyxel XGS2220-30HP (Punto Informatica) |
| 24/03/2026 | Acquisto telefoni IP Yealink (Punto Informatica) |
| — | Tagging VLAN fonia in corso, racconto completo riservato a lavori conclusi |

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
| Ragione sociale | Punto Informatica snc di Colò D. & Isidori M., Via Giammarco 28 Fermo (FM) / sede operativa Via Andrea Costa 7 Porto San Giorgio (FM) |
| Contatto principale | Daniele Colò |
| SLA hardware | 2 ore (accordo verbale) |
| RMM | NinjaOne – gestione centralizzata endpoint remoti |
| Ambito | Fornitura hardware (NAS, server, switch, AP), manutenzione |
| Modalità fatturazione | Preventivo → ordine → fattura per singolo acquisto (nessun contratto quadro noto) |
| Acquisto switch Piano Terra | Zyxel XGS2220-30HP-EU0101F acquistato con preventivo del 13/03/2026 (vedi `2026-switch-piano-terra.md` per il dettaglio tecnico dello switch); importi non riportati per policy |
| Acquisto telefoni VoIP | 2× Yealink SIP-T31G e 3× Yealink SIP-T34W acquistati con preventivo del 24/03/2026; importi non riportati per policy |

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
| Contatti | Referente-Proelium-1, Referente-Proelium-2 |
| Fondazione | 2025 |
| Specializzazione | Application security web, external PT, internal PT |
| Incontro | 19/01/2026 (call informativa) |
| Preventivo | Preventivo del 22/01/2026, solo VA: pacchetto singolo (2 giornate) o pacchetto triennale (3× 2 giornate, scontato). Importi non riportati per policy. Validita' 60 giorni (scaduta, non accettata) |
| Servizio | Black-box external: enumerazione asset, servizi esposti, brute force, web compromise |
| Piattaforma | SaaS proprietaria (app.proelium.io): risultati in tempo reale, storico report e vulnerabilita' fixate |
| Stato | Non ancora ingaggiato. Decisione subordinata a piano budget 2026. |

Dalla call informativa del 19/01/2026 (fonte: `notes (19012026) VA esterno.docx`):
l'approccio standard per un primo ingaggio parte dalla superficie esterna, con
enumerazione degli asset e dei servizi esposti a partire dal dominio principale.
Il VA e' dichiaratamente attivita' light (strumenti di scansione noleggiati da
terze parti piu' revisione esperta dei falsi positivi, senza sfruttamento delle
vulnerabilita'); il valore del fornitore sta nel penetration test manuale, che
sulla rete esterna lavora black-box servizio per servizio (brute force sulle
autenticazioni, compromissione dei web server) e sulle web app segue una
metodologia verticale graybox, con credenziali per ogni ruolo applicativo. I
progetti possono essere annuali, con riapertura del ciclo di test ogni 6-12
mesi e reportistica scaricabile con storico. Il preventivo copre il
solo VA: da remoto, previa manleva firmata, con conferma del perimetro e
preavviso a SOC e provider coinvolti; deliverable un report tecnico
(sintesi executive piu' dettaglio con evidenze replicabili, impatto,
probabilita' e rimedio per ogni vulnerabilita'). Fatturazione 40% all'ordine
e 60% alla consegna del report.

---

## RWS / SDL – GroupShare (Trados)

| Campo | Valore |
|-------|--------|
| Tipologia | Piattaforma CAT (Computer-Aided Translation) |
| Prodotto | GroupShare (server traducenti, project management) |
| Server | WINGROUPSHARE – IP 10.77.116.3 (raggiungibile via LAN/VPN) |
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
| Tipologia | Registrar/hosting domini, DNS |
| Domini gestiti (registrar) | ~20 domini di marketing per nicchia di traduzione (traduzionetecnica.net/.com, traduzionemedica, traduzionifinanziarie, traduzionifarmaceutiche, traduzionilegale, traduzionimanuali, traduzionibilanci, traduzionicertificate/-a, traduzioniurgenti, ecc.), via Tucows Domains Inc. o Aruba S.p.A. come registrar; rinnovi annuali marzo 2026 |
| intrawelt.de | Registrato presso DENIC tramite Aruba, DNS gestito da Aruba; contenuto sito redirect gestito da Fastnet verso `intrawelt.com/de/` (non confondere con l'hosting, che resta su Aruba); rinnovo anticipato a dicembre per gennaio |
| intrawebsite.it | Dominio dismesso, non piu' rinnovato: scaduto il 30/10/2025. Ospitava un vecchio sito WordPress, redirect verso `intrawelt.com`. Il certificato SSL DV associato si autorinnova su Aruba (WordPress hosting gestito) fino al 06/07/2026: da revocare esplicitamente dopo la scadenza del dominio, altrimenti resta attivo su un dominio ormai spirato |
| Architettura redirect legacy | I ~20 domini di nicchia puntavano storicamente a una VM `Ubuntu 1404-DOMV` (landing page dedicata per dominio). Migrazione pianificata: le pagine vengono spostate come sottopagine di `intrawelt.com` (es. `intrawelt.com/domv/<dominio>`), il redirect viene impostato su Aruba, e la VM Ubuntu 1404-DOMV viene infine spenta. Il redirect finale per la maggior parte dei domini passa fisicamente dal firewall ZYXEL USG FLEX 500 |
| DNS panel | `managehosting.aruba.it`; record supportati A, CNAME, TXT, MX, AAAA, DMARC, DKIM, SPF, SRV, CAA |
| Name server storici | dns.technorail.com, dns2.technorail.com, dns3.arubadns.net, dns4.arubadns.cz (Aruba) |

---

## Fastnet SpA – Hosting Plesk, DNS primario, compliance ICANN

| Campo | Valore |
|-------|--------|
| Tipologia | Hosting web (Plesk), gestione DNS del dominio primario, registrar per alcuni domini (es. .de tramite DENIC), liaison compliance ICANN |
| Sede | Via O. Zuccarini 1, Ancona |
| Referenti | Referente-FASTNET-1 (IT Specialist, gestione ordinaria e compliance ICANN), Referente-FASTNET-2 (supporto tecnico certificati SSL) |
| Hosting intrawelt.com | Due ambienti Plesk distinti: "produzione" e "test", entrambi con DNS gestito da Fastnet ma hosting fisico che si appoggia anche ad Aruba secondo l'analisi interna. Sottodominio `scenia.intrawelt.com` sulla stessa infrastruttura Plesk |
| Certificati SSL | Let's Encrypt via Plesk con rinnovo automatico. **Limite tecnico**: il rinnovo automatico del certificato *wildcard* richiede che il DNS del dominio sia gestito direttamente dal pannello Plesk per la verifica via record DNS; quando il DNS e' gestito altrove (come per intrawelt.com, DNS di fatto distribuito), Plesk non completa la verifica wildcard. L'11/05/2026 Fastnet ha dovuto riemettere il certificato di intrawelt.com **senza wildcard** (con rinnovo automatico attivo sul solo dominio principale e sottodomini configurati) dopo ripetuti fallimenti di rinnovo del wildcard |
| Compliance ICANN | Fastnet fa da tramite per la validazione annuale obbligatoria dei contatti di registrazione domini (richiesta ICANN, eseguita tramite EuroDNS/domainvalidation.com): ricorre annualmente (thread di giugno 2025 e maggio 2026), con frizioni operative ricorrenti (link di validazione scaduti, verifica telefonica con codici a 6 cifre su un numero fisso configurato per riceverne solo 4) |
| intrawelt.it | Alias del dominio principale, redirect HTTP 301 gestito da dentro Fastnet |

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

## MyOffice – Reseller Vianova

| Campo | Valore |
|-------|--------|
| Tipologia | Reseller/intermediario Vianova |
| Referente | Alessia Liberati (a.liberati@myofficegroup.it) |
| Servizi | Preventivo, contratto e gestione commerciale Vianova FTTO; centralino cloud |
| Note | MyOffice gestisce la relazione con Vianova. Riunione in sede 17/12/2024 (preventivo). Riunione centralino cloud 09/06/2026. |

---

## INFOCERT – Firma digitale

| Campo | Valore |
|-------|--------|
| Tipologia | CA (Certification Authority) firma digitale |
| Piano | GoSign Pro (certificati firma digitale su dominio INFOCERT) |
| Intestatario | Alessandro Potalivo (a nome azienda) |
| Rinnovo | 22/11/2024 (verifica rinnovo eseguita); rinnovo periodico |
| Portale | mysign.infocert.it (credenziali in Cartella_riservata_IT) |

---

## Cappelli Design – Sito web intrawelt.com

| Campo | Valore |
|-------|--------|
| Tipologia | Agenzia web design |
| Contatto | Anna Caruso (marketing@cappellidesign.com) |
| Progetto | Redesign sito intrawelt.com (aprile 2026) |
| Stato | In corso: primo rilascio esclusi Ricerca, Solution finder, slider, modulo consulenza; secondo rilascio TBD |
| CMS | WordPress (https://intrawelt.com/wp-login.php) – accesso Cappelli Design: utente marketing_cappelli (ruolo Amministratore) |
| Gestore WordPress | Tommaso Vezeni (tvezeni@intrawelt.com) |
