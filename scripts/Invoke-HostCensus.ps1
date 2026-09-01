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
    [string] $OutputDir,
    [string] $Script = 'censimento-host.sh',
    [string] $Prefisso = 'censimento',
    [string] $Argomenti = ''
)

$ErrorActionPreference = 'Continue'
$radice = Split-Path -Parent $PSScriptRoot
# Lo script da eseguire e' un parametro e non un valore fisso: la stessa meccanica
# di copia ed esecuzione serve a qualunque ricognizione di sola lettura, e ogni volta
# che si e' provato a incollare un comando equivalente nella riga di comando esso si
# e' rotto per citazione prima di arrivare all'host.
$sh     = Join-Path $PSScriptRoot $Script
if (-not (Test-Path $sh)) { throw "Script non trovato: $sh" }
if (-not $OutputDir) { $OutputDir = Join-Path $radice 'output' }
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

$remoto = '/tmp/ricognizione.sh'
$outRem = '/tmp/ricognizione.out'
$risultati = @()

# La raggiungibilita' si verifica aprendo una connessione TCP alla porta del servizio
# SSH, non tentando un accesso con chiave. La prima versione usava `ssh -o BatchMode=yes`,
# che pero' fallisce in due casi indistinguibili fra loro: host spento e host raggiungibile
# che accetta soltanto la password. Su questa infrastruttura il secondo caso e' la regola e
# non l'eccezione, perche' la chiave della postazione e' distribuita solo su una parte
# delle macchine, quindi il controllo scartava host perfettamente funzionanti.
function Test-Raggiungibile([string] $h) {
    $hostname = $h
    if ($h -match '@') { $hostname = $h.Split('@')[-1] }
    # Un alias del ~/.ssh/config non e' un nome risolvibile: in quel caso si lascia
    # decidere a ssh, che sa espandere l'alias, e si considera l'host raggiungibile.
    if ($hostname -notmatch '^[\d.]+$' -and -not ($hostname -match '\.')) { return $true }
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $a = $c.BeginConnect($hostname, 22, $null, $null)
        $ok = $a.AsyncWaitHandle.WaitOne(4000, $false)
        if ($ok) { $c.EndConnect($a) }
        $c.Close()
        return $ok
    } catch { return $false }
}

function Test-ChiaveAccettata([string] $h) {
    & ssh -o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new $h 'true' 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Test-EsitoValido([string] $percorso) {
    if (-not (Test-Path $percorso)) { return $false }
    return ((Get-Content $percorso -Raw) -match 'fine ')  # ogni script di ricognizione termina con una riga 'fine'
}

foreach ($t in $Target) {
    Write-Host ''
    Write-Host "=== $t ===" -ForegroundColor Cyan
    $dest = Join-Path $OutputDir ("{0}-{1}.txt" -f $Prefisso, ($t -replace '[^\w.-]', '_'))

    if (-not (Test-Raggiungibile $t)) {
        Write-Warning "$t : la porta 22 non risponde. L'host e' spento, non raggiungibile in rete, oppure il servizio SSH non e' attivo."
        $risultati += [pscustomobject]@{ Host = $t; Esito = 'NON RAGGIUNTO'; Sudo = '-'; Righe = 0; Nota = 'porta 22 chiusa o host spento' }
        continue
    }

    $conChiave = Test-ChiaveAccettata $t
    if (-not $conChiave) {
        Write-Host "  la chiave della postazione non e' accettata da questo host: verra' chiesta la password di accesso piu' volte, una per ciascun passaggio (copia, esecuzione, recupero, pulizia)." -ForegroundColor DarkGray
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
        #
        # Il file di esito viene rimosso prima di essere riscritto, e non e' una
        # precauzione oziosa: su Ubuntu il parametro di kernel fs.protected_regular
        # impedisce di aprire in scrittura, dentro una cartella condivisa e con sticky
        # bit come /tmp, un file gia' esistente e di proprieta' di un altro utente, e
        # la restrizione vale anche per root. Un residuo lasciato da un'esecuzione
        # precedente fatta con un utente diverso fa quindi fallire la scrittura con un
        # errore di permessi che sembra, e non e', un problema di password.
        # Alla fine la proprieta' passa all'utente della sessione, altrimenti scp non
        # potrebbe rileggere un file creato da root con permessi restrittivi.
        # Gli argomenti dello script viaggiano fra apici singoli lato remoto: e' l'unico
        # punto in cui un valore fornito dall'utente entra nella riga di comando remota,
        # quindi viene ripulito di cio' che potrebbe chiuderli anzitempo.
        $arg = ($Argomenti -replace "[^\w.:@/ -]", '')
        $prep = "rm -f $outRem"
        $post = "chown `$SUDO_USER $outRem 2>/dev/null; chmod 600 $outRem"
        if ($conSudo) {
            Write-Host "  password di sudo di QUESTO host (non quella di Windows)" -ForegroundColor DarkGray
            $cmd = "sudo -k sh -c '$prep; sh $remoto $arg > $outRem 2>&1; $post'"
        } else {
            $cmd = "sh -c '$prep; sh $remoto $arg > $outRem 2>&1'"
        }

        & ssh -t -o ConnectTimeout=15 $t $cmd
        $rc = $LASTEXITCODE

        if ($rc -eq 0) {
            & scp -q "${t}:$outRem" $dest 2>$null
            if ($LASTEXITCODE -eq 0 -and (Test-EsitoValido $dest)) {
                $righe = (Get-Content $dest | Measure-Object -Line).Lines
                # Senza sudo il censimento e' parziale solo se l'utente della sessione non e'
                # gia' l'amministratore: su un host a cui ci si collega come root il comando
                # gira con tutti i privilegi e l'esito e' completo. Lo si riconosce dal fatto
                # che l'output contiene i nomi dei processi in ascolto, che il kernel mostra
                # soltanto a chi ha i privilegi.
                $completo = $conSudo -or ((Get-Content $dest -Raw) -match 'users:\(\("')
                if ($completo) {
                    $stato = 'ok'; $nota = if ($conSudo) { '' } else { 'senza sudo ma con utente amministratore' }
                } else {
                    $stato = 'ok parziale'; $nota = 'senza privilegi: mancano nomi dei processi e regole del kernel'
                }
                Write-Host ("  raccolte {0} righe in {1}" -f $righe, $dest) -ForegroundColor Green
                if (-not $conChiave) { $nota = ($nota + ' | accesso solo con password, chiave non distribuita').Trim(' |') }
                $risultati += [pscustomobject]@{ Host = $t; Esito = $stato; Sudo = $(if ($conSudo) { 'si' } else { 'no' }); Righe = $righe; Nota = $nota }
                $fatto = $true
                continue
            }
            Write-Warning "$t : comando eseguito ma esito non recuperabile o incompleto."
        }

        $prova++
        if ($conSudo -and $prova -lt $Tentativi) {
            Write-Host "  non riuscito. Puo' essere la password, oppure un errore del comando: se sopra compare un messaggio diverso da 'Riprovare', la password era corretta." -ForegroundColor Yellow
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
