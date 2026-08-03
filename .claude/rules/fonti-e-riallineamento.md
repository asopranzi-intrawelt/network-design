# Fonti del progetto e protocollo di riallineamento

> Regola modulare, da caricare all'inizio di ogni sessione. Nasce il 03/08/2026 da una
> domanda dell'IT Manager: quali fonti pesca davvero questo progetto, e perche' resta
> indietro. La risposta breve e' che il repository e' una sola delle cinque classi di fonti,
> e le altre quattro non lo notificano: vanno interrogate. Questo file elenca ogni fonte,
> dice su cosa e' autorevole, come si legge, con quale cadenza va riletta, e quali sono i
> punti ciechi noti. La colonna della cadenza e' quella che l'IT Manager conferma o corregge:
> senza una cadenza dichiarata, una fonte che non notifica viene riletta quando qualcuno si
> ricorda, cioe' mai.

## Perche' un progetto di rete resta indietro

La rete non cambia dentro questo repository. Cambia sugli apparati, e viene cambiata da piu'
mani: da questa sessione di lavoro, da altre sessioni con altri strumenti e altri account,
da interventi manuali dell'IT Manager sulle GUI, e da fornitori che consegnano hardware. Il
repository impara soltanto cio' che qualcuno vi scrive.

Ne segue che il rischio non e' la contraddizione, che si vede, ma l'*obsolescenza
silenziosa*: una scheda che descrive correttamente lo stato di tre settimane fa e non
dichiara di essere vecchia. Il 03/08/2026 il progetto ne ha misurate tre insieme — la
distribuzione dei telefoni, il parco telefonico stimato un quinto del reale, e due acquisti
di hardware di rete mai censiti — e nessuna delle tre era una contraddizione: erano
affermazioni giuste che avevano smesso di esserlo.

## Classe A — Il repository stesso

Autorevole su: cosa il progetto sa, quali decisioni sono state prese e perche'. Non
autorevole su: com'e' la rete adesso.

| Fonte | Contenuto | Cadenza |
|---|---|---|
| `.claude/memory/index.md` | punto di ripresa, stato di verifica delle schede | sempre, per prima |
| `.claude/memory/progress.md` | work-log, una voce per sessione | sempre, la voce piu' recente |
| `.claude/memory/decisions.md` | registro ADR | su necessita', quando si tocca una decisione |
| `.claude/context/*.md` | schede con frontmatter `last-verified` | solo quelle pertinenti al task |
| `docs/**` | schede tematiche, timeline, runbook, gap, registro interventi | solo quelle pertinenti |
| `_notes/**` | layer narrativo locale, non versionato | `RESUME_PROMPT.md` e la coda di `DIARIO.md` |

Trappola nota su questa classe: il frontmatter `last-verified` va bumpato all'hash del commit
subito dopo il commit. A luglio 2026 non e' stato fatto per sei settimane e il risultato e'
stato che `index.md` dichiarava un drift che nessuno chiudeva.

## Classe B — Le fonti vive, che dicono com'e' la rete adesso

Autorevoli su: lo stato reale degli apparati. Vanno interrogate, non ricordate. Nessuna
notifica quando qualcosa cambia.

| Fonte | Come si legge | Autorevole su | Cadenza |
|---|---|---|---|
| Nebula OpenAPI | `scripts/Get-NebulaSnapshot.ps1` → `output/nebula-*` | porte, PVID, VLAN ammesse, tabella MAC, access point | da confermare |
| Proxmox REST | `scripts/Get-ProxmoxSnapshot.ps1` → `output/proxmox-*` | VM, storage, bridge, job di backup | da confermare |
| NinjaOne | `scripts/Get-NinjaSnapshot.ps1` → `output/ninjaone-*` | endpoint, interfacce, policy, workgroup | da confermare |
| MCP `proxmox` | tool MCP, token di sola lettura | stato puntuale di nodi e VM | su necessita' |
| GUI firewall Zyxel | solo tramite l'IT Manager, con screenshot | interfacce, DHCP, policy, DNS, NAT | su necessita' |
| Pannelli degli apparati | solo tramite l'IT Manager | multifunzione, NAS, telefoni, UPS | su necessita' |

Il principio che governa questa classe e' che una misura batte una memoria. Tre delle
correzioni del 03/08/2026 sono venute da qui e non da un documento.

## Classe C — Le fonti documentali esterne

Autorevoli su: decisioni prese, contratti firmati, hardware acquistato e consegnato. Hanno
un canale automatico, il delta, e il canale funziona: e' la lettura del suo output che era
il collo di bottiglia.

