<#
.SYNOPSIS
    Controllo periodico delle macchine virtuali dalla postazione, con notifiche di Windows.
.DESCRIPTION
    Nasce dal blocco della VM 204 (#205): per ventitre giorni la macchina e' rimasta
    ferma mentre Proxmox la dava in esecuzione, e nessun controllo guardava dentro.
    Finche' non c'e' un relay SMTP ne' il controllo di silenzio del collettore, questo
    script e' il controllo esterno: gira dalla postazione ogni 30 minuti come attivita'
    pianificata.

    Per ogni macchina indicata in configurazione controlla che risponda in SSH, che
    gli indirizzi web indicati rispondano con un codice sotto 500, se e' stata
    riavviata dall'ultimo giro (per esempio dal watchdog, #206) e se il controllo
    interno vm-health ha scritto allarmi nel journal (scripts/vm-health/).

    Regola delle notifiche, decisa il 05/10/2026 per non riempire la postazione:
    si notificano solo i cambi di stato. Un problema si notifica quando compare e
    una seconda volta quando rientra, mai mentre dura; un riavvio e un allarme nuovo
    di vm-health si notificano una volta. Tutto cio' che un giro trova va in una sola
    notifica, qualunque sia il numero di macchine. In un giorno normale non arriva
    nulla. Ogni giro resta scritto in output/vm-watch.log. Il riepilogo giornaliero
    da atop e' spento e si accende con -Riepilogo.

    Non contiene indirizzi: le macchine si indicano con gli alias del ~/.ssh/config
    della postazione, e alias e indirizzi web stanno nella configurazione privata
    _notes/vm-watch.json, ignorata da git. Stato e registro finiscono in output/.
    Non scrive nulla sulle macchine controllate.

    Esempio di _notes/vm-watch.json:
        { "targets": [ { "alias": "odoo-vm", "nome": "VM 204 convertitore",
                         "url": [ "http://<nome-del-servizio>/" ] } ] }

    Limite dichiarato: la notifica arriva solo quando la postazione e' accesa e
    l'utente ha una sessione aperta. Non sostituisce il controllo di silenzio del
    collettore (ADR-013 di D:/log-collector).
.PARAMETER Installa
    Registra l'attivita' pianificata, ogni 30 minuti e all'accesso, senza finestra.
.PARAMETER Disinstalla
    Rimuove l'attivita' pianificata.
.PARAMETER Silenzioso
    Esegue il giro senza mostrare notifiche: scrive solo nel registro. Per le prove.
.PARAMETER Riepilogo
    Aggiunge, una volta al giorno dopo le 9, il processo piu' pesante del giorno prima.
.EXAMPLE
    .\scripts\Watch-VmHealth.ps1 -Silenzioso
.EXAMPLE
    .\scripts\Watch-VmHealth.ps1 -Installa
#>
[CmdletBinding()]
param(
    [switch] $Installa,
    [switch] $Disinstalla,
    [switch] $Silenzioso,
    [switch] $Riepilogo,
    [string] $Config,
    [string] $Stato
)

$ErrorActionPreference = 'Stop'
$radice = Split-Path -Parent $PSScriptRoot
if (-not $Config) { $Config = Join-Path $radice '_notes\vm-watch.json' }
if (-not $Stato) { $Stato = Join-Path $radice 'output\vm-watch-state.json' }
$fileLog = Join-Path (Split-Path $Stato) 'vm-watch.log'
$nomeAttivita = 'Controllo VM (network-design)'
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

function Scrivi-Log([string] $testo) {
    $riga = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $testo
    Add-Content -Path $fileLog -Value $riga -Encoding UTF8
    if ($Silenzioso) { Write-Host $riga }
}

function Mostra-Notifica([string] $titolo, [string] $testo) {
    Scrivi-Log "NOTIFICA $titolo | $($testo -replace "`n", ' / ')"
    if ($Silenzioso) { return }
    [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
    $nodi = $xml.GetElementsByTagName('text')
    [void]$nodi.Item(0).AppendChild($xml.CreateTextNode($titolo))
    [void]$nodi.Item(1).AppendChild($xml.CreateTextNode($testo))
    $notifica = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($notifica)
}

function Invoca-Ssh([string] $alias, [string] $comando) {
    # In Windows PowerShell 5.1 lo stderr di un eseguibile, con Stop, diventa
    # un'eccezione anche se scartato: una VM irraggiungibile fermerebbe lo script
    # invece di essere segnalata
    $ErrorActionPreference = 'Continue'
    $out = & ssh.exe -o BatchMode=yes -o ConnectTimeout=10 $alias $comando 2>$null
    return [pscustomobject]@{ Ok = ($LASTEXITCODE -eq 0); Testo = ($out -join "`n") }
}

if ($Installa) {
    # conhost --headless evita la finestra che -WindowStyle Hidden lascia lampeggiare
    $argomenti = '--headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $PSCommandPath
    $azione = New-ScheduledTaskAction -Execute 'conhost.exe' -Argument $argomenti
    $ripetuto = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 30)
    $accesso = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $impostazioni = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName $nomeAttivita -Action $azione -Trigger $ripetuto, $accesso -Settings $impostazioni -Description 'Controlla le VM di _notes/vm-watch.json e notifica solo i cambi di stato (scripts/Watch-VmHealth.ps1)' -Force | Out-Null
    Write-Host "Attivita' '$nomeAttivita' registrata: ogni 30 minuti e all'accesso."
    return
}
if ($Disinstalla) {
    Unregister-ScheduledTask -TaskName $nomeAttivita -Confirm:$false
    Write-Host "Attivita' '$nomeAttivita' rimossa."
    return
}

