# Risoluzione dei nomi interni

> Scheda aperta il 02/09/2026 da una domanda dell'IT Manager — che cosa significa che un nome "sta sul broadcast" — emersa mentre si configurava il primo record interno sul firewall. E' la scheda del micro-step M25 e dell'intervento R12, e raccoglie una materia che il progetto aveva toccato tre volte senza mai spiegarla: ogni volta come sintomo di un guasto, mai come meccanismo.
>
> E' scritta con fondamento didattico secondo la direttiva permanente dei cinque livelli. La risoluzione dei nomi e' l'argomento in cui si sbaglia di piu' proprio perche' funziona quasi sempre da sola: nessuno la configura, tutti la usano, e quando smette di funzionare il guasto si manifesta come "l'applicazione non va" invece che come "il nome non si risolve".
>
> Convenzione. Nomi di servizio e suffissi sono reali. Gli indirizzi seguono i segnaposto di `.claude/rules/anonymization.md`.

## La stessa materia in tre minuti, per chi arriva adesso

Questa sezione dice in forma semplice cio' che il resto della scheda dice con precisione. Serve a chi deve capire il senso dell'intervento senza leggere venti pagine, e usa una similitudine che regge fino in fondo: l'azienda come un ufficio grande.

**Prima: i foglietti.** Ogni postazione ha un foglietto attaccato al monitor con scritto che un certo nome corrisponde a una certa stanza. Funziona. Ma sono venticinque foglietti scritti a mano in momenti diversi da persone diverse, nessuno sa cosa ci sia scritto su quelli degli altri, e se una stanza cambia numero bisogna girare venticinque scrivanie. E' il file degli host.

**E le urla.** Se sul foglietto quel nome non c'e', la postazione urla in corridoio chiedendo chi si chiami cosi', e qualcuno risponde. Funziona soltanto perche' siamo tutti nello stesso corridoio. Il giorno in cui si alzano i muri, cioe' con la segmentazione, le urla non passano piu'. E chiunque puo' rispondere a un'urlata che non lo riguarda, che e' il difetto #180.

**Cio' che si e' fatto: la rubrica in portineria.** I record sul firewall sono una rubrica unica. Da adesso una postazione puo' chiedere in portineria invece di urlare, e la portineria risponde anche attraverso i muri, perche' la domanda ha un destinatario e viene consegnata. Se una stanza cambia numero si corregge una riga invece di venticinque foglietti.

**Il suffisso e' il cognome.** In rubrica i nomi sono scritti per esteso. Le persone pero' dicono il nome corto. Il suffisso e' l'istruzione data alle postazioni: quando senti un nome corto, aggiungici il cognome e poi chiedi in portineria. Cosi' nessuno deve cambiare il modo in cui chiede.

**Indicare l'apparato come server dei nomi e' dire dov'e' la portineria.** I dispositivi sulla rete Wi-Fi del personale chiedevano a un ufficio informazioni fuori dall'edificio, che i nomi interni non li conosce e non puo' conoscerli.

**Un solo server dei nomi, perche' due portinerie si contraddicono.** Indicandone due, ogni tanto la postazione chiederebbe a quella esterna, che risponderebbe correttamente che quel nome non esiste, e ricorderebbe quella risposta per un intervallo. Il risultato sarebbe un nome che funziona quasi sempre e ogni tanto no: peggio di uno che non funziona mai, perche' non si riesce a riprodurlo quando lo si osserva.

**E i foglietti restano dove sono.** La postazione guarda prima il foglietto e poi la portineria, quindi finche' il foglietto c'e' vince lui. E' esattamente il motivo per cui **oggi non e' cambiato niente per nessuno**. La rubrica serve per dopo: per quando i foglietti si toglieranno, e per quando arriveranno i muri.

## Che cosa succede davvero quando digiti un nome

Un computer non sa parlare con i nomi: sa parlare solo con gli indirizzi. Quando digiti `https://intralino/login`, prima che parta un solo pacchetto verso quel servizio, il sistema operativo deve trasformare la parola `intralino` in un indirizzo numerico. Quella trasformazione si chiama *risoluzione*, e avviene prima di tutto il resto.

Il punto che sfugge, e che genera meta' della confusione su questa materia, e' che la risoluzione **non e' un solo meccanismo**. Il sistema operativo ne ha diversi, li prova in un ordine stabilito, e si ferma al primo che risponde. Ne discende che due nomi apparentemente simili possono essere risolti da meccanismi completamente diversi, e che un nome puo' funzionare per anni senza che nessuno sappia chi stia rispondendo.

L'ordine, su una postazione Windows tipica, e' questo. Prima la memoria di cio' che ha gia' risolto di recente. Poi il file degli host, cioe' un elenco scritto a mano sul disco della postazione. Poi il servizio dei nomi configurato, che e' il DNS. E infine, solo se tutti i precedenti hanno fallito, i meccanismi a **domanda diffusa**, che sono il tema di questa scheda.

## Che cosa significa "sta sul broadcast"

Un meccanismo a domanda diffusa funziona nel modo piu' semplice che si possa immaginare: invece di chiedere a un servizio che sa le risposte, si chiede a tutti.

La postazione spedisce sulla rete locale un pacchetto che dice, in sostanza, "chi di voi si chiama `intralino`?". Quel pacchetto non ha un destinatario preciso: viene consegnato a **ogni** apparato del segmento, che lo riceve, lo guarda, e nella quasi totalita' dei casi lo scarta perche' non lo riguarda. La macchina che porta quel nome invece risponde direttamente al mittente: "sono io, ecco il mio indirizzo". Fine.

Su questa rete i meccanismi di questa famiglia sono tre e convivono. Il piu' antico e' quello dei *nomi NetBIOS*[^netbios], eredita' delle reti Windows degli anni Novanta, che risolve i nomi corti delle macchine ed e' ancora attivo per compatibilita'. Il piu' recente in casa Microsoft e' *LLMNR*[^llmnr], introdotto per sostituire il precedente e che fa la stessa cosa in modo piu' moderno. E c'e' *mDNS*[^mdns], nato in ambito Apple e oggi universale, che e' quello che risolve i nomi che finiscono in `.local` e che su questa rete e' attivo su piu' macchine, come il censimento dell'esposizione ha misurato trovando il relativo servizio in ascolto.

Tre pregi spiegano perche' siano ancora in uso. Non richiedono nessuna configurazione: si accende una macchina, dichiara il proprio nome, e da quel momento gli altri la trovano. Non richiedono nessun server: non c'e' niente da installare, mantenere o salvare. E funzionano subito, anche su una rete improvvisata.

Questo e' il senso della frase "oggi `intralino` sta sul broadcast": quel nome non e' scritto da nessuna parte, non c'e' un record in nessun sistema, e nessuno lo ha mai configurato. Funziona perche' la macchina risponde quando qualcuno lo grida sulla rete.

## Perche' e' fragile, e perche' e' un problema proprio adesso

Il difetto discende direttamente dal pregio. Un pacchetto a domanda diffusa **non attraversa i confini di rete**: viene consegnato a tutti gli apparati del proprio dominio di broadcast e si ferma li'. Non e' una limitazione configurabile, e' il modo in cui funziona l'inoltro nelle reti a commutazione: un apparato che separa due segmenti non propaga quel traffico, altrimenti i due segmenti sarebbero un segmento solo.

Su questa rete il difetto oggi non si vede, e la ragione e' precisa: **la LAN e' piatta**. C'e' un unico dominio di broadcast che comprende ogni postazione, ogni telefono, ogni stampante e ogni macchina virtuale, quindi la domanda arriva sempre a destinazione. La risoluzione a domanda diffusa funziona perche' la rete non e' segmentata.

Ne discende la conseguenza che rende questa scheda urgente: **il giorno in cui la segmentazione separera' i servizi dalle postazioni, tutti i nomi che oggi vivono sul broadcast smetteranno di risolvere**, tutti insieme, e senza che nessuno abbia toccato quei nomi. Il guasto si presentera' come "l'applicazione non funziona piu' dopo l'intervento sulla rete", e la diagnosi partira' dall'applicazione, che e' il posto sbagliato.

E' la stessa trappola che questo progetto ha gia' incontrato tre volte in forme diverse: due destinazioni di scansione configurate per nome di macchina invece che per indirizzo, che si romperebbero attraversando un confine; l'ipotesi sbagliata secondo cui il firewall ospitasse gia' record interni, nata dal fatto che interrogando un NAS arrivava una risposta, quando la risposta veniva dal client stesso in multicast; e la fragilita' generale registrata come motivazione dell'intervento R12.

## C'e' anche un problema di sicurezza, e non e' teorico

La fragilita' e' la ragione per cui se ne parla in un progetto di rete. Ce n'e' pero' una seconda, di natura diversa, che vale la pena rendere esplicita perche' non e' intuitiva.

In un meccanismo a domanda diffusa **non esiste alcuna verifica di chi risponde**. La postazione chiede "chi si chiama `intralino`?" e crede alla prima risposta che arriva. Nulla impedisce a un apparato qualunque del segmento di rispondere "sono io" a una domanda che non lo riguarda.

