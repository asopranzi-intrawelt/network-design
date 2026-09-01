# Esposizione dei servizi interni e protezione host-based

> Scheda aperta il 28/08/2026 come esito del micro-step M27-7, il censimento della protezione host-based sulle macchine Linux dell'hypervisor. Nasce da una dichiarazione dell'IT Manager del 25/08/2026 — "per ora ogni protezione viene risolta da ufw interno delle macchine linux" — e ha attraversato due correzioni in tre giorni: la prima passata ha misurato che `ufw` non c'e', la seconda ha stabilito che questo non significa che non ci siano filtri, perche' un filtro puo' vivere ad almeno quattro livelli diversi e `ufw` e' soltanto uno. Va letta insieme a `docs/virtualizzazione-proxmox-e-bridge.md`, che descrive come le stesse macchine sono attaccate alla rete, e a `docs/segmentazione-lan-m22.md`, che descrive dove dovranno andare.
>
> Convenzione. Nomi di macchina virtuale, numeri di porta, versioni di sistema operativo e nomi di container sono reali, perche' servono a operare. Gli indirizzi seguono i segnaposto di `.claude/rules/anonymization.md`. Fonte: comando di sola lettura eseguito dall'IT Manager su ciascuna macchina il 25-28/08/2026, con `ss -tulpn`, `ufw status verbose` e `docker ps`, piu' la correzione del 31/08/2026 sulla VM 204. La seconda passata, che copre tutti e quattro i livelli, non e' ancora stata eseguita.

## Il risultato in una riga, e la correzione del 31/08/2026

Su sette macchine ispezionate, `ufw` non e' installato su sei e sulla settima e' installato ma inattivo. Questo e' cio' che la prima passata ha misurato, ed e' un fatto.

**Cio' che la prima passata aveva concluso da quel fatto era invece sbagliato, e va detto per esteso perche' l'errore e' istruttivo.** La scheda affermava che "la protezione dei servizi interni non e' affidata a nulla". L'IT Manager ha corretto l'affermazione il 31/08/2026 portando un controesempio puntuale: sulla VM 204, che ospita il convertitore dei ruolini, l'accesso e' ristretto per indirizzo, e sono ammessi soltanto la postazione dell'IT Manager e due indirizzi della fascia `.70`. Quella restrizione esiste, funziona, e `ufw status` non la vede.

L'errore di ragionamento e' di quelli che vale la pena riconoscere invece che correggere in silenzio: si e' misurato **uno** dei livelli a cui puo' vivere un filtro e si e' concluso sull'insieme. In termini piu' precisi, l'assenza di `ufw` e' l'assenza di una prova, non la prova di un'assenza, e questo progetto ha una regola esplicita che vieta esattamente questo passaggio (`.claude/rules/interaction-style.md`, §Onesta' del contenuto).

L'affermazione corretta e' quindi piu' stretta e piu' utile: **il livello host-based non e' governato in modo uniforme ne' ispezionabile centralmente**. Alcune macchine hanno restrizioni, altre no, e per sapere quali bisogna guardare in quattro posti diversi invece che in uno. Il difetto #159 e' stato riformulato di conseguenza.

La conseguenza sul piano di segmentazione cambia di segno rispetto a quanto scritto il 28/08. Il vincolo dichiarato dall'IT Manager — nessun intervento deve togliere agli endpoint interni l'accesso ai servizi interni — non solo resta valido, ma torna a essere **stringente**: se sulla VM 204 esiste una lista di indirizzi ammessi, un cambio di indirizzamento dovuto alla segmentazione la rompe, e la rompe silenziosamente, perche' il servizio continuera' a rispondere a chi non e' in lista con un rifiuto che sembra un problema applicativo. La seconda passata del censimento serve a trovare tutte le liste di questo tipo prima di toccare gli indirizzi.

## Da dove si lanciano i comandi, e una regola che sembra pedanteria e non lo e'

I comandi di questa scheda si lanciano da due posti soltanto, e confonderli e' costato tempo il 31/08/2026. Quelli che riguardano una macchina virtuale si lanciano dalla postazione verso quella macchina, con l'alias SSH corrispondente. Quelli che riguardano l'hypervisor, cioe' tutta la famiglia `qm`, si lanciano sull'host Proxmox: dalla postazione con `ssh root@<host> "<comando>"`, oppure direttamente se si e' gia' collegati a quella shell.

La regola che ne discende e' che **non si lancia mai `ssh` verso l'host su cui ci si trova gia'**. Il caso concreto e' stato un `ssh root@<host> "qm agent 208 ping"` digitato mentre si era gia' su quella shell, cioe' il server verso se' stesso, che ha prodotto la richiesta di accettare l'impronta della propria chiave.

Tre ragioni per cui vale la pena evitarlo, e nessuna delle tre e' la superficie di attacco, che non cambia perche' il servizio SSH e' comunque in ascolto. La prima e' che accettare quell'impronta scrive una voce permanente nel file degli host conosciuti **del server**, riferita al server stesso: rumore che resta e che chi verra' dopo dovra' interpretare. La seconda e' la tracciabilita': un comando lanciato dalla postazione lascia una sessione sola e attribuibile, mentre uno lanciato dal server verso se' stesso ne lascia due annidate e nei registri somiglia a un accesso dalla rete. La terza e' pratica: due livelli di shell sono due livelli di citazione, ed e' esattamente il punto in cui i comandi si rompono, come gia' successo con il censimento.

## Come si chiama la stessa macchina nei tre posti in cui compare

Una macchina di questa infrastruttura porta almeno tre nomi diversi, e non coincidono. Proxmox la identifica con un numero e un nome di macchina virtuale. Il sistema operativo che vi gira dentro ha un proprio nome host, scelto in fase di installazione e in quattro casi lasciato al valore predefinito. E la postazione dell'IT Manager la raggiunge con un alias SSH, che e' un soprannome locale scritto nel suo `~/.ssh/config` e che spesso ricorda l'applicazione invece della macchina: `odoo-vm` per il convertitore dei ruolini, che gira su Odoo, `openproject-vm` per quello che Proxmox chiama GanttTool, che e' OpenProject.

Nessuno dei tre nomi e' sbagliato, ma la loro convivenza e' una trappola: un comando lanciato sull'alias giusto sembra sbagliato a chi guarda la lista di Proxmox, ed e' esattamente cio' che e' successo il 31/08/2026. La tabella che segue e' la traduzione, e va tenuta aggiornata quando nasce una macchina.

| VM | Nome in Proxmox | Indirizzo | Alias SSH | Utente | Nome host interno |
|---|---|---|---|---|---|
| 100 | WinServer2022 | `10.61.20.13` | nessuno, e' Windows | — | `WIN-...` di fabbrica |
| 202 | PasswordManager | `10.61.20.21` | `pwmanager-vm` | `intrawelt` | `Ubuntu24` |
| 203 | templateMicroservice | — | nessuno | — | spenta |
| 204 | ConvertitoreRuoliniENI | `10.61.20.22` | `odoo-vm` | `intrawelt` | `Ubuntu24` |
| 205 | GanttTool | `10.61.20.61` | `openproject-vm` | `intrawelt` | non rilevato |
| ~~206~~ | ~~intrasite~~ | ~~`10.61.20.23`~~ | ~~`wordpress-vm`~~ | — | — | dismessa il 31/08/2026 |
| 207 | websiteAnalyst | `10.61.20.24` | `vm207` | `intrawelt` | `Ubuntu24` |
| 208 | portaleAsset | `10.61.20.25` | `asset-vm` | `portale-asset-it` | `asset` |
| 209 | IntraNewSite | `10.61.20.209` | nessuno | `intrawelt-site` | `intrawelt-site-...` |
| 602 | Intralino | `10.61.20.60` | `intralino` | `developer` | `developer-std-...` |
| 810 | TESTNEWEGETRADBOOT | `10.61.20.90` | nessuno | `root` | `ubuntegetrad` |

Tre osservazioni che discendono dalla tabella. La prima e' che l'indirizzo della VM 205 non era stato rilevato dal censimento e si e' recuperato proprio da qui, dalla configurazione SSH della postazione: e' `.61` e non un indirizzo adiacente agli altri, il che spiega perche' nessuno lo ricordasse. La seconda e' che due macchine su nove non hanno un alias e vanno raggiunte per indirizzo, il che le rende piu' facili da dimenticare in un censimento. La terza e' che quattro macchine condividono il nome host `Ubuntu24`, che e' il difetto #166: in questa tabella la distinzione la fa l'indirizzo, ma in un registro di eventi non la farebbe nessuno.

## Sequenza operativa, nell'ordine in cui va eseguita

Tutti i passi si eseguono dal terminale della postazione dell'IT Manager, che raggiunge in SSH sia l'host Proxmox sia le macchine virtuali; nessuno richiede di essere fisicamente davanti a un apparato. Gli alias SSH e le chiavi corrispondenti sono gia' configurati sulla postazione e vivono in `~/.ssh/config`, non in questo repository.

| # | Passo | Dove si esegue | Blocca | Stato |
|---|---|---|---|---|
| 1 | Verificare se le due macchine "chiuse" rispondano a chiave SSH invece che a password | postazione | #162, e con esso M22d | **fatto il 31/08/2026, esito misto**: la VM 208 risponde e non era inaccessibile; la VM 205 non risponde affatto sulla porta 22 |
| 2 | Seconda passata del censimento su tutti e quattro i livelli, macchine raggiungibili | dalla postazione, con `scripts/Invoke-HostCensus.ps1` | #159, #167 | da fare, la 208 vi rientra |
| 2bis | Registrare, host per host, dove la password locale non e' piu' nota | esito automatico del passo 2 | #162, #168 | da fare, lo produce lo stesso comando |
| 3 | Censimento della VM 100 con i tre comandi PowerShell | dentro la VM 100 | copertura Windows | da fare |
| 4 | Se il passo 1 fallisce: reimpostazione della password con l'agente ospite | host Proxmox | #162 | condizionato |
| 5 | Se anche il passo 4 fallisce: console e riga di avvio, con interruzione | console Proxmox | #162 | condizionato |
| 6 | HTTPS sul gestore delle password, **prima** di depositarvi credenziali nuove | dentro la VM 202 | #160 | da fare |

