<#
.SYNOPSIS
    Snapshot completo della configurazione Proxmox VE via API REST.
.DESCRIPTION
    Interroga l'API REST di Proxmox VE e produce due file di output nella cartella output/:
      proxmox-snapshot.json   dump strutturato completo (nodi, VM, LXC, storage, rete, cluster)
      proxmox-config.md       riepilogo Markdown leggibile, pronto per Claude Code

    Le credenziali vengono chieste a runtime. Nessun segreto finisce su disco.
    Compatibile con PowerShell 5.1 (Windows PowerShell) e PowerShell 7+.
    Gestisce il certificato TLS self-signed di default di Proxmox VE.

    v3: aggiunta raccolta firewall (cluster + per-VM/LXC), dischi fisici, PCI devices,
        SDN (zone/vnet), pool risorse, backup schedules, HA resources, snapshot VM.
.PARAMETER ProxmoxHost
    Hostname o indirizzo IP del nodo Proxmox (es. 192.168.20.11).
.PARAMETER Port
    Porta HTTPS dell'API Proxmox. Default: 8006.
.PARAMETER Username
    Username nel formato user@realm (es. root@pam). Se omesso, viene chiesto a runtime.
.PARAMETER OutputDir
    Cartella di destinazione dell'output. Default: output\ nella radice del progetto.
.EXAMPLE
    .\scripts\Get-ProxmoxSnapshot.ps1 -ProxmoxHost 192.168.20.11
.EXAMPLE
    .\scripts\Get-ProxmoxSnapshot.ps1 -ProxmoxHost 192.168.20.11 -Port 8006 -Username root@pam
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ProxmoxHost,

    [int]$Port = 8006,

    [string]$Username,

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
# 1. Bypass certificato TLS self-signed di Proxmox
#    PS 5.1: TrustAllCertsPolicy globale
#    PS 7+:  -SkipCertificateCheck per chiamata
# ---------------------------------------------------------------------------
$isPSCore = $PSVersionTable.PSVersion.Major -ge 7

if (-not $isPSCore) {
    try {
        Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) { return true; }
}
"@
    } catch {
        # Il tipo e' gia' definito in questa sessione: ignorare
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Write-Host "Certificato self-signed: bypass attivato (PS 5.1)" -ForegroundColor DarkGray
} else {
    Write-Host "Certificato self-signed: -SkipCertificateCheck (PS 7+)" -ForegroundColor DarkGray
}

# ---------------------------------------------------------------------------
# 2. Credenziali
# ---------------------------------------------------------------------------
if (-not $Username) {
    $Username = Read-Host "Username Proxmox (es. root@pam)"
}
if ($Username -notmatch '@') {
    Write-Warning "Username '$Username' non contiene il realm. Proxmox richiede il formato user@realm (es. root@pam)."
    $Username = "$Username@pam"
    Write-Host "  Uso: $Username" -ForegroundColor Yellow
}
$securePwd = Read-Host "Password per $Username" -AsSecureString
$bstr      = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd)
$plainPwd  = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

# ---------------------------------------------------------------------------
# 3. Autenticazione: POST /api2/json/access/ticket
# ---------------------------------------------------------------------------
$baseUrl  = "https://${ProxmoxHost}:${Port}/api2/json"
$authBody = "username=$([uri]::EscapeDataString($Username))&password=$([uri]::EscapeDataString($plainPwd))"

