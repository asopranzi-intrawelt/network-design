# Build-TimelineSvg.ps1
# Genera una timeline SVG degli interventi di rete a partire dai file Markdown
# tracciati in docs/infrastructure-timeline/ (gia' anonimizzati per il repo
# pubblico). Perimetro: dal 2024 (ingresso IT manager), solo intestazioni
# datate. Ogni evento e' classificato in un'area di competenza (skill) con
# colore categoriale validato + tag testuale (identita' mai affidata al solo
# colore). Output: solo docs/infrastructure-timeline/timeline.svg
# (versionato in questo repository).
#
# Questo script NON scrive in nessun altro repository. Il sito MkDocs dei
# progetti personali (E:\projects) e' un consumatore esterno: se vuole
# l'asset aggiornato lo legge da questo repository per conto proprio, non lo
# riceve per copia in push da qui (vedi CLAUDE.md, sezione "Confine con
# E:\projects").
#
# Deterministico: nessuna chiamata LLM. I titoli legacy con nomi reali sono
# anonimizzati a valle tramite _notes/.svg-name-replacements.txt (privato);
# un guard-rail avvisa se compare un IP privato non-placeholder.
#
# Uso:
#   .\scripts\Build-TimelineSvg.ps1

param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [int]$FromYear = 2024
)

$ErrorActionPreference = "Stop"
$tlDir = Join-Path $RepoRoot "docs\infrastructure-timeline"
$outSvg = Join-Path $tlDir "timeline.svg"

# File eventi (2023-baseline escluso: contesto ereditato, non interventi)
$files = @(
    @{ Name = "2024-infra.md";                    Year = 2024 },
    @{ Name = "2025-q1-server-vianova.md";        Year = 2025 },
    @{ Name = "2025-q2-migrazione-tim-vianova.md";Year = 2025 },
    @{ Name = "2025-q3-q4.md";                    Year = 2025 },
    @{ Name = "2025-storage-anni-vecchi.md";      Year = 2025 },
    @{ Name = "2026-switch-piano-terra.md";       Year = 2026 }
)

$mesi = @{ "gennaio"=1; "febbraio"=2; "marzo"=3; "aprile"=4; "maggio"=5; "giugno"=6;
           "luglio"=7; "agosto"=8; "settembre"=9; "ottobre"=10; "novembre"=11; "dicembre"=12 }

# Aree di competenza: ordine fisso -> slot fisso della tavolozza categoriale
# validata (dataviz, light mode). Il match usa la prima categoria che scatta.
$categorie = @(
    @{ Tag="AI";     Nome="AI e automazione";          Colore="#e87ba4"; Kw=@("intralino","scenia","ollama","rag ","n8n","qdrant","gpu","benchmark","tinker","thinking","unimc","aidapt","chroma","automazione","api odoo","export tm","power platform","app desktop","pyqt") },
    @{ Tag="SEC";    Nome="Sicurezza e compliance";    Colore="#e34948"; Kw=@("phishing","bitdefender","iso 27001","gdpr","dpa","dpia","vulnerability","pentest","proelium","onova","cve","mfa","ssl","certificat","password","crittograf","audit","questionario","nis2","breach","ransomware","csrf","sicurezza","regolamento","2fa","cybersecurity","malware","spoofing") },
    @{ Tag="TEL";    Nome="Telefonia e linee";         Colore="#4a3aa7"; Kw=@("vianova","tim:","da tim","fibercop","ftto","centralino","voip","pbx","ivr","telefon","sip-","fonia","linea","linee","ponte radio","pec","disdetta") },
    @{ Tag="RETE";   Nome="Rete e switching";          Colore="#2a78d6"; Kw=@("vlan","switch","trunk","cablaggio","dorsale","sfp","wi-fi","dhcp","dns","tagging","porte","porta ","rack","10 gbps","scan-to-folder","scanner","stampant","nebula") },
    @{ Tag="FW/VPN"; Nome="Firewall e VPN";            Colore="#1baf7a"; Kw=@("firewall","vpn","zyxel","usg","tunnel","ipsec","dmz","seeweb","allow-",'allow->') },
    @{ Tag="STOR";   Nome="Storage e backup";          Colore="#008300"; Kw=@("nas","backup","veeam","dischi","disco","raid","qnap","spazio","groupshare 2020","black-out") },
    @{ Tag="SRV";    Nome="Server e virtualizzazione"; Colore="#eda100"; Kw=@("proxmox","vm6","vm2","vm8","vm1","server","ram","ilo","hp g","hp prol","snapshot","vzdump","datacenter","partizione","hypervisor","freeze") },
    @{ Tag="SYS";    Nome="Sistemi e gestionali";      Colore="#eb6834"; Kw=@() }   # default
)

