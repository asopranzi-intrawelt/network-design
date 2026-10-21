# Un sito costruito da zero: storia tecnica, decisioni e lettura ISO 27001

> Scheda aperta il 21/10/2026 su direttiva dell'IT Manager. È un asset a sé: racconta per intero lo sviluppo del sito nuovo dal primo commit alla messa in produzione, con il dettaglio tecnico di ogni passaggio e la lettura di sicurezza che ne discende. Serve a due lettori diversi. Chi lavora su questa rete, perché un sito che Intrawelt sviluppa, ospita e di cui risponde è infrastruttura come lo è un firewall. E chi un giorno dovrà costruire un sito da zero, perché la parte che insegna non sono le scelte riuscite ma i punti in cui il progetto ha scoperto di avere torto.
>
> Cresce insieme alla roadmap di produzione: ogni passo di quella roadmap aggiunge un capitolo qui, e il documento resta uno solo. Non duplica il registro dei difetti, che dice che cosa è aperto, né la roadmap, che dice che cosa va fatto: dice come ci si è arrivati.
>
> Convenzione. I nomi di prodotto, di tecnologia e di dominio sono reali perché servono a capire. Le persone compaiono per ruolo. Indirizzi, credenziali e dati identificanti seguono i segnaposto di `.claude/rules/anonymization.md`, perché questo repository è pubblico. Le misure vengono dal repository del sito e dalle macchine, lette il 21/10/2026.

## I numeri, misurati e non stimati

Cinquantasei commit fra il 12 agosto e il 21 ottobre 2026, su diciotto giornate di lavoro effettivo. Tre contributori: chi ha costruito il progetto, con quarantacinque commit; un secondo sviluppatore entrato il 2 settembre sul frontend, con sei; e l'IT Manager, con quattro, tutti del 21 ottobre e tutti di rete e non di prodotto.

Trentasette decisioni architetturali registrate. Ventisette migrazioni versionate del database. Tre alberi di lavoro git su una macchina sola. Quattro rami. Dodici collection nel CMS, dieci blocchi di contenuto, quattro lingue.

Lo stack: Payload 3.88 come CMS dentro Next.js 16, PostgreSQL 17 in contenitore, il tutto su una macchina virtuale del nodo Proxmox per lo sviluppo e su una VPS esterna per la produzione futura.

La distribuzione del lavoro non è uniforme e la forma dice qualcosa. Tre giornate concentrano la maggior parte del volume: il 19 agosto con oltre duecentomila righe aggiunte in tre commit, il 2 settembre con centotredicimila in un commit solo, e il 23 settembre con duecentottantasettemila. Sono le giornate in cui è entrato materiale generato o importato in blocco — schemi, asset, consegne grafiche — e non giornate di scrittura di codice. Un conteggio di righe su un progetto di contenuto misura l'ingestione, non lo sforzo.

## Agosto: le fondamenta, e tre decisioni che hanno retto

### 12 agosto, il primo commit

Un solo commit, cinquantaquattro file, lo scaffold di Payload con Next.js e PostgreSQL su template vuoto. La macchina di sviluppo nasce lo stesso giorno sul nodo Proxmox, e il database nasce come contenitore avviato a mano.

Quel «avviato a mano» ritorna cinquanta giorni dopo come un problema, ed è la prima lezione del documento: un servizio creato fuori dal suo descrittore resta descritto male finché qualcuno non se ne accorge, e nel frattempo il descrittore racconta una cosa diversa da quella che gira.

### 13-14 agosto, le tre decisioni che hanno retto

Lo schema del database cambia solo per migrazione, con la sincronizzazione implicita disattivata. È la decisione che ha retto meglio di tutte: ventisette migrazioni dopo, lo schema è riproducibile da zero su una macchina vuota, ed è il motivo per cui la produzione potrà ricostruire il database senza copiarlo. Il costo dichiarato è che ogni modifica richiede tre passi in sequenza e che i tipi restano vecchi finché non si rigenerano.

La localizzazione si articola su tre livelli distinti: la lingua del pannello, il ripiego per campo, e la pubblicazione per lingua del documento. Il terzo livello non è implicito, e chi aggiunge una collection pubblica deve ricordarselo. Un mese dopo entrerà il francese come quarta lingua di contenuto, e la decisione reggerà senza riaprirsi.

