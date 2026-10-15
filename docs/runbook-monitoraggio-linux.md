# Runbook del pilota Linux e GPU

## Ripristino NVIDIA dopo migrazione Ubuntu, 15/10/2026

Riscontro tecnico del 15/10/2026 dall'host fisico pilota: Ubuntu 26.04.1 LTS e kernel 7.0.0-38-generic. I log di migrazione mostrano aggiornamento e successiva rimozione di nvidia-utils-595 e libnvidia-compute-595; ripristinati entrambi alla versione 595.99.02-0ubuntu0.26.04.1, coerente con il modulo caricato. Verifica indipendente SSH: nvidia-smi identifica RTX 5060 Ti con 16.311 MiB, libcuda/NVML caricabili, cuInit=0 e un dispositivo CUDA. Ollama, Veeam e Netdata active/running; nessun comando di reboot o riavvio servizi richiesto. Nessuna inferenza LLM: uso GPU da Ollama ancora da verificare. Le corrispondenze NVIDIA nell'API Netdata sono soltanto stati di unità systemd, non chart di utilizzo/VRAM/temperatura: collaudo del collector ancora aperto. Veeam nosnap 6.3.2.1501 presente; job riuscito/restore non attestati da questa verifica. Restano invariati configurazione Netdata, flussi al collettore, gate AdS e lavoro già aperto.

Fonte: installazione interattiva autorizzata dall'operatore, poi letture indipendenti via SSH alle 13:53:37 UTC. Il modulo kernel già presente non sostituiva le librerie user-space: libcuda serve al calcolo GPU dal programma; NVML e nvidia-smi espongono stato/risorse. Ripristino limitato ai due pacchetti con versione fissata e simulazione senza rimozioni. I dati della baseline precedente, più avanti nel runbook, restano una fotografia precedente.

Prova privata: [nvidia-post-upgrade-20261015.json](../_notes/linux-observability-20261015/pilot/nvidia-post-upgrade-20261015.json), SHA-256 6924038e39f88a8b302fb611897cb435920d39ae4461366448ebc2aac977db06. Contiene i riferimenti e gli hash delle letture sorgenti. Nessun indirizzo, account o destinazione NAS reale nel testo pubblico. Il controllo CUDA verifica caricamento/inizializzazione e presenza del dispositivo, non accuratezza, prestazioni, energia o inferenza Ollama.

