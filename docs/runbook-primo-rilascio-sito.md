# Primo rilascio del sito nuovo sulla VPS: che cosa esiste, in quale ordine si procede

> Scheda aperta il 26/10/2026. Il piano di merito resta `piano-produzione-sito-nuovo.md` e la roadmap operativa privata resta `_notes/roadmap-vps-sito.md`: qui c'è soltanto la procedura del primo rilascio, con lo stato misurato di ciascun passo. Il criterio è quello della roadmap: un passo è fatto quando è stato misurato dopo essere stato configurato, non quando è stato eseguito.

## Perché questa scheda esiste adesso

Fino al 23/10/2026 il primo rilascio era bloccato da un difetto a monte e da una decisione. Il difetto era che il descrittore dei contenitori del progetto del sito definisce la sola banca dati, senza servizio applicativo, senza proxy inverso e senza volumi per le due cartelle dei file caricati: al primo rilascio quei file sarebbero vissuti dentro il contenitore e sarebbero spariti alla prima ricreazione, e un salvataggio costruito sopra avrebbe copiato una cartella destinata a svuotarsi. La decisione era quella sulla misura del traffico, chiusa da ADR-039.

Il 26/10/2026 la misura ha spostato il quadro in due punti. Il primo è che il riferimento di rilascio, cioè `main`, ha già chiuso il difetto che impediva di costruire l'immagine: l'uscita autoconsistente è dichiarata nella configurazione del framework e il contesto di costruzione esclude le due cartelle dei file caricati, che è esattamente il comportamento voluto perché quelle cartelle devono arrivare da un volume e non dall'immagine. Il secondo è che il ramo di lavoro da cui si leggeva non lo sapeva, perché quelle correzioni vivono su `main` e il canale di questo progetto punta all'albero autorevole della memoria, che è un altro ramo: una misura presa sul ramo sbagliato dava per aperto un difetto chiuso.

Resta vero che il descrittore di produzione non esiste nel progetto del sito, e per costruzione non è lì che deve stare. Secondo la ripartizione della roadmap il proxy inverso, il filtro e il canale sono dell'IT, mentre la configurazione applicativa è di chi sviluppa. Il descrittore di produzione è quindi di questo progetto, e da oggi vive in `deploy/vps-sito/`.

## Che cosa c'è sulla macchina, misurato il 26/10/2026

| Elemento | Stato |
|---|---|
| Accesso amministrativo dalla postazione aziendale | Funzionante, con alias e chiave propri; la porta è ristretta alla sola provenienza aziendale dal 23/10 |
| Motore dei contenitori | Presente alla versione 29.7.2, e l'utente operativo ne fa parte |
| Risorse | Otto gigabyte di memoria con sei e quattro liberi, settantun gigabyte liberi su disco |
| Banca dati di produzione | In esecuzione e sana, pubblicata sul solo loopback, con i contenuti ripristinati |
| File caricati | Venticinque file e trentasette megabyte nella cartella pubblica, un file e cinquecentotrentasei kilobyte in quella riservata, identici alla macchina di sviluppo |
| Descrittore dei contenitori di produzione | Presente e validato dal motore stesso |
| Configurazione del proxy inverso | Presente e validata dal proxy stesso |
| Segreti di produzione | Generati sulla macchina, in due file leggibili dal solo utente operativo |
| Codice sorgente | Presente: chiave di distribuzione autorizzata e verificata, copia di `main` prelevata sulla macchina |
| Immagine dell'applicazione | Costruita e in esecuzione: l'applicazione risponde dentro la rete dei contenitori e non pubblica porte |
| Nome e certificato | Chiusi: il record esiste, il proxy ha ottenuto il certificato e il sito risponde in HTTPS dalla sede |
| Restrizione del sito di anteprima | Configurata e validata: ammessa la sola provenienza aziendale, con l'eccezione del percorso di verifica del certificato |
| Persistenza dei file caricati | Provata con una scrittura vera su entrambe le collezioni; i file riservati non sono raggiungibili senza autenticazione |

