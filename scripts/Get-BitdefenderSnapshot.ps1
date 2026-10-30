<#
.SYNOPSIS
    Snapshot in sola lettura della postura endpoint Bitdefender GravityZone via Control Center API.
.DESCRIPTION
    Interroga la Public API di GravityZone (JSON-RPC 2.0) e produce due file in output/:
      bitdefender-snapshot.json  dump strutturato di quanto e' stato possibile leggere
      bitdefender-config.md      riepilogo Markdown leggibile, pronto per la sessione

    Perche' esiste in un progetto di network design. Il Vulnerability Assessment di
    Onova e' una scansione NON autenticata e limitata a una sola /24: il fornitore
    dichiara da se' il limite, cioe' che vede cio' che e' esposto dalla rete e non lo
    stato interno dei sistemi. GravityZone guarda dall'interno, con un agente su ogni
    endpoint, e vede esattamente cio' che la scansione non poteva vedere: patch di
    sistema operativo e di applicazione mancanti con le loro CVE, stato dei moduli di
    protezione per macchina, agenti con motore o firme non aggiornati, quarantena e
    incidenti. Le due fonti non si sovrappongono: si completano, e l'una misura il
    punto cieco dichiarato dell'altra.

    CHE COSA QUESTA API NON DA', E VA LETTO PRIMA DI PROGETTARCI SOPRA. Non esiste un
    servizio pubblico "Risk Management" ne' "Vulnerabilities": i rilievi che la console
    mostra sotto Gestione dei rischi non sono esposti come elenco interrogabile. Dalla
    API il rischio arriva in due sole forme, ed e' bene non aspettarsene una terza.
    Primo, riskScore per endpoint e per compagnia, cioe' un punteggio con le tre
    componenti impact, misconfigurations, appVulnerabilities e humanRisks: sono
    aggregati, non il nome della singola misconfigurazione. Secondo, le CVE dentro
    getMissingPatches e getInstalledPatches, che sono invece puntuali e sono la vera
    materia prima per il controllo A.8.8. Chi volesse l'elenco nominale dei rilievi
    deve passare da un report schedulato in console, non da questa API.

    NATURA DELLE CREDENZIALI. La chiave e' una service API key di GravityZone, mostrata
    una volta sola alla creazione. Questo script e' di sola lettura e non deve essere
    esteso a metodi di scrittura: nessun createScanTask, nessun assignPolicy, nessun
    isolamento di endpoint. La chiave non viene mai scritta su disco da questo script
    ne' passata sulla riga di comando in chiaro: ordine di risoluzione parametro, poi
    file .env privato del progetto, poi variabile d'ambiente, infine prompt a runtime
    come SecureString. L'output contiene nomi host, utenti e indirizzi reali: la
    cartella output/ e' ignorata da git per questa ragione e il suo contenuto non va
    copiato in file tracciati senza applicare .claude/rules/anonymization.md.

    Gli endpoint vengono interrogati in modalita' best-effort: l'insieme dei servizi
    realmente abilitati dipende dai permessi concessi alla chiave e dai moduli in
    licenza, quindi lo script prova ciascun servizio, registra l'esito e salva soltanto
    quello che ha ottenuto. Un servizio negato o non licenziato produce un avviso e non
    interrompe lo snapshot. Il primo metodo chiamato e' sempre getApiKeyDetails, che
    dichiara quali servizi la chiave ha davvero.

    Compatibile con PowerShell 5.1 (Windows PowerShell) e PowerShell 7+.
.PARAMETER ApiUrl
    Access URL della Control Center API, SENZA il suffisso /v1.0/jsonrpc. E' un valore
    specifico dell'installazione e non si indovina: va letto in console sotto il
    proprio account, nella sezione delle API. Se omesso si usa BITDEFENDER_API_URL dal
    file .env privato, poi la variabile d'ambiente omonima.
.PARAMETER ApiKey
    Service API key come SecureString. Se omessa si usa BITDEFENDER_API_KEY dal file
    .env privato, poi la variabile d'ambiente omonima, infine un prompt a runtime.
.PARAMETER OutputDir
    Cartella di output. Default: sottocartella output/ della radice del progetto.
.PARAMETER IncludeHeavy
    Include le interrogazioni voluminose, cioe' il dettaglio per singolo endpoint e le
    patch mancanti e installate. Escluse per default perche' su alcune decine di
    endpoint producono molte migliaia di righe. Per il lavoro ISO servono: la prima
    corsa utile si fa con questo parametro.
.PARAMETER MaxEndpointDetails
    Tetto al numero di endpoint di cui chiedere il dettaglio quando -IncludeHeavy e'
    attivo. Default 200. Esiste per non trasformare un errore di perimetro in migliaia
    di chiamate.
.PARAMETER IncludeInstalledPatches
    Aggiunge anche le patch gia' installate. Pesa molto piu' delle mancanti e serve
    soltanto a dimostrare la copertura storica, non a trovare un difetto aperto.