La libreria aziendale OneDrive contiene **diciannove radici di primo livello** (misurate il
03/08/2026). Il progetto ne sorveglia **tre**, e le altre sedici sono fuori perimetro per
scelta dichiarata, da rivedere se un ambito nuovo entra in scope.

| Radice sorvegliata | Volume | Natura | Cosa vi si trova che non sta altrove |
|---|---|---|---|
| `Documenti - IT` | ~23.600 file | tecnica | analisi, handoff, note di intervento, questionari, VA |
| `IT + Administration - Documenti` | ~750 file | amministrativa | **preventivi, documenti di trasporto, contratti firmati** |
| `File di chat di Microsoft Teams` | ~220 file | scambio | **gli handoff condivisi in chat**, che non atterrano nelle altre due |

Le sedici fuori perimetro, per trasparenza: `AI adoption`, `App`, `Attachments`, `Desktop`,
`Documenti - Certificazioni`, `Documenti - Projects`, `Documenti condivisi - Resources`,
`Documenti`, `File chat di Microsoft Copilot`, `Immagini`, `Marketing`, `Microsoft Teams Chat
Files`, `Registrazioni`, `Riunioni`, `Scansioni`, `Whiteboards`. Due meritano un pensiero se il
perimetro si allarga: `Documenti - Certificazioni` quando comincera' la Fase 5 ISO27001, e
`Scansioni` se il servizio di scansione dovesse cambiare destinazione.

Esistono inoltre sul disco altre due librerie montate, `OneDrive` personale e `OneDrive -
Intrawelt S.a.s (1)`, che sembra un doppio aggancio della stessa libreria aziendale: nessuna
delle due e' sorvegliata, e la seconda va chiarita perche' un doppio mount produce copie
divergenti.

La seconda libreria e' quella che il progetto sottovalutava. Un preventivo e un documento di
trasporto non sembrano documentazione tecnica, ma sono l'unico posto dove compare un apparato
nuovo prima che entri in rete, e sono l'unico posto dove si legge che un contratto e' stato
firmato. I tre ritrovamenti del 03/08/2026 vengono tutti da li'.

Lettura: `scripts/Check-OneDriveDelta.ps1` a ogni avvio di sessione tramite hook. Del suo
output si legge per intero il blocco `RILEVANTI PER LA RETE`, che non e' troncato, e il
riepilogo per cartella, che dice da cosa e' dominato il delta. Dopo il triage nella checklist
di ingestione, e solo dopo, si rilancia con `-UpdateBaseline`.

Regola di ammissione: se il delta e' arretrato di piu' di qualche giorno, si triaga prima di
qualunque altro lavoro. Un arretrato nasconde informazione operativa, non solo rumore.

## Classe D — Le altre sessioni di lavoro: il punto cieco vero

Autorevoli su: tutto cio' che e' stato fatto senza passare da qui. Nessun canale automatico
verso questo progetto, e questa e' la ragione strutturale dei ritardi.

Su questa macchina convivono piu' installazioni dell'assistente, ciascuna con i propri
progetti: al 03/08/2026 sono ventidue su un account, venti su un altro, quindici su un
terzo, con sovrapposizioni. Alcuni di quei progetti toccano direttamente la rete che questo
repository documenta.

| Progetto o sede | Perche' riguarda la rete |
|---|---|
| `D:/portale-asset-it-intrawelt` | il pilota sulla VM208, che pubblica su 80/443 sulla LAN piatta (NET-011) |
| `D:/sviluppo-ninjaOne/*` | automazioni sull'RMM che governa gli endpoint e ruota le password locali |
| `D:/getrad-migration` | le VM TESTNEWEGETRAD del nodo Proxmox |
| `D:/API_intrawelt` | servizi interni esposti sulla LAN |
| `E:/lettore-doc` | pipeline documentale con vault Obsidian, sorgente di note |
| Claude sulla VM207 | installazione sull'host stesso, con i propri progetti |
| App claude.ai (altro account) | nessuna traccia leggibile su disco da qui |

Il canale che esiste e' il file di handoff, e funziona quando viene scritto e messo dove il
delta lo vede. Il progetto ne ha gia' ingeriti tre per questa via, sul GroupShare, sul
certificato HTTPS e su un intervento di postazione.

Il caso che dimostra il difetto, scoperto il 03/08/2026: due documenti di handoff sul
dimensionamento della VM207, datati 13/07/2026, con i valori reali di memoria, processori,
disco e bridge di una macchina che questo progetto documenta come asset di rete, piu' un
`CLAUDE.md` di progetto, si trovavano dentro una cartella che la lista di esclusione del
delta scartava come "mirror di siti esterni". L'esclusione era corretta quando fu scritta,
nel luglio 2026; poi un'altra sessione ha usato quella cartella per altro. Erano invisibili
per costruzione, non per distrazione. Correzione applicata: i file il cui nome contiene
`handoff` e i `CLAUDE.md` non vengono mai esclusi in base alla cartella, e compaiono nel
blocco delle voci rilevanti.