Ne discende un attacco classico e completamente automatizzato: una macchina compromessa sul segmento risponde a tutte le domande diffuse che passano, si fa credere il servizio cercato, e riceve i tentativi di autenticazione destinati a quello vero. Su una rete Windows quei tentativi contengono materiale di autenticazione riutilizzabile. L'attacco non richiede di violare nulla: richiede soltanto di stare sullo stesso segmento e di rispondere piu' in fretta.

Su questa rete tre condizioni gia' documentate lo rendono particolarmente efficace. Il segmento e' uno solo e comprende tutto, quindi chiunque puo' rispondere a chiunque. Alcune credenziali sono condivise fra piu' macchine, quindi cio' che si cattura in un punto vale altrove. E le postazioni non hanno un filtro che limiti da chi accettano risposte. Tracciato come difetto #180.

## Come si esce: chiedere a qualcuno che sa, invece che a tutti

L'alternativa alla domanda diffusa e' il *sistema dei nomi*[^dns], cioe' un servizio a cui le postazioni chiedono e che risponde consultando un elenco. Cambia tre cose rispetto al broadcast, e sono esattamente le tre che servono qui.

La risposta viene da un servizio designato e non da chiunque passi, quindi l'attacco descritto sopra non si applica: la postazione non accetta risposte da altri. La domanda e' indirizzata a un apparato preciso, quindi **attraversa i confini di rete** come qualunque altro traffico, e continua a funzionare quando i segmenti si separano. E i nomi vivono in un elenco unico che qualcuno mantiene, quindi spostare un servizio significa cambiare una riga invece di toccare ogni postazione.

Su questa rete il servizio esiste gia' e nessuno lo sapeva. La verifica dell'ambito DHCP del 30/07/2026 mostra che le postazioni della LAN principale ricevono come primo server dei nomi **il firewall stesso**. Manca solo il contenuto: la lettura della sua configurazione, il 02/09/2026, conferma che la tabella dei record di indirizzo e' vuota e che il firewall si limita a inoltrare ogni domanda a due resolver pubblici.

## L'esempio completo: IntraLino, prima e dopo, passo per passo

Le tre situazioni si capiscono meglio seguendo un singolo pacchetto. La postazione dell'IT Manager sta nella classe delle postazioni, il servizio sta su una macchina virtuale nella classe dei server, e per come e' fatta oggi la rete quelle due classi **non sono due reti**: la maschera `/19` le comprende entrambe, quindi sono lo stesso segmento con due fasce di indirizzi diverse. E' un punto che vale la pena fissare perche' e' la radice di tutto: nella LAN piatta la separazione fra postazioni e server e' una convenzione di numerazione, non un confine.

### Oggi: due postazioni, due meccanismi diversi, e nessuno lo sa

Qui va fatta una distinzione che il primo tentativo di scrivere questa scheda aveva mancato, e che l'IT Manager ha corretto mostrando il proprio file degli host. **Non tutte le postazioni risolvono quel nome allo stesso modo**, e la differenza determina come si romperanno.

Su una postazione **senza** una voce per quel nome nel proprio file degli host, la sequenza e' quella descritta piu' sopra. Memoria: niente. File degli host: niente. Servizio dei nomi, cioe' il firewall: non ha record, inoltra a un resolver pubblico, che risponde correttamente che quel nome su Internet non esiste. Tutti i meccanismi ordinati hanno fallito, e il sistema operativo passa all'ultima risorsa, la domanda diffusa: il pacchetto raggiunge ogni apparato del dominio di broadcast, che essendo la LAN piatta comprende anche la macchina del servizio, la quale risponde. La pagina si apre.

Su una postazione **con** quella voce, e la postazione di chi amministra la rete e' in questo caso, la sequenza si ferma alla seconda fase: il nome e' scritto nel file, il sistema legge l'indirizzo e apre la connessione. **Il firewall non viene nemmeno interrogato**, e la domanda diffusa non parte mai.

Ne discende un fatto operativo che va tenuto presente durante l'intervento, perche' altrimenti fa perdere tempo e induce a conclusioni sbagliate: **dopo aver creato il record sul firewall, una postazione che abbia quel nome nel proprio file degli host continuera' a usare il file**, perche' viene prima nell'ordine. Per collaudare il record bisogna quindi commentare la riga corrispondente, oppure collaudare con il nome completo, che nel file non c'e'.

Ne discende anche che le due popolazioni di postazioni si romperanno per **ragioni diverse** al momento della segmentazione, ed e' una distinzione che conta per la diagnosi. Chi risolve per domanda diffusa smettera' di risolvere perche' il grido non attraversa il confine. Chi risolve per file degli host continuera' a risolvere benissimo, ma **verso un indirizzo che non e' piu' quello del servizio**, perche' la segmentazione lo avra' cambiato: il nome portera' quindi da nessuna parte, e il sintomo sara' un tempo di attesa che scade invece di un nome non trovato. Sono due guasti diversi, con due messaggi diversi, sulla stessa rete e nello stesso momento.

### Dopo la segmentazione, senza aver fatto nulla: il nome smette di funzionare

Si supponga che la segmentazione abbia spostato le postazioni in un segmento proprio e i servizi applicativi interni in un altro, come prevede il piano. Sono ora due domini di broadcast distinti, separati da un apparato che instrada fra loro.

L'utente digita lo stesso indirizzo di sempre. Le prime tre fasi vanno esattamente come prima e falliscono esattamente come prima. Il sistema operativo passa alla domanda diffusa, e qui cambia tutto: il pacchetto viene consegnato a ogni apparato del **suo** segmento, cioe' alle altre postazioni, e si ferma li'. La macchina virtuale del servizio sta in un altro segmento e quel pacchetto non lo vede mai, quindi non risponde. Dopo qualche secondo il navigatore dichiara che il sito non e' raggiungibile.

Sulla postazione che ha la voce nel file degli host il guasto e' diverso e arriva un momento dopo: il nome continua a risolvere, ma verso il vecchio indirizzo, che dopo lo spostamento non risponde piu'. Il sistema non dice che il nome non esiste, dice che non riesce a raggiungerlo.

Ed ecco la parte che rende il guasto insidioso, e che vale piu' di tutto il resto di questa sezione: **la rete funziona perfettamente**. L'instradamento fra i due segmenti c'e', le regole del firewall permettono il passaggio, e se qualcuno prova a raggiungere il servizio **per indirizzo** la pagina si apre normalmente. Non e' caduto niente: e' caduto soltanto il modo in cui quel nome veniva tradotto in indirizzo.

Ne discende il percorso tipico della diagnosi sbagliata. L'utente dice che l'applicazione non funziona. Chi verifica prova per indirizzo, vede che risponde, e conclude che la rete e' a posto e il problema e' del navigatore o dell'applicazione. Nel frattempo la stessa cosa capita a ogni altro nome che viveva sul broadcast, quindi il sintomo e' diffuso e sembra ancora meno legato a un intervento sugli switch. Nella documentazione di questo progetto la stessa trappola compare gia' tre volte in forme diverse, ed e' sempre stata riconosciuta a posteriori.

### Con il nome sul firewall: la domanda ha un destinatario, quindi viaggia

Con il record pubblicato, la sequenza cambia alla terza fase e non arriva mai alla quarta.

L'utente digita l'indirizzo. Il sistema operativo interroga il servizio dei nomi configurato, cioe' il firewall, e questa volta il firewall ha il record e risponde con l'indirizzo della macchina virtuale. Il sistema operativo apre la connessione verso quell'indirizzo, che essendo in un altro segmento viene instradata attraverso il firewall come qualunque altro traffico e sottoposta alle regole. La pagina si apre.

La differenza che fa funzionare tutto e' in una parola: la domanda al firewall e' un pacchetto **indirizzato**, con un destinatario preciso, quindi viene instradata fra i segmenti come qualunque altro traffico. La domanda diffusa non ha un destinatario e per questo non viene instradata. Non e' una questione di permessi o di configurazione: sono due tipi di traffico con destini diversi per costruzione.

### Il secondo guadagno, che si vede solo il giorno dello spostamento

C'e' un beneficio che al momento della configurazione non si nota e che si manifesta la prima volta che un servizio cambia indirizzo, cosa che la segmentazione fara' per piu' servizi.

| Meccanismo | Attraversa i segmenti | Se il servizio cambia indirizzo |
|---|---|---|
| Domanda diffusa | no | si aggiorna da sola, ma tanto non funziona piu' |
| File degli host sulle postazioni | si' | va corretto su **ogni** postazione, una per una |
| Record sul servizio dei nomi | si' | si corregge **una riga**, e vale per tutti |

E' la stessa asimmetria del difetto #171 sugli indirizzi scritti a mano dentro le configurazioni dei servizi, vista dal lato dei client invece che da quello dei server: un dato ripetuto in molti posti si rompe in molti posti, un dato in un posto solo si corregge in un posto solo.

### Che cosa succede al nome corto in tutto questo

Nell'esempio sopra il nome corto continua a essere digitato dall'utente. Perche' la terza fase lo risolva senza che nessuno cambi abitudini serve il suffisso di ricerca descritto nella sezione seguente: la postazione lo attacca al nome corto e domanda al firewall il nome completo, ottiene la risposta, e l'utente non si accorge di nulla se non del fatto che adesso funziona anche da un altro segmento.

Senza il suffisso il nome corto arriverebbe comunque alla quarta fase e continuerebbe a dipendere dalla domanda diffusa, quindi si romperebbe con la segmentazione come prima: il record da solo non basta, servono il record **e** il suffisso.

