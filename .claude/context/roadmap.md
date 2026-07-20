---
last-verified: 347f79c
---

# Roadmap e fasi del progetto

## Fase 0 - Inizializzazione (COMPLETATA)

- Struttura progetto e template `.claude/` canonica
- Script snapshot Proxmox v3 integrato
- Snapshot infrastruttura v3 come baseline corrente
- Due layer documentali (narrativo + tecnico) configurati
- Primo commit e push su git@github-corp:asopranzi-intrawelt/network-design.git

## Fase 1 - Ricostruzione storia della rete (COMPLETATA)

Documento Word principale (ARCHITETTURA SERVER-CLOUD-LINEE 20052026.docx) ingestato
con strategia a disclosure progressiva. Estratte 12 sezioni prioritarie.

Output prodotto in `docs/infrastructure-timeline/`:
- 2023-baseline.md: stato di partenza pre-IT-manager
- 2024-infra.md: ottobre-dicembre 2024
- 2025-q1-server-vianova.md: gennaio-marzo 2025
- 2025-q2-migrazione-tim-vianova.md: aprile-giugno 2025 (switch WAN, tunnel SEEWEB)
- 2025-q3-q4.md: luglio-dicembre 2025
- 2026-switch-piano-terra.md: gennaio-giugno 2026
- GAP-TBC.md: 53 TBC censiti con fonte probabile

Credenziali e IP pubblici anonimizzati per repo pubblico su GitHub.

Documenti Word secondari da ingestare (rimandati a Fase 2):
- Mappatura porte fisiche
- Telefono-PBX
- ZYXEL FIREWALL e VPN
- [TBC] Diagramma di rete

## Fase 2 - Documentazione stato corrente (COMPLETATA il 10/07/2026)

Obiettivo: documentare in modo completo la rete attuale integrando snapshot Proxmox
con configurazioni switch, firewall, AP e NAS. Produrre un diagramma di rete completo.

Steps:

1. **Fatto.** Documenti Word secondari della cartella ARCHITETTURA SERVER-CLOUD-LINEE
   ingestati (Telefono-PBX, ZYXEL FIREWALL e VPN, licenze). Il documento
   "[TBC] Diagramma di rete e analisi firewall, centralino" (cartella separata in
   radice progetto, non OneDrive) e' stato ingestato integralmente il 01/07/2026:
   vedi `docs/infrastructure-timeline/ingestion-checklist.md` e i riferimenti
   incrociati in `docs/firewall-zyxel-usg-flex-500.md`, `docs/network-diagram.md`,
   `docs/telefono-pbx-voip.md`.

2. **Fatto 08/07/2026.** Snapshot v4 eseguito dall'utente
   (`Get-ProxmoxSnapshot.ps1`): scheda `design-and-security.md` aggiornata,
   gap #106/#107 riconciliati, nuovo #108 (IP nodo = iLO nello stato
   cluster). Resta M18 per il re-run post-M5/M16.