function Get-Categoria([string]$titolo) {
    $t = $titolo.ToLower()
    foreach ($c in $categorie) {
        foreach ($k in $c.Kw) { if ($t.Contains($k)) { return $c } }
    }
    return $categorie[-1]
}

function Parse-EventDate([string]$text, [int]$fallbackYear) {
    if ($text -match '(\d{1,2})/(\d{1,2})/(\d{4})') {
        return @{ Y=[int]$Matches[3]; M=[int]$Matches[2]; D=[int]$Matches[1] }
    }
    $lower = $text.ToLower()
    foreach ($m in $mesi.Keys) {
        if ($lower -match "$m[\s\-]") {
            $y = $fallbackYear
            if ($lower -match '(\d{4})') { $y = [int]$Matches[1] }
            return @{ Y=$y; M=$mesi[$m]; D=1 }
        }
    }
    if ($lower -match 'fine\s+(\d{4})') { return @{ Y=[int]$Matches[1]; M=12; D=1 } }
    if ($lower -match '(\d{4})') { return @{ Y=[int]$Matches[1]; M=1; D=1 } }
    return $null   # nessuna data: intestazione strutturale, si scarta
}

function Esc([string]$s) {
    $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
}

# --- Raccolta eventi -------------------------------------------------------
$events = @()
$seq = 0
foreach ($f in $files) {
    $path = Join-Path $tlDir $f.Name
    if (-not (Test-Path $path)) { Write-Warning "Manca $($f.Name), salto"; continue }
    foreach ($line in (Get-Content $path -Encoding UTF8)) {
        if ($line -match '^\#\#\s+(.+)$') {
            $h = $Matches[1].Trim()
            if ($h -match '^(Stato|Riepilogo|Legenda)\b') { continue }
            $d = Parse-EventDate $h $f.Year
            if ($null -eq $d) { continue }
            if ($d.Y -lt $FromYear) { continue }
            $datePart = $h; $titlePart = $h
            $sep = $null
            foreach ($cand in @(' - ', [char]0x2013 + ' ', ' ' + [char]0x2013 + ' ')) {
                $idx = $h.IndexOf($cand)
                if ($idx -gt 0 -and $idx -le 40) { $sep = $cand; break }
            }
            if ($sep) {
                $idx = $h.IndexOf($sep)
                $cand1 = $h.Substring(0, $idx).Trim()
                $isDate = ($cand1 -match '\d') -or ($mesi.Keys | Where-Object { $cand1.ToLower().Contains($_) })
                if ($isDate) {
                    $datePart  = $cand1
                    $titlePart = $h.Substring($idx + $sep.Length).Trim()
                } else { $datePart = "" }
            } elseif ($h -notmatch '\d') { $datePart = "" }
            $seq++
            $events += [pscustomobject]@{
                Year = $d.Y; Month = $d.M; Day = $d.D; Seq = $seq
                DateLabel = $datePart; Title = $titlePart
            }
        }
    }
}

$events = $events | Sort-Object Year, Month, Day, Seq

# --- Anonimizzazione dei titoli legacy ---------------------------------------
$replFile = Join-Path $RepoRoot "_notes\.svg-name-replacements.txt"
if (Test-Path $replFile) {
    $rules = Get-Content $replFile -Encoding UTF8 | Where-Object { $_ -match '==>' -and $_ -notmatch '^\s*#' }
    foreach ($e in $events) {
        foreach ($r in $rules) {
            $parts = $r -split '==>', 2
            $e.Title = $e.Title.Replace($parts[0].Trim(), $parts[1].Trim())
            $e.DateLabel = $e.DateLabel.Replace($parts[0].Trim(), $parts[1].Trim())
        }
    }
} else {
    Write-Warning "File $replFile assente: i titoli legacy possono contenere nomi reali."
}

# --- Guard-rail anonimizzazione ----------------------------------------------
$all = ($events | ForEach-Object { "$($_.DateLabel) $($_.Title)" }) -join "`n"
$leak = [regex]::Matches($all, '\b(192\.168\.\d{1,3}\.\d{1,3}|172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}|10\.(?!61\.|77\.)\d{1,3}\.\d{1,3}\.\d{1,3})\b')
if ($leak.Count -gt 0) {
    Write-Warning "POSSIBILE IP REALE nei titoli: $($leak | ForEach-Object Value | Select-Object -Unique)"
}

# --- Classificazione e conteggi ----------------------------------------------
foreach ($e in $events) { $e | Add-Member Cat (Get-Categoria "$($e.Title) $($e.DateLabel)") }
$counts = @{}
foreach ($c in $categorie) { $counts[$c.Tag] = @($events | Where-Object { $_.Cat.Tag -eq $c.Tag }).Count }

