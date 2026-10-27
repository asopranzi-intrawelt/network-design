# Accesso di emergenza alla VPS del sito: la via fuori banda, e come si percorre

> Scheda aperta il 26/10/2026, quando la via fuori banda è tornata a funzionare dopo essere stata dichiarata guasta il 22/10. Serve a una sola cosa: entrare nella macchina quando la via ordinaria non c'è più. Si legge in un momento in cui nessuno ha voglia di cercare, quindi è corta e dice i passi nell'ordine in cui si premono. Il contesto del difetto che l'ha resa necessaria sta in GAP-TBC #224; qui c'è la procedura.

## Quando serve, e quando non serve

Serve quando la via ordinaria non risponde: il servizio di accesso remoto è fermo, la regola del filtro è stata scritta male e si è chiusa la porta da cui si stava passando, l'indirizzo pubblico della sede è cambiato e non è più fra quelli ammessi, oppure la macchina si avvia ma la rete no. In tutti questi casi la macchina è viva e irraggiungibile, ed è esattamente la situazione per cui una via fuori banda esiste.

Non serve per l'amministrazione quotidiana, e il fornitore stesso lo dichiara nella finestra che la propone: è una console di ripristino, non un terminale di lavoro. Non ha il trasferimento di file, non regge una sessione lunga e passa dalla sua infrastruttura invece che dalla nostra chiave.

## Il percorso, misurato il 26/10/2026

Il percorso è stato percorso per intero e si è fermato soltanto al prompt di accesso, che è il punto in cui doveva arrivare. Va detto subito perché è la cosa che il 22/10 non si era capita: la console **non funziona dal pannello nuovo**, dove l'interfaccia del fornitore cade con un errore del suo servizio, e **funziona dal pannello precedente**, che dal nuovo si raggiunge in due clic.

Si entra nel pannello del fornitore con le credenziali dell'account. In alto a destra compare l'identificativo dell'account con una freccia: si apre quel menu e si sceglie la voce che porta al pannello di controllo precedente. Da lì, nel menu di sinistra, si apre la sezione dei server e poi la voce di gestione, che elenca le macchine con nome, indirizzo pubblico, sistema operativo e risorse.

Da quell'elenco ci sono due strade equivalenti. Il menu dei tre punti in fondo alla riga della macchina offre, fra le operazioni rapide, la voce di accesso; oppure si apre la macchina con il comando di gestione e nella sua pagina, nel riquadro delle azioni, si trova il comando che apre la console. In entrambi i casi compare prima una finestra che riepiloga i modi di connettersi, e in fondo il comando che apre davvero la console di ripristino.

La console si apre in una pagina a sé e mostra il prompt di accesso della macchina, con la versione del sistema operativo e il terminale virtuale. Da lì si entra con l'utenza amministrativa e la sua password, che è l'altra metà della ragione per cui questa via va presidiata.

## Che cosa serve avere prima, e dove sta

Due cose, e nessuna delle due si improvvisa nel momento del bisogno. Le credenziali del pannello del fornitore, senza le quali non si arriva nemmeno all'elenco delle macchine. E la password dell'utenza amministrativa della macchina, perché la console non usa le chiavi crittografiche con cui si entra per la via ordinaria: chiede utenza e password, e quelle chiavi lì non valgono. Entrambe vanno custodite nel gestore delle password aziendale e verificate quando si verifica il resto, non quando servono.

Ne discende una conseguenza che vale la pena dichiarare, perché è il motivo per cui questa via è una ridondanza vera e non apparente: usa credenziali diverse e un canale diverso da quello ordinario. Se la via ordinaria cade per una chiave persa, per una regola di filtro sbagliata o per un servizio fermo, questa regge, perché non dipende da nessuno di quei tre.

## Il limite che resta

La console passa dall'infrastruttura del fornitore, quindi quando il fornitore ha un guasto la via di emergenza non c'è. È successo il 22/10/2026, quando l'interfaccia del pannello nuovo rispondeva con un errore del suo servizio e nessuna via di accesso aziendale alla macchina esisteva, né in banda né fuori. La scoperta del 26/10 è che il pannello precedente non era toccato da quel guasto, quindi oggi la ridondanza è reale; resta che entrambe le vie fuori banda appartengono allo stesso fornitore e cadono insieme se cade lui.

Il presidio che ne discende è semplice e va fatto quando non serve: questa procedura si riprova una volta ogni tanto, per esempio insieme alla verifica periodica degli accessi, perché una via di emergenza mai provata è una dichiarazione e non una via. È lo stesso errore che il 22/10 aveva fatto considerare funzionante una console che nessuno aveva mai aperto.
