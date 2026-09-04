---
last-verified: 6750252
---

# Stack e struttura del progetto

## Componenti principali

Verificata il 04/09/2026 contro il contenuto reale di `scripts/`: la revisione precedente ne elencava cinque su ventuno. La tabella e' ora esaustiva ed e' l'indice; la descrizione estesa di ciascuna famiglia sta in `CLAUDE.md` e nelle sezioni piu' sotto.

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
| `scripts/Export-PortMatrix.py` | Configurazione delle porte dei due switch dallo snapshot Nebula a `data/port-matrix.json`, **tracciato**; nessun MAC in uscita |
| `scripts/Test-TopologyDrift.py` | Confronta la fonte della mappa con snapshot Nebula e Proxmox e riporta gli scostamenti; non aggiorna e non decide (hook SessionStart) |

Guard-rail e igiene, da eseguire prima di ogni commit che tocchi documentazione.

| Componente | Ruolo |
|---|---|
| `scripts/Test-Anonymization.py` | Passa tutti i file tracciati in cerca di valori reali; i pattern vivono in `_notes/`, non nello script |
| `scripts/Check-OneDriveDelta.ps1` | Delta delle tre radici OneDrive sorvegliate vs baseline locale (hook SessionStart) |
| `scripts/Check-SecurityAnomalies.ps1` | Verifica le anomalie note di GAP-TBC e del runbook; gli indirizzi si passano come parametri, non sono cablati |
| `scripts/Set-ProjectSecret.ps1` | Scrive o ruota un segreto nel blocco `env` di `settings.local.json`, unico posto dove vivono i token (ADR-021) |
| `tools/md-unwrap.py` | Attua la convenzione di una riga sorgente per paragrafo; `--check` esce diverso da zero se qualche file non la rispetta |

Scrittura verso gli apparati, l'unica famiglia che non e' di sola lettura. Gira in prova per impostazione predefinita e richiede `-Apply` piu' una conferma testuale (ADR-010).

| Componente | Ruolo |
|---|---|
| `scripts/Set-NebulaWifiVlan.ps1` | Assegna la VLAN Wi-Fi alle porte degli access point e la propaga sui trunk (M13a) |
| `scripts/Set-ApTestIsolation.ps1` | Spegne e riaccende il PoE degli access point per isolarne uno durante una prova di connessione |
| `scripts/New-ScanFolderShortcut.ps1` | Distribuito dall'RMM: crea sul desktop il collegamento alla cartella di scansione sul NAS (R8) |

Fonti e artefatti che non sono script.

| Componente | Ruolo |
|---|---|
| `data/network-topology.json` | Fonte strutturata della mappa, scritta a mano, tracciata |
| `data/port-matrix.json` | Matrice delle porte, derivata dallo snapshot Nebula, tracciata |
| `.claude/context/diagrams/network-topology.mmd` | Diagramma Mermaid della topologia |
| `docs/infrastructure-timeline/` | Storia cronologica degli interventi di rete |
| `_notes/` | Layer narrativo locale, ignorato da git |
| `output/` | Output degli script a runtime, ignorato da git: contiene nomi host, utenti e indirizzi reali |

## Script Get-ProxmoxSnapshot.ps1

- Linguaggio: PowerShell 5.1
- Autenticazione: cookie PVEAuthCookie via WebRequestSession (workaround PS5.1)
- TLS: TrustAllCertsPolicy via Add-Type (certificato self-signed Proxmox)
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

Dei tre, **solo la riconciliazione e' automatizzata** sull'hook di avvio, e la ragione va tenuta: legge tre file gia' sul disco, non scrive niente, non apre connessioni e non usa credenziali. Gli script che rinfrescano gli snapshot restano manuali per scelta, perche' fanno chiamate autenticate al fornitore e perche' se si rinfrescassero da soli il confronto non potrebbe piu' dire "questa misura e' vecchia", che e' meta' del suo valore.

## Gli script dell'autorita' di certificazione (ADR-024, ADR-025, dal 01/09/2026)

`crea-autorita.sh` ed `emetti-certificato.sh` sono versionati, non contengono alcun valore reale e **non si eseguono su una macchina della rete**: girano sulla cartella dell'autorita', che ADR-025 vuole fuori linea e protetta da passphrase, perche' chi possiede la chiave privata di un'autorita' puo' emettere un certificato valido per qualunque nome e ogni macchina che la consideri attendibile lo accettera' senza avvisi.

La sequenza e' controintuitiva e va rispettata: prima l'autorita', poi il certificato del gestore delle password, poi il deposito della passphrase dentro il gestore. La passphrase non puo' stare nel gestore prima che il gestore funzioni, e il gestore non funziona senza certificato. Al 04/09/2026 i due script sono scritti e **non ancora eseguiti**.
