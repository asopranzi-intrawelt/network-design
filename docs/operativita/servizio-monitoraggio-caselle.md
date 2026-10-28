# Servizio di monitoraggio delle caselle di posta

Questo documento esiste perché il servizio che sorveglia l'occupazione delle caselle Microsoft 365 di Intrawelt deve lasciare la postazione su cui gira oggi e diventare una macchina virtuale Proxmox dedicata. Il codice e la memoria di progetto del servizio vivono in un repository proprio; qui si registra soltanto ciò che cambia la rete, cioè dove il servizio andrà a stare, da che cosa dipende per funzionare e che cosa va osservato perché non si fermi di nuovo in silenzio.

## Che cosa fa il servizio, e perché la sua collocazione attuale è il problema

Il servizio interroga ogni mattina il tenant Microsoft 365 attraverso Microsoft Graph ed Exchange Online, raccoglie per ogni casella l'occupazione della cassetta primaria e dell'archivio online, aggiorna uno storico locale, genera due fogli di calcolo e invia un riepilogo alla casella `it@` più una notifica personale a ciascun titolare di casella in soglia. L'autenticazione è a certificato su una app registration, quindi non interattiva. Un secondo compito settimanale produce i report di tendenza.

Gira come attività pianificata di Windows sulla postazione di lavoro dell'autore, sotto la sua utenza interattiva, con una password memorizzata nel registro delle credenziali dell'Utilità di pianificazione. Questa collocazione ha prodotto un fermo misurato di ventitré giorni, dal 2026-10-06 al 2026-10-28, scoperto per caso. Il riavvio da Windows Update del 2026-10-06 ha invalidato la credenziale memorizzata; da allora l'Utilità di pianificazione ha rifiutato l'avvio ogni mattina con errore `0x8007052E`, ERROR_LOGON_FAILURE, registrato come evento 101 nel suo registro operativo. Lo script non è mai partito, quindi non ha prodotto nessun log, e il contatore delle esecuzioni mancate è arrivato a ventitré mentre lo stato dell'attività continuava a mostrarsi come pronto e l'ultimo esito registrato restava zero, cioè successo, perché apparteneva all'ultima esecuzione davvero avvenuta.

Il rimedio applicato il 2026-10-28 è stato reimmettere la password sulle due attività, e il servizio è tornato pronto. Resta un cerotto che ricadrà al prossimo cambio di password, ed è la ragione per cui la migrazione non è un miglioramento ma una correzione.

## La destinazione e i tre vincoli che non si trasferiscono con una copia

La destinazione è una macchina virtuale Proxmox dedicata, piccola e a scopo unico, che non si riavvia per gli aggiornamenti di una postazione, non dipende dalla sessione interattiva di nessuno e il cui stato è osservabile dall'esterno. Il requisito che la governa è la continuità del servizio.

Tre dipendenze vanno risolte prima di spegnere l'attività sulla postazione, perché nessuna delle tre si trasferisce copiando una cartella. La prima è il certificato della app registration, che vive nell'archivio certificati dell'utente corrente della postazione con la sua chiave privata e scade nel maggio 2028: sulla macchina virtuale va reinstallato come PFX esportato, oppure sostituito da un certificato nuovo caricato sulla app registration, e la scelta fra le due vie decide se il vecchio resti valido durante la transizione. La seconda è la credenziale del server di posta in uscita, cifrata con DPAPI e quindi decifrabile solo dall'utente Windows che l'ha creata sulla macchina che l'ha creata: va rigenerata sulla macchina virtuale e non copiata. Lo stesso vincolo spiega perché il tipo di accesso dell'attività pianificata non può passare a S4U come rimedio rapido, visto che sotto quel tipo di accesso DPAPI non dispone della chiave che sblocca la chiave principale dell'utente. La terza è lo storico, un database locale che contiene la serie da maggio 2026 e su cui poggiano tutti i confronti di crescita: va trasferito e non ricostruito.

## L'assenza che ha reso invisibile il fermo

Il solo canale che segnalava il funzionamento del servizio era la posta che il servizio stesso invia. Il suo fermo si è quindi manifestato come silenzio, che è indistinguibile da una giornata senza allarmi, ed è il motivo per cui ventitré giorni non hanno prodotto nessun segnale. Sulla macchina virtuale serve un controllo di vivacità esterno al processo, che osservi la freschezza dell'ultima esecuzione riuscita invece della sola raggiungibilità della macchina: una sonda che dica che la macchina risponde avrebbe dichiarato verde per tutti e ventitré i giorni. Il criterio è quello già adottato nell'area [osservabilità](../osservabilita/README.md), dove il valore di un servizio è un tasso e non una disponibilità.