Resta scoperto cio' che nessuno scrive: se una sessione cambia una porta su Nebula e non
lascia un handoff, questo progetto lo scopre soltanto rileggendo l'apparato. E' l'argomento
piu' forte a favore di una cadenza fissa sugli snapshot della classe B.

## Classe E — L'IT Manager

Unica autorita' su: le decisioni, le priorita', e tutto cio' che e' stato fatto a mano sugli
apparati senza che nessun agente ne conservi traccia. E' anche l'unica fonte che puo'
dichiarare superata un'affermazione che nessuna misura contraddice.

Esempio del 03/08/2026: la scheda descriveva due telefoni del Piano Terra come privi di lease
DHCP, fotografia corretta al 23/07. La correzione — tutti e cinque collegati, ciascuno su una
porta che prende la VLAN della fonia, lavoro concluso in sessioni precedenti — e' arrivata da
qui, e solo dopo la misura l'ha corroborata. Nessuna interrogazione automatica l'avrebbe
prodotta, perche' la tabella MAC dice dove sta un apparecchio, non che il lavoro e' finito.

Ne segue una domanda da fare, non da dedurre, all'inizio di ogni sessione: che cosa e'
cambiato sulla rete da quando ci siamo lasciati, e in quale sessione o intervento e'
avvenuto.

## Protocollo di riallineamento a inizio sessione

Ordine proposto. La cadenza delle voci della classe B e' quella da confermare.

Primo, leggere `.claude/memory/index.md` e la voce piu' recente di `progress.md`: dicono dove
si era rimasti e cosa era dichiarato aperto.

Secondo, leggere l'output del delta prodotto dall'hook: prima il blocco delle voci rilevanti
per intero, poi il riepilogo per cartella. Se e' arretrato, triagiare prima di ogni altra
cosa.

Terzo, chiedere all'IT Manager che cosa e' cambiato fuori da qui, comprese le altre sessioni
di lavoro e gli interventi manuali. E' l'unico passo che copre la classe D quando non e' stato
scritto un handoff.

Quarto, rileggere le fonti vive pertinenti al task secondo la cadenza concordata, e non a
memoria. Se il task tocca porte, VLAN o access point, lo snapshot Nebula si rilancia: costa
un minuto e ha prodotto quattro correzioni in una sola esecuzione.

Quinto, invocare la skill `sync-context` per il drift fra schede e stato, e bumpare il
frontmatter subito dopo il commit.

## Cadenze da confermare dall'IT Manager

Confermate dall'IT Manager il 03/08/2026. La riga del delta era rimasta in sospeso perche' il
perimetro delle radici sorvegliate non era stato spiegato: ora lo e', ed e' tre radici su
diciannove.

| Fonte | Cadenza | Stato |
|---|---|---|
| Delta OneDrive, tre radici | ogni sessione, automatico via hook; triage obbligatorio se arretrato di piu' di qualche giorno; `-UpdateBaseline` solo dopo il triage | confermata |
| Snapshot Nebula | prima di ogni task che tocca porte, VLAN o access point, e comunque una volta a settimana | confermata |
| Snapshot Proxmox | quando cambia l'inventario VM, e comunque una volta al mese | confermata |
| Snapshot NinjaOne | prima di ogni intervento massivo sulle postazioni | confermata |
| GUI firewall | su necessita', con screenshot | confermata |
| Domanda "cosa e' cambiato fuori da qui" | ogni sessione, in apertura | confermata |
| Handoff dalle altre sessioni | li scrive chi opera altrove, in una delle tre radici sorvegliate | confermata |

## Punti ciechi dichiarati

Restano tre cose che nessun automatismo copre, e vanno dette invece di essere sperate.

Il primo e' l'intervento manuale senza traccia: una porta cambiata su una GUI da chiunque, in
qualunque sessione, si scopre solo rileggendo l'apparato.

Il secondo e' l'app di assistente su un altro account, che non lascia file leggibili da qui:
il suo unico canale verso questo progetto e' un handoff scritto a mano.

Il terzo e' la documentazione di IntraLino, che vive su una macchina virtuale e che l'IT
Manager ha dichiarato come fonte da portare in una sessione futura: fino ad allora le sezioni
IntraLino di questo progetto restano parziali e sono etichettate come tali.
