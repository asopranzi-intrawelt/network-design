<#+
.SYNOPSIS
    Legge una chiave dal file .env privato del progetto rete.
.DESCRIPTION
    Il formato ammesso e' KEY="stringa JSON": le virgolette e le sequenze di
    escape vengono interpretate da ConvertFrom-Json. Non importa variabili nel
    processo e non stampa valori. Rifiuta chiavi duplicate e righe malformate.
#>

function Get-ProjectSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('NEBULA_API_KEY', 'PROXMOX_URL', 'PROXMOX_TOKEN_NAME', 'PROXMOX_TOKEN_VALUE', 'BITDEFENDER_API_URL', 'BITDEFENDER_API_KEY')][string]$Name,
        [Parameter(Mandatory)][string]$ProjectRoot
    )

    $path = Join-Path $ProjectRoot '.env'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $null }
    $values = @{}
    foreach ($line in [System.IO.File]::ReadAllLines($path)) {
        if (-not $line.Trim() -or $line.TrimStart().StartsWith('#')) { continue }
        $match = [regex]::Match($line, '^([A-Z_][A-Z0-9_]*)=("(?:[^"\\]|\\.)*")$')
        if (-not $match.Success) { throw 'Formato .env non valido' }
        $key = $match.Groups[1].Value
        if ($key -notin @('NEBULA_API_KEY', 'PROXMOX_URL', 'PROXMOX_TOKEN_NAME', 'PROXMOX_TOKEN_VALUE', 'BITDEFENDER_API_URL', 'BITDEFENDER_API_KEY')) {
            throw "Chiave non ammessa in .env: $key"
        }
        if ($values.ContainsKey($key)) { throw "Chiave duplicata in .env: $key" }
        try { $value = ConvertFrom-Json -InputObject $match.Groups[2].Value }
        catch { throw "Valore non valido in .env: $key" }
        if ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value) -or $value -match '[\x00-\x1f]') {
            throw "Valore vuoto o non testuale in .env: $key"
        }
        $values[$key] = $value
    }
    if ($values.ContainsKey($Name)) { return $values[$Name] }
    return $null
}
