---
last-verified: 4079c8e
---

# Studio didattico: racconto evolutivo delle scelte di qualità

> Livello adottato il 20/10/2026 su richiesta esplicita dell'IT Manager. Non è una scheda di stato e non sostituisce `STACK.md`, `design-and-security.md` o il registro delle decisioni: quelli dicono che cosa è vero adesso e quale decisione è stata presa, questo dice perché una forma precedente era fragile e perché quella nuova è un salto. Cresce per voci numerate in ordine cronologico, si aggiunge in fondo e non si riscrive. Si alimenta a ogni refactor o scelta di qualità non ovvia, non a ogni intervento.
>
> La pratica parte da qui in avanti: le voci del passato non si ricostruiscono a posteriori.

## 1. Un filtro attivo non è una porta chiusa

Contesto. Dall'agosto 2026 il progetto descrive la protezione della VPS di produzione del sito, e per estensione delle macchine Linux del parco, con una formula che compare nel diario di impianto, nella scheda del piano e nel documento di consegna: filtro di sistema attivo, politica di rifiuto in ingresso, tre porte aperte. Il 20/10/2026, leggendo le fonti ufficiali per chiudere il registro delle fonti del filone, quella formula è risultata non descrivere ciò che tutti credevano descrivesse.

Com'era e perché era fragile. La forma precedente non era una riga di codice ma un'inferenza, e per questo è sopravvissuta a tre riletture: dato che il filtro è attivo e ammette soltanto tre porte, qualunque altra porta è chiusa. L'inferenza è valida per un processo che ascolta sull'host, ed è falsa per un servizio pubblicato da un contenitore. La documentazione del motore dei container lo dichiara: il traffico verso una porta pubblicata viene deviato prima di passare dalle impostazioni del filtro, perché le regole del motore vivono nella tabella `nat` e precedono la catena che il filtro usa. Il filtro non viene aggirato per un difetto, ma per costruzione.

La fragilità strutturale sta nel fatto che la frase era *verificabile* e nessuno l'aveva verificata, perché sembrava una constatazione e non un'affermazione. La porta aperta ne è la conseguenza, non la causa. Un filtro attivo si legge con un comando e restituisce una risposta rassicurante; la domanda che contava, cioè se quella risposta coprisse il servizio di cui si stava parlando, non veniva posta. Lo stesso errore avrebbe prodotto, sulla VPS, una produzione con il database pubblicato e un filtro che sembrava proteggerlo.

Il salto senior e perché è meglio. La correzione tecnica è di una riga e consiste nel legare la pubblicazione al solo indirizzo di loopback invece che a tutte le interfacce. Il principio generale che la guida è più grande della riga: *il perimetro si dichiara al livello in cui viene davvero applicato, e un controllo si valuta per ciò che copre e non per ciò che risponde*. Ne segue che l'unica difesa efficace per una porta pubblicata da un contenitore è non pubblicarla, o pubblicarla dove non serve raggiungerla; e ne segue che nelle schede del progetto la frase sul filtro va qualificata con il livello a cui vale, invece di essere ripetuta come una proprietà della macchina.

Il compromesso dichiarato è che la correzione non si applica modificando il descrittore, perché il contenitore in esercizio non è stato creato da quel descrittore: va ricreato. È una scelta di perimetro deliberata non automatizzare quella ricreazione, perché il volume è esterno e un errore nel nome produrrebbe un database vuoto senza alcun errore, che è esattamente il guasto silenzioso che questa voce racconta in un'altra forma.

Dove leggere il dettaglio: `refactor-01-filtro-e-contenitori.md`.

## 2. Una copia che vive sulla macchina che protegge non è una copia

Contesto. Dal 26/10/2026 il sito nuovo gira sulla VPS di produzione, e prima di ogni rilascio si prende una copia logica della banca dati e un archivio dei file caricati, conservati in una cartella della VPS stessa. Il salvataggio notturno su un NAS della sede era deciso (ADR-044) ma messo in coda dopo il go-live. Il 29/10 il team ha scelto di salvare nella banca dati del sito le iscrizioni alla newsletter e gli invii dei moduli: da quel giorno la VPS custodisce dati personali che non esistono altrove, e l'IT Manager ha anticipato il salvataggio a prima della pubblicazione.

Com'era e perché era fragile. Sotto la parola copia convivevano due oggetti diversi. La copia presa prima di un rilascio serve a tornare indietro se il rilascio va male, e per quello scopo la VPS è il posto giusto, perché il ripristino è immediato. Contro la perdita della macchina, invece, non protegge niente: sta sullo stesso disco, sullo stesso account del fornitore e sullo stesso credito prepagato, quindi qualunque evento che porti via la VPS porta via anche lei. Finché la si chiamava salvataggio, la domanda su che cosa succede se sparisce la macchina aveva una risposta rassicurante e sbagliata.

La fragilità si sarebbe ripetuta anche nelle automazioni più ovvie. Un lavoro pianificato sulla VPS che spinge le copie verso il NAS obbliga ad aprire alla VPS una strada verso la rete della sede, cioè a rovesciare la direzione della fiducia: oggi la sede raggiunge la VPS e non il contrario. Uno script che conserva tutto ciò che riceve sostituisce, nella notte in cui la copia arriva troncata, una copia buona con una inutilizzabile, senza nessun errore. E una copia mai ripristinata è un'ipotesi, come il piano di manutenzione del sito scriveva già.

Il salto senior e perché è meglio. Il principio è che *una copia vale per il guasto da cui è separata, e conta solo dopo che qualcuno l'ha letta*. Ne discendono tre scelte. La copia sta in un dominio di guasto diverso, il NAS della sede, e la va a prendere la parte protetta: è il contenitore della sede che si collega alla VPS, quindi la VPS non riceve nessun accesso nuovo verso la sede. La credenziale che la prende sa fare una cosa sola: sulla VPS la chiave è legata a un comando forzato che restituisce l'archivio e ignora qualunque altra richiesta, e l'esecutore è un contenitore non privilegiato con una condivisione del NAS sua, così che chi lo compromettesse non troverebbe né i diritti del nodo né le copie delle altre macchine. Infine la copia entra fra quelle conservate solo dopo una verifica: l'archivio deve contenere la banca dati e le due cartelle, e `pg_restore` deve elencarvi almeno le 343 tabelle misurate il 28/10. Una copia che fallisce la verifica dà allarme e non sostituisce nessuna copia buona.

Il compromesso dichiarato è triplice. Un contenitore isola meno di una macchina virtuale, perché condivide il kernel del nodo, e la scelta regge solo grazie alle compensazioni appena descritte. Il canale dell'avviso non è ancora deciso, quindi oggi un allarme resta nel giornale di sistema finché qualcuno non lo legge. E una copia verificata non è ancora un ripristino provato: finché la prima prova di ripristino non è cronometrata e scritta, si può dire che la copia è leggibile, non che il sito si rimette in piedi in un tempo noto.

Dove leggere il dettaglio: `refactor-02-salvataggio-del-sito.md`.
