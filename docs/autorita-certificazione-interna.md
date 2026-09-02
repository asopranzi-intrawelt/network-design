# Autorita' di certificazione interna e nomi dei servizi

> Scheda aperta il 01/09/2026. Attua ADR-018, che fissa lo schema dei nomi interni, ADR-024, che vi assegna i primi nomi, e ADR-025, che stabilisce dove viva la chiave dell'autorita'. Nasce da una domanda operativa — come aggiungere il traffico cifrato al gestore delle password — che ha rivelato una catena di decisioni mai prese: per cifrare serve un certificato, per un certificato serve un nome, per un nome serve chi lo risolva, e per la firma serve un'autorita' di cui qualcuno risponda.
>
> E' scritta con fondamento didattico secondo la direttiva permanente dei cinque livelli: la materia dei certificati e' quella in cui si sbaglia per analogia con l'esperienza dei siti pubblici, dove tutto e' automatico e nessuna delle decisioni qui descritte e' visibile.
>
> Convenzione. Nomi di servizio e suffissi sono reali, perche' servono a operare e un segnaposto li renderebbe inutilizzabili. Nessuna chiave, passphrase o impronta compare qui ne' in alcun file tracciato.

## I due compiti di un certificato, e perche' solo il secondo e' difficile

Un certificato TLS assolve a due compiti che il linguaggio comune confonde in uno.

Il primo e' **cifrare** il traffico, cioe' rendere illeggibile a chi ascolta cio' che passa fra il navigatore e il servizio. Per questo compito basta un certificato qualunque, anche generato in dieci secondi dalla macchina stessa: la cifratura che ne risulta e' identica a quella di un certificato costoso. Chi dice che un certificato autofirmato "non e' sicuro" sta usando una scorciatoia imprecisa.

Il secondo e' **dimostrare l'identita'** di chi risponde, cioe' garantire che dietro quel nome ci sia davvero il servizio atteso e non qualcuno che si e' interposto. Questo compito la cifratura da sola non lo assolve, perche' anche un impostore puo' cifrare. Lo assolve una firma: il certificato porta la firma di qualcuno, e il navigatore lo accetta senza protestare solo se quel qualcuno figura nel proprio elenco di firmatari attendibili.

Ne discende la definizione esatta di certificato **autofirmato**: e' un certificato che si firma da solo, cioe' afferma la propria identita' appellandosi a se stesso. L'avviso che il navigatore mostra non e' un tecnicismo fastidioso, e' la descrizione corretta della situazione, cioe' che nessuno indipendente garantisce quell'identita'.

E ne discende il motivo per cui conviverci e' peggio di quanto sembri. Un utente abituato a superare l'avviso lo superera' anche il giorno in cui l'avviso e' vero, cioe' il giorno in cui qualcuno si e' davvero interposto. La cifratura senza identita' verificata protegge da chi ascolta e non da chi si sostituisce, e sulla LAN piatta di questa azienda, dove ogni apparato e' adiacente a ogni altro, il secondo scenario non e' teorico.

## Perche' un'autorita' interna e non un certificato per servizio

Un'*autorita' di certificazione*[^ca] e' semplicemente un certificato la cui chiave viene usata per firmarne altri, piu' la disciplina con cui la si usa. Non e' un prodotto e non richiede un'infrastruttura: sono due file e una procedura.

La differenza rispetto ai certificati autofirmati sta nel numero di volte che qualcuno deve fare qualcosa su ogni postazione. Con certificati autofirmati per servizio, ogni postazione deve installare il certificato di **ogni** servizio: con `n` servizi e `m` postazioni le installazioni sono `n` per `m`, e ne nascono di nuove ogni volta che nasce un servizio. Con un'autorita' interna si installa **una volta sola** il certificato dell'autorita' su ogni postazione, e da quel momento ogni certificato che essa firma viene accettato senza avvisi: le installazioni sono `m` e non crescono piu'.

