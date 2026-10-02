# Roadmap operativa ISO 27001 della rete

> File generato da `data/iso27001-interventi.json` con `python scripts/IsoRoadmap.py build`. Non modificare questa vista a mano.

Fotografia iniziale: 2026-09-28. Ultimo avanzamento registrato: 2026-10-02. Obiettivo di progetto: marzo 2027. Le scadenze delle fasi sono proposte operative, non attestazioni di conformita'.

## Come si usa

- Aprire questa lista per scegliere il prossimo intervento. Ogni voce specifica azione, prova di chiusura, responsabile, dipendenze e fornitura.
- **Stati:** da fare = non iniziato; in corso = avviato ma senza prova di chiusura; bloccato = in attesa di un prerequisito; completato = chiuso con evidenza datata; non applicabile = esclusione motivata.
- **Forniture:** necessaria = serve un acquisto o servizio; condizionata = solo se diagnosi o decisione lo richiedono; da verificare = controllare prima se esiste gia'; nessuna = non prevista.
- Per ogni avanzamento comunicato o realizzato, l'agente aggiorna il registro nella stessa sessione: azione, stato, fornitura e nota datata. Il comando `advance` rigenera questa vista nel progetto, senza richiedere azioni all'utente.
- L'HTML e' una copia di sola lettura: si esporta solo su richiesta con `python scripts/IsoRoadmap.py build --desktop`, che aggiorna insieme Desktop e cartella ISO OneDrive configurata privatamente. Puo' essere piu' vecchio del registro; non va modificato a mano.
- Nell'HTML le sigle aprono una vista interna allo stesso file. Le spiegazioni vivono in `data/iso27001-glossario.json`; quelle dei controlli ISO sono parafrasi operative, non il testo della norma.
- Una voce si chiude solo con una prova datata (`--evidenza`); non trascrivere dati reali o segreti nel registro pubblico.
- Cambiamenti fisici non ancora comunicati o misurabili non possono essere rilevati dal registro: in quel caso la voce resta da verificare fino a sopralluogo o evidenza.
- Prima del commit manuale eseguire `python scripts/IsoRoadmap.py check`, `python scripts/Test-Anonymization.py` e `python tools/md-unwrap.py --check .`.

## Stato del programma

- Interventi: **47**; da fare 35, in corso 12, bloccati 0, completati 0, non applicabili 0.
- Forniture: **1 necessarie**, 12 condizionate da diagnosi o decisione, 2 da verificare. Le etichette indicano una necessita' tecnica o di servizio, non un acquisto autorizzato.
- Le configurazioni di firewall, il ripristino dei backup e l'indipendenza elettrica richiedono ancora prove dirette; la riconciliazione della mappa non li certifica.
- La checklist ISO locale conta 93 controlli ma non contiene prove compilate; lo Statement of Applicability va riconciliato con misure e documenti datati.

## Forniture e decisioni di approvvigionamento

### Fornitura necessaria

- **ISO-47 - Audit di certificazione:** Servizio dell'organismo di certificazione accreditato per audit Stage 1 e Stage 2. Decisione: Richiedere proposta su ambito approvato e calendario realistico.

### Fornitura condizionata

- **ISO-08 - Diagnosi del NAS principale dei backup:** NAS sostitutivo preventivato; dischi, NIC, firmware o assistenza solo se la diagnosi identifica il componente da sostituire. Decisione: Confrontare capacita', ritenzione e ripristino prima di qualsiasi ordine o migrazione.
- **ISO-11 - Copertura e cifratura della copia fuori sede:** Capacita' o servizio cloud aggiuntivo solo se la misura dimostra che il piano attuale non copre il perimetro approvato. Decisione: Definire prima perimetro e ritenzione.
- **ISO-21 - Segmenti postazioni, server e management:** Eventuali porte gestite o apparati aggiuntivi soltanto se il censimento delle porte mostra insufficienza. Decisione: Usare la capacita' esistente prima di acquistare.
- **ISO-25 - VPN moderne e failover WAN:** Intervento del fornitore di connettivita' se le modifiche ai peer o al failover non sono gestibili internamente. Decisione: Confermare responsabilita' e condizioni del servizio.
- **ISO-27 - Patch e configurazioni di riferimento:** Licenze di supporto o sostituzioni hardware solo per prodotti fuori supporto accertati dall'inventario. Decisione: Aprire proposta distinta per ogni asset non aggiornabile.
- **ISO-28 - Remediation del vulnerability assessment:** Riscansione o consulenza esterna se gli strumenti interni non possono verificare i rimedi. Decisione: Definire perimetro della verifica prima dell'incarico.
- **ISO-29 - Cifratura endpoint e dispositivo personale in RMM:** Licenze MDM o altra gestione di conformita' solo dopo scelta del requisito di controllo centralizzato. Decisione: Confrontare il requisito con le funzioni RMM gia' disponibili.
- **ISO-30 - Log e allarmi di rete e infrastruttura:** VM e spazio di archiviazione da dimensionare dopo misura dei volumi; eventuali schede SNMP UPS solo se necessarie ai requisiti di allarme. Decisione: Verificare capacita' Proxmox e NAS e misurare volumi e ritenzione prima di acquistare.
- **ISO-32 - Indipendenza delle alimentazioni del server:** Intervento elettrico o distribuzione di alimentazione solo se le due sorgenti risultano comuni. Decisione: Sopralluogo al retro dell'armadio.
- **ISO-33 - Licenze di sicurezza e gestione apparati:** Rinnovo di licenze soltanto alla scadenza confermata dal pannello; nessun nuovo acquisto dedotto dalla vecchia pendenza AP. Decisione: Risolvere lo scostamento fra le letture del 09 e 10/09/2026.
- **ISO-44 - Revisione accessi e formazione:** Formazione esterna solo se il programma interno non copre le competenze richieste. Decisione: Valutare competenze e materiale esistenti.
- **ISO-45 - Audit interno indipendente:** Auditor esterno se non esiste una persona interna sufficientemente indipendente e competente. Decisione: Verificare indipendenza e competenza prima dell'incarico.

