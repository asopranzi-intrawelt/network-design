# Registro dei micro-interventi di robustezza

> Registro operativo aperto il 29/07/2026. Raccoglie gli interventi piccoli, indipendenti e **non bloccanti** che emergono come effetto collaterale delle analisi di progetto: cose che si possono fare una alla volta, in orario di lavoro, senza interrompere niente e senza attendere il completamento di un micro-step strutturale della Fase 3. Ogni voce e' un intervento a se': ha un motivo dichiarato, una procedura, una verifica, un criterio di rollback e uno stato. Non sostituisce la roadmap: la roadmap dice dove va la rete, questo registro dice cosa si puo' migliorare subito mentre ci si arriva.
>
> Il criterio di ammissione a questo registro e' esplicito e va rispettato, altrimenti diventa un contenitore di lavori arretrati: un intervento entra qui solo se non richiede finestre di manutenzione, non tocca il piano dati di apparati centrali, e ha un rollback di una sola azione. Tutto il resto sta nei micro-step della roadmap.

## Perche' un registro separato

Le analisi di questo progetto producono due tipi di risultato. Il primo sono i difetti strutturali, che richiedono progetto, finestre e coordinamento: la rete piatta, la DMZ assente, le VPN con parametri deboli. Il secondo sono i difetti puntuali che si scoprono mentre si guarda dentro un apparato per un'altra ragione: una credenziale di fabbrica mai cambiata, un annuncio multicast inutile, una porta rimasta in una VLAN di test, un campo descrittivo vuoto. Il secondo tipo ha una caratteristica che merita un trattamento diverso: il rapporto tra riduzione del rischio e costo e' altissimo, e il rischio di rompere qualcosa e' quasi nullo.

Tenerli insieme ai micro-step strutturali li condanna ad aspettare. Metterli in un registro proprio, con il vincolo che ciascuno sia eseguibile in isolamento, li rende eseguibili nei ritagli di tempo e li rende anche *contabili*: a fine mese si sa quanti sono stati chiusi, e ciascuno e' una riga di miglioramento verificabile nella documentazione ISO27001, non un'intenzione.

## Registro

