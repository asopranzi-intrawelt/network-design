# Telefonia e PBX - Stato e migrazione Vianova

## Stato attuale (giugno 2026)

### Centralino fisico: Panasonic KX-NCP1000

Il centralino fisico Panasonic KX-NCP1000 e' installato in sede e gestisce la telefonia interna. Il gateway SIP verso la linea Vianova e' il Patton SmartNode 5551.

Linee telefoniche Vianova attive fisicamente dal 17/04/2025, gestite attraverso il contratto myOffice firmato il 18/12/2024 (6 canali voce, centralino cloud previsto in contratto). Il canone non e' riportato: `.claude/rules/anonymization.md` esclude gli importi dai file tracciati. Correzione applicata il 06/08/2026, il valore era rimasto qui da una stesura precedente alla regola.

### Il centralino fisico e' stato smantellato il 31/07/2026

Dichiarazione dell'IT Manager del 06/08/2026, nella scheda dei telefoni restituita compilata. Il centralino Panasonic e i **ventisette apparecchi digitali** che vi erano attestati sono stati **rimossi fisicamente giovedi' 31/07/2026**. Tutto cio' che questa sezione descrive al presente riguarda quindi lo stato fino a quella data, e va letto come storia.

La conseguenza non e' documentale ma operativa, e capovolge TEL-003. Il gap era stato aperto il 03/08 come "ventisette apparecchi digitali che il centralino cloud non puo' registrare, e per ciascuno va scelto fra telefono SIP nuovo, softphone o gateway di conversione". Oggi la scelta non e' piu' davanti a una migrazione ma dietro a una rimozione gia' avvenuta: quei ventisette interni non hanno piu' un terminale, e il centralino cloud che dovrebbe sostituirli non e' attivo, perche' la quantita' di interni del contratto e' ancora in bianco e i messaggi non sono decisi. Che cosa usino oggi quelle ventisette persone per telefonare e' la prima domanda da fare, e non e' deducibile da nessuna fonte di questo progetto. Tracciato come **TEL-004**.

Ne discendono due code che nessuno ha ancora preso: la sorte del Patton SmartNode 5551, che era il gateway SIP verso la linea e la cui presenza in servizio dopo lo smantellamento non e' dichiarata, e lo smaltimento degli apparecchi rimossi, che ricade sul gap RAEE gia' aperto al #109.

### Terminali VoIP installati

**Distribuzione corretta il 03/08/2026 sulla tabella MAC di entrambi gli switch, a 54HP rientrato nel piano di gestione.** La versione precedente di questa sezione collocava tre apparecchi al Piano Terra e due al Piano 2, e trattava l'etichetta della porta 3 del 54HP come probabile errore. La misura dice il contrario: cinque apparecchi con prefisso MAC Yealink appresi sulla VLAN 2, **tre sul Piano 2 e due sul Piano Terra**. Chiude M10 e i gap #67/#99.

**Modelli, prese a parete e ubicazioni aggiunti il 06/08/2026** dalla scheda restituita compilata dall'IT Manager. Chiude il `[TBC: modello esatto per porta]` che questa sezione portava dal 03/08.

| Porta | Switch | Modello | Presa a parete | Ubicazione dell'apparecchio |
|---|---|---|---|---|
| 3 | XGS2220-54HP | Yealink SIP-T34W | 1.1.2 | Piano 1, amministrazione |
| 5 | XGS2220-54HP | Yealink SIP-T31G | 1.2.1 | Piano 1, amministrazione |
| 44 | XGS2220-54HP | Yealink SIP-T31G | 2.3.7 | Sala-1 |
| 13 | XGS2220-30HP | Yealink SIP-T31G | 0.3.1 | ufficio centrale del Piano Terra |
| 23 | XGS2220-30HP | Yealink SIP-T34W | 0.5.3 | reception |

