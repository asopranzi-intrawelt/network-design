# GAP-TBC "” Registro completo delle sezioni incomplete

Ogni voce indica: sezione di origine, tipo di informazione mancante, e dove
trovare il materiale per completarla (screenshot, file, mail).

---

## sec-002 "” Introduzione 2024

Nessun TBC esplicito. Sezione completa.

---

## sec-003 "” Routing 2026

Sezione quasi interamente placeholder (puntini di sospensione).

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 1 | I1 | Diagramma routing 2026 "” intervento I1 | Screenshot Visio/diagrama rete |
| 2 | I2 | Intervento I2 descrizione e data | Screenshot o note operative |
| 3 | I3 | Intervento I3 descrizione e data | Screenshot o note operative |

Tutta la sezione va integrata con screenshot del diagramma di rete 2026
(file "[TBC] Diagramma di rete" nella cartella ARCHITETTURA SERVER-CLOUD-LINEE).

---

## sec-004 "” Piano Terra

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 4 | TBC | Configurazione Nebula switch Piano Terra (punti di sospensione) | Screenshot Nebula XGS2220-30HP |
| 5 | TBC | Rimozione DHCP server classe .90 | Screenshot Nebula/firewall dopo configurazione |
| 6 | TBC | VLAN tagging fonia Piano Terra (VLAN 2 per telefoni IP) | Screenshot Nebula configure switch ports |
| 7 | TBC | Wi-Fi su VLAN separata (non classe .10) | Screenshot configurazione AP |

---