## Il file degli host di una postazione reale, letto il 02/09/2026

L'IT Manager ha mostrato il proprio file degli host, ed e' il documento piu' istruttivo incontrato su questa materia, perche' mostra in venti righe tutto cio' che la mancanza di un servizio dei nomi produce nel tempo. Vale la pena leggerlo come reperto e non come elenco.

**Cinque convenzioni di nome convivono nello stesso file.** Ci sono nomi corti a un'etichetta sola, per i NAS e per un paio di servizi. C'e' un nome sul suffisso riservato alla scoperta multicast, per l'applicativo di pianificazione. C'e' un nome sul suffisso inventato `.lan`, per il portale asset. Ci sono nomi sotto il dominio pubblico dell'azienda, per un servizio interno. E c'e' un nome di fabbrica di una macchina Windows, quello generato dall'installazione e mai cambiato. Nessuna delle cinque e' sbagliata in se': il problema e' che sono cinque, che nessuna e' dichiarata da nessuna parte, e che chi arriva domani non ha modo di sapere quale usare. E' esattamente la situazione che ADR-018 aveva rilevato a luglio e che ADR-024 chiude.

**Una voce e' ripetuta due volte**, con lo stesso nome e lo stesso indirizzo, in due punti diversi del file. Non fa danno e proprio per questo e' significativa: un file che nessuno rilegge accumula duplicati senza che nessuno se ne accorga, ed e' il segno che quel file cresce per aggiunte successive e non viene mai manutenuto.

**Il nome sul suffisso della scoperta multicast e' una collisione in attesa.** Quel suffisso e' riservato per convenzione al meccanismo in multicast, e su questa rete quel meccanismo e' attivo: scrivere una voce statica per un nome che finisce cosi' significa avere due sistemi che rivendicano la stessa risposta, con l'esito che dipende dall'ordine di consultazione del singolo sistema operativo. Funziona finche' funziona, e quando smette la causa e' fra le piu' difficili da trovare.

**La voce piu' significativa e' pero' un'altra**, ed e' un nome sotto il dominio pubblico dell'azienda che punta a un indirizzo interno. E' un orizzonte separato fatto a mano su una singola postazione: da quella macchina quel nome porta al servizio interno, da qualunque altra porta dove lo manda il sistema dei nomi pubblico. Se il nome esiste anche pubblicamente, quella postazione non potra' mai raggiungere la versione pubblica, e nessuno collegherebbe il sintomo a una riga scritta anni prima in un file di sistema. Nello stesso file, commentate, ci sono due righe che facevano la stessa cosa con **il dominio principale dell'azienda** e con il suo nome canonico, dirottandoli entrambi su una macchina interna: sono disattivate, ma sono li', e basta togliere un carattere.

Ne discende la ragione per cui questo reperto conta piu' del suo contenuto. Questo e' il file di **una** postazione, quella di chi amministra la rete. Le altre ne hanno di propri, scritti in momenti diversi da mani diverse, e nessuno sa cosa contengano: non esiste inventario, non esiste procedura, non esiste modo di sapere quante postazioni dirottino un nome pubblico verso un indirizzo interno. E' la meta' mancante del difetto #119, che registrava la stessa pratica per il pilota del portale asset, e diventa la ragione operativa piu' concreta per completare M25: non tanto pubblicare i nomi, quanto **poterli togliere dai file**.

### Censire i file degli host di tutte le postazioni: si puo', ma non da qui

L'IT Manager ha chiesto il 02/09/2026 di censire il contenuto del file degli host di ogni endpoint gestito. E' la domanda giusta, perche' e' l'unico dato che dice quante postazioni dirottino un nome e verso dove, e nessuna delle fonti automatiche di questo progetto lo possiede. Va pero' chiarito **chi** puo' ottenerlo, perche' la risposta tocca un confine che il progetto si e' dato per iscritto.

Il dato non e' in nessuno snapshot esistente. La gestione remota degli endpoint espone interrogazioni predefinite su sistemi operativi, hardware, interfacce di rete, antivirus e utenti collegati, e nessuna di queste comprende il contenuto di un file. Per ottenerlo bisogna **eseguire un comando sull'endpoint**, che e' un'operazione di natura diversa dalla lettura di un inventario.

Qui il termine "sola lettura" si sdoppia, e conviene tenerne separati i due sensi. Leggere un file **sull'endpoint** e' un'operazione che non modifica nulla: e' lettura in senso pieno. Ma per farla eseguire dalla gestione remota bisogna creare o lanciare uno script **dentro la piattaforma**, e questa e' un'operazione di scrittura sulla piattaforma, oltre che l'esecuzione di codice su postazioni di lavoro altrui. ADR-017 stabilisce che questo progetto interroghi quella piattaforma **solo in lettura e solo come fotografia**, con credenziali di ambito di sola osservazione che appartengono al fornitore che la gestisce: con quelle credenziali l'operazione non e' semplicemente sconsigliata, non e' proprio autorizzata.

Ne discende che la strada non passa dagli script di questo repository. Passa dall'IT Manager, che alla console di quella piattaforma puo' lanciare un comando sugli endpoint Windows e raccoglierne l'esito, e dal quale il progetto riceve il risultato come riceve uno screenshot: un dato da ingerire, non un dato da andare a prendere. E' la stessa distinzione gia' applicata alla interfaccia del firewall, che resta una fonte di classe E proprio perche' si legge solo tramite una persona.

Il comando da lanciare li' e' una riga, e va ricordato che l'esito contiene nomi host e indirizzi reali di ogni postazione, quindi appartiene a `_notes/` e non a un file tracciato.

```powershell
Get-Content $env:SystemRoot\System32\drivers\etc\hosts | Where-Object { $_.Trim() -and $_ -notmatch '^\s*#' }
```

Il filtro toglie righe vuote e commenti, che su un file appena installato sono la quasi totalita' del contenuto: senza di esso il risultato sarebbe illeggibile e coprirebbe cio' che interessa. Vale la pena notare che il filtro esclude anche le righe **commentate**, che come si e' visto possono contenere dirottamenti disattivati ma pronti: su un censimento generale e' il compromesso giusto per la leggibilita', ma se dal risultato emergessero postazioni interessanti quelle andrebbero riguardate senza filtro.

Tre cose da cercare nel risultato, in ordine di gravita'. I nomi sotto il dominio pubblico dell'azienda che puntino a indirizzi interni, perche' impediscono a quella postazione di raggiungere la versione pubblica e nessuno lo collegherebbe mai a un file di sistema. Gli indirizzi che non corrispondono piu' a nulla, cioe' voci rimaste da servizi dismessi, che oggi non fanno danno e diventeranno guasti quando quegli indirizzi verranno riassegnati. E le convenzioni di nome in uso, che dicono quali abitudini vadano sostituite dai record e quante persone andranno avvisate.

### L'esito del censimento, 02/09/2026: diciotto postazioni, e il quadro e' piu' grande del previsto

L'automazione e' stata lanciata su venticinque postazioni e diciotto hanno risposto; le altre erano spente e l'esecuzione resta in coda. Gli esiti sono stati raccolti in sola lettura dal registro delle attivita' con `scripts/Get-NinjaScriptOutput.ps1`, che restituisce il testo **intero** mentre il pannello della console lo tronca.

Il conteggio complessivo e' di **ottanta nomi distinti** su diciotto file, con una distribuzione molto disuguale: si va da una postazione con una sola riga a una con cinquantatre. Non e' un parco configurato in modo uniforme, e' una sedimentazione.

#### Il dato che serviva, e conferma il timore

**`intralino` compare in tutti e diciotto i file.** Non su qualcuno: su tutti. Ne discende che il record che stiamo per pubblicare sul firewall sarebbe oscurato su ogni postazione del parco, perche' il file viene prima. Il record da solo non cambierebbe nulla per nessuno, e senza il censimento lo avremmo scoperto interrogando una macchina a caso e concludendo che il firewall non funziona.

Seguono per diffusione il nome di un NAS, presente in quindici file, e il nome di fabbrica del server Windows, presente in undici. Sono i tre nomi da pubblicare per primi, perche' sono quelli su cui la rimozione delle righe romperebbe piu' gente.

#### Trenta domini pubblici dirottati su indirizzi interni

E' il ritrovamento piu' importante, e non riguarda la risoluzione dei nomi ma il governo dei dati. Su alcune postazioni sono presenti **circa trenta nomi di dominio pubblici dell'azienda**, quelli dei siti dei servizi di traduzione, tutti dirottati verso un **unico indirizzo interno**. Su altre postazioni compaiono altri tre domini pubblici, fra cui uno di dimostrazione e uno di un cliente, dirottati verso un secondo indirizzo interno. E c'e' il nome gia' noto del gestionale, dirottato su sei postazioni.

Due postazioni portano inoltre il dominio principale dell'azienda e il suo nome canonico dirottati verso un indirizzo **pubblico** diverso da quello attuale, verosimilmente un hosting precedente.

Ne discendono tre problemi distinti, e conviene separarli perche' hanno rimedi diversi.

Il primo e' che quelle postazioni **non possono raggiungere la versione pubblica** di quei siti. Chi ci lavora vede sempre e solo la copia interna, anche quando vuole controllare cosa vedono i clienti, e non ha modo di accorgersene se non sospettandolo.

