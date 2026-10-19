# Dossier tecnico: credenziali, policy MCP e TLS Proxmox

Data della misura: 09/10/2026. Destinazione versionata: `D:/network-design/docs/dossier-sicurezza-mcp-proxmox.md`. I nomi dei nodi, gli indirizzi e le impronte integrali stanno nell'appendice privata `_notes/archivio-sessioni/rete-proxmox/materiali/proxmox-mcp-security-evidence-private-20261009.md`; questo dossier non contiene token o identificativi dell'organizzazione.

## 1. Perimetro e stato dichiarato

Questo intervento riguarda il **client MCP Proxmox avviato da Claude Code sulla postazione Windows**. Non installa software o credenziali sulla VM Debian del collettore dei log. Proxmox invia già i suoi eventi di autenticazione al collettore tramite un canale Syslog distinto; l'intervento MCP non cambia quel flusso. Lo script pianificato `Get-ProxmoxSnapshot.ps1` è un altro consumer HTTPS e va valutato separatamente.

I due rischi iniziali erano `PROXMOX_ALLOW_DANGER=true`, che lasciava disponibili gli strumenti MCP di modifica, e `PROXMOX_VERIFY_SSL=false`, che disattivava la verifica del certificato del server. La configurazione **attiva e collaudata** ha entrambi i flag corretti: `false` per i tool pericolosi e `true` per TLS. La chiusura è limitata al pacchetto e al runtime oggi misurati; non equivale alla chiusura di ISO-41 o di tutti i rischi Proxmox.

Termini usati sotto:

| Termine | Significato in questo progetto |
|---|---|
| MCP | Protocollo con cui Claude Code avvia un server locale e gli chiede l'elenco e l'esecuzione di strumenti. La risposta degli strumenti può essere letta da Claude. |
| `.mcp.json` | File versionato che dice a Claude quale programma lanciare. Oggi contiene percorso del launcher e i due flag, nessun valore di token. |
| `.env` | File privato ignorato da Git, con URL e credenziali locali. Gli ACL limitano gli account Windows che possono aprirlo, non isolano processi dello stesso account. |
| CA | Certificato pubblico dell'autorità del cluster che firma il certificato HTTPS del nodo; non è una chiave privata. |
| SAN | Elenco dei nomi e indirizzi ammessi nel certificato del nodo. Il client deve verificare il nome usato nell'URL contro il SAN. |
| `PVEAuditor` | Ruolo in sola lettura del token lato Proxmox; è una barriera server distinta dal catalogo MCP e dalla verifica TLS. |

## 2. Configurazione funzionante prima del test

La baseline era già successiva alla migrazione delle quattro chiavi operative dal JSON delle impostazioni locali di Claude a `.env`. Claude leggeva `.mcp.json`, avviava `scripts/start_proxmox_mcp.py`, e il launcher leggeva `.env` e passava le tre variabili Proxmox al processo `uvx proxmox-mcp`. La chiave Nebula non era passata al figlio MCP. L'URL usava l'IP di gestione; il certificato del nodo non includeva quell'IP nel SAN. Per far funzionare `list_nodes`, la configurazione aveva `PROXMOX_VERIFY_SSL=false`. Aveva anche `PROXMOX_ALLOW_DANGER=true`: il token `PVEAuditor` impediva le scritture lato server, ma il client esponeva comunque tool di modifica.

```text
Claude Code -> .mcp.json -> start_proxmox_mcp.py -> .env
                                            | tre valori Proxmox
                                            v
                                   uvx proxmox-mcp 0.1.0
                                            |
                                            v
                              API HTTPS Proxmox / token PVEAuditor

Flag della baseline: ALLOW_DANGER=true; VERIFY_SSL=false.
```

Questa baseline era **operativa**, misurata con `list_nodes`, e proprio per questo è stata salvata con hash per un rollback. La riuscita della lettura non dimostrava l'identità del server HTTPS né che un futuro token più potente sarebbe rimasto protetto.

## 3. Causa del primo fallimento: policy mancante nel pacchetto

Il primo tentativo ha cambiato soltanto `PROXMOX_ALLOW_DANGER` a `false`. `initialize`, elenco degli strumenti e connessione risultavano disponibili, ma una chiamata reale `list_nodes` falliva. Ripristinato il file precedente da backup con hash verificato, la stessa lettura tornava a riuscire. Questo è un test causale più forte del solo controllo che il processo parta: esercita la funzione richiesta dal progetto.