Il campo dei ruoli degli utenti riceve un controllo di accesso proprio, che impedisce a un utente di elevarsi da solo. È la prima decisione di sicurezza del progetto e precede di due mesi qualunque discorso di rete. **Lettura ISO**: è controllo degli accessi privilegiati, che la norma tratta sotto la gestione dei diritti di accesso privilegiati (A.8.2); il punto che la rende matura è che il vincolo vive nel codice della collection e non in una procedura che qualcuno deve ricordare.

### 19-21 agosto, il volume e il vocabolario chiuso

Tre giornate portano tassonomie, i dieci blocchi di contenuto, le collection, i global, i token di design, l'impianto grafico e le prime schermate.

La decisione che governa tutto questo è il vocabolario chiuso: dieci blocchi e nessun blocco con markup libero. Un undicesimo richiede una decisione esplicita. È una scelta che si paga ogni volta che una pagina vuole qualcosa che non c'è, e infatti il 16 settembre la cronologia di Chi siamo viene infilata dentro il blocco di testo invece di diventare l'undicesimo blocco, con il costo dichiarato che quel campo nasce anche dove non serve. Il beneficio è che dopo due mesi il sito ha ancora dieci blocchi e non trenta.

Accanto, il pattern per cui i blocchi che mostrano contenuto esistente lo leggono dalla collection di origine invece di duplicarlo. La conseguenza, dichiarata subito, è che il renderer dipende dal database anche per blocchi che sembrano statici, e che ogni lettura va coperta da cache e tag.

Il 21 agosto la cache riceve la sua regola: nessuna scadenza temporale, invalidazione per tag alla pubblicazione. Il costo è scritto nella decisione stessa, ed è il tipo di costo che si paga in silenzio: una lettura nuova senza tag resta in cache per sempre, e nessun errore lo segnala.

### 24 agosto, la macchina diventa un servizio

Quattro commit, nessuno grande, tutti di infrastruttura.

Il server di sviluppo smette di essere un comando in un terminale e diventa un servizio di sistema con riavvio automatico. La conseguenza dichiarata è che l'unità vive fuori dal repository e va ricreata a mano su una macchina nuova.

E il descrittore dei container viene riallineato al contenitore reale, quello avviato a mano il 12 agosto. Da qui nasce la parte più istruttiva del documento, che però esplode solo due mesi dopo.

## Settembre: la squadra, il sistema, e la moltiplicazione dei rami

### 2 settembre, entra il secondo sviluppatore

Sei commit da un contributore nuovo, con la prima e la seconda richiesta di incorporazione del progetto. Arriva il rifacimento di Chi siamo approvato in sede di design, centotredicimila righe in un commit, e la decisione che il sito si usa da telefono.

Lo stesso giorno il materiale di studio dell'interfaccia esce dal repository, con le regole che spiegano perché. È igiene di repository e vale come lezione generale: un archivio compresso e una cartella di asset dentro un repository di codice non si tolgono più, perché restano nella storia anche dopo la cancellazione.

**Lettura ISO**: qui nasce il controllo degli accessi al codice sorgente (A.8.4). La repository vive in un'organizzazione con i permessi di base azzerati e gli accessi concessi uno per uno. La decisione porta però un avviso che è esattamente il tipo di cosa che si dimentica: riportare i permessi di base a lettura, o aggiungere la repository a un gruppo, farebbe cadere il vincolo **senza alcun avviso**.

### 15-16 settembre, il progetto adotta un sistema

Sei commit in un giorno, duecentocinquantuno file. Il progetto adotta un sistema di documentazione e memoria versionata: schede di contesto, registro delle decisioni, work-log, e la regola che commit e spinta restano manuali.

Nello stesso giro arrivano tre decisioni che vale la pena leggere insieme, perché raccontano un progetto che impara a diffidare di sé.

La memoria vive nel repository e la memoria automatica resta spenta. La conseguenza è che va scritta nello stesso giro in cui il contenuto nasce, perché nessuno la aggiorna al posto tuo.

Il materiale importato dal bundle esterno viene bonificato: conteneva la configurazione git e SSH di un'altra macchina, con percorsi, alias e nomi di chiave che non avevano nulla a che fare con questo progetto. La motivazione scritta nella decisione è la frase migliore dell'intero registro: *un documento di configurazione che descrive un'altra macchina è peggio di un documento assente, perché chi lo legge lo applica*.

E le trascrizioni delle sessioni di lavoro non si cancellano, con lo script di pulizia deliberatamente non installato dopo averne letto il comportamento. **Lettura ISO**: è una decisione a doppio taglio e la voce lo dichiara. Conserva la storia, che è ciò che si voleva; ma crea un archivio non versionato, su una macchina sola, che può contenere qualunque segreto sia transitato a schermo durante una sessione. La protezione delle registrazioni (A.5.33) e la prevenzione della fuga di informazioni (A.8.12) tirano in due direzioni opposte, e la voce le nomina entrambe invece di nasconderne una.

