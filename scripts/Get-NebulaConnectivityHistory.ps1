<#
.SYNOPSIS
    Diagnostica di sola lettura per NEB-001: storico di connettivita' cloud e log
    eventi dei due switch Nebula, per correlare le anomalie osservate il 16/07/2026
    (scritture non stabili, PoE non effettivo) con eventuali disconnessioni dal cloud.
.DESCRIPTION
    Interroga due endpoint Nebula OpenAPI non ancora usati dagli altri script di questo
    progetto (verificati il 16/07/2026 contro zyxelnetworks.github.io/NebulaOpenAPI):
      POST /{siteId}/{devId}/connectivity   storico online/offline (begin_time, end_time,
                                             status) per il periodo indicato
      POST /{siteId}/sw/{devId}/event-logs  log eventi dello switch tra due timestamp
    Nessuna scrittura: stesso perimetro di sicurezza di Get-NebulaSnapshot.ps1. Lo schema
    esatto del body/risposta non e' stato verificato con una chiamata reale prima d'ora:
    in try/catch con warning, non hard-fail, se la forma non corrisponde.
.PARAMETER ApiKey
    Chiave API Nebula. Stessa risoluzione degli altri script del progetto.
.PARAMETER Period
    Periodo per lo storico di connettivita': '2h', '1d', '7d' o '30d'. Default '1d'.
.PARAMETER HoursBack
    Ore indietro da coprire per i log eventi (event-logs usa timestamp espliciti,
    non un periodo predefinito come connectivity). Default 24.
.PARAMETER OutputDir
    Cartella di destinazione. Default: output/ nella radice del progetto.
.EXAMPLE
    .\scripts\Get-NebulaConnectivityHistory.ps1
    Storico connettivita' (1 giorno) e log eventi (ultime 24h) per entrambi gli switch.
#>

[CmdletBinding()]
param(
    [string]$ApiKey,
    [ValidateSet('2h', '1d', '7d', '30d')]
    [string]$Period = '1d',
    [int]$HoursBack = 24,
    [string]$OutputDir
)

$ErrorActionPreference = 'Stop'

if (-not $OutputDir) {
    $scriptDir  = Split-Path $PSCommandPath -Parent
    $projectDir = Split-Path $scriptDir -Parent
    $OutputDir  = Join-Path $projectDir "output"
}
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

if (-not $ApiKey) {
    if ($env:NEBULA_API_KEY) {
        $ApiKey = $env:NEBULA_API_KEY
    } else {
        $secureKey = Read-Host "Chiave API Nebula" -AsSecureString
        $bstr      = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        $ApiKey    = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}
if (-not $ApiKey) { Write-Error "Nessuna chiave API disponibile."; exit 1 }

$baseUrl = "https://api.nebula.zyxel.com/v1/nebula"
$headers = @{ "X-ZyxelNebula-API-Key" = $ApiKey }

function Invoke-NebulaGet {
    param([string]$Path)
    try { return Invoke-RestMethod -Uri "$baseUrl$Path" -Method GET -Headers $headers }
    catch { Write-Warning "  [WARN] GET $Path : $_"; return $null }
}
function Invoke-NebulaPostBody {
    param([string]$Path, [hashtable]$Body)
    $json = $Body | ConvertTo-Json -Compress
    try { return Invoke-RestMethod -Uri "$baseUrl$Path" -Method POST -Headers $headers -Body $json -ContentType 'application/json' }
    catch { Write-Warning "  [WARN] POST $Path : $_"; return $null }
}

$nowMs   = [long]([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
$fromMs  = [long]([DateTimeOffset]((Get-Date).AddHours(-$HoursBack))).ToUnixTimeMilliseconds()

Write-Host "Scoperta organizzazione e siti Nebula..." -ForegroundColor Cyan
$orgs = @(Invoke-NebulaGet "/organizations")
if (-not $orgs -or $orgs.Count -eq 0) { Write-Error "Impossibile elencare le organizzazioni."; exit 1 }

$results = @()
foreach ($org in $orgs) {
    $sites = @(Invoke-NebulaGet "/organizations/$($org.orgId)/sites")
    $siteDevicesResp = Invoke-NebulaGet "/organizations/$($org.orgId)/sites/devices"
    foreach ($site in $sites) {
        $deviceGroup = $siteDevicesResp | Where-Object { $_.siteId -eq $site.siteId }
        $devices = if ($deviceGroup) { $deviceGroup.devices } else { @() }
        $switches = @($devices | Where-Object { $_.type -eq "SW" })
        foreach ($sw in $switches) {
            Write-Host "`nSwitch: $($sw.name) [$($sw.model)]" -ForegroundColor Cyan

            Write-Host "  Storico connettivita' (periodo $Period)..." -ForegroundColor DarkGray
            $connectivity = Invoke-NebulaPostBody "/$($site.siteId)/$($sw.devId)/connectivity" @{ period = $Period }

            Write-Host "  Log eventi (ultime $HoursBack ore)..." -ForegroundColor DarkGray
            $eventLogs = Invoke-NebulaPostBody "/$($site.siteId)/sw/$($sw.devId)/event-logs" @{ startTimestamp = $fromMs; endTimestamp = $nowMs }

            $results += [PSCustomObject]@{
                Name = $sw.name; Model = $sw.model; DevId = $sw.devId
                Connectivity = $connectivity; EventLogs = $eventLogs
            }
        }
    }
}

$jsonPath = Join-Path $OutputDir "nebula-connectivity-history.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding utf8
Write-Host "`nOutput: $jsonPath" -ForegroundColor Green

foreach ($r in $results) {
    Write-Host "`n=== $($r.Name) [$($r.Model)] ===" -ForegroundColor Cyan
    if ($r.Connectivity) {
        $r.Connectivity | Format-Table -AutoSize | Out-String | Write-Host
    } else {
        Write-Host "  (nessun dato di connettivita' - endpoint non riuscito o schema diverso da quello atteso)" -ForegroundColor Yellow
    }
    if ($r.EventLogs) {
        $r.EventLogs | Sort-Object timestamp -Descending | Select-Object -First 30 | Format-Table timestamp, category, priority, message -AutoSize | Out-String | Write-Host
    } else {
        Write-Host "  (nessun log eventi - endpoint non riuscito o schema diverso da quello atteso)" -ForegroundColor Yellow
    }
}
