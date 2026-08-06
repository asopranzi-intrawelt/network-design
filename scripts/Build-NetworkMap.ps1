<#
.SYNOPSIS
    Genera la mappa di rete interattiva a partire dalla fonte strutturata (M26, ADR-023).
.DESCRIPTION
    Legge `data/network-topology.json`, lo valida, lo inietta nel template
    `scripts/templates/network-map.template.html` e scrive un unico file HTML
    autoconsistente in `docs/network-map.html`.

    Tre vincoli che questo script fa rispettare, e che vengono da ADR-023.

    Il file generato non si modifica mai a mano: se un dato e' sbagliato si corregge la
    fonte e si rigenera, altrimenti nasce la seconda verita' che l'impianto esiste per
    evitare. Lo script scrive l'avvertenza in testa al file.

    L'HTML e' autoconsistente: nessuna libreria esterna, nessuna richiesta di rete,
    nessun carattere scaricato. Si apre con un doppio clic, anche offline.

    La mappa eredita l'anonimizzazione. Prima di scrivere, lo script cerca nel risultato
    indirizzi che non appartengono agli intervalli di documentazione e MAC che non sono
    segnaposto, e **rifiuta di scrivere** se ne trova. E' lo stesso guard-rail di
    `Build-TimelineSvg.ps1`, con la stessa ragione: il repository e' pubblico.

.PARAMETER SourcePath
    Fonte strutturata. Predefinito: data/network-topology.json
.PARAMETER OutputPath
    File generato. Predefinito: docs/network-map.html
.PARAMETER Force
    Scrive anche se il guard-rail di anonimizzazione trova qualcosa. Da usare solo dopo
    aver guardato ogni riscontro: il valore predefinito e' rifiutare.
.EXAMPLE
    .\scripts\Build-NetworkMap.ps1
.NOTES
    Micro-step M26. Decisione di impianto in ADR-023 (.claude/memory/decisions.md).
#>