.EXAMPLE
    .\scripts\Get-BitdefenderSnapshot.ps1
    Corsa leggera: licenza, moduli, inventario, policy, quarantena, incidenti.
.EXAMPLE
    .\scripts\Get-BitdefenderSnapshot.ps1 -IncludeHeavy
    Corsa completa con dettaglio per endpoint e patch mancanti con le loro CVE.
.NOTES
    Fonti ufficiali, lette il 30/10/2026:
      Public API, indice dei servizi   https://www.bitdefender.com/business/support/en/77209-125277-public-api.html
      getApiKeyDetails                 https://www.bitdefender.com/business/support/en/77209-140282-getapikeydetails.html
      getLicenseInfo                   https://www.bitdefender.com/business/support/en/77209-127105-getlicenseinfo.html
      getNetworkInventoryItems         https://www.bitdefender.com/business/support/en/77209-128494-getnetworkinventoryitems.html
      getEndpointsList                 https://www.bitdefender.com/business/support/en/77209-128483-getendpointslist.html
      getManagedEndpointDetails        https://www.bitdefender.com/business/support/en/77209-128484-getmanagedendpointdetails.html
      getMissingPatches                https://www.bitdefender.com/business/support/en/77209-1223777-getmissingpatches.html
      getInstalledPatches              https://www.bitdefender.com/business/support/en/77209-1223776-getinstalledpatches.html
      getQuarantineItemsList           https://www.bitdefender.com/business/support/en/77209-140256-getquarantineitemslist.html
      getIncidentsList                 https://www.bitdefender.com/business/support/en/77209-1463999-getincidentslist.html
      getPoliciesList                  https://www.bitdefender.com/business/support/en/77209-135303-getpolicieslist.html
      getCompanyDetails                https://www.bitdefender.com/business/support/en/77209-126239-getcompanydetails.html
      getReportsList                   https://www.bitdefender.com/business/support/en/77209-135315-getreportslist.html
#>

[CmdletBinding()]
param(
    [string]$ApiUrl,
    [SecureString]$ApiKey,
    [string]$OutputDir,
    [switch]$IncludeHeavy,
    [int]$MaxEndpointDetails = 200,
    [switch]$IncludeInstalledPatches
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutputDir) { $OutputDir = Join-Path $projectRoot 'output' }
if (-not (Test-Path -LiteralPath $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------------------------------------------------------------------------
# Risoluzione della configurazione: parametro, poi .env privato, poi ambiente.
# ---------------------------------------------------------------------------

function Get-EnvFileValue {
    param([string]$Name)
    $envPath = Join-Path $projectRoot '.env'
    if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) { return $null }
    foreach ($line in [System.IO.File]::ReadAllLines($envPath)) {
        if (-not $line.Trim() -or $line.TrimStart().StartsWith('#')) { continue }
        $match = [regex]::Match($line, '^([A-Z_][A-Z0-9_]*)=("(?:[^"\\]|\\.)*")$')
        if (-not $match.Success) { continue }
        if ($match.Groups[1].Value -ne $Name) { continue }
        try { return (ConvertFrom-Json -InputObject $match.Groups[2].Value) } catch { return $null }
    }
    return $null
}

if (-not $ApiUrl) { $ApiUrl = Get-EnvFileValue -Name 'BITDEFENDER_API_URL' }
if (-not $ApiUrl) { $ApiUrl = $env:BITDEFENDER_API_URL }
if (-not $ApiUrl) {
    throw "Access URL della Control Center API assente. Leggerlo in console sotto il proprio account, sezione API, e passarlo con -ApiUrl oppure scriverlo in .env come BITDEFENDER_API_URL."
}
if ($ApiUrl -notmatch '^https://') { throw "L'Access URL deve essere https://, ricevuto: $ApiUrl" }
# Normalizzazione. Chi copia l'indirizzo dalla barra del browser porta con se' il
# frammento della pagina di console, che non fa parte della base API; chi copia un
# esempio della documentazione porta il suffisso della versione e del servizio. Si
# tolgono entrambi. Se non resta alcun percorso si usa /api, che e' la base della
# console cloud: non e' un indovinello silenzioso, viene stampata e la prima chiamata
# la verifica subito.
$ApiUrl = ($ApiUrl -split '[#?]')[0]
$ApiUrl = $ApiUrl -replace '/v1\.\d+/jsonrpc.*$', ''
$ApiUrl = $ApiUrl.TrimEnd('/')
if ($ApiUrl -match '^https://[^/]+$') {
    $ApiUrl = "$ApiUrl/api"
    Write-Host "Access URL senza percorso: si usa la base $ApiUrl" -ForegroundColor Yellow
}
Write-Host "Base API: $ApiUrl" -ForegroundColor DarkGray

if (-not $ApiKey) {
    $plainFromEnv = Get-EnvFileValue -Name 'BITDEFENDER_API_KEY'
    if (-not $plainFromEnv) { $plainFromEnv = $env:BITDEFENDER_API_KEY }
    if ($plainFromEnv) { $ApiKey = ConvertTo-SecureString -String $plainFromEnv -AsPlainText -Force }
    Remove-Variable -Name plainFromEnv -ErrorAction SilentlyContinue
}
if (-not $ApiKey) { $ApiKey = Read-Host -Prompt 'Service API key GravityZone (non mostrata)' -AsSecureString }

$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ApiKey)
try { $keyPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
if ([string]::IsNullOrWhiteSpace($keyPlain)) { throw 'Service API key vuota.' }

# GravityZone ha due schemi di autenticazione, e quale valga dipende da come la chiave e'
# stata creata. Le chiavi API personali, generate dal proprio account, si mandano in HTTP
# Basic con la chiave come nome utente e password vuota. Le service API key, legate a un
# account di servizio e non a una persona, si mandano invece nell'header X-API-Key. Una
# chiave del secondo tipo mandata con lo schema del primo risponde 401 su ogni metodo,
# che e' esattamente cio' che e' successo il 30/10/2026 alla prima corsa. Invece di
# scegliere per ipotesi si negozia: si prova il primo schema sulla chiamata di apertura,
# e se risponde 401 si passa all'altro e lo si usa per tutto il resto della corsa.
$keyPlain = $keyPlain.Trim()
$script:SchemiAuth = @(
    @{ Nome = 'X-API-Key'; Headers = @{ 'X-API-Key' = $keyPlain } },
    @{ Nome = 'Basic';     Headers = @{ Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($keyPlain + ':')) } }
)
$script:AuthHeaders = $script:SchemiAuth[0].Headers
$script:AuthNome = $script:SchemiAuth[0].Nome
Remove-Variable -Name keyPlain

