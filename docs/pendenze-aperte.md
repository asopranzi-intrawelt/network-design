# Pendenze aperte

> Vista consolidata di cio' che resta da sanare, aggiornata al 06/08/2026. Non e' una fonte:
> ogni riga punta al registro che la possiede davvero, e nessuna informazione vive **solo** qui.
> Serve a rispondere in trenta secondi alla domanda "cosa e' rimasto in sospeso", che altrimenti
> richiede di attraversare quattro registri diversi: i gap in
> `infrastructure-timeline/GAP-TBC.md`, i micro-interventi in `interventi-robustezza.md`, i
> micro-step in `.claude/context/roadmap.md` e le decisioni in `.claude/memory/decisions.md`.
> Va riletta e potata a fine sessione: una lista di pendenze che non si accorcia mai smette di
> essere letta.

## Sanabili subito, rischio circoscritto

Interventi che non richiedono una finestra di manutenzione, non toccano il piano dati di apparati
centrali e hanno un rollback di una sola azione. Sono la coda del registro dei micro-interventi,
piu' due voci di configurazione nate il 05-06/08.

| Cosa | Dove e' tracciato | Nota che decide se farlo adesso |
|---|---|---|
| Restringere ad `allowed = 2` le cinque porte di fonia che oggi ammettono `all`: 13 del 30HP, 3, 6, 8 e 44 del 54HP | R19; NET-019 (#143) | Il `PVID` non si tocca, quindi il traffico non taggato continua a finire in VLAN 2 e il comportamento normale non cambia. Una porta per volta; sulla **8** ci sono tre indirizzi appresi, quindi guardare cosa c'e' dietro prima di stringerla |
| Riportare la porta 21 del 30HP a una configurazione coerente (oggi PVID 1 con la sola VLAN 2 ammessa) | R15; NET-015 (#134) | La porta e' senza link: nessun impatto in atto, ma chi vi collega qualcosa non naviga |
| Riportare la porta 19 del 30HP da PVID 90 a PVID 1 | R5; NET-013 (#123) | Residuo di un test, porta senza link |
| Portare `PROXMOX_ALLOW_DANGER` a `false` in `.mcp.json` | SEC-025 (#142) | Tutto l'uso documentato del MCP e' in lettura; oggi l'unica difesa e' il token di sola lettura |
| Completare la rotazione della chiave API Nebula e **revocare la vecchia** in NCC | ADR-021; procedura nel punto di ripresa di `.claude/memory/index.md` | Igiene, non ripristino: la chiave attuale funziona. Serve `scripts/Set-ProjectSecret.ps1` e un riavvio della sessione |
| Le due code di R8: verificare che la credenziale del NAS sia permanente su ogni postazione, e rimuovere le vecchie condivisioni di scansione con le credenziali che le servivano | R8; SEC-020 (#126) | E' la rimozione delle vecchie condivisioni, non la creazione delle nuove, a chiudere SEC-020 |
| Le voci multifunzione e scansioni ancora aperte: credenziali di fabbrica, filtro IP, mDNS, campo posizione, porte di stampa orfane, riserve DHCP, account di servizio nelle rubriche, conferma prima dell'invio | R1, R2, R3, R4, R6, R7, R9, R11 | Nessuna interrompe la stampa; R7 e' anche prerequisito di M22b |

## Prerequisiti di interventi gia' pianificati

Non sono opzionali e non sono rimandabili al dopo: se saltano, l'intervento a cui appartengono
fallisce in modo silenzioso o si scopre irreversibile.

| Cosa | Dove e' tracciato | Perche' viene prima |
|---|---|---|
| Licenziare con Nebula Professional il nuovo access point da esterno **entro quindici giorni** dall'adozione, co-terminato al 22/11/2027 | M13c-9; ADR-022; precedente NEB-002 (#140) | Il livello dell'organizzazione e' il minimo fra i suoi apparati: un dispositivo scoperto fa cadere tutta l'organizzazione a Base Pack e spegne la OpenAPI. E' gia' successo il 05/08 |
| Misurare quale elemento impone i 100 Mbps sulla tratta del tetto, **prima dell'ordine** del WBE530 | M13c-5; NET-017 (#136) | Se il limite e' il cavo, un apparato con porte da 2,5 Gbps resta strozzato e si paga capacita' inutilizzabile |
| Aggiungere la VLAN 30 alla lista delle ammesse della porta 29 del 30HP **e** della porta 33 del 54HP | M22b passo 6; `segmentazione-lan-m22.md` | Senza la 33 il segmento stampanti non raggiunge il gateway: non risulta isolato, risulta morto, e la diagnosi parte dal posto sbagliato |
| Identificare cosa serve la porta 3 del 30HP, e stringere la 4 quando M22c porta il ramo del tetto nel segmento IoT/OT | NET-020 (#144) | La 4 e' l'unica via verso irrigazione, inverter e access point EOL, e il collaudo di quel ramo e' un ciclo di irrigazione reale |
| Risoluzione dei nomi interni prima della segmentazione | M25; R12, R13; NET-014 (#131) | Unita' mappate, destinazioni e servizi interni dipendono oggi da nomi risolti per broadcast o per file `hosts` |
| Snapshot Proxmox v5 completo, lanciato dall'IT Manager | M18 | Cadenza mensile scaduta: l'ultimo e' dell'08/07. Il MCP non vede job di backup, pool, regole firewall, dischi fisici, SDN, HA e snapshot |

## Da presidiare nel tempo

Cose che non si "fanno" una volta: scadono, e il segnale di scadenza e' debole o assente.

| Cosa | Data | Dove e' tracciato |
|---|---|---|
| Rinnovo Nebula Professional Pack, tutti i dispositivi co-terminati | **22/11/2027**, che e' la piu' vicina (54HP) | ADR-022; `vendor-management.md` scheda Zyxel |
| Gold Security Pack dell'USG FLEX 500, licenza distinta da quella Nebula | **19/12/2026** | `vendor-management.md` scheda Zyxel |
| Regola permanente: ogni apparato adottato in organizzazione va licenziato entro quindici giorni | continua | ADR-022; `.claude/rules/fonti-e-riallineamento.md` |
| Chiave pre-condivisa del tunnel PSE-SEEWEB: verificare se e' ancora quella del 2018 e in caso ruotarla **prima** di occuparsi dei file | aperta | SEC-023 (#138); FW-006, M14 |
| Access key AWS amministrativa mai ruotata | aperta | SEC-012 |
| Binding HTTPS di GroupShare, oggi servito in chiaro | aperta | SEC-015 (#117); ADR-013 |

## Verifiche aperte, cioe' domande senza risposta

Vanno chiuse con una misura, non con un'inferenza. Finche' restano qui, il progetto non ha il
diritto di affermare la risposta.

| Domanda | Come si chiude | Dove e' tracciato |
|---|---|---|
| La console VNC della VM602 Intralino e' davvero attiva sulla LAN piatta, e ha una password di display? | `qm showcmd 602` sul nodo, piu' verifica della password | SRV-006 (#141) |
| Il file di credenziali in chiaro nella home dell'utente della VM207 | ispezione e rimozione | SRV-005 (#120) |
| Che cosa espone la OpenAPI per il firewall **assegnato a un sito** in Cloud Monitoring Mode | assegnarlo e rileggere; oggi in stato `Unused` espone la sola anagrafica | `.claude/rules/fonti-e-riallineamento.md` §Fonte automatica pianificata |
| Perche' le porte di fonia hanno due generazioni di configurazione | change log di configurazione degli apparati su NCC | NET-019 (#143) |
| Cosa c'e' davvero sulla porta 52 del 54HP, che ha imparato undici indirizzi mentre la documentazione la descrive come ramo QNAP | sopralluogo fisico, nella sessione dedicata allo snapshot della rete | osservazione del 06/08/2026 |
| Cosa e' collegato alle tre porte che negoziano 10 Mbps (5 e 22 del 30HP, 25 del 54HP) | sopralluogo e prova del cavo | R16; NET-016 (#135) |
| Proprieta', amministratore e credenziali del Mikrotik sulla catena WAN | domanda al fornitore | R17; NET-018 (#137) |
| Anagrafica dell'inverter del fotovoltaico come asset di rete | sopralluogo | R18; NET-017 (#136) |
| Se un dispositivo in stato `Unused` concorra al requisito di copertura della licenza | non verificabile senza provocare un declassamento: **non** si prova per curiosita' | ADR-022 |

## Igiene documentale e di sessione

| Cosa | Nota |
|---|---|
| Triagiare i due file di handoff comparsi nel delta del 06/08 come rilevanti per la rete, `intrawelt_telefoni-e-AP_scheda-da-completare.md` e `intrawelt-rete_AP-stampanti-VLAN-fonia_2026-08-03.md`, e solo dopo rilanciare `Check-OneDriveDelta.ps1 -UpdateBaseline` | Non ancora registrati nella checklist di ingestione. I due file hanno **convenzioni diverse sugli indirizzi**: stabilire se un valore e' segnaposto o reale prima di riportarlo in un file tracciato |
| Commit manuale delle modifiche di questa sessione, poi bump del frontmatter `last-verified` sulle schede toccate | E' il passo che a luglio si e' perso per sei settimane |
| Lo snapshot Nebula congelato `_notes/nebula-snapshot-ultimo-buono-2026-08-05-1148-pre-downgrade.json` e' ora **superato** da quello del 06/08, piu' completo | Si puo' eliminare: la ragione per cui esisteva e' venuta meno |
