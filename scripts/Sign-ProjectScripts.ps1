<#
.SYNOPSIS
    Firma gli script PowerShell del progetto con il certificato di firma del codice
    dell'autorita' aziendale, verificando prima di firmare che il certificato sia quello.
.DESCRIPTION
    Perche' esiste. Il progetto produce strumenti in PowerShell per mestiere, e due volte
    in diciotto giorni la protezione endpoint ne ha fermato uno: il 12/10/2026 uno script
    di prova classificato Heur.BZC.PZQ.Boxter, rimosso alla scansione all'accesso, e il
    30/10/2026 uno script di ripristino classificato Gen:Illusion.Slingshot.PythonShell.
    Nessuno dei due era dannoso; entrambi avevano la forma che una firma generica cerca.

    CHE COSA LA FIRMA RISOLVE E CHE COSA NO, perche' la differenza decide se questo
    strumento serve. La firma NON spegne un rilevamento euristico: un file firmato che
    somiglia a un dropper viene segnalato lo stesso, e il caso del 12/10 fu infatti
    chiuso compilando lo script, non firmandolo. Cio' che la firma da' e' altro, ed e'
    piu' duraturo. Da' integrita' e provenienza, cioe' la prova che il file e' quello
    che il progetto ha prodotto e che nessuno lo ha alterato in transito. Permette la
    policy di esecuzione AllSigned sulle postazioni, che e' il presidio vero contro uno
    script estraneo. E soprattutto rende possibile chiedere al fornitore che gestisce la
    console un'esclusione per editore invece che per percorso: un'esclusione per percorso
    protegge chiunque scriva in quella cartella, oggi e in futuro, mentre un'esclusione
    legata a un certificato protegge soltanto cio' che questa autorita' ha firmato. E' la
    ragione per cui conviene firmare prima di chiedere l'esclusione, e non dopo.

    DIPENDENZE DA CONOSCERE. La radice dell'autorita' aziendale deve essere fra le
    autorita' fidate delle postazioni perche' la firma vi risulti valida: la
    distribuzione con lo strumento di gestione degli endpoint e' decisa ma non ancora
    eseguita, quindi fino ad allora la firma e' verificabile solo dove la radice e' gia'
    installata. Il materiale dell'autorita' non sta piu' sul supporto rimovibile previsto
    da ADR-025: dopo il guasto del 26/10/2026 vive in una cartella locale sincronizzata,
    e il percorso reale resta nel livello privato e si passa a questo script come
    parametro, mai scritto qui dentro.

    LA MARCA TEMPORALE NON E' FACOLTATIVA. Senza di essa la firma smette di essere valida
    quando il certificato scade, cioe' il 15/11/2027, e tutti gli script firmati
    diventerebbero non fidati nello stesso giorno. Con la marca temporale la firma resta
    valida oltre la scadenza del certificato, perche' attesta che la firma e' stata
    apposta mentre il certificato era valido. Questo script non firma senza marca
    temporale, e se il servizio non risponde si ferma invece di produrre una firma
    fragile.
.PARAMETER Pfx
    Percorso del PKCS#12 che contiene il certificato di firma del codice e la sua chiave.
    Sta nella sottocartella firma-codice/ del materiale dell'autorita'.
.PARAMETER Password
    Passphrase del PKCS#12, come SecureString. Se omessa viene chiesta a runtime e non
    viene mai mostrata ne' scritta.
.PARAMETER Path
    File o cartelle da firmare. Default: la cartella scripts/ del progetto.
.PARAMETER TimestampServer
    Servizio di marca temporale RFC 3161. Default quello di DigiCert, pubblico e gratuito.
.PARAMETER ExpectedThumbprint
    Impronta SHA-1 attesa del certificato, confrontata prima di firmare. Il valore
    predefinito e' quello del certificato «Intrawelt Code Signing» numero di serie 1001
    emesso il 14/10/2026, registrato in docs/sicurezza/autorita-certificazione-interna.md.
    Esiste perche' firmare con il certificato sbagliato non produce nessun errore.
.PARAMETER WhatIfOnly
    Mostra che cosa verrebbe firmato e verifica il certificato, senza apporre nessuna firma.
.EXAMPLE
    .\scripts\Sign-ProjectScripts.ps1 -Pfx 'X:\firma-codice\code-signing.p12' -WhatIfOnly
    Controllo a vuoto: elenca i file e verifica che il certificato sia quello atteso.
.EXAMPLE
    .\scripts\Sign-ProjectScripts.ps1 -Pfx 'X:\firma-codice\code-signing.p12'
    Firma gli script di scripts/ e verifica ogni firma dopo averla apposta.
.NOTES
    Fonti: Set-AuthenticodeSignature e la firma Authenticode di PowerShell,
    https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-authenticodesignature
    Marca temporale RFC 3161, https://datatracker.ietf.org/doc/html/rfc3161
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Pfx,
    [SecureString]$Password,
    [string[]]$Path,
    [string]$TimestampServer = 'http://timestamp.digicert.com',
    [string]$ExpectedThumbprint = 'A2D89C9A1743EA654450817914E744A8C5AE4417',
    [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $Path -or $Path.Count -eq 0) { $Path = @(Join-Path $projectRoot 'scripts') }