# ---------------------------------------------------------------------------
# Trasporto JSON-RPC, best-effort: un servizio negato non ferma lo snapshot.
# ---------------------------------------------------------------------------

$script:Avvisi = New-Object System.Collections.ArrayList
$script:ChiamateRiuscite = 0
$script:ChiamateFallite = 0
$script:UltimaChiamata = (Get-Date).AddSeconds(-1)

function Invoke-GzApi {
    param(
        [Parameter(Mandatory)][string]$Service,
        [Parameter(Mandatory)][string]$Method,
        [hashtable]$Params,
        [string]$ApiVersion = 'v1.0'
    )
    $uri = "$ApiUrl/$ApiVersion/jsonrpc/$Service"
    $body = @{
        id      = [guid]::NewGuid().ToString()
        jsonrpc = '2.0'
        method  = $Method
        params  = if ($Params) { $Params } else { @{} }
    } | ConvertTo-Json -Depth 10 -Compress

    # La API limita a poco piu' di dieci richieste al secondo per chiave e risponde 429
    # quando si supera: con decine di endpoint il dettaglio ci arriva da solo. Si tiene
    # una distanza minima fra le chiamate e si riprova con attesa crescente, perche' un
    # 429 non e' un errore del metodo ma una richiesta di rallentare.
    $response = $null
    $tentativi = 0
    while ($true) {
        $tentativi++
        # Si confronta prima e si converte dopo: alla prima chiamata la differenza vale
        # milioni di anni in millisecondi e non entra in un Int32.
        $attesa = ($script:UltimaChiamata.AddMilliseconds(120) - (Get-Date)).TotalMilliseconds
        if ($attesa -gt 0) { Start-Sleep -Milliseconds ([int][Math]::Min($attesa, 5000)) }
        $script:UltimaChiamata = Get-Date
        try {
            $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType 'application/json' -Headers $script:AuthHeaders -TimeoutSec 120
            break
        }
        catch {
            $code = $null
            if ($_.Exception.PSObject.Properties.Name -contains 'Response' -and $_.Exception.Response) {
                try { $code = [int]$_.Exception.Response.StatusCode } catch { $code = $null }
            }
            if ($code -eq 429 -and $tentativi -le 4) {
                Start-Sleep -Seconds ([Math]::Pow(2, $tentativi))
                continue
            }
            $spiega = ''
            if ($code -eq 403) { $spiega = ' (servizio raggiunto ma non consentito: permesso della chiave o modulo non in licenza)' }
            $null = $script:Avvisi.Add("${Service}.${Method}: errore di trasporto - $($_.Exception.Message)$spiega")
            $script:ChiamateFallite++
            return $null
        }
    }

    if ($response.PSObject.Properties.Name -contains 'error' -and $response.error) {
        $msg = $response.error.message
        if ($response.error.PSObject.Properties.Name -contains 'data' -and $response.error.data) {
            $msg = "$msg | $($response.error.data | ConvertTo-Json -Compress -Depth 4)"
        }
        $null = $script:Avvisi.Add("${Service}.${Method}: errore API - $msg")
        $script:ChiamateFallite++
        return $null
    }

    $script:ChiamateRiuscite++
    if ($response.PSObject.Properties.Name -contains 'result') { return $response.result }
    return $null
}