Il passo 1 precede tutti gli altri per una ragione che vale la pena isolare, perche' e' il tipo di verifica che si dimentica di fare: **una password persa non e' un accesso perso**. Su un sistema Linux l'autenticazione con chiave e quella con password sono due meccanismi indipendenti, e la prima non smette di funzionare quando la seconda viene cambiata o dimenticata. Su questa infrastruttura esistevano gia' chiavi dedicate per entrambe le macchine considerate inaccessibili, quindi prima di programmare un'interruzione di servizio andava provato un comando che costava nulla.

**Eseguito il 31/08/2026, con esito diverso sulle due macchine, e la differenza conta.** La **VM 208** risponde a chiave, restituisce il proprio nome e i propri indirizzi: non era inaccessibile, era inaccessibile *con quella password*. Ne discende che il blocco su M22d non esiste e che la macchina rientra subito nella seconda passata. La **VM 205** invece non risponde per nulla, con un errore di connessione scaduta sulla porta 22: non e' un problema di credenziali ma di raggiungibilita', il che e' coerente con il fatto che la macchina non arrivi alla schermata di accesso e sposta il caso dal recupero della password alla diagnosi di avvio. Il difetto #162 e' stato riscritto su questa distinzione.

Il passo 6 precede la reimpostazione delle password per la ragione registrata in #162 e #160: il deposito delle credenziali di questa infrastruttura e' la VM 202, che oggi risponde in chiaro. Depositare due password nuove in un contenitore servito senza cifratura riproduce il problema invece di chiuderlo.

## Che cosa significa esattamente "in ascolto", perche' senza questo il resto non si legge

Un programma che offre un servizio apre un *socket*[^socket] in ascolto su una porta, e nel farlo dichiara anche su quale indirizzo vuole ricevere. Quella scelta, che si legge nella colonna sinistra dell'output di `ss`, e' la differenza fra un servizio raggiungibile da tutta la rete e uno raggiungibile solo da se' stesso, e non ha niente a che vedere con il firewall.

Se l'indirizzo dichiarato e' `127.0.0.1`, cioe' l'indirizzo di *loopback*[^loopback], il servizio risponde solo a chi si trova sulla stessa macchina: nessun pacchetto proveniente dalla rete potra' mai raggiungerlo, indipendentemente da qualunque filtro. E' il caso dei database MariaDB sulle macchine 202 e 207, e lo era della 206 finche' e' esistita, e dei due processi Python sulla 204, e va detto che e' la configurazione corretta per un componente che serve solo l'applicazione che gli sta accanto.

Se l'indirizzo dichiarato e' `0.0.0.0`, oppure `*`, il servizio accetta connessioni su qualunque interfaccia della macchina, quindi da tutta la LAN piatta. Se e' un indirizzo specifico, per esempio quello della macchina sulla LAN come nel caso della porta 8000 sulla 207, l'effetto pratico e' lo stesso perche' quell'indirizzo e' proprio quello che tutta la rete puo' raggiungere: cambia solo che il servizio non risponde su loopback o sulle reti interne dei container.

Un firewall di sistema serve a mettere una decisione fra il pacchetto e il socket in ascolto. Va pero' tenuta ferma la distinzione fra i due piani: un socket in ascolto su tutte le interfacce **e' esposto in ascolto**, cioe' il sistema operativo accettera' la connessione, ma se qualcuno ha messo una decisione a un qualunque livello successivo la richiesta puo' comunque non arrivare all'applicazione. La colonna delle porte in ascolto dice dunque dove esiste una superficie, non dove esiste un accesso, e le due coincidono solo dove nessuno dei quattro livelli della sezione seguente ha una regola.

## I quattro livelli a cui puo' vivere un filtro, e perche' guardarne uno non basta

Fra un pacchetto che arriva sul cavo e la risposta che l'applicazione produce esistono almeno quattro punti in cui qualcuno puo' aver deciso di negare l'accesso. Sono indipendenti, si configurano in posti diversi, e nessuno dei quattro comandi che li mostra vede gli altri tre. E' la ragione per cui la prima passata ha dato un quadro parziale, ed e' anche il motivo per cui questa sezione precede la matrice.

Il primo livello e' il **filtro di pacchetti del kernel**, cioe' `netfilter`, che decide se il pacchetto arriva o no al programma in ascolto. `ufw` e' soltanto una delle interfacce con cui lo si amministra, ed e' quella che questo progetto ha guardato per prima perche' era quella nominata; ma le stesse regole si scrivono con `iptables`, con `nftables`, con `firewalld`, o con un file di regole caricato all'avvio da uno script. Se qualcuno ha scritto regole direttamente con uno di quei comandi, `ufw status` dira' "non installato" mentre il filtro sta lavorando.

Il secondo livello e' il **server web davanti all'applicazione**. Su una macchina dove nginx o Apache ricevono le richieste e le girano a un processo in ascolto solo su loopback, la restrizione per indirizzo si scrive tipicamente li', con direttive di tipo `allow` e `deny`. Dall'esterno il risultato somiglia a un firewall — chi non e' ammesso non entra — ma tecnicamente e' diverso in un punto che conta: la connessione viene **stabilita** e poi rifiutata con un errore applicativo, mentre un filtro di rete la scarta prima. E' l'ipotesi piu' probabile per la VM 204, la cui forma corrisponde: due processi Python in ascolto su `127.0.0.1` alle porte 5000 e 5010, e due porte pubbliche, la 80 e la 8090, servite da un processo che ha tutta l'aria di essere un server web.

Il terzo livello e' l'**applicazione stessa**, che puo' controllare l'indirizzo del chiamante nel proprio codice o nella propria configurazione. E' il livello meno visibile di tutti, perche' non lascia traccia in nessun comando di sistema: si scopre solo leggendo la configurazione dell'applicazione o provando da un indirizzo non ammesso.

Il quarto livello sono i **contenitori**, che come gia' detto inseriscono regole proprie valutate prima di quelle di `ufw`, e che possono pubblicare una porta su tutte le interfacce oppure sul solo loopback.

Ne discende il metodo della seconda passata: non chiedere a `ufw` se c'e' un filtro, ma chiedere a ciascuno dei quattro livelli che cosa sa. Il comando e' in fondo alla scheda.

## La matrice dell'esposizione, al 28/08/2026

Questa e' la prima passata, del 25-28/08/2026, ed e' superata per le cinque macchine coperte dalla seconda: vedi §L'esito della seconda passata. La colonna del filtro dice soltanto che cosa risponde `ufw`, che come si e' visto e' uno dei quattro livelli: dove dice "non installato" non si deve leggere "nessun filtro", ma "nessun filtro **a questo livello**". La colonna delle restrizioni note raccoglie quanto emerso finora per altra via.

