---
last-verified: 4782336
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
- Dati raccolti: nodi, reti, storage, VM QEMU, LXC, pool, firewall cluster e per-VM, SDN, backup schedules, HA, snapshot VM, dischi fisici, dispositivi PCI

## Script Get-NebulaSnapshot.ps1

- Linguaggio: PowerShell 5.1 / 7+
- Autenticazione: header `X-ZyxelNebula-API-Key`, chiave risolta da parametro -> variabile d'ambiente `NEBULA_API_KEY` -> prompt SecureString
- Output: JSON completo + report Markdown in `output/`
- Dati raccolti: organizzazioni, siti, inventario dispositivi (switch, AP, gateway...), stato porte e tabella MAC L2 per switch (nato per localizzare gli AP fisici per porta quando non compaiono come dispositivi Nebula, vedi ADR-009 e `runbook-anomalie.md` §AP-001)
- Nessuna dipendenza esterna: solo `Invoke-RestMethod` nativo

## Infrastruttura target

- Proxmox VE su `10.61.20.11:8006`
- Singolo nodo `pve`
- Tre storage pool: local, local-lvm, NAS_INTRA, NAS_HERO
- 4 bridge Linux: vmbr0 (10.61.20.x), vmbr1-3 (porte fisiche dedicate)
- 10 VM QEMU, 0 LXC al momento dello snapshot v3

## Dipendenze PowerShell

Nessuna dipendenza esterna. Lo script usa solo classi .NET integrate in PS5.1: `System.Net.WebRequestSession`, `System.Net.Cookie`, `System.Net.ServicePointManager`.

## Script del censimento dell'esposizione (M27-7, dal 31/08/2026)

`scripts/censimento-host.sh` interroga in sola lettura i quattro livelli a cui puo' vivere un filtro su un host Linux: il filtro di pacchetti del kernel con `ufw`, `nft` e `iptables`, le direttive di ammissione per indirizzo nella configurazione di nginx e Apache, le porte in ascolto con il processo che le tiene, i contenitori che pubblicano porte, e la configurazione di autenticazione del servizio SSH. Esiste perche' guardarne uno solo produce un quadro parziale, ed e' l'errore corretto il 31/08/2026 quando il censimento fatto con il solo `ufw` aveva mancato la restrizione per indirizzo attiva sulla VM 204. Non scrive nulla sull'host.

`scripts/Invoke-HostCensus.ps1` lo esegue su piu' host dalla postazione, copiandolo, lanciandolo e raccogliendo l'esito in `output/censimento-<host>.txt`. La ragione per cui esiste un driver invece di un comando da incollare e' di citazione, non di comodita': un comando con apici annidati che attraversa PowerShell e poi una shell remota si rompe prima di poter essere sbagliato nel merito, e ripeterlo a mano su nove macchine e' nove occasioni di sbagliarne una in silenzio. Nessuno dei due file contiene indirizzi o credenziali: gli host si indicano con gli alias del `~/.ssh/config` della postazione, che non fa parte del repository. L'output contiene nomi host e indirizzi reali e finisce in `output/`, ignorato da git.

## Script di ricognizione TLS, e la generalizzazione del driver (dal 01/09/2026)

`scripts/ispeziona-tls.sh` risponde in sola lettura alle tre domande che precedono l'aggiunta di HTTPS a un servizio interno: quale server web sta davanti all'applicazione e come le parla, se il supporto TLS e' gia' predisposto, e quali certificati esistano sulla macchina e di che natura siano. Dei certificati stampa soltanto i campi pubblici, cioe' soggetto, emittente, scadenza e se si tratti di un'autorita': non legge mai una chiave privata. L'ultimo dato e' quello che orienta la scelta fra certificati per servizio e autorita' interna.

`scripts/Invoke-HostCensus.ps1` ha ora il parametro `-Script`, che gli permette di eseguire su un host qualunque script di sola lettura invece del solo censimento, e `-Prefisso` per nominare i file di esito. La generalizzazione non e' un vezzo: nel corso della sessione del 31/08 e del 01/09 lo stesso comando incollato nella riga di comando si e' rotto per citazione **tre volte**, perche' attraversa PowerShell e poi una shell remota e ciascuno dei due livelli interpreta a modo proprio apici, barre verticali e virgolette. Trasferire un file ed eseguirlo elimina il problema alla radice, e la meccanica vale per qualunque ricognizione futura.
