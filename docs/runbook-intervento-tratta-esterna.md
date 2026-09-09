# Runbook dell'intervento sulla tratta esterna (M13c)

> Runbook operativo di un intervento **pianificato**, distinto da `runbook-anomalie.md` che raccoglie le procedure di diagnosi di un guasto. Nasce il 09/09/2026 dopo ADR-029, che sposta il baricentro di M13c dalla sostituzione dell'access point a quella dell'apparato di diramazione. Serve a eseguire l'intervento in un ordine in cui ogni passo e' verificabile e ogni punto di non ritorno e' dichiarato. Lo stato di avanzamento dei singoli passi vive in `.claude/context/roadmap.md` (M13c-1..M13c-10), non qui: questo documento dice **come**, la roadmap dice **dove siamo**.

## Che cosa c'e' oggi, in una figura sola

Dalla porta 4 del XGS2220-30HP parte la tratta verso l'esterno: presa a parete `0-8-1` nel locale caldaia, ponte verso la derivazione `0-9-1` sul tetto, e li' uno **Zyxel GS-105B v5**, cinque porte, non gestito e non PoE, interposto dagli elettricisti durante il montaggio dell'inverter fotovoltaico per diramare tre utenze da un cavo che prima ne serviva una. I tre rami sono la **centrale di irrigazione** (cavo di categoria 6 proprio), l'**access point esterno** Ubiquiti fuori supporto, e l'**inverter del fotovoltaico**.

Le misure del 09/09/2026, dalle quali dipende tutto il resto del documento: la porta 4 e' attiva, non trunk, PVID 1, VLAN ammesse `all`, **PoE attivo**, negozia **100 Mb/s**, e i suoi contatori di errore sono a **zero** su CRC, lunghezza e runt. Il vicino LLDP che annuncia e' ancora il vecchio access point, il che conferma che il GS-105B, essendo non gestito, inoltra i frame LLDP. La porta 3, che e' l'altra tratta verso l'esterno, negozia anch'essa 100 Mb/s, mentre la porta 6 dello stesso switch negozia 1 Gb/s.

## Il vincolo che va deciso prima di comprare: dove sta l'apparato

Il GS-105B sta alla **derivazione sul tetto**, non nel locale caldaia, perche' e' li' che convergono i tre cavi. Ne segue che il suo sostituto sta nello stesso posto, e questo governa l'acquisto in modo che nessuna scheda tecnica di rete rende evidente: uno switch gestito da interno, montato in un contenitore esterno, deve sopportare l'escursione termica di un sottotetto d'estate e la condensa d'inverno, e un contenitore chiuso senza ricambio d'aria peggiora la prima cosa mentre risolve la seconda.

Le due strade sono alternative e vanno scelte, non scoperte in opera. La prima e' un contenitore esterno con grado di protezione adeguato e gestione termica, dentro cui vive uno switch da interno: e' la strada economica, e sposta il rischio sul contenitore. La seconda e' uno switch con intervallo di temperatura esteso, che costa piu' del primo e non richiede nulla intorno. La domanda da cui dipende la scelta, e che va posta a chi ha montato l'impianto, e' **in che posizione fisica stia oggi la derivazione `0-9-1`**: dentro un vano tecnico riparato, oppure esposta. Fino a quella risposta l'acquisto del solo switch resta indeterminato, mentre l'access point non lo e', perche' quello e' un apparato da esterno per costruzione e prende il proprio contenitore protettivo.

## Requisiti dello switch, da mettere nella richiesta di preventivo

Quattro porte in servizio come minimo, cioe' uplink verso la porta 4 piu' i tre rami, e conviene prenderne cinque od otto perche' la differenza di prezzo e' minima e la derivazione ha gia' dimostrato di attirare utenze nuove senza preavviso. **PoE erogato** su almeno una porta in 802.3at, perche' l'access point del preventivo del 31/07 si alimenta cosi' e dichiara 24 W: il bilancio PoE dell'apparato va confermato dal fornitore, non dedotto dal numero di porte alimentate. **Gestione Nebula** nella stessa organizzazione degli altri apparati, che e' la ragione per cui la sostituzione ha senso: senza quella si sostituisce un apparato cieco con un altro apparato cieco. Alimentazione da presa locale, quella che oggi alimenta il GS-105B. E l'intervallo di temperatura operativa dichiarato, che va confrontato con la risposta sulla posizione fisica.

Un requisito che non serve, e vale dirlo per non pagarlo: porte a 2,5 o 10 Gb/s sull'uplink non servono finche' la tratta negozia 100 Mb/s, e se la ri-terminazione la porta a 1 Gb/s il limite diventa il cavo in categoria 6 verso l'irrigazione, non lo switch.

## Il testo della richiesta di preventivo, pronto da inoltrare

Scritto il 09/09/2026, dopo la chiusura di M13c-5 e l'accettazione consapevole di #196. Segue la procedura di M13b, cioe' preventivo dal fornitore abituale, e va inoltrato insieme alla richiesta di conferma dell'ordine dell'access point del 31/07, che nessuna fonte del progetto risulta confermato.