if (-not (Test-Path $Config)) { throw "Configurazione assente: $Config (esempio nell'intestazione di questo script)" }
New-Item -ItemType Directory -Force -Path (Split-Path $Stato) | Out-Null
$conf = Get-Content $Config -Raw -Encoding UTF8 | ConvertFrom-Json
$memoria = @{}
if (Test-Path $Stato) {
    $letto = Get-Content $Stato -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($p in $letto.PSObject.Properties) { $memoria[$p.Name] = $p.Value }
}

$adesso = Get-Date
$epoca = [int][double]::Parse((Get-Date -Date $adesso.ToUniversalTime() -UFormat %s))
$eventi = New-Object System.Collections.Generic.List[string]
$nuovaMemoria = [ordered]@{}

foreach ($vm in $conf.targets) {
    $alias = $vm.alias
    $nome = if ($vm.nome) { $vm.nome } else { $alias }
    $prima = $memoria[$alias]
    $giaAperti = @()
    if ($prima -and $prima.problemi) { $giaAperti = @($prima.problemi) }
    $avvioPrima = if ($prima) { [string]$prima.avvio } else { '' }
    $da = if ($prima -and $prima.ultimo) { [int]$prima.ultimo } else { $epoca - 1800 }
    $aperti = New-Object System.Collections.Generic.List[string]

    $r = Invoca-Ssh $alias "uptime -s; echo ---; journalctl -t vm-health --since @$da -q -o cat 2>/dev/null | grep '^ALLARME' | head -3"
    $avvio = $avvioPrima
    if (-not $r.Ok) {
        $aperti.Add('non risponde in SSH')
    } else {
        $parti = $r.Testo -split "`n---`n?", 2
        $avvio = $parti[0].Trim()
        if ($avvioPrima -and $avvio -and $avvio -ne $avvioPrima) {
            $eventi.Add("${nome}: riavviata alle $avvio (watchdog o riavvio manuale)")
        }
        if ($parti.Count -gt 1 -and $parti[1].Trim()) {
            foreach ($riga in ($parti[1].Trim() -split "`n")) { $eventi.Add("${nome}: $($riga -replace '^ALLARME [^:]*: ', '')") }
        }
    }

    foreach ($url in @($vm.url)) {
        if (-not $url) { continue }
        try {
            $codice = [int](Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10).StatusCode
        } catch {
            $codice = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        }
        if ($codice -eq 0 -or $codice -ge 500) { $aperti.Add("$url non risponde") }
    }

    foreach ($p in $aperti) { if ($giaAperti -notcontains $p) { $eventi.Add("${nome}: $p") } }
    foreach ($p in $giaAperti) { if (-not $aperti.Contains($p)) { $eventi.Add("${nome}: rientrato, $p") } }
    $esito = if ($aperti.Count) { 'problemi aperti: ' + ($aperti -join '; ') } else { 'ok' }
    Scrivi-Log "$nome $esito"

    $ultimoRiepilogo = if ($prima) { [string]$prima.riepilogo } else { '' }
    $oggi = $adesso.ToString('yyyy-MM-dd')
    if ($Riepilogo -and $r.Ok -and $adesso.Hour -ge 9 -and $ultimoRiepilogo -ne $oggi) {
        $ieri = $adesso.AddDays(-1).ToString('yyyyMMdd')
        $a = Invoca-Ssh $alias "atopsar -r /var/log/atop/atop_$ieri -O 2>/dev/null"
        $picco = $null
        foreach ($riga in ($a.Testo -split "`n")) {
            if ($riga -match '^(\d\d:\d\d:\d\d)\s+\d+\s+(\S+)\s+(\d+)%' -and (-not $picco -or [int]$Matches[3] -gt $picco[2])) {
                $picco = @($Matches[1], $Matches[2], [int]$Matches[3])
            }
        }
        if ($picco) { $eventi.Add(("{0}: ieri il processo piu' pesante e' stato {1}, {2}% di un core alle {3}" -f $nome, $picco[1], $picco[2], $picco[0])) }
        $ultimoRiepilogo = $oggi
    }

    # Gli elenchi si salvano come array di stringhe: in Windows PowerShell 5.1 una
    # hashtable annidata vuota si serializzerebbe con le sue proprieta' interne
    $nuovaMemoria[$alias] = [ordered]@{ ultimo = $epoca; avvio = $avvio; problemi = [string[]]$aperti.ToArray(); riepilogo = $ultimoRiepilogo }
}

if ($eventi.Count) {
    $titolo = if ($eventi.Count -eq 1) { 'Controllo VM' } else { "Controllo VM: $($eventi.Count) avvisi" }
    Mostra-Notifica $titolo ($eventi -join "`n")
}
$nuovaMemoria | ConvertTo-Json -Depth 5 | Set-Content -Path $Stato -Encoding UTF8
# Il codice d'uscita dell'ultimo ssh non deve far risultare fallita l'attivita'
exit 0
