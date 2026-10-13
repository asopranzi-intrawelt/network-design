# Fonti del progetto e protocollo di riallineamento

> Regola modulare, da caricare all'inizio di ogni sessione. Nasce il 03/08/2026 da una domanda dell'IT Manager: quali fonti pesca davvero questo progetto, e perche' resta indietro. La risposta breve e' che il repository e' una sola delle cinque classi di fonti, e le altre quattro non lo notificano: vanno interrogate. Questo file elenca ogni fonte, dice su cosa e' autorevole, come si legge, con quale cadenza va riletta, e quali sono i punti ciechi noti. La colonna della cadenza e' quella che l'IT Manager conferma o corregge: senza una cadenza dichiarata, una fonte che non notifica viene riletta quando qualcuno si ricorda, cioe' mai. I casi osservati che hanno prodotto queste prescrizioni, con le misure e le date, stanno in `.claude/norme/fonti-e-riallineamento.md`: quel file non si carica all'avvio di una sessione e non serve per applicare la regola, serve a chi deve estenderla o rimetterla in discussione.

## Perche' un progetto di rete resta indietro

La rete non cambia dentro questo repository. Cambia sugli apparati, e viene cambiata da piu' mani: da questa sessione di lavoro, da altre sessioni con altri strumenti e altri account, da interventi manuali dell'IT Manager sulle GUI, e da fornitori che consegnano hardware. Il repository impara soltanto cio' che qualcuno vi scrive.

Ne segue che il rischio non e' la contraddizione, che si vede, ma l'*obsolescenza silenziosa*: una scheda che descrive correttamente lo stato di tre settimane fa e non dichiara di essere vecchia.

## Classe A — Il repository stesso

Autorevole su: cosa il progetto sa, quali decisioni sono state prese e perche'. Non autorevole su: com'e' la rete adesso.

| Fonte | Contenuto | Cadenza |
|---|---|---|
| `.claude/memory/index.md` | punto di ripresa, stato di verifica delle schede | sempre, per prima |
| `.claude/memory/progress.md` | work-log, una voce per sessione | sempre, la voce piu' recente |
| `.claude/memory/decisions.md` | registro ADR | su necessita', quando si tocca una decisione |
| `.claude/context/*.md` | schede con frontmatter `last-verified` | solo quelle pertinenti al task |
| `docs/**` | schede tematiche, timeline, runbook, gap, registro interventi | solo quelle pertinenti |
| `_notes/**` | layer narrativo locale, non versionato | `RESUME_PROMPT.md` e la coda di `DIARIO.md` |

Trappola nota su questa classe: il frontmatter `last-verified` va bumpato all'hash del commit subito dopo il commit. A luglio 2026 non e' stato fatto per sei settimane e il risultato e' stato che `index.md` dichiarava un drift che nessuno chiudeva.

## Classe B — Le fonti vive, che dicono com'e' la rete adesso

Autorevoli su: lo stato reale degli apparati. Vanno interrogate, non ricordate. Nessuna notifica quando qualcosa cambia.

**Dal 04/09/2026, ADR-026, due di queste fonti non si interrogano piu' a mano**: Nebula e Proxmox si rinfrescano da un'attivita' pianificata che esegue `scripts/Invoke-RefreshFonti.ps1`, con le tre guardie descritte nei casi. La **gestione endpoint resta manuale**, perche' le sue credenziali appartengono al provider MSP (ADR-017) e non stanno in questo repository.

Ne discende che la colonna della cadenza qui sotto cambia significato per quelle due righe: non e' piu' un impegno di chi lavora, e' il limite oltre il quale `scripts/Test-Allineamento.py` dichiara vecchia la misura e quindi, implicitamente, segnala che l'automazione non sta girando.

