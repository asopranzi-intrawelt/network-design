# Il sito nuovo: come i suoi sviluppi arrivano in questo progetto

> Scheda aperta il 20/10/2026 su direttiva dell'IT Manager. Il rifacimento del sito non è un progetto applicativo che vive accanto a questo: è materia di rete, perché la sua produzione sta su una VPS di cui Intrawelt ha manutenzione, sviluppo e responsabilità, perché il suo staging è una macchina virtuale del nodo Proxmox attaccata alla LAN piatta, e perché il suo passaggio in produzione sposta una zona DNS che porta la posta aziendale. Lo sviluppo si fa sulla VM e si pilota da qui in SSH.
>
> Questa scheda risponde a una domanda sola: per quale canale gli avanzamenti di quel lavoro entrano qui, così che la roadmap di hardening, la timeline, il registro dei difetti e lo stato ISO non restino indietro senza che nessuno se ne accorga. Il piano di merito è `piano-produzione-sito-nuovo.md`; qui c'è il meccanismo, non il contenuto.

## Perché serve un canale e non la buona volontà

Il problema è quello descritto da `.claude/rules/fonti-e-riallineamento.md` per la classe D, cioè le altre sessioni di lavoro: ciò che viene fatto altrove non notifica, e questo repository impara soltanto ciò che qualcuno vi scrive. Nel caso del sito la condizione è peggiore che per gli altri progetti collegati, per tre ragioni che vanno dette una per una.

La prima è che il lavoro si svolge su una macchina e non su questo disco, quindi nessun percorso locale lo rende osservabile. La seconda è che quel lavoro cambia proprio le cose che questo progetto è incaricato di sapere: porte in ascolto, servizi pubblicati, provenienze ammesse, certificati, nomi di dominio, flussi verso il deposito dei salvataggi. La terza è che il sito ha una data di pubblicazione e la rete no: quando il passaggio in produzione arriverà, arriverà in fretta, e una scheda che descrive correttamente lo stato di tre settimane prima sarà indistinguibile da una aggiornata.

## Il canale, e che cosa fa oggi

Il sito è registrato in `data/scadenze.json` fra i `progetti_collegati`, accanto a `log-collector`, `integrita-docs` e `intrawelt-qa-verifier`, e `scripts/Test-Allineamento.py` lo valuta a ogni avvio di sessione insieme agli altri. La voce differisce dalle altre tre in un punto, ed è il punto che ha richiesto di estendere lo strumento: il repository non ha un `percorso_locale` ma un `percorso_remoto` nella forma `ssh://<alias>/<percorso>`, perché vive sulla VM 209 sotto la cartella dell'utente del sito. L'alias è quello del `~/.ssh/config` della postazione, che non fa parte di questo repository, quindi il registro non contiene né indirizzi né credenziali.

Lo strumento legge allora l'impronta del commit con un comando di sola lettura attraverso SSH, in modalità non interattiva e con un tetto di tempo, e la confronta con `commit_riconciliato` esattamente come fa per un progetto locale. Il working tree non si guarda: uno sviluppo in corso non è una baseline da recepire, ed è la stessa scelta già fatta per gli altri tre.

**Stato al 29/10/2026: il canale è attivo dal 20/10.** Il registro riporta `accesso_stato` a `configurato`, con alias `intra-newsite` e chiave dedicata senza frase di accesso, per decisione dell'IT Manager. Il 29/10 la lettura non interattiva è stata riprovata con esito positivo, e la voce è stata riconciliata su `2ba2c44`. Questa scheda era rimasta al giorno della sua apertura: il 29/10 un agente l'ha letta al posto del registro e ha dichiarato il canale da configurare, mentre funzionava da nove giorni. Il registro in `data/scadenze.json` è la misura; questa scheda racconta come ci si è arrivati. Il paragrafo seguente descrive lo stato del 20/10, prima della configurazione.