L'ispezione del **wheel 0.1.0 effettivamente avviato da `uvx`** ha trovato la causa: manca `config/safety_policy.json`. <!-- ref-assente --> Il loader del pacchetto crea quindi `safe_tools=[]`; con il flag a `false`, la funzione di controllo tratta anche `list_nodes` come azione non autorizzata. Il README upstream classifica `list_nodes` come sicuro, ma la descrizione del repository non corrispondeva ai byte installati. Il difetto è nel packaging o nella policy locale del server MCP, non nell'API Proxmox né nel ruolo del token.

Il rimedio locale fa quattro cose, in quest'ordine:

1. Fissa `proxmox-mcp==0.1.0` e calcola l'hash aggregato di tutti i 19 file Python del pacchetto **prima di importarlo**. Versione, numero o byte diversi fermano l'avvio.
2. Carica in memoria la policy dei dieci tool di lettura esaminati. Non modifica il wheel in cache.
3. Riduce il catalogo MCP ai medesimi dieci tool. Un tool non elencato non è chiamabile attraverso questo server.
4. Forza `PROXMOX_ALLOW_DANGER=false`. Il ruolo `PVEAuditor` continua a limitare le operazioni lato Proxmox.

I tool ammessi sono `list_nodes`, `list_lxc_containers`, `list_vms`, `get_instance_config`, `get_lxc_interfaces`, `list_storage`, `list_storage_content`, `get_task_status`, `get_task_log` e `get_resource_usage`. La lista è una scelta interna dopo esame del codice e delle chiamate GET del pacchetto; non è una promessa di sicurezza per versioni future. Il filtro usa il catalogo interno del pacchetto: se quella struttura cambia, l'hash o il controllo della struttura deve fermare l'avvio. Le prove offline con credenziali finte hanno ottenuto dieci tool, `list_nodes` ammesso e `delete_instance` negato. La stessa verifica è stata ripetuta sul nodo reale prima e dopo il cutover.

## 4. Catena TLS: CA, nome, runtime e confini di fiducia

La prima ricognizione ha letto **solo il certificato pubblico del nodo via handshake TLS**, senza richiesta HTTP e senza token. Il certificato era firmato dalla CA interna del cluster. Il vecchio URL API usava un IP assente dal SAN, mentre un nome DNS del nodo era presente ma non risolto sulla postazione. Impostare semplicemente `verify=true` sul vecchio URL avrebbe fallito la verifica del nome.

L'operatore ha letto il certificato pubblico da `/etc/pve/pve-root-ca.pem` nella Shell Proxmox. La prima trascrizione arrivata in chat mancava di quattro caratteri Base64: il decoder l'ha rifiutata. La sola riga incompleta è stata riletta dal nodo; la copia corretta si decodifica, la sua autofirma RSA è valida e l'impronta SHA-256 DER calcolata localmente coincide con quella stampata indipendentemente da `openssl x509 -fingerprint -sha256` sulla Shell. Questa corrispondenza autentica la copia rispetto al file del nodo consultato; non dice ancora se un particolare processo la stia usando.

Un test senza HTTP e senza token ha aperto un socket verso l'indirizzo di gestione, presentando come SNI e nome da verificare quello del SAN e caricando la CA copiata. Con Python 3.13 ha fallito: `CA cert does not include key usage extension`. In quella versione `VERIFY_X509_STRICT` è predefinito; la CA Proxmox osservata non ha l'estensione `keyUsage` richiesta dalla verifica rigorosa. La stessa prova con Python 3.12.13, runtime del MCP 0.1.0, ha restituito `TLS_VERIFIED_OK TLSv1.3`. Non è stato impostato `CERT_NONE` né disabilitata la verifica nel nuovo launcher.

La postazione ora risolve il nome del SAN tramite una voce nel file Windows `hosts`: lo script ha creato un backup, rifiuta voci preesistenti diverse, ha richiesto PowerShell elevata e ha verificato la risoluzione. Una prova negativa da processo non elevato si è fermata **prima** di scrivere. L'URL nel `.env` privato è stato cambiato dal writer del progetto, preservando l'ACL, e il vecchio URL è in un file privato per il rollback. La mappatura `hosts` è un rimedio locale: se l'indirizzo del nodo cambia, va aggiornata e verificata; una voce DNS amministrata sarebbe più semplice da mantenere.

