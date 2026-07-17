<#
.SYNOPSIS
    Micro-step M13a (Fase A rete Wi-Fi): assegna la VLAN Wi-Fi staff alle tre porte
    degli access point gia' localizzati e la propaga sulle porte trunk, via Nebula OpenAPI.
.DESCRIPTION
    Scrive (non solo legge) la configurazione dei due switch Zyxel Nebula. A differenza
    di Get-NebulaSnapshot.ps1 (sola lettura), questo script puo' modificare port-settings
    reali: di default gira SEMPRE in modalita' dry-run e stampa il piano senza inviare
    nulla. Serve il parametro -Apply PIU' una conferma testuale a runtime per scrivere
    davvero (vedi ADR-010 in .claude/memory/decisions.md).

    Target fissi (da docs/runbook-anomalie.md §AP-001, verificati il 15/07/2026 via
    tabella MAC L2 incrociata con LLDP):
      XGS2220-30HP porta 1   -> AP "PianoTerra"  (74:83:C2:20:8F:27)
      XGS2220-54HP porta 41  -> AP "PianoPrimo"   (74:83:C2:83:48:12)
      XGS2220-54HP porta 45  -> AP "PianoSecondo" (74:83:C2:20:8E:E6)
    (EsternoIrrigazione, XGS2220-30HP porta 4, e' fuori scope: e' l'AP dell'irrigazione,
    non fa parte della Wi-Fi staff da isolare in questa fase.)

    Per ciascuna delle tre porte target, imposta portVid=$VlanId (access port, VLAN
    untagged) mantenendo invariati enabled/pseEnabled correnti (non si spegne mai il PoE
    di un AP che sta alimentando un dispositivo live). Per ogni porta gia' marcata
    trunk=true su entrambi gli switch (scoperta dinamicamente via GET, non hardcoded),
    aggiunge $VlanId a allowedVLAN se non gia' presente, cosi' il traffico della nuova
    VLAN attraversa anche il collegamento dorsale tra i due switch.

    CORREZIONE 15/07/2026 (verificata a schermo, non solo da documentazione): il campo
    PVID nel pannello "Update port" della GUI Nebula (Switch ports > Edit) e' un campo di
    testo libero, non un menu a tendina vincolato a VLAN preesistenti - scrivere un ID mai
    usato prima lo rende valido immediatamente, sulla singola porta. La VLAN NON va quindi
    pre-creata da nessuna parte (ne' da GUI ne' da un endpoint dedicato, che infatti non
    esiste): assegnarla a una prima porta e' sufficiente. Questo semplifica ADR-010, la
    cui parte sul "limite di creazione VLAN" resta corretta sulla API (non esiste un
    endpoint dedicato) ma la conseguenza pratica (serve un passo GUI preliminare) era
    un'inferenza sbagliata, corretta dopo la verifica diretta a schermo.

    ATTENZIONE OPERATIVA (piu' rilevante del punto sopra): applicare in un colpo solo sia
    le porte trunk sia le tre porte AP e' rischioso, perche' il firewall non ha ancora
    un'interfaccia/DHCP per la VLAN $VlanId nel momento in cui gira questo script (vedi
    firewall-zyxel-usg-flex-500.md §Fase A, ancora da applicare a mano). Spostare il PVID
    di un AP live su una VLAN priva di DHCP lo scollega finche' il firewall non e' pronto.
    Per questo il parametro -Only permette di applicare prima solo le porte trunk (innocuo,
    nessun traffico usa ancora la VLAN), poi il resto del piano firewall a mano, e infine
    -Only Access per le tre porte AP, una alla volta con verifica.
.PARAMETER ApiKey
    Chiave API Nebula. Stessa risoluzione di Get-NebulaSnapshot.ps1: parametro -> variabile
    d'ambiente NEBULA_API_KEY -> prompt SecureString a runtime.
