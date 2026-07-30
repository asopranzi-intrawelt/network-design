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
| R11 | Attivare la conferma della destinazione prima dell'invio sulle destinazioni di scansione di entrambe le multifunzione | SEC-020 (#126): su tutte le voci censite l'opzione e' disattivata, quindi una selezione sbagliata dal display invia documenti nella cartella di un'altra persona senza alcun passaggio che permetta di accorgersene | Nessuno sulla rete; aggiunge un tocco in piu' all'utente che scansiona, ed e' il compromesso da spiegare | Da fare |
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

#### Come si diventa immuni alla rotazione delle password, e non solo meno esposti

Obiettivo posto dall'IT Manager il 30/07/2026, e va preso alla lettera: non ridurre il
problema, **eliminarlo**. La soluzione deve essere tale che il cambio password degli
endpoint non tocchi mai la scansione.

Il ragionamento parte da cosa ruota davvero. La rotazione a trenta giorni e' una policy
dell'RMM sulle **utenze locali di Windows**: agisce sugli endpoint, non sugli altri
apparati della rete. Ne segue che qualunque credenziale memorizzata che *sia* un'utenza
locale di Windows scade, e qualunque credenziale che appartenga a un sistema fuori da quel
perimetro no. Il problema quindi non e' la rotazione: e' il fatto che oggi le destinazioni
di scansione usano identita' delle postazioni. Spostare la destinazione sul NAS non e' solo
una scelta di governo dei dati, e' la condizione per l'immunita'.

Il disegno immune ha due gambe, e vanno rese immuni entrambe, altrimenti il problema si
sposta invece di sparire.

La gamba macchina-verso-storage e' l'account di servizio della multifunzione: **utenza
locale del NAS**, non di Windows, quindi fuori dalla policy dell'RMM per costruzione. Va
verificato che sul NAS non sia attiva una politica di scadenza password che la riporterebbe
dentro il problema da un'altra porta: se lo e', quell'account va escluso o configurato senza
scadenza. E' l'unica credenziale memorizzata negli apparati, quindi l'unica che potrebbe
scadere: risolta questa, la scansione non si rompe piu' da sola.

La gamba utente-verso-storage e' l'accesso di ciascuna persona alla propria cartella. Anche
qui l'identita' da usare e' **un'utenza locale del NAS**, non quella di Windows: si salva
una volta nelle credenziali di Windows e sopravvive a tutte le rotazioni successive, perche'
e' una credenziale diversa e gestita da chi amministra il NAS, non dall'RMM. Il costo e' che
la persona ha una seconda password, che pero' digita una sola volta.

##### Perche' non si puo' fare di meglio oggi, e cosa lo renderebbe possibile

