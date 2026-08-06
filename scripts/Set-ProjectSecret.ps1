<#
.SYNOPSIS
    Scrive o ruota un segreto nel blocco "env" di .claude/settings.local.json.
.DESCRIPTION
    ADR-021 stabilisce che i segreti di questo progetto vivono in un posto solo, il blocco
    "env" di .claude/settings.local.json, che Claude Code inietta nell'ambiente della
    sessione e dei sottoprocessi che avvia. Questo script e' il modo previsto per
    scriverli o ruotarli senza che il valore passi mai per una chat, per la cronologia
    del terminale o per un file temporaneo.

    Il valore viene chiesto a runtime come SecureString, non compare a schermo, non
    viene scritto in nessun log e resta in memoria solo per il tempo della sostituzione.

    La sostituzione e' mirata sul valore della singola chiave: il file non viene
    rigenerato da un round-trip JSON, cosi' formattazione, ordine delle chiavi, hook e
    permessi restano identici. Dopo la scrittura il file viene riletto e validato come
    JSON; se la validazione fallisce, il backup viene ripristinato automaticamente.

    Il file di destinazione non e' versionato: contiene segreti e sta in .gitignore.
    Lo script invece e' versionato, perche' non contiene nessun valore.
.PARAMETER Name
    Nome della variabile da scrivere nel blocco "env", per esempio NEBULA_API_KEY
    oppure PROXMOX_TOKEN_VALUE. Deve gia' esistere nel blocco: creare una chiave nuova
    e' un'operazione che cambia la configurazione del progetto e va fatta a mano.
.PARAMETER SettingsPath
    Percorso di settings.local.json. Default: .claude/settings.local.json nella radice
    del progetto.
.PARAMETER KeepBackup
    Conserva il backup del file precedente. Per impostazione predefinita il backup viene
    creato prima della modifica e rimosso dopo la validazione riuscita, perche' un
    backup di un file di segreti e' una copia in piu' del segreto (SEC-024).
.EXAMPLE
    .\scripts\Set-ProjectSecret.ps1 -Name NEBULA_API_KEY
.NOTES
    Dopo la scrittura serve RIAVVIARE la sessione di Claude Code: il blocco "env" viene
    letto all'avvio, quindi la sessione in corso continua a usare il valore vecchio.
    Compatibile con PowerShell 5.1 e PowerShell 7+.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Z_][A-Z0-9_]*$')]
    [string]$Name,

    [string]$SettingsPath,

    [switch]$KeepBackup
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 1. Individuazione del file di destinazione
# ---------------------------------------------------------------------------
if (-not $SettingsPath) {
    $scriptDir    = Split-Path $PSCommandPath -Parent
    $projectDir   = Split-Path $scriptDir -Parent
    $SettingsPath = Join-Path $projectDir ".claude\settings.local.json"
}
$SettingsPath = [System.IO.Path]::GetFullPath($SettingsPath)

if (-not (Test-Path $SettingsPath)) {
    throw "File non trovato: $SettingsPath"
}
Write-Host "File di destinazione: $SettingsPath" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 2. La chiave deve gia' esistere nel blocco env
#    Si legge il JSON solo per verificare la presenza della chiave: la scrittura
#    avviene poi sul testo, non su questo oggetto.
# ---------------------------------------------------------------------------
$raw = Get-Content -LiteralPath $SettingsPath -Raw -Encoding UTF8

try {
    $parsed = $raw | ConvertFrom-Json
} catch {
    throw "Il file non e' JSON valido, non tocco niente: $($_.Exception.Message)"
}

if (-not $parsed.env) {
    throw "Il file non contiene un blocco 'env'. Vedi ADR-021."
}
if (-not ($parsed.env.PSObject.Properties.Name -contains $Name)) {
    $presenti = ($parsed.env.PSObject.Properties.Name | Sort-Object) -join ', '
    throw "La chiave '$Name' non esiste nel blocco env. Chiavi presenti: $presenti"
}

# ---------------------------------------------------------------------------
# 3. Richiesta del valore, mai a schermo
# ---------------------------------------------------------------------------
$secure = Read-Host -Prompt "Nuovo valore per $Name (non viene mostrato)" -AsSecureString
$bstr   = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

if ([string]::IsNullOrWhiteSpace($plain)) {
    throw "Valore vuoto: nessuna modifica."
}
if ($plain -match '["\\]') {
    throw "Il valore contiene virgolette o backslash: sostituzione non sicura su testo, va scritto a mano."
}

# Riferimento visivo senza rivelare il segreto: lunghezza e ultimi due caratteri.
$coda = $plain.Substring([Math]::Max(0, $plain.Length - 2))
Write-Host ("Valore acquisito: {0} caratteri, termina con '{1}'." -f $plain.Length, $coda) -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
# 4. Backup, sostituzione mirata, validazione, eventuale rollback
# ---------------------------------------------------------------------------
$backupPath = "$SettingsPath.bak-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss')
Copy-Item -LiteralPath $SettingsPath -Destination $backupPath -Force

$pattern     = '("' + [regex]::Escape($Name) + '"\s*:\s*")[^"]*(")'
$replacement = '${1}' + $plain.Replace('$', '$$$$') + '${2}'
$nuovo       = [regex]::Replace($raw, $pattern, $replacement, 1)

if ($nuovo -eq $raw) {
    Remove-Item -LiteralPath $backupPath -Force
    throw "Nessuna sostituzione effettuata: la chiave '$Name' non e' stata trovata nel testo del file."
}

# UTF8 senza BOM, per non alterare la codifica del file originale.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($SettingsPath, $nuovo, $utf8NoBom)

$plain = $null
[System.GC]::Collect()

try {
    Get-Content -LiteralPath $SettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
} catch {
    Copy-Item -LiteralPath $backupPath -Destination $SettingsPath -Force
    throw "JSON non valido dopo la scrittura: ripristinato il backup. Dettaglio: $($_.Exception.Message)"
}

if ($KeepBackup) {
    Write-Host "Backup conservato: $backupPath" -ForegroundColor Yellow
    Write-Host "Contiene il segreto precedente: eliminarlo quando la rotazione e' verificata." -ForegroundColor Yellow
} else {
    Remove-Item -LiteralPath $backupPath -Force
}

Write-Host ""
Write-Host "Fatto: $Name aggiornata in settings.local.json." -ForegroundColor Green
Write-Host "Passo obbligatorio: RIAVVIARE la sessione di Claude Code." -ForegroundColor Yellow
Write-Host "Il blocco env viene letto all'avvio, quindi la sessione in corso usa ancora il valore vecchio." -ForegroundColor Yellow
