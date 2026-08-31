# Come il server HP ProLiant Gen10 e' attaccato alla rete

> Scheda aperta il 25/08/2026, a valle delle misure del 24/08 che hanno chiuso il difetto #153 e aperto il #157, e aggiornata in giornata con la conferma LLDP del 25/08 e con il disegno dell'intervento sulla DMZ. Risponde a una domanda sola, posta dall'IT Manager: in che modo l'unico server fisico dell'azienda e' collegato alla rete, dal cavo nell'armadio fino alla scheda della singola macchina virtuale. E' scritta con fondamento didattico secondo la direttiva permanente dei cinque livelli (`.claude/context/current-work.md`): ogni concetto viene spiegato prima di essere usato, perche' una scheda che dia per scontato che cosa sia un bridge o che cosa significhi VLAN-aware si legge solo da chi gia' lo sa, e chi gia' lo sa non ha bisogno della scheda.
>
> Convenzione. Modelli, nomi di apparato e numeri di porta sono reali, perche' servono a operare. Indirizzi IP e MAC seguono i segnaposto di `.claude/rules/anonymization.md`; la traduzione vive in `_notes/.anonymization-map.md`. La fonte strutturata di tutto cio' che segue e' `data/network-topology.json` alla revisione 6 del 24/08/2026, corroborata da `data/port-matrix.json` e dagli snapshot Proxmox e Nebula in `output/`, non versionati.

## Il quadro in una pagina

Il server e' uno solo, e' un HP ProLiant Gen10 nell'armadio di destra del CED al secondo piano, esegue Proxmox VE e sopra di esso vivono le undici macchine virtuali dell'azienda. Dal telaio escono cinque cavi di rete: quattro portano il traffico delle macchine virtuali e dell'hypervisor, il quinto porta la gestione fuori banda. Quattro dei cinque terminano sullo switch gestito XGS2220-54HP; uno solo, ed e' il piu' importante dei cinque, termina su uno switch che non e' gestito.

| Presa sul telaio | Nome nel sistema operativo | Bridge | Dove termina | Misura sulla porta, 24/08/2026 |
|---|---|---|---|---|
| eth2 | eno2 | `vmbr1` | XGS2220-54HP, porta 7 | 1 Gb/s, 1 stazione, PVID 1 |
| eth3 | eno3 | `vmbr2` | XGS2220-54HP, porta 9 | 1 Gb/s, 3 stazioni, PVID 1 (misura del 24/08, precedente alla dismissione della VM 206) |
| eth4 | eno4 | `vmbr3` | XGS2220-54HP, porta 11 | 1 Gb/s, 3 stazioni, PVID 1 |
| eth1 | eno1 | `vmbr0` | QNAP QSW-1208-8c, non gestito | il ramo rientra nel 54HP dalla fibra 52: 10 Gb/s, 9 stazioni, trunk |
| iLO | scheda di gestione indipendente | — | XGS2220-54HP, porta 22 | 1 Gb/s, 1 stazione, PVID 1 |

Esiste un estratto grafico locale di questa tabella, `_notes/estratto-gen10.html`, generato da `_notes/estrai-gen10.py` a partire dalle stesse due fonti: mostra il ramo intero, dal firewall alle singole macchine virtuali, e si rigenera con un comando. Non e' tracciato, perche' e' un derivato di comodo e non una fonte; l'artefatto ufficiale resta la mappa `docs/network-map.html`, dove lo stesso ramo si apre isolato con il frammento `#isola=srv-gen10`.

## Che cos'e' un bridge, e perche' qui ce ne sono quattro

Un *bridge*[^bridge] Linux e' uno switch di rete realizzato in software dentro il sistema operativo. Fa esattamente quello che fa uno switch di metallo: riceve trame da una porta, guarda l'indirizzo fisico del destinatario, e le manda fuori dalla porta giusta invece che da tutte. La differenza e' che le sue porte non sono prese RJ45 ma oggetti software: da un lato ci si attaccano le schede di rete virtuali delle macchine, dall'altro una scheda di rete fisica del server, che fa da uscita verso il mondo.

Su questo host i bridge sono quattro e ciascuno contiene una sola scheda fisica: `vmbr0` contiene eno1, `vmbr1` contiene eno2, `vmbr2` contiene eno3, `vmbr3` contiene eno4. Le macchine virtuali sono distribuite fra i quattro, ed e' una distribuzione fatta a mano nel tempo, non il risultato di un criterio scritto da qualche parte.

| Bridge | Scheda fisica | Porta dello switch | Indirizzo sull'host | Macchine attestate |
|---|---|---|---|---|
| `vmbr0` | eno1 | 52, attraverso il QNAP non gestito | si, `10.61.20.11/19` | VM 100 prima scheda, VM 202, VM 208, VM 810 |
| `vmbr1` | eno2 | 7 | no | VM 100 seconda scheda, e nient'altro |
| `vmbr2` | eno3 | 9 | no | VM 209; vi era anche la VM 206, dismessa il 31/08/2026 |
| `vmbr3` | eno4 | 11 | no | VM 203 spenta, VM 204, VM 205, VM 207, VM 602 |

## L'indirizzo dell'hypervisor, e i tre bridge senza indirizzo

Un bridge puo' lavorare in due modi, ed e' la stessa distinzione che vale per uno switch di metallo. Puo' essere soltanto uno switch, e allora smista trame fra le sue porte e non ha nessuna identita' propria in rete. Oppure gli si assegna un indirizzo IP, e allora diventa anche l'interfaccia attraverso la quale la macchina che lo ospita parla in rete, esattamente come uno switch gestito che ha un proprio indirizzo di amministrazione.

