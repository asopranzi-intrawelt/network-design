# Registro dei micro-interventi di robustezza

> Registro operativo aperto il 29/07/2026. Raccoglie gli interventi piccoli, indipendenti
> e **non bloccanti** che emergono come effetto collaterale delle analisi di progetto: cose
> che si possono fare una alla volta, in orario di lavoro, senza interrompere niente e senza
> attendere il completamento di un micro-step strutturale della Fase 3. Ogni voce e' un
> intervento a se': ha un motivo dichiarato, una procedura, una verifica, un criterio di
> rollback e uno stato. Non sostituisce la roadmap: la roadmap dice dove va la rete, questo
> registro dice cosa si puo' migliorare subito mentre ci si arriva.
>
> Il criterio di ammissione a questo registro e' esplicito e va rispettato, altrimenti
> diventa un contenitore di lavori arretrati: un intervento entra qui solo se non richiede
> finestre di manutenzione, non tocca il piano dati di apparati centrali, e ha un rollback
> di una sola azione. Tutto il resto sta nei micro-step della roadmap.

## Perche' un registro separato

Le analisi di questo progetto producono due tipi di risultato. Il primo sono i difetti
strutturali, che richiedono progetto, finestre e coordinamento: la rete piatta, la DMZ
assente, le VPN con parametri deboli. Il secondo sono i difetti puntuali che si scoprono
mentre si guarda dentro un apparato per un'altra ragione: una credenziale di fabbrica mai
cambiata, un annuncio multicast inutile, una porta rimasta in una VLAN di test, un campo
descrittivo vuoto. Il secondo tipo ha una caratteristica che merita un trattamento
diverso: il rapporto tra riduzione del rischio e costo e' altissimo, e il rischio di
rompere qualcosa e' quasi nullo.