.PARAMETER VlanId
    ID della VLAN Wi-Fi staff da assegnare. Default 40 (confermato dall'utente il
    15/07/2026: nessuna collisione con le VLAN gia' in uso - 10 management, 90 Guest/IoT
    legacy, 100 fonia, 201 Proxmox test pianificata).
.PARAMETER Only
    'All' (default), 'Trunk' (solo le porte dorsali, sicuro da applicare subito) oppure
    'Access' (solo le tre porte AP, da applicare per ultimo e una alla volta - vedi
    ATTENZIONE OPERATIVA sopra).
.PARAMETER ApName
    Solo con -Only Access: limita il piano a un singolo AP ('PianoTerra',
    'PianoPrimo' o 'PianoSecondo') invece di tutti e tre insieme. Permette di
    applicare le porte AP una alla volta con verifica di connettivita' tra
    l'una e l'altra, come richiesto dalla checklist di
    firewall-zyxel-usg-flex-500.md §Fase A.
.PARAMETER Apply
    Se omesso, lo script gira in dry-run: stampa il piano (quali porte cambierebbero e
    come) senza inviare nessuna richiesta di scrittura. Con -Apply, dopo aver mostrato lo
    stesso piano chiede una conferma testuale esplicita prima di inviare le POST reali.
.PARAMETER OutputDir
    Cartella di destinazione del log di applicazione. Default: output/ nella radice del progetto.
.EXAMPLE
    .\scripts\Set-NebulaWifiVlan.ps1
    Dry-run con la VLAN di default (40): mostra il piano completo, non scrive nulla.
.EXAMPLE
    .\scripts\Set-NebulaWifiVlan.ps1 -Only Trunk -Apply
    Applica subito solo la propagazione sui trunk (sicuro, nessun impatto su traffico live).
.EXAMPLE
    .\scripts\Set-NebulaWifiVlan.ps1 -Only Access -ApName PianoTerra -Apply
    Applica solo la porta di un singolo AP - da ripetere una volta per AP, con
    verifica di connettivita' tra un AP e il successivo.
.PARAMETER PowerCycle
    Solo con -Only Access: dopo aver scritto la nuova VLAN sulla porta, spegne
    e riaccende il PoE di quella stessa porta (pseEnabled false poi true, con
    una pausa in mezzo), forzando un riavvio a freddo dell'AP gia' sulla VLAN
    nuova. Nato dall'incidente del 16/07/2026 (runbook-anomalie.md §NET-005):
    l'ipotesi e' che l'AP porti avanti uno stato residuo (es. lease DHCP della
    vecchia rete) che scade dopo qualche minuto invece di re-inizializzarsi
    subito sulla VLAN corretta - un riavvio a freddo elimina quello stato.
.EXAMPLE
    .\scripts\Set-NebulaWifiVlan.ps1 -Only Access -ApName PianoTerra -PowerCycle -Apply
    Applica la VLAN 40 su PianoTerra e forza subito un riavvio PoE per test.
#>

[CmdletBinding()]
param(
    [string]$ApiKey,
    [int]$VlanId = 40,
    [ValidateSet('All', 'Trunk', 'Access')]
    [string]$Only = 'All',
    [ValidateSet('PianoTerra', 'PianoPrimo', 'PianoSecondo')]
    [string]$ApName,
    [switch]$PowerCycle,
    [switch]$Apply,
    [string]$OutputDir
)

$ErrorActionPreference = 'Stop'

if ($PowerCycle -and $Only -ne 'Access') {
    Write-Error "-PowerCycle richiede -Only Access (il power-cycle ha senso solo sulle porte AP)."
    exit 1
}

$ReservedVlans = @(10, 90, 100, 201)
if ($ReservedVlans -contains $VlanId) {
    Write-Error "VLAN $VlanId e' gia' assegnata a un altro scopo noto (10=management, 90=Guest/IoT legacy, 100=fonia, 201=Proxmox test). Interrompo per sicurezza."
    exit 1
}

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