Su questo server tre bridge sono nel primo caso e uno solo nel secondo. Su `vmbr0` sono configurati l'indirizzo `10.61.20.11/19` e il gateway `10.61.20.1`, e quello e' l'indirizzo dell'hypervisor: e' dove risponde l'interfaccia web di Proxmox, dove si arriva in SSH, dove risponde l'API REST che gli script di questo progetto interrogano. Gli altri tre non hanno nessun indirizzo configurato, e nel resto di questa scheda sono chiamati bridge nudi: esistono solo per far uscire il traffico delle macchine virtuali, e l'host su quei tre cavi non ha una propria identita' IP.

Ne discende una conseguenza operativa che vale la pena isolare, perche' e' la ragione per cui un passo del piano DMZ e' scritto come e' scritto. Riconfigurare `vmbr0` significa modificare la rete sotto i piedi della sessione con cui la si sta modificando: se il comando e' sbagliato la sessione cade e non torna, e il server resta raggiungibile solo fisicamente. Riconfigurare uno dei tre bridge nudi non ha quel rischio, perche' la sessione di amministrazione non passa di li'.

## In banda e fuori banda: l'iLO non e' un quinto cavo di rete come gli altri

Le vie per raggiungere il server sono due, e sono di natura diversa. La prima e' `10.61.20.11` su `vmbr0`, ed e' una via *in banda*: passa dalla stessa rete di tutto il resto e funziona se e solo se il sistema operativo dell'host e' acceso, ha caricato la configurazione di rete e non e' bloccato. La seconda e' l'*iLO*[^ilo], che e' un piccolo computer indipendente dentro il server, con la propria scheda di rete, il proprio indirizzo e la propria alimentazione: e' una via *fuori banda*, funziona anche a sistema operativo spento o congelato, e da' la console come se si fosse fisicamente davanti a un monitor collegato al server.

La distinzione non e' accademica. Il micro-step M5 prescrive di applicare `ifreload -a` dalla console iLO e non da SSH proprio per questo: e' l'unico modo di toccare la configurazione di rete dell'host senza dipendere dalla configurazione di rete che si sta toccando.

Sul piano della sicurezza l'iLO merita una riga a se'. Sta sulla porta 22 del 54HP, con PVID 1 e tutte le VLAN ammesse, cioe' nello stesso dominio di broadcast di ogni postazione, telefono e stampante dell'azienda. Una console che accende, spegne e reinstalla il server, e che vede lo schermo dell'hypervisor, e' raggiungibile in teoria da qualunque host della LAN piatta. E' l'adiacenza che una segmentazione dovrebbe eliminare per prima, e oggi nessun documento del progetto la descrive come un segmento di gestione, perche' non lo e'.

## Che cosa sono le stazioni contate su una porta

Nelle tabelle di questa scheda e nella matrice `data/port-matrix.json` compare per ogni porta un numero di stazioni. E' il numero di indirizzi fisici distinti che lo switch ha imparato su quella porta.

Il meccanismo e' quello con cui uno switch funziona da sempre, ed e' utile richiamarlo perche' spiega sia il numero sia il suo limite. Uno switch impara guardando il mittente: ogni volta che da una porta entra una trama, legge l'indirizzo *MAC*[^mac] di chi l'ha spedita e scrive in una tabella, chiamata tabella MAC o *forwarding database*, che quell'apparato si raggiunge da quella porta. Da quel momento le trame dirette a lui non vengono piu' diffuse su tutte le porte ma mandate solo su quella. Il numero di stazioni e' semplicemente quante righe di quella tabella puntano a quella porta.

Ne discende come si legge il dato. La porta 7 vede una stazione sola, coerente con il fatto che su `vmbr1` c'e' una sola scheda di macchina virtuale. Le porte 9 e 11 ne vedono tre ciascuna, coerente con le macchine accese su quei bridge. La porta 52 ne vede nove perche' di la' non c'e' un apparato ma un intero ramo, con i due NAS, le sei postazioni a 10 Gbps e il server. Una porta con collegamento attivo e zero stazioni e' invece il caso interessante al contrario, cioe' un cavo che ha negoziato e su cui nessuno ha mai parlato: e' la firma delle nove porte anomale del difetto #156, che vanno verificate in armadio.

Due limiti del dato vanno dichiarati. Il primo e' che la tabella MAC invecchia da sola: una voce non rinfrescata viene dimenticata dopo pochi minuti, quindi il numero fotografa chi ha parlato di recente e non chi esiste. Il secondo e' di perimetro documentale: `scripts/Export-PortMatrix.py` esporta il conteggio e le VLAN viste, mai gli indirizzi, perche' il conteggio risponde alle due domande operative — questa porta e' viva, il traffico passa nella VLAN attesa — senza pubblicare identificatori di apparati reali in un repository pubblico.

## Corrispondenza uno a uno, e l'assenza di aggregazione

Ogni bridge contiene una sola scheda fisica e nessuna scheda e' condivisa fra due bridge: e' questo che si intende dicendo che la corrispondenza e' uno a uno. Non esiste nessun *bond*[^bond], cioe' nessuna aggregazione di piu' schede in un'unica interfaccia logica.

Alla domanda su come dovrebbe essere non esiste una risposta unica, ma esistono tre impianti sensati, e conoscerli serve a capire perche' quello attuale non e' nessuno dei tre.

