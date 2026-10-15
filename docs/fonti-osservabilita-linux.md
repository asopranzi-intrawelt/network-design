# Fonti e passi dell’osservabilità Linux

Stato al 15/10/2026. Questo registro collega le fonti tecniche alla sequenza del pilota e alle nuove scelte per il Debian. Requisito permanente dell’operatore: ogni passo deve riportare motivo, fonte con URL/data/versione, destinazione, comando, criterio di riuscita, risultato ricevuto, interpretazione e limiti; evidenze identificanti nel livello privato con impronta SHA-256. Una fonte scaricata non è per questo letta; una documentazione corrente non prova la compatibilità della versione installata. Gli aggiornamenti successivi mantengono gli stati precedenti come storia, rendendo esplicito quello corrente.

## Sequenza e provenienza

I comandi e le spiegazioni sono nel [runbook](runbook-monitoraggio-linux.md). Le letture iniziali dell’operatore sono state hostname, os-release, uname -m, free, df, nvidia-smi e presenza di Netdata; poi lspci -nnk, /dev/dri, ollama ps e apt-cache policy netdata. L’output effettivo e i nomi reali sono conservati come estratti dichiarati, non come acquisizione remota autonoma dell’assistente. Nessun hash di un estratto certifica da solo l’origine host.

| Passo | Ragione e risultato | Evidenza privata nella directory pilot; limite |
|---|---|---|
| 1. Sistema e capacità iniziali | Ubuntu 26.04.1 x86_64, RAM e radice lette; utility assente | operator-preflight-excerpts.txt; istantanea, non benchmark |
| 2. PCI, dispositivo e APT | RTX 5060 Ti con nvidia in uso; Netdata senza candidato APT | Stesso preflight; non prova indisponibilità repository ufficiali |
| 3. Modulo e conflitti | Modulo 595.99.02, servizio e directory Netdata assenti | operator-dry-run-excerpts.txt; utility e GPU non collaudate |
| 4. Artefatto e dry-run | Script del tag con hash OK; piano statico senza avvio | Script e release-source-files.json; banner di successo simulato non è installazione |
| 5. Lettura del codice | Ramo statico online fissato salta il confronto esterno del pacchetto | kickstart fissato; scelto bundle verificato separatamente |
| 6. Preparazione offline | Archivio e checksum OK, nome alias legato alla release | operator-offline-preparation-excerpts.txt; hash archivio distinto da hash script |
| 7. Errore del percorso | Sanitizzazione rimuove slash, verifica file successiva fallisce | Stesso estratto; prima procedura difettosa, installazione non avviata |
| 8. Correzione misurata | Leaf semplice in preparazione, sorgente assoluta in installazione | offline-path-proof.json; funzioni originali isolate, niente payload |
| 9. Recupero reale | Due hash ricontrollati, installazione statica 2.12.1 completata | operator-installed-excerpts.txt; esecuzione dell’operatore |
| 10. Configurazione prima dell’avvio | Backup, opt-out, bind loopback; servizio loaded/inactive/enabled | Stesso estratto e state.json; updater DISABLED riferito, timer/cron da leggere |
| 11. Guardie della prova | CPU e RAM entrambi necessari; fallimento curl impedisce il filtro | first-start-command-proof.json; fixture e mutazione, nessuna API reale |
| 12. Avvio reale | active/running, Result success e listener loopback | operator-first-start-excerpts.txt; non prova reboot o stabilità prolungata |
| 13. API e stato Cloud | v2.12.1, un host; Claimed No e Online No | operator-first-start-selected.json; campi selezionati, non dump integrale o analisi del traffico |
| 14. Metriche e memoria | Righe CPU/RAM presenti; cgroup circa 372 MiB | Estratti primo avvio; conteggio per prefissi, impatto a regime ignoto |
| 15. GPU | Ripristino e simulazione riconciliati; query come netdata riuscita e configurazione letta | Trascrizioni e prova handoff; comando enable accettato, campioni hardware Netdata ancora attesi |
| 16. Normalizzazione e risorse | Contratto comune, retention, budget e guardie richiesti | Documento di progetto; nessuna applicazione sul Debian |
| 17. Debian e stack centrale | Baseline, dimensionamento, parser e servizi da realizzare | Nessuna evidenza runtime ancora disponibile |
| 18. Pacchetto riutilizzabile | Specifica nei tre progetti, estrazione dopo collaudo | Documento di proposta; catalogo e pacchetto non ancora completati |

