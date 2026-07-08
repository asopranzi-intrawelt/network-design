---
last-verified: 347f79c
---

# Design e sicurezza della rete — angolo ISO27001

## Paradigma architetturale

La rete Intrawelt usa una segmentazione L2 tramite Linux bridge di Proxmox. Ogni bridge
corrisponde a una porta fisica del BCM5719 quad-port e definisce un segmento di rete
logicamente separato. La segmentazione attuale e' fisica (bridge separati) ma non e'
supportata da firewall attivi o VLAN tagging.

## Nodo pve (snapshot v4, 08/07/2026)

| Parametro | Valore |
|---|---|
| CPU | 48 core, 2x Xeon Gold 6126 |
| RAM | 125.4 GB totali (upgrade dei 64 GB ordinati il 14/11/2025 confermato in campo), 92.2 GB usati |
| PVE | 8.3.4, kernel 6.8.12-8-pve |
| Cluster | "Intrawelt", nodo singolo |

Anomalia da chiarire: lo stato cluster riporta come IP del nodo 10.61.1.71,
che coincide con l'indirizzo documentato della iLO5, mentre vmbr0 e'
10.61.20.11/19 (gap #108).

## Segmenti di rete documentati (snapshot v4)

| Bridge | Porta | Subnet | Scopo |
|---|---|---|---|
| vmbr0 | eno1 | 10.61.20.11/19 (LAN unica /19) | Rete principale servizi |
| vmbr1 | eno2 | — | Seconda NIC VM100 WinServer2022 |
| vmbr2 | eno3 | — | Intrasite (VM206) |
| vmbr3 | eno4 | — | Servizi separati (VM203/204/205/602) |

Nessun bridge e' VLAN-aware (la configurazione target di M5 non e' ancora
applicata). Lo snapshot v4 conferma che la LAN e' una /19, non una /24: le
"classi" .10/.20/.30/.90 sono convenzioni di piano di indirizzamento dentro
un unico dominio L2/L3.

## Inventario VM (snapshot v4, 08/07/2026)

| VMID | Nome | Stato | Bridge(s) | IP | Note |
|---|---|---|---|---|---|
| VM100 | WinServer2022 | running | vmbr0+vmbr1 | .12/.13 | 64 GB RAM (meta' del nodo), doppia NIC |
| VM202 | PasswordManager | running | vmbr0 | .21 | firewall=1 su NIC, Docker interno |
| VM203 | templateMicroservice | stopped | vmbr3 | — | Template microservizi (base disk) |
| VM204 | ConvertitoreRuoliniENI | running | vmbr3 | .22 | |
| VM205 | GanttTool | running | vmbr3 | — | Guest agent non in esecuzione |
| VM206 | intrasite | running | vmbr2 | .23 | Docker interno |
| VM602 | Intralino | running | vmbr3 | — | Rinominata (era ITdeveloping); pool Programmazione, disco 200G su storage PROGRAMMAZIONE; no agent |
| VM810 | TESTNEWEGETRADBOOT | running | vmbr0 | — | 260G; sostituisce la VM809 dei log di febbraio; no agent |

Rimosse rispetto al v3: VM803. Rimosse rispetto ai log vzdump di febbraio
2026: VM101, 201, 601, 801-803, 809, 900-902 (gap #106 riconciliato). Pool
risorse: "Servizi" (100, 202-206, 810) e "Programmazione" (602).

## Storage e backup (snapshot v4)

| Storage | Tipo | Totale | Usato |
|---|---|---|---|
| SERVIZI | lvmthin | 1000 GB | 537 GB |
| PROGRAMMAZIONE | lvmthin (nuovo rispetto al v3) | 1500 GB | 100 GB |
| NAS_INTRA | cifs | 5.5 TB | 2.5 TB |
| NAS_HERO | cifs | 5.0 TB | 0.2 TB |
| NAS_INTRA2 | cifs | 22.1 TB | 14.5 TB |

Nove job di backup schedulati (zstd, snapshot mode), scaglionati tra le
21:00 e le 06:00 verso NAS_INTRA (uno generale "tutte" piu' job per-VM),
con un secondo job della VM100 verso NAS_HERO alle 00:30.

## Stato firewall (snapshot v4)

- Firewall cluster: INATTIVO, 0 regole — invariato dal v3
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