Va letta con attenzione la distinzione fra le due colonne di ubicazione, perche' e' la fonte di meta' delle confusioni passate su questi cinque apparecchi: lo switch dice a quale armadio l'apparecchio e' attestato, la presa dice in che stanza si trova. I tre apparecchi sul 54HP, che e' lo switch del Piano 2, stanno fisicamente due al Piano 1 e uno in Sala-1.

Corroborazione indipendente: il piano di numerazione conta esattamente cinque interni di tipo IP e IP+, compresa la sala riunioni. L'associazione fra porta, interno e persona vive in `_notes/.anonymization-map.md` e in `_notes/livello-fisico-ed-elettrico.md`, non qui: i numeri di interno sono fra i dati che `.claude/rules/anonymization.md` esclude dai file tracciati.

**La contraddizione anagrafica NET-007 si chiude, e nel senso opposto a quello ipotizzato.** Il progetto portava dal 09/06/2026 uno screenshot che etichettava la porta 3 del 54HP come "SIP-T34W Persona-A" contro un rilievo del 29/05 che collocava i tre T34W al Piano Terra, e aveva concluso che l'etichetta fosse probabilmente sbagliata. La misura dice il contrario: sulla porta 3 c'e' davvero un T34W ed e' davvero quello di Persona-A, quindi l'etichetta era corretta e il rilievo di maggio sbagliato. Sbagliato anche nel conteggio, perche' i T34W sono **due** e i T31G **tre**, non tre e due. E' la seconda smentita dello stesso rilievo dopo quella del 03/08 sulla distribuzione fra i piani, e la lezione e' quella gia' registrata nel protocollo delle fonti: un rilievo e' una fotografia datata, non uno stato. Chiude i gap #67/#99 con esito rovesciato.

**Stato dichiarato dall'utente il 03/08/2026, e corroborato dalla misura.** Tutti e cinque gli apparecchi sono collegati alla rete e **ciascuno sta su una porta che prende correttamente la VLAN della fonia**: il lavoro e' stato completato in sessioni di lavoro precedenti a questa. La misura indipendente dello stesso giorno concorda, perche' i cinque indirizzi compaiono nella tabella MAC dei due switch tutti e cinque sulla VLAN 2 e non sulla VLAN dati.

Ne segue che la parte di rete di TEL-002 non riguarda piu' due apparecchi con la fonia mancante: e' chiusa su tutti e cinque. La documentazione precedente descriveva i due del Piano Terra come "parte di rete risolta ma nessun lease DHCP" sulla base dello stato del 23/07, ed e' quella descrizione a essere superata. Vedi la nota di chiusura in `runbook-anomalie.md` §TEL-002 per il residuo da confermare, che riguarda la registrazione verso il centralino e non la rete.

Resta aperta la sola verifica che gli apparecchi si registrino e chiamino, che si legge dal display e non da una tabella MAC: vedi `runbook-anomalie.md` §TEL-002.

---

## Voice VLAN (configurazione giugno 2026)

### Scelta tecnica

Voice VLAN ID: **2**. Metodo di assegnazione: **LLDP-MED** (Link Layer Discovery Protocol - Media Endpoint Discovery, TIA-1057) **piu' Vendor ID based VLAN**, cioe' entrambi i meccanismi contemporaneamente. Entrambi i modelli Yealink T31G e T34W supportano LLDP-MED.

**Correzione del 03/08/2026, dalla lettura degli screenshot della sessione del 07/07/2026.** Questa scheda affermava che LLDP-MED fosse stato preferito all'OUI e che la lista OUI non richiedesse manutenzione perche' non era in uso. Sul dispositivo sono attivi **entrambi**: la sezione "Vendor ID based VLAN" e' abilitata e contiene una voce, il prefisso `C4:FC:22` mappato sulla VLAN 2 con priorita' 1 e descrizione "Telefonia Yealink". Il prefisso e' riportato verbatim come eccezione dichiarata alla regola di anonimizzazione, perche' e' il nome di un oggetto di configurazione presente sull'apparato e serve a ritrovare quella voce nella GUI: non e' il MAC di un dispositivo, e' un prefisso di produttore.