function Invoke-GzPaged {
    <# Scorre le pagine finche' pagesCount lo consente. Tetto di sicurezza a 100 pagine. #>
    param(
        [Parameter(Mandatory)][string]$Service,
        [Parameter(Mandatory)][string]$Method,
        [hashtable]$Params,
        [string]$ApiVersion = 'v1.0',
        [int]$PerPage = 100
    )
    $items = New-Object System.Collections.ArrayList
    $page = 1
    do {
        $p = @{}
        if ($Params) { foreach ($k in $Params.Keys) { $p[$k] = $Params[$k] } }
        $p['page'] = $page
        $p['perPage'] = $PerPage
        $res = Invoke-GzApi -Service $Service -Method $Method -Params $p -ApiVersion $ApiVersion
        if (-not $res) { break }
        if ($res.PSObject.Properties.Name -contains 'items' -and $res.items) {
            foreach ($i in $res.items) { $null = $items.Add($i) }
        }
        $pagesCount = 1
        if ($res.PSObject.Properties.Name -contains 'pagesCount' -and $res.pagesCount) { $pagesCount = [int]$res.pagesCount }
        $page++
    } while ($page -le $pagesCount -and $page -le 100)
    return , $items.ToArray()
}

# Il nome del servizio nel path e' confermato dalla documentazione solo per network,
# quarantine e incidents; per gli altri la pagina dichiara il nome della sezione e non
# il segmento di URL. Invece di indovinarne uno solo si provano i candidati in ordine e
# si registra quale ha risposto, cosi' la corsa successiva sa gia' da dove passare.
$script:PathRisolti = [ordered]@{}

function Invoke-GzApiAny {
    param(
        [Parameter(Mandatory)][string[]]$Services,
        [Parameter(Mandatory)][string]$Method,
        [hashtable]$Params,
        [string]$ApiVersion = 'v1.0'
    )
    foreach ($s in $Services) {
        $r = Invoke-GzApi -Service $s -Method $Method -Params $Params -ApiVersion $ApiVersion
        if ($null -ne $r) { $script:PathRisolti[$Method] = "$ApiVersion/$s"; return $r }
    }
    return $null
}

function Invoke-GzPagedAny {
    param(
        [Parameter(Mandatory)][string[]]$Services,
        [Parameter(Mandatory)][string]$Method,
        [hashtable]$Params,
        [string]$ApiVersion = 'v1.0',
        [int]$PerPage = 100
    )
    foreach ($s in $Services) {
        $prima = $script:ChiamateFallite
        $r = Invoke-GzPaged -Service $s -Method $Method -Params $Params -ApiVersion $ApiVersion -PerPage $PerPage
        if ($script:ChiamateFallite -eq $prima) { $script:PathRisolti[$Method] = "$ApiVersion/$s"; return , $r }
    }
    return , @()
}

# ---------------------------------------------------------------------------
# Raccolta.
# ---------------------------------------------------------------------------

$snapshot = [ordered]@{
    meta = [ordered]@{
        generato_il       = (Get-Date).ToString('o')
        access_url        = $ApiUrl
        script            = 'Get-BitdefenderSnapshot.ps1'
        sola_lettura      = $true
        include_heavy     = [bool]$IncludeHeavy
        nota_perimetro    = 'La Public API di GravityZone non espone i rilievi nominali di Risk Management: il rischio arriva come riskScore aggregato e come CVE dentro le patch.'
    }
}

function Select-SchemaAuth {
    <# Prova gli schemi in ordine sulla chiamata di apertura e adotta il primo che non
       viene rifiutato. Un errore JSON-RPC torna comunque con HTTP 200, quindi una
       risposta ricevuta significa che l'autenticazione e' passata, anche se il metodo
       fosse negato dai permessi. #>
    $uri = "$ApiUrl/v1.0/jsonrpc/general"
    $body = @{ id = [guid]::NewGuid().ToString(); jsonrpc = '2.0'; method = 'getApiKeyDetails'; params = @{} } | ConvertTo-Json -Depth 5 -Compress
    foreach ($s in $script:SchemiAuth) {
        try {
            $null = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType 'application/json' -Headers $s.Headers -TimeoutSec 60
            $script:AuthHeaders = $s.Headers
            $script:AuthNome = $s.Nome
            Write-Host "Schema di autenticazione adottato: $($s.Nome)" -ForegroundColor Green
            return $true
        }
        catch {
            $code = $null
            if ($_.Exception.PSObject.Properties.Name -contains 'Response' -and $_.Exception.Response) {
                try { $code = [int]$_.Exception.Response.StatusCode } catch { $code = $null }
            }
            if ($code -eq 401 -or $code -eq 403) {
                $null = $script:Avvisi.Add("Schema $($s.Nome): HTTP $code sulla chiamata di apertura, si prova l'altro schema.")
            }
            else {
                $null = $script:Avvisi.Add("Schema $($s.Nome): $($_.Exception.Message)")
            }
        }
    }
    return $false
}

