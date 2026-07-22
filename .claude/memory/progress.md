# Work-log

## 2026-07-22 — Wi-Fi ospiti VLAN 90: ripristino navigazione, SNAT mancante (sessione corrente)

Commit: PENDING (da fare manualmente)
File toccati (tracciati): docs/firewall-zyxel-usg-flex-500.md (nuova sezione
§Policy Route (SNAT)), docs/infrastructure-timeline/2026-switch-piano-terra.md
(nuova voce 22/07/2026), .claude/memory/index.md (punto di ripresa aggiornato).
File privati (non versionati): _notes/DIARIO.md (diagnosi, esito, spiegazione
didattica SNAT implicito, valore per CV), _notes/.anonymization-map.md (voci
22/07: MAC interfaccia guest del FLEX, MAC ethernet del portatile Persona-H,
nota vlan40 placeholder-in-config-reale).
Motivo: la Wi-Fi ospiti su VLAN 90 (SSID Intrawelt GUEST, multi-SSID sul nuovo AP
Zyxel) faceva prendere ai client l'IP dal DHCP del firewall (.90.1) ma non
navigare, sia via Wi-Fi sia via cavo (portatile su porta switch messa in access
VLAN 90). Diagnosi a strati: L2 verso il gateway ok (ARP risolve il MAC
dell'interfaccia guest del firewall), security policy GUEST_Outgoing permette
l'uscita senza drop nel log, NAT con soli virtual server, Policy Route vuota ->
unica causa il SNAT mancante. Sullo ZLD il mascheramento verso WAN e' automatico
solo per le interfacce LAN di fabbrica; la guest, aggiunta dopo, ne restava fuori.
Fix: creato oggetto GUEST_SUBNET e policy route GUEST_SNAT (SNAT
outgoing-interface sulla sola subnet guest), verificato con ping 8.8.8.8 (risposta)
e S25 sull'SSID guest con Internet. VLAN 90 ormai ripulita dall'infrastruttura
legacy che vi era finita per errore. Anonimizzazione: nei file tracciati solo
10.61.90.x/10.61.40.x e nomi di oggetto tecnici del firewall; tutti i valori reali
(192.168.x, MAC, nome del consulente esterno = Persona-H, oggetti pc-* del
firewall con nomi propri) restano solo sotto _notes/. Nessun ADR (intervento
operativo). Restano aperti: restringere GUEST_Outgoing a sola WAN + valutare il
toggle Guest Network su Nebula (#2); renumber vlan40 al valore reale + policy
route STAFF_SNAT gemella (#3); nota ISO27001 in design-and-security.md e aggancio
GAP-TBC (relazione con NET-001) da completare (#4).

## 2026-07-20 — Fix endpoint END-001: errore 657rx M365 / workplace join orfano (sessione corrente)

Commit: PENDING (da fare manualmente)
File toccati: docs/runbook-anomalie.md (nuova sezione §END-001, prima del
footer), docs/infrastructure-timeline/2026-switch-piano-terra.md (nuova voce
20/07/2026), docs/design-and-security.md (§A.9.2, nota igiene identita' di
dispositivo), _notes/DIARIO.md (voce narrativa), .claude/memory/index.md
(punto di ripresa). SVG timeline rigenerata.
Motivo: l'utente ha fornito un handoff dal Desktop
(`fix-errore-657rx-m365-workplace-join.md`) su un intervento di helpdesk del
20/07/2026: dopo il reset password M365 di un utente, le app Microsoft di una
postazione Windows (account locale) fallivano il login con errore 657rx /
0x80090016 NTE_BAD_KEYSET. Causa: workplace join orfano del 2017 con keyset
software corrotto (TPM non in causa, `TpmProtected : NO`); il broker AAD
tentava la chiave di dispositivo inaccessibile invece della password.
Risolto rimuovendo la registrazione orfana (`dsregcmd /leave`, certificato
MS-Organization-Access, chiave HKCU WorkplaceJoin) e ricreandone una pulita
al re-login. Anonimizzazione: il documento sorgente e' una procedura
Microsoft generica, senza IP/nomi propri/importi reali; nessun identificatore
reale introdotto (utente colpito e hostname non riportati). Nessun ADR
(intervento operativo, non decisione architetturale). Residuo: purga del
record di dispositivo orfano lato Entra ID, segnalata come igiene A.9.2.

## 2026-07-20 — GroupShare SEC-015: incidente HTTPS scomparso, ripristinato solo HTTP (sessione corrente)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/GAP-TBC.md (nuova voce #117
SEC-015, conteggio aggiornato), docs/design-and-security.md (§A.13.2),
docs/runbook-anomalie.md (nuova sezione §SEC-015), docs/infrastructure-timeline/2026-switch-piano-terra.md
(voce 17-20/07/2026), .claude/memory/decisions.md (ADR-013), _notes/.anonymization-map.md
(client LAN 192.168.10.74, riuso placeholder Seeweb/Persona-E/Persona-H).
Motivo: l'utente ha fornito due handoff dal Desktop (`groupshare-upgrade-handoff.md`,
gia' noto e coerente con la voce tracciata del 06/07; `handoff-SSL.md`,
nuovo) e ha chiarito che l'esito reale dell'incidente HTTPS del 17/07 e'
stato il ripristino della sola connettivita' HTTP (non cifrata) per
sbloccare i PM, non il completamento del fix win-acme. Identita' degli
operatori chiarita su richiesta: Alessio Sopranzi (reale) con Tommaso
Vezeni (Persona-E) e Daniele Colo' (Persona-H, Punto Informatica). Nessuna
credenziale del documento sorgente (accessi firewall/ESXi/VM/SQL) riportata
nei file tracciati. Gap registrato come SEC-015, ancora aperto: il binding
HTTPS via win-acme resta il fix identificato ma non applicato.

## 2026-07-20 — Fase B Wi-Fi: scelto il preventivo Punto Informatica (3x Zyxel NWA130BE-EU0101)

Commit: PENDING (da fare manualmente)
File toccati: docs/runbook-anomalie.md (§AP-001, nuova sezione "Preventivo
Fase B scelto"), docs/vendor-management.md (§Punto Informatica), docs/infrastructure-timeline/2026-switch-piano-terra.md
(nuova voce 20/07/2026), .claude/context/roadmap.md (M13b aggiornato),
.claude/context/current-work.md (paragrafo Fase B aggiunto), .claude/memory/decisions.md
(ADR-012).
Motivo: l'utente ha letto un preventivo locale (`Preventivo-205_2026-INTRAWELT...pdf`,
non versionato, fuori dal repository) di Punto Informatica per tre access
point Zyxel NWA130BE-EU0101 (Wi-Fi 7 tri-radio, NebulaFlex) e ha scelto di
adottarlo per la Fase B (sostituzione dei tre AP Ubiquiti EOL decisa il
15/07/2026). Quantita' di tre unita' coerente con le tre ubicazioni
staff/guest gia' mappate (PianoTerra, PianoPrimo, PianoSecondo); l'AP
EsternoIrrigazione resta fuori scope. Importo, sconto e numero del
preventivo non riportati in nessun file tracciato per policy di
anonimizzazione (`.claude/rules/anonymization.md` §dati amministrativi e
commerciali) — solo il fatto tecnico e' stato documentato. Acquisto e
consegna non confermati in questa sessione. Il retry di Fase A (VLAN 40
lato switch) e la diagnosi NET-010 (porta 46 del 54HP) restano aperti,
indipendenti da questa decisione.

## 2026-07-15 — Triage delta OneDrive, script di scrittura Nebula per M13a, verifica canale API firewall (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/ingestion-checklist.md (delta
09/07->15/07 triato, baseline aggiornata per entrambe le librerie OneDrive),
_notes/DIARIO.md (ripresa della pratica narrativa: prima voce sulla caccia
agli AP/Nebula), scripts/Set-NebulaWifiVlan.ps1 (nuovo, scrittura), .claude/memory/decisions.md
(ADR-010), .claude/context/roadmap.md (M13a aggiornato a "parziale").
Motivo: l'utente ha chiesto di procedere a micro-step tracciati sulla
configurazione switch via script, e di valutare se collegarsi anche al
firewall via API. Delta OneDrive: eseguito `Check-OneDriveDelta.ps1
-UpdateBaseline`, tutte le 44 voci (42 nuovi + 3 modificati + 1 eliminato
su "Documenti - IT", 2+5 su "IT + Administration") ricadono in categorie
gia' decise (corpus dataset bilingue del tirocinio Unimc, manuali prodotto
SCENIA, fatture, la sottocartella centralino cloud riservata alla nota
PORT-TAGGING) — nessuna nuova ingestione, solo baseline avanzata.
Script di scrittura: `Set-NebulaWifiVlan.ps1` assegna la VLAN Wi-Fi (default
proposto 40, NON confermato) alle tre porte AP note (XGS2220-30HP porta 1,
XGS2220-54HP porte 41/45) e la propaga sulle porte trunk scoperte
dinamicamente; dry-run di default, `-Apply` richiede conferma testuale
("CONFERMA") prima di scrivere. Sintassi validata via
`[System.Management.Automation.Language.Parser]::ParseFile`; non ancora
eseguito in dry-run reale contro l'API (richiede la chiave, in mano
all'utente). Scoperta rilevante durante la stesura (due fetch della
documentazione ufficiale Nebula OpenAPI): non esiste nessun endpoint per
creare una VLAN, solo per assegnarla a una porta — la VLAN va creata una
tantum dalla GUI Nebula prima di lanciare lo script con `-Apply`. Verificato
inoltre che l'API Nebula e' scopata per amministratore, non per ruolo:
niente equivalente del token PVEAuditor di Proxmox, quindi la mitigazione
del rischio di scrittura resta a livello di script (dry-run + conferma),
non di permessi del token — documentato in ADR-010, che formalizza anche
lo scostamento dal pattern ADR-008.
Firewall: confermato (via fetch diretto di zyxelnetworks.github.io/NebulaOpenAPI
e verifica dell'inventario dispositivi in nebula-config.md, che mostra solo
i due switch) che lo USG FLEX 500 non e' adottato in Nebula e gira in
modalita' standalone ZLD classica: nessuna API REST disponibile per questo
dispositivo nel suo stato attuale. L'unico canale scriptabile e' quello
amministrativo gia' attivo, SSH con 2FA (`firewall-zyxel-usg-flex-500.md`
riga 373), che richiede comunque un umano per il secondo fattore ad ogni
sessione: la via praticabile e' uno script "generatore" del blocco di
comandi CLI ZLD da incollare in una sessione gia' autenticata, non ancora
scritto (dipende dalla conferma dell'ID VLAN, che determina il contenuto
esatto delle regole ACL/interfaccia). Diario narrativo: scritta la prima
voce di `_notes/DIARIO.md` nel formato esistente, a copertura dell'intera
saga Nebula/AP-001/Fase A-B, su richiesta esplicita dell'utente di
riprendere quella pratica da ora in avanti.
Aperto: conferma utente sull'ID VLAN (proposto 40), creazione manuale
della VLAN su Nebula GUI, dry-run reale dello script, poi il generatore di
comandi CLI per il firewall.

**Addendum stessa sessione**: l'utente ha confermato VLAN 40. Mentre
verificavo i dati reali dello switch per un avviso dell'utente su due
porte fonia (6 e 8 del 54HP, DHCP Vianova tagged), scoperto un bug reale
nello script appena scritto: l'endpoint `port-settings` di Nebula
restituisce un inviluppo OData `{"value": [...], "Count": N}`, non un
array nudo come `l2-mac-table`/`ports-status` — senza unwrap esplicito
ogni filtro `Where-Object` su portNum/trunk avrebbe fallito silenziosamente
e il piano sarebbe risultato vuoto. Corretto con una funzione
`Get-NebulaArrayValue` dedicata, risintassato con il parser .NET. Verificato
sui dati reali che le porte fonia (3/5/6/8/44 sul 54HP, portVid=2) hanno
tutte `trunk=false`: la logica di propagazione VLAN dello script (che tocca
solo porte con `trunk=true`, di fatto 49-54) non le tocca, coerente con
l'avviso dell'utente ma gia' sicura per costruzione. Scritta la sezione
"Fase A rete Wi-Fi (M13a)" in `firewall-zyxel-usg-flex-500.md`: interfaccia
vlan40 (10.61.40.0/24) e security policy di deny verso LAN1 in sintassi
verificata sul dispositivo reale (idem della VLAN 201 DMZ e del changelog
M1), zona da assegnare via GUI (non ipotizzata in CLI per non rischiare un
nome zona sbagliato silenzioso), checklist di applicazione in sei passi con
screenshot di verifica.

**Addendum, guida live in Nebula GUI**: seguendo l'utente passo passo dentro
Nebula per creare la VLAN 40, verificato a schermo (screenshot pannello
"Update port", Switch ports > Port1 dello switch XGS2220-30HP) che il campo
PVID e' testo libero, non un menu vincolato a VLAN preesistenti — corretta
l'ipotesi scritta in mattinata (ADR-010, roadmap, firewall doc) secondo cui
la VLAN andrebbe pre-creata a mano prima di usare l'API/lo script. Scoperta
piu' rilevante della correzione stessa: applicare in un solo colpo trunk e
porte AP e' rischioso perche' il firewall non ha ancora l'interfaccia/DHCP
per la VLAN 40 — spostare il PVID di un AP live la scollegherebbe. Aggiunto
un parametro `-Only Trunk\|Access\|All` allo script per staged rollout
(trunk sicuro subito, porte AP solo a firewall pronto, una alla volta).
L'utente NON ha ancora premuto Update sulla porta 1 (istruito a chiudere
senza salvare): nessuna modifica reale applicata finora.