Il secondo e' che il dirottamento **sopravvive alla ragione per cui fu fatto**. Erano quasi certamente prove di migrazione o di anteprima: si punta il dominio alla macchina di collaudo, si verifica, e si dovrebbe rimettere a posto. Le righe sono rimaste, e nessuno sa piu' quali siano ancora volute.

Il terzo si manifestera' con la segmentazione: quegli indirizzi interni cambieranno, e le righe continueranno a puntare al vecchio, quindi quelle postazioni raggiungeranno un indirizzo morto o, peggio, una macchina diversa che nel frattempo lo avra' ereditato.

Tracciato come difetto #181.

#### Voci che reindirizzano a se stessi i servizi di attivazione di alcuni programmi

Su alcune postazioni compaiono voci che puntano all'indirizzo di *loopback*, cioe' alla postazione stessa, i domini di **attivazione, aggiornamento e telemetria** di alcuni programmi commerciali, piu' tre indirizzi pubblici nudi. L'effetto tecnico e' che quei programmi non riescono a contattare il proprio produttore.

Il fatto va riportato per quello che e', senza inferenze: questo progetto non sa perche' quelle righe siano state scritte. Va pero' segnalato che il rimedio ha comunque due conseguenze da valutare a prescindere dal motivo. La prima e' che **un programma che non raggiunge il proprio produttore non riceve nemmeno le correzioni di sicurezza**, quindi resta alla versione installata per sempre; e' un difetto di manutenzione che vale anche se il blocco fosse stato messo per ridurre la telemetria. La seconda e' che la configurazione delle licenze dei programmi in uso non e' nel perimetro tecnico di questo progetto ma appartiene al governo degli asset, e va guardata da chi ne risponde.

Tracciato come difetto #182, con la riserva esplicita che la causa non e' accertata.

#### Un refuso propagato, che chiude una domanda vecchia

Il nome di fabbrica del server Windows compare in due grafie diverse: undici postazioni ne portano una, due postazioni una variante che ha **un carattere in meno**. E' lo stesso refuso registrato come difetto #106, che il progetto aveva rilevato in un documento sorgente e non sapeva se fosse un errore di trascrizione o due macchine diverse. Ora si sa: e' un refuso, ed e' stato copiato in due file degli host, presumibilmente per copia-incolla da quel documento.

Su quelle due postazioni il nome sbagliato risolve comunque, perche' e' scritto nel loro file e punta all'indirizzo giusto. Il guasto e' l'opposto e piu' sottile: **il nome corretto, su quelle due macchine, non risolve**, perche' li' non c'e'. Finche' tutti usano il nome sbagliato funziona; il giorno in cui qualcuno usa quello giusto, non funziona su due macchine su diciotto e nessuno capisce perche'.

#### Altre incoerenze minori, tutte della stessa famiglia

Tre nomi di NAS compaiono in maiuscolo su alcune postazioni e in minuscolo su altre, il che tecnicamente non fa differenza ma segnala che le righe sono state scritte in momenti diversi da persone diverse copiando l'una dall'altra in modo impreciso.

Le voci che il programma di contenitori aggiunge da se' contengono **l'indirizzo della postazione stessa scritto a mano**, e risultano con tre indirizzi diversi su tre macchine. Una di esse porta un indirizzo che non appartiene alla rete aziendale, segno di un portatile configurato mentre era su un'altra rete: su quella macchina quelle voci sono gia' sbagliate adesso.

Ne discende la conclusione generale che vale piu' dei singoli casi: **un file degli host non ha scadenza, non ha proprietario e non ha revisione**. Cresce per aggiunte, conserva per sempre decisioni prese per mezz'ora, e nessuno lo rilegge finche' qualcosa non si rompe. E' esattamente il motivo per cui la risoluzione centralizzata non e' un miglioramento di comodita' ma di governo.

### La regola che garantisce zero telefonate, e la sola eccezione

La domanda posta dall'IT Manager il 02/09/2026 e' la piu' importante di tutto l'intervento: dopo la pubblicazione dei record, qualcuno dovra' cambiare i propri collegamenti? La risposta e' **no**, e vale la pena mostrare perche', perche' non e' ovvia e perche' regge solo se si rispetta una regola.

La regola e' questa: **per ogni nome che si toglie da un file degli host deve esistere un equivalente che risolva allo stesso modo**. Se l'equivalente c'e', la rimozione e' invisibile; se manca, quella riga in meno e' un servizio irraggiungibile per chi la aveva. Non ci sono vie di mezzo, e non e' un rischio da valutare caso per caso: e' una verifica meccanica da fare prima di ogni rimozione.

Applicata ai nomi trovati dal censimento, la regola produce tre categorie.

I **nomi corti** sono coperti dal suffisso di ricerca. Chi digita un nome a un'etichetta sola vede la postazione completarlo con il suffisso e interrogare il firewall, che risponde. L'utente digita quello di sempre e ottiene lo stesso indirizzo di sempre: nessun collegamento da aggiornare, nessun segnalibro da rifare, nessuna telefonata. E' il caso della grande maggioranza delle voci censite.

I **nomi gia' qualificati** non ricevono il suffisso, perche' il sistema li considera gia' completi. Per questi la copertura si ottiene pubblicando **lo stesso identico nome** come record, cosa che per un nome ordinario non pone alcun problema: si aggiunge una riga in piu' e la rimozione dal file resta invisibile. E' il caso del nome del portale asset sul vecchio suffisso, che va quindi pubblicato tale e quale accanto al nome nuovo.

L'unico nome per cui la copertura **non e' ottenibile** e' quello dell'applicativo di pianificazione, che vive sul suffisso riservato alla scoperta multicast: pubblicarlo tale e quale sul firewall non sarebbe affidabile, perche' quel suffisso e' rivendicato anche dal meccanismo in multicast e l'esito dipenderebbe dall'ordine di consultazione di ciascun sistema operativo.

Va pero' detto con precisione che cosa ne discende, perche' il primo istinto porta alla conclusione sbagliata. **Non ne discende che tre persone debbano cambiare qualcosa.** Ne discende che quella singola riga, su quelle tre postazioni, **non si rimuove**: resta dov'e' e continua a funzionare esattamente come oggi. La regola non e' stata violata, e' stata applicata — l'equivalente manca, quindi la riga non si tocca.

L'intervento e' percio' trasparente per **tutti**, senza eccezioni: nessuno cambia collegamenti, nessuno cambia abitudini, nessuno riceve comunicazioni. La differenza fra quel nome e gli altri e' soltanto che gli altri, un domani, si potranno anche ripulire dai file, mentre quello no finche' qualcuno non decidera' di far passare tre persone al nome nuovo. E' una scelta futura e facoltativa, non un passo di questo intervento.

### I servizi raggiunti per indirizzo, che oggi non cambiano e domani si'

L'IT Manager ha segnalato che sulla macchina del server Windows convivono altri due applicativi web, raggiunti per **indirizzo** e non per nome. Il fatto e' importante per due ragioni opposte.

Oggi non cambia nulla per loro, perche' un collegamento scritto con l'indirizzo non passa dalla risoluzione dei nomi: ignora sia i file degli host sia il firewall. Sono quindi fuori dall'ambito di questo intervento e nessuno dovra' toccare quei collegamenti adesso.

Domani cambia tutto, ed e' il motivo per cui vanno affrontati ora e non poi. Quando la segmentazione spostera' quella macchina, il suo indirizzo cambiera' e **ogni collegamento scritto con l'indirizzo smettera' di funzionare insieme**, senza che nessuno li abbia toccati, e senza che esista un modo per sapere quanti siano e chi li abbia. Un nome invece si aggiorna in un punto solo.

Ne discende un'aggiunta all'intervento che costa nulla adesso e risparmia il giro delle postazioni dopo: **pubblicare fin da subito un nome per ciascuno di quei servizi**, scelto per ruolo, e cominciare a usarlo al posto dell'indirizzo. Piu' nomi possono puntare allo stesso indirizzo: non c'e' alcun conflitto, e' la situazione normale di un server che ospita piu' applicazioni. Chi vuole continuare con l'indirizzo lo puo' fare finche' quell'indirizzo esiste, ma da quel momento esiste anche l'alternativa, ed e' quella che sopravvivera'.

Va notato che questo e' l'unico punto dell'intervento in cui si chiede a qualcuno di cambiare abitudine, e lo si chiede senza scadenza e senza rompere nulla nel frattempo: la vecchia strada resta aperta finche' la segmentazione non la chiude da se'.

## Le due voci verso indirizzi pubblici, verificate il 02/09/2026

Il censimento aveva lasciato aperte due voci che puntavano a indirizzi **pubblici** invece che interni, e per le quali non si poteva dire se fossero valide o residue. La verifica consiste nel chiedere a un resolver pubblico che cosa risponda oggi per quei nomi e confrontare.

