# Snapshot di sincronizzazione

> Da leggere per primo a inizio sessione. Fotografa lo stato del progetto al commit di
> riferimento e mappa ogni scheda al suo stato di verifica.

## Stato

```
Branch attivo:         main
Commit di riferimento: e9ce5d7 (03/08/2026, ADR-019 e sette condivisioni di scansione)
Data snapshot:         2026-08-03
```

Nota di stato al momento della chiusura: il lavoro documentale del 03/08 (chiusura di R8,
allineamento schede, resume prompt) e' **su disco ma non ancora committato** — commit e push
restano manuali dell'utente secondo i vincoli di team. Alla ripresa, se `git status` mostra
modifiche non committate, sono quelle.

Nota di riallineamento: questo file era rimasto fermo a `PENDING-FIRST-COMMIT`
dal 2026-06-22 nonostante piu' commit successivi. Il riferimento va aggiornato
a ogni sessione che tocca schede o memoria, non solo alla prima.

## Nota sul frontmatter delle schede (03/08/2026)

Tutte le schede di `.claude/context/` portano ancora `last-verified: 347f79c`, che e' il
commit di riferimento di luglio: il valore e' stale su tutte, comprese quelle il cui
contenuto e' allineato. Non e' stato bumpato perche' i commit sono manuali dell'utente e il
valore corretto e' l'hash del commit che include le modifiche, che non esiste finche' il
commit non e' fatto. Subito dopo il commit, il bump si fa con una riga per scheda
sostituendo `347f79c` con l'hash nuovo, e va fatto in quel momento e non rimandato: e'
esattamente il passo che si e' perso a luglio, con il risultato che questo file dichiarava un
drift che nessuno chiudeva.

## Stato di verifica delle schede

| Scheda | last-verified | Stato |
|---|---|---|
| STACK.md | 347f79c | **da riverificare**: drift accumulato, non toccata da luglio. Non conosce i tre script aggiunti da allora (`Get-NinjaSnapshot.ps1`, `New-ScanFolderShortcut.ps1`, e il ruolo di `Get-NebulaSnapshot.ps1` nel censimento) |
| design-and-security.md | 347f79c (frontmatter) | contenuto allineato al 03/08: inventario a dieci VM, contesto di gestione endpoint (rotazione a trenta giorni, RMM), assenza di servizio di directory, snapshot multi-tenant, gap A.8.20/A.8.22/A.8.24/A.5.14-A.8.3/A.8.4-A.8.31. Frontmatter da bumpare al prossimo commit |
| deployment.md | 347f79c | **da riverificare**: non conosce l'esecuzione degli script nuovi ne' i vincoli sulle credenziali dell'RMM (ADR-017) |
| dev-testing.md | 347f79c (frontmatter) | contenuto allineato al 03/08: conteggio VM a dieci, cinque trappole PowerShell, regola sulle verifiche che possono fallire per la ragione giusta, banco di prova fuori linea |
| current-work.md | 347f79c (frontmatter) | contenuto allineato al 03/08: §Stato al 03/08/2026 con R8 eseguito, code aperte e filone strutturale |
| roadmap.md | 347f79c (frontmatter) | contenuto allineato al 03/08: M13c (quarto AP), M22a-M22e, M23, M24, **M25** (risoluzione nomi interna), registro parallelo dei micro-interventi |
| interventi-robustezza.md (docs/) | non applicabile | registro operativo, allineato al 03/08: R1-R14, R8 completato con tabella per destinatario |

## Punto di ripresa

