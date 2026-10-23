# VPS del sito: stato interno letto dalla macchina

> Fase 0 del piano di produzione, meta' che nessun pannello puo' dare. Prima lettura dall'interno dopo l'impianto dell'11/08/2026. Gli indirizzi reali vivono nel livello privato; qui vale il segnaposto `192.0.2.10`.

## Lettura del 22/10/2026, ore 15:11 UTC

La lettura e' stata possibile dopo l'autorizzazione di una seconda chiave intestata alla postazione aziendale, che chiude la dipendenza da un solo dispositivo descritta in VPS-001 (#224). Prima di fidarsi del canale e' stata verificata l'identita' della macchina: l'impronta della chiave di host osservata da questa postazione coincide con quella registrata all'impianto sul calcolatore che gia' accedeva, cioe' due osservazioni indipendenti, da reti e in momenti diversi, che convergono. La fiducia al primo incontro accettata la mattina del 22/10 risulta percio' corroborata da una registrazione anteriore, e non resta una scommessa.

### Che cosa e' misurato

La macchina e' in piedi da settantadue giorni, cioe' dall'impianto, e non e' mai stata riavviata. Dichiara che un riavvio e' richiesto, con cinque aggiornamenti del kernel e uno della libreria di sistema installati ma non attivi: il kernel in esecuzione e' il `6.8.0-137` mentre il piu' recente installato e' il `6.8.0-147`. I pacchetti aggiornabili sono quarantasei. Gli aggiornamenti non presidiati risultano abilitati e attivi, con aggiornamento degli elenchi e installazione automatica entrambi a uno, e stanno funzionando; coprono pero' il solo canale di sicurezza, quindi il resto si accumula, e fra cio' che resta indietro c'e' il motore dei container.

In ascolto c'e' la sola porta di amministrazione, su IPv4 e IPv6, piu' il risolutore di sistema vincolato al loopback. Non ci sono porte del web in ascolto e non c'e' nessun contenitore in esecuzione: la macchina e' vuota, come la consegna dichiarava. La cartella di distribuzione esiste dall'11/08/2026 e appartiene all'utente operativo. L'occupazione del disco e' al sei per cento di settantanove gigabyte; la memoria e' di sette e otto gigabyte con quattro e nove liberi, e la memoria di scambio non e' mai stata toccata. Quest'ultimo dato conferma il vincolo di SRV-015 (#244), cioe' che una costruzione che chiede fino a otto gigabyte di heap non sta su questa macchina insieme al resto.

Sul fronte degli accessi, il file di configurazione del servizio SSH dichiara il login di amministrazione disabilitato e l'autenticazione per password disabilitata, coerentemente con l'interrogazione del protocollo fatta lo stesso giorno, che aveva gia' mostrato il solo metodo a chiave pubblica fra quelli offerti. Il file delle chiavi autorizzate dell'utente operativo contiene esattamente due chiavi, quella dell'impianto e quella della postazione aziendale. Il filtro di sistema e' installato, abilitato e attivo. Il blocco automatico dei tentativi ripetuti e' abilitato e attivo, ed e' un presidio che la documentazione d'impianto non cita e che il progetto non sapeva di avere.

### Due riscontri non attesi

Esiste un secondo utente con shell di accesso oltre a quello operativo, cioe' l'utente predefinito dell'immagine della distribuzione, e **appartiene al gruppo di elevazione**. La sua cartella delle chiavi esiste ma non e' leggibile dall'utente operativo, quindi non si sa se porti chiavi autorizzate. E' un secondo possibile accesso di cui nessun documento del progetto ha mai tenuto conto, e va chiarito prima di dichiarare chiuso l'inventario degli accessi alla macchina.

L'utente operativo appartiene inoltre al gruppo del motore dei container, il che sul piano pratico equivale a privilegi di amministratore senza passare dall'elevazione tracciata, perche' chi dialoga con il socket dei container puo' montare l'intero disco dentro un contenitore. Non e' un difetto di configurazione ma una conseguenza nota dell'assetto scelto all'impianto, e va dichiarata invece di restare implicita quando si ragiona sul privilegio minimo.

### Che cosa non e' misurato, e perche'

La lettura e' stata eseguita senza elevazione, perche' la password dell'utente operativo e' dell'IT Manager e non dell'agente. Restano percio' non misurati, e non vanno dedotti dalle sezioni precedenti: le regole del filtro, cioe' quali porte siano effettivamente ammesse e con quale politica predefinita; la configurazione effettiva del servizio SSH oltre alle due direttive lette dal file; l'eventuale presenza di chiavi autorizzate per il secondo utente; l'esistenza di regole di elevazione senza password; e, soprattutto, **il registro degli accessi riusciti e falliti dall'impianto a oggi**, che era lo scopo principale della lettura. La domanda se qualcuno sia entrato in oltre due mesi di porta di amministrazione aperta a Internet resta percio' senza risposta, e la fase 0 non si chiude finche' quella risposta non e' qui.

Un avvertimento di metodo che discende da questo giro: nella prima esecuzione diverse sezioni avevano stampato un ripiego, per esempio che il filtro fosse assente, perche' il comando elevato falliva e il ripiego dichiarava l'assenza invece del fallimento. Un ripiego che somiglia a una misura e' peggio di un errore, perche' si legge come un riscontro: le voci sono state percio' rifatte con comandi che non richiedono elevazione, e solo quelle hanno prodotto le affermazioni qui sopra.

## Lettura con elevazione del 22/10/2026, e la risposta alla domanda rimasta aperta

### Nessuno e' entrato

La domanda che il progetto si poneva da settembre, cioe' se qualcuno fosse entrato nei mesi in cui la porta di amministrazione e' rimasta aperta a Internet, ha una risposta e la risposta e' no. Il registro degli accessi riusciti comincia il giorno stesso dell'impianto, quindi copre l'intera vita della macchina e non una finestra recente, ed elenca soltanto sessioni dell'utente di amministrazione e dell'utente operativo nei due giorni dell'impianto, tutte provenienti dall'indirizzo pubblico aziendale, piu' una dalla macchina stessa durante la configurazione. Fra la chiusura dell'impianto e il 22/10/2026 non risulta nessun accesso riuscito. I due avvii registrati sono quelli dell'impianto, e il secondo e' quello ancora in corso.

### Ma bussano senza sosta

Nello stesso periodo i tentativi falliti sono 18.737 nella finestra conservata dal giornale di sistema. Il campione piu' recente mostra un'attivita' continua nella sola giornata del 22/10, da piu' di dieci indirizzi distinti e con nomi utente da dizionario, fra cui quelli di prodotti di uso comune come un sistema di integrazione continua, un gestore di progetti e un gestionale. E' il traffico di fondo che qualunque indirizzo pubblico riceve, ed e' la misura piu' concreta a sostegno della restrizione per provenienza: fra quei tentativi e la macchina stanno oggi soltanto l'autenticazione a sola chiave e il blocco automatico dei tentativi ripetuti.

### Le regole del filtro

Il filtro e' attivo, con politica predefinita di rifiuto in ingresso, permesso in uscita e rifiuto per il traffico instradato. Le porte ammesse sono tre, la porta di amministrazione e le due del web, tutte da qualunque provenienza e sia in IPv4 sia in IPv6; la porta di amministrazione compare due volte, una per profilo applicativo e una per numero. Le due porte del web sono aperte mentre nulla vi e' in ascolto, il che non e' un rischio oggi ma lo diventera' quando un contenitore vi si leghera', perche' per SEC-054 (#239) una porta pubblicata dal motore dei container non e' governata da questo filtro.

### Il riscontro che annulla il modello di accesso documentato

E' il piu' grave della giornata ed e' tracciato come VPS-011 (#253). L'utente predefinito dell'immagine della distribuzione ha nel proprio file delle chiavi autorizzate la stessa chiave che apre l'utente operativo, e il meccanismo di inizializzazione dell'istanza gli concede elevazione totale senza password. Chiunque possieda quella chiave entra come quell'utente e diventa amministratore senza digitare niente: il login di amministrazione disabilitato, il lavoro con permessi limitati e l'elevazione tracciata dietro password, cioe' le tre garanzie che la documentazione d'impianto dichiara, sono aggirate da una via parallela che nessun documento del progetto aveva censito. Non e' un errore di chi ha fatto l'impianto: e' un'eredita' dell'immagine del fornitore, e per questo va verificata anche sulle altre macchine create dallo stesso pannello.
