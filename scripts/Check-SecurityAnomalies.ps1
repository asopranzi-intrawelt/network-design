<#
.SYNOPSIS
    Verifica anomalie di sicurezza note nell'infrastruttura Intrawelt.
.DESCRIPTION
    Controlla le anomalie documentate in GAP-TBC.md e runbook-anomalie.md.
    Legge proxmox-config.md (output/) e testa la raggiungibilita dei dispositivi critici.
    Le credenziali vengono chieste a runtime. Nessun segreto finisce su disco.
.NOTES
    Owner: Alessio Sopranzi
    Richiede: accesso alla rete LAN Intrawelt (192.168.20.0/24)
#>

[CmdletBinding()]
param(
    [switch]$SkipNetworkTests,
    [string]$OutputPath = "$PSScriptRoot\..\output\security-anomaly-check.txt"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

$results = [System.Collections.Generic.List[PSObject]]::new()
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

function Add-Result {
    param(
        [string]$ID,
        [string]$Descrizione,
        [ValidateSet('CRITICA','ALTA','MEDIA','BASSA','OK')]
        [string]$Severity,
        [string]$Stato,
        [string]$Dettaglio
    )
    $results.Add([PSCustomObject]@{
        ID          = $ID
        Severity    = $Severity
        Stato       = $Stato
        Descrizione = $Descrizione
        Dettaglio   = $Dettaglio
    })
}

Write-Host "`nIntrawelt - Security Anomaly Checker" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Avvio: $timestamp`n"

# --- CHECK 1: FW-001 - Regola Phishing action=ALLOW ---
# Non possiamo testare la FW rule via PS senza API Zyxel; leggiamo GAP-TBC se esiste
Write-Host "[FW-001] Verifica regola Blocco_Gruppo_IP_Phishing_Elisa..." -ForegroundColor Yellow
$gapFile = Join-Path $PSScriptRoot '..\docs\GAP-TBC.md'
if (Test-Path $gapFile) {
    $gapContent = Get-Content $gapFile -Raw
    if ($gapContent -match 'FW-001') {
        $resolved = $gapContent -match 'FW-001.*\[x\]|FW-001.*risolto|FW-001.*chiuso'
        if ($resolved) {
            Add-Result 'FW-001' 'Regola Phishing_Elisa action=ALLOW' 'OK' 'Risolto' 'Stato risolto trovato in GAP-TBC.md'
        } else {
            Add-Result 'FW-001' 'Regola Phishing_Elisa action=ALLOW' 'CRITICA' 'APERTO' `
                'GAP-TBC.md indica anomalia non risolta. Accedere a USG FLEX 500 e correggere action=DENY.'
        }
    }
} else {
    Add-Result 'FW-001' 'Regola Phishing_Elisa action=ALLOW' 'CRITICA' 'NON VERIFICABILE' `
        'File GAP-TBC.md non trovato. Verificare manualmente sulla Web GUI firewall.'
}

# --- CHECK 2: FW-002 - Switch management su VLAN Guest ---
Write-Host "[FW-002] Verifica switch management su VLAN 90 (192.168.90.37)..." -ForegroundColor Yellow
if (-not $SkipNetworkTests) {
    $ping = Test-Connection -ComputerName '192.168.90.37' -Count 1 -Quiet
    if ($ping) {
        $tcpResult = Test-NetConnection -ComputerName '192.168.90.37' -Port 443 -WarningAction SilentlyContinue
        if ($tcpResult.TcpTestSucceeded) {
            Add-Result 'FW-002' 'Switch management su VLAN Guest' 'CRITICA' 'CONFERMATO' `
                'Switch 192.168.90.37 risponde su porta 443 (HTTPS management). Spostare management su VLAN 10.'
        } else {
            Add-Result 'FW-002' 'Switch management su VLAN Guest' 'ALTA' 'VERIFICA' `
                '192.168.90.37 risponde al ping ma non a 443. Verificare se la mgmt interface e ancora su VLAN 90.'
        }
    } else {
        Add-Result 'FW-002' 'Switch management su VLAN Guest' 'OK' 'Non raggiungibile' `
            '192.168.90.37 non risponde. Potrebbe essere stato corretto o spento.'
    }
} else {
    Add-Result 'FW-002' 'Switch management su VLAN Guest' 'ALTA' 'SALTATO' 'Test di rete saltati (-SkipNetworkTests).'
}

