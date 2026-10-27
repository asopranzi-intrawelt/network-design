# Baseline di una VPS di fornitore cloud: dalla consegna all'istantanea di ripristino

> Procedura riproducibile, scritta il 23/10/2026 dopo averla percorsa per intero sulla VPS del sito. Lo strumento che la attua e la verifica e' `scripts/Set-VpsBaseline.sh`. Questo documento dice perche' ogni passo esiste e in quale ordine va fatto; lo script dice come. Gli indirizzi reali vivono nel livello privato.

## Che cosa produce, e perche' si chiama baseline

Il risultato e' una macchina messa in sicurezza e ancora vuota, di cui si prende un'istantanea dal pannello del fornitore. Quell'istantanea diventa il punto a cui tornare se la macchina va reinizializzata, e vale piu' di una procedura scritta perche' non dipende da chi la riesegue. La procedura resta necessaria per il giorno in cui cambia il fornitore o l'immagine, cioe' per il giorno in cui l'istantanea non si puo' usare.

Il momento per farla e' adesso, mentre la macchina non serve a nessuno. Ogni passo qui sotto diventa piu' caro dopo la pubblicazione, e due di essi, il riavvio e la restrizione della porta di amministrazione, diventano un disservizio invece che un'operazione.

## Il presupposto da smontare per primo

Una consegna ben fatta descrive cio' che chi ha fatto l'impianto ha configurato. Non descrive cio' che l'immagine del fornitore conteneva gia', e la differenza fra le due cose e' un accesso.

L'immagine standard di una distribuzione porta un utente predefinito proprio. Alla creazione, l'infrastruttura del fornitore vi inietta la **stessa** chiave pubblica indicata per l'amministratore, e il meccanismo di inizializzazione dell'istanza gli concede elevazione totale **senza password**, scrivendo una regola in un file che resta datato alla costruzione dell'immagine e non al giorno dell'impianto. Ne discende che le tre garanzie che una buona consegna dichiara, cioe' amministratore non raggiungibile da remoto, lavoro quotidiano con permessi limitati ed elevazione tracciata dietro password, convivono con una via parallela che le aggira tutte: chi possiede quella chiave entra come l'utente predefinito e diventa amministratore senza digitare niente.

Non e' un errore di chi ha fatto l'impianto, ed e' per questo che sfugge: la consegna e' corretta su cio' che afferma. E poiche' il difetto appartiene all'immagine e non alla macchina, quando se ne trova uno si verificano **tutte** le altre macchine create dallo stesso pannello, invece di chiudere il rilievo su quella.

## L'ordine, e perche' non e' negoziabile

**Primo, l'identita' della macchina.** Si legge l'impronta della chiave di host dall'interno e la si confronta con quella che il client ha accettato al primo contatto. La fiducia al primo incontro non e' una verifica: e' una scommessa, e questo e' il momento in cui la si trasforma in un riscontro. Dove esiste una seconda macchina che accedeva gia' da prima, il confronto con il suo registro degli host noti e' una corroborazione indipendente e anteriore, e vale piu' di una rilettura fatta adesso dallo stesso punto.

**Secondo, la continuita' dell'accesso.** Si autorizza una seconda chiave intestata all'organizzazione, generata sulla macchina da cui si amministrera' e **mai copiata** da quella esistente: una chiave privata copiata fra macchine distrugge l'attribuzione, perche' nei registri non si distingue piu' chi ha agito, e moltiplica i luoghi da cui puo' uscire. Il file delle chiavi autorizzate ne accetta molte, quindi il costo di una in piu' e' nullo. La scrittura si fa con una copia di salvataggio del file e preceduta da un a capo, perche' un file che non terminasse con un a capo attaccherebbe la chiave nuova a quella esistente rompendole entrambe, e con la via di emergenza non provata quello e' il modo di restare fuori definitivamente.

**Terzo, la lettura.** Si legge lo stato interno prima di cambiarlo: utenti con shell, chiavi autorizzate di ciascuno, regole di elevazione senza password, configurazione in vigore del servizio di accesso, regole del filtro, aggiornamenti pendenti e, soprattutto, **il registro degli accessi riusciti e falliti dal primo avvio**. Quest'ultimo si legge prima della restrizione e non dopo, perche' dopo la domanda su chi abbia bussato non si pone piu' allo stesso modo. Su una macchina esposta da qualche settimana il conteggio dei tentativi falliti e' nell'ordine delle decine di migliaia, e il dato che conta non e' quello ma il suo complemento, cioe' se esista anche un solo accesso riuscito che non si riconosce.