Il fatto ha una conseguenza pratica utile e non e' una svista da correggere. I due meccanismi si coprono a vicenda: LLDP-MED negozia con l'apparecchio che lo supporta, l'OUI cattura per prefisso qualunque telefono dello stesso produttore anche dove la negoziazione non si completi. Corroborazione incrociata: i cinque indirizzi appresi sulla VLAN 2 nello snapshot del 03/08/2026 hanno tutti esattamente quel prefisso.

Il rovescio della medaglia va detto, perche' e' il motivo per cui la scheda preferiva LLDP-MED: la lista per prefisso e' manutenzione manuale, e un telefono di un altro produttore — per esempio il dispositivo voce Grandstream sulla porta 6 del 54HP, o l'adattatore analogico dell'ascensore in arrivo — non viene catturato da quella voce e va gestito con LLDP-MED o con un PVID esplicito sulla porta.

Motivi per cui LLDP-MED resta il meccanismo preferito dove funziona:
- Bidirezionale: lo switch comunica attivamente al telefono la VLAN da usare.
- Non richiede manutenzione manuale della lista OUI.
- La negoziazione e' verificabile nei log dello switch.

### Priorita' e QoS

802.1p CoS (Class of Service): **5** (valore standard IEEE per voce RTP). DSCP: **46** (EF - Expedited Forwarding, RFC 3246, standard voce). **TBC chiuso il 03/08/2026**: il dubbio era se il valore fosse rimasto sul default Nebula di
44. Lo screenshot della pagina Voice VLAN del 07/07/2026 mostra il campo DSCP impostato a **46**, con Voice VLAN ID 2 e Priority 5. Il valore e' quindi quello corretto per la voce e non il default.

### Configurazione porte

**Porte telefoni (Piano Terra, XGS2220-30HP, porte 21 e 23):**
```
Type: Access
VLAN type: Voice VLAN (LLDP-MED)
PVID: 1  (traffico dati untagged sulla VLAN 1)
LLDP: Enabled
Mgmt VLAN control: Disabled
```

**Porte telefoni (Piano 2, XGS2220-54HP, porte 3, 5, 44 - contrassegnate con PoE):** Stessa configurazione: Access, Voice VLAN, PVID 1, LLDP Enabled.

**Porta uplink fibra SFP+ tra i due switch:**
```
Type: Trunk
VLAN ammesse: VLAN dati (untagged) + VLAN 2 voce (tagged)
```

**Porte PC (tutte le restanti):**
```
Type: Access
VLAN type: None
PVID: 1
```
[TBC: 28 porte Piano Terra configurate via selezione multipla su Nebula - verificare che la configurazione sia stata salvata.]

### Flusso LLDP-MED

Il telefono Yealink si connette alla porta Access. Lo switch invia via LLDP-MED il Network Policy TLV con VLAN ID 2, CoS 5, DSCP 46. Il telefono registra la VLAN e invia il traffico voce taggato VLAN 2. Il traffico PC che attraversa il telefono (porta passante) resta untagged, assegnato al PVID 1.

---

## Porte SIP/RTP per centralino virtuale Vianova

Verifica del 23/03/2026 (mail myOffice/Vianova referente-vianova-1@myofficegroup.it): nessuno dei seguenti range e' bloccato dal firewall Zyxel USG FLEX 500 in uscita. Verifica condotta su policy e log del 23/03/2026.

