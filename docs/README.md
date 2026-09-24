# Documentazione della rete

Lo [snapshot dell'infrastruttura](snapshot-infrastruttura.md) e' il punto di partenza per leggere lo stato censito al 23/09/2026, con fonti, limiti e pendenze. La [mappa interattiva](network-map.html) consente di esplorare gli stessi apparati per logica, luogo, segmento, alimentazione e porte. La [guida alla topologia](network-diagram.md) spiega i comandi e il significato dei tratti del disegno. La fonte modificabile della mappa e' [`data/network-topology.json`](../data/network-topology.json); l'HTML e' generato. Il [diagramma storico](archivio/network-diagram-2026-08.md) conserva una ricostruzione precedente e non serve come istruzione sullo stato corrente.

## Percorsi di lettura

| Domanda | Documento |
|---|---|
| Che cosa e' collegato e quanto e' verificato? | [Snapshot](snapshot-infrastruttura.md), [mappa](network-map.html) e [guida](network-diagram.md) |
| Dove stanno cavi, armadi, corrente e porte fisiche? | [Livello fisico ed elettrico](livello-fisico-ed-elettrico.md) e [mappatura delle porte](mappatura-porte-fisiche.md) |
| Come il server e le VM raggiungono la rete? | [Proxmox e bridge](virtualizzazione-proxmox-e-bridge.md) e [servizi esposti](esposizione-servizi-interni.md) |
| Come sono separati oggi i segmenti e come cambieranno? | [Segmentazione M22](segmentazione-lan-m22.md), [firewall](firewall-zyxel-usg-flex-500.md), [risoluzione dei nomi](risoluzione-nomi-interni.md) e [autorita' di certificazione](autorita-certificazione-interna.md) |
| Che cosa resta aperto e quali vincoli ci sono? | [Pendenze consolidate](pendenze-aperte.md), [registro dei difetti](infrastructure-timeline/GAP-TBC.md) e [roadmap](../.claude/context/roadmap.md) |
| Come si e' arrivati allo stato attuale? | [Timeline degli interventi](infrastructure-timeline/README.md) e [SVG interattivo](infrastructure-timeline/timeline.svg) |
| Come si interviene su un caso concreto? | [Runbook delle anomalie](runbook-anomalie.md), [tratta esterna](runbook-intervento-tratta-esterna.md) e [continuita' operativa](business-continuity-disaster-recovery.md) |

Le altre schede tematiche descrivono [telefonia](telefono-pbx-voip.md), [governance della sicurezza](cybersecurity-governance.md), [sviluppo interno](sviluppo-interno.md) e altri servizi. Quando due documenti raccontano date diverse, il registro del fatto e la misura datata hanno precedenza sulla sintesi: la pagina di snapshot indica sempre il suo limite di verifica.

## Come si aggiorna

La topologia pubblica si corregge nella fonte JSON e si rigenera con `powershell -NoProfile -File scripts/Build-NetworkMap.ps1`. La matrice delle porte e' una seconda fonte tracciata derivata dallo snapshot Nebula privato tramite `python scripts/Export-PortMatrix.py`; va aggiornata quando cambia la misura, senza inserire MAC o nomi reali nel repository. Il confronto `python scripts/Test-TopologyDrift.py` legge gli snapshot privati di Nebula e Proxmox e puo' riportare un verde solo sulle proprieta' che controlla. La verifica `python scripts/Test-Anonymization.py` resta necessaria prima del commit documentale.

`_notes/` contiene il racconto operativo privato e `output/` gli snapshot completi: entrambi sono ignorati da Git. `.claude/context/` e `.claude/memory/` contengono invece schede tecniche e stato di sessione versionati; [CLAUDE.md](../CLAUDE.md) ne definisce la procedura di lettura e aggiornamento.
