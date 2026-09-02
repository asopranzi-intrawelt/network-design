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