Il **dominio principale dell'azienda** risulta oggi risolto, attraverso un alias, verso un indirizzo che differisce di **una sola cifra** da quello scritto nei file degli host di due postazioni. Non e' quindi lo stesso indirizzo, ed e' verosimilmente una macchina adiacente dello stesso fornitore, o la precedente. Ne discende che quelle due voci sono **residui e vanno rimosse**: quelle postazioni oggi raggiungono un indirizzo che non e' quello del sito aziendale, e nessuno se ne e' accorto perche' probabilmente risponde comunque qualcosa. La vicinanza fra i due numeri e' la ragione per cui l'errore e' passato inosservato: a occhio sembrano lo stesso indirizzo.

L'IT Manager ha inoltre chiarito il 02/09/2026 che il sito aziendale **non e' piu' ospitato dove quelle righe puntavano**, perche' il rifacimento in corso vive su una macchina virtuale dedicata: quelle voci non hanno quindi piu' alcuna funzione neanche potenziale, e la risoluzione pubblica e' l'unica corretta per chiunque.

Il nome del **portale documentale** risulta invece risolto verso esattamente l'indirizzo scritto nel file, quindi la voce duplica cio' che il sistema dei nomi pubblico gia' risponde e sarebbe innocua. La prova pero' non si e' fermata alla risoluzione, ed e' andata bene che sia stato cosi'.

### Un guasto trovato mentre se ne cercava un altro: il portale documentale non risponde

Interrogato da un navigatore, il portale documentale restituisce un errore di tempo scaduto. Il fatto va separato con cura da tutto il resto di questa scheda, perche' e' facile attribuirlo all'intervento in corso e non c'entra nulla.

Che non sia un problema di risoluzione e' dimostrato: il nome risolve, e risolve verso lo stesso indirizzo che risponde il sistema dei nomi pubblico. La traduzione da nome a indirizzo funziona; e' il passo successivo, cioe' raggiungere quell'indirizzo, che fallisce.

Il **modo** in cui fallisce e' informativo, ed e' il genere di dettaglio che distingue due cause opposte. Un tempo scaduto significa che i pacchetti partono e non torna nulla, quindi qualcosa li scarta silenziosamente lungo il percorso: un filtro, una rotta che non arriva, un tunnel caduto. Se il servizio fosse semplicemente fermo sulla macchina di destinazione, la risposta sarebbe un rifiuto immediato e non un'attesa. Vale la pena tenerlo a mente come regola di lettura generale: attesa che scade significa percorso, rifiuto immediato significa servizio.

Ne discendono tre ipotesi, da distinguere in quest'ordine perche' ciascuna e' meno probabile della precedente. Il percorso passa per il tunnel cifrato verso il fornitore esterno e il tunnel e' caduto. Il servizio filtra per indirizzo di provenienza e l'indirizzo pubblico dell'azienda non e' piu' fra quelli ammessi. Il servizio e' stato fermato dal fornitore.

Il fatto va letto insieme al difetto #117, che registra dal luglio 2026 la perdita della configurazione cifrata su quel medesimo portale e il ripristino sul solo canale in chiaro: e' lo stesso servizio, gia' fragile, e vale la pena chiedersi se sia un seguito di quell'incidente mai chiuso del tutto. Tracciato come #183.

Non appartiene a questo intervento e non lo blocca: la voce nel file degli host va rimossa comunque, perche' la sua presenza o assenza non cambia nulla dell'esito.

E' un esempio istruttivo della regola dell'equivalente applicata a un caso che non riguarda i nomi interni: l'equivalente non deve necessariamente essere un record che creiamo noi, puo' essere una risposta che qualcun altro gia' da'.

### Come si distribuisce il suffisso su questo firewall, che non ha il campo per farlo

Dettaglio operativo registrato il 03/09/2026, perche' e' il genere di cosa che fa perdere mezz'ora a chi lo rifara'. Sull'apparato in uso **non esiste un campo chiamato nome di dominio** nelle impostazioni dell'ambito DHCP: chi lo cerca non lo trova, e la prima conclusione naturale, cioe' che l'apparato non sappia farlo, e' sbagliata.

La ragione e' che il costruttore espone come campi propri soltanto le informazioni piu' usate fra quelle che un server DHCP distribuisce, cioe' indirizzo, maschera, gateway, server dei nomi e durata, e lascia tutte le altre a una tabella di **opzioni estese** dove ciascuna si indica con il proprio numero invece che con il proprio nome. Non e' una funzione mancante: e' la stessa funzione raggiunta per un'altra strada.

Le informazioni che un server DHCP distribuisce sono infatti numerate da uno standard, e il nome di dominio e' la **quindicesima**. Nella tabella delle opzioni estese si aggiunge quindi una voce con opzione definita dall'utente, un'etichetta libera che serve solo a chi legge, il numero quindici, il tipo testuale e come valore il suffisso scelto. Il sistema operativo delle postazioni la riceve come suffisso della connessione, ed e' precisamente quel valore che usa per completare i nomi corti prima di interrogare il servizio dei nomi.

Due avvertenze pratiche. Le opzioni estese sono **per interfaccia** e non si ereditano, quindi la stessa voce va ripetuta su ogni ambito DHCP che debba distribuire il suffisso: nel caso di questa rete la LAN principale e la rete Wi-Fi del personale, e non quella degli ospiti. E la modifica richiede **due conferme in sequenza**, quella della finestra dell'interfaccia e quella della pagina, perche' fino alla seconda la riga resta solo a schermo; l'apparato la segnala con un contrassegno sulle celle modificate, che e' facile non notare.

### La rete Wi-Fi del personale interrogava resolver pubblici, e perche' era ragionevole

La correzione applicata il 03/09/2026 sull'ambito della rete Wi-Fi del personale merita una spiegazione, perche' altrimenti sembra la correzione di una svista e non lo e'.

Quell'ambito distribuiva come server dei nomi due resolver pubblici invece del firewall. Quando fu creato, nel luglio 2026, era la scelta giusta: sul firewall non esisteva alcun record interno, quindi indicarlo come server dei nomi avrebbe aggiunto un passaggio senza aggiungere una risposta, e i due resolver pubblici facevano lo stesso lavoro con un salto in meno. La scelta e' diventata sbagliata nel momento in cui i record sono stati creati, cioe' pochi giorni fa, e non lo era prima. E' il tipo di configurazione che invecchia per un cambiamento avvenuto altrove, ed e' anche il motivo per cui va corretta contestualmente e non dopo: dimenticandola, i nomi interni funzionerebbero dal cavo e non dal Wi-Fi, e il sintomo manderebbe la diagnosi ovunque tranne che nell'ambito DHCP di una rete virtuale.

Sulla maschera va notato che il campo del server dei nomi e' un **menu a scelta**, non una casella di testo. Le voci disponibili comprendono l'apparato stesso e la definizione manuale di un indirizzo; scegliendo la prima la casella accanto sparisce, perche' non c'e' piu' nessun indirizzo da indicare. Scrivere il nome dell'apparato dentro la casella della definizione manuale non funziona, perche' quel campo attende un indirizzo.

### Perche' il secondo server dei nomi va lasciato vuoto

La domanda nasce spontanea: perche' non tenere un resolver pubblico come secondo, per sicurezza? La risposta e' che qui quel ripiego non copre nulla, e in cambio introduce un difetto.

Un secondo server protegge dal caso in cui il primo non risponda. Il primo, qui, e' il firewall, che di quella rete e' **anche il gateway**: se il firewall non risponde, i dispositivi di quella rete non raggiungono comunque nulla, perche' ogni pacchetto diretto fuori dal proprio segmento passa da lui. Il ripiego coprirebbe quindi esattamente lo scenario in cui e' inutile.

In cambio introdurrebbe un comportamento non deterministico. In certe condizioni il sistema operativo interroga anche il secondo server, che per un nome interno risponde in modo corretto e definitivo che quel nome non esiste, e quella risposta negativa puo' restare in memoria per un intervallo. Il sintomo sarebbe un nome interno che funziona quasi sempre e ogni tanto no, senza una regolarita' riproducibile, che e' fra i guasti piu' difficili da diagnosticare perche' non si riesce a farlo accadere quando si guarda.

Ne discendeva la scelta di lasciarlo vuoto, che era anche quella gia' in uso sulla LAN principale.

**Questa raccomandazione e' stata smentita dai fatti il 03/09/2026 e va considerata sbagliata.** Applicata alla rete Wi-Fi del personale ha prodotto un'interruzione: i dispositivi hanno perso la risoluzione dei nomi e con essa l'uso della rete, ed e' il difetto #185.

L'argomento aveva un buco che vale la pena isolare, perche' e' un errore di ragionamento e non un errore di configurazione. Diceva che un ripiego fosse inutile perche' il firewall e' anche il gateway, quindi se non risponde non c'e' comunque rete. Ma **sull'apparato convivono servizi distinti**: l'instradamento e la risoluzione dei nomi sono due funzioni separate che si guastano in modo indipendente, e in questo caso l'instradamento funzionava perfettamente mentre la risoluzione no. Trattare i due come una cosa sola ha trasformato un difetto di configurazione in un'interruzione di servizio.

La raccomandazione corretta e' l'opposta: **sulle reti servite da un solo resolver interno si tiene un secondo server pubblico**. Il ripiego non e' ridondanza inutile ma copertura di un guasto reale e distinto, e il difetto teorico che si temeva — risposte negative dalla fonte pubblica per i nomi interni — e' un inconveniente minore rispetto a un'interruzione.

## Perche' nessun utente deve cambiare nulla: la dimostrazione caso per caso

