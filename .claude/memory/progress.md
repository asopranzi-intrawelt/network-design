# Work-log

> Append-only, in ordine cronologico inverso (la voce piu recente in alto). Ogni passo
> significativo di codice e ogni intervento manuale rilevante lascia una voce con data, file
> toccati, motivo e commit di riferimento.

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