Write-Host 'Negoziazione dello schema di autenticazione...' -ForegroundColor Cyan
if (-not (Select-SchemaAuth)) {
    $null = $script:Avvisi.Add('Nessuno schema di autenticazione accettato: la chiave, la sua scadenza o la base API vanno verificate prima di leggere il resto di questo esito.')
    Write-Warning "Nessuno schema accettato su $ApiUrl. Si prosegue con $($script:AuthNome) per registrare gli errori, ma non si attende alcun esito utile."
}

Write-Host 'Chiave API: lettura dei servizi abilitati...' -ForegroundColor Cyan
$apiKeyDetails = Invoke-GzApi -Service 'general' -Method 'getApiKeyDetails'
$snapshot['chiave_api'] = $apiKeyDetails
$serviziAbilitati = @()
if ($apiKeyDetails -and $apiKeyDetails.PSObject.Properties.Name -contains 'enabledApis') {
    $serviziAbilitati = @($apiKeyDetails.enabledApis)
    Write-Host ("  servizi abilitati: " + ($serviziAbilitati -join ', ')) -ForegroundColor DarkGray
}
else {
    $null = $script:Avvisi.Add('getApiKeyDetails non ha risposto: i servizi abilitati non sono noti e si prova comunque ogni interrogazione.')
}

function Test-ServizioAbilitato {
    param([string]$Nome)
    if (-not $serviziAbilitati -or $serviziAbilitati.Count -eq 0) { return $true }
    return ($serviziAbilitati -contains $Nome)
}

Write-Host 'Licenza e moduli...' -ForegroundColor Cyan
$snapshot['licenza'] = Invoke-GzApi -Service 'licensing' -Method 'getLicenseInfo'

Write-Host 'Compagnia...' -ForegroundColor Cyan
$snapshot['compagnia'] = Invoke-GzApi -Service 'companies' -Method 'getCompanyDetails'

Write-Host 'Inventario di rete...' -ForegroundColor Cyan
# Le opzioni arricchite esistono solo dove i moduli corrispondenti sono in licenza: su
# questa installazione includeRiskScore e' rifiutato come opzione sconosciuta, perche'
# Risk Management non e' licenziato. Si prova la forma ricca e si ripiega sulla povera,
# invece di perdere l'inventario intero per un'opzione.
$inventario = Invoke-GzPaged -Service 'network' -Method 'getNetworkInventoryItems' -Params @{
    options = @{
        endpoints = @{
            includeRiskScore      = $true
            returnProductOutdated = $true
            includeScanLogs       = $true
        }
    }
}
if ($inventario.Count -eq 0) {
    $null = $script:Avvisi.Add('getNetworkInventoryItems con le opzioni arricchite non ha prodotto nulla: si riprova senza opzioni.')
    $inventario = Invoke-GzPaged -Service 'network' -Method 'getNetworkInventoryItems'
}
$snapshot['inventario'] = $inventario

Write-Host 'Elenco degli endpoint...' -ForegroundColor Cyan
$endpoints = Invoke-GzPaged -Service 'network' -Method 'getEndpointsList' -Params @{ isManaged = $true }
$snapshot['endpoint'] = $endpoints

Write-Host 'Policy...' -ForegroundColor Cyan
$snapshot['policy'] = Invoke-GzPaged -Service 'policies' -Method 'getPoliciesList'

Write-Host 'Quarantena...' -ForegroundColor Cyan
$snapshot['quarantena'] = Invoke-GzPaged -Service 'quarantine/computers' -Method 'getQuarantineItemsList'

Write-Host 'Incidenti EDR/XDR...' -ForegroundColor Cyan
$snapshot['incidenti'] = Invoke-GzPaged -Service 'incidents' -Method 'getIncidentsList' -ApiVersion 'v1.2' -PerPage 100

Write-Host 'Rapporti schedulati...' -ForegroundColor Cyan
$snapshot['rapporti'] = Invoke-GzPaged -Service 'reports' -Method 'getReportsList'

$dettagli = @()
$patchMancanti = @()
$patchInstallate = @()