| VM | Nome | Indirizzo | Sistema | `ufw` | Porte in ascolto su tutte le interfacce | Porte solo locali | Restrizioni note per altra via |
|---|---|---|---|---|---|---|---|
| 202 | PasswordManager | `10.61.20.21` | Ubuntu 24.04.2 LTS | non installato | 22, 80 | 3306, 631 | da verificare |
| 204 | ConvertitoreRuoliniENI | `10.61.20.22` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 8090 | 5000, 5010 | **si**: accesso ristretto per indirizzo, ammessi la postazione dell'IT Manager e due indirizzi della fascia `.70`, riferito il 31/08/2026; livello e sintassi da determinare |
| ~~206~~ | ~~intrasite~~ | — | — | — | — | — | **dismessa il 31/08/2026**, vedi §La dismissione della VM 206 |
| 205 | GanttTool | `10.61.20.61` | `ufw` inattivo, solo catene del motore dei container | nessuna | 22, 80, 9001 | 631, 3306, e i contenitori non pubblicati | censita il 01/09/2026, vedi §La VM 205 |
| 207 | websiteAnalyst | `10.61.20.24` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 8000 | 3306, 631 | da verificare |
| 209 | IntraNewSite | `10.61.20.209` | Ubuntu 24.04.4 LTS | non installato | 22, 3000, 5432 | 631 | da verificare |
| 602 | Intralino | `10.61.20.60` | Ubuntu 25.10 | non installato | 22, 80, 443, 4443, 5443, 5444 | nessuna | da verificare |
| 810 | TESTNEWEGETRADBOOT | `10.61.20.90` | Ubuntu 24.04.4 LTS | installato, inattivo | 22, 80, 3389, 8080, 8090 | 3350 | da verificare |
| 205 | GanttTool | non rilevato | non rilevato | non rilevato | non rilevato | non rilevato | macchina non accessibile, #162 |
| 208 | portaleAsset | `10.61.20.25` | non rilevato | non rilevato | 80 e 443 note da NET-011, il resto non rilevato | non rilevato | macchina non accessibile, #162 |
| 100 | WinServer2022 | `10.61.20.12` e `10.61.20.13` | Windows Server 2022 | non applicabile | vedi §La macchina Windows | 6379, 49864 | **firewall disattivato su tutti e tre i profili** (#175) |

## L'esito della seconda passata, 31/08/2026

**Dieci host su dieci** interrogati su tutti e quattro i livelli, fra il 31/08 e il 01/09/2026. Il micro-step M27-7 e' chiuso nella sua parte di raccolta: cio' che resta e' la matrice dei flussi, che nessuna misura puo' produrre da sola.

Il conto e' salito da nove a dieci perche' nella lista e' entrato un host che nessun inventario del progetto conteneva: l'host Ollama, che non e' una macchina virtuale e per questo era sfuggito a un censimento costruito sull'inventario di Proxmox. La rete lo conosceva gia' come l'apparato sulla porta 46 del 54HP, quello delle oscillazioni del collegamento di NET-010, ma nessuno lo aveva mai trattato come un host da censire.

| VM | Filtro del kernel | Ammissione nel server web | Container | Conclusione |
|---|---|---|---|---|
| 202 | `ufw` inattivo, nessuna regola propria oltre a quelle del motore dei container | nessuna | Vaultwarden, non pubblicato sull'host | il proxy davanti al gestore e' Apache, in chiaro |
| 204 | `ufw` inattivo, nessuna regola | **si**, `allow`/`deny` su due configurazioni di nginx | nessuno | l'unica macchina con una restrizione per indirizzo |
| 207 | `ufw` inattivo, tabelle presenti ma vuote | nessuna | nessuno | nessuna restrizione a nessun livello |
| 208 | nessun `ufw`, regole del motore dei container | nessuna | tre pubblicati su loopback, due su tutte le interfacce | separazione parziale, e fatta bene dove c'e' |
| 602 | `ufw` non installato | nessuna | dieci, due pile complete | nessuna restrizione a nessun livello |
| 209 | `ufw` inattivo, regole del motore dei container | nessuna | uno, PostgreSQL pubblicato su tutte le interfacce | il database e' un contenitore, non il motore della macchina |
| Ollama | `ufw` inattivo, tabelle del motore dei container vuote | nessuna | nessuno attivo | due istanze del servizio, una locale e una esposta a tutta la LAN |
| 810 | `ufw` inattivo, regole del motore dei container | nessuna | cinque, due pile complete | i database non sono pubblicati, tutto il resto si |

### La restrizione della VM 204, trovata dov'era prevista

L'ipotesi del secondo livello era corretta. Su `/etc/nginx/sites-available/convertitore-ruolini` e sul gemello `-staging` compaiono quattro direttive `allow` seguite da un `deny all`: l'indirizzo di *loopback*, perche' il servizio sia provabile da dentro la macchina, e tre indirizzi della classe delle postazioni. Il meccanismo e' esattamente quello descritto sopra: la connessione viene stabilita e poi rifiutata a livello applicativo, e nessun comando di sistema la mostra.

Due cose vanno notate oltre al fatto in se'. La prima e' che la restrizione e' **duplicata** su due file, produzione e collaudo, il che significa che una modifica futura va fatta in due posti e che dimenticarne uno non produce nessun errore visibile. La seconda e' che gli indirizzi sono scritti come **valori letterali**, ed e' il punto in cui questa scoperta tocca il piano di segmentazione: vedi #171.

### Il gestore delle password, e il pezzo mancante del suo disegno

La misura chiude una domanda che #160 lasciava aperta, cioe' **come** il gestore sia servito. Il contenitore Vaultwarden espone la porta 80 soltanto verso l'interno della macchina e non e' pubblicato sull'host, il che e' corretto; davanti gli sta **Apache**, in ascolto sulla porta 80 su tutte le interfacce, senza alcun ascolto sulla 443.

Il disegno in `docs/cybersecurity-governance.md` prevedeva un proxy inverso con HTTPS e certificato interno. Il proxy inverso c'e', il HTTPS no, e cambia il server rispetto al progetto, che diceva nginx. Ne discende che il rimedio a #160 e' circoscritto e non richiede di rifare l'architettura: si aggiunge un host virtuale in ascolto sulla 443 con un certificato, si reindirizza la 80, e il contenitore non si tocca.

### Le due macchine senza alcuna restrizione, e quella che ne ha una parziale

Sulla VM 207 non esiste filtro a nessuno dei quattro livelli: le tabelle di `nftables` sono presenti ma vuote, `ufw` e' inattivo, Apache non ha direttive di ammissione, e il servizio applicativo e' in ascolto direttamente sull'indirizzo di LAN alla porta 8000. Il database, correttamente, sta su loopback. Sulla VM 602 la situazione e' la stessa, con in piu' dieci contenitori.

La VM 208 e' il caso piu' interessante perche' mostra che qualcuno **ha** ragionato sull'esposizione, ma a meta'. I suoi servizi di appoggio — il database, la cache, un servizio applicativo interno — sono pubblicati su `127.0.0.1`, quindi irraggiungibili dalla rete, ed e' la scelta giusta. Le porte 80 e 443 sono invece pubblicate su tutte le interfacce, il che e' voluto perche' il portale deve servire gli utenti, ed e' il difetto #121. C'e' pero' anche un processo Node in ascolto sulla porta 3000 su tutte le interfacce, che ha la forma di un ambiente di sviluppo accanto al servizio in esercizio, e va verificato.

### Il database del sito e' un contenitore, e la correzione costa una riga

La domanda che #161 lasciava aperta era se la porta 5432 in ascolto su tutte le interfacce appartenesse al motore PostgreSQL installato sulla macchina oppure alla pubblicazione di un contenitore. La misura risponde: e' un contenitore, `intrawelt-pg` sull'immagine ufficiale, pubblicato con la forma `0.0.0.0:5432->5432/tcp`, e in ascolto sull'host c'e' infatti il processo intermediario del motore dei contenitori e non il database.

La risposta e' una buona notizia operativa, perche' cambia il costo del rimedio. Non serve toccare la configurazione di PostgreSQL ne' riprogettare nulla: si cambia la forma della pubblicazione da `5432:5432` a `127.0.0.1:5432:5432` nella definizione del servizio, e il database smette di essere raggiungibile dalla rete restando raggiungibile dall'applicazione che gli sta accanto. E' lo stesso schema gia' applicato correttamente sulla VM 208 per il proprio database, la propria cache e il proprio servizio interno, il che dimostra che la conoscenza c'e' gia' in casa e che qui e' semplicemente mancata.

### L'host Ollama, e un servizio di inferenza aperto a tutta la LAN

Sull'host Ollama il servizio risulta in ascolto **due volte**: sulla porta predefinita `11434` legata al solo indirizzo locale, che e' la configurazione corretta, e sulla porta `11500` su tutte le interfacce, che e' raggiungibile da qualunque host della LAN piatta. Nessun filtro a nessuno dei quattro livelli.

Il punto merita una precisazione, perche' un servizio di inferenza non somiglia a un database e il rischio non e' intuitivo. L'interfaccia di programmazione di Ollama **non prevede autenticazione**: non e' che sia configurata male, e' che nel disegno del prodotto l'autenticazione non esiste, perche' e' pensato per essere in ascolto sul solo indirizzo locale. Chi lo raggiunge puo' quindi non soltanto sottoporre richieste, consumando la scheda grafica, ma anche elencare i modelli presenti, scaricarne di nuovi occupando lo spazio del disco, e **cancellarli**. La stessa interfaccia che serve l'applicazione serve anche l'amministrazione.

Ne discende che il rimedio non e' aggiungere una password, che non esiste, ma togliere l'ascolto dalla rete o metterci davanti qualcosa che autentichi. Tracciato come #173.

Sullo stesso host e' in ascolto anche il servizio di scrivania remota sulla porta 3389, su tutte le interfacce, che e' la stessa condizione gia' registrata per la VM 810 in #164.

### Un fatto trasversale che nessuna scheda mostra da sola

Su nessuno degli host il servizio SSH dichiara esplicitamente quali metodi di autenticazione accetti: la configurazione non contiene alcuna direttiva in merito, quindi valgono i valori predefiniti della distribuzione, che ammettono **anche l'autenticazione con password**. Letto da solo e' un dettaglio; letto insieme a #170, cioe' al fatto che alcune password sono condivise fra piu' macchine, e a #159, cioe' che la porta 22 e' raggiungibile da tutta la LAN piatta su tutte, diventa una via di movimento laterale che non richiede di violare nulla. Tracciato come #172.

### La VM 810, e la lezione sul come si sbaglia una diagnosi

Sulla VM 810 il censimento e' riuscito al secondo tentativo, e la causa del primo fallimento era la piu' banale delle due ipotesi: una password diversa digitata in quel momento, cosa non sorprendente su un parco dove alcune credenziali sono condivise e altre no (#170). La seconda ipotesi, cioe' l'assenza del sottosistema di trasferimento file, e' stata **verificata e smentita**: la copia con il protocollo storico e quella con il protocollo predefinito funzionano entrambe.

Vale la pena tenere il percorso della diagnosi invece del solo esito, perche' contiene due ipotesi sbagliate una dopo l'altra su un guasto che era banale. La prima, la politica che vieta l'accesso dell'utente amministratore con password, e' stata smentita da un comando; la seconda dal comando successivo. E' lo stesso schema descritto in #171: un messaggio di errore che non distingue le cause manda la diagnosi nel posto sbagliato, e in questo caso il messaggio diceva "copia non riuscita" senza dire perche'.

Sull'host risultano cinque contenitori: il servizio in esercizio sulla porta 8080, il gemello di collaudo sulla 8090, un proxy davanti a entrambi sulla porta 80, e **due database che non sono pubblicati** e quindi restano raggiungibili solo dai contenitori accanto, il che e' corretto. Il servizio di scrivania remota e' in ascolto sulla 3389 su tutte le interfacce, come gia' registrato.

I due database sono pero' su una versione del motore la cui serie e' fuori supporto da oltre due anni. Il fatto che non siano esposti alla rete ne riduce molto la portata, perche' per raggiungerli bisogna gia' essere dentro la macchina o dentro un contenitore accanto, ma non lo annulla: una vulnerabilita' del motore diventa sfruttabile appena qualcosa che gli sta accanto viene compromesso, ed e' esattamente la situazione di un ambiente di collaudo che convive con l'esercizio. Tracciato come #174.

### Due lezioni sullo strumento, da non ripetere

La prima riguarda l'etichetta dell'esito. Lo strumento marcava come parziale ogni censimento eseguito senza `sudo`, ma su un host a cui ci si collega gia' come amministratore il comando gira con tutti i privilegi e l'esito e' completo: sulla VM 810 i nomi dei processi e le regole del kernel c'erano tutti, e l'etichetta diceva il contrario. Ora la completezza si riconosce dal contenuto, cioe' dalla presenza dei nomi dei processi, che il kernel mostra soltanto a chi ha i privilegi, invece che dedurla dalla modalita' di esecuzione. E' una differenza di metodo che vale oltre questo strumento: si misura il risultato, non l'intenzione.

La seconda riguarda un ripiego che sembrava equivalente e non lo era. Per aggirare la copia si era proposto di passare lo script attraverso il flusso di ingresso di una sessione remota. Il comando fallisce con errori incomprensibili — righe non trovate e una struttura di controllo che sembra rotta — e la causa non e' lo script: quando PowerShell incanala il contenuto di un file verso un programma esterno, riscrive le terminazioni di riga nella convenzione di Windows, e una shell di sistema unix legge quel carattere in piu' come parte dell'ultimo comando di ogni riga. Da qui il metodo: verso un sistema unix si trasferiscono **file**, con una copia, non flussi di testo passati attraverso PowerShell.

## La VM 205, censita senza rete attraverso l'agente ospite

La macchina non risponde sulla porta 22 dalla postazione, ma e' accesa e il suo agente ospite risponde. Il primo settembre 2026 il censimento e' stato quindi eseguito **attraverso l'hypervisor** invece che attraverso la rete, con `qm guest exec`, ed e' una possibilita' che vale la pena registrare come metodo: quando una macchina virtuale non e' raggiungibile ma l'agente risponde, l'hypervisor e' una via di ispezione che non dipende dalla rete della macchina, e non richiede la console.

Cio' che espone: il servizio SSH sulla 22 e Apache sulla 80, entrambi su tutte le interfacce, piu' una porta 9001 pubblicata da un contenitore. Correttamente vincolati all'indirizzo locale il database MariaDB e il servizio di stampa. Il quadro e' quindi lo stesso delle altre macchine e non contiene sorprese.

### La diagnosi, chiusa il 01/09/2026: nessuna causa, e cinque ipotesi cadute

La sequenza merita di essere tenuta per intero, perche' cinque spiegazioni plausibili sono cadute una dopo l'altra e alla fine non ne e' rimasta nessuna. E' un esito scomodo da scrivere e per questo vale la pena scriverlo.

Non era spenta: l'hypervisor la riportava in esecuzione e l'agente eseguiva comandi. Non era un cambio di indirizzo: l'agente ha confermato lo stesso indirizzo che la postazione stava interrogando. Non era il servizio SSH fermo: risultava attivo e in ascolto su tutte le interfacce. Non era un filtro sulla macchina: `ufw` e' inattivo e nelle regole del kernel ci sono soltanto le catene del motore dei container, nessuna delle quali scarta traffico in ingresso verso l'host. E **non era un nome utente sbagliato**, che era l'ipotesi formulata per ultima: il censimento del 01/09 e' riuscito con lo stesso alias e lo stesso utente che il progetto usava dall'inizio.

Quell'ultima ipotesi era nata da un errore di prova, e va detto perche' e' il tipo di errore che si ripete. La verifica era stata fatta con un comando che non specificava l'utente, quindi il programma ne ha usato uno predefinito preso dal sistema della postazione, e il rifiuto che ne e' seguito riguardava quell'utente inesistente e non la configurazione. La prova misurava se stessa, non la macchina. Ne era discesa una conclusione sbagliata, corretta il giorno stesso.

Resta quindi la spiegazione piu' scomoda e l'unica compatibile con le misure: **il tempo scaduto del 31/08 era transitorio** e non e' riproducibile. Il progetto non sa perche' sia avvenuto, e questa scheda lo dichiara invece di attribuirlo a una causa plausibile scelta a posteriori. Va tenuto d'occhio: se si ripresenta, i due dati da raccogliere nel momento in cui accade sono se l'hypervisor riesca a raggiungerla e che cosa dica in quel momento la tabella degli indirizzi dello switch per la porta corrispondente, perche' entrambi si perdono appena la situazione si risolve.

Cio' che il difetto #162 registrava per questa macchina, cioe' credenziali perdute e macchina inaccessibile, era percio' **falso in entrambe le meta'**, ed e' stato corretto.

### Cosa espone la VM 205

Apache sulla porta 80 e il servizio SSH sulla 22, entrambi su tutte le interfacce, piu' la porta 9001 pubblicata dal proxy dell'applicativo. Correttamente non pubblicati, quindi raggiungibili solo dai contenitori accanto, il database PostgreSQL e la cache. Il database e' pero' su una versione la cui serie e' fuori supporto dalla fine del 2025, come i due della VM 810: vedi #174.

## La macchina Windows, censita il 31/08/2026, e l'assunzione che ha rovesciato

La VM 100 WinServer2022 non era nelle prime due passate perche' il comando usato e' scritto per Linux e nessuno dei tre strumenti esiste su Windows. Il censimento equivalente e' stato eseguito il 31/08/2026 dal desktop remoto, con i tre comandi PowerShell riportati piu' avanti.

### Il firewall c'e' ed e' spento, su tutti e tre i profili

Questa scheda aveva scritto, ragionando e non misurando, che su questa macchina "la domanda non e' se il filtro esista, ma quali eccezioni siano state aperte", perche' il firewall di Windows e' attivo per impostazione predefinita. **La misura dice l'opposto**: i tre profili, dominio, privato e pubblico, risultano tutti disattivati, e l'azione predefinita in ingresso non e' nemmeno configurata.

E' un'affermazione sbagliata dello stesso tipo di quella corretta il 31/08 sulle macchine Linux, e vale la pena notarlo perche' l'errore e' simmetrico e opposto: la' si era concluso "nessun filtro" avendo guardato un solo livello, qui si era concluso "un filtro c'e'" avendo guardato una documentazione di prodotto invece della macchina. In entrambi i casi il difetto non era nel dato ma nel fatto di non averlo chiesto.

Ne discende che le decine di regole in ingresso che la macchina ha configurate, e che il censimento elenca, **non hanno effetto**: sono un elenco di eccezioni a un blocco che non viene applicato. Chiunque le abbia scritte lavorava presupponendo un firewall acceso.

### Che cosa espone, e perche' e' la macchina piu' esposta del parco

La VM 100 e' un server multiservizio, e l'elenco di cio' che tiene in ascolto e' piu' lungo di quello di tutte le altre macchine messe insieme. Raggruppato per natura, senza le porte effimere del sistema:

| Ambito | Porte in ascolto | Nota |
|---|---|---|
| Condivisione file e nomi | 135, 139, 445 | il servizio di condivisione, legato ai due indirizzi della macchina |
| Web di sistema | 80, 443 | |
| Scrittorio remoto | 3389 | |
| Amministrazione remota Windows | 5985, 47001 | e' attivo, quindi la terza strada avrebbe funzionato |
| Gestione hardware HP | 2301, 2381 | console web di gestione del produttore, vedi sotto |
| Rilevazione presenze | 9000, 9002, 9010, 51212 | il server del sistema di controllo accessi, vedi sotto |
| Applicativi | 444 e 9510 (Java), 3002 (Node), 3312 (MySQL) | il database e' in ascolto su tutte le interfacce |
| Corretti, solo locali | 6379 (Redis), 49864 (SQL Server) | vincolati all'indirizzo locale, come dev'essere |

Tre voci meritano una riga propria e sono diventate altrettanti difetti. Il database MySQL sulla porta 3312 e' in ascolto su tutte le interfacce, quindi raggiungibile da chiunque sulla LAN piatta, ed e' l'unico servizio di questa macchina che abbia un rimedio a costo quasi nullo (#176). La console web di gestione dell'hardware del produttore, sulle porte 2301 e 2381, e' un componente storico che espone stato e configurazione del server e la cui superficie e' nota per essere problematica: va determinato se serva ancora a qualcuno (#175). E il **server del sistema di rilevazione presenze** vive qui (#177), il che chiude una domanda che il progetto aveva aperto da un'altra parte.

### Il sistema di rilevazione presenze era gia' noto per meta'

Il difetto NET-021 registrava l'unita' terminale del sistema di rilevazione presenze sulla porta 3 dello switch del Piano Terra, notando che si trattava di un apparato che tratta dati personali dei dipendenti, collegato alla LAN piatta e assente da ogni inventario. Mancava l'altra meta': **dove stia il server**. Sta sulla VM 100, in ascolto su quattro porte, su una macchina senza firewall.

Ne discende che il flusso dei dati di presenza attraversa per intero la LAN piatta, dal terminale al server, senza alcun filtro interposto in nessuno dei due estremi, e che i dati a riposo stanno su una macchina il cui perimetro e' aperto. E' un fatto che tocca il trattamento di dati personali e non solo la rete.

### I due indirizzi, e la conseguenza su M4

Il censimento mostra il servizio di condivisione file legato a **due indirizzi distinti** della stessa macchina, coerente con il fatto gia' documentato che la VM 100 ha due schede di rete su due bridge diversi, e che la seconda e' l'unica cosa attestata su `vmbr1`.

La conseguenza sul piano rafforza un vincolo gia' scritto su M5, e lo rende piu' stringente di quanto sembrasse. Quella seconda scheda non e' un residuo inattivo: porta il servizio di condivisione file, cioe' traffico che gli utenti usano. Quando la porta 7 del 54HP diventera' un trunk, la VLAN 1 dovra' restare **non taggata**, altrimenti si interrompe una condivisione di rete in uso, e il guasto si manifestera' come "le cartelle non si aprono piu'" senza che nessuno lo colleghi a un intervento sullo switch.

### I comandi usati

```powershell
Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction
Get-NetFirewallRule -Enabled True -Direction Inbound -Action Allow | Get-NetFirewallPortFilter | Where-Object LocalPort -ne "Any" | Select-Object -Unique Protocol,LocalPort | Sort-Object LocalPort
Get-NetTCPConnection -State Listen | Select-Object LocalAddress,LocalPort,@{n='Processo';e={(Get-Process -Id $_.OwningProcess).ProcessName}} | Sort-Object LocalPort
```

Il primo dice se i profili sono accesi e che cosa fanno per impostazione predefinita, il secondo elenca le eccezioni in ingresso attive, il terzo e' l'equivalente di `ss -tulpn` e aggiunge il nome del processo.

## I sette fatti che discendono dalla matrice, in ordine di quanto pesano

Il primo e' il gestore delle password della VM 202, che risponde sulla porta 80, cioe' in chiaro, e non ha nessun ascolto sulla 443. Va notato che questo fatto e' **indipendente** dalla correzione del 31/08: una lista di indirizzi ammessi, se anche esistesse su questa macchina, non renderebbe cifrato il traffico di chi e' ammesso. Un servizio che custodisce credenziali e che le trasmette senza cifratura su una rete dove ogni apparato e' adiacente a ogni altro e' il caso peggiore della matrice, perche' non richiede di violare nulla: chi si trovi in condizione di osservare il traffico legge le credenziali mentre passano, e la password principale del deposito passa di li' a ogni accesso. Tracciato come #160.

Il secondo e' PostgreSQL della VM 209, in ascolto sulla porta 5432 su tutte le interfacce. Non e' soltanto un'esposizione: e' anche una contraddizione con cio' che questo progetto affermava, perche' la fonte della mappa e la scheda del sito descrivevano quel database come residente sulla rete interna dei container e privo di un indirizzo proprio sulla LAN. La misura dice altro, la fonte e' stata corretta, e il fatto va letto come un caso di scuola di obsolescenza silenziosa: l'affermazione era vera quando fu scritta e ha smesso di esserlo senza che nulla la contraddicesse. Tracciato come #161.

Il terzo sono le due macchine su cui non si entra piu'. Sulla 205 la macchina non arriva alla schermata di accesso e la password va reimpostata; sulla 208 la password locale non e' piu' quella conosciuta. Il punto non e' il fastidio: e' che la 208 e' il portale asset, cioe' proprio il servizio che il piano di segmentazione deve spostare per primo, e non lo si puo' ne' ispezionare ne' riconfigurare finche' non vi si rientra. La reimpostazione su una macchina virtuale Proxmox si fa dalla console, avviando in modalita' di manutenzione, ed e' un intervento con interruzione di servizio da programmare. Tracciato come #162.

Il quarto sono gli ambienti di prova esposti accanto alla produzione. Sulla 602 convivono due pile complete di Intralino, quella in esercizio sulle porte 80, 443 e 5443 e quella di test sulle 4443 e 5444, entrambe raggiungibili da chiunque; sulla 810 la stessa cosa con `getrad-app` sulla 8080 e `getrad-test-app` sulla 8090. Un ambiente di prova ha per definizione dati di prova, credenziali deboli e correzioni non ancora applicate, e non ha ragione di essere raggiungibile da tutta l'azienda. Tracciato come #163.

Il quinto e' il servizio di scrivania remota `xrdp` sulla porta 3389 della VM 810, in ascolto su tutte le interfacce. E' un canale di accesso interattivo completo alla macchina, esposto all'intera LAN piatta, su una macchina che e' un ambiente di prova di una migrazione. Tracciato come #164.

Il sesto e' la versione di sistema della VM 602, Ubuntu 25.10. Le versioni intermedie di Ubuntu, cioe' quelle che non sono LTS, hanno nove mesi di supporto, il che collocherebbe la fine del supporto di questa a luglio 2026, quindi gia' trascorsa. Il dato va confermato sulla pagina del ciclo di vita del fornitore prima di essere trattato come fatto, ma se confermato significa che la macchina che ospita Intralino non riceve piu' aggiornamenti di sicurezza. Tracciato come #165, con la sua riserva scritta.

Il settimo e' minore e riguarda l'igiene: quattro macchine distinte rispondono con lo stesso nome host, `Ubuntu24`. Non produce un guasto, ma rende ambiguo ogni registro, ogni traccia di accesso e ogni diagnosi che si appoggi al nome invece che all'indirizzo. Tracciato come #166.

A questi si aggiunge il fatto trasversale, che e' il primo in ordine di gravita' e ha un codice proprio: l'assenza del firewall di sistema su tutte e sette le macchine, tracciata come #159.

## Il limite della prima passata, superato dalla seconda

Nella prima passata il comando era stato eseguito da un utente non privilegiato su sei macchine su sette. L'elenco delle porte in ascolto era comunque completo e affidabile, perche' quel dato il kernel lo espone a chiunque; mancavano invece il nome del processo che tiene aperta ciascuna porta e l'elenco dei contenitori, e su tre macchine la risposta "nessun docker" era un errore di permessi e non un'assenza, come dimostrava la presenza delle reti interne del motore.

Il limite e' superato: la seconda passata del 31/08/2026 e' stata eseguita con privilegi su tutti e otto gli host raggiunti, e la sezione §L'esito della seconda passata contiene sia cosa e' esposto sia chi lo espone. Il paragrafo resta come promemoria del fatto che un censimento senza privilegi risponde a meta' della domanda, e che meta' risposta su una superficie di attacco somiglia troppo a una risposta intera.

## Perche' i container complicano il quadro, e va saputo prima di installare un filtro

Quando un container pubblica una porta, il motore dei container non si limita ad avviare un processo in ascolto: inserisce regole proprie nella tabella di traduzione degli indirizzi del kernel, e quelle regole vengono valutate prima della catena su cui `ufw` opera. La conseguenza pratica e' che, su una macchina con container che pubblicano porte, installare `ufw` e negare una porta puo' produrre uno stato che dichiara la porta negata mentre il servizio continua a rispondere.

Riguarda direttamente questa infrastruttura, perche' la 810 pubblica tre porte da container e la 602 ne pubblica cinque, e con ogni probabilita' anche la 209 e la 206, la cui lista di container non e' stata leggibile. Ne discende che il rimedio host-based su quelle macchine non e' una regola di `ufw`, ma un intervento sulla pubblicazione stessa: un container che deve servire solo la macchina si pubblica su `127.0.0.1` invece che su tutte le interfacce, ed e' una modifica di una riga nella definizione del servizio che non richiede nessun filtro.

## Che cosa questo cambia nel piano di segmentazione

Tre cose, e nessuna delle tre annulla il lavoro gia' fatto.

La prima e' che la segmentazione resta il livello dove mettere una decisione **governabile** fra due macchine. Le restrizioni che esistono oggi, come quella della VM 204, sono reali ma vivono ciascuna dentro la macchina che proteggono, scritte in posti diversi con sintassi diverse: non si leggono da un punto solo, non si verificano tutte insieme, e nessuno se ne accorge se una viene rimossa. Il firewall di rete non sostituisce quelle restrizioni e non le rende inutili, aggiunge il livello che oggi manca, cioe' quello ispezionabile e uniforme.

La seconda e' che il vincolo dell'IT Manager si applica con un dato in mano invece che a memoria, e con un rischio in piu' rispetto a quanto scritto il 28/08. Quando una macchina cambia segmento cambia anche indirizzo, e ogni lista di indirizzi ammessi che la riguardi smette di funzionare: sulla VM 204 gli ammessi sono la postazione dell'IT Manager e due indirizzi della fascia `.70`, e se una di quelle postazioni finisse in un segmento diverso il convertitore le rifiuterebbe. Il guasto sarebbe per giunta silenzioso, perche' il servizio continuerebbe a rispondere e l'errore somiglierebbe a un problema applicativo. Ne discende che la seconda passata non e' una rifinitura del censimento ma un prerequisito della segmentazione: le liste vanno trovate tutte **prima** di toccare gli indirizzi, e aggiornate nello stesso intervento.

La terza e' che alcuni rimedi non aspettano la segmentazione e conviene farli prima, perche' costano poco e riducono la superficie: portare il gestore delle password su HTTPS, ripubblicare su loopback i container che servono solo la propria macchina, spegnere gli ambienti di prova quando non servono o vincolarli a un indirizzo, e chiudere `xrdp` sulla 810. Sono candidati naturali al registro degli interventi non bloccanti di `docs/interventi-robustezza.md`.

## Il comando della seconda passata, e che cosa chiede a ciascun livello

Legge e non scrive nulla, e va eseguito come amministratore su ciascuna macchina Linux. Rispetto alla prima passata aggiunge il nome dei processi, la lista dei contenitori, la configurazione di autenticazione del servizio SSH, e soprattutto i tre livelli di filtro che `ufw` non vede.

Dal 31/08/2026 non si incolla a mano: vive in `scripts/censimento-host.sh` e si lancia dalla postazione con `scripts/Invoke-HostCensus.ps1`, che lo copia su ciascun host indicato, lo esegue e raccoglie l'esito in `output/`. La ragione non e' la comodita': un comando con apici annidati passato attraverso PowerShell e poi attraverso una shell remota si rompe per citazione prima ancora di essere sbagliato nel merito, e nove ripetizioni a mano sono nove occasioni di sbagliarne una in silenzio. Gli host si indicano con gli alias del `~/.ssh/config` della postazione, che non fa parte di questo repository, quindi lo script non contiene indirizzi.

```powershell
.\scripts\Invoke-HostCensus.ps1 -Target odoo-vm, pwmanager-vm, wordpress-vm, vm207, intralino, asset-vm
```

Il contenuto dello script, per chi voglia leggerlo senza aprirlo, e' il seguente.

```sh
sudo sh -c '
echo "=== $(hostname) | $(hostname -I) ==="
echo "--- 1. filtro del kernel ---"
ufw status verbose 2>/dev/null || echo "ufw: non installato"
nft list ruleset 2>/dev/null | head -60 || echo "nftables: nessuna regola o comando assente"
iptables -S 2>/dev/null | grep -v "^-P" | head -40 || echo "iptables: nessuna regola"
echo "--- 2. server web: direttive di ammissione ---"
grep -rniE "^[[:space:]]*(allow|deny)[[:space:]]" /etc/nginx /etc/apache2 /etc/httpd 2>/dev/null | head -40 || echo "nessuna direttiva allow/deny trovata"
echo "--- 3. porte in ascolto, con il processo ---"
ss -tulpn | grep -E "LISTEN|UNCONN"
echo "--- 4. contenitori ---"
docker ps --format "{{.Names}} | {{.Image}} | {{.Ports}}" 2>/dev/null || echo "nessun docker"
'
```

La sezione 2 e' quella che sulla VM 204 dovrebbe far comparire la lista degli indirizzi ammessi. Se non compare li' e nemmeno nella sezione 1, allora la restrizione vive nel terzo livello, cioe' dentro l'applicazione, e va cercata nella sua configurazione: in quel caso il comando non la trovera' e il fatto va accertato leggendo il codice o la configurazione del convertitore.

## Come si rientra nelle due macchine chiuse

Vale per la VM 205, che non raggiunge la schermata di accesso, e per la VM 208, la cui password locale non e' piu' valida. Sono due situazioni diverse e le vie sono due, in ordine di quanto costano.

La prima via non richiede alcun riavvio e va provata per prima. Se dentro la macchina e' installato e funzionante l'*agente ospite*[^agente], l'hypervisor puo' impostare la password di un utente senza toccare l'avvio. Le due macchine hanno l'agente **abilitato nella configurazione**, il che e' condizione necessaria ma non sufficiente: che il servizio stia girando dentro la macchina va verificato, e il primo comando serve a quello. Dalla riga di comando dell'host Proxmox:

```
qm agent 208 ping
qm guest passwd 208 <nomeutente>
```

Se il primo comando risponde senza errore, l'agente c'e' e il secondo chiede la password nuova in modo interattivo e la imposta. Se il primo da' errore, l'agente non risponde e questa via non e' percorribile.

La seconda via passa dall'avvio della macchina e comporta un'interruzione di servizio, quindi va programmata. Si apre la console della macchina dall'interfaccia di Proxmox, si riavvia, e alla comparsa del menu di avvio si preme `e` per modificare temporaneamente la riga di avvio del kernel: alla fine della riga che comincia con `linux` si aggiunge `init=/bin/bash`, poi si avvia con `Ctrl+X`. Il sistema parte con una shell di amministratore senza chiedere credenziali; il disco pero' e' montato in sola lettura, quindi prima di cambiare la password va rimontato in scrittura.

```
mount -o remount,rw /
passwd <nomeutente>
exec /sbin/init
```

La modifica alla riga di avvio non e' permanente e non lascia traccia: al riavvio successivo il menu torna com'era. Su questa procedura vanno detti due limiti, perche' e' proprio la sua semplicita' il punto. Il primo e' che funziona solo con accesso alla console, che nel caso di una macchina virtuale coincide con l'accesso all'hypervisor, ed e' quindi tanto sicura quanto lo e' l'accesso a Proxmox. Il secondo e' che non funziona se il disco e' cifrato, nel qual caso serve la chiave e non c'e' scorciatoia.

Per la VM 205, che non arriva alla schermata di accesso, la seconda via e' comunque necessaria, ma con un passo in piu': prima di cambiare la password conviene capire perche' non arrivi, e la risposta si legge nei registri dell'avvio con `journalctl -b -p err` una volta ottenuta la shell.

Nota di igiene che discende da #162: prima di reimpostare le due password va deciso **dove finiranno**, perche' il deposito delle credenziali di questa infrastruttura e' la VM 202, che oggi risponde in chiaro (#160). Mettere due password nuove dentro un deposito servito senza cifratura riproduce il problema invece di chiuderlo, quindi la sequenza corretta e' prima HTTPS sulla 202, poi la reimpostazione.

## La dismissione della VM 206, e le tre cose da controllare quando una macchina sparisce

Il 31/08/2026 l'IT Manager ha spento e distrutto la VM 206 `intrasite`, con `qm destroy 206 --purge`, dichiarando che non serve piu' per il momento. La macchina era la copia uno a uno del rifacimento del sito commissionato all'agenzia, tenuta come riferimento di contenuto e di marchio, e stava su `vmbr2` insieme alla VM 209.

Il presupposto e' verificato e non riferito: sul NAS, sotto `Backup/dump`, esistono copie `vzdump-qemu-206` datate 16/06, 26/07, 23/08, 29/08, 30/08 e **31/08/2026 alle 06:44**, ciascuna di circa venti gigabyte, con il rispettivo file di annotazioni. La copia piu' recente e' quindi dello stesso giorno della dismissione, presa poche ore prima. Vale la pena registrare il dettaglio perche' e' cio' che distingue una dismissione da una perdita di dati, e perche' fra sei mesi nessuno si ricordera' che il backup c'era.

L'opzione `--purge` merita una riga, perche' e' quella che rende l'operazione piu' pulita e insieme piu' definitiva. Senza di essa Proxmox rimuove la macchina ma lascia dietro i riferimenti che altri oggetti della configurazione le fanno, in particolare le voci nei job di backup e nelle regole di replica, che continuano a puntare a una macchina che non esiste e producono errori a ogni esecuzione. Con `--purge` quei riferimenti vengono rimossi insieme alla macchina, i dischi compresi. Ne discende che il ripristino non e' un annullamento ma un'operazione a se': si ricrea la macchina dal file di backup, e va rifatto a mano cio' che stava fuori dal disco, cioe' l'appartenenza ai job.

Tre cose vanno controllate quando una macchina virtuale sparisce, e valgono come procedura per le prossime volte.

La prima e' **chi la cercava**. Un indirizzo che smette di rispondere non produce un errore leggibile in chi lo interrogava: produce un timeout, che somiglia a un problema di rete. Della 206 va quindi verificato se qualche postazione avesse un riferimento nel proprio file `hosts`, come la documentazione registra, e se qualche altro servizio la chiamasse.

La seconda e' **cosa resta acceso al suo posto**. L'indirizzo che occupava torna libero e potra' essere riassegnato: se qualcuno tiene un riferimento vecchio, in futuro raggiungera' una macchina diversa da quella che si aspetta, che e' peggio di un timeout perche' risponde.

La terza e' la **documentazione derivata**. La macchina compariva nella fonte della mappa, nella matrice di questa scheda, nel diagramma di `.claude/context/diagrams/`, nella scheda dei bridge e in quella della segmentazione: se la si toglie da una sola, le altre continuano a descrivere una macchina che non esiste, ed e' il modo tipico in cui una documentazione comincia a mentire. Le occorrenze sono state aggiornate tutte nella stessa sessione.

## Reimpostare le password delle altre macchine, e dove vanno a finire

La procedura con l'agente ospite funziona su qualunque macchina virtuale in cui l'agente sia installato e in esecuzione, ed e' stata usata con successo sulla VM 208 il 31/08/2026. Due precisazioni prima di applicarla in serie.

La prima riguarda quando una rotazione serva davvero, e su questo punto la scheda si e' corretta in giornata. Una rotazione ha senso quando la credenziale e' stata esposta, quando e' condivisa, quando non rispetta il criterio di robustezza adottato, o quando esce qualcuno che la conosceva. Il 31/08/2026 l'IT Manager ha chiarito che **alcune password sono condivise fra piu' macchine**, il che fa ricadere il caso nella seconda condizione ed e' la ragione per cui voleva cambiarle: la rotazione qui non e' facoltativa, e' il rimedio a #170. Quante e quali siano condivise non e' pero' ancora determinato, ed e' la prima cosa da scrivere nel registro senza valori.

Una credenziale condivisa annulla il confine fra le macchine, perche' chi la ottiene su una qualunque le ottiene tutte senza dover violare nient'altro. Sommata ai difetti gia' registrati — il gestore che risponde in chiaro (#160), il servizio SSH esposto a tutta la LAN piatta senza filtro uniforme (#159), un ambiente di prova con credenziali deboli sullo stesso segmento della produzione (#163) — significa che la superficie non e' la somma delle macchine ma il loro prodotto. Va anche detto che **la segmentazione da sola non lo risolve**, perche' separa i segmenti e non le identita': sono due lavori diversi e nessuno dei due sostituisce l'altro.

Ne discende pero' un ordine, ed e' il motivo per cui la rotazione non e' il prossimo passo: cambiare dieci password uguali in dieci password diverse richiede un posto dove custodirle, altrimenti si producono nove credenziali che nessuno ricordera'. Prima l'HTTPS sul gestore (#160), poi la rotazione con valori distinti, poi il deposito.

La seconda e' una conseguenza della procedura stessa che vale la pena rendere esplicita, perche' cambia il modello di fiducia dell'infrastruttura e non e' ovvia. `qm guest passwd` imposta la password di un utente **senza conoscere quella precedente**: non e' un difetto dello strumento, e' il potere legittimo di chi amministra l'hypervisor, che possiede i dischi delle macchine e potrebbe comunque montarli. Ne discende pero' un fatto che nessun documento del progetto aveva scritto: **chi ha accesso amministrativo a Proxmox ha, di fatto, accesso a ogni macchina virtuale dell'azienda**, compresa quella che ospita il gestore delle password, e puo' ottenerlo in un comando senza lasciare traccia dentro la macchina bersaglio. La protezione del gestore delle password non e' quindi piu' forte della protezione dell'accesso a Proxmox. Tracciato come #169.

### Dove si depositano, e cosa non va fatto

Il posto giusto esiste gia' ed e' progettato: il gestore delle password sulla VM 202, la cui architettura e' descritta in `docs/cybersecurity-governance.md` come Vaultwarden dietro un proxy inverso con HTTPS, autenticazione a due fattori obbligatoria e vault condivisi per area. La misura del censimento dice pero' che di quel disegno manca proprio il pezzo che lo rende utilizzabile: la macchina risponde sulla porta 80 e non ha alcun ascolto sulla 443, quindi oggi il deposito viaggia in chiaro. E' il difetto #160, e questa e' la sua conseguenza pratica: **finche' non e' chiuso, depositare le credenziali nel gestore le espone invece di proteggerle**, perche' un gestore servito senza cifratura trasmette in chiaro, a ogni accesso, sia la password principale sia tutte quelle che custodisce.

Ne discende una sequenza obbligata, ed e' la ragione per cui #160 e' il primo intervento della lista e non uno dei tanti. Prima si chiude l'HTTPS sulla VM 202, poi vi si depositano le credenziali, e solo allora la reimpostazione in serie ha un senso, perche' ha una destinazione.

Tre cose che non vanno fatte, e la prima riguarda direttamente il modo in cui si lavora con un assistente. Le password **non si scrivono in una conversazione** e **non si mettono in un file che l'assistente legge**: la conversazione resta nella trascrizione della sessione finche' non viene cancellata, e un file letto entra nel contesto e da li' puo' finire in un riassunto. Questo progetto non ha mai bisogno del valore di una credenziale: gli serve sapere che esiste, a quale macchina e a quale utenza si riferisce, e dove e' custodita. Non vanno scritte in un file di testo o in un foglio di calcolo su una condivisione, che e' il modo in cui una credenziale sopravvive alla persona che l'ha scritta e diventa leggibile da chiunque abbia accesso alla cartella — lo stesso schema gia' registrato in #126 per le utenze memorizzate nelle multifunzione. E non vanno lasciate nella cartella dei download o nelle foto delle etichette degli apparati, come annotato piu' volte nella mappa privata.

### Il gestore non e' ancora in uso, e questo cambia la ragione dell'urgenza

Precisato dall'IT Manager il 01/09/2026: il gestore delle password della VM 202 e' installato ma **non e' ancora utilizzato**. Il fatto va registrato perche' corregge la valutazione del rischio di #160 in una direzione e la conferma nell'altra.

Nella direzione che attenua: se nessuno vi accede, oggi non transita in chiaro nessuna credenziale, quindi non esiste una fuga in corso. La descrizione del difetto va letta come "cio' che accadrebbe appena qualcuno cominciasse a usarlo" e non come "cio' che sta accadendo". La gravita' resta alta perche' la macchina e' predisposta e l'adozione e' prevista, ma il difetto e' **latente** e non attivo.

Nella direzione che conferma, ed e' quella che conta per la sequenza: proprio perche' non e' ancora in uso, **e' adesso che sistemarlo costa meno**. Farlo oggi significa aggiungere un host virtuale in ascolto sulla porta cifrata e un certificato a un servizio che nessuno sta usando, quindi senza finestra di interruzione da concordare, senza avvisare nessuno e senza nulla da rimediare a posteriori. Farlo dopo l'adozione significherebbe la stessa modifica piu' la rotazione di tutto cio' che nel frattempo e' stato depositato, perche' ogni credenziale inserita su un canale in chiaro va considerata esposta. La differenza fra i due momenti non e' di comodita' ma di quantita' di lavoro, e cresce ogni giorno che il gestore resta li' pronto.

Ne discende anche che l'ordine "prima HTTPS, poi deposito, poi rotazione" non e' cautela eccessiva: e' l'unico ordine che evita di fare due volte lo stesso lavoro.

### Il registro senza valori, che e' cio' che serve al progetto

Cio' che manca e che si puo' tenere fin da subito, anche prima dell'HTTPS, e' l'inventario delle credenziali **senza le credenziali**: per ogni macchina, quale utenza esiste, se la password e' nota, dove e' custodita e quando e' stata cambiata l'ultima volta. E' il rimedio a #168, costa poco e non contiene nulla di sensibile, tanto che potrebbe stare in un file tracciato; resta comunque in `_notes/` perche' l'elenco delle utenze e' informazione operativa che non serve a nessuno fuori.

Il modello e' `_notes/registro-credenziali.md`, con una colonna per lo stato e nessuna per il valore. Lo produce anche `scripts/Invoke-HostCensus.ps1` nella sua forma minima, cioe' l'elenco degli host su cui la password non e' risultata disponibile.

## La ricognizione TLS del 01/09/2026, e cio' che ha rovesciato

La ricognizione doveva rispondere a una domanda di dettaglio, cioe' come aggiungere HTTPS al gestore delle password. Ha risposto a una domanda diversa e piu' importante: **il gestore delle password non e' raggiungibile dalla rete, e cio' che risponde sulla porta 80 della VM 202 e' un altro servizio.**

### Come si e' stabilito, e perche' i tre indizi convergono

Il contenitore del gestore dichiara la propria porta come `80/tcp`, **senza alcuna corrispondenza verso l'host**. E' una distinzione che nella lettura di un elenco di contenitori si perde facilmente e che qui e' decisiva: una porta scritta come `0.0.0.0:443->443/tcp` e' pubblicata, cioe' l'host la offre alla rete; una porta scritta come `80/tcp` e' soltanto **dichiarata**, cioe' il contenitore la usa al proprio interno e nessuno da fuori la raggiunge. Il gestore e' nel secondo caso.

Restava la possibilita' che un server web lo raggiungesse per conto proprio, ed e' l'ipotesi che questa scheda aveva scritto. La ricognizione la esclude in due modi indipendenti. Gli host virtuali attivi di Apache sono due, e nessuno dei due ha a che vedere con il gestore: uno e' il sito predefinito dell'installazione, l'altro serve un applicativo di gestione dei ticket. E soprattutto **il modulo di inoltro non e' caricato**: dei moduli cercati risulta attivo il solo modulo di riscrittura, quindi Apache non solo non inoltra verso il gestore, ma non ne sarebbe tecnicamente capace nella configurazione attuale.

Ne discende anche perche' il supporto cifrato non e' semplicemente disattivato ma **assente**: il file delle porte contiene un'istruzione per l'ascolto sulla porta cifrata, ma racchiusa in una condizione che si avvera solo se il modulo corrispondente e' caricato, e non lo e'. Sulla macchina non esiste alcun certificato, ne' alcuna autorita' interna fra quelle considerate attendibili dal sistema.

### La correzione a #160, e perche' era un errore di lettura

Il difetto affermava che il gestore delle password fosse servito in chiaro a tutta la LAN e che la password principale vi transitasse a ogni accesso. **Non e' vero, e non lo e' mai stato.** L'affermazione nasceva da un'inferenza fatta su due dati veri messi insieme male: sulla macchina c'era un contenitore del gestore, e sulla macchina c'era Apache in ascolto sulla porta 80. Da li' si era concluso che il secondo servisse il primo, senza verificarlo.

E' il terzo errore dello stesso tipo in una settimana, dopo quello sull'assenza di filtri e quello sul firewall di Windows, e i tre hanno la stessa forma: una conclusione plausibile tratta da una misura parziale, senza fare la misura che l'avrebbe confermata o smentita. Vale la pena registrarlo come schema e non come episodio, perche' la lezione operativa e' precisa: quando due fatti veri suggeriscono un collegamento, il collegamento e' un terzo fatto e va misurato a parte.

Il difetto riformulato e' piu' modesto e piu' utile: il gestore delle password e' **installato e non collegato**. Non c'e' nessuna fuga in corso, nemmeno potenziale, perche' non c'e' nessun accesso. Cio' che manca per renderlo utilizzabile e' l'intera catena: il modulo di inoltro, il modulo cifrato, un host virtuale che punti al contenitore, un certificato e un nome. Coerente, del resto, con la dichiarazione dell'IT Manager che non e' ancora in uso: non lo e' perche' non e' mai stato collegato.

### Il servizio che nessuno aveva censito: la gestione dei ticket

Sulla porta 80 della VM 202 risponde un applicativo di **gestione dei ticket di assistenza**, con un host virtuale dedicato e una radice propria. Nessun documento di questo progetto lo conosceva: la macchina era censita come "gestore delle password" e basta.

Non e' un dettaglio di inventario. Un sistema di ticket contiene per natura descrizioni di problemi, nomi di richiedenti, allegati e non di rado credenziali incollate da un utente dentro una segnalazione; e' quindi un archivio di dati personali e talvolta di segreti, servito in chiaro a tutta la LAN piatta su una macchina senza filtro. Ed e' anche il secondo caso, dopo l'host di inferenza, di un servizio che esisteva e che nessun inventario conteneva. Tracciato come #178.

### Un limite dello strumento, dichiarato

La ricognizione ha guardato dentro il sistema operativo dell'host e non dentro i contenitori. Sulla macchina di IntraLino non ha trovato alcun certificato, ma quella macchina **serve traffico cifrato**, perche' il suo contenitore di inoltro pubblica la porta cifrata verso la rete: il certificato esiste e vive dentro il contenitore, dove lo sguardo dello strumento non arriva.

E' esattamente il certificato a cui l'IT Manager si riferiva, e la sua natura resta quindi da determinare. La domanda che conta e' se sia autofirmato dal contenitore, cioe' il caso comune, oppure emesso da un'autorita' gia' esistente, nel qual caso non ci sarebbe nulla da creare.

## Certificato per servizio o autorita' interna: la domanda posta il 01/09/2026

L'IT Manager ha osservato che su alcune macchine un certificato esiste gia', per esempio su quella di IntraLino dove e' la macchina stessa a fornirlo, e ha chiesto se non sia quella la scelta giusta. La domanda va sciolta prima di generare il primo certificato per il gestore delle password, perche' le due strade divergono al primo comando e tornare indietro costa il doppio.

### Che cosa fa davvero un certificato, e perche' il browser si lamenta

Un certificato TLS assolve a due compiti distinti, e nel linguaggio comune vengono confusi. Il primo e' **cifrare** il traffico, e per questo basta un certificato qualunque, anche generato in dieci secondi dalla macchina stessa: la cifratura funziona identica. Il secondo e' **dimostrare l'identita'** di chi risponde, cioe' garantire che dietro quel nome ci sia davvero la macchina che ci si aspetta e non qualcuno che si e' messo in mezzo, e per questo la cifratura non basta.

L'identita' si dimostra con una firma. Il certificato porta la firma di qualcuno, e il browser lo accetta senza protestare solo se quel qualcuno e' nel suo elenco di firmatari attendibili. Un certificato **autofirmato** e' un certificato che si firma da solo, cioe' afferma la propria identita' appellandosi a se stesso: e' esattamente per questo che il browser mostra un avviso, e l'avviso non e' un tecnicismo fastidioso ma la descrizione corretta della situazione, cioe' che nessuno indipendente garantisce quell'identita'.

Ne discende che, di fronte a un avviso, l'utente ha due sole possibilita': cliccare per proseguire, imparando a ignorare un avviso di sicurezza, oppure installare quel singolo certificato fra quelli attendibili della propria postazione. La prima possibilita' e' la peggiore di tutte, e vale la pena dire perche': un utente abituato a superare l'avviso lo superera' anche il giorno in cui l'avviso e' vero, cioe' il giorno in cui qualcuno si e' davvero messo in mezzo. La cifratura senza identita' verificata protegge da chi ascolta e non da chi si sostituisce.

### La differenza fra le due strade sta nel numero di volte

Con i **certificati autofirmati per servizio**, ogni servizio genera il proprio e ogni postazione deve installare quel certificato per non vedere l'avviso. Con `n` servizi e `m` postazioni le installazioni sono `n` per `m`, e crescono ogni volta che nasce un servizio.

Con una **autorita' di certificazione interna**, si genera una volta sola un certificato di autorita', lo si installa una volta sola su ogni postazione fra i firmatari attendibili, e da quel momento ogni certificato che quell'autorita' firma viene accettato senza avvisi. Le installazioni sono `m`, una per postazione, e non crescono mai piu': un servizio nuovo ottiene un certificato firmato e funziona ovunque il giorno stesso.

Il costo si ribalta quindi con il numero di servizi. Con un servizio solo l'autofirmato e' piu' semplice; a partire da tre o quattro l'autorita' interna e' piu' semplice, e la differenza cresce.

### Perche' in questo caso la risposta e' l'autorita' interna

I servizi interni che avranno bisogno di un certificato non sono uno. Ci sono gia' il gestore delle password, il portale asset, IntraLino, l'applicativo di pianificazione, e ci saranno il proxy inverso della DMZ e i servizi che vi verranno pubblicati. Sono almeno cinque, e il piano di segmentazione ne prevede altri.

C'e' pero' una ragione piu' forte del conteggio, e riguarda cio' che questo progetto sta facendo adesso. Il piano di segmentazione spostera' i servizi su segmenti diversi, il che significa che **cambieranno indirizzo**. Un certificato autofirmato generato oggi per un indirizzo diventa sbagliato quando quell'indirizzo cambia, esattamente come le liste di indirizzi letterali del difetto #171, e va rigenerato e reinstallato su ogni postazione. Un'autorita' interna emette invece certificati per **nomi**, e un nome puo' continuare a valere quando l'indirizzo dietro di esso cambia: e' la stessa ragione per cui la segmentazione ha bisogno di una risoluzione dei nomi che funzioni.

E qui la decisione tocca una dipendenza che non va scoperta a meta' lavoro.

### La dipendenza che va dichiarata: senza nomi, i certificati funzionano male

Un certificato certifica un **nome**, non una macchina. Il browser confronta il nome che ha digitato l'utente con quello scritto nel certificato, e se non coincidono protesta anche quando il certificato e' firmato da un'autorita' attendibile.

Su questa rete i nomi interni non hanno oggi un servizio che li risolva: il micro-step M25 registra che la risoluzione dei nomi interni non e' consolidata, e la documentazione di una delle macchine descrive un servizio raggiunto per nome grazie al file degli host di una singola postazione, che e' l'equivalente moderno di un foglietto attaccato a un monitor. E' possibile emettere certificati per indirizzi anziche' per nomi, ma e' una strada peggiore in tre modi: l'indirizzo cambia con la segmentazione, alcuni strumenti la supportano male, e soprattutto rinuncia proprio a cio' che rende utile un'autorita' interna.

Ne discende una precedenza che va detta adesso e non a meta' lavoro: **prima si decide come si chiamano i servizi interni e chi risolve quei nomi, poi si emettono i certificati**. Non serve completare M25 per intero, serve stabilire il suffisso interno e il modo di risolverlo. Se la scelta ricadesse sul file degli host delle postazioni, resterebbe una soluzione fragile ma sufficiente a non sprecare i certificati.

### Il quadro va misurato prima di essere deciso

L'osservazione dell'IT Manager sul certificato gia' presente su una macchina va verificata prima di trarne conclusioni, perche' le due cose che potrebbero esserci sono diverse e si somigliano. Potrebbe essere un certificato autofirmato dal servizio stesso, che e' il caso comune e non costituisce un'autorita'. Oppure potrebbe esistere davvero un'autorita' interna gia' generata, magari per un altro progetto, e in quel caso non c'e' nulla da creare e la strada e' gia' aperta.

La distinzione si legge nei campi pubblici del certificato: se soggetto ed emittente coincidono e' autofirmato; se esiste un certificato marcato come autorita' di certificazione, allora un'autorita' c'e'. La ricognizione si fa con `scripts/ispeziona-tls.sh`, che stampa quei campi e non tocca mai le chiavi private.

## L'autorita' interna esiste gia', ed e' di un progetto: la sonda del 01/09/2026

La sonda dalla rete ha risposto alla domanda lasciata aperta. Il certificato che serve il traffico cifrato di IntraLino, su entrambe le porte cifrate che quella macchina pubblica, **non e' autofirmato**: soggetto ed emittente sono distinti, e l'emittente e' un'autorita' di certificazione interna creata per quel progetto. Il certificato e' valido fino alla meta' del 2028 ed e' emesso per un nome semplice, senza alcun suffisso di dominio.

Esiste quindi gia' in azienda la capacita' di emettere certificati, ed e' una buona notizia: significa che qualcuno ha gia' fatto il lavoro di generare un'autorita' e di firmarci un certificato, quindi la strada e' praticata e non teorica. Non significa pero' che quell'autorita' sia gia' l'autorita' aziendale, e le ragioni sono tre.

### Prima domanda: chi custodisce la chiave, che e' la piu' importante di tutte

Una chiave di autorita' non e' una credenziale come le altre e vale la pena dire perche', perche' e' la ragione per cui questa domanda viene prima delle altre due. Chi possiede la chiave privata di un'autorita' puo' emettere un certificato valido per **qualunque nome**, e ogni macchina che consideri attendibile quell'autorita' lo accettera' senza un avviso. Non serve compromettere il servizio bersaglio: basta la chiave, e da quel momento ci si puo' presentare come qualunque servizio interno, gestore delle password compreso.

Ne discende che una chiave di autorita' e' piu' sensibile di qualunque credenziale di servizio, perche' le contiene tutte. Di questa non si sa dove risieda, se sia protetta da una passphrase, chi vi abbia accesso e se ne esista una copia. Finche' quelle risposte mancano, adottarla come autorita' aziendale significherebbe estendere a tutta l'azienda una fiducia di cui non si conosce il fondamento. Tracciato come #179.

### Seconda domanda: il nome, che rimanda alla dipendenza gia' dichiarata

Il certificato e' emesso per un nome semplice, senza suffisso di dominio, ed e' coerente con il fatto che i nomi interni di questa rete non abbiano oggi un servizio che li risolva. Funziona finche' quel nome viene risolto a mano sulle postazioni che lo usano, ma non e' una base su cui costruire: due servizi diversi potrebbero rivendicare nomi che si somigliano, e nulla distingue un nome interno da uno esterno.

E' la stessa dipendenza da M25 gia' registrata poco sopra, e la sonda la rende concreta: qui non e' un'ipotesi, e' un certificato realmente emesso per un nome che nessun servizio risolve.

### Terza domanda: il perimetro, che e' la piu' semplice

L'autorita' porta il nome di un progetto, non dell'azienda. Non e' un ostacolo tecnico, perche' un'autorita' puo' firmare qualunque nome a prescindere da come si chiama; e' un problema di leggibilita' e di ciclo di vita. Fra due anni, quando qualcuno guardera' l'emittente del certificato del gestore delle password e leggera' il nome di un progetto applicativo, non sapra' se sia intenzionale; e se un giorno quel progetto venisse dismesso, la sua autorita' resterebbe a garantire mezza azienda.

### La domanda che decide, e che si risponde in un comando

Le tre considerazioni pesano diversamente a seconda di un solo dato, che non e' ancora stato misurato: **se quell'autorita' sia gia' installata fra quelle attendibili sulle postazioni**.

Se lo e', esiste un patrimonio da non buttare, cioe' un'installazione gia' fatta su ogni postazione, e la scelta ragionevole diventa mettere in sicurezza la chiave esistente e continuare a usarla, magari riemettendo l'autorita' con un nome aziendale quando scadra'. Se non lo e', e gli utenti di IntraLino superano semplicemente l'avviso del navigatore, allora non c'e' nessun patrimonio da preservare: creare un'autorita' aziendale nuova, con custodia della chiave documentata e nomi decisi, costa esattamente quanto adottare quella esistente, e produce un impianto piu' pulito.

Il dato si legge sulla postazione, fra i certificati di autorita' attendibili della macchina e dell'utente, ed e' una lettura che non modifica nulla.

## Cosa resta aperto

La seconda passata su tutti e quattro i livelli, sulle sette macchine gia' raggiungibili: e' la sola cosa che possa dire dove esistano davvero restrizioni, e la prima domanda a cui deve rispondere e' dove viva quella della VM 204.

Il censimento della VM 100, con i tre comandi PowerShell della sezione dedicata.

Le due macchine su cui non si entra, la 205 e la 208, con la procedura descritta sopra e nell'ordine indicato, cioe' dopo aver messo in sicurezza il deposito delle credenziali.

La conferma della fine del supporto di Ubuntu 25.10 sulla VM 602.

E la matrice dei flussi, cioe' chi ha bisogno di raggiungere che cosa, che e' l'unica parte che nessuna misura puo' produrre da sola e che va compilata con l'IT Manager servizio per servizio. La restrizione della VM 204 e' gia' una riga di quella matrice: dice che quel servizio ha tre soli destinatari legittimi, ed e' un'informazione che nessuno snapshot avrebbe prodotto.

[^socket]: *socket* - il punto di aggancio con cui un programma si mette in comunicazione sulla rete; un socket in ascolto e' identificato dalla coppia indirizzo e porta su cui il programma accetta connessioni in arrivo.

[^loopback]: *loopback* - l'interfaccia di rete virtuale che ogni macchina ha verso se' stessa, con indirizzo `127.0.0.1`; il traffico che vi transita non lascia mai la macchina e non e' visibile dalla rete.

[^agente]: *agente ospite*, QEMU guest agent - piccolo servizio installato dentro una macchina virtuale che permette all'hypervisor di eseguirvi alcune operazioni dall'esterno, fra cui leggere gli indirizzi di rete, congelare il filesystem per un backup coerente e impostare la password di un utente, senza passare dalla rete.