**Addendum, dry-run reale**: l'utente ha eseguito `Set-NebulaWifiVlan.ps1
-Only Trunk` con la chiave API reale — 6 porte (49-54 del 54HP) segnalate
come "Changed", ma un controllo sui dati grezzi (rieseguito
`Get-NebulaSnapshot.ps1` per un refresh, poi ispezionato con uno script
scratchpad) ha rivelato che quelle porte hanno gia' `allowedVLAN: ["all"]`
oggi, e cosi' pure la porta 29 del 30HP (l'uplink verso il 54HP, marcata
`trunk: false` ma ugualmente permissiva). Lo script confrontava la stringa
letterale "all" con "40" e la trattava erroneamente come "da cambiare".
Corretto: `$alreadyAllowed` ora riconosce "all" come gia' comprensivo di
qualunque VLAN. Conseguenza pratica per M13a: il passo di propagazione
trunk non serve, la VLAN 40 attraversa gia' la dorsale; resta solo
l'intervento sulle tre porte AP. Annotato anche il limite di postura L2
di fondo (allowedVLAN universalmente permissivo su ogni porta controllata)
come nota residua non bloccante in `runbook-anomalie.md` §NET-005 e nel
checklist di `firewall-zyxel-usg-flex-500.md`, non richiesto per chiudere
M13a. Nessuna scrittura reale ancora inviata a nessuno switch.

**Addendum, revisione del piano firewall prima di guidare l'utente**:
l'utente ha chiesto come fa la VLAN 40 ad attraversare la dorsale senza
modifiche esplicite (risposto: `allowedVLAN: "all"` non filtra per numero
di VLAN, vedi addendum sopra) e di rivedere `firewall-zyxel-usg-flex-500.md`
§Fase A prima di procedere. Rilettura ha trovato un'imprecisione: la nota
originaria diceva "porta fisica nessuna... stesso principio della VLAN 201
DMZ", ma la DMZ usa una porta fisica dedicata (P7), mentre qui tutte le 8
porte del firewall sono gia' assegnate. Verificato sui dati reali che la
porta 33 del 54HP (dove termina la P4 del firewall, collegamento lan1) ha
anch'essa `allowedVLAN: "all"`: vlan40 va quindi legata come interfaccia
taggata sullo stesso port-group lan1 (P4/P5/P6), non a una porta libera
inesistente. Corretta la sezione "Interfaccia VLAN 40" di conseguenza.
Nessuna modifica reale ancora eseguita ne' su switch ne' su firewall.

**Addendum, guida live sul firewall**: creata (via GUI, dry-check con
l'utente prima di ogni click) l'interfaccia `vlan40` sul firewall USG FLEX
500 — Interface Type internal, Base Port lan1 (corretto da un tentativo
iniziale su "sfp"), Interface Name `vlan40` (il campo non accetta il solo
numero, richiede il formato `vlanX`), IP 10.61.40.1/255.255.255.0. Non
ancora confermato con "Apply" sulla pagina lista. Durante la spiegazione
del perche' lan1/lan1:1/lan1:2 usano `/19`, l'utente ha corretto una mia
imprecisione ("storia pregressa") e fatto un'osservazione tecnica esatta:
i tre alias (.10 PC, .20 server, .30 stampanti) cadono tutti nello stesso
blocco `/19` (10.61.0.0-31.255), quindi sono la stessa rete flat, non tre
reti isolate — coerente con nessun tag VLAN su `lan1`. Registrata come
nuovo gap **NET-009** (`GAP-TBC.md` #114) e nuovo micro-step **M22**
(roadmap.md, "Da pianificare", dipendenza M13a) per una futura
segmentazione reale PC/server/stampanti, distinta e successiva a M13a.

**Addendum, side-note tracciata su richiesta esplicita**: durante la stessa
sessione l'utente ha risolto un problema separato (due unita' di rete
`net use` su NAS-INTRA2 confermate OK ma invisibili in Explorer — UAC
token splitting, PowerShell elevata vs Explorer non elevato) e ha chiesto
di tracciarlo comunque come "parentesi" sulle informazioni di rete. Aggiunta
nuova voce **NAS-002** in `runbook-anomalie.md`, causa e fix documentati,
nessun placeholder nuovo necessario (Persona-A/B e 10.61.20.177 gia' in
mappa). Non impatta M13a.

**Addendum, avanzamento Fase A sul firewall**: creata zona `WIFI_STAFF`
(Object > Zone > Add) sul firewall USG FLEX 500, al momento vuota (0
membri) — screenshot confermano che l'interfaccia `vlan40` e' invece
ancora membro della zona di default `LAN1` (`LAN1 | lan1,vlan40`).
Prossimo passo: riaprire l'Edit di `vlan40` e cambiare Zone da LAN1 a
WIFI_STAFF. Risolto anche un dubbio sui pulsanti Activate/Inactivate della
lista Interface: la lettura iniziale era sbagliata, il checkbox "Enable
Interface" nel dialogo di modifica e' la fonte di verita' reale per lo
stato acceso/spento, non quei due pulsanti (il cui significato esatto
resta non verificato con certezza).

**Addendum, zona confermata**: screenshot successivi confermano che
`vlan40` e' stato spostato correttamente in `WIFI_STAFF` (unico membro) e
che `LAN1` e' tornata a contenere solo `lan1`. Interfaccia + zona lato
firewall completate. Prossimo passo: security policy (due regole servono,
non solo il deny verso LAN1 gia' pianificato — anche un allow esplicito
WIFI_STAFF->WAN, altrimenti la nuova zona non avrebbe accesso a Internet:
nessuna regola esistente la copre essendo nata oggi).

**Addendum, pulizia regole disattivate (16/07/2026)**: durante la stessa
sessione, in parallelo a M13a, l'utente ha esaminato la lista security
policy reale (34 regole) e rimosso 9 regole complessive: le tre gia'
documentate come "Disallineamento" (`DOMV_WEB`, `DEMO_SERVER_WEB`,
`EGETRAD_WEB`, virtual server deactivate, FW-003/SEC-004), altre quattro
nella stessa condizione (`EGETRAD_WEB_TEST`, `NAS_HERO_SUPPORT`,
`NAS_HERO_SUPPORT2`, `NAS_FTP_WEB` — coerenti con l'elenco NAT
"Deactivate" gia' in `firewall-zyxel-usg-flex-500.md`), e due regole di
egress nominative per due postazioni specifiche (`LAN1_Outgoing_FEDERICA`,
`LAN1_Outgoing_ulrike`), verificate dall'utente come non piu' necessarie.
Applicate con Apply sul dispositivo reale. Aggiornati: `firewall-zyxel-usg-flex-500.md`
(Disallineamento marcato risolto, conteggio regole 34->25), `GAP-TBC.md`
(FW-003 risolto, SEC-004 parziale — resta aperta solo la VM Egetrad
stessa), `_notes/.anonymization-map.md` (nuovo Persona-AK per "Federica",
nome noto solo dalla regola rimossa). Non impatta le due regole di Fase A
ancora da creare (`WIFI_STAFF_to_LAN1_deny`, `WIFI_STAFF_Outgoing`).

**Addendum, obiettivo ISO27001 e direttiva permanente (16/07/2026)**:
l'utente ha dichiarato l'obiettivo di certificazione ISO27001 entro marzo
2027 (registrato in `roadmap.md` Fase 5) e ha fissato una direttiva
permanente sui cinque livelli di tracciamento (didattico, deep-dive
tecnico, comunicazione stakeholder, cronologia, ISO27001), scritta in
`current-work.md` in apertura del file perche' resti visibile a inizio
sessione. Segnalata anche una nuova implicazione concreta di NET-009: le
stampanti multifunzione con scan-to-folder possono scrivere direttamente
nelle cartelle condivise di un PC Windows 11 invece che su un NAS
presidiato — aggiunta a `GAP-TBC.md` (NET-009) e a `design-and-security.md`
§A.8.22 come fronte di sanificazione dei flussi dato distinto dalla sola
segmentazione VLAN.

**Addendum, M13a lato firewall completato (16/07/2026)**: creata anche la
seconda security policy `WIFI_STAFF_Outgoing`; scoperto (screenshot) che
l'ordine tra le due regole nuove era invertito rispetto al piano — l'allow
generico avrebbe intercettato anche il traffico verso LAN1 prima del deny,
stesso principio dell'anomalia FW-001 gia' risolta nel progetto (motore
first-match). Corretto con "Move" (posizione 1) prima di Apply. Confermato
via screenshot: Apply riuscito, pulsanti disabilitati, ordine finale corretto
(deny priorita' 1, allow priorita' 2). Aggiornati `firewall-zyxel-usg-flex-500.md`
(checklist passi 1-2 marcati fatti, conteggio regole 25->27, struttura
generale con le due nuove righe) e `roadmap.md` (M13a: lato firewall
completato, resta solo lo script sulle porte AP).

**Addendum, DHCP mancante scoperto e corretto (16/07/2026)**: prima di
lanciare lo script sulle porte AP, controllato che l'interfaccia `vlan40`
avesse un pool DHCP reale — non l'aveva (`DHCP: None`), sarebbe stato un
blackout silenzioso per i primi client Wi-Fi spostati. Configurato via GUI
(Show Advanced Settings, sezione non ovvia): DHCP Server, pool
10.61.40.10-209 (200 indirizzi), DNS 8.8.8.8/1.1.1.1, Default Router auto,
lease 2 giorni (coerente con LAN1_POOL). Aggiornato
`firewall-zyxel-usg-flex-500.md` con i valori reali applicati. M13a lato
firewall ora davvero completo (interfaccia + zona + DHCP + 2 security
policy in ordine corretto).

**Addendum, dry-run reale e parametro -ApName**: eseguito
`Set-NebulaWifiVlan.ps1 -Only Access` con la chiave API reale — piano
confermato corretto per le tre porte (PianoTerra 30HP/1, PianoPrimo
54HP/41, PianoSecondo 54HP/45, tutte CurrentVid=1 -> TargetVid=40).
Aggiunto un nuovo parametro `-ApName` (ValidateSet sui tre nomi noti) per
applicare un AP alla volta invece di tutti e tre insieme in un solo
`-Apply`, coerente con la checklist "una alla volta con verifica" — prima
non esisteva questa granularita'. Sintassi validata. Non ancora eseguito
nessun `-Apply` reale sulle porte AP.

**Addendum, primo tentativo -Apply fallito e corretto (16/07/2026)**:
`Set-NebulaWifiVlan.ps1 -Only Access -ApName PianoTerra -Apply` ha provato
a scrivere la porta 1 del 30HP ma l'API ha risposto `422
INVALID_ALLOWED_VLAN` — rifiuto pulito, nessuna scrittura parziale,
confermato dal log `output/nebula-apply-log-fase-a.json`. Causa: il target
`allowedVLAN: []` (lista vuota, tentativo di access strict) non e' un
valore che l'API accetta. Corretto lo script per usare `[VlanId]` (la sola
VLAN nativa) come nuovo target — meno stretto dell'obiettivo originale ma
comunque piu' stretto di "all". Documentato in ADR-010 come conferma che
il design dry-run+conferma+one-AP-at-a-time ha contenuto l'errore a una
singola porta invece di propagarlo a tutte e tre. Prossimo passo: ripetere
il dry-run e poi l'apply su PianoTerra con il valore corretto.

**Addendum, PianoTerra applicato con successo**: `-Only Access -ApName
PianoTerra -Apply` con `allowedVLAN: [40]` completato senza errori API
("Tutte le scritture completate senza errori API"). Aggiunta subito dopo
una verifica automatica post-scrittura allo script (rilettura immediata
della porta via GET, confronto portVid/allowedVLAN col target atteso,
campo `Verified` nel log e nell'output console) — non ci si fida piu' di
un solo "200 OK" dato l'errore 422 appena visto sullo stesso endpoint.
Resta da: verificare la connettivita' fisica reale dell'AP PianoTerra
(IP nella 10.61.40.x, raggiungibilita'), poi ripetere per PianoPrimo e
PianoSecondo uno alla volta con lo script aggiornato.

**Addendum, verifica PianoTerra (16/07/2026)**: primo tentativo di
verifica dal telefono dell'utente, fisicamente al piano terra, ha mostrato
un IP ancora in classe .10 — diagnosticato dai dettagli Wi-Fi Android (BSSID
connesso, lista AP vicini con RSSI) che il telefono aveva agganciato il
BSSID di un altro AP (famiglia MAC di PianoPrimo/PianoSecondo, non
PianoTerra), non un problema della modifica. Verifica definitiva fatta
lato switch: rieseguito `Get-NebulaSnapshot.ps1`, ispezionata la porta 1
del 30HP — `l2-mac-table` mostra il MAC di PianoTerra
(AA:BB:CC:00:00:27) taggato VLAN 40, `port-settings` conferma
`portVid: 40, allowedVLAN: ["40"]`, PoE ancora attivo. PianoTerra
verificato e chiuso. Prossimo: PianoPrimo (`-ApName PianoPrimo -Apply`).

**Addendum, PianoPrimo applicato (16/07/2026)**: `-ApName PianoPrimo -Apply`
completato, la nuova verifica automatica post-scrittura integrata nello
script ha confermato inline "portVid ora 40, allowedVLAN 40" senza bisogno
di un controllo manuale separato via snapshot — l'enhancement fatto dopo
l'errore 422 di PianoTerra funziona come previsto. Resta solo
PianoSecondo.

## 2026-07-16 — Incidente Wi-Fi: le tre porte AP ritaggate interrompono l'SSID, rollback e chiusura provvisoria di M13a

Commit: PENDING (da fare manualmente)
File toccati: `runbook-anomalie.md` (nuova sezione "Incidente 16/07/2026"
sotto NET-005, stato riportato ad APERTO), `GAP-TBC.md` (NET-005
aggiornato, non piu' RISOLTO), `roadmap.md` (M13a da "Fatto" a "Tentato e
ripristinato"), `design-and-security.md` (nota A.8.22 sull'incidente e la
lezione di change management), `firewall-zyxel-usg-flex-500.md` (checklist
passo 3 aggiornato).

Motivo: dopo aver applicato PianoPrimo e PianoSecondo (oltre a PianoTerra
gia' verificato), l'utente ha segnalato che il Wi-Fi non funzionava piu' —
il telefono non si connetteva. Diagnosticato in tempo reale: la rete
"intrawelt" era del tutto sparita dalla scansione (non solo irraggiungibile),
confermato con due dispositivi diversi (smartphone + portatile con scheda
di rete diversa), escludendo cache o problema del singolo device. Un
tentativo di aggiunta manuale della rete (SSID+password corretti, hidden
network) non ha comunque prodotto connessione. La diagnostica lato switch
(rieseguito `Get-NebulaSnapshot.ps1`) mostrava tutto tecnicamente corretto
dal lato switch: link fisici up, PoE attivo, `portVid`/`allowedVLAN`
esattamente come previsto, perfino una voce nella tabella MAC L2 che
confermava che per una finestra breve un client si era davvero connesso
in VLAN 40. Nessuna anomalia visibile lato switch: la spiegazione piu'
plausibile e' che i tre AP stessi abbiano smesso di trasmettere il
segnale, non lo switch.

Deciso di dare priorita' al ripristino del servizio piuttosto che
continuare a diagnosticare con la rete giu': rollback immediato con lo
stesso script (`-Only Access -VlanId 1 -Apply`, tutte e tre le porte
insieme per velocita'), verificato dallo script e confermato empiricamente
(screenshot del telefono riconnesso, IP tornato nella vecchia classe .10).
Tempo totale dell'interruzione: circa 15 minuti tra la prima segnalazione
e la conferma del ripristino.

Causa non determinata con certezza (i tre AP restano inaccessibili, nessun
modo di leggere log o stato interno): l'assunzione teorica alla base di
Fase A — "il tagging VLAN e' trasparente per l'AP, che non deve sapere
nulla della VLAN sottostante" — non ha retto per questo hardware Ubiquiti
del 2011-2013, per una ragione ipotizzabile (IP di management statico
legato alla vecchia subnet, necessita' di riavvio per rinegoziare,
comportamento di firmware non documentato) ma non verificabile. La
configurazione lato firewall (interfaccia vlan40, zona WIFI_STAFF, DHCP,
le due security policy, la pulizia delle 9 regole disattivate) NON e'
stata toccata dal rollback: resta applicata e valida per un nuovo
tentativo o per la Fase B. M13a torna "tentato, non chiuso" nella
roadmap; rafforza ulteriormente (con una prova pratica, non solo teorica)
la decisione gia' presa di puntare su Fase B (sostituzione hardware)
invece che tentare di far convivere questi AP con altre modifiche di
rete. Prossimi passi possibili, non ancora decisi: ripetere con presenza
fisica a un AP alla volta e finestra di osservazione piu' lunga, oppure
esplorare `Layer 2 Isolation` (visto nel menu Network del firewall, mai
aperto) come meccanismo di isolamento che non richieda di toccare il PVID
della porta AP.

**Addendum, decisione di retry mirato**: l'utente ha chiesto di procedere
a risolvere per davvero. Osservato che il pattern dell'incidente (SSID
funzionante subito dopo il cambio VLAN, sparito solo dopo qualche minuto)
punta piu' verso uno stato residuo lato AP (es. lease DHCP vecchio non
scaduto) che verso un rifiuto immediato del cambio. Proposto un test
mirato: un solo AP (PianoTerra) + power-cycle PoE remoto subito dopo il
cambio VLAN, osservazione prolungata prima di giudicare. Utente ha
confermato questa opzione (non presenza fisica, non Layer 2 Isolation
per ora). Aggiunto parametro `-PowerCycle` allo script (spegne/riaccende
`pseEnabled` della porta con 10s di pausa, poi rilegge lo stato),
sintassi validata, non ancora eseguito.

**Addendum, secondo problema e nuovo script di isolamento test**: il
retry su PianoTerra ha risposto 200 OK ma la rilettura immediata mostrava
ancora la VLAN vecchia — non un errore, un ritardo di propagazione
cloud->switch (coerente con NEB-001). Corretto lo script con retry a
backoff (3/5/8/12s) prima di dichiarare fallimento; il power-cycle non e'
scattato (gated su verifica riuscita), nessun impatto su PianoTerra da
questo tentativo. L'utente ha anche notato che anche stando al piano
terra il telefono aggancia l'AP di sopra, rendendo ambiguo un test col
solo smartphone: creato un nuovo script dedicato,
`scripts/Set-ApTestIsolation.ps1` (stessa disciplina dry-run+conferma),
che spegne/riaccende il PoE degli AP noti via Nebula per lasciare acceso
un solo AP durante il test (`-Keep <nome>`) e riaccendere tutti a fine
test (`-Restore`). Utente ha confermato di procedere spegnendo
temporaneamente PianoPrimo e PianoSecondo per isolare il test su
PianoTerra.

**Addendum, scoperta di inaffidabilita' Nebula-switch (16/07/2026, stesso
giorno)**: il retry su PianoTerra ha avuto successo (verificato dopo il
fix del backoff), il power-cycle e' partito regolarmente. Pochi minuti
dopo pero', senza alcuna azione esterna, la porta e' tornata da sola a
`portVid: 1`. Nello stesso controllo, la tabella MAC ha rivelato che
PianoPrimo e PianoSecondo — con `pseEnabled: false` confermato dalla
rilettura API — erano in realta' ancora perfettamente funzionanti (il
telefono, dopo un "forget"+reconnect da zero, si e' ricollegato proprio a
PianoPrimo). Conclusione: non e' (solo) un problema degli AP, e' la
sincronizzazione Nebula<->switch stessa a non essere affidabile — le
scritture possono non restare stabili nel tempo, e uno spegnimento PoE
confermato dall'API puo' non tradursi in un effetto fisico reale.
Correlato a NEB-001 (gia' noto: intermittenza del canale di gestione),
esteso in `GAP-TBC.md` con questa evidenza aggiuntiva. Ripristinato il
PoE di entrambi gli AP per sicurezza. Aggiornati `runbook-anomalie.md`
§NET-005 (nuova sottosezione "Secondo tentativo"), `roadmap.md` (M13a).
Decisione su come procedere lasciata in sospeso con l'utente: presenza
fisica, approfondire NEB-001, o priorita' a M13b. **Scelto: approfondire
NEB-001 prima di riprovare.** Creato `scripts/Get-NebulaConnectivityHistory.ps1`
(sola lettura, stesso perimetro di sicurezza di Get-NebulaSnapshot.ps1),
che interroga due endpoint Nebula OpenAPI non ancora usati nel progetto
(verificati via fetch della documentazione ufficiale, non ancora testati
con una chiamata reale): `connectivity` (storico online/offline per
periodo) e `event-logs` (log eventi tra due timestamp) per entrambi gli
switch — per correlare le anomalie di oggi (scrittura auto-revertita,
PoE non effettivo) con eventuali disconnessioni dal canale cloud.
Sintassi validata, non ancora eseguito.

**Addendum, esecuzione ed esito**: eseguito con successo. Nessuno dei due
switch risulta mai offline nelle ultime 24h (esclude disconnessione cloud
durante i test). Il 30HP (PianoTerra) mostra nel log eventi esattamente le
nostre azioni (PoE off/on del power-cycle, poi due brevi flap plausibilmente
il boot dell'AP) senza alcuna anomalia. Il 54HP (PianoPrimo/PianoSecondo)
non mostra NESSUN evento per le porte 41/45 nonostante le scritture di
oggi, ma mostra migliaia di link-flap non documentati sulla porta 46
(su/giu' ogni 14-16s, con ricalcolo STP a ogni flap; verificato
`OFFLINE` al momento del controllo) — nuovo gap **NET-010**
(`GAP-TBC.md` #115). Interpretazione: il problema e' plausibilmente
localizzato al 54HP (porta 46 che degrada l'affidabilita' delle altre
operazioni sullo stesso switch), non una sincronizzazione cloud generica
inaffidabile su tutta l'infrastruttura Nebula. Non spiega la reversione
VLAN vista su PianoTerra (il log eventi non sembra tracciare i cambi di
PVID come categoria) — resta ipotesi aperta, piu' plausibile come lettura
cache-stale che come reversione reale. Aggiornati `runbook-anomalie.md`
§NET-005 (nuova sottosezione "Approfondimento NEB-001") e `roadmap.md`
(M13a). Prossimo passo consigliato: diagnosticare la porta 46 prima di
altre scritture sul 54HP; PianoTerra (30HP, pulito) resta un candidato
ragionevole per un nuovo tentativo mirato.

**Addendum, identificazione porta 46**: l'utente ha identificato il
dispositivo — il PC che ospita Ollama (10.61.20.58, GPU dedicata),
confermato raggiungibile via HTTP porta 11500 ("Ollama is running")
nonostante il flap. E' lo stesso host ambiguo gia' segnalato in
SRV-002/GAP-TBC #107 (finora non chiaro se fisico o VM): questo conferma
la sua natura di host fisico e la sua porta di attacco reale. Aggiornati
GAP-TBC.md (#115 NET-010 e #107 SRV-002, cross-referenziati) e
runbook-anomalie.md §NET-005. Causa del flap ancora da diagnosticare
sull'host stesso (risparmio energetico scheda di rete/EEE, driver, cavo).

## 2026-07-15 — AP-001 chiuso su accesso, decisione architetturale in due fasi per la Wi-Fi (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/runbook-anomalie.md (AP-001 riscritta con la
correzione vendor, la conferma "nessuna dashboard mai esistita", e il
piano in due fasi), docs/infrastructure-timeline/GAP-TBC.md (NET-005/AP-001
aggiornati), .claude/context/roadmap.md (M13 diviso in M13a/M13b),
.claude/context/current-work.md (nota aggiornata + promemoria sul taglio
di racconto richiesto per la stesura finale).
Motivo: l'utente ha tentato l'accesso SSH ai tre AP legacy (superata la
negoziazione crittografica con host key/MAC obsoleti, ma credenziali
`ubnt`/`ubnt` non valide), niente trovato nel vault credenziali interno,
nessun controller UniFi rintracciato. Un agente di ricerca lanciato per
cercare riferimenti storici a un controller UniFi e' fallito per limite
di sessione (nessun risultato). L'utente ha poi trovato da solo il
referto Nessus originale della VA Onova (`Intrawelt_remediation_checklist_2026-05-15_15-00.html`)
e riportato dati precisi: corregge la classificazione vendor di
EsternoIrrigazione (e' Ubiquiti come gli altri tre, "gemello hardware",
non un vendor diverso come ipotizzato prima), conferma le tre
corrispondenze IP del 06/11/2025, segnala che PianoPrimo non compare in
quello scan (assente o installato dopo, [TBC]), e conferma che l'unica
porta TCP mai trovata aperta su questi host e' la 22 (SSH) — quindi la
domanda "si puo' entrare dalla dashboard web" ha risposta definitiva: no,
non e' mai esistita, non e' un problema di percorso/porta sbagliata.
Reset di fabbrica valutato e rimandato (disruptivo per gli utenti Wi-Fi
in produzione ora). Su questa base, ragionato con l'utente sulla
strategia: la sua proposta (segmentazione a livello switch/firewall senza
toccare gli AP, piu' un AP Zyxel nuovo dedicato al guest) e' stata
raffinata in una decisione esplicita di NON affiancare un quarto AP ai
tre EOL ma pianificarne la sostituzione completa (Fase B), mantenendo
pero' la segmentazione (Fase A) come intervento immediato e indipendente
dall'hardware AP. Motivazione: se comunque serve comprare hardware Zyxel
per il guest, non ha senso lasciare in produzione hardware EOL dal 2018
non gestibile ne' aggiornabile (rilevante anche per il gap ISO 27001
A.8.8 gia' aperto). Annotato il requisito esplicito dell'utente per la
stesura finale: racconto sia tecnico approfondito sia didattico, con
valore CV, oltre alla timeline.

## 2026-07-14 — AP-001 risolto: tre access point Ubiquiti localizzati per porta switch (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/runbook-anomalie.md (AP-001: tabella con le tre
localizzazioni), docs/infrastructure-timeline/GAP-TBC.md (NET-005 aggiornato),
`_notes/.anonymization-map.md` (5 nuovi MAC: switch XGS2220-30HP, due
USG20-VPN, due AP Ubiquiti + un terzo).
Motivo: primo run reale di `Get-NebulaSnapshot.ps1` con chiave API valida
(generata dall'utente dopo aver trovato il percorso corretto in Nebula).
Script eseguito senza errori bloccanti (un solo endpoint best-effort,
sw-clients v2, ha risposto 404 come previsto per schema non confermato).
Dalla tabella MAC L2 di entrambi gli switch, cercato il prefisso MAC
Ubiquiti (74:83:c2) gia' noto dalla VA di novembre 2025: trovati esattamente
tre dispositivi, coerente col numero atteso. Localizzazione confermata
incrociando due segnali indipendenti (non solo la velocita' di link):
l'elenco porte "trunk" di ciascuno switch dal campo port-settings, e la
presenza/assenza della stessa voce sul dorsale dell'altro switch. Risultato:
2 AP fisicamente su XGS2220-54HP (Piano 2, porte 41 e 45), 1 su
XGS2220-30HP (Piano Terra, porta 1). Non ancora tradotto in etichetta
patch panel (0-7-1/0-9-1/1-8-1/2-5-1/2-7-1): Nebula non riporta nomi/
descrizioni per porta, serve una verifica fisica del cablaggio per
l'ultimo miglio. Coerente con l'aspettativa architetturale (2 ubicazioni
note lato Piano 2, 3 lato Piano Terra/tetto/Piano 1: delle tre lato
Piano Terra solo una risulta oggi viva). Corretto anche, nello stesso
lavoro di scoperta della chiave API, l'inventario USG20-VPN (vedi voce
precedente) e il percorso di navigazione Nebula in ADR-009.

## 2026-07-14 — Trovato il percorso reale della chiave API Nebula; corretto inventario USG20-VPN (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: scripts/Get-NebulaSnapshot.ps1 (commento -ApiKey corretto),
docs/runbook-anomalie.md (percorso corretto), .claude/memory/decisions.md
(ADR-009 esteso col percorso reale), docs/infrastructure-timeline/2025-q3-q4.md
(corretta la nota sui due USG20-VPN dismessi), `_notes/.anonymization-map.md`
(3 nuovi MAC: switch XGS2220-30HP, due USG20-VPN).
Motivo: dopo un'ora di navigazione a tentativi nell'interfaccia Nebula
(myZyxel account, avatar dropdown, ingranaggio, Administrators,
Organization-wide manage per intero, Cloud authentication, ricerca
interna — tutti vicoli ciechi), trovato il percorso reale: icona "..."
nella barra in alto (mai provata prima) > "My devices & services" >
scheda "NCC OpenAPI Key" > Generate. Non coincide con quanto scritto
nella documentazione ufficiale/community Zyxel ("User's Device and
Service" o "My Devices and Services" come voce di menu diretta): quella
dicitura descrive il nome della PAGINA, non del punto di accesso nel
menu, che invece sta dietro l'icona ellipsis. Corretto il commento dello
script e il runbook di conseguenza. La stessa pagina "My devices &
services" mostra anche l'inventario completo dispositivi dell'account:
scoperto che i due USG20-VPN, documentati come "non più in lista
myZyxel" (quindi presunti rimossi), risultano invece ancora presenti
nell'inventario Nebula — corretta la nota in 2025-q3-q4.md chiarendo che
le due liste (Marketplace licenze vs Nebula device inventory) hanno
perimetri diversi. Aggiunto anche il MAC reale dello switch XGS2220-30HP,
non censito finora.

## 2026-07-14 — Nuovo script Get-NebulaSnapshot.ps1 per l'API REST Zyxel Nebula (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: scripts/Get-NebulaSnapshot.ps1 (nuovo), .claude/context/STACK.md
(voce script + sezione dedicata), .claude/memory/decisions.md (ADR-009),
docs/runbook-anomalie.md (AP-001: riferimento allo script come strumento
disponibile).
Motivo: l'utente ha chiesto di scriptare/automatizzare anche
l'interrogazione di Nebula, oltre a Proxmox, per risolvere in modo
sistematico l'identificazione degli AP (AP-001/NET-005). Prima di
scrivere il codice, verificati via WebSearch/WebFetch gli endpoint REST
reali e il loro schema di risposta sulla documentazione ufficiale
(zyxelnetworks.github.io/NebulaOpenAPI), per non inventare path o campi:
confermati organizations, sites, sites/devices (con devId, mac, sn, model,
type: AP/SW/GW/FIREWALL/WWAN/SCR/GWH/ACCY), ports-status, port-settings,
l2-mac-table (macAddress+vlan+portNum per porta — esattamente il dato
che serve per localizzare gli AP per porta indipendentemente dalla marca).
Script scritto sullo stesso pattern di Get-ProxmoxSnapshot.ps1 (nessuna
dipendenza esterna, output JSON+Markdown in output/, mai committato),
chiave API risolta da parametro/variabile d'ambiente NEBULA_API_KEY/prompt
SecureString, mai su disco. Sintassi validata con il parser PowerShell
nativo (nessun test contro un'organizzazione Nebula reale, non disponibile
in sessione). Documentata la decisione come ADR-009. Nota importante
gestita separatamente: l'utente ha chiesto anche di aggiornare
E:\windows-status e E:\my-cv — bloccato dalla regola "Confine con
E:\projects" gia' scritta in CLAUDE.md in questa sessione (nessuna
scrittura fuori da D:\network-design); confermato con l'utente di tenere
tutto tracciato solo qui, rimandando quei due repository a sessioni
dedicate separate che leggeranno da qui per conto proprio.

## 2026-07-14 — Scansione live VLAN Guest: popolazione cambiata dalla VA nov 2025 (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/runbook-anomalie.md (AP-001 aggiornata con la nota di
scansione e procedura fix rivista).
Motivo: l'utente ha condiviso uno screenshot di Advanced IP Scanner su
tutta la classe Guest (10.61.90.1-254): nessuno dei dispositivi
noti dalla VA di novembre 2025 risponde piu' agli stessi indirizzi (ne'
i tre presunti AP, ne' switch mgmt/UPS/MyHome/Bticino). La classe oggi
mostra dispositivi diversi (HPE, Xiaomi, MSI, Pegatron, ASUS). Non
verificato se sia una risoluzione reale o solo dispositivi spenti/IP
cambiati: segnalato esplicitamente come da chiarire, senza dare per
risolto nulla. Prossimo passo suggerito: controllare via Nebula i
dettagli delle porte switch a cui gli AP sono fisicamente collegati
(mappatura nota) invece di cercarli per IP, dato che lo switch mostra
MAC/stato link per porta indipendentemente dalla marca del dispositivo
collegato.

## 2026-07-14 — Smentita "AP gestiti Nebula": nessun AP nell'organizzazione Zyxel (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/vendor-management.md (rimossa l'affermazione errata
"AP gestiti Nebula" dalla scheda Zyxel), docs/runbook-anomalie.md
(AP-001 riscritta con la conferma e una procedura fix aggiornata).
Motivo: l'utente ha verificato il portale Nebula gia' usato per i due
switch e confermato che nessun access point vi compare come dispositivo
gestito — smentisce l'unica fonte che affermava "AP gestiti Nebula" e
rafforza l'ipotesi, gia' indicata dalla VA di novembre 2025 (MAC vendor
Ubiquiti, firmware Debian 7 EOL dal 2018), che si tratti di hardware non
Zyxel e non centralmente gestito. Riscritta la procedura fix di AP-001:
accesso diretto ai tre IP noti (web e SSH) per identificare modello reale
e stato di adozione, ricerca di un eventuale controller UniFi mai
documentato, pianificazione sostituzione se il modello risulta fuori
produzione e senza controller. Segnalato che questo blocca anche NET-005/
M13 (rete ospiti): senza gestione centrale nota degli AP non si puo'
creare in modo affidabile un secondo SSID taggato su VLAN.

## 2026-07-14 — NET-005 confermato live: PC esterno su Wi-Fi ottiene IP di management (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/runbook-anomalie.md (nuova sezione NET-005 con evidenza
live e procedura fix), docs/infrastructure-timeline/GAP-TBC.md (nota di
conferma su NET-005), `_notes/.anonymization-map.md` (nuovo IP
10.61.10.247 e MAC AA:BB:CC:00:00:21).
Motivo: l'utente ha condiviso l'output di `ipconfig` di un PC esterno non
censito in NinjaOne, connesso alla Wi-Fi "intrawelt": ha ottenuto in DHCP
un indirizzo (10.61.10.247) nella stessa subnet /19
della VLAN 10 di management, con lo stesso gateway — conferma diretta e
datata del gap NET-005 gia' tracciato solo su base documentale. Aggiunta
una sezione runbook completa (stesso formato di FW-002/UPS-001/AP-001)
con la sequenza di fix consigliata: identificare il modello reale degli AP
controllando se compaiono nell'organizzazione Nebula gia' usata per gli
switch (prima di tutto), eseguire M12 per liberare la VLAN 90
dall'infrastruttura che oggi la occupa per errore, decidere la VLAN di
destinazione della Wi-Fi aziendale, configurare un secondo SSID ospiti
taggato sulla VLAN 90 ripulita con isolamento client-to-client.

## 2026-07-13 — VM207 "websiteAnalyst" censita via MCP Proxmox; SSH bidirezionale predisposto (sessione parallela)

Commit: PENDING (da fare manualmente)
File toccati: `.claude/context/design-and-security.md` (tabella VM: riga VM207, bridge
vmbr3), `.claude/context/dev-testing.md` (conteggio VM QEMU aggiornato a 9, rimossa
menzione generica "+ una"), `.claude/context/diagrams/network-topology.mmd` (nodo V207,
collegamenti B3/SLVM; corretto anche un riferimento orfano preesistente a "V802" mai
definito nel diagramma), `_notes/.anonymization-map.md` (voce 192.168.20.24 →
10.61.20.24, MAC net0 non anonimizzato perche' non riportato in alcun file tracciato).
Motivo: l'utente ha segnalato la nuova VM207, interrogata dal vivo via il server MCP
`proxmox` (`list_vms`/`get_instance_config` sul nodo `pve`) invece di fidarsi solo del
nome dato dall'utente: 6 vCPU, 16 GB RAM, dischi 32G+96G su storage SERVIZI, bridge vmbr3.
Predisposta anche la connettivita', fuori dal perimetro documentale di questo repository
ma degna di nota per chi riprende il progetto: alias SSH `vm207` da questa macchina verso
la VM (chiave dedicata senza passphrase) e, sulla VM stessa, alias `github-corp` verso
GitHub per il repository applicativo separato `asopranzi-intrawelt/website-analyst`
(bootstrap del sistema di contesto portabile fatto in quel repository, non in
`network-design`). Segnalato ma non risolto un file `passworg_gmail_intra` trovato in
chiaro sul desktop della VM, fuori dal perimetro di questo progetto.

## 2026-07-13 — M2 parziale (iLO recuperato via hponcfg), pianificato intervento Wi-Fi/Guest (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: .claude/context/roadmap.md (M2 parziale, M13 ampliato),
docs/infrastructure-timeline/GAP-TBC.md (nota su NET-005), .claude/context/current-work.md
(nuova voce "Domande aperte" per l'intervento Wi-Fi/Guest pianificato).
Motivo: l'utente ha recuperato l'accesso iLO5 (password root perduta,
reset via hponcfg dal sistema operativo senza riavviare il server) e
configurato una connessione SSH all'iLO da questa macchina — tracciato
come M2 parziale (restano console seriale e conferma 802.1Q). VM207
"websiteAnalyst" aggiunta a design-and-security.md da un'altra sessione
dell'utente in parallelo (nessuna azione richiesta, solo presa visione).
L'utente ha poi descritto un nuovo intervento pianificato (non ancora
eseguito): verificare che la Wi-Fi "intrawelt" sia isolata dalla LAN
(NET-005, oggi non lo e') e predisporre una vera rete Guest per i
visitatori, dato che la VLAN 90 "Guest" esistente sul firewall e' in
realta' una raccolta di dispositivi IoT/management finiti li' per errore,
non una rete ospiti funzionante. Ampliato M13 della roadmap con questa
doppia natura del task e aggiunta nota di chiarimento a GAP-TBC #72.

## 2026-07-13 — Timeline SVG: redesign grafico e accordion di dettaglio (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: scripts/Build-TimelineSvg.ps1 (riscritto), docs/infrastructure-timeline/timeline.svg
(rigenerato), CLAUDE.md (§Script timeline SVG aggiornata).
Motivo: su richiesta dell'utente, prima presentata una proposta di resa
grafica come artifact HTML (palette blueprint/petrolio, accoppiata
monospazio/serif, filtri categoria) per discuterne insieme; confermata la
direzione ("assolutamente"), l'utente ha poi chiesto di implementarla in
locale nello script di produzione, mantenendo l'output sempre e solo
`.svg` (mai artifact), aggiungendo che ogni riga deve essere un accordion
che espone il paragrafo di dettaglio ricostruito dai .docx ingeriti.
Riscritto lo script: estrazione del corpo Markdown tra un'intestazione
"## " e la successiva (paragrafi separati da righe vuote, sottointestazioni
"### " promosse a paragrafo in grassetto, righe di tabella/code-fence/hr
scartate, troncamento meccanico oltre 2200 caratteri), nuova palette
neutra (fondo/inchiostro/accento petrolio) e accoppiata tipografica
monospazio (date, tag, eyebrow) + serif (titoli e corpo dettaglio) al
posto del Segoe UI generico precedente, script SVG nativo incorporato
(CDATA) che gestisce apertura/chiusura pannello via foreignObject,
misurando l'altezza reale del testo con getBoundingClientRect scalato per
getScreenCTM (robusto a ridimensionamenti della pagina ospite) e
ritraslando tutte le righe sottostanti. Verificato: script rieseguito
senza errori (130 eventi, stesso output di partenza a comprimibile
chiuso), XML validato come ben formato con xml.dom.minidom, ispezionati a
mano due pannelli (uno semplice, uno con tabella markdown nel sorgente) per
confermare l'estrazione corretta. **Caveat noto e documentato in
CLAUDE.md**: l'accordion funziona quando l'SVG e' navigato direttamente o
incluso via `<object>`/`<iframe>`/inline; se la pagina statica esterna
dell'utente lo include con un tag `<img>`, gli script SVG sono disabilitati
dal browser per quel contesto e le righe non si espandono (limite del
browser, non risolvibile lato repository). L'utente deve verificare a
occhio aprendo il file .svg direttamente, perche' l'agente non ha modo di
testare visivamente il click.

## 2026-07-11 — Fase 2 chiusa: inventario NAS fleet e gap analysis ISO27001 (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/vendor-management.md (§QNAP – NAS riscritta con inventario
sistematico RAID/capacita'/backup per i 5 dispositivi), .claude/context/design-and-security.md
(gap analysis Annex A ampliata da 5 a 10 controlli), .claude/context/roadmap.md
(Fase 1bis e Fase 2 marcate complete, Fase 3 marcata "riprendibile").
Motivo: su richiesta esplicita dell'utente di procedere con la roadmap
dando priorita' ai residui documentali di Fase 2 rispetto alla ripresa
fisica della Fase 3. Consolidati dati NAS gia' sparsi in piu' file della
timeline (2023-baseline, 2025-q1/q3-q4) in un'unica tabella di riferimento;
ampliata la gap analysis Annex A incrociando snapshot Proxmox v4, piano
firewall e GAP-TBC.md (nuovi controlli: A.8.21 VPN IKEv1, A.8.1 endpoint/
Intune, A.8.13 backup, A.7.1 badge sala server, A.8.24 crittografia). Fase 2
ora COMPLETATA. Fase 3 (21 micro-step firewall/Proxmox) resta in attesa
dell'utente per gli step fisici da M2 in poi.

## 2026-07-10 — Sweep di anonimizzazione completo su tutto l'albero docs/ (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: cybersecurity-governance.md, scenia-project.md,
helpdesk-operations.md, it-backlog.md, vendor-management.md,
business-continuity-disaster-recovery.md, telephony-pbx.md,
infrastructure-timeline/{2024-infra,2025-q1-server-vianova,
2025-q2-migrazione-tim-vianova,2025-q3-q4,ingestion-checklist}.md,
`_notes/.anonymization-map.md` (17 nuovi placeholder: Persona-V..AJ,
Referente-Vianova-5/6, Referente-Fibercop-1, Referente-RWS-1).
Motivo: su conferma esplicita dell'utente ("continua ora il sweep
completo"), esteso oltre ai file gia' bonificati il controllo a tutto
l'albero `docs/` e `.claude/context/`. Trovato e corretto: un registro
firme dipendenti con 21 nomi reali in chiaro (mai messi in placeholder
prima d'ora), una decina di referenti esterni (Vianova, myOffice,
Fastnet, Novadys, ABBYY, Proelium, BioStar2, Fibercop, RWS) citati per
nome reale nelle timeline 2024-2025 nonostante avessero gia' un
placeholder assegnato altrove, due hostname PC-* legati a nomi reali, e
quattro numeri di telefono reali (rimossi, non solo anonimizzati, per la
regola sui dati amministrativi). Deciso con l'utente di trattare
"Intrawelt di Alessandro Potalivo & C. Sas" come ragione sociale legale
(dato di registro) e lasciarlo reale solo dove compare letteralmente
come denominazione d'impresa, anonimizzando pero' ogni menzione
narrativa personale del legale rappresentante altrove. Grep esteso
finale su tutto l'albero: nessun residuo noto. Fase B resta aperta solo
per la riscrittura della storia git (fuori scope di una sessione
normale); il contenuto in HEAD e' ora pulito.

> Append-only, in ordine cronologico inverso (la voce piu recente in alto). Ogni passo
> significativo di codice e ogni intervento manuale rilevante lascia una voce con data, file
> toccati, motivo e commit di riferimento.

## 2026-07-10 — Mappatura porte Persona-D, sec-009 continua, bonifica IP/nomi reali estesa (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/mappatura-porte-fisiche.md (spostamento postazione Persona-D
0-3-3 -> 0-R-4 per aggiornamento IP), docs/infrastructure-timeline/2025-q1-server-vianova.md
(dettaglio migrazione BioStar2 su HP Gen10/Windows Server 2022), docs/vendor-management.md
(predecessore GroupShare 2017 SP1 su Seeweb, Persona-H al posto del nome reale),
docs/infrastructure-timeline/2023-baseline.md (bonifica quasi totale: era rimasto
il file originale non anonimizzato con IP reali 192.168.x.x, 5.98.88.x,
31.197.194.x, 10.1.116.x, nomi reali Pasquale Sconciafurno/Giordano
Mandolesi/Daniele Colo', MAC e seriale device reali, numeri di telefono
reali), docs/infrastructure-timeline/2025-q3-q4.md (bonifica IP reali
residui NAS fleet + seriali/MAC device + nomi Francesca Caricchia/Marco
Perri/Serafino Bartolomei gia' in placeholder dove serviva),
docs/infrastructure-timeline/{2024-infra,2025-q1-server-vianova,2025-q2-migrazione-tim-vianova}.md,
docs/{helpdesk-operations,it-backlog,runbook-anomalie,sviluppo-interno,
vulnerability-assessment-nov2025,firewall-zyxel-usg-flex-500,
business-continuity-disaster-recovery}.md (bonifica IP reali via script
Python deterministico + fix manuali di nomi propri residui), `_notes/.anonymization-map.md`
(nuove voci: placeholder per le tre IP pubbliche TIM WAN1 legacy).
Motivo: applicato l'aggiornamento port-mapping richiesto dall'utente per
Persona-D, poi ripresa la re-estrazione di sec-009. Durante la lettura di
sec-009 (arrivata a copertura quasi completa, restano poche decine di
paragrafi finali su USG20/USG60 dismessi, privi di contenuto testuale
utile nella fonte) e' emerso un grep-audit che ha rivelato una bonifica
di anonimizzazione molto piu' estesa del previsto: 2023-baseline.md non
era mai stato passato dalla pipeline di anonimizzazione (probabilmente
scritto prima che la regola esistesse) e altri 10 file avevano residui
IP reali reintrodotti o mai bonificati. Bonifica IP completata su tutti
i file individuati dal grep esteso del 09/07 piu' alcuni nuovi (seriali
device, un MAC, numeri di telefono). Bonifica nomi propri completata solo
sui file toccati in questa sessione; resta un sweep piu' ampio non
ancora fatto su cybersecurity-governance.md, scenia-project.md e le
timeline 2024/2025-q1/q2 (soprattutto Alessia Nasini e Alessandro
Potalivo), segnalato all'utente con una domanda aperta sul trattamento
di Alessandro Potalivo dato che il suo nome coincide con la ragione
sociale legale dell'azienda.

## 2026-07-10 — sec-009 ARCHITETTURA: migrazione W2012_bioserver, diagnosi VLAN BioStar2 (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/helpdesk-operations.md (limite Windows Server 2012 su
cambio hardware/virtualizzatore), docs/infrastructure-timeline/2025-q1-server-vianova.md
(saga guasto lettore BioStar2 7-25/02/2025 con diagnosi VLAN), docs/infrastructure-timeline/GAP-TBC.md
(gap #40 risolto)
Motivo: proseguita la lettura di sec-009 (ora a circa 750/1543 paragrafi).
Estratta la diagnosi di rete del guasto BioStar2 (sintomo di segmentazione
VLAN: ping al lettore attraverso lo switch risponde sempre dal gateway
della VLAN sbagliata, non dal dispositivo, indipendentemente dalla porta
fisica) e il vincolo tecnico di Windows Server 2012 sul cambio di
virtualizzatore (non tollerato, causa boot loop, si risolve solo da
Windows Server 2019 in poi). Contenuto rimanente di sec-009 sempre piu'
simile a log di troubleshooting dettagliato (migrazione Timewalker/SQL/IIS
sul nuovo server, con molte credenziali reali mai riportate): valutare con
l'utente se continuare a questo livello di dettaglio o accelerare/fermarsi.

## 2026-07-10 — sec-009 ARCHITETTURA in corso: NAS INTRA2 crisi giu-lug 2025, inventario HP G5 (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/2025-q3-q4.md (crisi spazio NAS
INTRA2 giugno-luglio 2025), docs/infrastructure-timeline/2023-baseline.md
(inventario dettagliato 8 VM legacy su HP G5), docs/infrastructure-timeline/GAP-TBC.md
Motivo: proseguita la re-estrazione di sec-009 (Non attivi/dismessi, 1543
paragrafi, la piu' grande di ARCHITETTURA.docx), coperti finora circa 350
paragrafi su 1543. Estremamente densa di credenziali reali (mai riportate).
Gran parte del contenuto letto finora (SEEWEB, WINGROUPSHARE/WINSRV2019,
NAS INTRA2 disk migration dic24-gen25) era gia' documentata. Novita':
seconda crisi di spazio su NAS INTRA2 giu-lug 2025 (soglia 80% l'80%
raggiunta due volte, job Veeam falliti, causa root identificata nel disco
esterno Toshiba anni-vecchi collegato durante un backup) — motiva
operativamente l'urgenza del consolidamento gia' documentato in
`2025-storage-anni-vecchi.md`; inventario dettagliato delle 8 VM legacy sul
vecchio host ESXi HP G5 (eGetrad, SVN, TestWeb, DOMV, licenze Trados,
timbracartellini) con l'analisi di dismissione di dicembre 2024, gap
"HP G5" chiuso. Restano ~1200 paragrafi di sec-009 da coprire: dato il volume
e la densita', checkpoint con l'utente prima di continuare.

## 2026-07-10 — Re-estrazione ARCHITETTURA.docx: sec-005/006/008 completate (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/2025-q1-server-vianova.md (NAS
INTRA3 riconnessione 27/06/2025), docs/infrastructure-timeline/2023-baseline.md
(hardware Vianova telefonia DDT 29/03/2024), docs/vendor-management.md
(Seeweb Foundation Server Pro + VM ospitate), docs/helpdesk-operations.md
(procedure GroupShare restart/wrong-user), docs/firewall-zyxel-usg-flex-500.md
(data disattivazione VPN_auth_LAN2), docs/telephony-pbx.md (discrepanza
modello centralino e data servizio Vianova), docs/infrastructure-timeline/GAP-TBC.md
(#14 risolto, #112 nuovo, sec-005/006/008 marcate verificate)
Motivo: su richiesta dell'utente, riavviata l'ambizione originaria della
sessione — re-estrazione esaustiva dai grandi .docx gia' ingeriti solo per
sintesi. Iniziato da ARCHITETTURA.docx, le 4 sezioni gia' segnalate come
non completamente estratte in GAP-TBC.md: sec-005 (Piano 1 Ufficio IT),
sec-006 (Piano 2 Rack SX, 974 paragrafi) e sec-008 (Cloud SEEWEB)
completate; sec-009 (Non attivi/dismessi, 1543 paragrafi) ancora da fare.
La maggior parte del contenuto era gia' coperta da file esistenti; le
novita' principali: riconnessione NAS INTRA3 27/06/2025 con analisi dischi
(RAID 1, bad blocks su un disco Seagate), architettura Seeweb (Foundation
Server Pro, VLAN 437, rationale VM WINGROUPSHARE/WINSRV2019), procedure
GroupShare non ancora documentate, data esatta di disattivazione
VPN_auth_LAN2. Emerse anche due discrepanze non risolte da segnalare
all'utente: modello del centralino Panasonic (KX-NCP1000 vs KX-TDA100,
due fonti indipendenti a favore di NCP1000) e data di inizio servizio
telefonico Vianova (aprile 2024 vs aprile 2025 in telephony-pbx.md).

## 2026-07-10 — GAP-TBC #111 chiuso: vpn.intrawelt.com era un hostname superato

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/GAP-TBC.md (#111 marcato
RISOLTO, conteggio risolti 5->6), .claude/context/current-work.md
Motivo: l'utente ha spiegato che `vpn.intrawelt.com` (irraggiungibile nel
test TCP/443 del 09/07) e' un riferimento a una configurazione VPN
precedente, ormai superata dall'accesso VPN attuale tramite il firewall
Zyxel USG FLEX 500. La cancellazione del certificato ZeroSSL e' quindi
coerente con la dismissione, non un'anomalia da investigare oltre.

## 2026-07-09 — Verifica live dei certificati SSL in sospeso (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/scenia-project.md (risolta dipendenza wildcard
scenia.intrawelt.com), docs/infrastructure-timeline/GAP-TBC.md (#111
aggiornato con tentativo di verifica), .claude/context/design-and-security.md
(nuova nota VM206 "intrasite"), .claude/context/current-work.md
Motivo: su richiesta dell'utente, verificati direttamente via TLS (openssl
s_client) i due certificati rimasti in sospeso. `scenia.intrawelt.com` ha
un certificato Let's Encrypt dedicato dall'11/05/2026, non dipende piu' dal
wildcard di intrawelt.com: domanda chiusa. `intrawelt.com` stesso ha un
certificato valido coerente con la nota Fastnet (nessun wildcard). Scoperta
non richiesta ma rilevante: una voce nel file hosts di questa macchina
reindirizza intrawelt.com/www a VM206 "intrasite" (10.61.20.23) con
certificato auto-firmato, per uso interno — non un problema sul sito
pubblico reale, ma una scoperta architetturale genuina (vedi
design-and-security.md). `vpn.intrawelt.com` invece non ha risposto al
tentativo di connessione TCP/443 dalla rete interna (timeout): la domanda
resta aperta per mancanza di raggiungibilita', non per assenza di verifica.
Aggiunte due nuove coppie IP pubblico placeholder/reale alla mappa privata
(hosting Fastnet, IP pubblico vpn.intrawelt.com).

## 2026-07-09 — Audit e bonifica dati amministrativi/commerciali (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: `.claude/rules/anonymization.md` (nuova sezione "Dati
amministrativi e commerciali: mai in un file tracciato"), `_notes/.anonymization-map.md`
(Referente-OpenForce-2/3, Persona-U, Referente-Proelium-1/2, MAC
AA:BB:CC:00:00:20), docs/vendor-management.md, docs/infrastructure-timeline/2025-q2-migrazione-tim-vianova.md,
docs/infrastructure-timeline/2025-q1-server-vianova.md,
docs/infrastructure-timeline/2025-q3-q4.md, docs/infrastructure-timeline/2024-infra.md,
docs/infrastructure-timeline/GAP-TBC.md, docs/infrastructure-timeline/ingestion-checklist.md,
docs/helpdesk-operations.md, docs/cybersecurity-governance.md,
docs/scenia-project.md, docs/telephony-pbx.md
Motivo: l'utente ha ricordato che il repository e' pubblico e che nessuna
informazione aziendale deve trapelare, "neanche di tipo amministrativo" —
la regola di anonimizzazione fino ad ora coprivo solo IP/MAC/nomi propri,
non importi contrattuali, prezzi, numeri di fattura/ordine/preventivo,
numeri di linea telefonica. Aggiornata la regola con una sezione dedicata,
poi bonificato tutto quanto scritto nella sessione (e trovato per caso
mentre si controllava, anche di sessioni precedenti): importi contrattuali
Vianova/Punto Informatica/Openforce/Proelium/Aruba Cloud, un numero di
linea telefonica reale, numeri di preventivo/ordine (P220126, SO1429,
ZNET241120-9007-66116, Preventivo-9_2025), il costo dell'anomalia AWS, un
ticket Zyxel, e la Partita IVA reale di Intrawelt in un DPA. Trovato anche
un caso serio non legato a oggi: le ultime 4 cifre reali di una carta di
credito aziendale scritte in chiaro in `2024-infra.md` (rinnovo Zyxel
20/11/2024), insieme a un MAC address reale non ancora anonimizzato —
entrambi corretti. Corretti anche due nomi propri di referenti Proelium che
una sessione precedente aveva deliberatamente lasciato "per la Fase B":
la decisione e' stata superata dalla richiesta esplicita di oggi di non
aspettare. Non toccati gli IP reali pre-esistenti sparsi nel resto del
repository (Fase B, workstream separato, portata gia' nota).

## 2026-07-09 — Coda BASSA di "IT + Administration - Documenti" chiusa (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/helpdesk-operations.md (§Odoo 18: preventivo Openforce,
fee Odoo +25%), docs/cybersecurity-governance.md (§Bitdefender: razionale
difesa a piu' livelli Defender/Bitdefender/Zyxel, risolve TBC Email
Security), docs/infrastructure-timeline/GAP-TBC.md (#111/SEC-013 ZeroSSL
cert VPN cancellato), docs/infrastructure-timeline/ingestion-checklist.md
Motivo: chiuse tutte le voci BASSA residue (Google Cloud abortito,
Openforce, Eter, TREX, MICROSOFT, ZeroSSL, Rinnovo marchi, Savelli, file
sciolti root, foto sala server). Trovati: preventivo Openforce per
l'analisi di migrazione Odoo v12->v18 (nov-dic 2025, importo non riportato) con
cambio di contatto tecnico; pressione temporale dal fornitore Odoo (fee
+25% annuo su versioni legacy da aprile 2026); razionale a tre livelli
della difesa in profondita' (Defender P1 cloud/email, Bitdefender endpoint,
Zyxel perimetro rete); certificato SSL VPN ZeroSSL cancellato il
10/02/2026 con esito non chiaro (nuovo gap #111). Savelli e Rinnovo marchi
confermati fuori scope (ascensore, proprieta' intellettuale). La libreria
Administration e' ora chiusa salvo l'eccezione deliberata di
`MyOffice/Transizione centralino cloud 2026/`, riservata alla nota
PORT-TAGGING.

## 2026-07-09 — Risolta discrepanza date Vianova: due migrazioni distinte (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/vendor-management.md (§Vianova riscritta con due
evoluzioni separate), .claude/context/current-work.md (nota discrepanza
chiusa)
Motivo: l'utente ha chiarito che non era un errore di date ma due
migrazioni Vianova distinte confuse in un'unica tabella: la migrazione
della linea dati (fibra FTTO, sostituzione TIM, marzo-luglio 2025,
conclusa) e la migrazione del centralino cloud (PBX, dicembre 2025-2026,
ancora in corso, oggetto della nota PORT-TAGGING). Riscritta la sezione con
due tabelle "Evoluzione rapporto" separate; corretta anche l'etichetta
errata "primo appuntamento tecnico per attivazione dati" del 02/02/2026,
che in realta' riguarda il centralino.

## 2026-07-09 — Ingestione voci MEDIA di "IT + Administration - Documenti" (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/vendor-management.md (Punto Informatica espanso con
acquisto switch/telefoni), docs/infrastructure-timeline/GAP-TBC.md
(#110/SEC-012 AWS access key admin non rotata), docs/infrastructure-timeline/ingestion-checklist.md
Motivo: completate le 5 voci MEDIA della libreria Administration (QNAP
cloud license, Aruba amministrazione/cloud, Seeweb, Punto Informatica, AWS
dismissione Glacier). Trovato un gap di sicurezza reale non risolto: una
access key IAM AWS con AdministratorAccess creata nel 2019 senza MFA,
ancora attiva, che ha generato una chiamata anomala ad Amazon Translate la
cui origine non e' mai stata identificata (mitigata solo con una Deny
Policy specifica, non con la rotazione della chiave). Confermato l'acquisto
dello switch Piano Terra (13/03/2026) e dei telefoni Yealink (24/03/2026)
da Punto Informatica, con prezzi. Verificato e scartato: QNAP cloud license
(solo foto e fatture Azure), Aruba VPS (studio mai confermato completato,
credenziali reali mai riportate), Seeweb (contratto scansionato illeggibile).
La coda ALTA e MEDIA della libreria Administration e' ora chiusa; restano
le voci BASSA e la sottocartella riservata (MyOffice/Transizione centralino
cloud 2026/).

## 2026-07-09 — Ingestione voci ALTA di "IT + Administration - Documenti" (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/vendor-management.md (Aruba espanso, nuova sezione
Fastnet, nota Vianova), docs/scenia-project.md (data registrazione
scenia.it, nota cert wildcard), docs/infrastructure-timeline/2025-q2-migrazione-tim-vianova.md
(richiesta VPN Unmanaged 10/04, disdetta TIM), docs/infrastructure-timeline/2025-q3-q4.md
(causa radice rinnovo licenze ZYXEL), docs/business-continuity-disaster-recovery.md
(incidente UPS 01/07/2025), docs/infrastructure-timeline/ingestion-checklist.md,
docs/infrastructure-timeline/timeline.svg (125→128 eventi), _notes/.anonymization-map.md
(6 nuove voci: Persona-S/T, Referente-FASTNET-1/2, Referente-Vianova-3/4,
Referente-MyOffice-3, cognome Persona-R confermato)
Motivo: su richiesta dell'utente, ingerite le 4 cartelle ALTA della nuova
libreria scoperta (Analisi Domini Intrawelt, VIANOVA, ZYXEL, MyOffice).
Trovati: portfolio di ~20 domini di nicchia marketing su Aruba/Tucows con
architettura redirect legacy (VM Ubuntu 1404-DOMV in dismissione); Fastnet
come vendor DNS/hosting Plesk finora non documentato, con un limite tecnico
reale (rinnovo wildcard SSL fallito 11/05/2026 per DNS non su Plesk,
certificato riemesso senza wildcard); offerta commerciale Vianova datata
07/02/2024 con economics contrattuali complete; causa radice della crisi
rinnovo licenze ZYXEL nov-dic 2025 (carta di credito dismessa). Corretto un
errore proprio (nome inventato "Alessandro Sopranzi", corretto in
Alessandro Potalivo) e rimosso un codice di licenza reale scritto per
errore in un file tracciato prima del commit. **NON ingerita** la
sottocartella MyOffice/Transizione centralino cloud 2026/: si sovrappone
alla nota PORT-TAGGING che l'utente ha riservato al racconto "a lavori
conclusi" — da riprendere solo su indicazione esplicita. Rilevata (non
riconciliata) una discrepanza di un anno tra le date Vianova in
vendor-management.md e in 2025-q2-migrazione-tim-vianova.md, segnalata
inline per verifica futura.

## 2026-07-09 — File sciolti ARCHITETTURA ingeriti, scoperta nuova libreria OneDrive (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/2025-storage-anni-vecchi.md (nuovo),
docs/infrastructure-timeline/ingestion-checklist.md (voci file sciolti
ARCHITETTURA, nuova sezione IT + Administration - Documenti, note su
riorganizzazione D:\), scripts/Check-OneDriveDelta.ps1 (multi-target, due
librerie), _notes/.onedrive-manifest-admin.json (nuova baseline, non
versionata)
Motivo: l'utente ha segnalato che tre file sciolti mai apriti nella cartella
ARCHITETTURA SERVER-CLOUD-LINEE (root) erano stati saltati durante tutte le
sessioni di ingestione precedenti. Verificati: `Intrawelt_anni_vecchi_2026-05-20_15-44.html`
e' un mini-tool interattivo con dati incorporati nel `<script>` (non nel
solo testo visibile) che traccia 66 movimenti datati (feb 2025-gen 2026) di
consolidamento dell'archivio storico 2009-2023 su tre nuovi HDD Toshiba 4TB
+ doppia copia su NAS HERO, con 14 confronti FreeFileSync (due dei quali
hanno evitato perdita di 1GB e 177GB di dati aziendali) — tutto integrato
nel nuovo file dedicato. `email_server_config.xls` (2016) verificato, senza
contenuto rilevante. Il file
`.lnk` "Analisi Domini Intrawelt" punta a una libreria OneDrive separata mai
censita, `IT + Administration - Documenti` (742 file, cartelle per
fornitore: VIANOVA, ZYXEL, MyOffice, AWS, Aruba, Seeweb, Punto Informatica,
ecc.). Su richiesta dell'utente: aggiunta al perimetro di
`Check-OneDriveDelta.ps1` (ora multi-target, due librerie con baseline
separate) e censita in una nuova sezione della checklist con priorita'
assegnate per rilevanza, non ancora ingerita contenuto per contenuto.
Rilevato durante l'aggiornamento baseline un apparente crollo di 21.347 file
nella libreria "Documenti - IT" (incluse le quattro cartelle sviluppo-*
appena lette in sessione): falso allarme, l'utente le ha convertite in
progetti standalone sotto `D:\` lo stesso giorno, non perdita dati.

## 2026-07-09 — Coda BASSA della checklist ingestione chiusa (sessione 9, continua)

Commit: PENDING (da fare manualmente)
File toccati: docs/infrastructure-timeline/ingestion-checklist.md (tutte le
voci BASSA verificate e chiuse), docs/business-continuity-disaster-recovery.md
(§Vademecum urgenze, §Storage e backup NAS HERO/Azure), docs/GAP-TBC.md
(#109/ENV-001 RAEE), docs/cybersecurity-governance.md (§Procedura di audit
mailbox via eDiscovery), docs/runbook-anomalie.md (NAS-001), docs/sviluppo-interno.md
(Cheshire Cat espanso, nuove voci Google Antigravity e Notes con
relazioni/Obsidian, Tool AI coding assistance espanso), _notes/.anonymization-map.md
(Persona-S nuova, Persona-M nome proprio scoperto, nuove coppie IP)
Motivo: su richiesta dell'utente, percorse in ordine tutte le ~25 voci BASSA
residue della checklist (ALTA/MEDIA erano gia' a zero). La maggioranza si e'
rivelata fuori scope (contabilita', HR, marketing vendor, tutorial generici
non specifici a Intrawelt) o gia' coperta altrove, ma sono emersi cinque fatti
sostanziali: runbook di emergenza a 9 casi con scala di reperibilita' (da
`_planning_ferie_lunghe.xlsx`), replica NAS HERO su Azure Blob via QNAP
HBS/QuDedup, gap ambientale RAEE mai risolto, procedura legale di audit
mailbox via M365 Purview eDiscovery (art.4 Statuto Lavoratori/GDPR), e
quattro studi di tooling AI mai implementati (Cheshire Cat, Google
Antigravity, Obsidian vs IT Glue, Claude Subagents). Verificato anche che
`intraweb2_1osxen.pdf`/`intraweb_wx7v5r.pdf` (1506+415 pagine) sono i report
Nessus grezzi del 06/11/2025 alla base del VA Onova gia' sintetizzato in
vulnerability-assessment-nov2025.md: nessuna nuova ingestione necessaria.
Corretti anche due IP reali non anonimizzati trovati per caso in
business-continuity-disaster-recovery.md (192.168.90.33 pre-esistente da
sessione precedente, e due miei stessi nuovi inserimenti prima della
correzione) — bug di bookkeeping isolato, non la Fase B completa: un grep
esteso su tutto `docs/` conferma che il resto del repository (helpdesk,
timeline storica, SCENIA) resta con IP reali non anonimizzati, esattamente
come previsto dalla Fase B non ancora iniziata (roadmap.md). La coda BASSA
e' ora chiusa; restano solo le due attese esterne (PORT-TAGGING, fonte
IntraLino su VM).

## 2026-07-08 — Rimossa scrittura verso E:\projects, nuova regola di confine (sessione 9)

Commit: PENDING (da fare manualmente)
File toccati: scripts/Build-TimelineSvg.ps1 (rimosso parametro -MkDocsAsset,
-NoCopy e il blocco Copy-Item finale), CLAUDE.md (nuova sezione "Confine con
E:\projects", sezione "Script timeline SVG" aggiornata), .claude/context/STACK.md
(riga Build-TimelineSvg.ps1 aggiornata)
Motivo: l'utente ha segnalato che questo repository non deve scrivere dentro
`E:\projects` (sito MkDocs dei progetti personali); la direzione corretta e'
che sia quel progetto a leggere l'asset da qui, non il contrario. Lo script
ora scrive solo `docs/infrastructure-timeline/timeline.svg` in questo repo.
Nota: la copia gia' esistente in `E:\projects\docs\company\assets\network-timeline.svg`
(scritta dalle sessioni precedenti prima di questa correzione) resta
orfana finche' l'utente non predispone un meccanismo di lettura dal lato
E:\projects; non toccata da questa sessione perche' fuori dall'albero di
D:\network-design.

## 2026-07-08 — sync-context: bump timbri last-verified a HEAD (sessione 9)

Commit: PENDING (da fare manualmente)
File toccati: .claude/context/STACK.md, deployment.md, design-and-security.md,
dev-testing.md, roadmap.md, current-work.md (frontmatter last-verified),
.claude/memory/index.md (commit di riferimento e tabella di stato)
Motivo: sync-context ha rilevato che tutte le sei schede avevano contenuto
gia' coerente con HEAD (347f79c) ma il timbro last-verified era rimasto
disallineato per un errore di bookkeeping nelle sessioni precedenti (il
timbro veniva impostato al commit precedente a quello che conteneva davvero
la modifica: es. design-and-security.md portava 594ec07 ma il contenuto v4
risale al successivo 0e4b837). Nessuna modifica di contenuto, solo
riallineamento dei timbri e del riferimento in memory/index.md, fermo dal
07/07/2026 a 68216f0.

## 2026-07-08 — Token MCP Proxmox creato e verificato (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati: .claude/memory/decisions.md (esito ADR-007), .gitignore
(pattern .env/.env.* aggiunti, mancavano), .env creato in radice (backup
umano del segreto, non tracciato, valutazione rischio in ADR-008)
Motivo: completata la procedura ADR-007. Token `mcp-readonly` creato su
root@pam con privilege separation e ruolo PVEAuditor su `/`; le tre
variabili PROXMOX_URL/TOKEN_NAME/TOKEN_VALUE impostate nel registro HKCU
dell'utente via setx (il valore del secret e' stato letto dal .env locale
via script PowerShell per evitare di farlo transitare in chiaro nella
chat). Verifica di autenticazione: GET /nodes -> 200, nodo pve online,
senza mai stampare il token. Resta il riavvio di Claude Code per il
reload del server MCP `proxmox`.

## 2026-07-08 — ADR-008: schema a due token Proxmox (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati: .claude/memory/decisions.md (ADR-008)
Motivo: l'utente ha chiesto se il token MCP dovesse avere anche la
scrittura per gli script di network design; ragionamento tracciato per
esteso nell'ADR come argomentato in sessione. Esito: MCP resta PVEAuditor
sola lettura (canale ambientale senza conferme per la safety rotta);
scrittura con secondo token a finestra (automation@pve, ruolo minimo,
expiry) alla ripresa della Fase 3. Confermato dall'utente. Token
mcp-readonly creato sulla GUI (passo 1); restano permesso PVEAuditor
(passo 2) e variabili d'ambiente (passo 3), poi riavvio di Claude Code.

## 2026-07-08 — Correzione date Bitdefender, timeline SVG con aree di competenza, diagramma fonia VLAN 100 (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/cybersecurity-governance.md (correzione confermata dall'utente: il
    deploy Bitdefender era registrato "giu 2024" ma e' avvenuto in autunno
    2025, dopo la sottoscrizione del 15/09/2025; righe spostate al Q4 2025
    con nota di correzione; VA interno Bitdefender marcato [TBC] fine 2025)
  - docs/infrastructure-timeline/2024-infra.md (sezione Bitdefender rimossa)
    e 2025-q3-q4.md (sezione ricollocata in autunno 2025, con bonifica di
    tre IP reali che conteneva: due Seeweb -> 10.77.116.3/.4, uno LAN ->
    10.61.20.13)
  - scripts/Build-TimelineSvg.ps1 (v2: perimetro dal 2024 — ingresso IT
    manager, come chiesto; esclusi 2023-baseline e intestazioni senza data;
    otto aree di competenza con tavolozza categoriale validata dataviz,
    legenda con conteggi, tag testuale per evento cosi' l'identita' non e'
    solo colore) + timeline.svg rigenerata (121 interventi dal 2024,
    verificata al render) e ricopiata su E:\projects
  - docs/firewall-zyxel-usg-flex-500.md (tabella diagrammi: registrato
    rete_fonia_voip_08072026_2.drawio-claudio.drawio prodotto dall'utente —
    VLAN 100 fonia, zona VOICE su ge5, DHCP firewall, SIP ALG off, PoE
    priority, 5 step hitless; nota refuso modelli GS2220 vs XGS2220;
    convergenza con M11/M12 rispetto a FW-012)
  - docs/network-diagram.md (riga VLAN 100 target in tabella; nota 08/07
    aggiornata col diagramma fonia)
  - .claude/context/diagrams/firewall-dmz-2026/rete_stato_target_08072026.drawio
    (nota interna: VLAN fonia = 100, rimando al diagramma dell'utente)
Motivo: feedback utente pre-commit — timeline piu' dettagliata con
interventi e skill, date sbagliate (Bitdefender), perimetro dal suo
ingresso (2024); piu' il nuovo diagramma fonia consegnato dall'utente.

## 2026-07-08 — Timeline SVG auto-rigenerata per repo e sito progetti (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - scripts/Build-TimelineSvg.ps1 (nuovo: parser deterministico delle
    intestazioni `## data - titolo` dei sei file timeline, ordinamento
    cronologico, SVG verticale a bande per anno; sostituzione nomi legacy
    da _notes/.svg-name-replacements.txt privato; guard-rail IP
    non-placeholder; copia verso E:\projects)
  - docs/infrastructure-timeline/timeline.svg (nuovo, versionato: 136
    eventi 2021-2026, verificato al render — zero nomi reali, zero IP)
  - CLAUDE.md (sezione Script timeline SVG), .claude/context/STACK.md (riga)
  - .claude/settings.local.json (secondo hook SessionStart: rigenerazione
    a ogni avvio, "si aggiorna sempre" come chiesto dall'utente)
  - E:\projects\docs\company\network-infrastructure-documentation{,.en,.es}.md
    (sezione Timeline con l'immagine assets/network-timeline.svg — fuori
    repo, sito MkDocs progetti) + assets/network-timeline.svg (copia)
  - _notes/.svg-name-replacements.txt (nuovo, privato),
    _notes/.anonymization-map.md (Referente-Vianova-2, Referente-BioStar2-1,
    Persona-Q, Persona-R; cognome Consulente-ISO27001-1 ora noto)
Motivo: richiesta utente 08/07 — la timeline aggiornata deve essere un SVG
sempre aggiornato, anonimizzato, accessibile in E:\projects nel progetto
"Progettazione e documentazione della rete aziendale". Nota di design: i
sorgenti legacy contengono ancora nomi reali (Fase B pendente), quindi
l'anonimizzazione dell'artefatto avviene in generazione con mappa privata;
l'SVG e' piu' pulito dei sorgenti finche' la Fase B non chiude.

## 2026-07-08 — Snapshot v4 riconciliato + decisione MCP (ADR-007) + bonifica .mcp.json (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/design-and-security.md (scheda portata dallo snapshot
    v3 al v4: nodo 48 core/125.4 GB con upgrade RAM confermato, LAN /19,
    inventario 8 VM con VM602 "Intralino" e VM810, storage PROGRAMMAZIONE
    nuovo, nove backup schedule, firewall cluster ancora inattivo)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce
    08/07/2026 snapshot v4 con delta rispetto alla v3)
  - docs/infrastructure-timeline/GAP-TBC.md (#106 RICONCILIATO: VM effimere
    rimosse, 810 sostituisce 809; #107 aggiornato: .58/.60 confermati NON
    VM del nodo; #108 nuovo SRV-003: stato cluster riporta IP nodo = iLO5;
    totale 108)
  - .claude/context/roadmap.md (Fase 2 step 2 fatto: snapshot v4)
  - .mcp.json (bonificato: conteneva l'IP reale del nodo in un file
    TRACCIATO del repo pubblico; ora tutte le variabili si espandono da
    env utente; riscritto per l'autenticazione a token del pacchetto)
  - .claude/memory/decisions.md (ADR-007: approccio B, token API
    PVEAuditor sul pacchetto proxmox-mcp esistente, ALLOW_DANGER=true
    accettabile solo con token di sola lettura)
  - CLAUDE.md (Nota MCP riscritta: rimando ad ADR-007)
  - _notes/.git-filter-replacements.txt (regola IP nodo per la Fase B:
    .mcp.json in storia con valore reale)
Motivo: l'utente ha eseguito Get-ProxmoxSnapshot.ps1 (v4, 08/07 10:35) e
ha chiesto di scegliere e documentare l'approccio MCP. Nota: lo snapshot
v4 conferma in campo l'ordine RAM del 14/11/2025 ingerito stamattina dalla
cartella PROXMOX. Il token API e le tre env restano da creare (utente).

## 2026-07-08 — Diagnosi MCP Proxmox non funzionante (sessione 8, continua)

Commit: PENDING (nessun file tracciato modificato oltre a questa voce)
Tentata la lettura live dell'inventario Proxmox (riconciliazione gap
#106/#107) via server MCP `proxmox` di `.mcp.json`, con ok esplicito
dell'utente alla sola lettura. Esito: inutilizzabile per due difetti
indipendenti del pacchetto risolto da `uvx proxmox-mcp` (0.1.0, non e'
ProxmoxMCP-Plus): (1) la safety policy carica `config/safety_policy.json`
da un PROJECT_ROOT sbagliato per un pacchetto installato, il file non
esiste, la lista safe_tools resta vuota e OGNI tool viene bloccato; il
bypass `confirmed=true` non passa perche' i tool non dichiarano quel
parametro nello schema e il client lo scarta. (2) Il pacchetto autentica
solo via token API (`PROXMOX_URL`, `PROXMOX_TOKEN_NAME/VALUE`) mentre
`.mcp.json` fornisce `PROXMOX_HOST/USER/PASSWORD`: anche superata la
safety, il client non si connetterebbe. `PROXMOX_PASSWORD` non e' nemmeno
presente nell'ambiente della shell. Rimedi possibili: sostituire il
pacchetto con il ProxmoxMCP-Plus vero, oppure creare un token API su
Proxmox e riscrivere `.mcp.json` con le env giuste (piu' safety_policy.json
nel PROJECT_ROOT del pacchetto). Nel frattempo la via canonica resta
`scripts/Get-ProxmoxSnapshot.ps1` eseguito dall'utente (M18): chiesto.

## 2026-07-08 — Diagramma target rev 08/07 (secondo trunk PT-P2) + ingestione BASSA infrastrutturali (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/diagrams/firewall-dmz-2026/rete_stato_target_08072026.drawio
    (nuovo, su richiesta utente: secondo trunk 802.1Q tra XGS2220-30HP Piano
    Terra e XGS2220-54HP Piano 2 con VLAN dati del Piano Terra + VLAN fonia;
    ID VLAN non fissati, nota NET-008/TEL-002 nel diagramma)
  - docs/firewall-zyxel-usg-flex-500.md (riga nuova nella tabella diagrammi)
  - docs/network-diagram.md (nota aggiornamento target 08/07 sotto la
    tabella VLAN)
  - docs/infrastructure-timeline/2025-q2-migrazione-tim-vianova.md
    (§04-10/04/2025 VM601/applyconfiguration/postinstall; §11-12/06/2025
    scanner Canon C5840 con Referente-MyOffice-2)
  - docs/infrastructure-timeline/2025-q3-q4.md (§14/11/2025 saturazione RAM
    pve, ordine 64GB, quotazione DL380 G10 ricondizionato; §01/12/2025 VM205
    spazio esaurito, script vm_disk_alert e Postfix send-only sul nodo)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md
    (§Febbraio-Aprile 2026 esercizio Proxmox: vzdump lock 16/02 con
    inventario VM dai log, freeze VM 15/04, arrivo GPU e transceiver;
    §03-23/04/2026 NinjaOne backup/Archiver)
  - docs/infrastructure-timeline/GAP-TBC.md (#106 aggiornato: VM101
    confermata da qemu-101.log 12/02/2025; popolazione VM piu' ampia dello
    snapshot v3, riconciliazione a M18)
  - docs/infrastructure-timeline/ingestion-checklist.md (PROXMOX
    riclassificata da BASSA e ingerita; Ninjaone backup e scanner [x];
    QNAP cloud, Sharepoint, sostituzione RAM, 2 txt vuoti SKIP)
  - _notes/.anonymization-map.md (Referente-MyOffice-2)
Motivo: richiesta utente 08/07 (nuova revisione del diagramma target con il
secondo trunk, poi prosecuzione ingestione). La cartella PROXMOX era
sotto-classificata: conteneva eventi di esercizio mai tracciati. Config
mailer Postfix e appunti debian-odoo non letti (possibili credenziali).
Fonti solo-screenshot lasciate nel sorgente e marcate SKIP.

## 2026-07-08 — MEDIA preesistenti completate: Veeam, Odoo restore, Appina, Pi-hole, Proelium (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/2025-q1-server-vianova.md (§17/01-05/02/2025
    Veeam Agent: nuova politica backup postazioni verso NAS INTRA2, recovery
    media .iso, monitoraggio NinjaOne su evento 190)
  - docs/business-continuity-disaster-recovery.md (paragrafo backup
    postazioni in §Storage e backup; bonifica IP Seeweb reale -> 10.77.116.3)
  - docs/infrastructure-timeline/2025-q2-migrazione-tim-vianova.md
    (§28/05/2025 restore dump Odoo 12 in locale, precauzioni anti-invio
    posta da ambiente di test)
  - docs/infrastructure-timeline/2025-q3-q4.md (§03/11/2025 studio API Odoo
    per CRM con OpenForce; §18/12/2025 studio Pi-hole mai implementato;
    bonifica del percorso UNC del NAS reale -> 10.61.20.177)
  - docs/helpdesk-operations.md (tre sezioni Odoo: ambiente di sviluppo
    locale e restore, audit attivita' utente v12, studio API CRM)
  - docs/vendor-management.md (Proelium: preventivo 22/01/2026 solo
    VA, pacchetto singolo o triennale (importi non riportati), scaduto non
    accettato; dettaglio metodologia dalla call 19/01; bonifica IP Seeweb ->
    10.77.116.3)
  - docs/infrastructure-timeline/GAP-TBC.md (#105/SEC-011 esteso a
    Veeam_DRAFT.pdf e transcript Odoo 28/05)
  - docs/infrastructure-timeline/ingestion-checklist.md (6 voci MEDIA [x],
    riepilogo: MEDIA esaurite, resta BASSA; Regolamento rev1.pdf era gia'
    coperto dal .docx)
  - .claude/context/roadmap.md (Fase 1bis: fonte IntraLino su VM da contesto
    utente; tabella riepilogativa allineata: 1bis corrente, Fase 3 sospesa)
  - .claude/context/current-work.md (step 4 chiuso, domanda aperta IntraLino
    VM), _notes/.anonymization-map.md (Referente-OpenForce-2, IP 10.61.10.57,
    residui bonificati, credenziali mai copiate),
    _notes/.tmp-docx-odoo-restore/ (estrazione transcript)
Motivo: prosecuzione Fase 1bis su richiesta utente. Nota utente 08/07
recepita in roadmap: IntraLino come progetto aziendale si documentera' dalla
documentazione Claude che vive su una VM (contesto che l'utente fornira');
le sezioni IntraLino attuali valgono come parziali. Fonti lette a costo
minimo: mirror graphify-out per Odoo v12, eml via parser Python, PDF Veeam
e preventivo Proelium letti una volta, transcript 7 MB estratto con
python-docx in _notes. Credenziali nei sorgenti mai riportate (gap #105).

## 2026-07-07 — Delta MEDIA completato: ABBYY, Checklist/call SCENIA, benchmark IntraLino (sessione 8, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/2025-q1-server-vianova.md (§Migrazione
    licenze ABBYY FineReader 15, 27/02-24/03/2025: contesto acquisto 2021 e
    SMUA mai rinnovata, ticket supporto, errore LM v16, attivazione sul
    nuovo server, decisione 21/03 di dismettere il vecchio licserver,
    rollout ~18 postazioni con utente guest)
  - docs/infrastructure-timeline/2024-infra.md (voce 06/11/2024: falso
    allarme licenza ABBYY, licenza trial pescata oltre le 5 concurrent)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (§Benchmark DoE
    IntraLino maggio-luglio 2026: C1/C2/C3, GPU RTX 5060 Ti installata
    08/06, embedder bge-m3 fisso dal 04/06, report differenziali 29/06,
    C4 Qwen3-14B fuori benchmark su ambiente test :4443)
  - docs/scenia-project.md (§Call AIDAPT 06/07/2026 Qdrant/KB, §Checklist
    operativa caricamento nuovo customer, riga timeline Fase 3 aggiornata)
  - docs/infrastructure-timeline/GAP-TBC.md (#105 SEC-011 credenziali in
    chiaro in ABBYY.docx; #106 SRV-001 hostname alternati e VM101 vs VM100;
    #107 SRV-002 host IntraLino .58/.60 dichiarati VM ma .58 con hardware
    fisico, assenti dallo snapshot v3; totale 107)
  - docs/infrastructure-timeline/ingestion-checklist.md (4 voci MEDIA [x],
    riepilogo: delta MEDIA esaurito)
  - .claude/context/current-work.md (step 3 chiuso, prossimo blocco MEDIA
    preesistenti), _notes/.anonymization-map.md (Persona-O/P,
    Referente-Novadys/ABBYY/AIDAPT, IP .58/.60/.114/.8/.170),
    _notes/.manifest-docx.json e _notes/.tmp-docx-abbyy/ (estrazione ABBYY)
Motivo: prosecuzione Fase 1bis su richiesta utente ("Procedi"). Metodo:
ABBYY.docx (17 MB, 166 immagini) estratto una volta con python-docx (42 KB
testo) e manifesto anti-rilettura creato; per IntraLino letti solo lo stato
progetto, la guida C4 e le conclusioni dei due report (disclosure
progressiva); i file di credenziali della cartella n8n mai aperti. Tutto il
nuovo contenuto tracciato e' anonimizzato (10.61.x, Persona-X); password,
seriali licenze e lista nominativa postazioni restano solo nei sorgenti.

## 2026-07-07 — Sync-context post 594ec07 + ingestione revisione WindTre e BitLocker endpoint (sessione 8)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/*.md (bump last-verified 1ad2cb7 -> 594ec07 su tutte e sei
    le schede, dimenticato nei commit 6e1d4b6..594ec07; current-work.md
    aggiornata: voci ALTA chiuse, prossimo blocco delta MEDIA)
  - .claude/memory/index.md (commit di riferimento 594ec07, tabella schede,
    punto di ripresa riscritto)
  - docs/cybersecurity-governance.md (timeline Q3 2026: BitLocker endpoint
    attivo dal 03/07 con escrow chiavi su NinjaOne, revisione WindTre;
    nuova sezione §Revisione chiarimenti WindTre RFQ 10714 06-07/07;
    raccordo endpoint nella sezione Crittografia dati a riposo; riga
    WindTre della tabella questionari aggiornata)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce WindTre [x],
    riepilogo priorita': ALTA vuota, MEDIA aggiornata)
