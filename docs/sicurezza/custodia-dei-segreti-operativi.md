---
last-verified: 2026-10-30
covers-paths:
  - scripts/Set-ProjectSecret.ps1
  - scripts/Read-ProjectEnv.ps1
  - scripts/Get-BitdefenderSnapshot.ps1
  - scripts/Sign-ProjectScripts.ps1
---

# Custodia dei segreti operativi della postazione

> Scheda del 30/10/2026. Nasce da una domanda dell'IT Manager mentre si aggiungevano al progetto la chiave API della console di protezione degli endpoint e la firma del codice: come si proteggono i segreti che stiamo aggiungendo, e come si protegge nel frattempo la cartella riservata dove oggi vivono, finche' il gestore delle password non sara' in servizio. I percorsi reali e i valori restano nel livello privato; qui stanno il criterio e le pratiche.

## Il criterio, prima delle pratiche

La protezione di un segreto non e' la somma delle misure che lo circondano: e' la piu' debole fra quattro cose, cioe' dove e' conservato, chi lo puo' leggere, quanto a lungo vale e che cosa consente di fare. Una chiave cifrata con un algoritmo robusto non e' protetta se la frase che la decifra sta nella stessa cartella; una credenziale di sola lettura che finisce in pubblico costa molto meno di una che poteva anche scrivere; una chiave che scade fra un anno vale un anno di esposizione se qualcuno la copia oggi. Ne discende l'ordine in cui conviene intervenire, che non e' quello dell'istinto: prima si riduce cio' che un segreto consente, poi quanto dura, poi chi lo legge, e solo alla fine si pensa a cifrarlo meglio dove sta.

Vale anche l'inverso, ed e' la ragione per cui questa scheda esiste adesso e non dopo. Ogni strumento nuovo che il progetto costruisce aggiunge un segreto, e un segreto aggiunto senza una decisione su queste quattro cose la prende lo stesso, per inerzia: finisce dove e' comodo, con i permessi che aveva il modulo da cui e' stato copiato, con la scadenza predefinita e leggibile da chiunque legga quella cartella.

## Il difetto che si misura oggi, e perche' conta piu' degli altri

Nella cartella riservata dell'IT, sincronizzata su un servizio cloud, convivono il materiale dell'autorita' di certificazione aziendale recuperato dopo il guasto del supporto del 26/10/2026 e un file di testo che contiene le passphrase di quell'autorita'. Il PKCS#12 della firma del codice e' cifrato in AES-256, e la cifratura e' corretta; ma la frase che la apre sta nella cartella che la contiene, a un livello di distanza. Per chiunque ottenga quella cartella, la cifratura del contenitore non aggiunge nulla: chiave e serratura viaggiano insieme.

Non e' un rimprovero a una scelta fatta sotto pressione, perche' quella copia nasce da un recupero d'emergenza riuscito e il primo obiettivo era non perdere il materiale. E' il momento giusto per separarle, ora che l'emergenza e' finita. La scheda dell'autorita' prescriveva gia' la forma corretta, cioe' passphrase scritte su carta e custodite in busta chiusa fino all'entrata in servizio del gestore delle password: va applicata a questa copia, togliendo il file delle passphrase dalla cartella sincronizzata.

Si somma un secondo fatto, che riguarda la sincronizzazione e non la cartella. Cio' che sta li' dentro non e' su una macchina: e' sul servizio cloud e su ogni dispositivo dove quell'account e' collegato, piu' il cestino del servizio e le sue versioni precedenti, che sopravvivono alla cancellazione. Una chiave privata di un'autorita' di certificazione in quella posizione contraddice la ragione per cui ADR-025 prescriveva un supporto rimovibile, cioe' che una chiave che non sta su nessuna macchina non si ottiene compromettendo una macchina. La deroga e' consapevole e registrata; la conseguenza da trarne e' che serve una misura compensativa, non che la cosa sia neutra.

## Le pratiche, per il materiale che stiamo aggiungendo

### La chiave API della console di protezione degli endpoint

Una chiave di servizio va creata con i soli permessi che lo strumento usa, e lo strumento del progetto e' di sola lettura: i permessi di scrittura che la chiave oggi porta non servono a nessuno e consentono azioni serie, come isolare un endpoint o cambiare una policy. La durata si sceglie la piu' breve compatibile con l'uso, non la massima offerta. La chiave vive in un posto solo: ora che sta nel file privato del progetto, con la lista chiusa delle chiavi ammesse e i permessi ristretti, la copia in chiaro nella cartella sincronizzata va cancellata, perche' due copie di un segreto raddoppiano le occasioni di perderlo e nessuna delle due e' autorevole. La scadenza entra nel registro delle scadenze nello stesso giro in cui la chiave nasce, perche' alla scadenza nessun allarme arriva dalla console e l'unico segnale sarebbe il fallimento silenzioso dello strumento.

