# Check-OneDriveDelta.ps1
# Confronta lo stato corrente della cartella OneDrive "Documenti - IT" con una
# baseline salvata localmente e riporta i file nuovi, modificati ed eliminati.
# Serve al check di inizio sessione del progetto network-design: la checklist di
# ingestione (docs/infrastructure-timeline/ingestion-checklist.md) fotografa un
# momento preciso, e questo script dice cosa e' cambiato da allora senza rileggere
# nulla a mano. Lavoro deterministico: nessun contenuto viene letto, solo percorsi,
# dimensioni e date di modifica.
#
# La baseline vive in _notes/ (ignorata da git) perche' contiene nomi di file
# reali, che possono includere nomi di persone: non va mai versionata ne' copiata
# in un file tracciato (vedi .claude/rules/anonymization.md).
#
# Uso:
#   .\scripts\Check-OneDriveDelta.ps1                  # report del delta
#   .\scripts\Check-OneDriveDelta.ps1 -UpdateBaseline  # accetta lo stato corrente come nuova baseline
#   .\scripts\Check-OneDriveDelta.ps1 -MaxList 10      # limita le righe elencate per categoria

param(
    [string]$Folder = "C:\Users\Utente\OneDrive - Intrawelt S.a.s\Documenti - IT",
    [string]$BaselinePath = "$PSScriptRoot\..\_notes\.onedrive-manifest.json",
    [switch]$UpdateBaseline,
    [int]$MaxList = 25
)

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

if (-not (Test-Path $Folder)) {
    Write-Output "ERRORE: cartella non trovata: $Folder"
    exit 1
}

$current = @{}
Get-ChildItem -LiteralPath $Folder -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { (-not (Test-Excluded $_.FullName)) -and ($_.Name -ne 'desktop.ini') -and ($_.Extension -ne '.lnk') -and ($_.Name -notlike '~$*') } |
    ForEach-Object {
        $rel = $_.FullName.Substring($Folder.Length).TrimStart('\')
        $current[$rel] = @{ t = $_.LastWriteTimeUtc.Ticks; s = $_.Length }
    }

if (-not (Test-Path $BaselinePath)) {
    if ($UpdateBaseline) {
        $out = @{ created = (Get-Date -Format 'yyyy-MM-dd HH:mm'); folder = $Folder; files = $current }
        $out | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $BaselinePath -Encoding UTF8
        Write-Output "Baseline creata: $($current.Count) file censiti in $BaselinePath"
    } else {
        Write-Output "Nessuna baseline trovata ($BaselinePath)."
        Write-Output "Eseguire con -UpdateBaseline per crearla dallo stato corrente ($($current.Count) file)."
    }
    exit 0
}

$baselineRaw = Get-Content -LiteralPath $BaselinePath -Raw -Encoding UTF8 | ConvertFrom-Json
$baseline = @{}
$baselineRaw.files.PSObject.Properties | ForEach-Object { $baseline[$_.Name] = $_.Value }

$new = @(); $modified = @(); $deleted = @()
foreach ($k in $current.Keys) {
    if (-not $baseline.ContainsKey($k)) { $new += $k }
    elseif ($baseline[$k].t -ne $current[$k].t -or $baseline[$k].s -ne $current[$k].s) { $modified += $k }
}
foreach ($k in $baseline.Keys) { if (-not $current.ContainsKey($k)) { $deleted += $k } }

Write-Output "=== Delta OneDrive IT vs baseline del $($baselineRaw.created) ==="
Write-Output "Nuovi: $($new.Count) | Modificati: $($modified.Count) | Eliminati: $($deleted.Count) | Censiti: $($current.Count)"
foreach ($pair in @(@('NUOVI', $new), @('MODIFICATI', $modified), @('ELIMINATI', $deleted))) {
    $label = $pair[0]; $list = $pair[1]
    if ($list.Count -gt 0) {
        Write-Output ""
        Write-Output "--- $label ---"
        $list | Sort-Object | Select-Object -First $MaxList | ForEach-Object { Write-Output "  $_" }
        if ($list.Count -gt $MaxList) { Write-Output "  ... e altri $($list.Count - $MaxList)" }
    }
}
if ($new.Count -eq 0 -and $modified.Count -eq 0 -and $deleted.Count -eq 0) {
    Write-Output "Nessuna variazione: la checklist di ingestione resta allineata."
} else {
    Write-Output ""
    Write-Output "Triage: registrare le voci rilevanti in docs/infrastructure-timeline/ingestion-checklist.md,"
    Write-Output "poi rieseguire con -UpdateBaseline per accettare lo stato corrente."
}

if ($UpdateBaseline) {
    $out = @{ created = (Get-Date -Format 'yyyy-MM-dd HH:mm'); folder = $Folder; files = $current }
    $out | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $BaselinePath -Encoding UTF8
    Write-Output ""
    Write-Output "Baseline aggiornata ($($current.Count) file)."
}