Il primo e' l'impianto moderno di riferimento: le quattro schede si aggregano in un unico bond, tipicamente con *LACP*[^lacp] concordato con lo switch, sopra il bond si mette un solo bridge VLAN-aware, e la porta dello switch diventa un trunk. Si ottengono insieme la banda sommata, il subentro automatico se un cavo o una scheda cadono, e la separazione per VLAN decisa macchina per macchina invece che cavo per cavo.

Il secondo e' l'impianto a bridge separati fatto per davvero: quattro bridge su quattro cavi, ma ogni cavo attestato su una porta dello switch configurata in una VLAN diversa. Qui la separazione e' fisica anziche' logica, e' rigida perche' spostare una macchina di segmento significa spostarla di bridge, ma e' separazione vera e in certi contesti e' la scelta corretta proprio perche' non dipende da una configurazione che qualcuno puo' cambiare per sbaglio.

Il terzo e' la via di mezzo diffusa negli ambienti piccoli: un cavo dedicato alla gestione, tenuto semplice e separato, e un bond con bridge VLAN-aware per tutto il traffico delle macchine virtuali.

Quello che c'e' oggi non e' nessuno dei tre. Ci sono quattro bridge separati su quattro cavi, ma tutte e quattro le porte dello switch sono in accesso con PVID 1, cioe' nella stessa identica VLAN, e nessuna macchina virtuale porta un tag. Il risultato e' quattro tratte fisiche parallele fra le stesse due entita', che sommano banda soltanto per come le macchine sono state distribuite a mano, e che non aumentano la separazione di un bit. E' il difetto #152 (NET-022), e la sua seconda meta' e' che senza bond non esiste nessun subentro: se si stacca il cavo di eno3, la VM 206 e la VM 209 restano isolate e non passano da sole sugli altri tre cavi, che pure sono li', accesi e nella stessa rete.

Il caso che lo dimostra e' documentale prima che tecnico. Alla creazione, il 12/08/2026, la VM 209 ha preso via DHCP un indirizzo della fascia `.10` invece che della `.20`, e la spiegazione non e' un errore di configurazione: con maschera `/19` le due fasce sono la stessa rete servita da piu' ambiti, e la macchina ha semplicemente risposto al primo che ha parlato.

## Che cosa significa VLAN-aware, e perche' oggi la DMZ non passerebbe

Un bridge Linux ordinario non capisce le VLAN. Le trame che portano un tag *802.1Q*[^dot1q] le lascia passare cosi' come sono, come farebbe un tubo, ma non sa distinguerle e soprattutto non puo' decidere lui che una certa macchina virtuale appartenga alla VLAN 201: il tag, se c'e', deve averlo messo qualcun altro, tipicamente il sistema operativo dentro la macchina.

Attivando il flag VLAN-aware il bridge diventa uno switch che i tag li capisce davvero. A quel punto si assegna un numero di VLAN a ciascuna interfaccia di macchina virtuale, il bridge aggiunge e toglie il tag per conto proprio, e il cavo verso lo switch fisico diventa un trunk che porta piu' segmenti sullo stesso rame. La strada alternativa, su Proxmox altrettanto praticata, e' non attivare il flag e creare invece una sotto-interfaccia per VLAN, per esempio `eno2.201`, mettendoci sopra un bridge dedicato: una VLAN per bridge invece di tutte dentro uno.

Oggi nessuna delle due strade e' imboccata. Nessuno dei quattro bridge e' VLAN-aware, nessuna sotto-interfaccia esiste, e *STP*[^stp] e' spento su tutti e quattro. Manca anche il presupposto dall'altro capo del cavo: le quattro porte del server sullo switch sono in accesso con PVID 1, quindi anche se una macchina virtuale apponesse un tag di propria iniziativa lo switch non lo rispetterebbe.

Messe insieme le due mancanze si capisce la frase che altrimenti suonerebbe come uno slogan: i quattro bridge hanno l'aspetto di una segregazione e non lo sono. Sembrano quattro compartimenti stagni, e sono quattro tubi paralleli che sbucano tutti nella stessa stanza.

## Come si e' stabilita la corrispondenza fra bridge, prese e porte

Il problema di partenza e' che sullo stesso server convivono tre numerazioni che nessuno aveva mai confrontato. Il sistema operativo chiama le schede eno1, eno2, eno3, eno4. La mappa fisica degli armadi le chiama eth1, eth2, eth3, eth4. Lo switch conosce solo numeri di porta. Nessuno garantisce che eno1 sia eth1, e non e' pignoleria: l'ordine con cui il sistema operativo enumera le schede dipende dall'ordine del bus PCI e non da come le prese sono stampate sul telaio, quindi coincide spesso ma non sempre. Era il difetto #153 (NET-023) ed era bloccante per il micro-step M4, che prescrive di configurare in trunk la porta verso Proxmox senza poter dire quale sia.

L'unico identificatore visibile da entrambe le parti e' l'indirizzo fisico. Sull'host si leggono con `ip -br link`, sullo switch si leggono nelle tabelle MAC dello snapshot Nebula, e il metodo consiste nel cercare lo stesso valore nei due elenchi. Il 24/08/2026 il metodo ha funzionato, ma non allo stesso modo per tutte e quattro le schede, e la differenza e' esattamente quella fra misurare e dedurre.