| Destinazione         | Protocollo | Porte           | Uso              |
|----------------------|-----------|-----------------|------------------|
| <RANGE-VIANOVA-SIP-1>   | TCP       | 5061            | SIP              |
| <RANGE-VIANOVA-SIP-1>   | UDP       | 20000-40000     | RTP (media)      |
| <RANGE-VIANOVA-SIP-2>      | TCP       | 5039            | SIP alternativo  |
| <IP-VIANOVA-MGMT>       | TCP       | 433             | gestione         |
| <IP-VIANOVA-SIP-3>       | TCP       | 5222            | XMPP/segnalazione|
| <IP-VIANOVA-MEDIA-1>       | TCP/UDP   | 6050            | media            |
| <RANGE-VIANOVA-MEDIA-2>    | TCP       | 14000-14999     | media            |
| <RANGE-VIANOVA-MEDIA-2>    | UDP       | 15000-15999     | media            |

Risultato: nessun blocco esistente. La migrazione al centralino virtuale Vianova non richiede modifiche alle security policy del firewall per il traffico in uscita.

Oggetti Address e Service creati nel firewall durante la verifica (23/03/2026): SUBNET_185_158_118_128_26, SUBNET_103_26_124_0_24, HOST_185_158_118_27, HOST_185_158_116_29, HOST_94_138_161_187, SUBNET_94_138_161_180_30 e i corrispondenti Service Objects TCP_5061, UDP_20000_40000, TCP_5039, TCP_433, TCP_5222, TCP_6050, UDP_6050, TCP_14000_14999, UDP_15000_15999.

---

## Migrazione centralino cloud Vianova

### Stato (giugno 2026)

La migrazione al centralino cloud Vianova e' in corso. Il meeting con myOffice e' avvenuto il 09/06/2026 (Referente-Vianova-1). Nella stessa giornata sono stati eseguiti i primi passi operativi concreti, documentati dagli screenshot della cartella `08062026 (steps)` e dalla mail `Messagistica centrale telefonica.eml`.

### Provisioning utente Area Clienti Vianova (09/06/2026)

Il portale di gestione del centralino cloud e' Area Clienti Vianova (areaclienti.vianova.it). Alessio (asopranzi@intrawelt.com, profilo Amministratore Area Clienti) ha creato un secondo utente, Persona-E (reparto IT), profilo "Base", senza privilegi di amministratore Area Clienti ne' di amministratore PBX Centrex. Procedura osservata:

1. Impostazioni > Utenti > Aggiungi: inserire nome, cognome, reparto, email.
2. Il sistema segnala se il dominio email e' esterno al cliente (caso Persona-E, dominio intrawelt.com diverso dal dominio Vianova): la password verra' impostata dall'utente stesso alla conferma dell'invito, non da chi crea l'account.
3. L'utente riceve una mail da Vianova (info@vianova.it) con un link di conferma valido 15 giorni.
4. Al primo accesso l'utente sceglie una password, indica un numero di cellulare per il 2FA via SMS ed eventualmente un indirizzo email alternativo per i codici.
5. Registrazione completata: l'utente accede da quel momento con le proprie credenziali.

E' stato inoltre scaricato l'installer di **Vianova One** (`VianovaOneInstaller-1.4.0.6.exe`, versione 1.4.0.6), l'applicazione unificata Vianova per chiamate, chat e videoconferenza inclusa nella licenza Collaboration UC, disponibile per Windows/macOS/iOS/Android, per verificarne il funzionamento su una seconda postazione.

### Riconfigurazione porte switch (09/06/2026)

Sullo switch Nebula con MAC `AA:BB:CC:00:00:01` sono state rinominate e riconfigurate due porte: la porta 8 ("Vianova DHCP server fonia") e' passata da PVID 1 a PVID 2 restando di tipo Voice VLAN; la porta 3 ("SIP-T34W Persona-A") resta Voice VLAN con PVID 1. [TBC: il pannello Nebula di questo switch mostra 54 porte, compatibili solo con lo XGS2220-54HP di Piano 2, mentre `interventi 29052026.docx` (29/05/2026) descrive esplicitamente un'assegnazione diversa e coerente con quanto gia' scritto sopra in questa scheda: i tre T34W (Persona-A, Persona-B, Persona-C) sulle porte 21/23 dello switch Piano Terra XGS2220-30HP, i due T31G (Persona-D, Sala-1) sulle porte 3/5/44 dello switch Piano 2 XGS2220-54HP con PoE. L'etichetta "SIP-T34W Persona-A" sulla porta 3 del Piano 2, undici giorni dopo, e' quindi piu' probabilmente un errore di etichettatura, forse per riferimento incrociato con il modello di telefono sbagliato, che un reale spostamento fisico: da verificare con Alessio prima di consolidare la mappatura IP/MAC/porta.]