Il launcher sicuro legge `.env`, crea un ambiente figlio con le sole tre variabili Proxmox e pochi valori di sistema, forza `PROXMOX_VERIFY_SSL=true` e `PROXMOX_ALLOW_DANGER=false`, e imposta `SSL_CERT_FILE` sul PEM pubblico nella cartella privata del progetto rete. Non installa la CA nello store globale Windows. L'ispezione del pacchetto conferma che il client usa `httpx.AsyncClient(verify=True)`; [HTTPX documenta](https://www.python-httpx.org/environment_variables/) che `SSL_CERT_FILE` specifica il bundle CA usato dal processo. Il test `list_nodes` riuscito con il nuovo launcher misura il percorso HTTPS completo nel runtime corrente.

## 5. Sequenza misurata, con esiti positivi e negativi

| Ordine | Prova o cambio | Esito e interpretazione |
|---|---|---|
| 1 | Baseline `.mcp.json` con hash e `list_nodes` reale | Connessione disponibile con i due flag non sicuri; punto di rollback. |
| 2 | Solo `ALLOW_DANGER=false` sulla baseline | Avvio e catalogo OK, `list_nodes` KO. La prova ha rilevato che il semplice flag non bastava. |
| 3 | Ripristino della baseline e seconda `list_nodes` | Lettura tornata OK con hash del file precedente; rollback esercitato. |
| 4 | Ispezione dei moduli Python del wheel | `safety_policy.json` assente e lista sicura vuota; causa confermata nel codice eseguito. |
| 5 | Filtro candidato e test offline con valori finti | Dieci tool, lettura ammessa, modifica negata. Il controllo hash è stato spostato prima dell'import e ritestato. |
| 6 | Handshake del certificato del nodo senza token | IP vecchio fuori dal SAN; nome DNS presente ma inizialmente non risolto. |
| 7 | Copia CA pubblica, correzione riga Base64 e confronto impronte | Prima copia invalida respinta; seconda copia autofirmata e identica al certificato pubblico letto sulla Shell. |
| 8 | TLS verificato con Python 3.13, poi Python 3.12 | Fallimento rigoroso per `keyUsage` mancante; riuscita con il runtime MCP corrente. Compatibilità futura esplicitamente aperta. |
| 9 | Script `hosts` non elevato, poi elevato | Prima prova fermata senza scritture; seconda `HOSTS_PROXMOX_OK`, risoluzione riletta dalla sessione. |
| 10 | Cambio del solo URL nel `.env` e backup privato | Nome corrispondente al SAN; token e percorso API invariati. |
| 11 | Sonda sul launcher candidato inattivo | `initialize`, dieci tool, rifiuto di `delete_instance`, `list_nodes` reale: tutti OK. |
| 12 | Cutover guardato di `.mcp.json` | Backup privato e hash prima/dopo; nuovo launcher attivo con flag `false/true`. |
| 13 | `claude mcp list` | `Connected` per il nuovo launcher. Da sola questa prova non chiude il gate funzionale. |
| 14 | Sonda vincolata all'hash del file attivo | Dieci tool, rifiuto modifica e `list_nodes` reale: tutti OK. Chiude i due rischi del MCP nel runtime osservato. |

I comandi precisi, gli hash e gli output sintetici sono nel [registro delle evidenze](evidenze-sicurezza-mcp-proxmox.md) e nell'appendice privata. Le sonde non stampano i nomi dei nodi né i token. Ogni chiamata sul Proxmox reale è stata autorizzata singolarmente secondo `CLAUDE.md`.

## 6. Dove vivono i segreti e che cosa Claude può vedere

Il file `.env` è ignorato da Git e ha un ACL che limita l'accesso agli account autorizzati della postazione. Il launcher non inoltra la chiave Nebula al figlio MCP e non mette i token in `.mcp.json`, negli argomenti del processo o nella documentazione versionata. Questo riduce duplicazione e divulgazione accidentale. **Non isola il file da Claude Code**, che gira sotto lo stesso account Windows: un processo con quel token di accesso può aprire i file accessibili allo stesso utente, ed il risultato di un tool MCP può tornare nel contesto di Claude. È una proprietà del confine degli account Windows, non un difetto del parser `.env`.