## Le tre scelte che il descrittore attua, e il difetto che ciascuna chiude

La prima è che nessun servizio pubblica porte verso l'esterno tranne il proxy. La banca dati e l'applicazione si raggiungono per nome sulla rete interna dei contenitori. La ragione non è di stile: la documentazione del motore dichiara che il traffico verso una porta pubblicata viene deviato prima di passare dal filtro di sistema, quindi su una porta pubblicata il filtro non protegge niente, ed è il vincolo V2-ter della roadmap. È lo stesso difetto che sulla macchina di sviluppo teneva la banca dati aperta su tutte le interfacce.

La banca dati fa però un'eccezione dichiarata, e la si legge insieme alla sua ragione perché altrimenti sembra una svista. È pubblicata sul solo indirizzo di loopback della macchina, e non serve all'applicazione: serve alla costruzione dell'immagine. Per ADR-038 l'immagine si costruisce qui e contro la banca dati di qui, perché la costruzione legge i contenuti e li incorpora nelle pagine generate in anticipo; ma la costruzione gira fuori dalla rete dei contenitori, dove il nome del servizio non si risolve. Usa perciò la rete della macchina e raggiunge la banca dati sul loopback. Con il motore alla versione ventinove la pubblicazione sul loopback è raggiungibile dalla sola macchina, e il difetto che fino alla versione ventotto la esponeva ai vicini di segmento non si applica.

La terza è che le due cartelle dei file caricati sono montate dall'host. Senza quelle due righe il difetto della persistenza resterebbe intero. Montandole sull'host restano anche leggibili da chi farà il salvataggio, senza entrare nei contenitori, che è la forma prescritta dalla fase cinque del piano.

## L'ordine del primo rilascio, e perché quest'ordine

I contenuti precedono la costruzione, e non è un dettaglio di comodità. Per ADR-038 la costruzione legge la banca dati e incorpora nelle pagine generate i contenuti che vi trova: costruire contro una banca dati vuota produce un sito le cui pagine sono nate dal nulla, e il guasto non si vede perché il sito funziona. Il 26/10/2026 la copia logica della banca dati di sviluppo è stata ripristinata in produzione e verificata contando le righe su entrambe: trecentoquarantatré tabelle, quattro pagine, ventinove articoli, sei soluzioni e sedici record di media, identici. I file caricati sono stati trasferiti nella stessa occasione e contati dopo il trasferimento.

Il codice precede la costruzione per ragioni ovvie, ma la via con cui arriva è una scelta, presa il 26/10/2026: una chiave di distribuzione dedicata al solo repository del sito, in sola lettura, generata sulla macchina e autorizzata su GitHub. È la via che la roadmap già raccomandava, perché una chiave di distribuzione vale per un solo repository e non porta i permessi di una persona; resta che non ha scadenza e che la sua revoca alla cessazione di un rapporto è un'operazione manuale, il che va presidiato invece che scoperto dopo.

Il nome precede il certificato, perché il proxy ottiene e rinnova da sé il certificato soltanto per un nome che già punta alla macchina. Il primo rilascio avviene su un nome provvisorio e non sul dominio definitivo, deciso il 26/10/2026: il passaggio del dominio aziendale resta una fase a sé, ed è la parte più rischiosa del piano perché quella zona porta scambiatore, due selettori di firma e un mittente autorizzato che termina in rifiuto duro della posta aziendale. Un sottodominio nuovo che punti alla macchina non tocca nessuno di quei record.

La sequenza è dunque questa, e i primi due passi sono già fatti. Ripristinare i contenuti e i file caricati. Scrivere il descrittore e la configurazione del proxy e validarli. Autorizzare la chiave di distribuzione e prelevare il codice dal riferimento di rilascio. Scrivere nella cartella del sorgente il file di ambiente che la costruzione legge, con la banca dati sul loopback. Costruire l'immagine. Far puntare il nome provvisorio alla macchina. Avviare applicazione e proxy, e verificare.

