<#
.SYNOPSIS
    Snapshot della configurazione Zyxel Nebula via API REST ufficiale (Nebula OpenAPI).
.DESCRIPTION
    Interroga l'API pubblica di Zyxel Nebula (https://api.nebula.zyxel.com/v1/nebula)
    e produce due file di output nella cartella output/:
      nebula-snapshot.json   dump strutturato completo (organizzazioni, siti, dispositivi,
                              stato porte, tabella MAC L2 per switch)
      nebula-config.md       riepilogo Markdown leggibile, pronto per Claude Code

    Nato per rispondere a una domanda operativa precisa: quali dispositivi (per MAC
    address) sono collegati a quale porta di quale switch, per identificare gli access
    point WiFi fisici quando non compaiono come dispositivi gestiti in Nebula (vedi
    docs/runbook-anomalie.md §AP-001).

    La chiave API non viene mai scritta su disco da questo script. Ordine di risoluzione:
    parametro -ApiKey, poi variabile d'ambiente NEBULA_API_KEY, infine prompt a runtime
    (SecureString, mai in chiaro).

    Endpoint usati (verificati contro la documentazione ufficiale
    https://zyxelnetworks.github.io/NebulaOpenAPI/doc/openapi.html il 14/07/2026):
      GET  /organizations
      GET  /organizations/{orgId}/sites
      GET  /organizations/{orgId}/sites/devices
      GET  /{siteId}/sw/{devId}/ports-status
      GET  /{siteId}/sw/{devId}/port-settings
      GET  /{siteId}/sw/{devId}/l2-mac-table
      POST /v2/{siteId}/sw-clients   (best-effort: schema del body non documentato in
                                       dettaglio, fallisce silenziosamente con warning
                                       se il body atteso e' diverso da quello tentato)

    Compatibile con PowerShell 5.1 (Windows PowerShell) e PowerShell 7+.
.PARAMETER ApiKey
    Chiave API Nebula. Percorso reale per generarla (verificato il 14/07/2026,
    non ovvio - non e' sotto "Organization-wide manage"): icona "..." nella
    barra in alto di Nebula Control Center > "My devices & services" > scheda
    "NCC OpenAPI Key" > Generate. Richiede licenza Nebula Professional Pack
    sui dispositivi dell'organizzazione. Se il parametro e' omesso, si prova
    la variabile d'ambiente NEBULA_API_KEY, poi si chiede a runtime.
.PARAMETER OrgId
    ID organizzazione specifico. Se omesso, lo script itera su tutte le organizzazioni
    visibili con quella chiave API.
.PARAMETER OutputDir
    Cartella di destinazione dell'output. Default: output\ nella radice del progetto.
.EXAMPLE
    .\scripts\Get-NebulaSnapshot.ps1
.EXAMPLE
    .\scripts\Get-NebulaSnapshot.ps1 -OrgId "abcdef0123456789"
#>

[CmdletBinding()]
param(
    [string]$ApiKey,
    [string]$OrgId,
    [string]$OutputDir
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 0. Cartella output
# ---------------------------------------------------------------------------
if (-not $OutputDir) {
    $scriptDir  = Split-Path $PSCommandPath -Parent
    $projectDir = Split-Path $scriptDir -Parent
    $OutputDir  = Join-Path $projectDir "output"
}
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}
Write-Host "Output verso: $OutputDir" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Chiave API: parametro -> variabile d'ambiente -> prompt runtime
# ---------------------------------------------------------------------------
if (-not $ApiKey) {
    if ($env:NEBULA_API_KEY) {
        $ApiKey = $env:NEBULA_API_KEY
        Write-Host "Chiave API letta da variabile d'ambiente NEBULA_API_KEY." -ForegroundColor DarkGray
    } else {
        $secureKey = Read-Host "Chiave API Nebula (Nebula Control Center > API Key Management)" -AsSecureString
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

# ---------------------------------------------------------------------------
# 2. Helper GET / POST API
# ---------------------------------------------------------------------------
function Invoke-NebulaGet {
    param([string]$Path)
    try {
        return Invoke-RestMethod -Uri "$baseUrl$Path" -Method GET -Headers $headers
    } catch {
        Write-Warning "  [WARN] GET $Path : $_"
        return $null
    }
}

function Invoke-NebulaPost {
    param([string]$Path, [string]$BodyJson = '{}')
    try {
        return Invoke-RestMethod -Uri "$baseUrl$Path" -Method POST -Headers $headers -Body $BodyJson -ContentType 'application/json'
    } catch {
        Write-Warning "  [WARN] POST $Path (best-effort, schema body non documentato con certezza) : $_"
        return $null
    }
}

# ---------------------------------------------------------------------------
# 3. Organizzazioni
# ---------------------------------------------------------------------------
Write-Host "`nRaccolta organizzazioni..." -ForegroundColor Cyan
$orgsResp = Invoke-NebulaGet "/organizations"
if (-not $orgsResp) {
    Write-Error "Impossibile elencare le organizzazioni. Verificare la chiave API."
    exit 1
}
$allOrgs = @($orgsResp)
if ($OrgId) {
    $allOrgs = @($allOrgs | Where-Object { $_.orgId -eq $OrgId })
    if ($allOrgs.Count -eq 0) {
        Write-Error "Nessuna organizzazione con orgId '$OrgId' visibile con questa chiave."
        exit 1
    }
}
Write-Host "  Organizzazioni trovate: $($allOrgs.Count)" -ForegroundColor Gray

$orgsData = @()
foreach ($org in $allOrgs) {
    $oid = $org.orgId
    Write-Host "`nOrganizzazione: $($org.name) ($oid)" -ForegroundColor Cyan

    Write-Host "  Raccolta siti..." -ForegroundColor DarkGray
    $sites = Invoke-NebulaGet "/organizations/$oid/sites"

    Write-Host "  Raccolta dispositivi..." -ForegroundColor DarkGray
    $siteDevicesResp = Invoke-NebulaGet "/organizations/$oid/sites/devices"

    $sitesData = @()
    if ($sites) {
        foreach ($site in $sites) {
            $sid = $site.siteId
            Write-Host "    Sito: $($site.name) ($sid)" -ForegroundColor Gray

            $deviceGroup = $siteDevicesResp | Where-Object { $_.siteId -eq $sid }
            $devices = if ($deviceGroup) { $deviceGroup.devices } else { @() }

            $switchesData = @()
            foreach ($dev in $devices) {
                if ($dev.type -ne "SW") { continue }
                $devId = $dev.devId
                Write-Host "      Switch: $($dev.name) [$($dev.model)] devId=$devId" -ForegroundColor DarkGray

                $portsStatus  = Invoke-NebulaGet "/$sid/sw/$devId/ports-status"
                $portSettings = Invoke-NebulaGet "/$sid/sw/$devId/port-settings"
                $l2MacTable   = Invoke-NebulaGet "/$sid/sw/$devId/l2-mac-table"
                $swClients    = Invoke-NebulaPost "/v2/$sid/sw-clients" (@{ devId = $devId } | ConvertTo-Json -Compress)

                $switchesData += [PSCustomObject]@{
                    devId          = $devId
                    name           = $dev.name
                    model          = $dev.model
                    mac            = $dev.mac
                    sn             = $dev.sn
                    ports_status   = $portsStatus
                    port_settings  = $portSettings
                    l2_mac_table   = $l2MacTable
                    sw_clients     = $swClients
                }
            }

            $sitesData += [PSCustomObject]@{
                siteId    = $sid
                name      = $site.name
                timeZone  = $site.timeZone
                devices   = $devices
                switches  = $switchesData
            }
        }
    }

    $orgsData += [PSCustomObject]@{
        orgId = $oid
        name  = $org.name
        mode  = $org.mode
        sites = $sitesData
    }
}

# ---------------------------------------------------------------------------
# 4. Output JSON
# ---------------------------------------------------------------------------
$snapshot = [PSCustomObject]@{
    generated_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    organizations = $orgsData
}
$jsonPath = Join-Path $OutputDir "nebula-snapshot.json"
$snapshot | ConvertTo-Json -Depth 20 | Out-File -FilePath $jsonPath -Encoding utf8
Write-Host "`nJSON:     $jsonPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 5. Output Markdown
# ---------------------------------------------------------------------------
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Zyxel Nebula - Snapshot infrastruttura")
$lines.Add("")
$lines.Add("> Generato il $(Get-Date -Format 'yyyy-MM-dd HH:mm') via Nebula OpenAPI.")
$lines.Add("")

foreach ($org in $orgsData) {
    $lines.Add("## Organizzazione: $($org.name)")
    $lines.Add("")
    $lines.Add("| Campo | Valore |")
    $lines.Add("|---|---|")
    $lines.Add("| Org ID | $($org.orgId) |")
    $lines.Add("| Mode | $($org.mode) |")
    $lines.Add("")

    foreach ($site in $org.sites) {
        $lines.Add("### Sito: $($site.name)")
        $lines.Add("")
        $lines.Add("Site ID: $($site.siteId) - Timezone: $($site.timeZone)")
        $lines.Add("")

        if ($site.devices -and $site.devices.Count -gt 0) {
            $lines.Add("#### Inventario dispositivi")
            $lines.Add("")
            $lines.Add("| Nome | Tipo | Modello | MAC | Serial |")
            $lines.Add("|---|---|---|---|---|")
            foreach ($d in $site.devices) {
                $lines.Add("| $($d.name) | $($d.type) | $($d.model) | $($d.mac) | $($d.sn) |")
            }
            $lines.Add("")
            $apCount = @($site.devices | Where-Object { $_.type -eq "AP" }).Count
            if ($apCount -eq 0) {
                $lines.Add("> Nessun dispositivo di tipo AP in questa organizzazione Nebula: conferma che gli access point WiFi fisici non sono gestiti da questo portale (vedi `runbook-anomalie.md` §AP-001).")
                $lines.Add("")
            }
        }

        foreach ($sw in $site.switches) {
            $lines.Add("#### Switch: $($sw.name) [$($sw.model)]")
            $lines.Add("")
            $lines.Add("devId: $($sw.devId) - MAC: $($sw.mac) - S/N: $($sw.sn)")
            $lines.Add("")

            if ($sw.l2_mac_table -and @($sw.l2_mac_table).Count -gt 0) {
                $lines.Add("Tabella MAC L2 (chi e' collegato a quale porta):")
                $lines.Add("")
                $lines.Add("| Porta | MAC Address | VLAN |")
                $lines.Add("|---|---|---|")
                foreach ($m in ($sw.l2_mac_table | Sort-Object portNum)) {
                    $lines.Add("| $($m.portNum) | $($m.macAddress) | $($m.vlan) |")
                }
                $lines.Add("")
            } else {
                $lines.Add("> Tabella MAC L2 non disponibile per questo switch.")
                $lines.Add("")
            }

            if ($sw.ports_status -and @($sw.ports_status).Count -gt 0) {
                $lines.Add("Stato porte:")
                $lines.Add("")
                $lines.Add("| Porta | Link speed |")
                $lines.Add("|---|---|")
                foreach ($p in ($sw.ports_status | Sort-Object portNum)) {
                    $lines.Add("| $($p.portNum) | $($p.linkSpeed) |")
                }
                $lines.Add("")
            }
        }
    }
}

$mdPath = Join-Path $OutputDir "nebula-config.md"
$lines | Out-File -FilePath $mdPath -Encoding utf8
Write-Host "Markdown: $mdPath" -ForegroundColor Green
Write-Host "`nSnapshot completato." -ForegroundColor Green
Write-Host "Cerca il MAC vendor Ubiquiti nella tabella MAC L2 di ciascuno switch per localizzare gli AP per porta." -ForegroundColor Yellow