Al 20/10 il confronto non si poteva fare, e il registro lo dichiarava invece di nasconderlo. Il campo `accesso_stato` valeva `da_configurare` e il campo `accesso_mancante` dice perché: non esiste un alias per quella macchina nel `~/.ssh/config` della postazione e non esiste una chiave dedicata, perché l'accesso avviene con una password, che è il difetto #226. Finché quel campo resta così, lo strumento riporta la voce in rosso a ogni avvio con il motivo scritto accanto, e non degrada in un generico "non leggibile" che si confonderebbe con un refuso nel percorso. La ragione di questa scelta è la stessa che il registro delle decisioni fissa per il rinfresco delle fonti vive: un'automazione che fallisce in silenzio è peggio dell'assenza di automazione, perché sostituisce un dubbio con una fiducia mal riposta.

Il canale si attiva quindi con un atto solo, che è anche il primo passo della fase 1 e 2 del piano: creare la chiave e l'alias, provarli, e portare `accesso_stato` a `configurato`. Da quel momento ogni commit nuovo sul sito compare all'avvio della sessione successiva senza che nessuno debba ricordarsene.

## Da quale albero si legge, che non è una domanda di dettaglio

Il progetto del sito tiene **tre alberi di lavoro** sulla stessa macchina, e questo cambia dove vive la sua memoria. Il 21/10/2026 il registro delle decisioni contava trentasei voci sul ramo delle consegne grafiche, sedici su quello di integrazione e nessuna sul principale: la memoria versionata descrive la branch e non il progetto, quindi puntare il canale alla cartella del repository invece che all'albero giusto significa leggere una fotografia vecchia che ha l'aria di essere quella corrente.

È successo, e va scritto perché non si ripeta. Il canale è nato il 20/10 puntato sull'albero di integrazione e ha dichiarato allineato un commit di ventisette giorni prima. La risposta era già nel progetto del sito, nel suo ADR-034, che stabilisce che la memoria sta sulla branch più avanti: esisteva una decisione e il canale la ignorava. Dal 21/10 `percorso_remoto` punta all'albero autorevole per percorso assoluto, e i tre alberi sono annotati nel registro.

Ne discende la regola per chi mantiene questo canale, che è quella della norma `alberi-di-lavoro` applicata a un progetto esterno. La memoria si legge dall'albero autorevole e non si copia né si fonde negli altri. Quale sia l'albero autorevole lo decide quel progetto e non questo, quindi la domanda si fa a chi lo tiene invece di dedurla dai nomi dei rami; dove quel progetto abbia già registrato la risposta in una propria decisione, quella vale. E quando gli alberi cambiano, cambia anche il percorso qui: è la ragione per cui il registro porta l'elenco dei tre e non solo il percorso in uso.

## Che cosa si porta qui quando compare un commit nuovo

Il criterio è quello già in vigore per gli altri progetti collegati e non va allargato: si legge il diff e si trasferisce soltanto ciò che cambia topologia, sorgenti, accessi, regole, backup, presidio o stato ISO. Tradotto su questo progetto, sono sei famiglie di fatti.

Le porte e i servizi, cioè che cosa la macchina mette in ascolto e su quale interfaccia. Un passaggio da pubblicazione su tutte le interfacce a pubblicazione sul solo loopback chiude il difetto #161 e va scritto nella scheda dell'esposizione dei servizi, non soltanto nel diario del sito.

Gli accessi, cioè chi può entrare e con che cosa: chiavi aggiunte o revocate, provenienze ammesse, utenti creati, pannelli amministrativi resi raggiungibili o chiusi. È la famiglia che tocca ISO-07 e che nessuno scopre guardando il codice.

I nomi e i certificati, cioè ogni modifica a un record DNS, a un nome di host, a un certificato o alla sua catena di rinnovo. Qui il vincolo della fase 3-bis del piano è assoluto: nulla si tocca sulla zona di `intrawelt.com` senza averla prima esportata e confrontata, perché quella zona porta la posta aziendale.

I flussi verso l'interno, cioè qualunque cosa faccia parlare la VPS con la LAN o con il deposito dei salvataggi. Una copia di sicurezza che risale verso il NAS è un flusso nuovo attraverso il perimetro e appartiene a questo progetto anche se nasce da uno script del sito.