### Fornitura da verificare

- **ISO-17 - CA interna e HTTPS del gestore password:** Disponibilita' di un supporto rimovibile dedicato e custodito per la chiave CA. Decisione: Usare un supporto esistente idoneo o procurarne uno.
- **ISO-31 - UPS dello switch Piano Terra:** UPS dimensionato sul carico reale e possibile scheda SNMP; verificare se l'unita' prevista sia stata gia' acquistata. Decisione: Confermare disponibilita' prima di ordinare.

## Elenco dettagliato

### 1. Esposizioni e ripristino - entro due settimane

- **ISO-01 | HTTPS del portale GroupShare** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Installare certificato pubblico e binding TLS; provare l'accesso interno ed esterno; reindirizzare HTTP senza togliere l'accesso ai collaboratori.
  - **Chiusura verificabile:** Connessione TLS valida da due reti, credenziali non trasmesse in HTTP, rinnovo del certificato provato.
  - **Responsabile:** IT Manager e gestore del servizio. **Dipendenze:** nessuna. **Controlli:** A.8.24, A.8.21.
  - **Fonti:** GAP-TBC #117, docs/risoluzione-nomi-interni.md.
  - **Ultimo stato (2026-09-28):** Il portale risulta ancora servito in chiaro secondo la misura del 03/09/2026.

- **ISO-02 | Accesso Internet al firewall** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Leggere i servizi delle regole WAN verso l'apparato, preparare accesso di recupero, limitare la GUI alle origini amministrative e la VPN a portale alle provenienze necessarie.
  - **Chiusura verificabile:** Prove da origini ammesse e negate, log, screenshot della policy e rollback collaudato.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.2, A.8.20, A.5.15.
  - **Fonti:** GAP-TBC #193.
  - **Ultimo stato (2026-09-28):** L'avviso del firewall e' misurato; il contenuto preciso del gruppo servizi va riletto in GUI.

- **ISO-03 | Desktop remoto dalla rete ospiti** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Verificare uso e motivo della regola, poi eliminarla o limitarla a sorgente e destinazione esplicite; correggere l'ordine rispetto al diniego.
  - **Chiusura verificabile:** Tentativo RDP dalla rete ospiti negato salvo eventuale eccezione approvata e circoscritta.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.22, A.8.20.
  - **Fonti:** GAP-TBC #194, docs/interventi-robustezza.md R21.

- **ISO-04 | Firewall della VM Windows 100** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Inventariare i flussi in uso e le eccezioni, quindi attivare gradualmente Windows Firewall sui tre profili e limitare RDP, amministrazione e condivisioni.
  - **Chiusura verificabile:** Servizi aziendali funzionanti e connessioni non autorizzate negate da una postazione di prova.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.20, A.8.9.
  - **Fonti:** docs/esposizione-servizi-interni.md sezione VM 100, GAP-TBC #175.

- **ISO-05 | Database della VM 209** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Cambiare la pubblicazione del contenitore PostgreSQL da tutte le interfacce al solo loopback; verificare che l'applicazione continui a connettersi.
  - **Chiusura verificabile:** Connessione applicativa riuscita e porta del database non raggiungibile dalla LAN.
  - **Responsabile:** Responsabile applicativo. **Dipendenze:** nessuna. **Controlli:** A.8.3, A.8.20.
  - **Fonti:** docs/esposizione-servizi-interni.md sezione VM 209.

- **ISO-06 | Servizio Ollama esposto alla LAN** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Togliere l'ascolto dell'istanza non autenticata dalla LAN o metterla dietro un accesso autenticato e ristretto.
  - **Chiusura verificabile:** Client applicativo autorizzato funziona; host non autorizzato non raggiunge l'API.
  - **Responsabile:** Responsabile del servizio. **Dipendenze:** nessuna. **Controlli:** A.8.3, A.8.20.
  - **Fonti:** docs/esposizione-servizi-interni.md sezione host Ollama, GAP-TBC #173.

- **ISO-07 | Credenziali e accessi amministrativi delle VM** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Censire password condivise e SSH con password, assegnare credenziali individuali o chiavi, eliminare file di credenziali in chiaro e rivedere VNC/RDP aperti.
  - **Chiusura verificabile:** Matrice accessi approvata, vecchie credenziali revocate, test degli accessi consentiti e negati.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.5.16, A.5.17, A.8.2.
  - **Fonti:** docs/esposizione-servizi-interni.md, GAP-TBC #120, #170, #172.

