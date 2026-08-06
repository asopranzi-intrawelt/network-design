---
last-verified: 4782336
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

Valgono per qualunque script di questo progetto che consumi JSON di un'API, quindi stanno qui e non nella documentazione del singolo script. Entrambe si manifestano solo con `Set-StrictMode -Version Latest` attivo, che questi script usano di proposito perche' trasforma in errore quello che altrimenti sarebbe un valore vuoto silenzioso.

La prima e' l'accesso a una **proprieta' assente**. Le API tendono a omettere i campi nulli invece di riportarli vuoti, quindi `$oggetto.campoAssente` non e' `$null`: e' un errore `PropertyNotFoundStrict` che interrompe lo script. Il rimedio adottato e' una funzione di lettura difensiva che controlla `PSObject.Properties.Name` prima di leggere e ritorna un valore predefinito. Quando il predefinito e' negativo va passato per nome (`-Default -1`), altrimenti il parser puo' interpretare `-1` come nome di parametro.

La seconda e' piu' insidiosa: PowerShell **srotola gli array restituiti da una funzione**. Una funzione che ritorna un array di un solo elemento consegna al chiamante uno scalare, e la lettura di `.Count` su quello scalare fallisce sotto modalita' rigorosa. Il rimedio corretto e' avvolgere sempre l'esito nel chiamante, `@(Get-RowSet -Data $x)`. Il rimedio sbagliato, provato e scartato in giornata, e' usare l'operatore virgola nel `return`: quello produce un array annidato e tutti i conteggi risultano pari a uno, che e' un difetto peggiore del precedente perche' non solleva errori e falsifica i numeri in silenzio.

Verifica minima di regressione, da rifare quando si tocca una funzione che normalizza payload: si prova con quattro forme di dato — array di piu' elementi, array di un solo elemento, oggetto paginato con i risultati dentro un campo, e `$null` — e si controlla che i conteggi siano rispettivamente il numero reale, uno, il numero reale e zero. E' il test che ha smascherato il rimedio sbagliato: senza di esso lo script sarebbe stato "funzionante" e i filtri avrebbero conservato un elemento per endpoint.

La terza trappola, trovata al lancio successivo, e' banale e costa un giro intero: **usare come nome di variabile una variabile automatica di PowerShell**. `$pid` sembra un'abbreviazione naturale per "policy id" ed e' invece il numero di processo della sessione, in sola lettura: l'assegnazione fallisce a runtime con un errore che non nomina la causa. Controllo da fare su ogni script prima di considerarlo pronto: cercare assegnazioni a `$PID`, `$HOME`, `$HOST`, `$PWD`, `$INPUT`, `$ARGS`, `$ERROR`, `$MATCHES`, `$PROFILE`, `$PSHOME`, `$FOREACH`, `$SWITCH`, `$THIS`, `$EVENT`, `$SENDER`, `$LASTEXITCODE` e alle altre automatiche. E' una ricerca di dieci secondi che l'analisi sintattica **non** segnala, perche' la sintassi e' corretta: l'errore e' semantico e si manifesta solo eseguendo.

## Due trappole ulteriori, dallo script di distribuzione dei collegamenti (31/07/2026)

La quarta trappola PowerShell, e per una volta non e' un errore di sintassi ma di architettura: **una funzione restituisce tutto cio' che scrive sul flusso di output**, non solo cio' che segue `return`. Una funzione di supporto che stampi un messaggio diagnostico con `Write-Output` — o con un helper che lo usa — contamina il proprio valore di ritorno, e il chiamante riceve un array invece della stringa attesa. Il sintomo osservato: un nome di condivisione diventato `System.Object[]` e finito dentro un percorso di rete. La regola: dentro una funzione i messaggi vanno su flussi separati (`Write-Warning`, `Write-Verbose`, `Write-Information`), e il flusso di output si riserva al valore di ritorno.

La quinta e' sulla fiducia nell'output altrui: **l'esito di un comando esterno non e' una stringa affidabile**. Puo' essere un array, contenere righe di servizio o un messaggio d'uso, e se lo si concatena in un percorso si costruisce un percorso senza senso senza che nulla protesti. Quando un valore letto da un sistema esterno finisce in un percorso, in un comando o in una configurazione, va **normalizzato e validato** contro un'espressione che descriva la forma attesa, e in caso di dubbio si scarta invece di indovinare.

