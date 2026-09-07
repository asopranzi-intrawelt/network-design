<#
.SYNOPSIS
    Rinfresca le fonti vive di classe B senza mai sovrascrivere una misura buona con una
    peggiore. Attua ADR-026, ed e' pensato per girare da un'attivita' pianificata.

.DESCRIPTION
    PERCHE' ESISTE. Fino al 04/09/2026 gli snapshot si rinfrescavano a mano, e la
    conseguenza misurata e' che l'allineamento dipendeva da chi si ricordava: lo
    snapshot Nebula aveva undici giorni contro una cadenza settimanale, e nessuno lo
    sapeva perche' nessuno lo diceva. ADR-026 sposta il rinfresco su un'attivita'
    pianificata e lascia all'avvio di sessione la sola verifica, che legge file gia' sul
    disco e non usa credenziali.

    LE TRE GUARDIE, e sono la ragione per cui questo script esiste invece di mettere i
    due comandi dentro un'attivita' pianificata.

    La prima. La misura buona non si sovrascrive mai. `Get-NebulaSnapshot.ps1` scrive di
    suo sia la copia datata sia il puntatore `nebula-snapshot.json`, e lo fa comunque,
    anche quando la risposta e' povera: il 05/08/2026, con l'organizzazione declassata a
    Base Pack, ha prodotto un file di poche centinaia di byte con zero siti, che avrebbe
    cancellato l'ultima misura completa se fosse stato promosso. Qui il rinfresco scrive
    prima in una cartella temporanea, il risultato viene validato, e solo a validazione
    riuscita diventa la misura corrente. Nessuno script a valle e' stato modificato.

    La seconda. Un rinfresco fallito e' un evento rumoroso e non un salto silenzioso: si
    scrive un file di segnalazione in `output/`, che `Test-Allineamento.py` legge e
    riporta in rosso al primo avvio di sessione utile. Un'automazione che fallisce in
    silenzio e' peggio dell'assenza di automazione, perche' produce fiducia mal riposta.

    La terza. Le credenziali restano dove ADR-021 le mette, cioe' nel blocco `env` di
    `.claude/settings.local.json`, e questo script le legge da li' per passarle ai
    processi figli. Non ne crea una seconda copia in una variabile d'ambiente di utente,
    non le scrive su disco e non le stampa mai, nemmeno troncate: un segreto in piu' e'
    una superficie in piu' (SEC-024).

    PERIMETRO. Nebula e Proxmox, che sono le due fonti le cui credenziali di sola lettura
    vivono nel blocco `env`. La gestione endpoint resta **fuori** e resta manuale: le sue
    credenziali appartengono al provider MSP (ADR-017), non stanno in questo repository, e
    automatizzare una chiamata autenticata con credenziali di terzi e' una decisione che
    non spetta a questo progetto.

.PARAMETER Fonte
    nebula, proxmox oppure tutte (predefinito).

.PARAMETER DryRun
    Esegue le chiamate e la validazione ma non promuove nulla: serve a provare
    l'attivita' pianificata senza toccare la misura corrente.

.EXAMPLE
    .\scripts\Invoke-RefreshFonti.ps1
    .\scripts\Invoke-RefreshFonti.ps1 -Fonte nebula -DryRun
#>