Lo stesso giorno nasce il secondo albero di lavoro. La regola: un ramo di lavoro si apre in un albero git separato, mai spostando la cartella che serve la vetrina. Il motivo è che la vetrina è raggiungibile in rete e cambiarle il ramo sotto i piedi cambia ciò che gli altri vedono.

### 16 settembre, il francese e la prova di contenimento

Il francese entra come quarta lingua di contenuto. La migrazione è additiva, il ritorno indietro costoso e capace di fallire se nel frattempo esistono righe in francese.

E il ramo che aveva costruito il progetto si ritira, ma solo dopo una prova di contenimento con quattro verifiche. La decisione dice una cosa che molti progetti imparano tardi: *il contenimento conta solo in un riferimento che resta*. Un ramo contenuto in un ramo di integrazione ma non nel ramo principale non è ancora al sicuro. Trentacinque giorni dopo questa frase si rivelerà profetica, perché il ramo principale risulterà fermo e scollegato dal resto.

### 23-25 settembre, tre alberi e la posta

Nove commit in un giorno. Nasce il terzo albero di lavoro per la fase degli invii, e con esso la decisione che risolve la domanda che tre alberi pongono: la memoria resta una sola, e chi lavora su un ramo parallelo scrive nella memoria del ramo più avanti.

È una decisione corretta e cara. Risolve la divergenza delle memorie, ma colloca la memoria autorevole su un ramo di lavorazione, cioè su un ramo destinato a sparire. Un mese dopo questo progetto ne pagherà il prezzo: aprendo un canale automatico verso il sito, il canale è stato puntato sulla cartella del repository invece che sull'albero giusto, e per un giorno ha letto e dichiarato allineata una fotografia di ventisette giorni prima.

Lo stesso giorno la posta riceve la sua decisione: l'identità con cui ci si autentica al server di invio è distinta dal mittente visibile. **Lettura ISO**: è l'anello che collega il sito alla posta aziendale, e il punto in cui un progetto di sito tocca un sistema che non è suo. Due giorni dopo la decisione si estende: l'adattatore rifiuta di inviare se non è configurato, le prove passano da un raccoglitore locale che trattiene tutto, e la conservazione dei contatti raccolti è fissata a ventiquattro mesi. Quest'ultimo numero è un limite di trattamento e appartiene alla protezione dei dati personali (A.5.34), non una scelta di ingegneria.

Sempre il 23 settembre, i dati anagrafici reali sostituiscono i segnaposto, con la distinzione fra sede legale e sede operativa. È conformità agli obblighi legali e contrattuali (A.5.31), e ha un effetto collaterale che questo documento deve dichiarare: da quel commit il repository contiene dati identificanti dell'azienda, il che è legittimo per un repository privato e sarebbe un problema in uno pubblico.

## Ottobre: il carattere, il contenuto, e l'ingresso della rete

### 30 settembre, il carattere tipografico

Il carattere del marchio entra in opera, servito come file web da regola tipografica. Il giorno prima la decisione era opposta: il sito **nominava** il carattere senza servirlo, perché la licenza posseduta era per uso su scrivania e vietava sia l'incorporamento sia la pubblicazione. La conseguenza accettata era che il sito si vedesse diverso su computer diversi.

La licenza per uso web viene acquisita il 30 settembre, e il vincolo cade. Ma non sparisce: diventa un vincolo di esercizio con tre limiti che il progetto deve ricordare. Un solo dominio, quindi un ambiente di prova su un nome diverso richiederebbe una seconda licenza. Un tetto di visualizzazioni mensili, che si supera in silenzio perché nessun errore lo segnala. E il divieto di servire il carattere da una rete di distribuzione di terzi.

**Lettura ISO**: appartiene agli obblighi legali (A.5.31), ed è l'unico vincolo del progetto capace di bloccare la pubblicazione senza che nulla sia rotto. Il tetto di visualizzazioni è il caso più interessante, perché trasforma una metrica di traffico in una misura di conformità contrattuale: il presidio deve raccoglierla non per capacità ma per legalità.

### 8 ottobre, fuori i caratteri di terze parti

Il carattere del marchio viene esteso a tutte le pagine del banco di prova, e nella stessa occasione sparisce la dipendenza dal servizio di caratteri esterno. È una riga di nota in un commit, e vale due cose insieme: toglie una chiamata verso un terzo a ogni caricamento di pagina, e toglie il trasferimento dell'indirizzo del visitatore verso quel terzo, che è il motivo per cui in Europa quella pratica è discussa.