- **ISO-08 | Diagnosi del NAS principale dei backup** - **Da fare**; FORNITURA CONDIZIONATA. NAS sostitutivo preventivato; dischi, NIC, firmware o assistenza solo se la diagnosi identifica il componente da sostituire.
  - **Azione:** Leggere RAID, dischi, carico, firmware, SMB, negoziazione e aggregazione delle due NIC; ripetere le misure prima e dopo il rimedio.
  - **Chiusura verificabile:** Causa documentata e throughput di lettura/scrittura e durata dei backup nuovamente misurati.
  - **Responsabile:** IT Manager e fornitore NAS. **Dipendenze:** nessuna. **Controlli:** A.8.13, A.8.6.
  - **Fonti:** GAP-TBC #204, docs/pendenze-aperte.md.
  - **Ultimo stato (2026-09-30):** 30/09: causa del deposito NAS ancora da misurare sul pannello. Il preventivo del 22/09 propone un NAS rack a quattro dischi e porte multigigabit, ma non prova acquisto o messa in servizio; non sostituisce la diagnosi. Restano le misure 10,5 MB/s in scrittura e 15,8 MB/s in lettura.
  - **Evidenza:** Preventivo fornitore 22/09/2026 nella libreria amministrativa; GAP-TBC #204

- **ISO-09 | Collisione e allarmi dei dieci backup VM** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Correggere il job della VM 207 che fallisce per timeout del lock: verificare e impostare l'attesa sui tre job aggiunti per 207, 208 e 209, oggi privi di lockwait=1440; poi spostare il job della VM 208 dalle 04:30, mantenendo frequenza giornaliera e destinazioni. Aggiungere soglie per fallimento, durata, mancata partenza, spazio e fine oltre la finestra concordata.
  - **Chiusura verificabile:** Sette notti con dieci esiti OK, nessuna collisione, fine entro la finestra concordata e prova di ricezione dell'allarme di degrado.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.13, A.8.16.
  - **Fonti:** GAP-TBC #200, #203, #204, docs/pendenze-aperte.md.
  - **Ultimo stato (2026-09-30):** 30/09: letti i task Proxmox delle ultime tre notti. Nove job OK su dieci; il job VM 207 delle 03:45 fallisce ogni notte per timeout del lock. I tre job aggiunti per 207, 208 e 209 non hanno lockwait=1440, presente sugli altri sette. Ultimo job alle 08:15, doppia partenza alle 04:30 ancora presente. Correggere configurazione e misurare sette notti.
  - **Evidenza:** API task Proxmox 28-30/09/2026; snapshot Proxmox 30/09/2026; docs/business-continuity-disaster-recovery.md

- **ISO-10 | Prove di ripristino VM e documenti** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Ripristinare una VM piccola cronometrando; avviare la verifica di integrita' dei lavori NAS e recuperare un campione locale e fuori sede.
  - **Chiusura verificabile:** Verbale con dati aperti, tempi effettivi, errori e azioni correttive.
  - **Responsabile:** IT Manager e responsabili dei dati. **Dipendenze:** nessuna. **Controlli:** A.8.13, A.5.30.
  - **Fonti:** docs/business-continuity-disaster-recovery.md, GAP-TBC #192, #204.

- **ISO-11 | Copertura e cifratura della copia fuori sede** - **In corso**; FORNITURA CONDIZIONATA. Capacita' o servizio cloud aggiuntivo solo se la misura dimostra che il piano attuale non copre il perimetro approvato.
  - **Azione:** Verificare completamento del caricamento a Milano e anni coperti; definire la copertura mancante; valutare cifratura lato client insieme alla custodia della chiave.
  - **Chiusura verificabile:** Elenco delle cartelle coperte, ripristino campione e decisione approvata sulla cifratura.
  - **Responsabile:** IT Manager e RSGSI. **Dipendenze:** nessuna. **Controlli:** A.8.13, A.8.24, A.5.23.
  - **Fonti:** GAP-TBC #192, data/scadenze.json.
  - **Ultimo stato (2026-09-28):** Esiste una sola copia fuori sede misurata; copertura e integrita' non sono ancora dimostrate.

- **ISO-12 | Chiave precondivisa del tunnel verso il fornitore** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Concordare una finestra con il peer, ruotare la chiave di eta' ignota e verificare il ristabilimento del tunnel.
  - **Chiusura verificabile:** Nuova chiave attiva su entrambi i peer, vecchia revocata e test dei servizi sul tunnel.
  - **Responsabile:** IT Manager e fornitore hosting. **Dipendenze:** nessuna. **Controlli:** A.5.17, A.8.21.
  - **Fonti:** GAP-TBC #138, roadmap M14.

- **ISO-13 | Vecchie configurazioni e segreti sincronizzati** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Dopo la rotazione, censire le copie storiche di configurazione, spostarle in deposito protetto o cifrarle e limitare gli accessi alla libreria.
  - **Chiusura verificabile:** Inventario delle copie, permessi verificati e nessuna credenziale ancora attiva nei file esposti.
  - **Responsabile:** IT Manager. **Dipendenze:** ISO-12. **Controlli:** A.5.17, A.8.24.
  - **Fonti:** GAP-TBC #138, docs/pendenze-aperte.md.