Motivo: ripresa sessione con sync-context (schede con frontmatter mai
bumpato dopo 1ad2cb7 ma contenuti gia' coerenti; solo current-work e index
davvero stale). Il delta OneDrive di avvio (2 nuovi + 1 modificato, tutti
WindTre Busta Tecnica _WIP) coincideva con la prima voce MEDIA: ingerita
dalle due NOTA-INTERNA (fonti .md, nessun docx da estrarre). Fatti chiave:
BitLocker full-disk XTS-AES 128 su tutti gli endpoint dal 03/07 (migliora
righi 77/190/191 annex), SCC nuove ex art. 46 GDPR con 4 sub-responsabili
extra-SEE (RWS/UK, NinjaOne/USA, QNAP e Zyxel/Taiwan), correzione del
file-base dell'annex (prima revisione applicata a copia non allineata).
Consegna a WindTre attesa entro il 08/07. Baseline OneDrive da aggiornare
con -UpdateBaseline a valle del triage.

## 2026-07-07 — Ingestione delta SCENIA: Allegati A-L, DPIA compilata, Risposte AIDAPT (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/scenia-project.md (Fase 3 estesa a 29/06-06/07; nuove sezioni: DPIA
    stato 02/07 con necessita'/proporzionalita' compilate, Risposte Tecniche
    AIDAPT con nota di riconciliazione retention 7/10gg vs 60gg e breach 48h
    vs EDPB, Allegati separati A-L con contenuti F/H/I/J; bonifica nomi reali
    residui: Persona-A, Collaboratore-Esterno-1, Persona-N nuova, IP
    collaboratore rimosso)
  - docs/infrastructure-timeline/ingestion-checklist.md (2 voci ALTA [x]:
    delta SCENIA e Risposte Tecniche, trovate negli estratti DPA/extracted/)
  - _notes/.anonymization-map.md (Persona-N), _notes/.git-filter-replacements.txt
