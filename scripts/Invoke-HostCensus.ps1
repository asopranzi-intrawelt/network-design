<#
.SYNOPSIS
    Censimento in sola lettura dell'esposizione su piu' host Linux (micro-step M27-7).
.DESCRIPTION
    Copia scripts/censimento-host.sh su ciascun host indicato, lo esegue come root e
    raccoglie l'esito in output/censimento-<host>.txt, piu' due riepiloghi.

    Perche' esiste un driver invece di un comando da incollare. La ragione e' di
    citazione, non di comodita': un comando con apici annidati che attraversa
    PowerShell e poi una shell remota si rompe per quoting prima ancora di poter
    essere sbagliato nel merito, e ripeterlo a mano su nove macchine sono nove
    occasioni di sbagliarne una in silenzio.

    Perche' l'output non passa per una pipeline. Il prompt della password di sudo
    viaggia sullo pseudo-terminale allocato da ssh -t: incanalarlo in Tee-Object lo
    renderebbe invisibile e il comando resterebbe in attesa di un input mai chiesto
    a schermo. Lo script scrive quindi su un file remoto e lo recupera con scp.

    Perche' tiene un registro delle password. Su questa infrastruttura le credenziali
    locali di piu' macchine si sono perse (gap #162), e il loro recupero e' un
    intervento a se' che conviene pianificare una volta sola: per farlo serve sapere
    con precisione su quali host manca la password, cosa che si scopre solo provando.
    Ogni esito viene quindi classificato e gli host da sanare finiscono in un elenco.

    Non contiene indirizzi ne' credenziali: gli host si indicano con gli alias del
    ~/.ssh/config della postazione, che non fa parte di questo repository. L'output
    contiene nomi host e indirizzi reali e finisce in output/, ignorato da git.

    Non scrive nulla sugli host, a parte due file temporanei che rimuove da se'.
.PARAMETER Target
    Alias SSH o destinazioni utente@host da interrogare.
.PARAMETER NoSudo
    Esegue senza sudo su tutti gli host, per i casi in cui l'utente e' gia' root.
.PARAMETER Tentativi
    Quante volte richiedere la password di sudo prima di proporre le alternative.
.EXAMPLE
    .\scripts\Invoke-HostCensus.ps1 -Target odoo-vm, pwmanager-vm, vm207
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string[]] $Target,
    [switch] $NoSudo,
    [int] $Tentativi = 2,
    [string] $OutputDir
)

$ErrorActionPreference = 'Continue'
$radice = Split-Path -Parent $PSScriptRoot
$sh     = Join-Path $PSScriptRoot 'censimento-host.sh'
if (-not (Test-Path $sh)) { throw "Script di censimento non trovato: $sh" }
if (-not $OutputDir) { $OutputDir = Join-Path $radice 'output' }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

$remoto = '/tmp/censimento-host.sh'
$outRem = '/tmp/censimento-host.out'
$risultati = @()

