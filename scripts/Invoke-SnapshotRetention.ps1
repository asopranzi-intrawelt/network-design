<#
.SYNOPSIS
    Pianifica la retention delle sole copie JSON datate di Proxmox e Nebula.
.DESCRIPTION
    Default: anteprima senza cancellazioni. -Apply elimina solo i candidati verificati.
    -EnableScheduled abilita la stessa politica per i futuri rinfreschi riusciti.
    La politica privata abilita la pulizia soltanto con gli stessi parametri salvati.
    Alias correnti, ultima copia per famiglia, pin e riferimenti versionabili sono protetti.
#>
[CmdletBinding(DefaultParameterSetName='Plan')]
param(
    [Parameter(ParameterSetName='Apply')][switch]$Apply,
    [Parameter(ParameterSetName='Enable')][switch]$EnableScheduled,
    [Parameter(ParameterSetName='Scheduled')][switch]$Scheduled,
    [string]$OutputDir,
    [string]$PinsPath,
    [ValidateRange(1,3650)][int]$KeepDays=90,
    [ValidateRange(1,1099511627776)][long]$WarningBytes=536870912,
    [datetime]$AsOf=(Get-Date)
)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path -Parent $PSScriptRoot
if (-not $OutputDir) { $OutputDir=Join-Path $repoRoot 'output' }
if (-not $PinsPath) { $PinsPath=Join-Path $repoRoot '_notes/snapshot-retention-pins.json' }
$policyPath=Join-Path $repoRoot '_notes/snapshot-retention-policy.json'
$directory=Get-Item -LiteralPath $OutputDir
if (-not $directory.PSIsContainer -or ($directory.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Output non e una directory ordinaria.' }
$resolvedRoot=$directory.FullName.TrimEnd([IO.Path]::DirectorySeparatorChar)
if ($resolvedRoot -ieq [IO.Path]::GetPathRoot($directory.FullName).TrimEnd([IO.Path]::DirectorySeparatorChar)) { throw 'La radice del disco non e una directory output ammessa.' }
$pattern='^(proxmox|nebula|nebula-snapshot)-(\d{8})-(\d{6})\.json$'
$mode='plan'
if ($Scheduled -and (Test-Path -LiteralPath $policyPath)) {
    $policy=Get-Content -LiteralPath $policyPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($policy.version -ne 1 -or $policy.enabled -isnot [bool] -or $policy.keep_days -lt 1 -or $policy.keep_days -gt 3650 -or $policy.warning_bytes -lt 1) { throw 'Politica privata non valida.' }
    $KeepDays=[int]$policy.keep_days
    $WarningBytes=[long]$policy.warning_bytes
    $Apply=[bool]$policy.enabled
}
if ($Apply) { $mode='apply' }
if ($EnableScheduled) { $mode='enable' }
$cutoff=$AsOf.Date.AddDays(-($KeepDays-1))
$protected=@{}
$pinsHash=$null
if (Test-Path -LiteralPath $PinsPath -PathType Leaf) {
    $pinsHash=(Get-FileHash -LiteralPath $PinsPath -Algorithm SHA256).Hash
    $pins=Get-Content -LiteralPath $PinsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($pins.version -ne 1 -or $null -eq $pins.files) { throw 'Indice dei pin non valido.' }
    foreach ($pin in $pins.files) {
        if ($pin.name -notmatch $pattern -or $pin.sha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Pin non valido.' }
        $p=Join-Path $resolvedRoot $pin.name
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Evidenza protetta assente: $($pin.name)" }
        $item=Get-Item -LiteralPath $p
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash -ine $pin.sha256) { throw "Evidenza protetta cambiata: $($pin.name)" }
        $protected[$pin.name]='pin'
    }
} elseif ($Apply -or $EnableScheduled) { throw 'Indice privato dei pin assente: applicazione non consentita.' }

# Gli hash degli alias correnti vengono ricontrollati subito prima delle cancellazioni.
$aliases=@{}
foreach ($source in @('proxmox','nebula')) {
    $name=if ($source -eq 'proxmox') { 'proxmox-snapshot.json' } else { 'nebula-snapshot.json' }
    $p=Join-Path $resolvedRoot $name
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Alias corrente assente: $name" }
    $item=Get-Item -LiteralPath $p
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Alias corrente reparse point.' }
    $data=Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($null -eq $data -or $data -isnot [pscustomobject]) { throw 'Alias corrente JSON non valido.' }
    if ($source -eq 'proxmox' -and (-not $data.nodes -or -not $data.resources)) { throw 'Alias Proxmox privo di nodi/risorse.' }
    if ($source -eq 'nebula' -and -not $data.organizations) { throw 'Alias Nebula privo di organizzazioni.' }
    $aliases[$name]=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash
}

# I file pubblicabili possono gia richiamare una copia datata come evidenza.
$gitFiles=@(& git -C $repoRoot ls-files --cached --others --exclude-standard 2>&1)
if ($LASTEXITCODE -ne 0) { throw 'Impossibile enumerare i riferimenti pubblicabili.' }
foreach ($rel in $gitFiles) {
    if ([IO.Path]::GetExtension([string]$rel) -notin @('.md','.json','.yaml','.yml','.toml','.ps1','.py','.sh')) { continue }
    $path=Join-Path $repoRoot ([string]$rel)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    $text=[IO.File]::ReadAllText($path)
    foreach ($match in [regex]::Matches($text,'(?<![\w-])(?:proxmox|nebula|nebula-snapshot)-\d{8}-\d{6}\.json')) { $protected[$match.Value]='reference' }
}

$files=@()
foreach ($item in Get-ChildItem -LiteralPath $resolvedRoot -File) {
    $m=[regex]::Match($item.Name,$pattern)
    if (-not $m.Success) { continue }
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Snapshot reparse point: $($item.Name)" }
    if ($item.DirectoryName -ine $resolvedRoot -or -not $item.FullName.StartsWith($resolvedRoot+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Snapshot fuori dal perimetro.' }
    $stamp=[datetime]::ParseExact($m.Groups[2].Value+$m.Groups[3].Value,'yyyyMMddHHmmss',[Globalization.CultureInfo]::InvariantCulture)
    $hash=(Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
    $reason=$protected[$item.Name]
    if ($aliases.Values -contains $hash) { $reason='current-alias-copy' }
    $files+= [pscustomobject]@{name=$item.Name;path=$item.FullName;family=$m.Groups[1].Value;timestamp=$stamp;bytes=$item.Length;sha256=$hash;reason=$reason}
}
foreach ($family in @('proxmox','nebula','nebula-snapshot')) {
    $latest=$files | Where-Object { $_.family -eq $family } | Sort-Object timestamp -Descending | Select-Object -First 1
    if ($latest -and -not $latest.reason) { $latest.reason='latest-in-family' }
}
$candidates=@()
foreach ($f in $files) {
    if ($f.reason) { continue }
    if ($f.timestamp -ge $cutoff) { $f.reason='within-retention'; continue }
    try { $j=Get-Content -LiteralPath $f.path -Raw -Encoding UTF8 | ConvertFrom-Json; if ($null -eq $j -or $j -isnot [pscustomobject]) { throw 'JSON non oggetto' } }
    catch { $f.reason='invalid-json-preserved'; continue }
    $candidates+=$f
}

$removed=0
if ($Apply) {
    # Prima di iniziare si verifica ancora l'intero piano, poi ogni file prima di rimuoverlo.
    if ($pinsHash -ne (Get-FileHash -LiteralPath $PinsPath -Algorithm SHA256).Hash) { throw 'Indice dei pin cambiato durante la lettura.' }
    foreach ($name in $aliases.Keys) { if ((Get-FileHash -LiteralPath (Join-Path $resolvedRoot $name) -Algorithm SHA256).Hash -ne $aliases[$name]) { throw 'Alias cambiato durante la lettura.' } }
    foreach ($f in $candidates) { if ((Get-FileHash -LiteralPath $f.path -Algorithm SHA256).Hash -ne $f.sha256) { throw 'Candidato cambiato durante la lettura.' } }
    foreach ($f in $candidates) {
        $current=Get-Item -LiteralPath $f.path
        if ($current.DirectoryName -ine $resolvedRoot -or ($current.Attributes -band [IO.FileAttributes]::ReparsePoint) -or (Get-FileHash -LiteralPath $f.path -Algorithm SHA256).Hash -ne $f.sha256) { throw 'Candidato cambiato prima della cancellazione.' }
        Remove-Item -LiteralPath $f.path -Force -ErrorAction Stop
        $removed++
    }
}
if ($EnableScheduled) {
    $policyDir=Split-Path -Parent $policyPath
    if (-not (Test-Path -LiteralPath $policyDir)) { New-Item -ItemType Directory -Path $policyDir | Out-Null }
    [ordered]@{version=1;enabled=$true;keep_days=$KeepDays;warning_bytes=$WarningBytes} | ConvertTo-Json | Set-Content -LiteralPath $policyPath -Encoding UTF8
}
[long]$total=0
foreach ($f in $files) { $total+=$f.bytes }
[long]$expiredBytes=0
foreach ($f in $candidates) { $expiredBytes+=$f.bytes }
[ordered]@{mode=$mode;keep_days=$KeepDays;cutoff=$cutoff.ToString('yyyy-MM-dd');snapshot_files=$files.Count;bytes_before=$total;warning=($total -ge $WarningBytes);candidate_files=$candidates.Count;candidate_bytes=$expiredBytes;removed_files=$removed;pinned_or_referenced=@($files | Where-Object { $_.reason -in @('pin','reference') }).Count;invalid_preserved=@($files | Where-Object { $_.reason -eq 'invalid-json-preserved' }).Count;candidates=@($candidates | Select-Object name,bytes,sha256)} | ConvertTo-Json -Depth 4