### 7-20 ottobre, le pagine che chiudono il sito

Home con video in apertura, carosello delle soluzioni, pittogrammi, pagine di policy, certificazioni, area riservata, ricerca estesa. È lavoro di prodotto e non di infrastruttura, e qui compare per completezza più che per lezione.

Una nota che appartiene a questo documento: il 19 ottobre un commit risolve il fatto che gli a capo scritti nel pannello del CMS non si vedevano nella pagina. È il tipo di difetto che un progetto scopre solo quando qualcuno scrive contenuto vero, e dice che il contenuto è entrato nel sito prima della produzione, non dopo.

### 21 ottobre, entra la rete

Quattro commit, tutti dell'IT Manager, nessuno di prodotto. È il giorno in cui questo progetto di rete entra nella storia del sito, ed è anche il giorno che ha prodotto la lezione tecnica più generale dell'intero documento.

Il database del sito era pubblicato su tutte le interfacce della macchina dal 12 agosto, cioè da settanta giorni, su una rete piatta e con una parola d'ordine di sviluppo scritta in chiaro nel descrittore. La correzione è una riga: la pubblicazione passa da tutte le interfacce al solo indirizzo di anello locale.

Tre cose rendono questo passaggio istruttivo oltre il caso.

**La prima: un filtro attivo non è una porta chiusa.** Per settanta giorni la documentazione del progetto ha descritto la protezione delle macchine con la formula «filtro di sistema attivo, politica di rifiuto in ingresso, tre porte aperte». La formula è vera per un processo che ascolta sull'host e falsa per un servizio pubblicato da un contenitore, perché il motore dei container inserisce le proprie regole in una tabella che precede la catena su cui il filtro agisce. Attivare il filtro non avrebbe chiuso quella porta. La fragilità non era la porta aperta: era un'affermazione verificabile che nessuno aveva verificato, perché sembrava una constatazione.

**La seconda: cambiare il file non applica la correzione.** La pubblicazione di una porta si fissa alla creazione del contenitore. Modificare il descrittore e riavviare non cambia nulla; il contenitore va ricreato. Ed è qui che torna il «avviato a mano» del 12 agosto: il contenitore in esercizio non era nato da quel descrittore, e il descrittore gli era stato riallineato dopo.

**La terza: una ricreazione poteva dare un database vuoto senza errori.** Il descrittore dichiara il volume come esterno e con il nome reale. Senza quella dichiarazione la ricreazione avrebbe montato un volume nuovo, Postgres sarebbe ripartito su un database senza dati, e nessun errore lo avrebbe segnalato: il sito sarebbe sembrato azzerato pur non avendo perso niente. La dichiarazione c'era, scritta mesi prima da chi aveva previsto il problema, ed è stata verificata prima di procedere.

**Lettura ISO**: è restrizione dell'accesso alle informazioni (A.8.3) e sicurezza delle reti (A.8.20), ed è l'intervento che il registro ISO del progetto di rete segue come ISO-05. La verifica che lo chiude è una misura prima e dopo con lo stesso comando, non una dichiarazione: la connessione verso la porta dall'indirizzo di rete riusciva e ora riceve un rifiuto.

## Le lezioni che valgono oltre questo progetto

Sei, e sono quelle che un progetto nuovo può prendere senza conoscere nulla di questo.

**Un'affermazione verificabile che nessuno verifica è peggio di un'affermazione assente.** Vale per il filtro di sistema, per la configurazione importata da un'altra macchina, per il ramo principale dato per aggiornato. Il segno comune è che tutte e tre sembravano constatazioni e nessuna lo era.

**Il contenimento conta solo in un riferimento che resta.** Il progetto l'ha scritto a settembre parlando di rami e l'ha dimostrato a ottobre con il ramo principale fermo da sette settimane. La stessa regola vale per i salvataggi: una copia su un disco che muore insieme all'originale non è contenimento.

**Una configurazione che descrive un'altra macchina viene applicata da chi la legge.** È la motivazione più chiara del registro ed è la ragione per cui ogni import esterno va letto prima di essere committato.

**Un costo dichiarato alla nascita si paga meglio di uno scoperto dopo.** Il vocabolario chiuso dei blocchi, la cache senza scadenza, la migrazione additiva con ritorno costoso: in tutti e tre i casi la decisione contiene la propria conseguenza scomoda. Quando quella conseguenza è arrivata, nessuno ha dovuto indagare.

