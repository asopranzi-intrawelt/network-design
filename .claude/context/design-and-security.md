---
last-verified: 34a9dd7
---

# Design e sicurezza della rete — angolo ISO27001

## Paradigma architetturale

La rete Intrawelt usa una segmentazione L2 tramite Linux bridge di Proxmox. Ogni bridge
corrisponde a una porta fisica del BCM5719 quad-port e definisce un segmento di rete
logicamente separato. La segmentazione attuale e' fisica (bridge separati) ma non e'
supportata da firewall attivi o VLAN tagging.

## Segmenti di rete documentati (snapshot v3)

| Bridge | Porta | Subnet | Scopo |
|---|---|---|---|
| vmbr0 | eno1 | 10.61.20.0/24 | Rete principale servizi |
| vmbr1 | eno2 | 10.61.20.0/24 | Seconda NIC VM100 WinServer2022 |
| vmbr2 | eno3 | — | Intrasite (VM206) |
| vmbr3 | eno4 | — | Servizi separati (VM203/204/205/206/602) |

## Inventario VM (snapshot v3)

| VMID | Nome | Bridge(s) | IP | Note |
|---|---|---|---|---|
| VM100 | WinServer2022 | vmbr0+vmbr1 | .12/.13 | Doppia NIC: due segmenti fisici |
| VM202 | PasswordManager | vmbr0 | .21 | firewall=1 su NIC |
| VM203 | — | vmbr3 | — | Stopped |
| VM204 | ConvertitoreRuoliniENI | vmbr3 | .22 | |
| VM205 | GanttTool | vmbr3 | .61 | 4 reti Docker interne |
| VM206 | intrasite | vmbr2 | .23 | |
| VM602 | ITdeveloping | vmbr3 | — | No agent |
| VM803 | — | vmbr0 | — | Stopped |
| VM810 | — | vmbr0 | — | No agent |

## Stato firewall (snapshot v3)

- Firewall cluster: INATTIVO, 0 regole, 0 ipset
- VM202: `firewall=1` a livello NIC, 0 regole esplicite — nessun effetto pratico
- Tutte le altre VM: firewall non abilitato

## Gap di sicurezza identificati (ISO27001 Annex A)

| Controllo | Stato | Gap |
|---|---|---|
| A.8.20 Network security | Parziale | Nessun firewall attivo tra segmenti |
| A.8.22 Segregation in networks | Parziale | Segmentazione fisica ma no policy enforcement |
| A.8.16 Monitoring activities | Non verificato | Logging traffico non documentato |
| A.5.37 Documented operating procedures | In corso | Questo progetto |
| A.8.8 Management of technical vulnerabilities | Non verificato | Patch management non documentato |

## Prossimi passi di hardening (da pianificare)

1. Attivare e configurare firewall cluster Proxmox con policy di default DROP
2. Definire regole per segmento (vmbr0: management only, vmbr3: isolamento servizi)
3. Documentare e verificare patch level Proxmox e VM
4. Valutare VLAN tagging per segmentazione ulteriore

## Decisioni di sicurezza di design

- Le credenziali Proxmox vengono chieste a runtime, mai scritte su disco
- `output/` mai in git (IP, MAC, nomi VM, configurazioni)
- Il codice dello script non contiene segreti hardcoded