| Fonte | Come si legge | Autorevole su | Cadenza |
|---|---|---|---|
| Nebula OpenAPI | `scripts/Get-NebulaSnapshot.ps1` → `output/nebula-*` | porte, PVID, VLAN ammesse, tabella MAC, access point | settimanale, e prima di ogni task su porte, VLAN o access point. **Dipende dalla licenza**: vedi §La fonte che si e' spenta e riaccesa |
| Proxmox REST | `scripts/Get-ProxmoxSnapshot.ps1` → `output/proxmox-*` | VM, storage, bridge, job di backup | da confermare |
| NinjaOne | `scripts/Get-NinjaSnapshot.ps1` → `output/ninjaone-*` | endpoint, interfacce, policy, workgroup | da confermare |
| MCP `proxmox` | tool MCP, token di sola lettura, credenziali dal blocco `env` di `settings.local.json` (ADR-021, verificato il 05/08/2026) | stato puntuale di nodi, VM e configurazione per VM | su necessita'; e' oggi l'unica classe B che risponde subito |
| GUI firewall Zyxel | solo tramite l'IT Manager, con screenshot | interfacce, DHCP, policy, DNS, NAT | su necessita' |
| Pannelli degli apparati | solo tramite l'IT Manager | multifunzione, NAS, telefoni, UPS | su necessita' |

### La fonte che si e' spenta e riaccesa: la OpenAPI Nebula dipende dalla licenza

Fra il 05 e il 06/08/2026 la OpenAPI ha smesso di autorizzare le chiamate, perche' i quindici giorni di grazia su un apparato senza licenza erano scaduti e l'organizzazione era stata declassata: per un giorno la fonte piu' usata della classe B non esisteva. Il fatto, la regola di licenza che lo governa e la decisione stanno in `.claude/norme/fonti-e-riallineamento.md`, gap NEB-002 e ADR-022. Qui restano le due righe che vincolano il lavoro.

Ne segue una precondizione che va letta ogni volta che si adotta un apparato nuovo, e che non e' un dettaglio di acquisto ma la condizione di sopravvivenza di questa riga della tabella: **un dispositivo nuovo in organizzazione va licenziato entro quindici giorni**, altrimenti spegne la fonte per tutti. Il caso imminente e' l'access point da esterno di M13c, tracciato come M13c-9.

### Fonte automatica pianificata: lo USG FLEX 500 su Nebula

Il firewall e' oggi l'unico apparato centrale che vive in classe E e non in classe B, quindi ogni affermazione di questo progetto sul firewall ha la freschezza dell'ultima volta che qualcuno ne ha aperto la GUI. Verra' portato sull'organizzazione Nebula che gia' gestisce switch e access point, ma la data non e' fissata; il piano, le due modalita' fra cui scegliere e cio' che l'OpenAPI gia' espone oggi stanno in `.claude/norme/fonti-e-riallineamento.md`. Qui resta il vincolo da non perdere quando arrivera'.

Vincolo da non perdere quando arrivera': la chiave Nebula in uso e' di sola lettura per scelta (ADR-009), e il canale di scrittura verso gli switch si e' dimostrato inaffidabile (ADR-010, NEB-001). Portare il firewall su Nebula non deve trasformarsi nell'occasione per scrivere configurazioni di sicurezza da un canale che ha gia' perso silenziosamente delle scritture.

Il principio che governa questa classe e' che una misura batte una memoria.

## Classe C — Le fonti documentali esterne

Autorevoli su: decisioni prese, contratti firmati, hardware acquistato e consegnato. Hanno un canale automatico, il delta, e il canale funziona: e' la lettura del suo output che era il collo di bottiglia.

La libreria aziendale OneDrive contiene **diciannove radici di primo livello** (misurate il 03/08/2026). Il progetto ne sorveglia **tre**, e le altre sedici sono fuori perimetro per scelta dichiarata, da rivedere se un ambito nuovo entra in scope.

| Radice sorvegliata | Volume | Natura | Cosa vi si trova che non sta altrove |
|---|---|---|---|
| `Documenti - IT` | ~23.600 file | tecnica | analisi, handoff, note di intervento, questionari, VA |
| `IT + Administration - Documenti` | ~750 file | amministrativa | **preventivi, documenti di trasporto, contratti firmati** |
| `File di chat di Microsoft Teams` | ~220 file | scambio | **gli handoff condivisi in chat**, che non atterrano nelle altre due |