| Bridge | Che cosa si e' trovato | Natura della conclusione |
|---|---|---|
| `vmbr0` / eno1 | l'indirizzo della scheda dell'host compare nella tabella della porta 52 | diretta: lo switch ha visto proprio quella scheda su quella porta |
| `vmbr2` / eno3 | l'indirizzo della scheda dell'host compare nella tabella della porta 9 | diretta, per la stessa ragione |
| `vmbr3` / eno4 | la scheda non compare; compaiono sulla porta 11 gli indirizzi delle macchine attestate sul bridge | indiretta, ma corroborata da piu' macchine |
| `vmbr1` / eno2 | **confermata il 25/08/2026 da LLDP**: e' lo switch stesso ad annunciare nome e numero di porta sul cavo | diretta e dichiarata dall'apparato, la piu' forte delle quattro |

Il motivo per cui due schede su quattro non compaiono non e' un'anomalia ed e' bene capirlo, perche' e' lo stesso meccanismo delle stazioni visto dall'altro lato. Uno switch impara un indirizzo solo se vede una trama partire da quell'indirizzo. La scheda eno2 ha un proprio indirizzo fisico come ogni scheda, ma l'host non ha nessun IP su `vmbr1`, quindi non ha mai niente da dire su quel cavo, quindi non spedisce mai nulla in proprio, quindi lo switch non impara mai quell'indirizzo. Cio' che impara sono gli indirizzi delle macchine virtuali, perche' un bridge inoltra le loro trame senza riscriverne il mittente: e' la differenza fra un bridge e un router, il primo trasparente e il secondo no. Guardando la porta 7 dello switch, quindi, non si vede il server: si vede la macchina virtuale che gli sta dietro.

Le prime due righe della tabella sono percio' una misura, le altre due un ragionamento corretto ma di secondo grado, del tipo "su quel bridge c'e' solo questa macchina, quella macchina si vede sulla porta 7, dunque il bridge esce dalla porta 7". Il ragionamento regge se e solo se la premessa e' completa. Su `vmbr3` poggia su tre macchine e un errore singolo non lo ribalta; su `vmbr1` poggia su una sola e un errore singolo lo ribalta tutto.

Il guaio era che `vmbr1` e' proprio il bridge candidato per la DMZ, cioe' quello su cui si sarebbe andati a scrivere il piano. La conferma diretta e' arrivata il 25/08/2026 ed e' descritta nella sezione che segue.

```
lldpcli show neighbors ports eno2
```

*LLDP*[^lldp] risolve il problema alla radice invece di aggirarlo: fa in modo che sia lo switch a presentarsi sul cavo, dichiarando il proprio nome e il proprio numero di porta, quindi non resta piu' niente da dedurre.

### La conferma, ottenuta il 25/08/2026

Sull'host `lldpd` non era installato, e la scelta e' stata di installarlo invece di aggirare il problema una volta sola. Il ragionamento e' che il pacchetto e' piccolo, non tocca la configurazione di rete e non richiede riavvii, mentre il beneficio dura: da quel momento tutte e quattro le schede del server si identificano da sole, e l'ambiguita' fra le tre numerazioni non puo' piu' ripresentarsi, ne' per questo progetto ne' per chi verra' dopo. L'installazione ha portato con se' quattro dipendenze di sistema, `libsensors-config`, `libsensors5`, `libsnmp-base` e `libsnmp40`, e ha registrato il servizio all'avvio.

La risposta al comando dice tre cose, e la prima e' quella che serviva.

Primo, il numero di porta: `PortID: local 7`, con descrizione `Port7`. La corrispondenza `vmbr1` con la porta 7 del 54HP non e' piu' dedotta da un indirizzo, e' dichiarata dall'apparato che sta dall'altro capo del cavo. Il difetto #153 e' chiuso in tutte e quattro le righe, e il prerequisito bloccante di M4 non esiste piu'.

Secondo, l'identita' del vicino: nome di sistema "Switch piano 2 (rack)", identificativo di telaio `AA:BB:CC:00:00:01`, modello XGS2220-54HP codificato nelle estensioni proprietarie del vendor. Coincide con cio' che la mappa gia' affermava, quindi e' anche una verifica indipendente della fonte.

Terzo, due informazioni che nessuno stava cercando e che vale la pena registrare invece di lasciarle passare. L'indirizzo di gestione annunciato dallo switch e' `10.61.10.203`, cioe' nella classe delle postazioni e non in un segmento di gestione, il che conferma dal lato dell'apparato quanto la scheda del firewall diceva dal lato della configurazione. E la versione di firmware annunciata e' `V4.80(ABXQ.2)` datata `08/07/2023`: sullo switch centrale della rete, e' una versione di piu' di due anni fa, tracciata come difetto #158.

## Che problema stiamo risolvendo, prima del come

Le sezioni che seguono descrivono un intervento, e un intervento si giudica dal problema che chiude. Vale quindi la pena scrivere il problema per intero, perche' resti leggibile anche fra un anno a chi non era nella stanza.

Oggi ogni macchina virtuale del server sta sulla stessa rete di ogni postazione, telefono e stampante dell'azienda: un solo dominio di broadcast, la LAN piatta con maschera `/19`. Ne discende che qualunque host della rete puo' bussare a qualunque porta di qualunque macchina virtuale, e l'unica difesa e' quella che ciascun servizio si porta dietro da solo. Non e' un'ipotesi: e' gia' successo tre volte, e sono tre difetti aperti. Il portale asset della VM 208 pubblica sulle porte 80 e 443 verso l'intero dominio di broadcast (#121). Il pannello di amministrazione del CMS di staging sulla VM 209 risponde a chiunque, con la sola autenticazione applicativa a difenderlo (#155). E la stessa cosa accadra' con il prossimo servizio interno che verra' acceso, perche' non c'e' niente nell'architettura che lo impedisca.

