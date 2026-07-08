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
   reali in vendor-management, BCD e q3-q4). La coda checklist e' ora solo
   BASSA piu' le attese esterne (PORT-TAGGING, fonte IntraLino su VM).
5. Ogni scrittura in file tracciato segue `.claude/rules/anonymization.md`
   (verificare con grep prima di chiudere il passo); i documenti voluminosi
   si ingeriscono con `docx-ingest` a disclosure progressiva.
6. Alla chiusura di ogni blocco: spunta in checklist, voce in
   `memory/progress.md`, commit manuale dell'utente.

## Domande aperte non risolte

- IntraLino: la documentazione Claude del progetto vive su una VM che
  l'utente fornira' come contesto (nota 08/07/2026, vedi roadmap Fase 1bis);
  fino ad allora le sezioni IntraLino restano parziali e il gap #107 aperto.
- PORT-TAGGING: dettagli del tagging dei due switch (input utente atteso).
- Contraddizione porta/switch telefono di Persona-A (NET-007, M10): la
  mappatura porte 2020-2026 documenta permutazioni sistematiche di etichette
  mai ricorrette, ipotesi errore di etichettatura rafforzata.
- Testo IVR centralino cloud non ancora comunicato a myOffice (TEL-001, M17).
- Funzione porta 8 "Vianova DHCP server fonia" (FW-012, M11).
- GroupShare: download installer SR2 bloccato, email a support@rws.com da
  inviare (fuori scope progetto rete, tracciato in timeline).
- Allineamento a `E:\template-claude-developing` rimandato.