**Ciò che è nato a mano resta descritto male finché qualcuno non se ne accorge.** Il contenitore del database, l'unità di sistema che vive fuori dal repository, i server di sviluppo lasciati in ascolto. Tutti e tre funzionano e nessuno dei tre è dove la documentazione lo cerca.

**Tre alberi di lavoro risolvono un problema e ne creano un altro.** Permettono di lavorare in parallelo senza spostare la vetrina; moltiplicano per tre le copie della configurazione, e una correzione di sicurezza che atterra su un albero lascia gli altri due com'erano. Il progetto lo ha scoperto il 21 ottobre e la pendenza è aperta.

## La lettura ISO 27001, raccolta

Il progetto non è nato con una norma davanti e questo documento non finge il contrario: le decisioni sono state prese per ragioni tecniche e il collegamento ai controlli è una lettura a posteriori. Vale però come inventario di ciò che esiste e di ciò che manca.

| Tema | Che cosa il progetto ha fatto | Controllo | Che cosa manca ancora |
|---|---|---|---|
| Accessi privilegiati | Il campo dei ruoli ha un controllo che impedisce l'auto-elevazione | A.8.2 | La matrice completa degli accessi al CMS non è scritta |
| Accesso al codice | Permessi di base azzerati nell'organizzazione, accessi uno per uno | A.8.4 | Le chiavi di distribuzione sono legate a profili personali, non al compito |
| Restrizione dell'accesso ai dati | Il database non è più raggiungibile dalla rete | A.8.3, A.8.20 | La correzione vive su un ramo solo: gli altri due la riaprirebbero |
| Gestione della configurazione | Lo schema cambia solo per migrazione, riproducibile da zero | A.8.9 | La configurazione infrastrutturale diverge fra rami |
| Separazione degli ambienti | Sviluppo, prova e produzione distinti per macchina e per ramo | A.8.31 | La produzione non esiste ancora, quindi la separazione non è provata |
| Vulnerabilità tecniche | Versione del framework tracciata, avvisi letti | A.8.8 | La versione installata ricade in un avviso: debito di aggiornamento aperto |
| Dati personali | Conservazione dei contatti fissata a ventiquattro mesi | A.5.34 | Il trattamento non è descritto in un documento di privacy del sito |
| Obblighi legali | Dati anagrafici reali, licenza del carattere acquisita | A.5.31 | Il tetto di visualizzazioni della licenza non è sorvegliato da nulla |
| Continuità | Schema riproducibile, macchina coperta da un lavoro di backup | A.8.13 | I file caricati dalla redazione non sono versionati e non hanno prova di ripristino |
| Registrazioni | Le trascrizioni delle sessioni sono conservate per scelta | A.5.33, A.8.12 | Non sono versionate, stanno su una macchina sola e possono contenere segreti |
| Sorveglianza | — | A.8.16 | Nessun presidio: un fermo del sito non verrebbe rilevato |

Due righe di questa tabella meritano di essere lette insieme, perché si contraddicono. La conservazione delle trascrizioni protegge la storia e crea un archivio di segreti; la stessa decisione che risolve un controllo ne apre un altro. Un inventario onesto le tiene entrambe.

## Dove la storia continua

Il sito è in sviluppo e la produzione non esiste ancora. Quattro cose restano fra oggi e la prima pubblicazione, e questo documento le elenca perché il capitolo successivo le racconterà.

Il ramo di rilascio deve esistere davvero: il ramo principale è fermo al 2 settembre e una richiesta di incorporazione lo porta allo stato attuale. Finché non è fusa, non c'è un riferimento da cui costruire.

L'immagine non è mai stata costruita: manca un'impostazione nella configurazione del framework che il descrittore dell'immagine dichiara come necessaria nella propria prima riga. La catena non è mai stata eseguita fino in fondo.

Il contenuto non arriva in produzione da solo, perché i file caricati dalla redazione non sono versionati e non entrano nell'immagine. Il trasferimento è un passo distinto dalla distribuzione del codice.

E il nome del dominio va spostato, che è la parte più rischiosa e la meno visibile: la zona che serve il sito porta anche la posta aziendale, con una regola di mittente autorizzato che rifiuta e non segnala. Un errore lì non rompe il sito, rompe la posta.

Il piano che governa questi quattro passi è `piano-produzione-sito-nuovo.md`; il canale per cui gli avanzamenti del sito arrivano in questo progetto è `sito-nuovo-integrazione.md`. Questo documento registra che cosa è successo; quelli dicono che cosa deve succedere.