Motivo: voce ALTA del delta 23/06-07/07. Metodo token-economy: usati gli
estratti .md gia' presenti in DPA/extracted/ (INDEX, diff tra le due versioni
DPIA invece di rilettura integrale: 64 righe cambiate), python-docx per i
soli 4 allegati non ancora coperti (F/H/I/J). Resta da ingerire la call
AIDAPT del 06/07 (MEDIA). Dati personali del referente privacy (telefono,
anagrafica completa) lasciati solo nel sorgente.

## 2026-07-07 — Tagging in corso (gap 102-104), architettura LAN telefoni, audit crittografia (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce 07/07/2026:
    tagging VLAN in corso sui due switch, evidenze in _notes, architettura LAN
    telefoni Vianova dalla nota utente)
  - docs/infrastructure-timeline/GAP-TBC.md (#102 NET-008: VLAN 1 non taggabile
    sulla dorsale senza perdere NAS-HERO, ipotesi native VLAN mismatch da
    verificare; #103 TEL-002: telefoni via vano ascensore non passano le VLAN;
    #104 SEC-010: password archivi cifrati in chiaro; #98 FW-012 funzione
    confermata; totale 104)
  - docs/firewall-zyxel-usg-flex-500.md (FW-012 confermata: DHCP+gateway
    Vianova untagged su porta 8, isolati dal firewall, VPN Vianova->myOffice)
  - docs/cybersecurity-governance.md (nuova sezione Crittografia dati a riposo
    da AUDIT_INVENTORY.md: due schemi paralleli VeraCrypt/.z 2009-2022,
    password in chiaro su filesystem, azioni P0/P1/P2; dettagli di derivazione
    password NON riportati, repo pubblico)
  - docs/infrastructure-timeline/ingestion-checklist.md (AUDIT_INVENTORY [x],
    nota PORT-TAGGING aggiornata: racconto a lavori conclusi)
  - .claude/context/roadmap.md (M11 parziale), .claude/context/current-work.md