Una *DMZ*[^dmz] e' la risposta consolidata a questo problema, ed e' bene dire con precisione in che cosa consiste, perche' il nome evoca piu' di quello che e'. Non e' un apparato e non e' un cavo diverso: e' una rete separata, con un proprio intervallo di indirizzi, dove si collocano i servizi che devono essere raggiungibili, e la cui separazione consiste nel fatto che il traffico fra quella rete e la LAN e' obbligato a passare da un apparato che decide che cosa puo' passare, cioe' il firewall. Il beneficio non e' rendere i servizi irraggiungibili, che sarebbe l'opposto del loro scopo, ma fare in modo che chi compromette un servizio pubblicato non si trovi automaticamente dentro la rete dove stanno i file, i NAS e le postazioni.

Il collegamento con i bridge, che e' il punto in cui questa scheda e il piano DMZ si toccano, e' il seguente. Perche' una macchina virtuale stia nella DMZ, il suo traffico deve arrivare allo switch marchiato come appartenente alla VLAN 201 anziche' alla VLAN 1. Il marchio e' l'etichetta *802.1Q*[^dot1q] di quattro byte aggiunta a ogni trama, e qualcuno la deve apporre materialmente. Oggi non la appone nessuno: non i bridge, che come si e' visto non sanno che cosa sia una VLAN, e non lo switch, che ha quelle quattro porte in accesso e quindi tratta indistintamente tutto come VLAN 1. Il lavoro sui bridge consiste esattamente nell'insegnare a uno dei quattro ad apporre quell'etichetta, e alla porta corrispondente dello switch a rispettarla.

## Una DMZ o due segmenti: la domanda posta dall'IT Manager il 31/08/2026

La domanda, riportata nei suoi termini, e' duplice. Primo: la DMZ non deve togliere i servizi interni agli endpoint della LAN, che devono continuare a raggiungerli. Secondo: forse serve allora un segmento distinto per i servizi che Intrawelt eroga verso l'esterno, come il portale asset. Entrambe le osservazioni sono fondate, e la risposta chiarisce un equivoco di linguaggio prima ancora che di architettura.

### Togliere dalla LAN piatta non significa rendere irraggiungibile

L'espressione "togliere i servizi dalla LAN piatta", usata in questa documentazione, e' ambigua e va sciolta. Non significa che le postazioni smettano di raggiungerli: significa che il traffico fra una postazione e un servizio, che oggi passa direttamente da uno switch senza che nessuno lo esamini, dopo la segmentazione attraversa il firewall, che lo lascia passare se una regola lo prevede.

La differenza non e' se il collegamento funziona, ma **chi ha deciso che funzioni**. Oggi funziona perche' non esiste nulla che lo impedisca, ed e' la stessa ragione per cui funzionerebbe un collegamento che nessuno vuole, per esempio dal portatile di un ospite al pannello di amministrazione di una macchina di prova. Dopo, funziona perche' qualcuno lo ha scritto, e cio' che nessuno ha scritto non passa.

Ne discende che il vincolo dell'IT Manager e' pienamente compatibile con la segmentazione, a una condizione operativa precisa: le regole che permettono gli accessi legittimi vanno scritte **contestualmente** allo spostamento, non dopo. E' il motivo per cui la matrice dei flussi, cioe' l'elenco di chi ha bisogno di raggiungere che cosa, e' un prerequisito e non una rifinitura, e per cui il censimento dell'esposizione le sta davanti.

### Il criterio che divide i due segmenti non e' chi usa il servizio

L'intuizione della seconda domanda e' giusta e la roadmap la prevedeva gia', ma il criterio che separa i due segmenti va detto con precisione, perche' quello istintivo porta fuori strada.

Il criterio **non** e' chi usa il servizio. Se lo fosse, un servizio usato dai dipendenti starebbe sempre dentro e uno usato dai clienti sempre fuori, e non e' cosi'. Il criterio e' **da dove puo' arrivare una connessione non richiesta**, cioe' chi puo' bussare alla porta senza essere stato invitato.

Un servizio raggiungibile da Internet puo' ricevere connessioni da chiunque, in qualunque momento, senza che nessuno dentro l'azienda lo sappia. E' quindi il candidato piu' probabile a essere compromesso per primo, e la sola cosa che conta e' che una sua compromissione non consegni la rete interna. Questo e' il segmento **DMZ, VLAN 201**: la sua ragione d'essere e' che dalla DMZ verso la LAN si nega per impostazione predefinita.

Un servizio raggiungibile solo dall'interno riceve connessioni solo da apparati dell'azienda. Il rischio non e' nullo, perche' una postazione compromessa e' dentro, ma e' di natura diversa e non giustifica lo stesso isolamento. Questo e' il segmento dei **servizi applicativi interni, VLAN 50**, gia' previsto dal micro-step M22d: la sua ragione d'essere non e' proteggersi da Internet, e' impedire che una postazione compromessa raggiunga senza filtro **ogni** servizio, e simmetricamente che un servizio compromesso raggiunga ogni postazione e ogni NAS.

