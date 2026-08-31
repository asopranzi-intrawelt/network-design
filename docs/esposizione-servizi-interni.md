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

La colonna del filtro dice soltanto che cosa risponde `ufw`, che come si e' visto e' uno dei quattro livelli: dove dice "non installato" non si deve leggere "nessun filtro", ma "nessun filtro **a questo livello**". La colonna delle restrizioni note raccoglie quanto emerso finora per altra via.

| VM | Nome | Indirizzo | Sistema | `ufw` | Porte in ascolto su tutte le interfacce | Porte solo locali | Restrizioni note per altra via |
|---|---|---|---|---|---|---|---|
| 202 | PasswordManager | `10.61.20.21` | Ubuntu 24.04.2 LTS | non installato | 22, 80 | 3306, 631 | da verificare |
| 204 | ConvertitoreRuoliniENI | `10.61.20.22` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 8090 | 5000, 5010 | **si**: accesso ristretto per indirizzo, ammessi la postazione dell'IT Manager e due indirizzi della fascia `.70`, riferito il 31/08/2026; livello e sintassi da determinare |
| ~~206~~ | ~~intrasite~~ | — | — | — | — | — | **dismessa il 31/08/2026**, vedi §La dismissione della VM 206 |
| 207 | websiteAnalyst | `10.61.20.24` | Ubuntu 24.04.2 LTS | non installato | 22, 80, 8000 | 3306, 631 | da verificare |
| 209 | IntraNewSite | `10.61.20.209` | Ubuntu 24.04.4 LTS | non installato | 22, 3000, 5432 | 631 | da verificare |
| 602 | Intralino | `10.61.20.60` | Ubuntu 25.10 | non installato | 22, 80, 443, 4443, 5443, 5444 | nessuna | da verificare |
| 810 | TESTNEWEGETRADBOOT | `10.61.20.90` | Ubuntu 24.04.4 LTS | installato, inattivo | 22, 80, 3389, 8080, 8090 | 3350 | da verificare |
| 205 | GanttTool | non rilevato | non rilevato | non rilevato | non rilevato | non rilevato | macchina non accessibile, #162 |
| 208 | portaleAsset | `10.61.20.25` | non rilevato | non rilevato | 80 e 443 note da NET-011, il resto non rilevato | non rilevato | macchina non accessibile, #162 |
| 100 | WinServer2022 | non rilevato | Windows Server 2022 | non applicabile | non rilevato | non rilevato | Windows Defender Firewall, da censire a parte: vedi §La macchina Windows |

## La macchina Windows, che non e' un caso a parte per pigrizia

La VM 100 WinServer2022 non compare nella prima passata perche' il comando usato e' scritto per Linux, e su Windows nessuno dei tre strumenti esiste. Non e' pero' fuori perimetro, per tre ragioni distinte.

La prima e' che ha un firewall e ce l'ha da sempre acceso: Windows Defender Firewall e' attivo per impostazione predefinita, con tre profili distinti — dominio, privato e pubblico — e la regola predefinita e' bloccare le connessioni in ingresso non esplicitamente ammesse. Ne discende che su questa macchina la domanda non e' se il filtro esista, ma quali eccezioni siano state aperte nel tempo e su quale profilo, che e' una domanda diversa da quella posta alle macchine Linux.

La seconda e' che, essendo un server Windows, ospita per costruzione servizi che le postazioni raggiungono continuamente, e ogni sua porta e' quindi un flusso da preservare nella segmentazione, non una superficie da chiudere.

La terza e' la piu' rilevante per il lavoro in corso, e non riguarda il firewall: **la VM 100 e' l'unica macchina attestata su `vmbr1`**, con la propria seconda scheda di rete, e `vmbr1` e' il bridge scelto per portare la VLAN 201. Ne discende un vincolo operativo su M4 che va scritto qui perche' non si perda: quando la porta 7 del 54HP diventera' un trunk, la VLAN 1 dovra' restare **non taggata** su quella porta, altrimenti la seconda scheda di questa macchina perde la rete. Non e' un dettaglio di configurazione, e' la ragione per cui M4 non e' un'operazione a rischio nullo nonostante `vmbr1` sia il bridge piu' scarico.