### Messaggistica IVR - decisione aperta (09/06/2026)

myOffice (Referente-MyOffice-1, reparto Telefonia) ha richiesto via mail il testo dei messaggi da caricare sulla centrale telefonica cloud:

Messaggio GIORNO, a scelta tra due modalita'. La prima e' un semplice messaggio di attesa ("SIETE IN LINEA CON INTRAWELT, SIETE PREGATI DI ATTENDERE, GRAZIE"), con eventuale sottofondo musicale royalty-free, in cui squilla uno o piu' interni oppure prima la reception e poi, dopo 3-4 squilli, altri interni. La seconda e' un IVR con instradamento per reparto ("SIETE IN LINEA CON INTRAWELT, PREMERE 1 PER L'AMMINISTRAZIONE, PREMERE 2 PER IL COMMERCIALE, ATTENDERE IN LINEA PER UN OPERATORE"), in cui la selezione fa squillare un gruppo di interni distinto per reparto, e l'assenza di selezione instrada al gruppo operatore generico.

Messaggio NOTTE, unico: comunica gli orari di apertura ("SIETE IN LINEA CON INTRAWELT, I NOSTRI UFFICI SONO APERTI DAL LUNEDI' AL VENERDI' DALLE 9 ALLE 13 E DALLE 14 ALLE 17, GRAZIE PER AVER CHIAMATO"), con o senza squillo di un interno prima del messaggio.

**Decisione ancora aperta al 01/07/2026**: non risulta una risposta di Alessio a myOffice su quale modalita' adottare per il messaggio giorno (semplice attesa o IVR con instradamento reparti) ne' sui dettagli del messaggio notte.

### Il piano di numerazione, e la scala reale della migrazione (ingerito 03/08/2026)

Fonte: `IT + Administration - Documenti\MyOffice\Transizione centralino cloud 2026\Interni
Intrawelt_V3.xlsx`, piu' un foglio di riscontro con sette contatti e relativo interno. E' il
documento che questa scheda elencava come `[TBC: piano di numerazione definitivo]` dal
01/07/2026: era sempre stato dentro la sottocartella riservata al racconto a lavori conclusi.

Il piano conta **trentasei interni**, e la colonna del tipo di terminale e' il dato che cambia la dimensione del progetto. I nomi delle persone associate a ciascun interno non vengono riportati qui per policy di anonimizzazione: la corrispondenza vive in `_notes/.anonymization-map.md`.

| Tipo di terminale | Interni | Note |
|---|---|---|
| IP+ | 3 | reception, rappresentante legale, amministrazione |
| IP | 2 | una postazione e la sala riunioni |
| Digitale | 27 | apparecchi digitali sul Panasonic |
| Bca (analogico) | 4 | uno non connesso, piu' citofono, fax e ascensore |

Sette interni risultano marcati come non connessi, quindi gli interni realmente attivi sono ventinove.