[CmdletBinding()]
param(
    [string]$SourcePath,
    [string]$TemplatePath,
    [string]$OutputPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Fail([string]$m) { Write-Error $m; exit 1 }

# Lettura difensiva di una proprieta' che puo' non esistere sull'oggetto JSON: la fonte
# dichiara solo cio' che sa, e un nodo senza alimentazione nota non ha quel campo.
function Get-Prop($obj, [string]$name) {
    if ($null -eq $obj) { return $null }
    $p = $obj.PSObject.Properties[$name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

# I percorsi si risolvono qui e non nel blocco param: con un'invocazione per percorso
# relativo $PSScriptRoot non e' sempre valorizzato quando i default vengono calcolati.
$here = $PSScriptRoot
if (-not $here) { $here = Split-Path -Parent $MyInvocation.MyCommand.Path }
$root = Split-Path -Parent $here
if (-not $SourcePath)   { $SourcePath   = Join-Path $root 'data\network-topology.json' }
if (-not $TemplatePath) { $TemplatePath = Join-Path $here 'templates\network-map.template.html' }
if (-not $OutputPath)   { $OutputPath   = Join-Path $root 'docs\network-map.html' }

if (-not (Test-Path -LiteralPath $SourcePath))   { Fail "Fonte non trovata: $SourcePath" }
if (-not (Test-Path -LiteralPath $TemplatePath)) { Fail "Template non trovato: $TemplatePath" }

# --- 1. Lettura e validazione della fonte -----------------------------------
$raw = Get-Content -Raw -LiteralPath $SourcePath
try   { $topo = $raw | ConvertFrom-Json }
catch { Fail "La fonte non e' JSON valido: $($_.Exception.Message)" }

foreach ($campo in 'meta','vlan','livelli','nodi','collegamenti','alimentazione') {
    if (-not ($topo.PSObject.Properties.Name -contains $campo)) { Fail "Campo obbligatorio mancante nella fonte: $campo" }
}

$idNodi = @{}
foreach ($n in $topo.nodi) {
    if (-not $n.id)   { Fail "Nodo senza id: $($n | ConvertTo-Json -Compress)" }
    if ($idNodi.ContainsKey($n.id)) { Fail "Id di nodo duplicato: $($n.id)" }
    $idNodi[$n.id] = $n
}
$idLivelli = @{}; foreach ($l in $topo.livelli) { $idLivelli[$l.id] = $true }
$idPwr = @{};     foreach ($p in $topo.alimentazione) { $idPwr[$p.id] = $true }

$problemi = New-Object System.Collections.Generic.List[string]

foreach ($n in $topo.nodi) {
    $lv = Get-Prop $n 'livello'
    if ($lv -and -not $idLivelli.ContainsKey($lv)) { $problemi.Add("Nodo '$($n.id)': livello sconosciuto '$lv'") }
    $al = Get-Prop $n 'alimentazione'
    if ($al -and -not $idPwr.ContainsKey($al)) { $problemi.Add("Nodo '$($n.id)': sorgente di alimentazione sconosciuta '$al'") }
    $al2 = Get-Prop $n 'alimentazione-2'
    if ($al2 -and -not $idPwr.ContainsKey($al2)) { $problemi.Add("Nodo '$($n.id)': seconda sorgente sconosciuta '$al2'") }
}
foreach ($c in $topo.collegamenti) {
    if (-not $idNodi.ContainsKey($c.da)) { $problemi.Add("Collegamento con estremo 'da' sconosciuto: '$($c.da)'") }
    if (-not $idNodi.ContainsKey($c.a))  { $problemi.Add("Collegamento con estremo 'a' sconosciuto: '$($c.a)'") }
}
foreach ($p in $topo.alimentazione) {
    $up = Get-Prop $p 'alimentato-da'
    if ($up -and -not $idPwr.ContainsKey($up)) { $problemi.Add("Sorgente '$($p.id)': monte sconosciuto '$up'") }
}

if ($problemi.Count -gt 0) {
    Write-Host "La fonte ha riferimenti che non risolvono:" -ForegroundColor Red
    $problemi | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Fail "Correggere $SourcePath e rilanciare."
}

# --- 2. Iniezione nel template ----------------------------------------------
$stamp = Get-Date -Format 'dd/MM/yyyy'
$html  = Get-Content -Raw -LiteralPath $TemplatePath

# Il JSON entra dentro un tag <script type="application/json">: l'unica sequenza che
# lo chiuderebbe in anticipo e' "</script", quindi si neutralizza quella e basta.
$jsonInline = $raw -replace '</script', '<\/script'

$html = $html.Replace('__TOPOLOGY_DATA__', $jsonInline)
$html = $html.Replace('__GENERATED_AT__', $stamp)

$avvertenza = @"
<!--
  FILE GENERATO. NON MODIFICARE A MANO.
  Fonte:      data/network-topology.json
  Generatore: scripts/Build-NetworkMap.ps1
  Decisione:  ADR-023, micro-step M26
  Generato il $stamp. Ogni modifica manuale viene persa alla prossima rigenerazione,
  e soprattutto crea una seconda verita' accanto alla fonte: correggere la fonte.
-->
"@
$html = $html -replace '(?s)^<!doctype html>', "<!doctype html>`r`n$avvertenza"

# --- 3. Guard-rail di anonimizzazione ---------------------------------------
# Indirizzi ammessi: gli intervalli di documentazione RFC 5737, i segnaposto del progetto,
# i resolver pubblici, e i numeri che indirizzi non sono (versioni, misure).
$ipTrovati = [regex]::Matches($html, '\b(?:\d{1,3}\.){3}\d{1,3}\b') |
    ForEach-Object { $_.Value } | Sort-Object -Unique
$ipAmmessi = @('8.8.8.8','8.8.4.4','0.0.0.0','127.0.0.1','255.255.255.0','255.255.224.0')
$ipSospetti = $ipTrovati | Where-Object {
    $ip = $_
    ($ipAmmessi -notcontains $ip) -and
    -not ($ip -like '203.0.113.*' -or $ip -like '198.51.100.*' -or $ip -like '192.0.2.*' -or $ip -like '10.61.*' -or $ip -like '10.77.116.*')
}

$macSospetti = [regex]::Matches($html, '\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b') |
    ForEach-Object { $_.Value } | Where-Object { $_.ToUpper() -notlike 'AA:BB:CC*' -and $_.ToUpper() -notlike '00:00:5E*' } |
    Sort-Object -Unique

if (($ipSospetti.Count -gt 0 -or $macSospetti.Count -gt 0)) {
    Write-Host "Guard-rail di anonimizzazione: riscontri nel file generato." -ForegroundColor Red
    $ipSospetti  | ForEach-Object { Write-Host "  indirizzo: $_" -ForegroundColor Red }
    $macSospetti | ForEach-Object { Write-Host "  MAC:       $_" -ForegroundColor Red }
    if (-not $Force) {
        Fail "Non scrivo. Bonificare la fonte, oppure rilanciare con -Force dopo aver guardato ogni riscontro."
    }
    Write-Host "  -Force attivo: scrivo comunque." -ForegroundColor Yellow
}

# --- 4. Scrittura ------------------------------------------------------------
$outDir = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
Set-Content -LiteralPath $OutputPath -Value $html -Encoding UTF8 -NoNewline

$risolto = (Resolve-Path -LiteralPath $OutputPath).Path
$kb = [math]::Round((Get-Item -LiteralPath $risolto).Length / 1KB, 1)
$nNodi = @($topo.nodi).Count
$nColl = @($topo.collegamenti).Count
$nPwr  = @($topo.alimentazione).Count
$nGap  = @($topo.nodi | Where-Object { (Get-Prop $_ 'gap') }).Count

Write-Host "Mappa: $risolto ($kb KB)" -ForegroundColor Green
Write-Host "  $nNodi nodi, $nColl collegamenti, $nPwr sorgenti di alimentazione, $nGap nodi con difetti aperti"
Write-Host "  Autoconsistente: nessuna dipendenza esterna. Si apre con un doppio clic."
