# Check-OneDriveDelta.ps1
# Confronta lo stato corrente di una o piu' cartelle OneDrive con una baseline
# salvata localmente e riporta i file nuovi, modificati ed eliminati. Serve al
# check di inizio sessione del progetto network-design: la checklist di
# ingestione (docs/infrastructure-timeline/ingestion-checklist.md) fotografa un
# momento preciso, e questo script dice cosa e' cambiato da allora senza rileggere
# nulla a mano. Lavoro deterministico: nessun contenuto viene letto, solo percorsi,
# dimensioni e date di modifica.
#
# Perimetro di default: due librerie OneDrive distinte, ciascuna con la propria
# baseline. "Documenti - IT" e' la libreria tecnica principale (mappatura porte,
# ARCHITETTURA, Cybersec, SCENIA, ecc.). "IT + Administration - Documenti" e' la
# libreria amministrativa/fornitori (contratti, fatture, corrispondenza vendor:
# Vianova, myOffice, Seeweb, AWS, Zyxel, ecc.), scoperta il 09/07/2026 tramite un
# collegamento .lnk dentro ARCHITETTURA SERVER-CLOUD-LINEE e aggiunta al perimetro
# da quella data.
#
# Le baseline vivono in _notes/ (ignorate da git) perche' contengono nomi di file
# reali, che possono includere nomi di persone: non vanno mai versionate ne'
# copiate in un file tracciato (vedi .claude/rules/anonymization.md).
#
# Uso:
#   .\scripts\Check-OneDriveDelta.ps1                  # report del delta su entrambe le librerie di default
#   .\scripts\Check-OneDriveDelta.ps1 -UpdateBaseline  # accetta lo stato corrente come nuova baseline (entrambe)
#   .\scripts\Check-OneDriveDelta.ps1 -MaxList 10      # limita le righe elencate per categoria
#   .\scripts\Check-OneDriveDelta.ps1 -Folder <path> -BaselinePath <path>  # singola cartella custom, ignora i default

param(
    [string]$Folder,
    [string]$BaselinePath,
    [switch]$UpdateBaseline,
    [int]$MaxList = 25
)

# Le radici sorvegliate. La libreria aziendale OneDrive ne contiene diciannove al
# 03/08/2026; queste sono quelle che possono contenere informazione sulla rete.
#
# Le prime due sono le librerie documentali: la tecnica, dove vivono analisi, handoff e
# note di intervento, e l'amministrativa, molto piu' piccola ma dove vivono preventivi,
# documenti di trasporto e contratti firmati — cioe' l'unico posto dove un apparato nuovo
# compare prima di entrare in rete.
#
# La terza e' stata aggiunta il 03/08/2026 ed e' il canale di scambio: quando un handoff
# prodotto in un'altra sessione di lavoro viene condiviso in chat, il file atterra li' e in
# nessun'altra delle radici sorvegliate. Al momento dell'aggiunta conteneva tre handoff, di
# cui uno sul dimensionamento di una VM che questo progetto documenta come asset di rete.
# La cartella e' rumorosa e in gran parte estranea alla rete: e' il filtro delle voci
# rilevanti a renderla utilizzabile, non la lettura integrale del suo delta.
$defaultTargets = @(
    @{ Label = "Documenti - IT"; Folder = "C:\Users\Utente\OneDrive - Intrawelt S.a.s\Documenti - IT"; BaselinePath = "$PSScriptRoot\..\_notes\.onedrive-manifest.json" },
    @{ Label = "IT + Administration - Documenti"; Folder = "C:\Users\Utente\OneDrive - Intrawelt S.a.s\IT + Administration - Documenti"; BaselinePath = "$PSScriptRoot\..\_notes\.onedrive-manifest-admin.json" },
    @{ Label = "File di chat di Microsoft Teams"; Folder = "C:\Users\Utente\OneDrive - Intrawelt S.a.s\File di chat di Microsoft Teams"; BaselinePath = "$PSScriptRoot\..\_notes\.onedrive-manifest-teams.json" }
)

if ($Folder) {
    $bp = if ($BaselinePath) { $BaselinePath } else { "$PSScriptRoot\..\_notes\.onedrive-manifest-custom.json" }
    $targets = @(@{ Label = $Folder; Folder = $Folder; BaselinePath = $bp })
} else {
    $targets = $defaultTargets
}