### 2. Segmentazione e accessi - ottobre-novembre 2026

- **ISO-14 | Chiusura delle vecchie destinazioni di scansione** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Verificare che la credenziale NAS sia permanente sulle sette postazioni, rimuovere le vecchie share dei PC e le credenziali memorizzate nelle multifunzione.
  - **Chiusura verificabile:** Scansioni verso tutte le destinazioni NAS riuscite e vecchie condivisioni non piu' utilizzabili.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.5.14, A.8.3.
  - **Fonti:** docs/interventi-robustezza.md R8, R9, GAP-TBC #126.
  - **Ultimo stato (2026-09-28):** Nuove share e rubriche sono state provate; restano rimozione delle vecchie share e verifica della persistenza.

- **ISO-15 | Hardening delle multifunzione** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Cambiare credenziali di fabbrica, limitare l'amministrazione, disabilitare servizi inutili, richiedere conferma destinatario e convertire gli indirizzi a riserve DHCP.
  - **Chiusura verificabile:** Stampa e scansione funzionanti dopo ogni modifica; accesso amministrativo negato dalle postazioni non IT.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.9, A.8.20.
  - **Fonti:** docs/interventi-robustezza.md R1-R7, R11, GAP-TBC #125.

- **ISO-16 | DNS interno su endpoint e Wi-Fi staff** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Distribuire le impostazioni verificate alle 24 postazioni; aggiungere la regola dalla Wi-Fi staff verso il solo DNS del firewall prima di cambiare il DHCP.
  - **Chiusura verificabile:** Nomi interni risolti da cavo e Wi-Fi staff; rete ospiti esclusa; servizi raggiungibili.
  - **Responsabile:** IT Manager e gestore RMM. **Dipendenze:** nessuna. **Controlli:** A.8.21, A.8.22.
  - **Fonti:** docs/interventi-robustezza.md R12, R20, docs/risoluzione-nomi-interni.md.
  - **Ultimo stato (2026-09-28):** Diciassette record verificati su una postazione; distribuzione e regola Wi-Fi da confermare.

- **ISO-17 | CA interna e HTTPS del gestore password** - **Da fare**; FORNITURA DA VERIFICARE. Disponibilita' di un supporto rimovibile dedicato e custodito per la chiave CA.
  - **Azione:** Generare la chiave CA fuori linea con passphrase, distribuire la sola radice, emettere il certificato e configurare Apache sulla 443 con rinvio da HTTP.
  - **Chiusura verificabile:** Accesso TLS senza avvisi, rinnovo e revoca documentati, chiave privata assente dalla rete.
  - **Responsabile:** IT Manager e RSGSI. **Dipendenze:** ISO-16. **Controlli:** A.8.24, A.5.17.
  - **Fonti:** docs/autorita-certificazione-interna.md, docs/esposizione-servizi-interni.md.

- **ISO-18 | Primo segmento: stampanti VLAN 30** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Completare matrice dei flussi e code; configurare gateway, DHCP e policy; ammettere VLAN 30 su entrambi i trunk previsti; migrare una porta per volta con rollback.
  - **Chiusura verificabile:** Stampa e scansione riuscite, SMB solo verso NAS dedicato, traffico stampanti verso PC negato.
  - **Responsabile:** IT Manager. **Dipendenze:** ISO-14, ISO-15, ISO-16. **Controlli:** A.8.22, A.8.20.
  - **Fonti:** docs/segmentazione-lan-m22.md, roadmap M22b.

- **ISO-19 | Ramo esterno e segmento IoT/OT VLAN 60** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Censire inverter, irrigazione, controllo presenze, UPS e AP; documentare la centralina via Wi-Fi sul WBE530 e l'inverter sulla seconda porta Ethernet dell'AP; verificare l'alimentazione dell'AP; progettare VLAN 60 e policy mirate senza ordinare uno switch per questa tratta.
  - **Chiusura verificabile:** Collegamenti fisici e radio verificati, inventario apparati, alimentazione AP nota, ciclo reale d'irrigazione e flussi non autorizzati negati.
  - **Responsabile:** IT Manager e fornitore rete. **Dipendenze:** ISO-18. **Controlli:** A.8.22, A.7.8.
  - **Fonti:** correzione IT Manager 28/09/2026, roadmap M13c-10, M22c, docs/mappatura-porte-fisiche.md.
  - **Ultimo stato (2026-09-28):** Correzione IT Manager 28/09/2026: centralina via Wi-Fi del WBE530; inverter sulla seconda porta Ethernet dell'AP. Il GS-105B non e' nel percorso attivo. Fornitura dello switch annullata; da verificare alimentazione AP, presenza fisica residua del GS-105B e segmentazione VLAN 60.

- **ISO-20 | Segmento dei servizi applicativi VLAN 50** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Rendere VLAN-aware il bridge previsto senza spostare i cavi; migrare VM 208 e servizi interni con policy e rollback per macchina.
  - **Chiusura verificabile:** Servizi raggiungibili dagli utenti autorizzati e movimenti laterali non autorizzati negati.
  - **Responsabile:** IT Manager e responsabili applicativi. **Dipendenze:** ISO-16, ISO-18. **Controlli:** A.8.22.
  - **Fonti:** roadmap M22d, docs/virtualizzazione-proxmox-e-bridge.md.