I cinque interni di tipo IP e IP+ coincidono con i cinque Yealink censiti in questa scheda, compresa la sala riunioni, e questo chiude per corroborazione indipendente la mappatura fra interno e apparecchio. Ma e' il resto della tabella che conta: **ventisette interni sono apparecchi digitali del Panasonic**, cioe' terminali proprietari che non parlano SIP e che un centralino cloud non puo' registrare in nessun modo. Fino a oggi la documentazione di questo progetto descriveva il parco telefonico come cinque Yealink piu' il centralino fisico, e trattava TEL-002, i due apparecchi del Piano Terra senza lease, come il problema residuo della migrazione. Non lo e': **il problema residuo e' che l'ottanta per cento del parco non e' migrabile cosi' com'e'**. Ogni interno digitale richiede una delle tre cose — un telefono SIP nuovo, una licenza di *softphone* al posto dell'apparecchio, o un gateway che converta i terminali digitali — e la scelta e' per persona, non globale, perche' dipende da chi ha bisogno di un apparecchio fisico.

Registrato come gap **TEL-003**, ed e' la ragione per cui il micro-step M17 passa da "rispondere sul testo IVR" a un vero piano di migrazione dei terminali.

**Aggiornamento del 06/08/2026, che cambia il verso del problema.** I ventisette apparecchi digitali non sono piu' da migrare: sono stati rimossi insieme al centralino il 31/07/2026, come descritto in apertura di questa scheda. La domanda non e' piu' con che cosa sostituirli in una migrazione ordinata, ma che cosa usino oggi quelle persone nell'intervallo fra la rimozione e l'attivazione del centralino cloud, che non e' attiva. TEL-003 resta aperto perche' la decisione per persona non e' stata presa e la quantita' del contratto e' ancora in bianco; accanto nasce **TEL-004** per l'intervallo scoperto.

### Il contratto del centralino virtuale: firmato, con la quantita' lasciata in bianco

Fonte: `_Preventivi\prev Intrawelt_UCC_26.02.26_signed.pdf`, offerta myOffice del 26/02/2026 per il servizio Vianova Unified Communication & Collaboration, **firmata digitalmente dal rappresentante legale il 23/03/2026**. Il fatto che il contratto del centralino cloud sia accettato da marzo non era tracciato in nessun file di questo progetto.

Due elementi contano per la progettazione, e nessuno dei due e' un importo (canoni e sconti restano fuori dai file tracciati per policy).

Il primo e' il modello di conteggio, dichiarato in maiuscolo nell'offerta: **ogni telefono fisso, ogni cordless, ogni citofono e ogni posto operatore corrisponde a un interno del centralino virtuale**, e il canone e' per interno. La licenza di collaborazione, quella che porta chat, videoconferenza e condivisione dello schermo, e' invece separata e per utente. Ne segue che il piano di numerazione non e' solo una tabella tecnica: e' il documento che determina il dimensionamento del servizio, e le sette voci non connesse valgono un interno ciascuna se restano nel piano.

Il secondo e' una lacuna del documento firmato: sotto la firma c'e' l'istruzione "specificare il numero esatto di interni e di licenze", e **il numero non e' compilato**. Il contratto e' quindi accettato nel prezzo unitario ma non nella quantita', e la quantita' dipende esattamente dalla decisione ancora aperta su cosa fare dei ventisette interni digitali. Va chiuso prima dell'attivazione, non durante.

L'installazione del centralino virtuale e' inoltre fatturata a consuntivo sulle ore tecniche impiegate, quindi ogni ambiguita' risolta prima riduce tempo fatturato.

### Gateway FXS consegnato per il telefono dell'ascensore (31/07/2026)

Rilevato il 03/08/2026 dal delta OneDrive e verificato leggendo il documento di
trasporto, in cartella `IT + Administration - Documenti\MyOffice\Transizione
centralino cloud 2026\DDT del gateway FXS (ascensore)`.

myOffice ha consegnato un **Grandstream HT-812 v2**, ATA[^ata] con due porte FXS[^fxs] e router NAT Gigabit, in un'unita': documento di trasporto di vendita datato 01/07/2026, ricevuta controfirmata il 31/07/2026, riferimento interno a un preventivo di marzo 2026 (importi e numeri di documento esclusi dai file tracciati per policy di anonimizzazione).

