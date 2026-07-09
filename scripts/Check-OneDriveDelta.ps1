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

$defaultTargets = @(
    @{ Label = "Documenti - IT"; Folder = "C:\Users\Utente\OneDrive - Intrawelt S.a.s\Documenti - IT"; BaselinePath = "$PSScriptRoot\..\_notes\.onedrive-manifest.json" },
    @{ Label = "IT + Administration - Documenti"; Folder = "C:\Users\Utente\OneDrive - Intrawelt S.a.s\IT + Administration - Documenti"; BaselinePath = "$PSScriptRoot\..\_notes\.onedrive-manifest-admin.json" }
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
function Test-Excluded([string]$fullName) {
    foreach ($p in $excludePatterns) { if ($fullName -like $p) { return $true } }
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
    foreach ($pair in @(@('NUOVI', $new), @('MODIFICATI', $modified), @('ELIMINATI', $deleted))) {
        $itemLabel = $pair[0]; $list = $pair[1]
        if ($list.Count -gt 0) {
            Write-Output ""
            Write-Output "--- $itemLabel ---"
            $list | Sort-Object | Select-Object -First $maxList | ForEach-Object { Write-Output "  $_" }
            if ($list.Count -gt $maxList) { Write-Output "  ... e altri $($list.Count - $maxList)" }
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
