# Esposizione dei servizi interni e protezione host-based

> Scheda aperta il 28/08/2026 come esito del micro-step M27-7, il censimento della protezione host-based sulle macchine Linux dell'hypervisor. Nasce da una dichiarazione dell'IT Manager del 25/08/2026 — "per ora ogni protezione viene risolta da ufw interno delle macchine linux" — che la misura ha smentito, ed e' il motivo per cui il censimento esisteva. Va letta insieme a `docs/virtualizzazione-proxmox-e-bridge.md`, che descrive come le stesse macchine sono attaccate alla rete, e a `docs/segmentazione-lan-m22.md`, che descrive dove dovranno andare.
>
> Convenzione. Nomi di macchina virtuale, numeri di porta, versioni di sistema operativo e nomi di container sono reali, perche' servono a operare. Gli indirizzi seguono i segnaposto di `.claude/rules/anonymization.md`. Fonte: comando di sola lettura eseguito dall'IT Manager su ciascuna macchina il 25-28/08/2026, con `ss -tulpn`, `ufw status verbose` e `docker ps`.

## Il risultato in una riga, e perche' cambia il piano

Su sette macchine ispezionate, `ufw` non e' installato su sei e sulla settima e' installato ma inattivo. Nessuna delle macchine interne ha oggi un firewall di sistema che filtri qualcosa.

Ne discende che la protezione dei servizi interni non e' affidata a un filtro debole o mal configurato: non e' affidata a nulla. Cio' che oggi impedisce a un host qualunque della LAN piatta di raggiungere una qualunque di quelle porte e' soltanto il fatto che nessuno ci prova, piu' l'autenticazione che ciascuna applicazione si porta dietro. Non e' una critica a chi ha costruito quelle macchine, che le ha costruite per funzionare: e' la fotografia di una difesa che si credeva presente e non c'e', ed e' esattamente il tipo di affermazione che una misura serve a rovesciare.

La conseguenza sul piano di segmentazione e' opposta a quella che ci si aspetterebbe, e vale la pena dirla subito. Il vincolo dichiarato dall'IT Manager — nessun intervento deve togliere agli endpoint interni l'accesso ai servizi interni — resta valido e va rispettato. Ma il timore che una regola di rete rompesse una configurazione host-based esistente non ha oggetto, perche' quella configurazione non esiste. La segmentazione non ha nulla da preservare a quel livello: ha tutto da costruire.

## Che cosa significa esattamente "in ascolto", perche' senza questo il resto non si legge

Un programma che offre un servizio apre un *socket*[^socket] in ascolto su una porta, e nel farlo dichiara anche su quale indirizzo vuole ricevere. Quella scelta, che si legge nella colonna sinistra dell'output di `ss`, e' la differenza fra un servizio raggiungibile da tutta la rete e uno raggiungibile solo da se' stesso, e non ha niente a che vedere con il firewall.

Se l'indirizzo dichiarato e' `127.0.0.1`, cioe' l'indirizzo di *loopback*[^loopback], il servizio risponde solo a chi si trova sulla stessa macchina: nessun pacchetto proveniente dalla rete potra' mai raggiungerlo, indipendentemente da qualunque filtro. E' il caso dei database MariaDB sulle macchine 202, 206 e 207, e dei due processi Python sulla 204, e va detto che e' la configurazione corretta per un componente che serve solo l'applicazione che gli sta accanto.

Se l'indirizzo dichiarato e' `0.0.0.0`, oppure `*`, il servizio accetta connessioni su qualunque interfaccia della macchina, quindi da tutta la LAN piatta. Se e' un indirizzo specifico, per esempio quello della macchina sulla LAN come nel caso della porta 8000 sulla 207, l'effetto pratico e' lo stesso perche' quell'indirizzo e' proprio quello che tutta la rete puo' raggiungere: cambia solo che il servizio non risponde su loopback o sulle reti interne dei container.

Un firewall di sistema serve a mettere una decisione fra il pacchetto e il socket in ascolto. In sua assenza, ogni porta della colonna che segue e' raggiungibile da ogni host della `/19`, cioe' da ogni postazione, ogni telefono, ogni stampante e ogni macchina virtuale dell'azienda.

## La matrice dell'esposizione, al 28/08/2026