L'elenco delle sedici radici fuori perimetro, le due librerie montate in piu' e la ragione per cui la libreria amministrativa era la piu' sottovalutata stanno in `.claude/norme/fonti-e-riallineamento.md`.

Lettura: `scripts/Check-OneDriveDelta.ps1` a ogni avvio di sessione tramite hook. Del suo output si legge per intero il blocco `RILEVANTI PER LA RETE`, che non e' troncato, e il riepilogo per cartella, che dice da cosa e' dominato il delta. Dopo il triage nella checklist di ingestione, e solo dopo, si rilancia con `-UpdateBaseline`.

Regola di ammissione: se il delta e' arretrato di piu' di qualche giorno, si triaga prima di qualunque altro lavoro. Un arretrato nasconde informazione operativa, non solo rumore.

## Classe D — Le altre sessioni di lavoro: il punto cieco vero

Autorevoli su: tutto cio' che e' stato fatto senza passare da qui. Nessun canale automatico verso questo progetto, e questa e' la ragione strutturale dei ritardi.

Quante installazioni dell'assistente convivano su questa macchina, e il caso del 03/08/2026 in cui due handoff sul dimensionamento della VM207 sono rimasti invisibili per costruzione e non per distrazione, stanno in `.claude/norme/fonti-e-riallineamento.md`.

| Progetto o sede | Perche' riguarda la rete |
|---|---|
| `D:/portale-asset-it-intrawelt` | il pilota sulla VM208, che pubblica su 80/443 sulla LAN piatta (NET-011) |
| `D:/sviluppo-ninjaOne/*` | automazioni sull'RMM che governa gli endpoint e ruota le password locali |
| `D:/getrad-migration` | le VM TESTNEWEGETRAD del nodo Proxmox |
| `D:/API_intrawelt` | servizi interni esposti sulla LAN |
| `D:/log-collector` | collettore dei log degli accessi amministrativi, futura VM Proxmox e nuovi flussi da firewall, switch, NAS e host |
| `E:/lettore-doc` | pipeline documentale con vault Obsidian, sorgente di note |
| Claude sulla VM207 | installazione sull'host stesso, con i propri progetti |
| App claude.ai (altro account) | nessuna traccia leggibile su disco da qui |

Il canale che esiste e' il file di handoff, e funziona quando viene scritto e messo dove il delta lo vede. Il progetto ne ha gia' ingeriti tre per questa via, sul GroupShare, sul certificato HTTPS e su un intervento di postazione.

Per `D:/log-collector`, `scripts/Test-Allineamento.py` confronta a ogni avvio il commit Git corrente con `data/scadenze.json` (`progetti_collegati`). Un commit nuovo richiede di leggere il diff e trasferire qui soltanto le novita' che cambiano topologia, sorgenti, accessi, regole, backup o stato ISO. Aggiornare il commit riconciliato solo dopo il triage; le modifiche non ancora committate nell'altro repository restano sviluppo in corso. Il punto di integrazione e la connessione SSH futura sono in `docs/log-collector-integrazione.md`. La VM prevista e il suo accesso SSH Windows restano da configurare alla creazione effettiva della macchina.

Resta scoperto cio' che nessuno scrive: se una sessione cambia una porta su Nebula e non lascia un handoff, questo progetto lo scopre soltanto rileggendo l'apparato. E' l'argomento piu' forte a favore di una cadenza fissa sugli snapshot della classe B.

## Classe E — L'IT Manager

Unica autorita' su: le decisioni, le priorita', e tutto cio' che e' stato fatto a mano sugli apparati senza che nessun agente ne conservi traccia. E' anche l'unica fonte che puo' dichiarare superata un'affermazione che nessuna misura contraddice.