- **ISO-21 | Segmenti postazioni, server e management** - **Da fare**; FORNITURA CONDIZIONATA. Eventuali porte gestite o apparati aggiuntivi soltanto se il censimento delle porte mostra insufficienza.
  - **Azione:** Decidere il segmento gestione; migrare postazioni e server dopo il censimento degli statici; spostare la gestione switch/iLO per ultima con console alternativa pronta.
  - **Chiusura verificabile:** Matrice dei flussi soddisfatta, servizi invariati e gestione accessibile solo da postazioni IT.
  - **Responsabile:** IT Manager. **Dipendenze:** ISO-18, ISO-19, ISO-20. **Controlli:** A.8.22, A.8.2.
  - **Fonti:** roadmap M22e, docs/segmentazione-lan-m22.md.

- **ISO-22 | DHCP Guard e pulizia delle porte switch** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Attivare protezioni livello 2 per segmento, fidandosi solo dei trunk DHCP legittimi; correggere porte 19 e 21 del 30HP e restringere le VLAN delle porte fonia dopo il riscontro fisico.
  - **Chiusura verificabile:** DHCP legittimo funziona, risposta di server abusivo scartata, porte campione coerenti con la matrice.
  - **Responsabile:** IT Manager. **Dipendenze:** ISO-18. **Controlli:** A.8.20.
  - **Fonti:** GAP-TBC #122, #123, #134, #143, docs/pendenze-aperte.md.

- **ISO-23 | DMZ e prima pubblicazione controllata** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Usare il bridge su switch gestito indicato dalla ricognizione; applicare VLAN 201, policy di ingresso e uscita, poi pubblicare il primo proxy in finestra reversibile.
  - **Chiusura verificabile:** Servizio esterno raggiungibile, DMZ verso LAN negato salvo flussi dichiarati e rollback provato.
  - **Responsabile:** IT Manager e responsabile applicativo. **Dipendenze:** ISO-20. **Controlli:** A.8.22, A.8.20.
  - **Fonti:** roadmap M4-M9, docs/virtualizzazione-proxmox-e-bridge.md.

- **ISO-24 | Firewall Proxmox con regole efficaci** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Definire regole per host, bridge e VM, provarle su una macchina pilota e solo dopo attivare policy predefinita di blocco.
  - **Chiusura verificabile:** Flag firewall e regole realmente applicati; flussi autorizzati vivi e tentativi negati registrati.
  - **Responsabile:** IT Manager. **Dipendenze:** ISO-23. **Controlli:** A.8.20, A.8.22.
  - **Fonti:** roadmap M15, docs/virtualizzazione-proxmox-e-bridge.md.

- **ISO-25 | VPN moderne e failover WAN** - **Da fare**; FORNITURA CONDIZIONATA. Intervento del fornitore di connettivita' se le modifiche ai peer o al failover non sono gestibili internamente.
  - **Azione:** Pianificare IKEv2 e parametri correnti, chiarire profili duplicati, rivedere rotte e interfacce obsolete dopo backup configurazione e prova di failover.
  - **Chiusura verificabile:** Tunnel ristabiliti e servizi operativi con ciascuna tratta di riserva testata.
  - **Responsabile:** IT Manager e fornitori di connettivita'. **Dipendenze:** ISO-12. **Controlli:** A.8.21, A.8.14.
  - **Fonti:** roadmap M14, M7, GAP-TBC FW-004, FW-006, FW-007.

- **ISO-26 | Revisione delle policy Wi-Fi staff e guest** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Dopo la segmentazione, sostituire l'accesso pieno della Wi-Fi staff con la matrice dei flussi; verificare isolamento ospiti e DNS separato.
  - **Chiusura verificabile:** Test da staff e ospiti verso servizi consentiti e vietati, con log del firewall.
  - **Responsabile:** IT Manager. **Dipendenze:** ISO-21. **Controlli:** A.8.22, A.8.20.
  - **Fonti:** docs/segmentazione-lan-m22.md, ADR-014, GAP-TBC #194.

### 3. Controlli ripetibili - dicembre 2026-gennaio 2027

- **ISO-27 | Patch e configurazioni di riferimento** - **In corso**; FORNITURA CONDIZIONATA. Licenze di supporto o sostituzioni hardware solo per prodotti fuori supporto accertati dall'inventario.
  - **Azione:** Censire versioni di firewall, switch, AP, NAS, Proxmox e VM; fissare finestre, priorita', eccezioni e verifica post aggiornamento.
  - **Chiusura verificabile:** Registro aggiornamenti con asset, versione precedente e nuova, esito e prossima revisione.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.8, A.8.9, A.8.32.
  - **Fonti:** docs/vendor-management.md, docs/design-and-security.md, roadmap Fase 4.
  - **Ultimo stato (2026-09-29):** Conferma IT Manager 29/09: server VA storico del gestionale ritirato dopo migrazione; snapshot Proxmox odierno coerente con assenza del vecchio guest. VM 810 TESTNEWEGETRADBOOT e successore candidato da verificare via SSH e prossimo censimento.

