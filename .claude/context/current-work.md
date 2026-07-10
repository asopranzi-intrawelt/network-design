---
last-verified: 347f79c
---

# Lavoro corrente: Fase 1bis - Ripresa ingestione OneDrive IT e timeline completa

## Stato

**Pivot del 07/07/2026, deciso dall'utente**: prima di proseguire con i
micro-step operativi della Fase 3 (M2/M20, ora SOSPESI in roadmap), si
completa l'ingestione della cartella OneDrive "Documenti - IT" per costruire
la timeline cronologica dei due anni di ristrutturazione dell'infrastruttura
di rete in massimo dettaglio. La fonte di verita' su cosa e' ingestito e cosa
no e' `docs/infrastructure-timeline/ingestion-checklist.md`, riallineata il
07/07/2026 (riepilogo priorita' rigenerato, delta 23/06-07/07 triato).

**Gestione del delta operativa dal 07/07/2026**: lo script
`scripts/Check-OneDriveDelta.ps1` confronta la cartella OneDrive con una
baseline locale (`_notes/.onedrive-manifest.json`, 44.515 file censiti, non
versionata) e gira automaticamente a ogni avvio di sessione tramite hook
SessionStart in `.claude/settings.local.json`. Quando segnala variazioni:
triage nella checklist, poi rilancio con `-UpdateBaseline`.

**Gia' ingestito dal delta**: `groupshare-upgrade-handoff.md` (upgrade
GroupShare SR1 -> SR2+CU15 bloccato su download RWS) -> voce 06/07/2026 in
`2026-switch-piano-terra.md`, sorgente con credenziali in chiaro non
riportate; `AUDIT_INVENTORY.md` -> `cybersecurity-governance.md`
sezione Crittografia dati a riposo piu' gap #104/SEC-010 (commit 552d96c);
delta SCENIA (Allegati A-L, DPIA compilata, Risposte Tecniche AIDAPT) ->
`scenia-project.md` (commit 594ec07).

## Nota PORT-TAGGING (racconto rimandato a lavori conclusi)

Il tagging dei due switch Nebula (XGS2220-54HP e XGS2220-30HP) per la
migrazione al centralino cloud e' **in corso**: interventi eseguiti
dall'utente il 07/07/2026, evidenze in
`_notes/[TBC] screenshot e note myoffice/` (16 screenshot, 2 foto, note.txt;
gli screenshot si analizzano al momento del racconto). Il racconto completo
arrivera' quando tutti gli endpoint (telefoni) funzioneranno. Gia' tracciati:
voce timeline 07/07/2026 (inclusa l'architettura LAN telefoni dalla nota:
DHCP+gateway Vianova untagged su porta 8, isolati dal firewall, VPN Vianova
verso myOffice — chiude la domanda FW-012), gap NET-008 (#102, VLAN 1 non
taggabile sulla dorsale senza perdere il NAS-HERO) e TEL-002 (#103, telefoni
via vano ascensore non passano le VLAN).

**Mappatura porte fisiche ingestita per intero il 07/07/2026**
(`docs/mappatura-porte-fisiche.md` riscritto): xlsx completo (Piano 0 uffici
1-4, Piano 1 uffici 1-6, Piano 2, colonna "nome porta attuale") piu' il
rilievo manoscritto originale del 20/08/2020 (Luciani Impianti, scansione
PDF letta come immagini). Le etichette delle prese risultano permutate in
modo sistematico gia' dal rilievo 2020 e mai ricorrette: questo rafforza
l'ipotesi che NET-007 (porta telefono di Persona-A) sia un errore di
etichettatura, non uno spostamento fisico. Nelle fonti non c'e' alcuna
informazione VLAN/tagging: la nota PORT-TAGGING passa ora all'utente.

## Prossimi step

1. FATTO: `Mappatura porte fisiche/` ingestita. La nota PORT-TAGGING resta
   in attesa: racconto a lavori conclusi (endpoint telefonici funzionanti),
   evidenze gia' raccolte in `_notes/[TBC] screenshot e note myoffice/`.
2. FATTO (594ec07): voci ALTA della checklist chiuse. Delta SCENIA
   SECURITY/Allegati + DPIA e Risposte Tecniche AIDAPT ingerite in
   `scenia-project.md`.
3. FATTO (07/07, questa sessione): tutte le voci MEDIA del delta ingerite.
   WindTre revisione luglio -> `cybersecurity-governance.md` (sezione sotto
   Questionari B2B, timeline Q3 con BitLocker endpoint dal 03/07, raccordo
   Crittografia); ABBYY.docx -> `2025-q1-server-vianova.md` §Migrazione
   licenze ABBYY + voce 06/11/2024 in `2024-infra.md` + gap #105-106;
   Checklist customer e call AIDAPT 06/07 -> `scenia-project.md`; benchmark
   IntraLino C1-C4 -> `2026-switch-piano-terra.md` §Benchmark DoE IntraLino
   + gap #107.
