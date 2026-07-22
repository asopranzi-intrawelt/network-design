# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 7463b73 (HEAD al 17/07/2026, chiusura ADR-011 Fibercop)
Data snapshot:         2026-07-22
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

Aggiornato il 22/07/2026 (sessione corrente). Filone attivo: **Wi-Fi guest
VLAN 90**. Obiettivo: far navigare la rete ospiti sulla VLAN 90 (10.61.90.0/24),
servita da un AP Zyxel nuovo in multi-SSID (staff VLAN 40 + guest VLAN 90).
Sintomo: i client prendono l'IP dal DHCP del firewall (.90.1) ma non navigano,
sia via Wi-Fi (S25) sia via cavo (portatile su porta 19 del 30HP messa in access
PVID 90) — difetto comune a tutta la VLAN 90. **Diagnosi conclusa** (dettaglio
completo con evidenze e valori reali in `_notes/DIARIO.md` voce 22/07): L2 verso
il gateway integro (arp risolve .90.1 = interfaccia guest del FLEX 500), la
security policy PERMETTE guest->WAN (regola 12 `GUEST_Outgoing`, From OPT, log
off: nessun drop nel log durante il ping), ma il traffico non viene SNATtato — la
Policy Route del firewall e' vuota e la subnet guest non e' coperta dal SNAT
implicito ZLD che serve solo le LAN di fabbrica. **Fix individuato, NON ancora
applicato**: aggiungere una Policy Route con SNAT = outgoing-interface per la
subnet guest verso WAN_TRUNK. Aperti inoltre: (a) la vlan40 staff risulta
configurata sul dispositivo con un indirizzamento da correggere (dettaglio
operativo riservato in `_notes/DIARIO.md`), e come interfaccia aggiunta
richiedera' anch'essa una Policy Route SNAT; (b) stringere la regola 12
`GUEST_Outgoing` da To:any a sola WAN (segmentazione). Commit dei file tracciati
manuale dell'utente.

**Aggiornamento 22/07 (a fine sessione):** fix SNAT APPLICATO e verificato — creato
l'oggetto `GUEST_SUBNET` e la policy route `GUEST_SNAT` (Source GUEST_SUBNET,
SNAT outgoing-interface); il client guest naviga (ping 8.8.8.8 ok) e l'S25 su
SSID `Intrawelt (GUEST)` ha Internet. Tracciato in `firewall-zyxel-usg-flex-500.md`
§Policy Route (SNAT). Restano aperte le voci #2 (restringere `GUEST_Outgoing` a
sola WAN + valutare toggle Guest Network su Nebula) e #3 (renumber vlan40 al valore
reale + policy route `STAFF_SNAT` gemella). Timeline e work-log da completare.

Aggiornato il 20/07/2026 (voce precedente). Filone attivo: **Wi-Fi/AP
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

**Terzo filone di questa sessione: fix endpoint END-001 (20/07/2026).**
Intervento di helpdesk da handoff Desktop (`fix-errore-657rx-m365-workplace-join.md`):
su una postazione Windows con account locale, dopo il reset password M365
le app Microsoft fallivano il login con errore 657rx / 0x80090016
NTE_BAD_KEYSET. Causa: workplace join orfano del 2017 con keyset software
corrotto (TPM non in causa); il broker AAD tentava la chiave di dispositivo
inaccessibile. Risolto rimuovendo la registrazione orfana e ricreandone una
pulita al re-login. Documentato in `runbook-anomalie.md` §END-001, timeline
`2026-switch-piano-terra.md` (voce 20/07/2026), nota igiene identita' di
dispositivo in `design-and-security.md` §A.9.2. Residuo: purga del record di
dispositivo orfano lato Entra ID. Nessun ADR (intervento operativo).

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