| | VLAN 201, DMZ | VLAN 50, servizi interni |
|---|---|---|
| Chi puo' iniziare una connessione | chiunque, da Internet | solo apparati dell'azienda |
| Regola predefinita verso la LAN | nega | nega, con eccezioni piu' ampie |
| Regola predefinita dalla LAN | consenti cio' che serve | consenti cio' che serve |
| Rischio da cui protegge | compromissione dall'esterno | movimento laterale dall'interno |
| Inquilini previsti | proxy inverso e servizi pubblicati | portale asset e servizi interni futuri |

### Il caso del portale asset, che sta esattamente sul confine

Il portale asset della VM 208 e' il caso che rende concreta la distinzione, ed e' anche quello su cui la documentazione ha detto due cose diverse in momenti diversi, quindi vale la pena fissarlo.

Oggi il portale serve utenti interni, quindi la sua destinazione corretta e' la **VLAN 50**. Il piano del giugno 2026 lo destinava alla DMZ perche' allora si prevedeva di pubblicarlo verso l'esterno, e quella previsione non e' stata realizzata.

Se un giorno verra' pubblicato, non serviranno due copie e non servira' una seconda DMZ: si sposta nella **VLAN 201** e si scrive una regola che consente alle postazioni della LAN di raggiungerlo. Un servizio in DMZ resta perfettamente raggiungibile dall'interno, perche' la DMZ nega la direzione DMZ verso LAN, non la direzione LAN verso DMZ. E' l'asimmetria che rende utile il segmento, e capirla evita l'errore di duplicare i servizi.

Ne discende la regola di destinazione, da applicare a ogni servizio nuovo: se qualcuno da fuori deve potervi bussare, va in DMZ; altrimenti va nei servizi interni. Un servizio non cambia segmento perche' cambia chi lo usa, ma perche' cambia **da dove lo si puo' raggiungere senza invito**.

### Che cosa questo non risolve, e va detto

La segmentazione separa i segmenti, non le identita'. Se la stessa credenziale apre piu' macchine, spostarle in segmenti diversi non impedisce a chi la possiede di usarla su tutte quelle che riesce a raggiungere: riduce quante ne raggiunge, non quante ne apre. E' il motivo per cui il difetto #170 va chiuso a prescindere dalla DMZ, e per cui i due lavori non si sostituiscono a vicenda.

## I vincoli dichiarati dall'IT Manager il 25/08/2026

Due vincoli sono stati posti prima di cominciare, e vanno scritti qui perche' restringono le soluzioni ammissibili: senza di essi, fra sei mesi qualcuno riproporra' in buona fede una strada gia' esclusa.

Il primo e' che i collegamenti fisici del server non si spostano. Ne discende che il difetto #157 non si risolve ricablando eth1 dal QNAP a una porta gestita, e che qualunque disegno della DMZ deve appoggiarsi a un bridge gia' attestato su uno switch gestito, con una modifica di sola configurazione. Il vincolo e' compatibile con il piano, perche' `vmbr1` e' gia' sulla porta 7 del 54HP e la conferma e' ora diretta. Va notato che il vincolo riguarda i cavi del server e non l'eventuale cavo nuovo fra la porta P7 del firewall e lo switch previsto da M6, che e' un'altra tratta e va decisa a parte.

Il secondo e' che nessun intervento deve togliere agli endpoint interni della LAN l'accesso ai servizi interni. E' un requisito funzionale, e cambia il disegno in un punto preciso: segmentare non significa interrompere, significa rendere esplicito e filtrato cio' che oggi e' implicito e non filtrato. Quando la VM 208 sara' in un segmento separato, la regola che permette alle postazioni di raggiungerla sulle porte 80 e 443 dovra' essere scritta a mano sul firewall, mentre oggi funziona proprio perche' non esiste nessuna regola. Ne discende anche una conseguenza sulla destinazione: la roadmap prevede due segmenti distinti, la DMZ 201 per cio' che si pubblica verso l'esterno e la VLAN 50 dei servizi applicativi interni prevista da M22d, e per un portale che serve soltanto utenti interni la destinazione corretta e' la seconda, non la prima.

Il terzo elemento, dichiarato nello stesso momento, non e' un vincolo ma uno stato di fatto: oggi la protezione dei servizi interni e' affidata al firewall di sistema delle singole macchine Linux. E' la sezione che segue.

## La protezione host-based, che oggi e' l'unica difesa e non e' censita

Un firewall di sistema, su Linux tipicamente amministrato con *ufw*[^ufw], filtra il traffico in ingresso sulla singola macchina: e' una difesa che vive dentro l'host che deve proteggere, invece che sul percorso fra gli host. La differenza rispetto a un firewall di rete e' sostanziale e va detta senza sminuire nessuna delle due. La difesa host-based e' precisa, perche' conosce i propri servizi, e sopravvive a un cambio di indirizzamento; ma e' distribuita, quindi va configurata e verificata macchina per macchina, e chi amministra la macchina puo' disattivarla, per errore o durante una diagnosi, senza che nessuno se ne accorga altrove. La difesa di rete e' centrale e ispezionabile in un solo posto, e non dipende dalla buona configurazione di ciascun host, ma non sa nulla di cio' che accade fra due macchine dello stesso segmento.

Le due sono complementari e non alternative, ed e' la ragione per cui il censimento di quella host-based e' un prerequisito e non una curiosita': senza sapere che cosa ciascuna macchina permette oggi, non si puo' scrivere una regola di rete che non tolga un accesso funzionante.