Il censimento equivalente su Windows si fa con tre comandi PowerShell da eseguire come amministratore, ed e' tracciato come parte della seconda passata di M27-7.

```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
Get-NetFirewallRule -Enabled True -Direction Inbound -Action Allow | Get-NetFirewallPortFilter | Where-Object LocalPort -ne "Any" | Sort-Object LocalPort -Unique
Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess | Sort-Object LocalPort
```

Il primo dice se i tre profili sono accesi e che cosa fanno per impostazione predefinita, il secondo elenca le eccezioni in ingresso effettivamente attive con la porta a cui si riferiscono, il terzo elenca cio' che e' realmente in ascolto e su quale indirizzo, che e' l'equivalente esatto di `ss -tulpn`.

## I sette fatti che discendono dalla matrice, in ordine di quanto pesano

Il primo e' il gestore delle password della VM 202, che risponde sulla porta 80, cioe' in chiaro, e non ha nessun ascolto sulla 443. Va notato che questo fatto e' **indipendente** dalla correzione del 31/08: una lista di indirizzi ammessi, se anche esistesse su questa macchina, non renderebbe cifrato il traffico di chi e' ammesso. Un servizio che custodisce credenziali e che le trasmette senza cifratura su una rete dove ogni apparato e' adiacente a ogni altro e' il caso peggiore della matrice, perche' non richiede di violare nulla: chi si trovi in condizione di osservare il traffico legge le credenziali mentre passano, e la password principale del deposito passa di li' a ogni accesso. Tracciato come #160.

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

La prima e' che **cambiare una password gia' nota non e' un guadagno di sicurezza in se'**. Una rotazione ha senso quando la credenziale e' stata esposta, quando e' condivisa fra piu' persone, quando non rispetta il criterio di robustezza adottato, o quando esce qualcuno che la conosceva. Cambiarle tutte perche' si e' imparata la procedura significa produrre una decina di credenziali nuove da memorizzare da qualche parte, il che sposta il problema invece di risolverlo: il problema, registrato in #168, non e' che le password siano vecchie ma che **non esista un posto unico dove sono scritte**.

La seconda e' una conseguenza della procedura stessa che vale la pena rendere esplicita, perche' cambia il modello di fiducia dell'infrastruttura e non e' ovvia. `qm guest passwd` imposta la password di un utente **senza conoscere quella precedente**: non e' un difetto dello strumento, e' il potere legittimo di chi amministra l'hypervisor, che possiede i dischi delle macchine e potrebbe comunque montarli. Ne discende pero' un fatto che nessun documento del progetto aveva scritto: **chi ha accesso amministrativo a Proxmox ha, di fatto, accesso a ogni macchina virtuale dell'azienda**, compresa quella che ospita il gestore delle password, e puo' ottenerlo in un comando senza lasciare traccia dentro la macchina bersaglio. La protezione del gestore delle password non e' quindi piu' forte della protezione dell'accesso a Proxmox. Tracciato come #169.

### Dove si depositano, e cosa non va fatto

Il posto giusto esiste gia' ed e' progettato: il gestore delle password sulla VM 202, la cui architettura e' descritta in `docs/cybersecurity-governance.md` come Vaultwarden dietro un proxy inverso con HTTPS, autenticazione a due fattori obbligatoria e vault condivisi per area. La misura del censimento dice pero' che di quel disegno manca proprio il pezzo che lo rende utilizzabile: la macchina risponde sulla porta 80 e non ha alcun ascolto sulla 443, quindi oggi il deposito viaggia in chiaro. E' il difetto #160, e questa e' la sua conseguenza pratica: **finche' non e' chiuso, depositare le credenziali nel gestore le espone invece di proteggerle**, perche' un gestore servito senza cifratura trasmette in chiaro, a ogni accesso, sia la password principale sia tutte quelle che custodisce.