| VM | Nome | Indirizzo | Sistema | Firewall di sistema | Porte raggiungibili da tutta la LAN | Porte solo locali |
|---|---|---|---|---|---|---|
| 202 | PasswordManager | `10.61.20.21` | Ubuntu 24.04.2 LTS | non installato | 22, 80 | 3306, 631 |
| 204 | ConvertitoreRuoliniENI | `10.61.20.22` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 8090 | 5000, 5010 |
| 206 | intrasite | `10.61.20.23` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 443 | 3306, 631 |
| 207 | websiteAnalyst | `10.61.20.24` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 8000 | 3306, 631 |
| 209 | IntraNewSite | `10.61.20.209` | Ubuntu 24.04.4 LTS | non installato | 22, 3000, 5432 | 631 |
| 602 | Intralino | `10.61.20.60` | Ubuntu 25.10 | non installato | 22, 80, 443, 4443, 5443, 5444 | nessuna |
| 810 | TESTNEWEGETRADBOOT | `10.61.20.90` | Ubuntu 24.04.4 LTS | installato, inattivo | 22, 80, 3389, 8080, 8090 | 3350 |
| 205 | GanttTool | non rilevato | non rilevato | non rilevato | non rilevato | la macchina non arriva alla schermata di accesso e la password va reimpostata |
| 208 | portaleAsset | `10.61.20.25` | non rilevato | non rilevato | 80 e 443 note da NET-011, il resto non rilevato | la password locale non e' piu' valida e va reimpostata |

## I sette fatti che discendono dalla matrice, in ordine di quanto pesano

Il primo e' il gestore delle password della VM 202, che risponde sulla porta 80, cioe' in chiaro, e non ha nessun ascolto sulla 443. Un servizio che custodisce credenziali e che le trasmette senza cifratura su una rete dove ogni apparato e' adiacente a ogni altro e' il caso peggiore della matrice, perche' non richiede di violare nulla: chi si trovi in condizione di osservare il traffico legge le credenziali mentre passano, e la password principale del deposito passa di li' a ogni accesso. Tracciato come #160.

Il secondo e' PostgreSQL della VM 209, in ascolto sulla porta 5432 su tutte le interfacce. Non e' soltanto un'esposizione: e' anche una contraddizione con cio' che questo progetto affermava, perche' la fonte della mappa e la scheda del sito descrivevano quel database come residente sulla rete interna dei container e privo di un indirizzo proprio sulla LAN. La misura dice altro, la fonte e' stata corretta, e il fatto va letto come un caso di scuola di obsolescenza silenziosa: l'affermazione era vera quando fu scritta e ha smesso di esserlo senza che nulla la contraddicesse. Tracciato come #161.

Il terzo sono le due macchine su cui non si entra piu'. Sulla 205 la macchina non arriva alla schermata di accesso e la password va reimpostata; sulla 208 la password locale non e' piu' quella conosciuta. Il punto non e' il fastidio: e' che la 208 e' il portale asset, cioe' proprio il servizio che il piano di segmentazione deve spostare per primo, e non lo si puo' ne' ispezionare ne' riconfigurare finche' non vi si rientra. La reimpostazione su una macchina virtuale Proxmox si fa dalla console, avviando in modalita' di manutenzione, ed e' un intervento con interruzione di servizio da programmare. Tracciato come #162.

Il quarto sono gli ambienti di prova esposti accanto alla produzione. Sulla 602 convivono due pile complete di Intralino, quella in esercizio sulle porte 80, 443 e 5443 e quella di test sulle 4443 e 5444, entrambe raggiungibili da chiunque; sulla 810 la stessa cosa con `getrad-app` sulla 8080 e `getrad-test-app` sulla 8090. Un ambiente di prova ha per definizione dati di prova, credenziali deboli e correzioni non ancora applicate, e non ha ragione di essere raggiungibile da tutta l'azienda. Tracciato come #163.

Il quinto e' il servizio di scrivania remota `xrdp` sulla porta 3389 della VM 810, in ascolto su tutte le interfacce. E' un canale di accesso interattivo completo alla macchina, esposto all'intera LAN piatta, su una macchina che e' un ambiente di prova di una migrazione. Tracciato come #164.

Il sesto e' la versione di sistema della VM 602, Ubuntu 25.10. Le versioni intermedie di Ubuntu, cioe' quelle che non sono LTS, hanno nove mesi di supporto, il che collocherebbe la fine del supporto di questa a luglio 2026, quindi gia' trascorsa. Il dato va confermato sulla pagina del ciclo di vita del fornitore prima di essere trattato come fatto, ma se confermato significa che la macchina che ospita Intralino non riceve piu' aggiornamenti di sicurezza. Tracciato come #165, con la sua riserva scritta.

Il settimo e' minore e riguarda l'igiene: quattro macchine distinte rispondono con lo stesso nome host, `Ubuntu24`. Non produce un guasto, ma rende ambiguo ogni registro, ogni traccia di accesso e ogni diagnosi che si appoggi al nome invece che all'indirizzo. Tracciato come #166.

