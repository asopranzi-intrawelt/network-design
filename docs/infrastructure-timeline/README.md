# Timeline degli interventi infrastrutturali

Ogni file racconta un periodo della rete, in ordine cronologico. Le voci fino a maggio 2026 sono state ricostruite dal documento di architettura dell'IT Manager; quelle successive sono scritte nel giro di lavoro in cui l'intervento avviene. I marcatori [TBC] indicano sezioni in cui manca ancora uno screenshot o un'informazione. L'[SVG interattivo](timeline.svg) si rigenera da questi file a ogni apertura di sessione con `scripts/Build-TimelineSvg.ps1` e non si modifica a mano.

| File | Periodo | Contenuto |
|---|---|---|
| [2023-baseline.md](2023-baseline.md) | 2023 | stato di partenza: switch, firewall, NAS, virtualizzazione, problemi aperti |
| [2024-infra.md](2024-infra.md) | 2024 | inventario, blackout del NAS INTRA2, scelta del nuovo operatore |
| [2025-q1-server-vianova.md](2025-q1-server-vianova.md) | gen-mar 2025 | server HP ProLiant, Proxmox, cablaggio del rack, posa della fibra |
| [2025-q2-migrazione-tim-vianova.md](2025-q2-migrazione-tim-vianova.md) | apr-giu 2025 | attivazione della fibra, cambio della WAN, tunnel verso il datacenter |
| [2025-q3-q4.md](2025-q3-q4.md) | lug-dic 2025 | consolidamento, parco NAS, secondo router |
| [2025-storage-anni-vecchi.md](2025-storage-anni-vecchi.md) | 2009-2023 | consolidamento dell'archivio storico annuale |
| [2026-switch-piano-terra.md](2026-switch-piano-terra.md) | gen-set 2026 | phishing, switch del Piano Terra, Voice VLAN, dorsale 10 Gbps, Wi-Fi |
| [2026-q4-segreti-e-collettore.md](2026-q4-segreti-e-collettore.md) | ott 2026 | segreti della postazione, collettore dei log, sito in produzione |
| [GAP-TBC.md](GAP-TBC.md) | trasversale | registro dei difetti e delle sezioni incomplete |

La checklist di ingestione dei documenti OneDrive, che stava qui, è nel livello privato in `_notes/ingestione/`: cataloga nomi di file e di cartelle che non possono stare in un repository pubblico.

Torna alla [documentazione](../README.md).