**Chiusura sessione 05/08/2026 — le prossime tre sessioni sono pianificate.** Leggere
`_notes/RESUME_PROMPT.md`, riscritto per questo scopo. In sintesi: **sessione 1** il 06/08 mattina,
montaggio di un access point esterno nuovo che servira' la centrale di irrigazione e l'inverter
del fotovoltaico (esecuzione di M13c; verificare la tratta a 100 Mbps e l'alimentazione **prima**
di salire, e il collaudo e' un ciclo di irrigazione reale, non un ping); **sessione 2** dedicata
interamente allo snapshot della rete a ogni livello — fisico, elettrico, L2, L3, configurazione del
firewall — con i diagrammi ricomposti e i due armadi rack finalmente descritti; **dalla sessione 3**
si riprende la roadmap, con l'ordine raccomandato R8+R5+R15 in un giro, poi M22b previa M3, poi M17.
L'IT Manager rimandera' inoltre **due documenti modificati a mano**, entrambi sul desktop:
`intrawelt_telefoni-e-AP_scheda-da-completare.md` (valori reali, scheda operativa) e
`intrawelt-rete_AP-stampanti-VLAN-fonia_2026-08-03.md` (segnaposto, cinque filoni tematici).
Hanno **convenzioni diverse sugli indirizzi**: prima di riportare qualunque valore in un file
tracciato va stabilito se e' segnaposto o dato reale, perche' un indirizzo vero scritto per
distrazione in un repository pubblico non si toglie piu' senza riscrivere la storia. Cosa farne,
punto per punto, e' nel prompt di ripresa.

**Catena WAN ricostruita il 03-04/08/2026 — leggere prima di toccare il firewall.** Antenna sul
tetto, iniettore PoE (sotto gruppo di continuita', confermato), **Mikrotik RB2011UiAS-RM**, due
**Vianova R-1000** in cascata di cui il secondo con una **linea VDSL** sulla xDSL, entrambi sullo
**Vianova S-1000**, che sdoppia: porta 4 alla P2 del firewall per i dati, porta 1 alla porta 8 del
54HP per la voce. Tre conseguenze: i percorsi Internet sono **tre**; il ponte radio **non tocca il
firewall** perche' il failover e' dentro gli apparati del fornitore; e `wan2` sulla P3 e' il
**residuo della linea TIM dismessa**, ancora attiva, da spegnere in M7. Fonte: `startup-config.conf`
del 03/08 in `_notes/`, mai versionato. Dal file anche: quattro indirizzi pubblici spenti su `wan1`
(M9 riattiva un alias invece di chiederne uno nuovo), tabelle DNS **vuote** (corregge NET-014: la
risposta `.local` veniva dal client in multicast, non dal firewall), e un ambito DHCP in DMZ che il
piano non prevedeva. Nuovo gap **NET-018 (#137)**: Mikrotik e iniettore non censiti. Nuovi
interventi **R15-R18**. In attesa di un diagramma aggiornato al livello 2 dall'IT Manager; quello
nel repository e' superato.

**NET-017 (#136), aperto e risolto il 03/08/2026 — e ribalta M13c.** Sulla tratta del tetto c'e'
uno **Zyxel GS-105B v5**, cinque porte non gestite e non PoE, interposto **dagli elettricisti**
durante il montaggio dell'inverter fotovoltaico. Catena: porta 4 del 30HP, presa `0-8-1` in
locale caldaia, ponte a `0-9-1`, GS-105B, e da li' tre rami — cavo cat. 6 alla **centrale di
irrigazione**, l'**access point esterno** EOL, e l'**inverter del fotovoltaico**. Tre assunzioni
del progetto cadono: la centrale **e' cablata** e non servita via radio, quindi la prima opzione
di M13c-3 non e' un'opzione ma lo stato dei fatti e la domanda diventa a cosa serva oggi quell'AP;
i **100 Mbps sono quasi certamente il cavo** `0-8-1`-`0-9-1` e non l'apparato, perche' il GS-105B
e' gigabit, quindi sostituire l'AP non porterebbe un Mbps in piu' (da verificare leggendo la
velocita' sul GS-105B, e va fatto **prima dell'ordine** del WBE530); e l'**inverter e' un asset di
rete mai censito**, IoT/OT sulla LAN piatta, aggiunto a M22c insieme alla centrale. Aperto:
alimentazione dell'AP (il GS-105B taglia il PoE, un WBE530 lo richiede) e anagrafica
dell'inverter. Dettaglio in `docs/mappatura-porte-fisiche.md` §La catena del tetto.

**Protocollo delle fonti, dal 03/08/2026 — leggere prima di tutto il resto.** Esiste ora
`.claude/rules/fonti-e-riallineamento.md`, da caricare a ogni sessione: elenca le cinque classi
di fonti di questo progetto, dice su cosa ciascuna e' autorevole, e fissa il protocollo di
riallineamento in apertura. Il punto che spiega i ritardi accumulati: il repository e' una sola
classe, e le altre quattro **non notificano**. In particolare la rete viene cambiata anche da
altre sessioni di lavoro su questa macchina (ventidue, venti e quindici progetti su tre
installazioni, almeno sei dei quali toccano questa rete), il cui unico canale verso qui e' un
file di handoff. Due passi non automatizzabili vanno fatti a mano in apertura: leggere per
intero il blocco `RILEVANTI PER LA RETE` del delta, e **chiedere all'IT Manager cosa e'
cambiato fuori da qui**. La tabella delle cadenze in coda a quella regola attende conferma.

Correzione registrata lo stesso giorno: **tutti e cinque i Yealink sono collegati e ciascuno sta
su una porta che prende correttamente la VLAN della fonia**, lavoro concluso in sessioni
precedenti. La parte di rete di TEL-002 e' chiusa (nuova sezione in `runbook-anomalie.md`);
resta da confermare solo che ogni apparecchio si registri e chiami, verificabile dal display.
Non confondere con TEL-003, che e' la scala del parco digitale.

**Allineamento eseguito il 03/08/2026 — leggere questo blocco per primo.** Tre fatti nuovi
cambiano le priorita'. Il primo: il piano di numerazione dice che **ventisette dei trentasei
interni sono apparecchi digitali del Panasonic**, che non parlano SIP e che un centralino cloud
non puo' registrare — la migrazione della fonia e' cinque volte piu' grande di come il progetto
la descriveva, e il contratto del centralino virtuale risulta **firmato dal 23/03/2026** con la
quantita' di interni lasciata in bianco (gap TEL-003, scheda `telefono-pbx-voip.md`). Il
secondo: **M22a e' chiuso**, il 54HP e' rientrato e la tabella MAC c'e' per entrambi gli
switch; da qui un prerequisito che il design non aveva, cioe' che la VLAN 30 va aggiunta anche
alla **porta 33 del 54HP**, l'uplink verso il firewall, altrimenti il segmento delle stampanti
non raggiunge il proprio gateway. Il terzo: **M10 e' chiuso**, i telefoni sono tre al Piano 2 e
due al Piano Terra, non il contrario. Nuovi difetti NET-015 e NET-016. Baseline del delta
riallineata e script corretto perche' l'arretrato non si riformi. Riserva PORT-TAGGING sciolta
e chiusa. Frontmatter delle schede: vedi la nota qui sopra, va bumpato subito dopo il commit.
Igiene aperta: la chiave API Nebula e' in chiaro in un file sul desktop, va spostata in
`NEBULA_API_KEY` e il file cancellato.

**Audit di allineamento del 03/08/2026 — antefatto.** Il delta OneDrive
era arretrato di diciannove giorni ed e' stato triagiato: dentro c'erano **due asset di rete
mai censiti**, un access point da esterno **Zyxel WBE530-EU0101F** (l'hardware di M13c) e un
**UPS rack Addpower TP130N-1500** con scheda SNMP opzionale, entrambi da preventivo del
31/07, ordine non confermato. Due decisioni sono ora davanti all'acquisto e non dopo:
verificare la tratta della porta 4 prima di ordinare un apparato con porte da 2,5 Gbps
(M13c-5 promosso ad ALTA), e decidere se prendere la scheda SNMP dell'UPS, perche' se si
prende quell'apparato va fatto nascere nel segmento IoT/OT di M22c. Baseline dei manifest
**non ancora riallineata**: lanciare `Check-OneDriveDelta.ps1 -UpdateBaseline` dopo la
conferma. Buchi locali dichiarati: `_notes/RESOCONTO.md` fermo al 22/06 (livello 3 della
direttiva mai prodotto per gli interventi di luglio), `TEST-CHECKLIST.md` che conosce solo
Proxmox, due file RESUME quasi omonimi di cui solo `RESUME_PROMPT.md` e' quello valido,
`DIARIO.md` completo ma con la cronologia rotta dal 22/07 in poi. Snapshot Nebula fermo al
27/07 con la tabella MAC del 54HP mancante: **e' il rilancio che sblocca M22a**.

**Aggiunta della seconda sessione del 03/08/2026 — due fatti nuovi da tenere presenti.**
La dorsale fra i due switch e' la **porta 51** del 54HP e il ramo QNAP la **52**:
`network-diagram.md` portava ancora l'assegnazione invertita nel diagramma ASCII, ora
allineata. Ed e' comparso un asset di rete non censito: un **Grandstream HT-812 v2**
(adattatore analogico, due porte FXS, router NAT Gigabit) consegnato da myOffice il 31/07,
attribuito al telefono dell'ascensore — attribuzione da confermare col fornitore, e tre
questioni di rete aperte prima dell'installazione (segmento di attestazione, se disabilitare
il NAT interno, rapporto con il Patton SmartNode 5551). Vedi `docs/telefono-pbx-voip.md`
§Gateway FXS. Prodotto anche un estratto tematico temporaneo sul desktop dell'utente (access
point, stampanti, VLAN, telefoni, centralino), fuori repository per scelta: e' una vista, non
una fonte.

**Ripresa 03/08/2026 — leggere questo blocco per primo.** L'intervento **R8 e' eseguito e
verificato su tutte e sette le postazioni**: le scansioni delle due multifunzione non finiscono
piu' nelle cartelle condivise dei PC ma in sette condivisioni nascoste di NAS-INTRA2, una per
destinatario, con un solo account di servizio locale del NAS come unica credenziale memorizzata
negli apparati e con l'isolamento fra utenti provato in campo. Ogni utente raggiunge la propria
cartella da un collegamento sul desktop, distribuito con `scripts/New-ScanFolderShortcut.ps1`.

**Due code di R8 da chiudere per prime**: verificare su ciascuna postazione che la credenziale
del NAS sia **permanente** e non di sessione (`cmdkey /list` non deve dire "solo per questo
accesso": la memorizzazione da riga di comando non sopravvive al riavvio, quella
dall'interfaccia si'), e **rimuovere le vecchie condivisioni di scansione dalle postazioni con
le credenziali che le servivano** — e' quel passo che chiude SEC-020, non la creazione delle
cartelle nuove.

**Da decidere, in attesa dell'IT Manager**: la soglia di conservazione sulla cartella scansioni
(R10), che conviene fissare adesso che le cartelle sono quasi vuote. E va confermato se durante
il giro sulle rubriche e' stata spuntata la conferma prima dell'invio (R11).

**Filone strutturale invariato**: M22 segmentazione, con M22a chiuso (22 statici, 4 dinamici) e
M22b come prossimo intervento di rete; M25 (risoluzione nomi interna) e' il suo prerequisito
reale, perche' oggi unita' mappate, destinazioni e servizi interni dipendono da nomi risolti per
broadcast o per file `hosts`.



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

**M22a avviato il 27/07, prima meta' acquisita.** Snapshot Nebula raccolto dall'utente:
censimento completo per il Piano Terra (30 porte, tabella MAC di 58 voci) e mancante per
il Piano 2, perche' il 54HP ha risposto `DEVICE_IS_OFFLINE` sulla tabella MAC (nuova
occorrenza NEB-001; piano dati integro, e' il piano di gestione a essere assente). Tre
risultati: i **tre AP Zyxel della Fase B risultano installati e in servizio** (M13b era
dato come da installare), la porta 1 del 30HP e' ora un trunk che porta VLAN 1 e 40 —
cioe' l'isolamento Wi-Fi tentato con M13a e' operativo sul nuovo hardware — e sono
emersi due residui: protezioni DHCP di livello 2 disattivate sul 30HP (#122 NET-012) e
porta 19 ancora su PVID 90 (#123 NET-013).

**Requisito vincolante posto dall'IT Manager il 28/07**: la migrazione non deve rompere
niente, un PC deve continuare a raggiungere stampante e NAS. Tradotto in progetto nella
sezione §Requisito vincolante di `docs/segmentazione-lan-m22.md`, con la regola d'oro
che ne deriva (si spostano i client, non gli endpoint referenziati: NAS e server restano
fermi fino all'ultimo), l'eccezione delle stampanti (endpoint referenziato dalle code di
stampa, quindi serve rilevare il tipo di coda e ri-puntarla, preferibilmente a un nome) e
la checklist di verifica funzionale per ogni porta spostata, dove il canary e' una
lettura piu' scrittura su share NAS e non un ping (precedente NET-008).

**Nuovo filone aperto il 28/07**: sostituzione del quarto AP Ubiquiti EOL
"EsternoIrrigazione" (porta 4 del 30HP, tetto, serve la centrale di irrigazione),
portata in scope superando la clausola "fuori scope" di ADR-012 — vedi **ADR-016**, gap
**SEC-018** (#124) e gli otto sotto-passi **M13c-1..M13c-8** in `roadmap.md`. Quattro
fatti che ne condizionano l'esecuzione: la tratta al tetto e' cablata con patch nel locale
caldaia (non un ponte radio), la porta 4 negozia a 100 Mbps contro 1 Gbps delle altre, la
passphrase della rete radio attuale non e' recuperabile quindi la centrale va comunque
riconfigurata, e la prima opzione da valutare e' eliminare l'AP cablando la centrale.

**Nuovo artefatto del 29/07: `docs/interventi-robustezza.md`**, registro dei
micro-interventi non bloccanti (R1-R9), aperto su indicazione dell'IT Manager per gli
interventi puntuali eseguibili uno alla volta senza fermare la rete. Regola di ammissione:
nessuna finestra di manutenzione, nessun tocco al piano dati di apparati centrali, rollback
di una sola azione. Due voci sono anche prerequisiti di M22b e si possono fare prima della
segmentazione (R7 riserve DHCP, R8 destinazioni di scansione sul NAS); R5 chiude NET-013.

**Misura del 29-30/07 che ha motivato il registro, censimento chiuso su entrambe le
multifunzione**: undici destinazioni di scansione su undici sono cartelle SMB verso
condivisioni di singole postazioni, nessuna verso un NAS, che si riducono a **sette
destinatari distinti** (le quattro della Kyocera sono un sottoinsieme delle sette della
Canon). Due destinazioni puntano alla postazione per nome NetBIOS, quindi dipendono dal
broadcast e sono le prime a rompersi con la segmentazione; due utenze memorizzate sono
nominali; la conferma della destinazione prima dell'invio e' disattivata su tutte (R11).
SEC-020 (#126) esteso; NET-009 passa da osservazione a misura. Aggancio ISO su A.5.14/A.8.3
nella scheda di contesto e su §A.13.2 nella SoA.

**Protocollo deciso (30/07)**: due scansioni di prova riuscite da entrambe le multifunzione
verso una postazione dove SMBv1 e' disattivato, quindi **entrambi gli apparati parlano
SMB 2+** e la proposta di usare FTP e' archiviata. Ordine di preferenza fissato prima
dell'esito: SMB 2/3, poi FTPS solo per un apparato incapace, FTP in chiaro solo come debito
dichiarato.

**Vincolo trasversale registrato il 30/07 (ADR-017 e `design-and-security.md` §Contesto di
gestione degli endpoint)**: gli endpoint vivono su un RMM distribuito (NinjaOne) che applica
policy, script e automazioni e **ruota la password locale ogni trenta giorni**. Ne segue che
ogni credenziale di postazione memorizzata in un apparato dura al massimo trenta giorni (R8
elimina quindi un lavoro ricorrente, non solo un rischio), che le modifiche massive alle
postazioni si progettano come script distribuito via RMM, e che le policy vanno conosciute
prima di cambiare rete sotto di esse. Aggiunto `scripts/Get-NinjaSnapshot.ps1`, **sola
lettura**: le credenziali API sono del provider MSP, scope non estendibile, nessun valore nel
repository, output in `output/`. Beneficio collaterale: l'interrogazione delle interfacce di
rete per dispositivo puo' sostituire il censimento manuale degli indirizzi statici di M22a.

**Decisione su R8 del 30/07**: NAS-INTRA2, **sette cartelle condivise nascoste** una per
destinatario, con un solo account di servizio in sola scrittura come unica credenziale
memorizzata negli apparati. Sette destinatari erano uno oltre la soglia di sei fissata prima
di conoscere il numero: la deviazione e' dichiarata nel registro con la sua motivazione (il
costo che la soglia proteggeva, la illeggibilita' della lista delle condivisioni, e'
eliminabile nascondendole), e la soglia resta a sei per il caso generale.

**Esecuzione avviata il 30/07/2026, un passo per volta e ciascuno documentato.** Sequenza
**corretta** dopo un'obiezione dell'IT Manager: la prima versione metteva R12 in testa
definendolo prerequisito, ed era un errore di priorita' — R12 non serve alle scansioni (le
multifunzione non hanno DNS, quindi le destinazioni devono essere indirizzi) ne' alla
migrazione delle stampanti (le code si ri-puntano al nuovo indirizzo), e in un'azienda dove
la pratica consolidata e' modificare il file `hosts` per endpoint non produce nemmeno un
risparmio immediato, perche' il file locale ha precedenza sul DNS e per ottenere il beneficio
andrebbero anche ripulite le voci esistenti. Sequenza valida: **R8 con R9 e R10** (scansioni
sul NAS, il problema da cui tutto e' partito, indipendente da tutto); poi gli interventi brevi
R1, R2, R3, R5, R6; poi **M22b**; R12 e R13 come miglioramento a se', quando conviene.

**R12 in corso**: procedura nei tre sotto-passi in `docs/interventi-robustezza.md` §R12.
Bloccato su una decisione: il **suffisso** dei nomi interni. Emerso che i due nomi interni
esistenti usano `.local`, che e' riservato a mDNS e non e' quindi lo standard da seguire ma un
debito da migrare (NET-014 #131, intervento R13). Le due strade sono un suffisso di uso privato
(`.lan`, gia' usato per il portale della VM208) oppure un sottodominio del dominio pubblico
aziendale, che in piu' rende ottenibili certificati pubblicamente riconosciuti e chiuderebbe
SEC-016 per intero.

**M22a e' chiuso** (30/07): 22 indirizzi statici o riservati e 4 dinamici sulle postazioni, con
il 22 corroborato in modo indipendente dagli oggetti indirizzo del firewall.

**Prossimo passo operativo**: completare M22a — tabella MAC del 54HP a switch rientrato,
ambiti e riserve DHCP dalla GUI del firewall, oggetti indirizzo pagina 2 compresa,
censimento degli host statici, e rilevamento del tipo di code di stampa su una postazione
reale. Pendenze operative non chiuse: provisioning dei due telefoni lato Vianova/myOffice (attesa esterna, email
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