Tenerli insieme ai micro-step strutturali li condanna ad aspettare. Metterli in un
registro proprio, con il vincolo che ciascuno sia eseguibile in isolamento, li rende
eseguibili nei ritagli di tempo e li rende anche *contabili*: a fine mese si sa quanti
sono stati chiusi, e ciascuno e' una riga di miglioramento verificabile nella
documentazione ISO27001, non un'intenzione.

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
| R8 | Spostare le destinazioni di scansione dalle cartelle condivise delle postazioni a una share dedicata sul NAS | NET-009 (#114) lato flussi dato, SEC-020 (#126), A.8.3 e A.5.14 | Nessuno sulla rete: si riconfigurano le destinazioni sull'apparato. Cambia dove gli utenti trovano le scansioni, quindi richiede comunicazione | Da fare |
| R9 | Sostituire negli account di scansione i nomi di persona con un account di servizio dedicato alla share di scansione | SEC-020 (#126), A.9.2: un account nominale usato da un apparato non e' attribuibile a una persona ed e' impossibile da dismettere all'uscita di quella persona | Nessuno se eseguito insieme a R8 | Da fare |
| R10 | Definire una regola di conservazione sulla cartella delle scansioni (cancellazione automatica oltre una soglia di giorni concordata) | Minimizzazione e limitazione della conservazione: una cartella di scansioni diventa in pochi mesi un archivio documentale parallelo, non censito e pieno di dati personali. Rilevante per A.5.33 e per il principio di limitazione della conservazione | Nessuno sulla rete; va concordata la soglia con chi usa il servizio | Da fare, dipende da R8 |

## Dettaglio degli interventi

### R1 — Credenziali di fabbrica sulla multifunzione

La multifunzione del Piano Terra ha il pannello amministrativo protetto dalla coppia di
credenziali predefinita del produttore, quella pubblicata nella documentazione del
prodotto. Il pannello governa indirizzamento, protocolli esposti e rubrica delle
destinazioni di scansione, e la rubrica contiene credenziali di accesso a condivisioni
aziendali: chi entra puo' leggere dove finiscono i documenti, cambiarne la destinazione, e
usare il pulsante di prova connessione per validare credenziali.

Procedura: dal pannello web, sezione delle impostazioni di gestione, cambiare la password
dell'utenza amministrativa; registrare la nuova credenziale nel password manager
aziendale sulla VM202, non in un file e non in un documento condiviso. Verifica: nuovo
accesso al pannello con la credenziale nuova, e conferma che una stampa di prova esce
normalmente (il cambio non tocca il servizio di stampa, ma la verifica costa dieci
secondi). Rollback: non necessario; se la credenziale nuova venisse persa, resta il reset
amministrativo dal display dell'apparato, che e' fisicamente presidiato.

### R2 — Filtro IP come controllo compensativo

Finche' la rete e' piatta il firewall non vede il traffico tra una postazione e la
multifunzione, quindi non puo' proteggere il pannello amministrativo. L'apparato ha
tuttavia una funzione di filtro degli indirizzi ammessi: e' l'unico punto in cui oggi si
puo' restringere quella platea, e la porta da tutta la `/19` alle due o tre postazioni IT.

Procedura: nella sezione TCP/IP del pannello, aprire le impostazioni dei filtri IPv4 e
consentire l'accesso ai soli indirizzi delle postazioni IT. Attenzione, ed e' la ragione
per cui questo intervento va fatto con la verifica accanto: il filtro, se applicato a tutti
i protocolli invece che alla sola amministrazione, blocca anche la stampa dalle
postazioni. Verifica obbligatoria in due passi, nell'ordine: prima una stampa di prova da
una postazione **non** IT, che deve continuare a funzionare, poi un tentativo di accesso al
pannello dalla stessa postazione, che deve essere rifiutato. Rollback: disattivare il
filtro, che e' una singola opzione.

### R3 — Disabilitare Bonjour

L'apparato annuncia se stesso in multicast e pubblica un nome nel dominio `.local`. Serve
alla scoperta automatica da parte dei client, che qui non e' il modo con cui le code sono
state create: le code puntano all'indirizzo. L'annuncio quindi non porta beneficio e ha due
costi, uno piccolo e uno insidioso. Il piccolo e' traffico multicast e superficie di
esposizione in piu'. L'insidioso e' che invita a ri-puntare le code al nome `.local`, che
funziona oggi e cessa di funzionare il giorno in cui la stampante finisce in un segmento
diverso, perche' mDNS non attraversa un confine di livello 3.

Procedura: nella sezione TCP/IP, impostare Bonjour su `Off` e inviare. Verifica: la
risoluzione del nome `.local` dalla postazione non risponde piu', mentre la stampa
continua a funzionare. Rollback: rimettere `On`.

### R4 — Campo Posizione

Costa trenta secondi e rende l'inventario leggibile dal pannello, che e' il punto in cui lo
si consulta quando si e' davanti alla macchina con un problema. Procedura: sezione delle
impostazioni dispositivo, campo `Posizione`, valore uguale all'ubicazione fisica reale
coerente con `mappatura-porte-fisiche.md`. Verifica: il valore compare
nell'intestazione del pannello. Nessun rollback necessario.

### R5 — Porta 19 dello switch del Piano Terra

La porta e' rimasta configurata come access sulla VLAN degli ospiti dopo il test cablato
del 22/07, nonostante risultasse ripristinata: e' una presa a muro che consegna chi si
collega direttamente in rete ospiti, cioe' una segmentazione al contrario. Oggi non ha
link, quindi non c'e' impatto in atto, ed e' esattamente il momento giusto per correggerla.

Procedura: dal pannello Nebula, vista di dettaglio della porta 19 dello switch del Piano
Terra, impostare PVID 1 e salvare; oppure con `Set-NebulaWifiVlan.ps1` in dry-run e poi
`-Apply`, che lascia traccia in `output/nebula-apply-log-*.json`. Verifica: rilettura della
configurazione della porta, e prova con un portatile che ottiene un indirizzo nella classe
delle postazioni e non in quella ospiti. Rollback: rimettere PVID 90, che e' lo stato
attuale.

### R6 — Porte di stampa orfane sulle postazioni

Su almeno una postazione convivono due porte verso lo stesso indirizzo di stampante, una
usata dalla coda e una orfana, residuo di un ri-puntamento fatto in passato creando una
porta nuova. Non fanno danno, ma al prossimo ri-puntamento moltiplicano le voci e rendono
ambiguo quale porta sia viva.

Procedura: sulla postazione, elencare code e porte, individuare le porte non associate a
nessuna coda e rimuoverle. Verifica: la coda stampa ancora e la porta orfana non compare
piu'. Rollback: la porta si ricrea in trenta secondi con lo stesso indirizzo. Estensione:
lo stesso controllo va fatto sull'inventario dell'RMM per tutte le postazioni, non solo su
quella esaminata.

### R7 — Da indirizzo statico a riserva DHCP

Le multifunzione hanno oggi indirizzo statico impostato sull'apparato. Ne segue che ogni
cambio di indirizzo, compreso quello della migrazione, richiede di mettere le mani sul
pannello di ciascuna macchina. Convertirle in riserva DHCP sposta il controllo sul
firewall: da quel momento il cambio di indirizzo e' una modifica centrale, e la
riconciliazione tra MAC, indirizzo e apparato vive in un solo posto invece che su ogni
pannello.

Procedura, nell'ordine: sul firewall, creare o verificare l'ambito DHCP che serve la classe
delle stampanti e registrare una riserva per il MAC dell'apparato con lo stesso indirizzo
che ha oggi, cosi' che nulla cambi; poi sull'apparato impostare DHCP su `On` e inviare;
infine riavviare la rete dell'apparato. Verifica: l'apparato riprende **lo stesso**
indirizzo di prima, la stampa di prova esce, la scansione verso la destinazione configurata
arriva. Rollback: rimettere l'indirizzo statico sul pannello, che e' la configurazione
attuale e va annotata prima di iniziare. Nota di finestra: e' l'unica voce del registro con
una indisponibilita', di pochi minuti, perche' l'apparato richiede il riavvio della rete
per applicare il cambiamento.

### R8 — Scansioni verso una share dedicata sul NAS

E' l'intervento con il maggior valore di questo registro, e va capito bene perche' e'
anche l'unico che cambia l'esperienza degli utenti. Oggi tutte le destinazioni di
scansione della multifunzione del Piano Terra puntano a cartelle condivise di singole
postazioni, con le credenziali di quelle postazioni memorizzate nell'apparato. Ne derivano
quattro problemi indipendenti: i documenti scansionati, che spesso contengono dati
personali, finiscono su endpoint invece che su uno spazio presidiato e sottoposto a backup
noto; la scansione funziona solo se quella postazione e' accesa e la condivisione e'
attiva; l'apparato conserva credenziali di accesso a share aziendali (SEC-020); e la
matrice dei flussi del progetto di segmentazione nega esattamente questo percorso, quindi
il giorno della migrazione queste destinazioni smetterebbero di funzionare.

La cosa importante, ed e' il motivo per cui questo intervento sta nel registro dei
non-bloccanti invece che dentro M22b: **si puo' fare adesso, sulla rete piatta, senza
toccare nessuna VLAN**, e produce da subito il beneficio di governo dei dati. Quando poi
arrivera' la segmentazione, le destinazioni saranno gia' dove devono essere e il passo si
riduce a una regola sul firewall.

#### Requisito posto dall'IT Manager il 29/07/2026

Gli utenti hanno gia' accesso a NAS-INTRA2 e a due cartelle di primo livello di NAS-HERO,
quindi l'accesso esistente si puo' sfruttare invece di crearne uno nuovo. La condizione e'
che nella nuova cartella di primo livello dedicata alle scansioni **ciascun utente veda
soltanto la propria sottocartella** e non quelle degli altri.

Il requisito sembra banale e non lo e', perche' entra in tensione diretta con R9. Se
l'isolamento tra utenti lo si ottenesse facendo scrivere l'apparato con le credenziali di
ciascun utente, come avviene oggi verso le postazioni, allora la multifunzione dovrebbe
conservare al proprio interno le credenziali personali di tutti — cioe' si peggiorerebbe
esattamente il problema che SEC-020 registra, su un apparato il cui pannello ha ancora le
credenziali di fabbrica. La separazione va quindi ottenuta dal lato dei permessi del NAS, non
dal lato delle credenziali dell'apparato.

#### Il disegno che soddisfa entrambe le cose

Un solo **account di servizio** dedicato alla scansione, che e' l'unica credenziale
memorizzata nella multifunzione, con permesso di scrittura su tutte le sottocartelle; e i
permessi degli utenti definiti sul NAS in modo che ciascuno acceda solo alla propria. L'utente
non usa mai la credenziale dell'apparato e l'apparato non usa mai quella dell'utente: sono due
percorsi distinti verso la stessa cartella, ed e' questa separazione a rendere il disegno
sostenibile.

```
<cartella di primo livello: Scansioni>
├── <utente-1>/   servizio: scrittura   utente-1: lettura/scrittura   altri: nessun accesso
├── <utente-2>/   servizio: scrittura   utente-2: lettura/scrittura   altri: nessun accesso
├── <utente-3>/   servizio: scrittura   utente-3: lettura/scrittura   altri: nessun accesso
└── <utente-4>/   servizio: scrittura   utente-4: lettura/scrittura   altri: nessun accesso
```

| Soggetto | Sulla cartella di primo livello | Sulla propria sottocartella | Sulle sottocartelle altrui |
|---|---|---|---|
| Account di servizio della multifunzione | attraversamento, nessuna lettura dell'elenco se il NAS lo consente | scrittura e creazione file | scrittura e creazione file (inevitabile: e' un solo account per tutte le destinazioni) |
| Utente | attraversamento | lettura e scrittura, cancellazione dei propri file | **nessun accesso** |
| Amministratore IT | pieno | pieno | pieno |

Sul rischio residuo bisogna essere onesti, perche' e' il punto che un auditor chiederebbe:
l'account di servizio puo' scrivere in tutte le sottocartelle, quindi chi ne ottenesse la
credenziale potrebbe depositare file nella cartella di chiunque. Non puo' pero' *leggere* le
scansioni altrui se il NAS permette di concedergli la sola scrittura, ed e' questa
asimmetria a fare la differenza rispetto a oggi: attualmente l'apparato conserva credenziali
che danno accesso completo a cartelle condivise di postazioni. Il rischio passa quindi da
lettura e scrittura su endpoint a sola scrittura su una cartella presidiata, e viene ridotto
ulteriormente da R1 e R2, che chiudono la via d'accesso al pannello dove quella credenziale
e' memorizzata.

#### Su quale NAS, e la nota che ne consegue

La scelta e' tra i due apparati a cui gli utenti hanno gia' accesso. Il criterio non e' lo
spazio, che in entrambi i casi e' ampiamente sufficiente, ma la copertura di backup e le
implicazioni di un'eventuale replica fuori sede: NAS-HERO e' replicato offsite su
archiviazione cloud secondo quanto documentato in
`business-continuity-disaster-recovery.md`, quindi scegliendolo le scansioni erediterebbero
automaticamente una copia esterna. E' un vantaggio di continuita' e insieme un fatto da
dichiarare, perche' significa che documenti con dati personali vengono replicati presso un
fornitore cloud: va verificato che questo sia coerente con quanto dichiarato agli
interessati e con il registro dei trattamenti, non deciso implicitamente da una scelta di
cartella. Decisione dell'IT Manager, da registrare qui quando presa.

#### Come si ottiene davvero la separazione per sottocartella sul NAS scelto

**Decisione dell'IT Manager del 29/07/2026: il NAS di destinazione e' NAS-INTRA2.** Coerente
con la raccomandazione: se le scansioni sono un mezzo di trasporto con una scadenza (R10) e
non un archivio, replicarle fuori sede sarebbe un costo di riservatezza senza un beneficio
di continuita' reale.

La domanda operativa che ne segue e' come si separano gli accessi *dentro* una cartella di
primo livello, dato che per impostazione predefinita su questi NAS i permessi si assegnano
alla cartella condivisa e chi vi accede vede tutto quello che contiene. Ci sono due strade
native, piu' una che va scartata.

La prima strada e' abilitare le **autorizzazioni avanzate per cartella**, che sul pannello di
controllo del NAS stanno nella sezione dei privilegi, alla voce delle cartelle condivise,
scheda delle autorizzazioni avanzate. Attivata quell'opzione, i permessi diventano
assegnabili anche alle sottocartelle, dal gestore file: si seleziona la sottocartella, si
aprono le proprieta' e si concede a ciascun utente lettura e scrittura sulla propria e
nessun accesso sulle altre, con la possibilita' di applicare la scelta in modo ricorsivo.
E' la strada che soddisfa il requisito mantenendo **una sola** cartella di primo livello,
come chiesto, e scala quando gli utenti aumentano. L'unica cautela e' che l'opzione e'
globale per l'apparato e cambia il modo in cui i permessi vengono valutati: va attivata
deliberatamente e va verificato prima se non sia gia' attiva, perche' la presenza di cartelle
condivise nominative suggerisce che una gestione granulare sia gia' in uso. L'attivazione non
modifica da sola i permessi esistenti, che restano quelli della cartella condivisa finche'
non si assegna un permesso specifico a una sottocartella.

La seconda strada e' creare **una cartella condivisa per utente**, cioe' spostare la
separazione dal livello sottocartella al livello cartella condivisa, dove i permessi
esistono sempre e senza abilitare nulla. E' la strada piu' semplice e la piu' robusta, e
richiede zero modifiche di configurazione globale; il costo e' che la lista delle cartelle
condivise di primo livello, che oggi ha gia' tredici voci tra cartelle di lavoro, backup e
cartelle di sistema dell'apparato, cresce di una voce per utente e diventa meno leggibile.
Con quattro destinatari e' del tutto praticabile, con quindici no.

La strada da scartare, ed e' utile dire perche', e' usare le cartelle personali degli utenti
che l'apparato mette a disposizione nativamente. Sono isolate per costruzione, quindi
sembrerebbero la risposta ovvia, ma scrivervi dall'esterno richiede privilegi
amministrativi sul NAS: la multifunzione dovrebbe conservare una credenziale
amministrativa, che e' esattamente cio' che questo intervento vuole evitare. La separazione
nativa risolverebbe il problema degli utenti creandone uno molto piu' grande sull'apparato.

Raccomandazione: la prima strada, con verifica preliminare se le autorizzazioni avanzate
siano gia' attive. La seconda resta il piano di ripiego se per qualche motivo non si vuole
toccare quell'impostazione globale, e non e' una scelta di serie B — e' solo meno ordinata
nella lista delle condivisioni.

Nota a margine emersa dalla stessa lettura: tra le cartelle condivise di primo livello
esiste una cartella pubblica, tipicamente accessibile a tutti gli utenti. Va evitato che la
cartella delle scansioni le somigli per permessi, ed e' un motivo in piu' per verificare i
permessi effettivi al termine dell'intervento invece di fidarsi di come sono stati impostati.

#### Procedura

Nell'ordine, e ogni passo verificabile prima del successivo.

1. Su NAS-INTRA2, verificare se le autorizzazioni avanzate per cartella sono gia' attive e,
   se non lo sono, attivarle; poi creare la cartella condivisa di primo livello dedicata alle
   scansioni, senza concedervi accesso generalizzato.
2. Creare l'account di servizio della multifunzione, senza scadenza password e senza
   accesso interattivo ad altri servizi del NAS, e assegnargli la sola scrittura sulle
   sottocartelle.
3. Creare una sottocartella per ciascuno dei destinatari attuali e assegnare i permessi
   secondo la tabella sopra dal gestore file dell'apparato, verificando **da due postazioni
   diverse** che ciascun utente veda la propria e non quelle degli altri: e' la verifica che
   dimostra il requisito, e va fatta prima di toccare la multifunzione, non dopo, perche'
   scoprire un permesso sbagliato quando i documenti sono gia' dentro significa aver esposto
   documenti veri.
4. Sulla multifunzione, riconfigurare ciascuna voce della rubrica: host di destinazione
   l'indirizzo del NAS — un indirizzo e non un nome, perche' l'apparato non ha alcun server
   DNS configurato — percorso la sottocartella del destinatario, utenza quella dell'account
   di servizio. Annotare prima i valori attuali di ciascuna voce, perche' sono il rollback.
5. Provare ciascuna voce con il pulsante di prova connessione dell'apparato, poi con una
   scansione reale dal display, verificando che il file compaia nella cartella attesa.
6. Comunicare agli utenti dove trovano da ora le scansioni, prima che se ne accorgano da
   soli. E' l'unico intervento del registro che cambia un'abitudine, quindi la
   comunicazione fa parte della procedura e non e' un extra.
7. Solo dopo che tutte le destinazioni funzionano, rimuovere le condivisioni di scansione
   dalle postazioni e le credenziali che le servivano.

Verifica complessiva: quattro scansioni reali, una per destinazione, e un controllo di
accesso incrociato da due postazioni diverse. Rollback: ripristino dei valori annotati al
passo 4, una riscrittura di tre campi per voce.

#### Un dettaglio tecnico che il quadro attuale risolve da se'

Un dubbio legittimo prima di toccare l'apparato e' se la multifunzione parli una versione di
SMB accettata da un NAS configurato correttamente, perche' molti apparati di questa
generazione nascono con SMB versione 1 e i NAS aggiornati la rifiutano. Qui la risposta si
ricava dai fatti gia' raccolti senza fare prove: le destinazioni attuali sono cartelle
condivise di postazioni Windows 11, dove SMB versione 1 e' disabilitato per impostazione
predefinita, e le scansioni funzionano. Ne segue che l'apparato parla gia' SMB 2 o
superiore, quindi il passaggio al NAS non incontrera' quell'ostacolo. Resta buona pratica
verificare sul NAS quale dialetto minimo e' accettato, ma non e' un rischio aperto.

#### Evoluzione futura, da non confondere con questo intervento

Il disegno qui descritto e' quello corretto per la situazione attuale, in cui l'utente non
si autentica sull'apparato. Se in futuro la multifunzione venisse integrata con la
directory aziendale e gli utenti si autenticassero al pannello, diventerebbe possibile la
soluzione piu' elegante, in cui l'apparato invia alla cartella personale
dell'utente autenticato usando la sua identita': niente account di servizio e isolamento
garantito dall'autenticazione invece che dai permessi. E' un progetto a se', con impatto
sull'esperienza d'uso (l'utente deve identificarsi prima di scansionare) e con una
dipendenza dalla directory: va valutato quando si affrontera' la gestione delle identita',
non adesso.

### R9 — Account di servizio invece di account nominali

Almeno una delle destinazioni di scansione usa come utenza di accesso il nome e cognome di
una persona. Un'utenza nominale usata da un apparato ha tre difetti: il log della share non
distingue piu' l'attivita' della persona da quella della macchina, la credenziale resta
memorizzata in un dispositivo che quella persona non controlla, e alla sua uscita
dall'azienda la disattivazione dell'account rompe silenziosamente la scansione. Un account
di servizio dedicato, con permesso di scrittura solo sulla share di scansione, risolve
tutti e tre. Va eseguito insieme a R8, perche' e' la stessa configurazione.

### R10 — Regola di conservazione sulla cartella delle scansioni

Va deciso insieme a R8 e non dopo, perche' e' molto piu' facile stabilire una regola su una
cartella nuova che su una cartella che ha gia' accumulato tre anni di documenti. Una cartella
di scansioni non presidiata diventa in pochi mesi un archivio documentale parallelo: non
censito, non classificato, pieno di documenti che contengono dati personali e che nessuno
ricorda di aver messo li'. Il fatto che sia su un NAS con backup peggiora il quadro invece di
migliorarlo, perche' le copie si moltiplicano.

La regola da concordare e' semplice: le scansioni sono un mezzo di trasporto dal vetro dello
scanner alla propria postazione o al proprio archivio, non un luogo di conservazione, quindi
oltre una soglia di giorni concordata con chi usa il servizio vengono cancellate
automaticamente. La soglia la decide chi lavora, non l'IT: quindici giorni sono comodi,
trenta sono generosi, novanta significano che la cartella e' diventata un archivio e allora
il problema e' un altro. Procedura: una regola di cancellazione pianificata sul NAS, oppure
uno script schedulato, applicata alla cartella delle scansioni e non alle cartelle di lavoro.
Verifica: dopo il primo ciclo, i file oltre soglia non ci sono piu' e quelli entro soglia si.
Rollback: disattivare la regola; i file gia' cancellati restano recuperabili solo dallo
snapshot o dal backup del NAS, quindi la prima applicazione va fatta con una soglia
volutamente larga e ristretta poi, non il contrario.

## Come si aggiorna questo registro

Ogni intervento chiuso passa a stato `Fatto` con la data, e lo stesso fatto va riportato
nella voce di timeline della giornata e, se tocca un controllo Annex A, nella scheda
`design-and-security.md`. Se un intervento si rivela piu' invasivo di quanto sembrava,
non si forza: si sposta nella roadmap come micro-step con la sua finestra, e in questo
registro resta la riga con la nota del perche' e' stato promosso. La disciplina di
ammissione e' l'unica cosa che tiene utile un registro come questo.