Il presidio, cioè quali segnali la macchina espone e con quale soglia. Per ADR-037 un servizio si sorveglia sulla prestazione e non sulla sola raggiungibilità, e per un sito il valore è il tempo di composizione della pagina.

Lo stato ISO, cioè l'avanzamento degli interventi che il lavoro tocca, oggi ISO-05 sul database della VM 209, ISO-07 sulle credenziali amministrative e ISO-43 sui servizi esterni. L'avanzamento si registra con `IsoRoadmap.py advance` nella stessa sessione in cui la notizia arriva, come lo standard del progetto prescrive, e non alla fine.

## Che cosa non si porta qui

Non si porta il merito applicativo: lo schema delle collezioni del CMS, i blocchi del contenuto, le tassonomie, il frontend, la migrazione dei contenuti e le scelte di design non sono materia di rete e non appartengono a questo repository. La prova che la distinzione regge è che nessuno di quegli oggetti cambia una porta, un accesso, un nome o un flusso.

Non si porta il versionamento. Il repository del sito è del progetto del sito e si governa da lì; questo repository non vi scrive e non lo amministra, e verso quella macchina arriva soltanto in SSH per leggere. Che il codice oggi viva su un disco solo è registrato qui come il difetto #225 e per una ragione di continuità, non perché il rimedio sia nostro.

Non si porta nulla che non sia stato misurato o dichiarato da chi ha titolo. Un avanzamento comunicato si registra come comunicato; un cambiamento su un apparato si registra come verificato solo se qualcuno lo ha verificato, e la roadmap ISO porta già questo limite scritto.

## Il nesso con la roadmap di hardening

Le due cose non sono parallele, sono la stessa cosa guardata da due lati, e conviene dirlo perché è la ragione per cui questa scheda esiste. L'hardening del sito non è un lavoro che comincia quando lo sviluppo finisce: metà delle sue voci sono decisioni di sviluppo. Che il processo applicativo si leghi al loopback invece che a tutte le interfacce è una riga di configurazione del progetto. Che il database non sia pubblicato è una riga del descrittore dei container. Che l'avvio di produzione non sia il server di sviluppo è lo script del pacchetto. Che i cookie siano sicuri e il controllo di accesso stretto è configurazione del CMS. Che la versione del framework chiuda le vulnerabilità note è una dipendenza.

Ne discende la prescrizione operativa di questa scheda: le fasi 3 e 4 del piano non si eseguono sulla macchina di produzione a sviluppo concluso, si eseguono come requisiti sullo sviluppo che si fa sulla VM, e ogni volta che una di quelle righe cambia nel repository del sito, il commit corrispondente è un commit che questo progetto deve leggere. È esattamente ciò che il canale serve a far accadere senza chiederlo.

## Come il modello dei rami del sito incontra la roadmap di produzione

Misurato il 21/10/2026. Il punto comune di tutto il lavoro recente è un commit del 15/09; da lì si diramano tre rami, mentre il ramo principale si è fermato a una fusione di richiesta di incorporazione del 02/09 e non contiene nemmeno quel punto comune. Dei tre, uno è la vetrina della macchina di sviluppo con un commit oltre la diramazione, uno porta il lavoro della fase sugli invii senza commit propri, e il terzo ne porta ventidue e la memoria autorevole del progetto.

Questo assetto nasce dalle decisioni di quel progetto e funziona per ciò per cui è stato pensato, cioè una macchina sola con tre alberi di lavoro paralleli. Incontra però la roadmap di messa in produzione in quattro punti, e tutti e quattro vanno sciolti prima della fase di distribuzione e non durante.

Il primo è che **non esiste un riferimento di rilascio**. La fase 3 prevede che la produzione esegua un'immagine costruita fuori dalla macchina, e una costruzione automatica parte da un riferimento dichiarato. Oggi quel riferimento non c'è: il ramo principale è fermo a settembre, la vetrina significa "la macchina di sviluppo" e il codice più avanti sta su un ramo di lavorazione. Senza una scelta, la prima distribuzione pubblicherebbe un ramo di lavorazione oppure qualcosa di molto indietro.