param(
    [ValidateSet('nebula', 'proxmox', 'tutte')]
    [string]$Fonte = 'tutte',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$radice     = Split-Path -Parent $PSScriptRoot
$cartellaOut = Join-Path $radice 'output'
# Join-Path annidato e non una stringa con separatore: su Linux la barra rovesciata e'
# un carattere valido in un nome di file, quindi '.claude\settings.local.json' non e' un
# percorso di due livelli ma un nome unico bizzarro, e lo script cerca un file che non
# esistera' mai. Il guasto si manifesta solo fuori da Windows, cioe' quando nessuno lo sta
# guardando.
$impostazioni = Join-Path (Join-Path $radice '.claude') 'settings.local.json'
$registro   = Join-Path $cartellaOut 'refresh-log.txt'
$stampo     = Get-Date -Format 'yyyyMMdd-HHmmss'

if (-not (Test-Path $cartellaOut)) { New-Item -ItemType Directory -Path $cartellaOut | Out-Null }

function Scrivi-Registro([string]$testo) {
    $riga = "{0}  {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $testo
    Add-Content -LiteralPath $registro -Value $riga -Encoding UTF8
    Write-Host $riga
}

function Segnala-Fallimento([string]$fonte, [string]$motivo) {
    $marcatore = Join-Path $cartellaOut ".refresh-fallito-$fonte.txt"
    @(
        "Rinfresco della fonte '$fonte' FALLITO."
        "Quando:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        "Motivo:  $motivo"
        ""
        "La misura precedente NON e' stata toccata: cio' che sta in output/ e' l'ultima buona,"
        "e la sua eta' e' quella che Test-Allineamento.py riporta nella sezione della freschezza."
        "Questo file viene rimosso da solo al primo rinfresco riuscito della stessa fonte."
    ) | Set-Content -LiteralPath $marcatore -Encoding UTF8
    Scrivi-Registro "FALLITO  $fonte  $motivo"
}

function Pulisci-Fallimento([string]$fonte) {
    $marcatore = Join-Path $cartellaOut ".refresh-fallito-$fonte.txt"
    if (Test-Path $marcatore) { Remove-Item -LiteralPath $marcatore -Force }
}

# --- Credenziali dal blocco env, senza copie e senza stamparle mai -----------
if (-not (Test-Path $impostazioni)) {
    Segnala-Fallimento 'configurazione' "manca $impostazioni, quindi non ci sono credenziali da usare"
    exit 2
}
$env_ = (Get-Content -LiteralPath $impostazioni -Raw -Encoding UTF8 | ConvertFrom-Json).env
if (-not $env_) {
    Segnala-Fallimento 'configurazione' "il file delle impostazioni non ha un blocco env"
    exit 2
}

# --- Validatori: il criterio viene dal fallimento reale del 05/08/2026 -------
function Test-SnapshotNebula([string]$percorso) {
    if (-not (Test-Path $percorso)) { return "il file non e' stato prodotto" }
    try { $d = Get-Content -LiteralPath $percorso -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { return "JSON non interpretabile" }
    if (-not $d.organizations) { return "nessuna organizzazione nella risposta" }
    $dispositivi = 0
    foreach ($o in $d.organizations) {
        foreach ($s in @($o.sites)) { $dispositivi += @($s.devices).Count }
        $dispositivi += @($o.unassigned_devices).Count
    }
    # Il 05/08/2026, con l'organizzazione declassata, la risposta aveva zero siti e zero
    # dispositivi pur essendo un JSON valido: e' precisamente questo il caso da fermare.
    if ($dispositivi -lt 1) { return "risposta povera: zero dispositivi, verosimilmente autorizzazione degradata" }
    return $null
}

function Test-SnapshotProxmox([string]$percorso) {
    if (-not (Test-Path $percorso)) { return "il file non e' stato prodotto" }
    try { $d = Get-Content -LiteralPath $percorso -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { return "JSON non interpretabile" }
    if (@($d.resources).Count -lt 1) { return "nessuna risorsa nella risposta" }
    if (@($d.nodes).Count -lt 1)     { return "nessun nodo nella risposta" }
    return $null
}

# --- Il rinfresco di una fonte ----------------------------------------------
function Rinfresca([string]$nome, [scriptblock]$chiamata, [string]$fileMisura, [scriptblock]$validatore) {
    $temporanea = Join-Path $cartellaOut ".refresh-tmp-$nome"
    if (Test-Path $temporanea) { Remove-Item -LiteralPath $temporanea -Recurse -Force }
    New-Item -ItemType Directory -Path $temporanea | Out-Null
    try {
        Scrivi-Registro "avvio    $nome"
        & $chiamata $temporanea 2>&1 | Out-Null
        $prodotto = Join-Path $temporanea $fileMisura
        $problema = & $validatore $prodotto
        if ($problema) {
            Segnala-Fallimento $nome $problema
            return $false
        }
        if ($DryRun) {
            Scrivi-Registro "PROVA    $nome  misura valida, non promossa (-DryRun)"
            return $true
        }
        # Promozione: prima la copia datata, poi il puntatore alla misura corrente.
        # L'ordine conta: se il processo morisse fra le due, resterebbe una copia datata
        # in piu' e la misura corrente vecchia, che e' il modo giusto di rompersi.
        Copy-Item -LiteralPath $prodotto -Destination (Join-Path $cartellaOut ("{0}-{1}.json" -f $nome, $stampo)) -Force
        foreach ($f in Get-ChildItem -LiteralPath $temporanea -File) {
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $cartellaOut $f.Name) -Force
        }
        Pulisci-Fallimento $nome
        Scrivi-Registro "OK       $nome  misura promossa"
        return $true
    }
    catch {
        Segnala-Fallimento $nome ("eccezione durante la chiamata: " + $_.Exception.Message)
        return $false
    }
    finally {
        if (Test-Path $temporanea) { Remove-Item -LiteralPath $temporanea -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

$esiti = @{}

if ($Fonte -in @('nebula', 'tutte')) {
    if (-not $env_.NEBULA_API_KEY) {
        Segnala-Fallimento 'nebula' "manca NEBULA_API_KEY nel blocco env"
        $esiti['nebula'] = $false
    }
    else {
        $esiti['nebula'] = Rinfresca 'nebula' {
            param($dir)
            & (Join-Path $PSScriptRoot 'Get-NebulaSnapshot.ps1') -ApiKey $env_.NEBULA_API_KEY -OutputDir $dir
        } 'nebula-snapshot.json' { param($p) Test-SnapshotNebula $p }
    }
}

if ($Fonte -in @('proxmox', 'tutte')) {
    $mancanti = @('PROXMOX_TOKEN_NAME', 'PROXMOX_TOKEN_VALUE', 'PROXMOX_URL') | Where-Object { -not $env_.$_ }
    if ($mancanti) {
        Segnala-Fallimento 'proxmox' ("mancano nel blocco env: " + ($mancanti -join ', '))
        $esiti['proxmox'] = $false
    }
    else {
        # L'indirizzo reale non sta in nessun file tracciato (repo pubblico): si ricava
        # dall'URL gia' presente nel blocco env, che non e' versionato.
        $indirizzo = ([uri]$env_.PROXMOX_URL).Host
        $porta = ([uri]$env_.PROXMOX_URL).Port
        if ($porta -le 0) { $porta = 8006 }
        $esiti['proxmox'] = Rinfresca 'proxmox' {
            param($dir)
            $env:PROXMOX_TOKEN_NAME  = $env_.PROXMOX_TOKEN_NAME
            $env:PROXMOX_TOKEN_VALUE = $env_.PROXMOX_TOKEN_VALUE
            try {
                & (Join-Path $PSScriptRoot 'Get-ProxmoxSnapshot.ps1') -ProxmoxHost $indirizzo -Port $porta -OutputDir $dir
            }
            finally {
                Remove-Item Env:\PROXMOX_TOKEN_NAME  -ErrorAction SilentlyContinue
                Remove-Item Env:\PROXMOX_TOKEN_VALUE -ErrorAction SilentlyContinue
            }
        } 'proxmox-snapshot.json' { param($p) Test-SnapshotProxmox $p }
    }
}

$falliti = @($esiti.GetEnumerator() | Where-Object { -not $_.Value })
if ($falliti.Count -gt 0) {
    Scrivi-Registro ("esito    {0} fonti su {1} fallite: {2}" -f $falliti.Count, $esiti.Count, (($falliti | ForEach-Object { $_.Key }) -join ', '))
    exit 1
}
Scrivi-Registro ("esito    tutte le {0} fonti rinfrescate" -f $esiti.Count)
exit 0
