# Nomi, zona e hosting di `intrawelt.com`: che cosa sono, chi li tiene, che cosa cambia con il sito nuovo

>  Serve a fissare i concetti che governano il passaggio del sito in produzione, perché sono gli stessi su cui si decidono la dismissione dell'hosting, il censimento dei certificati e la fase più rischiosa del piano. Il merito operativo resta in `runbook-primo-rilascio-sito.md` e `piano-produzione-sito-nuovo.md`; qui ci sono i concetti e i tre disegni dello stato attuale, di quello intermedio e di quello futuro. Gli indirizzi sono segnaposto, come prescrive la regola di anonimizzazione: i valori reali stanno nella mappa privata.
> 
> La stessa materia spiegata per immagini, con la sequenza di una richiesta e il significato di ogni nome della zona, sta in [`dns-domini-spiegato-semplice.html`](dns-domini-spiegato-semplice.html).
> 
> È scritta per essere letta da sola, da chi non ha seguito il lavoro. Tutto ciò che afferma sullo stato attuale è stato misurato il 26/10/2026 interrogando i server DNS del dominio e leggendo il pannello dell'hosting, e non ricavato da documentazione pregressa.

## Una correzione preliminare, perché il problema era il linguaggio

Nelle risposte in sessione sono stati usati termini tradotti in italiano che non esistono nell'uso tecnico, e che hanno reso incomprensibile un argomento già ostico. La tabella che segue li traduce nei nomi veri, che sono quelli che compaiono nei pannelli, nelle documentazioni e nelle risposte dei fornitori, e che vanno usati da qui in avanti.

| Termine usato impropriamente | Nome corretto                            | Che cosa è                                                                           |
| ---------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------ |
| scambiatore                  | record MX (mail exchanger)               | la riga della zona che dice a chi consegnare la posta del dominio                    |
| mittente autorizzato         | record SPF                               | la riga che elenca chi può spedire posta a nome del dominio                          |
| selettori della firma        | record DKIM                              | le righe che pubblicano le chiavi con cui la posta in uscita viene firmata           |
| politica di autenticazione   | record DMARC                             | la riga che dice ai destinatari che cosa fare se SPF o DKIM falliscono               |
| alias                        | record CNAME                             | una riga che non dà un indirizzo ma rimanda a un altro nome                          |
| tempo di validità            | TTL (time to live)                       | per quanto tempo gli altri possono tenersi in tasca la risposta prima di richiederla |
| server di nomi               | record NS, e le macchine che esso indica | le macchine incaricate di rispondere per quel dominio                                |

## I tre mestieri, che sono distinti anche quando li fa lo stesso fornitore

Dietro un sito raggiungibile a un nome ci sono tre mestieri diversi, e confonderli è la causa di quasi tutti gli incidenti di questa materia. Vale la pena nominarli una volta, perché poi tutto il resto discende da qui.

Il primo è la registrazione del nome. Qualcuno deve risultare intestatario di `intrawelt.com` presso gli organismi che governano i nomi, pagarne il rinnovo e dichiarare a chi è delegata la risposta. Quel qualcuno si chiama registrar, e per questo dominio è EuroDNS. Il registrar non ospita niente e non risponde a nessuna domanda sul nome: dice soltanto, in un registro pubblico, quali macchine sono incaricate di rispondere.

Il secondo è rispondere alle domande sul nome. Quando un browser vuole aprire `www.intrawelt.com` non sa dove andare: chiede. La domanda arriva, di passaggio in passaggio, alle macchine che il registrar ha dichiarato come incaricate, e sono loro a dare la risposta buona. Questo mestiere si chiama DNS autoritativo, e per questo dominio lo fa Fastnet con due macchine, `regulus.fastnet.it` e `rigel.fastnet.it`.

Il terzo è servire davvero le pagine. Una volta saputo l'indirizzo, il browser vi si collega e chiede la pagina: dall'altra parte c'è una macchina con un server web sopra. Questo mestiere si chiama hosting, e oggi lo fa Fastnet con la macchina del pannello Plesk.

Il punto che interessa questo progetto è che i tre mestieri si possono affidare a tre fornitori diversi, e che cambiarne uno non cambia gli altri. È la ragione per cui si può smettere di usare Fastnet come hosting continuando a usarlo come DNS.

## Che cos'è la zona, e perché è il documento che conta