if ($IncludeHeavy) {
    $ids = @()
    foreach ($e in $endpoints) {
        if ($e.PSObject.Properties.Name -contains 'id' -and $e.id) { $ids += $e.id }
    }
    if ($ids.Count -gt $MaxEndpointDetails) {
        $null = $script:Avvisi.Add("Endpoint trovati $($ids.Count), tetto -MaxEndpointDetails ${MaxEndpointDetails}: il dettaglio si ferma al tetto.")
        $ids = $ids[0..($MaxEndpointDetails - 1)]
    }

    Write-Host "Dettaglio di $($ids.Count) endpoint..." -ForegroundColor Cyan
    $n = 0
    foreach ($id in $ids) {
        $n++
        Write-Progress -Activity 'Dettaglio endpoint' -Status "$n / $($ids.Count)" -PercentComplete (100 * $n / [Math]::Max($ids.Count, 1))
        $d = Invoke-GzApi -Service 'network' -Method 'getManagedEndpointDetails' -Params @{
            endpointId = $id
            options    = @{ includeScanLogs = $true }
        }
        if ($d) { $dettagli += $d }
    }
    Write-Progress -Activity 'Dettaglio endpoint' -Completed

    # L'ordine viene da enabledApis, che su questa installazione dichiara 'patchmanagement'.
    # Un 403 su questo servizio non e' un difetto dello strumento: significa che il modulo
    # Patch Management non e' in licenza, cosa che getLicenseInfo conferma con
    # managePatchManagement a falso. Senza quel modulo non esistono CVE da leggere.
    $candidatiPatch = @('patchmanagement', 'patchManagement', 'patch')

    Write-Host 'Patch mancanti (CVE)...' -ForegroundColor Cyan
    $patchMancanti = Invoke-GzPagedAny -Services $candidatiPatch -Method 'getMissingPatches' -Params @{ endpointsIds = $ids } -PerPage 100

    if ($IncludeInstalledPatches) {
        Write-Host 'Patch installate...' -ForegroundColor Cyan
        $patchInstallate = Invoke-GzPagedAny -Services $candidatiPatch -Method 'getInstalledPatches' -Params @{ endpointsIds = $ids } -PerPage 100
    }

    Write-Host 'Dettaglio delle policy applicate...' -ForegroundColor Cyan
    $dettaglioPolicy = @()
    foreach ($p in $snapshot['policy']) {
        if ($p.PSObject.Properties.Name -contains 'id' -and $p.id) {
            $pd = Invoke-GzApi -Service 'policies' -Method 'getPolicyDetails' -Params @{ policyId = $p.id }
            if ($pd) { $dettaglioPolicy += $pd }
        }
    }
    $snapshot['dettaglio_policy'] = $dettaglioPolicy
}

# ---------------------------------------------------------------------------
# Il resto di cio' che la chiave puo' leggere. La chiave di questa installazione porta
# tutti e quattordici i permessi, quindi si raccoglie tutto il leggibile in un giro
# solo: ogni voce che non risponde finisce negli avvisi e non ferma le altre.
# ---------------------------------------------------------------------------

Write-Host 'Resto del leggibile (tag, gruppi, account, integrazioni, PHASR, push)...' -ForegroundColor Cyan

$altro = [ordered]@{}

$altro['tag_endpoint']        = Invoke-GzApiAny   -Services @('network') -Method 'getEndpointTags'
# getCustomGroupsList non accetta page e perPage, getIntegrators vuole un integrationId
# che qui non si ha: entrambi si chiamano nella forma che la API dichiara di attendersi.
$altro['gruppi_personalizzati'] = Invoke-GzApiAny -Services @('network') -Method 'getCustomGroupsList'
$altro['attivita_scansione']  = Invoke-GzPagedAny -Services @('network') -Method 'getScanTasksList'

$altro['account']             = Invoke-GzPagedAny -Services @('accounts') -Method 'getAccountsList'
$altro['notifiche']           = Invoke-GzApiAny   -Services @('accounts') -Method 'getNotificationsSettings'

$altro['integrazioni_configurate'] = Invoke-GzApiAny -Services @('integrations') -Method 'getConfiguredIntegrations'

$altro['push_impostazioni']   = Invoke-GzApiAny -Services @('push') -Method 'getPushEventSettings'
$altro['push_statistiche']    = Invoke-GzApiAny -Services @('push') -Method 'getPushEventStats'

$altro['pacchetti']           = Invoke-GzPagedAny -Services @('packages') -Method 'getPackagesList'
$altro['link_installazione']  = Invoke-GzApiAny   -Services @('packages') -Method 'getInstallationLinks'

$altro['uso_mensile']         = Invoke-GzApiAny -Services @('licensing') -Method 'getMonthlyUsage'
$altro['uso_mensile_per_prodotto'] = Invoke-GzApiAny -Services @('licensing') -Method 'getMonthlyUsagePerProductType'

$candidatiFinestre = @('maintenanceWindows', 'maintenance-windows', 'maintenancewindows')
$altro['finestre_manutenzione'] = Invoke-GzPagedAny -Services $candidatiFinestre -Method 'getMaintenanceWindowsList'
$altro['patch_approvate_a_mano'] = Invoke-GzPagedAny -Services $candidatiFinestre -Method 'getManuallyApprovedPatches'

$altro['quarantena_exchange'] = Invoke-GzPagedAny -Services @('quarantine/exchange') -Method 'getQuarantineItemsList'

$altro['blocklist']           = Invoke-GzPagedAny -Services @('incidents') -Method 'getBlocklistItems' -ApiVersion 'v1.2'
$altro['regole_personalizzate'] = Invoke-GzPagedAny -Services @('incidents') -Method 'getCustomRulesList' -ApiVersion 'v1.2'

