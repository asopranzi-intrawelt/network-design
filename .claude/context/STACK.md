---
last-verified: 0ca70f8
---

# Stack e struttura del progetto

## Componenti principali

Verificata il 04/09/2026 contro il contenuto reale di `scripts/`: la revisione precedente ne elencava cinque su ventuno. La tabella e' ora esaustiva ed e' l'indice; la descrizione estesa di ciascuna famiglia sta nelle sezioni piu' sotto, fino in fondo alla scheda.

Lettura delle fonti vive, tutte in sola lettura.

| Componente | Ruolo |
|---|---|
| `scripts/Get-ProxmoxSnapshot.ps1` | Snapshot completo infrastruttura Proxmox via REST API |
| `scripts/Get-NebulaSnapshot.ps1` | Snapshot organizzazione Zyxel Nebula via API REST (organizzazioni, siti, dispositivi, stato porte, tabella MAC L2 per switch) |
| `scripts/Get-NebulaConnectivityHistory.ps1` | Diagnostica di NEB-001: storico online/offline e log eventi dei due switch, su due endpoint Nebula che nessun altro script usa |
| `scripts/Get-NinjaSnapshot.ps1` | Snapshot della gestione endpoint: organizzazioni, dispositivi, policy, automazioni, interfacce di rete per dispositivo. Credenziali del provider MSP, scope di sola lettura (ADR-017) |
| `scripts/Get-NinjaScriptOutput.ps1` | Raccoglie per intero l'esito di un'automazione su piu' endpoint, che la console tronca a video (nato per M27-8) |
| `scripts/Invoke-HostCensus.ps1` | Driver: copia ed esegue uno script di ricognizione su piu' host via SSH e ne raccoglie l'esito in `output/`. Parametri `-Script`, `-Argomenti`, `-Prefisso` |

Ricognizione su host, script POSIX di sola lettura eseguiti tramite il driver.

| Componente | Ruolo |
|---|---|
| `scripts/censimento-host.sh` | I quattro livelli a cui puo' vivere un filtro su un host Linux (M27-7) |
| `scripts/ispeziona-tls.sh` | Server web, predisposizione TLS e certificati presenti sulla macchina; dei certificati legge i soli campi pubblici |
| `scripts/sonda-tls.sh` | Interroga un endpoint **dalla rete** e legge il certificato realmente presentato, che e' cio' che determina l'avviso del navigatore |
| `scripts/trova-ca.sh` | Cerca per contenuto un'autorita' di certificazione su un host e ne valuta la custodia; l'elenco dei percorsi attraversati e' dichiarato dentro lo script |
| `scripts/trova-ca-container.sh` | Da dove un contenitore prende il proprio certificato, quando la ricerca sull'host non trova nulla ma il servizio ne presenta uno |

Autorita' di certificazione interna, da eseguire sul supporto rimovibile che custodisce la chiave (ADR-024, ADR-025).

| Componente | Ruolo |
|---|---|
| `scripts/crea-autorita.sh` | Genera l'autorita' aziendale. Si esegue **una volta sola** |
| `scripts/emetti-certificato.sh` | Emette un certificato di servizio con i nomi alternativi, firmato dall'autorita' |

Generazione di artefatti derivati, e loro riconciliazione.

| Componente | Ruolo |
|---|---|
| `scripts/Build-TimelineSvg.ps1` | Timeline SVG anonimizzata dai md della timeline (hook SessionStart) |
| `scripts/Build-NetworkMap.ps1` | Mappa di rete interattiva in `docs/network-map.html` da `data/network-topology.json` piu' il template (M26, ADR-023) |
| `scripts/IsoRoadmap.py` | Registro operativo ISO 27001: valida `data/iso27001-interventi.json` e il glossario dei codici, registra avanzamenti e genera sempre la vista Markdown di progetto; su richiesta esporta copie HTML identiche sul Desktop e nella cartella ISO privata di OneDrive, con CSS e JavaScript incorporati |
| `scripts/Build-OnovaReconciliation.py` | Riconciliazione datata della checklist VA privata con i fatti del progetto: anteprima in `output/`, originale conservato, aggiornamento e controllo della sezione aggiunta; percorsi e indirizzi solo nella configurazione privata |
| `scripts/Export-PortMatrix.py` | Configurazione delle porte dei due switch dallo snapshot Nebula a `data/port-matrix.json`, **tracciato**; nessun MAC in uscita |
| `scripts/Test-TopologyDrift.py` | Confronta la fonte della mappa con snapshot Nebula e Proxmox e riporta gli scostamenti; non aggiorna e non decide (hook SessionStart) |

Guard-rail e igiene, da eseguire prima di ogni commit che tocchi documentazione.

| Componente | Ruolo |
|---|---|
| `scripts/Test-Anonymization.py` | Passa tutti i file tracciati in cerca di valori reali; i pattern vivono in `_notes/`, non nello script |
| `scripts/Check-OneDriveDelta.ps1` | Delta delle tre radici OneDrive sorvegliate vs baseline locale (hook SessionStart) |
| `scripts/Check-SecurityAnomalies.ps1` | Verifica le anomalie note di GAP-TBC e del runbook; gli indirizzi si passano come parametri, non sono cablati |
| `scripts/Set-ProjectSecret.ps1` | Scrive o ruota una delle quattro chiavi operative nel `.env` privato (ADR-031); ADR-021 descrive la configurazione storica |
| `tools/md-unwrap.py` | Attua la convenzione di una riga sorgente per paragrafo; `--check` esce diverso da zero se qualche file non la rispetta |
| `tools/chiudi-sessione.ps1` | Procedura Windows del template per stato, controlli, commit e push confermati dall'utente, verifica remota e impronta di ripresa; il comando breve e' `chiudi` nel profilo PowerShell |
| `scripts/Test-Allineamento.py` | Dice quali affermazioni stanno invecchiando: scadenze, freschezza delle fonti, invarianti strutturali, asserzioni umane scadute (ADR-026, hook SessionStart) |
| `scripts/Invoke-RefreshFonti.ps1` | Rinfresca Nebula e Proxmox da attivita' pianificata, senza mai promuovere una misura peggiore di quella in essere (ADR-026) |