# Cartelle escluse dal confronto: dati raw dichiarati SKIP nella checklist,
# artefatti di strumenti e materiale non documentale. Tenere allineate alla
# checklist quando una categoria cambia stato.
$excludePatterns = @(
    '*\Cartella_riservata_IT\*',            # credenziali: mai ingestire, mai enumerare
    '*\ENIVIPA\*',                          # 104k+ file dati raw billing
    '*\Helpdesk_Timbracartellini\*',        # dati operativi HR
    '*\graphify-out\*',                     # output derivati dello strumento graphify
    '*\.claude\*',                          # metadati strumenti AI
    '*\__pycache__\*',
    '*\Web scraping - Downloaded Web sites\*',  # mirror di siti esterni
    '*\VIDEOs\*',
    '*\TEST\*'
)
# Contro-eccezioni all'esclusione: file che vanno sorvegliati SEMPRE, anche quando si
# trovano dentro una cartella esclusa. Nascono da un caso reale scoperto il 03/08/2026:
# la cartella "Web scraping - Downloaded Web sites" era stata esclusa nel luglio 2026 come
# "mirror di siti esterni", e da allora una sessione di lavoro diversa da questa vi ha
# depositato due documenti di handoff sul dimensionamento della VM207 -- che questo progetto
# documenta come asset di rete -- piu' un CLAUDE.md di progetto. Erano invisibili al delta
# per costruzione, non per distrazione. Un handoff e un CLAUDE.md sono la traccia scritta di
# una sessione che ha cambiato qualcosa: non si escludono mai in base alla cartella in cui
# stanno, perche' e' proprio dove non li aspetti che contano.
$neverExcludePatterns = @(
    '*handoff*.md',
    '*HANDOFF*.md',
    '*\CLAUDE.md'
)
function Test-Excluded([string]$fullName) {
    foreach ($p in $neverExcludePatterns) { if ($fullName -like $p) { return $false } }
    foreach ($p in $excludePatterns) { if ($fullName -like $p) { return $true } }
    return $false
}

# Percorsi che riguardano la rete e l'infrastruttura documentata da questo progetto.
# Servono a risolvere un problema osservato il 03/08/2026: il delta era arretrato di
# diciannove giorni con 398 voci nuove, l'elenco veniva troncato alle prime 25 in ordine
# alfabetico, e le voci che contavano davvero -- due preventivi di hardware di rete --
# erano invisibili sotto centinaia di file di un altro progetto. Un elenco troncato di un
# insieme dominato dal rumore non e' un avviso: e' un avviso che verra' ignorato.
# Le voci che corrispondono a questi pattern vengono quindi elencate PER INTERO e a parte,
# mai troncate. Estendere la lista quando entra in scope un fornitore o un ambito nuovo.
$relevantPatterns = @(
    'handoff', '\bclaude\.md\b',
    'punto informatica', 'preventiv', '\bddt\b',
    'myoffice', 'vianova', 'centralino', 'fonia', 'telefon', 'interni intrawelt',
    'zyxel', 'nebula', 'firewall', 'switch', '\bvpn\b', '\bvlan\b',
    'qnap', '\bnas\b', 'proxmox', '\bilo\b', 'seeweb', 'groupshare',
    'mappatura porte', 'architettura server', 'network', 'diagramma di rete',
    '\bups\b', 'access point', 'stampant', 'printer', 'scanner', 'ninja',
    # Aggiunti il 04/09/2026 dopo un difetto del filtro trovato durante il triage del delta.
    # "STATO RETE INTRAWELT.docx", il documento piu' importante arrivato al progetto in tutto
    # il 2026 -- catena fisica dalla WAN al firewall, mappa porta-apparato, alimentazione dei
    # due armadi -- non corrispondeva a NESSUNO dei pattern qui sopra: non contiene 'network',
    # non contiene 'diagramma di rete', non nomina un apparato ne' un fornitore. Il 06/08/2026
    # fu notato solo perche' cadeva per caso fra le prime venticinque voci in ordine alfabetico
    # dell'elenco troncato. E' la stessa famiglia del difetto del 03/08 sulla cartella esclusa:
    # non si sbaglia su cio' che si conosce, si sbaglia su cio' che non si e' previsto.
    # 'backup' e 'crittograf' entrano perche' continuita' e dati a riposo sono ambiti su cui il
    # progetto ha difetti aperti; 'intervista' e 'censiment' perche' sono le forme in cui
    # arrivano le fonti prodotte da altre sessioni di lavoro.
    '\brete\b', 'stato rete', 'topologia', 'backup', 'crittograf', 'intervista', 'censiment'
)
function Test-Relevant([string]$relPath) {
    foreach ($p in $relevantPatterns) { if ($relPath -imatch $p) { return $true } }
    return $false
}

