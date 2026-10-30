<#
.SYNOPSIS
    Aggiorna una delle quattro chiavi nel file .env privato.
.DESCRIPTION
    Chiede il valore senza mostrarlo, crea un file temporaneo vuoto con lo stesso
    ACL di .env, poi vi scrive il nuovo contenuto e sostituisce .env. Non usa la
    riga di comando o il JSON di Claude per trasmettere il valore.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('NEBULA_API_KEY', 'PROXMOX_URL', 'PROXMOX_TOKEN_NAME', 'PROXMOX_TOKEN_VALUE', 'BITDEFENDER_API_URL', 'BITDEFENDER_API_KEY')]
    [string]$Name,
    [string]$EnvPath,
    [SecureString]$SecureValue
)

$ErrorActionPreference = 'Stop'
if (-not $EnvPath) { $EnvPath = Join-Path (Split-Path -Parent $PSScriptRoot) '.env' }
$EnvPath = [System.IO.Path]::GetFullPath($EnvPath)
if (-not (Test-Path -LiteralPath $EnvPath -PathType Leaf)) { throw 'File .env privato assente' }

$lines = [System.IO.File]::ReadAllLines($EnvPath)
$positions = @(
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match ('^' + [regex]::Escape($Name) + '=')) { $i }
    }
)
if ($positions.Count -gt 1) { throw "Chiave duplicata in .env: $Name" }
# Una chiave ammessa ma non ancora presente si crea in coda: il ValidateSet e' gia' il
# controllo che impedisce di scrivere una chiave estranea, e chiedere all'utente di
# aprire a mano un file di credenziali per aggiungere una riga vuota e' peggio.
if ($positions.Count -eq 0) {
    $lines += "$Name=`"`""
    $positions = @($lines.Length - 1)
    Write-Host "Chiave non presente: viene creata in coda a .env - $Name" -ForegroundColor Yellow
}

$secure = $SecureValue
if (-not $secure) { $secure = Read-Host -Prompt "Nuovo valore per $Name (non mostrato)" -AsSecureString }
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
if ([string]::IsNullOrWhiteSpace($plain) -or $plain -match '[\x00-\x1f]') {
    throw 'Valore vuoto o non valido: nessuna modifica'
}

$encoded = ConvertTo-Json -InputObject $plain -Compress
if ((ConvertFrom-Json -InputObject $encoded) -cne $plain) { throw 'Serializzazione non verificata' }
$lines[$positions[0]] = "$Name=$encoded"
$temporary = "$EnvPath.pending-$([guid]::NewGuid().ToString('N'))"
$backup = "$EnvPath.backup-$([guid]::NewGuid().ToString('N'))"
try {
    # ACL prima dei dati: il file temporaneo nasce vuoto.
    [System.IO.File]::WriteAllText($temporary, '')
    Set-Acl -LiteralPath $temporary -AclObject (Get-Acl -LiteralPath $EnvPath)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($temporary, (($lines -join "`n") + "`n"), $utf8)
    [System.IO.File]::Replace($temporary, $EnvPath, $backup)
    Write-Host "Chiave aggiornata nel file privato .env: $Name" -ForegroundColor Green
    Write-Host 'Riavviare il consumer che usa questa chiave e verificarne il risultato.' -ForegroundColor Yellow
} finally {
    $plain = $null
    if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Force }
}