4. FATTO (08/07): tutte le MEDIA preesistenti ingerite (Veeam -> q1 2025 +
   BCD; Odoo restore 28/05 -> q2 2025 + helpdesk; Interrogare Odoo e API
   CRM -> helpdesk; Appina e Pi-hole -> q3-q4 2025; Proelium -> vendor
   management; gap #105 esteso a Veeam/Odoo; bonificati tre residui IP
   reali in vendor-management, BCD e q3-q4).
5. FATTO (09/07): tutta la coda BASSA della checklist percorsa e chiusa.
   Emersi cinque fatti sostanziali: Vademecum urgenze (9 casi guasto + scala
   reperibilita') in business-continuity-disaster-recovery.md; replica NAS
   HERO su Azure Blob (QNAP HBS/QuDedup) nello stesso file; gap ambientale
   RAEE mai risolto (GAP-TBC #109/ENV-001); procedura di audit mailbox via
   M365 Purview eDiscovery in cybersecurity-governance.md; quattro studi AI
   mai implementati (Cheshire Cat, Google Antigravity, Obsidian vs IT Glue,
   Claude Subagents) in sviluppo-interno.md. Confermato che i due PDF da
   1506+415 pagine in IntraLino_Knowledge sono i report Nessus grezzi alla
   base del VA Onova nov 2025 gia' sintetizzato, nessuna nuova ingestione.
   Corretti due IP reali non anonimizzati (uno pre-esistente, due miei
   propri prima della correzione) in business-continuity-disaster-recovery.md;
   il resto del repository resta con IP reali non anonimizzati, questione
   nota e rimandata alla Fase B (roadmap.md), non toccata in questa sessione.
   La coda checklist e' ora solo le attese esterne (PORT-TAGGING, fonte
   IntraLino su VM).
6. FATTO (09/07, questa sessione): tre file sciolti mai apriti nella root di
   ARCHITETTURA SERVER-CLOUD-LINEE ingeriti. L'html "anni vecchi" ha dato
   un nuovo file dedicato `2025-storage-anni-vecchi.md` (66 movimenti
   datati). Il collegamento `.lnk` ha rivelato una libreria OneDrive
   separata mai censita, `IT + Administration - Documenti` (742 file,
   fornitori/amministrazione): aggiunta al perimetro di
   `Check-OneDriveDelta.ps1` (ora multi-target) e censita in una nuova
   sezione della checklist con priorita' assegnate, NON ancora ingerita.
   Prossimo blocco: le 4 voci ALTA di quella libreria (VIANOVA, ZYXEL,
   MyOffice, Analisi Domini Intrawelt).
7. FATTO (09/07, stessa sessione): le 4 voci ALTA ingerite. Novita' vendor
   Fastnet (DNS/hosting Plesk), offerta Vianova 07/02/2024, causa radice
   crisi licenze ZYXEL, incidente UPS 01/07/2025. Deliberatamente NON
   ingerita `MyOffice/Transizione centralino cloud 2026/` (si sovrappone
   alla nota PORT-TAGGING riservata a fine lavori). Prossimo blocco: voci
   MEDIA della stessa libreria (QNAP cloud license, Aruba, Seeweb, Punto
   Informatica, AWS) su indicazione dell'utente.
8. Ogni scrittura in file tracciato segue `.claude/rules/anonymization.md`
   (verificare con grep prima di chiudere il passo); i documenti voluminosi
   si ingeriscono con `docx-ingest` a disclosure progressiva.
9. Alla chiusura di ogni blocco: spunta in checklist, voce in
   `memory/progress.md`, commit manuale dell'utente.

## Domande aperte non risolte

- IntraLino: la documentazione Claude del progetto vive su una VM che
  l'utente fornira' come contesto (nota 08/07/2026, vedi roadmap Fase 1bis);
  fino ad allora le sezioni IntraLino restano parziali e il gap #107 aperto.
- PORT-TAGGING: dettagli del tagging dei due switch (input utente atteso).
  Nota 09/07: la sottocartella `MyOffice/Transizione centralino cloud 2026/`
  (742 file della libreria Administration) si sovrappone a questo tema e
  NON e' stata ingerita per lo stesso motivo — resta in attesa della stessa
  indicazione.
- Contraddizione porta/switch telefono di Persona-A (NET-007, M10): la
  mappatura porte 2020-2026 documenta permutazioni sistematiche di etichette
  mai ricorrette, ipotesi errore di etichettatura rafforzata.
- Testo IVR centralino cloud non ancora comunicato a myOffice (TEL-001, M17).
- Funzione porta 8 "Vianova DHCP server fonia" (FW-012, M11).
- GroupShare: download installer SR2 bloccato, email a support@rws.com da
  inviare (fuori scope progetto rete, tracciato in timeline).
- Allineamento a `E:\template-claude-developing` rimandato.

### Nuovo (09/07/2026): pendenze emerse dall'ingestione della libreria Administration

- RISOLTO (09/07): l'utente ha ricordato che il repository pubblico non deve
  esporre nessuna informazione aziendale, "neanche di tipo amministrativo".
  Aggiunta una sezione dedicata a `.claude/rules/anonymization.md` (importi
  contrattuali, prezzi, numeri di fattura/ordine/preventivo, numeri di
  linea telefonica, IBAN, P.IVA di terzi non vanno mai in un file
  tracciato). Bonificato tutto quanto scritto nella libreria Administration
  oggi, e per bonus anche alcuni casi pre-esistenti trovati durante il
  controllo: due nomi propri Proelium che una sessione precedente aveva
  lasciato "per la Fase B" (ora corretti, la decisione e' stata superata),
  un numero di preventivo Zyxel/Vianova, e un caso serio non collegato
  all'ingestione di oggi — le ultime 4 cifre reali di una carta di credito
  aziendale e un MAC address reale, scritti in chiaro in `2024-infra.md`
  fin da una sessione precedente. Gli IP reali pre-esistenti nel resto del
  repository restano il workstream separato della Fase B, non toccati.
- RISOLTO (09/07): la presunta discrepanza di date Vianova non era un
  errore ma due migrazioni distinte confuse in un'unica tabella — linea
  dati (2025, TIM→Vianova) e centralino cloud (dic.2025-2026, in corso).
  `vendor-management.md` §Vianova riscritto con le due evoluzioni separate.
- **Gap di sicurezza reale non risolto** (GAP-TBC #110/SEC-012): una access
  key IAM AWS con `AdministratorAccess`, creata nel 2019, **senza MFA**, e'
  ancora attiva e ha generato una chiamata anomala ad Amazon Translate la
  cui origine (quale PC/VM/script la usa) non e' mai stata identificata.
  La mitigazione applicata e' stata solo una Deny Policy sull'azione
  `translate:*`, non la rotazione della chiave: il rischio di fondo
  (credenziali admin AWS storiche, non ruotate, di provenienza incerta)
  resta aperto. Azione operativa suggerita, non eseguita: identificare e
  ruotare/disattivare quella access key.
- RISOLTO (10/07): **Certificato SSL VPN ZeroSSL cancellato** (GAP-TBC
  #111/SEC-013). La connessione TCP/443 verso `vpn.intrawelt.com` non
  rispondeva (timeout) perche' e' un hostname di una configurazione VPN
  precedente ormai superata: l'utente ha confermato che l'accesso VPN
  attuale passa dal firewall Zyxel USG FLEX 500 (SSL VPN / ZyWALL
  SecuExtender), non piu' da quell'hostname dedicato. La cancellazione del
  certificato ZeroSSL e' coerente con la dismissione del vecchio servizio.
- **Restituzione router Huawei a TIM**: TIM ha confermato la cessazione del
  noleggio il 12/06/2025 ma non ha mai risposto (solleciti 24/06 e
  25/07/2025) su dove restituire i due router (AR1200, NetEngine AR600).
  Stato non aggiornato nella fonte consultata.
- RISOLTO (09/07): **Certificato wildcard `intrawelt.com`**. Verificato live
  via TLS: `intrawelt.com` ha un certificato Let's Encrypt valido senza
  wildcard (SAN: intrawelt.com/.it, www.intrawelt.com/.it), coerente con la
  nota Fastnet dell'11/05/2026. `scenia.intrawelt.com` ha un certificato
  Let's Encrypt **dedicato** emesso lo stesso giorno: non dipende (piu') dal
  wildcard ed e' correttamente coperto. Scoperta collaterale: una voce hosts
  locale su questa macchina reindirizza `intrawelt.com`/`www.intrawelt.com`
  a VM206 "intrasite" (10.61.20.23) per uso interno/di test, con certificato
  auto-firmato — non e' un problema sul sito pubblico reale. Aggiunto a
  `design-and-security.md` §VM206 e `scenia-project.md` §Architettura domini.
- **Progetto di rebranding** citato in un thread email sul rinnovo di
  `intrawelt.de` (dic. 2025) come motivo per cui il rinnovo era stato
  inizialmente disattivato: nessun altro dettaglio nella fonte, non
  ricollegato a nessun documento esistente.
- **Fase B anonimizzazione** (roadmap.md): il 10/07 fatta una bonifica
  meccanica (script Python, sostituzione di prefisso) degli IP reali
  192.168.x.x, 10.1.116.x, 5.98.88.x, 31.197.194.x, 193.124.241.x,
  195.96.193.x, 193.30.116.x, 212.35.202.x su tutti i file dove il grep
  esteso del 09/07 li aveva confermati (helpdesk-operations.md,
  2023-baseline.md, 2024-infra.md, 2025-q1-server-vianova.md,
  2025-q2-migrazione-tim-vianova.md, 2025-q3-q4.md, it-backlog.md,
  runbook-anomalie.md, sviluppo-interno.md, vendor-management.md,
  vulnerability-assessment-nov2025.md, firewall-zyxel-usg-flex-500.md) piu'
  due seriali dispositivo reali e un MAC reale residuo. Corretti anche a
  mano diversi nomi propri reali non ancora in placeholder in
  2023-baseline.md, 2024-infra.md, 2025-q1/q2/q3-q4.md,
  business-continuity-disaster-recovery.md, helpdesk-operations.md,
  it-backlog.md, vendor-management.md (Persona-P/R/H/E/O/F/J/M/K/N).
  Confermato dall'utente il 10/07 di proseguire il sweep completo: fatto
  anche per Persona-A e Persona-J su cybersecurity-governance.md,
  scenia-project.md, helpdesk-operations.md, le timeline 2024/2025-q1/q2/q3-q4,
  vendor-management.md, business-continuity-disaster-recovery.md, mantenendo
  reale solo la ragione sociale legale "Intrawelt di Alessandro Potalivo &
  C. Sas" dove compare letteralmente (e' un dato di registro, non narrativo).
  **RISOLTO (10/07)**: sweep esteso a tutto l'albero `docs/` e
  `.claude/context/`, non solo ai file gia' segnalati dal 09/07. Trovati e
  bonificati un registro firme dipendenti con 21 nomi reali in chiaro
  (cybersecurity-governance.md, 13 nuovi placeholder Persona-V..AJ
  aggiunti alla mappa), i referenti di Vianova/myOffice/Fastnet/Novadys/
  ABBYY/Proelium/BioStar2/Fibercop/RWS mai messi in placeholder nelle
  timeline 2024/2025 (nuovi Referente-Vianova-5/6, Referente-Fibercop-1,
  Referente-RWS-1), hostname PC-GIORDANO/PC-Tommaso, e 4 numeri di
  telefono reali residui (rimossi per policy amministrativa, non solo
  anonimizzati). Verificato con grep esteso finale: nessun IP 192.168.x.x,
  nessun MAC reale, nessun nome della mappa privata rimasto in chiaro nei
  file tracciati, salvo le eccezioni deliberate (ragione sociale legale,
  nomi di file sorgente citati per tracciabilita'). Fase B non e' chiusa
  (resta la riscrittura della storia git, pianificata a parte), ma il
  contenuto attualmente in HEAD e' pulito.
- RISOLTO (09/07): coda BASSA della libreria Administration chiusa per
  intero (Google Cloud abortito, Openforce, Eter, TREX, MICROSOFT, ZeroSSL,
  Rinnovo marchi, Savelli, foto sala server, file sciolti root, contabilita'
  varia). Trovati: preventivo Openforce migrazione Odoo v18 con nuovo
  contatto tecnico, pressione fee Odoo +25% dal 2026, razionale difesa a
  tre livelli (Defender/Bitdefender/Zyxel), nuovo gap #111/SEC-013
  (certificato SSL VPN ZeroSSL cancellato 10/02/2026, esito non chiaro —
  aggiunto alla lista qui sopra). L'unica eccezione resta la sottocartella
  riservata `MyOffice/Transizione centralino cloud 2026/`.
- **Ambizione originaria della sessione — ARCHITETTURA.docx completato,
  gli altri tre ridimensionati**: ARCHITETTURA.docx (sec-005/006/008/009)
  e' stato interamente ri-estratto (10/07). Iniziata poi la stessa
  ri-estrazione su MICROSOFT 365.docx (1419 paragrafi): dopo un primo
  passaggio, confermato con l'utente di passare a una modalita' veloce
  (solo novita' rilevanti) perche' il file e' un quaderno di procedure
  IT generiche (SharePoint/Exchange/deleghe caselle/gestione turni-ferie
  HR) con moltissime credenziali in chiaro e forte overlap con
  helpdesk-operations.md gia' esistente. Unico risultato di valore:
  GAP-TBC #113 (licenza M365 Business Standard priva di Intune/MDM).
  Verificato lo skeleton di TREX.docx e STUDIO-RWS-GROUPSHARE.docx: stesso
  pattern (troubleshooting applicativo Odoo/Trados con credenziali dense,
  poco valore "network design", gia' in gran parte coperto). Conclusione:
  la ri-estrazione esaustiva riga-per-riga vale solo per ARCHITETTURA.docx
  (storia hardware/infrastruttura); per gli altri tre la sintesi gia'
  scritta resta la fonte di riferimento salvo richiesta esplicita di
  scavare un punto preciso.