### Il materiale dell'autorita' e la firma del codice

La chiave privata dell'autorita' e quella di firma non si leggono, non si copiano e non si importano nell'archivio certificati della macchina: lo strumento di firma del progetto carica il PKCS#12 dal file e lo tiene in memoria, cosi' che non resti traccia nel profilo utente. La passphrase si chiede a runtime e non passa mai dalla riga di comando, perche' la riga di comando finisce nella cronologia della shell e nell'elenco dei processi. Il certificato pubblico si puo' distribuire liberamente, la chiave privata mai: sono due file diversi e vanno trattati come tali. Finche' il materiale resta in una cartella sincronizzata, la misura compensativa e' un contenitore cifrato con una passphrase propria, in modo che cio' che lascia la macchina sia cifrato e non solo cio' che sta dentro il PKCS#12.

Vale inoltre una regola che riguarda il tempo e non il luogo: una firma senza marca temporale muore con il certificato che l'ha apposta. Lo strumento di firma del progetto rifiuta percio' di firmare senza marca temporale, e non e' una comodita': senza, il 15/11/2027 ogni script firmato diventerebbe non fidato nello stesso giorno.

### Le credenziali che appartengono a terzi

Le credenziali della console di gestione degli endpoint appartengono al fornitore che gestisce il servizio, non al progetto. Da qui discende che non si duplicano nel file privato di questo repository: si passano allo strumento come variabili della sessione, che muoiono con la finestra, oppure si digitano al prompt. Lo strumento del progetto e' gia' costruito cosi', e lo scope richiesto resta quello di sola lettura. Una credenziale di terzi copiata in un repository, anche privato, crea un obbligo di custodia che nessuno ha assunto.

### La regola che vale per tutti

Un segreto non entra mai in un file tracciato, in un messaggio, in un registro o in un documento generato, nemmeno troncato, perche' un frammento restringe lo spazio di ricerca di chi prova a indovinarlo. Non si scrive sulla riga di comando. Non si fa leggere a un assistente: le regole di permesso del progetto negano gia' la lettura del file privato e delle chiavi, e quella negazione va mantenuta anche quando sarebbe comodo aggirarla. Ogni segreto aggiunto porta con se', nello stesso giro in cui nasce, tre cose scritte: dove vive, che cosa consente e quando scade.

## Che cosa fare della cartella riservata, nel frattempo

Il gestore delle password non e' in servizio, ed e' una lacuna gia' registrata dal progetto. Finche' non lo sara', la cartella resta la custodia di fatto di credenziali di sistemi, caselle, apparati e fornitori, quindi va trattata come tale invece di essere lasciata crescere. L'ordine delle misure segue il criterio enunciato sopra, dalla piu' efficace alla piu' costosa.

La prima e' separare le passphrase dal materiale che proteggono, togliendo il file delle passphrase dalla cartella sincronizzata e portandolo nella forma gia' prescritta, cioe' su carta in busta chiusa. E' la misura che costa meno e rende utile tutta la cifratura che gia' c'e'.

La seconda e' cifrare prima della sincronizzazione il materiale che non deve uscire dalla macchina in chiaro, cioe' almeno la cartella dell'autorita': un contenitore cifrato con passphrase propria, custodita separatamente, fa si' che cio' che arriva al servizio cloud e agli altri dispositivi sia cifrato. Non risolve la duplicazione, la rende inutile a chi la ottiene.

La terza e' guardare chi vede quella cartella: le condivisioni attive del servizio cloud, i dispositivi collegati a quell'account e i permessi locali della cartella. Una cartella riservata condivisa per comodita' con qualcuno che non serve piu' e' il modo piu' comune in cui una custodia smette di esserlo, e non lascia traccia visibile a chi la usa ogni giorno.

La quarta e' togliere da li' cio' che non ha piu' ragione di starci, che oggi comprende almeno la copia in chiaro della chiave API ora custodita nel file privato del progetto, e in generale le credenziali di sistemi dismessi, che non servono a nessuno e restano esposte.

La quinta, quando il gestore delle password entrera' in servizio, e' la migrazione, e va fatta con un criterio e non per svuotamento: ogni voce che migra viene anche ruotata, perche' una credenziale che e' stata per anni in un file di testo sincronizzato va considerata potenzialmente nota, e la migrazione e' l'unico momento in cui ruotarla costa poco. Le passphrase dell'autorita' sono il caso in cui questo conta di piu'.

## Che cosa questa scheda non afferma

Nessuna compromissione e' stata osservata, e nulla qui va letto come un incidente: si descrive un'esposizione possibile, non un fatto avvenuto. Non e' stato letto il contenuto di nessun file di credenziali per scrivere questa scheda, e non e' stata eseguita nessuna verifica delle condivisioni attive del servizio cloud ne' dei permessi locali della cartella: sono le due misure che la terza pratica richiede, e restano da fare.