| ID | Intervento | Motivo / gap | Impatto sulla rete | Stato |
|---|---|---|---|---|
| R1 | Cambiare le credenziali amministrative di fabbrica sulla multifunzione del Piano Terra e conservarle nel password manager aziendale | SEC-019 (#125), A.5.17, A.9.4 | Nessuno: si cambia una password del pannello, la stampa non si interrompe | Da fare |
| R2 | Attivare il filtro IP sulla multifunzione, limitando l'accesso amministrativo alle sole postazioni IT | SEC-019 (#125), controllo compensativo sulla LAN piatta | Nessuno sulla stampa; da verificare che il filtro non blocchi le porte di stampa | Da fare |
| R3 | Disabilitare Bonjour/mDNS sulla multifunzione | Riduzione della superficie e degli annunci multicast; evita che le code vengano ri-puntate a un nome `.local` che non sopravvive alla segmentazione | Nessuno sulle code esistenti, che puntano all'indirizzo | Da fare |
| R4 | Compilare il campo `Posizione` sulle multifunzione con l'ubicazione fisica reale | Igiene di inventario: il dato serve a chi sta davanti alla macchina | Nessuno | Da fare |
| R5 | Riportare la porta 19 del XGS2220-30HP da PVID 90 a PVID 1 | NET-013 (#123): presa che consegna in rete ospiti, residuo di un test | Nessuno: la porta e' senza link | Da fare |
| R6 | Rimuovere le porte di stampa orfane sulle postazioni (una porta `IP_<indirizzo>` inutilizzata accanto alla `IP_2_<indirizzo>` in uso) | Igiene: evita di non capire piu' quale porta sia viva al prossimo ri-puntamento | Nessuno se si rimuove la porta non associata a nessuna coda | Da fare |
| R7 | Convertire l'indirizzamento delle multifunzione da statico su apparato a riserva DHCP sul firewall | Prerequisito di M22b e miglioramento permanente: i cambi di indirizzo futuri diventano modifiche centrali | Breve indisponibilita' dell'apparato al riavvio della rete: unica voce del registro che richiede una finestra, anche se di minuti | Da fare |
| R8 | Spostare le destinazioni di scansione dalle cartelle condivise delle postazioni a una share dedicata sul NAS | NET-009 (#114) lato flussi dato, SEC-020 (#126), A.8.3 e A.5.14 | Nessuno sulla rete: si riconfigurano le destinazioni sull'apparato. Cambia dove gli utenti trovano le scansioni, quindi richiede comunicazione | **Sostanzialmente completato il 03/08/2026, verificato su tutte e sette le postazioni.** Fatto: account di servizio con il solo privilegio SMB; nessuna scadenza password sul NAS, quindi immunita' alla rotazione verificata; sette condivisioni nascoste con permessi per destinatario, isolamento provato e scrittura dell'account di servizio provata su tutte e sette; quattordici voci di rubrica riconfigurate sulle due multifunzione, di cui tre create ex novo sul Piano Terra; collegamento sul desktop distribuito e funzionante su tutte le postazioni. **Restano due code**: la verifica che su ogni postazione la credenziale del NAS sia **permanente** e non di sessione, e la rimozione delle vecchie condivisioni di scansione dalle postazioni con le credenziali che le servivano — che e' il passo che chiude davvero SEC-020 |
| R9 | Sostituire negli account di scansione i nomi di persona con un account di servizio dedicato alla share di scansione | SEC-020 (#126), A.9.2: un account nominale usato da un apparato non e' attribuibile a una persona ed e' impossibile da dismettere all'uscita di quella persona | Nessuno se eseguito insieme a R8 | Da fare |
| R11 | Attivare la conferma della destinazione prima dell'invio sulle destinazioni di scansione di entrambe le multifunzione | SEC-020 (#126): su tutte le voci censite l'opzione e' disattivata, quindi una selezione sbagliata dal display invia documenti nella cartella di un'altra persona senza alcun passaggio che permetta di accorgersene | Nessuno sulla rete; aggiunge un tocco in piu' all'utente che scansiona, ed e' il compromesso da spiegare | Da fare |
| R12 | Pubblicare i nomi interni come record di indirizzo sul DNS del firewall, che i client ricevono gia' via DHCP come primo server DNS | Chiude in gran parte SEC-016 e la dipendenza dal broadcast (mDNS, NetBIOS) senza introdurre un dominio; abilita il ri-puntamento delle code di stampa a un nome, quindi rende gratuiti gli spostamenti futuri | Nessuno: si aggiungono record, non si cambia nulla lato client, che gia' interroga il firewall | Da fare |
| R13 | Migrare i due nomi interni che usano il suffisso `.local` al suffisso scelto in R12, aggiornando prima le configurazioni che li referenziano | NET-014 (#131): `.local` e' riservato a mDNS, quindi quei nomi si risolvono via multicast e non sopravvivono a un confine di livello 3 | Nessuno se si crea il nome nuovo prima di rimuovere il vecchio: per un periodo rispondono entrambi | Da fare, dipende da R12 |
| R14 | Valutare il rafforzamento del criterio password del NAS (oggi lettere e cifre, lunghezza minima otto, nessun carattere speciale obbligatorio, nessun divieto di coincidenza con il nome utente) | Il NAS custodisce l'archivio documentale e le cartelle di scansione, e le sue 29 utenze locali sono l'archivio identita' effettivo in assenza di un dominio: il criterio e' piu' debole di quello applicato agli endpoint | Nessuno sulle credenziali esistenti; incide sui cambi futuri | Da valutare, nessuna urgenza |
| R10 | Definire una regola di conservazione sulla cartella delle scansioni (cancellazione automatica oltre una soglia di giorni concordata) | Minimizzazione e limitazione della conservazione: una cartella di scansioni diventa in pochi mesi un archivio documentale parallelo, non censito e pieno di dati personali. Rilevante per A.5.33 e per il principio di limitazione della conservazione | Nessuno sulla rete; va concordata la soglia con chi usa il servizio | Da fare, dipende da R8 |
| R15 | Riportare la porta 21 del XGS2220-30HP a una configurazione coerente: oggi ha PVID 1 e `allowedVLAN` uguale a `2`, cioe' ammette solo la VLAN 2 taggata mentre consegna il non taggato sulla VLAN 1, che nella lista non c'e' | NET-015 (#134): residuo della Voice VLAN del 29/05, quando la porta ospitava un telefono. Chi vi collegasse un portatile non avrebbe rete, con una causa non evidente dal sintomo | Nessuno: la porta e' senza link. Da fare nello stesso giro di R5, che e' il gemello sulla porta 19 | Da fare |
| R16 | Identificare cosa e' collegato alle tre porte che negoziano a 10 Mbps (porte 5 e 22 del 30HP, porta 25 del 54HP) e stabilire se la causa sia l'apparato o il cablaggio | NET-016 (#135): su switch gigabit un collegamento a 10 Mbps e' quasi sempre un cavo danneggiato o una coppia interrotta. Se e' cablaggio conviene sistemarlo mentre si mette mano alle porte per M22, non dopo | Nessuno: e' una ricognizione, non una modifica | Da fare |
| R17 | Stabilire proprieta', amministratore e credenziali del **Mikrotik RB2011UiAS-RM** sulla catena WAN, e verificare firmware e configurazione | NET-018 (#137): e' sul percorso del backup di linea e nessuno sa se sia Intrawelt o del fornitore. Un apparato in cui non si riesce a entrare, su quel percorso, si scopre inaccessibile quando la linea primaria e' giu' — stesso schema di AP-001 | Nessuno: e' una richiesta al fornitore piu' una lettura. **Non** tentare accessi a tentativi su un apparato in produzione sul backup | Da fare |
| R18 | Censire l'**inverter del fotovoltaico** come asset di rete: marca, modello, indirizzo, porte esposte, se contatta il cloud del produttore e con quale protocollo | NET-017 (#136): e' entrato in rete per mano degli elettricisti, sta sulla LAN piatta dietro uno switch non gestito, e non e' in nessun inventario. Prerequisito per collocarlo nel segmento IoT/OT di M22c | Nessuno: lettura del pannello dell'apparato | Da fare |
| R19 | Portare a `2` la lista `Allowed VLANs` delle cinque porte di fonia che oggi hanno `all`: la **13 del 30HP** e la **3, 6, 8 e 44 del 54HP**, allineandole alla 23 del 30HP e alla 5 del 54HP che sono gia' corrette. Una porta per volta, verificando dopo ciascuna che il telefono resti registrato e che una chiamata parta | NET-019 (#143): salto di VLAN possibile da una presa di fonia in area accessibile e alimentata in PoE | Basso e circoscritto. Il `PVID` **non si tocca**: il traffico non taggato continua a finire in VLAN 2 esattamente come adesso, quindi telefono e PC in cascata non cambiano comportamento. Si perde solo la possibilita' di entrare in VLAN 1, 40 e 90 taggando, che e' il difetto. L'unico caso che si romperebbe e' un apparato dietro quelle prese che oggi manda traffico **taggato** su una VLAN diversa dalla 2: la tabella MAC non ne mostra (le cinque porte hanno appreso solo indirizzi in VLAN 2, la 8 tre di essi), ma la verifica per porta resta obbligatoria. Rollback immediato: si rimette `all` su quella porta | Da fare |

## Dettaglio degli interventi

### R1 — Credenziali di fabbrica sulla multifunzione

La multifunzione del Piano Terra ha il pannello amministrativo protetto dalla coppia di credenziali predefinita del produttore, quella pubblicata nella documentazione del prodotto. Il pannello governa indirizzamento, protocolli esposti e rubrica delle destinazioni di scansione, e la rubrica contiene credenziali di accesso a condivisioni aziendali: chi entra puo' leggere dove finiscono i documenti, cambiarne la destinazione, e usare il pulsante di prova connessione per validare credenziali.

Procedura: dal pannello web, sezione delle impostazioni di gestione, cambiare la password dell'utenza amministrativa; registrare la nuova credenziale nel password manager aziendale sulla VM202, non in un file e non in un documento condiviso. Verifica: nuovo accesso al pannello con la credenziale nuova, e conferma che una stampa di prova esce normalmente (il cambio non tocca il servizio di stampa, ma la verifica costa dieci secondi). Rollback: non necessario; se la credenziale nuova venisse persa, resta il reset amministrativo dal display dell'apparato, che e' fisicamente presidiato.

### R2 — Filtro IP come controllo compensativo

Finche' la rete e' piatta il firewall non vede il traffico tra una postazione e la multifunzione, quindi non puo' proteggere il pannello amministrativo. L'apparato ha tuttavia una funzione di filtro degli indirizzi ammessi: e' l'unico punto in cui oggi si puo' restringere quella platea, e la porta da tutta la `/19` alle due o tre postazioni IT.

Procedura: nella sezione TCP/IP del pannello, aprire le impostazioni dei filtri IPv4 e consentire l'accesso ai soli indirizzi delle postazioni IT. Attenzione, ed e' la ragione per cui questo intervento va fatto con la verifica accanto: il filtro, se applicato a tutti i protocolli invece che alla sola amministrazione, blocca anche la stampa dalle postazioni. Verifica obbligatoria in due passi, nell'ordine: prima una stampa di prova da una postazione **non** IT, che deve continuare a funzionare, poi un tentativo di accesso al pannello dalla stessa postazione, che deve essere rifiutato. Rollback: disattivare il filtro, che e' una singola opzione.

### R3 — Disabilitare Bonjour

L'apparato annuncia se stesso in multicast e pubblica un nome nel dominio `.local`. Serve alla scoperta automatica da parte dei client, che qui non e' il modo con cui le code sono state create: le code puntano all'indirizzo. L'annuncio quindi non porta beneficio e ha due costi, uno piccolo e uno insidioso. Il piccolo e' traffico multicast e superficie di esposizione in piu'. L'insidioso e' che invita a ri-puntare le code al nome `.local`, che funziona oggi e cessa di funzionare il giorno in cui la stampante finisce in un segmento diverso, perche' mDNS non attraversa un confine di livello 3.

Procedura: nella sezione TCP/IP, impostare Bonjour su `Off` e inviare. Verifica: la risoluzione del nome `.local` dalla postazione non risponde piu', mentre la stampa continua a funzionare. Rollback: rimettere `On`.

### R4 — Campo Posizione

Costa trenta secondi e rende l'inventario leggibile dal pannello, che e' il punto in cui lo si consulta quando si e' davanti alla macchina con un problema. Procedura: sezione delle impostazioni dispositivo, campo `Posizione`, valore uguale all'ubicazione fisica reale coerente con `mappatura-porte-fisiche.md`. Verifica: il valore compare nell'intestazione del pannello. Nessun rollback necessario.

### R5 — Porta 19 dello switch del Piano Terra

La porta e' rimasta configurata come access sulla VLAN degli ospiti dopo il test cablato del 22/07, nonostante risultasse ripristinata: e' una presa a muro che consegna chi si collega direttamente in rete ospiti, cioe' una segmentazione al contrario. Oggi non ha link, quindi non c'e' impatto in atto, ed e' esattamente il momento giusto per correggerla.

Procedura: dal pannello Nebula, vista di dettaglio della porta 19 dello switch del Piano Terra, impostare PVID 1 e salvare; oppure con `Set-NebulaWifiVlan.ps1` in dry-run e poi `-Apply`, che lascia traccia in `output/nebula-apply-log-*.json`. Verifica: rilettura della configurazione della porta, e prova con un portatile che ottiene un indirizzo nella classe delle postazioni e non in quella ospiti. Rollback: rimettere PVID 90, che e' lo stato attuale.

### R6 — Porte di stampa orfane sulle postazioni

Su almeno una postazione convivono due porte verso lo stesso indirizzo di stampante, una usata dalla coda e una orfana, residuo di un ri-puntamento fatto in passato creando una porta nuova. Non fanno danno, ma al prossimo ri-puntamento moltiplicano le voci e rendono ambiguo quale porta sia viva.

Procedura: sulla postazione, elencare code e porte, individuare le porte non associate a nessuna coda e rimuoverle. Verifica: la coda stampa ancora e la porta orfana non compare piu'. Rollback: la porta si ricrea in trenta secondi con lo stesso indirizzo. Estensione: lo stesso controllo va fatto sull'inventario dell'RMM per tutte le postazioni, non solo su quella esaminata.

### R7 — Da indirizzo statico a riserva DHCP

Le multifunzione hanno oggi indirizzo statico impostato sull'apparato. Ne segue che ogni cambio di indirizzo, compreso quello della migrazione, richiede di mettere le mani sul pannello di ciascuna macchina. Convertirle in riserva DHCP sposta il controllo sul firewall: da quel momento il cambio di indirizzo e' una modifica centrale, e la riconciliazione tra MAC, indirizzo e apparato vive in un solo posto invece che su ogni pannello.

Procedura, nell'ordine: sul firewall, creare o verificare l'ambito DHCP che serve la classe delle stampanti e registrare una riserva per il MAC dell'apparato con lo stesso indirizzo che ha oggi, cosi' che nulla cambi; poi sull'apparato impostare DHCP su `On` e inviare; infine riavviare la rete dell'apparato. Verifica: l'apparato riprende **lo stesso** indirizzo di prima, la stampa di prova esce, la scansione verso la destinazione configurata arriva. Rollback: rimettere l'indirizzo statico sul pannello, che e' la configurazione attuale e va annotata prima di iniziare. Nota di finestra: e' l'unica voce del registro con una indisponibilita', di pochi minuti, perche' l'apparato richiede il riavvio della rete per applicare il cambiamento.

### R8 — Scansioni verso una share dedicata sul NAS

E' l'intervento con il maggior valore di questo registro, e va capito bene perche' e' anche l'unico che cambia l'esperienza degli utenti. Oggi tutte le destinazioni di scansione della multifunzione del Piano Terra puntano a cartelle condivise di singole postazioni, con le credenziali di quelle postazioni memorizzate nell'apparato. Ne derivano quattro problemi indipendenti: i documenti scansionati, che spesso contengono dati personali, finiscono su endpoint invece che su uno spazio presidiato e sottoposto a backup noto; la scansione funziona solo se quella postazione e' accesa e la condivisione e' attiva; l'apparato conserva credenziali di accesso a share aziendali (SEC-020); e la matrice dei flussi del progetto di segmentazione nega esattamente questo percorso, quindi il giorno della migrazione queste destinazioni smetterebbero di funzionare.

La cosa importante, ed e' il motivo per cui questo intervento sta nel registro dei non-bloccanti invece che dentro M22b: **si puo' fare adesso, sulla rete piatta, senza toccare nessuna VLAN**, e produce da subito il beneficio di governo dei dati. Quando poi arrivera' la segmentazione, le destinazioni saranno gia' dove devono essere e il passo si riduce a una regola sul firewall.

#### Come si diventa immuni alla rotazione delle password, e non solo meno esposti

Obiettivo posto dall'IT Manager il 30/07/2026, e va preso alla lettera: non ridurre il problema, **eliminarlo**. La soluzione deve essere tale che il cambio password degli endpoint non tocchi mai la scansione.

Il ragionamento parte da cosa ruota davvero. La rotazione a trenta giorni e' una policy dell'RMM sulle **utenze locali di Windows**: agisce sugli endpoint, non sugli altri apparati della rete. Ne segue che qualunque credenziale memorizzata che *sia* un'utenza locale di Windows scade, e qualunque credenziale che appartenga a un sistema fuori da quel perimetro no. Il problema quindi non e' la rotazione: e' il fatto che oggi le destinazioni di scansione usano identita' delle postazioni. Spostare la destinazione sul NAS non e' solo una scelta di governo dei dati, e' la condizione per l'immunita'.

Il disegno immune ha due gambe, e vanno rese immuni entrambe, altrimenti il problema si sposta invece di sparire.

La gamba macchina-verso-storage e' l'account di servizio della multifunzione: **utenza locale del NAS**, non di Windows, quindi fuori dalla policy dell'RMM per costruzione. Va verificato che sul NAS non sia attiva una politica di scadenza password che la riporterebbe dentro il problema da un'altra porta: se lo e', quell'account va escluso o configurato senza scadenza. E' l'unica credenziale memorizzata negli apparati, quindi l'unica che potrebbe scadere: risolta questa, la scansione non si rompe piu' da sola.

La gamba utente-verso-storage e' l'accesso di ciascuna persona alla propria cartella. Anche qui l'identita' da usare e' **un'utenza locale del NAS**, non quella di Windows: si salva una volta nelle credenziali di Windows e sopravvive a tutte le rotazioni successive, perche' e' una credenziale diversa e gestita da chi amministra il NAS, non dall'RMM. Il costo e' che la persona ha una seconda password, che pero' digita una sola volta.

##### Perche' non si puo' fare di meglio oggi, e cosa lo renderebbe possibile

La soluzione strutturalmente superiore sarebbe non memorizzare nessuna credenziale: con un servizio di directory e l'autenticazione integrata, l'utente ottiene l'accesso alla propria cartella con il *ticket* della sessione di lavoro e il cambio password diventa un non-evento, perche' non c'e' nessun segreto salvato da aggiornare. Lo snapshot dell'RMM del 30/07/2026 dice pero' che quella strada oggi non esiste: i ventisei dispositivi gestiti dell'organizzazione sono **tutti standalone**, in workgroup, senza alcun dominio (gap SEC-021, `GAP-TBC.md` #128). Senza directory non c'e' autenticazione integrata, e ogni accesso tra sistemi resta necessariamente basato su una credenziale memorizzata.

Vale la pena registrare che l'introduzione di un servizio di directory con DNS interno chiuderebbe in un colpo quattro cose che questo progetto sta affrontando separatamente: la dipendenza dalle credenziali memorizzate, l'assenza di risoluzione nomi interna (SEC-016), la dipendenza dal broadcast per NetBIOS e mDNS che rende fragile ogni segmentazione, e la distribuzione a mano dei file `hosts`. Non e' un intervento di rete e non appartiene a questo registro: e' un progetto con impatto organizzativo, che cambia anche il modo in cui l'RMM gestisce le utenze. Va valutato come tale, e nel frattempo la coppia di utenze locali del NAS descritta sopra rende la scansione immune alla rotazione senza dipendere da quel progetto.

#### Un argomento in piu', che da solo giustificherebbe l'intervento

Registrato il 30/07/2026: gli endpoint sono gestiti da un RMM distribuito che **impone la rotazione della password locale ogni trenta giorni** (vedi `.claude/context/design-and-security.md` §Contesto di gestione degli endpoint e ADR-017). Ne segue che qualunque credenziale di postazione memorizzata nelle multifunzione ha una vita massima di trenta giorni: le undici destinazioni censite non sono soltanto un problema di protezione dei dati, sono una manutenzione ricorrente che si rompe da sola a ogni rotazione e che qualcuno deve rimettere a posto ogni volta, apparato per apparato.

Questo cambia il modo di presentare R8 a chi lo deve approvare. Non e' un intervento di sicurezza che chiede uno sforzo in cambio di un rischio ridotto: e' un intervento che **elimina un lavoro ricorrente** e in piu' riduce il rischio. L'account di servizio sul NAS vive fuori dal perimetro di rotazione degli endpoint, quindi la destinazione di scansione smette di scadere.

#### Requisito posto dall'IT Manager il 29/07/2026

Gli utenti hanno gia' accesso a NAS-INTRA2 e a due cartelle di primo livello di NAS-HERO, quindi l'accesso esistente si puo' sfruttare invece di crearne uno nuovo. La condizione e' che nella nuova cartella di primo livello dedicata alle scansioni **ciascun utente veda soltanto la propria sottocartella** e non quelle degli altri.

Il requisito sembra banale e non lo e', perche' entra in tensione diretta con R9. Se l'isolamento tra utenti lo si ottenesse facendo scrivere l'apparato con le credenziali di ciascun utente, come avviene oggi verso le postazioni, allora la multifunzione dovrebbe conservare al proprio interno le credenziali personali di tutti — cioe' si peggiorerebbe esattamente il problema che SEC-020 registra, su un apparato il cui pannello ha ancora le credenziali di fabbrica. La separazione va quindi ottenuta dal lato dei permessi del NAS, non dal lato delle credenziali dell'apparato.

#### Il disegno che soddisfa entrambe le cose

Un solo **account di servizio** dedicato alla scansione, che e' l'unica credenziale memorizzata nella multifunzione, con permesso di scrittura su tutte le sottocartelle; e i permessi degli utenti definiti sul NAS in modo che ciascuno acceda solo alla propria. L'utente non usa mai la credenziale dell'apparato e l'apparato non usa mai quella dell'utente: sono due percorsi distinti verso la stessa cartella, ed e' questa separazione a rendere il disegno sostenibile.

La struttura, nella forma decisa il 29/07/2026 dopo la correzione descritta sotto, e' una cartella condivisa per destinatario invece di una cartella unica con sottocartelle. Il disegno dei permessi non cambia, cambia solo il livello a cui vengono applicati.

```
\\<nas>\Scan_<destinatario-1>   servizio: scrittura   destinatario-1: lettura/scrittura   altri: nessun accesso
\\<nas>\Scan_<destinatario-2>   servizio: scrittura   destinatario-2: lettura/scrittura   altri: nessun accesso
\\<nas>\Scan_<destinatario-3>   servizio: scrittura   destinatario-3: lettura/scrittura   altri: nessun accesso
\\<nas>\Scan_<destinatario-4>   servizio: scrittura   destinatario-4: lettura/scrittura   altri: nessun accesso
```

| Soggetto | Sulla propria condivisione | Sulle condivisioni altrui |
|---|---|---|
| Account di servizio della multifunzione | scrittura e creazione file | scrittura e creazione file (inevitabile: e' un solo account per tutte le destinazioni) |
| Destinatario | lettura e scrittura, cancellazione dei propri file | **nessun accesso** |
| Amministratore IT | pieno | pieno |

Sul rischio residuo bisogna essere onesti, perche' e' il punto che un auditor chiederebbe: l'account di servizio puo' scrivere in tutte le sottocartelle, quindi chi ne ottenesse la credenziale potrebbe depositare file nella cartella di chiunque. Non puo' pero' *leggere* le scansioni altrui se il NAS permette di concedergli la sola scrittura, ed e' questa asimmetria a fare la differenza rispetto a oggi: attualmente l'apparato conserva credenziali che danno accesso completo a cartelle condivise di postazioni. Il rischio passa quindi da lettura e scrittura su endpoint a sola scrittura su una cartella presidiata, e viene ridotto ulteriormente da R1 e R2, che chiudono la via d'accesso al pannello dove quella credenziale e' memorizzata.

#### Su quale NAS, e la nota che ne consegue

La scelta e' tra i due apparati a cui gli utenti hanno gia' accesso. Il criterio non e' lo spazio, che in entrambi i casi e' ampiamente sufficiente, ma la copertura di backup e le implicazioni di un'eventuale replica fuori sede: NAS-HERO e' replicato offsite su archiviazione cloud secondo quanto documentato in `business-continuity-disaster-recovery.md`, quindi scegliendolo le scansioni erediterebbero automaticamente una copia esterna. E' un vantaggio di continuita' e insieme un fatto da dichiarare, perche' significa che documenti con dati personali vengono replicati presso un fornitore cloud: va verificato che questo sia coerente con quanto dichiarato agli interessati e con il registro dei trattamenti, non deciso implicitamente da una scelta di cartella. Decisione dell'IT Manager, da registrare qui quando presa.

#### Come si ottiene davvero la separazione per sottocartella sul NAS scelto

**Decisione dell'IT Manager del 29/07/2026: il NAS di destinazione e' NAS-INTRA2.** Coerente con la raccomandazione: se le scansioni sono un mezzo di trasporto con una scadenza (R10) e non un archivio, replicarle fuori sede sarebbe un costo di riservatezza senza un beneficio di continuita' reale.

La domanda operativa che ne segue e' come si separano gli accessi *dentro* una cartella di primo livello, dato che per impostazione predefinita su questi NAS i permessi si assegnano alla cartella condivisa e chi vi accede vede tutto quello che contiene. Ci sono due strade native, piu' una che va scartata.

La prima strada e' abilitare le **autorizzazioni avanzate per cartella**, che sul pannello di controllo del NAS stanno nella sezione dei privilegi, alla voce delle cartelle condivise, scheda delle autorizzazioni avanzate. Attivata quell'opzione, i permessi diventano assegnabili anche alle sottocartelle, dal gestore file: si seleziona la sottocartella, si aprono le proprieta' e si concede a ciascun utente lettura e scrittura sulla propria e nessun accesso sulle altre, con la possibilita' di applicare la scelta in modo ricorsivo. E' la strada che soddisfa il requisito mantenendo **una sola** cartella di primo livello, come chiesto, e scala quando gli utenti aumentano. L'unica cautela e' che l'opzione e' globale per l'apparato e cambia il modo in cui i permessi vengono valutati: va attivata deliberatamente e va verificato prima se non sia gia' attiva, perche' la presenza di cartelle condivise nominative suggerisce che una gestione granulare sia gia' in uso. L'attivazione non modifica da sola i permessi esistenti, che restano quelli della cartella condivisa finche' non si assegna un permesso specifico a una sottocartella.

La seconda strada e' creare **una cartella condivisa per utente**, cioe' spostare la separazione dal livello sottocartella al livello cartella condivisa, dove i permessi esistono sempre e senza abilitare nulla. E' la strada piu' semplice e la piu' robusta, e richiede zero modifiche di configurazione globale; il costo e' che la lista delle cartelle condivise di primo livello, che oggi ha gia' tredici voci tra cartelle di lavoro, backup e cartelle di sistema dell'apparato, cresce di una voce per utente e diventa meno leggibile. Con quattro destinatari e' del tutto praticabile, con quindici no.

La strada da scartare, ed e' utile dire perche', e' usare le cartelle personali degli utenti che l'apparato mette a disposizione nativamente. Sono isolate per costruzione, quindi sembrerebbero la risposta ovvia, ma scrivervi dall'esterno richiede privilegi amministrativi sul NAS: la multifunzione dovrebbe conservare una credenziale amministrativa, che e' esattamente cio' che questo intervento vuole evitare. La separazione nativa risolverebbe il problema degli utenti creandone uno molto piu' grande sull'apparato.

**Raccomandazione rivista il 29/07/2026: la seconda strada, una cartella condivisa per utente.** La prima stesura raccomandava le autorizzazioni avanzate, sulla base dell'assunzione errata che l'attivazione fosse a costo nullo. Con i dati veri il confronto si capovolge. Le quattro destinazioni attuali richiedono quattro cartelle condivise: quattro righe in piu' in una lista che ne ha dodici, permessi assegnati dove esistono nativamente, nessuna impostazione globale toccata, nessuna riscrittura di permessi su milioni di oggetti, nessun cambiamento nel modello di gestione dei permessi del resto del NAS, e l'intervento e' eseguibile subito e in orario di lavoro — cioe' rispetta la regola di ammissione di questo registro, che la prima strada non rispetta piu'.

La prima strada resta quella giusta se e quando i destinatari diventeranno molti, o se si decidera' di adottare permessi per sottocartella come modello generale del NAS. In quel caso diventa un intervento a se', da pianificare fuori orario con la durata misurata su una prova, e non un passaggio dentro R8. La differenza tra le due non e' tecnica ma di ordine di grandezza: quattro utenti non giustificano una riscrittura di permessi su cinque milioni di oggetti.

#### Stato verificato il 29/07/2026: le autorizzazioni avanzate sono disattivate

Verifica eseguita sul pannello di controllo di NAS-INTRA2, sezione privilegi, cartelle condivise, scheda delle autorizzazioni avanzate: **entrambe le caselle sono deselezionate**, sia quella delle autorizzazioni avanzate per cartella sia quella del supporto Windows ACL. Oggi, quindi, i permessi vivono solo a livello di cartella condivisa e chi accede a una condivisione vede tutto il suo contenuto: il requisito di separazione per utente non e' soddisfabile senza intervenire su una delle due strade descritte sopra.

Due precisazioni che contano per non fare danni. La casella da attivare e' **solo** la prima, quella delle autorizzazioni avanzate per cartella: la seconda, il supporto Windows ACL, e' un'altra cosa e va lasciata disattivata, perche' cambia il modello di permessi verso quello NTFS e ha senso solo con un dominio a cui appoggiarsi.

**Correzione del 29/07/2026, importante perche' ribalta la raccomandazione.** Una prima stesura di questo documento affermava che attivare l'opzione non modifica i permessi esistenti. E' falso, e lo dice l'apparato stesso nel dialogo di conferma che compare spuntando la casella: all'attivazione **tutte le autorizzazioni delle sottocartelle vengono impostate come quelle delle cartelle principali**, con un'operazione che puo' richiedere diversi minuti in funzione del numero di file e cartelle da elaborare. Non e' una spunta di configurazione, e' una riscrittura massiva di permessi su tutto il volume.

Su questo apparato specifico quel "diversi minuti" va letto con i numeri veri: una sola cartella condivisa contiene circa 3,45 milioni di cartelle e 1,86 milioni di file (gap STOR-001, `GAP-TBC.md` #127), e il pannello di amministrazione e' gia' marcatamente lento (NAS-003 in `runbook-anomalie.md`). L'inizializzazione attraverserebbe l'intero albero generando I/O su un apparato con 4 GB di RAM e CPU ARM che nel frattempo serve le condivisioni di lavoro. Ne derivano due conseguenze: la durata reale e' imprevedibile e va misurata, non stimata, e l'operazione va comunque fuori orario di lavoro.

C'e' anche una conseguenza di lungo periodo, meno visibile e piu' importante: dopo l'inizializzazione ogni sottocartella porta permessi espliciti propri, quindi la gestione dei permessi diventa granulare **e** manuale, e una modifica al permesso di una cartella condivisa non si propaga piu' implicitamente a tutto il suo contenuto. Su un NAS con quell'albero significa un modello di permessi molto piu' potente e molto piu' facile da sbagliare.

C'e' poi un comportamento da **verificare in campo prima di migrare le destinazioni**, e non da dare per scontato leggendo la documentazione del produttore: quando un utente ha permesso su una sottocartella ma non sulla cartella condivisa che la contiene, l'accesso funziona per percorso diretto ma l'elenco della cartella condivisa puo' essere negato. E' esattamente il comportamento che vogliamo per gli utenti, che devono raggiungere la propria cartella e non vedere quelle altrui, ma va provato anche per l'**account di servizio della multifunzione**, che si connette alla condivisione e poi scende nella sottocartella: se la connessione alla condivisione richiede un permesso che l'account non ha, la scansione fallisce con un errore che sul display dell'apparato non dice nulla di utile. La prova si fa con un utente di test e una cartella di test, prima di toccare la rubrica, ed e' il motivo per cui il passo 3 della procedura viene prima del passo 4.

Nota operativa sull'apparato: la sua interfaccia di amministrazione risponde con lentezza marcata, cosa rilevata durante questa stessa verifica e registrata in `runbook-anomalie.md` §NAS-003. Va messo in conto nel tempo dell'intervento, perche' R8 richiede diversi passaggi in quella interfaccia.

Nota a margine emersa dalla stessa lettura: tra le cartelle condivise di primo livello esiste una cartella pubblica, tipicamente accessibile a tutti gli utenti. Va evitato che la cartella delle scansioni le somigli per permessi, ed e' un motivo in piu' per verificare i permessi effettivi al termine dell'intervento invece di fidarsi di come sono stati impostati.

#### Passo zero: censimento globale dei destinatari su tutti gli apparati

Richiesto dall'IT Manager il 29/07/2026, prima di creare qualunque cartella, ed e' la domanda giusta al momento giusto: il disegno di R8 dimensionato su quattro destinatari e' una cosa, lo stesso disegno su dodici e' un'altra, e la scelta tra cartelle condivise separate e autorizzazioni per sottocartella dipende esattamente da quel numero. La rubrica letta finora e' solo quella della multifunzione del Piano Terra; l'altra multifunzione, la Canon del Piano 1, ha la propria rubrica indipendente e i due insiemi vanno **unificati e non sommati**, perche' chi lavora su due piani puo' comparire in entrambe.

| Apparato | Destinazioni rilevate | Di cui verso postazioni | Stato del censimento |
|---|---|---|---|
| Kyocera TASKalfa 2552ci (Piano Terra) | 4 | 4 | **Fatto 29/07/2026** |
| Canon iR-ADV C5840 (Piano 1) | 7, tutte nell'elenco a selezione veloce | 7 | **Fatto 29/07/2026** |
| **Unione dei destinatari distinti** | **7** | 7 | **Censimento chiuso** |

Le undici destinazioni si riducono a sette destinatari distinti perche' quattro persone sono censite su entrambe le multifunzione: le quattro voci della Kyocera sono un sottoinsieme delle sette della Canon, che aggiunge tre destinatari non presenti al Piano Terra. Nessuna destinazione e' di tipo e-mail o FTP: sono **undici su undici cartelle di rete SMB**, tutte verso condivisioni di postazioni, con la conferma che il fronte scan-to-folder e' totale su entrambi gli apparati e non una particolarita' di uno dei due.

Tre fatti nuovi emersi dalla rubrica della Canon, che il primo censimento non poteva mostrare.

Il primo e' che **due destinazioni su sette usano un nome NetBIOS della postazione invece dell'indirizzo** (`\\<nome-postazione>\<condivisione>`). Funzionano oggi perche' la risoluzione NetBIOS avviene in broadcast dentro il dominio di livello 2, ed e' lo stesso meccanismo che muore attraversando un confine di livello 3: e' quindi una terza forma della stessa trappola gia' vista con mDNS sulle stampanti e con l'assenza di un DNS interno. Dopo R8 la questione si estingue da se', perche' tutte le destinazioni puntano al NAS per indirizzo, ma va registrata perche' spiega perche' quelle due voci si romperebbero **prima** delle altre.

Il secondo e' che i nomi utente memorizzati includono **due utenze nominali** invece di account di servizio, una su ciascun apparato: la motivazione di R9 e' quindi doppia e non un caso isolato.

Il terzo e' un dettaglio della configurazione che vale un intervento a se': su tutte e sette le voci l'opzione di **conferma prima dell'invio e' disattivata**. Significa che chi scansiona non vede una richiesta di conferma della destinazione scelta, quindi una selezione sbagliata dal display invia i documenti nella cartella di un'altra persona senza nessun passaggio che permetta di accorgersene. Aggiunto al registro come R11.

Sulla lettura della rubrica del secondo apparato c'e' una particolarita' del modello che vale la pena annotare, perche' a prima vista fa sembrare il censimento un lavoro enorme quando non lo e'. La rubrica espone un elenco personale, cinquanta elenchi per gruppi di utenti, dieci elenchi indirizzi e un elenco per amministratori: sessantadue contenitori, tutti creati a vuoto per costruzione. La colonna dei conteggi lo dice a chiare lettere, perche' tutti riportano zero destinazioni tranne l'**elenco a selezione veloce**, che ne contiene sette. Tutta la rubrica utile di quell'apparato sta quindi in un solo elenco, e leggerla e' un clic.

Per completezza, dato che era stata cercata: la funzione di importazione ed esportazione su questo modello sta in `Impostazioni/Registrazione`, sezione `Impostazioni gestione`, voce **`Gestione dati`**, dove si trovano importazione ed esportazione sia complessive sia per singolo elemento, incluso l'elenco indirizzi. Con sette voci, pero', aprire l'elenco a selezione veloce e' piu' rapido dell'esportazione, e non produce un file con dati reali da custodire.

Regola di decisione fissata prima di conoscere il numero, cosi' che il numero non venga piegato alla soluzione preferita. Fino a **sei** destinatari distinti si procede con una cartella condivisa per destinatario, che e' la strada senza impostazioni globali e senza riscritture di permessi. Oltre sei, la lista delle condivisioni diventa illeggibile e conviene la strada delle autorizzazioni per sottocartella, che a quel punto va pianificata come intervento a se' fuori orario, con la durata dell'inizializzazione misurata su una prova, e non piu' dentro questo registro.

#### Esito: sette destinatari, uno oltre la soglia, e la deviazione dichiarata

Il censimento chiuso da' **sette** destinatari distinti, cioe' uno oltre la soglia. Applicando la regola alla lettera si dovrebbe passare alle autorizzazioni per sottocartella e rimandare R8 a un intervento fuori orario. La regola pero' aveva una ragione dichiarata, non era un numero magico: il costo delle cartelle condivise separate e' che la lista delle condivisioni diventa illeggibile. Quel costo, su questo apparato, e' **eliminabile**: il NAS ha per ogni cartella condivisa l'opzione che la nasconde dalla navigazione di rete, e una condivisione nascosta resta raggiungibile per percorso diretto senza comparire nell'elenco che si vede sfogliando il server. Sette condivisioni nascoste non allungano nessuna lista visibile agli utenti, restano ordinate nel pannello di amministrazione, e ciascun destinatario raggiunge la propria con un'unita' di rete mappata al percorso completo.

Decisione presa, con la deviazione dalla regola dichiarata invece che nascosta riscrivendo la soglia a posteriori: **si procede con sette cartelle condivise nascoste**, una per destinatario. Il beneficio e' che nessuna impostazione globale viene toccata, nessuna riscrittura di permessi attraversa cinque milioni di oggetti, e l'intervento resta dentro la regola di ammissione di questo registro. Il costo accettato e' che il modello non scala elegantemente: alla decina di destinatari, o quando si voglia adottare i permessi per sottocartella come standard del NAS, si passa all'altra strada come intervento pianificato fuori orario. La soglia della regola resta a sei per il caso generale; qui e' stata superata di uno con una mitigazione specifica e verificabile, non per comodita'.

Come leggere la rubrica dell'altra multifunzione. Il suo pannello di amministrazione non e' interrogabile da riga di comando, per un motivo diverso ma con lo stesso esito della Kyocera: la pagina di autenticazione cifra la password nel browser combinandola con un *challenge* di sessione e una chiave pubblica RSA generata per quella pagina, quindi uno script dovrebbe replicare quella cifratura. Restano due strade manuali, e la seconda e' molto piu' rapida della prima. La prima e' aprire l'elenco degli indirizzi e guardare le voci una per una, come fatto sull'altra macchina. La seconda e' usare la funzione di **esportazione della rubrica** dell'apparato, che produce un file unico con tutte le voci: si trova nelle impostazioni di gestione dei dati, alla voce di importazione ed esportazione, scegliendo l'elenco indirizzi. Nell'esportazione va **esclusa** l'opzione che include le password, se presente, perche' altrimenti il file contiene credenziali in chiaro; e il file, contenendo indirizzi e nomi reali, resta materiale privato e non entra mai in un file tracciato di questo repository.

#### Disposizione confermata dall'IT Manager il 30/07/2026

Sette condivisioni nascoste, una per destinatario, con il nome nella forma `scansioni_<nome>`. Ciascun utente ha mappata sulla propria postazione **solo la propria**, e **entrambe** le multifunzione puntano alla cartella di ciascun destinatario: ne segue che le voci di rubrica da configurare sono quattordici, sette per apparato, e che la macchina del Piano Terra ne guadagna tre che oggi non ha, dato che la sua rubrica conta quattro destinatari contro i sette dell'altra.

#### Che cosa fa davvero una condivisione nascosta, e cosa non fa

La distinzione va capita perche' la parola promette piu' di quanto mantenga, e confonderla porta a credere protetto cio' che non lo e'.

Nascondere una condivisione significa **escluderla dall'elenco** che il NAS restituisce quando un client chiede "quali condivisioni offri". In pratica, sfogliando il server da Esplora risorse quella cartella non compare: chi guarda vede solo le condivisioni visibili, e la lista resta leggibile — che nel nostro caso e' il motivo per cui la usiamo, perche' sette cartelle in piu' su una lista che ne conta dodici la renderebbero un elenco da leggere due volte.

Cio' che **non** fa e' proteggere. Una condivisione nascosta risponde normalmente a chi la chiama per nome esatto: `\\<indirizzo-nas>\scansioni_<nome>` funziona come qualunque altra. Chiunque indovini o conosca il nome ci arriva, ed e' esattamente cio' che vogliamo, perche' e' cosi' che vi arriveranno la multifunzione e la scorciatoia sul desktop dell'utente. La protezione, quindi, non viene dal nascondere: viene **solo** dai permessi assegnati a ciascuna condivisione, cioe' il destinatario in lettura e scrittura sulla propria, l'account di servizio in sola scrittura, e nessun accesso per tutti gli altri. Se quei permessi sono sbagliati, la cartella nascosta e' esposta come qualunque altra; se sono giusti, il fatto che sia nascosta non aggiunge sicurezza, aggiunge ordine.

Tre conseguenze pratiche del nasconderle, tutte volute. Gli utenti non possono trovarle sfogliando il NAS, quindi la scorciatoia o l'unita' mappata sulla propria cartella non e' una comodita' ma il modo previsto per arrivarci — ed e' anche la ragione per cui mapparne una sola per postazione ha senso: nessuno vede l'esistenza delle altre. L'amministratore continua a vederle tutte nel pannello di controllo del NAS, dove l'elenco e' completo per definizione. E le multifunzione non se ne accorgono: si connettono al percorso esatto scritto in rubrica, e per loro una condivisione nascosta e' indistinguibile da una visibile.

Una nota di onesta' su come chiamarla nei documenti: questo e' un accorgimento di *ordine*, non un controllo di sicurezza, e va scritto cosi' anche quando si racconta l'intervento. Chiamarlo misura di protezione sarebbe sicurezza per oscurita', che e' precisamente il tipo di affermazione che un audit smonta in trenta secondi.

#### Procedura

Nell'ordine, e ogni passo verificabile prima del successivo.

1. Su NAS-INTRA2, creare **una cartella condivisa per destinatario** — sette secondo il censimento chiuso — spuntando per ciascuna l'opzione che la nasconde dalla navigazione di rete, senza attivare le autorizzazioni avanzate per cartella e senza concedere accesso generalizzato: i permessi si assegnano nel dialogo di creazione della condivisione, dove esistono nativamente. Se in futuro si decidera' di passare al modello per sottocartella, sara' un intervento separato da pianificare fuori orario, non un passaggio di R8.
2. Creare l'account di servizio della multifunzione, senza scadenza password e senza accesso interattivo ad altri servizi del NAS, e assegnargli la sola scrittura sulle condivisioni di scansione.

   **Attenzione ai valori predefiniti del dialogo di creazione, verificati a schermo il 30/07/2026**: il NAS non crea un utente senza privilegi, ne crea uno con privilegi ereditati, e per un account di servizio sono tutti da togliere prima di confermare. Nella sezione delle autorizzazioni sulle cartelle condivise il nuovo utente arriva proposto con **lettura e scrittura su due cartelle di applicazione** e lettura sulla cartella pubblica: nessuna delle tre gli serve, e la seconda gli darebbe scrittura su spazi che non c'entrano nulla con le scansioni. Nella sezione dei privilegi applicativi arriva proposto con **accesso illimitato a tutte le applicazioni** del NAS, cioe' con la possibilita' di autenticarsi ai portali web dell'apparato: un account che deve solo scrivere file via SMB non ha alcun motivo di poterlo fare, ed e' il tipo di privilegio che trasforma una credenziale memorizzata in una stampante in una via d'accesso al NAS.

   **Correzione importante su quest'ultimo punto, appresa sbagliando il 30/07/2026**: "negare tutti i privilegi applicativi" e' un'istruzione troppo larga e rompe l'intervento. In quell'elenco convivono due categorie diverse: i **servizi di rete** (condivisione file Microsoft, AFP, FTP, WebDAV) e le **applicazioni** dell'apparato (File Station e simili). L'account di servizio ha bisogno di **esattamente uno** di quei permessi, la condivisione file Microsoft, perche' e' il protocollo con cui scrive; tutto il resto va negato, applicazioni comprese. Toglierli tutti, come una lettura affrettata dell'istruzione suggerirebbe, produce un account che si autentica ma non puo' scrivere nulla, e la multifunzione riporta un errore d'invio che non dice quale permesso manchi. E' il principio del minimo privilegio applicato bene: non "zero permessi", ma **solo quello che serve**.

   Va inoltre lasciata **disattivata** la richiesta di cambiare la password al primo accesso: un apparato non puo' eseguire un cambio interattivo, e attivarla farebbe fallire l'autenticazione senza un messaggio comprensibile.

   **Esito della creazione, verificato a schermo il 30/07/2026.** L'account di servizio esiste con la configurazione corretta: fra i privilegi e' concessa **soltanto** la condivisione file Microsoft, mentre AFP, FTP, WebDAV, le applicazioni dell'apparato e File Station sono negate; sulle cartelle condivise e' impostato il diniego esplicito dove esisteva un accesso ereditato, e l'anteprima riporta "nega accesso" su tutte quelle visibili. Resta da controllare la seconda pagina dell'elenco cartelle, che ne contiene altre due.

   Due note che il dialogo dei permessi dichiara e che servono al passo successivo. La prima e' l'ordine di precedenza: **diniego batte lettura/scrittura, che batte sola lettura**. Ne segue che sulle sette condivisioni di scansione l'account di servizio dovra' avere lettura/scrittura e **non** dovra' avere alcun diniego, altrimenti il diniego vince e la scansione fallisce. La seconda e' che le autorizzazioni del gruppo concorrono a quelle dell'utente nel determinare il risultato effettivo, quindi l'anteprima e' l'unico posto dove si legge cosa accade davvero: e' li' che si verifica, non nell'elenco delle spunte.

   **Immunita' alla rotazione: confermata.** Il criterio password del NAS (`Pannello di controllo > Sistema > Sicurezza > Politica sulla password`) ha la voce "richiedi agli utenti di cambiare periodicamente le password" **disattivata**, quindi nessuna scadenza si applica agli utenti locali dell'apparato. L'account di servizio e le utenze con cui gli utenti raggiungeranno le proprie cartelle vivono percio' fuori dal perimetro di rotazione dell'RMM, che agisce sulle utenze locali di Windows: e' la condizione che rende il disegno di R8 immune al cambio password, ed e' ora verificata e non assunta.

   Osservazione registrata nella stessa verifica, non un passo di questo intervento: il criterio di robustezza delle password del NAS richiede lettere e cifre con lunghezza minima di otto caratteri, senza caratteri speciali obbligatori e senza il divieto di coincidenza con il nome utente. E' un criterio debole rispetto a quello applicato agli endpoint, e vale una valutazione a se' (voce R14).

   Da verificare subito dopo la creazione, perche' e' la condizione che rende l'account davvero immune alla rotazione: che non esista una politica di scadenza delle password applicata agli utenti locali del NAS, o che quell'account ne sia escluso. Da verificare anche cosa concede il gruppo predefinito a cui ogni utente appartiene per costruzione: se quel gruppo ha permessi su qualche condivisione, l'account di servizio li eredita senza che nessuno glieli abbia assegnati. 2-bis. **Cifratura della cartella: valutata e deliberatamente non attivata (30/07/2026).** Il dialogo di creazione della condivisione offre la cifratura della cartella con una password e l'opzione di salvare la chiave sull'apparato. La domanda e' legittima e la risposta e' no, per tre ragioni che vanno registrate perche' la stessa domanda tornera' a ogni cartella nuova.

   La prima e' che quella cifratura protegge da un solo scenario, l'asportazione fisica dei dischi, mentre i dischi stanno in un CED con accesso a badge; non protegge in alcun modo dagli scenari che questo intervento affronta, che sono documenti depositati sugli endpoint, credenziali memorizzate negli apparati e utenti che vedono le cartelle degli altri — quelli si risolvono con destinazione e permessi, non con la cifratura.

   La seconda e' il compromesso che rende la scelta poco sensata proprio qui: una cartella cifrata resta **bloccata dopo ogni riavvio** dell'apparato finche' qualcuno non la sblocca con la password. Su una destinazione di scansione, che deve funzionare senza presidio, si tradurrebbe in scansioni che smettono di arrivare dopo un blackout — e questo ambiente ha gia' avuto un blackout con impatto documentato. L'alternativa e' spuntare il salvataggio della chiave sull'apparato, che la sblocca da sola all'avvio: ma cosi' la chiave vive sul NAS, e chi porta via il NAS intero, che e' il furto realistico, si porta via anche la chiave. L'opzione che rende la cifratura utilizzabile e' quindi la stessa che ne annulla quasi il beneficio.

   La terza e' la custodia della chiave: questo ambiente non ha ancora una pratica consolidata per i segreti — e' documentato il contrario nei gap SEC-007, SEC-010 e SEC-011 — e una chiave persa significa dati irrecuperabili.

   La conclusione non e' "la cifratura a riposo non serve", e' che **non e' questa la leva**. La leva e' una policy di cifratura a riposo decisa come tale, sul volume e sulle copie fuori sede, con la custodia delle chiavi definita: e' il gap A.8.24 gia' aperto (`GAP-TBC.md` #104, SEC-010), e va affrontato li' e non con una spunta su una singola cartella.

3. Assegnare i permessi di ciascuna condivisione secondo la tabella sopra — il destinatario in lettura e scrittura, l'account di servizio in sola scrittura, nessun altro — e verificare l'isolamento **prima** di toccare la multifunzione, non dopo, perche' scoprire un permesso sbagliato quando i documenti sono gia' dentro significa aver esposto documenti veri.

   La verifica non richiede piu' postazioni: si fa tutta da una sola macchina, perche' quello che conta e' l'identita' con cui si apre la connessione e non il computer da cui si parte. Da una finestra di comando, la prova positiva e' montare la condivisione con le credenziali del proprio destinatario e riuscire a scrivere un file; la prova negativa, che e' quella che dimostra il requisito, e' tentare di montare la condivisione di un altro destinatario con le stesse credenziali e ricevere un rifiuto.

   ```powershell
   # Prova positiva: il destinatario accede alla propria condivisione
   net use X: \\<indirizzo-nas>\scansioni_<nome-1> /user:<utente-1>
   # Prova negativa attesa: accesso negato alla condivisione di un altro destinatario
   net use Y: \\<indirizzo-nas>\scansioni_<nome-2> /user:<utente-1>
   net use X: /delete ; net use Y: /delete
   ```

   Un dettaglio di Windows che fa perdere tempo se non lo si sa: verso lo stesso server non si possono tenere aperte contemporaneamente connessioni con identita' diverse, e il tentativo restituisce un errore di conflitto di sessione (**1219**) che sembra un problema di permessi e non lo e'.

   **Precisazione appresa provandolo il 30/07/2026**, piu' utile della regola generale: il conflitto scatta anche indicando la **stessa** utenza, perche' e' l'opzione `/user` a chiedere una sessione nuova mentre una verso quel server esiste gia'. La soluzione non e' chiudere la connessione buona, e' **omettere `/user`**: senza quell'opzione Windows riusa la sessione autenticata gia' aperta e mette alla prova soltanto l'autorizzazione sulla condivisione, che e' precisamente cio' che il test deve misurare. Il rifiuto atteso in quel caso e' un accesso negato vero e proprio, non un errore di sessione — ed e' cosi' che si distingue una prova riuscita da un falso negativo. Lo stesso vale per l'account di servizio, che va provato con la sua credenziale: deve riuscire a **scrivere** in ciascuna condivisione e, se il NAS lo consente, non riuscire a **leggerne** il contenuto. 3-bis. **Due opzioni della terza fase del dialogo, viste il 30/07/2026, che valgono una decisione consapevole.**

   La prima e' la **cifratura SMB**, che va tenuta distinta dalla cifratura della cartella scartata al passo precedente: quella riguardava i dati a riposo, questa riguarda il **trasporto**, cioe' cifra il traffico verso la condivisione. E' un guadagno reale, perche' oggi i documenti scansionati e la credenziale dell'account di servizio viaggiano sulla LAN senza cifratura e senza che la firma SMB sia richiesta. Ha pero' un prerequisito: la cifratura SMB esiste solo dalla versione 3 del protocollo, e delle due multifunzione sappiamo che parlano "almeno la versione 2" — non se arrivino alla 3. Attivarla adesso rischierebbe di rompere la scansione prima di averla vista funzionare, con un errore dell'apparato che non direbbe quale sia la causa. Scelta: si lascia **disattivata per ottenere il funzionamento di base**, e la si attiva subito dopo come prova a se' stante, ripetendo una scansione da ciascun apparato; se regge, resta accesa ed e' un miglioramento di trasporto ottenuto gratis, se non regge si spegne sapendo esattamente perche'.

   La seconda e' l'**enumerazione basata sull'accesso**, nelle due varianti che il dialogo offre per le condivisioni e per il contenuto. Fa la stessa cosa che si e' ottenuta spuntando "nascondi unita' di rete", ma su un principio diverso e migliore: nasconde in base ai **permessi** invece che in base al nome, quindi ogni utente non vede cio' a cui non ha accesso, senza che nessuno debba decidere caso per caso cosa nascondere. Non si attiva ora perche' cambierebbe il modo in cui tutti navigano il NAS e non e' questo il momento di introdurre una variabile del genere; resta la strada corretta se un giorno si volesse sostituire l'accorgimento per oscurita' con un meccanismo basato sui permessi.

4. Sulla multifunzione, riconfigurare ciascuna voce della rubrica: host di destinazione l'indirizzo del NAS — un indirizzo e non un nome, perche' l'apparato non ha alcun server DNS configurato — percorso la sottocartella del destinatario, utenza quella dell'account di servizio. Annotare prima i valori attuali di ciascuna voce, perche' sono il rollback.
5. Provare ciascuna voce con il pulsante di prova connessione dell'apparato, poi con una scansione reale dal display, verificando che il file compaia nella cartella attesa. 5-bis. **Convenzione della lettera di unita', decisa il 30/07/2026 dopo un inciampo.** Le lettere di unita' sulle postazioni non sono libere: la prima prova di mappatura ha incontrato una lettera gia' assegnata in modo persistente a una condivisione del cloud raggiunta via tunnel, e la richiesta di sovrascriverla e' stata correttamente rifiutata dall'IT Manager. Nota tecnica utile: una mappatura **memorizzata** ma non connessa puo' non comparire nell'elenco delle connessioni attive, quindi "l'elenco e' vuoto" non significa "la lettera e' libera".

   Ne segue una regola per questo intervento: la cartella di scansione si mappa su una lettera **scelta e dichiarata**, la stessa su tutte le postazioni per non dover ricordare eccezioni, e prima di assegnarla si verifica che sia libera su ciascuna macchina. La verifica si fa leggendo sia le connessioni attive sia le mappature memorizzate nel registro dell'utente, perche' le seconde sopravvivono al riavvio e sono quelle che generano il conflitto.

   ```powershell
   # Connessioni attive
   net use
   # Mappature memorizzate, comprese quelle non connesse in questo momento
   Get-ChildItem 'HKCU:\Network' | Select-Object PSChildName, @{n='RemotePath';e={ (Get-ItemProperty $_.PSPath).RemotePath }}
   ```

5-ter. **Esito della prima prova, 30/07/2026: positiva superata.** Creata la prima condivisione con i permessi decisi, l'utenza NAS dell'IT Manager si e' connessa e ha scritto un file nella propria cartella. La prova negativa e' stata rinviata di un minuto perche' la lettera scelta era occupata da una mappatura persistente: ripetuta su una lettera libera.

   **Osservazione dallo stesso elenco, piu' importante della prova.** Le mappature persistenti di quella postazione puntano a due condivisioni di NAS **per nome** e non per indirizzo, mentre una terza punta per indirizzo a una condivisione raggiunta attraverso il tunnel verso il cloud. Le prime due sono quindi un'altra dipendenza dalla risoluzione nomi senza DNS interno: se quei nomi si risolvono per broadcast, quelle mappature si rompono attraversando un confine di livello 3, cioe' quando si segmentera'. E' la quarta forma della stessa trappola dopo mDNS delle stampanti, i nomi NetBIOS nelle rubriche di scansione e i nomi `.local` dei servizi interni — con la differenza che qui l'impatto e' su unita' di rete che le persone usano ogni giorno.

   Da verificare, ed e' una verifica di trenta secondi che cambia la stima di M22e: come si risolvono davvero quei nomi. Se per broadcast, ogni postazione con mappature per nome va toccata alla migrazione, oppure quei nomi vanno pubblicati sul DNS del firewall — che e' il caso in cui R12 diventa non piu' un miglioramento facoltativo ma il modo di non toccare le postazioni.

   ```powershell
   Resolve-DnsName -Name <nome-nas> -ErrorAction SilentlyContinue   # risponde il DNS?
   nbtstat -a <nome-nas>                                            # risponde NetBIOS?
   ```

5-quater. **Sette condivisioni create il 31/07/2026, e la verifica che precede le rubriche.** Con le sette cartelle in piedi, la prova che conta non e' piu' quella degli utenti ma quella dell'**account di servizio**: e' la credenziale che le multifunfioni useranno, e se manca un permesso su una sola cartella il sintomo arrivera' dal display di un apparato che non dice quale sia il problema. Va quindi provata da postazione, prima di configurare quattordici voci di rubrica.

   Il modo di farlo aggira il limite di Windows sulle sessioni multiple verso lo stesso server, che era stato incontrato con l'errore 1219: **una connessione per indirizzo e una per nome contano come due server distinti**. Poiche' la postazione ha gia' una sessione verso il NAS per indirizzo con l'utenza personale, la sessione dell'account di servizio si apre verso lo **stesso NAS chiamato per nome**, e le due convivono. E' un trucco, ma e' anche l'unico modo di provare due identita' contemporaneamente senza chiudere la connessione buona.

   La prova scrive un file di controllo in ciascuna delle sette cartelle e lo rimuove subito: scrivere e' l'unica verifica valida, perche' il permesso di scrittura non si deduce dalla possibilita' di elencare. Esito atteso: sette riuscite su sette. Se una fallisce, si corregge il permesso di quella cartella e si ripete solo quella, senza toccare le altre.

5-quinquies. **Distribuzione del collegamento sul desktop, via RMM.** Ogni destinatario deve raggiungere la propria cartella in un clic. La scelta e' un **collegamento** a percorso UNC e non un'unita' di rete mappata, per tre ragioni concrete: non consuma una lettera, e su queste postazioni le lettere sono scarse e gia' occupate da mappature persistenti (tre su una sola macchina, verificato il 30/07/2026); non si riconnette all'accesso, quindi non produce attese ne' icone in errore quando il NAS non risponde; e non compare come disco, il che evita che qualcuno la confonda con uno spazio locale. Un'unita' mappata resta preferibile solo quando un'applicazione pretende una lettera, che qui non e' il caso.

   La distribuzione avviene con `scripts/New-ScanFolderShortcut.ps1`, versionato in questo repository e pensato per essere eseguito dall'RMM su ciascuna postazione. Tre vincoli sono incorporati nello script e vanno rispettati nella configurazione dell'RMM.

   Il primo: va eseguito **nel contesto dell'utente connesso**, non come sistema. Il percorso del desktop si chiede all'ambiente dell'utente perche' su queste postazioni puo' essere reindirizzato su OneDrive, e in quel caso la cartella `Desktop` sotto il profilo non e' quella che l'utente vede; eseguendolo come sistema il collegamento finirebbe nel posto sbagliato. Sulla postazione di prova il desktop risulta non reindirizzato, ma la condizione non e' garantita su tutte.

   Il secondo: indirizzo del NAS e nome della condivisione sono **parametri obbligatori**, passati dalla configurazione dell'RMM e non scritti nello script, sia per la regola di anonimizzazione del repository sia perche' la condivisione cambia per destinatario. Sul lato RMM conviene quindi un parametro per dispositivo, oppure un campo personalizzato per dispositivo che lo script legge: sono sette postazioni e sette valori distinti.

   Il terzo: lo script e' **idempotente**, quindi puo' girare in modo ricorrente. Se il collegamento esiste e punta al bersaglio giusto lo dichiara invariato, se punta altrove lo corregge. Verificato in campo il 31/07/2026 su una postazione reale: prima esecuzione creato, seconda esecuzione invariato.

   **Protezione contro la cartella sbagliata, aggiunta il 31/07/2026 dopo averla vista servire.** Lanciato su una postazione con il nome della condivisione di un'altra persona, lo script creava obbediente un collegamento verso la cartella sbagliata: non poteva sapere a chi appartenesse la macchina. Ora, prima di scrivere, **verifica che l'utente connesso acceda davvero a quella condivisione**, e in caso contrario rifiuta. Il controllo funziona proprio grazie al disegno dei permessi: ogni cartella e' permessa al solo destinatario, quindi una condivisione altrui risulta inaccessibile e l'errore compare prima che il collegamento esista. La stessa asimmetria che protegge i documenti serve percio' come controllo di correttezza della distribuzione. Resta l'interruttore `-Force` per i casi dichiarati, ed e' anche il rimedio a un collegamento gia' creato per errore: rieseguendo lo script con la condivisione giusta, il bersaglio viene corretto.

   Nota di verifica: il collegamento e' un file locale e si crea anche quando il NAS non risponde, percio' la sua creazione **non** dimostra che l'utente possa accedere alla cartella. Lo script lo dichiara esplicitamente con un avviso quando il bersaglio non e' raggiungibile al momento dell'esecuzione, e la prova d'accesso resta quella fatta a mano dall'utente.

5-sexies. **Avanzamento per destinatario (esecuzione manuale, dal 31/07/2026).** Le sette configurazioni si fanno una persona alla volta, e per ciascuna servono quattro cose: la voce di rubrica sulla multifunzione del Piano Terra, quella sulla multifunzione del Piano 1, la credenziale del NAS memorizzata sulla postazione dell'utente, e il collegamento sul desktop. Il criterio di completamento non e' "configurato" ma **verificato**: una scansione reale da ciascuna delle due macchine che arriva nella cartella, e il collegamento che si apre senza richiesta di password.

   | Destinatario | Voce rubrica Piano Terra | Voce rubrica Piano 1 | Credenziale NAS | Collegamento sul desktop | Esito |
   |---|---|---|---|---|---|
   | IT Manager | fatta | fatta | presente | creato | funzionante |
   | Persona-C | fatta | fatta | presente | creato | funzionante |
   | Persona-D | fatta | fatta | presente | creato | funzionante |
   | Persona-E | fatta | fatta | presente | creato | funzionante |
   | Persona-A | creata | fatta | presente | creato | funzionante |
   | Persona-B | creata | fatta | presente | creato | funzionante |
   | Persona-J | creata | fatta | **memorizzata il 03/08, da rendere permanente** | creato | funzionante |

   Stato al 03/08/2026: tutte e sette le postazioni funzionanti. Due verifiche residue, entrambe a basso costo e alto valore: che la credenziale del NAS su ciascuna postazione sia permanente e non di sessione (`cmdkey /list` non deve riportare "solo per questo accesso", altrimenti al primo riavvio ricompare la richiesta di password), e che ciascun destinatario abbia visto arrivare una scansione da **entrambe** le macchine e non solo da una.

   Nota sulle tre voci da creare: la rubrica del Piano Terra conta quattro destinatari contro i sette del Piano 1, quindi per tre persone la voce va aggiunta e non modificata. Nota sulla colonna delle credenziali: se la postazione ha gia' una credenziale memorizzata verso il NAS — in una qualunque delle due forme, nome o indirizzo — non serve toccarla, perche' lo script di distribuzione usa la forma che funziona; se non ne ha nessuna, va aperta una volta la condivisione da Esplora risorse e memorizzata, altrimenti la verifica di accesso fallisce e il collegamento non viene creato.

5-septies. **Verificare ogni voce di rubrica sul posto, non dopo.** Entrambe le multifunzione hanno nel dialogo della voce un pulsante di **controllo della connessione** che tenta subito l'autenticazione e la scrittura verso il percorso indicato. Va premuto prima di confermare la voce: distingue immediatamente un errore di percorso da uno di credenziale, mentre una scansione di prova fatta dopo dice solo che qualcosa non ha funzionato. Costa cinque secondi per voce e trasforma quattordici configurazioni in quattordici verifiche.

   **Nota di disegno confermata il 03/08/2026**: tutte le voci di entrambe le macchine usano la **stessa credenziale di servizio**, mai quella dell'utente. Ne segue che l'isolamento tra destinatari non e' garantito dall'apparato ma dai permessi del NAS, ed e' una conseguenza voluta e gia' dichiarata in ADR-019: l'account di servizio puo' scrivere in tutte e sette le cartelle, quindi chi sta davanti al pannello puo' selezionare la destinazione di un'altra persona e la scansione vi finisce. Non puo' invece **leggere** le scansioni altrui, ed e' questa l'asimmetria che rende il disegno accettabile. La mitigazione dell'errore umano e' l'intervento R11, la conferma della destinazione prima dell'invio, la cui casella si trova **nello stesso dialogo** che si sta modificando: spuntarla mentre si passa voce per voce chiude R11 senza una seconda passata su quattordici schermate.

5-octies. **La credenziale del NAS va memorizzata, e non e' un'eccezione: e' un passo della procedura.** Su sei postazioni su sette il collegamento e' stato creato senza intoppi perche' una credenziale verso il NAS era gia' salvata da tempo. Sulla settima non c'era nulla — la cassaforte credenziali dell'utente era **vuota** — e il collegamento veniva rifiutato dalla verifica di accesso. Il meccanismo, verificato il 03/08/2026: in assenza di credenziale memorizzata Windows tenta l'accesso SMB con l'utenza corrente della macchina, che su queste postazioni e' un'utenza **locale** e sul NAS non esiste, quindi l'accesso e' negato. Non c'entrano ne' i permessi della condivisione, verificati corretti, ne' l'elevazione della sessione, che era la prima ipotesi.

   Il passo va quindi eseguito su ogni postazione prima del collegamento, e per **entrambe le forme** della destinazione, dato che Windows le tratta come server distinti.

   **Attenzione alla persistenza, correzione del 03/08/2026 dopo averla vista fallire.** Il comando da riga di comando (`cmdkey /add`) salva la credenziale **per la sola sessione corrente**: lo dichiara lui stesso nell'elenco, con la dicitura che il salvataggio vale solo per quell'accesso. Al riavvio della postazione la credenziale sparisce e il collegamento ricomincia a chiedere la password, con l'effetto peggiore possibile — l'intervento sembra riuscito il giorno in cui si fa e si rompe il giorno dopo, quando nessuno collega piu' le due cose. Da riga di comando non esiste un'opzione per renderla persistente.

   La via che produce una credenziale **permanente** e' l'interfaccia: si apre la condivisione da Esplora risorse digitando il percorso, si inseriscono le credenziali del NAS e si spunta la casella che le memorizza; in alternativa si aggiunge una credenziale di Windows dal pannello di gestione delle credenziali, indicando come destinazione l'indirizzo e poi il nome del NAS. Il comando da riga di comando resta utile per una **prova rapida**, non per la configurazione definitiva.

   ```powershell
   cmdkey /list   # verifica: le due voci non devono riportare "solo per questo accesso"
   ```

   Due note che evitano diagnosi sbagliate. La cassaforte credenziali e' **per utente** e condivisa fra sessione normale ed elevata, mentre le sessioni di rete sono separate: quindi memorizzare la credenziale risolve anche il caso dell'esecuzione elevata, e non serve inseguire quella pista. E un `net use` riuscito **non** memorizza nulla: apre una sessione che vive fino al riavvio, quindi se si prova l'accesso in quel modo e poi si crea il collegamento, tutto funziona oggi e si rompe domani. La prova che la cosa e' fatta bene e' `cmdkey /list` che elenca le due voci, non un accesso riuscito.

6. Comunicare agli utenti dove trovano da ora le scansioni, prima che se ne accorgano da soli. E' l'unico intervento del registro che cambia un'abitudine, quindi la comunicazione fa parte della procedura e non e' un extra.
7. Solo dopo che tutte le destinazioni funzionano, rimuovere le condivisioni di scansione dalle postazioni e le credenziali che le servivano.

Verifica complessiva: quattro scansioni reali, una per destinazione, e un controllo di accesso incrociato da due postazioni diverse. Rollback: ripristino dei valori annotati al passo 4, una riscrittura di tre campi per voce.

#### La scelta del protocollo, e la premessa da verificare prima di scegliere

Sul tavolo, il 30/07/2026, sono arrivate due proposte alternative: portare le scansioni sul NAS usando **FTP** invece di SMB, nel presupposto che le multifunzione parlino soltanto SMB versione 1 e che quella versione non sia accettabile; oppure installare **un server FTP su ciascuna postazione** e cambiare protocollo nelle rubriche, lasciando le destinazioni dove sono. Vanno valutate separatamente, perche' la prima e' una scelta di protocollo dentro il disegno giusto e la seconda e' un disegno diverso.

**La seconda proposta va scartata**, e le ragioni sono quattro e indipendenti. Non risolve il problema che R8 esiste per risolvere, perche' i documenti continuerebbero a depositarsi sulle postazioni: cambierebbe il protocollo del trasporto, non la destinazione dei dati. Aggiunge un servizio in ascolto su ogni endpoint, cioe' allarga la superficie di attacco esattamente dove si e' investito per ridurla, e su una LAN piatta quel servizio e' raggiungibile da tutti. Moltiplica il lavoro di gestione per il numero di postazioni, con un server da installare, aggiornare e configurare su ciascuna, e mantiene la dipendenza dal fatto che quel PC sia accesso. E il protocollo in chiaro trasporterebbe credenziali e documenti in chiaro sulla rete. Nessuno dei quattro punti dipende dalla versione di SMB: la proposta e' peggiore a prescindere.

**La prima proposta ha il disegno giusto ma la premessa da verificare**, e la premessa e' decisiva perche' se cade, cade anche la scelta di FTP. L'affermazione che gli apparati parlino solo SMB versione 1 non e' ancora un fatto verificato, e ci sono due scenari possibili, entrambi significativi. Se gli apparati parlano SMB 2 o superiore, allora si va sul NAS in SMB e la questione FTP non si pone. Se davvero parlano solo SMB versione 1 e le scansioni verso le postazioni funzionano, allora il fatto interessante non e' la multifunzione: e' che **SMB versione 1 e' abilitato sulle postazioni**, cioe' un protocollo dismesso da anni e vettore di famiglie di malware note e' attivo sugli endpoint aziendali. Sarebbe un gap piu' grave di quello che stiamo chiudendo, e andrebbe registrato come tale.

Nota di correzione: una versione precedente di questo documento dava per risolto il dubbio deducendolo dal fatto che le destinazioni sono condivisioni di postazioni Windows 11, dove SMB versione 1 e' disabilitato per impostazione predefinita, quindi gli apparati dovevano necessariamente parlare SMB 2 o superiore. La deduzione e' valida solo se su quelle postazioni nessuno ha riattivato SMB versione 1, che in un parco cresciuto per stratificazioni non e' scontato. Resta un'inferenza plausibile, non un fatto: va misurata.

##### Come si misura, in tre modi indipendenti

Il primo e' il piu' diretto e non richiede di toccare nulla: si fa una scansione di prova verso una postazione e, subito dopo, su quella postazione si leggono le sessioni SMB aperte, che riportano il dialetto negoziato dal client.

```powershell
# Sulla postazione che riceve la scansione, subito dopo l'invio
Get-SmbSession | Select-Object ClientComputerName, ClientUserName, Dialect, NumOpens
Get-SmbConnection | Select-Object ServerName, Dialect     # per le connessioni in uscita
# Stato del protocollo legacy sulla postazione
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol | Select-Object FeatureName, State
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol, EnableSMB2Protocol, RequireSecuritySignature
```

Il valore di `Dialect` chiude la questione: se e' `2.x` o `3.x` la premessa cade e si va in SMB; se e' `1.x`, la premessa e' confermata e con essa il gap sulle postazioni.

Il secondo e' leggere le impostazioni di protocollo degli apparati stessi, dove entrambi i modelli espongono la versione SMB del proprio client: sulla Kyocera nella pagina dei protocolli di Command Center RX, sulla Canon nelle impostazioni di rete alla voce del client SMB, dove tipicamente si impostano versione minima e massima. Se l'apparato consente di alzare la versione minima, il problema si risolve configurandolo e non cambiando protocollo.

Il terzo e' lato NAS: nelle impostazioni della condivisione file di rete Microsoft si puo' fissare la versione minima accettata. Alzandola a SMB 2 si ottengono due cose insieme, cioe' la certezza che nessun client possa negoziare la versione legacy e una prova pratica immediata, perche' un apparato che dopo quella modifica non riesce piu' a scrivere e' un apparato che stava usando la versione legacy.

##### Prima misura, 30/07/2026: sulla postazione dell'IT Manager il protocollo legacy e' disattivato

Eseguiti i comandi sulla postazione dell'IT Manager, che e' anche una delle sette destinazioni di scansione censite su entrambi gli apparati. Tre risultati.

Il protocollo legacy **non e' attivo**: la funzione opzionale di Windows risulta disabilitata e la configurazione del servizio riporta il protocollo versione 1 disattivato e la versione 2 attiva. La sessione SMB osservata in quel momento negoziava **dialetto 3.1.1**, cioe' la versione piu' recente, il che dimostra che su questa rete SMB 3 funziona senza problemi tra Windows e Windows.

Da qui una deduzione che vale come prova, e non piu' come inferenza. Entrambe le multifunzione hanno tra le proprie destinazioni una condivisione **su questa stessa postazione**. Se il protocollo versione 1 e' disattivato su di essa, un apparato che parlasse solo quella versione non riuscirebbe nemmeno a stabilire la connessione: quindi **se quelle due destinazioni funzionano, gli apparati parlano necessariamente SMB 2 o superiore**, e la premessa che aveva motivato la proposta FTP cade. La verifica residua e' percio' minima e non tecnica: basta una scansione di prova da ciascun apparato verso quella postazione e osservare se il file arriva. Per leggere anche il dialetto esatto negoziato dall'apparato, il comando sulle sessioni va eseguito entro pochi secondi dall'invio, perche' queste macchine chiudono la sessione appena finito il trasferimento.

Due osservazioni collaterali dallo stesso output. La firma SMB non e' richiesta sulla postazione: e' un irrobustimento candidato, da valutare quando si sara' certi che tutti i client parlano almeno SMB 2, perche' richiederla con un client legacy in giro romperebbe quel client. La sessione osservata proveniva invece da un'altra postazione autenticandosi con un account **locale** della postazione dell'IT Manager: chiarito subito dall'IT Manager che si tratta di un accesso deliberato e noto, concesso a un collega verso un disco interno di quella macchina. Non e' quindi un accesso opaco ma un accordo documentato, e resta annotato solo perche' un account locale condiviso tra macchine e' il tipo di configurazione che, se non scritta da nessuna parte, in due anni diventa inspiegabile: ora e' scritta.

##### Esito definitivo, 30/07/2026: entrambi gli apparati scrivono, premessa FTP decaduta

Eseguite le due scansioni di prova verso la cartella della postazione dell'IT Manager, dove il protocollo legacy e' disattivato. La multifunzione del Piano Terra ha depositato il proprio PDF; quella del Piano 1, comandata a distanza dallo strumento di controllo remoto del produttore invece che dal display fisico, ha depositato il proprio nella stessa cartella. Il secondo file e' un PDF vuoto perche' la prova e' stata fatta senza foglio, cosa che non inficia il risultato: quello che si stava verificando e' la connessione, non l'immagine.

Conclusione: **entrambe le multifunzione parlano SMB 2 o superiore**, perche' nessun apparato limitato al protocollo legacy potrebbe stabilire una connessione con un host che quel protocollo ha disabilitato. La premessa che motivava la proposta FTP e' decaduta, la prima opzione dell'ordine di preferenza e' percorribile, e le sette condivisioni del NAS si configurano in SMB. Da qui deriva anche un'informazione operativa utile per il resto dell'intervento: la multifunzione del Piano 1 e' pilotabile a distanza dal proprio strumento di controllo remoto, quindi le prove di scansione dei passi successivi si possono fare dalla postazione senza salire al piano.

##### Ordine di preferenza del protocollo, deciso a monte del risultato

Anche qui la regola si fissa prima di conoscere l'esito, per non adattarla al risultato. La prima scelta e' **SMB 2 o 3 verso il NAS**, con la firma attiva e, se il NAS e gli apparati lo consentono, la cifratura SMB 3: e' il protocollo che il NAS gestisce nativamente con permessi per utente, ed e' quello che stiamo gia' usando per tutto il resto. La seconda scelta, se e solo se un apparato non e' in grado di superare SMB versione 1, e' **FTP esplicito su TLS** verso il servizio FTP del NAS, limitato a quell'apparato, con un account dedicato che non serve nient'altro: cifra il trasporto e resta centralizzato. La terza, cioe' **FTP in chiaro**, si adotta solo se le prime due sono impossibili, e in quel caso non e' una scelta ma un debito: va registrata come gap con la stessa serieta' con cui e' stato registrato il portale servito in chiaro, perche' significa far viaggiare documenti e credenziali in chiaro sulla LAN.

#### Evoluzione futura, da non confondere con questo intervento

Il disegno qui descritto e' quello corretto per la situazione attuale, in cui l'utente non si autentica sull'apparato. Se in futuro la multifunzione venisse integrata con la directory aziendale e gli utenti si autenticassero al pannello, diventerebbe possibile la soluzione piu' elegante, in cui l'apparato invia alla cartella personale dell'utente autenticato usando la sua identita': niente account di servizio e isolamento garantito dall'autenticazione invece che dai permessi. E' un progetto a se', con impatto sull'esperienza d'uso (l'utente deve identificarsi prima di scansionare) e con una dipendenza dalla directory: va valutato quando si affrontera' la gestione delle identita', non adesso.

### R9 — Account di servizio invece di account nominali

Almeno una delle destinazioni di scansione usa come utenza di accesso il nome e cognome di una persona. Un'utenza nominale usata da un apparato ha tre difetti: il log della share non distingue piu' l'attivita' della persona da quella della macchina, la credenziale resta memorizzata in un dispositivo che quella persona non controlla, e alla sua uscita dall'azienda la disattivazione dell'account rompe silenziosamente la scansione. Un account di servizio dedicato, con permesso di scrittura solo sulla share di scansione, risolve tutti e tre. Va eseguito insieme a R8, perche' e' la stessa configurazione.

### R12 — I nomi interni sul DNS del firewall

E' l'intervento con il miglior rapporto tra beneficio e rischio emerso finora, ed e' nato da una lettura che smentisce un'affermazione ripetuta piu' volte in questo progetto. Si era scritto che sulla LAN non esiste risoluzione nomi interna: **non e' vero**. La verifica del 30/07/2026 sull'ambito DHCP di `lan1` mostra che il primo server DNS distribuito ai client e' il firewall stesso, mentre secondo e terzo sono assenti e i campi WINS sono vuoti. Esiste quindi un resolver, ed e' un apparato che governiamo: quello che manca non e' il servizio, sono i **record**.

Il firewall ZLD puo' ospitare record di indirizzo propri, quindi i nomi dei sistemi interni — NAS, multifunzione, servizi applicativi interni — si possono pubblicare li'. Non serve introdurre un dominio, non serve toccare gli endpoint, non serve distribuire file `hosts`: i client interrogano gia' quel resolver per ogni nome che non risolvono da soli.

Le conseguenze sugli altri fronti aperti sono tre, e sono la ragione per cui questo intervento va prima e non dopo. Chiude in gran parte SEC-016, perche' la risoluzione nomi smette di dipendere da file distribuiti a mano. Rimuove la dipendenza dal broadcast, cioe' da mDNS e NetBIOS, che e' la trappola incontrata tre volte in questo progetto e che si rompe inevitabilmente appena si segmenta. E rende sensato il ri-puntamento delle code di stampa a un **nome** invece che a un indirizzo, che e' esattamente il passo che rende gratuiti tutti gli spostamenti futuri delle stampanti: senza un DNS interno quel passo richiedeva una voce `hosts` per postazione, con il DNS interno e' un record unico.

Procedura: identificare i nomi da pubblicare partendo da quelli che servono davvero (NAS di destinazione delle scansioni, le due multifunzione, il portale interno della VM208), creare i record corrispondenti sul firewall, verificare la risoluzione da una postazione con una query diretta, e solo dopo usare quei nomi nelle configurazioni. Verifica: la risoluzione del nome da una postazione risponde con l'indirizzo atteso e, dopo la segmentazione, continua a rispondere — che e' precisamente cio' che mDNS non farebbe. Rollback: rimuovere il record, dato che nessuna configurazione dipende dal nome finche' non la si cambia.

#### Correzione di priorita' del 30/07/2026: R12 non e' un prerequisito

Una prima stesura di questa voce presentava R12 come prerequisito degli altri interventi e come primo passo dell'esecuzione. **E' un errore di priorita' e va corretto qui**, perche' altrimenti torna alla sessione successiva.

R12 non serve al problema delle scansioni e non serve alla migrazione delle stampanti. Le destinazioni di scansione di R8 devono essere indirizzi in ogni caso, perche' le multifunzione non hanno alcun server DNS configurato: il nome non lo risolverebbero comunque. E lo spostamento delle stampanti in un segmento dedicato si fa ri-puntando le code al nuovo indirizzo, esattamente come si e' sempre fatto qui.

Il beneficio reale di R12 e' un altro e piu' ristretto: evitare che *ogni prossimo* cambio di indirizzo di un servizio interno richieda di toccare tutte le postazioni. Va pesato contro il fatto che in questa azienda la pratica consolidata e' modificare il file `hosts` di ogni endpoint quando serve, che e' una pratica che funziona e che le persone conoscono. Con quel punto di partenza, il guadagno immediato di un record DNS e' nullo per un singolo spostamento: la voce `hosts` costa lo stesso lavoro del ri-puntamento diretto. E c'e' un costo che la prima stesura non aveva dichiarato — un record DNS **non** sostituisce le voci `hosts` esistenti: il file locale ha precedenza, quindi finche' quelle voci restano il record e' invisibile, e per ottenere il beneficio bisogna anche ripulirle su ogni postazione. Il lavoro non diminuisce, si sposta.

R12 resta quindi un intervento valido ma **indipendente e non urgente**, e le sue vere motivazioni sono altre tre, tutte estranee alle stampanti: chiude la dipendenza dal broadcast (mDNS e NetBIOS) che rendera' fragile la segmentazione; elimina progressivamente la proliferazione delle voci `hosts`, che oggi nessuno inventaria; e, grazie alla convenzione di ADR-018, apre la strada al certificato pubblico per il portale interno, che e' il pezzo mancante di SEC-016. Si esegue quando conviene, non prima di R8.

**Sequenza corretta**: prima R8 con R9 e R10, che risolvono il problema da cui tutto e' partito e non dipendono da nulla; poi gli interventi brevi R1, R2, R3, R5, R6; poi M22b, il segmento stampanti; R12 e R13 quando si vuole, come miglioramento a se'.

#### Riformulazione del 30/07/2026: R12 non e' creare, e' consolidare

**Attenzione all'ordine delle correzioni, perche' qui ce ne sono due e la seconda annulla la prima.** Interrogando il resolver del firewall per il nome di un NAS e' arrivata una risposta, e da quella si era concluso che l'apparato ospitasse gia' record di indirizzo interni. La lettura della pagina DNS del firewall, poche ore dopo, dice il contrario: la tabella dei record di indirizzo e' **vuota**, come quella degli alias, e l'unica configurazione presente inoltra qualunque zona verso due resolver pubblici. Il firewall e' percio' un **puro inoltratore**: nessun nome interno vive su di lui.

Da dove veniva allora la risposta. Dallo stack di risoluzione di Windows, non dal server interrogato: il comando usato consulta anche i meccanismi locali di scoperta — mDNS e NetBIOS — e il nome ottenuto finiva in `.local` con un tempo di vita di 120 secondi, che sono la firma tipica di una risposta mDNS annunciata dall'apparato stesso. La lezione di metodo, registrata anche in `dev-testing.md`, e' che indicare un server nel comando **non garantisce** che la risposta arrivi da quel server: per provarlo serve forzare la sola via DNS, altrimenti si attribuisce a un'infrastruttura una risposta prodotta da un broadcast.

Resta invece vero, ed e' il punto che conta, che sul suffisso `.local` esiste un'intera pratica: i servizi si annunciano, i nomi si risolvono per broadcast e i file `hosts` completano il resto. E' NET-014, su scala piu' ampia di quanto si pensasse.

La seconda: in parallelo ogni postazione mantiene il proprio file `hosts`, e quello ispezionato contiene **sedici voci** che rimappano a mano gli stessi nomi e altri ancora, compreso un nome del dominio pubblico aziendale dirottato verso un indirizzo interno — cioe' un orizzonte separato costruito a mano, postazione per postazione. Poiche' il file locale ha precedenza sul DNS, oggi convivono due sistemi di risoluzione in concorrenza e nessuno sa quale risponde su una data macchina.

Ne segue che R12 non e' un intervento di creazione ma di **consolidamento**, e cambia anche il suo valore: non serve a "dare i nomi", serve a far coincidere i nomi. La sequenza corretta diventa pubblicare i record sul suffisso deciso in ADR-018, verificare che rispondano, e solo allora **rimuovere le voci `hosts` corrispondenti** su ogni postazione — passo che va inventariato prima, perche' finche' quelle voci esistono i record nuovi restano invisibili. Resta, come prima, un intervento indipendente dalle stampanti e non urgente.

#### Passo R12-1: la convenzione dei nomi, e un difetto nei nomi gia' in uso

Prima di creare un solo record va deciso il suffisso, perche' cambiarlo dopo significa rifare ogni configurazione che lo usa. La ricognizione dei nomi interni attualmente in uso nel progetto mostra tre convenzioni diverse convissute nel tempo: un servizio interno su `.intrawelt.local`, un altro su un nome breve seguito da `.local`, e il portale della VM208 su `.intrawelt.lan`.

Il problema non e' l'incoerenza, e' che **`.local` e' riservato a mDNS** dallo standard che lo definisce. Un nome che finisce in `.local` viene risolto dai sistemi operativi interrogando il multicast, non il DNS unicast: pubblicare record `.local` su un server DNS produce un comportamento che dipende dall'ordine dei risolutori del singolo client, quindi funziona su una macchina e non sull'altra, e smette di funzionare attraversando un confine di livello 3. E' la stessa trappola che abbiamo incontrato tre volte questa settimana, con la differenza che qui e' incorporata nella scelta del nome. Ne segue che i due nomi `.local` esistenti non sono uno standard da seguire ma un debito da migrare.

Restano due strade sensate.

La prima e' un suffisso di uso privato, `.lan`, che il portale della VM208 usa gia'. E' semplice, non collide con mDNS, non richiede nulla dall'esterno. Il limite e' che non e' un nome di cui l'azienda sia titolare: non e' assegnabile a nessuna autorita' di certificazione pubblica, quindi ogni servizio interno servito in HTTPS continuera' a dipendere da una CA interna e dalla sua distribuzione a mano, che e' esattamente il gap SEC-016.

La seconda e' un sottodominio del dominio pubblico che l'azienda possiede, per esempio la forma `<host>.int.<dominio-aziendale>`, con i record pubblicati **solo** sul DNS interno e mai su quello pubblico. Costa una riga di convenzione in piu' e ha due vantaggi che la prima non ha. Non collidera' mai con nulla, perche' il dominio e' dell'azienda, mentre un suffisso inventato puo' un giorno diventare un dominio di primo livello reale. E rende ottenibile un **certificato di una CA pubblica** per i servizi interni, tramite la validazione via record DNS che non richiede di esporre il servizio su Internet: il portale interno smetterebbe di dipendere da una CA importata macchina per macchina, e SEC-016 si chiuderebbe per intero invece che a meta'.

**Decisione dell'IT Manager del 30/07/2026: la seconda** — i nomi interni vivono su un sottodominio del dominio aziendale, nella forma `<host>.int.<dominio-aziendale>`, con i record pubblicati soltanto sul DNS interno del firewall e mai su quello pubblico. Razionale completo e vincoli in ADR-018. Ne segue che i due nomi `.local` esistenti sono un debito da migrare a questa convenzione (intervento R13), e che il beneficio sui certificati ha una dipendenza da conoscere in anticipo: la validazione via record DNS richiede di poter creare un record di testo sulla zona **pubblica** del dominio presso il fornitore che la ospita, ma non richiede alcun record di indirizzo pubblico.

#### Passo R12-2: i record da creare

Elenco minimo, quello che serve ai fronti aperti. I nomi sono indicativi e vanno confermati insieme al suffisso; gli indirizzi sono quelli documentali, i reali stanno nella mappa privata.

Nomi pienamente qualificati secondo la convenzione decisa (`int.<dominio-aziendale>`); gli indirizzi sono quelli documentali, i reali stanno nella mappa privata.

| Nome pienamente qualificato | Punta a | Serve per |
|---|---|---|
| `nas-intra2.int.<dominio>` | `10.61.20.177` | Destinazione delle scansioni di R8: e' il nome che entrera' nelle rubriche delle multifunzione al posto dell'indirizzo |
| `stampante-pt.int.<dominio>` | `10.61.30.10` | Ri-puntamento della coda della multifunzione del Piano Terra a un nome, cosi' lo spostamento di M22b non tocca piu' le postazioni |
| `stampante-p1.int.<dominio>` | `10.61.30.133` | Idem per la multifunzione del Piano 1 |
| `nas-hero.int.<dominio>` | `10.61.20.169` | Riferimento stabile per le unita' di rete oggi mappate per indirizzo |
| `nas-intra.int.<dominio>` | `10.61.20.168` | Idem |
| `asset.int.<dominio>` | `10.61.20.25` | Portale interno della VM208, che oggi si risolve per file `hosts` su ogni postazione: e' il caso che dimostra il beneficio, perche' quel file smette di servire, e sara' il primo candidato al certificato pubblico |

#### Passo R12-3: dove si creano, e come si verifica

Sul firewall il percorso atteso e' `Configuration > System > DNS`, sezione dei record di indirizzo, dove si aggiunge la coppia nome pienamente qualificato e indirizzo. Va confermato a schermo, perche' la denominazione esatta della sezione cambia tra le versioni del firmware, e va verificato nella stessa pagina che il servizio DNS sia consentito dall'interfaccia della LAN — condizione che i client soddisfano gia', dato che ricevono il firewall come primo server DNS e navigano.

La verifica va fatta con due accortezze, altrimenti si scambia un successo per un fallimento o viceversa. La prima: un'eventuale voce nel file `hosts` della postazione **vince** sul DNS, quindi se il nome scelto e' gia' presente in `hosts` la risposta arriva da li' e non prova nulla; conviene interrogare esplicitamente il firewall. La seconda: la cache del risolutore locale va svuotata, altrimenti si continua a leggere una risposta vecchia.

```powershell
# Interroga esplicitamente il firewall, ignorando hosts e cache locale
Resolve-DnsName -Name <nome-scelto> -Server 10.61.10.1 -Type A
# Poi la risoluzione normale della postazione, che e' quella che conta per le applicazioni
Clear-DnsClientCache
Resolve-DnsName -Name <nome-scelto> -Type A
# Controllo di cosa contiene oggi il file hosts, che ha precedenza sul DNS
Get-Content "$env:WINDIR\System32\drivers\etc\hosts" | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() }
```

#### Passo R12-4: i segmenti che oggi non riceverebbero i nomi

Emerso dalla decisione sulla convenzione, e va corretto contestualmente altrimenti i record esistono ma metà della rete non li vede. I client cablati ricevono il firewall come primo server DNS e quindi risolveranno i nomi nuovi senza alcun intervento. Non e' cosi' per tutti i segmenti.

La **Wi-Fi staff** riceve, per come e' stato configurato il suo ambito DHCP il 16/07/2026, `8.8.8.8` come primo DNS e `1.1.1.1` come secondo: sono resolver pubblici, che non conoscono i nomi interni. Un dispositivo staff non risolverebbe quindi ne' il NAS ne' le stampanti ne' il portale interno, e la nota che lo prevedeva era gia' scritta nella scheda firewall al momento della creazione di quell'ambito. Va corretto impostando il firewall come primo DNS di quel segmento, coerentemente con la postura decisa in ADR-014, per cui la Wi-Fi staff lavora come una postazione cablata.

La **rete ospiti** riceve anch'essa resolver pubblici, e li' non si tocca nulla: e' corretto che un ospite non risolva i nomi interni, ed e' coerente con la regola che lo lascia uscire solo verso Internet.

I **client VPN** ricevono gia' il firewall come DNS, quindi risolveranno i nomi interni da remoto senza alcuna modifica. Vale la pena saperlo perche' e' un beneficio collaterale: i nomi funzioneranno anche in VPN, cosa che nessun file `hosts` distribuito a mano ha mai garantito.

Esito atteso: la prima query risponde con l'indirizzo del record appena creato; la seconda risponde allo stesso modo, a meno che una voce `hosts` non lo intercetti, e in quel caso la voce va rimossa perche' e' precisamente il debito che R12 esiste per eliminare. Rollback: rimuovere il record, dato che nessuna configurazione dipende dal nome finche' non la si cambia.

### R10 — Regola di conservazione sulla cartella delle scansioni

Va deciso insieme a R8 e non dopo, perche' e' molto piu' facile stabilire una regola su una cartella nuova che su una cartella che ha gia' accumulato tre anni di documenti. Una cartella di scansioni non presidiata diventa in pochi mesi un archivio documentale parallelo: non censito, non classificato, pieno di documenti che contengono dati personali e che nessuno ricorda di aver messo li'. Il fatto che sia su un NAS con backup peggiora il quadro invece di migliorarlo, perche' le copie si moltiplicano.

La regola da concordare e' semplice: le scansioni sono un mezzo di trasporto dal vetro dello scanner alla propria postazione o al proprio archivio, non un luogo di conservazione, quindi oltre una soglia di giorni concordata con chi usa il servizio vengono cancellate automaticamente. La soglia la decide chi lavora, non l'IT: quindici giorni sono comodi, trenta sono generosi, novanta significano che la cartella e' diventata un archivio e allora il problema e' un altro. Procedura: una regola di cancellazione pianificata sul NAS, oppure uno script schedulato, applicata alla cartella delle scansioni e non alle cartelle di lavoro. Verifica: dopo il primo ciclo, i file oltre soglia non ci sono piu' e quelli entro soglia si. Rollback: disattivare la regola; i file gia' cancellati restano recuperabili solo dallo snapshot o dal backup del NAS, quindi la prima applicazione va fatta con una soglia volutamente larga e ristretta poi, non il contrario.

## Come si aggiorna questo registro

Ogni intervento chiuso passa a stato `Fatto` con la data, e lo stesso fatto va riportato nella voce di timeline della giornata e, se tocca un controllo Annex A, nella scheda `design-and-security.md`. Se un intervento si rivela piu' invasivo di quanto sembrava, non si forza: si sposta nella roadmap come micro-step con la sua finestra, e in questo registro resta la riga con la nota del perche' e' stato promosso. La disciplina di ammissione e' l'unica cosa che tiene utile un registro come questo.
