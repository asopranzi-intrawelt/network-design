# Collegamento a cartella di rete o unita' di rete mappata: differenza e criterio di scelta

> Nota tecnica nata durante l'intervento R8 (`interventi-robustezza.md`), quando si e' dovuto decidere come far raggiungere a ciascun utente la propria cartella di scansione sul NAS. La distinzione sembra un dettaglio di comodita' e non lo e': i due meccanismi hanno costi e modi di rompersi diversi, e su questa rete la differenza si e' vista subito.

## Cosa sono, davvero

Un **collegamento** e' un file con estensione `.lnk` che contiene un percorso, per esempio `\\<indirizzo-nas>\scansioni_<nome>`. Non esiste nulla di montato: quando si fa doppio clic, Explorer risolve il percorso in quel momento, si autentica se serve e apre la cartella. Il collegamento vive nel profilo dell'utente, tipicamente sul desktop, ed e' un file come un altro — si copia, si rinomina, si cancella senza conseguenze.

Un'**unita' di rete mappata** e' un'associazione tra una lettera e un percorso di rete, registrata nel profilo dell'utente e ripristinata a ogni accesso. Compare come disco in Esplora risorse, e le applicazioni la vedono come un percorso locale del tipo `S:\...`.

## Le differenze che contano nella pratica

| | Collegamento | Unita' mappata |
|---|---|---|
| Consuma una lettera di unita' | No | Si, e le lettere sono finite |
| All'accesso | Non fa nulla | Prova a riconnettersi |
| Se il server non risponde | Errore solo quando si clicca | Attese all'avvio, icona in errore, talvolta ritardi nell'apertura di Esplora risorse |
| Visibilita' | Icona dove lo si mette | Disco in "Questo PC" |
| Applicazioni che pretendono una lettera | Non le soddisfa | Le soddisfa |
| Credenziali | Chieste all'apertura, memorizzabili nel gestore credenziali | Memorizzate nella mappatura |
| Condivisioni nascoste | Funziona identicamente | Funziona, ma va scritto il percorso a mano |

## Perche' qui si e' scelto il collegamento

Tre ragioni concrete, tutte emerse dai fatti di questa rete e non da preferenze di stile.

Le lettere di unita' sono una risorsa scarsa e gia' occupata. Su una sola postazione ispezionata risultano tre lettere impegnate da mappature persistenti verso altrettante condivisioni, una delle quali raggiunta attraverso il tunnel verso il cloud. Aggiungere una lettera per le scansioni significa entrare in concorrenza con quelle, e infatti il primo tentativo di mappatura si e' scontrato con una lettera occupata.

Le mappature si riconnettono all'accesso, i collegamenti no. Una cartella di scansione serve qualche volta al giorno: non vale il prezzo di un tentativo di riconnessione a ogni avvio, che quando il NAS non risponde si traduce in attese e in un'icona con l'errore che genera chiamate all'assistenza per un problema che non esiste.

Una mappatura in piu' e' un disco in piu' da spiegare. Un collegamento sul desktop chiamato "Scansioni" e' autoesplicativo; un disco `S:` accanto a `T:` e `V:` chiede di ricordare quale sia quale.

L'unita' mappata resta la scelta giusta in un solo caso: quando un'applicazione pretende una lettera di unita' per funzionare. Per una cartella dove si depositano documenti scansionati non e' il caso di nessuno.

## Un dettaglio che vale la pena sapere

Il fatto che un collegamento si crei **non** dimostra che la cartella sia raggiungibile: il `.lnk` e' un file locale e nasce identico anche se il server e' spento o se l'utente non ha alcun permesso. La verifica di accesso e' un'operazione a se', e nel caso delle scansioni consiste nell'aprire il collegamento e scrivere davvero un file. Per questo lo script di distribuzione `scripts/New-ScanFolderShortcut.ps1` verifica l'accesso **prima** di creare il collegamento e si rifiuta di crearlo se l'utente connesso non entra nella cartella: su queste condivisioni, permesse al solo destinatario, un accesso negato e' il segnale che la cartella assegnata appartiene a un'altra persona.

## Le credenziali di Windows sono legate alla forma del nome, non al server

E' il dettaglio che ha piu' conseguenze pratiche di tutti, e su questa rete e' emerso come problema reale. Il gestore credenziali di Windows memorizza una credenziale **per nome di destinazione**: una credenziale salvata per il nome del NAS non vale quando si apre lo stesso NAS per indirizzo, e viceversa. Per Windows sono due destinazioni diverse, anche se la macchina in fondo al cavo e' la stessa.

Su queste postazioni la pratica e' mista: alcuni utenti hanno salvato la credenziale del NAS usando il nome, altri usando l'indirizzo. Ne derivano due conseguenze. La prima e' che imporre una sola forma nei collegamenti farebbe chiedere le credenziali a chi ha salvato l'altra, con la tipica reazione "non funziona piu' niente". La seconda, piu' sottile, e' che un controllo automatico di accesso fatto su una sola forma restituirebbe un accesso negato per la meta' degli utenti, portando a diagnosticare un problema di permessi dove c'e' solo una credenziale salvata con un'altra etichetta.

Per questo lo script di distribuzione prova entrambe le forme e scrive nel collegamento quella che per quell'utente funziona davvero, preferendo — quando entrambe funzionano — la forma gia' in uso in un collegamento esistente, cosi' da non alternare a ogni esecuzione. Nota di comportamento: la forma di un collegamento esistente e valido **vince** anche su una preferenza esplicita, proprio per evitare oscillazioni; per cambiarla si rimuove il collegamento e si rilancia.

La lezione generale, oltre le scansioni: quando si documenta o si automatizza un accesso di rete, la forma del nome fa parte della configurazione. Scrivere "il NAS" non basta: va detto se si intende il nome o l'indirizzo, perche' per il sistema operativo sono due cose diverse. Ed e' un argomento in piu' a favore di una risoluzione nomi interna unica e governata, che e' il micro-step M25 della roadmap.

## Una nota su Windows e le sessioni

Verso lo stesso server non si possono tenere aperte contemporaneamente connessioni con identita' diverse: il tentativo produce un errore di conflitto di sessione (**1219**) che somiglia a un problema di permessi e non lo e'. Due conseguenze utili. Se serve provare due identita' diverse verso lo stesso NAS, si usa **l'indirizzo per una e il nome per l'altra**, perche' Windows le considera due server distinti. E se si vuole verificare un'autorizzazione con la sessione gia' aperta, si omette l'opzione dell'utente nel comando di mappatura: senza di essa la sessione esistente viene riusata e cio' che si misura e' il permesso sulla condivisione, che e' quello che interessa.