**Quarto, la chiusura della via parallela.** Il controllo che regge e' limitare il servizio di accesso remoto al **solo utente operativo**, perche' continua a valere anche se l'inizializzazione ricrea utente, chiave e regola al riavvio. Svuotare le chiavi dell'utente predefinito, revocargli la shell e rimuovere la regola di elevazione sono misure di contorno utili e disfacibili dall'inizializzazione. La modifica al servizio si valida prima di applicarla, si ricarica invece di riavviare, e si tiene aperta la sessione corrente mentre se ne prova una nuova da un secondo terminale: la sessione aperta e' il tasto annulla, ed e' migliore di un'istantanea perche' agisce in dieci secondi.

**Quinto, il filtro.** La porta di amministrazione si ammette dalla sola provenienza da cui si amministra. Prima si aggiunge la regola ristretta, poi si rimuovono quelle aperte, mai l'inverso. Due avvertenze. Le regole aperte sono spesso quattro e non due, perche' esistono in IPv4 e IPv6 e spesso sono definite sia per profilo applicativo sia per numero di porta; rimuoverne solo alcune lascia la porta aperta credendola chiusa. E una restrizione per provenienza presuppone che l'indirizzo da cui si esce non cambi: va verificato con il fornitore della connettivita' prima, non dopo, perche' un subentro su una linea di riserva che cambiasse l'indirizzo chiuderebbe fuori proprio mentre la rete e' gia' in avaria.

**Sesto, il riavvio.** Serve ad attivare i nuclei installati, che altrimenti restano sul disco senza effetto, e lo si vede perche' il sistema dichiara di richiederlo. Ma serve soprattutto come **prova**: e' l'unico modo di sapere se la configurazione appena scritta sopravvive all'inizializzazione automatica dell'istanza. Si fa adesso. Resta un rischio che nessuna istantanea copre, cioe' un nucleo nuovo che non si avvia su una macchina la cui console di emergenza non funziona: su una macchina ancora vuota il peggio e' reinstallarla, dopo la pubblicazione sarebbe un fermo.

**Settimo, l'istantanea.** Si prende dal pannello del fornitore quando ogni voce della verifica e' conforme e **nessuna e' non verificabile**. Da quel momento esiste un punto di ritorno che non dipende dalla procedura.

## Come si usa lo strumento

Il comportamento predefinito e' la sola verifica: non applica niente finche' non glielo si chiede, perche' un errore sul servizio di accesso chiude fuori chi lo sta lanciando. Va eseguito con un terminale vero e come utente operativo, mai come amministratore.

```bash
ssh -t <alias> 'bash -s -- --verifica' < scripts/Set-VpsBaseline.sh
ssh -t <alias> 'bash -s -- --applica --ammessi <indirizzo-ammesso>' < scripts/Set-VpsBaseline.sh
```

Lo strumento restituisce tre esiti e non due: conforme, non conforme e **non verificabile**. Il terzo pesa sull'esito complessivo come il secondo, e la ragione e' un difetto che lo strumento stesso ha avuto nella sua prima stesura e che vale la pena raccontare, perche' si ripresenta in qualunque controllo di sistema. I comandi che richiedono elevazione falliscono in silenzio quando l'elevazione non c'e', e il loro ripiego coincide con il valore che segnala l'assenza del problema: un conteggio restituisce zero, una ricerca restituisce vuoto, e zero e vuoto sono esattamente le risposte che chi legge sperava. La prima esecuzione, fatta senza elevazione, riporto' tre voci in regola e quattro fuori regola, e tutte e sette erano fittizie. Da qui la regola: la disponibilita' dei permessi si accerta una volta sola all'inizio e decide che cosa lo strumento ha il diritto di affermare; dove una misura non si puo' prendere, si puo' mostrare l'indizio, per esempio il contenuto del file di configurazione al posto della configurazione in vigore, ma etichettandolo per quello che e'.

## Che cosa questa baseline non copre

Non copre l'applicazione che girera' sopra, che ha una propria postura da irrobustire. Non copre il salvataggio, che e' un passo a se' e il cui script va letto prima di attivarlo, perche' uno script di salvataggio incompleto produce lo stato peggiore dei due, cioe' un salvataggio che esiste e che nessuno rimette in discussione. Non copre il presidio. E non sostituisce la via di emergenza fuori banda: finche' la console del pannello non e' stata **provata**, la ridondanza di accesso e' dichiarata e non reale.
