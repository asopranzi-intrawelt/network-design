---
last-verified: 347f79c
---

# Roadmap e fasi del progetto

## Fase 0 - Inizializzazione (COMPLETATA)

- Struttura progetto e template `.claude/` canonica
- Script snapshot Proxmox v3 integrato
- Snapshot infrastruttura v3 come baseline corrente
- Due layer documentali (narrativo + tecnico) configurati
- Primo commit e push su git@github-corp:asopranzi-intrawelt/network-design.git

## Fase 1 - Ricostruzione storia della rete (COMPLETATA)

Documento Word principale (ARCHITETTURA SERVER-CLOUD-LINEE 20052026.docx) ingestato
con strategia a disclosure progressiva. Estratte 12 sezioni prioritarie.

Output prodotto in `docs/infrastructure-timeline/`:
- 2023-baseline.md: stato di partenza pre-IT-manager
- 2024-infra.md: ottobre-dicembre 2024
- 2025-q1-server-vianova.md: gennaio-marzo 2025
- 2025-q2-migrazione-tim-vianova.md: aprile-giugno 2025 (switch WAN, tunnel SEEWEB)
- 2025-q3-q4.md: luglio-dicembre 2025
- 2026-switch-piano-terra.md: gennaio-giugno 2026
- GAP-TBC.md: 53 TBC censiti con fonte probabile

Credenziali e IP pubblici anonimizzati per repo pubblico su GitHub.

Documenti Word secondari da ingestare (rimandati a Fase 2):
- Mappatura porte fisiche
- Telefono-PBX
- ZYXEL FIREWALL e VPN
- [TBC] Diagramma di rete

## Fase 2 - Documentazione stato corrente (COMPLETATA il 10/07/2026)

Obiettivo: documentare in modo completo la rete attuale integrando snapshot Proxmox
con configurazioni switch, firewall, AP e NAS. Produrre un diagramma di rete completo.

Steps:

1. **Fatto.** Documenti Word secondari della cartella ARCHITETTURA SERVER-CLOUD-LINEE
   ingestati (Telefono-PBX, ZYXEL FIREWALL e VPN, licenze). Il documento
   "[TBC] Diagramma di rete e analisi firewall, centralino" (cartella separata in
   radice progetto, non OneDrive) e' stato ingestato integralmente il 01/07/2026:
   vedi `docs/infrastructure-timeline/ingestion-checklist.md` e i riferimenti
   incrociati in `docs/firewall-zyxel-usg-flex-500.md`, `docs/network-diagram.md`,
   `docs/telefono-pbx-voip.md`.

2. **Fatto 08/07/2026.** Snapshot v4 eseguito dall'utente
   (`Get-ProxmoxSnapshot.ps1`): scheda `design-and-security.md` aggiornata,
   gap #106/#107 riconciliati, nuovo #108 (IP nodo = iLO nello stato
   cluster). Resta M18 per il re-run post-M5/M16.