La domanda e' stata posta due volte dall'IT Manager, ed e' quella giusta: se si pubblicano nomi nuovi, chi usa quei servizi dovra' essere avvisato? La risposta e' no, e non e' una rassicurazione ma una conseguenza che si dimostra. Vale la pena scriverla per intero, perche' e' l'affermazione su cui si regge la decisione di procedere senza comunicazione preventiva a tutta l'azienda.

Il fondamento e' uno solo: **pubblicare un record e' un'operazione additiva**. Non rimuove niente, non sostituisce niente, non modifica il comportamento di nulla che gia' funzioni. Aggiunge una risposta possibile a una domanda che oggi trova risposta altrove o non la trova affatto. Da questo discendono i quattro casi, che coprono ogni utente e ogni servizio.

**Primo caso, chi usa un nome che ha nel proprio file degli host.** E' la situazione della maggioranza, e per il nome di IntraLino e' la situazione di tutti e diciotto i file censiti. Il file viene consultato **prima** del servizio dei nomi: finche' quella riga esiste, la risposta arriva da li' e il firewall non viene nemmeno interrogato. Non c'e' quindi neanche un cambiamento teorico: la strada nuova esiste ma nessuno la percorre.

**Secondo caso, chi usa un nome che nel proprio file non c'e'.** Oggi quel nome si risolve per domanda diffusa, e funziona perche' la rete e' piatta. Da adesso si risolvera' per interrogazione al firewall, che risponde con lo stesso identico indirizzo. L'utente digita quello di sempre e arriva dove arrivava prima: cambia il meccanismo, non il risultato. E' l'unico caso in cui qualcosa cambia davvero, ed e' invisibile per costruzione.

**Terzo caso, chi usa un indirizzo invece di un nome.** E' la situazione dei due applicativi web sul server Windows e di ogni collegamento scritto con i numeri. Un indirizzo non passa dalla risoluzione dei nomi: ignora sia i file sia il firewall. Non cambia nulla, oggi ne' domani, finche' quell'indirizzo esiste.

**Quarto caso, un servizio che ne chiama un altro dal proprio codice o dalla propria configurazione.** Se lo chiama per indirizzo vale il terzo caso e non cambia nulla. Se lo chiama per nome valgono il primo o il secondo, a seconda che sulla macchina che lo esegue quel nome sia scritto in un file oppure no. In entrambe le forme il risultato e' lo stesso indirizzo di prima.

Ne discende la conclusione, che vale la pena enunciare come regola generale e non come esito di questo intervento: **finche' ci si limita ad aggiungere record, non esiste un modo per rompere qualcosa**. Il rischio nasce solo con la rimozione delle righe dai file, che e' un'operazione diversa, successiva, facoltativa, e governata dalla regola dell'equivalente descritta sopra.

## Perche' il servizio dei nomi serve ai passi successivi, e non e' un fine in se'

Il secondo chiarimento chiesto dall'IT Manager riguarda il senso dell'operazione: perche' costruire un servizio dei nomi interno se oggi tutto funziona senza. La risposta e' che quattro lavori gia' pianificati lo richiedono, e nessuno dei quattro puo' procedere senza.

**I certificati.** Un certificato certifica un nome e il navigatore lo verifica contro il nome digitato. Senza nomi risolvibili non si possono emettere certificati utilizzabili, quindi resta bloccato il collegamento del gestore delle password, che oggi non e' raggiungibile affatto, e resta bloccata la riemissione del certificato di IntraLino dalla nuova autorita' aziendale. E' la dipendenza che ha fatto scoprire tutto il resto.

**La segmentazione.** Quando i servizi cambieranno segmento cambieranno indirizzo. Con un servizio dei nomi si corregge un record e vale per tutti; senza, si tocca ogni postazione una per una. E soprattutto i nomi che oggi vivono sulla domanda diffusa smetteranno di risolvere del tutto, tutti insieme e senza che nessuno li abbia toccati.

**La zona di pubblicazione.** Un proxy inverso smista le richieste in base al **nome** richiesto, non alla porta. Senza nomi si puo' solo pubblicare per porta, che e' esattamente cio' che oggi rende difficile governare IntraLino con i suoi quattro servizi su quattro porte diverse: ogni porta e' una regola in piu' da aprire in ogni filtro futuro.

**La pulizia dei file degli host.** Non si possono togliere quelle righe finche' non esiste un equivalente che risolva allo stesso modo. Il servizio dei nomi **e'** quell'equivalente: senza, i file restano dove sono, con tutto cio' che il censimento vi ha trovato dentro.

Ne discende che questo intervento non e' un miglioramento facoltativo di comodita' ma il primo anello di una catena: e' il pezzo che i tre lavori successivi presuppongono, ed e' anche il piu' economico dei quattro perche' il resolver esisteva gia' e mancava solo il contenuto.

## Lo stato al 02/09/2026: diciassette record pubblicati

I record sono stati creati sul firewall dall'IT Manager. La pagina non ha un pulsante di conferma separato: le voci si applicano al salvataggio di ciascuna.

| Nome | Serve | Nota |
|---|---|---|
| `intralino.int.intrawelt.com` | IntraLino | presente in tutti e diciotto i file censiti |
| `nas-intra2.int.intrawelt.com` | NAS | in quindici file |
| `win-v712i9qhqt9.int.intrawelt.com` | server Windows | nome di fabbrica, tenuto per compatibilita' |
| `presenze.int.intrawelt.com` | rilevazione presenze | nome di ruolo nuovo, oggi il servizio si raggiunge per indirizzo |
| `timewalker.int.intrawelt.com` | secondo applicativo sulla stessa macchina | come sopra |
| `egetrad.int.intrawelt.com` | gestionale precedente | |
| `nas-intra3.int.intrawelt.com`, `nas-intra.int.intrawelt.com`, `nas-hero.int.intrawelt.com` | i tre NAS | |
| `convertitore-ruolini.int.intrawelt.com` | convertitore | |
| `gantttool.int.intrawelt.com` | pianificazione | sostituisce il nome sul suffisso della scoperta multicast |
| `vault.int.intrawelt.com` | gestore delle password | prerequisito del suo collegamento |
| `asset.int.intrawelt.com` e `asset.intrawelt.lan` | portale asset | il secondo per non rompere chi usa il nome vecchio |
| `sito-staging.int.intrawelt.com` | ambiente del sito | |
| `analyst.int.intrawelt.com` | macchina di analisi | |
| `ollama.int.intrawelt.com` | host di inferenza | |

Non sono stati creati, su indicazione dell'IT Manager: il nome della condivisione documenti e quello del servizio di trasferimento file, che non esistono piu'; il nome del sistema di ticket, la cui natura non e' nota a chi amministra pur essendo il servizio in ascolto sulla macchina del gestore delle password, il che rinforza il difetto #178; il nome del server di licenze e quello del secondo server applicativo, dismessi.

## Esposto e in chiaro sono due cose diverse: il caso del portale documentale

L'IT Manager ha obiettato il 03/09/2026, e l'obiezione e' giusta: quel portale **deve** essere raggiungibile da fuori, perche' i traduttori esterni hanno bisogno delle memorie di traduzione e non sono dentro l'azienda. Ne discende che l'esposizione su Internet non e' un difetto da eliminare ma un requisito da soddisfare, e qualunque proposta che la riduca e' una proposta che rompe il lavoro.

La correzione riguarda un altro punto, e vale la pena isolarla perche' e' la confusione piu' comune di tutta la materia. **Chi puo' raggiungere un servizio e se il traffico sia leggibile sono due proprieta' indipendenti.** Un servizio puo' essere pubblico e cifrato, pubblico e in chiaro, interno e cifrato, interno e in chiaro: sono quattro combinazioni, e la scelta sulla prima non determina la seconda.

Il difetto #117 riguarda **solo la seconda**. Ripararlo significa aggiungere la cifratura, non togliere l'accesso: i traduttori esterni continuerebbero a raggiungere lo stesso servizio, allo stesso indirizzo, con le stesse credenziali, cambiando una sola lettera nell'indirizzo che digitano — e nella maggior parte dei casi nemmeno quella, perche' il navigatore ci arriva da solo. Non c'e' alcun compromesso da valutare fra sicurezza e operativita': in questo caso non si toccano.

Ne discende anche la risposta alla domanda implicita sul perche' insistere. Non si insiste perche' il servizio sia esposto, cosa corretta e voluta, ma perche' oggi le credenziali dei responsabili di progetto e il contenuto scambiato, cioe' memorie di traduzione e documenti dei clienti, attraversano otto passaggi di rete pubblica in una forma che chiunque stia su uno di quei passaggi puo' leggere.

### Le due proposte dell'IT Manager, valutate

La prima e' che gli accessi **dall'interno** passino per il tunnel cifrato invece che per la rete pubblica. E' corretta, e' realizzabile con quello che gia' esiste, e questo progetto ha appena costruito il pezzo che serviva.

Oggi non succede per una ragione semplice: il tunnel verso il fornitore trasporta la rete privata remota, mentre il portale viene raggiunto per il suo **indirizzo pubblico**, e un indirizzo pubblico viene instradato verso l'uscita Internet come qualunque altro. Il tunnel c'e' ma quel traffico non lo imbocca, perche' nessuno gli ha detto di farlo.