Il punto di pareggio sta intorno ai tre o quattro servizi. Qui sono gia' almeno cinque fra gestore delle password, portale asset, IntraLino, applicativo di pianificazione e il futuro proxy inverso della DMZ, e il piano di segmentazione ne prevede altri.

C'e' pero' una ragione piu' forte del conteggio, e riguarda proprio il lavoro in corso in questo progetto. La segmentazione spostera' i servizi su segmenti diversi, quindi **cambieranno indirizzo**. Un certificato emesso per un indirizzo diventa sbagliato quando quell'indirizzo cambia, con lo stesso identico meccanismo del difetto #171, dove liste di indirizzi scritte a mano dentro configurazioni si romperanno silenziosamente. Un'autorita' interna emette certificati per **nomi**, e un nome puo' continuare a valere quando l'indirizzo dietro di esso cambia.

## Lo schema dei nomi, e perche' viene prima di tutto

Un certificato certifica un nome, non una macchina: il navigatore confronta il nome digitato dall'utente con quello scritto nel certificato, e se non coincidono protesta anche quando la firma e' di un'autorita' attendibile. Scegliere i nomi non e' quindi un preliminare estetico, e' il primo passo tecnico.

Secondo **ADR-018**, presa il 30/07/2026, i servizi interni si chiamano sotto **`int.intrawelt.com`**, sottodominio del dominio gia' posseduto dall'azienda, risolto soltanto sul resolver interno del firewall e mai pubblicato nel sistema dei nomi pubblico. E' una configurazione a orizzonte separato: lo stesso dominio risponde con nomi diversi a chi interroga da dentro e a chi interroga da fuori, e da fuori quei nomi semplicemente non esistono. ADR-024 la conferma e vi aggiunge i primi nomi concreti.

| Servizio | Nome interno | Stato |
|---|---|---|
| Gestore delle password | `vault.int.intrawelt.com` | deciso il 01/09/2026 |
| Portale asset | `asset.int.intrawelt.com` | deciso il 01/09/2026; il vecchio nome sul suffisso `.lan` resta pubblicato in parallelo per non rompere chi lo usa; avra' anche un nome pubblico, vedi sotto |
| IntraLino | `intralino.int.intrawelt.com` | deciso il 02/09/2026; riemissione del certificato a carico del progetto IntraLino |
| Rilevazione presenze | `presenze.int.intrawelt.com` | deciso il 02/09/2026; oggi raggiunto per indirizzo, il nome esiste perche' sopravviva alla segmentazione |
| Secondo applicativo sulla stessa macchina | `timewalker.int.intrawelt.com` | come sopra |
| Applicativo di pianificazione | `gantttool.int.intrawelt.com` | deciso il 02/09/2026; sostituisce il nome sul suffisso della scoperta multicast, ed e' l'unico caso che richiede di avvisare gli utenti |
| Proxy inverso della DMZ | da assegnare | quando M6-M9 lo creeranno |

Va notato che piu' nomi possono puntare allo stesso indirizzo senza alcun conflitto: e' la situazione normale di una macchina che ospita piu' applicazioni, ed e' il motivo per cui il server Windows ne riceve due oltre al proprio nome di compatibilita'.

Sul significato del suffisso vale la pena essere espliciti, perche' si presta a un equivoco che si e' verificato: **`int` sta per interno**, non per il nome di un progetto. E' il pezzo che distingue un nome che vive soltanto dentro la rete da uno pubblicabile, ed e' per questo che compare fra il nome del servizio e il dominio e non altrove.

Due regole che accompagnano lo schema e che valgono piu' del suffisso.

I nomi si scelgono per **ruolo del servizio** e non per macchina. Un nome legato alla macchina che oggi lo ospita diventa fuorviante il giorno in cui il servizio si sposta, ed e' esattamente cio' che la segmentazione fara' con almeno due servizi. Un nome che dice cosa fa il servizio sopravvive allo spostamento.

Un nome interno non si pubblica mai nel sistema dei nomi pubblico. Il sottodominio esiste solo dentro la rete: chi lo interroga da Internet non deve ottenere risposta, perche' altrimenti l'elenco dei servizi interni diventerebbe leggibile da chiunque.