## Registro dei collegamenti

Consultazione di questo giro: 15/10/2026. Le fonti del pilota già citate restano rintracciabili sotto con il documento che le usa; la loro presenza non implica un nuovo recupero o una nuova verifica in questo giro. Per quelle recuperate ora, URL, data UTC, esito HTTP, SHA-256 e file sono nel manifest privato sources/retrievals-reviewed.json. Le copie ufficiali XML sostituiscono i due manuali freedesktop non recuperati; il manuale Proxmox inizialmente rifiutato dal lettore web è stato recuperato via HTTPS pubblico locale, senza credenziali. Nessun contenuto respinto è indicato come letto.

| Collegamento ufficiale | Stato e uso | Documento del percorso |
|---|---|---|
| [NCUL1](https://app.netdata.cloud/LICENSE.txt) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [documentazione Docker](https://docs.docker.com/engine/install/linux-postinstall/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [CLI Ollama](https://docs.ollama.com/cli) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [code rsyslog](https://docs.rsyslog.com/doc/concepts/queues.html) | Letto il 15/10: tipi di coda, maxDiskSpace/size e saveOnShutdown | normalizzazione-retention-capienza.md |
| [template rsyslog](https://docs.rsyslog.com/doc/configuration/templates.html) | Letto il 15/10: mapping JSONF, tipi e template list/subtree; versione target da verificare | normalizzazione-retention-capienza.md |
| [Repository Netdata](https://github.com/netdata/netdata) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md, progetto-pacchetto-linux-observability.md |
| [pubblicato per 2.12.1](https://github.com/netdata/netdata/releases/download/v2.12.1/sha256sums.txt) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [Release v2.12.1](https://github.com/netdata/netdata/releases/tag/v2.12.1) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [lettura file di Alloy](https://grafana.com/docs/alloy/latest/reference/components/loki/loki.source.file/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md, progetto-pacchetto-linux-observability.md |
| [datasource Prometheus di Grafana](https://grafana.com/docs/grafana/latest/datasources/prometheus/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Loki locale](https://grafana.com/docs/loki/latest/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md, progetto-pacchetto-linux-observability.md |
| [etichette Loki](https://grafana.com/docs/loki/latest/get-started/labels/) | Letto il 15/10: cardinalità delle etichette e metadati | normalizzazione-retention-capienza.md |
| [retention Loki](https://grafana.com/docs/loki/latest/operations/storage/retention/) | Letto il 15/10: Compactor e politiche per stream; target ancora da fissare | normalizzazione-retention-capienza.md, progetto-pacchetto-linux-observability.md |
| [Licenze Grafana Labs](https://grafana.com/licensing/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Grafana OSS](https://grafana.com/oss/grafana/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md |
| [Notifiche custom](https://learn.netdata.cloud/docs/alerts-&-notifications/notifications/agent-dispatched-notifications/custom) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Linux Hardware Sensors](https://learn.netdata.cloud/docs/collecting-metrics/collectors/hardware-and-sensors/linux-hardware-sensors-libsensors) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [NVIDIA GPU](https://learn.netdata.cloud/docs/collecting-metrics/collectors/hardware-and-sensors/nvidia-gpu) | Letto il 15/10: prerequisito nvidia-smi e configurazione del collector, non prova della release installata | osservabilita-linux-netdata.md, runbook-monitoraggio-linux.md |
| [Export metriche](https://learn.netdata.cloud/docs/exporting-metrics) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Netdata e Prometheus](https://learn.netdata.cloud/docs/exporting-metrics/prometheus) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md, progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [Gestione dei log](https://learn.netdata.cloud/docs/logs-management) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Plugin journal](https://learn.netdata.cloud/docs/logs-management/systemd-journal-logs/systemd-journal-plugin-reference) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [CLI](https://learn.netdata.cloud/docs/netdata-agent/agent-cli) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [database Netdata](https://learn.netdata.cloud/docs/netdata-agent/configuration/database) | Letto il 15/10: limiti per tier, tempo/spazio e obiettivi soft | normalizzazione-retention-capienza.md, progetto-pacchetto-linux-observability.md |
| [Protezione dell’Agent](https://learn.netdata.cloud/docs/netdata-agent/configuration/securing-agents) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [Installazione Linux](https://learn.netdata.cloud/docs/netdata-agent/installation/linux) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [bundle offline ufficiale](https://learn.netdata.cloud/docs/netdata-agent/installation/linux/offline-systems) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [build statica](https://learn.netdata.cloud/docs/netdata-agent/installation/linux/static-binary-linux-packages) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [Controllo del servizio](https://learn.netdata.cloud/docs/netdata-agent/maintenance/service-control) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [Disinstallazione](https://learn.netdata.cloud/docs/netdata-agent/maintenance/uninstall) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | runbook-monitoraggio-linux.md |
| [Parent e Child](https://learn.netdata.cloud/docs/netdata-parents/parent-child-configuration-reference) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Accesso e disponibilità delle funzioni](https://learn.netdata.cloud/docs/security-and-privacy-design/access-control-and-feature-availability) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |
| [Comunicazioni in uscita](https://learn.netdata.cloud/docs/security-and-privacy-design/netdata-agent#outbound-network-communication) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [modello log](https://opentelemetry.io/docs/specs/otel/logs/data-model/) | Letto il 15/10: tempi evento/osservazione, severità, Body, Resource e Attributes | normalizzazione-retention-capienza.md, progetto-pacchetto-linux-observability.md |
| [TSDB Prometheus](https://prometheus.io/docs/prometheus/latest/storage/) | Letto il 15/10: retention time/size, WAL/Head e spazio di compattazione | normalizzazione-retention-capienza.md, progetto-pacchetto-linux-observability.md |
| [manuale qm](https://pve.proxmox.com/pve-docs/qm.1.html) | Letto il 15/10: balloon e comandi di resize; compatibilità target da confrontare | normalizzazione-retention-capienza.md |
| [parser del kickstart 2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/packaging/installer/kickstart.sh) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | progetto-pacchetto-linux-observability.md, runbook-monitoraggio-linux.md |
| [modello storage](https://raw.githubusercontent.com/proxmox/pve-docs/master/pvesm.adoc) | Letto il 15/10: tipi di storage e configurazioni; non una misura del pool reale | normalizzazione-retention-capienza.md |
| [guida della memoria](https://raw.githubusercontent.com/proxmox/pve-docs/master/qm.adoc) | Letto il 15/10: memoria fissa/dinamica, pressione del nodo e ballooning | normalizzazione-retention-capienza.md |
| [journald](https://raw.githubusercontent.com/systemd/systemd/main/man/journald.conf.xml) | Letto il 15/10: SystemMaxUse/KeepFree e cancellazione dei soli file archiviati; ramo main | normalizzazione-retention-capienza.md |
| [controlli systemd](https://raw.githubusercontent.com/systemd/systemd/main/man/systemd.resource-control.xml) | Letto il 15/10: MemoryHigh/MemoryMax e pesi relativi CPU/I/O; ramo main, non versione Debian | normalizzazione-retention-capienza.md, progetto-pacchetto-linux-observability.md |
| [Prezzi e condizioni dei piani](https://www.netdata.cloud/pricing/) | Già citato nel percorso; nessuna nuova lettura dichiarata qui | osservabilita-linux-netdata.md |

## Registro privato e aggiornamenti successivi

La radice privata è _notes/linux-observability-20261015/: inventario, pilot/state.json, prove dei comandi, estratti dell’operatore e cache delle fonti. Il manifest evidence-manifest.json registra percorsi, dimensioni e SHA dei materiali effettivamente presenti al momento di questo giro; non elenca file assenti come se esistessero. Le due copie di progetto condividono il dossier e le evidenze del pilota; le fonti scaricate sono copiate nella rete con il manifest. I valori compilati e le credenziali non entrano nei file versionati del template. Le pagine correnti restano da confrontare con le release effettive prima del rilascio dello stack.

## Artefatti fissati del pilota

Le impronte sono quelle dei file effettivamente acquisiti e confrontati nel percorso del pilota. Per script e checksum le copie sono nel livello privato; l’archivio completo è stato scaricato e verificato sul fisico dall’operatore. Non si attribuisce all’assistente una copia locale dell’archivio da lui non scaricata. Il nome alias latest usato dal bundle è legato all’impronta della release 2.12.1, non a un aggiornamento implicito.

| Artefatto ufficiale | SHA-256 e uso |
|---|---|
| [kickstart.sh del tag v2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/packaging/installer/kickstart.sh) | a3a6e66f0784fb105c926c4503f023a41f3fad1992b7b4b855248d5d730075dc; parser, dry-run e percorso offline letti nel giro del pilota |
| [Installer statico del tag](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/packaging/makeself/install-or-update.sh) | dea0ac0e3b73221b6e9fff1fa2df1bbec517b7cee0520c3228be547e37a4b13c; opzioni e modifiche di sistema lette |
| [Checksum ufficiali 2.12.1](https://github.com/netdata/netdata/releases/download/v2.12.1/sha256sums.txt) | 8601258acc70ebdad44021d459b66dc849c48f1e22ff35cbb314ca2fe922d42c; digest del file che elenca gli archivi |
| [Archivio statico x86_64 2.12.1](https://github.com/netdata/netdata/releases/download/v2.12.1/netdata-x86_64-v2.12.1.gz.run) | f4a73a7b2641f5d962afdf648948e3d472ab18759e906e9e3164cbb7c697147e; confronto del bundle riferito OK dall’operatore |

Le nuove istruzioni incorporano le lezioni dell’errore del percorso: verificare il comportamento reale del parser, concatenare al successo le modifiche dipendenti e mantenere il difetto nel registro. Il prossimo riscontro richiesto riguarda soltanto utility e pacchetti GPU; nessuna installazione è inclusa nel blocco preparato.

## Fonti del confronto GPU e della simulazione, 15/10/2026

| Fonte ufficiale | Sezione effettivamente consultata e limite |
|---|---|
| [APT trixie](https://manpages.debian.org/trixie/apt/apt-get.8.en.html) | Selezione versione, simulate, no-install-recommends e no-remove; fonte della semantica, non misura del resolver Ubuntu |
| [dpkg-query trixie](https://manpages.debian.org/trixie/dpkg/dpkg-query.1.en.html) | Stati abbreviati e differenza fra installato, rimosso con residui e non installato |
| [Ubuntu NVIDIA](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/) | Lettura del modulo, varianti server e mismatch user-space/kernel; nessuna procedura di sostituzione driver eseguita |
| [APT resolute](https://manpages.ubuntu.com/manpages/resolute/en/man8/apt-get.8.html) | Recupero web e HTTPS locale non riusciti, fonte non letta e non usata come evidenza |

Cache e URL/data/SHA delle fonti nuove in sources/retrievals-gpu-apt-reviewed.json, separati dal recupero precedente per conservarne la storia. La tabella di versioni dei quattro pacchetti e le origini dei candidati provengono dall’output dell’operatore, non da una ricerca web o da un catalogo ricostruito. La simulazione non blocca lo stato APT contro cambiamenti concorrenti: il futuro piano di installazione dovrà essere confrontato nuovamente con quello rivisto.

## Esito ripristino NVIDIA e prova CUDA, 15/10/2026

Pacchetti NVIDIA ripristinati dopo la rimozione finale nella migrazione Ubuntu: nvidia-utils-595 e libnvidia-compute-595 alla versione 595.99.02-0ubuntu0.26.04.1, coerente col modulo 595.99.02. Verifica indipendente del 15/10/2026: nvidia-smi funzionante, RTX 5060 Ti con 16.311 MiB, libcuda/NVML caricabili, cuInit=0 e un dispositivo CUDA. Ollama, Veeam e Netdata attivi; nessun reboot o riavvio servizi richiesto. Nessuna inferenza LLM e nessun collaudo GPU di Ollama dichiarato. Nell'API Netdata compaiono soltanto stati delle unità systemd NVIDIA, non metriche GPU di utilizzo, VRAM o temperatura: questa verifica resta aperta, insieme all'impatto a regime. Nessun nuovo flusso al collettore, nessuna chiusura dei gate AdS, nessun risultato del benchmark trasferito.

Il [runbook](runbook-monitoraggio-linux.md#ripristino-nvidia-dopo-migrazione-ubuntu-15102026) distingue installazione, caricamento librerie e prova di inferenza ancora assente. La prova privata ha SHA-256 6924038e39f88a8b302fb611897cb435920d39ae4461366448ebc2aac977db06. I riferimenti Ubuntu/CUDA/NVML già riportati descrivono il comportamento; le letture dell'host attestano l'esito locale.

## Simulazione ricevuta e collector della release fissata

Il risultato APT e la prova di ripristino già presente sono due fonti distinte: il primo riferito dall’operatore ora, la seconda trasferita come handoff tecnico. Il dossier e lo stato strutturato mantengono questa provenienza senza attribuire nuove sessioni SSH all’assistente corrente. Il testo ricevuto è conservato integralmente, la prova privata precedente mantiene il proprio hash e i riferimenti originali.

| Fonte primaria del tag v2.12.1 | Lettura del 15/10/2026 e limite |
|---|---|
| [Configurazione distribuita nvidia_smi](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/config/go.d/nvidia_smi.conf) | Job presente nel file originale; copia/configurazione effettive sull’host ancora da leggere |
| [Collector Go](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/collector/nvidia_smi/collector.go) | Selezione del binario, timeout e Check senza metriche; non prova processo o retry in esecuzione |
| [Schema configurazione](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/collector/nvidia_smi/config_schema.json) | Opzioni del modulo nella release fissata; non applicato come nuova configurazione |

Il lettore web non ha recuperato configurazione e schema; successivo recupero HTTPS pubblico locale riuscito per tutti e tre i sorgenti, poi letti integralmente. File originali e URL/data/SHA in sources/retrievals-gpu-collector-reviewed.json. Nessun contenuto fallito viene citato come consultato: la prova è il recupero successivo conservato. La documentazione corrente del collector aiuta per la diagnostica, ma le opzioni di rilascio si confrontano con il tag e con i file dell’host prima di applicarle.

## Utente Netdata verificato e criteri dei campioni, 15/10/2026

La fonte delle nuove misure è il testo dell’operatore, non una nuova sessione SSH. Trascrizione completa, configurazione distribuita mostrata, override assente e riga del journal sono registrati separatamente dalla prova locale del filtro. Il link master nel commento del file distribuito è un riferimento incorporato nell’output, non una nuova verifica della branch corrente; le definizioni usate per il controllo provengono dal tag fissato.

| Collegamento | Consultazione e perimetro |
|---|---|
| [charts.go v2.12.1](https://raw.githubusercontent.com/netdata/netdata/v2.12.1/src/go/plugin/go.d/collector/nvidia_smi/charts.go) | Lette le tre definizioni: nomi dei contesti, dimensioni e unità GPU/VRAM/temperatura; non prova del runtime |
| [Export Prometheus](https://learn.netdata.cloud/docs/exporting-metrics/prometheus) | Nomi da contesto, prefix, source=as-collected e timestamp; endpoint locale già provato per CPU/RAM, GPU da ricevere |
| [README master citato dal file originale](https://github.com/netdata/netdata/tree/master/src/go/plugin/go.d/collector/nvidia_smi#readme) | Riferimento presente nel commento; non letto in questo giro e non usato per attribuire feature alla release |

Il lettore web non ha recuperato charts.go; recupero HTTPS locale successivo riuscito e conservato. URL, date UTC, SHA e sezioni consultate in sources/retrievals-gpu-metrics-reviewed.json. La prova della procedura in pilot/gpu-metric-command-proof.json usa soltanto campioni costruiti e controlli del fallimento: non afferma di avere interrogato la GPU reale. Soglie di freschezza scelte per questo collaudo e limiti sono nel runbook; il manifest delle evidenze distingue file condivisi e copie presenti solo nel collettore.