- **ISO-28 | Remediation del vulnerability assessment** - **In corso**; FORNITURA CONDIZIONATA. Riscansione o consulenza esterna se gli strumenti interni non possono verificare i rimedi.
  - **Azione:** Attribuire i 174 interventi VA a asset, responsabile, priorita' e scadenza; verificare prima critici e alti con una nuova prova mirata.
  - **Chiusura verificabile:** Ogni chiusura ha output o verbale; i rilievi critici e alti sono riprovati.
  - **Responsabile:** RSGSI e IT Manager. **Dipendenze:** nessuna. **Controlli:** A.8.8, A.5.36.
  - **Fonti:** docs/vulnerability-assessment-nov2025.md, docs/design-and-security.md.
  - **Ultimo stato (2026-09-29):** Perimetro VA aggiornato: escluso il vecchio host del gestionale, ritirato dopo migrazione (conferma IT Manager 29/09). Non trasferire i plugin Ubuntu/Tomcat al successore. VM 810 TESTNEWEGETRADBOOT e successore candidato; accesso SSH odierno non verificato, quindi serve censimento del nuovo sistema prima della chiusura.

- **ISO-29 | Cifratura endpoint e dispositivo personale in RMM** - **Da fare**; FORNITURA CONDIZIONATA. Licenze MDM o altra gestione di conformita' solo dopo scelta del requisito di controllo centralizzato.
  - **Azione:** Misurare cifratura, TPM, protezioni e chiavi per dispositivo; definire trattamento del PC personale gestito dall'RMM e delle eccezioni.
  - **Chiusura verificabile:** Esportazione datata per la flotta e decisione documentata sui dispositivi fuori criterio.
  - **Responsabile:** IT Manager e RSGSI. **Dipendenze:** nessuna. **Controlli:** A.8.1, A.5.9.
  - **Fonti:** docs/design-and-security.md, GAP-TBC #113.

- **ISO-30 | Log e allarmi di rete e infrastruttura** - **In corso**; FORNITURA CONDIZIONATA. VM e spazio di archiviazione da dimensionare dopo misura dei volumi; eventuali schede SNMP UPS solo se necessarie ai requisiti di allarme.
  - **Azione:** Definire eventi, soglie, destinatari e ritenzione per firewall, switch, VPN, Proxmox, NAS e UPS; generare un evento di prova per categoria.
  - **Chiusura verificabile:** Evento ricevuto, letto e preso in carico entro il tempo stabilito.
  - **Responsabile:** IT Manager e RSGSI. **Dipendenze:** nessuna. **Controlli:** A.8.15, A.8.16.
  - **Fonti:** docs/design-and-security.md, GAP-TBC #200, docs/log-collector-integrazione.md.
  - **Ultimo stato (2026-10-02):** Collettore dei log AdS in servizio: VM 210 ads-collector creata il 01/10/2026 e misurata nello snapshot del 02/10; sorgenti host Proxmox (TLS 6514) e firewall USG FLEX (syslog 514) collaudate il 02/10 con login riusciti e falliti; restano NAS, custodia esterna della prova e analisi
  - **Evidenza:** docs/log-collector-integrazione.md

- **ISO-31 | UPS dello switch Piano Terra** - **Da fare**; FORNITURA DA VERIFICARE. UPS dimensionato sul carico reale e possibile scheda SNMP; verificare se l'unita' prevista sia stata gia' acquistata.
  - **Azione:** Misurare carico dello switch incluso budget PoE, verificare se l'UPS previsto e' gia' disponibile, installarlo e provarne l'autonomia.
  - **Chiusura verificabile:** Switch, telefoni e AP del piano restano alimentati nel test controllato; autonomia registrata.
  - **Responsabile:** IT Manager e fornitore elettrico. **Dipendenze:** nessuna. **Controlli:** A.7.11, A.8.14.
  - **Fonti:** GAP-TBC #148, docs/livello-fisico-ed-elettrico.md.

- **ISO-32 | Indipendenza delle alimentazioni del server** - **Da fare**; FORNITURA CONDIZIONATA. Intervento elettrico o distribuzione di alimentazione solo se le due sorgenti risultano comuni.
  - **Azione:** Rilevare la presa di PS1 e PS2, verificare se arrivano a sorgenti distinte e correggere il cablaggio solo dopo la misura.
  - **Chiusura verificabile:** Schema elettrico firmato e prova controllata delle due sorgenti.
  - **Responsabile:** IT Manager e fornitore elettrico. **Dipendenze:** nessuna. **Controlli:** A.7.11, A.8.14.
  - **Fonti:** GAP-TBC #202, docs/livello-fisico-ed-elettrico.md.

- **ISO-33 | Licenze di sicurezza e gestione apparati** - **In corso**; FORNITURA CONDIZIONATA. Rinnovo di licenze soltanto alla scadenza confermata dal pannello; nessun nuovo acquisto dedotto dalla vecchia pendenza AP.
  - **Azione:** Rileggere pannello Nebula e Gold Security Pack, riconciliare date discordanti e assegnare responsabile e preavviso per ogni rinnovo.
  - **Chiusura verificabile:** Schermate datate, registro scadenze corretto e servizi di sicurezza attivi verificati.
  - **Responsabile:** IT Manager e fornitore licenze. **Dipendenze:** nessuna. **Controlli:** A.5.22, A.8.20.
  - **Fonti:** data/scadenze.json, ADR-022.
  - **Ultimo stato (2026-09-28):** La misura del 10/09 indica l'AP esterno licenziato; alcune date lette il giorno prima divergono.

