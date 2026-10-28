# Fonti del progetto e protocollo di riallineamento

> Regola modulare, da caricare all'inizio di ogni sessione. Nasce il 03/08/2026 da una domanda dell'IT Manager: quali fonti pesca davvero questo progetto, e perche' resta indietro. Qui restano il principio, le cinque classi e il protocollo; le tabelle complete delle fonti, le radici sorvegliate, i progetti della classe D, la dipendenza dalla licenza Nebula, il piano dello USG FLEX su Nebula, le cadenze confermate e i punti ciechi stanno nella skill `fonti-di-rete`, file `RIFERIMENTO.md`, spostati il 28/10/2026 per riportare il carico delle istruzioni sotto soglia. I casi osservati stanno in `.claude/norme/fonti-e-riallineamento.md`.

## Perche' un progetto di rete resta indietro

La rete non cambia dentro questo repository. Cambia sugli apparati, e viene cambiata da piu' mani: da questa sessione, da altre sessioni con altri strumenti e altri account, da interventi manuali dell'IT Manager sulle GUI, e da fornitori che consegnano hardware. Il repository impara soltanto cio' che qualcuno vi scrive, quindi il rischio non e' la contraddizione, che si vede, ma l'*obsolescenza silenziosa*: una scheda che descrive correttamente lo stato di tre settimane fa e non dichiara di essere vecchia.

## Le cinque classi

Classe A, il repository: autorevole su cio' che il progetto sa e sulle decisioni prese, non su com'e' la rete adesso. Si leggono sempre `.claude/memory/index.md` e l'ultima voce di `progress.md`, il resto solo se pertinente. Il frontmatter `last-verified` delle schede si bumpa subito dopo il commit.

Classe B, le fonti vive: Nebula, Proxmox, NinjaOne, il server MCP `proxmox`, la GUI del firewall e i pannelli degli apparati, questi ultimi solo tramite l'IT Manager. Si interrogano, non si ricordano: una misura batte una memoria. Nebula e Proxmox si rinfrescano da un'attivita' pianificata (ADR-026); la OpenAPI Nebula dipende dalla licenza, e un apparato nuovo va licenziato entro quindici giorni (ADR-022).

Classe C, le fonti documentali esterne: tre radici OneDrive su diciannove, lette a ogni avvio da `scripts/Check-OneDriveDelta.ps1`. Del suo output si legge per intero il blocco `RILEVANTI PER LA RETE`; se il delta e' arretrato di piu' di qualche giorno si triagia prima di ogni altro lavoro, e `-UpdateBaseline` si lancia solo dopo il triage.

Classe D, le altre sessioni di lavoro: il punto cieco vero, perche' nessun canale automatico porta qui cio' che si fa altrove. L'unico canale e' il file di handoff messo dove il delta lo vede; per `D:/log-collector` `scripts/Test-Allineamento.py` confronta il commit corrente con quello riconciliato in `data/scadenze.json`, e un commit nuovo impone di leggerne il diff e trasferire qui solo cio' che cambia la rete.

Classe E, l'IT Manager: unica autorita' sulle decisioni, sulle priorita' e su cio' che e' stato fatto a mano sugli apparati senza traccia.

## Protocollo di riallineamento a inizio sessione

Primo, leggere `index.md` e l'ultima voce di `progress.md`. Secondo, leggere l'output del delta OneDrive dell'hook e triagiare se arretrato. Terzo, chiedere all'IT Manager che cosa e' cambiato fuori da qui, comprese le altre sessioni e gli interventi manuali. Quarto, rileggere le fonti vive pertinenti al task secondo la cadenza, caricando la skill `fonti-di-rete`; se il task tocca porte, VLAN o access point lo snapshot Nebula si rilancia. Quinto, invocare `sync-context` per il drift fra schede e stato.

Le cadenze sono confermate dall'IT Manager e la loro sorveglianza non dipende dalla memoria di nessuno: `scripts/Test-Allineamento.py` gira all'avvio e riporta l'eta' di ogni misura contro la cadenza dichiarata, insieme alle scadenze di `data/scadenze.json`. E' rumoroso e non blocca, per decisione dell'IT Manager.