$candidatiPhasr = @('phasr', 'PHASR')
$altro['phasr_regole_monitorate'] = Invoke-GzApiAny -Services $candidatiPhasr -Method 'getMonitoredRules'
$altro['phasr_identita']      = Invoke-GzApiAny -Services $candidatiPhasr -Method 'getAllCompanyIdentities'
$altro['phasr_risorse']       = Invoke-GzApiAny -Services $candidatiPhasr -Method 'getAllCompanyResources'
$altro['phasr_raccomandazioni'] = Invoke-GzApiAny -Services $candidatiPhasr -Method 'getPhasrRecommendations'
$altro['phasr_profili']       = Invoke-GzApiAny -Services $candidatiPhasr -Method 'getRecommendationProfiles'

$snapshot['altro'] = $altro
$snapshot['meta']['path_risolti'] = $script:PathRisolti

$snapshot['dettaglio_endpoint'] = $dettagli
$snapshot['patch_mancanti'] = $patchMancanti
$snapshot['patch_installate'] = $patchInstallate
$snapshot['avvisi'] = @($script:Avvisi.ToArray())
$snapshot['meta']['chiamate_riuscite'] = $script:ChiamateRiuscite
$snapshot['meta']['chiamate_fallite'] = $script:ChiamateFallite

# ---------------------------------------------------------------------------
# Scrittura.
# ---------------------------------------------------------------------------

$jsonPath = Join-Path $OutputDir 'bitdefender-snapshot.json'
$snapshot | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
Write-Host "JSON scritto: $jsonPath" -ForegroundColor Green

function Get-ModuliScaduti {
    param($Licenza)
    $out = New-Object System.Collections.ArrayList
    if (-not $Licenza) { return $out }
    $flag = @{
        manageIntegrityMonitoring = 'Integrity Monitoring'
        managePatchManagement     = 'Patch Management'
        manageHyperDetect         = 'HyperDetect'
        manageSandboxAnalyzer     = 'Sandbox Analyzer'
        manageEncryption          = 'Encryption'
        manageEventCorrelator     = 'Event Correlator (EDR)'
        manageComplianceManager   = 'Compliance Manager'
        managePHASR               = 'PHASR'
        manageEASM                = 'EASM'
        manageAiSpm               = 'AI SPM'
        manageContainerProtection = 'Container Protection'
        manageExtendedEmailSecurity = 'Extended Email Security'
        manageMobileSecurity      = 'Mobile Security'
        manageExchange            = 'Security for Exchange'
    }
    foreach ($k in $flag.Keys) {
        if ($Licenza.PSObject.Properties.Name -contains $k) {
            $null = $out.Add([pscustomobject]@{ Modulo = $flag[$k]; Flag = $k; Licenziato = [bool]$Licenza.$k })
        }
    }
    return $out
}

$md = New-Object System.Collections.ArrayList
$null = $md.Add('# Snapshot Bitdefender GravityZone')
$null = $md.Add('')
$null = $md.Add("> Generato da ``scripts/Get-BitdefenderSnapshot.ps1`` il $((Get-Date).ToString('dd/MM/yyyy HH:mm')). Sola lettura. Contiene nomi host e indirizzi reali: non copiare in file tracciati senza applicare ``.claude/rules/anonymization.md``.")
$null = $md.Add('')
$null = $md.Add("Chiamate riuscite $($script:ChiamateRiuscite), fallite $($script:ChiamateFallite).")
$null = $md.Add('')

$null = $md.Add('## Licenza e moduli')
$null = $md.Add('')
if ($snapshot['licenza']) {
    $lic = $snapshot['licenza']
    foreach ($campo in @('expiryDate', 'endSubscription', 'subscriptionType', 'usedSlots', 'totalSlots')) {
        if ($lic.PSObject.Properties.Name -contains $campo) {
            $null = $md.Add("- $campo : $($lic.$campo)")
        }
    }
    $null = $md.Add('')
    $null = $md.Add('| Modulo | Licenziato |')
    $null = $md.Add('|---|---|')
    foreach ($m in (Get-ModuliScaduti -Licenza $lic | Sort-Object Modulo)) {
        $null = $md.Add("| $($m.Modulo) | $(if ($m.Licenziato) { 'si' } else { 'NO' }) |")
    }
}
else {
    $null = $md.Add('Non letta: vedere gli avvisi in fondo.')
}
$null = $md.Add('')

