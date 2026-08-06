# Design e Sicurezza – Intrawelt S.a.s.

Documento di governance della sicurezza IT. Contiene l'analisi dei principi di design, la Statement of Applicability ISO/IEC 27001:2022 e il piano di implementazione.

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

Nota: la SoA è la dichiarazione formale di quali controlli ISO27001 sono applicabili, implementati o esclusi. Stato: pre-gap analysis (la gap analysis formale è pianificata entro fine 2025, da aggiornare con Consulente-ISO27001-1).

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
| A.5.1 | Politiche per la sicurezza delle informazioni | SI | Parziale | Nessuna policy formale pubblicata. Disciplinare lavoratori in preparazione (Consulente-ISO27001-1 18/04/2025). |
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
| A.8.3 | Gestione dei supporti | SI | Parziale | Chiavette USB da disabilitare (Consulente-ISO27001-1). Politica da definire. |
| A.8.10 | Cancellazione delle informazioni | SI | Parziale | Offboarding: cancellazione account. Cancellazione dati da dispositivi non documentata. |

---

### A.9 – Controllo degli accessi

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.9.1 | Politica di controllo degli accessi | SI | Parziale | Accessi distinti per utente. Policy formale non prodotta. |
| A.9.2 | Gestione dell'identità degli utenti | SI | SI – Parziale | Active Directory / Entra ID. Onboarding documentato. Nota igiene identita' di dispositivo (20/07/2026): un workplace join orfano del 2017 con keyset corrotto ha bloccato le app M365 di una postazione dopo un reset password (incidente 657rx, `runbook-anomalie.md` §END-001); manca un processo di purga periodica dei record di dispositivo orfani lato Entra ID. |
| A.9.3 | Autenticazione degli utenti | SI | SI – Parziale | MFA Azure admin attivo. MFA per tutti gli utenti non attivo. |
| A.9.4 | Diritti di accesso privilegiato | SI | Parziale | 4 account Azure admin identificati. Account locali admin non censiti. |
| A.9.5 | Autenticazione sicura | SI | SI – Parziale | Password policy M365 attiva. Robustezza criteri da rivedere (Consulente-ISO27001-1). |
| A.9.6 | Gestione delle password | SI | Parziale | Password manager non adottato aziendalmente. |
| A.9.7 | Controllo degli accessi ai sistemi e alle applicazioni | SI | Parziale | Firewall policy, VLAN segmentation. Accessi applicativi non documentati. **Aggiornamento 27/07/2026**: sulla VM207 la configurazione QEMU porta un parametro di console VNC su tutte le interfacce (display 77) invece che sul solo loopback, ed e' presente un file di credenziali in chiaro nella home dell'utente di servizio: da verificare se la console sia effettivamente attiva e protetta da password (SRV-005, `GAP-TBC.md` #120). Le console delle VM vanno raggiunte via tunnel o dall'interfaccia Proxmox autenticata, non da una porta in ascolto sulla LAN. |

---

### A.10 – Crittografia

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.10.1 | Crittografia | SI | Parziale | VPN IPsec attiva. BitLocker XTS-AES 128 attivo su tutti gli endpoint Windows dal 03/07/2026, chiavi in escrow su NinjaOne. Crittografia NAS [TBC]. **Aggiornamento 27/07/2026**: nessuna policy crittografica aziendale scritta, e i servizi interni stanno divergendo — certificato pubblico Let's Encrypt sui domini esposti, certificato auto-firmato sulla VM206, CA interna del reverse proxy sulla VM208 con root da importare a mano su ogni client e nessuna procedura di revoca o rinnovo (SEC-016, `GAP-TBC.md` #119). Nel frattempo il portale GroupShare viaggia in chiaro (SEC-015). La policy va scritta prima che i servizi interni si moltiplichino ulteriormente. |

---

### A.11 – Sicurezza fisica e ambientale

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.11.1 | Perimetro di sicurezza fisica | SI | Parziale | CED con accesso fisico. Badge lettore impronte (BioStar, .20.199). Accesso sala server con badge da implementare (Consulente-ISO27001-1). |
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
| A.13.1 | Gestione della sicurezza delle reti | SI | Parziale | Firewall UTM, VLAN segmentation. Switch mgmt su VLAN guest (ANOMALIA FW-002). **Aggiornamento 22/07/2026**: la rete ospiti VLAN 90 e' ora una vera rete Wi-Fi guest, ripulita dall'infrastruttura legacy che vi era finita per errore, e naviga su Internet tramite SNAT esplicito (policy route `GUEST_SNAT`, vedi `firewall-zyxel-usg-flex-500.md` §Policy Route). Resta da isolarla dalle zone interne: la regola `GUEST_Outgoing` ha destinazione ancora `any` (NET-001 resta aperto), restringimento a sola WAN pianificato, eventualmente con isolamento anche lato access point. **Aggiornamento 22-23/07/2026, tre fatti**: (1) la regola `GUEST_Outgoing` e' stata ristretta da destinazione `any` a sola WAN e la restrizione e' stata verificata — la rete ospiti naviga e non raggiunge la LAN interna; (2) per la Wi-Fi staff l'IT Manager ha deciso l'opposto, cioe' **accesso completo alla LAN come una postazione cablata**: la regola `WIFI_STAFF_to_LAN1_deny` e' stata portata ad `allow`, quindi l'isolamento tentato con M13a e' stato deliberatamente rimosso. Il razionale e' che i due SSID sono distinti e protetti da password, quindi la staff e' popolata da dispositivi fidati mentre la guest fa da rete non fidata; l'effetto e' che NET-005 resta aperto come **rischio accettato e consapevole**, non come difetto residuo, e la sua chiusura passa dalla segmentazione reale della LAN (M22/NET-009) invece che da una ACL sulla sola Wi-Fi. La modifica e' reversibile cambiando l'azione della regola; (3) la gestione dei due switch Nebula viaggia sulla VLAN nativa dei dati (classe `.10`), non sulla VLAN 90 come indicava FW-002 in una versione datata: un PVID non valido sul trunk fa quindi cadere il piano di gestione, come e' accaduto il 23/07 in modo transitorio. **Aggiornamento 27/07/2026**: sul fronte opposto, il pilota della VM208 pubblica un'applicazione con identity provider su TCP/80 e 443 verso tutta la LAN piatta `/19` senza filtro interposto (NET-011, `GAP-TBC.md` #118). |
| A.13.2 | Trasferimento delle informazioni | SI | Parziale | VPN per accesso remoto. File transfer tramite SharePoint/Teams. Policy non formale. **Gap misurato il 29/07/2026**: le destinazioni di scansione della multifunzione del Piano Terra sono quattro su quattro cartelle condivise di singole postazioni (SMB/445), nessuna verso un NAS presidiato; l'apparato conserva le credenziali di accesso a quelle condivisioni e in un caso l'utenza e' il nome e cognome di una persona invece di un account di servizio (SEC-020, `GAP-TBC.md` #126). I documenti scansionati, tipicamente con dati personali, si depositano quindi su endpoint. Rimedio eseguibile subito e indipendente dalla segmentazione: interventi R8 e R9 di `docs/interventi-robustezza.md`. **Gap aperto (SEC-015, GAP-TBC #117)**: portale GroupShare (`gs.intrawelt.com`, Seeweb) servito in chiaro su HTTP dopo la scomparsa del certificato/binding HTTPS del 17/07/2026 — ripristinata solo la connettivita' HTTP per sbloccare i PM, non la cifratura. |

---

### A.14 – Acquisizione, sviluppo e manutenzione dei sistemi

| ID | Controllo | Applicabile | Stato | Note |
|----|-----------|-------------|-------|------|
| A.14.1 | Sicurezza nei processi di sviluppo | SI | Parziale | SCENIA: requisiti sicurezza AIDAPT documentati. Sviluppo interno IntraLino: sicurezza ad-hoc. |
| A.14.2 | Sicurezza dei servizi di sviluppo e supporto | SI | Parziale | Repository GitHub. CI/CD non formalizzato. **Aggiornamento 27/07/2026**: due progetti applicativi girano su VM Proxmox aziendali (VM207, VM208) con repository propri. Manca una regola scritta su dove viva il codice prodotto su asset aziendali: uno dei due repository ha un secondo remote verso l'account GitHub personale di un collaboratore, con l'identita' di commit locale di quella persona, e non esiste procedura di revoca dell'accesso all'uscita di un collaboratore (SEC-017, `GAP-TBC.md` #121). Sul lato separazione degli ambienti, il pilota della VM208 ha una decisione di progetto per isolare pre-produzione e produzione sulla stessa VM, attuata alla data solo a livello di configurazione. |
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
| 0 – Awareness | Apr 2025 | Incontro Consulente-ISO27001-1, valutazione consulenza | Completato |
| 1 – Gap Analysis | Fine 2025 | Analisi gap rispetto ai controlli Annex A | In corso |
| 1b – Formazione | 2025-2026 | CompTIA Security+ SY0-701 + ISO 27001 Foundation (Alessio) | In corso |
| 2 – ISMS Design | Q1-Q2 2026 | Progettazione ISMS, politiche, procedure | In corso |
| 3 – Disciplinare | Q2 2026 | Regolamento gestione sistemi informativi lavoratori | Pianificato |
| 4 – Audit interno | Mag 2026 | Audit interno pre-certificazione | Pianificato |
| 5 – Audit esterno | Giu-Lug 2026 | Certificazione da ente accreditato | Pianificato |

**Prerequisiti identificati da Consulente-ISO27001-1 (18/04/2025):**
- Disciplinare lavoratori (gestione sistemi informativi)
- Politica password robusta
- Badge accesso sala server
- Formazione phishing per tutti i dipendenti
- Politica chiavette USB e dispositivi personali

---

## Dove vivono i segreti di questo progetto (05/08/2026)

Sezione scritta perche' la domanda e' stata posta e la risposta non era scritta da nessuna parte: esistevano cinque ADR che ciascuno spiega un canale, e nessun documento che li mettesse in fila. L'assenza di una vista d'insieme ha prodotto un'affermazione sbagliata in sessione, cioe' che il progetto non usasse un file `.env`, quando ne usa uno con un ruolo preciso.

La configurazione e' stata resa univoca il 05/08/2026 con **ADR-021**, su richiesta dell'IT Manager. La regola e' una sola: **un segreto sta in un posto solo**. Da cui tre posti in tutto, ciascuno con un criterio che si spiega in una frase.

| Tipo di segreto | Dove vive | Perche' li' |
|---|---|---|
| Token che uno script legge da solo | blocco **`env` di `.claude/settings.local.json`**, unica copia | e' un file di progetto ignorato da git, e il blocco `env` alimenta sia il server MCP sia gli script |
| Segreto di un fornitore | **digitato a runtime**, mai su disco | non e' nostro: non averlo scritto e' la scelta corretta |
| Password degli apparati | **archivio KeePassXC `.kdbx` sul NAS** | non e' rigenerabile e non lo legge nessuno script: e' il caso per cui esiste un password manager |

### Perche' non un `.env`, e quando invece il `.env` e' giusto

Il principio, che vale oltre questo progetto: **il `.env` e' possibile quando il codice che consuma la configurazione e' tuo**. Non e' una funzione del sistema operativo, e' una convenzione che il consumatore deve implementare, con una libreria o con venti righe scritte a mano.

Qui i consumatori sono due e uno non e' modificabile. Gli script PowerShell potrebbero caricare un `.env`; Claude Code no, perche' l'espansione `${VAR}` di `.mcp.json` legge **soltanto le variabili d'ambiente del processo** — verificato sulla documentazione ufficiale — e se una variabile manca la configurazione si carica lasciando il testo `${VAR}` non espanso, con un avviso in `claude mcp list`. Un `.env` non entra in quel percorso per nessuna configurazione.

Il contrasto utile e' con un altro progetto sulla stessa macchina, `telegram-notifications`, dove il `.env` **e' la scelta corretta**: li' il consumatore e' `relay/config.py`, codice proprio, con una funzione `load_dotenv()` scritta a mano. Stessa regola, risposta diversa, perche' la regola segue il consumatore e non il gusto.

Un lucchetto valutato e scartato, perche' il ragionamento sbagliato e' istruttivo. Poiche' `.claude/settings.local.json` contiene anche hook e permessi, si era pensato di aggiungerlo alle regole `deny` per impedire all'agente di leggervi i segreti. E' costo senza beneficio: il blocco `env` funziona **iniettando i valori nell'ambiente dei sottoprocessi**, e le chiamate Bash dell'agente sono sottoprocessi, quindi quei valori sono leggibili con un comando qualunque per costruzione. Il lucchetto togliesse all'agente la vista su hook e permessi senza togliergli la vista sui segreti. Rimosso.

La regola generale: non si mette un lucchetto su un file quando lo stesso contenuto e' disponibile per progetto attraverso un altro canale. Si perde una capacita' utile e si resta convinti di essere protetti. Vale il principio di SEC-024 — un agente che esegue uno script ha accesso ai segreti che quello script usa.

Nel dettaglio, sistema per sistema:

| Sistema | Variabile o canale | Chi la usa | Vincolo |
|---|---|---|---|
| Nebula (switch e AP) | `NEBULA_API_KEY` nel blocco `env` | i quattro script Nebula | ADR-009, ADR-010, ADR-021 |
| Proxmox, sola lettura | tre variabili nel blocco `env`, espanse in `.mcp.json` | MCP `proxmox` | ADR-007, ADR-008, ADR-021 |
| Proxmox, scrittura (futuro) | variabili dedicate, a finestra, mai in `.mcp.json` | script, solo quando serve | ADR-008 |
| NinjaOne (RMM) | prompt a runtime, nessuna variabile | `Get-NinjaSnapshot.ps1` | ADR-017 |
| Firewall, NAS, switch, MFP, iLO | archivio `.kdbx` | l'IT Manager | ADR-021, SEC-007 |

I valori vivono in **un solo file**, `.claude/settings.local.json`, ignorato da git e coperto da una regola `deny`. Il `.env` con i valori viene eliminato perche' nessuno lo legge; al suo posto c'e' **`.env.example`**, senza valori e **versionato di proposito**, perche' il valore di quel file non erano mai i valori ma i commenti — quali variabili servono, da dove vengono, come si rigenerano, quale ADR le vincola. Versionandolo, la procedura di rigenerazione sopravvive alla macchina, che e' precisamente cio' che un backup di valori non garantiva.

Nota operativa su `.env.example`: la regola `Read(.env.*)` lo rende non leggibile dall'agente, quindi e' documentazione **per le persone**. Il suo contenuto informativo e' comunque duplicato in questa sezione, che l'agente puo' leggere.

### L'interim sulle password degli apparati, e i suoi limiti

Fino al 05/08/2026 le password di firewall, NAS, switch e multifunzione vivevano in un foglio di calcolo sul NAS (`accesso_server_accounts_vari.xls`). L'interim adottato e' un unico archivio KeePassXC sul NAS, che eredita il backup gia' esistente. Lo studio di SEC-007 aveva scartato KeePass per i conflitti di scrittura concorrente, e quel motivo non si applica finche' l'unica persona che accede e' l'IT Manager; il formato importa direttamente in Vaultwarden, quindi non e' un vicolo cieco.

Cosa l'interim **non** da', e va detto perche' un interim di cui si tacciono i limiti diventa definitivo: nessun accesso condiviso, nessun registro di chi ha letto cosa, nessuna revoca per singola persona, e una sola password principale come unico punto di rottura. Sono le tre cose che Vaultwarden aggiunge, e sono la ragione per cui **SEC-007 resta aperto**. Cio' che si ottiene subito e' che il gruppo di segreti piu' numeroso smette di stare in chiaro.

### L'asimmetria da dichiarare, perche' non e' quella che si crede

La protezione e' stata messa sulla copia che nessuno script legge, e non su quella che leggono tutti. Le regole `deny` bloccano l'agente sul `.env`; **non lo bloccano sulle variabili d'ambiente**, che sono leggibili con un comando qualunque da qualunque processo dell'utente, agente compreso.

Non e' un difetto di progettazione ma una conseguenza necessaria: uno script che usa un segreto deve poterlo ottenere, e se l'agente esegue quello script allora l'agente ha accesso al segreto. Nessuna variante di questo schema lo evita. Va detto perche' altrimenti la riga "il segreto sta in una variabile d'ambiente" si legge come una barriera, e non lo e'.

Ne segue la lettura corretta dello spostamento fatto il 05/08/2026, quando la chiave Nebula e' passata da un file sul desktop a una variabile utente. Quello spostamento **non** ha protetto il segreto dall'agente ne' da un processo malevolo in esecuzione come quell'utente. Ha eliminato quattro esposizioni concrete e diverse: un file visibile sfogliando una cartella e apribile per sbaglio, un file che finisce in un backup del desktop, un file che compare in una condivisione schermo o in uno screenshot, e un file che qualcuno potrebbe copiare in una cartella sincronizzata. E' igiene contro l'esposizione accidentale, che e' il vettore piu' probabile in questo contesto, non un confine di sicurezza.

Il confine vero manca ed e' sempre lo stesso: **SEC-007**, il password manager aziendale. Va detto con precisione, perche' altrove in questa documentazione e' stato scritto come se esistesse: lo studio e' completo e il candidato individuato e' Vaultwarden, ma **non e' mai stato messo in produzione**, e oggi le credenziali degli apparati vivono in una cartella accessibile al solo IT Manager. Non si puo' quindi raccomandare di "metterle nel password manager": prima va costruito. Anche quando esistera' non eliminera' l'asimmetria — un segreto usato da uno script deve essere ottenibile dallo script — ma spostera' la custodia in un sistema con controllo di accesso, registro degli accessi e rotazione, invece del filesystem e del registro di una postazione.

Registrato come **SEC-024** per non perdere la conclusione.

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
