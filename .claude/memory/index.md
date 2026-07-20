# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 7463b73 (HEAD al 17/07/2026, chiusura ADR-011 Fibercop)
Data snapshot:         2026-07-20
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | 347f79c | da riverificare (drift accumulato, non toccata in questa sessione) |
| design-and-security.md | 347f79c | da riverificare (drift accumulato, non toccata in questa sessione) |
| deployment.md | 347f79c | da riverificare (drift accumulato, non toccata in questa sessione) |
| dev-testing.md | 347f79c | da riverificare (drift accumulato, non toccata in questa sessione) |
| current-work.md | 7463b73 (contenuto) | allineata (Fase B Wi-Fi: modello/quantita' AP scelti 20/07) |
| roadmap.md | 7463b73 (contenuto) | allineata (M13b aggiornato con preventivo scelto) |

## Punto di ripresa

Aggiornato il 20/07/2026 (sessione corrente). Filone attivo: **Wi-Fi/AP
(Fase A/B)**. Stato a questa data: Fase A (isolamento VLAN 40 lato switch)
tentata e ripristinata due volte il 16/07/2026 per inaffidabilita' del
canale Nebula OpenAPI (dettaglio `docs/runbook-anomalie.md` §AP-001/NET-005,
gap NEB-001/NET-010 aperti — porta 46 del 54HP in link-flap, host Ollama).
La configurazione lato firewall resta pronta per un nuovo tentativo, non
ancora rifatto in questa sessione. **Fase B**: il 20/07/2026 l'utente ha
scelto un preventivo Punto Informatica per tre access point Zyxel
NWA130BE-EU0101 (Wi-Fi 7) a sostituzione dei tre AP Ubiquiti EOL
(PianoTerra, PianoPrimo, PianoSecondo); l'AP EsternoIrrigazione resta fuori
scope. Decisione registrata in ADR-012; importo e riferimento del
preventivo esclusi dai file tracciati per policy di anonimizzazione.
Acquisto/consegna non confermati.

**Secondo filone di questa sessione: GroupShare (Seeweb).** Continuazione
del thread aperto il 06/07/2026 (upgrade SR1->SR2/CU15, ancora bloccato sul
download installer, non toccato in questa sessione). Nuovo: incidente
HTTPS del 17/07/2026 su `gs.intrawelt.com` (certificato/binding scomparsi),
diagnosticato e parzialmente rimediato — **ripristinata solo la
connettivita' HTTP, non la cifratura**, per sbloccare subito i Project
Manager. Registrato come gap **SEC-015** (`GAP-TBC.md` #117, ADR-013,
`design-and-security.md` §A.13.2, `runbook-anomalie.md` §SEC-015, timeline
`2026-switch-piano-terra.md` voce 17-20/07/2026). Resta aperto: completare
il binding HTTPS via win-acme (fix gia' identificato).

Punto di ripresa precedente (07/07/2026, Fase 1bis ingestione OneDrive IT):
dettaglio operativo in `.claude/context/current-work.md`; stato ingestione
e priorita' in `docs/infrastructure-timeline/ingestion-checklist.md`
(riallineata 07/07, coda residua solo BASSA/attese esterne al 09/07).

Fatto nelle sessioni del 07/07: gestione delta OneDrive con hook di avvio e
ingestione GroupShare (6e1d4b6); mappatura porte fisiche completa da rilievo
2020 e xlsx 2026 (6d65a87); tagging in corso con gap 102-104, architettura
LAN telefoni Vianova e audit crittografia (552d96c); delta SCENIA con
Allegati A-L, DPIA compilata e Risposte Tecniche AIDAPT (594ec07); sync
schede e revisione WindTre con BitLocker endpoint (68216f0); tutte le voci
MEDIA del delta ingerite in sessione 8 (ABBYY, Checklist/call SCENIA,
benchmark IntraLino, gap 105-107); l'08/07 ingerite anche tutte le MEDIA
preesistenti e le BASSA infrastrutturali (PROXMOX riclassificata), con
residui IP reali bonificati. Sempre l'08/07: diagramma target rev 08/07
(secondo trunk PT-P2), snapshot v4 eseguito dall'utente e riconciliato
(gap 106-107 chiusi/aggiornati, nuovo 108; design-and-security alla v4),
decisione MCP in ADR-007 (token PVEAuditor, .mcp.json bonificato — token
da creare), timeline SVG auto-rigenerata a ogni sessione (repo + sito
E:\projects). La coda checklist e' solo BASSA minore. Attese esterne:
nota PORT-TAGGING, documentazione Claude IntraLino su VM, creazione token
API Proxmox.

La nota PORT-TAGGING (tagging dei due switch per la migrazione al centralino
cloud) resta in attesa: il racconto completo arriva a lavori conclusi, quando
gli endpoint telefonici funzioneranno; le evidenze sono gia' raccolte in
`_notes/[TBC] screenshot e note myoffice/`.

M1 resta l'unico micro-step Fase 3 chiuso. Fase B anonimizzazione (Fase 3bis)
non iniziata; riscrittura storia git rimandata a dopo la Fase B
(`_notes/.git-filter-replacements.txt` pronto, esteso il 07/07 con gli
username VPN).