**Il censimento e' stato eseguito il 25-28/08/2026 come micro-step M27-7, e ha rovesciato la premessa.** Su sette macchine ispezionate `ufw` non e' installato su sei, e sulla settima e' installato ma inattivo: la difesa host-based che si credeva presente non esiste, ed e' il difetto #159. Ne discende una conseguenza sul disegno opposta a quella attesa: il vincolo dell'IT Manager resta valido e va rispettato, ma il timore che una regola di rete rompesse una configurazione host-based esistente non ha oggetto, perche' quella configurazione non c'e'. La segmentazione non ha nulla da preservare a quel livello, ha tutto da costruire, e il firewall di rete non sara' un secondo strato di difesa ma il primo. La matrice completa delle porte in ascolto macchina per macchina, gli otto difetti che ne discendono e la ragione per cui i container complicano qualunque rimedio host-based stanno in `docs/esposizione-servizi-interni.md`.

## La scala dei micro-step della DMZ, e dove siamo

L'ordine non e' arbitrario, e ogni gradino porta con se' la ragione per cui viene prima del successivo. Lo stato e' aggiornato al 25/08/2026.

| Passo | Cosa fa | Dove | Perche' in questa posizione | Stato |
|---|---|---|---|---|
| M4-0 | confermare su quale porta dello switch esce `vmbr1` | comando sull'host | tutto il resto configura "la porta 7": se non fosse la 7 si configurerebbe la porta sbagliata, e si toccherebbe un cavo che porta altro | **fatto il 25/08/2026**, esito positivo, porta 7 confermata da LLDP |
| M4 | portare la porta 7 dello switch da accesso a trunk, con la VLAN 1 non taggata e la 201 taggata | Nebula | e' il passo che puo' far cadere cio' che oggi passa da quel cavo, quindi va fatto con il rollback pronto e non per primo | da fare, il disegno va riscritto su `vmbr1` |
| M5 | applicare la configurazione sul bridge, dalla console iLO | Proxmox | e' la modifica che, se sbagliata, toglie l'accesso alla macchina su cui la si sta facendo | da fare |
| M6 | il braccio del firewall verso il segmento, e la validazione di livello 2 | firewall e switch | il segmento deve avere un gateway prima che qualcuno vi si affacci | da fare, da decidere se braccio dedicato sulla P7 o VLAN taggata sul collegamento gia' esistente |
| M7-M9 | zona, regole, pubblicazione e prima macchina nel segmento | firewall e Proxmox | si prova su una macchina sacrificabile prima di spostarvi un servizio in uso | da fare |
| M27-7 | censimento della protezione host-based sulle macchine Linux | SSH sulle macchine | senza sapere che cosa ogni host permette oggi, una regola di rete puo' togliere un accesso funzionante | **fatto il 25-28/08/2026 su sette macchine su nove**, esito in `docs/esposizione-servizi-interni.md`: `ufw` assente ovunque, otto difetti nuovi dal #159 al #166. Da ripetere come amministratore per il nome dei processi, e da completare sulle VM 205 e 208 quando vi si rientrera' |

## Perche' il piano DMZ scritto a maggio non e' piu' applicabile

Il piano del 05/06/2026, ancora scritto in `docs/network-diagram.md` nella sezione dell'architettura DMZ, prescrive di rendere VLAN-aware `vmbr0` e di portarvi la VLAN 201 taggata. Con le misure del 24/08 quel piano e' sbagliato per due ragioni indipendenti, e ciascuna basterebbe.

La prima e' il difetto #157 (NET-026): `vmbr0` non esce su una porta di accesso dello switch gestito, esce sul QNAP QSW-1208-8c, che e' uno switch non gestito. Un apparato non gestito i tag 802.1Q li propaga per caso e non per configurazione, non ha porte da mettere in trunk, non ha una tabella interrogabile, non tiene contatori ne' log. Costruirci sopra un segmento di sicurezza significa affidare la separazione a un comportamento non garantito.

La seconda e' che `vmbr0` e' il bridge che porta l'indirizzo di gestione dell'hypervisor, quindi la modifica andrebbe applicata a caldo sull'unica via d'accesso in banda al server.

Il candidato corretto e' `vmbr1`, che e' sulla porta 7 di uno switch gestito, e' il piu' scarico dei quattro con una sola scheda virtuale attestata, e non porta indirizzi dell'host. Da notare che l'analisi comparativa del 29/05/2026 aveva scartato l'ipotesi del cavo dedicato perche' "consuma una porta fisica aggiuntiva e non scala": quella premessa non regge piu' alla misura, perche' le porte sono quattro e i bridge sono gia' quattro. La riscrittura di M4-M6 resta comunque sospesa al riscontro LLDP: un piano sbagliato che resta scritto e' peggio di un piano assente, perche' sembra pronto, ma sostituirlo con un secondo piano appoggiato a un solo indirizzo ripeterebbe l'errore in direzione opposta.

## Le tre conseguenze che questo ramo porta con se'

La prima riguarda la continuita'. Lo switch non gestito e' un punto di guasto singolo sulla via di amministrazione in banda dell'hypervisor, e va verificato da quale sorgente elettrica dipende. Si somma al fatto accertato il 06/08/2026 che il server ha un solo alimentatore, collegato alla Ciabatta 2 DX: non e' una ridondanza da sistemare, e' una ridondanza che non esiste e che va dichiarata nel piano di continuita' invece di essere data per scontata dal fatto che l'apparato sta sotto gruppo. E' il difetto #147 (ELE-003).