Il modo per dirglielo e' pubblicare sul resolver interno un record per quel nome che punti all'**indirizzo privato** della macchina dentro la rete remota. Da quel momento le postazioni interne risolvono quel nome verso un indirizzo che il tunnel trasporta, e il traffico ci passa dentro. E' un orizzonte separato applicato a un nome pubblico: dall'interno porta al tunnel, dall'esterno all'indirizzo pubblico, e il certificato resta valido in entrambi i casi perche' certifica il **nome** e non l'indirizzo.

Va dichiarata la controindicazione, perche' esiste. Oggi, se il tunnel cade, gli utenti interni non se ne accorgono: raggiungono comunque il portale dalla via pubblica. Con il record interno quella via di ripiego sparisce, e una caduta del tunnel diventa un'interruzione del servizio per tutti gli interni. Non e' un motivo per non farlo, e' un motivo per accorgersi quando il tunnel cade, cosa che oggi non e' presidiata.

La seconda proposta e' far passare **anche i traduttori esterni** per un tunnel, verso un segmento dedicato del firewall. E' tecnicamente possibile e concettualmente elegante, ma il conto va fatto per intero. Ogni collaboratore esterno avrebbe bisogno di credenziali di accesso remoto, di un programma da installare e di assistenza quando non funziona, per un rapporto che spesso e' occasionale; e un collaboratore dentro il tunnel e' dentro il perimetro, quindi la sua postazione, che l'azienda non amministra, diventa un ingresso alla rete invece che un utente di un servizio. Per un applicativo web usato da esterni la strada consolidata e' l'opposta: lasciarlo pubblico, cifrarlo, e irrobustire l'autenticazione, per esempio con un secondo fattore.

Va notato infine il punto che rende la scelta meno urgente di quanto sembri: **la cifratura serve in tutti e tre gli scenari**. Se il portale resta pubblico serve perche' il traffico attraversa Internet. Se gli interni passano dal tunnel serve lo stesso, perche' gli esterni continuano a non passarci. E se passassero tutti dal tunnel servirebbe comunque, perche' un tunnel protegge il tratto fra due punti e non l'applicazione. Non e' quindi un'alternativa alle due proposte: e' il presupposto di entrambe, ed e' il motivo per cui va fatta per prima a prescindere da come si decida il resto.

## La Fase D non e' fallita: ha trovato il pezzo mancante

La prova del 03/09/2026 doveva verificare che le postazioni ricevessero il suffisso e interrogassero il firewall. Ha invece scoperto che **non lo faranno mai**, e la scoperta vale piu' della verifica che doveva sostituire.

Il primo segnale e' stato un messaggio che sembrava un intoppo: il comando per rinnovare l'indirizzo ha risposto che nessuna scheda si trova in uno stato che lo consenta. E' cio' che Windows dice quando non c'e' nessun indirizzo da rinnovare, perche' non e' stato ottenuto chiedendo ma **scritto a mano**. Da li' la verifica si e' spostata dalla singola postazione all'intero parco, usando l'inventario gia' disponibile.

L'esito: su venticinque macchine, **nessuna** indica il firewall come server dei nomi. Tutte puntano a resolver pubblici, e quattro portano ancora indirizzi di una rete domestica, segno di portatili configurati altrove e mai riportati. Solo due hanno un indirizzo compreso nell'intervallo distribuito dal firewall.

### Che cosa e' comunque stato verificato, e non e' poco

La rubrica funziona. Interrogando il firewall in modo esplicito, i nomi interni rispondono con gli indirizzi giusti e i nomi pubblici vengono inoltrati correttamente. La domanda tecnica che restava aperta — se un record locale prevalesse su inoltri dichiarati per qualunque nome — ha risposta affermativa e misurata.

Quindi il lavoro fatto e' corretto e resta valido. Semplicemente **non e' ancora utilizzato da nessuno**, perche' manca il passo che dice ai client dove chiedere.

### Perche' l'indirizzamento manuale non e' una stranezza, e perche' va superato

Va detto che la scelta ha con ogni probabilita' una ragione. Le liste di ammissione scritte dentro le configurazioni dei servizi, quelle del difetto #171, contengono indirizzi letterali: perche' funzionino, quegli indirizzi non devono cambiare. Fissarli sulla macchina e' il modo piu' diretto per ottenerlo, ed e' quello che chiunque farebbe senza pensarci troppo.

Il costo pero' si paga altrove, e si paga tutto insieme. Ogni impostazione decisa centralmente — il server dei nomi, il suffisso, e domani l'indirizzo del nuovo segmento — non arriva, perche' non c'e' nessun canale che la porti: va scritta a mano su ogni macchina. Non esiste registro di chi abbia quale indirizzo, quindi nessuna protezione contro l'assegnazione doppia. E ogni macchina nuova e' un intervento manuale che qualcuno deve ricordarsi di fare bene.

La conseguenza piu' pesante non riguarda i nomi ma la **segmentazione**. Spostare le postazioni in un segmento proprio significa cambiare il loro indirizzo: con l'indirizzamento manuale non e' un lavoro sugli apparati di rete, e' un lavoro su ogni singola postazione, una per una, con qualcuno che ci mette le mani. La stima di impegno di M22 va rifatta su questa base, ed e' registrato come difetto #184.

### Le due strade, che non sono alternative ma una sequenza

La prima e' **puntare i client al firewall con la gestione endpoint**, che raggiunge tutte le macchine gestite in una sola operazione senza cambiare l'indirizzamento. Rende immediatamente utilizzabile quanto gia' fatto e non pregiudica nulla. Il suffisso, non potendo arrivare dal DHCP, si imposta nello stesso passaggio.

La seconda e' **passare a indirizzi assegnati dal firewall con riserva per macchina**. Una riserva associa un indirizzo fisso a una scheda specifica: la macchina continua ad avere sempre lo stesso indirizzo, quindi le liste di ammissione di #171 continuano a funzionare, ma lo **chiede** invece di averlo scritto dentro. Da quel momento ogni impostazione futura arriva da sola, e la segmentazione torna a essere un lavoro sugli apparati invece che sulle scrivanie.

La prima si fa in un pomeriggio, la seconda e' un progetto. Farle in quest'ordine ha senso perche' la prima non complica la seconda: quando le macchine passeranno a chiedere l'indirizzo, riceveranno anche il server dei nomi e il suffisso, e la configurazione manuale spinta oggi diventera' semplicemente ridondante.

## La catena completa, verificata il 03/09/2026 sulla postazione dell'IT Manager

La prova e' riuscita su tutti i passaggi. Vale la pena ripercorrere che cosa succede, componente per componente, quando qualcuno digita l'indirizzo di un servizio interno: non per completezza descrittiva, ma perche' e' l'unico modo per sapere **dove mettere le mani** quando qualcosa non funziona. Ogni anello della catena si rompe in un modo diverso e produce un sintomo diverso.

### I sette passaggi

**Uno. Il programma isola il nome.** Il navigatore prende dall'indirizzo digitato la sola parte che identifica la macchina, scartando il protocollo e il percorso. Da questo momento in poi il nome viene trattato da solo, e il resto dell'indirizzo tornera' utile soltanto alla fine.

**Due. Il programma chiede al risolutore del sistema.** Non risolve da se': passa il nome al componente di Windows che si occupa di questo per tutti i programmi. E' un dettaglio che sembra pedante e non lo e', perche' e' la ragione per cui lo strumento diagnostico piu' usato mente, come si vede piu' avanti.

**Tre. Il risolutore guarda nella propria memoria.** Se ha risolto lo stesso nome di recente riusa la risposta senza chiedere a nessuno. E' il motivo per cui, dopo ogni modifica, va svuotata: altrimenti si misura il passato.

**Quattro. Il risolutore legge il file degli host.** Se il nome e' scritto li', la risposta esce da li' e la catena **si ferma**. Nessuna interrogazione parte, e nessun record sul firewall viene consultato. E' il passaggio che rende invisibile tutto il lavoro fatto sul firewall finche' quelle righe esistono, ed e' anche il motivo per cui aggiungere record non puo' rompere nulla.

**Cinque. Il risolutore interroga il servizio dei nomi.** Qui succedono due cose in una. Poiche' il nome digitato e' corto, cioe' senza punti, il risolutore vi aggiunge il **suffisso della connessione** e interroga il nome completo. E lo chiede all'indirizzo indicato nelle impostazioni della scheda di rete, che ora e' il firewall. Se il suffisso mancasse, chiederebbe il nome nudo e il firewall risponderebbe che non esiste, perche' in rubrica i nomi sono scritti per esteso.

**Sei. Il firewall risponde o inoltra.** Consulta la propria tabella: se il nome c'e' risponde con l'indirizzo, se non c'e' inoltra la domanda ai resolver pubblici e restituisce cio' che ottiene. E' il comportamento che rende compatibili le due cose, cioe' i nomi interni e tutto il resto di Internet, e che e' stato verificato interrogando un nome pubblico e ottenendo l'indirizzo pubblico.

**Sette. Il programma si collega, e il certificato viene verificato.** Aperta la connessione cifrata, il server presenta il proprio certificato e il navigatore confronta l'elenco dei nomi che vi sono scritti con **il nome che l'utente ha digitato**, non con quello completo usato per la risoluzione. E' la ragione per cui un certificato deve contenere entrambe le forme se si vuole che entrambe funzionino senza avvisi.