La zona è la tabella del dominio: l'elenco completo di tutti i nomi che finiscono per `intrawelt.com` e di che cosa ciascuno indica. Non è un concetto astratto, è un file. Dentro ci sono righe come «`www` rimanda a `vserver`», «`vserver` sta all'indirizzo tale», «la posta di questo dominio va consegnata a Microsoft», «chi può spedire a nome di questo dominio è questo elenco».

Ogni riga si chiama record e ha un tipo, e i tipi che contano qui sono cinque. Un record `A` associa un nome a un indirizzo numerico, ed è la riga che fa esistere un sito a quel nome. Un record `CNAME` non dà un indirizzo ma rimanda a un altro nome, che a sua volta avrà un `A`: serve per non ripetere lo stesso indirizzo in dieci righe, perché cambiandolo in un posto solo cambiano tutte. Un record `MX` dice a chi consegnare la posta indirizzata a quel dominio, e si noti bene che vive nella stessa tabella del sito pur non avendo niente a che fare con il sito. I record `TXT` portano testo libero e vi si scrivono le regole della posta, cioè SPF e DMARC. I record `NS` dichiarano quali macchine rispondono per il dominio.

Da questo discende il fatto che governa tutta la parte rischiosa del piano: il sito e la posta non hanno niente in comune tranne che le istruzioni per raggiungerli stanno scritte nello stesso foglio. Toccare quel foglio per spostare il sito significa avere le mani dentro il foglio dove c'è anche la posta.

## Che cosa vuol dire autoritativo, e che cosa vuol dire che la zona vive lì

Quando qualcuno nel mondo chiede dove sta `www.intrawelt.com`, la domanda non arriva quasi mai fino a Fastnet: passa per un risolutore, tipicamente quello del provider di chi naviga oppure uno pubblico come quello di Google, che tiene in memoria le risposte ricevute di recente e le riusa. Quei risolutori però non sanno niente: hanno una copia. L'originale sta su `regulus` e `rigel`, che per questo si dicono autoritativi, cioè sono quelli che la risposta la conoscono invece di ricordarla.

Dire che la zona vive lì significa quindi due cose insieme. Che la tabella sta fisicamente su quelle macchine, e che solo chi le amministra può modificarla. In questo caso chi le amministra è Fastnet, e lo dice la zona stessa: il record che apre ogni zona, chiamato SOA, dichiara come macchina primaria `rigel.fastnet.it` e come contatto una casella di Fastnet, non di Intrawelt.

## Che cosa significa che il servizio DNS è gestito fuori dal pannello

Il pannello Plesk che hai davanti sa fare il server DNS: è un programma che, fra le altre cose, può tenere lui la zona di un dominio e rispondere alle domande. Per `intrawelt.com` non lo sta facendo, e questo è ciò che significava quell'espressione infelice: fuori dal pannello, cioè su macchine che non sono quella del pannello e che il pannello non amministra.

Si vede da due cose, ed entrambe compaiono nelle schermate del 26/10/2026. La pagina delle impostazioni DNS del dominio contiene due soli oggetti, che sono i due record `NS`, cioè l'indicazione di a chi è delegata la zona, e non contiene nessuna delle righe della zona vera. E il comando per aggiungere un record offre un solo tipo, ancora un server di nomi: non può offrire gli altri, perché una zona che non possiede non la può modificare.

La conseguenza pratica è che da quel pannello non si crea nessun record, e che ogni modifica alla zona è una richiesta a Fastnet.

## Il pulsante «Abilita», e perché non si tocca

Sulla stessa pagina c'è un comando che abilita il servizio DNS locale del pannello per quel dominio. Preso alla lettera fa una cosa sola: dice a Plesk di cominciare a tenere lui una zona per `intrawelt.com`. Il problema è come la costruisce. Plesk non conosce la zona vera, che sta altrove: ne genera una nuova dal proprio modello, cioè con i nomi del web che puntano alla macchina del pannello e con la posta che punta al servizio di posta del pannello.

Quella zona, finché il registrar delega a `regulus` e `rigel`, non la interroga nessuno, quindi oggi non succede niente. Ma resta lì, scritta, e somiglia abbastanza a quella vera da ingannare chi la guardasse dopo. Se un domani qualcuno, per qualunque ragione, delegasse il dominio alla macchina del pannello, il mondo comincerebbe a ricevere una zona senza i record `MX`, `SPF`, `DKIM` e `DMARC` di Microsoft 365, e la posta aziendale smetterebbe di arrivare. Non si tocca, perché non serve a niente qui e perché predispone un errore futuro.

## Com'è adesso