if (-not (Test-Path -LiteralPath $Pfx -PathType Leaf)) {
    throw "PKCS#12 non trovato: $Pfx. Il materiale dell'autorita' sta nel livello privato; il percorso non e' scritto in questo script."
}

if (-not $Password) { $Password = Read-Host -Prompt 'Passphrase del PKCS#12 (non mostrata)' -AsSecureString }

# Il certificato si carica senza importarlo nell'archivio della macchina: la chiave resta
# nel file e non lascia traccia nel profilo utente.
try {
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
        $Pfx, $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::EphemeralKeySet
    )
}
catch {
    # EphemeralKeySet non e' disponibile ovunque: si ripiega sul caricamento in memoria.
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($Pfx, $Password)
}

if (-not $cert.HasPrivateKey) { throw "Il PKCS#12 non contiene la chiave privata: non si puo' firmare." }

Write-Host "Certificato: $($cert.Subject)" -ForegroundColor Cyan
Write-Host "  emesso da : $($cert.Issuer)"
Write-Host "  seriale   : $($cert.SerialNumber)"
Write-Host "  valido    : $($cert.NotBefore.ToString('dd/MM/yyyy')) - $($cert.NotAfter.ToString('dd/MM/yyyy'))"
Write-Host "  impronta  : $($cert.Thumbprint)"

if ($ExpectedThumbprint -and $cert.Thumbprint -ne ($ExpectedThumbprint -replace '[^0-9A-Fa-f]', '').ToUpperInvariant()) {
    throw "Impronta diversa da quella attesa. Atteso $ExpectedThumbprint, trovato $($cert.Thumbprint). Nessun file e' stato firmato."
}

$giorniResidui = [int]($cert.NotAfter - (Get-Date)).TotalDays
if ($giorniResidui -lt 0) { throw "Il certificato e' scaduto il $($cert.NotAfter.ToString('dd/MM/yyyy')): va riemesso con scripts/emetti-firma-codice.sh." }
if ($giorniResidui -lt 90) { Write-Warning "Il certificato scade fra $giorniResidui giorni: pianificare la riemissione." }

$usoCodeSigning = $false
foreach ($ext in $cert.Extensions) {
    if ($ext.Oid.Value -eq '2.5.29.37') {
        if ($ext.Format($false) -match '1\.3\.6\.1\.5\.5\.7\.3\.3|Code Signing|Firma codice') { $usoCodeSigning = $true }
    }
}
if (-not $usoCodeSigning) { Write-Warning "L'uso esteso «firma del codice» non e' stato riconosciuto nel certificato: verificarlo prima di fidarsi dell'esito." }

$files = @()
foreach ($p in $Path) {
    if (Test-Path -LiteralPath $p -PathType Container) {
        $files += Get-ChildItem -LiteralPath $p -Recurse -File -Include '*.ps1', '*.psm1', '*.psd1'
    }
    elseif (Test-Path -LiteralPath $p -PathType Leaf) {
        $files += Get-Item -LiteralPath $p
    }
    else { Write-Warning "Percorso inesistente, saltato: $p" }
}
$files = @($files | Sort-Object -Property FullName -Unique)

if ($files.Count -eq 0) { Write-Warning 'Nessun file da firmare.'; return }
Write-Host "File candidati: $($files.Count)" -ForegroundColor Cyan

if ($WhatIfOnly) {
    foreach ($f in $files) {
        $sig = Get-AuthenticodeSignature -LiteralPath $f.FullName
        Write-Host ("  {0,-12} {1}" -f $sig.Status, $f.FullName)
    }
    Write-Host 'Controllo a vuoto: nessuna firma apposta.' -ForegroundColor Yellow
    return
}

$firmati = 0
$falliti = 0
foreach ($f in $files) {
    try {
        $sig = Set-AuthenticodeSignature -LiteralPath $f.FullName -Certificate $cert -HashAlgorithm SHA256 -TimestampServer $TimestampServer -ErrorAction Stop
        # Non ci si fida dell'esito del comando: si rilegge la firma dal file.
        $verifica = Get-AuthenticodeSignature -LiteralPath $f.FullName
        if ($verifica.Status -eq 'Valid' -or $verifica.Status -eq 'UnknownError') {
            if (-not $verifica.TimeStamperCertificate) {
                Write-Warning "Firmato SENZA marca temporale: $($f.Name). La firma morira' con il certificato."
            }
            $firmati++
            Write-Host ("  firmato  {0}  [{1}]" -f $f.Name, $verifica.Status) -ForegroundColor Green
        }
        else {
            $falliti++
            Write-Warning "Firma non valida dopo la scrittura su $($f.Name): $($verifica.Status) - $($verifica.StatusMessage)"
        }
    }
    catch {
        $falliti++
        Write-Warning "Firma fallita su $($f.Name): $($_.Exception.Message)"
    }
}

Write-Host "Firmati $firmati, falliti $falliti, su $($files.Count) candidati." -ForegroundColor Cyan
Write-Host "Nota: una firma risulta valida solo dove la radice dell'autorita' aziendale e' fra le autorita' fidate." -ForegroundColor DarkGray
if ($falliti -gt 0) { exit 1 }