## Il servizio che sara' raggiungibile da dentro e da fuori: il caso del portale asset

L'IT Manager ha osservato il 02/09/2026 che il portale asset dovra' anche essere pubblicato all'esterno tramite la DMZ. E' il caso piu' interessante dello schema dei nomi, perche' e' l'unico in cui il nome interno non basta, e conviene affrontarlo adesso invece che al momento della pubblicazione.

Il nodo e' che **un'autorita' interna non serve a chi sta fuori**. Il certificato firmato dall'autorita' aziendale sara' accettato senza avvisi da ogni postazione dell'azienda, perche' su quelle postazioni l'autorita' e' installata; sara' rifiutato con un avviso da chiunque arrivi da Internet, perche' nel suo navigatore quell'autorita' non c'e' e non ci sara' mai. Non e' un difetto della soluzione: e' la definizione di autorita' interna.

Ne discendono tre strade, con costi diversi.

La prima e' **due nomi e due certificati**: `asset.int.intrawelt.com` firmato dall'autorita' interna per chi arriva da dentro, e un nome pubblico firmato da un'autorita' riconosciuta per chi arriva da fuori. E' la soluzione piu' pulita e la piu' laboriosa, perche' il servizio deve presentare l'uno o l'altro a seconda di chi bussa, cosa che il proxy inverso della DMZ sa fare ma va configurata.

La seconda e' **un nome solo, quello pubblico, con certificato pubblico**, usato anche da chi sta dentro. E' la piu' semplice da configurare e ha uno svantaggio di percorso: il traffico degli utenti interni esce verso l'indirizzo pubblico e rientra, attraversando il firewall due volte invece di restare dentro. Su una rete piccola e' spesso accettabile e va misurato invece che temuto; sulla linea di questa azienda, dove l'uscita e' a un gigabit contro una dorsale interna a dieci, non lo e' se il servizio movimenta file.

La terza e' **un nome solo, quello pubblico, risolto in modo diverso da dentro e da fuori**, cioe' l'orizzonte separato applicato allo stesso nome: il resolver interno risponde con l'indirizzo del segmento interno, quello pubblico con l'indirizzo pubblico. Un solo certificato, quello pubblico, valido per entrambi i percorsi, e nessun giro esterno. E' la soluzione che le organizzazioni adottano piu' spesso, e in questa infrastruttura e' anche la piu' economica perche' il resolver interno lo stiamo configurando adesso e sa gia' fare esattamente questo.

La scelta non e' urgente perche' la DMZ non esiste ancora, ma va fatta **prima** di emettere il certificato interno del portale, altrimenti si emette un certificato per un nome che poi verra' sostituito. Nel frattempo il nome interno resta quello deciso, ed e' comunque necessario per collegare il portale.

## Chi risolve i nomi: il firewall, e il resolver esisteva gia'

La materia della risoluzione dei nomi ha una scheda propria, `docs/risoluzione-nomi-interni.md`, che spiega come un nome diventa un indirizzo, perche' su questa rete molti nomi funzionino oggi senza essere scritti da nessuna parte, e perche' la segmentazione li rompera' tutti insieme. Qui se ne riprende soltanto quanto serve alla catena dei certificati.

Perche' un nome funzioni qualcuno deve tradurlo in un indirizzo. Su questa rete la risposta e' meno lontana di quanto il progetto abbia creduto a lungo, ed e' una delle affermazioni che questo repository ha dovuto correggere: **un resolver interno esiste gia', ed e' il firewall**. La verifica dell'ambito DHCP del 30/07/2026 mostra che il primo server dei nomi distribuito ai client della LAN principale e' il firewall stesso, mentre secondo e terzo non sono impostati.

Manca quindi soltanto il contenuto. Il firewall oggi lavora da puro inoltratore verso resolver pubblici e non ospita alcun record di indirizzo proprio, come la lettura della sua configurazione ha confermato correggendo un'ipotesi opposta: le risposte che si ottenevano interrogando il nome di un NAS non venivano da lui, venivano dal client che risolveva in multicast per conto proprio. Ne discende che pubblicare i nomi interni non richiede di introdurre un servizio nuovo ne' di toccare gli endpoint della LAN principale, che gia' interrogano il posto giusto: richiede di creare i record.

