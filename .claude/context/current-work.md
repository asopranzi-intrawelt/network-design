---
last-verified: 1ad2cb7
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
`2026-switch-piano-terra.md`. Il sorgente contiene credenziali in chiaro,
non riportate.

## Nota PORT-TAGGING (input utente atteso)

Il tagging delle porte dei due switch Nebula (XGS2220-54HP e XGS2220-30HP),
eseguito in occasione della migrazione al centralino cloud Vianova, non e'
ancora emerso per intero dai documenti ingestiti. L'utente ha chiesto
esplicitamente di fermarsi e chiedere a lui i dettagli quando l'analisi
cronologica arriva al punto in cui i due switch sono stati taggati.
Prerequisito: ingerire `ARCHITETTURA SERVER-CLOUD-LINEE/Mappatura porte
fisiche/` (voce ALTA in checklist).

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

1. FATTO: `Mappatura porte fisiche/` ingestita (vedi sopra). ORA: chiedere
   all'utente i dettagli del tagging porte (nota PORT-TAGGING).
2. Voci ALTA della checklist: delta SCENIA SECURITY/Allegati + DPIA;
   `Risposte Tecniche ai Requisiti di Sicurezza.docx` (da cercare in File
   condivisi da AIDAPT).
3. Delta MEDIA (AUDIT_INVENTORY, WindTre rev. luglio, ABBYY.docx, Checklist
   customer Scenia, call aidapt 6.7, IntraLino/n8n), poi MEDIA preesistenti
   in ordine cronologico delle fonti.
4. Ogni scrittura in file tracciato segue `.claude/rules/anonymization.md`
   (verificare con grep prima di chiudere il passo); i documenti voluminosi
   si ingeriscono con `docx-ingest` a disclosure progressiva.
5. Alla chiusura di ogni blocco: spunta in checklist, voce in
   `memory/progress.md`, commit manuale dell'utente.

## Domande aperte non risolte

- PORT-TAGGING: dettagli del tagging dei due switch (input utente atteso).
- Contraddizione porta/switch telefono di Persona-A (NET-007, M10): la
  mappatura porte 2020-2026 documenta permutazioni sistematiche di etichette
  mai ricorrette, ipotesi errore di etichettatura rafforzata.
- Testo IVR centralino cloud non ancora comunicato a myOffice (TEL-001, M17).
- Funzione porta 8 "Vianova DHCP server fonia" (FW-012, M11).
- GroupShare: download installer SR2 bloccato, email a support@rws.com da
  inviare (fuori scope progetto rete, tracciato in timeline).
- Allineamento a `E:\template-claude-developing` rimandato.