Motivo: l'utente ha eseguito il 07/07 gli interventi di tagging (racconto
completo rimandato a endpoint funzionanti; evidenze in
`_notes/[TBC] screenshot e note myoffice/`: 16 screenshot, 2 foto, note.txt).
Tracciati subito i fatti noti e ingerita la prima voce MEDIA del delta
(audit crittografia dati a riposo).

## 2026-07-07 — Ingestione completa Mappatura porte fisiche (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/mappatura-porte-fisiche.md (riscritto completo: prima era un estratto
    parziale con nomi propri e IP reali)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce marcata [x])
  - .claude/context/current-work.md (stato e NET-007 aggiornati)
Motivo: prima voce ALTA della Fase 1bis. Estratto integrale deterministico di
porte_fisiche_via_pescolla_2.xlsx (openpyxl: 4 fogli; rispetto all'estratto
precedente mancavano Piano 0 uffici 2-4 completi, Piano 1 uffici 4-6, la
colonna "nome porta attuale" e i totali) e lettura visiva del PDF (scansione
del rilievo manoscritto "Prese dati" di Luciani Impianti, 20/08/2020, tre
pagine, convertite in PNG con PyMuPDF: e' la fonte originale della mappatura,
con la colonna "attuale" delle etichette permutate e i "da fare" mai chiusi).
Scoperte: permutazione sistematica delle etichette dal 2020 mai ricorretta
(rafforza NET-007 come errore di etichettatura); discrepanza xlsx/PDF sul
numero porte Ufficio 2 Piano 0 (13 vs 14, nuovo TBC); nessuna informazione
VLAN/tagging nelle fonti (la nota PORT-TAGGING resta in attesa dell'input
utente). Anonimizzazione applicata: nomi uffici -> Persona-A/Persona-B, nomi
delle postazioni Ufficio 4 Piano 0 lasciati solo nel sorgente, IP -> 10.61.x.