## sec-005 "” Piano 1 (Ufficio IT)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
[TBC: verificare sezione 005 per marcatori specifici "” non estratta in dettaglio]

---

## sec-006 "” Piano 2 Rack SX

[TBC: verificare sezione 006 per marcatori specifici "” 974 paragrafi, non estratta completamente]

---

## sec-007 "” Piano 2 Rack DX (Proxmox)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 8 | TBC | Proxmox post-install (pve postinstall) | Screenshot terminale Proxmox dopo installazione |
| 9 | TBC | VM101 configurazione completa | Screenshot Proxmox VM list |
| 10 | TBC | Migrazione VM da ESXi G5 a Proxmox (roadmap) | Screenshot wizard import VMware |
| 11 | TBC | Data precisa installazione fisica Proxmox nel rack DX | Mail/chat Persona-H fine gennaio 2025 |

---

## sec-008 "” Cloud SEEWEB

[TBC: verificare sezione 008 per marcatori specifici "” non estratta completamente]

---

## sec-009 "” Non attivi / dismessi

[TBC: verificare sezione 009 per marcatori specifici]

---

## sec-050 "” Linea dati (studio pre-migrazione)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 12 | TBC | Configurazione VLAN sul firewall Zyxel (errori rilevati) | Screenshot Configuration > Network > Interface > VLAN |
| 13 | TBC | Regole inutilizzate da eliminare | Screenshot Security Policy > Policy Control |
| 14 | TBC | Documentazione regola VPN_auth_LAN2 (disattivata maggio 2025) | Screenshot prima/dopo |
| 15 | TBC | Taurus Bond: dettagli restituzione fisica | Mail TIM + foto materiale restituito |

---

## sec-051 "” Studio Vianova (pre-contratto)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 16 | TBC | Preventivo Vianova dettagliato (costi voce, dati, radio) | File preventivo PDF myOffice |
| 17 | TBC | Confronto costi TIM vs Vianova (prima/dopo) | File TIM.xlsx + fatture Vianova |
| 18 | TBC | Configurazione pool IP pubblici 203.0.113.x/28 | Screenshot configurazione firewall |

---

## sec-052 "” Cronologia passaggio Vianova (TBC completo)

Questa sezione e' esplicitamente marcata [TBC] nel titolo.

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 19 | TBC principale | Cronologia passaggio effettivo a Vianova (tutta la sezione) | Estratta parzialmente "” vedere 2025-q2 |
| 20 | TBC | Verbale sopralluogo Fibercop SF2400847235 (dettaglio) | File PDF verbale |
| 21 | TBC | Screenshot pannello Vianova (ordine di lavoro 14/04/2025) | Screenshot merlino/provisioning |
| 22 | TBC | Foto posatura fibra 20/03/2025 | File _Posatura Fibra 20032025.7z (>25MB) |
| 23 | TBC | Screenshot router R-1000 consegnato 01/04/2025 (screenshot_07, _08) | Cartella screenshot_07/08 del 31/03/2025 |
| 24 | TBC | Screenshot 09 ordine di lavoro 02/04/2025 | Cartella screenshot_09 |
| 25 | TBC | Cartella foto 11042025 (secondo router) | Cartella 11042025 |
| 26 | TBC | Risposta Referente-Vianova-1 ordine di lavoro 21/03/2025 (immagine) | Screenshot allegato mail |

---

## sec-053 "” Migrazione TIM-Vianova (dettaglio tecnico)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 27 | TBC | VPN collaboratori esterni "” configurazione definitiva post-migrazione | Screenshot VPN config Zyxel |
| 28 | TBC | Tutto cio' che passa sul firewall (analisi regole) | Screenshot Policy Control |
| 29 | TBC | Port forwarding (Virtual Server) UDP 500/4500 "” screenshot configurazione | Screenshot NAT > Virtual Server |
| 30 | TBC | Studio guida ufficiale Zyxel Site-to-Site VPN | Screenshot configurazione applicata |
| 31 | TBC | Prove 15/05 â†’ 23/05 debugging tunnel SEEWEB | Screenshot log Zyxel + tracert |
| 32 | TBC | Disdetta TIM: procedura restituzione materiale | Mail TIM + tracking reso |
| 33 | TBC | Test porte 500/4500 da yougetsignal.com | Screenshot test 27/05/2025 |
| 34 | TBC | Persona-K: porta 8008 "” test 26/06/2025 | Screenshot client Zywall |
| 35 | TBC | Risparmio costi netti post-migrazione (calcolo preciso) | File TIM.xlsx + fatture comparative |

---

## Timeline files "” TBC trasversali

Questi TBC sono stati identificati durante la scrittura dei file timeline e non
sono esplicitamente nel documento Word.

| # | File | Evento | Cosa manca |
|---|---|---|---|
| 36 | 2023-baseline.md | SSL VPN rinnovo | Screenshot procedura ZeroSSL completa |
| 37 | 2023-baseline.md | Inventario Punto Informatica | File allegati della mail del 03/07/2024 |
| 38 | 2024-infra.md | Blackout 21/11 NAS INTRA2 | Screenshot log errori NAS INTRA2 |
| 39 | 2025-q1.md | Proxmox in rack: data precisa | Chat WhatsApp Persona-H fine gennaio |
| 40 | 2025-q1.md | BioStar2 migrazione | Dettagli chiamata 13/02/2025 + firmware aggiornato |
| 41 | 2025-q1.md | Cablaggio rack DX foto | Screenshot/foto layout definitivo |
| 42 | 2025-q2.md | Attivazione fisica 17/04 | Screenshot configurazione switch S-1000 + note Referente-MyOffice-1 |
| 43 | 2025-q2.md | Log Zyxel durante switch WAN1 08/05 | Screenshot log firewall |
| 44 | 2025-q2.md | Ticket SEEWEB N.1317639 risposta completa | Screenshot ticket + risposta SEEWEB |
| 45 | 2025-q3-q4.md | Restituzione materiale TIM | Mail TIM + ricevuta di reso |
| 46 | 2025-q3-q4.md | Secondo router R-1000 installazione | Data, tecnico, screenshot Nebula dopo |
| 47 | 2025-q3-q4.md | Migrazione fonia (nuova fonia Vianova) | Sezione dedicata nel documento |
| 48 | 2026.md | Phishing 08/01/2026 | Mail phishing + azioni remediation |
| 49 | 2026.md | NAS INTRA2 guasto TS-451U | Log errore + foto NAS guasto |
| 50 | 2026.md | NAS INTRA2 TS-435XeU-4G installazione | Screenshot QNAP operativo + configurazione |
| 51 | 2026.md | DHCP .90 da rimuovere | Screenshot Nebula post-configurazione |
| 52 | 2026.md | VLAN fonia Piano Terra | Screenshot Nebula switch ports configurazione |
| 53 | 2026.md | Wi-Fi VLAN separata | Screenshot AP + VLAN config |

---

## Firewall USG FLEX 500 (da Analisi_Zyxel_USG_FLEX_500.docx, 29/05/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 54 | FW-001 | Regola Blocco_Gruppo_IP_Phishing_Elisa: action allow invece di deny | **Corretto 01/07/2026** — vedi firewall-zyxel-usg-flex-500-live.conf |
| 55 | FW-002 | Regola malicious_IP_12052025: action allow invece di deny | **Corretto 01/07/2026** — vedi firewall-zyxel-usg-flex-500-live.conf |
| 56 | FW-003 | secure-policy 8/9/10 attive ma virtual server DOMV_WEB/DEMO_SERVER_WEB/EGETRAD_WEB deactivate | Verificare intento con Alessio |
| 57 | FW-004 | Rotte statiche dipendono da router 10.61.100.1 non monitorato - da rimuovere con dismissione LAN2 | Backup config + revisione 05/06/2026 |
| 58 | FW-005 | Alias wan1 (.2/.3/.4/.254) in shutdown: verificare quali servono ancora | Backup startup-config.conf |
| 59 | FW-006 | VPN PSE-SEEWEB usa IKEv1/AES-128/SHA-1/DH2: parametri sotto best practice | Piano aggiornamento |
| 60 | FW-007 | Due profili IPsec verso <IP-SEEWEB-PEER> (PSE-SEEWEB e WIZ_VPN): transizione in corso o residuo? | Verificare con Alessio |
| 61 | FW-010 | File draw.io analisi firewall: localizzare e archiviare | **Fatto 01/07/2026** — archiviati in `.claude/context/diagrams/firewall-dmz-2026/`, registro in firewall-zyxel-usg-flex-500.md |
| 62 | FW-009 | DMZ VLAN 201 + bridge Proxmox VLAN-aware: intervento pianificato, non ancora eseguito | Piano_Operativo_Migrazione.docx 05/06/2026 — **confermato ancora non applicato al 01/07/2026** |
| 63 | FW-010bis | Meeting myOffice 09/06/2026 centralino cloud: steps documentati (provisioning utente Area Clienti, Vianova One, riconfigurazione porte switch) | **Fatto 01/07/2026** — cartella steps ingestionata, dettaglio in telefono-pbx-voip.md e 2026-switch-piano-terra.md |
| 97 | FW-011 | Piano di revisione a sei fasi (05/06/2026) non ancora applicato al firewall fisico: FW-001/002/004/008/009 restano aperte in produzione | Confermato con l'utente 01/07/2026 |
| 98 | FW-012 | Porta 8 switch 54HP (MAC AA:BB:CC:00:00:01) rinominata "Vianova DHCP server fonia", PVID 2 dal 09/06/2026: funzione effettiva da verificare, possibile collegamento con rimozione DHCP classe .90 | Screenshot 08062026 (steps) |
| 99 | NET-007 | Probabile errore di etichettatura: screenshot 09/06/2026 mostrano la porta 3 dello switch a 54 porte (Piano 2) rinominata "SIP-T34W Persona-A", ma interventi 29052026.docx (29/05/2026) colloca esplicitamente Persona-A (T34W) su Piano Terra porte 21/23 e riserva le porte 3/5/44 del Piano 2 ai T31G (Persona-D, Sala-1) | Screenshot 08062026 (steps) vs interventi 29052026.docx |
| 100 | TEL-001 | Testo messaggi IVR centrale telefonica cloud (giorno: attesa semplice o instradamento reparti; notte: orari apertura) — risposta di Alessio a myOffice non ancora inviata | Messagistica centrale telefonica.eml 09/06/2026 |
| 101 | NEB-001 | Switch Nebula (XGS2220-54HP e XGS2220-30HP) segnalati offline in modo intermittente sul pannello Nebula pur con rete dati funzionante — sintomo di canale di gestione (heartbeat cloud), non di switching reale. Ipotesi principale: FW-008 (WAN_TRUNK con wan2 ancora primario, linea morta da maggio 2025) causa fallimento periodico di sessioni a vita lunga verso il cloud Zyxel prima del failover su wan1. Ipotesi alternativa: interferenza SSL inspection sul traffico TLS del client Nebula. Nessun log a supporto ancora raccolto | Segnalato dall'utente 01/07/2026, foto app Nebula |

---

## Voice VLAN e telefonia (da interventi 29052026.docx)

| # | Descrizione | Fonte |
|---|-------------|-------|
| 64 | DSCP Voice VLAN: default Nebula mostra 44, standard e' 46 (EF) - verificare se e' stato modificato | Nebula > Configure > Switch settings > Voice VLAN |
| 65 | 28 porte Piano Terra configurate come Access via selezione multipla: verificare che il salvataggio sia avvenuto | Nebula XGS2220-30HP switch ports |
| 66 | NAS INTRA2 (10.61.20.177): configurazione definitiva dopo migrazione a fibra 10GbE (IP, adapter attivo, job backup) | QNAP QTS interfaccia + Qfinder |
| 67 | IP e MAC telefoni Yealink T31G/T34W: mappatura completa porta switch - telefono - utente | Nebula switch ports + QTS |

---

## Sezioni non estratte (da analizzare in futuro)

| Sezione | Priorita' | Note |
|---------|-----------|------|
| Studio dettagliato Firewall e networking (ARCHITETTURA) | ALTA | Analisi regole VLAN, policy control - ora coperto parzialmente da Analisi_Zyxel |
| Migrare hosting da Ubuntu-1404-DOMV | MEDIA | Fastnet, completato 02/02/2025 |
| Implementazione nuova fonia per Intrawelt | ALTA | Centralino cloud Vianova - ora parzialmente coperto da telefono-pbx-voip.md |
| Risparmio costi netti (analisi fatture) | MEDIA | TIM.xlsx, confronto prima/dopo |
| HP G5 (VMware ESXi fisico) | MEDIA | Da dismettere, import VM in Proxmox |
| Mappatura porte fisiche (file separato) | ALTA | Non ancora ingestato |

---

## Network Security – Gaps da Piano Attività (task_47)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 68 | NET-001 | VLAN 10/20/90 non isolate a livello firewall: un host su .90 può vedere hosts su .10 se usa IP fisso compatibile | task_47 – Piano Attività IT v3.xlsx |
| 69 | NET-002 | VPN IKEv2 (10.61.50.0/27) vede rete LAN .10 locale senza ACL tra loro | task_47 |
| 70 | NET-003 | Ethernet non segmentata: host esterno può usare IP fisso su qualsiasi classe | task_47 |
| 71 | NET-004 | Due server DHCP sospetti (Proxmox: ha ricevuto .10.239 e .90.103 su due porte dello stesso switch) | task_37 |
| 72 | NET-005 | WiFi "intrawelt" non su VLAN dedicata: dovrebbe essere .10 ma non c'è isolamento reale da .90 | task_47 |
| 73 | NET-006 | Configurazione WRR/WAN_TRUNK residua TIM ancora presente sul firewall | docs/network-diagram.md |

---

## Cybersecurity – Gaps da Piano Attività e ingestion documenti

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 74 | SEC-001 | Bitdefender non installato su WINGROUPSHARE (10.77.116.3), WINSRV2019 (10.77.116.4), WIN-V712I9QHQT9 (10.61.20.13) | task_31/32 – Piano Attività |
| 75 | SEC-002 | Password policy: solo 25% completata – NAS randomizzate, mancano altri sistemi | task_33 – Piano Attività |
| 76 | SEC-003 | AnyDesk e TeamViewer presenti su macchine aziendali (accesso remoto non presidiato) | task_14 – Piano Attività |
| 77 | SEC-004 | VM Egetrad (Ubuntu obsoleto, 10.61.20.5) ancora attiva; regole firewall EGETRAD_WEB da disabilitare | task_27 – Piano Attività + docs/it-backlog.md |
| 78 | SEC-005 | MFA non attivo su account non-admin M365 (enforcement solo Azure admin) | task_65 + MFA action plan |
| 79 | SEC-006 | Privacy policy NinjaOne non distribuita a tutti gli utenti | task_20 |
| 80 | SEC-007 | Dischi USB non bloccati sulle postazioni (task pending) | task_25 |
| 81 | SEC-008 | OneDrive personale non bloccato (policy mancante) | task_24 |
| 96 | SEC-009 | IntraPanel (React/Flask per ENI Servizi) installata su PC-GIORDANO (ex-dipendente); app non migrata né presidiata | docs/helpdesk-operations.md – ENIVIPA |

---

## SCENIA – Gaps sicurezza tecnica (da DPA Allegato II, giugno 2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 82 | SCENIA-001 | SAST/DAST assenti nel CI/CD pipeline AIDAPT (confermato) | DPA_ScenIA_Intrawelt_v1.0_bozza.md Allegato II §7 |
| 83 | SCENIA-002 | VA/Penetration test mai eseguiti su infrastruttura SCENIA (confermato) | DPA Allegato II §9 |
| 84 | SCENIA-003 | Qdrant audit log non configurato (default docker, solo api key) – ETA da AIDAPT | DPA Allegato II §4 |
| 85 | SCENIA-004 | API rate limiting non implementato – ETA incerta | DPA Allegato II §5 |
| 86 | SCENIA-005 | PII filter (mascheramento automatico dati personali nei segmenti) – solo PLANNED | DPA Allegato II §1 |
| 87 | SCENIA-006 | Test di ripristino backup non documentati nel DRP AIDAPT (rev 27/02/2026) | DPA Allegato II §6 |
| 88 | SCENIA-007 | DPA bozza v1.7: placeholder Parti e massimali responsabilità da completare prima della firma | CLAUDE.md SCENIA/SECURITY/DPA |
| 89 | SCENIA-008 | DPIA ScenIA: sezioni [DA COMPLETARE] ancora aperte (validazione tecnica AIDAPT, dati Titolare) | edpb_dpia_template_2026_v1_en_scenia.docx |

---

## ISO 27001 – Gaps identificati da Consulente-ISO27001-1 (18/04/2025)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 90 | ISO-001 | Disciplinare lavoratori: documento **esiste** (`Regolamento_rev1.docx`, 9 sezioni: postazione lavoro, password, antivirus, salvataggio dati, PC portatili, internet/email, trasmissione doc, videosorveglianza, sanzioni). Gap residuo = distribuzione formale + firme nel `Registro_accettazione.docx` (ancora vuoto) | Cybersec & IT Governance/Regolamento utilizzo sistemi informatici/ |
| 91 | ISO-002 | Badge accesso sala server non implementato | riunione_consulente-iso27001-1_18042025.txt |
| 92 | ISO-003 | Formazione strutturata anti-phishing non erogata ai dipendenti | riunione_consulente-iso27001-1_18042025.txt |
| 93 | ISO-004 | Politica BYOD (dispositivi personali) non formalizzata | riunione_consulente-iso27001-1_18042025.txt |
| 94 | ISO-005 | Politica chiavette USB non formalizzata e non tecnicamente applicata | riunione_consulente-iso27001-1_18042025.txt + task_25 |
| 95 | ISO-006 | Incident response process non formalizzato (nessun playbook) | docs/cybersecurity-governance.md |

---

## Riepilogo conteggio

| Categoria | TBC # |
|-----------|--------|
| sec-003 (routing) | 1-3 |
| sec-004 (piano terra) | 4-7 |
| sec-007 (proxmox) | 8-11 |
| sec-050 (linea dati) | 12-15 |
| sec-051 (studio Vianova) | 16-18 |
| sec-052 (cronologia Vianova) | 19-26 |
| sec-053 (migrazione TIM) | 27-35 |
| Timeline trasversali | 36-53 |
| Firewall USG FLEX 500 | 54-63 |
| Voice VLAN e telefonia | 64-67 |
| Network Security (task_47) | 68-73 |
| Cybersecurity (piano attività) | 74-81, 96 |
| SCENIA gaps (DPA Allegato II) | 82-89 |
| ISO 27001 (Consulente-ISO27001-1 18/04/2025) | 90-95 |
| Firewall/rete — ingestione [TBC] Diagramma di rete (01/07/2026) | 97-99 |
| Telefonia — ingestione [TBC] Diagramma di rete (01/07/2026) | 100 |
| Nebula switch offline intermittente (01/07/2026) | 101 |
| **Totale identificati** | **101** |
| **Di cui risolti** | **4** (54, 55, 61, 63 — vedi stato "Corretto"/"Fatto") |