Il secondo è che **il legame fra ramo e macchina non si estende alla produzione**. La decisione di quel progetto associa ciascun ramo a una macchina, e regge finché le macchine sono alberi di lavoro sullo stesso calcolatore. La VPS non è un albero di lavoro: non contiene un checkout, esegue un'immagine. O compare un quarto ramo e il legame si allunga, o il legame viene sostituito da un modello di rilascio. È una scelta che la roadmap costringe a fare.

Il terzo è che **la deriva della configurazione fra rami è dimostrata e non ipotetica**, ed è il difetto #242. Una correzione di sicurezza al descrittore dei servizi è atterrata in un albero e gli altri due hanno continuato a portare il valore precedente, con un comando ordinario capace di ripristinarlo senza errori. Ogni intervento di irrobustimento che tocchi configurazione ha la stessa forma, perché la configurazione è versionata come il codice e quindi diverge come il codice. Ne discende una regola operativa: una modifica di configurazione infrastrutturale si committa nel giro in cui si fa e si propaga agli altri rami prima che il giro si chiuda, altrimenti non è una correzione ma una correzione in attesa di essere annullata.

Il quarto è che **la memoria autorevole vive su un ramo destinato a sparire**. La decisione che la colloca sul ramo più avanti risolve la domanda su quale memoria valga, ma quel ramo è di lavorazione: quando verrà fuso, la memoria si sposterà. Il canale descritto in questa scheda punta a un percorso, e un percorso non segue una fusione. È già successo, il 20/10, in forma più lieve.

Ne discende la proposta di allineamento, che resta una decisione del progetto del sito e non di questo. Dare un nome al riferimento di rilascio, e la via più coerente con la storia è riportare in vita il ramo principale come ramo di rilascio, perché è già stato quel ruolo una volta e perché dà alla costruzione automatica un bersaglio stabile. Stabilire la direzione in cui scorre la configurazione infrastrutturale, cioè che atterri sul ramo di rilascio e salga nei rami di lavorazione, invece di atterrare sull'albero che capita di avere aperto. E aggiungere alla decisione sulla memoria la clausola che manca, cioè che quando il ramo autorevole viene fuso, il bersaglio del canale si aggiorna nello stesso atto.

## Il modello di rilascio deciso il 21/10/2026, e perché una fusione diretta su main è sbagliata

L'IT Manager ha deciso le tre scelte aperte. Il ramo di rilascio è `main`. `main` si aggiorna **soltanto per richiesta di incorporazione** aperta da un ramo di lavoro, riletta e approvata; la produzione preleva da lì. La configurazione infrastrutturale atterra su `main` e scende nei rami.

Ne discende che la fusione diretta su `main` da riga di comando, che questa sessione aveva preparato come script, è la via sbagliata: aggirerebbe la rilettura che è il punto del modello. Lo script è stato rimosso dalla macchina perché nessuno lo esegua per abitudine. Le richieste di incorporazione si aprono dall'interfaccia web, perché lo strumento a riga di comando installato sulla postazione è autenticato con un account che non vede quel repository, e sulla macchina di sviluppo non è installato affatto.

Va però sciolto un timore espresso in sede di decisione, perché riguarda la sicurezza dell'operazione e la risposta è precisa. Fondere un ramo **dentro** `main` non tocca quel ramo né il suo albero di lavoro: git sposta `main` e nient'altro, quindi i file non ancora committati nei due alberi dove si sta lavorando restano dove sono. Il rischio esiste nella direzione opposta, cioè quando `main` scende in un ramo il cui albero ha modifiche non committate: lì la fusione può rifiutarsi o entrare in conflitto con il lavoro in corso. Quella è proprio la direzione che chiude il difetto #242, e per questo aspetta che chi sta lavorando in quei due alberi committi o metta da parte.

Ne segue l'ordine corretto, che è anche il motivo per cui #242 non si chiude oggi. Prima le richieste di incorporazione verso `main`, che non disturbano nessuno. Poi, quando gli alberi di lavoro sono puliti, la discesa di `main` nei rami, che porta a tutti la correzione della porta del database e diventa la prassi per ogni modifica di configurazione futura.

