# Igiene delle caselle, degli spazi personali e dell'archivio storico aziendale

> Contesto portato qui dal progetto `export-teams-chat` il 2026-10-23, su richiesta dell'IT Manager, perché il problema non è di quel progetto ma della roadmap complessiva della rete. Quel progetto ha incontrato il problema per caso, estraendo conversazioni Teams del 2021, e ciò che ha accertato vale per qualunque recupero futuro di materiale aziendale. I nominativi sono sostituiti da segnaposto fra parentesi angolari, perché questo documento è versionato.

## Dove vive davvero un file scambiato in Teams

Un file allegato a una chat uno a uno non sta dentro il messaggio. Sta nel OneDrive di chi lo ha inviato, nella cartella «File di chat di Microsoft Teams» del suo spazio personale, e il messaggio ne conserva soltanto un riferimento, cioè il nome, il tipo `reference` e un collegamento della forma `https://<tenant>-my.sharepoint.com/personal/<utente>_<dominio>_com/Documents/File di chat di Microsoft Teams/<nome file>`. Nei canali, invece che nelle chat, i file stanno nella raccolta documenti del sito SharePoint del team, e seguono quindi il ciclo di vita del team e non quello di una persona.

Da questa architettura discendono tre conseguenze che contano per la conservazione e per gli accessi, e che conviene fissare perché nessuna delle tre è intuitiva.

La prima è che l'allegato segue il ciclo di vita dello spazio personale del mittente e non quello del messaggio. La conservazione dei messaggi di Teams non preserva i file allegati: se chi lo ha inviato cancella il file, o se il suo spazio personale viene svuotato, la conversazione continua a mostrare il nome dell'allegato mentre il collegamento non porta più a niente. Un collegamento conservato in un inventario è quindi un puntatore storico, cioè dice dove il file stava allora e non che esista oggi.

La seconda è che i permessi sul file non derivano dall'appartenenza alla chat. Chi può aprire quel file lo decide la condivisione in OneDrive, e un permesso applicativo di sola lettura sulle chat non basta a scaricarlo: servono `Files.Read.All` oppure `Sites.Read.All` con consenso amministrativo. Un'applicazione che legge le conversazioni può quindi inventariare gli allegati, cioè nome, data, mittente e collegamento, e non può recuperarne il contenuto.

La terza è che il materiale di un rapporto di lavoro finito si disperde fra almeno tre contenitori con regole diverse, cioè la casella di posta, lo spazio personale e i siti dei team, e nessuno dei tre è l'archivio aziendale.

## Che cosa succede allo spazio personale di chi esce

L'osservazione che ha fatto nascere questa nota riguarda una collaboratrice uscita, `<collaboratrice uscita>`. Aprendo il suo spazio personale da browser, Microsoft 365 risponde che lo spazio è stato archiviato perché l'account non dispone di licenza, e invita a contattare l'amministratore IT per riattivarlo. Il sito quindi esiste e non è stato cancellato.

Il riscontro è indipendente e vale la pena registrarlo come metodo, non solo come esito: l'esportatore di `export-teams-chat` ha risolto quell'utente in Entra ID ottenendo un oggetto utente valido, con cui ha poi letto la conversazione, e un oggetto cancellato non si risolverebbe in quel modo.

Le regole in gioco sono tre e si confondono facilmente. Ciò che distrugge uno spazio personale è la cancellazione dell'account in Entra ID, non la perdita della licenza: alla cancellazione il sito entra in conservazione per un periodo definito dalla configurazione del tenant, e poi sparisce. La conversione della casella a cassetta condivisa, che serve a tenere viva la posta di chi è uscito senza pagarle una licenza, è un'operazione di Exchange e non tocca OneDrive; lascia in genere l'account presente e disabilitato. Togliere la licenza, da sola, non cancella il sito personale: lo lascia esistente e senza titolare attivo, ed è proprio questo lo stato che Microsoft ha cominciato a trattare come spazio da archiviare e da tariffare dopo un periodo di inattività. Dallo stato archiviato si esce riattivando il sito dal centro di amministrazione SharePoint; la riattivazione non è istantanea e comporta un addebito legato alla dimensione. I termini esatti vanno letti nel tenant e qui non sono verificati.

## Perché questo entra nella roadmap della rete

L'IT Manager chiede che la roadmap complessiva comprenda il risanamento delle caselle di posta di Intrawelt, degli spazi personali, dei file, e la decisione su dove archiviare lo storico aziendale di questa natura. Il problema non è un singolo recupero andato male: è che oggi lo storico aziendale vive dentro contenitori legati a persone, con cicli di vita e costi che nessuno governa, e che si scoprono soltanto quando qualcuno cerca un documento di cinque anni prima.

Le domande che la roadmap deve chiudere sono queste. Quali account esistono senza licenza, in quale stato è il loro spazio personale, e quanto spazio e quanto costo rappresentano oggi. Che cosa va conservato davvero dello storico di una persona uscita, e con quale termine, distinguendo la posta dai file. Dove vive l'archivio aziendale di destinazione, con quali permessi, quali copie e quale verifica di integrità, dato che una risorsa di rete senza cifratura del disco e senza controllo degli accessi documentato non è un archivio ma un deposito. Quale procedura si applica all'uscita di una persona, prima che la licenza venga tolta, perché tutte le domande precedenti diventano più care e più incerte dopo. E chi decide, dato che la scelta su finalità e durata della conservazione non è una scelta tecnica.

## Il tooling che esiste già e quello che manca

Il progetto `mail-cleaner-exporter` copre la prima metà del problema, cioè le caselle. È un toolkit riusabile per esportare in modo statico le caselle di Exchange Online del tenant Intrawelt verso una risorsa di rete, allo scopo di archiviare la posta prima di liberarne lo spazio; il metodo di riferimento è l'export PST da Microsoft Purview eDiscovery, con una via alternativa da Outlook classico dove manca la licenza adeguata sull'operatore, più script di verifica preliminare in sola lettura e di archiviazione con impronte. Nasce da due cassette condivise piene al cento per cento, primaria e archivio online, che è esattamente il sintomo descritto qui.

Quel progetto va quindi riusato e non riscritto, ma non copre la seconda metà: gli spazi personali OneDrive, i siti SharePoint dei team e gli allegati delle chat restano fuori dal suo perimetro, e sono proprio i contenitori che questa nota mostra essere i più fragili. Serve una procedura gemella per gli spazi, con lo stesso impianto, cioè verifica preliminare in sola lettura, export verso la risorsa di rete, impronte e registro di ciò che è stato spostato, e con in più il passaggio di riattivazione per gli spazi archiviati.

Dal lato dei permessi applicativi, infine, va deciso in modo consapevole se concedere `Files.Read.All` o `Sites.Read.All` all'applicazione che già legge le conversazioni, perché senza quel permesso un recupero di allegati si ferma all'inventario. È un ampliamento di perimetro dai messaggi ai file personali, quindi è una decisione del titolare e non dell'operatore.