Per isolare davvero la credenziale da Claude serve spostarne la custodia a un'identità OS diversa, ad esempio un servizio locale dedicato con ACL sul file, e presentare a Claude soltanto un'interfaccia strettamente di lettura. Quel servizio deve verificare le richieste, limitare i dati di risposta e usare un token Proxmox dedicato. Anche così, un amministratore della macchina conserva poteri di gestione sull'identità di servizio; non va promessa protezione contro un amministratore compromesso. Cifrare `.env` con DPAPI **CurrentUser** senza separare l'identità non realizza da solo questo isolamento: la chiave rimane legata allo stesso utente che esegue Claude. La proposta è un'evoluzione architetturale, non una misura già installata.

## 7. Limiti residui e modo concreto per superarli

| Limite | Oggi | Intervento e criterio di chiusura |
|---|---|---|
| `Get-ProxmoxSnapshot.ps1` | Il bypass globale e `-SkipCertificateCheck` sono stati rimossi il 12/10; PowerShell 5.1 ha completato un dry-run reale con verifica di CA, nome, validità e impronte sul solo client .NET. | PowerShell 7 e il prossimo task pianificato restano da osservare; la revoca del certificato non è verificata perché la CA interna non offre qui una catena CRL/OCSP collaudata. Il pin della foglia richiede aggiornamento controllato alla rotazione. Dettaglio e prove in §10. |
| CA senza `keyUsage` | Il runtime MCP Python 3.12 verifica la connessione; Python 3.13 rigoroso la rifiuta. | Installare per `pveproxy` un certificato conforme firmato da una CA appropriata, tramite percorso ufficiale Proxmox di certificato personalizzato o ACME, dopo pianificazione del cambio e rollback. **Non** modificare a mano la CA o i certificati generati del cluster. Ripetere prova TLS e `list_nodes` nel runtime target prima dell'upgrade. |
| `.env` leggibile dallo stesso account di Claude | ACL e file ignorato da Git riducono la diffusione, ma non creano un confine fra processi dello stesso utente. | Progettare un servizio/broker con identità OS e token dedicati e catalogo/risposte strettamente limitati; provare con l'account Claude che il file non sia leggibile, che i tool consentiti funzionino e che le modifiche siano negate. Richiede un progetto separato di gestione dei segreti e dei processi. |
| Pin del pacchetto MCP | Il filtro usa API interne del wheel 0.1.0 e hash di 19 moduli. Se cambia il pacchetto, il launcher si ferma. | Prima di aggiornare: ispezione diff, ripetizione test offline e reali, nuova baseline hash, documentazione e prova di rollback. Il fail-closed è intenzionale. |
| `hosts` statico | Il nome verificato del certificato è mappato localmente all'IP attuale. | Registrare il nome nel DNS amministrato e provare risoluzione e TLS; poi rimuovere la voce locale con backup. Non cambiare l'URL finché il nuovo DNS non è validato. |