## Dove vive il materiale di riferimento, dal 21/10/2026

Il materiale che raccontava l'impianto e il disegno del sito viveva sulla postazione, fuori da qualunque controllo di versione, in una cartella separata dal progetto. Su decisione dell'IT Manager è stato consolidato sulla macchina di sviluppo, in `/home/intrawelt-site/riferimenti/`: settecentoventisei file per quaranta megabyte, verificati dopo il trasferimento confrontando l'impronta dei contenuti e non la dimensione. Contiene la guida di impianto e il diario di bordo, il materiale di progettazione del database, la consegna scritta e il materiale di design.

La collocazione è un fratello degli alberi di lavoro e non una cartella dentro uno di essi, benché la richiesta parlasse della radice del progetto. La ragione è pratica: una cartella ignorata da git dentro un albero esiste soltanto in quell'albero, e il progetto ne ha tre, quindi la scelta letterale avrebbe ricreato il problema che il consolidamento voleva chiudere. Essendo fuori da ogni albero, inoltre, non può finire committata per distrazione.

Una sola cosa non è stata spostata, ed è deliberato: la copia di sicurezza dei file caricati dalla redazione resta sulla postazione. È l'unica seconda copia di un contenuto che altrimenti esiste in un esemplare solo, e portarla sulla macchina di sviluppo metterebbe originale e copia sullo stesso disco, riaprendo il difetto #246 invece di mitigarlo.

## Come si scrive una richiesta di incorporazione, dal 21/10/2026

Su direttiva dell'IT Manager il progetto del sito adotta per le descrizioni delle richieste di incorporazione la forma già in uso in un altro progetto della stessa macchina, presa come modello di stile e non come contenuto da importare. Cinque parti fisse, nell'ordine in cui servono a chi legge: perché la richiesta esiste, cioè il problema e mai l'elenco delle modifiche; che cosa cambia, un blocco per intervento con il frammento di prima, quello di dopo e la ragione per cui il primo produceva il guasto; le trappole incontrate, comprese quelle di chi ha preparato il lavoro, perché un percorso raccontato pulito insegna meno di uno vero; le verifiche, con i numeri e non con gli aggettivi; e che cosa va guardato dal vivo, distinguendo ciò che le prove coprono da ciò che non possono coprire. Nessun riferimento agli screenshot, che sono effimeri e rimandano a file che chi verifica cancella.

Sulla collocazione l'IT Manager ha deciso diversamente dal progetto preso a modello, e la differenza va scritta perché è deliberata: **la descrizione vive soltanto nella richiesta di incorporazione**, senza copia locale e senza copia versionata. La ragione è che una descrizione tenuta in due posti è una descrizione da mantenere in due posti, e il luogo dove serve davvero è quello in cui la si legge per approvare. Il progetto preso a modello fa il contrario, cioè tiene la fonte nel repository, e lo fa per costruire una storia consultabile delle proprie consegne: è un bisogno che quel progetto ha e questo no. Le richieste possono essere approvate dall'IT Manager e dal collaboratore che ha costruito il progetto, e chi apre una richiesta non approva la propria.

Questo progetto non traccia le richieste di incorporazione del sito e non ne conserva copia, coerentemente con la stessa decisione: le registra soltanto quando portano un fatto di rete, come la prima, che porta su `main` la correzione della pubblicazione del database.

## Il presidio di questa scheda

La scheda dichiara il proprio modo di invecchiare, perché altrimenti invecchia in silenzio come le altre. Finché `accesso_stato` resta `da_configurare`, questa scheda descrive un canale progettato e non un canale in esercizio, e lo strumento lo ripete a ogni avvio. Quando passerà a `configurato`, la prima cosa da fare non è fidarsi: si legge una volta a mano l'impronta del commit sulla macchina e la si confronta con quella che lo strumento riporta, perché un confronto che risponde non dimostra di leggere la cosa giusta. Solo dopo quella verifica `commit_riconciliato` smette di valere `non_ancora_letto` e prende l'impronta vera.