## Il lavoro di merito che attende sul versante posta

Indipendentemente da dove giri il servizio, la misura del 2026-10-28 ha messo in evidenza una saturazione degli archivi online che il monitoraggio segnalava e che nessuno aveva preso in carico. Undici caselle risultano in soglia sull'archivio; di queste quattro sono oltre la quota assegnata, non vicine, e una quinta ha meno di dieci megabyte liberi. Il confronto va fatto sui byte e non sulla resa arrotondata, che per tutte mostra lo stesso valore.

La cassetta primaria non è il problema e la ricezione non è a rischio: la più piena del tenant sta sotto l'ottanta per cento. Ciò che si è fermato è l'archiviazione, perché la policy di retention predefinita sposta nell'archivio i messaggi oltre una certa età e l'archivio non accetta più nulla; la conseguenza è che quei messaggi restano nella cassetta primaria, che quindi comincerà a crescere.

La leva tecnica esiste e si chiama archiviazione ad espansione automatica, che porta l'archivio da una quota fissa fino a un ordine di grandezza superiore. Sul tenant è spenta a livello di organizzazione. Il vincolo non è tecnico ma di licenza: l'espansione automatica richiede un piano o un componente aggiuntivo che la maggior parte delle caselle in sofferenza non ha, e fra le undici una sola possiede oggi una licenza che la consente, per di più l'unica non satura. Cinque delle undici sono caselle condivise con archivio attivo e nessuna licenza assegnata, il che è anche una questione di conformità alle condizioni di licenza, da guardare a parte. Attivare l'espansione automatica è inoltre irreversibile, quindi non è un'operazione da fare in blocco.

Ne segue che la decisione è di natura economica e spetta alla direzione, e che la via a costo zero, cioè esportare e cancellare il contenuto vecchio, risolve per qualche mese e non toglie la causa.

## La campagna di phishing che ha fatto scoprire il fermo

Il fermo del servizio e' emerso perche' una mail sospetta e' arrivata a una casella funzionale il 2026-10-28 e si e' voluto capire se l'avesse prodotta il monitoraggio. Non l'aveva prodotta: e' phishing, ed e' accertato e non supposto.

La mail si presenta con marchio Microsoft 365, in inglese, con oggetto che dichiara una casella al novantotto per cento di quota e un pulsante «Manage my mailbox». Il collegamento sotto quel pulsante punta al dominio `mastbusiness.com`, attraverso un sottodominio di dieci caratteri casuali, con un percorso lungo e opaco che ha la forma di un identificativo per destinatario, cioe' il meccanismo con cui una campagna riconosce chi ha premuto e precompila la pagina di accesso falsa. Un avviso di quota autentico di Microsoft porta a un dominio Microsoft. Il dominio e' riportato qui per intero perche' e' un dato sulla minaccia e non un dato aziendale, secondo l'eccezione prevista dalla regola di anonimizzazione; il percorso completo no, perche' identifica il destinatario.

Tre riscontri indipendenti lo confermano. Il servizio di monitoraggio era fermo da ventitre' giorni quel giorno, quindi non puo' aver inviato nulla. Le sue notifiche vere sono in italiano, partono da una casella del dominio aziendale, vanno alla casella interessata e non a un alias, e nominano sempre la casella e i gigabyte occupati, mentre questa non nomina alcuna casella. E l'affermazione centrale della mail, cioe' che i messaggi in arrivo vengano restituiti al mittente, e' falsa su questo tenant, dove nessuna cassetta primaria era in soglia.

Ne seguono due azioni che non appartengono a questo documento ma vanno nominate perche' non si perdano: bloccare il dominio sul filtro di posta e verificare con una ricerca messaggi quante caselle lo abbiano ricevuto e se qualcuno abbia premuto.

## Provenienza delle affermazioni

Le misure sullo stato delle attività pianificate, sugli eventi dell'Utilità di pianificazione, sul riavvio da aggiornamento e sulla scadenza del certificato sono letture dirette della postazione del 2026-10-28. Le misure sull'occupazione degli archivi, sulla policy di retention e sullo stato dell'espansione automatica sono letture dirette del tenant della stessa data, in sola lettura e senza invii. Le licenze per casella vengono invece dallo storico locale del 2026-10-05 e non da una lettura odierna, quindi hanno ventitré giorni: vanno riverificate prima di qualunque decisione di acquisto. Che l'interruzione del servizio risalga precisamente al 2026-10-06 è un'inferenza e non una misura, perché il registro operativo conserva solo gli ultimi giorni; poggia sul numero di esecuzioni mancate e sull'assenza di log successivi.

Torna all'[operatività](README.md).