Scrittura verso gli apparati, l'unica famiglia che non e' di sola lettura. Gira in prova per impostazione predefinita e richiede `-Apply` piu' una conferma testuale (ADR-010).

| Componente | Ruolo |
|---|---|
| `scripts/Set-NebulaWifiVlan.ps1` | Assegna la VLAN Wi-Fi alle porte degli access point e la propaga sui trunk (M13a) |
| `scripts/Set-ApTestIsolation.ps1` | Spegne e riaccende il PoE degli access point per isolarne uno durante una prova di connessione |
| `scripts/New-ScanFolderShortcut.ps1` | Distribuito dall'RMM: crea sul desktop il collegamento alla cartella di scansione sul NAS (R8) |
| `scripts/Set-BitlockerEscrow.ps1` | Distribuito dall'RMM: deposita nel campo personalizzato del dispositivo la password di ripristino BitLocker del volume di sistema, creando il protettore se assente e senza mai stampare la chiave (SEC-044). Con `-SoloVerifica` non scrive nulla e restituisce il censimento di stato cifratura, protettore di ripristino e WinRE, riga per macchina (SEC-046) |
| `scripts/Get-BitlockerReadiness.ps1` | Distribuito dall'RMM: diagnostica in sola lettura del perche' BitLocker non si attiva su un endpoint (edizione, TPM, Secure Boot, WinRE, partizione di ripristino, policy FVE) |

Fonti e artefatti che non sono script.

| Componente | Ruolo |
|---|---|
| `data/network-topology.json` | Fonte strutturata della mappa, scritta a mano, tracciata |
| `data/port-matrix.json` | Matrice delle porte, derivata dallo snapshot Nebula, tracciata |
| `data/iso27001-interventi.json` | Fonte unica degli interventi ISO 27001, inclusi stato, prove, dipendenze e forniture; `docs/roadmap-iso27001-operativa.md` e' generato |
| `data/iso27001-glossario.json` | Spiegazioni brevi dei riferimenti ISO e dei codici interni riportati nell'HTML; il generatore rifiuta nuovi codici senza spiegazione |
| `scripts/iso-roadmap-style.css`, `scripts/iso-roadmap-interactions.js` | Aspetto e navigazione offline dell'export HTML, incorporati nel singolo file generato |
| `.claude/context/diagrams/network-topology.mmd` | Diagramma Mermaid della topologia |
| `docs/infrastructure-timeline/` | Storia cronologica degli interventi di rete |
| `_notes/` | Layer narrativo locale, ignorato da git |
| `output/` | Output degli script a runtime, ignorato da git: contiene nomi host, utenti e indirizzi reali |

## Script Get-ProxmoxSnapshot.ps1

- Linguaggio: PowerShell 5.1
- Autenticazione: token `PVEAuditor` da `.env` privato; fallback ticket interattivo via cookie sullo stesso client HTTPS verificato.
- TLS: `scripts/ProxmoxVerifiedHttp.cs` verifica per connessione nome, validità, pin foglia, CA e catena; PEM e pin in `_notes/certs/`. Bypass globale e `-SkipCertificateCheck` rimossi il 12/10. Dry-run reale Windows PowerShell 5.1 riuscito; PowerShell 7 e task pianificato restano da osservare. Dettaglio nel dossier `docs/dossier-sicurezza-mcp-proxmox.md` §10.
- Output: JSON completo + report Markdown in `output/`
- Dati raccolti: nodi, reti, storage, VM QEMU, LXC, pool, firewall cluster e per-VM, SDN, backup schedules, HA, snapshot VM, dischi fisici, dispositivi PCI

## Script Get-NebulaSnapshot.ps1

- Linguaggio: PowerShell 5.1 / 7+
- Autenticazione: header `X-ZyxelNebula-API-Key`, chiave risolta da parametro -> variabile d'ambiente `NEBULA_API_KEY` -> prompt SecureString
- Output: JSON completo + report Markdown in `output/`
- Dati raccolti: organizzazioni, siti, inventario dispositivi (switch, AP, gateway...), stato porte e tabella MAC L2 per switch (nato per localizzare gli AP fisici per porta quando non compaiono come dispositivi Nebula, vedi ADR-009 e `runbook-anomalie.md` §AP-001)
- Nessuna dipendenza esterna: solo `Invoke-RestMethod` nativo

## Infrastruttura target

- Proxmox VE su `10.61.20.11:8006`
- Singolo nodo `pve`
- Tre storage pool: local, local-lvm, NAS_INTRA, NAS_HERO
- 4 bridge Linux: vmbr0 (10.61.20.x), vmbr1-3 (porte fisiche dedicate)
- 11 VM QEMU, 0 LXC allo snapshot del 24/08/2026

Due correzioni datate, entrambe misurate dopo la stesura di questa sezione. La corrispondenza fra bridge e porte fisiche **non e' piu' da dedurre**: incrociando gli indirizzi fisici delle macchine virtuali con le tabelle MAC dei due switch si e' determinato che `vmbr1` sta sulla porta 7, `vmbr2` sulla 9 e `vmbr3` sulla 11 del 54HP, mentre `vmbr0` esce dalla porta 52 verso lo switch QNAP **non gestito**, il che significa che la via di amministrazione dell'hypervisor attraversa un apparato senza visibilita' di livello 2 (#157, e ne discende la scelta di `vmbr1` per la DMZ al posto di `vmbr0`). E il conteggio delle macchine e' quello dello snapshot del 24/08/2026: la **VM 206 e' stata dismessa il 31/08/2026** e nessuno snapshot successivo l'ha ancora registrato, quindi il numero reale e' dieci e il dato qui sopra e' la misura, non lo stato.

