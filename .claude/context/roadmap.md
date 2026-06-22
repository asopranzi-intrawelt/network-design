---
last-verified: PENDING-FIRST-COMMIT
---

# Roadmap e fasi del progetto

## Fase 0 — Inizializzazione (corrente)

- Struttura progetto e template `.claude/` canonica
- Script snapshot Proxmox (v3) integrato
- Snapshot infrastruttura v3 come baseline corrente
- Due layer documentali (narrativo + tecnico) configurati

## Fase 1 — Ricostruzione storia della rete

Obiettivo: costruire la timeline cronologica di tutti gli interventi infrastrutturali
di rete di Intrawelt, partendo dai documenti Word esistenti.

Steps:
1. Censire i documenti Word disponibili in `_notes/docs-word/`
2. Per ogni documento usare `docx-ingest` (disclosure progressiva: TOC, poi sezioni)
3. Estrarre gli eventi rilevanti: interventi di rete, cambi di configurazione, incidenti
4. Popolare `docs/infrastructure-timeline/` con Markdown strutturato per data
5. Collegare ogni evento ai controlli ISO27001 rilevanti

## Fase 2 — Documentazione stato corrente

Obiettivo: documentare in modo completo la rete attuale integrando snapshot Proxmox
con documentazione del firewall perimetrale e di altri componenti.

Steps:
1. Aggiornare snapshot Proxmox (ri-eseguire lo script)
2. Acquisire documentazione firewall (configurazione, regole, zone)
3. Documentare altri componenti: switch managed, AP WiFi, NAS
4. Produrre diagramma di rete completo aggiornato
5. Completare gap analysis ISO27001

## Fase 3 — Piano interventi futuri

Obiettivo: definire gli step di intervento sulla rete con criteri di priorita' e
impatto sulla sicurezza.

Steps:
1. Attivare firewall Proxmox con policy di default DROP
2. Definire regole per segmento (management, servizi, sviluppo)
3. Valutare VLAN tagging per ulteriore segmentazione
4. Documentare patch management
5. Definire procedure di backup e disaster recovery

## Fase 4 — Documentazione ISO27001 operativa

Obiettivo: produrre documentazione utilizzabile come base per un ISMS formale.

Steps:
1. Statement of Applicability per i controlli Annex A di rete
2. Risk assessment per i gap identificati
3. Procedure operative per gli interventi ricorrenti (backup, patching, accessi)
4. Incident response per i scenari rilevanti

## Timeline (indicativa)

| Fase | Stato | Priorita' |
|---|---|---|
| Fase 0 | In completamento | Alta |
| Fase 1 | Da iniziare | Alta |
| Fase 2 | Da iniziare | Alta |
| Fase 3 | Da pianificare | Media |
| Fase 4 | Da pianificare | Media |