**Attribuzione all'ascensore: confermata il 03/08/2026, non piu' un'inferenza.** L'offerta corrispondente (`_Preventivi\prev Intrawelt_apparato aggiuntivo_signed.pdf`, codice 052-AL-R0 del 26/03/2026, lo stesso riferimento riportato sul documento di trasporto) e' intitolata esplicitamente "Offerta adattatore telefonico analogico per ascensore" ed e' **firmata digitalmente dal rappresentante legale il 26/03/2026**. Il piano di numerazione corrobora in modo indipendente: l'interno **124 e' ASCENSORE, di tipo analogico**. L'ipotesi dedotta dal nome della cartella diventa quindi un fatto documentato da due fonti.

**Discrepanza fra ordinato e consegnato: sciolta il 06/08/2026 leggendo l'etichetta.** L'offerta firmata a marzo era per un **Grandstream HT802 v2**, due porte FXS e una sola porta Ethernet a 10/100 Mbps, nessuna funzione di router. Il documento di trasporto di luglio, con lo stesso riferimento di offerta, descriveva invece un **HT-812 v2**, due porte FXS con router NAT Gigabit. L'etichetta dell'apparato fisico, letta dall'IT Manager, dice **HT812 V2**: e' stato consegnato il modello superiore. Ne segue la conseguenza operativa che il progetto aveva anticipato in forma condizionale e che ora e' un requisito: l'apparato ha una coppia WAN/LAN e per impostazione predefinita fa NAT e distribuisce indirizzi, quindi la funzione di router va disattivata, perche' un secondo NAT interno e' causa classica di audio unidirezionale e di registrazioni che cadono, e su una LAN piatta un apparato che distribuisce indirizzi per conto proprio e' anche un rischio di conflitto DHCP.

Numero di serie, MAC e credenziale di amministrazione stampata sull'etichetta stanno in `_notes/livello-fisico-ed-elettrico.md` e non qui. Sulla credenziale va detta una cosa che riguarda la sicurezza e non la fonia: sugli HT8xx v2 la password di amministrazione e' randomizzata per dispositivo, quindi non e' una password di fabbrica nota, ma ora esiste in chiaro in piu' copie fuori dal password manager. Va portata sulla VM202 e cambiata alla configurazione, coerentemente con SEC-007, SEC-010 e SEC-011.

**Capacita': due porte FXS contro tre apparecchi analogici, ma il quadro e' cambiato.** Il piano di numerazione registrava quattro interni analogici, di cui uno non connesso e tre in uso: citofono, fax e ascensore. L'aggiornamento dell'IT Manager del 06/08/2026 li riduce a uno solo che richieda una porta FXS. Il **fax e' dismesso**, quindi la questione piu' delicata, cioe' il trasporto del fax su rete IP, decade insieme all'apparecchio. Il **citofono non passa dall'adattatore**: e' connesso alla Wi-Fi staff con la propria scheda di rete, quindi e' un endpoint IP e non un terminale analogico, anche se l'offerta del centralino virtuale continua a contarlo come un interno ai fini del canone. Resta l'**ascensore**, che e' esattamente cio' che l'offerta copriva. Con due porte FXS l'apparato e' quindi sovradimensionato rispetto al bisogno attuale, il che e' un problema che non esiste.

Sul citofono va segnalata una contraddizione aperta invece di essere risolta a tavolino: `docs/mappatura-porte-fisiche.md` lo colloca sulla classe `10.61.90.x` sulla base del referto della vulnerability assessment di novembre 2025, mentre la dichiarazione di oggi lo mette sulla VLAN 40 della Wi-Fi staff. Le due cose non possono essere entrambe vere adesso, e la spiegazione piu' probabile e' che l'indirizzo della VA sia superato da un cambio successivo, ma va letta sull'apparato. Registrata nell'elenco di rilievo di `docs/livello-fisico-ed-elettrico.md` §Cosa resta da rilevare.