## Dipendenze PowerShell

Nessuna dipendenza esterna. Lo script usa solo classi .NET integrate in PS5.1: `System.Net.WebRequestSession`, `System.Net.Cookie`, `System.Net.ServicePointManager`.

## Script del censimento dell'esposizione (M27-7, dal 31/08/2026)

`scripts/censimento-host.sh` interroga in sola lettura i quattro livelli a cui puo' vivere un filtro su un host Linux: il filtro di pacchetti del kernel con `ufw`, `nft` e `iptables`, le direttive di ammissione per indirizzo nella configurazione di nginx e Apache, le porte in ascolto con il processo che le tiene, i contenitori che pubblicano porte, e la configurazione di autenticazione del servizio SSH. Esiste perche' guardarne uno solo produce un quadro parziale, ed e' l'errore corretto il 31/08/2026 quando il censimento fatto con il solo `ufw` aveva mancato la restrizione per indirizzo attiva sulla VM 204. Non scrive nulla sull'host.

`scripts/Invoke-HostCensus.ps1` lo esegue su piu' host dalla postazione, copiandolo, lanciandolo e raccogliendo l'esito in `output/censimento-<host>.txt`. La ragione per cui esiste un driver invece di un comando da incollare e' di citazione, non di comodita': un comando con apici annidati che attraversa PowerShell e poi una shell remota si rompe prima di poter essere sbagliato nel merito, e ripeterlo a mano su nove macchine e' nove occasioni di sbagliarne una in silenzio. Nessuno dei due file contiene indirizzi o credenziali: gli host si indicano con gli alias del `~/.ssh/config` della postazione, che non fa parte del repository. L'output contiene nomi host e indirizzi reali e finisce in `output/`, ignorato da git.

## Script di ricognizione TLS, e la generalizzazione del driver (dal 01/09/2026)

`scripts/ispeziona-tls.sh` risponde in sola lettura alle tre domande che precedono l'aggiunta di HTTPS a un servizio interno: quale server web sta davanti all'applicazione e come le parla, se il supporto TLS e' gia' predisposto, e quali certificati esistano sulla macchina e di che natura siano. Dei certificati stampa soltanto i campi pubblici, cioe' soggetto, emittente, scadenza e se si tratti di un'autorita': non legge mai una chiave privata. L'ultimo dato e' quello che orienta la scelta fra certificati per servizio e autorita' interna.

`scripts/Invoke-HostCensus.ps1` ha ora il parametro `-Script`, che gli permette di eseguire su un host qualunque script di sola lettura invece del solo censimento, e `-Prefisso` per nominare i file di esito. La generalizzazione non e' un vezzo: nel corso della sessione del 31/08 e del 01/09 lo stesso comando incollato nella riga di comando si e' rotto per citazione **tre volte**, perche' attraversa PowerShell e poi una shell remota e ciascuno dei due livelli interpreta a modo proprio apici, barre verticali e virgolette. Trasferire un file ed eseguirlo elimina il problema alla radice, e la meccanica vale per qualunque ricognizione futura.

## La catena della mappa di rete (M26, ADR-023, dal 24/08/2026)

Tre script in fila, e la ragione della fila e' l'anonimizzazione. `Export-PortMatrix.py` estrae dallo snapshot Nebula la configurazione delle porte e la scrive in `data/port-matrix.json`, che e' tracciato; `Build-NetworkMap.ps1` legge quella e `data/network-topology.json` e genera `docs/network-map.html`; `Test-TopologyDrift.py` confronta la fonte con le misure vive e riporta dove non coincidono.

Il file intermedio esiste per un motivo preciso e non per comodita': lo snapshot vive in `output/`, ignorato da git perche' porta MAC e nomi host reali, mentre la mappa e' pubblica. Se il generatore leggesse lo snapshot, la mappa non sarebbe piu' rigenerabile da un clone e l'anonimizzazione dipenderebbe da un passaggio invisibile dentro il generatore. Con un intermedio tracciato, invece, cio' che finisce in pubblico si legge, si controlla con il guard-rail insieme a tutto il resto, e si diffa fra due revisioni.

Dei tre, la riconciliazione e' quella che gira sull'hook di avvio, e la ragione va tenuta: legge tre file gia' sul disco, non scrive niente, non apre connessioni e non usa credenziali. **Corretto il 04/09/2026, poche ore dopo essere stato scritto**: questa sezione proseguiva dicendo che gli script di rinfresco restassero manuali, e **ADR-026** lo ha superato in giornata. Nebula e Proxmox si rinfrescano da un'attivita' pianificata con `scripts/Invoke-RefreshFonti.ps1`, che promuove una misura nuova solo se valida; la gestione endpoint resta manuale perche' le sue credenziali sono del provider MSP. Vale la pena lasciare traccia del fatto che questa scheda si e' contraddetta con se' stessa nel giro di una mattina, perche' e' la dimostrazione in scala ridotta del difetto che ADR-026 esiste per combattere: un'affermazione corretta quando viene scritta non ha alcun meccanismo che la avvisi quando smette di esserlo.

## Gli script dell'autorita' di certificazione (ADR-024, ADR-025, dal 01/09/2026)