## 2026-07-07 — Pivot su ingestione OneDrive: gestione delta, hook di avvio, GroupShare (sessione 7, continua)

Commit: PENDING (da fare manualmente)
File toccati:
  - scripts/Check-OneDriveDelta.ps1 (nuovo: confronto deterministico della cartella
    OneDrive IT con baseline locale; esclusioni per dati raw/artefatti; baseline
    creata il 07/07 con 44.515 file in _notes/.onedrive-manifest.json, non versionata)
  - .claude/settings.local.json (non versionato: hook SessionStart che esegue lo
    script a ogni avvio, delta riportato in contesto automaticamente)
  - docs/infrastructure-timeline/ingestion-checklist.md (data e nota drift, voce
    ZYXEL XGS2220 corretta in "Mappatura porte fisiche" ALTA, sezione Delta
    23/06->07/07 triata, nota PORT-TAGGING, riepilogo priorita' rigenerato)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (nuova voce 06/07/2026:
    upgrade GroupShare 2020 SR1->SR2+CU15 bloccato su download RWS, da handoff con
    credenziali in chiaro NON riportate; corretti 6 cognomi reali residui nella
    voce Eni VIPA del 16-17/06)
  - .claude/context/roadmap.md (Fase 3 SOSPESA, nuova Fase 1bis CORRENTE)
  - .claude/context/current-work.md (riscritta: focus Fase 1bis, nota PORT-TAGGING)
  - .claude/memory/index.md (punto di ripresa, ancoraggi a 1ad2cb7)
  - frontmatter schede bumpato a 1ad2cb7 (commit dell'utente con ancoraggio+bonifica)
  - _notes/.anonymization-map.md (IP pubblico WINGROUPSHARE, host Seeweb per ruolo,
    nota cognomi Eni)
Motivo: decisione utente del 07/07: sospendere la Fase 3 operativa e completare
prima la timeline cronologica dei due anni di lavoro sulla rete ingerendo il
resto di OneDrive IT. Il delta 23/06->07/07 (checklist ferma al 23/06) e' stato
rilevato, triato in checklist e coperto per la voce ALTA (GroupShare); il
controllo del drift diventa strutturale con script + hook SessionStart. La
questione del tagging porte dei due switch (migrazione centralino cloud) non
e' ancora emersa per intero dai documenti: tracciata come nota PORT-TAGGING,
dettagli attesi dall'utente al momento giusto dell'analisi cronologica.

## 2026-07-07 — Ancoraggio schede e bonifica anonimizzazione file vivi .claude/ (sessione 7)

Commit: PENDING (da fare manualmente)
File toccati:
  - .claude/context/STACK.md, deployment.md, design-and-security.md, dev-testing.md,
    current-work.md, roadmap.md (frontmatter `last-verified` ancorato a 34a9dd7;
    per le prime quattro era il primo ancoraggio da PENDING-FIRST-COMMIT)
  - .claude/context/design-and-security.md (subnet server reale -> 10.61.20.0/24)
  - .claude/context/dev-testing.md (IP iLO reale -> 10.61.1.71)
  - .claude/context/roadmap.md (M9: IP DMZ e IP pubblico -> placeholder; M10: nome
    proprio -> Persona-A; M12: IP switch management -> 10.61.90.37)
  - .claude/memory/progress.md (due IP pubblici reali nelle voci del 01/07 -> placeholder)
  - .claude/rules/anonymization.md (l'esempio della convenzione usava la coppia
    reale/placeholder vera, rivelando la mappatura: sostituito con valori fittizi)
  - .claude/memory/index.md (commit di riferimento e tabella schede)
  - .claude/context/diagrams/firewall-dmz-2026/ (2 drawio su 8 file: username
    reali delle utenze VPN del firewall -> persona-a/b/e/k/l, IP peer Seeweb
    -> 192.0.2.27, subnet remota Seeweb -> 10.77.116.x; sostituzione
    deterministica via script Python, verificata a zero residui)
  - _notes/.anonymization-map.md (voce iLO, utenze VPN, elenco correzioni odierne)
  - _notes/.git-filter-replacements.txt (regole per gli username delle utenze VPN)
Motivo: sync-context a inizio sessione (passo 0, primo ancoraggio). Durante
l'ancoraggio trovati valori reali residui nei file "vivi" sotto `.claude/`,
fuori dal perimetro Fase A del 01/07: corretti al tip secondo la regola di
anonimizzazione (la storia git li conserva; la pulizia resta demandata alla
riscrittura unica post-Fase B, il file di sostituzioni copre tutti i valori).
Gli username delle utenze VPN nei diagrammi erano candidati all'eccezione
operativa dei nomi oggetto letterali, ma su decisione esplicita dell'utente
sono stati anonimizzati come tutto il resto: la traduzione per operare sulla
GUI reale sta nella mappa privata. Restano verbatim, come da eccezione gia'
dichiarata, i soli nomi regola/oggetto contenenti "Elisa" e le caselle
funzionali (mailer@, it@).

## 2026-07-01 — Anonimizzazione Fase A: perimetro network-design (sessione 6, continua)

Commit: PENDING (da fare manualmente)
File toccati (sostituzione deterministica via script, non a mano):
  - docs/firewall-zyxel-usg-flex-500.md, docs/firewall-zyxel-usg-flex-500-live.conf
  - docs/network-diagram.md, docs/telefono-pbx-voip.md
  - docs/infrastructure-timeline/2026-switch-piano-terra.md, GAP-TBC.md
  - CLAUDE.md, .claude/context/STACK.md, .claude/context/deployment.md
  - .claude/context/diagrams/network-topology.mmd
  - .claude/context/diagrams/firewall-dmz-2026/ (8 file drawio/svg)
  - .claude/rules/anonymization.md (nuovo, tracciato: convenzione per sessioni future)
  - _notes/.anonymization-map.md (nuovo, NON tracciato: mappatura reale)
  - _notes/.git-filter-replacements.txt (nuovo, NON tracciato: preparazione riscrittura storia)
Motivo: verificato che il repository e' pubblico su GitHub (HTTP 200 via API non
autenticata). Trovati IP pubblici reali (i blocchi WAN, oggi mappati sui
placeholder 203.0.113.x e 198.51.100.x), IP privati
RFC1918 reali, un MAC address reale e oltre venti occorrenze di nomi propri di
dipendenti e referenti esterni nei file del perimetro network-design attivo,
alcuni presenti da sessioni precedenti a questa. Con conferma esplicita
dell'utente: repository resta pubblico, anonimizzazione completa (inclusi IP
privati e nomi host) da qui in avanti, riscrittura della storia git pianificata
ma rimandata a dopo la Fase B (audit dell'intero repository, registrata come
Fase 3bis in roadmap.md) per evitare due round separati di force-push.
Eccezione deliberata: i nomi di oggetto firewall reali che contengono "Elisa"
restano verbatim per fedelta' operativa (necessari per guidare i prossimi
micro-step sulla GUI); le menzioni narrative della stessa persona sono
anonimizzate in "Persona-I". Il nome e l'email dell'utente (Alessio/asopranzi)
restano reali, coerentemente con il fatto che sono gia' nei metadati di ogni
commit git.
Verificato con grep case-insensitive su tutti i file toccati: nessun residuo.