> Serve uno **switch gestito con PoE** per sostituire uno switch non gestito a cinque porte che oggi dirama tre utenze in un punto tecnico raggiunto da una dorsale in categoria 6a. Requisiti: da cinque a otto porte, di cui almeno una che eroga **PoE 802.3at** per alimentare un access point da esterno che dichiara 24 W, con indicazione del **bilancio PoE totale** dell'apparato e non del solo numero di porte alimentate; **gestione cloud Nebula**, perche' l'apparato deve entrare nella stessa organizzazione che gia' gestisce gli altri switch e access point; alimentazione da presa di rete locale; e **intervallo di temperatura operativa dichiarato**, perche' l'apparato vive in un punto tecnico non climatizzato. Non servono porte a 2,5 o 10 Gb/s: la tratta negozia cento megabit e resta cosi'. Serve inoltre la **licenza Nebula Professional** per questo apparato e per l'access point, **co-terminata al 22/11/2027** per allinearla alle licenze in essere. Se disponibile, quotare anche un contenitore di protezione adeguato al punto di installazione.

Due note che stanno nella richiesta per una ragione e non per completezza. Il **bilancio PoE** si chiede perche' un apparato con quattro porte alimentate e un bilancio da 30 W alimenta un access point e nient'altro, e su quella derivazione le utenze sono cresciute due volte senza preavviso. L'**intervallo di temperatura** si chiede perche' l'access point del preventivo dichiara 0-50 gradi, che in un punto esterno esposto significa fuori specifica nelle notti d'inverno: e' la ragione per cui il contenitore protettivo non e' un accessorio estetico, e lo stesso vincolo vale per lo switch che gli sta accanto.

## Passo zero, prima di ordinare: la diagnostica del cavo

Da fare adesso, perche' decide se l'intervento comprende anche una ri-terminazione e perche' costa un clic. Nei pannelli Nebula, sul dettaglio della porta, la funzione **Cable diagnostic** manda un impulso e riporta lo stato coppia per coppia con la lunghezza stimata, con un errore dichiarato di circa dieci metri.

Il criterio di lettura e' scritto prima di guardare il risultato, cosi' non lo si interpreta a posteriori. Se le coppie risultano **due**, la dorsale in categoria 6a e' terminata a quattro fili e il limite e' la terminazione: va ri-terminata, e conviene farlo nella stessa uscita in cui si monta il contenitore, perche' l'elettricista e' gia' sul posto. Se le coppie risultano **quattro** e la velocita' resta 100 Mb/s, il limite e' altrove e il candidato successivo e' la qualita' della singola tratta o un apparato che forza la velocita', e in quel caso l'ipotesi di #196 va corretta invece di essere difesa. Se una coppia risulta interrotta a una distanza intermedia, quella distanza dice dove guardare.

Due avvertenze operative. La diagnostica **fa cadere il collegamento** per qualche secondo, quindi non si lancia durante un ciclo di irrigazione ne' mentre l'inverter sta comunicando dati che qualcuno sta guardando. E va lanciata su **entrambe** le porte 3 e 4, perche' il sintomo e' identico su due tratte posate nello stesso lavoro e una sola misura non distingue una coincidenza da una pratica di posa.

## Esito del passo zero, misurato il 09/09/2026

La diagnostica ha risposto: quattro coppie in stato `OK`, nessuna distanza di guasto, **Pair-A e Pair-B a 54,00 metri, Pair-C e Pair-D a 0,00**. Ne segue che la lunghezza non e' la causa del ripiego a 100 Mb/s, perche' cinquantaquattro metri stanno larghi dentro i cento ammessi, e che non c'e' un guasto localizzato, perche' una coppia interrotta a metà tratta avrebbe popolato la distanza di guasto. Lo stato `OK` con lunghezza zero e' la firma di una coppia non rilevata.

L'ipotesi delle due coppie non attestate e' quindi sostenuta e non dimostrata, e la ragione dell'ambiguita' va tenuta presente perche' e' dello strumento e non del cavo: con il collegamento attivo a 100 Mb/s soltanto due coppie trasportano segnale, e il riflettometro puo' non misurare quelle inattive. Il discriminante e' ripetere la misura con il collegamento **caduto**, quando il riflettometro misura i conduttori fisici a prescindere dall'uso, oppure aprire i due frutti di `0-8-1` e `0-9-1` e contare i fili attestati. La seconda verifica va fatta comunque durante l'intervento, quindi la prima serve solo a decidere **prima** se mettere la ri-terminazione nel preventivo dell'elettricista.

Resta da confermare il **numero della porta**: la pagina di dettaglio da cui viene la misura porta gli stessi contatori letti mezz'ora prima, e le porte 3 e 4 hanno lo stesso sintomo.

## L'esecuzione, in un ordine in cui ogni passo e' reversibile

Il principio che governa l'ordine viene dalle lezioni di change management del 16 e del 23/07/2026: il vecchio resta in servizio finche' il nuovo non e' verificato, e il punto di non ritorno si dichiara prima di attraversarlo.