$null = $md.Add('## Endpoint')
$null = $md.Add('')
$null = $md.Add("Endpoint gestiti letti: $($endpoints.Count).")
$null = $md.Add('')
if ($dettagli.Count -gt 0) {
    $obsoleti = @($dettagli | Where-Object { $_.PSObject.Properties.Name -contains 'agent' -and $_.agent -and $_.agent.productOutdated })
    $firmeVecchie = @($dettagli | Where-Object { $_.PSObject.Properties.Name -contains 'agent' -and $_.agent -and $_.agent.signatureOutdated })
    $null = $md.Add("Agenti con prodotto non aggiornato: $($obsoleti.Count). Con firme non aggiornate: $($firmeVecchie.Count).")
    $null = $md.Add('')
    $null = $md.Add('| Endpoint | Rischio | Misconfig. | Vuln. app | Moduli spenti |')
    $null = $md.Add('|---|---|---|---|---|')
    foreach ($d in $dettagli) {
        $nome = if ($d.PSObject.Properties.Name -contains 'name') { $d.name } else { '?' }
        $rs = if ($d.PSObject.Properties.Name -contains 'riskScore' -and $d.riskScore) { $d.riskScore } else { $null }
        $spenti = @()
        if ($d.PSObject.Properties.Name -contains 'modules' -and $d.modules) {
            foreach ($p in $d.modules.PSObject.Properties) {
                if ($p.Value -eq $false) { $spenti += $p.Name }
            }
        }
        $null = $md.Add("| $nome | $(if ($rs) { $rs.value } else { 'n.d.' }) | $(if ($rs) { $rs.misconfigurations } else { 'n.d.' }) | $(if ($rs) { $rs.appVulnerabilities } else { 'n.d.' }) | $($spenti -join ', ') |")
    }
}
else {
    $null = $md.Add('Dettaglio per endpoint non raccolto: rilanciare con -IncludeHeavy.')
}
$null = $md.Add('')

$null = $md.Add('## Patch mancanti e CVE')
$null = $md.Add('')
if ($patchMancanti.Count -gt 0) {
    $cve = New-Object System.Collections.Generic.HashSet[string]
    foreach ($p in $patchMancanti) {
        if ($p.PSObject.Properties.Name -contains 'cves' -and $p.cves) {
            foreach ($c in $p.cves) { $null = $cve.Add([string]$c) }
        }
    }
    $null = $md.Add("Patch mancanti: $($patchMancanti.Count). CVE distinte coperte da quelle patch: $($cve.Count).")
    $null = $md.Add('')
    $null = $md.Add('| Patch | Severita | Endpoint | CVE |')
    $null = $md.Add('|---|---|---|---|')
    foreach ($p in ($patchMancanti | Select-Object -First 100)) {
        $sev = if ($p.PSObject.Properties.Name -contains 'severity') { $p.severity } else { '' }
        $cves = if ($p.PSObject.Properties.Name -contains 'cves' -and $p.cves) { ($p.cves -join ' ') } else { '' }
        $null = $md.Add("| $($p.name) | $sev | $($p.endpointId) | $cves |")
    }
    if ($patchMancanti.Count -gt 100) { $null = $md.Add('') ; $null = $md.Add("Elencate le prime 100 su $($patchMancanti.Count): l'insieme completo e' nel JSON.") }
}
else {
    $null = $md.Add("Nessuna patch mancante letta. Puo' significare che il modulo Patch Management non e' in licenza, che la chiave non ha il permesso, oppure che non ne mancano: la distinzione sta negli avvisi e nella tabella dei moduli.")
}
$null = $md.Add('')

$null = $md.Add('## Quarantena, incidenti, policy')
$null = $md.Add('')
$null = $md.Add("Elementi in quarantena: $($snapshot['quarantena'].Count). Incidenti: $($snapshot['incidenti'].Count). Policy: $($snapshot['policy'].Count).")
$null = $md.Add('')

$null = $md.Add('## Copertura della raccolta')
$null = $md.Add('')
$null = $md.Add('| Voce | Elementi letti |')
$null = $md.Add('|---|---|')
foreach ($k in $altro.Keys) {
    $v = $altro[$k]
    $n = 'n.d.'
    if ($null -eq $v) { $n = 'non letta' }
    elseif ($v -is [array]) { $n = $v.Count }
    else { $n = 'oggetto' }
    $null = $md.Add("| $k | $n |")
}
$null = $md.Add('')
if ($script:PathRisolti.Count -gt 0) {
    $null = $md.Add('Path risolti in questa corsa:')
    $null = $md.Add('')
    foreach ($k in $script:PathRisolti.Keys) { $null = $md.Add("- $k -> $($script:PathRisolti[$k])") }
    $null = $md.Add('')
}

$null = $md.Add('## Avvisi')
$null = $md.Add('')
if ($script:Avvisi.Count -eq 0) {
    $null = $md.Add('Nessuno.')
}
else {
    foreach ($a in $script:Avvisi) { $null = $md.Add("- $a") }
}
$null = $md.Add('')

$mdPath = Join-Path $OutputDir 'bitdefender-config.md'
($md -join "`n") | Set-Content -LiteralPath $mdPath -Encoding UTF8
Write-Host "Riepilogo scritto: $mdPath" -ForegroundColor Green

if ($script:ChiamateRiuscite -eq 0) {
    Write-Warning 'Nessuna chiamata riuscita: verificare Access URL, chiave e permessi.'
    exit 1
}
Write-Host "Snapshot completato: $($script:ChiamateRiuscite) chiamate riuscite, $($script:ChiamateFallite) fallite, $($script:Avvisi.Count) avvisi." -ForegroundColor Green
