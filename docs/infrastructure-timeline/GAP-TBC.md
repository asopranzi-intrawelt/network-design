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

## sec-005 "” Piano 1 (Ufficio IT) — VERIFICATA IL 10/07/2026

Nessun marcatore [TBC] esplicito nella sezione (103 paragrafi, 0 immagini).
Contenuto: NAS INTRA3 (QNAP TS-210), specifiche hardware/software complete,
storico eventi (dismesso di fatto dal 2022, accesso e formattazione
21/02/2025 gia' documentato, riconnessione e analisi dischi 27/06/2025 non
ancora documentato — aggiunto in `2025-q1-server-vianova.md`). Sezione ora
completamente coperta.

---

## sec-006 "” Piano 2 Rack SX — VERIFICATA IL 10/07/2026

974 paragrafi, 17 [TBC] espliciti nella sezione. La maggior parte del
contenuto (walkthrough menu Zyxel USG FLEX 500, VPN, certificati SSL,
switch, centralino Panasonic) era gia' coperta da `firewall-zyxel-usg-flex-500.md`,
`2023-baseline.md`, `2024-infra.md` e `telephony-pbx.md`. Novita' emerse:
data precisa disattivazione VPN_auth_LAN2 (15/05/2025, gap #14 risolto),
valutazione Supremo come alternativa controllata ad AnyDesk/TeamViewer
(contesto aggiunto a SEC-003), consegna hardware Vianova telefonia
(UPS-700 + Patton SmartNode, DDT 29/03/2024, in `2023-baseline.md`).
Emersa anche una discrepanza sul modello del centralino Panasonic
(KX-NCP1000 qui vs KX-TDA100 in `telephony-pbx.md`, quest'ultima ora
segnalata come probabile errore) e sulla data di inizio servizio
telefonico Vianova (aprile 2024 confermato da due fonti indipendenti vs
aprile 2025 in telephony-pbx.md).

---

## sec-007 "” Piano 2 Rack DX (Proxmox)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 8 | TBC | Proxmox post-install (pve postinstall) | Screenshot terminale Proxmox dopo installazione |
| 9 | TBC | VM101 configurazione completa | Screenshot Proxmox VM list |
| 10 | TBC | Migrazione VM da ESXi G5 a Proxmox (roadmap) | Screenshot wizard import VMware |
| 11 | TBC | Data precisa installazione fisica Proxmox nel rack DX | Mail/chat Persona-H fine gennaio 2025 |

---

## sec-008 "” Cloud SEEWEB — VERIFICATA IL 10/07/2026

162 paragrafi, 0 immagini, 2 [TBC] espliciti nella sezione (entrambi su
WINSRV2019, gia' presenti nella scheda SEC-001 esistente: nessun contenuto
aggiuntivo scoperto oltre al disco di rete non identificato, vedi
#112/SRV-004 piu' sotto). Il resto della sezione (accesso firewall cloud,
Foundation Server Pro, WINGROUPSHARE/WINSRV2019, procedura GroupShare,
ticket SEEWEB 1317639) e' ora integrato in vendor-management.md §Seeweb e
helpdesk-operations.md §GroupShare.

---

## sec-009 — Non attivi / dismessi

VERIFICATA IL 10/07/2026. Re-estrazione completa (1543 paragrafi): guasto
lettore BioStar2 e migrazione su HP Gen10/Windows Server 2022, host
legacy HP G6 (predecessore di G5, VM eGetrad/SVN/TestWeb/DOMV/posta/
antivirus consolidate su G5 prima di fine 2024), predecessore Seeweb del
GroupShare attuale (Cloud Server 280SPU poi 2000SPU per GroupShare 2017),
NAS FTP e NAS documenti HPX1400 (dismissione e valutazione riuso
OpenMediaVault, non decisa nella fonte), rimozione fisica dello switch
GS1900-24 (08/05/2026, tenuto come backup). USG20/USG60 in coda alla
sezione privi di contenuto testuale utile (solo screenshot). La maggior
parte del contenuto era gia' coperta da file esistenti; novita' aggiunte
a 2025-q1-server-vianova.md, 2023-baseline.md, vendor-management.md.

---

## sec-050 "” Linea dati (studio pre-migrazione)

| # | Marcatore | Cosa manca | Fonte probabile |
|---|---|---|---|
| 12 | TBC | Configurazione VLAN sul firewall Zyxel (errori rilevati) | Screenshot Configuration > Network > Interface > VLAN |
| 13 | TBC | Regole inutilizzate da eliminare | Screenshot Security Policy > Policy Control |
| 14 | TBC | **Risolto 10/07/2026**: VPN_auth_LAN2 disattivata il 15/05/2025 (WAN2 non piu' usata con sola connettivita' Vianova); puntava a 10.61.100.2 su wan2. Dettaglio in `firewall-zyxel-usg-flex-500.md` §NAT e virtual server | ARCHITETTURA.docx sec-006 |
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
| 40 | 2025-q1.md | BioStar2 migrazione | **Risolto 10/07/2026**: dettaglio completo aggiunto in `2025-q1-server-vianova.md` (diagnosi VLAN, sostituzione hardware 25/02/2025, migrazione server) |
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
| 56 | FW-003 | secure-policy 8/9/10 attive ma virtual server DOMV_WEB/DEMO_SERVER_WEB/EGETRAD_WEB deactivate | **Risolto 16/07/2026**: le tre secure-policy rimosse (insieme ad altre sei nella stessa pulizia, vedi firewall-zyxel-usg-flex-500.md §NAT e virtual server), verificate dall'utente e applicate sul dispositivo durante M13a |
| 57 | FW-004 | Rotte statiche dipendono da router 10.61.100.1 non monitorato - da rimuovere con dismissione LAN2 | Backup config + revisione 05/06/2026 |
| 58 | FW-005 | Alias wan1 (.2/.3/.4/.254) in shutdown: verificare quali servono ancora | Backup startup-config.conf |
| 59 | FW-006 | VPN PSE-SEEWEB usa IKEv1/AES-128/SHA-1/DH2: parametri sotto best practice | Piano aggiornamento |
| 60 | FW-007 | Due profili IPsec verso <IP-SEEWEB-PEER> (PSE-SEEWEB e WIZ_VPN): transizione in corso o residuo? | Verificare con Alessio |
| 61 | FW-010 | File draw.io analisi firewall: localizzare e archiviare | **Fatto 01/07/2026** — archiviati in `.claude/context/diagrams/firewall-dmz-2026/`, registro in firewall-zyxel-usg-flex-500.md |
| 62 | FW-009 | DMZ VLAN 201 + bridge Proxmox VLAN-aware: intervento pianificato, non ancora eseguito | Piano_Operativo_Migrazione.docx 05/06/2026 — **confermato ancora non applicato al 01/07/2026** |
| 63 | FW-010bis | Meeting myOffice 09/06/2026 centralino cloud: steps documentati (provisioning utente Area Clienti, Vianova One, riconfigurazione porte switch) | **Fatto 01/07/2026** — cartella steps ingestionata, dettaglio in telefono-pbx-voip.md e 2026-switch-piano-terra.md |
| 97 | FW-011 | Piano di revisione a sei fasi (05/06/2026) non ancora applicato al firewall fisico: FW-001/002/004/008/009 restano aperte in produzione | Confermato con l'utente 01/07/2026 |
| 98 | FW-012 | Porta 8 switch 54HP (MAC AA:BB:CC:00:00:01) rinominata "Vianova DHCP server fonia", PVID 2 dal 09/06/2026 | **Funzione confermata dall'utente 07/07/2026**: DHCP server + gateway della LAN telefonica forniti da Vianova, connessi untagged alla porta 8, deliberatamente NON passanti per il firewall; Vianova raggiunge la porta 8 via VPN verso myOffice. Resta aperto se sostituisce il DHCP classe .90 (M11/M12) |
| 99 | NET-007 | Probabile errore di etichettatura: screenshot 09/06/2026 mostrano la porta 3 dello switch a 54 porte (Piano 2) rinominata "SIP-T34W Persona-A", ma interventi 29052026.docx (29/05/2026) colloca esplicitamente Persona-A (T34W) su Piano Terra porte 21/23 e riserva le porte 3/5/44 del Piano 2 ai T31G (Persona-D, Sala-1) | Screenshot 08062026 (steps) vs interventi 29052026.docx |
| 100 | TEL-001 | Testo messaggi IVR centrale telefonica cloud (giorno: attesa semplice o instradamento reparti; notte: orari apertura) — risposta di Alessio a myOffice non ancora inviata | Messagistica centrale telefonica.eml 09/06/2026 |
| 101 | NEB-001 | Switch Nebula (XGS2220-54HP e XGS2220-30HP) segnalati offline in modo intermittente sul pannello Nebula pur con rete dati funzionante — sintomo di canale di gestione (heartbeat cloud), non di switching reale. Ipotesi principale: FW-008 (WAN_TRUNK con wan2 ancora primario, linea morta da maggio 2025) causa fallimento periodico di sessioni a vita lunga verso il cloud Zyxel prima del failover su wan1. Ipotesi alternativa: interferenza SSL inspection sul traffico TLS del client Nebula. **Evidenza aggiuntiva 16/07/2026** (durante i tentativi M13a): una porta scritta correttamente via API (portVid confermato dopo scrittura) e' tornata da sola al valore precedente dopo qualche minuto senza alcuna azione esterna, e uno spegnimento PoE via API (`pseEnabled: false` confermato dalla rilettura) non ha tolto corrente reale all'AP collegato (confermato: il dispositivo restava raggiungibile). Rafforza l'ipotesi di una sincronizzazione cloud<->switch inaffidabile, non solo un problema di heartbeat/dashboard: le scritture stesse possono non restare stabili o non essere applicate fisicamente come atteso. Nessun log a supporto ancora raccolto. **Nuova occorrenza il 27/07/2026**: durante la raccolta dello snapshot per il censimento di M22a, l'endpoint `l2-mac-table` del solo XGS2220-54HP ha risposto `422 DEVICE_IS_OFFLINE`, mentre tutte le letture sul XGS2220-30HP sono andate a buon fine (tabella MAC completa, 58 voci). Il 54HP resta quindi assente dal piano di gestione a quattro giorni dall'episodio del 23/07, quando era andato offline per un PVID non valido sul trunk ed era rientrato da solo: da chiarire se sia una ricaduta dello stesso evento, una nuova occorrenza di NEB-001 o un'anomalia distinta, e da verificare in parallelo che il piano dati sia integro (gli endpoint del Piano 2 e il traffico attraverso il trunk risultano funzionanti dalla tabella MAC del 30HP, che mostra MAC del Piano 2 appresi via porta 29). Effetto pratico sul progetto: il censimento di M22a e' completo per il Piano Terra e mancante per il Piano 2 | Segnalato dall'utente 01/07/2026, foto app Nebula; esteso 16/07/2026 durante M13a; nuova occorrenza 27/07/2026 da `Get-NebulaSnapshot.ps1` |
| 115 | NET-010 | Porta 46 dello switch XGS2220-54HP in *link flap* continuo (su/giu' ogni 14-16 secondi, migliaia di eventi nelle sole ultime 24h secondo `event-logs`), ciascun flap genera anche un ricalcolo STP. **Identificato il 16/07/2026**: e' il PC che ospita Ollama (10.61.20.58, GPU dedicata, sistema operativo Linux — lo stesso host ambiguo di SRV-002/#107), confermato raggiungibile via HTTP sulla porta 11500 nonostante il flap continuo del link. Causa del flap non ancora diagnosticata (ipotesi: Energy Efficient Ethernet/risparmio energetico della scheda di rete gestibile via `ethtool`, ASPM PCIe, driver, cavo) — da verificare direttamente sull'host con `ethtool --show-eee <interfaccia>` e i contatori errori dell'interfaccia. Correlazione plausibile con NEB-001 e con l'inaffidabilita' delle scritture osservata sulle porte 41/45 dello stesso switch durante M13a (il 30HP, senza questa anomalia, si e' comportato in modo pulito sulle stesse operazioni) — da diagnosticare (impostazioni di risparmio energetico della scheda di rete, cavo) prima di fidarsi di nuove scritture su questo switch | `Get-NebulaConnectivityHistory.ps1`, 16/07/2026; identificazione dall'utente |
| 102 | NET-008 | Durante il tagging VLAN del 07/07/2026 (migrazione centralino cloud): la VLAN ID 1 non puo' essere impostata a Tx tagging sulla dorsale tra i due switch XGS2220, altrimenti gli endpoint Windows collegati allo switch perdono la connettivita' verso il NAS-HERO (10.61.20.169) senza che il file hosts di alcun endpoint sia cambiato. Causa non compresa dall'utente. Ipotesi da verificare: la VLAN 1 e' la native/untagged della dorsale, taggarla in uscita produce frame 802.1Q che il lato ricevente tratta come VLAN diversa (native VLAN mismatch), separando a L2 gli endpoint dal NAS; il file hosts e' irrilevante perche' il problema e' di inoltro, non di risoluzione nomi. **Aggiornamento 17/07/2026**: confermato dall'utente che la dorsale Piano Terra <-> Piano 2 e' oggi un trunk diretto tra i due switch XGS2220; il QNAP non e' un hop intermedio sulla dorsale, il che rende meno probabile (ma non esclude, causa non isolata) che fosse lui il responsabile del native VLAN mismatch ipotizzato. **Correzione 23/07/2026**: l'assegnazione delle due fibre SFP+ del 54HP era invertita nella documentazione. La verifica diretta in Nebula sulla vista di dettaglio delle porte, con il vicino LLDP dichiarato ("Switch piano terra"), stabilisce che la **porta 51 del 54HP e' il trunk verso il 30HP** (Trunk, PVID 1, Allowed VLANs `All`) e la **porta 52 e' il ramo verso il QNAP**, non il contrario. Il trunk lato Piano Terra e' la porta 29 del 30HP | Segnalato dall'utente 07/07/2026; evidenze in `_notes/[TBC] screenshot e note myoffice/` (16 screenshot, 2 foto, note.txt, non versionati); topologia corretta confermata 17/07/2026, screenshot pannello porte Nebula 54HP |
| 103 | TEL-002 | I telefoni "di sotto" collegati attraverso il vano ascensore non passano le VLAN (la VLAN voce non arriva/attraversa quel tratto), causa non compresa. [TBC: interpretazione del tratto interessato — segmento di cablaggio che attraversa il vano ascensore verso il piano inferiore; chiarire con l'utente topologia esatta, eventuale switch/repeater intermedio non 802.1Q-aware in quel percorso] | Segnalato dall'utente 07/07/2026, verbale; dettagli attesi a fine lavori (nota PORT-TAGGING) |
| 116 | TEL-002 (aggiornamento) | Confermato il 17/07/2026: i due telefoni IP interessati sono collegati a porte dello switch XGS2220-30HP (Piano Terra) stesso, non tramite un tratto separato riconducibile solo al vano ascensore. Anche dopo la conferma che la dorsale e' oggi un trunk diretto verso il 54HP (vedi NET-008 sopra), i due telefoni restano non visibili/raggiungibili: non ancora chiarito se il sintomo precede o segue l'attivazione del trunk diretto. Aperto anche il ruolo della porta 6 del 54HP, che condivide il PVID 2 con la porta 8 (Vianova DHCP fonia, FW-012) ma il cui scopo non e' confermato: il pannello d'insieme di Nebula non espone il PVID per porta, serve la vista di dettaglio della singola porta. **Aggiornamento 23/07/2026 — parte di rete RISOLTA**: la causa era doppia e tutta lato switch. Il trunk del 30HP (porta 29) aveva `Allowed VLANs` = `1, 40, 90`, senza la VLAN 2, quindi la fonia veniva scartata all'ingresso del Piano Terra pur essendo presente sul trunk lato 54HP (porta 51, `All`); e le due porte dei telefoni (13 e 23 del 30HP) erano Access PVID 1, cioe' sulla VLAN dati. Corretti entrambi (porta 29 -> `1,2,40,90`; porte 13 e 23 -> Access PVID 2, come la porta 3 del 54HP che funziona), la tabella MAC del 30HP mostra i due telefoni su VLAN 2 alle rispettive porte e il MAC VRRP del gateway Vianova raggiungibile su VLAN 2 via porta 29. Resta aperto il solo livello DHCP: i due apparecchi non ottengono lease (probabile provisioning per MAC mai eseguito lato Vianova/myOffice, ipotesi alternativa DHCP snooping non trusted sul trunk), attesa esterna al fornitore. Chiusa anche la domanda sulla porta 6 del 54HP: e' un dispositivo voce Grandstream di Vianova, coerentemente su PVID 2. **Switch scagionato con verifica diretta lo stesso 23/07** (`Configure > 30HP > impostazioni switch`): DHCP Server Guard disattivato, IP source guard disattivato, feature globale Voice VLAN disattivata — quindi lo switch non scarta le offerte DHCP e l'ipotesi snooping e' smentita, il residuo e' interamente lato fornitore. Uniformato di conseguenza il campo VLAN type delle due porte telefono del 30HP: entrambe ora `None` (la porta 23 era stata messa su Voice VLAN e vi e' stata riportata, coerente con la feature globale disattivata e con i telefoni funzionanti del Piano 2, che sono semplici Access PVID 2). **Verifica 27/07/2026** su snapshot Nebula nuovo: i due telefoni risultano ancora correttamente appresi sulla VLAN 2 alle porte 13 e 23, a 1 Gbps | Segnalato dall'utente 17/07/2026; screenshot pannello porte Nebula 54HP (porta 33 uplink, porte 3/5/44 PoE, porte 51/52 10 Gbps); verifica di dettaglio porte e tabella MAC 23/07/2026 |
| 104 | SEC-010 | Password e regola di derivazione degli archivi storici cifrati (container VeraCrypt per anno + archivi .z 2009-2022) salvate in chiaro in file di testo sullo stesso filesystem aziendale: la cifratura at-rest e' azzerata nel threat model interno. Nessun custodian designato, nessuna policy crittografica (ISO A.8.24), parametri container non documentati, nessuna verifica periodica (GDPR 32.1.d). Azioni P0/P1/P2 proposte dall'audit | AUDIT_INVENTORY.md (Criptare dati a riposo, 07/2026) → cybersecurity-governance.md §Crittografia dati a riposo |
| 105 | SEC-011 | Credenziali amministrative in chiaro nei documenti operativi su OneDrive: `Helpdesk_ABBYY/ABBYY.docx` (password Administrator del license server ripetuta tre volte, password della VM Windows citata come VM101, credenziali complete dell'utente guest della condivisione `abbyy_15`, senza scadenza e note a tutti i dipendenti); `Backup postazioni di lavoro con Veeam_DRAFT.pdf` (password dell'utenza NAS dedicata ai backup e dell'account Veeam personale); transcript restore Odoo 28/05/2025 (master password del database manager e password di reset di tutti gli utenti di test). Stessa radice di SEC-007/SEC-010: segreti operativi nel filesystem condiviso invece che in un vault. Le credenziali non sono mai riportate nei file tracciati | ABBYY.docx, Veeam_DRAFT.pdf, Odoo_12/28052025 (censiti 07-08/07/2026) |
| 106 | SRV-001 | Incoerenze da verificare nel sorgente ABBYY: il nuovo server e' citato con due hostname diversi (refuso probabile in una delle due forme; hostname reali nella mappa privata) e compare una "VM101 (node pve, Windows)" con password propria che non esiste nell'inventario snapshot v3 (il Windows Server 2022 e' VM100). AGGIORNAMENTO 08/07/2026: la VM101 e' esistita davvero (`qemu-101.log` del 12/02/2025). **RICONCILIATO con snapshot v4 (08/07/2026)**: popolazione attuale 8 VM (100, 202-206, 602 "Intralino", 810 "TESTNEWEGETRADBOOT"); VM101, 201, 601, 801-803, 809, 900-902 e 803 non esistono piu' (VM effimere/di test rimosse; la 810 sostituisce la 809). Resta solo la curiosita' storica sul ruolo della VM101 (probabile Windows intermedia della migrazione ABBYY 2025) | ABBYY.docx + PROXMOX/16022026 + snapshot v4 |
| 107 | SRV-002 | Host IntraLino: la documentazione benchmark descrive 10.61.20.58 (Ollama) e 10.61.20.60 (stack Docker) come "due VM Proxmox", ma attribuisce alla .58 hardware fisico dedicato (i7-7700, scheda madre, PSU, GPU RTX 5060 Ti installata fisicamente l'08/06/2026). AGGIORNAMENTO 08/07/2026 (snapshot v4): nessuna VM su pve corrisponde a quegli IP — confermato che .58 e .60 NON sono VM Proxmox del nodo pve, sono host separati. Su Proxmox esiste pero' la VM602 rinominata "Intralino" (pool Programmazione, 200G): chiarire il rapporto tra la VM602 e i due host, e la natura esatta della .60. Atteso il contesto della documentazione Claude IntraLino sulla VM. **AGGIORNAMENTO 16/07/2026**: confermata la natura di host fisico — collegato alla porta 46 dello switch XGS2220-54HP (identificato durante l'indagine NET-010 sul link flap di quella porta), raggiungibile via HTTP su porta 11500 ("Ollama is running"). Il link flap continuo su quella porta non ha impedito la raggiungibilita' HTTP nei momenti di test, ma resta un'anomalia da risolvere sull'host stesso (vedi NET-010) | Benchmark IntraLino vs snapshot v4; porta fisica confermata 16/07/2026 |
| 108 | SRV-003 | Lo stato cluster dello snapshot v4 riporta come IP del nodo pve 10.61.1.71, che coincide con l'indirizzo documentato della iLO5 del server HP Gen10, mentre vmbr0 (management PVE) e' 10.61.20.11/19. Nessuna interfaccia del nodo mostra un indirizzo sulla classe .1 nella tabella di rete. Chiarire quale interfaccia risponde su quell'IP e perche' il cluster la usa come indirizzo del nodo | output/proxmox-config.md (snapshot v4, 08/07/2026) |

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
| HP G5 (VMware ESXi fisico) | MEDIA | **Inventario dettagliato aggiunto 10/07/2026** in `2023-baseline.md` (8 VM, analisi dicembre 2024 di Alessio Sopranzi). Da dismettere, import VM in Proxmox ancora da eseguire |
| Mappatura porte fisiche (file separato) | ALTA | Non ancora ingestato |

---

## Network Security – Gaps da Piano Attività (task_47)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 68 | NET-001 | VLAN 10/20/90 non isolate a livello firewall: un host su .90 può vedere hosts su .10 se usa IP fisso compatibile | task_47 – Piano Attività IT v3.xlsx |
| 69 | NET-002 | VPN IKEv2 (10.61.50.0/27) vede rete LAN .10 locale senza ACL tra loro | task_47 |
| 70 | NET-003 | Ethernet non segmentata: host esterno può usare IP fisso su qualsiasi classe | task_47 |
| 71 | NET-004 | Due server DHCP sospetti (Proxmox: ha ricevuto .10.239 e .90.103 su due porte dello stesso switch) | task_37 |
| 72 | NET-005 | WiFi "intrawelt" non su VLAN dedicata: dovrebbe essere .10 ma non c'è isolamento reale da .90. Nota 13/07/2026: la VLAN 90 "Guest" gia' presente sul firewall non e' oggi una vera rete ospiti Wi-Fi, ma una raccolta di dispositivi IoT/management finiti li' per errore (switch mgmt, UPS, domotica) — l'intervento pianificato (roadmap M13) deve sia isolare davvero la Wi-Fi "intrawelt" sia predisporre una rete Guest dedicata ai visitatori. **Confermato live il 14/07/2026**: un PC esterno non censito in NinjaOne, connesso alla Wi-Fi "intrawelt", ha ottenuto in DHCP un indirizzo nella stessa /19 della VLAN 10 management (10.61.10.247, gateway 10.61.10.1) — procedura di verifica/fix in `docs/runbook-anomalie.md` §NET-005. **AP-001 localizzato il 14-15/07/2026**: i quattro AP fisici (tre Ubiquiti + l'AP irrigazione) localizzati per porta switch via `Get-NebulaSnapshot.ps1` e nome LLDP (PianoTerra/PianoPrimo/PianoSecondo/EsternoIrrigazione), dettaglio in `runbook-anomalie.md` §AP-001. Credenziali non recuperabili senza reset di fabbrica (disruptivo, rimandato). **Decisione architetturale 15/07/2026**: isolamento risolto a livello switch/firewall (Fase A, nessun accesso agli AP richiesto — VLAN dedicata sulle 3 porte note + ACL firewall verso VLAN 10), sostituzione hardware pianificata come Fase B (AP Zyxel Nebula multi-SSID, non affiancamento di un AP guest isolato ai tre EOL). **Tentato il 16/07/2026, ripristinato lo stesso giorno**: VLAN 40 applicata su switch (tre porte AP) e firewall (interfaccia+DHCP+zona+security policy, verificata via rilettura API), ma i tre AP hanno smesso di trasmettere l'SSID una volta ritaggata la porta — confermato con due dispositivi client diversi, nessuna rete visibile. Causa non determinata (AP inaccessibili). Ripristinato a VLAN 1, servizio Wi-Fi confermato tornato. Configurazione firewall resta applicata e valida per un nuovo tentativo; resta APERTO in attesa di un approccio diverso (test con presenza fisica, o isolamento senza toccare il PVID della porta AP) | task_47 |
| 73 | NET-006 | Configurazione WRR/WAN_TRUNK residua TIM ancora presente sul firewall | docs/network-diagram.md |
| 114 | NET-009 | La LAN principale (`lan1` + i due alias `lan1:1` server, `lan1:2` stampanti) e' in realta' un'unica rete `/19` flat: verificato che 10.61.10.0, 10.61.20.0 e 10.61.30.0 cadono tutti nello stesso blocco `/19` (10.61.0.0-10.61.31.255), quindi PC fisici (.10), server fisici/VM Proxmox (.20) e stampanti (.30) condividono lo stesso dominio di broadcast e la stessa VLAN (nessun tag 802.1Q, PVID 1 su `lan1`) — la suddivisione per ottetto e' solo una convenzione di indirizzamento leggibile, non un confine di sicurezza reale, a differenza di quanto una lettura superficiale della documentazione potrebbe suggerire. Andrebbe valutata una segmentazione VLAN reale delle tre classi (PC/server/stampanti su VLAN e zone firewall separate), stesso pattern gia' collaudato per la Wi-Fi in Fase A (M13a). **Aggiornamento 16/07/2026**: l'utente ha segnalato un'implicazione concreta della rete flat, distinta dalla sola segmentazione — le stampanti multifunzione con funzione scan-to-folder possono scrivere direttamente nelle cartelle condivise di un PC Windows 11 (es. "scannerizzo un file e lo mando a un utente" invece che a un NAS presidiato), un fronte di sanificazione dei flussi dato (dove finiscono davvero i documenti scansionati, spesso con dati personali) che la sola VLAN per stampanti risolverebbe solo in parte: servirebbe anche una policy di destinazione (share SMB dedicate, non le cartelle utente). **Misurato il 29/07/2026**: l'osservazione non era un'ipotesi, e' la configurazione reale. La rubrica della multifunzione del Piano Terra contiene quattro destinazioni e **tutte e quattro** puntano a condivisioni di postazioni nella classe `.10`, su porta 445, nessuna a un NAS (dettaglio e implicazioni in SEC-020, #126). La policy di destinazione e' quindi da costruire da zero, non da correggere, ed e' stata staccata dalla segmentazione come intervento eseguibile subito (R8 in `docs/interventi-robustezza.md`) | Osservazione dell'utente durante la guida GUI Fase A, confermata il 15/07/2026, estesa il 16/07/2026; misurata sulla rubrica dell'apparato il 29/07/2026 |

---

## Cybersecurity – Gaps da Piano Attività e ingestion documenti

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 74 | SEC-001 | Bitdefender non installato su WINGROUPSHARE (10.77.116.3), WINSRV2019 (10.77.116.4), WIN-V712I9QHQT9 (10.61.20.13) | task_31/32 – Piano Attività |
| 75 | SEC-002 | Password policy: solo 25% completata – NAS randomizzate, mancano altri sistemi | task_33 – Piano Attività |
| 76 | SEC-003 | AnyDesk e TeamViewer presenti su macchine aziendali (accesso remoto non presidiato). **Contesto aggiuntivo (ingestione sec-006 ARCHITETTURA, 10/07/2026)**: valutata come alternativa controllata la piattaforma Supremo (licenza floating, nessuna VPN necessaria, macchina sempre sospesa quando non in uso). Rationale: con 1-2 utenti esterni al massimo, non serve un accesso VPN dedicato, basta una macchina interna raggiungibile con la stessa filosofia. Testata da Persona-J come utente fidata prima di un eventuale rollout piu' ampio; nessuna conferma di adozione definitiva nella fonte | task_14 – Piano Attività |
| 77 | SEC-004 | VM Egetrad (Ubuntu obsoleto, 10.61.20.5) ancora attiva; regole firewall EGETRAD_WEB da disabilitare. **Parziale 16/07/2026**: le secure-policy EGETRAD_WEB/EGETRAD_WEB_TEST sono state rimosse durante la pulizia di M13a — resta aperta solo la VM Ubuntu obsoleta stessa, non ancora decommissionata | task_27 – Piano Attività + docs/it-backlog.md |
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

## RAEE / smaltimento apparecchiature — gap ambientale (ingestione RAEE.docx, 08/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 109 | ENV-001 | Nessun accordo documentato con il fornitore di smaltimento RAEE; nota interna segnala di verificare con Persona-B che tipo di accordo esiste. Rischio dichiarato solo prospettico (parco PC/monitor attuale tutto nuovo), ma la norma sullo smaltimento andra' applicata alla prossima dismissione | Cybersec & IT Governance/RAEE.docx |

---

## AWS – Access key admin inattiva/non rotata (indagine costo anomalo, febbraio 2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 110 | SEC-012 | Costo anomalo su Amazon Translate (importo non riportato per policy amministrativa) tracciato a un'unica utenza IAM "adminuser" (AdministratorAccess, creata maggio 2019, **senza MFA**) con una access key attiva dal 2019. Nessun ruolo o job interno AWS risulta aver generato la chiamata (verificato via CloudTrail Event History e job Translate attivi/batch, entrambi vuoti): l'ipotesi piu' probabile e' una vecchia access key salvata su un PC/VM/server esterno (`~/.aws/credentials` o script/plugin obsoleto) ancora in grado di autenticarsi con privilegi admin. La remediation applicata e' stata una Deny Policy mirata solo su `translate:*`, non la rotazione della access key: la chiave resta attiva con privilegi amministrativi completi e la fonte reale della chiamata non e' stata identificata | IT + Administration - Documenti/Amazon AWS/0202026 (policy per bloccare Amazon translate)/ |

---

## ZeroSSL – certificato VPN cancellato (10/02/2026) — RISOLTO

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 111 | SEC-013 | ZeroSSL notifica la cancellazione del certificato SSL per `vpn.intrawelt.com` il 10/02/2026 (indirizzato a `it@intrawelt.com`). ZeroSSL e' il provider gia' documentato per questo certificato in `2023-baseline.md` e `2024-infra.md`, dall'epoca in cui l'accesso VPN passava per un hostname/servizio dedicato separato. **Verifica live il 09/07/2026**: la connessione TCP/443 non risponde (timeout) dalla rete interna Intrawelt. **Spiegazione confermata dall'utente il 10/07/2026**: `vpn.intrawelt.com` e' un riferimento a una configurazione VPN precedente, ormai superata — l'accesso VPN attuale passa attraverso il firewall Zyxel USG FLEX 500 (ZyWALL SecuExtender / SSL VPN gia' documentato in `firewall-zyxel-usg-flex-500.md`), non piu' tramite quell'hostname dedicato. La cancellazione del certificato ZeroSSL e' quindi coerente con la dismissione del vecchio servizio, non un'anomalia | IT + Administration - Documenti/ZeroSSL/Certificate Cancelled_ vpn.intrawelt.com.eml |

---

## Seeweb – disco di rete non identificato su WINSRV2019 (ingestione sec-008 ARCHITETTURA, 10/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 112 | SRV-004 | WINSRV2019 (Seeweb) ha un disco di rete aggiuntivo di circa 150 GB, nella stessa classe di indirizzi SEEWEB, che punta alla stessa cartella di WINGROUPSHARE e ha una connessione verso il NAS documenti (.170). La fonte stessa non ne chiarisce lo scopo ("da capire che cosa sono questi 150GB di roba"): da verificare se e' ancora in uso, cosa contiene, e se e' ridondante rispetto ai backup gia' documentati | ARCHITETTURA.docx sec-008 (Cloud) |
| 113 | SEC-014 | Licenza M365 Business Standard: non include Microsoft Intune (MDM). I dispositivi Windows aziendali non risultano gestiti/registrati centralmente ne' sottoposti a policy di conformita' via Intune; la difesa endpoint resta affidata solo a Bitdefender GravityZone (vedi vendor-management.md). Verificare se l'assenza di MDM va colmata nel percorso ISO 27001 (A.8.3, gestione dispositivi) | MICROSOFT 365.docx §Defender e Intune |

---

## GroupShare Seeweb – certificato HTTPS scomparso, traffico rimasto in chiaro (17-20/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 117 | SEC-015 | `https://gs.intrawelt.com` (portale GroupShare, VM WINGROUPSHARE su Seeweb) irraggiungibile su 443 (`ERR_CONNECTION_TIMED_OUT`), confermato da rete interna e da rete esterna; la porta 80 rispondeva regolarmente. Diagnosi sul server: nessun listener sulla 443, nessun binding SSL registrato (`netsh http show sslcert` vuoto), nessun certificato per `gs.intrawelt.com` nello store (solo il certificato interno `identity.sdl.com`, non toccato), sito IIS "SDL Server" con solo binding `http *:80:`. Causa radice: il certificato pubblico e il binding HTTPS erano stati rimossi/mai ricreati, probabilmente alla scadenza del certificato precedente. Tentativo di ripristino con win-acme (Let's Encrypt): bloccato inizialmente perche' il binding esistente non aveva host header; fix identificato (aggiungere binding `http/80/gs.intrawelt.com` per abilitare la validazione HTTP-01) ma **la connettivita' cifrata non e' stata ripristinata**: per sbloccare subito i Project Manager (client Trados Studio bloccati) si e' ripristinata la sola connettivita' HTTP normale. Il traffico verso il portale GroupShare, incluse le credenziali applicative, viaggia oggi in chiaro | `handoff-SSL.md` (comunicato dall'utente, 17-20/07/2026); vedi anche voce GroupShare del 06/07/2026 sopra |

---

## VM applicative su Proxmox — ricognizione live del 27/07/2026 (VM207, VM208)

Gap emersi dalla ricognizione diretta del nodo `pve` via MCP Proxmox e dell'interno
delle due VM via SSH il 27/07/2026, fuori dai filoni Wi-Fi e telefonia. Le due VM
ospitano progetti applicativi con repository e documentazione propri: qui si registra
solo cio' che ha rilevanza di rete e di sicurezza, non lo stato di avanzamento del
loro sviluppo.

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 118 | NET-011 | La VM208 `portaleAsset` (pilota interno del portale di supporto ISO27001, creata il 21/07/2026) e' attestata sul bridge `vmbr0`, cioe' sulla LAN unica `/19` dei servizi, e pubblica l'applicazione su TCP/80 e TCP/443 di tutte le interfacce tramite il reverse proxy del suo stack container. Ne consegue che l'intero dominio di broadcast della LAN piatta — postazioni, stampanti, server, VM — raggiunge senza filtri sia la SPA sia l'endpoint dell'identity provider del pilota. La NIC della VM ha `firewall=1` a livello di configurazione Proxmox, ma il firewall di cluster e' inattivo e senza regole, quindi il flag non produce nessun effetto (stessa situazione gia' nota per la VM202). Il pilota e' per definizione un ambiente non ancora indurito: e' il caso d'uso concreto che rende non piu' teorica la mancata segmentazione di NET-009, e va tenuto presente quando si pianifica M22 | Ricognizione live 27/07/2026: `mcp__proxmox__get_instance_config` VMID 208, `docker ps` sulla VM |
| 119 | SEC-016 | Catena di fiducia del pilota VM208 costruita a mano su ogni client: non esiste un server DNS di LAN, quindi il nome del portale si risolve per file `hosts` su ciascun PC Windows che deve accedervi (prassi preesistente in azienda, confermata durante la messa in opera), e il certificato del reverse proxy e' emesso da una CA interna generata dal proxy stesso, la cui root va importata manualmente nello store `LocalMachine\Root` di ogni macchina. Nessuno dei due passaggi e' tracciato in un processo: non c'e' inventario di quali macchine hanno la root installata, ne' procedura di revoca o di rinnovo alla scadenza. Per un pilota e' accettabile, per un servizio destinato a piu' utenti no — va deciso se introdurre una risoluzione nomi interna e una CA di dominio, oppure un certificato emesso da una CA pubblica, prima di allargare la platea. Rilevante per A.10.1 (crittografia) e per A.13.1. **Via di chiusura individuata il 30/07/2026**: il primo dei due problemi, la risoluzione nomi, si chiude senza introdurre un dominio, perche' i client ricevono gia' il firewall come primo server DNS e il firewall puo' ospitare record di indirizzo propri (intervento R12). Il secondo, i certificati, si chiude come conseguenza della convenzione di denominazione scelta in ADR-018: nomi sotto un sottodominio del dominio aziendale sono validabili da un'autorita' pubblica tramite record DNS, senza esporre il servizio su Internet, quindi il portale interno puo' passare da CA interna a certificato pubblicamente riconosciuto e la distribuzione manuale della radice su ogni postazione cessa. Dipendenza da verificare: l'accesso alla zona DNS pubblica del dominio presso il fornitore che la ospita | Ricognizione live 27/07/2026; documentazione interna del progetto Portale Asset IT |
| 120 | SRV-005 | La configurazione della VM207 `websiteAnalyst` contiene, nel campo descrizione, il parametro `args: -vnc 0.0.0.0:77`, cioe' un server VNC potenzialmente in ascolto su tutte le interfacce del nodo (display 77, TCP 5977) invece che sul solo loopback come vuole la prassi di accesso alla console via tunnel. Non e' stato verificato se il parametro sia effettivamente attivo sul processo QEMU ne' se la sessione richieda una password: e' la prima verifica da fare. Nella home dell'utente della stessa VM sono inoltre presenti un file `pass.txt` leggibile da qualunque utente locale e un `error.log` applicativo del 2025 — stessa radice di SEC-007/SEC-010/SEC-011, segreti operativi nel filesystem invece che in un vault. Il servizio applicativo della VM (backend FastAPI sotto systemd, utente dedicato) espone HTTP in chiaro sulla porta 8000 legata all'indirizzo di LAN: coerente con la scelta dichiarata di esposizione solo interna, ma senza cifratura ne' autenticazione documentate | Ricognizione live 27/07/2026: `get_instance_config` VMID 207, `ss -tlnp` e `ls -la` sulla VM |
| 121 | SEC-017 | Governo del codice sorgente dei progetti ospitati sulle VM aziendali non normato. Il repository del progetto sulla VM207 ha due remote configurati: quello dell'organizzazione aziendale e un secondo verso un repository sotto l'account GitHub personale di un collaboratore, con l'identita' di commit locale della cartella impostata su quel collaboratore; entrambi allineati sullo stesso HEAD. Il progetto sulla VM208 pubblica invece sul solo remote dell'organizzazione. Non esiste una regola scritta su dove viva il codice prodotto su asset aziendali, su chi mantenga l'accesso ai repository quando un collaboratore esce, ne' sulla titolarita' del codice: da normare come parte del percorso ISO27001 (A.14.2 servizi di sviluppo, A.9 gestione degli accessi) prima che i progetti crescano | Ricognizione live 27/07/2026: `git remote -v` e `git config user.*` sulle due VM |

---

## Censimento M22a — snapshot Nebula del 27/07/2026 (Piano Terra completo, Piano 2 assente)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 122 | NET-012 | Sul XGS2220-30HP (Piano Terra) le protezioni di livello 2 contro un server DHCP abusivo sono **disattivate**: DHCP Server Guard (il nome Zyxel del DHCP snooping) e IP source guard risultano entrambi off, verificato il 23/07/2026 nelle impostazioni dello switch. La verifica era nata per scagionare lo switch dal sospetto di scartare le offerte DHCP della fonia, e in quel senso e' stata utile, ma lascia il fatto: qualunque dispositivo collegato a una porta di accesso puo' rispondere a una richiesta DHCP e dirottare i client su un gateway e un DNS arbitrari, senza che lo switch se ne accorga. Su una LAN piatta l'impatto e' l'intera `/19`. L'attivazione non e' pero' gratuita e va pianificata dentro M22: se si abilita lo snooping bisogna marcare come *trusted* la porta da cui arrivano le offerte legittime, altrimenti si scartano quelle vere — che e' esattamente il tranello che avevamo ipotizzato per i telefoni. Da valutare porta per porta insieme al disegno dei segmenti | Verifica `Configure > 30HP > impostazioni switch`, 23/07/2026 (screenshot 248-249) |
| 123 | NET-013 | La porta 19 del XGS2220-30HP risulta ancora configurata come access con **PVID 90**, cioe' nella VLAN degli ospiti, nello snapshot del 27/07/2026 alle 14:54. E' il residuo del test cablato del 22/07 (un portatile collegato a quella porta per verificare che il difetto della VLAN 90 non fosse specifico del Wi-Fi), che risultava riportato a PVID 1 a fine test: la configurazione dice il contrario, quindi il ripristino non e' stato applicato oppure e' stato perso. La porta e' attualmente senza link, quindi non c'e' un impatto in atto, ma una presa a muro del Piano Terra che consegna un client direttamente nella rete ospiti e' un difetto di segmentazione al contrario: chi si collega li' esce su Internet aggirando i controlli previsti per la LAN. Da riportare a PVID 1 come pulizia, prima di M22b | `output/nebula-snapshot.json` del 27/07/2026; nota di sessione del 22/07/2026 |

---

## Ultimo access point EOL residuo (28/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 124 | SEC-018 | Con la sostituzione dei tre AP Ubiquiti di Piano Terra, Piano 1 e Piano 2 (Fase B, in servizio dal 21-27/07/2026), resta in rete **un solo dispositivo della vecchia classe**: l'AP "EsternoIrrigazione" sulla porta 4 del XGS2220-30HP, che serve la centrale di irrigazione sul tetto. Il referto Nessus della VA del 06/11/2025 lo descrive come gemello hardware degli altri: Debian 7 con Dropbear SSH come unica porta aperta, cioe' un sistema operativo fuori supporto dal 2016, non gestibile (credenziali perdute, nessuna interfaccia web), collegato senza filtri alla LAN piatta `/19`. Finche' erano quattro il problema era di classe; ora e' concentrato su un singolo apparato identificato, con una porta nota, e quindi risolvibile. Portato in scope come micro-step M13c il 28/07/2026 (ADR-016), con due esiti possibili: eliminazione dell'AP se la centrale di irrigazione puo' essere cablata, oppure sostituzione con un apparato per esterni gestito. Mitigazione interim da valutare nel frattempo, dato che il firewall non puo' filtrare traffico interno alla `/19`: isolamento di porta a livello switch | Referto Nessus VA Onova 06/11/2025; snapshot Nebula 27/07/2026 (porta 4, `AUTO_100M`, PoE attivo); rilievo fisico `mappatura-porte-fisiche.md` (0-9-1 via patch da 0-8-1) |

---

## Multifunzione: credenziali amministrative di fabbrica (28/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 125 | SEC-019 | La multifunzione Kyocera TASKalfa 2552ci del Piano Terra (`10.61.30.10`) ha l'interfaccia amministrativa Command Center RX raggiungibile da tutta la LAN piatta e protetta dalle **credenziali di fabbrica del produttore**, cioe' la coppia predefinita documentata pubblicamente per quella linea di prodotti. Non e' un dettaglio minore per due ragioni concrete. La prima e' che il pannello amministrativo di una multifunzione controlla l'indirizzamento di rete, i protocolli esposti e la rubrica delle destinazioni di scansione: chi vi accede riconfigura l'apparato e vede dove finiscono i documenti. La seconda, piu' rilevante ai fini della protezione dei dati, e' che le destinazioni di scansione verso cartelle di rete richiedono credenziali di accesso alla condivisione, che l'apparato conserva al proprio interno: un accesso amministrativo con password di fabbrica e' quindi anche una via verso le credenziali di un account che scrive su una share aziendale. L'altra multifunzione, la Canon del Piano 1, risulta invece con una password amministrativa propria, non di fabbrica. Azione: cambiare la credenziale di fabbrica e conservarla nel password manager aziendale (VM202), contestualmente al micro-step M22b che tocca comunque queste due macchine. **Mitigazione immediata disponibile, scoperta il 28/07 leggendo il pannello**: l'apparato dispone di una funzione di filtro IP, quindi l'accesso puo' essere ristretto alle sole postazioni IT senza attendere la segmentazione e senza dipendere dal firewall, che sulla LAN piatta non vede questo traffico. E' il tipo di controllo compensativo che conviene applicare subito, perche' costa una configurazione e riduce la platea da "tutta la `/19`" a "due indirizzi". Rilevante per A.9.4 (accesso privilegiato) e A.5.17 (informazioni di autenticazione) | Comunicata dall'IT Manager il 28/07/2026 durante il censimento M22a; coppia di fabbrica non riportata qui per policy |

---

## Destinazioni di scansione verso postazioni, credenziali memorizzate nell'apparato (29/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 126 | SEC-020 | Lettura diretta della rubrica della multifunzione Kyocera del Piano Terra: **tutte e quattro** le destinazioni configurate sono di tipo cartella di rete SMB e puntano a **condivisioni di singole postazioni** nella classe delle postazioni, su porta 445, con percorsi del tipo `SCANNER` o `Scanner_<nome>`; nessuna destinazione punta a un NAS e nessuna e' di tipo e-mail o FTP. Per ciascuna voce l'apparato conserva al proprio interno **nome utente e password** di accesso alla condivisione, e almeno una di queste utenze e' il nome e cognome di una persona fisica invece di un account di servizio. Ne derivano quattro problemi distinti: i documenti scansionati, che tipicamente contengono dati personali, si depositano su endpoint invece che su uno spazio presidiato con backup noto (A.8.3, A.5.14); la scansione dipende dall'accensione di quella postazione e dalla condivisione attiva, quindi e' fragile per ragioni non di sicurezza; l'apparato e' un deposito di credenziali di accesso a share aziendali, aggravato dal fatto che il suo pannello amministrativo e' protetto dalle credenziali di fabbrica (SEC-019, #125) ed e' raggiungibile da tutta la LAN piatta; e l'utenza nominale rende non attribuibile l'attivita' sulla share e destinata a rompersi silenziosamente all'uscita di quella persona (A.9.2). Rimedio tracciato come intervento non bloccante R8 e R9 in `docs/interventi-robustezza.md`, eseguibile **prima** della segmentazione e indipendentemente da essa. **Estensione del 29-30/07/2026, censimento chiuso su entrambe le multifunzione**: la seconda macchina (Canon iR-ADV C5840, Piano 1) ha sette destinazioni registrate nel proprio elenco a selezione veloce — gli altri sessantadue elenchi che il firmware espone sono contenitori vuoti — e sono **sette su sette cartelle di rete SMB verso condivisioni di postazioni**, nessuna e-mail e nessun FTP. Il totale e' quindi undici destinazioni su due apparati che si riducono a **sette destinatari distinti**, perche' le quattro voci della Kyocera sono un sottoinsieme delle sette della Canon. Tre aggravanti emerse dalla seconda rubrica: due destinazioni puntano alla postazione per **nome NetBIOS** invece che per indirizzo, quindi dipendono da una risoluzione in broadcast che muore attraversando un confine di livello 3 (terza forma della stessa trappola dopo mDNS e assenza di DNS interno); le utenze nominali memorizzate sono **due**, una per apparato, quindi R9 non affronta un caso isolato; e su tutte e sette le voci l'opzione di **conferma della destinazione prima dell'invio e' disattivata**, quindi una selezione sbagliata dal display deposita documenti nella cartella di un'altra persona senza nessun passaggio che permetta di accorgersene — rimedio tracciato come R11. **Stato al 03/08/2026, dopo l'esecuzione di R8**: le quattordici destinazioni di entrambe le multifunzione sono state riconfigurate verso sette condivisioni nascoste del NAS, con **un solo account di servizio locale del NAS** come unica credenziale memorizzata negli apparati, permessi per destinatario e isolamento provato in campo; ogni utente raggiunge la propria cartella da un collegamento sul desktop e le sette postazioni risultano funzionanti. Il gap **resta pero' aperto** per un motivo preciso: sulle postazioni sopravvivono le vecchie condivisioni di scansione e le credenziali che le servivano, comprese le due utenze nominali. Finche' esistono, il percorso e i segreti sono ancora li' anche se nessuno vi scrive piu': la chiusura di SEC-020 coincide con la loro rimozione, non con la creazione delle nuove cartelle | Rubrica periferica dell'apparato, letta dall'IT Manager il 29/07/2026 (screenshot in `_notes/`); indirizzi e utenze reali non riportati qui per policy |

---

## NAS-INTRA2: cartella di backup ufficio da 14 TB e milioni di oggetti (29/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 127 | STOR-001 | Ispezionando le cartelle condivise di NAS-INTRA2 (QNAP TS-435XeU, QTS 5.2.9, 4 GB di RAM) per preparare l'intervento R8, e' emerso che la cartella condivisa dedicata al backup dell'ufficio contiene **14,37 TB distribuiti su circa 3,45 milioni di cartelle e 1,86 milioni di file**, cioe' da sola quasi tutta la capacita' utile dell'apparato. Tre domande aperte che nessuna fonte del progetto risponde: cosa contenga davvero (backup di postazioni, archivio storico, copia di altri NAS), se sia essa stessa protetta da una copia o solo la destinazione di copie altrui, e quanto tempo richiederebbe un ripristino selettivo con quel numero di oggetti — perche' un conteggio di file di quell'ordine rende lentissime le operazioni che attraversano l'albero, dagli snapshot all'antivirus all'indicizzazione, e trasforma un restore "veloce" in un'operazione di ore. Rilevante per A.8.13 (backup) e per il piano di continuita', dove va dichiarato un tempo di ripristino realistico e non ottimistico. Non e' un difetto in se': e' una concentrazione di dati e di rischio che va conosciuta prima di aggiungere su quello stesso apparato la cartella delle scansioni | Pannello cartelle condivise di NAS-INTRA2, letto il 29/07/2026 |

---

## Assenza di un servizio di directory e conseguenze sulle credenziali (30/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 128 | SEC-021 | Lo snapshot NinjaOne dell'organizzazione Intrawelt censisce 26 dispositivi gestiti e riporta per ognuno il ruolo di dominio: **tutti risultano "Standalone Workstation" o "Standalone Server"**, quattordici con un nome di workgroup aziendale e dieci con il workgroup predefinito di Windows, piu' una postazione Linux. Non esiste quindi alcun servizio di directory: nessun dominio, nessuna autenticazione centralizzata, nessun single sign-on. Non e' una curiosita' architetturale, e' la causa comune di almeno quattro fatti gia' tracciati separatamente in questo progetto. Primo, ogni accesso tra macchine avviene con **credenziali locali memorizzate** — e' cosi' che le due multifunzione conservano utenza e password delle condivisioni degli utenti (SEC-020), ed e' cosi' che una postazione accede al disco di un'altra. Secondo, poiche' l'RMM ruota le password locali ogni trenta giorni, ogni credenziale memorizzata ha vita massima trenta giorni: il difetto non e' solo di sicurezza ma di manutenzione ricorrente. Terzo, senza directory non esiste un servizio di risoluzione nomi interno, quindi la risoluzione e' affidata al broadcast (NetBIOS, mDNS) e ai file `hosts` distribuiti a mano, che e' esattamente cio' che SEC-016 registra e che rende fragile qualunque segmentazione, perche' il broadcast non attraversa un confine di livello 3. Quarto, non e' possibile una separazione degli accessi basata su identita': tutto si costruisce su permessi per condivisione e credenziali locali. L'introduzione di un servizio di directory con DNS interno chiuderebbe insieme SEC-016, la dipendenza dal broadcast e la dipendenza dalle credenziali memorizzate, ma cambia il modello di gestione degli endpoint e va valutata come progetto a se', non come intervento di rete | `output/ninjaone-snapshot.json` del 30/07/2026, campi `system.domain` e `system.domainRole` dei 26 dispositivi dell'organizzazione |
| 129 | SEC-022 | Lo snapshot dell'RMM eseguito il 30/07/2026 con le credenziali API del provider MSP ha restituito, prima di qualunque filtro, **99 dispositivi appartenenti a 26 organizzazioni**: cioe' l'inventario di venticinque aziende terze, clienti dello stesso provider, oltre a quello di Intrawelt. Non e' un difetto dell'istanza, e' la conseguenza naturale di una chiave API multi-tenant usata senza restringere l'ambito, ed e' un problema di minimizzazione: questo progetto non ha alcuna necessita' di detenere l'inventario di altre aziende, e conservarlo su disco significherebbe custodire dati di terzi senza titolo. Rimedio applicato nella stessa sessione: lo script `Get-NinjaSnapshot.ps1` filtra ora per organizzazione (default sul nome dell'azienda) e conserva solo dispositivi, interfacce e interrogazioni di quella, con un interruttore esplicito `-AllOrganizations` che va usato solo con una ragione dichiarata. Azione residua: rigenerare lo snapshot con il filtro attivo e cancellare quello non filtrato. Rilevante per A.5.34 e per il rapporto con il fornitore (A.5.19-A.5.22). **Seconda iterazione del rimedio, 30/07/2026**: il primo filtro conservava 28 dispositivi invece di 26 e la discrepanza, notata perche' lo script stampa il conteggio, ha rivelato un difetto con conseguenze di riservatezza e non solo di conteggio — l'insieme degli id usato per filtrare le interrogazioni diagnostiche raccoglieva anche gli id delle *locations*, che portano lo stesso campo di appartenenza all'organizzazione, e quei due id coincidevano con dispositivi di altre organizzazioni, facendo passare le loro righe (28 righe di sistema operativo invece di 26, 1384 interfacce invece di 1381). Corretto raccogliendo gli id soltanto dagli endpoint dei dispositivi. Aggiunta nella stessa correzione una minimizzazione ulteriore: policy, gruppi e libreria script non portano appartenenza a un'organizzazione perche' sono oggetti dell'istanza del provider, quindi per default si conservano solo le policy effettivamente applicate ai dispositivi filtrati e si scartano gruppi e libreria script, con un interruttore esplicito per conservarli quando serve | Esito del primo snapshot, 30/07/2026; correzioni successive nello stesso script | Esito del primo snapshot, 30/07/2026; correzione nello stesso script |

---

## Interfacce residue sul firewall (30/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 130 | FW-013 | L'elenco completo delle interfacce dello USG FLEX 500 conta 14 voci, e accanto a quelle in servizio ne convivono alcune **residue di configurazioni superate**: un'interfaccia denominata `guest` su una subnet `/24` che appartiene a un blocco RFC1918 estraneo al piano di indirizzamento documentale (valore reale nella mappa privata), residuo dell'epoca in cui la rete ospiti era una porta fisica e non la `vlan90` agganciata a `lan1` che funziona dal 22/07/2026; `lan2` su una `/24` dedicata, gia' documentata come da dismettere perche' raggiungibile solo attraverso una rotta statica verso un router downstream che non esiste piu'; piu' `sfp` e `reserved`, entrambe senza indirizzo. Nessuna di queste produce un danno in atto, ma insieme creano il rischio documentale che il progetto ha appena sperimentato: leggendo l'elenco senza sapere quale interfaccia sia viva si attribuisce alla rete ospiti una subnet che non usa piu'. Bonifica da pianificare con la stessa cautela di ogni modifica sul firewall: prima verificare che nessuna regola, rotta o oggetto indirizzo le referenzi, usando il pulsante `References` della stessa pagina | Elenco interfacce del firewall, letto il 30/07/2026 |

---

## Nomi interni sul suffisso riservato a mDNS (30/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 131 | NET-014 | Due servizi interni sono documentati con nomi che finiscono in `.local`: un vault di password su `<nome>.intrawelt.local` e uno strumento di gestione progetti su un nome breve seguito da `.local`. Quel suffisso e' **riservato a mDNS** dallo standard che lo definisce, quindi i sistemi operativi lo risolvono interrogando il multicast e non il DNS unicast: pubblicare quei nomi su un server DNS produce un comportamento che dipende dall'ordine dei risolutori del singolo client — funziona su una macchina e non sull'altra — e cessa comunque di funzionare attraversando un confine di livello 3, che e' esattamente cio' che la segmentazione introduce. E' la stessa trappola incontrata con l'annuncio Bonjour delle multifunzione e con le destinazioni di scansione per nome NetBIOS, con la differenza che qui e' incorporata nella scelta del nome. Non sono quindi lo standard da seguire per i nuovi record di R12 ma un debito da migrare al suffisso che verra' scelto, con l'accortezza di aggiornare le configurazioni che li referenziano prima di rimuoverli. **Estensione del 30/07/2026, verificata interrogando il firewall: il problema e' molto piu' ampio di due nomi.** Interrogando esplicitamente il resolver del firewall per il nome di un NAS, la risposta arriva — quindi l'apparato **ospita gia' record di indirizzo interni**, contrariamente a quanto questo progetto aveva assunto — ma la risposta e' per un nome pienamente qualificato che finisce in **`.local`**: la zona interna esistente e' costruita sul suffisso riservato a mDNS, non su un dominio aziendale. In parallelo, il file `hosts` della postazione ispezionata contiene **sedici voci** che mappano a mano gli stessi nomi e altri ancora, fra cui i quattro NAS, tre servizi interni, un nome nel dominio pubblico aziendale sovrascritto verso un indirizzo interno, e alcune voci generate da strumenti di sviluppo. Ne segue che oggi convivono **due sistemi di risoluzione nomi in concorrenza** — la zona `.local` sul firewall e i file `hosts` per postazione — con il file locale che vince sempre, e nessun inventario di cosa ci sia scritto su ciascuna macchina. Il gap non e' quindi "manca il DNS interno" ma "ci sono due nomi per la stessa cosa e nessuno sa quale risponde", che e' peggio: la stessa applicazione puo' funzionare su una postazione e non sull'altra a seconda di quale voce e' presente | Ricognizione dei nomi interni in uso nella documentazione di progetto, 30/07/2026 |

---

## Servizio DNS del firewall: inoltro a resolver pubblici e controllo di servizio permissivo (30/07/2026)

| # | ID | Descrizione | Fonte |
|---|----|-------------|-------|
| 132 | FW-014 | La pagina DNS dello USG FLEX 500 mostra tre fatti che vanno letti insieme. Primo: le tabelle dei **record di indirizzo e degli alias sono vuote**, quindi il firewall non ospita alcun nome interno — la risoluzione dei nomi interni su questa rete e' interamente affidata ai file `hosts` delle postazioni e agli annunci in broadcast (mDNS, NetBIOS), che e' la conferma di NET-014 e di SEC-016 e cio' che rende fragile ogni segmentazione. Secondo: l'unica configurazione presente inoltra **qualunque zona** verso due resolver pubblici, quindi l'apparato lavora da puro inoltratore. Terzo, ed e' il punto da verificare con priorita': il controllo di servizio del DNS e' impostato su zona `ALL` e indirizzo `ALL` con azione di accettazione, cioe' il servizio accetta interrogazioni da qualunque provenienza. Se quella configurazione e' effettivamente raggiungibile dalla WAN, il firewall e' un **resolver aperto**, condizione usata negli attacchi di amplificazione e riflessione DNS e tipicamente segnalata da qualunque scansione esterna. Va verificato interrogando il servizio dall'esterno e leggendo la politica di sicurezza da WAN verso il dispositivo; se confermato, il controllo di servizio va restretto alle sole zone interne. Rilevante per A.8.20 e A.8.21 | Pagina `Configuration > System > DNS` del firewall, letta il 30/07/2026 |

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
| Tagging VLAN centralino cloud (07/07/2026) | 102-103 |
| Crittografia dati a riposo (audit 07/2026) | 104 |
| Licenze ABBYY — ingestione ABBYY.docx (07/07/2026) | 105-106 |
| IntraLino benchmark — ingestione cartella n8n (07/07/2026) | 107 |
| Snapshot v4 (08/07/2026) | 108 |
| RAEE / smaltimento apparecchiature (08/07/2026) | 109 |
| AWS access key admin non rotata (09/07/2026) | 110 |
| ZeroSSL certificato VPN cancellato (09/07/2026) | 111 |
| Seeweb disco 150GB non identificato (10/07/2026) | 112 |
| LAN flat /19, scan-to-folder (16/07/2026) | 114 |
| Link flap porta 46 54HP (16/07/2026) | 115 |
| TEL-002 aggiornamento (17/07/2026) | 116 |
| GroupShare Seeweb, HTTPS non ripristinato (17-20/07/2026) | 117 |
| VM applicative su Proxmox, ricognizione live (27/07/2026) | 118-121 |
| Censimento M22a, snapshot Nebula (27/07/2026) | 122-123 |
| Ultimo AP EOL residuo (28/07/2026) | 124 |
| Multifunzione con credenziali di fabbrica (28/07/2026) | 125 |
| Destinazioni di scansione verso postazioni (29/07/2026) | 126 |
| NAS-INTRA2, cartella backup ufficio da 14 TB (29/07/2026) | 127 |
| Assenza di directory e snapshot multi-tenant (30/07/2026) | 128-129 |
| Interfacce residue sul firewall (30/07/2026) | 130 |
| Nomi interni su suffisso mDNS (30/07/2026) | 131 |
| Servizio DNS del firewall (30/07/2026) | 132 |
| **Totale identificati** | **132** |
| **Di cui risolti** | **8** (14, 54, 55, 61, 63, 106, 111, 116 — vedi stato "Corretto"/"Fatto"/"Riconciliato"/"Risolto"; il 116 e' risolto per la sola parte switch/VLAN, il livello DHCP resta in attesa del fornitore) |