L'esempio del 03/08/2026 che lo dimostra, cioe' cinque telefoni dati per scollegati e dichiarati collegati dall'IT Manager prima che qualunque misura lo confermasse, sta in `.claude/norme/fonti-e-riallineamento.md`.

Ne segue una domanda da fare, non da dedurre, all'inizio di ogni sessione: che cosa e' cambiato sulla rete da quando ci siamo lasciati, e in quale sessione o intervento e' avvenuto.

## Protocollo di riallineamento a inizio sessione

Ordine proposto. La cadenza delle voci della classe B e' quella da confermare.

Primo, leggere `.claude/memory/index.md` e la voce piu' recente di `progress.md`: dicono dove si era rimasti e cosa era dichiarato aperto.

Secondo, leggere l'output del delta prodotto dall'hook: prima il blocco delle voci rilevanti per intero, poi il riepilogo per cartella. Se e' arretrato, triagiare prima di ogni altra cosa.

Terzo, chiedere all'IT Manager che cosa e' cambiato fuori da qui, comprese le altre sessioni di lavoro e gli interventi manuali. E' l'unico passo che copre la classe D quando non e' stato scritto un handoff.

Quarto, rileggere le fonti vive pertinenti al task secondo la cadenza concordata, e non a memoria. Se il task tocca porte, VLAN o access point, lo snapshot Nebula si rilancia: costa un minuto e ha prodotto quattro correzioni in una sola esecuzione.

Quinto, invocare la skill `sync-context` per il drift fra schede e stato, e bumpare il frontmatter subito dopo il commit.

## Cadenze da confermare dall'IT Manager

Confermate dall'IT Manager il 03/08/2026, perimetro compreso: tre radici sorvegliate su diciannove.

| Fonte | Cadenza | Stato |
|---|---|---|
| Delta OneDrive, tre radici | ogni sessione, automatico via hook; triage obbligatorio se arretrato di piu' di qualche giorno; `-UpdateBaseline` solo dopo il triage | confermata |
| Snapshot Nebula | prima di ogni task che tocca porte, VLAN o access point, e comunque una volta a settimana. Sospesa fra il 05 e il 06/08/2026 per il declassamento della licenza (NEB-002), **ripristinata** dal 06/08. Presidiare la scadenza del **22/11/2027** e licenziare entro quindici giorni ogni apparato nuovo, altrimenti la fonte si spegne di nuovo | confermata |
| Snapshot Proxmox | quando cambia l'inventario VM, e comunque una volta al mese | confermata |
| Snapshot NinjaOne | prima di ogni intervento massivo sulle postazioni | confermata |
| GUI firewall | su necessita', con screenshot | confermata |
| Domanda "cosa e' cambiato fuori da qui" | ogni sessione, in apertura | confermata |
| Handoff dalle altre sessioni | li scrive chi opera altrove, in una delle tre radici sorvegliate | confermata |

Dal 04/09/2026 la sorveglianza di queste cadenze non dipende piu' dalla memoria di nessuno: `scripts/Test-Allineamento.py` gira all'avvio di sessione e riporta, per ogni fonte di questa tabella, l'eta' della misura contro la cadenza dichiarata. E' rumoroso e non blocca, per decisione dell'IT Manager. Con esso vengono riportate anche le sedici scadenze di licenza e di contratto raccolte in `data/scadenze.json`.

## Punti ciechi dichiarati

Restano tre cose che nessun automatismo copre, e vanno dette invece di essere sperate.

Il primo e' l'intervento manuale senza traccia: una porta cambiata su una GUI da chiunque, in qualunque sessione, si scopre solo rileggendo l'apparato.

Il secondo e' l'app di assistente su un altro account, che non lascia file leggibili da qui: il suo unico canale verso questo progetto e' un handoff scritto a mano.

Il terzo e' la documentazione di IntraLino, che vive su una macchina virtuale e che l'IT Manager ha dichiarato come fonte da portare in una sessione futura: fino ad allora le sezioni IntraLino di questo progetto restano parziali e sono etichettate come tali.
