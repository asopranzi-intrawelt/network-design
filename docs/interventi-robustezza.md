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

Procedura, nell'ordine: creare sul NAS una condivisione dedicata alle scansioni, con una
sottocartella per destinatario se si vuole mantenere la separazione a cui gli utenti sono
abituati; creare un account di servizio dedicato alla scrittura su quella share (vedi R9);
sull'apparato, riconfigurare ciascuna voce della rubrica in modo che l'host di destinazione
sia il NAS e il percorso la nuova cartella, usando l'indirizzo e non un nome, perche'
l'apparato non ha alcun server DNS configurato; provare ciascuna voce con il pulsante di
prova connessione; comunicare agli utenti dove trovano da ora le scansioni. Verifica:
scansione reale da display verso ciascuna destinazione, con il file che compare nella
cartella attesa sul NAS. Rollback: le voci precedenti vanno annotate prima della modifica,
e ripristinarle e' una riscrittura di due campi per voce.

### R9 — Account di servizio invece di account nominali

Almeno una delle destinazioni di scansione usa come utenza di accesso il nome e cognome di
una persona. Un'utenza nominale usata da un apparato ha tre difetti: il log della share non
distingue piu' l'attivita' della persona da quella della macchina, la credenziale resta
memorizzata in un dispositivo che quella persona non controlla, e alla sua uscita
dall'azienda la disattivazione dell'account rompe silenziosamente la scansione. Un account
di servizio dedicato, con permesso di scrittura solo sulla share di scansione, risolve
tutti e tre. Va eseguito insieme a R8, perche' e' la stessa configurazione.

## Come si aggiorna questo registro

Ogni intervento chiuso passa a stato `Fatto` con la data, e lo stesso fatto va riportato
nella voce di timeline della giornata e, se tocca un controllo Annex A, nella scheda
`design-and-security.md`. Se un intervento si rivela piu' invasivo di quanto sembrava,
non si forza: si sposta nella roadmap come micro-step con la sua finestra, e in questo
registro resta la riga con la nota del perche' e' stato promosso. La disciplina di
ammissione e' l'unica cosa che tiene utile un registro come questo.