## Il nome provvisorio scelto il 26/10/2026, e perché il sito di anteprima non è pubblico

Il nome è `anteprima.intrawelt.com`. Dice da sé di essere provvisorio, non si confonde con un ambiente di prova permanente, che è una decisione diversa e ancora aperta, e non rischia di restare appiccicato come resterebbe un nome generico. Si crea come un solo record di tipo `A` verso la VPS, dentro la zona che oggi sta presso l'hosting attuale, e sparirà quando la zona si sposterà: è provvisorio per costruzione e non per promessa.

Il proxy ammette però la sola provenienza aziendale, e le ragioni sono due, nessuna delle quali è la prudenza generica. La prima è contrattuale: la licenza del carattere del marchio copre un dominio solo e dichiara che l'uso su un altro dominio o sottodominio ne richiede una seconda, mentre un ambiente raggiungibile dalla sola sede non è un secondo sito servito al pubblico. La seconda è che un sito di prova pubblico finirebbe indicizzato accanto all'originale, e quel danno si ripara lentamente.

La restrizione ha un'eccezione che non è facoltativa: il percorso con cui l'autorità di certificazione verifica il nome resta aperto a chiunque, perché quella verifica arriva da Internet e una restrizione che la respingesse impedirebbe l'emissione del certificato. L'eccezione è scritta esplicitamente nella configurazione anche se il proxy gestisce da sé quella verifica prima delle regole del sito, così che la cosa non dipenda da un dettaglio interno che nessuno qui ha verificato. Il nome ammesso e la provenienza ammessa non stanno nel file di configurazione, che è versionato in un repository pubblico, ma arrivano dall'ambiente della macchina.

Quando il dominio definitivo punterà alla VPS, la restrizione e l'intestazione che scoraggia l'indicizzazione si tolgono nello stesso atto in cui il sito diventa pubblico. Non si lasciano per prudenza: un sito di produzione che respinge il pubblico è un guasto.

## Il record del nome provvisorio non si crea dal pannello: misurato il 26/10/2026

Il pannello dell'hosting mostra per il dominio una pagina di impostazioni DNS che contiene due soli oggetti, cioè i due server di nomi, e il comando per aggiungere un record offre un solo tipo, che è ancora un server di nomi. Non è una limitazione dei permessi dell'utenza: è lo stato di un pannello in cui il servizio DNS per quel dominio è esterno, e che della zona conserva soltanto l'elenco dei server a cui delegarla.

L'interrogazione diretta dei server autoritativi lo conferma e dice dove la zona vive davvero. I server di nomi sono `regulus.fastnet.it` e `rigel.fastnet.it`, il primario dichiarato nel record di inizio autorità è il secondo dei due, e il riferimento di contatto della zona è una casella dell'hosting e non di Intrawelt. La macchina del pannello è un'altra, quella che serve i siti. Ne discende che ogni modifica alla zona passa oggi dall'hosting, e che il record del nome provvisorio si chiede a loro invece di crearlo.

La stessa interrogazione porta un dato che cambia il giudizio sul rischio dell'intera fase del passaggio del nome, e va scritto perché il progetto finora lo trattava come un unico blocco. La posta non è presso l'hosting: lo scambiatore del dominio punta al servizio di protezione della posta di Microsoft 365, e l'hosting detiene soltanto il file di zona che contiene quel record. Il sito attuale invece sta lì, perché il nome con il prefisso del web è un alias verso un nome di macchina che risolve sull'indirizzo del pannello, lo stesso su cui risolve il sottodominio già esistente.

Ne discende la via a rischio minore per la messa in produzione, che non era stata considerata e che conviene mettere accanto alle altre. Si può smettere di usare l'hosting per il sito e lasciare la zona dove sta: al momento del passaggio si chiede all'hosting di cambiare i soli record che portano il web verso la VPS, e scambiatore, mittente autorizzato, selettori della firma e politica di autenticazione non vengono toccati affatto. Il capitolo più pericoloso del piano, cioè lo spostamento di una zona che porta la posta, si evita semplicemente non spostandola.