A questi si aggiunge il fatto trasversale, che e' il primo in ordine di gravita' e ha un codice proprio: l'assenza del firewall di sistema su tutte e sette le macchine, tracciata come #159.

## Una cosa che il censimento non ha potuto vedere, e va rifatta

Su sei macchine su sette il comando e' stato eseguito da un utente non privilegiato. L'elenco delle porte in ascolto e' comunque completo e affidabile, perche' quel dato il kernel lo espone a chiunque; non lo sono invece due colonne che mancano, cioe' il nome del processo che tiene aperta ciascuna porta e l'elenco dei container. Su tre di quelle macchine, la 202, la 206 e la 209, la presenza delle reti interne di Docker dimostra che il motore dei container e' installato e attivo, mentre il comando ha risposto "nessun docker": non e' vero, e' semplicemente che l'utente non aveva accesso al socket del motore.

Ne discende che la matrice qui sopra e' corretta su cosa e' esposto e incompleta su chi lo espone, e la seconda meta' serve per decidere che cosa spegnere. Il comando va ripetuto come amministratore sulle sei macchine.

## Perche' i container complicano il quadro, e va saputo prima di installare un filtro

Quando un container pubblica una porta, il motore dei container non si limita ad avviare un processo in ascolto: inserisce regole proprie nella tabella di traduzione degli indirizzi del kernel, e quelle regole vengono valutate prima della catena su cui `ufw` opera. La conseguenza pratica e' che, su una macchina con container che pubblicano porte, installare `ufw` e negare una porta puo' produrre uno stato che dichiara la porta negata mentre il servizio continua a rispondere.

Riguarda direttamente questa infrastruttura, perche' la 810 pubblica tre porte da container e la 602 ne pubblica cinque, e con ogni probabilita' anche la 209 e la 206, la cui lista di container non e' stata leggibile. Ne discende che il rimedio host-based su quelle macchine non e' una regola di `ufw`, ma un intervento sulla pubblicazione stessa: un container che deve servire solo la macchina si pubblica su `127.0.0.1` invece che su tutte le interfacce, ed e' una modifica di una riga nella definizione del servizio che non richiede nessun filtro.

## Che cosa questo cambia nel piano di segmentazione

Tre cose, e nessuna delle tre annulla il lavoro gia' fatto.

La prima e' che la segmentazione diventa piu' urgente e non meno, perche' e' l'unico livello dove oggi esiste la possibilita' di mettere una decisione fra due macchine. Con `ufw` assente ovunque, il firewall di rete non e' un secondo strato di difesa: e' il primo.

La seconda e' che il vincolo dell'IT Manager si applica con un dato in mano invece che a memoria. Quando la VM 208 andra' nel segmento dei servizi applicativi interni, le regole da scrivere sul firewall sono quelle che permettono alle postazioni di raggiungerla sulle porte 80 e 443, e nient'altro. La matrice di questa scheda e' la base di partenza per scrivere quelle regole per ciascuna macchina, e va completata con la colonna mancante, cioe' chi ha bisogno di raggiungere che cosa.

La terza e' che alcuni rimedi non aspettano la segmentazione e conviene farli prima, perche' costano poco e riducono la superficie: portare il gestore delle password su HTTPS, ripubblicare su loopback i container che servono solo la propria macchina, spegnere gli ambienti di prova quando non servono o vincolarli a un indirizzo, e chiudere `xrdp` sulla 810. Sono candidati naturali al registro degli interventi non bloccanti di `docs/interventi-robustezza.md`.

## Cosa resta aperto

Il censimento come amministratore sulle sei macchine, per avere il nome dei processi e la lista dei container. Le due macchine su cui non si entra, la 205 e la 208, che vanno riaperte dalla console Proxmox. La conferma della fine del supporto di Ubuntu 25.10 sulla 602. E la matrice dei flussi, cioe' chi ha bisogno di raggiungere che cosa, che e' l'unica parte che nessuna misura puo' produrre da sola e che va compilata con l'IT Manager servizio per servizio.

[^socket]: *socket* - il punto di aggancio con cui un programma si mette in comunicazione sulla rete; un socket in ascolto e' identificato dalla coppia indirizzo e porta su cui il programma accetta connessioni in arrivo.

[^loopback]: *loopback* - l'interfaccia di rete virtuale che ogni macchina ha verso se' stessa, con indirizzo `127.0.0.1`; il traffico che vi transita non lascia mai la macchina e non e' visibile dalla rete.
