---
last-verified: 347f79c
---

# Verifica output snapshot e casi limite

## Verifica rapida post-esecuzione

Dopo aver eseguito `Get-ProxmoxSnapshot.ps1`, verificare nel report Markdown:

1. **Nodi**: deve apparire almeno `pve` con uptime e versione PVE
2. **Bridge**: devono comparire vmbr0-vmbr3 con le porte fisiche eno1-eno4
3. **VM QEMU**: devono comparire tutte le 10 VM censite (100, 202, 203, 204, 205, 206, 207, 208, 602, 810), nove in esecuzione piu' la 203 template ferma; VM803 risulta rimossa rispetto ai log vzdump di febbraio 2026 (vedi design-and-security.md). La VM208 `portaleAsset` e' nata il 21/07/2026, dopo lo snapshot v4, ed e' stata censita con la riconciliazione live del 27/07/2026: il primo snapshot che la conterra' e' il v5 (M18)
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
| iLO5 IP 10.61.1.71 | Appare in corosync totem addr | Normale OOB management |
| Firewall cluster inattivo | 0 regole, 0 ipset | Gap di sicurezza documentato |
| SDN non configurato | Array vuoti per zones/vnets/controllers | Normale |
| HA non configurato | Array vuoti | Normale |
| Snapshot VM | 0 snapshot su tutte le VM | Da monitorare |

## Validare il JSON grezzo

```powershell
$data = Get-Content .\output\proxmox-snapshot.json | ConvertFrom-Json
$data.nodes.Count       # atteso: 1
$data.vms.Count         # atteso: 10 (dal 21/07/2026, VM208 inclusa)
$data.bridges.Count     # atteso: 4 bridge principali
$data.clusterFirewall.options.enable  # atteso: 0 (inattivo)
```

## Due trappole di PowerShell trovate sullo script NinjaOne (30/07/2026)

Valgono per qualunque script di questo progetto che consumi JSON di un'API, quindi stanno
qui e non nella documentazione del singolo script. Entrambe si manifestano solo con
`Set-StrictMode -Version Latest` attivo, che questi script usano di proposito perche'
trasforma in errore quello che altrimenti sarebbe un valore vuoto silenzioso.

La prima e' l'accesso a una **proprieta' assente**. Le API tendono a omettere i campi nulli
invece di riportarli vuoti, quindi `$oggetto.campoAssente` non e' `$null`: e' un errore
`PropertyNotFoundStrict` che interrompe lo script. Il rimedio adottato e' una funzione di
lettura difensiva che controlla `PSObject.Properties.Name` prima di leggere e ritorna un
valore predefinito. Quando il predefinito e' negativo va passato per nome
(`-Default -1`), altrimenti il parser puo' interpretare `-1` come nome di parametro.

La seconda e' piu' insidiosa: PowerShell **srotola gli array restituiti da una funzione**.
Una funzione che ritorna un array di un solo elemento consegna al chiamante uno scalare, e
la lettura di `.Count` su quello scalare fallisce sotto modalita' rigorosa. Il rimedio
corretto e' avvolgere sempre l'esito nel chiamante, `@(Get-RowSet -Data $x)`. Il rimedio
sbagliato, provato e scartato in giornata, e' usare l'operatore virgola nel `return`: quello
produce un array annidato e tutti i conteggi risultano pari a uno, che e' un difetto
peggiore del precedente perche' non solleva errori e falsifica i numeri in silenzio.

Verifica minima di regressione, da rifare quando si tocca una funzione che normalizza
payload: si prova con quattro forme di dato — array di piu' elementi, array di un solo
elemento, oggetto paginato con i risultati dentro un campo, e `$null` — e si controlla che i
conteggi siano rispettivamente il numero reale, uno, il numero reale e zero. E' il test che
ha smascherato il rimedio sbagliato: senza di esso lo script sarebbe stato "funzionante" e
i filtri avrebbero conservato un elemento per endpoint.

## Encoding

Lo script e' ASCII puro (tutti i caratteri < 128). Compatibile con PS5.1 e UTF-8 senza BOM.
Nessun accento nel codice, solo nei commenti e nei report. I report Markdown usano caratteri
ASCII estesi solo nei valori dell'API, mai nel codice dello script.