```
                  REGISTRAR: EuroDNS
                  intestatario del nome, dichiara a chi e' delegato
                              |
                              |  delega il dominio a
                              v
   +---------------------------------------------------------------+
   |  DNS AUTORITATIVO: regulus.fastnet.it e rigel.fastnet.it       |
   |  (macchine di Fastnet, amministrate da Fastnet)                |
   |                                                                |
   |  qui vive LA ZONA, cioe' la tabella del dominio:               |
   |     www                CNAME  vserver.intrawelt.com            |
   |     vserver            A      198.51.100.35                    |
   |     prodotto-1             A      198.51.100.35                    |
   |     @                  MX     ...mail.protection.outlook.com   |
   |     @                  TXT    SPF                              |
   |     _dmarc             TXT    DMARC                            |
   |     selector1/2        CNAME  DKIM di Microsoft                |
   |                                                                |
   |  TTL predefinito dichiarato dalla zona: 86400 secondi (1 g.)   |
   +----------------+--------------------------------+--------------+
                    |                                |
   il browser segue |                                | la posta segue
   le righe del web |                                | le righe della posta
                    v                                v
   +-------------------------------+   +-------------------------------+
   |  HOSTING: 198.51.100.35       |   |  POSTA: Microsoft 365         |
   |  macchina Fastnet con Plesk   |   |  riceve e conserva la posta   |
   |  serve il sito attuale        |   |  di @intrawelt.com            |
   |  e prodotto-1.intrawelt.com       |   |  Fastnet non la vede mai      |
   +-------------------------------+   +-------------------------------+

   MODIFICHE ALLA ZONA: solo Fastnet. Intrawelt apre un ticket.
```

Due cose si leggono da sole in questo disegno, ed entrambe erano state dette male prima. La posta non è a Fastnet: Fastnet tiene soltanto il foglio su cui è scritto dove la posta va consegnata. E il sito attuale invece è davvero a Fastnet, perché il nome con `www` rimanda, con un record `CNAME`, al nome `vserver.intrawelt.com`, il quale a sua volta ha un record `A` che porta all'indirizzo della macchina del pannello. Due passaggi invece di uno, ed è una forma normale: cambiando l'indirizzo in quella riga sola si sposta tutto ciò che vi rimanda.

## Com'è adesso, con l'anteprima del sito nuovo

Il primo passo non sposta niente: aggiunge una riga. Si chiede a Fastnet un record `A` per un nome nuovo, `anteprima.intrawelt.com`, che porta alla VPS. Il sito attuale, la posta e tutto il resto restano esattamente dove sono, perché nessuna delle righe esistenti viene toccata.

```
   ZONA (presso Fastnet), con una riga in piu':
     www        CNAME  vserver  ->  198.51.100.35   (sito attuale, invariato)
     @          MX     Microsoft 365                (posta, invariata)
     anteprima  A      192.0.2.10                   <-- RIGA NUOVA
                                      |
                                      v
   +-----------------------------------------------------------+
   |  VPS 192.0.2.10 (Aruba)                                   |
   |                                                           |
   |   Caddy (proxy inverso)  :80 :443                         |
   |     - ammette solo la provenienza 203.0.113.5 (la sede)   |
   |     - lascia aperta la verifica del certificato           |
   |              |                                            |
   |              v                                            |
   |   applicazione Next.js + Payload   (non pubblica porte)   |
   |              |                                            |
   |              v                                            |
   |   banca dati PostgreSQL            (solo loopback)        |
   +-----------------------------------------------------------+
```

## Come sarà dopo il passaggio, nella via a rischio minore

La via a rischio minore consiste nel cambiare i soli record del web e lasciare la zona dov'è. Si modificano le righe del dominio senza prefisso e di `vserver`, a cui `www` rimanda, facendole puntare alla VPS. Aggiornamento del 29/10/2026: lo stesso vale per `prodotto-1` e, nella zona del dominio secondario `intrawelt.it`, per il suo vertice e il suo `vserver`. I rimandi verso il dominio principale li fa il proxy della VPS, e il sottodominio del prodotto resta e rimanda al sito del prodotto. Tutte le righe della posta restano intatte perché nessuno le apre. L'hosting di Fastnet si dismette solo a sito stabile, perché fino ad allora è la via del ritorno indietro; Fastnet continua comunque a fare il DNS.

