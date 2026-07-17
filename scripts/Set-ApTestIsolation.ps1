<#
.SYNOPSIS
    Ausilio diagnostico per M13a: spegne/riaccende il PoE degli AP noti tramite Nebula
    OpenAPI, per isolare un solo AP durante un test di connessione senza ambiguita' su
    quale access point stia realmente rispondendo al client di prova.
.DESCRIPTION
    Nato dall'incidente del 16/07/2026 (docs/runbook-anomalie.md §NET-005): un client
    Wi-Fi in un punto dell'edificio puo' agganciare un AP diverso da quello che si sta
    testando, rendendo inconcludente un test fatto solo con uno smartphone. Questo
    script spegne temporaneamente l'alimentazione PoE (non la VLAN, non altre
    impostazioni) degli AP diversi da quello indicato con -Keep, cosi' un client puo'
    agganciare solo l'AP sotto test se qualcosa trasmette davvero.

    Stessa disciplina di sicurezza di Set-NebulaWifiVlan.ps1: dry-run di default,
    -Apply piu' conferma testuale per scrivere davvero. -Restore riaccende tutti e tre
    gli AP (da usare sempre a fine test, anche se il risultato e' negativo).
.PARAMETER ApiKey
    Chiave API Nebula. Stessa risoluzione degli altri script: parametro -> variabile
    d'ambiente NEBULA_API_KEY -> prompt SecureString a runtime.
.PARAMETER Keep
    Quale AP lasciare acceso ('PianoTerra', 'PianoPrimo' o 'PianoSecondo'). Gli altri
    due vengono spenti. Ignorato con -Restore.
.PARAMETER Restore
    Riaccende il PoE su tutti e tre gli AP, indipendentemente da -Keep. Da eseguire
    sempre a fine finestra di test.
.PARAMETER Apply
    Se omesso, dry-run: stampa il piano senza scrivere nulla.
.EXAMPLE
    .\scripts\Set-ApTestIsolation.ps1 -Keep PianoTerra -Apply
    Spegne PianoPrimo e PianoSecondo, lascia acceso solo PianoTerra, per un test pulito.
.EXAMPLE
    .\scripts\Set-ApTestIsolation.ps1 -Restore -Apply
    Riaccende tutti e tre gli AP a fine test.
#>

[CmdletBinding()]
param(
    [string]$ApiKey,
    [ValidateSet('PianoTerra', 'PianoPrimo', 'PianoSecondo')]
    [string]$Keep,
    [switch]$Restore,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

if (-not $Restore -and -not $Keep) {
    Write-Error "Specificare -Keep <AP> oppure -Restore."
    exit 1
}

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
if (-not $ApiKey) {
    Write-Error "Nessuna chiave API disponibile. Interrompo."
    exit 1
}

$baseUrl = "https://api.nebula.zyxel.com/v1/nebula"
$headers = @{ "X-ZyxelNebula-API-Key" = $ApiKey }

function Invoke-NebulaGet {
    param([string]$Path)
    try { return Invoke-RestMethod -Uri "$baseUrl$Path" -Method GET -Headers $headers }
    catch { Write-Warning "  [WARN] GET $Path : $_"; return $null }
}
function Invoke-NebulaPostPortSettings {
    param([string]$SiteId, [string]$DevId, [hashtable]$Body)
    $json = $Body | ConvertTo-Json -Compress
    try { return Invoke-RestMethod -Uri "$baseUrl/$SiteId/sw/$DevId/port-settings" -Method POST -Headers $headers -Body $json -ContentType 'application/json' }
    catch { Write-Warning "  [WARN] POST port-settings (portNum=$($Body.portNum)) : $_"; return $null }
}
function Get-NebulaArrayValue {
    param($Response)
    if ($null -eq $Response) { return @() }
    if ($Response.PSObject.Properties.Name -contains 'value') { return @($Response.value) }
    return @($Response)
}

$Targets = @(
    @{ SwitchMac = "70:49:A2:39:F9:00"; SwitchModel = "XGS2220-30HP"; PortNum = 1;  ApName = "PianoTerra" },
    @{ SwitchMac = "F4:4D:5C:8F:7C:39"; SwitchModel = "XGS2220-54HP"; PortNum = 41; ApName = "PianoPrimo" },
    @{ SwitchMac = "F4:4D:5C:8F:7C:39"; SwitchModel = "XGS2220-54HP"; PortNum = 45; ApName = "PianoSecondo" }
)

Write-Host "Scoperta organizzazione e siti Nebula..." -ForegroundColor Cyan
$orgs = @(Invoke-NebulaGet "/organizations")
if (-not $orgs -or $orgs.Count -eq 0) { Write-Error "Impossibile elencare le organizzazioni."; exit 1 }

$plan = New-Object System.Collections.Generic.List[object]
foreach ($org in $orgs) {
    $sites = @(Invoke-NebulaGet "/organizations/$($org.orgId)/sites")
    $siteDevicesResp = Invoke-NebulaGet "/organizations/$($org.orgId)/sites/devices"
    foreach ($site in $sites) {
        $deviceGroup = $siteDevicesResp | Where-Object { $_.siteId -eq $site.siteId }
        $devices = if ($deviceGroup) { $deviceGroup.devices } else { @() }
        $switches = @($devices | Where-Object { $_.type -eq "SW" })
        foreach ($sw in $switches) {
            $portSettings = Get-NebulaArrayValue (Invoke-NebulaGet "/$($site.siteId)/sw/$($sw.devId)/port-settings")
            foreach ($t in ($Targets | Where-Object { $_.SwitchMac -eq $sw.mac })) {
                $current = $portSettings | Where-Object { $_.portNum -eq $t.PortNum } | Select-Object -First 1
                if (-not $current) { continue }
                $targetPse = if ($Restore) { $true } else { $t.ApName -eq $Keep }
                $plan.Add([PSCustomObject]@{
                    SiteId = $site.siteId; DevId = $sw.devId; SwitchModel = $sw.model
                    PortNum = $t.PortNum; ApName = $t.ApName
                    CurrentPse = $current.pseEnabled; TargetPse = $targetPse
                    PortVid = $current.portVid; Trunk = $current.trunk; AllowedVLAN = $current.allowedVLAN
                    Changed = ($current.pseEnabled -ne $targetPse)
                })
            }
        }
    }
}

$mode = if ($Restore) { "Restore (tutti accesi)" } else { "Keep $Keep" }
Write-Host "`n=== Piano isolamento test AP ($mode) ===" -ForegroundColor Cyan
$plan | Sort-Object ApName | Format-Table ApName, SwitchModel, PortNum, CurrentPse, TargetPse, Changed -AutoSize | Out-String | Write-Host

$toChange = @($plan | Where-Object { $_.Changed })
if ($toChange.Count -eq 0) {
    Write-Host "Nessuna modifica necessaria: gia' nello stato desiderato." -ForegroundColor Green
    exit 0
}
if (-not $Apply) {
    Write-Host "Dry-run: nessuna richiesta di scrittura inviata. Rilanciare con -Apply per procedere." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nATTENZIONE: questo spegne/accende per davvero l'alimentazione PoE di access point live." -ForegroundColor Red
Write-Host "Digitare CONFERMA (maiuscolo) per procedere, qualunque altro input annulla." -ForegroundColor Red
if ((Read-Host "Conferma") -ne "CONFERMA") {
    Write-Host "Annullato dall'utente. Nessuna modifica inviata." -ForegroundColor Yellow
    exit 0
}

foreach ($item in $toChange) {
    $body = @{ portNum = $item.PortNum; enabled = $true; trunk = $item.Trunk; portVid = $item.PortVid; allowedVLAN = $item.AllowedVLAN; pseEnabled = $item.TargetPse }
    Write-Host "$($item.ApName): PoE -> $($item.TargetPse)..." -ForegroundColor Cyan
    Invoke-NebulaPostPortSettings -SiteId $item.SiteId -DevId $item.DevId -Body $body | Out-Null
}
Write-Host "`nFatto. Se hai usato -Keep, ricordati di rilanciare con -Restore a fine test." -ForegroundColor Green
