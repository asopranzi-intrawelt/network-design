# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: 92a3472 (27/07/2026, formalizzazione arretrati + ricognizione VM)
Data snapshot:         2026-07-27
```

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | 347f79c | da riverificare (drift accumulato, non toccata il 27/07) |
| design-and-security.md | 347f79c (frontmatter) | contenuto aggiornato il 27/07 per inventario VM (dieci VM, VM208 nuova), gap A.8.22/A.8.24/A.8.4-A.8.31; il resto resta ancorato allo snapshot v4 |
| deployment.md | 347f79c | da riverificare (drift accumulato, non toccata il 27/07) |
| dev-testing.md | 347f79c (frontmatter) | contenuto aggiornato il 27/07 (conteggio VM a dieci, VM208) |
| current-work.md | 347f79c (frontmatter) | contenuto allineato al 27/07: arretrati chiusi, filone attivo = design di rete (M22) |
| roadmap.md | 347f79c (frontmatter) | contenuto allineato al 27/07 (M12/M13a/M13b/M22 aggiornati con l'esito di luglio) |

## Punto di ripresa

**Ripresa 27/07/2026 — leggere questo blocco per primo.** La sessione del 27/07 ha
chiuso tutti gli arretrati documentali della sessione Wi-Fi/telefoni (correzione
della dorsale a porta 51, TEL-002 parte di rete risolta, postura Wi-Fi staff come
rischio accettato in ADR-014, management switch sulla VLAN dati `.10`, incidente del
PVID sul trunk, sezione Riferimenti utili) e ha censito quello che era comparso su
Proxmox: **dieci VM**, con la VM208 `portaleAsset` nata il 21/07 e attestata su
`vmbr0`, cioe' sul segmento piatto, dove pubblica un pilota applicativo con identity
provider su 80/443 verso tutta la `/19`. Quattro gap nuovi (#118 NET-011, #119
SEC-016, #120 SRV-005, #121 SEC-017) e il perimetro documentale delle VM applicative
fissato in ADR-015.

**Design M22 aperto nella stessa sessione** (secondo commit del 27/07): documento
`docs/segmentazione-lan-m22.md` su tre livelli — concettuale, deep-dive tecnico con
matrice dei flussi e sintassi verificata sul dispositivo, operativo con criterio di
rollback — piu' il diagramma target `.claude/context/diagrams/segmentazione-target-m22.mmd`
e i cinque sotto-step M22a-M22e in `roadmap.md`. Il design e' innestato sugli artefatti
esistenti (VLAN 40, DMZ 201, script Nebula, diagrammi drawio, mappatura porte) e da quel
confronto sono uscite tre correzioni: la nota "allowedVLAN: all su ogni porta" e' superata
dal 23/07, la tabella VLAN di `network-diagram.md` invertiva le classi `.10` e `.20`, ed e'
emerso un sesto segmento candidato (gestione degli apparati, oggi promiscua nella classe
delle postazioni, iLO su classe `.1`).

**Prossimo passo operativo: M22a, il censimento.** Serve materiale dell'utente: uno
snapshot Nebula nuovo (chiave API) e la lettura dalla GUI del firewall di ambiti DHCP,
riserve per MAC e oggetti indirizzo. Da quel censimento dipende la scelta tra rinumerare
le classi e affiancare segmenti nuovi. Pendenze operative non chiuse: provisioning dei due telefoni lato Vianova/myOffice (attesa esterna, email
pronta), binding HTTPS GroupShare (SEC-015), access key AWS non ruotata (SEC-012),
riscrittura storia git della Fase B.

Ripresa precedente 23/07/2026 (fine sessione Wi-Fi/telefoni): leggere
`_notes/RESUME_PROMPT.md`** — riassunto della sessione e recap completo delle
pendenze. Stato in breve: guest SNAT risolto e verificato; regola guest ristretta
a sola WAN; staff Wi-Fi con accesso completo alla LAN (per scelta, i due SSID sono
protetti da password); telefoni IP Piano Terra portati sulla VLAN 2 fonia (parte
di rete risolta) ma in attesa di provisioning per MAC lato Vianova/myOffice (email
pronta in `_notes/mail-myoffice-fonia-telefoni.md`). Modifiche ai file tracciati
gia' committate (c7119a6, 9555161).

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
Policy Route del firewall e' vuota e la subnet guest non e' coperta dal
mascheramento automatico del firewall perche' l'interfaccia `vlan90` guest e' di
tipo `general`, mentre le interfacce `internal` (come la `vlan40` staff)
ottengono da sole il mascheramento verso la WAN. Causa verificata il 22/07 su
Network > Interface (Interface Type: vlan40=internal, vlan90=general). **Fix individuato, NON ancora
applicato**: aggiungere una Policy Route con SNAT = outgoing-interface per la
subnet guest verso WAN_TRUNK. Aperti inoltre: (a) la vlan40 staff risulta
configurata sul dispositivo con un indirizzamento da correggere (dettaglio
operativo riservato in `_notes/DIARIO.md`); (b) stringere la regola 12
`GUEST_Outgoing` da To:any a sola WAN (segmentazione). Commit dei file tracciati
manuale dell'utente.

**Aggiornamento 22/07 (a fine sessione):** fix SNAT APPLICATO e verificato — creato
l'oggetto `GUEST_SUBNET` e la policy route `GUEST_SNAT` (Source GUEST_SUBNET,
SNAT outgoing-interface); il client guest naviga (ping 8.8.8.8 ok) e l'S25 su
SSID `Intrawelt (GUEST)` ha Internet. Tracciato in `firewall-zyxel-usg-flex-500.md`
§Policy Route (SNAT). Restano aperte le voci #2 (restringere `GUEST_Outgoing` a
sola WAN + valutare toggle Guest Network su Nebula) e #3 (rinumero vlan40 al valore
reale; la staff naviga gia', NON serve uno STAFF_SNAT). Documentazione tracciata
completata (firewall scheda, timeline, work-log, ISO A.13.1).

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
