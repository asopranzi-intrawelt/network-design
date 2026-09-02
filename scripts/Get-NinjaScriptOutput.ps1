<#
.SYNOPSIS
    Raccoglie in sola lettura l'esito di un'automazione eseguita su piu' endpoint (M27-8).
.DESCRIPTION
    Interroga in sola lettura il registro delle attivita' della gestione endpoint e ne
    estrae l'output delle esecuzioni di una automazione, una riga per dispositivo.

    Perche' esiste. Il censimento M27-8 chiede il contenuto del file degli host di ogni
    postazione. La console mostra l'esito nel pannello delle attivita' ma **tronca il
    testo**, e per leggerlo per intero bisogna aprire una scheda per dispositivo: su
    venticinque macchine sono venticinque aperture, con il risultato da ricomporre a
    mano e nessuna garanzia di non saltarne una. Questo script chiede lo stesso dato
    all'interfaccia di programmazione, dove il testo non e' troncato, e lo scrive in un
    file solo.

    Che cosa NON fa, e perche' e' importante. Non esegue nulla sugli endpoint, non crea
    ne' modifica automazioni, non tocca la configurazione della piattaforma: fa
    esclusivamente richieste di lettura. E' la condizione posta da ADR-017 perche'
    questo progetto possa interrogare quella piattaforma, le cui credenziali
    appartengono al fornitore che la gestisce. L'esecuzione dell'automazione resta
    quindi un'azione dell'IT Manager dalla console; questo script ne raccoglie soltanto
    il risultato.

    Riserva sull'esito. Non e' garantito che il registro delle attivita' riporti
    l'output completo di una esecuzione: alcune installazioni ne conservano il solo
    riepilogo. Lo script lo dichiara invece di fingere, e se il testo risulta troncato o
    assente lo segnala, cosi' che si possa ripiegare sulla lettura dalla console senza
    aver perso tempo a chiedersi se sia un difetto dello script.

    L'output contiene nomi host, nomi di postazione e indirizzi reali e finisce in
    output/, ignorato da git: non va copiato in un file tracciato senza applicare
    .claude/rules/anonymization.md.
.PARAMETER Automazione
    Porzione del nome dell'automazione di cui raccogliere gli esiti, per corrispondenza
    parziale e senza distinzione di maiuscole. Predefinito: 'hosts'.
.PARAMETER Giorni
    Quanti giorni indietro cercare nel registro. Predefinito 2.
.EXAMPLE
    .\scripts\Get-NinjaScriptOutput.ps1 -Automazione 'file hosts'