La [guida Proxmox VE](https://pve.proxmox.com/pve-docs/pve-admin-guide.pdf) descrive certificato predefinito firmato dalla CA del cluster, certificati personalizzati e ACME, e avverte di non modificare manualmente CA e certificati generati. [Microsoft PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6) documenta che `-SkipCertificateCheck` salta la validazione; [Microsoft .NET](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509chainpolicy.customtruststore) documenta il trust custom per i runtime che lo supportano. La distinzione fra ACL per account e processi è coerente con il [modello di identità dei servizi Windows](https://learn.microsoft.com/en-us/windows/win32/services/service-user-accounts) e con [DPAPI associata a utente o macchina](https://learn.microsoft.com/en-us/windows/win32/secbp/handling-passwords). Queste fonti descrivono le capacità delle piattaforme; le verifiche elencate sono scelte del progetto.

## 8. Rollback e continuità

Il backup esatto di `.mcp.json` e il precedente URL sono nel livello privato. Lo script `D:/log-collector/_notes/archivio-sessioni/rete-proxmox/strumenti/cutover_proxmox_mcp_secure_20261009.py --rollback` ripristina il JSON **solo** se hash del file attivo e backup coincidono con quelli attesi. `D:/log-collector/_notes/archivio-sessioni/rete-proxmox/strumenti/switch_proxmox_url_20261009.ps1 -Mode Rollback` ripristina il vecchio URL nel `.env` tramite il writer che preserva l'ACL. Dopo un rollback occorre verificare lo stato del MCP e registrare il motivo; la voce `hosts` e la CA pubblica possono restare, perché non contengono segreti, ma vanno censite. Il rollback ripristina temporaneamente i due flag rischiosi: è una misura di recupero, non una soluzione finale.

Nessun commit, push o deploy è stato eseguito dagli agenti. I file di progetto sono preparati per il controllo e per la chiusura manuale dell'utente. La roadmap ISO-41 resta **in corso**: il successo tecnico di SEC-025 è un'evidenza, non una dichiarazione di certificazione ISO/IEC 27001.

## 9. Mappatura ISO e fonti primarie

La mappatura del progetto è: controllo dei privilegi e accessi amministrativi, gestione dei segreti di autenticazione, sicurezza delle connessioni di rete, gestione delle configurazioni e registrazione verificabile delle modifiche. Sono aspetti pertinenti a ISO-41 della roadmap interna e ai controlli Annex A già mappati nel registro GAP-TBC del progetto rete; non è un'affermazione che l'intero controllo sia implementato o auditato. La [scheda ufficiale ISO/IEC 27001:2022](https://www.iso.org/standard/27001) descrive il sistema di gestione e l'approccio basato sul rischio.

Fonti dirette per le decisioni e le prove:

- [Proxmox VE Administration Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.pdf): CA del cluster, certificati del nodo, opzioni per `pveproxy` e divieto di modifica manuale dei file generati.
- [Repository upstream `proxmox-mcp`](https://github.com/josky-com/proxmox-mcp): capacità dichiarate e stato del progetto. Il difetto `safety_policy.json` è osservazione del wheel locale, non un fatto dedotto dal README.
- [HTTPX environment variables](https://www.python-httpx.org/environment_variables/): `SSL_CERT_FILE` e comportamento dell'ambiente.
- [Python 3.13 `ssl`](https://docs.python.org/en/3.13/library/ssl.html) e [OpenSSL verification options](https://docs.openssl.org/3.4/man1/openssl-verification-options/): `VERIFY_X509_STRICT` e requisiti delle estensioni X.509.
- [Microsoft Hosts File Editor](https://learn.microsoft.com/en-us/windows/powertoys/hosts-file-editor): risoluzione locale del nome.
- [Microsoft `Invoke-RestMethod`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-7.6): effetto di `-SkipCertificateCheck`.
- [Microsoft Service User Accounts](https://learn.microsoft.com/en-us/windows/win32/services/service-user-accounts) e [Handling Passwords](https://learn.microsoft.com/en-us/windows/win32/secbp/handling-passwords): identità dei processi, ACL e DPAPI.

Per l'audit, il [registro delle evidenze](evidenze-sicurezza-mcp-proxmox.md) separa metodo, risultato, limite probatorio e gate residui. L'appendice privata conserva gli identificativi e gli hash integrali. Le decisioni retroattive di altri componenti si riconciliano nel registro delle fonti del progetto; non si attribuisce una fonte non letta a una scelta interna.

## 10. Client PowerShell degli snapshot: rimozione del bypass e collaudo del 12/10/2026

Questo è un consumer HTTPS distinto dal MCP. Prima dell'intervento `Get-ProxmoxSnapshot.ps1` installava `TrustAllCertsPolicy` a livello di processo in PowerShell 5.1 e usava `-SkipCertificateCheck` nel ramo PowerShell 7. La prima decisione era rimuovere entrambi: un certificato arbitrario non deve ricevere il token API, e una policy globale altererebbe anche altre connessioni dello stesso processo. Il preflight del 12/10 ha aperto **un solo handshake TLS** con PowerShell 5.1, senza HTTP né token. Ha restituito `PS51_TLS_PIN_OK`, `PS51_PIN_NEGATIVE_OK`, `PS51_CHAIN_WITH_PRIVATE_CA_OK`: il certificato reale è stato accettato con pin della foglia, controllo del nome e validità; pin o nome errati sono stati respinti; una nuova catena X.509 che contiene la CA pubblica autenticata in `ExtraStore` termina su quella CA. Il primo test offline del callback PowerShell aveva fallito per la visibilità di una funzione dentro una closure: è stato corretto prima del test reale. Questi risultati appartengono al runtime Windows PowerShell 5.1 osservato, non a PowerShell 7 o a Linux.

La soluzione installata usa `scripts/ProxmoxVerifiedHttp.cs` tramite `Add-Type -AssemblyName System.Net.Http` e `Add-Type -Path`. `Get-ProxmoxSnapshot.ps1` legge dal livello privato `_notes/certs/` il PEM pubblico della CA e `proxmox-tls-pins.json` con nome, porta, SHA-256 della CA e SHA-256 del certificato foglia. Il JSON è ignorato da Git. Il nome richiesto deve coincidere con il pin privato e con il nome nell'URL del `.env`; il callback `HttpClientHandler.ServerCertificateCustomValidationCallback` controlla nome TLS, presenza del certificato, finestra di validità, SHA-256 della foglia, costruzione di una **nuova** catena con CA privata e hash della radice effettiva. `AllowUnknownCertificateAuthority` consente a .NET Framework di costruire la catena senza aggiungere la CA allo store di Windows; il controllo finale della radice impedisce che una CA diversa diventi attendibile. La revoca è impostata a `NoCheck`: è un limite esplicito, compensato solo in parte dal pin esatto della foglia. `UseProxy=false`, `AllowAutoRedirect=false`, URL e metodo controllati limitano a quale server si possano inviare header e cookie. Il token resta in memoria e viaggia solo dopo il successo dell'handshake TLS; il fallback con ticket usa lo stesso client e un cookie associato all'URL verificato. Nessuna impostazione di fiducia TLS globale di Windows è stata modificata.

Prima dell'installazione è stato salvato in `_notes/` il file PowerShell precedente; la candidata era vincolata all'hash della baseline. `ProxmoxVerifiedHttp.cs` è versionabile e non contiene host, IP o credenziali. Il test offline del **medesimo predicato** ha accettato un certificato con CA/pin corretti e respinto nome errato, certificato assente, host e porta diversi, pin foglia errato, pin CA errato e URL fuori nodo. La prova iniziale del rinfresco reale si è fermata subito con “Impossibile inviare un contenuto con questo tipo di verbo”: PowerShell ha convertito `$null` in stringa vuota passando l'argomento `body` a C#, e il client aveva costruito un corpo anche sulla GET. Nessuno snapshot è stato promosso. La correzione crea `StringContent` solo sulle POST e impone un corpo non vuoto; un test locale verso una porta chiusa controlla che una GET con stringa vuota arrivi al tentativo di connessione senza l'errore sul verbo. È stato salvato un secondo backup privato del file C# prima della correzione.

Il secondo comando `Invoke-RefreshFonti.ps1 -Fonte proxmox -DryRun`, autorizzato separatamente, è terminato con codice 0 il **12/10/2026 alle 09:36 CEST**: raccolta completata, JSON e Markdown temporanei prodotti, validatore dello snapshot superato, riga finale `PROVA proxmox misura valida, non promossa (-DryRun)`. Non si è cambiato l'output corrente. Dieci GET opzionali al guest agent hanno restituito HTTP 403 con il token di sola lettura: l'helper li tratta come dati non disponibili, perciò gli indirizzi ricavabili solo dall'agente possono mancare. Il validatore ha comunque misurato almeno una risorsa e un nodo. L'elenco dei guest resta nelle evidenze private. Il primo errore del dry-run e la correzione sono parte della prova, non vengono cancellati dalla riuscita successiva.

**Manutenzione e rollback.** Quando cambia il certificato foglia, il pin va aggiornato solo dopo aver verificato il nuovo certificato e la sua catena dalla console del nodo, prima della successiva esecuzione pianificata; altrimenti il client si ferma prima di trasmettere il token. Il backup privato del vecchio script esiste per analisi e recupero, ma contiene il bypass e **non va riattivato come stato ordinario**. La correzione da mantenere è il client verificato. Restano da provare PowerShell 7, il task pianificato nel suo account e la disponibilità delle sezioni guest-agent con privilegi minimi; non è stato affermato che quei tre gate siano superati. La CA senza `keyUsage` resta un limite separato per Python 3.13.

La [documentazione Microsoft del callback di `HttpClientHandler`](https://learn.microsoft.com/en-us/dotnet/api/system.net.http.httpclienthandler.servercertificatecustomvalidationcallback?view=netframework-4.8.1) descrive il punto di verifica per client; la [documentazione di `X509ChainPolicy.ExtraStore`](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x509chainpolicy.extrastore?view=netframework-4.8.1) descrive l'archivio aggiuntivo per costruire la catena. Il collegamento fra questi meccanismi, il pin esatto, il divieto di redirect e i gate descritti sopra sono decisioni locali provate nel runtime osservato, non garanzie attribuite alla documentazione Microsoft. La [guida Proxmox VE](https://pve.proxmox.com/pve-docs/pve-admin-guide.pdf) descrive la CA del cluster e la gestione dei certificati del nodo.
