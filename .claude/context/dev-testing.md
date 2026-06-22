---
last-verified: PENDING-FIRST-COMMIT
---

# Verifica output snapshot e casi limite

## Verifica rapida post-esecuzione

Dopo aver eseguito `Get-ProxmoxSnapshot.ps1`, verificare nel report Markdown:

1. **Nodi**: deve apparire almeno `pve` con uptime e versione PVE
2. **Bridge**: devono comparire vmbr0-vmbr3 con le porte fisiche eno1-eno4
3. **VM QEMU**: devono comparire tutte le 10 VM (100, 202, 203, 204, 205, 206, 602, 803, 810 + una)
4. **IP guest agent**: VM100 deve avere .12 su vmbr0 e .13 su vmbr1
5. **Pool**: devono comparire `Servizi` e `Programmazione`
6. **Backup**: devono comparire i 9 job verso NAS_INTRA (VM100 anche verso NAS_HERO)

## Warning attesi (comportamento normale)

```
WARN: /agent/network-get-interfaces non disponibile per VMID 602 (VM602 ITdeveloping)
WARN: /agent/network-get-interfaces non disponibile per VMID 810
```

VM602 e VM810 non hanno il guest agent installato o attivo. I warning sono normali.

## Casi limite documentati

| Caso | Comportamento atteso | Note |
|---|---|---|
| VM stopped (203, 803) | IP non disponibile, dati statici OK | Normal |
| Adaptec RAID controller | `/disks/list` restituisce array vuoto | Controller HW nasconde i fisici |
| BCM5719 PCIe passthrough | IOMMU group 40 = tutte 4 le porte insieme | No passthrough individuale |
| iLO5 IP 192.168.1.71 | Appare in corosync totem addr | Normale OOB management |
| Firewall cluster inattivo | 0 regole, 0 ipset | Gap di sicurezza documentato |
| SDN non configurato | Array vuoti per zones/vnets/controllers | Normale |
| HA non configurato | Array vuoti | Normale |
| Snapshot VM | 0 snapshot su tutte le VM | Da monitorare |

## Validare il JSON grezzo

```powershell
$data = Get-Content .\output\proxmox-snapshot.json | ConvertFrom-Json
$data.nodes.Count       # atteso: 1
$data.vms.Count         # atteso: ~10
$data.bridges.Count     # atteso: 4 bridge principali
$data.clusterFirewall.options.enable  # atteso: 0 (inattivo)
```

## Encoding

Lo script e' ASCII puro (tutti i caratteri < 128). Compatibile con PS5.1 e UTF-8 senza BOM.
Nessun accento nel codice, solo nei commenti e nei report. I report Markdown usano caratteri
ASCII estesi solo nei valori dell'API, mai nel codice dello script.