Nota utile sullo stesso episodio: sull'agente dell'RMM esiste realmente una funzione PowerShell per leggere i campi personalizzati del dispositivo, fornita da un modulo installato con l'agente. Fuori dal contesto dell'RMM quella funzione esiste ma fallisce, perche' non trova l'eseguibile della sua CLI: e' quindi utilizzabile in produzione e va gestita con un fallback pulito quando si prova lo script a mano.

## Una verifica deve poter fallire per la ragione che stai misurando

Tre episodi della stessa settimana, tutti su comandi di diagnosi, hanno mostrato lo stesso difetto di metodo: un comando risponde, la risposta sembra confermare la tesi, e in realta' arriva da un'altra strada.

Il primo: verificare la raggiungibilita' di una share con un `ping`. Il ping sopravvive a difetti a cui SMB non sopravvive, quindi rassicura senza dimostrare — su questa rete esiste il precedente di endpoint che pingavano il NAS e non riuscivano a montarlo. La verifica corretta e' una lettura **e** una scrittura sulla share.

Il secondo: provare l'isolamento tra due utenze verso lo stesso server aggiungendo `/user` al comando di mappatura. Windows rifiuta con un errore di sessione (1219) che sembra un diniego di permessi e non lo e'; la prova corretta omette `/user`, riusa la sessione gia' autenticata e mette alla prova la sola autorizzazione. Corollario: un rifiuto va sempre letto nel merito, un codice di errore diverso e' un test non eseguito.

Il terzo, il piu' insidioso: interrogare un nome indicando esplicitamente il server DNS da usare. Il comando di risoluzione di PowerShell consulta per default anche mDNS e NetBIOS, quindi **indicare un server non garantisce che la risposta venga da quel server**: una risposta con suffisso `.local` e tempo di vita di 120 secondi e' la firma di un annuncio mDNS, non di una zona DNS. Da quella lettura si era concluso che il firewall ospitasse record interni, mentre la sua tabella dei record e' vuota. Per provare che risponda il DNS serve forzare la sola via DNS, oppure interrogare il server con uno strumento che non abbia fallback.

La regola che ne esce, valida oltre questi tre casi: prima di credere a una verifica, chiedersi **quale altra strada** potrebbe produrre lo stesso esito. Se ne esiste una, il test non distingue le due ipotesi e va cambiato.

## Provare la logica di filtro fuori linea, invece di rilanciare contro l'API

Tre lanci consecutivi falliti su tre difetti diversi hanno insegnato che rilanciare uno script contro un'API remota per scoprire se funziona e' il modo piu' lento e piu' invasivo di fare un test: ogni tentativo consuma un'autenticazione reale, scarica dati veri e, nel caso di un'istanza multi-tenant, li scrive su disco.

La tecnica adottata, molto piu' rapida, e' un banco di prova che **estrae dal file dello script il codice vero** — le funzioni di normalizzazione e il blocco di filtro, delimitati dai commenti di sezione — e lo esegue su dati sintetici costruiti per riprodurre i casi limite noti. Nel caso del filtro per organizzazione i casi che contano sono tre: un dispositivo appartenente a un'altra organizzazione, una entita' non-dispositivo che porta lo stesso campo di appartenenza (una *location*), e un id di quella entita' che **collide** con l'id di un dispositivo di terzi, che e' esattamente il difetto che si era manifestato in produzione. Il banco verifica poi che nessuna riga di terzi sopravviva al filtro.

Il vantaggio non e' solo la velocita': testando il codice estratto dal file, e non una sua copia riscritta nel test, si prova quello che verra' eseguito davvero.

## Encoding

Lo script e' ASCII puro (tutti i caratteri < 128). Compatibile con PS5.1 e UTF-8 senza BOM. Nessun accento nel codice, solo nei commenti e nei report. I report Markdown usano caratteri ASCII estesi solo nei valori dell'API, mai nel codice dello script.