# ---------------------------------------------------------------------------
# 1. Chiave API
# ---------------------------------------------------------------------------
if (-not $ApiKey) {
    if ($env:NEBULA_API_KEY) {
        $ApiKey = $env:NEBULA_API_KEY
        Write-Host "Chiave API letta da variabile d'ambiente NEBULA_API_KEY." -ForegroundColor DarkGray
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
    try {
        return Invoke-RestMethod -Uri "$baseUrl$Path" -Method GET -Headers $headers
    } catch {
        Write-Warning "  [WARN] GET $Path : $_"
        return $null
    }
}

function Invoke-NebulaPostPortSettings {
    param([string]$SiteId, [string]$DevId, [hashtable]$Body)
    $json = $Body | ConvertTo-Json -Compress
    try {
        return Invoke-RestMethod -Uri "$baseUrl/$SiteId/sw/$DevId/port-settings" -Method POST -Headers $headers -Body $json -ContentType 'application/json'
    } catch {
        Write-Warning "  [WARN] POST /$SiteId/sw/$DevId/port-settings (portNum=$($Body.portNum)) : $_"
        return $null
    }
}

# GET /{siteId}/sw/{devId}/port-settings restituisce un inviluppo OData
# { "value": [...], "Count": N }, non un array nudo (a differenza di
# l2-mac-table e ports-status, verificato il 15/07/2026 sul dump reale in
# output/nebula-snapshot.json). Senza questo unwrap ogni filtro sui campi
# portNum/trunk fallisce silenziosamente: Where-Object non trova nulla e il
# piano risulterebbe vuoto senza nessun errore visibile.
function Get-NebulaArrayValue {
    param($Response)
    if ($null -eq $Response) { return @() }
    if ($Response.PSObject.Properties.Name -contains 'value') { return @($Response.value) }
    return @($Response)
}

# ---------------------------------------------------------------------------
# 2. Target fissi (vedi runbook-anomalie.md §AP-001)
# ---------------------------------------------------------------------------
$Targets = @(
    @{ SwitchMac = "70:49:A2:39:F9:00"; SwitchModel = "XGS2220-30HP"; PortNum = 1;  ApName = "PianoTerra" },
    @{ SwitchMac = "F4:4D:5C:8F:7C:39"; SwitchModel = "XGS2220-54HP"; PortNum = 41; ApName = "PianoPrimo" },
    @{ SwitchMac = "F4:4D:5C:8F:7C:39"; SwitchModel = "XGS2220-54HP"; PortNum = 45; ApName = "PianoSecondo" }
)

# ---------------------------------------------------------------------------
# 3. Scoperta organizzazione/sito/switch (stesso pattern di Get-NebulaSnapshot.ps1)
# ---------------------------------------------------------------------------
Write-Host "Scoperta organizzazione e siti Nebula..." -ForegroundColor Cyan
$orgs = @(Invoke-NebulaGet "/organizations")
if (-not $orgs -or $orgs.Count -eq 0) {
    Write-Error "Impossibile elencare le organizzazioni. Verificare la chiave API."
    exit 1
}

$plan = New-Object System.Collections.Generic.List[object]

foreach ($org in $orgs) {
    $oid = $org.orgId
    $sites = @(Invoke-NebulaGet "/organizations/$oid/sites")
    $siteDevicesResp = Invoke-NebulaGet "/organizations/$oid/sites/devices"

    foreach ($site in $sites) {
        $sid = $site.siteId
        $deviceGroup = $siteDevicesResp | Where-Object { $_.siteId -eq $sid }
        $devices = if ($deviceGroup) { $deviceGroup.devices } else { @() }
        $switches = @($devices | Where-Object { $_.type -eq "SW" })
        if ($switches.Count -eq 0) { continue }

        foreach ($sw in $switches) {
            $portSettings = Get-NebulaArrayValue (Invoke-NebulaGet "/$sid/sw/$($sw.devId)/port-settings")
            if ($portSettings.Count -eq 0) { continue }

            # 3a. Porte target (assegnazione access alla VLAN Wi-Fi)
            foreach ($t in ($Targets | Where-Object { $_.SwitchMac -eq $sw.mac })) {
                $current = $portSettings | Where-Object { $_.portNum -eq $t.PortNum } | Select-Object -First 1
                if (-not $current) {
                    Write-Warning "  Porta $($t.PortNum) non trovata su $($sw.name) [$($sw.model)] - salto ($($t.ApName))."
                    continue
                }
                # CORREZIONE 16/07/2026 (scoperta con un tentativo reale, non solo
                # ipotizzata): allowedVLAN=[] (lista vuota) viene RIFIUTATO dall'API
                # con 422 INVALID_ALLOWED_VLAN - nessuna scrittura parziale, la porta
                # resta nello stato precedente. Il valore minimo accettato sembra essere
                # la sola VLAN nativa della porta, [VlanId]: non ottiene l'access strict
                # "zero VLAN taggate" originariamente cercato, ma resta comunque piu'
                # stretto di "all" (ogni altra VLAN taggata continua a essere esclusa).
                $plan.Add([PSCustomObject]@{
                    Kind         = "access-port"
                    SiteId       = $sid
                    DevId        = $sw.devId
                    SwitchModel  = $sw.model
                    PortNum      = $t.PortNum
                    Label        = "AP $($t.ApName)"
                    CurrentVid   = $current.portVid
                    TargetVid    = $VlanId
                    CurrentTrunk = $current.trunk
                    TargetTrunk  = $false
                    AllowedVLAN  = @([string]$VlanId)
                    PseEnabled   = $current.pseEnabled
                    Changed      = ($current.portVid -ne $VlanId -or $current.trunk -eq $true -or (((@($current.allowedVLAN) | Sort-Object) -join ',') -ne 'all'))
                })
            }

            # 3b. Porte trunk (propagazione della VLAN sul dorsale)
            # NOTA (15/07/2026, verificato sui dati reali di entrambi gli switch): il
            # valore letterale "all" in allowedVLAN significa "ogni VLAN taggata passa
            # gia'", a prescindere dal flag trunk - la porta 29 del 30HP (l'uplink verso
            # il 54HP) ha trunk=false ma allowedVLAN=["all"] ed e' gia' attraversabile
            # dalla VLAN 40 oggi. Senza questo controllo lo script avrebbe provato ad
            # aggiungere "40" accanto alla stringa "all" (scrittura inutile, esito
            # sull'API non verificato) su porte che non ne hanno alcun bisogno.
            foreach ($trunkPort in ($portSettings | Where-Object { $_.trunk -eq $true })) {
                $allowed = @($trunkPort.allowedVLAN | ForEach-Object { [string]$_ })
                $alreadyAllowed = ($allowed -contains 'all') -or ($allowed -contains [string]$VlanId)
                $plan.Add([PSCustomObject]@{
                    Kind         = "trunk-port"
                    SiteId       = $sid
                    DevId        = $sw.devId
                    SwitchModel  = $sw.model
                    PortNum      = $trunkPort.portNum
                    Label        = "trunk"
                    CurrentVid   = $trunkPort.portVid
                    TargetVid    = $trunkPort.portVid
                    CurrentTrunk = $true
                    TargetTrunk  = $true
                    AllowedVLAN  = if ($alreadyAllowed) { $allowed } else { $allowed + [string]$VlanId }
                    PseEnabled   = $trunkPort.pseEnabled
                    Changed      = (-not $alreadyAllowed)
                })
            }
        }
    }
}

# ---------------------------------------------------------------------------
# 4. Filtro -Only e stampa del piano (sempre, dry-run o Apply)
# ---------------------------------------------------------------------------
$kindFilter = switch ($Only) {
    'Trunk'  { @('trunk-port') }
    'Access' { @('access-port') }
    default  { @('trunk-port', 'access-port') }
}
$scopedPlan = @($plan | Where-Object { $kindFilter -contains $_.Kind })

if ($ApName) {
    if ($Only -ne 'Access') {
        Write-Error "-ApName richiede -Only Access (filtra solo le porte AP, non ha senso con Trunk/All)."
        exit 1
    }
    $scopedPlan = @($scopedPlan | Where-Object { $_.Label -eq "AP $ApName" })
    if ($scopedPlan.Count -eq 0) {
        Write-Error "Nessuna porta trovata per l'AP '$ApName'."
        exit 1
    }
}

$ambito = if ($ApName) { "Access, solo $ApName" } else { $Only }
Write-Host "`n=== Piano Fase A - VLAN Wi-Fi staff $VlanId (ambito: $ambito) ===" -ForegroundColor Cyan
$scopedPlan | Sort-Object SwitchModel, PortNum | Format-Table SwitchModel, PortNum, Label, CurrentVid, TargetVid, CurrentTrunk, Changed -AutoSize | Out-String | Write-Host

$toChange = @($scopedPlan | Where-Object { $_.Changed })
if ($toChange.Count -eq 0) {
    Write-Host "Nessuna modifica necessaria nell'ambito '$ambito': le porte sono gia' nello stato target." -ForegroundColor Green
    exit 0
}
Write-Host "$($toChange.Count) porta/e richiedono una modifica reale nell'ambito '$ambito'." -ForegroundColor Yellow
if ($Only -eq 'Access') {
    Write-Host "PROMEMORIA: applicare le porte AP solo dopo che il firewall ha gia' l'interfaccia vlan40 con DHCP attivo (firewall-zyxel-usg-flex-500.md §Fase A), altrimenti l'AP resta senza indirizzo IP." -ForegroundColor Red
}

if (-not $Apply) {
    Write-Host "`nDry-run: nessuna richiesta di scrittura inviata. Rilanciare con -Apply per procedere." -ForegroundColor Yellow
    exit 0
}

# ---------------------------------------------------------------------------
# 5. Conferma esplicita e applicazione
# ---------------------------------------------------------------------------
Write-Host "`nATTENZIONE: si sta per scrivere configurazione reale su switch di produzione." -ForegroundColor Red
Write-Host "Digitare CONFERMA (maiuscolo) per procedere, qualunque altro input annulla." -ForegroundColor Red
$confirmation = Read-Host "Conferma"
if ($confirmation -ne "CONFERMA") {
    Write-Host "Annullato dall'utente. Nessuna modifica inviata." -ForegroundColor Yellow
    exit 0
}

$applyLog = New-Object System.Collections.Generic.List[object]
foreach ($item in $toChange) {
    $body = @{
        portNum     = $item.PortNum
        enabled     = $true
        trunk       = $item.TargetTrunk
        portVid     = $item.TargetVid
        allowedVLAN = $item.AllowedVLAN
        pseEnabled  = $item.PseEnabled
    }
    Write-Host "Scrivo $($item.SwitchModel) porta $($item.PortNum) ($($item.Label))..." -ForegroundColor Cyan
    $resp = Invoke-NebulaPostPortSettings -SiteId $item.SiteId -DevId $item.DevId -Body $body

    # Verifica post-scrittura: rilettura della porta, non ci si fida di un 200 OK da
    # solo. Scoperto il 16/07/2026 che l'API puo' rifiutare valori non ovvi (422 su
    # allowedVLAN vuoto) E che un 200 OK non garantisce che il cloud Nebula abbia gia'
    # spinto la modifica sullo switch fisico (coerente con l'intermittenza nota
    # cloud<->switch di NEB-001): una rilettura immediata puo' mostrare ancora lo stato
    # vecchio. Fino a 4 tentativi con attesa crescente prima di dichiarare fallimento.
    $verifyPort = $null
    $verified = $false
    $delays = @(3, 5, 8, 12)
    for ($attempt = 0; $attempt -lt $delays.Count; $attempt++) {
        Start-Sleep -Seconds $delays[$attempt]
        $verifyPorts = Get-NebulaArrayValue (Invoke-NebulaGet "/$($item.SiteId)/sw/$($item.DevId)/port-settings")
        $verifyPort = $verifyPorts | Where-Object { $_.portNum -eq $item.PortNum } | Select-Object -First 1
        $verified = $verifyPort -and ($verifyPort.portVid -eq $item.TargetVid)
        if ($verified) { break }
        Write-Host "  Non ancora propagato dopo $($delays[$attempt])s (tentativo $($attempt+1)/$($delays.Count)), riprovo..." -ForegroundColor DarkGray
    }
    if ($verified) {
        Write-Host "  Verificato: portVid ora $($verifyPort.portVid), allowedVLAN $($verifyPort.allowedVLAN -join ',')." -ForegroundColor Green
    } else {
        Write-Warning "  Verifica fallita anche dopo piu' tentativi: la porta non riflette il target atteso (portVid letto: $($verifyPort.portVid))."
    }

    $pcResult = $null
    if ($PowerCycle -and $item.Kind -eq 'access-port' -and $verified) {
        Write-Host "  Power-cycle: spengo il PoE della porta $($item.PortNum)..." -ForegroundColor Cyan
        $offBody = @{ portNum = $item.PortNum; enabled = $true; trunk = $item.TargetTrunk; portVid = $item.TargetVid; allowedVLAN = $item.AllowedVLAN; pseEnabled = $false }
        Invoke-NebulaPostPortSettings -SiteId $item.SiteId -DevId $item.DevId -Body $offBody | Out-Null
        Write-Host "  Attendo 10 secondi a corrente staccata..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 10
        Write-Host "  Riaccendo il PoE..." -ForegroundColor Cyan
        $onBody = @{ portNum = $item.PortNum; enabled = $true; trunk = $item.TargetTrunk; portVid = $item.TargetVid; allowedVLAN = $item.AllowedVLAN; pseEnabled = $true }
        $pcResp = Invoke-NebulaPostPortSettings -SiteId $item.SiteId -DevId $item.DevId -Body $onBody
        $pcVerify = Get-NebulaArrayValue (Invoke-NebulaGet "/$($item.SiteId)/sw/$($item.DevId)/port-settings")
        $pcPort = $pcVerify | Where-Object { $_.portNum -eq $item.PortNum } | Select-Object -First 1
        $pcResult = [PSCustomObject]@{ PseReEnabled = ($null -ne $pcResp) -and $pcPort.pseEnabled; PortAfter = $pcPort }
        Write-Host "  PoE riacceso, portVid ancora $($pcPort.portVid). L'AP sta riavviando: attendere qualche minuto prima di controllare l'SSID (i vecchi Ubiquiti impiegano tempo a fare boot)." -ForegroundColor Yellow
    }

    $applyLog.Add([PSCustomObject]@{ Target = $item; RequestBody = $body; Response = $resp; Success = ($null -ne $resp); Verified = $verified; VerifiedState = $verifyPort; PowerCycle = $pcResult })
}

$logPath = Join-Path $OutputDir "nebula-apply-log-fase-a.json"
$applyLog | ConvertTo-Json -Depth 10 | Out-File -FilePath $logPath -Encoding utf8
Write-Host "`nLog di applicazione: $logPath" -ForegroundColor Green

$failures = @($applyLog | Where-Object { -not $_.Success -or -not $_.Verified })
if ($failures.Count -gt 0) {
    Write-Warning "$($failures.Count) scrittura/e fallite o non verificate. Vedi il log per il dettaglio. Verificare lo stato reale delle porte prima di considerare la fase chiusa."
} else {
    Write-Host "Tutte le scritture completate e verificate via rilettura API. Verificare comunque la connettivita' reale degli AP prima di chiudere M13a." -ForegroundColor Green
}