- **ISO-34 | Esercitazione di continuita' operativa** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Concordare RTO e RPO per servizio, simulare perdita NAS, VM, connettivita' e alimentazione, aggiornare runbook con i tempi reali.
  - **Chiusura verificabile:** Verbali di prova, deviazioni dai tempi attesi e azioni correttive assegnate.
  - **Responsabile:** RSGSI e responsabili di servizio. **Dipendenze:** ISO-10, ISO-31, ISO-32. **Controlli:** A.5.29, A.5.30.
  - **Fonti:** docs/business-continuity-disaster-recovery.md.

- **ISO-35 | Inventario fisico ed elettrico completo** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Chiudere censimento di NAS, inverter, switch non gestiti, UPS, prese, porte a 10 Mb/s e apparati residui; riconciliare mappa e sopralluogo.
  - **Chiusura verificabile:** Inventario con proprietario, funzione, posizione, alimentazione e data di verifica per ogni apparato.
  - **Responsabile:** IT Manager. **Dipendenze:** nessuna. **Controlli:** A.5.9, A.7.8, A.7.12.
  - **Fonti:** docs/pendenze-aperte.md, docs/livello-fisico-ed-elettrico.md.
  - **Ultimo stato (2026-09-28):** Mappa strutturata disponibile; restano verifiche sul posto e apparati non censiti.

### 4. Sistema di gestione e audit - da avviare subito; chiusura entro marzo 2027

- **ISO-36 | Perimetro del sistema di gestione** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Confermare servizi, sedi, rete, VM, SaaS, fornitori, interfacce ed esclusioni, assegnando un responsabile a ogni confine.
  - **Chiusura verificabile:** Documento di ambito approvato dalla direzione e coerente con asset e contratti.
  - **Responsabile:** Direzione e RSGSI. **Dipendenze:** nessuna. **Controlli:** 4.3, 4.4.
  - **Fonti:** docs/business-continuity-disaster-recovery.md sezione PSGSI, ISO/IEC 27001:2022.
  - **Ultimo stato (2026-09-28):** La PSGSI del 2025 dichiara un ambito; va riconciliato con servizi e fornitori attuali.

- **ISO-37 | Contesto, parti interessate e clima** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Aggiornare dipendenze da fornitori, energia, meteo, connettivita' e dati dei clienti; registrare se il cambiamento climatico e' rilevante per l'ambito.
  - **Chiusura verificabile:** Analisi approvata con bisogni delle parti interessate e decisione motivata sul clima.
  - **Responsabile:** Direzione e RSGSI. **Dipendenze:** ISO-36. **Controlli:** 4.1, 4.2.
  - **Fonti:** ISO/IEC 27001:2022/Amd 1:2024, docs/business-continuity-disaster-recovery.md.

- **ISO-38 | Metodo e registro dei rischi** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Definire criteri di impatto e probabilita'; per ogni gap registrare scenario, asset, proprietario, rischio iniziale, trattamento, residuo e accettazione.
  - **Chiusura verificabile:** Registro approvato che copre almeno tutti gli interventi critici di questa roadmap.
  - **Responsabile:** RSGSI e proprietari dei rischi. **Dipendenze:** ISO-36. **Controlli:** 6.1.2, 6.1.3.
  - **Fonti:** docs/infrastructure-timeline/GAP-TBC.md, ISO/IEC 27001:2022.

- **ISO-39 | Statement of Applicability dei 93 controlli** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Riconciliare la checklist locale con misure attuali; motivare applicabilita', esclusioni, implementazione, responsabile e prova per ogni controllo.
  - **Chiusura verificabile:** SoA approvato, nessun 'Fatto' privo di evidenza, numerazione Annex A 2022 corretta.
  - **Responsabile:** RSGSI. **Dipendenze:** ISO-38. **Controlli:** 6.1.3.
  - **Fonti:** Checklist ISO27001 rev4 locale, docs/design-and-security.md.
  - **Ultimo stato (2026-09-28):** La checklist contiene 93 controlli e nessuna prova compilata.

- **ISO-40 | Obiettivi e indicatori misurabili** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Fissare metriche e soglie per backup, ripristino, patch, esposizioni, revisioni accessi e allarmi, con frequenza e proprietario.
  - **Chiusura verificabile:** Serie di misure datate e riesame delle deviazioni.
  - **Responsabile:** RSGSI e IT Manager. **Dipendenze:** ISO-38. **Controlli:** 6.2, 9.1.
  - **Fonti:** ISO/IEC 27001:2022, data/scadenze.json.

- **ISO-41 | Procedure operative e gestione dei cambi** - **In corso**; Nessuna fornitura prevista.
  - **Azione:** Formalizzare accessi e revoche, firewall/VLAN, backup, ripristino, patch, segreti, certificati e fornitori; usare ticket, prova e rollback per i cambi.
  - **Chiusura verificabile:** Una esecuzione documentata o esercizio per ciascuna procedura critica.
  - **Responsabile:** IT Manager e RSGSI. **Dipendenze:** nessuna. **Controlli:** A.5.37, A.8.32, 8.1.
  - **Fonti:** docs/runbook-anomalie.md, roadmap Fase 5.
  - **Ultimo stato (2026-09-28):** Esistono runbook puntuali; manca una procedura unificata applicata a tutte le classi di cambio.