L'intervento e' tracciato come **R12** in `docs/interventi-robustezza.md` ed e' scelto dall'IT Manager il 01/09/2026 come strada da percorrere, in alternativa al ripiego dei file degli host.

La lettura della pagina di configurazione, il 02/09/2026, conferma il quadro nel dettaglio e aggiunge un elemento. Le tabelle dei record di indirizzo e degli alias sono **entrambe vuote**, quindi non esiste nulla da conservare o da riconciliare: si parte da zero, che e' la condizione piu' semplice. Gli inoltri di zona sono tre, due definiti a mano verso altrettanti resolver pubblici e uno predefinito, tutti su zona `*`, cioe' applicati a qualunque nome. Ne discende la sola domanda tecnica dell'intervento, cioe' se un record locale prevalga su un inoltro che dichiara di applicarsi a tutto: prevale, perche' il servizio consulta le proprie tabelle prima di inoltrare, ma e' un'affermazione da confermare con una interrogazione dopo il primo record e non da dare per buona.

### Tre avvertenze che l'intervento porta con se'

La prima riguarda chi **non** interroga il firewall. L'ambito della rete Wi-Fi del personale distribuisce come server dei nomi due resolver pubblici e non il firewall: i dispositivi collegati in Wi-Fi non risolverebbero quindi alcun nome interno, e il difetto si manifesterebbe come "dal cavo funziona e dal Wi-Fi no", che e' fra i sintomi piu' difficili da attribuire alla causa giusta. Va corretto contestualmente. La rete ospiti deve invece continuare a usare resolver pubblici, e non e' una svista da sanare ma la scelta corretta: un ospite non ha ragione di poter risolvere i nomi dei servizi interni, e la risoluzione e' il primo passo di qualunque ricognizione.

La seconda riguarda l'orizzonte separato. Poiche' i nomi vivono sotto un sottodominio che pubblicamente non esiste, il firewall risponde con i propri record per quel sottodominio e continua a inoltrare tutto il resto, compreso il dominio principale: non serve replicare o oscurare la zona pubblica, che e' il vantaggio pratico della scelta di ADR-018 rispetto all'uso del dominio nudo.

La terza riguarda l'ordine. I record vanno creati **prima** di emettere i certificati, per una ragione di verifica e non di funzionamento: un certificato emesso per un nome che non risolve non si puo' collaudare, e si scoprirebbe che qualcosa non va solo dopo aver toccato la configurazione del servizio, con due variabili cambiate insieme e nessun modo di sapere quale delle due sia il problema.

## La procedura, e perche' e' scritta invece che ricordata

ADR-025 stabilisce che la chiave dell'autorita' viva su un supporto rimovibile, protetta da passphrase, e che l'emissione sia un'operazione manuale e deliberata. Il ragionamento e' quantitativo prima che di principio: un'autorita' emette pochi certificati all'anno, quindi il costo del passaggio manuale e' irrilevante rispetto alla frequenza, mentre il beneficio e' permanente, perche' **una chiave che non sta su nessuna macchina non si ottiene compromettendo una macchina**.

Da qui pero' discende un rischio secondario che va affrontato: un'operazione rara e manuale e' precisamente quella di cui si dimentica il come. Per questo la procedura e' versionata in due script, che non contengono alcun valore reale.

`scripts/crea-autorita.sh` genera l'autorita' e si esegue una volta sola. Chiede la passphrase a runtime e non la scrive da nessuna parte, rifiuta di sovrascrivere un'autorita' esistente — perche' sovrascriverla invaliderebbe in silenzio ogni certificato gia' emesso e ogni installazione gia' fatta — e stampa alla fine l'impronta del certificato, che serve a verificare al momento dell'installazione sulle postazioni di stare installando l'autorita' giusta.