Ne discende una sequenza obbligata, ed e' la ragione per cui #160 e' il primo intervento della lista e non uno dei tanti. Prima si chiude l'HTTPS sulla VM 202, poi vi si depositano le credenziali, e solo allora la reimpostazione in serie ha un senso, perche' ha una destinazione.

Tre cose che non vanno fatte, e la prima riguarda direttamente il modo in cui si lavora con un assistente. Le password **non si scrivono in una conversazione** e **non si mettono in un file che l'assistente legge**: la conversazione resta nella trascrizione della sessione finche' non viene cancellata, e un file letto entra nel contesto e da li' puo' finire in un riassunto. Questo progetto non ha mai bisogno del valore di una credenziale: gli serve sapere che esiste, a quale macchina e a quale utenza si riferisce, e dove e' custodita. Non vanno scritte in un file di testo o in un foglio di calcolo su una condivisione, che e' il modo in cui una credenziale sopravvive alla persona che l'ha scritta e diventa leggibile da chiunque abbia accesso alla cartella — lo stesso schema gia' registrato in #126 per le utenze memorizzate nelle multifunzione. E non vanno lasciate nella cartella dei download o nelle foto delle etichette degli apparati, come annotato piu' volte nella mappa privata.

### Il registro senza valori, che e' cio' che serve al progetto

Cio' che manca e che si puo' tenere fin da subito, anche prima dell'HTTPS, e' l'inventario delle credenziali **senza le credenziali**: per ogni macchina, quale utenza esiste, se la password e' nota, dove e' custodita e quando e' stata cambiata l'ultima volta. E' il rimedio a #168, costa poco e non contiene nulla di sensibile, tanto che potrebbe stare in un file tracciato; resta comunque in `_notes/` perche' l'elenco delle utenze e' informazione operativa che non serve a nessuno fuori.

Il modello e' `_notes/registro-credenziali.md`, con una colonna per lo stato e nessuna per il valore. Lo produce anche `scripts/Invoke-HostCensus.ps1` nella sua forma minima, cioe' l'elenco degli host su cui la password non e' risultata disponibile.

## Cosa resta aperto

La seconda passata su tutti e quattro i livelli, sulle sette macchine gia' raggiungibili: e' la sola cosa che possa dire dove esistano davvero restrizioni, e la prima domanda a cui deve rispondere e' dove viva quella della VM 204.

Il censimento della VM 100, con i tre comandi PowerShell della sezione dedicata.

Le due macchine su cui non si entra, la 205 e la 208, con la procedura descritta sopra e nell'ordine indicato, cioe' dopo aver messo in sicurezza il deposito delle credenziali.

La conferma della fine del supporto di Ubuntu 25.10 sulla VM 602.

E la matrice dei flussi, cioe' chi ha bisogno di raggiungere che cosa, che e' l'unica parte che nessuna misura puo' produrre da sola e che va compilata con l'IT Manager servizio per servizio. La restrizione della VM 204 e' gia' una riga di quella matrice: dice che quel servizio ha tre soli destinatari legittimi, ed e' un'informazione che nessuno snapshot avrebbe prodotto.

[^socket]: *socket* - il punto di aggancio con cui un programma si mette in comunicazione sulla rete; un socket in ascolto e' identificato dalla coppia indirizzo e porta su cui il programma accetta connessioni in arrivo.

[^loopback]: *loopback* - l'interfaccia di rete virtuale che ogni macchina ha verso se' stessa, con indirizzo `127.0.0.1`; il traffico che vi transita non lascia mai la macchina e non e' visibile dalla rete.

[^agente]: *agente ospite*, QEMU guest agent - piccolo servizio installato dentro una macchina virtuale che permette all'hypervisor di eseguirvi alcune operazioni dall'esterno, fra cui leggere gli indirizzi di rete, congelare il filesystem per un backup coerente e impostare la password di un utente, senza passare dalla rete.