```
                  REGISTRAR: EuroDNS            (invariato)
                              |
                              v
   +---------------------------------------------------------------+
   |  DNS AUTORITATIVO: regulus e rigel, presso Fastnet (invariato) |
   |                                                                |
   |     www                CNAME  vserver                          |
   |     vserver            A      192.0.2.10        <-- CAMBIATA   |
   |     @                  A      192.0.2.10        <-- CAMBIATA   |
   |     prodotto-1         A      192.0.2.10        <-- CAMBIATA   |
   |     anteprima          A      192.0.2.10        (poi si toglie)|
   |     @                  MX     Microsoft 365     (NON TOCCATA)  |
   |     @                  TXT    SPF               (NON TOCCATA)  |
   |     _dmarc             TXT    DMARC             (NON TOCCATA)  |
   |     selector1/2        CNAME  DKIM              (NON TOCCATA)  |
   +----------------+--------------------------------+--------------+
                    |                                |
                    v                                v
   +-------------------------------+   +-------------------------------+
   |  VPS 192.0.2.10 (Aruba)       |   |  POSTA: Microsoft 365         |
   |  Caddy, senza restrizione     |   |  invariata, perche' le sue    |
   |  applicazione, banca dati     |   |  righe non sono state aperte  |
   |  certificato automatico       |   +-------------------------------+
   +-------------------------------+
                    ^
                    |
   +-------------------------------+
   |  HOSTING Fastnet: DISMESSO    |
   |  il DNS resta a Fastnet       |
   +-------------------------------+
```

## Il TTL, cioè perché un errore può durare un giorno

Ogni risposta del DNS viaggia con un numero che dice per quanto tempo chi la riceve può tenersela e riusarla senza richiederla. È il TTL, e la zona di `intrawelt.com` ne dichiara uno predefinito di 86400 secondi, cioè ventiquattro ore.

La conseguenza non riguarda il momento in cui si fa la modifica, ma quello in cui ci si accorge di aver sbagliato. Se al passaggio si cambia l'indirizzo del sito e qualcosa non funziona, rimettere la riga com'era non riporta indietro il mondo: i risolutori che avevano già preso la risposta nuova se la tengono fino a scadenza, e per un giorno intero una parte dei visitatori continuerà ad andare dove non deve. Per questo il TTL si abbassa a pochi minuti qualche giorno prima del passaggio e si rialza dopo, quando si è visto che tutto regge. È una manovra banale e va chiesta in anticipo, perché abbassarlo nel momento del bisogno non serve: a quel punto le copie vecchie sono già in giro con la durata vecchia.

## Le tre conseguenze operative della scelta di restare con Fastnet per il DNS

La prima è la dipendenza: finché la zona sta lì, ogni modifica è una richiesta a loro, compreso il ritorno indietro durante il passaggio, che è il momento in cui si vorrebbe poter agire in proprio. Non è un motivo per cambiare adesso, ed è un motivo per cambiare poi: spostare la zona è a sua volta l'operazione rischiosa, e sommare due rischi nello stesso giorno è il modo tipico di non capire più quale dei due ha causato il guasto. La sequenza sensata è fare il passaggio del sito con la zona ferma dov'è, e valutare lo spostamento del DNS dopo, a sito stabile, come intervento a sé, scegliendo un gestore dove Intrawelt possa modificare i record da sola.

La seconda è il tempo di validità appena descritto, che in questa configurazione non si governa da soli e va concordato.

La terza è che questa scelta esclude, finché dura, l'opzione del fornitore di protezione davanti al sito, che è la decisione D1 della roadmap. Quel tipo di servizio non si limita a stare davanti a un nome: diventa lui il DNS autoritativo dell'intero dominio, perché per fare il proprio mestiere deve vedere e governare tutte le righe. Sceglierlo significa quindi spostare la zona, cioè proprio ciò che questa via evita. Le due cose non sono in contraddizione nel tempo: si fa il passaggio adesso senza protezione e con la zona ferma, e se in seguito si deciderà per quel servizio, lo spostamento della zona si farà allora, con la sua preparazione e la sua finestra.

## Che cosa ne discende per il resto del progetto

Il censimento dei certificati, già previsto dalla roadmap, eredita da qui il proprio perimetro: un certificato esiste sempre per un nome, e i nomi sono le righe di questa zona più quelli interni che non vi compaiono. Il certificato del sito attuale è emesso e rinnovato dall'hosting; quello del sito nuovo sarà ottenuto e rinnovato automaticamente dal proxy sulla VPS, a condizione che il nome punti alla macchina e che la porta in chiaro resti raggiungibile; i certificati interni della LAN non dipendono da questa zona e hanno un'autorità propria. La dismissione dell'hosting toglie quindi anche chi oggi rinnova il certificato pubblico, ed è una delle cose da non scoprire dopo.