La soluzione strutturalmente superiore sarebbe non memorizzare nessuna credenziale: con un
servizio di directory e l'autenticazione integrata, l'utente ottiene l'accesso alla propria
cartella con il *ticket* della sessione di lavoro e il cambio password diventa un non-evento,
perche' non c'e' nessun segreto salvato da aggiornare. Lo snapshot dell'RMM del 30/07/2026 dice
pero' che quella strada oggi non esiste: i ventisei dispositivi gestiti dell'organizzazione
sono **tutti standalone**, in workgroup, senza alcun dominio (gap SEC-021,
`GAP-TBC.md` #128). Senza directory non c'e' autenticazione integrata, e ogni accesso tra
sistemi resta necessariamente basato su una credenziale memorizzata.

Vale la pena registrare che l'introduzione di un servizio di directory con DNS interno
chiuderebbe in un colpo quattro cose che questo progetto sta affrontando separatamente: la
dipendenza dalle credenziali memorizzate, l'assenza di risoluzione nomi interna (SEC-016), la
dipendenza dal broadcast per NetBIOS e mDNS che rende fragile ogni segmentazione, e la
distribuzione a mano dei file `hosts`. Non e' un intervento di rete e non appartiene a questo
registro: e' un progetto con impatto organizzativo, che cambia anche il modo in cui l'RMM
gestisce le utenze. Va valutato come tale, e nel frattempo la coppia di utenze locali del NAS
descritta sopra rende la scansione immune alla rotazione senza dipendere da quel progetto.

#### Un argomento in piu', che da solo giustificherebbe l'intervento

Registrato il 30/07/2026: gli endpoint sono gestiti da un RMM distribuito che **impone la
rotazione della password locale ogni trenta giorni** (vedi
`.claude/context/design-and-security.md` §Contesto di gestione degli endpoint e ADR-017). Ne
segue che qualunque credenziale di postazione memorizzata nelle multifunzione ha una vita
massima di trenta giorni: le undici destinazioni censite non sono soltanto un problema di
protezione dei dati, sono una manutenzione ricorrente che si rompe da sola a ogni rotazione e
che qualcuno deve rimettere a posto ogni volta, apparato per apparato.

Questo cambia il modo di presentare R8 a chi lo deve approvare. Non e' un intervento di
sicurezza che chiede uno sforzo in cambio di un rischio ridotto: e' un intervento che
**elimina un lavoro ricorrente** e in piu' riduce il rischio. L'account di servizio sul NAS
vive fuori dal perimetro di rotazione degli endpoint, quindi la destinazione di scansione
smette di scadere.

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

La struttura, nella forma decisa il 29/07/2026 dopo la correzione descritta sotto, e' una
cartella condivisa per destinatario invece di una cartella unica con sottocartelle. Il
disegno dei permessi non cambia, cambia solo il livello a cui vengono applicati.

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

**Raccomandazione rivista il 29/07/2026: la seconda strada, una cartella condivisa per
utente.** La prima stesura raccomandava le autorizzazioni avanzate, sulla base
dell'assunzione errata che l'attivazione fosse a costo nullo. Con i dati veri il confronto si
capovolge. Le quattro destinazioni attuali richiedono quattro cartelle condivise: quattro
righe in piu' in una lista che ne ha dodici, permessi assegnati dove esistono nativamente,
nessuna impostazione globale toccata, nessuna riscrittura di permessi su milioni di oggetti,
nessun cambiamento nel modello di gestione dei permessi del resto del NAS, e l'intervento e'
eseguibile subito e in orario di lavoro — cioe' rispetta la regola di ammissione di questo
registro, che la prima strada non rispetta piu'.

La prima strada resta quella giusta se e quando i destinatari diventeranno molti, o se si
decidera' di adottare permessi per sottocartella come modello generale del NAS. In quel caso
diventa un intervento a se', da pianificare fuori orario con la durata misurata su una prova,
e non un passaggio dentro R8. La differenza tra le due non e' tecnica ma di ordine di
grandezza: quattro utenti non giustificano una riscrittura di permessi su cinque milioni di
oggetti.

#### Stato verificato il 29/07/2026: le autorizzazioni avanzate sono disattivate

Verifica eseguita sul pannello di controllo di NAS-INTRA2, sezione privilegi, cartelle
condivise, scheda delle autorizzazioni avanzate: **entrambe le caselle sono deselezionate**,
sia quella delle autorizzazioni avanzate per cartella sia quella del supporto Windows ACL.
Oggi, quindi, i permessi vivono solo a livello di cartella condivisa e chi accede a una
condivisione vede tutto il suo contenuto: il requisito di separazione per utente non e'
soddisfabile senza intervenire su una delle due strade descritte sopra.

Due precisazioni che contano per non fare danni. La casella da attivare e' **solo** la prima,
quella delle autorizzazioni avanzate per cartella: la seconda, il supporto Windows ACL, e'
un'altra cosa e va lasciata disattivata, perche' cambia il modello di permessi verso quello
NTFS e ha senso solo con un dominio a cui appoggiarsi.

**Correzione del 29/07/2026, importante perche' ribalta la raccomandazione.** Una prima
stesura di questo documento affermava che attivare l'opzione non modifica i permessi
esistenti. E' falso, e lo dice l'apparato stesso nel dialogo di conferma che compare
spuntando la casella: all'attivazione **tutte le autorizzazioni delle sottocartelle vengono
impostate come quelle delle cartelle principali**, con un'operazione che puo' richiedere
diversi minuti in funzione del numero di file e cartelle da elaborare. Non e' una spunta di
configurazione, e' una riscrittura massiva di permessi su tutto il volume.

Su questo apparato specifico quel "diversi minuti" va letto con i numeri veri: una sola
cartella condivisa contiene circa 3,45 milioni di cartelle e 1,86 milioni di file (gap
STOR-001, `GAP-TBC.md` #127), e il pannello di amministrazione e' gia' marcatamente lento
(NAS-003 in `runbook-anomalie.md`). L'inizializzazione attraverserebbe l'intero albero
generando I/O su un apparato con 4 GB di RAM e CPU ARM che nel frattempo serve le
condivisioni di lavoro. Ne derivano due conseguenze: la durata reale e' imprevedibile e va
misurata, non stimata, e l'operazione va comunque fuori orario di lavoro.

C'e' anche una conseguenza di lungo periodo, meno visibile e piu' importante: dopo
l'inizializzazione ogni sottocartella porta permessi espliciti propri, quindi la gestione dei
permessi diventa granulare **e** manuale, e una modifica al permesso di una cartella
condivisa non si propaga piu' implicitamente a tutto il suo contenuto. Su un NAS con
quell'albero significa un modello di permessi molto piu' potente e molto piu' facile da
sbagliare.

C'e' poi un comportamento da **verificare in campo prima di migrare le destinazioni**, e non
da dare per scontato leggendo la documentazione del produttore: quando un utente ha permesso
su una sottocartella ma non sulla cartella condivisa che la contiene, l'accesso funziona per
percorso diretto ma l'elenco della cartella condivisa puo' essere negato. E' esattamente il
comportamento che vogliamo per gli utenti, che devono raggiungere la propria cartella e non
vedere quelle altrui, ma va provato anche per l'**account di servizio della multifunzione**,
che si connette alla condivisione e poi scende nella sottocartella: se la connessione alla
condivisione richiede un permesso che l'account non ha, la scansione fallisce con un errore
che sul display dell'apparato non dice nulla di utile. La prova si fa con un utente di test e
una cartella di test, prima di toccare la rubrica, ed e' il motivo per cui il passo 3 della
procedura viene prima del passo 4.

Nota operativa sull'apparato: la sua interfaccia di amministrazione risponde con lentezza
marcata, cosa rilevata durante questa stessa verifica e registrata in
`runbook-anomalie.md` §NAS-003. Va messo in conto nel tempo dell'intervento, perche' R8
richiede diversi passaggi in quella interfaccia.

Nota a margine emersa dalla stessa lettura: tra le cartelle condivise di primo livello
esiste una cartella pubblica, tipicamente accessibile a tutti gli utenti. Va evitato che la
cartella delle scansioni le somigli per permessi, ed e' un motivo in piu' per verificare i
permessi effettivi al termine dell'intervento invece di fidarsi di come sono stati impostati.

#### Passo zero: censimento globale dei destinatari su tutti gli apparati

Richiesto dall'IT Manager il 29/07/2026, prima di creare qualunque cartella, ed e' la
domanda giusta al momento giusto: il disegno di R8 dimensionato su quattro destinatari e' una
cosa, lo stesso disegno su dodici e' un'altra, e la scelta tra cartelle condivise separate e
autorizzazioni per sottocartella dipende esattamente da quel numero. La rubrica letta finora
e' solo quella della multifunzione del Piano Terra; l'altra multifunzione, la Canon del Piano
1, ha la propria rubrica indipendente e i due insiemi vanno **unificati e non sommati**,
perche' chi lavora su due piani puo' comparire in entrambe.

| Apparato | Destinazioni rilevate | Di cui verso postazioni | Stato del censimento |
|---|---|---|---|
| Kyocera TASKalfa 2552ci (Piano Terra) | 4 | 4 | **Fatto 29/07/2026** |
| Canon iR-ADV C5840 (Piano 1) | 7, tutte nell'elenco a selezione veloce | 7 | **Fatto 29/07/2026** |
| **Unione dei destinatari distinti** | **7** | 7 | **Censimento chiuso** |

Le undici destinazioni si riducono a sette destinatari distinti perche' quattro persone sono
censite su entrambe le multifunzione: le quattro voci della Kyocera sono un sottoinsieme delle
sette della Canon, che aggiunge tre destinatari non presenti al Piano Terra. Nessuna
destinazione e' di tipo e-mail o FTP: sono **undici su undici cartelle di rete SMB**, tutte
verso condivisioni di postazioni, con la conferma che il fronte scan-to-folder e' totale su
entrambi gli apparati e non una particolarita' di uno dei due.

Tre fatti nuovi emersi dalla rubrica della Canon, che il primo censimento non poteva mostrare.

Il primo e' che **due destinazioni su sette usano un nome NetBIOS della postazione invece
dell'indirizzo** (`\\<nome-postazione>\<condivisione>`). Funzionano oggi perche' la risoluzione
NetBIOS avviene in broadcast dentro il dominio di livello 2, ed e' lo stesso meccanismo che
muore attraversando un confine di livello 3: e' quindi una terza forma della stessa trappola
gia' vista con mDNS sulle stampanti e con l'assenza di un DNS interno. Dopo R8 la questione
si estingue da se', perche' tutte le destinazioni puntano al NAS per indirizzo, ma va
registrata perche' spiega perche' quelle due voci si romperebbero **prima** delle altre.

Il secondo e' che i nomi utente memorizzati includono **due utenze nominali** invece di
account di servizio, una su ciascun apparato: la motivazione di R9 e' quindi doppia e non un
caso isolato.

Il terzo e' un dettaglio della configurazione che vale un intervento a se': su tutte e sette
le voci l'opzione di **conferma prima dell'invio e' disattivata**. Significa che chi
scansiona non vede una richiesta di conferma della destinazione scelta, quindi una selezione
sbagliata dal display invia i documenti nella cartella di un'altra persona senza nessun
passaggio che permetta di accorgersene. Aggiunto al registro come R11.

Sulla lettura della rubrica del secondo apparato c'e' una particolarita' del modello che vale
la pena annotare, perche' a prima vista fa sembrare il censimento un lavoro enorme quando non
lo e'. La rubrica espone un elenco personale, cinquanta elenchi per gruppi di utenti, dieci
elenchi indirizzi e un elenco per amministratori: sessantadue contenitori, tutti creati a
vuoto per costruzione. La colonna dei conteggi lo dice a chiare lettere, perche' tutti
riportano zero destinazioni tranne l'**elenco a selezione veloce**, che ne contiene sette.
Tutta la rubrica utile di quell'apparato sta quindi in un solo elenco, e leggerla e' un clic.

Per completezza, dato che era stata cercata: la funzione di importazione ed esportazione su
questo modello sta in `Impostazioni/Registrazione`, sezione `Impostazioni gestione`, voce
**`Gestione dati`**, dove si trovano importazione ed esportazione sia complessive sia per
singolo elemento, incluso l'elenco indirizzi. Con sette voci, pero', aprire l'elenco a
selezione veloce e' piu' rapido dell'esportazione, e non produce un file con dati reali da
custodire.

Regola di decisione fissata prima di conoscere il numero, cosi' che il numero non venga
piegato alla soluzione preferita. Fino a **sei** destinatari distinti si procede con una
cartella condivisa per destinatario, che e' la strada senza impostazioni globali e senza
riscritture di permessi. Oltre sei, la lista delle condivisioni diventa illeggibile e conviene
la strada delle autorizzazioni per sottocartella, che a quel punto va pianificata come
intervento a se' fuori orario, con la durata dell'inizializzazione misurata su una prova, e
non piu' dentro questo registro.

#### Esito: sette destinatari, uno oltre la soglia, e la deviazione dichiarata

Il censimento chiuso da' **sette** destinatari distinti, cioe' uno oltre la soglia. Applicando
la regola alla lettera si dovrebbe passare alle autorizzazioni per sottocartella e rimandare
R8 a un intervento fuori orario. La regola pero' aveva una ragione dichiarata, non era un
numero magico: il costo delle cartelle condivise separate e' che la lista delle condivisioni
diventa illeggibile. Quel costo, su questo apparato, e' **eliminabile**: il NAS ha per ogni
cartella condivisa l'opzione che la nasconde dalla navigazione di rete, e una condivisione
nascosta resta raggiungibile per percorso diretto senza comparire nell'elenco che si vede
sfogliando il server. Sette condivisioni nascoste non allungano nessuna lista visibile agli
utenti, restano ordinate nel pannello di amministrazione, e ciascun destinatario raggiunge la
propria con un'unita' di rete mappata al percorso completo.

Decisione presa, con la deviazione dalla regola dichiarata invece che nascosta riscrivendo la
soglia a posteriori: **si procede con sette cartelle condivise nascoste**, una per
destinatario. Il beneficio e' che nessuna impostazione globale viene toccata, nessuna
riscrittura di permessi attraversa cinque milioni di oggetti, e l'intervento resta dentro la
regola di ammissione di questo registro. Il costo accettato e' che il modello non scala
elegantemente: alla decina di destinatari, o quando si voglia adottare i permessi per
sottocartella come standard del NAS, si passa all'altra strada come intervento pianificato
fuori orario. La soglia della regola resta a sei per il caso generale; qui e' stata superata
di uno con una mitigazione specifica e verificabile, non per comodita'.

Come leggere la rubrica dell'altra multifunzione. Il suo pannello di amministrazione non e'
interrogabile da riga di comando, per un motivo diverso ma con lo stesso esito della Kyocera:
la pagina di autenticazione cifra la password nel browser combinandola con un *challenge* di
sessione e una chiave pubblica RSA generata per quella pagina, quindi uno script dovrebbe
replicare quella cifratura. Restano due strade manuali, e la seconda e' molto piu' rapida
della prima. La prima e' aprire l'elenco degli indirizzi e guardare le voci una per una, come
fatto sull'altra macchina. La seconda e' usare la funzione di **esportazione della rubrica**
dell'apparato, che produce un file unico con tutte le voci: si trova nelle impostazioni di
gestione dei dati, alla voce di importazione ed esportazione, scegliendo l'elenco indirizzi.
Nell'esportazione va **esclusa** l'opzione che include le password, se presente, perche'
altrimenti il file contiene credenziali in chiaro; e il file, contenendo indirizzi e nomi
reali, resta materiale privato e non entra mai in un file tracciato di questo repository.

#### Procedura

Nell'ordine, e ogni passo verificabile prima del successivo.

1. Su NAS-INTRA2, creare **una cartella condivisa per destinatario** — sette secondo il
   censimento chiuso — spuntando per ciascuna l'opzione che la nasconde dalla navigazione di
   rete, senza attivare le autorizzazioni avanzate per cartella e senza concedere accesso
   generalizzato: i permessi si assegnano nel dialogo di creazione della condivisione, dove
   esistono nativamente. Se in futuro si decidera' di passare al modello per sottocartella,
   sara' un intervento separato da pianificare fuori orario, non un passaggio di R8.
2. Creare l'account di servizio della multifunzione, senza scadenza password e senza
   accesso interattivo ad altri servizi del NAS, e assegnargli la sola scrittura sulle
   sottocartelle.
3. Assegnare i permessi di ciascuna condivisione secondo la tabella sopra — il destinatario
   in lettura e scrittura, l'account di servizio in sola scrittura, nessun altro — e
   verificare l'isolamento **prima** di toccare la multifunzione, non dopo, perche' scoprire
   un permesso sbagliato quando i documenti sono gia' dentro significa aver esposto documenti
   veri.

   La verifica non richiede piu' postazioni: si fa tutta da una sola macchina, perche' quello
   che conta e' l'identita' con cui si apre la connessione e non il computer da cui si parte.
   Da una finestra di comando, la prova positiva e' montare la condivisione con le credenziali
   del proprio destinatario e riuscire a scrivere un file; la prova negativa, che e' quella
   che dimostra il requisito, e' tentare di montare la condivisione di un altro destinatario
   con le stesse credenziali e ricevere un rifiuto.

   ```powershell
   # Prova positiva: il destinatario accede alla propria condivisione
   net use X: \\<indirizzo-nas>\<condivisione-destinatario-1> /user:<utente-1>
   # Prova negativa attesa: accesso negato alla condivisione di un altro destinatario
   net use Y: \\<indirizzo-nas>\<condivisione-destinatario-2> /user:<utente-1>
   net use X: /delete ; net use Y: /delete
   ```

   Un dettaglio di Windows che fa perdere tempo se non lo si sa: verso lo stesso server non si
   possono tenere aperte contemporaneamente connessioni con identita' diverse, e il tentativo
   restituisce un errore di conflitto di sessione che sembra un problema di permessi e non lo
   e'. Prima di ogni prova con un'altra utenza va quindi chiusa la sessione precedente con
   `net use * /delete`, altrimenti si finisce per interpretare come "negato" un rifiuto che
   Windows produce da solo. Lo stesso vale per l'account di servizio, che va provato con la
   sua credenziale: deve riuscire a **scrivere** in ciascuna condivisione e, se il NAS lo
   consente, non riuscire a **leggerne** il contenuto.
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

#### La scelta del protocollo, e la premessa da verificare prima di scegliere

Sul tavolo, il 30/07/2026, sono arrivate due proposte alternative: portare le scansioni sul
NAS usando **FTP** invece di SMB, nel presupposto che le multifunzione parlino soltanto SMB
versione 1 e che quella versione non sia accettabile; oppure installare **un server FTP su
ciascuna postazione** e cambiare protocollo nelle rubriche, lasciando le destinazioni dove
sono. Vanno valutate separatamente, perche' la prima e' una scelta di protocollo dentro il
disegno giusto e la seconda e' un disegno diverso.

**La seconda proposta va scartata**, e le ragioni sono quattro e indipendenti. Non risolve il
problema che R8 esiste per risolvere, perche' i documenti continuerebbero a depositarsi sulle
postazioni: cambierebbe il protocollo del trasporto, non la destinazione dei dati. Aggiunge un
servizio in ascolto su ogni endpoint, cioe' allarga la superficie di attacco esattamente dove
si e' investito per ridurla, e su una LAN piatta quel servizio e' raggiungibile da tutti.
Moltiplica il lavoro di gestione per il numero di postazioni, con un server da installare,
aggiornare e configurare su ciascuna, e mantiene la dipendenza dal fatto che quel PC sia
accesso. E il protocollo in chiaro trasporterebbe credenziali e documenti in chiaro sulla rete.
Nessuno dei quattro punti dipende dalla versione di SMB: la proposta e' peggiore a
prescindere.

**La prima proposta ha il disegno giusto ma la premessa da verificare**, e la premessa e'
decisiva perche' se cade, cade anche la scelta di FTP. L'affermazione che gli apparati parlino
solo SMB versione 1 non e' ancora un fatto verificato, e ci sono due scenari possibili, entrambi
significativi. Se gli apparati parlano SMB 2 o superiore, allora si va sul NAS in SMB e la
questione FTP non si pone. Se davvero parlano solo SMB versione 1 e le scansioni verso le
postazioni funzionano, allora il fatto interessante non e' la multifunzione: e' che **SMB
versione 1 e' abilitato sulle postazioni**, cioe' un protocollo dismesso da anni e vettore di
famiglie di malware note e' attivo sugli endpoint aziendali. Sarebbe un gap piu' grave di
quello che stiamo chiudendo, e andrebbe registrato come tale.

Nota di correzione: una versione precedente di questo documento dava per risolto il dubbio
deducendolo dal fatto che le destinazioni sono condivisioni di postazioni Windows 11, dove SMB
versione 1 e' disabilitato per impostazione predefinita, quindi gli apparati dovevano
necessariamente parlare SMB 2 o superiore. La deduzione e' valida solo se su quelle postazioni
nessuno ha riattivato SMB versione 1, che in un parco cresciuto per stratificazioni non e'
scontato. Resta un'inferenza plausibile, non un fatto: va misurata.

##### Come si misura, in tre modi indipendenti

Il primo e' il piu' diretto e non richiede di toccare nulla: si fa una scansione di prova
verso una postazione e, subito dopo, su quella postazione si leggono le sessioni SMB aperte,
che riportano il dialetto negoziato dal client.

```powershell
# Sulla postazione che riceve la scansione, subito dopo l'invio
Get-SmbSession | Select-Object ClientComputerName, ClientUserName, Dialect, NumOpens
Get-SmbConnection | Select-Object ServerName, Dialect     # per le connessioni in uscita
# Stato del protocollo legacy sulla postazione
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol | Select-Object FeatureName, State
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol, EnableSMB2Protocol, RequireSecuritySignature
```

Il valore di `Dialect` chiude la questione: se e' `2.x` o `3.x` la premessa cade e si va in
SMB; se e' `1.x`, la premessa e' confermata e con essa il gap sulle postazioni.

Il secondo e' leggere le impostazioni di protocollo degli apparati stessi, dove entrambi i
modelli espongono la versione SMB del proprio client: sulla Kyocera nella pagina dei
protocolli di Command Center RX, sulla Canon nelle impostazioni di rete alla voce del client
SMB, dove tipicamente si impostano versione minima e massima. Se l'apparato consente di
alzare la versione minima, il problema si risolve configurandolo e non cambiando protocollo.

Il terzo e' lato NAS: nelle impostazioni della condivisione file di rete Microsoft si puo'
fissare la versione minima accettata. Alzandola a SMB 2 si ottengono due cose insieme, cioe'
la certezza che nessun client possa negoziare la versione legacy e una prova pratica
immediata, perche' un apparato che dopo quella modifica non riesce piu' a scrivere e' un
apparato che stava usando la versione legacy.

##### Prima misura, 30/07/2026: sulla postazione dell'IT Manager il protocollo legacy e' disattivato

Eseguiti i comandi sulla postazione dell'IT Manager, che e' anche una delle sette destinazioni
di scansione censite su entrambi gli apparati. Tre risultati.

Il protocollo legacy **non e' attivo**: la funzione opzionale di Windows risulta disabilitata e
la configurazione del servizio riporta il protocollo versione 1 disattivato e la versione 2
attiva. La sessione SMB osservata in quel momento negoziava **dialetto 3.1.1**, cioe' la
versione piu' recente, il che dimostra che su questa rete SMB 3 funziona senza problemi tra
Windows e Windows.

Da qui una deduzione che vale come prova, e non piu' come inferenza. Entrambe le multifunzione
hanno tra le proprie destinazioni una condivisione **su questa stessa postazione**. Se il
protocollo versione 1 e' disattivato su di essa, un apparato che parlasse solo quella versione
non riuscirebbe nemmeno a stabilire la connessione: quindi **se quelle due destinazioni
funzionano, gli apparati parlano necessariamente SMB 2 o superiore**, e la premessa che aveva
motivato la proposta FTP cade. La verifica residua e' percio' minima e non tecnica: basta una
scansione di prova da ciascun apparato verso quella postazione e osservare se il file arriva.
Per leggere anche il dialetto esatto negoziato dall'apparato, il comando sulle sessioni va
eseguito entro pochi secondi dall'invio, perche' queste macchine chiudono la sessione appena
finito il trasferimento.

Due osservazioni collaterali dallo stesso output. La firma SMB non e' richiesta sulla
postazione: e' un irrobustimento candidato, da valutare quando si sara' certi che tutti i
client parlano almeno SMB 2, perche' richiederla con un client legacy in giro romperebbe quel
client. La sessione osservata proveniva invece da un'altra postazione autenticandosi con un
account **locale** della postazione dell'IT Manager: chiarito subito dall'IT Manager che si
tratta di un accesso deliberato e noto, concesso a un collega verso un disco interno di quella
macchina. Non e' quindi un accesso opaco ma un accordo documentato, e resta annotato solo
perche' un account locale condiviso tra macchine e' il tipo di configurazione che, se non
scritta da nessuna parte, in due anni diventa inspiegabile: ora e' scritta.

##### Esito definitivo, 30/07/2026: entrambi gli apparati scrivono, premessa FTP decaduta

Eseguite le due scansioni di prova verso la cartella della postazione dell'IT Manager, dove
il protocollo legacy e' disattivato. La multifunzione del Piano Terra ha depositato il proprio
PDF; quella del Piano 1, comandata a distanza dallo strumento di controllo remoto del
produttore invece che dal display fisico, ha depositato il proprio nella stessa cartella. Il
secondo file e' un PDF vuoto perche' la prova e' stata fatta senza foglio, cosa che non
inficia il risultato: quello che si stava verificando e' la connessione, non l'immagine.

Conclusione: **entrambe le multifunzione parlano SMB 2 o superiore**, perche' nessun apparato
limitato al protocollo legacy potrebbe stabilire una connessione con un host che quel
protocollo ha disabilitato. La premessa che motivava la proposta FTP e' decaduta, la prima
opzione dell'ordine di preferenza e' percorribile, e le sette condivisioni del NAS si
configurano in SMB. Da qui deriva anche un'informazione operativa utile per il resto
dell'intervento: la multifunzione del Piano 1 e' pilotabile a distanza dal proprio strumento
di controllo remoto, quindi le prove di scansione dei passi successivi si possono fare dalla
postazione senza salire al piano.

##### Ordine di preferenza del protocollo, deciso a monte del risultato

Anche qui la regola si fissa prima di conoscere l'esito, per non adattarla al risultato. La
prima scelta e' **SMB 2 o 3 verso il NAS**, con la firma attiva e, se il NAS e gli apparati lo
consentono, la cifratura SMB 3: e' il protocollo che il NAS gestisce nativamente con permessi
per utente, ed e' quello che stiamo gia' usando per tutto il resto. La seconda scelta, se e
solo se un apparato non e' in grado di superare SMB versione 1, e' **FTP esplicito su TLS**
verso il servizio FTP del NAS, limitato a quell'apparato, con un account dedicato che non
serve nient'altro: cifra il trasporto e resta centralizzato. La terza, cioe' **FTP in chiaro**,
si adotta solo se le prime due sono impossibili, e in quel caso non e' una scelta ma un debito:
va registrata come gap con la stessa serieta' con cui e' stato registrato il portale servito in
chiaro, perche' significa far viaggiare documenti e credenziali in chiaro sulla LAN.

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
