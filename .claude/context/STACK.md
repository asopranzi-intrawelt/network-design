---
last-verified: 594ec07
---

# Stack e struttura del progetto

## Componenti principali

| Componente | Ruolo |
|---|---|
| `scripts/Get-ProxmoxSnapshot.ps1` | Snapshot completo infrastruttura Proxmox via REST API |
| `scripts/Check-OneDriveDelta.ps1` | Delta cartella OneDrive IT vs baseline locale (hook SessionStart) |
| `.claude/context/diagrams/network-topology.mmd` | Diagramma Mermaid topologia di rete |
| `docs/infrastructure-timeline/` | Storia cronologica interventi di rete (Markdown) |
| `_notes/` | Layer narrativo locale (ignorato da git) |
| `output/` | Output script runtime (ignorato da git) |

## Script Get-ProxmoxSnapshot.ps1

- Linguaggio: PowerShell 5.1
- Autenticazione: cookie PVEAuthCookie via WebRequestSession (workaround PS5.1)
- TLS: TrustAllCertsPolicy via Add-Type (certificato self-signed Proxmox)
- Output: JSON completo + report Markdown in `output/`
- Dati raccolti: nodi, reti, storage, VM QEMU, LXC, pool, firewall cluster e per-VM,
  SDN, backup schedules, HA, snapshot VM, dischi fisici, dispositivi PCI

## Infrastruttura target

- Proxmox VE su `10.61.20.11:8006`
- Singolo nodo `pve`
- Tre storage pool: local, local-lvm, NAS_INTRA, NAS_HERO
- 4 bridge Linux: vmbr0 (10.61.20.x), vmbr1-3 (porte fisiche dedicate)
- 10 VM QEMU, 0 LXC al momento dello snapshot v3

## Dipendenze PowerShell

Nessuna dipendenza esterna. Lo script usa solo classi .NET integrate in PS5.1:
`System.Net.WebRequestSession`, `System.Net.Cookie`, `System.Net.ServicePointManager`.