**L'apparato non e' in attesa di installazione: e' installato.** Le tre questioni di rete che questa sezione elencava come "da chiarire prima dell'installazione" sono superate dai fatti, e due delle tre hanno una risposta. L'adattatore e' attestato sulla **porta 6 del XGS2220-54HP**, cioe' proprio sulla LAN telefonica del fornitore, con `PVID 2`, e la sua uscita raggiunge la **presa 2.8.1** che serve l'ascensore. La corroborazione e' indipendente dalla dichiarazione: il MAC appreso su quella porta e' l'indirizzo immediatamente successivo a quello stampato sull'etichetta dell'apparato, che e' il comportamento normale di un dispositivo con due interfacce. Quello che nella documentazione compariva dal 17/07 come "dispositivo voce Grandstream di Vianova sulla porta 6" e' dunque questo adattatore, e non un apparato del fornitore.

Restano aperte la disattivazione del NAT interno, che ora e' un requisito accertato e non piu' condizionale, e l'alimentazione: l'HT812 vuole 12V in continua da alimentatore esterno, non e' PoE, e da dove la prenda nella posizione in cui e' montato non e' documentato. La porta 6 e' inoltre una delle cinque porte di fonia di NET-019 che accettano qualunque VLAN taggata, quindi rientra in R19.

Il rapporto con il **Patton SmartNode 5551** resta la voce non formalizzata del piano di migrazione, e dal 31/07/2026 e' piu' urgente: con il Panasonic smantellato, un gateway che esisteva per interfacciare quel centralino alla linea non ha piu' un centralino dietro. Se sia ancora in servizio, e per fare che cosa, e' una domanda da porre.

[^ata]: *ATA*, Analog Telephone Adapter - apparato che collega un telefono analogico a una rete VoIP, presentando al telefono una porta telefonica tradizionale e parlando SIP verso la rete.

[^fxs]: *FXS*, Foreign Exchange Station - porta che eroga alimentazione, tono di libero e squillo a un apparecchio telefonico analogico; l'opposto e' la FXO, che si collega a una linea telefonica esterna.

### Prerequisiti verificati

- Linee Vianova attive da aprile 2025.
- Porte SIP/RTP non bloccate dal firewall (verifica 23/03/2026).
- Voice VLAN 2 configurata sugli switch (interventi 29/05/2026).
- Telefoni Yealink T31G e T34W supportano LLDP-MED e SIP.
- VPN Unmanaged Vianova attiva (prerequisito per IPsec, attivata 04/06/2025).
- Provisioning utente Area Clienti e app Vianova One verificati (09/06/2026).

### Aperto

Piano di migrazione completo dal centralino fisico Panasonic KX-NCP1000 al centralino cloud: routing interno, piano di numerazione, testo IVR (vedi sopra, decisione pendente), deviazioni di chiamata, configurazione Patton SmartNode durante la transizione. [TBC: nessuna di queste voci risulta ancora formalizzata nei documenti disponibili al 01/07/2026.]

---

## Procedure operative esistenti (Telefono-PBX folder)

Documenti disponibili per il centralino Panasonic KX-NCP1000:
- Centralino.doc: documentazione tecnica principale (CA client).
- procedura_deviazione_standard.docx: deviazione chiamate standard.
- procedura_deviazione_gruppo.docx: deviazione per gruppo di operatori.
- procedura_intercettare_chiamate_gruppo_operatori.docx: intercettazione chiamate.
- segreteria_personale.docx: configurazione segreteria personale.
- NuovoMessaggioCentralino.docx: procedura cambio messaggio centralino.
- x_avere_telefono_su_PC.docx: configurazione softphone su PC.

[TBC: verificare quali procedure restano valide con il centralino cloud Vianova e quali diventano obsolete. Da aggiornare dopo la migrazione.]
