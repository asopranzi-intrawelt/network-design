<#
.SYNOPSIS
    Snapshot in sola lettura della gestione endpoint NinjaOne (RMM) via Public API v2.
.DESCRIPTION
    Interroga la Public API v2 di NinjaOne con il flusso OAuth2 client credentials e
    produce due file nella cartella output/:
      ninjaone-snapshot.json  dump strutturato di quanto e' stato possibile leggere
      ninjaone-config.md      riepilogo Markdown leggibile, pronto per la sessione

    Perche' esiste in un progetto di network design. Gli endpoint di questa rete non
    sono gestiti a mano: vivono sotto un RMM distribuito che applica policy, script e
    automazioni, e che ruota le password locali su base periodica. Progettare la
    segmentazione, spostare destinazioni di scansione o cambiare indirizzamento senza
    sapere cosa l'RMM fa a quegli endpoint significa progettare a occhi chiusi. Questo
    script serve a fotografare quel lato: organizzazioni, dispositivi, policy, script,
    automazioni e, quando l'API lo consente, le interfacce di rete per dispositivo,
    che sono la fonte piu' rapida per il censimento degli indirizzi statici richiesto
    dal micro-step M22a.

    NATURA DELLE CREDENZIALI, DA LEGGERE PRIMA DI USARLO. Le credenziali API di
    questa istanza appartengono al provider MSP che gestisce l'RMM, non al progetto:
    vanno trattate come credenziali di terzi. Da qui tre vincoli non negoziabili.
    Primo, lo scope richiesto e' di sola lettura ('monitoring'): questo script non
    scrive nulla e non deve essere esteso a scope di scrittura. Secondo, il segreto
    non viene mai scritto su disco da questo script ne' passato sulla riga di comando
    in chiaro: ordine di risoluzione parametro, poi variabile d'ambiente, infine
    prompt a runtime come SecureString. Terzo, l'output contiene nomi host, utenti
    connessi e indirizzi reali: la cartella output/ e' ignorata da git per questa
    ragione e il suo contenuto non va copiato in file tracciati senza applicare
    .claude/rules/anonymization.md.

    Endpoint interrogati in modalita' best-effort: l'insieme esatto degli endpoint
    disponibili dipende dalla versione dell'istanza e dai permessi concessi alla
    client app, quindi lo script prova ciascun endpoint, registra l'esito HTTP e
    salva soltanto quello che ha ottenuto. Un endpoint negato o inesistente produce
    un warning e non interrompe lo snapshot.

    Compatibile con PowerShell 5.1 (Windows PowerShell) e PowerShell 7+.
.PARAMETER Instance
    Regione dell'istanza NinjaOne ('eu', 'us', 'us2', 'ca', 'oc', 'fed') oppure un
    URL https:// completo per istanze con dominio brandizzato di un MSP. Se omesso si
    usa la variabile d'ambiente NINJAONE_INSTANCE, altrimenti 'eu'.
.PARAMETER ClientId
    Client ID della client app API. Se omesso si usa NINJAONE_CLIENT_ID.
.PARAMETER ClientSecret
    Client secret come SecureString. Se omesso si usa NINJAONE_CLIENT_SECRET,
    altrimenti viene chiesto a runtime senza essere mostrato.
.PARAMETER Scope
    Scope OAuth2. Default 'monitoring', che e' sola lettura. Non usare scope di
    scrittura con questo script.
.PARAMETER IncludeHeavy
    Include anche le interrogazioni voluminose (inventario software, patch di
    sistema operativo, servizi Windows). Escluse per default perche' su un parco di
    decine di endpoint producono decine di migliaia di righe.
.PARAMETER OutputDir
    Cartella di output. Default: sottocartella output/ della radice del progetto.
.PARAMETER OrganizationName
    Filtro sull'organizzazione da conservare nello snapshot, per corrispondenza
    parziale sul nome (default 'intrawelt'). ESISTE PER UNA RAGIONE DI RISERVATEZZA,
    non di comodita': l'istanza e' quella multi-tenant del provider MSP e contiene
    anche l'inventario di altre aziende sue clienti, che questo progetto non ha
    alcuna necessita' di conservare. Lo snapshot filtrato tiene solo i dispositivi,
    le interfacce e le interrogazioni dell'organizzazione richiesta.
.PARAMETER OrganizationId
    Alternativa numerica a -OrganizationName, quando l'id e' noto e si vuole essere
    espliciti.