# --- CHECK 3: UPS su VLAN Guest ---
Write-Host "[UPS-001] Verifica UPS Emerson Liebert su VLAN Guest (192.168.90.33)..." -ForegroundColor Yellow
if (-not $SkipNetworkTests) {
    $upsReach = Test-NetConnection -ComputerName '192.168.90.33' -Port 6004 -WarningAction SilentlyContinue
    if ($upsReach.TcpTestSucceeded) {
        Add-Result 'UPS-001' 'UPS Emerson Liebert su VLAN Guest' 'ALTA' 'CONFERMATO' `
            'UPS 192.168.90.33 risponde su porta 6004 (management). Spostare su VLAN 10.'
    } else {
        $pingUps = Test-Connection -ComputerName '192.168.90.33' -Count 1 -Quiet
        if ($pingUps) {
            Add-Result 'UPS-001' 'UPS Emerson Liebert su VLAN Guest' 'ALTA' 'PARZIALE' `
                '192.168.90.33 risponde al ping ma non a 6004. Verificare porta management UPS.'
        } else {
            Add-Result 'UPS-001' 'UPS Emerson Liebert su VLAN Guest' 'MEDIA' 'Non raggiungibile' `
                '192.168.90.33 non risponde. Spostato su altra VLAN o spento.'
        }
    }
} else {
    Add-Result 'UPS-001' 'UPS Emerson Liebert su VLAN Guest' 'ALTA' 'SALTATO' 'Test di rete saltati (-SkipNetworkTests).'
}

# --- CHECK 4: MyHome Server CentOS 7 EOL ---
Write-Host "[EOL-001] Verifica MyHome Server CentOS 7 (192.168.90.40)..." -ForegroundColor Yellow
if (-not $SkipNetworkTests) {
    $myHome = Test-Connection -ComputerName '192.168.90.40' -Count 1 -Quiet
    if ($myHome) {
        Add-Result 'EOL-001' 'MyHome Server CentOS 7.6 EOL' 'ALTA' 'ATTIVO' `
            '192.168.90.40 risponde. CentOS 7 EOL da giugno 2024. Nessun aggiornamento sicurezza. Pianificare migrazione o isolamento.'
    } else {
        Add-Result 'EOL-001' 'MyHome Server CentOS 7.6 EOL' 'MEDIA' 'Non raggiungibile' `
            '192.168.90.40 non risponde. Verificare se dispositivo e spento o rimosso.'
    }
} else {
    Add-Result 'EOL-001' 'MyHome Server CentOS 7.6 EOL' 'ALTA' 'SALTATO' 'Test di rete saltati (-SkipNetworkTests).'
}

# --- CHECK 5: Bticino citofono Linux 2.6 EOL ---
Write-Host "[EOL-002] Verifica Bticino Classe100X (192.168.90.41)..." -ForegroundColor Yellow
if (-not $SkipNetworkTests) {
    $bticino = Test-Connection -ComputerName '192.168.90.41' -Count 1 -Quiet
    if ($bticino) {
        Add-Result 'EOL-002' 'Bticino Classe100X Linux 2.6 EOL' 'MEDIA' 'ATTIVO' `
            '192.168.90.41 risponde. Linux kernel 2.6 EOL. Firmware non aggiornabile. Isolare su VLAN dedicata IoT.'
    } else {
        Add-Result 'EOL-002' 'Bticino Classe100X Linux 2.6 EOL' 'BASSA' 'Non raggiungibile' `
            '192.168.90.41 non risponde.'
    }
} else {
    Add-Result 'EOL-002' 'Bticino Classe100X Linux 2.6 EOL' 'MEDIA' 'SALTATO' 'Test di rete saltati (-SkipNetworkTests).'
}

# --- CHECK 6: Proxmox VM senza snapshot recente ---
Write-Host "[PROX-001] Verifica snapshot Proxmox recenti..." -ForegroundColor Yellow
$snapshotFile = Join-Path $PSScriptRoot '..\output\proxmox-snapshots.json'
if (Test-Path $snapshotFile) {
    try {
        $snapData = Get-Content $snapshotFile -Raw | ConvertFrom-Json
        $oldThreshold = (Get-Date).AddDays(-7)
        $noRecentSnap = @()
        foreach ($vm in $snapData) {
            $vmName = $vm.name
            $snaps = $vm.snapshots | Where-Object { $_.name -ne 'current' }
            if (-not $snaps) {
                $noRecentSnap += "$vmName (nessuno snapshot)"
            } else {
                $latest = $snaps | Sort-Object snaptime -Descending | Select-Object -First 1
                if ($latest.snaptime) {
                    $snapDate = [DateTimeOffset]::FromUnixTimeSeconds($latest.snaptime).LocalDateTime
                    if ($snapDate -lt $oldThreshold) {
                        $noRecentSnap += "$vmName (ultimo: $($snapDate.ToString('dd/MM/yyyy')))"
                    }
                }
            }
        }
        if ($noRecentSnap.Count -gt 0) {
            Add-Result 'PROX-001' 'VM Proxmox senza snapshot recente (>7gg)' 'ALTA' 'ATTENZIONE' `
                ("VM senza snapshot recente: " + ($noRecentSnap -join '; '))
        } else {
            Add-Result 'PROX-001' 'VM Proxmox senza snapshot recente' 'OK' 'OK' `
                'Tutte le VM hanno snapshot recente (entro 7 giorni).'
        }
    } catch {
        Add-Result 'PROX-001' 'VM Proxmox senza snapshot recente' 'MEDIA' 'ERRORE PARSING' `
            "Impossibile leggere $snapshotFile. Rieseguire Get-ProxmoxSnapshot.ps1."
    }
} else {
    Add-Result 'PROX-001' 'VM Proxmox senza snapshot recente' 'MEDIA' 'MANCANTE' `
        "File output\proxmox-snapshots.json non trovato. Eseguire scripts\Get-ProxmoxSnapshot.ps1."
}

# --- CHECK 7: MFA Azure admin ---
Write-Host "[M365-001] Verifica MFA account Azure admin (manuale)..." -ForegroundColor Yellow
Add-Result 'M365-001' 'MFA Azure admin (asopranzi,anasini,tvezeni,atrovato)' 'ALTA' 'VERIFICA MANUALE' `
    'Verificare su https://entra.microsoft.com > Ruoli e amministratori > stato MFA = enforced per tutti e 4 gli account.'

# --- REPORT ---
Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "RISULTATI ANOMALIE" -ForegroundColor Cyan
Write-Host "======================================`n"

$colorMap = @{
    'CRITICA' = 'Red'
    'ALTA'    = 'DarkYellow'
    'MEDIA'   = 'Yellow'
    'BASSA'   = 'Gray'
    'OK'      = 'Green'
}

foreach ($r in $results | Sort-Object @{e={
    switch ($_.Severity) { 'CRITICA'{0} 'ALTA'{1} 'MEDIA'{2} 'BASSA'{3} 'OK'{4} }
}}) {
    $color = $colorMap[$r.Severity]
    Write-Host "[$($r.Severity)] $($r.ID) - $($r.Descrizione)" -ForegroundColor $color
    Write-Host "  Stato: $($r.Stato)"
    Write-Host "  $($r.Dettaglio)`n"
}

$critici = ($results | Where-Object { $_.Severity -eq 'CRITICA' }).Count
$alti    = ($results | Where-Object { $_.Severity -eq 'ALTA' }).Count
$ok      = ($results | Where-Object { $_.Severity -eq 'OK' }).Count

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Totale check: $($results.Count) | CRITICI: $critici | ALTI: $alti | OK: $ok" -ForegroundColor Cyan
Write-Host "Generato: $timestamp`n"

# Salva output in output/ (gitignored)
$outDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$reportLines = @("# Security Anomaly Check - $timestamp", "")
foreach ($r in $results) {
    $reportLines += "## [$($r.Severity)] $($r.ID) - $($r.Descrizione)"
    $reportLines += "- Stato: $($r.Stato)"
    $reportLines += "- $($r.Dettaglio)"
    $reportLines += ""
}
$reportLines | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "Report salvato in: $OutputPath" -ForegroundColor DarkGray