Tre cose da sapere prima di sceglierla. Ogni modifica alla zona diventa una richiesta all'hosting, compreso l'abbassamento del tempo di validità prima del passaggio e compreso il ritorno indietro se qualcosa va storto, cioè proprio i minuti in cui si vorrebbe poter agire da soli. Il tempo di validità predefinito dichiarato dalla zona è di un giorno, quindi un ritorno indietro non concordato in anticipo si propaga in ventiquattro ore e non in cinque minuti: l'abbassamento va chiesto giorni prima e non durante. E la scelta è incompatibile con la decisione D1 nella sua forma con il fornitore di protezione, che ragiona per dominio radice e richiederebbe comunque di prendere in carico la zona intera.

Una cosa da non fare, perché il pannello la offre e sembra innocua. Il comando che abilita il servizio DNS locale per il dominio farebbe generare al pannello una propria zona, costruita dal suo modello: quella zona non contiene i record della posta su Microsoft 365, e basta che qualcuno in seguito deleghi i server di nomi a quella macchina perché la posta aziendale smetta di essere consegnata. Non si tocca finché la zona è delegata altrove.

## La prima costruzione riuscita sulla macchina di produzione, 26/10/2026

La catena è stata percorsa per intero e si è fermata soltanto dove manca il record del nome. La chiave di distribuzione è stata autorizzata ed è stata verificata dalla macchina, che si autentica al solo repository del sito; la copia di `main` è stata prelevata; il file di ambiente della costruzione è stato scritto con la banca dati sul loopback, come la rete della costruzione impone, e con permessi di lettura al solo utente operativo.

La costruzione è durata due minuti e quarantotto secondi e ha prodotto l'immagine. È la prima volta che la catena arriva in fondo su questa macchina, e vale la pena dire che cosa ha dimostrato oltre al proprio esito: che gli otto gigabyte richiesti dallo script di costruzione erano un tetto concesso all'interprete e non un fabbisogno, e che il passo che copia l'uscita autoconsistente non fallisce più, perché quella configurazione è ora dichiarata sul riferimento di rilascio.

L'applicazione è stata avviata e risponde con esito positivo dentro la rete dei contenitori. Il motore conferma che non pubblica nessuna porta verso la macchina, quindi oggi è raggiungibile soltanto dal proxy, che non è ancora avviato perché senza un nome che punti qui non potrebbe ottenere il certificato.

Due verifiche fra le tre aperte sono state chiuse nella stessa occasione. Le pagine hanno contenuto vero e non pagine generate dal nulla, il che conferma a posteriori la ragione per cui i contenuti dovevano precedere la costruzione: la pagina iniziale pesa centoventun kilobyte, porta il titolo del sito e il pannello di amministrazione risponde. E le due cartelle dei file caricati sono visibili dentro il contenitore ai percorsi attesi, con venticinque file in quella pubblica e uno in quella riservata, cioè gli stessi contati sulla macchina di sviluppo; resta da provare che anche una scrittura nuova dal pannello atterri lì, e quella prova richiede il pannello raggiungibile.

Una cosa va detta perché si vede a schermo e non è un difetto tecnico. Il contenuto costruito da `main` contiene ancora testo di riempimento in una posizione visibile: la seconda delle tre immagini che scorrono sulla pagina iniziale ha titolo e paragrafo in lorem ipsum. Non blocca niente di infrastrutturale e appartiene al progetto del sito, ma è esattamente ciò che la decisione aperta sul contenuto da pubblicare già segnalava, e ora è misurato sul riferimento di rilascio invece che sul banco di prova.

## Il sito risponde sul nome di anteprima, 26/10/2026

Il fornitore dell'hosting ha creato il record richiesto nel pomeriggio del 26/10, con i parametri chiesti e il tempo di validità a trecento secondi. Il nome risolve verso la VPS sia interrogando il server autoritativo sia interrogando un risolutore pubblico, che è la verifica che conta perché il secondo è ciò che vedono i visitatori.