`scripts/emetti-certificato.sh` emette un certificato di servizio. Costruisce sempre l'elenco dei **nomi alternativi**, e vale la pena spiegare perche': dal 2017 i navigatori ignorano il nome comune del soggetto e leggono soltanto quell'elenco, quindi un certificato che porti il nome solo nel soggetto viene rifiutato come se il nome non ci fosse. E' l'errore piu' comune di chi emette a mano, e lo script lo rende impossibile.

Entrambi ricevono come parametro obbligatorio la cartella dell'autorita', e non hanno un valore predefinito. Non e' scomodita': un valore predefinito finirebbe prima o poi sul disco della macchina di turno, che e' esattamente cio' che ADR-025 vieta.

## La durata dei certificati, e l'assenza di revoca

I certificati emessi durano poco piu' di un anno, mentre l'autorita' dura dieci. La differenza non e' un'incongruenza ma la pratica corretta: sostituire un'autorita' significa reinstallarla ovunque, sostituire un certificato che essa firma non costa quasi nulla.

Sulla durata breve dei certificati di servizio c'e' pero' una ragione specifica di questo impianto e va detta, perche' altrimenti sembra pedanteria. Un'autorita' interna senza infrastruttura di revoca non ha modo di annullare un certificato prima della scadenza: se una chiave di servizio venisse compromessa, non esisterebbe alcun meccanismo per dire alle postazioni di non fidarsi piu' di quel certificato. **La scadenza e' quindi l'unico meccanismo di revoca disponibile**, e piu' e' vicina, meno dura una compromissione.

C'e' anche un beneficio secondario non trascurabile: una procedura che va eseguita ogni anno resta viva, mentre una che si esegue una volta e poi mai piu' si dimentica, e ci si accorge di averla dimenticata nel momento peggiore.

## L'ordine delle operazioni, che e' controintuitivo

La sequenza ha un solo ordine possibile e conviene scriverlo perche' il primo istinto e' un altro.

Si stabilisce **chi risolve i nomi**, anche solo con i file degli host come soluzione dichiaratamente provvisoria. Si **genera l'autorita'** sul supporto rimovibile. Si **emette il certificato** del gestore delle password. Si **collega il gestore**, che oggi non lo e' affatto (#160), configurando il modulo di inoltro, il modulo cifrato e un host virtuale che punti al contenitore. Si **distribuisce il certificato dell'autorita'** alle postazioni, contestualmente al rilascio di IntraLino, che e' l'occasione in cui qualcuno tocchera' comunque tutte le postazioni: farlo due volte e' l'unico errore veramente costoso di questa materia. Solo alla fine si **deposita la passphrase** dell'autorita' dentro il gestore.

L'ultimo passo e' quello che sorprende, ed e' anche il piu' logico: la passphrase non puo' stare nel gestore prima che il gestore funzioni, e il gestore non funziona senza il certificato che quella passphrase serve a firmare. Fino ad allora la passphrase sta fuori da qualunque file, secondo ADR-025.

## Cosa fare dell'autorita' esistente

L'autorita' creata per il progetto IntraLino resta in servizio finche' il suo certificato non e' sostituito, perche' e' cio' che rende quel servizio utilizzabile senza avvisi sulla postazione dove e' installata. Va disinstallata dalle postazioni **dopo** che l'ultimo certificato da essa firmato e' stato riemesso dalla nuova autorita'.

La sua chiave va poi distrutta consapevolmente, e non semplicemente dimenticata. Una chiave che resta su un disco, la cui autorita' e' ancora considerata attendibile da qualche postazione mai bonificata, e' un modo per firmare identita' che qualcuno continuera' ad accettare: e' il caso peggiore, perche' nessuno lo sta piu' sorvegliando.

[^ca]: *autorita' di certificazione*, certification authority - il soggetto la cui firma su un certificato ne attesta l'identita'; tecnicamente e' un certificato marcato come tale, la cui chiave privata viene usata per firmarne altri, e la fiducia in essa e' l'unica cosa che rende attendibili tutti i certificati che ha firmato.