# --- Layout SVG ---------------------------------------------------------------
$W = 1060; $rowH = 24; $yearH = 44; $top = 176; $bottom = 46
$maxTitle = 96
$years = $events | Select-Object -ExpandProperty Year -Unique
$H = $top + $bottom + ($events.Count * $rowH) + ($years.Count * $yearH)

$ink = "#1f2933"; $muted = "#616e7c"; $band = "#eef2f7"; $line = "#cbd2d9"; $accent = "#1f6391"

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("<svg xmlns=""http://www.w3.org/2000/svg"" width=""$W"" height=""$H"" viewBox=""0 0 $W $H"" font-family=""Segoe UI, Arial, sans-serif"">")
[void]$sb.AppendLine("<rect width=""$W"" height=""$H"" fill=""#ffffff""/>")
[void]$sb.AppendLine("<text x=""40"" y=""42"" font-size=""22"" font-weight=""700"" fill=""$ink"">Timeline interventi infrastruttura IT</text>")
$gen = Get-Date -Format "dd/MM/yyyy"
[void]$sb.AppendLine("<text x=""40"" y=""66"" font-size=""13"" fill=""$muted"">$($events.Count) interventi documentati dal $FromYear (ingresso IT manager) - contenuto anonimizzato - generato il $gen</text>")

# Legenda aree di competenza (2 righe x 4)
[void]$sb.AppendLine("<text x=""40"" y=""96"" font-size=""12"" font-weight=""700"" fill=""$ink"">AREE DI COMPETENZA</text>")
$lx = 40; $ly = 116; $i = 0
foreach ($c in $categorie) {
    $cx = $lx + (($i % 4) * 250); $cy = $ly + ([math]::Floor($i / 4) * 24)
    [void]$sb.AppendLine("<circle cx=""$cx"" cy=""$($cy-4)"" r=""5"" fill=""$($c.Colore)""/>")
    [void]$sb.AppendLine("<text x=""$($cx+12)"" y=""$cy"" font-size=""12"" fill=""$ink"">$($c.Nome) <tspan fill=""$muted"">($($counts[$c.Tag]))</tspan></text>")
    $i++
}

$y = $top
$spineX = 178
$curYear = $null
foreach ($e in $events) {
    if ($e.Year -ne $curYear) {
        $curYear = $e.Year
        $y += 10
        [void]$sb.AppendLine("<rect x=""40"" y=""$y"" width=""$($W-80)"" height=""28"" rx=""4"" fill=""$band""/>")
        [void]$sb.AppendLine("<text x=""54"" y=""$($y+19)"" font-size=""15"" font-weight=""700"" fill=""$accent"">$curYear</text>")
        $y += $yearH - 10
    }
    $t = Esc $e.Title
    if ($t.Length -gt $maxTitle) { $t = $t.Substring(0, $maxTitle - 1) + [char]0x2026 }
    $dl = Esc $e.DateLabel
    if ($dl.Length -gt 22) { $dl = $dl.Substring(0, 21) + [char]0x2026 }
    $cy = $y - 4
    [void]$sb.AppendLine("<line x1=""$spineX"" y1=""$($cy-$rowH+6)"" x2=""$spineX"" y2=""$($cy+6)"" stroke=""$line"" stroke-width=""2""/>")
    [void]$sb.AppendLine("<circle cx=""$spineX"" cy=""$cy"" r=""4.5"" fill=""$($e.Cat.Colore)""/>")
    [void]$sb.AppendLine("<text x=""$($spineX-14)"" y=""$($cy+4)"" font-size=""12"" fill=""$muted"" text-anchor=""end"">$dl</text>")
    [void]$sb.AppendLine("<text x=""$($spineX+16)"" y=""$($cy+4)"" font-size=""13"" fill=""$ink"">$t <tspan font-size=""10"" fill=""$muted"">$($e.Cat.Tag)</tspan></text>")
    $y += $rowH
}
[void]$sb.AppendLine("<text x=""40"" y=""$($H-16)"" font-size=""11"" fill=""$muted"">Fonte: repository network-design (github.com/asopranzi-intrawelt/network-design), docs/infrastructure-timeline/*.md</text>")
[void]$sb.AppendLine("</svg>")

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($outSvg, $sb.ToString(), $enc)
Write-Output "SVG: $outSvg ($($events.Count) eventi dal $FromYear, $H px)"
Write-Output ("Aree: " + (($categorie | ForEach-Object { "$($_.Tag)=$($counts[$_.Tag])" }) -join " "))