Il proxy è stato avviato e ha ottenuto il certificato alla prima richiesta. Il registro mostra che la verifica dell'autorità è arrivata da cinque punti di controllo distinti e che tutti e cinque hanno ricevuto risposta: è la prova che l'eccezione lasciata aperta nella restrizione era necessaria e corretta, perché senza di essa quelle cinque richieste sarebbero state respinte e il certificato non sarebbe mai stato emesso.

Le prove di esercizio sono tre e sono tutte positive. Dalla postazione aziendale il sito risponde in HTTPS con esito positivo, certificato valido, centoventun kilobyte di pagina e il titolo del sito, in poco più di un secondo. Da una provenienza non ammessa, provata dalla VPS stessa, la risposta è un rifiuto esplicito con il messaggio previsto, quindi la restrizione funziona e il sito di anteprima non è pubblico. Il traffico in chiaro viene rimandato su HTTPS con un reindirizzamento permanente.

Il registro degli accessi del proxy riporta la provenienza reale di chi chiama e non l'indirizzo di loopback, il che chiude metà della verifica che era rimasta aperta su questo punto. L'altra metà, cioè se il framework legga a sua volta l'intestazione che il proxy gli passa, non è stata provata e resta dichiarata come non verificata.

## Che cosa ha confermato il fornitore dell'hosting, e che cosa ne discende

Nella stessa risposta il fornitore ha sciolto le due domande che accompagnavano la richiesta, ed entrambe le risposte sono favorevoli alla via a rischio minore.

Sul tempo di validità ha confermato che può abbassarlo a trecento secondi sui record del web nei giorni che precedono il passaggio e riportarlo al valore normale dopo, a condizione che la data gli venga comunicata in anticipo. Cade quindi il vincolo che rendeva lungo un eventuale ritorno indietro, a patto di pianificare invece di improvvisare.

Sulla separazione fra i due servizi ha confermato che è possibile mantenere presso di loro la sola gestione dei nomi mentre il sito è ospitato altrove, e ha indicato la forma dell'atto: una richiesta di disdetta scritta che riguardi esclusivamente lo spazio web, lasciando attivo il servizio di gestione dei nomi. La via a rischio minore smette quindi di essere un'ipotesi tecnica e diventa una pratica amministrativa con una forma nota.

## Le tre verifiche aperte sono chiuse, 26/10/2026

La prima riguardava dove l'applicazione scrive davvero i file caricati, ed era la sola che richiedesse una scrittura vera invece di una lettura. È stata fatta dal pannello di redazione con l'utenza del redattore, su entrambe le collezioni. Due immagini caricate nella collezione pubblica sono atterrate sulla cartella della macchina, con il peso identico al byte e la scheda che riporta correttamente tipo, dimensione e pixel. Un file caricato nella collezione riservata è atterrato sull'altra cartella della macchina, quella che all'impianto non esisteva e che il descrittore nuovo ha creato. La persistenza è quindi provata su entrambe le collezioni, e il difetto che bloccava il salvataggio è chiuso con una misura e non con un ragionamento.

Nella stessa occasione è stata misurata una cosa che nessuno aveva chiesto e che vale più della prova stessa, cioè se il file riservato sia davvero irraggiungibile. Interrogando il sito dalla provenienza ammessa, le due cartelle non sono servite in nessuna forma diretta, e rispondono come se non esistessero. Il file pubblico si raggiunge soltanto attraverso il percorso applicativo della sua collezione, che risponde con esito positivo. Il file riservato, interrogato sul percorso applicativo della propria collezione senza essere autenticati, viene rifiutato dal controllo di accesso. La separazione fra le due collezioni regge quindi non per convenzione ma per costruzione, ed è la risposta alla domanda che il piano poneva sulla rilettura del controllo di accesso prima della pubblicazione.