3. **Fatto.** Configurazione switch Zyxel via Nebula documentata in
   `docs/network-diagram.md` e `docs/infrastructure-timeline/2026-switch-piano-terra.md`
   (XGS2220-54HP Piano 2, XGS2220-30HP Piano Terra installato aprile 2026,
   dorsale 10 Gbps operativa dall'08/05/2026).

4. **Fatto, ma piano non applicato.** Configurazione firewall Zyxel USG FLEX 500
   documentata in dettaglio in `docs/firewall-zyxel-usg-flex-500.md` (zone,
   interfacce, VPN, NAT, security policy, dieci anomalie FW-001/FW-010). Il piano
   di correzione a sei fasi (05/06/2026) resta da applicare: vedi Fase 3.

5. NAS fleet: stato RAID, capacita', job backup, versioni firmware. **Fatto
   10/07/2026**: inventario sistematico consolidato in `vendor-management.md`
   §QNAP – NAS (RAID, capacita', ruolo, backup per ciascuno dei 5 dispositivi).
   Resta [TBC] solo la versione firmware, non riportata in nessuna fonte.

6. **Fatto.** `docs/network-diagram.md` con diagramma ASCII della topologia corrente.
   Consolidamento in Mermaid versionato (`context/diagrams/network-topology.mmd`)
   rimandato alla fine della Fase 3, per aggiornarlo una sola volta con lo stato
   finale invece che a ogni micro-intervento (vedi nota "Diagramma vivo" sotto).

7. **Fatto 10/07/2026.** Gap analysis ISO27001 Annex A ampliata in
   `design-and-security.md` da 5 a 10 controlli, incrociando lo snapshot
   Proxmox v4, il piano firewall a micro-step e `GAP-TBC.md` (nuove righe:
   A.8.21 VPN IKEv1, A.8.1 endpoint/Intune, A.8.13 backup NAS, A.7.1 badge
   sala server, A.8.24 crittografia). Non e' una Statement of Applicability
   formale (resta in Fase 5).

## Fase 3 - Ottimizzazione Proxmox e firewall: roadmap a micro-step (RIPRENDIBILE dal 10/07/2026)

Sospensione originaria: su decisione dell'utente del 07/07/2026 i micro-step
operativi (M2 in avanti) erano in pausa finche' non fosse completata la
ripresa dell'ingestione OneDrive (Fase 1bis sopra). La condizione di
sblocco si e' verificata il 10/07/2026: la fase e' quindi riprendibile, ma
la maggior parte dei micro-step da M2 in poi richiede accesso fisico
all'hardware di rete reale (console seriale, cablaggio, iLO) che l'agente
non puo' eseguire da remoto — vanno guidati passo passo con l'utente in
sede. M1 resta l'unico micro-step chiuso.

Obiettivo: applicare le correzioni e le ottimizzazioni identificate dall'analisi
firewall/DMZ/Proxmox, un micro-step alla volta, con commit e aggiornamento di
`memory/progress.md` a ogni step chiuso. Ogni riga della tabella e' un intervento
singolo, verificabile, con un solo esito atteso: non si passa alla riga successiva
finche' quella corrente non e' verificata o esplicitamente rimandata con nota.

### Diagramma vivo

In parallelo a ogni micro-step, `docs/network-diagram.md` e la tabella diagrammi
di `docs/firewall-zyxel-usg-flex-500.md` si aggiornano con una nota testuale del
cambiamento (non un nuovo diagramma renderizzato a ogni step, per non consumare
token inutilmente). Il diagramma Mermaid consolidato in
`.claude/context/diagrams/network-topology.mmd` si rigenera una sola volta, a
fine Fase 3, riflettendo lo stato finale post-ottimizzazione; i drawio/svg
intermedi restano come riferimento storico in `context/diagrams/firewall-dmz-2026/`.

### Version control

Ogni micro-step chiuso corrisponde a un commit separato (manuale, a cura
dell'utente secondo `.claude/rules/git-commands-format.md`), cosi' che la
storia git rispecchi la sequenza degli interventi fisici sulla rete e non un
unico commit cumulativo di fine fase.

### Registro parallelo dei micro-interventi non bloccanti (dal 29/07/2026)

Gli interventi puntuali che emergono come effetto collaterale delle analisi — una
credenziale di fabbrica mai cambiata, un annuncio multicast inutile, una porta rimasta in
una VLAN di test, destinazioni di scansione verso postazioni, un campo descrittivo vuoto —
non vivono in questa tabella ma in `docs/interventi-robustezza.md`, con una regola di
ammissione esplicita: nessuna finestra di manutenzione, nessun tocco al piano dati di
apparati centrali, rollback di una sola azione. Nove voci all'apertura (R1-R9).

La distinzione non e' burocratica: serve a non far aspettare interventi a rischio quasi
nullo e beneficio alto dietro micro-step strutturali che richiedono progetto, finestre e
coordinamento. Due voci di quel registro sono anche prerequisiti di M22b e possono essere
eseguite prima e indipendentemente dalla segmentazione: R7, conversione delle stampanti da
indirizzo statico a riserva DHCP, e R8, spostamento delle destinazioni di scansione su una
share dedicata del NAS. R5, il ripristino della porta 19 del 30HP da PVID 90 a PVID 1,
chiude il gap NET-013 senza attendere nulla.

### Micro-step tracciati

| # | Intervento | Priorita' | Gap/fonte | Dipendenza | Stato |
|---|-----------|-----------|-----------|------------|-------|
| M1 | Correggere `Blocco_Gruppo_IP_Phishing_Elisa` (allow -> deny) e `malicious_IP_12052025` (allow -> deny) via GUI firewall, fuori finestra di manutenzione | CRITICA | FW-001, FW-002 (Fase 0 del piano) | Nessuna | **Fatto 01/07/2026** |
| M2 | Verificare fisicamente console seriale (115200 baud) e accesso iLO; confermare supporto 802.1Q su XGS2220-54HP | ALTA | Fase 1 del piano | M1 | Parziale 13/07/2026: accesso iLO5 recuperato (password root perduta, reset via hponcfg dal sistema operativo, nessun riavvio del server) e connessione SSH all'iLO configurata da questa macchina. Restano da verificare console seriale e supporto 802.1Q |
| M3 | Backup datato di firewall e switch prima di ogni modifica strutturale | ALTA | Fase 1 del piano | M2 | Da fare |
| M4 | Configurare VLAN 201 sullo switch Piano 2 (P7 access, porta Proxmox trunk) | ALTA | Fase 2 del piano, FW-009 | M3 | Da fare |
| M5 | Configurare bridge-vlan-aware su Proxmox (`ifreload -a` da iLO), VM di test con tag 201 | ALTA | Fase 3 del piano | M4 | Da fare |
| M6 | Cablare P7 verso lo switch, validare L2 con `arping`/`tcpdump` | ALTA | Fase 4 del piano | M5 | Da fare |
| M7 | Caricare la configurazione target dal seriale (rimozione WAN_TRUNK, rimozione LAN2 e rotte statiche, attivazione DMZ, pubblicazione web `wan1:2`) | CRITICA | Fase 5 del piano, FW-004, FW-008, FW-009 | M6 | Da fare |
| M8 | Verifica post-applicazione nell'ordine di impatto utente (LAN, SSL VPN, IPsec, VM DMZ) + 48h di osservazione log | ALTA | Fase 6 del piano | M7 | Da fare |
| M9 | Prima VM DMZ operativa (nginx reverse proxy 10.61.201.10, esposta su 203.0.113.3) | MEDIA | Piano_Operativo_Migrazione.docx | M8 | Da fare. Nota 27/07/2026: esiste ora un consumatore reale di questa DMZ — il progetto del portale sulla VM208 ha esplicitamente rimandato la propria esposizione pubblica a "dietro la DMZ del network-design", quindi M4-M9 sono il prerequisito di quella pubblicazione |
| M10 | Verificare quale switch ospita realmente la porta del telefono di Persona-A (contraddizione Piano 2 vs Piano Terra) prima di chiudere la mappatura IP/MAC telefoni | MEDIA | NET-007, GAP-TBC #67 | Nessuna (indipendente dal piano firewall) | Da fare |
| M11 | Verificare la funzione della porta 8 riconfigurata "Vianova DHCP server fonia" (PVID 2) e valutare se sostituisce la rimozione del DHCP server classe .90 | MEDIA | FW-012 | M10 | Parziale 07/07/2026: funzione confermata (DHCP+gateway Vianova untagged, isolati dal firewall); resta la valutazione sul DHCP .90 |
| M12 | Rimuovere il DHCP server residuo classe .90 e spostare lo switch di management (10.61.90.37) sulla VLAN corretta | ALTA | NET-001, NET-004, NET-005 | M11 | Parzialmente superato dai fatti (22-23/07/2026): la VLAN 90 e' stata ripulita dall'infrastruttura che la occupava (management switch, UPS, server domotica, vecchi AP) ed e' oggi una vera rete ospiti con SNAT esplicito; verificato il 23/07 che la gestione dei due switch Nebula viaggia sulla VLAN nativa dei dati (classe `.10`), non sulla VLAN 90 come indicava FW-002 in una versione datata. Resta da fare la sola rimozione del DHCP server residuo sulla classe .90 lato firewall, da verificare in GUI |
| M13a | Fase A rete Wi-Fi: isolare la Wi-Fi staff esistente creando una VLAN dedicata sulle tre porte switch gia' localizzate (XGS2220-30HP porta 1, XGS2220-54HP porte 41/45), con ACL firewall verso VLAN 10 management — nessun accesso agli AP richiesto, i tre Ubiquiti EOL restano cosi' come sono | MEDIA | NET-005 | M12 | **Tentato e ripristinato il 16/07/2026** — vedi `runbook-anomalie.md` §NET-005 "Incidente 16/07/2026" per il resoconto completo. Firewall lato configurazione resta pronto e applicato (interfaccia `vlan40`+DHCP, zona `WIFI_STAFF`, security policy, pulizia 9 regole disattivate — nessuno di questo e' stato rollbackato, resta valido per un nuovo tentativo). Lato switch: le tre porte AP spostate su VLAN 40 hanno smesso di trasmettere SSID (confermato con due dispositivi diversi, nessuna rete visibile in scansione), causa non determinata (i tre AP restano inaccessibili, nessuna diagnostica lato dispositivo possibile); ripristinate a VLAN 1 e servizio confermato tornato. Ipotesi principale: l'assunzione "lo switch tagga in modo trasparente, l'AP non deve sapere nulla di VLAN" non regge per questo hardware EOL specifico. **Secondo tentativo mirato (stesso giorno)**: scoperta rilevante — la sincronizzazione Nebula-switch e' inaffidabile su un solo switch (il 54HP, dove vivono PianoPrimo/PianoSecondo), non su entrambi. Approfondito NEB-001 con `Get-NebulaConnectivityHistory.ps1` (nuovi endpoint connectivity/event-logs): nessuna disconnessione cloud rilevata, ma il 54HP mostra migliaia di link-flap non documentati sulla porta 46 (nuovo gap NET-010) mentre il 30HP (PianoTerra) risulta pulito e coerente in ogni sua operazione. Prossimo passo: diagnosticare la porta 46 prima di fidarsi di nuove scritture sul 54HP; PianoTerra resta un candidato ragionevole per un nuovo tentativo con osservazione prolungata. **CHIUSO PER DECISIONE il 22/07/2026 (ADR-014)**: l'obiettivo di questo micro-step, isolare la Wi-Fi staff dalla LAN, e' stato deliberatamente abbandonato — la staff ha oggi accesso completo alla LAN come una postazione cablata (regola portata da `deny` ad `allow`), l'isolamento resta solo sulla rete ospiti, e NET-005 diventa un rischio accettato la cui chiusura passa da M22. Il retry di Fase A non va piu' eseguito come tale; la VLAN 40 staff resta in piedi e funzionante, e cio' che si e' imparato sul canale Nebula (NEB-001, NET-010) resta valido per M22 |
| M13b | Fase B rete Wi-Fi: pianificare la sostituzione dei tre AP Ubiquiti EOL (non gestibili, credenziali perse, dashboard web mai esistita) con AP Zyxel Nebula multi-SSID, che assorbono anche la copertura guest (DPPSK + VLAN dedicata) invece di affiancare un AP guest isolato ai tre legacy | MEDIA | AP-001 | M13a | Preventivo scelto il 20/07/2026 (Punto Informatica, 3x Zyxel NWA130BE-EU0101 Wi-Fi 7, dettaglio in `runbook-anomalie.md` §AP-001); EsternoIrrigazione fuori scope; **consegna confermata: il 21/07/2026 i tre AP NWA130BE risultano registrati sull'organizzazione Nebula** con i nomi di sito "AP piano terra", "AP Piano 1" e "AP Piano 2", corrispondenti alle tre ubicazioni da sostituire (30HP porta 1, 54HP porte 41 e 45). **Installazione confermata eseguita (verifica 27/07/2026 su snapshot Nebula)**: tutti e tre gli AP Zyxel sono in servizio, non solo registrati — "AP piano terra" e' appreso sulla porta 1 del 30HP, che e' stata convertita da access a trunk e porta VLAN 1 e VLAN 40, mentre "AP Piano 1" e "AP Piano 2" sono appresi attraverso la dorsale, quindi attestati sul 54HP e online. Dei quattro AP Ubiquiti legacy nella tabella MAC resta solo l'EsternoIrrigazione (porta 4 del 30HP, fuori scope). Multi-SSID staff/guest funzionante secondo la postura di ADR-014 (staff su VLAN 40 con accesso pieno alla LAN, ospiti su VLAN 90 con SNAT e uscita sola WAN). Da chiudere: conferma definitiva della rimozione dei tre AP legacy dal Piano 2, che richiede la tabella MAC del 54HP oggi non leggibile (NEB-001), e decisione sull'EsternoIrrigazione, candidato al segmento IoT/OT di M22c |
| M13c | **Sostituzione del quarto AP Ubiquiti EOL, "EsternoIrrigazione"** (XGS2220-30HP porta 4, tetto, serve la centrale di irrigazione). Portato in scope su decisione dell'IT Manager del 28/07/2026, superando la classificazione "fuori scope" di ADR-012 e di M13b: e' l'ultimo dei quattro dispositivi con Debian 7 e Dropbear SSH aperto, quindi il rischio della classe si concentra ora su di lui. Otto sotto-passi nelle righe seguenti | ALTA | AP-001, GAP-TBC #124/SEC-018; ADR-016 | Nessuna sull'hardware; il passo 7 si coordina con M22c (segmento IoT/OT) | Da fare — nuovo filone aperto il 28/07/2026 |
| M13c-1 | Stabilire **cosa fa realmente** il dispositivo: se sia un access point che serve via Wi-Fi la centrale di irrigazione (ipotesi corrente, dal rilievo fisico "AP tetto per centrale irrigazione") oppure un ponte radio verso il tetto. Il rilievo dice che la tratta e' cablata con un patch intermedio nel locale caldaia (0-8-1 -> 0-9-1), quindi l'ipotesi ponte radio e' improbabile ma va esclusa guardando l'apparato. Esito atteso: una frase che dica chi e' il client radio e su quale banda | ALTA | `mappatura-porte-fisiche.md` (0-8-1, 0-9-1) | Accesso fisico al tetto | Da fare |
| M13c-2 | Identificare la **centrale di irrigazione** come dispositivo di rete: marca, modello, se ha una porta Ethernet oltre al Wi-Fi, come si riconfigura la sua rete (pannello fisico, app del produttore, portale cloud), e se ha bisogno di Internet o solo della LAN. Da qui dipende tutto il resto | ALTA | Nessuna fonte in repository: informazione nuova | M13c-1 | Da fare |
| M13c-3 | **Decidere l'architettura**, e la prima opzione da valutare e' l'eliminazione dell'AP: se la centrale ha una porta Ethernet e il cavo del tetto arriva dove serve, si collega via filo e l'access point sparisce, togliendo insieme un apparato EOL e un salto radio. Se invece il collegamento deve restare wireless, serve un AP per esterni (grado di protezione adeguato, non un modello da interno) con radio 2.4 GHz compatibile con la centrale | ALTA | Principio di riduzione della superficie | M13c-2 | Da decidere |
| M13c-4 | Risolvere il **problema delle credenziali radio**: l'SSID attuale e' leggibile con una scansione dal tetto, la sua passphrase no, perche' l'AP e' inaccessibile (credenziali perdute, nessuna dashboard web, solo SSH Dropbear). Ne segue che non si puo' "clonare" la rete esistente sul nuovo AP: va creata una rete nuova e **riconfigurata la centrale** con il nuovo SSID e la nuova passphrase. E' il passo che determina se l'intervento richiede il fornitore dell'impianto di irrigazione | ALTA | AP-001 (dispositivi non gestibili) | M13c-2 | Da fare |
| M13c-5 | Verificare la **tratta fisica**: la porta 4 del 30HP negozia a 100 Mbps con PoE attivo, mentre le porte delle postazioni negoziano a 1 Gbps. Va chiarito se il limite e' il vecchio AP (Fast Ethernet per eta') o la tratta stessa (patch nel locale caldaia, cavo verso il tetto con coppie danneggiate): nel secondo caso un AP nuovo resterebbe strozzato e il cavo va sistemato prima. Verifica: sostituire temporaneamente il dispositivo terminale con un portatile e leggere la velocita' negoziata, oppure leggere i contatori di errore della porta | MEDIA | Snapshot Nebula 27/07/2026 (`linkSpeed AUTO_100M` sulla porta 4) | M13c-1 | Da fare |
| M13c-6 | **Acquisto** dell'hardware scelto, con la stessa procedura di M13b (preventivo dal fornitore abituale). Solo se il passo M13c-3 conclude che serve un AP e non un cavo | MEDIA | ADR-016 | M13c-3, M13c-5 | Da fare |
| M13c-7 | **Installazione e collaudo**, in questo ordine: montare e alimentare il nuovo apparato lasciando il vecchio in servizio dove possibile; creare la rete radio nuova; riconfigurare la centrale di irrigazione; verificare che la centrale sia raggiungibile **e** che un ciclo di irrigazione parta davvero, perche' la raggiungibilita' IP non dimostra il funzionamento dell'impianto; solo dopo scollegare il vecchio AP. Non fare l'intervento in una giornata in cui l'irrigazione e' critica e non smaltire il vecchio apparato prima del collaudo, cosi' il rollback resta possibile | ALTA | Lezione di change management del 16/07 e del 23/07 | M13c-6 | Da fare |
| M13c-8 | **Collocazione nel segmento IoT/OT**: portare la porta 4 del 30HP nella VLAN 60 quando il segmento esiste, con le regole della matrice (nessun accesso verso postazioni e server, uscita Internet solo se la centrale la richiede davvero per il cloud del produttore). Fino a quel momento il dispositivo resta nella LAN piatta: mitigazione interim da valutare, l'isolamento di porta a livello switch | ALTA | NET-011/NET-009, matrice dei flussi di M22 | M13c-7, M22c | Da fare |
| M25 | **Risoluzione nomi interna: consolidamento e messa in sicurezza.** Oggi la risoluzione dei nomi interni vive interamente su due meccanismi fragili e in concorrenza: i file `hosts` mantenuti a mano su ogni postazione (sedici voci sulla sola macchina ispezionata, nessun inventario delle altre) e gli annunci in broadcast, mDNS e NetBIOS, che per costruzione non attraversano un confine di livello 3. Il firewall, che i client ricevono via DHCP come primo server DNS, ha le tabelle dei record **vuote** e lavora da puro inoltratore verso due resolver pubblici (verificato 30/07/2026). Ne segue che ogni segmentazione rompe qualcosa che oggi funziona: unita' di rete mappate per nome, destinazioni di scansione per nome NetBIOS, servizi interni annunciati in `.local`. Scopo del micro-step: decidere dove vive la zona interna (record sul firewall oppure un servizio dedicato), pubblicare i nomi sul suffisso di ADR-018, migrare i nomi `.local` (R13), ritirare le voci `hosts` a inventario completato, portare il DNS interno anche sui segmenti che oggi ricevono resolver pubblici (Wi-Fi staff), e restringere il controllo di servizio del DNS sul firewall, oggi aperto a qualunque provenienza (FW-014). Non e' prerequisito di R8 ne' della migrazione delle stampanti: e' prerequisito della **segmentazione**, perche' e' cio' che oggi tiene in piedi i riferimenti per nome | ALTA | NET-014 (#131), SEC-016 (#119), FW-014 (#132), ADR-018; interventi R12 e R13 del registro | Nessuna tecnica; conviene prima di M22e, che sposta le postazioni | Da progettare (aperto 31/07/2026 su indicazione dell'IT Manager) |
| M14 | Aggiornare le VPN IPsec da IKEv1/AES-128/SHA-1/DH2 a parametri correnti; chiarire se PSE-SEEWEB e WIZ_VPN sono transizione o residuo | MEDIA | FW-006, FW-007 | M8 | Da fare |
| M15 | Attivare firewall Proxmox con policy di default DROP | MEDIA | Fase 3 originale (roadmap storica) | M9 | Da fare |
| M16 | Dismissione HP G5 (VMware ESXi) e migrazione VM residue su Proxmox | MEDIA | GAP-TBC #10, #195 (sec-007) | Indipendente | Da fare |
| M17 | Rispondere a myOffice sul testo IVR (giorno: attesa semplice o instradamento reparti; notte: orari) e completare la migrazione centralino cloud | MEDIA | TEL-001, GAP-TBC #47 | Indipendente (traccia telefonia, non firewall) | Da fare |
| M18 | Rigenerare `output/proxmox-snapshot.json` con `Get-ProxmoxSnapshot.ps1` per fotografare lo stato Proxmox post-M5/M16 | ALTA | Fase 2 step 2 | M5, M16 | Da fare. Nota 27/07/2026: nel frattempo l'inventario e' stato riconciliato live (dieci VM, VM208 inclusa) senza rigenerare lo snapshot; il v5 sara' il primo a contenere la VM208 |
| M19 | Consolidare il diagramma Mermaid finale (`network-topology.mmd`) con lo stato post-ottimizzazione e riconciliare tutte le schede tecniche coinvolte | BASSA (fine fase) | Chiusura Fase 3 | M1-M18 | Da fare |
| M20 | Diagnosticare l'intermittenza "offline" degli switch su Nebula (rete dati funzionante, solo il canale di gestione cade): raccogliere orari degli eventi offline da Nebula e correlarli con i log del firewall (failover wan2, eventi SSL inspection sul traffico verso il cloud Zyxel) | MEDIA | NEB-001 | Nessuna (diagnosi indipendente da M1-M9) | Da fare |
| M21 | Ricontrollare M20 dopo l'esecuzione di M7 (rimozione WAN_TRUNK): se l'intermittenza sparisce, FW-008 era la causa; se persiste, approfondire l'ipotesi SSL inspection | MEDIA | NEB-001 | M7, M20 | Da fare |
| M22 | Segmentazione reale della LAN principale: oggi `lan1`/`lan1:1`/`lan1:2` (PC .10, server .20, stampanti .30) sono alias IP nella stessa `/19` flat, nessuna VLAN separata tra le tre classi. VLAN dedicate + zone/ACL firewall separate, stesso pattern collaudato sulla Wi-Fi | **ALTA — progetto strutturale dal 27/07/2026** | NET-009 (#114), NET-011 (#118), NET-005 come rischio accettato (ADR-014), scan-to-folder | Pattern Wi-Fi collaudato (VLAN 40 e 90 in produzione); indipendente dal retry di M13a, che e' chiuso per decisione | Da progettare. **Promosso da MEDIA ad ALTA il 27/07/2026**: tre evidenze indipendenti di luglio convergono su questo micro-step e non su altri — la Wi-Fi staff ha accesso pieno alla LAN per scelta (ADR-014), quindi l'unica mitigazione residua e' la segmentazione; il pilota applicativo della VM208 pubblica un identity provider su 80/443 verso l'intera `/19` (NET-011); le stampanti con scan-to-folder scrivono nelle cartelle utente dei PC (NET-009, aggiornamento 16/07). Lo scopo si allarga di conseguenza: non tre segmenti (PC/server/stampanti) ma cinque, con un segmento dedicato ai **servizi applicativi interni** dove far vivere le VM come la 208 e uno per **IoT/OT**. **Design aperto il 27/07/2026 in `docs/segmentazione-lan-m22.md`** (livello concettuale, deep-dive tecnico con matrice dei flussi e sintassi verificata sul dispositivo, piano operativo passo per passo con criterio di rollback), diagramma target versionato in `.claude/context/diagrams/segmentazione-target-m22.mmd`. Decisioni dell'IT Manager del 27/07: cinque segmenti con IoT/OT separato, primo intervento sulle stampanti usando solo switch e firewall, strategia di indirizzamento rimandata al censimento. Emerso in fase di design un sesto candidato da decidere, il segmento di gestione degli apparati. Sotto-step nelle righe seguenti |
| M22a | Censimento pre-intervento: snapshot Nebula nuovo (posteriore al 23/07 e con la tabella MAC di entrambi gli switch, oggi assente per il 30HP), lettura dalla GUI del firewall degli ambiti DHCP, delle riserve per MAC e degli oggetti indirizzo, censimento degli host con indirizzo statico o scritto a mano (NAS, file `hosts`, unita' mappate, job di backup, license server) | ALTA | Prerequisito di tutto M22; condizione posta dall'IT Manager per scegliere la strategia di indirizzamento sui numeri reali | Chiave API Nebula e accesso GUI firewall (entrambi dell'utente) | **In corso, meta' fatto (27/07/2026)**: snapshot raccolto dall'utente, censimento completo per il Piano Terra (30 porte, tabella MAC di 58 voci, prima stampante identificata sulla porta 6, undici porte libere, porta 19 residua su PVID 90) e **mancante per il Piano 2** perche' il 54HP ha risposto `DEVICE_IS_OFFLINE` sulla tabella MAC (NEB-001). Restano: tabella MAC del 54HP a switch rientrato, ambiti e riserve DHCP dalla GUI del firewall, oggetti indirizzo (pagina 2 inclusa), censimento degli host statici. Dettaglio in `docs/segmentazione-lan-m22.md` §Censimento eseguito |
| M22b-0 | Prerequisito rilevato il 28/07/2026: le code di stampa sono **dirette Standard TCP/IP per indirizzo**, nessun server di stampa e nessuna coda WSD, e sono installate per piano e non tutte su tutte le postazioni. Ne segue che il ri-puntamento e' necessario ma limitato alle code effettivamente installate, da misurare sull'inventario NinjaOne, e va fatto verso un **nome** invece che verso un indirizzo per rendere gratuiti gli spostamenti futuri. Da includere nella pulizia le porte di stampa orfane verso lo stesso indirizzo (`IP_<indirizzo>` accanto a `IP_2_<indirizzo>`), traccia di un ri-puntamento precedente. Identificate due multifunzione: Kyocera TASKalfa 2552ci su `10.61.30.10` (Piano Terra, porta 6 del 30HP) e Canon DXC 5840 su `10.61.30.133` (Piano 1, porta fisica da attribuire), entrambe verificate raggiungibili sulla porta di stampa RAW dalla classe postazioni. **Vincolo scoperto nella stessa verifica**: su questa rete mDNS funziona e le stampanti pubblicano un nome `.local`, che e' il nome sbagliato a cui puntare le code perche' il multicast non attraversa un confine di livello 3 — il ri-puntamento deve usare un nome risolvibile in unicast (voce `hosts` distribuita dall'RMM finche' non esiste un DNS interno). Nell'inventario delle code va quindi verificato anche se qualcuna punta gia' a un nome `.local` | ALTA | Rilevamento `Get-Printer`/`Get-PrinterPort` e baseline `Test-NetConnection` del 28/07/2026 | M22a | **Fatto per il rilevamento e per la baseline**, resta da estrarre l'inventario completo delle code dall'RMM |
| M22b | Primo segmento: stampanti su VLAN 30. Interfaccia e DHCP sul firewall, zona e policy della matrice (stampanti verso PC negato, SMB solo verso la share di scansione dedicata), share di scansione predisposta sul NAS *prima* dello spostamento, ID 30 aggiunto alla lista VLAN ammesse della porta 29 del 30HP, poi una porta per volta con verifica e rollback a singola porta. **Vincoli rilevati dal pannello della Kyocera il 28/07/2026**: indirizzamento statico sull'apparato (da convertire in riserva DHCP prima della migrazione, cosi' i cambi futuri sono modifiche sul firewall e non interventi sulla macchina); maschera attuale `/19` corretta, quindi nessun difetto preesistente da correggere; gateway gia' impostato sull'alias del firewall; **nessun server DNS ne' WINS configurato**, quindi le destinazioni di scansione devono essere indirizzi IP e non nomi; Bonjour attivo, da disabilitare come irrobustimento perche' dopo la segmentazione non attraversa il confine; le modifiche di rete si applicano solo dopo `Invia` **e riavvio della rete o del dispositivo**, quindi comportano una breve indisponibilita' da dichiarare; presente una funzione di filtro IP utilizzabile subito come controllo compensativo (vedi SEC-019) | ALTA | NET-009 (#114); A.8.3 e A.5.14 per il fronte scan-to-folder; SEC-019 (#125) | M22a, M3 (backup datato) | Da fare |
| M22c | Segmento IoT/OT su VLAN 60: ricognizione dei dispositivi (UPS, domotica, citofono, centrale irrigazione, sensori), in parte residui storici della VLAN 90, e migrazione con la procedura validata su M22b | MEDIA | NET-001, NET-004 | M22b | Da fare |
| M22d | Segmento servizi applicativi interni su VLAN 50, dove far vivere la VM208 e i servizi interni futuri: condivide con la DMZ il prerequisito del bridge Proxmox VLAN-aware | MEDIA | NET-011 (#118) | M4, M5 | Da fare |
| M22e | Segmenti postazioni (VLAN 10) e server (VLAN 20), ultimi per accoppiamento, e decisione sul segmento di gestione degli apparati (switch, iLO, AP), oggi promiscuo nella classe delle postazioni. Dipendono dalla strategia di indirizzamento scelta dopo il censimento; lo spostamento della gestione va fatto per ultimo e con accesso alternativo pronto (console seriale, M2) | ALTA | NET-009, SRV-003 (#108), A.9.4 | M22a, M22b, M22c | Da progettare |
| M23 | Verificare e bonificare la postura delle VM applicative: parametro `-vnc 0.0.0.0:77` nella configurazione della VM207 (accertare se la console e' effettivamente in ascolto sulla LAN e se e' protetta da password, riportarla su loopback o su accesso via interfaccia Proxmox autenticata) e rimozione dei file di credenziali in chiaro nella home dell'utente di servizio | ALTA | SRV-005 (#120) | Nessuna | Da fare (identificato 27/07/2026 nella ricognizione live) |
| M24 | Definire dove vive il codice prodotto su asset aziendali e con quali accessi: remote autorizzati, titolarita', revoca degli accessi ai repository all'uscita di un collaboratore, separazione fra ambienti di sviluppo e produzione sulle VM | MEDIA | SEC-017 (#121), A.14.2 | Nessuna (traccia di governance, non di rete) | Da fare (identificato 27/07/2026) |

## Fase 1bis - Ripresa ingestione OneDrive IT e timeline completa (SOSTANZIALMENTE COMPLETATA il 10/07/2026)

Obiettivo: completare l'ingestione della cartella OneDrive "Documenti - IT"
secondo `docs/infrastructure-timeline/ingestion-checklist.md` (riepilogo
priorita' rigenerato il 07/07/2026), estraendo in massimo dettaglio la storia
cronologica dei due anni di ristrutturazione dell'infrastruttura di rete.
Il drift della cartella e' controllato a ogni avvio di sessione da
`scripts/Check-OneDriveDelta.ps1` (hook SessionStart, baseline non versionata
in `_notes/`). Primo obiettivo: `Mappatura porte fisiche/` e la nota
PORT-TAGGING della checklist (tagging dei due switch per la migrazione al
centralino cloud, dettagli attesi dall'utente quando l'analisi arriva a quel
punto). Ordine di lavoro: voci ALTA, poi delta 23/06-07/07, poi MEDIA in
ordine cronologico delle fonti.

Fonte aggiuntiva pianificata (nota utente dell'08/07/2026): IntraLino come
progetto aziendale va caricato dalla sua documentazione Claude dedicata, che
vive su una VM; l'utente fornira' quel contesto in una sessione futura.
Fino ad allora le sezioni IntraLino gia' scritte (architettura n8n in
`2026-switch-piano-terra.md`, benchmark DoE, sezione in
`helpdesk-operations.md`) valgono come parziali, ricostruite dai soli
frammenti OneDrive, e il gap #107 (natura degli host .58/.60) resta aperto
in attesa di quella fonte.

**Stato al 10/07/2026**: coda ALTA, delta 23/06-07/07 e coda MEDIA/BASSA
chiuse. ARCHITETTURA.docx ri-estratto integralmente (sec-005/006/008/009).
MICROSOFT 365.docx, TREX.docx e STUDIO-RWS-GROUPSHARE.docx verificati:
non giustificano la stessa ri-estrazione esaustiva (vedi `current-work.md`).
Restano aperti solo i due elementi deliberatamente riservati: la nota
PORT-TAGGING (racconto a lavori conclusi) e la fonte IntraLino su VM
(sessione futura, dipende dall'utente). Nessun'altra azione autonoma
possibile su questa fase.

## Fase 3bis - Anonimizzazione repository pubblico (AVVIATA)

Il repository e' pubblico su GitHub (verificato via API il 01/07/2026). Fase A
completata il 01/07/2026: anonimizzati IP pubblici/privati, MAC address e nomi
propri nei sei file del perimetro network-design attivo (`firewall-zyxel-usg-flex-500.md`
e `-live.conf`, `network-diagram.md`, `telefono-pbx-voip.md`,
`2026-switch-piano-terra.md`, `GAP-TBC.md`), piu' `CLAUDE.md`, `STACK.md`,
`deployment.md`, `network-topology.mmd` e gli 8 diagrammi archiviati in
`context/diagrams/firewall-dmz-2026/` (stesso IP Proxmox, corretto per
contatto diretto). Convenzione documentata in `.claude/rules/anonymization.md`,
mappatura reale privata in `_notes/.anonymization-map.md` (non versionata).

Fase B, da fare: audit completo del resto del repository (SCENIA, cybersecurity,
helpdesk, timeline storica pre-2026, onboarding/offboarding) per lo stesso tipo
di dati — IP, MAC, nomi propri di dipendenti e clienti accumulati su piu'
sessioni. E' un lavoro della stessa scala dell'ingestione iniziale, da trattare
come workstream a parte, non da fare di fretta in coda a un'altra sessione.

**Priorita' alta separata dentro la Fase B (09/07/2026)**: durante un audit
di dati amministrativi/commerciali (vedi sezione dedicata in
`.claude/rules/anonymization.md`) e' emerso che `2024-infra.md` conteneva,
gia' da una sessione precedente, le ultime 4 cifre reali di una carta di
credito aziendale e un MAC address reale (rinnovo licenza Zyxel del
20/11/2024) — corretti nel file tracciato lo stesso giorno, ma ancora
presenti in un commit precedente della storia git. A differenza del resto
degli IP interni (dati di rete, rischio piu' basso e generico), questo e'
un dato di pagamento: quando si esegue la riscrittura della storia (dopo
il completamento della Fase B), questo commit va incluso esplicitamente
nel file di sostituzioni `_notes/.git-filter-replacements.txt` con
priorita' maggiore rispetto al resto.

Riscrittura della storia git: pianificata **una sola volta**, dopo che anche la
Fase B e' completa, invece che due round separati di force-push. I comandi
`git filter-repo` con il file di sostituzioni sono preparati in
`_notes/.git-filter-replacements.txt` (non versionato, da estendere durante la
Fase B) e vanno eseguiti dall'utente, mai dall'agente: e' un'operazione che
riscrive quasi tutta la storia del repository (il valore piu' vecchio risale
al secondo commit del progetto) e richiede force-push coordinato.

**Deroga puntuale (17/07/2026, ADR-011)**: la voce Fibercop/Referente-Fibercop-1 e'
uscita dal round unico per richiesta esterna del CIRST Fibercop e va
eseguita come round di riscrittura storia a se', prima del resto della
Fase B. Non re-includerla nel round finale, e' gia' rimossa a parte.

## Fase 4 - Piano interventi futuri residui (DA PIANIFICARE)

Steps non coperti dalla Fase 3, da pianificare dopo la chiusura dei micro-step
sopra:
1. Patch management documentato (Proxmox, switch Nebula, firewall, NAS firmware)
2. Procedure backup e disaster recovery formali
3. Inventario sistematico NAS fleet (RAID, capacita', firmware)
4. Ripresa dell'ingestione della cartella OneDrive IT (sospesa su richiesta
   esplicita dell'utente per dare priorita' alla Fase 3; vedi nota di
   riallineamento in `ingestion-checklist.md`)

## Fase 5 - Documentazione ISO27001 operativa (DA PIANIFICARE)

**Obiettivo dichiarato dall'utente il 16/07/2026: ottenere la certificazione
ISO27001 entro marzo 2027.** Da questa data in avanti, ogni micro-step di
rete (non solo quelli esplicitamente etichettati Fase 5) va letto anche
con l'angolo ISO27001 quando rilevante — un gap di segmentazione, un
controllo di accesso, un flusso dati non presidiato sono materiale
Annex A a prescindere da quando la Fase 5 formale comincia. Vedi
`current-work.md` per la direttiva permanente sui cinque livelli di
tracciamento richiesti a ogni passo.

Steps:
1. Statement of Applicability per i controlli Annex A di rete
2. Risk assessment per i gap identificati (A.8.20, A.8.22, A.8.16, A.5.37, A.8.8)
3. Procedure operative per interventi ricorrenti (backup, patching, accessi VPN)
4. Incident response per scenari rilevanti (basato su evento phishing 08/01/2026)

## Stato riepilogativo

| Fase | Stato | Priorita' |
|---|---|---|
| Fase 0 | COMPLETATA | Alta |
| Fase 1 | COMPLETATA | Alta |
| Fase 2 | COMPLETATA il 10/07/2026 (NAS fleet e gap analysis ISO27001 Annex A chiusi) | Alta |
| Fase 1bis | Sostanzialmente completata il 10/07/2026 — residuano solo nota PORT-TAGGING e fonte IntraLino su VM (entrambe in attesa dell'utente) | Alta |
| Fase 3 | Attiva dal 27/07/2026 — 30 micro-step tracciati; M1 chiuso, M2/M11/M12 parziali, M13a chiuso per decisione (ADR-014), M13b con hardware consegnato e da installare; **M22 e' il filone attivo, con design aperto e cinque sotto-step M22a-M22e**; M23/M24 nuovi dalla ricognizione VM | Critica |
| Fase 4 | Da pianificare | Media |
| Fase 5 | Da pianificare | Media |