Riferimenti: [installazione NVIDIA su Ubuntu](https://ubuntu.com/server/docs/how-to/graphics/install-nvidia-drivers/), [CUDA Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/), [NVML](https://docs.nvidia.com/deploy/nvml-api/nvml-api-reference.html), [collector NVIDIA Netdata](https://learn.netdata.cloud/docs/collecting-metrics/collectors/hardware-and-sensors/nvidia-gpu).

Prossima verifica di osservabilità: riconoscimento di nvidia-smi nel collector e chart GPU effettive; il solo ripristino delle librerie non chiude quel collaudo.

Stato al 15/10/2026: Netdata 2.12.1 installato dall’operatore sul fisico Ollama, dopo il recupero del bundle. Script e archivio verificati, servizio avviato e active/running, abilitazione al boot già osservata, listener loopback verificato e opt-out presente. Export CPU/RAM presente e ACLK non claimed/non online; GPU e impatto a regime ancora da verificare; nessun invio di eventi al collettore aggiunto. Il piano generale è in [Osservabilità Linux](osservabilita-linux-netdata.md); la scelta della console locale senza abbonamenti rimane valida. Questo runbook è riportato anche nel progetto rete, insieme a M32 e alla timeline comune.

## Scelta del pilota e ambiente

La richiesta dell’operatore supera per questo monitoraggio la proposta iniziale di provare prima una VM: si comincia dal fisico con GPU, poi si estende alle VM. Non cambia il pilota vm-health di M29 né il gate per estendere gli accessi AdS degli ospiti. L’operatore indica il Debian del collettore come successivo punto di sviluppo dell’integrazione; la collocazione di tutti i database del monitoraggio deve ancora essere dimensionata. L’hub separato rimane una proposta, non una decisione imposta.

Il pilota riguarda un’applicazione di terze parti su una macchina reale, scelta dall’operatore: modello R0 del catalogo di separazione degli ambienti, con pacchetto fissato e ripristino documentato. Il fisico non dispone per definizione dello snapshot di un ospite Proxmox. L’installazione deve fermarsi davanti a un’installazione Netdata precedente non censita; prima di cambiare configurazioni esistenti occorrono copia, proprietà, permessi e impronte. Nessuna operazione sui driver NVIDIA o sul servizio Ollama è inclusa nell’installazione dell’Agent.

## Baseline riferita dall’operatore

La fonte delle misure è l’output incollato dall’operatore il 15/10/2026, non una connessione SSH eseguita dall’agente. Il primo gruppo legge sistema, risorse, `nvidia-smi` e presenza di Netdata nel PATH; il secondo PCI, dispositivi grafici, modelli caricati e metadati APT. Trascrizione sintetica, identità reale e stato strutturato sono nel livello privato `_notes/linux-observability-20261015/pilot/`. L’impronta di questi file identifica il materiale conservato, non certifica autonomamente l’esecuzione remota.

| Controllo | Output riferito | Limite |
|---|---|---|
| Sistema | Ubuntu 26.04.1 LTS, `resolute`, `x86_64` | API successiva: kernel 7.0.0-38-generic, i7-7700 con 8 CPU logiche; non un inventario completo dei servizi |
| Memoria | 15 GiB totali, 1,4 GiB usati, 13 GiB disponibili; swap 29 GiB, 636 KiB usati | Istantanea arrotondata di `free -h`, non misura dell’overhead |
| Disco | Radice e `/var` sullo stesso filesystem: 73 GB, 46 GB usati, 24 GB disponibili, uso 67% | Non prova salute SMART, quota o crescita |
| GPU | NVIDIA GeForce RTX 5060 Ti, famiglia GB206; `Kernel driver in use: nvidia` | Modulo 595.99.02 letto nel terzo riscontro; VRAM e temperature ancora da misurare |
| Dispositivi grafici | `card1` nel gruppo video e `renderD128` nel gruppo render | Non prova i permessi del futuro utente Netdata |
| Utility NVIDIA | `nvidia-smi` non trovato | Non equivale ad assenza del driver, che PCI mostra in uso |
| Ollama | `ollama ps` restituisce soltanto l’intestazione | Nessun modello caricato sull’endpoint interrogato in quel momento; non prova guasto né uso CPU/GPU |
| Netdata | Assente dal PATH; APT installato nessuno e candidato nessuno | Terzo riscontro: servizio not-found, directory statiche e native assenti; non prova indisponibilità dei pacchetti del produttore per Ubuntu 26.04 |

La presenza nei moduli possibili di `nouveau` e `nvidiafb` non dimostra che siano quelli in uso: il campo del driver attivo indica `nvidia`. Non si installano i pacchetti suggeriti dal command-not-found scegliendo arbitrariamente la serie 580 o 595. Il collector NVIDIA documentato usa `nvidia-smi`; la versione delle utility deve essere compatibile con il modulo già caricato. Le metriche generali dell’Agent possono essere collaudate prima della GPU.

## Comandi iniziali già eseguiti

Destinazione: Bash sul fisico pilota. Queste letture hanno prodotto la baseline precedente, senza installazioni. Il primo blocco verifica sistema e capacità e cerca Netdata; il secondo distingue driver PCI in uso, dispositivi, modelli Ollama caricati e disponibilità APT. Gli errori di nvidia-smi e l’assenza del candidato Netdata sono esiti conservati, non motivi per cambiare driver automaticamente. Il modulo NVIDIA è stato letto nel successivo blocco di dry-run.

```bash
cd /
hostname
cat /etc/os-release
uname -m
free -h
df -h / /var
nvidia-smi --query-gpu=name,driver_version,memory.total,memory.used,temperature.gpu --format=csv
if command -v netdata >/dev/null 2>&1; then netdata -v; else printf 'Netdata non presente nel PATH\n'; fi
```

```bash
cd /
lspci -nnk
ls -l /dev/dri
ollama ps
apt-cache policy netdata
```

## Percorso di installazione preparato

Scelta tecnica per il pilota: build statica ufficiale x86_64 in `/opt/netdata`, versione candidata 2.12.1, pubblicata come stabile nella pagina delle release consultata. Il motivo è mantenere il pacchetto separato dalle librerie di sistema e poter rinviare il primo avvio; non è una dichiarazione di mancato supporto del repository nativo. Il `kickstart.sh` del tag v2.12.1 è stato scaricato nel livello privato e letto prima di proporlo. SHA-256 dello script: `a3a6e66f0784fb105c926c4503f023a41f3fad1992b7b4b855248d5d730075dc`.

Il codice di questa versione riconosce `--static-only`, `--install-version`, `--dont-start-it`, `--no-updates`, `--disable-telemetry` e `--dry-run`. Il mancato avvio vale per installazioni statiche e build locali, non è una garanzia da trasferire ai pacchetti nativi. Il vecchio argomento `--disable-cloud` produce un avviso e non disabilita Cloud: non si usa come controllo. Il percorso locale prevede nessun claim, telemetria disattivata e aggiornamenti gestiti; il comportamento della release installata deve essere verificato.

Osservazione sul codice dell’installer fissato: il ramo statico online salta il confronto SHA-256 esterno quando `INSTALL_VERSION` è valorizzato. L’hash dello script non è l’hash del pacchetto che scaricherà. Prima dell’esecuzione che installa servirà quindi verificare separatamente l’archivio ufficiale e il suo checksum, oppure usare una sorgente offline già verificata. Il solo dry-run non certifica integrità del pacchetto o compatibilità runtime. La sequenza di installazione con privilegi è ora preparata sotto; la sua esecuzione rimane da confermare con l’output dell’operatore.

### Comandi del dry-run già eseguito

Destinazione: Bash del fisico pilota, nel terminale SSH già aperto dall’operatore; nessun ramo Git coinvolto. Sono letture e scaricamento dello script in una directory temporanea privata dell’utente. Il dry-run non installa Netdata. `ls` può segnalare directory inesistenti, dato utile per il controllo di un’installazione pregressa. Se il download o il checksum falliscono, l’ultima riga impedisce di eseguire lo script.

```bash
cd /
cat /sys/module/nvidia/version
systemctl show netdata.service --property=LoadState --property=ActiveState --property=FragmentPath
ls -ld /opt/netdata /etc/netdata
netdata_pilot_dir=$(mktemp -d /tmp/netdata-pilot.XXXXXXXX)
printf 'Directory della prova: %s\n' "$netdata_pilot_dir"
curl --fail --location --proto '=https' --tlsv1.2 --output "$netdata_pilot_dir/kickstart.sh" https://raw.githubusercontent.com/netdata/netdata/v2.12.1/packaging/installer/kickstart.sh
printf '%s  %s\n' a3a6e66f0784fb105c926c4503f023a41f3fad1992b7b4b855248d5d730075dc "$netdata_pilot_dir/kickstart.sh" | sha256sum --check - && sh "$netdata_pilot_dir/kickstart.sh" --dry-run --stable-channel --install-version 2.12.1 --static-only --dont-start-it --no-updates --disable-telemetry
```

Output ricevuto: modulo 595.99.02, servizio non trovato e inattivo, entrambi i percorsi assenti, script con SHA-256 coincidente. Il dry-run seleziona l’archivio x86_64 della versione 2.12.1 e stampa le operazioni previste; il suo banner finale «Successfully installed the Netdata Agent» è generico e non dimostra un’installazione. Nel codice il riepilogo viene emesso anche dopo le operazioni simulate. La richiesta sudo visibile alla fine riguarda la rimozione della directory temporanea del kickstart; non è una richiesta per avviare il servizio. L’operatore torna al prompt senza errori riportati, ma non fornisce un codice di uscita separato. Directory effettiva conservata solo nell’evidenza privata, senza dipendere dalla variabile del terminale.

## Bundle scaricato e difetto della prima procedura

L’operatore ha scaricato l’archivio x86_64 2.12.1 e il file dei checksum ufficiali. La preparazione stampa `./netdata-x86_64-latest.gz.run: OK`, copia lo script e salva il canale. L’installazione non parte: il controllo successivo cerca il file in una directory differente e fallisce prima di sudo. Le righe indipendenti successive chiedono la password per una copia di configurazione inesistente e restituiscono altri file assenti; non dimostrano una modifica riuscita. Il servizio rimane non trovato e inattivo. Percorso effettivo e output sintetico sono nel livello privato.

La causa è nel [parser del kickstart 2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/packaging/installer/kickstart.sh): l’argomento di `--prepare-offline-install-source` passa attraverso `sanitize_string`, che elimina gli slash. La procedura precedente aveva controllato il cambio directory, ma non questa trasformazione. Non basta aggiungere virgolette al percorso. Per una nuova preparazione si passa il solo nome `offline`, dalla directory di staging; l’argomento di `--offline-install-source` invece è conservato e deve essere assoluto, perché il programma cambia directory. La versione fissata non supporta spazi arbitrari in tutti gli argomenti: lo staging del pacchetto deve essere generato con nome semplice e validato.

Il controllo è stato ripetuto in WSL con le funzioni originali di parsing, validazione e costruzione degli URL, escludendo main, payload e trap finale del programma. La prima versione dell’harness non escludeva il trap e usciva senza fornire una prova valida; corretta prima di misurare il difetto. Il comando con preparazione semplice conserva il nome; reintroducendo il vecchio assoluto il confronto fallisce. La sorgente assoluta conserva l’URL file anche dopo il cambio directory; reintroducendo una relativa il confronto fallisce. Ripristinato il comando corretto, controllo verde e SHA dello script originale invariato. Questa prova misura i percorsi, non esegue l’installazione completa e non dimostra compatibilità runtime.

### Preparazione corretta per un nuovo pilota

Solo per una nuova istanza; il pilota corrente ha già un bundle e deve usare il recupero seguente. Bash, staging con nome semplice; nessun download da ripetere sul fisico corrente.

```bash
cd '<DIRECTORY_PILOTA_NETDATA>'
printf '%s  %s\n' a3a6e66f0784fb105c926c4503f023a41f3fad1992b7b4b855248d5d730075dc ./kickstart.sh | sha256sum --check - && sh ./kickstart.sh --stable-channel --install-version 2.12.1 --static-only --offline-architecture x86_64 --prepare-offline-install-source offline --disable-telemetry
```

### Recupero del bundle già verificato

Destinazione: Bash sul fisico, dentro la directory effettiva del bundle restituita dalla preparazione. Il primo percorso viene compilato dal riscontro dell’operatore, non ricostruito applicando una trasformazione a un dato futuro. Il blocco ricontrolla gli hash dello script e dell’archivio prima di sudo. Tutte le modifiche sono concatenate: un fallimento impedisce installazione, copia o scrittura successive. Le ultime righe sono letture di verifica.

Il [bundle offline ufficiale](https://learn.netdata.cloud/docs/netdata-agent/installation/linux/offline-systems) contiene il nome alias `netdata-x86_64-latest.gz.run`. Il checksum atteso è quello [pubblicato per 2.12.1](https://github.com/netdata/netdata/releases/download/v2.12.1/sha256sums.txt), `f4a73a7b2641f5d962afdf648948e3d472ab18759e906e9e3164cbb7c697147e`: il nome alias non seleziona una release diversa. Non si passa `--install-version` insieme alla sorgente offline. Il sorgente statico del tag conferma il mancato avvio con `--dont-start-it` e la creazione del marker di opt-out; non è ancora una misura del fisico.

```bash
cd '<DIRECTORY_BUNDLE_NETDATA>'
printf '%s  %s\n' a3a6e66f0784fb105c926c4503f023a41f3fad1992b7b4b855248d5d730075dc ./kickstart.sh f4a73a7b2641f5d962afdf648948e3d472ab18759e906e9e3164cbb7c697147e ./netdata-x86_64-latest.gz.run | sha256sum --check - && sudo sh ./kickstart.sh --stable-channel --static-only --offline-install-source "$PWD" --dont-start-it --no-updates --disable-telemetry --non-interactive && test ! -e /opt/netdata/etc/netdata/netdata.conf.before-linux-monitoring && sudo cp -a /opt/netdata/etc/netdata/netdata.conf /opt/netdata/etc/netdata/netdata.conf.before-linux-monitoring && printf '%s\n' '[web]' '    bind to = 127.0.0.1:19999' | sudo tee /opt/netdata/etc/netdata/netdata.conf
/opt/netdata/bin/netdata -v
systemctl show netdata.service --property=LoadState --property=ActiveState --property=UnitFileState --property=FragmentPath
sudo ls -l /opt/netdata/etc/netdata/.opt-out-from-anonymous-statistics /opt/netdata/etc/netdata/netdata.conf.before-linux-monitoring
```

Il blocco modifica il sistema installando l’Agent e la configurazione, ma lascia fermo il servizio. Non installa utility NVIDIA e non modifica driver o unità Ollama. Ci si attende versione 2.12.1, servizio presente e inattivo, bind loopback, backup e marker di opt-out. Output del recupero ricevuto: installazione completata, binario v2.12.1 e servizio loaded/inactive/enabled; dettagli nella sezione seguente. Timer e cron dell’updater vanno verificati prima di dichiarare l’assenza di auto-update sul fisico.

## Installazione reale ricevuta

Il recupero dal bundle effettivo è riuscito secondo l’output dell’operatore. I due confronti SHA-256 restituiscono OK prima di sudo; l’installer copia i file locali, estrae in `/opt/netdata`, crea l’account di servizio e installa le integrazioni di sistema. Il binario interrogato per percorso completo risponde `netdata v2.12.1`. Systemd restituisce `LoadState=loaded`, `ActiveState=inactive`, `UnitFileState=enabled` e unità in `/usr/lib/systemd/system/netdata.service`. Nonostante il banner iniziale generico annunci un riavvio, il risultato misurato è servizio fermo: l’opzione di mancato avvio ha avuto effetto. `enabled` indica l’avvio al prossimo boot, non un processo già in esecuzione né l’abilitazione dell’updater.

La riga successiva dell’operatore scrive `[web]` con `bind to = 127.0.0.1:19999`; il file iniziale è copiato in `netdata.conf.before-linux-monitoring`, 301 byte, `root:root 0644`. Il marker `.opt-out-from-anonymous-statistics` è presente, vuoto, `root:root 0664`. La disattivazione dell’updater restituisce `Auto-updates have been DISABLED` nel proprio output. Quest’ultimo è un riscontro della procedura, non ancora una ricerca indipendente di timer e cron. Il permesso del marker non contiene un segreto; proprietari, permessi e configurazione effettiva vanno conservati nell’inventario del pilota.

L’installazione ha aggiunto l’utente Netdata ai gruppi Docker e video e assegnato capability o setuid a plugin specifici. Sono modifiche osservate, da includere nel ripristino e nella revisione dei privilegi prima dell’estensione: la [documentazione Docker](https://docs.docker.com/engine/install/linux-postinstall/) descrive l’accesso privilegiato al daemon tramite quel gruppo; necessità e accesso effettivo vanno verificati per l’istanza, senza presumere il tipo di socket dal solo nome del gruppo. Nessun gruppo viene modificato in questo giro. Gli identificativi numerici effettivi restano nell’evidenza privata. L’installer ha scritto logrotate, configurazione journald per il namespace Netdata, tmpfiles e unità systemd, oltre al solo prefisso `/opt/netdata`: cancellare quella directory non descriverebbe una rimozione completa.

## Primo avvio e lettura delle metriche: esecuzione ricevuta

Destinazione Bash sul fisico pilota, già installato con bind locale. Il solo comando di modifica avvia il servizio Netdata; i successivi leggono API, listener, memoria del servizio e stato ACLK. Non avvia un modello Ollama, non modifica il driver e non crea il ricevitore sul Debian. [Controllo del servizio](https://learn.netdata.cloud/docs/netdata-agent/maintenance/service-control) e [CLI](https://learn.netdata.cloud/docs/netdata-agent/agent-cli) documentano avvio, API info e stato Cloud; l’[endpoint Prometheus](https://learn.netdata.cloud/docs/exporting-metrics/prometheus) è il punto di prova delle metriche.

```bash
cd /
sudo systemctl start netdata.service
curl --fail --silent --show-error --retry 5 --retry-delay 2 --retry-connrefused --max-time 10 http://127.0.0.1:19999/api/v1/info
systemctl show netdata.service --property=ActiveState --property=SubState --property=MainPID --property=MemoryCurrent --property=Result
sudo ss -lntp '( sport = :19999 )'
sudo /opt/netdata/bin/netdatacli aclk-state
netdata_metrics_file=$(mktemp /tmp/netdata-metrics.XXXXXXXX)
curl --fail --silent --show-error --max-time 10 'http://127.0.0.1:19999/api/v1/allmetrics?format=prometheus&source=as-collected' --output "$netdata_metrics_file" && awk '/^netdata_system_cpu/ {cpu++; if(cpu<=2) print} /^netdata_system_ram/ {ram++; if(ram<=2) print} END {printf "cpu_samples=%d ram_samples=%d\n",cpu,ram; if(cpu==0 || ram==0) exit 1}' "$netdata_metrics_file"
```

Output ricevuto dall’operatore il 15/10/2026. Il criterio preparato richiedeva il listener soltanto `127.0.0.1:19999`, non una wildcard; lo stato del servizio deve essere active/running senza risultato di errore. Il collector CPU e quello RAM devono entrambi fornire campioni: il riepilogo conta le righe metriche dei due prefissi, non macchine né secondi. Lo scaricamento su un file temporaneo precede il filtro, e il filtro si esegue solo se curl riesce; una risposta assente non viene contata come una prova verde. La disponibilità iniziale ha retry limitati; un risultato senza campioni richiede distinguere inizializzazione da collector assente prima di cambiare la configurazione.

Lo stato ACLK deve distinguere build con supporto Cloud da nodo claimed/connected: una feature compilata non dimostra una connessione attiva. Il marker di opt-out e il mancato claim non sostituiscono il controllo dello stato effettivo. Questa lettura non è un monitoraggio prolungato del traffico. `MemoryCurrent` è un’istantanea del servizio e non chiude la misura di impatto prima/dopo sullo stesso carico. La GPU resta da collaudare dopo aver riconciliato l’utility con il modulo 595.99.02; il solo Agent non rende disponibile `nvidia-smi`.

## Configurazione prima del primo avvio

La configurazione è stata scritta con HTTP e metriche limitati a `127.0.0.1:19999`; l’ascolto effettivo è ora verificato su loopback, con la lettura ss dell’operatore. L’accesso del futuro Prometheus sarà una modifica esplicita, con indirizzi e percorso di rete verificati. Per il primo collaudo non si apre una porta a tutta la LAN. La sola installazione dell’Agent non invia gli eventi di sistema al collettore e non crea Grafana, Prometheus o Loki.

Un Agent non collegato a Cloud, con telemetria e aggiornamenti automatici disattivati, può funzionare autonomamente secondo la documentazione ufficiale. Questo riguarda il runtime standard: installazione, eventuali collector configurati verso destinazioni esterne e risorse caricate da una UI sono percorsi distinti. Il collaudo usa le API locali e deve verificare versione, configurazione effettiva, stato non collegato e traffico, senza dedurre l’isolamento dal nome di un flag.

## Collaudo e ripristino da eseguire

| Fase | Criterio di riuscita | Stato |
|---|---|---|
| Assenza di conflitti e driver | Servizio e percorsi pregressi identificati, versione NVIDIA letta | Riscontro ricevuto: servizio e percorsi assenti, modulo 595.99.02 |
| Pacchetto | Archivio della release verificato, installazione senza avvio e senza aggiornamenti automatici | Installato 2.12.1, hash entrambi OK, mancato avvio iniziale verificato, successivamente avviato; opt-out presente; updater conferma DISABLED |
| Primo avvio locale | Servizio attivo, unico ascolto autorizzato, versione e dati API coerenti | Active/running, listener loopback, CPU/RAM presenti e ACLK non online; resto aperto |
| Metriche di sistema | Campioni CPU, memoria, disco e rete presenti; carico e crescita prima/dopo registrati | CPU/RAM locali presenti; disco/rete, crescita e impatto prima/dopo ancora da misurare |
| GPU | Utility compatibile, query eseguibile dall’utente Agent, metriche reali e non soli grafici vuoti | Ripristino già documentato e nvidia-smi riuscito nella verifica separata; APT non propone operazioni; utente Netdata verificato; campioni GPU Netdata ancora aperti |
| Servizio applicativo | Ollama ancora raggiungibile; confronto prima/dopo sullo stesso carico concordato | Non eseguito; nessun modello avviato per la prova |
| Eventi al collettore | Originali tecnici separati dagli accessi AdS, ricezione, code e silenzio verificati | Non configurato |
| Console comune | Raccolta Prometheus e ricerca tecnica Grafana/Loki con autenticazione e risorse dimensionate | Non installata |

La baseline attuale della memoria non misura l’impatto dell’Agent e `ollama ps` vuoto non è un test prestazionale. Prima di dichiarare concluso il pilota si misurano servizio, memoria del processo, CPU e crescita disco nello stesso contesto; un’inferenza Ollama può essere usata solo dopo aver scelto un carico ripetibile. Nessuna prova richiede OOM, crash GPU o riavvio del fisico.

Per un problema dopo il primo avvio, il primo ripristino previsto è fermare e disabilitare il solo servizio Netdata, conservando configurazione e dati per la diagnosi. L’eventuale rimozione completa segue il disinstallatore ufficiale e il file `.environment` dell’installazione effettiva, dopo averne verificato i percorsi; non è un comando di cancellazione ricorsiva generico. Se Netdata era già presente, si ripristina la copia iniziale invece di trattarlo come una nuova installazione. Driver, modelli e unità Ollama rimangono fuori da questa procedura.

## Fonti ufficiali lette il 15/10/2026

| Fonte | Uso nel runbook |
|---|---|
| [Release v2.12.1](https://github.com/netdata/netdata/releases/tag/v2.12.1) | Identifica la versione candidata; non prova il funzionamento sull’host |
| [Installer del tag v2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/packaging/installer/kickstart.sh) | Copia scaricata e letta: flag effettivi, avvio rinviato e limite del controllo del checksum con versione fissata |
| [Installazione Linux](https://learn.netdata.cloud/docs/netdata-agent/installation/linux) e [build statica](https://learn.netdata.cloud/docs/netdata-agent/installation/linux/static-binary-linux-packages) | Percorsi supportati, architettura e separazione dalle librerie del sistema |
| [Protezione dell’Agent](https://learn.netdata.cloud/docs/netdata-agent/configuration/securing-agents) | Porta predefinita e bind esplicito prima di esporre le metriche |
| [Comunicazioni in uscita](https://learn.netdata.cloud/docs/security-and-privacy-design/netdata-agent#outbound-network-communication) | Claim, telemetria e aggiornamenti sono controlli distinti per il runtime autonomo |
| [Collector NVIDIA](https://learn.netdata.cloud/docs/collecting-metrics/collectors/hardware-and-sensors/nvidia-gpu) e [CLI Ollama](https://docs.ollama.com/cli) | Prerequisito `nvidia-smi` e significato dell’elenco dei modelli caricati |
| [Disinstallazione](https://learn.netdata.cloud/docs/netdata-agent/maintenance/uninstall) | Rimozione coerente con metodo e `.environment` effettivi |

## Estrazione nel template richiesta dall’operatore

Il 15/10 l’operatore richiede, al termine del lavoro, un pacchetto utile in altri progetti: procedura, strumenti e stack locale riproducibili e parametrizzati. La [specifica del pacchetto](progetto-pacchetto-linux-observability.md) è condivisa con il progetto rete e registrata anche nel template, fuori dal catalogo dei pacchetti eseguibili fino al completamento. Destinazione proposta `.claude/templates/linux-observability/`, con profili Agent/hub/log, esempi senza valori reali, release e hash fissati, preflight, rendering, controlli negativi, persistenza, aggiornamento e ripristino.

L’estrazione dovrà includere Netdata, Prometheus, Grafana OSS e Loki/Alloy locali, con accesso e risorse configurati per l’istanza. Non si considera completata copiando questi comandi: servono primo avvio, metriche reali, ricezione degli eventi, consultazione e recupero dello stack misurati. L’adozione in un altro progetto deve superare una prova con parametri diversi, senza identità, percorsi temporanei o credenziali del pilota. Commit, push e propagazione del template restano manuali.

## Riscontro del primo avvio e limiti della misura

| Controllo eseguito dall’operatore | Riscontro | Che cosa non dimostra |
|---|---|---|
| systemctl show | active/running, Result success | Stabilità dopo reboot e prestazioni a regime |
| ss sulla porta 19999 | Un listener TCP su 127.0.0.1:19999 del processo Netdata | Accesso remoto da Prometheus o cifratura del percorso futuro |
| API info | v2.12.1, una macchina locale, stream disabilitato, dbengine | Campi di build HTTPS/Cloud non provano trasporti attivi; zero grafici/metriche in questa risposta non risolve il conteggio reale |
| netdatacli aclk-state | Claimed No, Online No, reconnect count zero | Assenza di qualsiasi traffico esterno durante un periodo prolungato |
| Export Prometheus locale | 14 righe col prefisso CPU e 4 RAM; righe campione di system.cpu e system.ram | Numero complessivo delle serie, GPU, salute di tutti i collector o integrazione centrale |
| MemoryCurrent | 389820416 byte, 371,76 MiB, circa 372 MiB | È memoria del cgroup, non RSS del solo processo né misura prima/dopo |

Il campo API charts-count=0 e metrics-count=0 precede l’export con campioni. Entrambi i riscontri sono conservati: non si attribuisce senza prova il primo valore all’inizializzazione né si usa per negare i campioni successivi. I valori guest/guest_nice zero nelle due righe mostrate non equivalgono a utilizzo complessivo CPU nullo. I conteggi del filtro riguardano prefissi; non sono 14 macchine o 14 secondi. La funzione journal elencata nell’API non dimostra che i log siano già inoltrati, e exporting-enabled=false non impedisce l’endpoint di pull appena letto.

La capacità disco aggregata riportata nell’API non è lo spazio libero della radice. La quota dbengine e il page-cache-size riportati non sono un limite totale dell’installazione. Dati identificanti, PID, API selezionata e campioni con timestamp sono nell’evidenza privata operator-first-start-excerpts.txt e operator-first-start-selected.json; sono estratti fedeli e campi selezionati, non una cattura completa di rete o una copia integrale dell’API. La [normalizzazione e capienza](normalizzazione-retention-capienza.md) distingue log, metriche ed evidenze; il [registro fonti e passi](fonti-osservabilita-linux.md) collega la sequenza completa.

## Inventario utility GPU: lettura ricevuta

Destinazione: stesso terminale Bash del fisico pilota. Sono inventario locale e metadati APT, senza aggiornamento dei repository o installazione. Servono a confrontare pacchetti user-space e modulo già caricato 595.99.02; i precedenti suggerimenti command-not-found indicavano anche 595.71.05, quindi scegliere soltanto il numero di ramo non basta. La [documentazione del collector NVIDIA](https://learn.netdata.cloud/docs/collecting-metrics/collectors/hardware-and-sensors/nvidia-gpu) richiede nvidia-smi; il percorso e la configurazione della release installata saranno verificati dopo questa lettura.

```bash
cd /
command -v nvidia-smi || printf 'nvidia-smi assente dal PATH\n'
cat /proc/driver/nvidia/version
dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\t${Version}\n' '*nvidia*'
apt-cache policy nvidia-utils-595 nvidia-utils-595-server libnvidia-compute-595 libnvidia-compute-595-server
```

Output ricevuto il 15/10/2026: la tabella seguente distingue componenti installati e candidati della cache APT. Un elenco vuoto o pacchetto assente è un dato di inventario; non autorizza a installare un driver differente. La fase successiva del Debian richiederà una baseline separata di spazio, mount, CPU, RAM, servizi e code prima di installare lo stack centrale.

## Riscontro GPU: componenti e versione candidata

Il modulo caricato è NVIDIA UNIX Open Kernel Module 595.99.02, compilato con GCC 15.2.0 secondo il testo ricevuto. Dpkg mostra installati il modulo per il kernel 7.0.0-38, firmware NVIDIA e kernel-common 595.99.02, oltre al firmware grafico della distribuzione. Le righe rc dei tre vecchi moduli sono pacchetti rimossi con configurazione residua; le righe un sono voci non installate, non prove di ulteriori driver in uso. Il [manuale dpkg-query](https://manpages.debian.org/trixie/dpkg/dpkg-query.1.en.html) documenta gli stati abbreviati. Non è stata richiesta o eseguita pulizia di tali residui. Le versioni dei vecchi pacchetti non dimostrano da sole la storia dell’aggiornamento del sistema.

| Pacchetto interrogato | Installato | Candidato nella cache riferita | Interpretazione |
|---|---|---|---|
| nvidia-utils-595 | Nessuno | 595.99.02-0ubuntu0.26.04.1 | Candidato standard corrispondente al modulo 595.99.02 |
| libnvidia-compute-595 | Nessuno | 595.99.02-0ubuntu0.26.04.1 | Libreria candidata alla stessa versione delle utility |
| nvidia-utils-595-server | Nessuno | 595.91.07-0ubuntu0.26.04.2 | Versione diversa, non selezionata per il modulo attuale |
| libnvidia-compute-595-server | Nessuno | 595.91.07-0ubuntu0.26.04.2 | Versione diversa, non selezionata per il modulo attuale |

Le quattro policy indicano anche la versione base 595.58.03; i candidati aggiornati sono proposti da resolute-updates/restricted e resolute-security/restricted amd64 a priorità 500. È una misura della cache locale ricevuta, non un aggiornamento degli indici o una prova di download. Le precedenti proposte command-not-found 595.71.05 sono uno stato storico diverso, senza prova qui di quando siano cambiate le liste. La [guida Ubuntu](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/) distingue pacchetti standard e server e descrive il rischio di disallineamento fra libreria e modulo. Le due versioni standard sono quindi candidate motivate; la compatibilità operativa rimane da provare tramite lettura della GPU.

## Simulazione delle dipendenze APT: esecuzione ricevuta

Destinazione: stesso terminale Bash del fisico pilota, cartella radice; nessun repository Git interessato. Il [manuale APT](https://manpages.debian.org/trixie/apt/apt-get.8.en.html) documenta la simulazione senza applicazione delle operazioni, il blocco delle rimozioni e la selezione per versione. Il manuale della variante Ubuntu resolute non è stato recuperato; la fonte Debian documenta la semantica dei flag, mentre il resolver sulla macchina reale fornirà la misura delle dipendenze effettive. Si usa sudo per evitare letture parziali della configurazione APT segnalate dal manuale per le simulazioni senza privilegi. Non si esegue apt update o upgrade, non si installano pacchetti e non si riavviano servizi.

```bash
cd /
sudo apt-get --simulate --no-install-recommends --no-remove install nvidia-utils-595=595.99.02-0ubuntu0.26.04.1 libnvidia-compute-595=595.99.02-0ubuntu0.26.04.1
```

Il comando fissa entrambe le versioni richieste, omette i pacchetti soltanto raccomandati e interrompe il resolver se occorrono rimozioni. Quest’ultima opzione non vieta da sola ogni possibile aggiornamento: per questo il piano intero va letto prima di preparare l’installazione. Le righe Inst, Conf e Remv sono operazioni simulate, non modifiche avvenute. Criterio da verificare sull’output integrale: dipendenze risolte, nessuna rimozione, nessuna sostituzione/aggiornamento di driver, moduli o pacchetti inattesi, sole aggiunte comprese e versioni coerenti. Errori, pacchetti held o proposte inattese lasciano il passo aperto; non si ripete senza simulate per tentare di risolverli.

Output della simulazione ricevuto: entrambi i pacchetti risultano già alla versione richiesta, con zero aggiornati, zero installati, zero da rimuovere e zero non aggiornati. Non viene proposta una seconda installazione; il ripristino già documentato in testa al runbook spiega il cambiamento rispetto all’inventario precedente. Il prossimo controllo riguarda l’utente Netdata e il collector. Il testo dell’inventario ricevuto è conservato integralmente nella trascrizione privata operator-gpu-packages-transcript.txt; operator-gpu-packages-selected.json mantiene i campi e i limiti. La sua impronta identifica il testo conservato, non certifica autonomamente l’esecuzione remota. Le nuove evidenze e lo stesso stato sono già riportati nel contesto e nella timeline del progetto rete.

## Riconciliazione fra inventario, ripristino e simulazione

Il nuovo output APT non contraddice il mancato nvidia-smi del preflight: fra i due stati il dossier condiviso registra il ripristino delle utility e della libreria. La simulazione non può essere la causa dell’installazione: il [manuale APT](https://manpages.debian.org/trixie/apt/apt-get.8.en.html) ne documenta il carattere senza applicazione delle operazioni. Il riepilogo tutto a zero vale per questa richiesta sullo stato attuale, non certifica ogni possibile manutenzione del sistema. Non è stato fornito un codice di uscita separato e non si inventa un timestamp dell’esecuzione dell’operatore.

La prova privata nvidia-post-upgrade-20261015.json, già presente e identica nei due progetti, ha SHA verificato e riporta una lettura separata riuscita alle 13:53:37 UTC: GPU riconosciuta, librerie caricabili e un dispositivo CUDA. Questa è evidenza trasferita dal progetto d’origine, non una nuova misura remota di questo giro. I riferimenti sorgenti rimangono nel file; non sono stati aperti per importare risultati di benchmark. L’esecuzione di un’inferenza Ollama e l’effettiva raccolta Netdata di utilizzo, VRAM e temperatura non risultano collaudate da quella prova. Le precedenti ricerche di nomi NVIDIA avevano trovato soltanto stati delle unità systemd: non equivalgono a metriche hardware.

La trascrizione integrale del testo APT ricevuto è in operator-gpu-apt-simulation-transcript.txt e il suo riepilogo è in operator-gpu-apt-simulation-selected.json. Lo stato corrente dei pacchetti è ora presente, mentre l’inventario precedente resta conservato come fotografia storica. La parte di ripristino aggiunta da un altro lavoro al dossier non viene sovrascritta; nessuna operazione Git viene compiuta dall’assistente corrente.

## Utente del collector e file effettivi: riscontro ricevuto

Il [file distribuito nel tag 2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/config/go.d/nvidia_smi.conf) contiene già un job nvidia_smi. Il [codice del collector](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/collector/nvidia_smi/collector.go) usa il binario nvidia-smi e un controllo che fallisce senza metriche; lo [schema di configurazione](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/collector/nvidia_smi/config_schema.json) documenta binary_path, timeout e loop_mode. La presenza del job distribuito non prova che il processo corrente lo stia eseguendo: configurazione locale, permessi ed errori di avvio vanno letti. Non si assume automaticamente che l’installazione tardiva delle utility abbia fatto ripartire il collector.

Destinazione: stesso terminale Bash del fisico pilota. Si leggono la GPU come utente netdata, il file originale nel prefisso statico e l’eventuale override locale. La query è diagnostica, senza caricare un modello o cambiare driver. Il comando journal segue il [percorso ufficiale del collector](https://learn.netdata.cloud/docs/collecting-metrics/collectors/hardware-and-sensors/nvidia-gpu): namespace Netdata, solo messaggi del modulo, giornata corrente e massimo 40 righe. Nessun riavvio o nuova configurazione è incluso.

```bash
cd /
sudo -u netdata /usr/bin/nvidia-smi --query-gpu=name,driver_version,memory.total,memory.used,temperature.gpu --format=csv
sudo cat /opt/netdata/usr/lib/netdata/conf.d/go.d/nvidia_smi.conf
if sudo test -f /opt/netdata/etc/netdata/go.d/nvidia_smi.conf; then sudo cat /opt/netdata/etc/netdata/go.d/nvidia_smi.conf; else printf 'Nessuna configurazione NVIDIA personalizzata\n'; fi
sudo journalctl --namespace=netdata --since today --no-pager --grep nvidia_smi -n 40
```

Criterio: query GPU riuscita anche come netdata, file e job effettivi identificati e diagnostica di avvio disponibile. File assente, accesso negato o zero messaggi sono risultati da conservare, non prove di raccolta riuscita. In particolare, nessun messaggio nel journal non dimostra un collector sano; il controllo conclusivo dovrà leggere chart e campioni con contesto nvidia_smi, escludendo i soli stati systemd. Output ricevuto: query come netdata riuscita, job distribuito presente, override assente e comando enable accettato nel journal. I campioni Netdata rimangono da verificare; prima di qualunque modifica si prepara il delta e il ripristino sul file realmente osservato.

## Riscontro dell’utente di servizio e comando accettato

| Lettura riferita dall’operatore | Risultato | Limite |
|---|---|---|
| Query nvidia-smi come netdata | NVIDIA GeForce RTX 5060 Ti, driver 595.99.02; 16311 MiB totali, 34 MiB usati, 36 Celsius | Il binario è leggibile/eseguibile per quell’utente; non prova inferenza Ollama o pipeline del collector |
| File distribuito nvidia_smi.conf | jobs con name nvidia_smi, testo mostrato coerente con quello del tag | È confronto del testo ricevuto, non hash autonomamente letto dal filesystem remoto |
| Configurazione personalizzata | Assente nel percorso interrogato | Non è una verifica di ogni possibile override globale o dinamico |
| Journal, 15/10 alle 15:12:21 | Job manager go.d: command enable, state accepted, result_status 202 | Evento di accettazione; esecuzione del job, durata, autore e metriche non dedotti da questa sola riga |

La trascrizione integrale ricevuta è nel livello privato operator-gpu-netdata-user-transcript.txt; i campi e i limiti sono in operator-gpu-netdata-user-selected.json. Non è stata aperta una nuova connessione SSH dall’assistente e non è stata cambiata la configurazione. La lettura del journal limitata ai messaggi del modulo e alla giornata non dimostra assenza di altri messaggi o errori. I valori VRAM e temperatura sono una singola osservazione nvidia-smi: non certificano l’impatto dell’Agent o l’assenza di carichi applicativi.

## Prossima prova: campioni hardware nell’export locale

Il [sorgente charts.go del tag 2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/collector/nvidia_smi/charts.go) definisce i contesti nvidia_smi.gpu_utilization, nvidia_smi.gpu_frame_buffer_memory_usage e nvidia_smi.gpu_temperature. Le [regole dell’export Prometheus](https://learn.netdata.cloud/docs/exporting-metrics/prometheus) collegano il nome al contesto e distinguono as-collected dalle medie. Il controllo fissa prefix=netdata e richiede quei tre nomi, escludendo gli stati delle unità systemd che contengono soltanto la parola NVIDIA. Questa verifica riguarda il pilota con una GPU osservata; l’estensione a più GPU richiederà il confronto per identificativo del dispositivo.

Destinazione: stesso terminale Bash del fisico pilota, directory radice. Si scarica l’export in un file temporaneo e si filtra solo se curl riesce. Il file resta disponibile per la diagnosi. Il filtro richiede numeri finiti e timestamp non più vecchi di 60 secondi, con tolleranza di 5 secondi verso il futuro rispetto al date della stessa macchina. Sono criteri interni del collaudo, non limiti dichiarati dal produttore; errore di clock o formato inatteso lascia la prova aperta. Il valore di utilizzo zero è ammesso, perché una GPU a riposo può essere correttamente monitorata.

```bash
cd /
netdata_gpu_metrics_file=$(mktemp /tmp/netdata-gpu-metrics.XXXXXXXX)
curl --fail --silent --show-error --max-time 15 'http://127.0.0.1:19999/api/v1/allmetrics?format=prometheus&source=as-collected&prefix=netdata&timestamps=yes' --output "$netdata_gpu_metrics_file" && awk -v now_ms="$(date +%s%3N)" 'function fresh(s,a){sub(/^.*}[ \t]+/,"",s); if(split(s,a,/[ \t]+/)!=2) return 0; return a[1] ~ /^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$/ && a[2] ~ /^[0-9]+$/ && now_ms-a[2]>=-5000 && now_ms-a[2]<=60000} /^netdata_nvidia_smi_gpu_utilization\{/ && fresh($0){gpu++; if(gpu<=2) print} /^netdata_nvidia_smi_gpu_frame_buffer_memory_usage\{/ && fresh($0){vram++; if(vram<=3) print} /^netdata_nvidia_smi_gpu_temperature\{/ && fresh($0){temp++; if(temp<=1) print} END{printf "gpu_samples=%d vram_samples=%d temp_samples=%d\n",gpu,vram,temp; if(gpu==0 || vram==0 || temp==0) exit 1}' "$netdata_gpu_metrics_file"
```

Ci si attendono righe con i tre contesti, identificativi/chart, valori e timestamp, seguite da gpu_samples, vram_samples e temp_samples tutti maggiori di zero. I totali contano righe corrispondenti, non dispositivi o secondi; le dimensioni VRAM possono produrre più righe. In questa sorgente as-collected si leggono i valori con le unità e le eventuali scale del contesto, senza chiamare percentuale un contatore o assumere unità da una stringa arbitraria. Il controllo dimostra presenza e freschezza puntuale; continuità, impatto e invio al Debian restano prove separate.

La procedura è stata provata in WSL senza rete o servizi: sintassi Bash, 14 fixture con tre gruppi, gruppi mancanti, zero valido, etichette con spazi, stati systemd, HTML/commenti, dati vecchi/futuri, NaN/Inf, timestamp assenti e contesto simile errato. Togliendo la guardia VRAM il suo caso mancante passa erroneamente; togliendo il limite di età il caso vecchio passa erroneamente. Comando originale ripristinato/verificato invariato; un curl fittizio fallito impedisce il filtro. È verifica della procedura, non dei campioni del pilota: output reale ancora atteso.