`crea-autorita.sh` ed `emetti-certificato.sh` sono versionati, non contengono alcun valore reale e **non si eseguono su una macchina della rete**: girano sulla cartella dell'autorita', che ADR-025 vuole fuori linea e protetta da passphrase, perche' chi possiede la chiave privata di un'autorita' puo' emettere un certificato valido per qualunque nome e ogni macchina che la consideri attendibile lo accettera' senza avvisi.

La sequenza e' controintuitiva e va rispettata: prima l'autorita', poi il certificato del gestore delle password, poi il deposito della passphrase dentro il gestore. La passphrase non puo' stare nel gestore prima che il gestore funzioni, e il gestore non funziona senza certificato. Al 04/09/2026 i due script sono scritti e **non ancora eseguiti**.

## Descrizione estesa delle famiglie di script

Le sezioni che seguono stavano nel `CLAUDE.md` fino al 13/10/2026 e sono state spostate qui verbatim, senza riscriverle: dicono che cosa fa ogni famiglia di script, che cosa scrive e quali vincoli rispetta, e servono quando si tocca uno di quegli script, non a ogni sessione. Nel `CLAUDE.md` restano le sole regole che valgono comunque. Il guard-rail di anonimizzazione chiude la serie perche' e' il controllo che passa su cio' che tutte le altre producono.

## Script Proxmox

`scripts/Get-ProxmoxSnapshot.ps1` interroga l'API REST di Proxmox VE (IP reale in `_notes/.anonymization-map.md`, non qui: repo pubblico) e produce lo snapshot completo dell'infrastruttura in `output/proxmox-snapshot.json` e `output/proxmox-config.md`. L'output e' ignorato da git (dati infrastrutturali sensibili). Eseguire dalla radice del progetto passando l'host reale a `-ProxmoxHost` (vedi `.claude/rules/anonymization.md`).

## Script di salute delle macchine virtuali

Questo repository e' la fonte unica degli strumenti per le VM: gli altri progetti, come il convertitore dei ruolini, non ne tengono copia e rimandano qui. `scripts/vm-health/` contiene i presidi che si installano dentro una VM Linux (atop, controllo ogni 5 minuti con allarmi nel journal, watchdog interno, driver watchdog fuori dalla blacklist di Ubuntu) e il README con la catena degli allarmi e le lezioni del pilota sulla VM 204; si installano dalla postazione con `scripts/Install-VmHealth.ps1 -Target <alias>`, che chiede la password di sudo a schermo. `scripts/Watch-VmHealth.ps1` gira ogni 30 minuti come attivita' pianificata della postazione, controlla da fuori le VM di `_notes/vm-watch.json` (privato) e notifica in Windows solo i cambi di stato, una notifica per giro; `-Silenzioso` scrive solo in `output/vm-watch.log`, per le prove. L'estensione alle altre VM e' il micro-step M29 della roadmap.

## Script snapshot NinjaOne (gestione endpoint)

`scripts/Get-NinjaSnapshot.ps1` fotografa in **sola lettura** la gestione endpoint su NinjaOne (RMM): organizzazioni, dispositivi, policy, script, automazioni e interrogazioni diagnostiche, fra cui le interfacce di rete per dispositivo, che sono la fonte piu' rapida per il censimento degli indirizzi statici di M22a. Serve a questo progetto perche' gli endpoint non sono gestiti a mano: policy e automazioni agiscono su di loro e le password locali ruotano ogni trenta giorni, quindi qualunque credenziale di postazione memorizzata in un apparato di rete si rompe alla rotazione. Autenticazione OAuth2 client credentials con scope di sola lettura; il segreto si risolve da parametro, variabile d'ambiente o prompt a runtime e non viene mai scritto su disco. **Le credenziali API appartengono al provider MSP che gestisce l'RMM**: nessuno scope di scrittura, nessun valore nel repository. L'output va in `output/` (ignorato da git) perche' contiene nomi host, utenti e indirizzi reali. Decisione e vincoli in ADR-017 (`.claude/memory/decisions.md`).

## Script di controllo delta OneDrive