La seconda riguarda la diagnosi. Quando la console Proxmox non risponde, oggi non esiste modo di sapere se il problema e' quel tratto: niente contatori, niente log, niente tabella MAC interrogabile. Si diagnostica staccando cavi, cioe' con un'interruzione di servizio.

La terza riguarda l'esposizione dei servizi. Tre difetti aperti sono manifestazioni diverse dello stesso fatto strutturale, cioe' che le macchine virtuali stanno sulla LAN piatta senza niente in mezzo: il portale asset della VM 208 che pubblica su 80 e 443 verso l'intero dominio di broadcast (#121, NET-011), il pannello di amministrazione del CMS di staging sulla VM 209 raggiungibile da qualunque host con la sola autenticazione applicativa a difenderlo (#155, NET-024), e la DMZ progettata da tre mesi che non esiste e che ha gia' un inquilino in attesa (#154, FW-014). Nessuno dei tre si risolve sul singolo servizio: si risolvono con M22 e con il segmento 201.

## Rilevanza ISO27001

I fatti di questa scheda toccano quattro controlli dell'Annex A, e sono gia' registrati nel registro dei gap con il codice corrispondente. A.8.22, segregazione delle reti, e' il controllo centrale: la riga della scheda `design-and-security.md` che descriveva la situazione come "segmentazione fisica tramite bridge separati" e' stata corretta il 25/08/2026, perche' la misura mostra che i quattro bridge non segregano. A.8.20, sicurezza delle reti, e' toccato dal tratto non gestito sulla via di amministrazione. A.8.9, gestione delle configurazioni, era il controllo del difetto #153, ora risolto. A.8.14, ridondanza degli impianti, riguarda l'alimentatore unico e l'assenza di aggregazione delle schede.

## Cosa resta da verificare

Tre cose, in ordine di quanto bloccano. La prima della lista precedente, il riscontro LLDP su eno2, e' stata chiusa il 25/08/2026 con esito positivo e non compare piu' qui.

La prima e' il completamento del censimento M27-7: la prima passata, del 25-28/08/2026, e' stata eseguita da utente non privilegiato su sei macchine su sette, quindi dice che cosa e' esposto ma non chi lo espone, e non ha potuto toccare le VM 205 e 208 perche' le loro credenziali locali sono perdute (#162). La 208 e' il portale asset, cioe' il primo servizio che la segmentazione deve spostare.

La seconda e' su quale porta del QNAP atterri eth1. La tabella di quell'apparato in `docs/livello-fisico-ed-elettrico.md` censisce le porte 1, 3, 4, 5, 6, 7, 8, 10 e 12, e il server non compare in nessuna riga: le candidate sono la 2, la 9 e l'11, e su uno switch non gestito non esiste modo di chiederlo da remoto. Va guardato in armadio, e conviene farlo nello stesso sopralluogo in cui si verificano le trentasei porte libere e le nove porte con collegamento attivo e zero traffico.

La terza e' da quale sorgente elettrica dipenda il QNAP, che con il difetto #157 diventa un apparato sulla via di amministrazione e non piu' soltanto sul ramo storage.

[^bridge]: *bridge* - switch di livello 2 realizzato in software dentro il sistema operativo dell'host; su Proxmox e' l'oggetto a cui si collegano le schede di rete delle macchine virtuali per farle uscire su una scheda fisica.

[^ilo]: *iLO*, Integrated Lights-Out - il processore di gestione indipendente dei server HP, con scheda di rete e alimentazione proprie, che offre console remota, accensione e spegnimento anche a sistema operativo fermo.

[^mac]: *MAC*, Media Access Control - l'indirizzo fisico di una scheda di rete, quello che identifica un apparato al livello 2, sotto l'indirizzo IP.

[^bond]: *bond*, o *link aggregation* - piu' schede di rete unite in un'unica interfaccia logica, per sommarne la banda o per garantire che il traffico continui se un cavo cade.

[^lacp]: *LACP*, Link Aggregation Control Protocol - il protocollo con cui le due estremita' di un'aggregazione si accordano su quali cavi ne fanno parte, invece di doverlo configurare a mano da entrambi i lati.

[^dot1q]: *802.1Q* - lo standard che permette di far viaggiare piu' reti logiche sullo stesso cavo aggiungendo a ogni trama un'etichetta di quattro byte che ne dichiara la VLAN di appartenenza.

[^stp]: *STP*, Spanning Tree Protocol - il protocollo che impedisce i cicli in una rete di livello 2 disattivando i collegamenti ridondanti; su un bridge senza percorsi alternativi non ha nulla da fare, ed e' il motivo per cui qui e' spento.

[^lldp]: *LLDP*, Link Layer Discovery Protocol - protocollo con cui gli apparati di rete annunciano su ogni cavo la propria identita' e il numero della porta, cosi' che il vicino sappia con precisione a che cosa e' collegato.

[^dmz]: *DMZ*, demilitarized zone - segmento di rete separato dove si collocano i servizi raggiungibili dall'esterno o da molti, in modo che una loro compromissione non dia accesso diretto alla rete interna; il traffico fra DMZ e rete interna passa obbligatoriamente da un firewall che lo filtra.

[^ufw]: *ufw*, uncomplicated firewall - l'interfaccia di amministrazione semplificata del filtro di pacchetti del kernel Linux, con cui si definisce quali connessioni in ingresso una singola macchina accetta.