#>
[CmdletBinding()]
param(
    [string] $Instance,
    [string] $ClientId,
    [System.Security.SecureString] $ClientSecret,
    [string] $Scope = 'monitoring',
    [string] $Automazione = 'hosts',
    [int] $Giorni = 2,
    [string] $OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch { Write-Verbose 'TLS 1.2 non forzabile, si usa il default.' }

$InstanceHosts = @{
    'eu' = 'https://eu.ninjarmm.com'; 'us' = 'https://app.ninjarmm.com'; 'us2' = 'https://us2.ninjarmm.com'
    'ca' = 'https://ca.ninjarmm.com'; 'oc' = 'https://oc.ninjarmm.com';  'fed' = 'https://fed.ninjarmm.com'
}

function Resolve-BaseUrl {
    param([string] $Value)
    if (-not $Value) { $Value = $env:NINJAONE_INSTANCE }
    if (-not $Value) { $Value = 'eu' }
    $Value = $Value.Trim()
    if ($Value -like 'https://*') { return $Value.TrimEnd('/') }
    $key = $Value.ToLowerInvariant()
    if ($InstanceHosts.ContainsKey($key)) { return $InstanceHosts[$key] }
    throw "Istanza '$Value' non riconosciuta."
}

function ConvertFrom-SecureStringPlain {
    param([System.Security.SecureString] $Secure)
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

function Get-Prop {
    param($Object, [string] $Name, $Default = '')
    if ($null -eq $Object) { return $Default }
    if ($Object.PSObject.Properties.Name -contains $Name) {
        $v = $Object.$Name
        if ($null -eq $v) { return $Default }
        return $v
    }
    return $Default
}

function Invoke-NinjaGet {
    param([string] $BaseUrl, [string] $Token, [string] $Path)
    try {
        return Invoke-RestMethod -Method Get -Uri ($BaseUrl + $Path) `
            -Headers @{ Authorization = "Bearer $Token" } -TimeoutSec 60
    } catch {
        $status = $null
        if ($_.Exception.PSObject.Properties.Name -contains 'Response' -and $_.Exception.Response) {
            try { $status = [int] $_.Exception.Response.StatusCode } catch { $status = $null }
        }
        Write-Warning ("  richiesta non riuscita su {0} (HTTP {1})" -f $Path, $status)
        return $null
    }
}

$radice = Split-Path -Parent $PSScriptRoot
if (-not $OutputDir) { $OutputDir = Join-Path $radice 'output' }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

$baseUrl = Resolve-BaseUrl -Value $Instance
if (-not $ClientId) { $ClientId = $env:NINJAONE_CLIENT_ID }
if (-not $ClientId) { $ClientId = Read-Host 'Client ID NinjaOne' }
if (-not $ClientSecret) {
    if ($env:NINJAONE_CLIENT_SECRET) {
        $ClientSecret = ConvertTo-SecureString $env:NINJAONE_CLIENT_SECRET -AsPlainText -Force
    } else {
        $ClientSecret = Read-Host 'Client secret NinjaOne (non viene mostrato ne salvato)' -AsSecureString
    }
}

Write-Host ''
Write-Host ("Istanza:      {0}" -f $baseUrl)
Write-Host ("Automazione:  corrispondenza su '{0}'" -f $Automazione)
Write-Host ("Finestra:     ultimi {0} giorni" -f $Giorni)
Write-Host 'Sola lettura: nessuna esecuzione, nessuna modifica.'
Write-Host ''

$body = @{
    grant_type = 'client_credentials'; client_id = $ClientId
    client_secret = (ConvertFrom-SecureStringPlain -Secure $ClientSecret); scope = $Scope
}
$tokenResponse = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/ws/oauth/token') `
    -Body $body -ContentType 'application/x-www-form-urlencoded' -TimeoutSec 30
$body = $null
if (-not $tokenResponse.access_token) { throw 'Token non ottenuto: credenziali o scope non validi.' }
$token = $tokenResponse.access_token
Write-Host 'Token ottenuto.'

# Anagrafica dei dispositivi, per tradurre gli identificativi in nomi leggibili.
$dispositivi = @{}
$dev = Invoke-NinjaGet -BaseUrl $baseUrl -Token $token -Path '/v2/devices'
foreach ($d in @($dev)) {
    $id = Get-Prop $d 'id' $null
    if ($null -ne $id) {
        $nome = Get-Prop $d 'systemName' ''
        if (-not $nome) { $nome = Get-Prop $d 'dnsName' '' }
        if (-not $nome) { $nome = "dispositivo-$id" }
        $dispositivi[[string]$id] = $nome
    }
}
Write-Host ("Anagrafica: {0} dispositivi." -f $dispositivi.Count)

$dopo = [DateTimeOffset]::UtcNow.AddDays(-$Giorni).ToUnixTimeSeconds()
$attivita = Invoke-NinjaGet -BaseUrl $baseUrl -Token $token -Path ("/v2/activities?after={0}&pageSize=1000" -f $dopo)
if ($null -eq $attivita) {
    Write-Warning "Il registro delle attivita' non e' interrogabile con queste credenziali."
    Write-Warning "Ripiego: leggere gli esiti dalla console, una scheda per dispositivo."
    return
}

$righe = @()
if ($attivita.PSObject.Properties.Name -contains 'activities') { $righe = @($attivita.activities) }
else { $righe = @($attivita) }
Write-Host ("Attivita' nella finestra: {0}." -f $righe.Count)

$pertinenti = @()
foreach ($a in $righe) {
    $testo = ((Get-Prop $a 'subject' ''), (Get-Prop $a 'message' ''), (Get-Prop $a 'statusCode' '')) -join ' '
    if ($testo -notmatch [regex]::Escape($Automazione)) { continue }
    $devId = [string](Get-Prop $a 'deviceId' '')
    $nome = if ($devId -and $dispositivi.ContainsKey($devId)) { $dispositivi[$devId] } else { "dispositivo-$devId" }
    $pertinenti += [pscustomobject]@{
        Dispositivo = $nome
        Data        = Get-Prop $a 'activityTime' ''
        Stato       = Get-Prop $a 'statusCode' ''
        Testo       = Get-Prop $a 'message' ''
    }
}

if (-not $pertinenti) {
    Write-Warning ("Nessuna attivita' corrisponde a '{0}' negli ultimi {1} giorni." -f $Automazione, $Giorni)
    Write-Warning "Verificare il nome dell'automazione, oppure allargare la finestra con -Giorni."
    return
}

$dest = Join-Path $OutputDir 'ninjaone-esiti-automazione.txt'
$out = @()
$out += "Esiti dell'automazione che corrisponde a '$Automazione'"
$out += "Raccolti in sola lettura dal registro delle attivita'. Contiene nomi e indirizzi reali: non copiare in file tracciati senza anonimizzare."
$out += ''
foreach ($p in ($pertinenti | Sort-Object Dispositivo)) {
    $out += ('=== {0} | {1} | {2} ===' -f $p.Dispositivo, $p.Data, $p.Stato)
    $out += $p.Testo
    $out += ''
}
$out | Set-Content -Path $dest -Encoding UTF8

$troncati = @($pertinenti | Where-Object { $_.Testo -match '\.\.\.\s*$' }).Count
Write-Host ''
Write-Host ("Raccolti {0} esiti in {1}" -f $pertinenti.Count, $dest) -ForegroundColor Green
if ($troncati -gt 0) {
    Write-Warning ("{0} esiti risultano troncati: il registro conserva il riepilogo e non il testo intero." -f $troncati)
    Write-Warning "In quel caso il dato completo si legge solo dalla console, una scheda per dispositivo."
}
Write-Host "output/ e' ignorato da git." -ForegroundColor DarkGray