`scripts/Check-OneDriveDelta.ps1` confronta la cartella OneDrive "Documenti - IT" con una baseline locale (`_notes/.onedrive-manifest.json`, ignorata da git perche' contiene nomi di file reali) e riporta file nuovi, modificati ed eliminati rispetto all'ultimo triage della checklist di ingestione (`docs/infrastructure-timeline/ingestion-checklist.md`). Gira automaticamente a ogni avvio di sessione tramite hook SessionStart in `.claude/settings.local.json` (non versionato, percorsi di macchina). Dopo aver registrato in checklist le variazioni segnalate, rieseguirlo con `-UpdateBaseline`.

## Script timeline SVG

`scripts/Build-TimelineSvg.ps1` genera `docs/infrastructure-timeline/timeline.svg` (versionato, anonimizzato) dai file Markdown della timeline. Gira a ogni avvio di sessione tramite hook SessionStart (settings.local.json, non versionato). Ogni riga e' un accordion: il paragrafo che segue l'intestazione datata nel Markdown sorgente (il dettaglio ricostruito dai .docx ingeriti) diventa un pannello espandibile via script SVG nativo incorporato nel file (nessuna dipendenza esterna, resta un solo file .svg). L'interattivita' funziona quando l'SVG e' navigato direttamente o incluso via `<object>`/`<iframe>`/ inline nel DOM della pagina ospite; se la pagina esterna lo include con un tag `<img>`, il browser disabilita gli script per quel contesto e le righe restano leggibili ma non si espandono. I titoli legacy con nomi reali vengono anonimizzati a valle tramite `_notes/.svg-name-replacements.txt` (privato); un guard-rail avvisa se nei titoli o nei pannelli di dettaglio compare un IP non-placeholder. Lo script scrive solo dentro questo repository: vedi "Confine con E:\projects" piu' sotto.

## Script di scrittura dei segreti

Dal 09/10/2026 `scripts/Set-ProjectSecret.ps1` scrive o ruota una delle quattro chiavi operative nel `.env` privato del progetto, con ACL ristretto (ADR-031); ADR-021 descrive la configurazione storica, ora superata per queste chiavi. Il valore si digita a runtime come SecureString e non passa per chat, cronologia del terminale o argomenti di processo; durante la sostituzione e' scritto in un file temporaneo con lo stesso ACL ristretto del `.env`, poi eliminato. La sostituzione e' mirata alla singola chiave: il file temporaneo vuoto riceve prima l'ACL del `.env`, poi i dati; `File.Replace` crea un backup temporaneo che lo script elimina dopo la sostituzione. Il writer e l'ACL sono stati provati con valori finti; una rotazione reale richiede la verifica successiva dei consumer. La chiave deve appartenere alla whitelist del loader: crearne una nuova richiede una modifica del contratto `.env`. Dopo una rotazione si ripetono le prove dei consumer e si riavvia il server MCP, che legge `.env` all'avvio. Lo script e' versionato e non contiene nessun valore; il file che modifica non e' versionato.

## Script della mappa di rete interattiva

`scripts/Build-NetworkMap.ps1` genera `docs/network-map.html`, la mappa interattiva della topologia, a partire dalla fonte strutturata `data/network-topology.json` e dal template `scripts/templates/network-map.template.html`. E' l'attuazione di **ADR-023** e del micro-step **M26**, sullo stesso schema che gia' funziona per la timeline SVG: il deterministico prima del linguistico, e l'artefatto derivato nasce da uno script. Tre vincoli che lo script fa rispettare. Il file generato **non si modifica mai a mano**, e porta l'avvertenza in testa: se un dato e' sbagliato si corregge la fonte e si rigenera, altrimenti nasce una seconda verita' accanto alla prima. L'HTML e' **autoconsistente**, senza librerie esterne ne' richieste di rete, quindi si apre con un doppio clic anche offline. E la mappa **eredita l'anonimizzazione**: prima di scrivere, lo script cerca nel risultato indirizzi fuori dagli intervalli di documentazione e MAC non segnaposto, e si rifiuta di scrivere se ne trova. Lo script valida anche la fonte, cioe' rifiuta identificatori duplicati e riferimenti che non risolvono, che e' il modo in cui un file di topologia scritto a mano si rompe per primo.

Dalla revisione 3 del 24/08/2026 il template disegna un grafo vero invece di elencare schede: la disposizione si calcola a ogni apertura dalla sola fonte (ranghi per corsia, nodi fittizi sugli archi lunghi, ordinamento per baricentro, compattazione dei vuoti, attacchi distribuiti sul bordo dei nodi perche' altrimenti sotto lo switch con venti collegamenti si forma un pettine illeggibile). Quattro viste: Logica, Fisica come matrice luogo-per-corsia, Segmenti sui soli archi che dichiarano una VLAN con la ricaduta scritta nella pagina, ed Elettrica dalla presa a parete all'apparato. La capacita' su cui si regge l'uso operativo e' l'isolamento di un ramo, che mostra tutto cio' che dipende da un apparato piu' due salti di contesto a monte: si attiva dalla scheda, con doppio clic sul nodo, con il tasto `i`, o aprendo il file con il frammento `#isola=<identificatore>`. Il frammento accetta anche il nome di una vista, e le due cose si combinano con la virgola.

## Roadmap operativa ISO 27001

`data/iso27001-interventi.json` e' la fonte unica dei 47 interventi aperti il 28/09/2026: stato, prova di chiusura, dipendenze, responsabile e fornitura. `scripts/IsoRoadmap.py` genera `docs/roadmap-iso27001-operativa.md`. **L'agente deve registrare automaticamente, senza chiedere all'utente di lanciare comandi, ogni avanzamento o correzione rilevante nella stessa sessione in cui aggiorna il progetto o riceve la notizia.** Esegue `python scripts/IsoRoadmap.py advance <ID> --stato <stato> --nota "..."` e, per `completato`, aggiunge `--evidenza "..."`; il comando rigenera la vista nel progetto. Se cambia la necessita' di una fornitura, aggiornare la stessa voce nel registro senza lasciare il vecchio acquisto suggerito. A ogni avanzamento ISO, `advance` rigenera anche l'HTML privato `output/Roadmap ISO 27001 - rete.html` e le copie identiche sul Desktop e nella cartella ISO privata di OneDrive. `build --desktop` riallinea le copie anche senza un nuovo evento. Sono viste derivate di sola lettura: nessuna si modifica a mano. L'export incorpora il glossario di `data/iso27001-glossario.json`: ogni codice di controllo, clausola, gap, micro-step, decisione o intervento deve avere una sintesi consultabile nella vista interna dello stesso HTML. Le voci normative sono parafrasi operative della ISO/IEC 27001:2022, non citazioni del testo; il generatore rifiuta codici di riferimento non spiegati. Il CSS versionato in `scripts/iso-roadmap-style.css` e l'interazione in `scripts/iso-roadmap-interactions.js` sono incorporati nell'HTML; i percorsi del logo e della cartella ISO vivono solo in `_notes/iso-roadmap-brand.json` (privato e ignorato da Git). `python scripts/IsoRoadmap.py check`, richiamato anche da `Test-Allineamento.py`, controlla la vista nel progetto; `check --desktop` confronta esplicitamente l'HTML di progetto, Desktop e archivio con la fonte corrente. Il registro puo' seguire gli avanzamenti comunicati o verificati, ma non scoprire un cambiamento fisico su un apparato non interrogabile: dichiarare quel limite e chiedere evidenza. Le informazioni reali o identificanti non entrano nella fonte tracciata: la prova puo' essere citata per percorso o verbale senza trascriverne il contenuto.

La checklist VA Onova privata e' una fotografia storica del 06/11/2025 con 174 interventi. `scripts/Build-OnovaReconciliation.py` aggiunge nello stesso HTML una sezione datata che confronta dodici host/schede e le priorita' con lo stato del progetto; non modifica i finding originari, le spunte o le note che il browser conserva localmente. La configurazione con percorsi e indirizzi reali e' solo in `_notes/onova-reconciliation.json`, ignorato da Git. `preview` scrive l'anteprima in `output/`, `check` verifica l'allineamento e `apply` aggiorna la checklist privata conservando prima un originale nella stessa cartella. Dopo ogni cambiamento delle fonti elencate nella configurazione privata, rivedere i fatti, aggiornare la data e l'impronta delle fonti e poi rigenerare la sezione, senza promuovere un rilievo a risolto senza prova o nuovo VA. Il documento pubblico `docs/vulnerability-assessment-nov2025.md` riporta solo la sintesi anonimizzata.

La checklist Onova non ripete i codici, gli stati o le forniture ISO: mantiene i rilievi VA e il riscontro corrente sugli host e offre un collegamento alla Roadmap ISO. L'HTML ISO e' l'unica vista che riporta stato, prova richiesta, responsabile e fornitura degli interventi ISO; la data di esportazione ne dichiara la freschezza. In questo modo un aggiornamento VA rigenera Onova e un avanzamento ISO aggiorna il registro e la sua vista di progetto, senza mantenere due copie degli stessi stati.

Per collegare le VM, consultare `_notes/registro-credenziali.md` prima di chiedere alias o utenti all'IT Manager e confrontare la tabella con `docs/esposizione-servizi-interni.md`. La nota privata conserva la corrispondenza tra ID/nome Proxmox, prompt della macchina, alias `Host`, utente e nome del file chiave. Non leggere o copiare contenuti delle chiavi private e non salvare password. Se `C:\Users\Utente\.ssh\config` cambia, aggiornare la tabella nella stessa sessione.

## Script della matrice delle porte

`scripts/Export-PortMatrix.py` estrae dallo snapshot Nebula la configurazione completa delle porte dei due switch gestiti e la scrive in `data/port-matrix.json`, che e' **tracciato**. Esiste un file intermedio invece di leggere lo snapshot direttamente per una ragione precisa: lo snapshot vive in `output/`, ignorato da git perche' contiene MAC reali e nomi host, mentre la mappa e' pubblica. Se il generatore leggesse lo snapshot, la mappa non sarebbe piu' rigenerabile da un clone e l'anonimizzazione dipenderebbe da un passaggio invisibile dentro il generatore; con un file intermedio tracciato, invece, cio' che finisce in pubblico si legge, si controlla con il guard-rail insieme a tutto il resto, e si diffa fra due revisioni. Escono numero di porta, abilitazione, modalita' trunk, PVID, VLAN ammesse, stato del PoE e velocita' negoziata, che sono numeri di configurazione e non identificano nessuno. **Non escono gli indirizzi MAC**: della tabella MAC sopravvivono due aggregati, quante stazioni distinte si vedono su quella porta e in quali VLAN, che sono la parte informativa e servono a rispondere a "questa porta e' viva" e a "il traffico passa nella VLAN che mi aspettavo". Prima di scrivere, il risultato viene ripassato in cerca di MAC e in caso lo script non scrive, come gia' fanno gli altri due generatori. Il file alimenta la vista Porte della mappa; se manca, la mappa si costruisce lo stesso con una vista in meno invece che con un errore.

## Script di riconciliazione della mappa

`scripts/Test-TopologyDrift.py` confronta la fonte della mappa con le misure vive e riporta dove non coincidono. Non aggiorna niente e non decide niente: dice che la fonte afferma una cosa e l'apparato un'altra, e chi ha ragione lo stabilisce una persona. Esiste perche' `data/network-topology.json` la scrive a mano chi legge uno snapshot, e dopo niente la tiene allineata: se qualcuno sposta un telefono di porta o cambia un PVID, la mappa continua a disegnare la verita' di ieri con la stessa sicurezza di prima. Contro lo snapshot Nebula verifica che ogni porta dichiarata in un collegamento esista, sia abilitata, ammetta le VLAN dichiarate e abbia il PVID coerente, e che l'inventario degli apparati gestiti corrisponda; la corrispondenza fra nodo e dispositivo Nebula e' esplicita e vive nel campo `nebula` dei nodi della fonte, perche' un confronto per somiglianza di nome produce falsi positivi (gli access point la fonte li chiama per ruolo e Nebula per etichetta di sito). Contro lo snapshot Proxmox verifica che i bridge esistano, che ogni macchina virtuale della fonte esista ancora e che il bridge di attestazione sia quello reale. Su entrambi controlla l'eta' dello snapshot e si rifiuta di dichiarare un verde che non ha calcolato: se una fonte viva manca o e' piu' vecchia della soglia esce con codice 2 e lo dice. Si lancia con `python scripts/Test-TopologyDrift.py`, accetta `--giorni` per la soglia di eta' e `--silenzioso` per il solo verdetto, ed esce con 0 se allineata, 1 se ci sono scostamenti, 2 se non e' giudicabile. Le etichette che vengono dagli snapshot, cioe' nomi host e nomi di apparato, **non si stampano** se non con `--nomi`: quelle della fonte sono gia' pubblicabili perche' la fonte e' tracciata e passa il guard-rail, quelle di `output/` no, ed e' il motivo per cui quella cartella e' ignorata da git. L'output non va mai rediretto dentro un file tracciato.

Gira automaticamente a ogni avvio di sessione tramite hook SessionStart (`settings.local.json`, non versionato), accanto al delta OneDrive e alla timeline SVG. Fra i tre script della catena della mappa e' quello che si automatizza senza pensarci, e la ragione e' precisa: legge tre file gia' sul disco, non scrive niente, non apre connessioni e non usa credenziali. **Aggiornamento del 04/09/2026**: fino a quel giorno questo paragrafo proseguiva dicendo che gli script che **rinfrescano** gli snapshot restassero manuali per scelta, e con **ADR-026** non e' piu' vero. Nebula e Proxmox si rinfrescano ora da un'attivita' pianificata tramite `scripts/Invoke-RefreshFonti.ps1`, descritto piu' sotto; restano vere le tre ragioni operative di allora, cioe' che sono chiamate autenticate con una cadenza concordata che scrivono una copia datata, e infatti sono diventate le guardie di quello script. E' caduta invece la quarta ragione, quella secondo cui rinfrescando da soli il confronto non potrebbe piu' dire "questa misura e' vecchia": se le misure sono sempre fresche quel dubbio non serve, perche' ogni scostamento diventa senza ambiguita' un documento sbagliato. La gestione endpoint resta l'eccezione e resta manuale, perche' le sue credenziali sono del provider MSP (ADR-017).

## Controllo di allineamento e rinfresco automatico delle fonti

`scripts/Test-Allineamento.py` risponde alla domanda che nessuno degli altri controlli poneva: quali affermazioni di questo progetto stanno invecchiando in silenzio. Attua **ADR-026**, che stabilisce il principio da cui discende tutto il resto, cioe' che ogni affermazione dei file tracciati deve avere una verifica meccanica, una scadenza dichiarata dopo la quale torna a stato non verificata, oppure una marcatura esplicita di non verificabile con la domanda gia' scritta e la persona a cui porla. Non esiste un quarto caso: un'affermazione senza nessuna delle tre invecchia in silenzio, e il 04/09/2026 il progetto ne ha misurate tre nella stessa mattina, fra cui una copia di backup fuori sede ferma da sei settimane che ogni documento continuava a dare per esistente.

Legge `data/scadenze.json`, tracciato, che porta i dati: le scadenze con il loro preavviso, le cadenze delle fonti, e le asserzioni che nessun programma puo' verificare con la loro validita' dichiarata. Gli invarianti strutturali stanno invece nello script, perche' sono codice e non configurazione: gli script presenti in `scripts/` e non citati in `STACK.md`, gli ADR richiamati e non definiti, i difetti richiamati oltre il massimo del registro, la divergenza fra la mappa dei segnaposto e il file dei pattern, l'unicita' dei numeri e degli identificatori del registro dei difetti, e le schede il cui `last-verified` non copre l'ultima modifica di **contenuto**. Quest'ultimo invariante e' stato riscritto due volte l'08/09/2026, e la seconda riscrittura e' quella che conta: confrontare il campo con il commit che ha toccato la scheda per ultimo conserva una circolarita', perche' il bump scrive dentro la scheda e quindi crea un commit nuovo che la tocca, riportando il confronto in giallo e segnalando la sessione proprio per aver rispettato la regola. Il fatto che conta non e' quando la scheda e' stata scritta ma quando ne e' cambiato il contenuto: un commit che tocca il solo campo `last-verified` non e' una modifica della scheda, e' la sua firma. Il confronto e' percio' di discendenza e non di uguaglianza, cosi' resta verde anche chi rilegge una scheda immutata a una data successiva e ribumpa in avanti, che e' cio' che la regola del bump chiede di fare. L'invariante sull'unicita' nasce l'08/09/2026 da una collisione reale, cioe' due difetti diversi arrivati in un commit con lo stesso numero e lo stesso identificatore perche' scritti lo stesso giorno da due sessioni che non sapevano di condividere il file: il numero e' il modo in cui ogni scheda si riferisce a un difetto, quindi due voci allo stesso numero rendono ambiguo ogni richiamo. Il numero non ammette eccezioni e la sua collisione e' rossa; l'identificatore ne ammette due dichiarate, la riga di aggiornamento e la riga di seguito con suffisso di lettera, e il suo esito e' percio' un avviso. Gira a ogni avvio di sessione tramite hook, e' **rumoroso e non blocca** per decisione dell'IT Manager, e distingue nel codice di uscita il giallo dal rosso: il giallo e' un'affermazione che sta invecchiando e non marca la sessione come fallita, perche' un controllo che fallisce sempre smette di essere letto; il rosso e' qualcosa di gia' rotto.

`scripts/Invoke-RefreshFonti.ps1` rinfresca Nebula e Proxmox da un'attivita' pianificata, ed e' l'altra meta' di ADR-026: **supera** la regola che teneva manuale il rinfresco degli snapshot. Rispetta tre guardie. La misura buona non si sovrascrive mai, perche' il risultato si scrive in una cartella temporanea, si valida e solo allora si promuove; valido significa che contiene dispositivi, e il criterio viene dal fallimento reale del 05/08/2026, quando l'organizzazione declassata a Base Pack produsse uno snapshot valido e vuoto che avrebbe cancellato l'ultima misura completa. Un rinfresco fallito lascia un marcatore in `output/` che il controllo di allineamento riporta in rosso, e che sparisce da solo al primo rinfresco riuscito. Dal cutover M30 del 09/10/2026 le quattro chiavi operative sono nel `.env` privato con ACL ristretto; il job lo legge esplicitamente e non crea variabili d'ambiente persistenti di utente. La gestione endpoint resta fuori e resta manuale, perche' le sue credenziali appartengono al provider MSP (ADR-017).


## Guard-rail di anonimizzazione

`scripts/Test-Anonymization.py` passa i file del repository e riporta indirizzi reali, MAC reali, nomi propri di persona, caselle di posta personali, importi, numeri di telefono, IBAN, partite IVA e i segreti letterali gia' noti. Esce con codice diverso da zero se trova qualcosa nelle categorie bloccanti, e va eseguito prima di ogni commit che tocchi documentazione: `python scripts/Test-Anonymization.py`. Lo script e' versionato e non contiene nessun valore reale, perche' cio' che deve cercare vive in `_notes/.anonymization-patterns.json`, ignorato da git accanto alla mappa dei segnaposto; se quel file manca lo script si ferma invece di dare un verde non calcolato. Il primo passaggio, il 06/08/2026, ha trovato centoquarantotto riscontri su ottantanove file, nessuno introdotto di proposito: il controllo va fatto sull'intero albero e non sui soli file toccati, perche' un residuo non si introduce, si eredita.

Dal **07/09/2026** il perimetro non e' piu' quello dei soli file tracciati ma **cio' che sta per essere pubblicato**, cioe' i tracciati piu' i non tracciati e non ignorati, che sono i candidati al prossimo commit: fino a quel giorno un file nuovo era invisibile al controllo proprio nel momento in cui serviva guardarlo. Con `--tutti` entrano anche i file ignorati, `_notes/` e `output/`, i cui riscontri sono elencati a parte e **non bloccanti**, perche' quei file contengono valori reali per costruzione ed e' la ragione per cui git li ignora. Un percorso privato diventa bloccante nell'istante in cui viene tracciato, senza che nessuno debba cambiare la configurazione del controllo. Dettaglio in `.claude/rules/anonymization.md`.

## Processo fonti vive e retention, 16/10/2026

scripts/Invoke-SnapshotRetention.ps1 pianifica o applica la pulizia dei soli JSON datati in output: 90 giorni, protezione di pin con SHA, alias/ultima copia e riferimenti pubblicabili, rifiuto di reparse point. Invoke-RefreshFonti lo chiama solo dopo successo delle fonti e fuori dal DryRun; senza politica privata abilitata resta in anteprima. Test in tests/test_snapshot_retention.py: fixture isolate e cinque scenari del launcher; prove delle mutazioni nel livello privato. Procedura e fonti in docs/processo-fonti-vive-retention.md. Task Windows giornaliero osservato il 16/10 con esito 0 e sessione interattiva, distinto dall’attivazione della nuova pulizia ancora aperta; PowerShell 7 resta da collaudare.

| Componente di conservazione locale | Ruolo |
|---|---|
| `scripts/Invoke-SnapshotRetention.ps1` | Anteprima, applicazione manuale o attivazione della politica privata per i rinfreschi riusciti; dati reali esclusi da git |

## Sorgenti QA catalogate e ripresa con altro account preparata, 16/10/2026

Aggiunto docs/integrazione-log-qa-verifier.md: catalogo sorgenti del produttore QA e mapping al contratto comune. Campioni di codice in lavorazione e digest delle immagini candidate conservati privatamente; nessun nuovo componente runtime o flusso di raccolta installato. Retention snapshot abilitata dall’operatore dopo la milestone rete pubblicata.
## Dove si sviluppa il presidio della prestazione, 20/10/2026

Dopo ADR-037 conviene dire una volta che cosa di questo lavoro nasce qui e che cosa arriva da fuori, perche' il presidio della prestazione non si costruisce in questo repository. Qui vivono la regola e cio' che la rende verificabile: la decisione, i segnali scelti per ogni sorgente, la soglia e il suo riferimento misurato, il micro-step M32g della roadmap, i gap 222-223, la nota su ISO-30 e le letture preparate nel runbook. Qui non vivono il trasporto, gli archivi, l'hub di consultazione e gli esportatori: quelli sono di `D:/log-collector`, che tiene il pilota Agent, Prometheus, Grafana, Loki e Alloy e le sue prove, e che per ADR-013 non porta allarmi tecnici nel flusso degli accessi. L'host fisico di inferenza e' inoltre destinazione di `D:/intrawelt-qa-verifier`, che prevede su quella macchina un'istanza dedicata del servizio accanto a quella esistente: ogni decisione di capacita' su quella scheda riguarda due progetti insieme, e il rilievo del 20/10 dice che la capacita' misurata su quell'endpoint vale solo con la data accanto.

Ne segue il canale da cui le notizie arrivano, che e' quello della classe D e non una notifica. `scripts/Test-Allineamento.py` confronta a ogni avvio il commit riconciliato dei progetti elencati in `data/scadenze.json` sotto `progetti_collegati`: per ognuno un commit nuovo si legge nel diff e se ne porta qui soltanto cio' che cambia topologia, sorgenti, accessi, regole, backup, presidio o stato ISO. Dal 20/10/2026, su decisione dell'IT Manager, l'elenco comprende anche `intrawelt-qa-verifier` accanto a `log-collector` e `integrita-docs`, con baseline al commit `71a3892` del ramo `staging`, che e' l'ultimo davvero triagiato da questo progetto e non la sua testa: il controllo segnala percio' da subito i tre commit successivi, fra cui uno applicativo sul banco di prova, che restano da leggere. Il punto cieco che resta non e' piu' il progetto ma il ramo: la lettura si fa su `staging`, e un lavoro che vivesse su un altro ramo non comparirebbe nel confronto. Cio' che si porta qui per questo filone sono i segnali effettivamente raccolti, la soglia adottata, l'esito del riavvio pianificato dell'host e l'eventuale cambio di collocazione dell'istanza dedicata.
