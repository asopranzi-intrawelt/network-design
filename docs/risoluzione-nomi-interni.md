# Risoluzione dei nomi interni

> Scheda aperta il 02/09/2026 da una domanda dell'IT Manager — che cosa significa che un nome "sta sul broadcast" — emersa mentre si configurava il primo record interno sul firewall. E' la scheda del micro-step M25 e dell'intervento R12, e raccoglie una materia che il progetto aveva toccato tre volte senza mai spiegarla: ogni volta come sintomo di un guasto, mai come meccanismo.
>
> E' scritta con fondamento didattico secondo la direttiva permanente dei cinque livelli. La risoluzione dei nomi e' l'argomento in cui si sbaglia di piu' proprio perche' funziona quasi sempre da sola: nessuno la configura, tutti la usano, e quando smette di funzionare il guasto si manifesta come "l'applicazione non va" invece che come "il nome non si risolve".
>
> Convenzione. Nomi di servizio e suffissi sono reali. Gli indirizzi seguono i segnaposto di `.claude/rules/anonymization.md`.

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

### Oggi: il nome funziona, e nessuno sa perche'

L'utente digita l'indirizzo del servizio con il nome corto. Il sistema operativo cerca nella propria memoria e non trova nulla, poi nel file degli host e non trova nulla, poi interroga il servizio dei nomi configurato, che e' il firewall, il quale non ha alcun record di indirizzo e inoltra la domanda a un resolver pubblico, che risponde correttamente che quel nome non esiste su Internet.

A questo punto tutti i meccanismi ordinati hanno fallito, e il sistema operativo passa all'ultima risorsa: spedisce sul segmento una domanda diffusa. Quel pacchetto raggiunge ogni apparato del dominio di broadcast, e siccome la LAN e' piatta il dominio comprende anche la macchina virtuale del servizio, che risponde con il proprio indirizzo. La connessione parte e la pagina si apre.

Tre osservazioni su questa sequenza, tutte importanti. Il nome non e' scritto **da nessuna parte**: non c'e' un record, non c'e' una riga in un file, non c'e' una configurazione. Il firewall e' stato interrogato e ha risposto che il nome non esiste, quindi non e' lui a farlo funzionare. E il meccanismo che lo fa funzionare e' l'unico dei quattro che dipende dal fatto che chi chiede e chi risponde stiano nello stesso segmento.

### Dopo la segmentazione, senza aver fatto nulla: il nome smette di funzionare

Si supponga che la segmentazione abbia spostato le postazioni in un segmento proprio e i servizi applicativi interni in un altro, come prevede il piano. Sono ora due domini di broadcast distinti, separati da un apparato che instrada fra loro.

L'utente digita lo stesso indirizzo di sempre. Le prime tre fasi vanno esattamente come prima e falliscono esattamente come prima. Il sistema operativo passa alla domanda diffusa, e qui cambia tutto: il pacchetto viene consegnato a ogni apparato del **suo** segmento, cioe' alle altre postazioni, e si ferma li'. La macchina virtuale del servizio sta in un altro segmento e quel pacchetto non lo vede mai, quindi non risponde. Dopo qualche secondo il navigatore dichiara che il sito non e' raggiungibile.

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