La seconda verifica riguardava l'indirizzo reale del visitatore, e si chiude per una ragione diversa da quella attesa. Il registro del proxy riporta la provenienza vera e non il loopback, questo era già misurato; ma la ricerca nel codice del sito non trova nessun punto che usi l'indirizzo di chi visita né l'intestazione che glielo porta. Oggi quindi la domanda non si pone, perché nessuno usa quel dato. Tornerà a porsi quando sarà installato lo strumento di misura del traffico, e a quel punto sarà la configurazione di quello strumento da verificare, non il sito.

La terza riguardava la versione del framework ed era già stata chiusa come rilievo non raggiungibile, perché il codice non usa la funzione colpita. Resta l'aggiornamento da fare prima della pubblicazione sul nome definitivo.

## Due fatti sulla gestione delle immagini, emersi dalla prova

Nessuno dei due è un guasto e ciascuno cambia una regola di lavoro per chi caricherà i contenuti veri.

Il primo è che la collezione pubblica conserva l'originale e non genera versioni ridotte. Nella cartella gli unici file con un suffisso di dimensione sono due residui della vecchia importazione, non prodotti dal sistema. Ne discende che ogni immagine viene servita esattamente come è stata caricata, e che il peso di una fotografia non ridimensionata si paga per intero sul tempo di composizione della pagina, che è proprio la grandezza su cui il presidio dovrà vigilare.

Il secondo corregge un'affermazione fatta in sessione poche ore prima e sbagliata. Era stato detto che un'immagine in CMYK non si sarebbe vista, perché i browser non la disegnano: la prova mostra il contrario, cioè che il file caricato in quello spazio colore si vede correttamente nella scheda del pannello. L'anteprima vuota osservata nell'elenco era un'altra cosa e non autorizzava quella conclusione. Resta vera la raccomandazione generale di caricare in RGB per il web, ma come buona pratica e non come difetto misurato qui.

## Che cosa va verificato dopo il primo avvio, e che oggi non si può dare per fatto

Tre cose sono state progettate e non misurate, e vanno guardate sul primo rilascio invece di essere assunte.

La prima è dove l'applicazione scrive davvero i file caricati. Le due collezioni dichiarano cartelle con percorso relativo, e il descrittore le monta sulla cartella di lavoro dell'applicazione dentro il contenitore; che la risoluzione del percorso dentro l'uscita autoconsistente coincida con quella attesa va verificato caricando un file dal pannello e cercandolo sull'host, non dedotto.

La seconda è l'indirizzo reale del visitatore. Il proxy aggiunge da sé le intestazioni che lo portano, ma che il framework le legga invece di vedere sempre il loopback è una proprietà da leggere in un registro. È la trappola che il precedente interno documenta per esperienza diretta.

La terza è la versione del framework. Quella in uso è `16.3.0`, e l'avviso ufficiale del 22/09/2026 dichiara affette le versioni da `16.2.0` a prima di `16.3.6` per un'esecuzione di codice remoto di gravità critica nell'implementazione Node.js di `ImageResponse`. La ricerca nel codice del sito non trova nessun uso di `next/og` né di `ImageResponse`, quindi il rilievo non è oggi raggiungibile in questa applicazione; resta che la versione è sotto la soglia corretta, e l'aggiornamento va fatto prima della pubblicazione sul nome definitivo, perché una dipendenza che introducesse quell'uso riaprirebbe il rilievo senza che nessuno se ne accorga.

## Che cosa questo rilascio non copre

Non copre il salvataggio, che resta la fase cinque del piano e che ora ha però il proprio presupposto soddisfatto, perché i file caricati vivono su cartelle dell'host e non dentro un contenitore. Non copre la prova di ripristino, senza la quale un salvataggio non è un salvataggio. Non copre il passaggio del dominio definitivo né la decisione sulla protezione davanti al sito, che sono la fase tre-bis e la decisione D1. Non copre il presidio, che per ADR-037 guarda la prestazione e non la sola raggiungibilità. E non cambia nessuno stato della roadmap ISO: finché il sito non è pubblicato e sorvegliato, nessun intervento si chiude per effetto di questo lavoro.