[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
Remove-Variable plainPwd -ErrorAction SilentlyContinue

$authParams = @{
    Uri         = "$baseUrl/access/ticket"
    Method      = 'POST'
    Body        = $authBody
    ContentType = 'application/x-www-form-urlencoded'
}
if ($isPSCore) { $authParams['SkipCertificateCheck'] = $true }

try {
    $authResp = Invoke-RestMethod @authParams
} catch {
    Write-Error "Autenticazione fallita su ${ProxmoxHost}:${Port} - $_"
    exit 1
}

$ticket = $authResp.data.ticket
$csrf   = $authResp.data.CSRFPreventionToken

if (-not $ticket) {
    Write-Error "Ticket non ricevuto. Verificare credenziali."
    exit 1
}
Write-Host "Autenticato come $Username su $ProxmoxHost" -ForegroundColor Green

# WebRequestSession con CookieContainer: unico modo affidabile in PS 5.1
# per passare il PVEAuthCookie (Invoke-RestMethod ignora l'header Cookie manuale)
$pveSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$pveCookie  = New-Object System.Net.Cookie("PVEAuthCookie", $ticket, "/", $ProxmoxHost)
$pveSession.Cookies.Add($pveCookie)

# ---------------------------------------------------------------------------
# 4. Helper GET API
# ---------------------------------------------------------------------------
function Invoke-PVEGet {
    param([string]$Path)
    $p = @{
        Uri        = "$baseUrl$Path"
        Method     = 'GET'
        WebSession = $pveSession
    }
    if ($isPSCore) { $p['SkipCertificateCheck'] = $true }
    try {
        $r = Invoke-RestMethod @p
        return $r.data
    } catch {
        Write-Warning "  [WARN] GET $Path : $_"
        return $null
    }
}

# ---------------------------------------------------------------------------
# 5. Raccolta dati
# ---------------------------------------------------------------------------
Write-Host "`nRaccolta cluster e storage globale..." -ForegroundColor Cyan
$clusterStatus    = Invoke-PVEGet "/cluster/status"
$clusterResources = Invoke-PVEGet "/cluster/resources"
$storageGlobal    = Invoke-PVEGet "/storage"

# Pool risorse
Write-Host "Raccolta pool risorse..." -ForegroundColor Cyan
$resourcePoolsList = Invoke-PVEGet "/pools"
$resourcePools = @()
if ($resourcePoolsList) {
    foreach ($pool in $resourcePoolsList) {
        $pd = Invoke-PVEGet "/pools/$($pool.poolid)"
        if ($pd) { $resourcePools += $pd } else { $resourcePools += $pool }
    }
}

# Backup schedules
Write-Host "Raccolta backup schedules..." -ForegroundColor Cyan
$backupJobs = Invoke-PVEGet "/cluster/backup"

# HA
Write-Host "Raccolta HA..." -ForegroundColor Cyan
$haResources = Invoke-PVEGet "/cluster/ha/resources"
$haGroups    = Invoke-PVEGet "/cluster/ha/groups"

# Firewall cluster
Write-Host "Raccolta firewall cluster..." -ForegroundColor Cyan
$clusterFwOptions = Invoke-PVEGet "/cluster/firewall/options"
$clusterFwRules   = Invoke-PVEGet "/cluster/firewall/rules"
$clusterFwAliases = Invoke-PVEGet "/cluster/firewall/aliases"
$clusterFwIpsetList = Invoke-PVEGet "/cluster/firewall/ipset"
$fwIpsetDetails = @{}
if ($clusterFwIpsetList) {
    foreach ($ipset in $clusterFwIpsetList) {
        $members = Invoke-PVEGet "/cluster/firewall/ipset/$($ipset.name)"
        if ($members) { $fwIpsetDetails[$ipset.name] = $members }
    }
}

# SDN (Software Defined Networking) - disponibile in PVE 7+
Write-Host "Raccolta SDN..." -ForegroundColor Cyan
$sdnZones      = Invoke-PVEGet "/cluster/sdn/zones"
$sdnVnets      = Invoke-PVEGet "/cluster/sdn/vnets"
$sdnControllers = Invoke-PVEGet "/cluster/sdn/controllers"

# Nodi
Write-Host "Raccolta nodi..." -ForegroundColor Cyan
$nodesList = Invoke-PVEGet "/nodes"

$nodesData = @()
foreach ($node in $nodesList) {
    $n = $node.node
    Write-Host "  Nodo: $n" -ForegroundColor Gray

    $nodeStatus  = Invoke-PVEGet "/nodes/$n/status"
    $nodeStorage = Invoke-PVEGet "/nodes/$n/storage"

    # Rete: lista + dettaglio per-interfaccia
    Write-Host "    Rete (dettaglio per-interfaccia)..." -ForegroundColor DarkGray
    $nodeNetworkList = Invoke-PVEGet "/nodes/$n/network"
    $nodeNetworkDetail = @()
    if ($nodeNetworkList) {
        foreach ($iface in $nodeNetworkList) {
            $detail = Invoke-PVEGet "/nodes/$n/network/$($iface.iface)"
            if ($detail) {
                # Il dettaglio per-interfaccia non include il nome: lo inietta dalla lista
                $detail | Add-Member -NotePropertyName 'iface' -NotePropertyValue $iface.iface -Force
                $nodeNetworkDetail += $detail
            } else {
                $nodeNetworkDetail += $iface
            }
        }
    }

    # Dischi fisici
    Write-Host "    Dischi fisici..." -ForegroundColor DarkGray
    $nodeDisks = Invoke-PVEGet "/nodes/$n/disks/list"
    $nodeLvm   = Invoke-PVEGet "/nodes/$n/disks/lvm"
    $nodeZfs   = Invoke-PVEGet "/nodes/$n/disks/zfs"

    # PCI devices (NIC fisiche, GPU, HBA, schede di espansione)
    Write-Host "    PCI devices..." -ForegroundColor DarkGray
    $nodePci = Invoke-PVEGet "/nodes/$n/hardware/pci"

    # Firewall per nodo
    Write-Host "    Firewall nodo..." -ForegroundColor DarkGray
    $nodeFwRules   = Invoke-PVEGet "/nodes/$n/firewall/rules"
    $nodeFwOptions = Invoke-PVEGet "/nodes/$n/firewall/options"

    # VM QEMU: config + status + IP via guest agent + firewall + snapshot
    Write-Host "    VM QEMU..." -ForegroundColor DarkGray
    $qemuList = Invoke-PVEGet "/nodes/$n/qemu"
    $vms = @()
    if ($qemuList) {
        foreach ($vm in $qemuList) {
            $vmid   = $vm.vmid
            $cfg    = Invoke-PVEGet "/nodes/$n/qemu/$vmid/config"
            $status = Invoke-PVEGet "/nodes/$n/qemu/$vmid/status/current"

            # IP via QEMU guest agent (richiede qemu-guest-agent installato nella VM)
            $agentNet = $null
            if ($vm.status -eq 'running') {
                $agentNet = Invoke-PVEGet "/nodes/$n/qemu/$vmid/agent/network-get-interfaces"
            }

            # Firewall per VM (indipendente dallo stato running/stopped)
            $vmFwRules   = Invoke-PVEGet "/nodes/$n/qemu/$vmid/firewall/rules"
            $vmFwOptions = Invoke-PVEGet "/nodes/$n/qemu/$vmid/firewall/options"

            # Snapshot list
            $vmSnapshots = Invoke-PVEGet "/nodes/$n/qemu/$vmid/snapshot"

            $vms += [PSCustomObject]@{
                vmid         = $vmid
                name         = $vm.name
                status       = $vm.status
                config       = $cfg
                runtime      = $status
                agent_net    = $agentNet
                fw_rules     = $vmFwRules
                fw_options   = $vmFwOptions
                snapshots    = $vmSnapshots
            }
        }
    }

    # LXC: config + status + interfacce runtime + firewall
    Write-Host "    LXC..." -ForegroundColor DarkGray
    $lxcList = Invoke-PVEGet "/nodes/$n/lxc"
    $containers = @()
    if ($lxcList) {
        foreach ($ct in $lxcList) {
            $vmid   = $ct.vmid
            $cfg    = Invoke-PVEGet "/nodes/$n/lxc/$vmid/config"
            $status = Invoke-PVEGet "/nodes/$n/lxc/$vmid/status/current"

            $lxcIfaces = $null
            if ($ct.status -eq 'running') {
                $lxcIfaces = Invoke-PVEGet "/nodes/$n/lxc/$vmid/interfaces"
            }

            $ctFwRules   = Invoke-PVEGet "/nodes/$n/lxc/$vmid/firewall/rules"
            $ctFwOptions = Invoke-PVEGet "/nodes/$n/lxc/$vmid/firewall/options"

            $containers += [PSCustomObject]@{
                vmid       = $vmid
                name       = $ct.name
                status     = $ct.status
                config     = $cfg
                runtime    = $status
                interfaces = $lxcIfaces
                fw_rules   = $ctFwRules
                fw_options = $ctFwOptions
            }
        }
    }

    $nodesData += [PSCustomObject]@{
        node         = $n
        status       = $nodeStatus
        network      = $nodeNetworkDetail
        storage      = $nodeStorage
        disks        = $nodeDisks
        lvm          = $nodeLvm
        zfs          = $nodeZfs
        pci          = $nodePci
        fw_rules     = $nodeFwRules
        fw_options   = $nodeFwOptions
        vms          = $vms
        containers   = $containers
    }
}

# ---------------------------------------------------------------------------
# 6. Output JSON
# ---------------------------------------------------------------------------
$snapshot = [PSCustomObject]@{
    generated_at    = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    proxmox_host    = $ProxmoxHost
    cluster         = $clusterStatus
    resources       = $clusterResources
    storage         = $storageGlobal
    pools           = $resourcePools
    backup_jobs     = $backupJobs
    ha_resources    = $haResources
    ha_groups       = $haGroups
    fw_options      = $clusterFwOptions
    fw_rules        = $clusterFwRules
    fw_aliases      = $clusterFwAliases
    fw_ipsets       = $clusterFwIpsetList
    fw_ipset_detail = $fwIpsetDetails
    sdn_zones       = $sdnZones
    sdn_vnets       = $sdnVnets
    sdn_controllers = $sdnControllers
    nodes           = $nodesData
}

$jsonPath = Join-Path $OutputDir "proxmox-snapshot.json"
$snapshot | ConvertTo-Json -Depth 20 | Out-File -FilePath $jsonPath -Encoding utf8
Write-Host "`nJSON:     $jsonPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 7. Output Markdown
# ---------------------------------------------------------------------------
$lines = [System.Collections.Generic.List[string]]::new()

$lines.Add("# Proxmox VE - Snapshot infrastruttura")
$lines.Add("")
$lines.Add("> Generato il $(Get-Date -Format 'yyyy-MM-dd HH:mm') da ``$ProxmoxHost``.")
$lines.Add("")

# ---------------------------------------------------------------------------
# Cluster
# ---------------------------------------------------------------------------
$lines.Add("## Cluster")
$lines.Add("")
if ($clusterStatus) {
    $ci = $clusterStatus | Where-Object { $_.type -eq 'cluster' }
    $cn = $clusterStatus | Where-Object { $_.type -eq 'node' }
    if ($ci) {
        $lines.Add("| Campo | Valore |")
        $lines.Add("|---|---|")
        $lines.Add("| Nome | $($ci.name) |")
        $lines.Add("| Quorum | $($ci.quorate) |")
        $lines.Add("| Versione | $($ci.version) |")
        $lines.Add("| Nodi | $($ci.nodes) |")
        $lines.Add("")
    }
    if ($cn) {
        $lines.Add("### Nodi nel cluster")
        $lines.Add("")
        $lines.Add("| Nodo | Online | IP | Level |")
        $lines.Add("|---|---|---|---|")
        foreach ($x in $cn) {
            $online = if ($x.online -eq 1) { "si" } else { "no" }
            $lines.Add("| $($x.name) | $online | $($x.ip) | $($x.level) |")
        }
        $lines.Add("")
    }
}

# ---------------------------------------------------------------------------
# Pool risorse
# ---------------------------------------------------------------------------
if ($resourcePools -and $resourcePools.Count -gt 0) {
    $lines.Add("## Pool risorse")
    $lines.Add("")
    foreach ($pool in $resourcePools) {
        $lines.Add("### Pool: $($pool.poolid)")
        $lines.Add("")
        if ($pool.comment) { $lines.Add("> $($pool.comment)") ; $lines.Add("") }
        if ($pool.members) {
            $vmMembers = $pool.members | Where-Object { $_.type -eq 'qemu' -or $_.type -eq 'lxc' }
            if ($vmMembers) {
                $lines.Add("| VMID | Nome | Tipo | Stato |")
                $lines.Add("|---|---|---|---|")
                foreach ($m in ($vmMembers | Sort-Object vmid)) {
                    $lines.Add("| $($m.vmid) | $($m.name) | $($m.type) | $($m.status) |")
                }
                $lines.Add("")
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Backup schedules
# ---------------------------------------------------------------------------
if ($backupJobs -and $backupJobs.Count -gt 0) {
    $lines.Add("## Backup schedules")
    $lines.Add("")
    $lines.Add("| ID | Abilitato | Schedule | Storage dest | VM/CT | Compress | Mode | Commento |")
    $lines.Add("|---|---|---|---|---|---|---|---|")
    foreach ($job in $backupJobs) {
        $enabled  = if ($job.enabled -eq 0) { "no" } else { "si" }
        $vmids    = if ($job.vmid)    { $job.vmid }    else { "tutte" }
        $compress = if ($job.compress) { $job.compress } else { "" }
        $mode     = if ($job.mode)    { $job.mode }    else { "" }
        $comment  = if ($job.comment) { $job.comment } else { "" }
        $lines.Add("| $($job.id) | $enabled | $($job.schedule) | $($job.storage) | $vmids | $compress | $mode | $comment |")
    }
    $lines.Add("")
}

# ---------------------------------------------------------------------------
# HA (High Availability)
# ---------------------------------------------------------------------------
if ($haResources -and $haResources.Count -gt 0) {
    $lines.Add("## HA - High Availability")
    $lines.Add("")
    $lines.Add("### Risorse HA")
    $lines.Add("")
    $lines.Add("| SID | Gruppo | Stato | Commento |")
    $lines.Add("|---|---|---|---|")
    foreach ($r in $haResources) {
        $lines.Add("| $($r.sid) | $($r.group) | $($r.state) | $($r.comment) |")
    }
    $lines.Add("")
    if ($haGroups -and $haGroups.Count -gt 0) {
        $lines.Add("### Gruppi HA")
        $lines.Add("")
        $lines.Add("| Gruppo | Nodi | Restritto | Non-preempt | Commento |")
        $lines.Add("|---|---|---|---|---|")
        foreach ($g in $haGroups) {
            $restr  = if ($g.restricted -eq 1) { "si" } else { "no" }
            $noprem = if ($g.nofailback -eq 1) { "si" } else { "no" }
            $lines.Add("| $($g.group) | $($g.nodes) | $restr | $noprem | $($g.comment) |")
        }
        $lines.Add("")
    }
}

# ---------------------------------------------------------------------------
# Firewall cluster
# ---------------------------------------------------------------------------
$lines.Add("## Firewall - Cluster")
$lines.Add("")

if ($clusterFwOptions) {
    $fwEnable = if ($clusterFwOptions.enable -eq 1) { "ATTIVO" } else { "inattivo" }
    $lines.Add("**Stato firewall cluster:** $fwEnable")
    $lines.Add("")
    $lines.Add("| Opzione | Valore |")
    $lines.Add("|---|---|")
    if ($null -ne $clusterFwOptions.enable)          { $lines.Add("| enable | $($clusterFwOptions.enable) |") }
    if ($clusterFwOptions.policy_in)                  { $lines.Add("| policy_in | $($clusterFwOptions.policy_in) |") }
    if ($clusterFwOptions.policy_out)                 { $lines.Add("| policy_out | $($clusterFwOptions.policy_out) |") }
    if ($clusterFwOptions.log_ratelimit)              { $lines.Add("| log_ratelimit | $($clusterFwOptions.log_ratelimit) |") }
    $lines.Add("")
} else {
    $lines.Add("> Opzioni firewall cluster non disponibili.")
    $lines.Add("")
}

if ($clusterFwAliases -and $clusterFwAliases.Count -gt 0) {
    $lines.Add("### Alias IP")
    $lines.Add("")
    $lines.Add("| Nome | CIDR | Commento |")
    $lines.Add("|---|---|---|")
    foreach ($a in $clusterFwAliases) {
        $lines.Add("| $($a.name) | $($a.cidr) | $($a.comment) |")
    }
    $lines.Add("")
}

if ($clusterFwIpsetList -and $clusterFwIpsetList.Count -gt 0) {
    $lines.Add("### IP Set")
    $lines.Add("")
    foreach ($ipset in $clusterFwIpsetList) {
        $lines.Add("**$($ipset.name)**$(if ($ipset.comment) { " - $($ipset.comment)" })")
        $members = $fwIpsetDetails[$ipset.name]
        if ($members) {
            $lines.Add("")
            $lines.Add("| CIDR/IP | No-match | Commento |")
            $lines.Add("|---|---|---|")
            foreach ($m in $members) {
                $nomatch = if ($m.nomatch -eq 1) { "!" } else { "" }
                $lines.Add("| $($m.cidr) | $nomatch | $($m.comment) |")
            }
        }
        $lines.Add("")
    }
}

if ($clusterFwRules -and $clusterFwRules.Count -gt 0) {
    $lines.Add("### Regole cluster")
    $lines.Add("")
    $lines.Add("| # | Abil | Dir | Action | Proto | Sorgente | Dest | Porta dest | Commento |")
    $lines.Add("|---|---|---|---|---|---|---|---|---|")
    foreach ($r in ($clusterFwRules | Sort-Object pos)) {
        $en     = if ($r.enable -eq 0) { "no" } else { "si" }
        $proto  = if ($r.proto)  { $r.proto }  else { "*" }
        $src    = if ($r.source) { $r.source } else { "*" }
        $dst    = if ($r.dest)   { $r.dest }   else { "*" }
        $dport  = if ($r.dport)  { $r.dport }  else { "*" }
        $iface  = if ($r.iface)  { " [$($r.iface)]" } else { "" }
        $lines.Add("| $($r.pos) | $en | $($r.type)$iface | $($r.action) | $proto | $src | $dst | $dport | $($r.comment) |")
    }
    $lines.Add("")
} else {
    $lines.Add("### Regole cluster")
    $lines.Add("")
    $lines.Add("> Nessuna regola cluster firewall configurata.")
    $lines.Add("")
}

# ---------------------------------------------------------------------------
# SDN
# ---------------------------------------------------------------------------
$hasSdn = ($sdnZones -and $sdnZones.Count -gt 0) -or ($sdnVnets -and $sdnVnets.Count -gt 0)
if ($hasSdn) {
    $lines.Add("## SDN - Software Defined Networking")
    $lines.Add("")
    if ($sdnZones -and $sdnZones.Count -gt 0) {
        $lines.Add("### Zone SDN")
        $lines.Add("")
        $lines.Add("| Zone | Tipo | Nodi | Commento |")
        $lines.Add("|---|---|---|---|")
        foreach ($z in $sdnZones) {
            $lines.Add("| $($z.zone) | $($z.type) | $($z.nodes) | $($z.comment) |")
        }
        $lines.Add("")
    }
    if ($sdnVnets -and $sdnVnets.Count -gt 0) {
        $lines.Add("### VNet SDN")
        $lines.Add("")
        $lines.Add("| VNet | Zone | Tag | Alias | Commento |")
        $lines.Add("|---|---|---|---|---|")
        foreach ($v in $sdnVnets) {
            $lines.Add("| $($v.vnet) | $($v.zone) | $($v.tag) | $($v.alias) | $($v.comment) |")
        }
        $lines.Add("")
    }
}

# ---------------------------------------------------------------------------
# Storage globale
# ---------------------------------------------------------------------------
$lines.Add("## Storage - configurazione globale")
$lines.Add("")
if ($storageGlobal) {
    $lines.Add("| ID | Tipo | Contenuto | Nodi | Abilitato |")
    $lines.Add("|---|---|---|---|---|")
    foreach ($s in $storageGlobal) {
        $en = if ($s.disable -eq 1) { "no" } else { "si" }
        $lines.Add("| $($s.storage) | $($s.type) | $($s.content) | $($s.nodes) | $en |")
    }
    $lines.Add("")
}

# ---------------------------------------------------------------------------
# Nodi
# ---------------------------------------------------------------------------
foreach ($nodeObj in $nodesData) {
    $n = $nodeObj.node
    $lines.Add("## Nodo: $n")
    $lines.Add("")

    if ($nodeObj.status) {
        $s      = $nodeObj.status
        $cpuStr = if ($s.cpuinfo) { "$($s.cpuinfo.cpus) core ($($s.cpuinfo.model))" } else { "n/d" }
        $ramTot = if ($s.memory)  { "$([math]::Round($s.memory.total / 1GB, 1)) GB" }  else { "n/d" }
        $ramUsd = if ($s.memory)  { "$([math]::Round($s.memory.used  / 1GB, 1)) GB" }  else { "n/d" }
        $lines.Add("| Parametro | Valore |")
        $lines.Add("|---|---|")
        $lines.Add("| CPU | $cpuStr |")
        $lines.Add("| RAM | $ramUsd usati / $ramTot totali |")
        $lines.Add("| Kernel | $($s.kversion) |")
        $lines.Add("| Versione PVE | $($s.pveversion) |")
        $lines.Add("")
    }

    # -----------------------------------------------------------------------
    # Rete
    # -----------------------------------------------------------------------
    if ($nodeObj.network) {
        $lines.Add("### Rete - $n")
        $lines.Add("")

        $lines.Add("| Interfaccia | Tipo | Indirizzo/Maschera | Gateway | Porte / Slave | VLAN-id | Bond-mode | MTU | STP | Autostart |")
        $lines.Add("|---|---|---|---|---|---|---|---|---|---|")
        foreach ($iface in $nodeObj.network) {
            $addr  = if ($iface.address -and $iface.netmask) { "$($iface.address)/$($iface.netmask)" } elseif ($iface.cidr) { $iface.cidr } else { "" }
            $gw    = if ($iface.gateway)       { $iface.gateway }       else { "" }
            $ports = if ($iface.bridge_ports)  { $iface.bridge_ports }  elseif ($iface.slaves) { $iface.slaves } else { "" }
            $vid   = if ($iface.vlan_id)       { $iface.vlan_id }       elseif ($iface.'vlan-id') { $iface.'vlan-id' } else { "" }
            $bmode = if ($iface.bond_mode)     { $iface.bond_mode }     elseif ($iface.'bond-mode') { $iface.'bond-mode' } else { "" }
            $mtu   = if ($iface.mtu)           { $iface.mtu }           else { "" }
            $stp   = if ($iface.bridge_stp -eq 'on') { "on" }           else { "" }
            $auto  = if ($iface.autostart -eq 1) { "si" }               else { "no" }
            $lines.Add("| $($iface.iface) | $($iface.type) | $addr | $gw | $ports | $vid | $bmode | $mtu | $stp | $auto |")
        }
        $lines.Add("")

        # Topologia bridge
        $bridges = $nodeObj.network | Where-Object { $_.type -eq 'bridge' -or $_.type -eq 'OVSBridge' }
        if ($bridges) {
            $lines.Add("#### Topologia bridge - $n")
            $lines.Add("")
            $lines.Add("| Bridge | Porta fisica | Indirizzo IP | STP | VLAN-aware |")
            $lines.Add("|---|---|---|---|---|")
            foreach ($br in $bridges) {
                $addr  = if ($br.address -and $br.netmask) { "$($br.address)/$($br.netmask)" } elseif ($br.cidr) { $br.cidr } else { "" }
                $ports = if ($br.bridge_ports) { $br.bridge_ports } else { "(nessuna)" }
                $stp   = if ($br.bridge_stp) { $br.bridge_stp } else { "" }
                $aware = if ($br.bridge_vlan_aware -eq 1) { "si" } else { "no" }
                $lines.Add("| $($br.iface) | $ports | $addr | $stp | $aware |")
            }
            $lines.Add("")
        }

        # Bond
        $bonds = $nodeObj.network | Where-Object { $_.type -eq 'bond' -or $_.type -eq 'OVSBond' }
        if ($bonds) {
            $lines.Add("#### Bond - $n")
            $lines.Add("")
            foreach ($b in $bonds) {
                $slaves = if ($b.slaves)    { $b.slaves }    else { "(nessuno)" }
                $bmode  = if ($b.bond_mode) { $b.bond_mode } elseif ($b.'bond-mode') { $b.'bond-mode' } else { "n/d" }
                $lines.Add("- **$($b.iface)** mode=$bmode -> slave: $slaves")
            }
            $lines.Add("")
        }
    }

    # -----------------------------------------------------------------------
    # Dischi fisici
    # -----------------------------------------------------------------------
    if ($nodeObj.disks -and $nodeObj.disks.Count -gt 0) {
        $lines.Add("### Dischi fisici - $n")
        $lines.Add("")
        $lines.Add("| Dispositivo | Dimensione | Modello | Health | Usato da | RPM | Wearout |")
        $lines.Add("|---|---|---|---|---|---|---|")
        foreach ($d in ($nodeObj.disks | Sort-Object devpath)) {
            $sz      = if ($d.size)    { "$([math]::Round($d.size / 1GB, 0)) GB" } else { "n/d" }
            $health  = if ($d.health)  { $d.health }  else { "n/d" }
            $used    = if ($d.used)    { $d.used }    else { "" }
            $rpm     = if ($d.rpm -gt 0) { $d.rpm }   else { "SSD" }
            $wear    = if ($d.wearout -and $d.wearout -ne 'N/A') { "$($d.wearout)%" } else { "" }
            $lines.Add("| $($d.devpath) | $sz | $($d.model) | $health | $used | $rpm | $wear |")
        }
        $lines.Add("")
    }

    if ($nodeObj.lvm -and $nodeObj.lvm.Count -gt 0) {
        $lines.Add("#### LVM Volume Groups - $n")
        $lines.Add("")
        $lines.Add("| VG | Totale | Libero | PV |")
        $lines.Add("|---|---|---|---|")
        foreach ($vg in $nodeObj.lvm) {
            $tot  = if ($vg.size) { "$([math]::Round($vg.size / 1GB, 1)) GB" } else { "n/d" }
            $free = if ($vg.free) { "$([math]::Round($vg.free / 1GB, 1)) GB" } else { "n/d" }
            $lines.Add("| $($vg.vg) | $tot | $free | $($vg.pvs) |")
        }
        $lines.Add("")
    }

    if ($nodeObj.zfs -and $nodeObj.zfs.Count -gt 0) {
        $lines.Add("#### ZFS Pool - $n")
        $lines.Add("")
        $lines.Add("| Pool | Stato | Totale | Alloc | Free |")
        $lines.Add("|---|---|---|---|---|")
        foreach ($zp in $nodeObj.zfs) {
            $tot   = if ($zp.size)  { "$([math]::Round($zp.size  / 1GB, 1)) GB" } else { "n/d" }
            $alloc = if ($zp.alloc) { "$([math]::Round($zp.alloc / 1GB, 1)) GB" } else { "n/d" }
            $free  = if ($zp.free)  { "$([math]::Round($zp.free  / 1GB, 1)) GB" } else { "n/d" }
            $lines.Add("| $($zp.name) | $($zp.health) | $tot | $alloc | $free |")
        }
        $lines.Add("")
    }

    # -----------------------------------------------------------------------
    # PCI devices
    # -----------------------------------------------------------------------
    if ($nodeObj.pci -and $nodeObj.pci.Count -gt 0) {
        $lines.Add("### PCI devices - $n")
        $lines.Add("")
        $lines.Add("| ID | Vendor | Dispositivo | Classe | IOMMU Group |")
        $lines.Add("|---|---|---|---|---|")
        foreach ($pci in ($nodeObj.pci | Sort-Object id)) {
            $vendor  = if ($pci.vendor_name)  { $pci.vendor_name }  else { $pci.vendor }
            $device  = if ($pci.device_name)  { $pci.device_name }  else { $pci.device }
            $class   = if ($pci.class_name)   { $pci.class_name }   elseif ($pci.class) { $pci.class } else { "" }
            $iommu   = if ($null -ne $pci.iommugroup) { $pci.iommugroup } else { "" }
            $lines.Add("| $($pci.id) | $vendor | $device | $class | $iommu |")
        }
        $lines.Add("")
    }

    # -----------------------------------------------------------------------
    # Firewall nodo
    # -----------------------------------------------------------------------
    if ($nodeObj.fw_rules -and $nodeObj.fw_rules.Count -gt 0) {
        $lines.Add("### Firewall - $n")
        $lines.Add("")
        $lines.Add("| # | Abil | Dir | Action | Proto | Sorgente | Dest | Porta | Commento |")
        $lines.Add("|---|---|---|---|---|---|---|---|---|")
        foreach ($r in ($nodeObj.fw_rules | Sort-Object pos)) {
            $en    = if ($r.enable -eq 0) { "no" } else { "si" }
            $proto = if ($r.proto)  { $r.proto }  else { "*" }
            $src   = if ($r.source) { $r.source } else { "*" }
            $dst   = if ($r.dest)   { $r.dest }   else { "*" }
            $dport = if ($r.dport)  { $r.dport }  else { "*" }
            $lines.Add("| $($r.pos) | $en | $($r.type) | $($r.action) | $proto | $src | $dst | $dport | $($r.comment) |")
        }
        $lines.Add("")
    }

    # -----------------------------------------------------------------------
    # Storage per nodo
    # -----------------------------------------------------------------------
    if ($nodeObj.storage) {
        $lines.Add("### Storage - $n")
        $lines.Add("")
        $lines.Add("| Storage | Tipo | Totale | Usato | Disponibile | Attivo |")
        $lines.Add("|---|---|---|---|---|---|")
        foreach ($s in $nodeObj.storage) {
            $tot   = if ($s.total) { "$([math]::Round($s.total / 1GB, 1)) GB" } else { "n/d" }
            $used  = if ($s.used)  { "$([math]::Round($s.used  / 1GB, 1)) GB" } else { "n/d" }
            $avail = if ($s.avail) { "$([math]::Round($s.avail / 1GB, 1)) GB" } else { "n/d" }
            $act   = if ($s.active -eq 1) { "si" } else { "no" }
            $lines.Add("| $($s.storage) | $($s.type) | $tot | $used | $avail | $act |")
        }
        $lines.Add("")
    }

    # -----------------------------------------------------------------------
    # VM QEMU
    # -----------------------------------------------------------------------
    if ($nodeObj.vms -and $nodeObj.vms.Count -gt 0) {
        $lines.Add("### VM (QEMU) - $n")
        $lines.Add("")
        foreach ($vm in ($nodeObj.vms | Sort-Object vmid)) {
            $lines.Add("#### VM $($vm.vmid) - $($vm.name) [$($vm.status)]")
            $lines.Add("")
            if ($vm.config) {
                $c     = $vm.config
                $cpus  = if ($c.cores)  { "$($c.cores) core (socket: $($c.sockets))" } else { "n/d" }
                $mem   = if ($c.memory) { "$($c.memory) MB" }                           else { "n/d" }
                $os    = if ($c.ostype) { $c.ostype }                                   else { "n/d" }
                $lines.Add("| Parametro | Valore |")
                $lines.Add("|---|---|")
                $lines.Add("| CPU | $cpus |")
                $lines.Add("| RAM | $mem |")
                $lines.Add("| OS type | $os |")
                $lines.Add("| Boot | $($c.boot) |")
                if ($c.cpu)     { $lines.Add("| CPU type | $($c.cpu) |") }
                if ($c.machine) { $lines.Add("| Machine | $($c.machine) |") }
                if ($c.bios)    { $lines.Add("| BIOS | $($c.bios) |") }
                if ($c.hugepages) { $lines.Add("| Hugepages | $($c.hugepages) |") }
                if ($c.numa -eq 1) { $lines.Add("| NUMA | si |") }
                $lines.Add("")

                # Interfacce di rete
                $netKeys = $c.PSObject.Properties.Name | Where-Object { $_ -match '^net\d+$' }
                if ($netKeys) {
                    $lines.Add("Interfacce di rete (config):")
                    $lines.Add("")
                    $lines.Add("| Slot | Driver/MAC | Bridge | Firewall | Tag VLAN | Rate |")
                    $lines.Add("|---|---|---|---|---|---|")
                    foreach ($k in ($netKeys | Sort-Object)) {
                        $raw    = $c.$k
                        $mac    = if ($raw -match '=([0-9A-Fa-f:]{17})') { $Matches[1] } else { "" }
                        $model  = if ($raw -match '^([^=]+)=')           { $Matches[1] } else { "" }
                        $bridge = if ($raw -match 'bridge=([^,]+)')      { $Matches[1] } else { "" }
                        $fw     = if ($raw -match 'firewall=1')          { "si" }         else { "no" }
                        $tag    = if ($raw -match 'tag=(\d+)')           { $Matches[1] } else { "" }
                        $rate   = if ($raw -match 'rate=([^,]+)')        { $Matches[1] } else { "" }
                        $lines.Add("| $k | $model $mac | $bridge | $fw | $tag | $rate |")
                    }
                    $lines.Add("")
                }

                # IP da QEMU guest agent
                if ($vm.agent_net -and $vm.agent_net.result) {
                    $agentIfaces = $vm.agent_net.result
                    $lines.Add("Indirizzi IP (QEMU guest agent):")
                    $lines.Add("")
                    $lines.Add("| Interfaccia | MAC | Indirizzi IP |")
                    $lines.Add("|---|---|---|")
                    foreach ($ai in $agentIfaces) {
                        $ips = ""
                        if ($ai.'ip-addresses') {
                            $ips = ($ai.'ip-addresses' | Where-Object { $_.'ip-address-type' -ne 'ipv6' -or $_.'ip-address' -notmatch '^fe80' } |
                                ForEach-Object { "$($_.'ip-address')/$($_.'prefix')" }) -join ", "
                        }
                        $lines.Add("| $($ai.name) | $($ai.'hardware-address') | $ips |")
                    }
                    $lines.Add("")
                } elseif ($vm.status -eq 'running') {
                    $lines.Add("> IP non disponibili: QEMU guest agent non installato o non risponde.")
                    $lines.Add("")
                }

                # Dischi
                $diskKeys = $c.PSObject.Properties.Name | Where-Object { $_ -match '^(scsi|virtio|ide|sata)\d+$' }
                if ($diskKeys) {
                    $lines.Add("Dischi:")
                    $lines.Add("")
                    $lines.Add("| Slot | Configurazione |")
                    $lines.Add("|---|---|")
                    foreach ($k in ($diskKeys | Sort-Object)) {
                        $lines.Add("| $k | $($c.$k) |")
                    }
                    $lines.Add("")
                }

                # PCI passthrough
                $pciKeys = $c.PSObject.Properties.Name | Where-Object { $_ -match '^(hostpci|usb)\d+$' }
                if ($pciKeys) {
                    $lines.Add("Passthrough PCI/USB:")
                    $lines.Add("")
                    $lines.Add("| Slot | Configurazione |")
                    $lines.Add("|---|---|")
                    foreach ($k in ($pciKeys | Sort-Object)) {
                        $lines.Add("| $k | $($c.$k) |")
                    }
                    $lines.Add("")
                }
            }

            # Firewall VM
            $fwEnabled = if ($vm.fw_options -and $vm.fw_options.enable -eq 1) { $true } else { $false }
            if ($vm.fw_rules -and $vm.fw_rules.Count -gt 0) {
                $lines.Add("Firewall ($($vm.fw_rules.Count) regole, abilitato: $(if ($fwEnabled) { 'si' } else { 'no' })):")
                $lines.Add("")
                $lines.Add("| # | Abil | Dir | Action | Proto | Sorgente | Dest | Porta | Commento |")
                $lines.Add("|---|---|---|---|---|---|---|---|---|")
                foreach ($r in ($vm.fw_rules | Sort-Object pos)) {
                    $en    = if ($r.enable -eq 0) { "no" } else { "si" }
                    $proto = if ($r.proto)  { $r.proto }  else { "*" }
                    $src   = if ($r.source) { $r.source } else { "*" }
                    $dst   = if ($r.dest)   { $r.dest }   else { "*" }
                    $dport = if ($r.dport)  { $r.dport }  else { "*" }
                    $lines.Add("| $($r.pos) | $en | $($r.type) | $($r.action) | $proto | $src | $dst | $dport | $($r.comment) |")
                }
                $lines.Add("")
            } elseif ($fwEnabled) {
                $lines.Add("Firewall: abilitato, nessuna regola esplicita (usa policy default).")
                $lines.Add("")
            }

            # Snapshot
            if ($vm.snapshots -and $vm.snapshots.Count -gt 0) {
                $realSnaps = $vm.snapshots | Where-Object { $_.name -ne 'current' }
                if ($realSnaps -and $realSnaps.Count -gt 0) {
                    $lines.Add("Snapshot ($($realSnaps.Count)):")
                    $lines.Add("")
                    $lines.Add("| Nome | Descrizione | Data |")
                    $lines.Add("|---|---|---|")
                    foreach ($snap in ($realSnaps | Sort-Object snaptime)) {
                        $snapDate = if ($snap.snaptime) { (Get-Date -UnixTimeSeconds $snap.snaptime -Format "yyyy-MM-dd HH:mm") } else { "" }
                        $lines.Add("| $($snap.name) | $($snap.description) | $snapDate |")
                    }
                    $lines.Add("")
                }
            }
        }
    }

    # -----------------------------------------------------------------------
    # Container LXC
    # -----------------------------------------------------------------------
    if ($nodeObj.containers -and $nodeObj.containers.Count -gt 0) {
        $lines.Add("### Container (LXC) - $n")
        $lines.Add("")
        foreach ($ct in ($nodeObj.containers | Sort-Object vmid)) {
            $lines.Add("#### CT $($ct.vmid) - $($ct.name) [$($ct.status)]")
            $lines.Add("")
            if ($ct.config) {
                $c    = $ct.config
                $cpus = if ($c.cores)  { "$($c.cores) core" } else { "n/d" }
                $mem  = if ($c.memory) { "$($c.memory) MB" }  else { "n/d" }
                $swap = if ($c.swap)   { "$($c.swap) MB" }    else { "0 MB" }
                $lines.Add("| Parametro | Valore |")
                $lines.Add("|---|---|")
                $lines.Add("| CPU | $cpus |")
                $lines.Add("| RAM | $mem |")
                $lines.Add("| Swap | $swap |")
                $lines.Add("| Hostname | $($c.hostname) |")
                $lines.Add("| Template | $($c.ostemplate) |")
                $lines.Add("")

                $netKeys = $c.PSObject.Properties.Name | Where-Object { $_ -match '^net\d+$' }
                if ($netKeys) {
                    $lines.Add("Interfacce di rete (config):")
                    $lines.Add("")
                    $lines.Add("| Slot | Nome | Bridge | IP (config) | Gateway | Firewall | Tag VLAN |")
                    $lines.Add("|---|---|---|---|---|---|---|")
                    foreach ($k in ($netKeys | Sort-Object)) {
                        $raw    = $c.$k
                        $ifname = if ($raw -match 'name=([^,]+)')   { $Matches[1] } else { "" }
                        $bridge = if ($raw -match 'bridge=([^,]+)') { $Matches[1] } else { "" }
                        $ip     = if ($raw -match 'ip=([^,]+)')     { $Matches[1] } else { "" }
                        $gw     = if ($raw -match 'gw=([^,]+)')     { $Matches[1] } else { "" }
                        $fw     = if ($raw -match 'firewall=1')     { "si" }         else { "no" }
                        $tag    = if ($raw -match 'tag=(\d+)')      { $Matches[1] } else { "" }
                        $lines.Add("| $k | $ifname | $bridge | $ip | $gw | $fw | $tag |")
                    }
                    $lines.Add("")
                }

                if ($ct.interfaces) {
                    $lines.Add("Indirizzi IP (runtime):")
                    $lines.Add("")
                    $lines.Add("| Interfaccia | MAC | Indirizzi IP |")
                    $lines.Add("|---|---|---|")
                    foreach ($ri in $ct.interfaces) {
                        $lines.Add("| $($ri.name) | $($ri.hwaddr) | $($ri.'inet' + ' ' + $ri.'inet6') |")
                    }
                    $lines.Add("")
                }

                $mpKeys = $c.PSObject.Properties.Name | Where-Object { $_ -match '^(rootfs|mp\d+)$' }
                if ($mpKeys) {
                    $lines.Add("Mount point:")
                    $lines.Add("")
                    $lines.Add("| Mount | Configurazione |")
                    $lines.Add("|---|---|")
                    foreach ($k in ($mpKeys | Sort-Object)) {
                        $lines.Add("| $k | $($c.$k) |")
                    }
                    $lines.Add("")
                }
            }

            # Firewall LXC
            if ($ct.fw_rules -and $ct.fw_rules.Count -gt 0) {
                $ctFwEn = if ($ct.fw_options -and $ct.fw_options.enable -eq 1) { "si" } else { "no" }
                $lines.Add("Firewall ($($ct.fw_rules.Count) regole, abilitato: $ctFwEn):")
                $lines.Add("")
                $lines.Add("| # | Abil | Dir | Action | Proto | Sorgente | Dest | Porta | Commento |")
                $lines.Add("|---|---|---|---|---|---|---|---|---|")
                foreach ($r in ($ct.fw_rules | Sort-Object pos)) {
                    $en    = if ($r.enable -eq 0) { "no" } else { "si" }
                    $proto = if ($r.proto)  { $r.proto }  else { "*" }
                    $src   = if ($r.source) { $r.source } else { "*" }
                    $dst   = if ($r.dest)   { $r.dest }   else { "*" }
                    $dport = if ($r.dport)  { $r.dport }  else { "*" }
                    $lines.Add("| $($r.pos) | $en | $($r.type) | $($r.action) | $proto | $src | $dst | $dport | $($r.comment) |")
                }
                $lines.Add("")
            }
        }
    }
}

$mdPath = Join-Path $OutputDir "proxmox-config.md"
$lines | Out-File -FilePath $mdPath -Encoding utf8
Write-Host "Markdown: $mdPath" -ForegroundColor Green
Write-Host "`nSnapshot completato." -ForegroundColor Green