### Perche' lo strumento diagnostico piu' usato ha dato un risultato sbagliato

Durante la prova il comando di interrogazione diagnostica ha dichiarato che il nome corto non esisteva, mentre il nome corto funzionava perfettamente da programma. Non e' una contraddizione ed e' un caso che merita di essere registrato, perche' fa sbagliare diagnosi di continuo.

Quel comando **non usa il risolutore del sistema**: parla direttamente al servizio dei nomi, saltando i passaggi tre, quattro e la prima meta' del cinque. Non guarda la memoria, non legge il file degli host e non applica il suffisso. Chiede il nome esattamente come glielo si scrive, e ottiene la risposta corretta per quella domanda, che pero' non e' la domanda che fa un programma.

Ne discende una regola pratica: quel comando serve a interrogare **il server**, e va usato quando si vuole sapere che cosa il server risponde. Per sapere che cosa fara' un programma servono i comandi che passano dal risolutore, cioe' quello di risoluzione nativo e la verifica di raggiungibilita'.

### Dove intervenire, a seconda del sintomo

| Sintomo | Anello rotto | Dove si guarda |
|---|---|---|
| Il nome non si risolve affatto | cinque | impostazioni della scheda: quale server dei nomi e quale suffisso |
| Il nome completo funziona, quello corto no | cinque, prima meta' | manca il suffisso sulla connessione |
| Si risolve verso l'indirizzo sbagliato | quattro o tre | riga nel file degli host, oppure memoria non svuotata |
| Il nome corretto risponde, uno simile no | sei | il record non e' in rubrica, o e' scritto diversamente |
| I nomi interni funzionano, Internet no | sei | il firewall non inoltra, oppure non raggiunge i resolver pubblici |
| Si risolve ma non si collega | oltre la catena | non e' un problema di nomi: instradamento, filtro o servizio fermo |
| Compare un avviso sul certificato | sette | il nome digitato non e' fra quelli scritti nel certificato |

### Lo stato in cui resta la postazione di prova

A prova conclusa il file degli host e' stato ripristinato. Ne discende che su quella macchina il nome corto continua a essere risolto **dal file**, cioe' dall'anello quattro, e la strada nuova resta disponibile ma non percorsa per quel nome. E' esattamente la condizione in cui si trovano tutte le altre postazioni, con una differenza sola: quella dell'IT Manager ora chiede al firewall per tutto il resto, mentre le altre continuano a chiedere a resolver pubblici che i nomi interni non li conoscono.

La modifica applicata riguarda due impostazioni della sola scheda Ethernet di quella macchina, il server dei nomi e il suffisso della connessione. **L'indirizzo della macchina non e' stato toccato** e resta assegnato a mano, come su tutto il parco: era il punto posto dall'IT Manager, ed e' compatibile con quanto fatto perche' indirizzo e server dei nomi sono impostazioni distinte e indipendenti.

### Che cosa farne, e in quale ordine

Non vanno cancellati subito, e la ragione e' la stessa che vale per l'autorita' di certificazione esistente: finche' i record sul firewall non esistono e non sono verificati, quelle righe sono cio' che fa funzionare i servizi.

L'ordine e': creare i record per i nomi decisi, verificarli **commentando temporaneamente** la riga corrispondente sulla postazione di prova, distribuire il suffisso di ricerca, e solo allora rimuovere le voci dai file, una categoria per volta, verificando dopo ciascuna. Le due righe commentate che dirottano il dominio principale vanno invece rimosse subito: non servono a nulla oggi e sono l'unica cosa in quel file che possa produrre un guasto grave se qualcuno le riattivasse per errore.

Resta fuori da questo intervento, e va posto come domanda all'IT Manager, quali altre postazioni abbiano voci e quali: e' un dato che nessuno snapshot possiede e che si ottiene soltanto leggendo quei file, cosa che la gestione remota degli endpoint puo' fare.

## Il suffisso di ricerca, cioe' come far sopravvivere i nomi corti

Resta un problema pratico. Un servizio dei nomi lavora con nomi completi, del tipo `intralino.int.intrawelt.com`, mentre le persone digitano nomi corti come `intralino`. Se il nome corto smette di funzionare, ogni segnalibro e ogni configurazione vanno aggiornati, che e' esattamente il lavoro che si vuole evitare.

La soluzione esiste da sempre e si chiama *suffisso di ricerca*: si dice alle postazioni, tramite lo stesso ambito DHCP che gia' distribuisce indirizzo e server dei nomi, che quando incontrano un nome corto devono provare ad attaccarci un suffisso e chiedere quello. Con suffisso `int.intrawelt.com`, una postazione che cerca `intralino` domanda al firewall `intralino.int.intrawelt.com`, ottiene la risposta, e l'utente non si accorge di nulla.

Il vantaggio e' che il nome corto continua a funzionare **ma cambia chi risponde**: non piu' il broadcast, che sparira' con la segmentazione ed e' attaccabile, ma il servizio dei nomi. Si conserva la comodita' e si perde la fragilita'.

Una precisazione che serve quando si arriva ai certificati, ed e' la causa di un equivoco frequente. Il completamento del nome avviene **solo** per la risoluzione: il navigatore continua a sapere che tu hai digitato `intralino`, e verifica il certificato contro quello, non contro il nome completo. Ne discende che un certificato deve contenere **entrambi** i nomi se si vuole che entrambe le forme funzionino senza avvisi. E' il motivo per cui i certificati emessi in questo progetto portano il nome completo e quello corto insieme.

## Lo stato di questa rete, misurato

| Chi chiede | A chi chiede oggi | Risolve i nomi interni? |
|---|---|---|
| Postazioni cablate della LAN principale | il firewall, piu' broadcast come ripiego | solo via broadcast, finche' la rete e' piatta |
| Dispositivi sulla Wi-Fi del personale | due resolver pubblici, non il firewall | **no**, nemmeno dopo R12, finche' non si corregge |
| Dispositivi sulla Wi-Fi ospiti | due resolver pubblici | no, ed e' corretto cosi' |
| Client VPN | il firewall | si', appena esisteranno i record |
| Le due multifunzione | nessun server configurato | no, e per questo le destinazioni di scansione usano indirizzi |

La riga della Wi-Fi del personale e' quella che produrra' il guasto piu' difficile da attribuire: dopo R12 i nomi interni funzioneranno dal cavo e non dal Wi-Fi, e un sintomo del genere manda la diagnosi ovunque tranne che nell'ambito DHCP di una VLAN. Va corretta contestualmente.

La riga degli ospiti va invece lasciata com'e', e non e' una svista rimasta indietro: un ospite non ha ragione di poter risolvere i nomi dei servizi interni, e la risoluzione e' il primo passo di qualunque ricognizione di una rete sconosciuta.

## L'intervento, e in che ordine

Primo, creare sul firewall i record di indirizzo per i nomi decisi con ADR-018 e ADR-024. Secondo, verificare da una postazione che il nome risolva e che i nomi pubblici continuino a risolvere come prima: la seconda verifica non e' pleonastica, perche' gli inoltri di zona configurati dichiarano di applicarsi a qualunque nome, e va confermato che i record locali abbiano la precedenza invece di darlo per buono. Terzo, distribuire il suffisso di ricerca nell'ambito DHCP della LAN principale, cosi' che i nomi corti smettano di dipendere dal broadcast. Quarto, correggere l'ambito della Wi-Fi del personale perche' punti al firewall. Quinto, e solo dopo che la risoluzione funziona, emettere i certificati.

L'ultimo punto ha una ragione di collaudo e non di funzionamento: un certificato emesso per un nome che non risolve non si puo' provare, e cambiando due cose insieme non si saprebbe quale delle due non va.

Resta fuori da questo intervento, e va affrontato quando la segmentazione arrivera', lo spegnimento dei meccanismi a domanda diffusa sulle postazioni. Finche' sono accesi restano una via di attacco (#180) anche quando nessuno li usa piu' per risolvere, perche' rispondono comunque; ma spegnerli prima che il servizio dei nomi copra tutti i casi significa rompere qualcosa che oggi funziona.

[^netbios]: *NetBIOS* - insieme di servizi di rete delle reti Windows storiche; il suo meccanismo di risoluzione dei nomi funziona per domanda diffusa sul segmento locale e resta attivo per compatibilita' anche su sistemi moderni.

[^llmnr]: *LLMNR*, Link-Local Multicast Name Resolution - protocollo Microsoft che risolve i nomi interrogando in multicast tutti gli apparati del segmento; nato per sostituire la risoluzione NetBIOS, condivide con essa la mancanza di qualunque verifica su chi risponde.

[^mdns]: *mDNS*, multicast DNS - meccanismo che risolve i nomi in multicast sul segmento locale, riservato per convenzione al suffisso `.local`; e' cio' che rende raggiungibili stampanti e apparati domestici senza configurazione, ed e' attivo su piu' macchine di questa rete.

[^dns]: *DNS*, Domain Name System - il sistema gerarchico che traduce nomi in indirizzi interrogando servizi designati; a differenza dei meccanismi in multicast la domanda ha un destinatario preciso, quindi attraversa i confini di rete e la risposta arriva da chi e' stato interrogato.