Si comincia alimentando il nuovo switch dalla presa che alimenta il GS-105B e portandolo sulla porta 4 del 30HP, **senza** spostare ancora i tre rami. A questo punto lo switch nuovo e' in rete e non serve nessuno: si adotta in organizzazione Nebula, si verifica che risponda, e si legge la velocita' che negozia verso la porta 4, che e' la seconda misura utile della giornata perche' conferma o smentisce la diagnostica del cavo con un apparato diverso in fondo alla tratta. Se qui qualcosa non torna, non e' stato ancora toccato niente.

Poi si sposta **un ramo alla volta**, e l'ordine e' dal meno critico al piu' critico: prima l'inverter del fotovoltaico, poi l'access point nuovo in PoE dallo switch, per ultima la centrale di irrigazione. Dopo ogni spostamento si verifica quell'utenza prima di passare alla successiva, perche' tre spostamenti verificati insieme non dicono quale dei tre ha fallito.

Il collaudo dell'irrigazione e' l'unico che non si accontenta della raggiungibilita': **va fatto partire un ciclo davvero**, perche' un indirizzo che risponde dimostra che la scheda di rete della centrale funziona e non che l'impianto funziona. E' la ragione per cui l'intervento non si fa in una giornata in cui l'irrigazione e' critica.

Il punto di non ritorno e' lo scollegamento del vecchio access point Ubiquiti e la rimozione del GS-105B, che si fanno **solo dopo** i tre collaudi. Fino a quel momento il rollback e' rimettere i tre rami sul GS-105B, che resta sul posto alimentato e funzionante. Il vecchio access point non si smaltisce nella stessa giornata: si conserva finche' la tratta non ha visto un ciclo di irrigazione completo in condizioni normali.

## Che cosa leggere mentre il contenitore e' aperto

E' l'unico momento in cui alcune informazioni costano poco, e sono informazioni che il progetto non ha e che nessuna interrogazione automatica produce. Marca, modello, indirizzo e porte esposte dell'**inverter del fotovoltaico**, che resta l'asset di rete mai censito del sotto-gap di NET-017 e che finira' nel segmento IoT/OT di M22c. La posizione e il grado di protezione effettivi della derivazione `0-9-1`. Il modello e l'etichetta della presa che alimenta il punto, per la catena elettrica di `livello-fisico-ed-elettrico.md`. E la conferma di quanti cavi arrivino davvero al punto, perche' il conteggio dei rami del progetto viene da una descrizione e non da un rilievo.

## Dopo l'intervento, e non alla sessione successiva

Le due licenze **Nebula Professional**, una per apparato, entro **quindici giorni** dall'adozione di ciascuno e co-terminate al 22/11/2027. Non e' un adempimento amministrativo: il livello dell'organizzazione e' il minimo fra i suoi dispositivi, quindi un solo apparato scoperto la fa scendere a Base Pack allo scadere della grazia e con essa muore la OpenAPI da cui questo progetto legge porte, PVID, VLAN e tabelle MAC. E' accaduto il 05-06/08/2026 (NEB-002, ADR-022) e per due giorni lo strumento con cui si verifica il lavoro non e' esistito.

Poi si rinfrescano le fonti e si aggiornano gli artefatti, in questo ordine: `scripts/Get-NebulaSnapshot.ps1` per la misura nuova, `scripts/Export-PortMatrix.py` per la matrice tracciata, l'aggiornamento a mano di `data/network-topology.json` con il nodo nuovo e i tre rami al posto del GS-105B, `scripts/Build-NetworkMap.ps1` per rigenerare la mappa, e `scripts/Test-TopologyDrift.py` che a quel punto deve tornare allineato. La regola di M26 e' che la mappa si aggiorni al primo intervento utile: se non lo fa qui, il modello ha gia' fallito.

Restano da chiudere tre voci del registro che questo intervento tocca. La dismissione del vecchio access point chiude **#124 (SEC-018)**, ultimo dei quattro apparati con Debian 7 e SSH Dropbear aperto, e il suo smaltimento ricade su **ENV-001 (#109)**. Il difetto **#196 (NET-031)** si chiude se la ri-terminazione porta la tratta a 1 Gb/s, e si riformula se la diagnostica dice altro. Il difetto **NET-017 (#136/#136b)** si chiude per sostituzione, perche' l'apparato non gestito cessa di esistere. E **M13c-8** diventa eseguibile: la porta 4 potra' portare la VLAN 60 verso irrigazione e inverter quando il segmento esistera', cosa che con un apparato non gestito in fondo alla tratta non era possibile.

## Il vincolo che resta, e che non va perso nell'entusiasmo

La chiave Nebula in uso e' di **sola lettura** per scelta (ADR-009), e il canale di scrittura verso gli switch si e' dimostrato inaffidabile (ADR-010, NEB-001), con scritture perse in silenzio. La configurazione del nuovo switch si fa dai pannelli e non da questo repository, e questo repository resta cio' che legge e verifica.