3. **Fatto.** Configurazione switch Zyxel via Nebula documentata in
   `docs/network-diagram.md` e `docs/infrastructure-timeline/2026-switch-piano-terra.md`
   (XGS2220-54HP Piano 2, XGS2220-30HP Piano Terra installato aprile 2026,
   dorsale 10 Gbps operativa dall'08/05/2026).

4. **Fatto, ma piano non applicato.** Configurazione firewall Zyxel USG FLEX 500
   documentata in dettaglio in `docs/firewall-zyxel-usg-flex-500.md` (zone,
   interfacce, VPN, NAT, security policy, dieci anomalie FW-001/FW-010). Il piano
   di correzione a sei fasi (05/06/2026) resta da applicare: vedi Fase 3.

5. NAS fleet: stato RAID, capacita', job backup, versioni firmware. **Fatto
   10/07/2026**: inventario sistematico consolidato in `vendor-management.md`
   §QNAP – NAS (RAID, capacita', ruolo, backup per ciascuno dei 5 dispositivi).
   Resta [TBC] solo la versione firmware, non riportata in nessuna fonte.

6. **Fatto.** `docs/network-diagram.md` con diagramma ASCII della topologia corrente.
   Consolidamento in Mermaid versionato (`context/diagrams/network-topology.mmd`)
   rimandato alla fine della Fase 3, per aggiornarlo una sola volta con lo stato
   finale invece che a ogni micro-intervento (vedi nota "Diagramma vivo" sotto).

7. **Fatto 10/07/2026.** Gap analysis ISO27001 Annex A ampliata in
   `design-and-security.md` da 5 a 10 controlli, incrociando lo snapshot
   Proxmox v4, il piano firewall a micro-step e `GAP-TBC.md` (nuove righe:
   A.8.21 VPN IKEv1, A.8.1 endpoint/Intune, A.8.13 backup NAS, A.7.1 badge
   sala server, A.8.24 crittografia). Non e' una Statement of Applicability
   formale (resta in Fase 5).

## Fase 3 - Ottimizzazione Proxmox e firewall: roadmap a micro-step (RIPRENDIBILE dal 10/07/2026)

Sospensione originaria: su decisione dell'utente del 07/07/2026 i micro-step
operativi (M2 in avanti) erano in pausa finche' non fosse completata la
ripresa dell'ingestione OneDrive (Fase 1bis sopra). La condizione di
sblocco si e' verificata il 10/07/2026: la fase e' quindi riprendibile, ma
la maggior parte dei micro-step da M2 in poi richiede accesso fisico
all'hardware di rete reale (console seriale, cablaggio, iLO) che l'agente
non puo' eseguire da remoto — vanno guidati passo passo con l'utente in
sede. M1 resta l'unico micro-step chiuso.

Obiettivo: applicare le correzioni e le ottimizzazioni identificate dall'analisi
firewall/DMZ/Proxmox, un micro-step alla volta, con commit e aggiornamento di
`memory/progress.md` a ogni step chiuso. Ogni riga della tabella e' un intervento
singolo, verificabile, con un solo esito atteso: non si passa alla riga successiva
finche' quella corrente non e' verificata o esplicitamente rimandata con nota.

### Diagramma vivo

In parallelo a ogni micro-step, `docs/network-diagram.md` e la tabella diagrammi
di `docs/firewall-zyxel-usg-flex-500.md` si aggiornano con una nota testuale del
cambiamento (non un nuovo diagramma renderizzato a ogni step, per non consumare
token inutilmente). Il diagramma Mermaid consolidato in
`.claude/context/diagrams/network-topology.mmd` si rigenera una sola volta, a
fine Fase 3, riflettendo lo stato finale post-ottimizzazione; i drawio/svg
intermedi restano come riferimento storico in `context/diagrams/firewall-dmz-2026/`.

### Version control

Ogni micro-step chiuso corrisponde a un commit separato (manuale, a cura
dell'utente secondo `.claude/rules/git-commands-format.md`), cosi' che la
storia git rispecchi la sequenza degli interventi fisici sulla rete e non un
unico commit cumulativo di fine fase.

### Micro-step tracciati

| # | Intervento | Priorita' | Gap/fonte | Dipendenza | Stato |
|---|-----------|-----------|-----------|------------|-------|
| M1 | Correggere `Blocco_Gruppo_IP_Phishing_Elisa` (allow -> deny) e `malicious_IP_12052025` (allow -> deny) via GUI firewall, fuori finestra di manutenzione | CRITICA | FW-001, FW-002 (Fase 0 del piano) | Nessuna | **Fatto 01/07/2026** |
| M2 | Verificare fisicamente console seriale (115200 baud) e accesso iLO; confermare supporto 802.1Q su XGS2220-54HP | ALTA | Fase 1 del piano | M1 | Parziale 13/07/2026: accesso iLO5 recuperato (password root perduta, reset via hponcfg dal sistema operativo, nessun riavvio del server) e connessione SSH all'iLO configurata da questa macchina. Restano da verificare console seriale e supporto 802.1Q |
| M3 | Backup datato di firewall e switch prima di ogni modifica strutturale | ALTA | Fase 1 del piano | M2 | Da fare |
| M4 | Configurare VLAN 201 sullo switch Piano 2 (P7 access, porta Proxmox trunk) | ALTA | Fase 2 del piano, FW-009 | M3 | Da fare |
| M5 | Configurare bridge-vlan-aware su Proxmox (`ifreload -a` da iLO), VM di test con tag 201 | ALTA | Fase 3 del piano | M4 | Da fare |
| M6 | Cablare P7 verso lo switch, validare L2 con `arping`/`tcpdump` | ALTA | Fase 4 del piano | M5 | Da fare |
| M7 | Caricare la configurazione target dal seriale (rimozione WAN_TRUNK, rimozione LAN2 e rotte statiche, attivazione DMZ, pubblicazione web `wan1:2`) | CRITICA | Fase 5 del piano, FW-004, FW-008, FW-009 | M6 | Da fare |
| M8 | Verifica post-applicazione nell'ordine di impatto utente (LAN, SSL VPN, IPsec, VM DMZ) + 48h di osservazione log | ALTA | Fase 6 del piano | M7 | Da fare |
| M9 | Prima VM DMZ operativa (nginx reverse proxy 10.61.201.10, esposta su 203.0.113.3) | MEDIA | Piano_Operativo_Migrazione.docx | M8 | Da fare |
| M10 | Verificare quale switch ospita realmente la porta del telefono di Persona-A (contraddizione Piano 2 vs Piano Terra) prima di chiudere la mappatura IP/MAC telefoni | MEDIA | NET-007, GAP-TBC #67 | Nessuna (indipendente dal piano firewall) | Da fare |
| M11 | Verificare la funzione della porta 8 riconfigurata "Vianova DHCP server fonia" (PVID 2) e valutare se sostituisce la rimozione del DHCP server classe .90 | MEDIA | FW-012 | M10 | Parziale 07/07/2026: funzione confermata (DHCP+gateway Vianova untagged, isolati dal firewall); resta la valutazione sul DHCP .90 |
| M12 | Rimuovere il DHCP server residuo classe .90 e spostare lo switch di management (10.61.90.37) sulla VLAN corretta | ALTA | NET-001, NET-004, NET-005 | M11 | Da fare |
| M13a | Fase A rete Wi-Fi: isolare la Wi-Fi staff esistente creando una VLAN dedicata sulle tre porte switch gia' localizzate (XGS2220-30HP porta 1, XGS2220-54HP porte 41/45), con ACL firewall verso VLAN 10 management — nessun accesso agli AP richiesto, i tre Ubiquiti EOL restano cosi' come sono | MEDIA | NET-005 | M12 | **Tentato e ripristinato il 16/07/2026** — vedi `runbook-anomalie.md` §NET-005 "Incidente 16/07/2026" per il resoconto completo. Firewall lato configurazione resta pronto e applicato (interfaccia `vlan40`+DHCP, zona `WIFI_STAFF`, security policy, pulizia 9 regole disattivate — nessuno di questo e' stato rollbackato, resta valido per un nuovo tentativo). Lato switch: le tre porte AP spostate su VLAN 40 hanno smesso di trasmettere SSID (confermato con due dispositivi diversi, nessuna rete visibile in scansione), causa non determinata (i tre AP restano inaccessibili, nessuna diagnostica lato dispositivo possibile); ripristinate a VLAN 1 e servizio confermato tornato. Ipotesi principale: l'assunzione "lo switch tagga in modo trasparente, l'AP non deve sapere nulla di VLAN" non regge per questo hardware EOL specifico. **Secondo tentativo mirato (stesso giorno)**: scoperta rilevante — la sincronizzazione Nebula-switch e' inaffidabile su un solo switch (il 54HP, dove vivono PianoPrimo/PianoSecondo), non su entrambi. Approfondito NEB-001 con `Get-NebulaConnectivityHistory.ps1` (nuovi endpoint connectivity/event-logs): nessuna disconnessione cloud rilevata, ma il 54HP mostra migliaia di link-flap non documentati sulla porta 46 (nuovo gap NET-010) mentre il 30HP (PianoTerra) risulta pulito e coerente in ogni sua operazione. Prossimo passo: diagnosticare la porta 46 prima di fidarsi di nuove scritture sul 54HP; PianoTerra resta un candidato ragionevole per un nuovo tentativo con osservazione prolungata |
| M13b | Fase B rete Wi-Fi: pianificare la sostituzione dei tre AP Ubiquiti EOL (non gestibili, credenziali perse, dashboard web mai esistita) con AP Zyxel Nebula multi-SSID, che assorbono anche la copertura guest (DPPSK + VLAN dedicata) invece di affiancare un AP guest isolato ai tre legacy | MEDIA | AP-001 | M13a | Preventivo scelto il 20/07/2026 (Punto Informatica, 3x Zyxel NWA130BE-EU0101 Wi-Fi 7, dettaglio in `runbook-anomalie.md` §AP-001); EsternoIrrigazione fuori scope; acquisto/consegna non ancora confermati |
| M14 | Aggiornare le VPN IPsec da IKEv1/AES-128/SHA-1/DH2 a parametri correnti; chiarire se PSE-SEEWEB e WIZ_VPN sono transizione o residuo | MEDIA | FW-006, FW-007 | M8 | Da fare |
| M15 | Attivare firewall Proxmox con policy di default DROP | MEDIA | Fase 3 originale (roadmap storica) | M9 | Da fare |
| M16 | Dismissione HP G5 (VMware ESXi) e migrazione VM residue su Proxmox | MEDIA | GAP-TBC #10, #195 (sec-007) | Indipendente | Da fare |
| M17 | Rispondere a myOffice sul testo IVR (giorno: attesa semplice o instradamento reparti; notte: orari) e completare la migrazione centralino cloud | MEDIA | TEL-001, GAP-TBC #47 | Indipendente (traccia telefonia, non firewall) | Da fare |
| M18 | Rigenerare `output/proxmox-snapshot.json` con `Get-ProxmoxSnapshot.ps1` per fotografare lo stato Proxmox post-M5/M16 | ALTA | Fase 2 step 2 | M5, M16 | Da fare |
| M19 | Consolidare il diagramma Mermaid finale (`network-topology.mmd`) con lo stato post-ottimizzazione e riconciliare tutte le schede tecniche coinvolte | BASSA (fine fase) | Chiusura Fase 3 | M1-M18 | Da fare |
| M20 | Diagnosticare l'intermittenza "offline" degli switch su Nebula (rete dati funzionante, solo il canale di gestione cade): raccogliere orari degli eventi offline da Nebula e correlarli con i log del firewall (failover wan2, eventi SSL inspection sul traffico verso il cloud Zyxel) | MEDIA | NEB-001 | Nessuna (diagnosi indipendente da M1-M9) | Da fare |
| M21 | Ricontrollare M20 dopo l'esecuzione di M7 (rimozione WAN_TRUNK): se l'intermittenza sparisce, FW-008 era la causa; se persiste, approfondire l'ipotesi SSL inspection | MEDIA | NEB-001 | M7, M20 | Da fare |
| M22 | Valutare e pianificare la segmentazione reale della LAN principale: oggi `lan1`/`lan1:1`/`lan1:2` (PC .10, server .20, stampanti .30) sono alias IP nella stessa `/19` flat, nessuna VLAN separata tra le tre classi. VLAN dedicate + zone/ACL firewall separate, stesso pattern di M13a | MEDIA | NET-009 | M13a (pattern collaudato prima sulla Wi-Fi) | Da pianificare (identificato 15/07/2026 durante la guida GUI di Fase A) |

## Fase 1bis - Ripresa ingestione OneDrive IT e timeline completa (SOSTANZIALMENTE COMPLETATA il 10/07/2026)

Obiettivo: completare l'ingestione della cartella OneDrive "Documenti - IT"
secondo `docs/infrastructure-timeline/ingestion-checklist.md` (riepilogo
priorita' rigenerato il 07/07/2026), estraendo in massimo dettaglio la storia
cronologica dei due anni di ristrutturazione dell'infrastruttura di rete.
Il drift della cartella e' controllato a ogni avvio di sessione da
`scripts/Check-OneDriveDelta.ps1` (hook SessionStart, baseline non versionata
in `_notes/`). Primo obiettivo: `Mappatura porte fisiche/` e la nota
PORT-TAGGING della checklist (tagging dei due switch per la migrazione al
centralino cloud, dettagli attesi dall'utente quando l'analisi arriva a quel
punto). Ordine di lavoro: voci ALTA, poi delta 23/06-07/07, poi MEDIA in
ordine cronologico delle fonti.

Fonte aggiuntiva pianificata (nota utente dell'08/07/2026): IntraLino come
progetto aziendale va caricato dalla sua documentazione Claude dedicata, che
vive su una VM; l'utente fornira' quel contesto in una sessione futura.
Fino ad allora le sezioni IntraLino gia' scritte (architettura n8n in
`2026-switch-piano-terra.md`, benchmark DoE, sezione in
`helpdesk-operations.md`) valgono come parziali, ricostruite dai soli
frammenti OneDrive, e il gap #107 (natura degli host .58/.60) resta aperto
in attesa di quella fonte.

**Stato al 10/07/2026**: coda ALTA, delta 23/06-07/07 e coda MEDIA/BASSA
chiuse. ARCHITETTURA.docx ri-estratto integralmente (sec-005/006/008/009).
MICROSOFT 365.docx, TREX.docx e STUDIO-RWS-GROUPSHARE.docx verificati:
non giustificano la stessa ri-estrazione esaustiva (vedi `current-work.md`).
Restano aperti solo i due elementi deliberatamente riservati: la nota
PORT-TAGGING (racconto a lavori conclusi) e la fonte IntraLino su VM
(sessione futura, dipende dall'utente). Nessun'altra azione autonoma
possibile su questa fase.

## Fase 3bis - Anonimizzazione repository pubblico (AVVIATA)

Il repository e' pubblico su GitHub (verificato via API il 01/07/2026). Fase A
completata il 01/07/2026: anonimizzati IP pubblici/privati, MAC address e nomi
propri nei sei file del perimetro network-design attivo (`firewall-zyxel-usg-flex-500.md`
e `-live.conf`, `network-diagram.md`, `telefono-pbx-voip.md`,
`2026-switch-piano-terra.md`, `GAP-TBC.md`), piu' `CLAUDE.md`, `STACK.md`,
`deployment.md`, `network-topology.mmd` e gli 8 diagrammi archiviati in
`context/diagrams/firewall-dmz-2026/` (stesso IP Proxmox, corretto per
contatto diretto). Convenzione documentata in `.claude/rules/anonymization.md`,
mappatura reale privata in `_notes/.anonymization-map.md` (non versionata).

Fase B, da fare: audit completo del resto del repository (SCENIA, cybersecurity,
helpdesk, timeline storica pre-2026, onboarding/offboarding) per lo stesso tipo
di dati — IP, MAC, nomi propri di dipendenti e clienti accumulati su piu'
sessioni. E' un lavoro della stessa scala dell'ingestione iniziale, da trattare
come workstream a parte, non da fare di fretta in coda a un'altra sessione.

**Priorita' alta separata dentro la Fase B (09/07/2026)**: durante un audit
di dati amministrativi/commerciali (vedi sezione dedicata in
`.claude/rules/anonymization.md`) e' emerso che `2024-infra.md` conteneva,
gia' da una sessione precedente, le ultime 4 cifre reali di una carta di
credito aziendale e un MAC address reale (rinnovo licenza Zyxel del
20/11/2024) — corretti nel file tracciato lo stesso giorno, ma ancora
presenti in un commit precedente della storia git. A differenza del resto
degli IP interni (dati di rete, rischio piu' basso e generico), questo e'
un dato di pagamento: quando si esegue la riscrittura della storia (dopo
il completamento della Fase B), questo commit va incluso esplicitamente
nel file di sostituzioni `_notes/.git-filter-replacements.txt` con
priorita' maggiore rispetto al resto.

Riscrittura della storia git: pianificata **una sola volta**, dopo che anche la
Fase B e' completa, invece che due round separati di force-push. I comandi
`git filter-repo` con il file di sostituzioni sono preparati in
`_notes/.git-filter-replacements.txt` (non versionato, da estendere durante la
Fase B) e vanno eseguiti dall'utente, mai dall'agente: e' un'operazione che
riscrive quasi tutta la storia del repository (il valore piu' vecchio risale
al secondo commit del progetto) e richiede force-push coordinato.

**Deroga puntuale (17/07/2026, ADR-011)**: la voce Fibercop/Referente-Fibercop-1 e'
uscita dal round unico per richiesta esterna del CIRST Fibercop e va
eseguita come round di riscrittura storia a se', prima del resto della
Fase B. Non re-includerla nel round finale, e' gia' rimossa a parte.

## Fase 4 - Piano interventi futuri residui (DA PIANIFICARE)

Steps non coperti dalla Fase 3, da pianificare dopo la chiusura dei micro-step
sopra:
1. Patch management documentato (Proxmox, switch Nebula, firewall, NAS firmware)
2. Procedure backup e disaster recovery formali
3. Inventario sistematico NAS fleet (RAID, capacita', firmware)
4. Ripresa dell'ingestione della cartella OneDrive IT (sospesa su richiesta
   esplicita dell'utente per dare priorita' alla Fase 3; vedi nota di
   riallineamento in `ingestion-checklist.md`)

## Fase 5 - Documentazione ISO27001 operativa (DA PIANIFICARE)

**Obiettivo dichiarato dall'utente il 16/07/2026: ottenere la certificazione
ISO27001 entro marzo 2027.** Da questa data in avanti, ogni micro-step di
rete (non solo quelli esplicitamente etichettati Fase 5) va letto anche
con l'angolo ISO27001 quando rilevante — un gap di segmentazione, un
controllo di accesso, un flusso dati non presidiato sono materiale
Annex A a prescindere da quando la Fase 5 formale comincia. Vedi
`current-work.md` per la direttiva permanente sui cinque livelli di
tracciamento richiesti a ogni passo.

Steps:
1. Statement of Applicability per i controlli Annex A di rete
2. Risk assessment per i gap identificati (A.8.20, A.8.22, A.8.16, A.5.37, A.8.8)
3. Procedure operative per interventi ricorrenti (backup, patching, accessi VPN)
4. Incident response per scenari rilevanti (basato su evento phishing 08/01/2026)

## Stato riepilogativo

| Fase | Stato | Priorita' |
|---|---|---|
| Fase 0 | COMPLETATA | Alta |
| Fase 1 | COMPLETATA | Alta |
| Fase 2 | COMPLETATA il 10/07/2026 (NAS fleet e gap analysis ISO27001 Annex A chiusi) | Alta |
| Fase 1bis | Sostanzialmente completata il 10/07/2026 — residuano solo nota PORT-TAGGING e fonte IntraLino su VM (entrambe in attesa dell'utente) | Alta |
| Fase 3 | Riprendibile dal 10/07/2026 — 21 micro-step tracciati, M1 chiuso, M11 parziale; M2 in poi richiedono intervento fisico dell'utente | Critica (alla ripresa) |
| Fase 4 | Da pianificare | Media |
| Fase 5 | Da pianificare | Media |