function Invoke-DeltaCheck($target, $maxList, $updateBaseline) {
    $folder = $target.Folder
    $baselinePath = $target.BaselinePath
    $label = $target.Label

    Write-Output "=== $label ==="

    if (-not (Test-Path $folder)) {
        Write-Output "ERRORE: cartella non trovata: $folder"
        Write-Output ""
        return
    }

    $current = @{}
    Get-ChildItem -LiteralPath $folder -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { (-not (Test-Excluded $_.FullName)) -and ($_.Name -ne 'desktop.ini') -and ($_.Extension -ne '.lnk') -and ($_.Name -notlike '~$*') } |
        ForEach-Object {
            $rel = $_.FullName.Substring($folder.Length).TrimStart('\')
            $current[$rel] = @{ t = $_.LastWriteTimeUtc.Ticks; s = $_.Length }
        }

    if (-not (Test-Path $baselinePath)) {
        if ($updateBaseline) {
            $out = @{ created = (Get-Date -Format 'yyyy-MM-dd HH:mm'); folder = $folder; files = $current }
            $out | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $baselinePath -Encoding UTF8
            Write-Output "Baseline creata: $($current.Count) file censiti in $baselinePath"
        } else {
            Write-Output "Nessuna baseline trovata ($baselinePath)."
            Write-Output "Eseguire con -UpdateBaseline per crearla dallo stato corrente ($($current.Count) file)."
        }
        Write-Output ""
        return
    }

    $baselineRaw = Get-Content -LiteralPath $baselinePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $baseline = @{}
    $baselineRaw.files.PSObject.Properties | ForEach-Object { $baseline[$_.Name] = $_.Value }

    $new = @(); $modified = @(); $deleted = @()
    foreach ($k in $current.Keys) {
        if (-not $baseline.ContainsKey($k)) { $new += $k }
        elseif ($baseline[$k].t -ne $current[$k].t -or $baseline[$k].s -ne $current[$k].s) { $modified += $k }
    }
    foreach ($k in $baseline.Keys) { if (-not $current.ContainsKey($k)) { $deleted += $k } }

    Write-Output "Delta vs baseline del $($baselineRaw.created)"
    Write-Output "Nuovi: $($new.Count) | Modificati: $($modified.Count) | Eliminati: $($deleted.Count) | Censiti: $($current.Count)"
    # Indice unico delle variazioni, usato per il riepilogo per cartella e per il blocco
    # delle voci rilevanti: entrambi servono a rendere leggibile un delta grande.
    $all = @()
    foreach ($pair in @(@('N', $new), @('M', $modified), @('E', $deleted))) {
        foreach ($f in $pair[1]) { $all += [pscustomobject]@{ Kind = $pair[0]; Path = $f } }
    }

    if ($all.Count -gt 0) {
        Write-Output ""
        Write-Output "--- RIEPILOGO PER CARTELLA (N=nuovi M=modificati E=eliminati) ---"
        $all | Group-Object -Property { ($_.Path -split '\\')[0] } | Sort-Object Count -Descending |
            ForEach-Object {
                $g = $_.Group
                $n = @($g | Where-Object { $_.Kind -eq 'N' }).Count
                $m = @($g | Where-Object { $_.Kind -eq 'M' }).Count
                $e = @($g | Where-Object { $_.Kind -eq 'E' }).Count
                Write-Output ("  {0,5} totali  (N {1,4}  M {2,3}  E {3,4})  {4}" -f $_.Count, $n, $m, $e, $_.Name)
            }
    }

    $relevant = @($all | Where-Object { Test-Relevant $_.Path })
    if ($relevant.Count -gt 0) {
        Write-Output ""
        Write-Output "*** RILEVANTI PER LA RETE: $($relevant.Count) voci - elenco integrale, NON troncato ***"
        $relevant | Sort-Object Path | ForEach-Object { Write-Output ("  [{0}] {1}" -f $_.Kind, $_.Path) }
    }

    foreach ($pair in @(@('NUOVI', $new), @('MODIFICATI', $modified), @('ELIMINATI', $deleted))) {
        $itemLabel = $pair[0]; $list = $pair[1]
        if ($list.Count -gt 0) {
            Write-Output ""
            Write-Output "--- $itemLabel (primi $maxList in ordine alfabetico) ---"
            $list | Sort-Object | Select-Object -First $maxList | ForEach-Object { Write-Output "  $_" }
            if ($list.Count -gt $maxList) { Write-Output "  ... e altri $($list.Count - $maxList) (usare -MaxList per vederli)" }
        }
    }
    if ($new.Count -eq 0 -and $modified.Count -eq 0 -and $deleted.Count -eq 0) {
        Write-Output "Nessuna variazione: la checklist di ingestione resta allineata."
    } else {
        Write-Output ""
        Write-Output "Triage: registrare le voci rilevanti in docs/infrastructure-timeline/ingestion-checklist.md,"
        Write-Output "poi rieseguire con -UpdateBaseline per accettare lo stato corrente."
    }

    if ($updateBaseline) {
        $out = @{ created = (Get-Date -Format 'yyyy-MM-dd HH:mm'); folder = $folder; files = $current }
        $out | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $baselinePath -Encoding UTF8
        Write-Output ""
        Write-Output "Baseline aggiornata ($($current.Count) file)."
    }
    Write-Output ""
}

foreach ($t in $targets) {
    Invoke-DeltaCheck -target $t -maxList $MaxList -updateBaseline $UpdateBaseline
}