.PARAMETER AllOrganizations
    Disattiva il filtro e conserva tutte le organizzazioni dell'istanza. Da usare
    solo con una ragione dichiarata: significa scrivere su disco dati di aziende
    terze.
.EXAMPLE
    .\scripts\Get-NinjaSnapshot.ps1
    Usa le variabili d'ambiente e chiede il segreto se manca.
.EXAMPLE
    .\scripts\Get-NinjaSnapshot.ps1 -IncludeHeavy
    Aggiunge software, patch e servizi: piu' lento e molto piu' voluminoso.
.NOTES
    Decisione, razionale e vincoli sulle credenziali: ADR-017 in
    .claude/memory/decisions.md. Pattern di autenticazione ripreso dal progetto
    interno di notifiche NinjaOne, dove era gia' verificato contro l'istanza reale.
#>
[CmdletBinding()]
param(
    [string] $Instance,
    [string] $ClientId,
    [System.Security.SecureString] $ClientSecret,
    [string] $Scope = 'monitoring',
    [switch] $IncludeHeavy,
    [string] $OutputDir,
    [string] $OrganizationName = 'intrawelt',
    [int] $OrganizationId = 0,
    [switch] $AllOrganizations
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# PowerShell 5.1 non negozia TLS 1.2 per default su alcune installazioni.
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {
    Write-Verbose 'Impossibile forzare TLS 1.2, si procede con il default del sistema.'
}

$InstanceHosts = @{
    'eu'  = 'https://eu.ninjarmm.com'
    'us'  = 'https://app.ninjarmm.com'
    'us2' = 'https://us2.ninjarmm.com'
    'ca'  = 'https://ca.ninjarmm.com'
    'oc'  = 'https://oc.ninjarmm.com'
    'fed' = 'https://fed.ninjarmm.com'
}

function Resolve-BaseUrl {
    param([string] $Value)
    if (-not $Value) { $Value = $env:NINJAONE_INSTANCE }
    if (-not $Value) { $Value = 'eu' }
    $Value = $Value.Trim()
    if ($Value -like 'https://*') { return $Value.TrimEnd('/') }
    $key = $Value.ToLowerInvariant()
    if ($InstanceHosts.ContainsKey($key)) { return $InstanceHosts[$key] }
    throw "Istanza '$Value' non riconosciuta: attesi $($InstanceHosts.Keys -join ', ') oppure un URL https:// completo."
}

function ConvertFrom-SecureStringPlain {
    param([System.Security.SecureString] $Secure)
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Get-AccessToken {
    param([string] $BaseUrl, [string] $Id, [string] $Secret, [string] $TokenScope)
    $body = @{
        grant_type    = 'client_credentials'
        client_id     = $Id
        client_secret = $Secret
        scope         = $TokenScope
    }
    $response = Invoke-RestMethod -Method Post -Uri ($BaseUrl + '/ws/oauth/token') `
        -Body $body -ContentType 'application/x-www-form-urlencoded' -TimeoutSec 30
    if (-not $response.access_token) {
        throw 'Risposta del token senza campo access_token: credenziali o scope non validi.'
    }
    return $response.access_token
}

function Get-Prop {
    <#
        Lettura difensiva di una proprieta': con Set-StrictMode attivo, accedere a una
        proprieta' assente su un oggetto deserializzato da JSON solleva un'eccezione, e
        i payload di questa API omettono i campi nulli invece di riportarli vuoti.
    #>
    param($Object, [string] $Name, $Default = '')
    if ($null -eq $Object) { return $Default }
    if ($Object.PSObject.Properties.Name -contains $Name) {
        $value = $Object.$Name
        if ($null -eq $value) { return $Default }
        return $value
    }
    return $Default
}

function Get-RowSet {
    <#
        Le interrogazioni diagnostiche (/v2/queries/*) non ritornano un array ma un
        oggetto con 'results' e un cursore di paginazione: senza questo unwrap il
        conteggio risulta sempre 1.
    #>
    param($Data)
    # PowerShell srotola gli array restituiti da una funzione, quindi un risultato di
    # un solo elemento torna come scalare e la lettura di .Count fallisce con
    # Set-StrictMode attivo. La protezione sta nei siti di chiamata, che avvolgono
    # sempre l'esito in @(...): qui NON si usa l'operatore virgola, perche'
    # produrrebbe un array annidato e i conteggi risulterebbero tutti pari a uno.
    if ($null -eq $Data) { return @() }
    if ($Data.PSObject.Properties.Name -contains 'results') { return @($Data.results) }
    return @($Data)
}

function Invoke-NinjaGet {
    <#
        Best-effort: ritorna un oggetto con Path, Ok, Status e Data. Non lancia
        eccezioni sui codici di errore, cosi' un endpoint negato non interrompe
        lo snapshot.
    #>
    param([string] $BaseUrl, [string] $Token, [string] $Path)
    $result = [ordered]@{ path = $Path; ok = $false; status = $null; count = $null; data = $null }
    try {
        $data = Invoke-RestMethod -Method Get -Uri ($BaseUrl + $Path) `
            -Headers @{ Authorization = "Bearer $Token" } -TimeoutSec 60
        $result.ok = $true
        $result.status = 200
        $result.data = $data
        if ($null -ne $data) {
            $result.count = @(Get-RowSet -Data $data).Count
        }
        Write-Host ("  OK   {0}  ({1} elementi)" -f $Path, $result.count)
    } catch {
        $status = $null
        if ($_.Exception.PSObject.Properties.Name -contains 'Response' -and $_.Exception.Response) {
            try { $status = [int] $_.Exception.Response.StatusCode } catch { $status = $null }
        }
        $result.status = $status
        Write-Warning ("  SALTATO {0} (HTTP {1}): endpoint non disponibile o non autorizzato per questa client app." -f $Path, $status)
    }
    return [pscustomobject] $result
}

# --- Risoluzione dei parametri e delle credenziali ---------------------------------

$baseUrl = Resolve-BaseUrl -Value $Instance

if (-not $ClientId) { $ClientId = $env:NINJAONE_CLIENT_ID }
if (-not $ClientId) { $ClientId = Read-Host 'Client ID NinjaOne (Amministrazione > App > API)' }

$secretPlain = $null
if ($ClientSecret) {
    $secretPlain = ConvertFrom-SecureStringPlain -Secure $ClientSecret
} elseif ($env:NINJAONE_CLIENT_SECRET) {
    $secretPlain = $env:NINJAONE_CLIENT_SECRET
} else {
    $secure = Read-Host 'Client secret NinjaOne (non viene mostrato ne salvato)' -AsSecureString
    $secretPlain = ConvertFrom-SecureStringPlain -Secure $secure
}

if (-not $OutputDir) {
    $OutputDir = Join-Path (Split-Path -Parent $PSScriptRoot) 'output'
}
if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host ''
Write-Host ("Istanza:      {0}" -f $baseUrl)
Write-Host ("Scope:        {0} (sola lettura attesa)" -f $Scope)
Write-Host ("Output verso: {0}" -f $OutputDir)
Write-Host ''

Write-Host 'Autenticazione OAuth2 client credentials...'
$token = Get-AccessToken -BaseUrl $baseUrl -Id $ClientId -Secret $secretPlain -TokenScope $Scope
$secretPlain = $null
Write-Host 'Token ottenuto.'
Write-Host ''

# --- Endpoint da interrogare -------------------------------------------------------
# L'insieme esatto dipende da versione dell'istanza e permessi della client app:
# ciascuno e' best-effort e il suo esito HTTP viene registrato nello snapshot.

$corePaths = @(
    '/v2/organizations',
    '/v2/locations',
    '/v2/devices',
    '/v2/devices-detailed',
    '/v2/groups',
    '/v2/policies',
    '/v2/alerts',
    '/v2/scripting/scripts',
    '/v2/automation/scripts',
    '/v2/queries/network-interfaces',
    '/v2/queries/operating-systems',
    '/v2/queries/computer-systems',
    '/v2/queries/antivirus-status',
    '/v2/queries/custom-fields',
    '/v2/queries/policy-overrides',
    '/v2/queries/logged-on-users'
)

$heavyPaths = @(
    '/v2/queries/software',
    '/v2/queries/os-patches',
    '/v2/queries/os-patch-installs',
    '/v2/queries/windows-services',
    '/v2/queries/volumes'
)

$paths = $corePaths
if ($IncludeHeavy) { $paths = $corePaths + $heavyPaths }

Write-Host 'Raccolta (best-effort, gli endpoint negati vengono saltati con warning):'
$results = @()
foreach ($p in $paths) {
    $results += Invoke-NinjaGet -BaseUrl $baseUrl -Token $token -Path $p
}

# --- Filtro sull'organizzazione ----------------------------------------------------
# L'istanza e' multi-tenant (provider MSP): senza filtro lo snapshot conserverebbe
# l'inventario di aziende terze, che questo progetto non ha motivo di detenere.

$targetOrgIds = @()
$orgEntry = $results | Where-Object { $_.path -eq '/v2/organizations' -and $_.ok }
if ($AllOrganizations) {
    Write-Warning 'Filtro organizzazione DISATTIVATO: lo snapshot conservera'' dati di tutte le organizzazioni dell''istanza, comprese aziende terze.'
} elseif ($orgEntry) {
    $allOrgs = @(Get-RowSet -Data $orgEntry.data)
    if ($OrganizationId -gt 0) {
        $targetOrgIds = @($allOrgs | Where-Object { (Get-Prop $_ 'id' 0) -eq $OrganizationId } | ForEach-Object { Get-Prop $_ 'id' 0 })
    } else {
        $targetOrgIds = @($allOrgs | Where-Object { (Get-Prop $_ 'name' '') -like ('*' + $OrganizationName + '*') } | ForEach-Object { Get-Prop $_ 'id' 0 })
    }
    if ($targetOrgIds.Count -eq 0) {
        throw ("Nessuna organizzazione corrisponde al filtro (nome '{0}', id {1}). Usare -OrganizationName/-OrganizationId corretti, oppure -AllOrganizations con una ragione dichiarata." -f $OrganizationName, $OrganizationId)
    }
    Write-Host ''
    Write-Host ('Filtro organizzazione attivo: id {0} su {1} organizzazioni presenti nell''istanza.' -f ($targetOrgIds -join ', '), @(Get-RowSet -Data $orgEntry.data).Count)

    $keptDeviceIds = @{}
    foreach ($r in $results) {
        if (-not $r.ok) { continue }
        $rows = @(Get-RowSet -Data $r.data)
        if ($rows.Count -eq 0) { continue }
        $sample = $rows[0]
        if ($sample.PSObject.Properties.Name -contains 'organizationId') {
            $filtered = @($rows | Where-Object { $targetOrgIds -contains (Get-Prop -Object $_ -Name 'organizationId' -Default -1) })
            foreach ($x in $filtered) { $keptDeviceIds[[string](Get-Prop $x 'id' '')] = $true }
            $r.data = $filtered
            $r.count = $filtered.Count
        } elseif ($r.path -eq '/v2/organizations') {
            $filtered = @($rows | Where-Object { $targetOrgIds -contains (Get-Prop -Object $_ -Name 'id' -Default -1) })
            $r.data = $filtered
            $r.count = $filtered.Count
        }
    }
    # Secondo giro: le interrogazioni diagnostiche non portano organizationId ma deviceId.
    foreach ($r in $results) {
        if (-not $r.ok) { continue }
        $rows = @(Get-RowSet -Data $r.data)
        if ($rows.Count -eq 0) { continue }
        $sample = $rows[0]
        if ($sample.PSObject.Properties.Name -contains 'deviceId') {
            $filtered = @($rows | Where-Object { $keptDeviceIds.ContainsKey([string](Get-Prop $_ 'deviceId' '')) })
            $r.data = $filtered
            $r.count = $filtered.Count
        }
    }
    Write-Host ('Dopo il filtro: {0} dispositivi conservati.' -f $keptDeviceIds.Count)
    Write-Host ''
}

# --- Scrittura dello snapshot JSON -------------------------------------------------

$snapshot = [ordered]@{
    generated_at   = (Get-Date).ToString('s')
    instance       = $baseUrl
    scope          = $Scope
    include_heavy  = [bool] $IncludeHeavy
    organization_filter = @{ name = $OrganizationName; id = $OrganizationId; all = [bool] $AllOrganizations; kept_ids = $targetOrgIds }
    endpoints      = @{}
    endpoint_status = @()
}

foreach ($r in $results) {
    $snapshot.endpoint_status += [ordered]@{ path = $r.path; ok = $r.ok; status = $r.status; count = $r.count }
    if ($r.ok) { $snapshot.endpoints[$r.path] = $r.data }
}

$jsonPath = Join-Path $OutputDir 'ninjaone-snapshot.json'
$snapshot | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

# --- Riepilogo Markdown ------------------------------------------------------------

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Snapshot NinjaOne (gestione endpoint) - sola lettura')
$md.Add('')
$md.Add(('Generato il {0} sull''istanza {1}, scope `{2}`.' -f (Get-Date).ToString('dd/MM/yyyy HH:mm'), $baseUrl, $Scope))
$md.Add('')
$md.Add('> Contiene nomi host, utenti e indirizzi reali: file ignorato da git, non copiare')
$md.Add('> valori in file tracciati senza applicare `.claude/rules/anonymization.md`.')
$md.Add('')
$md.Add('## Esito per endpoint')
$md.Add('')
$md.Add('| Endpoint | Esito | HTTP | Elementi |')
$md.Add('|---|---|---|---|')
foreach ($r in $results) {
    $esito = 'saltato'
    if ($r.ok) { $esito = 'ok' }
    $st = $r.status
    if ($null -eq $st) { $st = '-' }
    $cn = $r.count
    if ($null -eq $cn) { $cn = '-' }
    $md.Add(('| `{0}` | {1} | {2} | {3} |' -f $r.path, $esito, $st, $cn))
}
$md.Add('')

function Add-Section {
    param([string] $Title, [string] $Path, [scriptblock] $Renderer)
    $entry = $results | Where-Object { $_.path -eq $Path -and $_.ok }
    if (-not $entry) { return }
    $md.Add(('## {0}' -f $Title))
    $md.Add('')
    & $Renderer $entry.data
    $md.Add('')
}

Add-Section -Title 'Organizzazioni' -Path '/v2/organizations' -Renderer {
    param($data)
    $md.Add('| id | nome | dispositivi |')
    $md.Add('|---|---|---|')
    foreach ($o in $data) {
        $md.Add(('| {0} | {1} | {2} |' -f (Get-Prop $o 'id'), (Get-Prop $o 'name'), (Get-Prop $o 'nodeApprovalMode' '-')))
    }
}

Add-Section -Title 'Policy' -Path '/v2/policies' -Renderer {
    param($data)
    $md.Add('| id | nome | tipo nodo | eredita da |')
    $md.Add('|---|---|---|---|')
    foreach ($p in $data) {
        $md.Add(('| {0} | {1} | {2} | {3} |' -f (Get-Prop $p 'id'), (Get-Prop $p 'name'), (Get-Prop $p 'nodeClass'), (Get-Prop $p 'parentPolicyId' '-')))
    }
}

Add-Section -Title 'Script e automazioni' -Path '/v2/automation/scripts' -Renderer {
    param($data)
    $md.Add('| id | nome | linguaggio | sistema operativo |')
    $md.Add('|---|---|---|---|')
    foreach ($s in $data) {
        $os = Get-Prop $s 'operatingSystems' @()
        $md.Add(('| {0} | {1} | {2} | {3} |' -f (Get-Prop $s 'id'), (Get-Prop $s 'name'), (Get-Prop $s 'language' '-'), (@($os) -join ' ')))
    }
}

Add-Section -Title 'Dispositivi (sintesi)' -Path '/v2/devices' -Renderer {
    param($data)
    $md.Add(('Dispositivi censiti: **{0}**.' -f @(Get-RowSet -Data $data).Count))
    $md.Add('')
    $byClass = @($data) | Group-Object -Property { Get-Prop -Object $_ -Name 'nodeClass' -Default 'ignoto' } | Sort-Object -Property Count -Descending
    $md.Add('| classe nodo | numero |')
    $md.Add('|---|---|')
    foreach ($g in $byClass) { $md.Add(('| {0} | {1} |' -f $g.Name, $g.Count)) }
}

Add-Section -Title 'Interfacce di rete per dispositivo' -Path '/v2/queries/network-interfaces' -Renderer {
    param($data)
    $rows = @(Get-RowSet -Data $data)
    $md.Add(('Righe: **{0}**. E'' la fonte piu'' rapida per il censimento indirizzi di M22a:' -f $rows.Count))
    $md.Add('incrocia MAC e indirizzo per dispositivo gestito.')
}

$mdPath = Join-Path $OutputDir 'ninjaone-config.md'
$md -join "`r`n" | Set-Content -LiteralPath $mdPath -Encoding UTF8

Write-Host ''
Write-Host ('JSON:     {0}' -f $jsonPath)
Write-Host ('Markdown: {0}' -f $mdPath)
Write-Host ''
Write-Host 'Snapshot completato. Ricorda: output/ e'' ignorato da git, e i valori reali'
Write-Host 'vanno anonimizzati prima di finire in un file tracciato.'
