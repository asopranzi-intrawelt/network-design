---
last-verified: 347f79c
---

# Stack e struttura del progetto

## Componenti principali

| Componente | Ruolo |
|---|---|
| `scripts/Get-ProxmoxSnapshot.ps1` | Snapshot completo infrastruttura Proxmox via REST API |
| `scripts/Get-NebulaSnapshot.ps1` | Snapshot organizzazione Zyxel Nebula via API REST (organizzazioni, siti, dispositivi, tabella MAC L2 per switch) |
| `scripts/Check-OneDriveDelta.ps1` | Delta cartella OneDrive IT vs baseline locale (hook SessionStart) |
| `scripts/Build-TimelineSvg.ps1` | Timeline SVG anonimizzata dai md della timeline (hook SessionStart); scrive solo dentro questo repo, vedi CLAUDE.md "Confine con E:\projects" |
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

## Script Get-NebulaSnapshot.ps1

- Linguaggio: PowerShell 5.1 / 7+
- Autenticazione: header `X-ZyxelNebula-API-Key`, chiave risolta da
  parametro -> variabile d'ambiente `NEBULA_API_KEY` -> prompt SecureString
- Output: JSON completo + report Markdown in `output/`
- Dati raccolti: organizzazioni, siti, inventario dispositivi (switch,
  AP, gateway...), stato porte e tabella MAC L2 per switch (nato per
  localizzare gli AP fisici per porta quando non compaiono come
  dispositivi Nebula, vedi ADR-009 e `runbook-anomalie.md` §AP-001)
- Nessuna dipendenza esterna: solo `Invoke-RestMethod` nativo

## Infrastruttura target

- Proxmox VE su `10.61.20.11:8006`
- Singolo nodo `pve`
- Tre storage pool: local, local-lvm, NAS_INTRA, NAS_HERO
- 4 bridge Linux: vmbr0 (10.61.20.x), vmbr1-3 (porte fisiche dedicate)
- 10 VM QEMU, 0 LXC al momento dello snapshot v3

## Dipendenze PowerShell

Nessuna dipendenza esterna. Lo script usa solo classi .NET integrate in PS5.1:
`System.Net.WebRequestSession`, `System.Net.Cookie`, `System.Net.ServicePointManager`.