## 2026-07-01 — M1: correzione guidata regole firewall allow->deny (sessione 6)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/firewall-zyxel-usg-flex-500-live.conf (nuovo — changelog incrementale live del firewall)
  - docs/firewall-zyxel-usg-flex-500.md (FW-001/FW-002 marcate corrette, FW-011 aggiornata, callout di stato)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voce datata 01/07/2026)
  - docs/infrastructure-timeline/GAP-TBC.md (item 54/55 risolti)
  - .claude/context/roadmap.md (M1 marcato Fatto, stato riepilogativo Fase 3 aggiornato)
Motivo: eseguito M1 della roadmap Fase 3, guidando l'utente passo-passo dentro la
Web UI del firewall Zyxel USG FLEX 500 con verifica su screenshot Screenpresso a
ogni passaggio (11 screenshot, screenshot_01.png-screenshot_15.png). Corretta la
regola `Blocco_Gruppo_IP_Phishing_Elisa` (allow->deny, log alert, rimosso
203.0.113.5/IP_09_phishing_2026_Elisa dal gruppo Bad_IP_Phishing_Elisa_2026,
confermato a 11 membri totali) e la regola gemella `malicious_IP_12052025`
(allow->deny). Entrambe verificate scritte sul dispositivo senza necessita' di
un Apply separato. Introdotto su richiesta esplicita dell'utente un changelog
incrementale (`firewall-zyxel-usg-flex-500-live.conf`) che traccia 1:1, con
riferimento agli screenshot, ogni modifica live applicata via GUI, distinto dal
config target del 05/06/2026 (mai applicato in blocco). Rilevate due regole non
censite (BLOCCO_IP_SOSPETTI, EGETRAD_WEB_TEST) da riconciliare in seguito.
Aggiunto anche il gap NEB-001 (switch Nebula segnalati offline in modo
intermittente pur con rete dati funzionante, foto app Nebula dell'utente) con
ipotesi di correlazione a FW-008 (WAN_TRUNK/wan2 morto); nuovi micro-step M20
(diagnosi log) e M21 (ricontrollo dopo M7) in roadmap.md.
Prossimo micro-step: M2 (verifica console seriale/iLO, conferma 802.1Q) o M20
(diagnosi Nebula) a scelta dell'utente.

## 2026-07-01 — Ingestione "[TBC] Diagramma di rete e analisi firewall, centralino" + roadmap ottimizzazione (sessione 5)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/firewall-zyxel-usg-flex-500.md (stato applicazione, sei fasi, registro diagrammi, FW-011/FW-012)
  - docs/network-diagram.md (nota discrepanza NET-007, riferimento diagrammi)
  - docs/telefono-pbx-voip.md (provisioning Vianova Area Clienti, Vianova One, TEL-001)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (voci datate 29/05, 05/06, 09/06)
  - docs/infrastructure-timeline/GAP-TBC.md (item 61/63 risolti, nuovi 97-100, totale 100)
  - docs/infrastructure-timeline/ingestion-checklist.md (voce TBC ingestita, nota riallineamento)
  - .claude/context/roadmap.md (Fase 2 sostanzialmente completa, nuova Fase 3 a 19 micro-step M1-M19, rinumerazione Fase 4/5)
  - .claude/context/current-work.md (riscritto: focus Fase 3, domande aperte/risolte)
  - .claude/context/diagrams/firewall-dmz-2026/ (8 file drawio/svg archiviati, risolve FW-010)
Motivo: ingestione completa della cartella non tracciata "[TBC] Diagramma di rete e
analisi firewall, centralino" (tre snapshot datati 29/05, 05/06, 08/06/2026), su
richiesta esplicita dell'utente di completarla e poi cancellarla. Confermato con
l'utente che il piano di correzione firewall del 05/06/2026 e' una configurazione
target preparata, non ancora applicata al dispositivo fisico: le anomalie critiche
(regola phishing action=allow) restano aperte in produzione. Prodotta una roadmap
tracciata a micro-step (Fase 3) per l'ottimizzazione di Proxmox e del firewall,
sostituendo la Fase 3 generica precedente. Allineamento a
E:\template-claude-developing verificato (gap: skill init-project-system/onboard
e cartella templates/ mancanti) ma importazione rimandata su richiesta dell'utente.
Segnalata nella checklist di ingestione la deriva tra il "Riepilogo priorita'" e
le spunte reali, come richiesto dall'utente per riprendere l'ingestione OneDrive
IT in modo ordinato quando la Fase 3 sara' chiusa.
Cartella sorgente "[TBC] Diagramma di rete e analisi firewall, centralino" non
ancora eliminata: in attesa di conferma finale dell'utente a fine sessione.

## 2026-06-23 — Aggiornamento GAP-TBC e timeline (sessione 4)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/infrastructure-timeline/GAP-TBC.md (aggiunto TBC 68-95: NET, SEC, SCENIA, ISO)
  - docs/infrastructure-timeline/2024-infra.md (aggiunti: Bitdefender, SCENIA start, IntraLino)
  - docs/infrastructure-timeline/2025-q3-q4.md (aggiunti: Serafino, SCENIA→AIDAPT, MFA, Onova VA)
  - docs/infrastructure-timeline/2026-switch-piano-terra.md (aggiunti: Proelium, IntraLino Zep, SCENIA DPA, myOffice riunione)
Motivo: completamento ingestion — tutti gli eventi dal Piano Attività IT v3.xlsx e dai
documenti SCENIA/DPA sono ora mappati nelle timeline. GAP-TBC completo: 95 voci.

## 2026-06-22 — Feature batch e ingestion IT folder (sessione 3)

Commit: PENDING (da fare manualmente)
File toccati:
  - docs/network-diagram.md (nuovo - topologia ASCII completa)
  - docs/runbook-anomalie.md (nuovo - FW-001, FW-002, DMZ, AP, UPS runbook)
  - docs/vendor-management.md (nuovo - tutti i fornitori IT)
  - docs/design-and-security.md (nuovo - SoA ISO27001:2022 Annex A completa)
  - docs/cybersecurity-governance.md (nuovo - timeline 2024-2026 sicurezza)
  - docs/scenia-project.md (nuovo - timeline SCENIA + AIDAPT + DPA status)
  - docs/sviluppo-interno.md (nuovo - IntraLino RAG + scripting)
  - scripts/Check-SecurityAnomalies.ps1 (nuovo - check automatico anomalie)
  - .mcp.json (nuovo - ProxmoxMCP-Plus configurazione)
  - .claude/rules/git-commands-format.md (PowerShell only)
  - .claude/rules/git-identity-and-repo.md (PowerShell only)
  - .claude/PROJECT-SYSTEM.md (wipe script PowerShell)
Motivo: implementazione tutte 6 le feature proposte + 2 doc aggiuntivi timeline
biennale (cybersec-governance, scenia-project, sviluppo-interno).
Ingestion: ARCHITETTURA (10240 par), VA/PT, MFA plan, ISO27001 state, Serafino,
phishing, DPA/DPIA ScenIA, IntraLino Implementazione.docx, MEETINGS WITH AIDAPT.docx.
Template: allineati a Windows PowerShell 5.1 (rimossi blocchi bash/POSIX).

## 2026-06-22 — Inizializzazione del progetto

Commit: PENDING-FIRST-COMMIT
File toccati: tutta la struttura iniziale.
Motivo: creazione del progetto network-design. Struttura `.claude/` canonica dal template
portabile. Script Get-ProxmoxSnapshot.ps1 spostato da C:\Scripts\proxmox-snapshot.
Diagramma network-topology.mmd copiato dallo snapshot v3 di proxmox-snapshot.
Regole e skill copiate dal template. ADR 001-006 registrate. Due layer documentali
(narrativo locale + tecnico versionato). Angolo ISO27001. Skill docx-ingest per
ingestione progressiva dei Word. Agent iso27001-reviewer.
Identita git: asopranzi / asopranzi@intrawelt.com via alias SSH github-corp.
Remote: da configurare su git@github-corp:asopranzi-intrawelt/network-design.git