function Test-Raggiungibile([string] $h) {
    & ssh -o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new $h 'true' 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Test-EsitoValido([string] $percorso) {
    if (-not (Test-Path $percorso)) { return $false }
    return ((Get-Content $percorso -Raw) -match 'fine ')
}

foreach ($t in $Target) {
    Write-Host ''
    Write-Host "=== $t ===" -ForegroundColor Cyan
    $dest = Join-Path $OutputDir ("censimento-{0}.txt" -f ($t -replace '[^\w.-]', '_'))

    if (-not (Test-Raggiungibile $t)) {
        Write-Warning "$t : nessuna risposta su SSH con la chiave. Non e' la password di sudo: o l'host non e' raggiungibile, oppure la chiave non e' accettata."
        $risultati += [pscustomobject]@{ Host = $t; Esito = 'NON RAGGIUNTO'; Sudo = '-'; Righe = 0; Nota = 'SSH non risponde con la chiave' }
        continue
    }

    & scp -q -o ConnectTimeout=10 $sh "${t}:$remoto" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "$t : copia dello script non riuscita."
        $risultati += [pscustomobject]@{ Host = $t; Esito = 'NON RAGGIUNTO'; Sudo = '-'; Righe = 0; Nota = 'copia non riuscita' }
        continue
    }

    $conSudo = -not $NoSudo
    $prova   = 0
    $fatto   = $false

    while (-not $fatto) {
        # sudo -k scarta l'autorizzazione in cache, cosi' una password sbagliata si
        # manifesta subito. Solo l'output dello script viene rediretto su file: il
        # prompt di sudo resta a schermo e l'utente puo' digitarlo.
        if ($conSudo) {
            Write-Host "  password di sudo di QUESTO host (non quella di Windows)" -ForegroundColor DarkGray
            $cmd = "sudo -k sh -c 'sh $remoto > $outRem 2>&1'"
        } else {
            $cmd = "sh -c 'sh $remoto > $outRem 2>&1'"
        }

        & ssh -t -o ConnectTimeout=15 $t $cmd
        $rc = $LASTEXITCODE

        if ($rc -eq 0) {
            & scp -q "${t}:$outRem" $dest 2>$null
            if ($LASTEXITCODE -eq 0 -and (Test-EsitoValido $dest)) {
                $righe = (Get-Content $dest | Measure-Object -Line).Lines
                if ($conSudo) {
                    $stato = 'ok'; $nota = ''
                } else {
                    $stato = 'ok parziale'; $nota = 'senza sudo: mancano nomi dei processi e regole del kernel'
                }
                Write-Host ("  raccolte {0} righe in {1}" -f $righe, $dest) -ForegroundColor Green
                $risultati += [pscustomobject]@{ Host = $t; Esito = $stato; Sudo = $(if ($conSudo) { 'si' } else { 'no' }); Righe = $righe; Nota = $nota }
                $fatto = $true
                continue
            }
            Write-Warning "$t : comando eseguito ma esito non recuperabile o incompleto."
        }

        $prova++
        if ($conSudo -and $prova -lt $Tentativi) {
            Write-Host "  password non accettata. Riprovo." -ForegroundColor Yellow
            continue
        }

        Write-Host ''
        Write-Host "  Su $t l'esecuzione con sudo non e' riuscita." -ForegroundColor Yellow
        Write-Host "  [R] riprova la password"
        Write-Host "  [P] prosegui senza sudo, censimento parziale"
        Write-Host "  [S] salta e annota la password come da recuperare"
        $scelta = (Read-Host '  scelta').Trim().ToUpper()

        if ($scelta -eq 'R') {
            $prova = 0
        }
        elseif ($scelta -eq 'P') {
            $conSudo = $false; $prova = 0
        }
        else {
            Write-Host "  annotato: password di sudo non disponibile su $t" -ForegroundColor Yellow
            $risultati += [pscustomobject]@{ Host = $t; Esito = 'PASSWORD SUDO DA RECUPERARE'; Sudo = 'ignota'; Righe = 0; Nota = 'da sanare nell intervento sulle credenziali' }
            $fatto = $true
        }
    }

    & ssh -o BatchMode=yes -o ConnectTimeout=8 $t "rm -f $remoto $outRem" 2>$null | Out-Null
}

Write-Host ''
$risultati | Format-Table -AutoSize

$indice = Join-Path $OutputDir 'censimento-indice.txt'
$risultati | Format-Table -AutoSize | Out-String | Set-Content -Path $indice -Encoding UTF8

$dasanare = $risultati | Where-Object { $_.Esito -like 'PASSWORD*' -or $_.Esito -eq 'NON RAGGIUNTO' }
$registro = Join-Path $OutputDir 'password-da-recuperare.txt'
if ($dasanare) {
    $testo = @()
    $testo += "Host su cui le credenziali vanno recuperate o l'accesso ripristinato"
    $testo += "Prodotto da scripts/Invoke-HostCensus.ps1. Vedi gap #162 e docs/esposizione-servizi-interni.md."
    $testo += ''
    $testo += ($dasanare | Format-Table -AutoSize Host, Esito, Nota | Out-String)
    $testo | Set-Content -Path $registro -Encoding UTF8
    Write-Host "Da sanare: $($dasanare.Count) host. Elenco in $registro" -ForegroundColor Yellow
} else {
    Write-Host 'Nessun host da sanare: tutti censiti.' -ForegroundColor Green
}
Write-Host "Indice: $indice"
Write-Host "output/ e' ignorato da git: i valori reali non vanno copiati in file tracciati senza anonimizzarli." -ForegroundColor DarkGray