- **ISO-42 | Risposta agli incidenti** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Definire ruoli, escalation, decisione sugli eventi, raccolta prove e comunicazioni; esercitare uno scenario pertinente al phishing gia' documentato.
  - **Chiusura verificabile:** Esercitazione con tempi, decisioni, verbale e miglioramenti assegnati.
  - **Responsabile:** RSGSI e Comitato di crisi. **Dipendenze:** nessuna. **Controlli:** A.5.24, A.5.25, A.5.26, A.5.28, A.6.8.
  - **Fonti:** docs/cybersecurity-governance.md, docs/business-continuity-disaster-recovery.md.

- **ISO-43 | Fornitori, cloud e servizi esterni** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Rivedere responsabilita', accessi, incidenti, continuita' e cessazione per hosting, RMM, backup, connettivita' e SaaS; chiedere prove contrattuali e operative.
  - **Chiusura verificabile:** Schede fornitore con rischio, proprietario, ultima revisione e azioni aperte.
  - **Responsabile:** RSGSI e responsabile acquisti. **Dipendenze:** nessuna. **Controlli:** A.5.19, A.5.20, A.5.21, A.5.22, A.5.23.
  - **Fonti:** docs/vendor-management.md, ISO/IEC 27001:2022.

- **ISO-44 | Revisione accessi e formazione** - **Da fare**; FORNITURA CONDIZIONATA. Formazione esterna solo se il programma interno non copre le competenze richieste.
  - **Azione:** Rivedere account privilegiati, accessi di collaboratori e fornitori, revoche e consapevolezza del personale su phishing e segnalazione eventi.
  - **Chiusura verificabile:** Elenco accessi approvato dai proprietari, revoche eseguite e registri di formazione.
  - **Responsabile:** RSGSI e responsabili di servizio. **Dipendenze:** nessuna. **Controlli:** A.5.18, A.6.3, A.6.8.
  - **Fonti:** docs/cybersecurity-governance.md, ISO/IEC 27001:2022.

- **ISO-45 | Audit interno indipendente** - **Da fare**; FORNITURA CONDIZIONATA. Auditor esterno se non esiste una persona interna sufficientemente indipendente e competente.
  - **Azione:** Pianificare audit su clausole 4-10 e controlli applicabili, con auditor indipendente dal lavoro verificato; registrare rilievi e correzioni.
  - **Chiusura verificabile:** Piano, rapporto di audit, non conformita' e prove delle azioni correttive.
  - **Responsabile:** Direzione e RSGSI. **Dipendenze:** ISO-39, ISO-41. **Controlli:** 9.2, 10.1.
  - **Fonti:** ISO/IEC 27001:2022.

- **ISO-46 | Riesame della direzione e azioni correttive** - **Da fare**; Nessuna fornitura prevista.
  - **Azione:** Presentare rischi, obiettivi, misure, incidenti, audit e risorse; assegnare decisioni, scadenze e verifica dell'efficacia dei correttivi.
  - **Chiusura verificabile:** Verbale di riesame, registro azioni e verifica successiva dell'efficacia.
  - **Responsabile:** Direzione. **Dipendenze:** ISO-45. **Controlli:** 9.3, 10.1, 10.2.
  - **Fonti:** ISO/IEC 27001:2022, docs/business-continuity-disaster-recovery.md.

- **ISO-47 | Audit di certificazione** - **Da fare**; FORNITURA NECESSARIA. Servizio dell'organismo di certificazione accreditato per audit Stage 1 e Stage 2.
  - **Azione:** Selezionare organismo accreditato, concordare ambito e calendario Stage 1/Stage 2 e presentare SGSI con prove operative e azioni correttive chiuse.
  - **Chiusura verificabile:** Contratto e programma di audit, esiti delle due fasi e trattamento di eventuali rilievi.
  - **Responsabile:** Direzione e RSGSI. **Dipendenze:** ISO-45, ISO-46. **Controlli:** 4-10.
  - **Fonti:** obiettivo di progetto marzo 2027, ISO/IEC 27001:2022.

## Limiti delle fonti

- Baseline di rete documentale al 23/09/2026, tratta esterna corretta dall'IT Manager il 28/09/2026 e riconciliazione automatica Nebula/Proxmox al 28/09/2026: 39 confronti, zero scostamenti sulle sole proprieta' controllate. Il GS-105B non gestito non e' verificabile direttamente da Nebula: la sua eventuale presenza fisica residua richiede sopralluogo.
- Lo snapshot NinjaOne aveva 20 giorni al 28/09/2026; le tre baseline del delta OneDrive ne avevano 20 contro la cadenza di 7 giorni. Il delta generale non e' stato completato durante la ricognizione.
- Le licenze Nebula e Gold Security Pack hanno letture discordanti nel registro: rileggere il pannello prima di proporre un rinnovo. La vecchia scadenza del nuovo access point e' superata dalla misura del 10/09/2026.
- Lo standard di riferimento e' ISO/IEC 27001:2022 con Amd 1:2024; questa lista copre il lavoro emerso dal progetto, non sostituisce la valutazione di applicabilita' di tutti i controlli.
