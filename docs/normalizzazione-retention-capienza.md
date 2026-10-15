# Normalizzazione, retention e capienza del collettore

Stato al 15/10/2026: requisiti confermati dall’operatore e progetto tecnico, non configurazione in esercizio. Il primo Agent Netdata risponde localmente sul fisico pilota; il Debian non riceve ancora questi eventi o metriche. Sviluppo richiesto sulla VM del collettore, con risorse Proxmox adeguabili dopo misure. [Studio Linux](osservabilita-linux-netdata.md), [runbook del pilota](runbook-monitoraggio-linux.md), [tre archivi logici](progetto-log-operativi-email.md) e [fonti e passi](fonti-osservabilita-linux.md) formano lo stesso percorso anche nel progetto rete.

## Lettura uniforme, provenienza conservata

Decisione: una vista di consultazione comune per tutte le sorgenti, costruita da adattatori specifici per formato/versione. Gli originali raccolti e i loro riferimenti restano disponibili secondo la politica del rispettivo archivio. Il modello proposto si ispira alle distinzioni fra tempi, risorsa, severità e corpo del [Logs Data Model OpenTelemetry](https://opentelemetry.io/docs/specs/otel/logs/data-model/); il JSON del progetto sarà un contratto locale versionato, non dichiarato automaticamente un payload OTLP conforme. Grafana presenterà i campi comuni e permetterà di aprire quelli specifici della sorgente.

| Campo della vista proposta v0 | Significato e regola |
|---|---|
| schema_version, event_id | Versione del contratto e identità dell’occorrenza acquisita; eventi distinti possono avere testo identico |
| archive | ads, technical, backup_outcomes oppure unclassified; la categoria incerta non diventa automaticamente AdS |
| observed_at, event_at, event_time_original | Ricezione osservata distinta dal tempo dichiarato; originale e offset conservati, UTC solo se determinabile; tempo evento ignoto resta null |
| source_id, host, service, transport_peer | Identità censita, host dichiarato e peer del trasporto distinti; un relay non diventa l’autore dell’evento |
| category, action, outcome | Valori controllati e documentati; esito unknown quando il messaggio non consente di determinarlo |
| severity_original, severity_normalized | Livello originale e mappatura dichiarata per sorgente; assenza del livello non equivale a normalità |
| actor, target | Account, eventuale identità personale verificata e oggetto; account condiviso non attribuito a una persona per deduzione |
| message, attributes | Messaggio leggibile e campi specifici preservati, con tipi e unità espliciti |
| parser_name, parser_version, parse_status, errors | Regola applicata, versione e stato ok/partial/unknown/error; campi estratti sempre riconducibili all’input |
| original_ref, original_sha256, record_locator | Riferimento all’oggetto originale effettivamente conservato, impronta e posizione della riga/unità; il digest non prova da solo autenticità o custodia indipendente |

Il formato AdsLine attuale conserva ricezione, IP di provenienza, tempo e hostname dichiarati e messaggio ricostruito dal template. Non si attribuisce retroattivamente ai file storici una cattura byte per byte del datagramma. La nuova vista deve riferire il record conservato senza riscrivere gli archivi giornalieri o i manifest esistenti. I [template rsyslog](https://docs.rsyslog.com/doc/configuration/templates.html) consentono mapping ed escaping JSON; prima dell’uso va verificata la disponibilità nella versione effettiva del Debian. Non basta concatenare stringhe per produrre JSON valido.

| Famiglia | Adattamento da verificare su campioni reali |
|---|---|
| Syslog/AdsLine, Linux e apparati | Separare peer, hostname dichiarato, tempo sorgente e ricezione; riconoscere formato e multilinea senza perdere il testo |
| Nebula | Conservare risposta originale, identità dell’apparato e chiave del record; classificazione degli accessi solo per formati collaudati |
| Report backup email | Conservare EML/MIME; un evento per unità/job quando presente; Date e Received non sono l’ora di esecuzione del job |
| API, journal e notifiche tecniche | Cursore/identità/tempi e severità propri della fonte; accesso via UI Netdata non prova inoltro al collettore |
| Metriche Netdata/Prometheus | Serie temporali con nome, etichette, unità e tempo; restano metriche, eventuale allarme diventa un evento tecnico separato |
| Output di collaudo | Evidenza della procedura con origine e limiti, non ingresso indiscriminato nell’archivio AdS |

Pipeline proposta: acquisizione dell’originale, identificazione del formato, parsing, normalizzazione, classificazione, scrittura della vista e indicizzazione della copia consultabile. I fallimenti producono stato esplicito, contatore e flusso di quarantena con capienza controllata; non scompaiono silenziosamente. La politica di deduplicazione deve distinguere una ritrasmissione dello stesso record da due eventi uguali; il solo hash del testo non basta. Un report con più unità mantiene i legami all’EML comune. D7, elenco AdS approvato e gate già aperti restano necessari.

## Politiche distinte di conservazione

| Oggetto | Politica da rispettare o definire | Controllo prima dell’esercizio |
|---|---|---|
| Originali AdS e manifest | 213 giorni previsti dallo studio esistente; custodia e gate del progetto invariati | Volume e riserva commisurati al periodo; nessuna cancellazione anticipata per fare spazio |
| Tecnici iLO | 90 giorni già scelti; timer preparato e non installato | Giorno corrente più 89 precedenti; dry-run e permessi del runbook esistente |
| Altri tecnici e quarantena | Durata e budget da approvare per sorgente e criticità | Origine, scadenza, quota, diritti, errori del parser e controllo della perdita |
| Esiti backup e originali EML | Durata da definire; storico dei job distinto dalla durata delle copie di backup | Più job per mail, copie inoltrate, mancata ricezione e prova di ripristino distinti |
| Copia normalizzata e indice Loki | Durata esplicita per archivio, coerente con autorizzazioni e politica degli originali | Retention realmente abilitata e cancellazione osservata, non solo parametro nel file |
| Metriche locali e centrali | Risoluzione, periodo e quota da scegliere misurando serie e crescita | Budget Netdata locale e TSDB centrale distinti; downsampling solo dove effettivamente configurato |
| Journal del sistema, log dei componenti, WAL, code e temporanei | Budget autonomi con spazio di emergenza | Contare rotazione, riavvio, compattazione, spool e stato persistente del lettore |

Le politiche AdS e iLO provengono dal documento canonico `docs/studio-collettore-ads.md` del progetto collettore, non da una nuova valutazione normativa in questo documento. Dove il periodo non è deciso non si assegna un valore implicito né si mantiene un default senza revisione. Ridurre una copia analitica non autorizza a eliminare il suo originale. I tempi di conservazione e le quote di byte hanno scopi diversi: se la quota fa espirare campioni prima del tempo desiderato, si deve rilevare e dichiarare il periodo realmente coperto.

La [retention Loki](https://grafana.com/docs/loki/latest/operations/storage/retention/) richiede la corretta configurazione del Compactor e dello storage scelto. Le [etichette Loki](https://grafana.com/docs/loki/latest/get-started/labels/) devono restare a cardinalità controllata: archive, famiglia di sorgente e servizio sono candidati; utente, IP, UID, hash e testo vanno di norma nel corpo o nei metadati, non in una label diversa per ogni evento. La verifica va ripetuta sulla release fissata, con un campione isolato a scadenza breve e originali di prova.

La [TSDB Prometheus](https://prometheus.io/docs/prometheus/latest/storage/) richiede margine per WAL, Head e compattazioni oltre ai blocchi conservati. La documentazione consultata suggerisce retention.size al massimo all’80-85% dello spazio dedicato a Prometheus: è un’indicazione del prodotto, non una soglia già applicata alla VM o agli originali. Anche i [limiti Netdata](https://learn.netdata.cloud/docs/netdata-agent/configuration/database) sono obiettivi per tier e possono essere superati temporaneamente. Il campo API multidb-disk-quota=1024 del pilota non prova un tetto complessivo di 1 GiB per installazione, journal e tutti i tier; configurazione effettiva e occupazione restano da leggere.

## Misure e budget prima di allocare risorse

Il dato documentale disponibile per il Debian è 2 GiB di RAM e due vCPU nello snapshot Proxmox del 15/10, non una misura del margine odierno. I circa 372 MiB letti nel servizio Netdata riguardano il fisico pilota: non sono il costo di Grafana, Loki e Prometheus né una raccomandazione di RAM per l’hub. La configurazione finale richiede baseline del Debian e del nodo Proxmox, conteggi delle sorgenti attive e misura sotto carico rappresentativo, includendo il ciclo di manutenzione notturna.

| Misura | Uso nel dimensionamento |
|---|---|
| Byte/eventi giornalieri per archivio, distribuzione delle dimensioni e picchi | Originali da conservare, throughput di parsing e ritardo accettabile |
| Crescita reale di originali, normalizzati, indice, WAL e cache | Evitare fattori di compressione/indicizzazione inventati e contare le copie multiple |
| Serie attive, scrape interval, campioni/giorno e variazione delle label | TSDB e carico di scraping; campioni/giorno circa serie medie per 86400 diviso intervallo in secondi |
| Byte liberi, inode liberi, volumi e mount reali | Riserva OS, quota per area e individuazione di un volume dati non montato |
| CPU, memoria disponibile/cgroup, swap, PSI, latenza disco e code | Margine sotto ingestione, query concorrenti, rotazioni e compressione D-1 |
| Ritardo e riempimento code, tasso d’ingresso e drenaggio | Finestra di disservizio assorbibile e tempo di recupero dopo il ripristino |
| RAM/CPU/storage del nodo Proxmox, thin pool, snapshot e backup | Capacità fisica prima di aumentare risorse nominali della VM |

Calcolo da compilare con le misure: spazio dati richiesto = somma dei byte/giorno osservati per il periodo di ciascuna copia, più code, WAL, indici, stato, temporanei di picco e riserva operativa. Per le code il riferimento è il picco di byte/secondo per la finestra di disservizio accettata, aggiungendo l’overhead misurato. Il tempo stimato a esaurimento è byte ancora utilizzabili sopra la riserva diviso crescita netta positiva in byte/secondo; senza crescita positiva il risultato è non applicabile, non una divisione per zero o garanzia di spazio infinito. Registrarvi finestra e qualità della stima.

I volumi o quote separati servono a impedire che indice e metriche consumino la riserva degli originali e del sistema. Una directory diversa sullo stesso filesystem non isola la capienza. Il progetto deve prevedere directory di mount dedicate e verifica del mount prima di scrivere, così un disco assente non riversa i dati sulla root. Backup, snapshot, ricostruzione degli indici e compressione possono tenere contemporaneamente due copie: includerle nel picco, non solo nella media giornaliera.

## Guardie proposte, non applicate

Le seguenti soglie sono valori iniziali di progetto da ricalibrare con la baseline e la finestra di intervento concordata. Sono condizioni alternative: un filesystem grande può avere percentuale buona e autonomia insufficiente; gli inode possono terminare prima dei byte.

| Segnale | Soglia iniziale proposta | Reazione da realizzare e verificare |
|---|---|---|
| Dati o root in crescita | Avviso dall’80%, critico dal 90%; oppure autonomia stimata sotto 7 giorni/48 ore | Notifica al sysadmin, analisi dell’area in crescita; riserva minima in GiB da fissare per volume |
| Inode | Avviso sotto il 10% libero, critico sotto il 5% | Individuare moltiplicazione di file/serie senza cancellare gli originali protetti |
| Code e ritardo | Avviso al 70% del budget, critico al 90%, più massima età e tempo previsto al pieno | Controllare il ricevitore e rallentare le copie analitiche dove supportato; perdita o blocco espliciti, mai promesse di assenza di perdita UDP |
| Memoria/CPU/I/O | Disponibilità, pressione e ritardi confrontati con la baseline su intervallo sostenuto | Budget per servizio; prima ridurre frequenza/query/concorrenza analitica e verificare ingestione |
| Mount, parser e raccolta | Mount atteso assente, errori/unknown in crescita, sorgente silente o heartbeat mancante | Allarme indipendente dal solo hub e stato degradato visibile |
| Manutenzione e retention | Job fallito, spazio non recuperato, retention reale inferiore alla richiesta | Errore esplicito, verifica conteggi e allarme; nessuna pulizia indiscriminata |

I [controlli systemd](https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.resource-control.xml) possono attribuire priorità CPU/I/O e limiti di memoria sui sistemi compatibili. MemoryHigh provoca pressione/rallentamento; MemoryMax può portare all’OOM nel servizio. Perciò un limite rigido scelto senza misura può interrompere la raccolta: non si copia lo stesso budget su tutti i componenti. Definire margine per OS e ingestione, limitare separatamente le query/copie analitiche e verificare cgroup, versione e comportamento effettivi del Debian. Le priorità relative non sono prenotazioni assolute.

Le [code rsyslog](https://docs.rsyslog.com/doc/concepts/queues.html) richiedono sia limite di elementi sia spazio disco e comportamento al pieno; la sola queue.size non limita i byte della parte disk-assisted. La persistenza allo shutdown non è garanzia contro ogni crash. Anche [journald](https://raw.githubusercontent.com/systemd/systemd/main/man/journald.conf.xml) richiede budget di uso e spazio da lasciare libero: il vacuum rimuove file archiviati, non garantisce che i file attivi spariscano. Il namespace Netdata aggiunto dall’installer e il journal di sistema vanno entrambi censiti.

In emergenza la procedura deve proteggere gli originali: sospendere o contenere attività analitiche onerose secondo un piano provato, segnalare code/perdite e ripristinare capienza. Le cancellazioni seguono esclusivamente la politica della specifica area e il suo dry-run; nessun comando globale per liberare il disco. Un osservatore esterno deve rilevare hub indisponibile e mancata consegna delle notifiche: un allarme ospitato soltanto sulla VM satura non basta. Destinatario, canale e cadenza saranno concordati prima della messa in esercizio.

## Adeguamento tramite Proxmox e prove di accettazione

Prima di cambiare la VM si confrontano risorse guest e margine del nodo, storage reale e configurazione di memoria/ballooning. Il [manuale qm](https://pve.proxmox.com/pve-docs/qm.1.html), la [guida della memoria](https://raw.githubusercontent.com/proxmox/pve-docs/master/qm.adoc) e il [modello storage](https://raw.githubusercontent.com/proxmox/pve-docs/master/pvesm.adoc) sono riferimenti ufficiali; M29 resta il punto di coordinamento della standardizzazione. Aumentare il disco virtuale non dimostra che partizione, LVM e filesystem del guest siano già ampliati: rilevare la catena reale prima di preparare i comandi. Headroom fisico, pool thin, snapshot e backup si verificano separatamente. Nessuna nuova allocazione è eseguita o prescritta con numeri non misurati.

L’accettazione richiede un caso reale per ciascuna famiglia di log, con confronto input/campi/UI e errore su formato sconosciuto; orari senza fuso, account condivisi, multilinea, ritrasmissioni e più job per EML sono casi distinti. Riavvio, rotazione e breve interruzione del solo ricevitore di prova devono dimostrare continuità o rendere misurabile la perdita. Scadenza, compattazione, coda piena, mount assente e soglie di capienza si provano in ambiente isolato con dati fittizi, senza saturare il collettore reale o interrompere Ollama. Dopo il carico rappresentativo si misurano ingestione, query, pressione e riserva; solo allora si fissano taglie, retention dei nuovi archivi ed estensione agli altri host.
