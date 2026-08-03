<#
.SYNOPSIS
    Crea sul desktop dell'utente il collegamento alla propria cartella di scansione sul NAS,
    scegliendo la forma del percorso (indirizzo o nome) che per quell'utente funziona davvero.
.DESCRIPTION
    Script di distribuzione pensato per essere eseguito dall'RMM (NinjaOne) su ciascuna
    postazione, come parte dell'intervento R8 di `docs/interventi-robustezza.md`: le
    destinazioni di scansione delle due multifunzione passano dalle cartelle condivise delle
    postazioni a sette condivisioni nascoste sul NAS, e ogni utente deve poter raggiungere la
    propria in un clic.

    PERCHE' UN COLLEGAMENTO E NON UN'UNITA' DI RETE. Un collegamento e' un file `.lnk` che
    punta a un percorso UNC: non consuma una lettera di unita', non si riconnette all'accesso,
    non compare come disco e non genera attese all'avvio quando il NAS non risponde. Su queste
    postazioni le lettere sono scarse e gia' occupate da mappature persistenti. Spiegazione
    estesa in `docs/collegamento-vs-unita-di-rete.md`.

    PERCHE' SI PROVANO DUE FORME DELLO STESSO PERCORSO. Le credenziali di Windows sono
    memorizzate **per nome di destinazione**: una credenziale salvata per il nome del NAS non
    vale per il suo indirizzo e viceversa, perche' per Windows sono due destinazioni distinte.
    Su queste postazioni la pratica e' mista, alcuni utenti hanno salvato la credenziale per il
    nome e altri per l'indirizzo (segnalato dall'IT Manager il 31/07/2026), quindi imporre una
    sola forma farebbe chiedere le credenziali a una parte degli utenti e, peggio, farebbe
    fallire il controllo di accesso di questo script facendolo sembrare un problema di
    permessi. Lo script prova percio' entrambe le forme e scrive nel collegamento quella che
    per quell'utente funziona, preferendo a parita' di esito la forma gia' usata da un
    collegamento esistente o quella per cui risulta una credenziale memorizzata: cosi' non
    alterna forma a ogni esecuzione.

    COME SI DECIDE QUALE CONDIVISIONE. Lo script non puo' indovinare a chi appartenga la
    postazione: ordine di risoluzione parametro esplicito, poi campo personalizzato del
    dispositivo sull'RMM, altrimenti si ferma. Prima di scrivere verifica che l'utente connesso
    acceda davvero alla condivisione: poiche' ogni cartella e' permessa al solo destinatario,
    una condivisione altrui risulta inaccessibile e lo script rifiuta di creare il collegamento.

    CONTESTO DI ESECUZIONE. Va eseguito **nel contesto dell'utente connesso**, non come
    sistema: il percorso del desktop dipende dall'ambiente dell'utente (puo' essere
    reindirizzato su OneDrive) e sia le credenziali memorizzate sia la verifica di accesso
    hanno senso solo con l'identita' di chi usa la macchina.

    IDEMPOTENZA. Se il collegamento punta gia' a una forma valida della cartella corretta non
    viene toccato; se punta altrove viene riscritto. Puo' girare in modo ricorrente.

    NESSUN VALORE REALE NEL FILE. Indirizzo e nome del NAS, condivisione e corrispondenza fra
    postazioni e destinatari vivono nella configurazione dell'RMM
    (`.claude/rules/anonymization.md`, repository pubblico).
.PARAMETER NasAddress
    Indirizzo del NAS che ospita le condivisioni.
.PARAMETER NasName
    Nome del NAS, se in uso sulle postazioni. Opzionale ma consigliato: e' la forma che serve
    agli utenti che hanno memorizzato la credenziale per nome.
.PARAMETER ShareName
    Condivisione del destinatario, nella forma `scansioni_<nome>`. Se omesso si legge dal campo
    personalizzato indicato da -CustomFieldName.
.PARAMETER CustomFieldName
    Campo personalizzato del dispositivo da cui leggere la condivisione. Default: 'scanShare'.
.PARAMETER PreferredForm
    Forma da preferire quando entrambe funzionano: 'Auto' (default: decide in base al
    collegamento esistente e alle credenziali memorizzate), 'Address' oppure 'Name'.
.PARAMETER ShortcutName
    Nome del collegamento sul desktop. Default: 'Scansioni'.
.PARAMETER Force
    Crea il collegamento anche se nessuna forma risulta accessibile. Disattiva la protezione
    contro l'assegnazione della cartella sbagliata: usare solo con una ragione dichiarata.
.EXAMPLE
    .\scripts\New-ScanFolderShortcut.ps1 -NasAddress 10.0.0.10 -NasName NAS -ShareName scansioni_rossi
.EXAMPLE
    .\scripts\New-ScanFolderShortcut.ps1 -NasAddress 10.0.0.10 -NasName NAS
    Forma da usare per la distribuzione unica: la condivisione arriva dal campo personalizzato.
.NOTES
    Intervento R8 di `docs/interventi-robustezza.md`; vincoli sull'RMM in ADR-017.
    Compatibile con PowerShell 5.1.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $NasAddress,
    [string] $NasName,
    [string] $ShareName,
    [string] $CustomFieldName = 'scanShare',
    [ValidateSet('Auto', 'Address', 'Name')] [string] $PreferredForm = 'Auto',
    [string] $ShortcutName = 'Scansioni',
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Result {
    param([string] $Stato, [string] $Messaggio)
    Write-Output ("{0}: {1}" -f $Stato, $Messaggio)
}

function Resolve-ShareName {
    # I messaggi diagnostici vanno su Write-Warning e non sul flusso di output: dentro una
    # funzione il flusso di output E' il valore di ritorno, e un messaggio lo contaminerebbe.
    param([string] $Explicit, [string] $FieldName)
    if ($Explicit) { return $Explicit.Trim('\') }
    $getter = Get-Command -Name 'Ninja-Property-Get' -ErrorAction SilentlyContinue
    if ($getter) {
        try {
            $raw = & $getter.Name $FieldName 2>$null
            # L'output di un comando esterno non e' una stringa affidabile: va normalizzato e
            # validato prima di finire in un percorso di rete.
            $candidati = @(@($raw) | ForEach-Object { [string] $_ } |
                ForEach-Object { $_.Trim().Trim('\') } |
                Where-Object { $_ -match '^[A-Za-z0-9._-]+$' })
            if ($candidati.Count -eq 1) { return $candidati[0] }
            if ($candidati.Count -gt 1) {
                Write-Warning ("Il campo '$FieldName' ha restituito piu' valori plausibili (" + ($candidati -join ', ') + '): ignorato, passare -ShareName.')
            } elseif ($raw) {
                Write-Warning "Il campo '$FieldName' ha restituito un valore non utilizzabile come nome di condivisione: ignorato."
            }
        } catch {
            Write-Warning "Lettura del campo '$FieldName' non riuscita: $($_.Exception.Message)"
        }
    }
    return $null
}

function Get-StoredCredentialText {
    # Elenco delle credenziali memorizzate dell'utente. Non contiene password: serve solo a
    # sapere per quale forma della destinazione esiste una credenziale salvata.
    try { return (cmdkey /list 2>$null | Out-String) } catch { return '' }
}

function Test-ShareAccess {
    param([string] $Unc)
    try { return [bool] (Test-Path -LiteralPath $Unc) } catch { return $false }
}

function Test-IsElevated {
    # Una sessione elevata ha un insieme di connessioni di rete separato da quello della
    # sessione interattiva: credenziali memorizzate e unita' mappate dell'utente non sono
    # visibili qui. E' la stessa radice dell'anomalia NAS-002 del runbook, e in questo script
    # produce un accesso negato che non ha nulla a che vedere con i permessi sulla condivisione.
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        return ([Security.Principal.WindowsPrincipal] $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Test-NameResolves {
    param([string] $Name)
    if (-not $Name) { return $false }
    try { $null = [System.Net.Dns]::GetHostAddresses($Name); return $true } catch { return $false }
}

try {
    $share = Resolve-ShareName -Explicit $ShareName -FieldName $CustomFieldName
    if (-not $share) {
        throw "Condivisione non determinata: passare -ShareName oppure valorizzare il campo personalizzato '$CustomFieldName' sul dispositivo, verificando che le automazioni possano leggerlo. Lo script non indovina il destinatario."
    }

    $elevato = Test-IsElevated
    if ($elevato) {
        Write-Warning "Sessione elevata rilevata: in questo contesto le credenziali memorizzate e le connessioni della sessione interattiva dell'utente non sono visibili, quindi la verifica di accesso alla condivisione puo' fallire pur essendo i permessi corretti. Eseguire lo script in una sessione NON elevata dell'utente."
    }

    $desktop = [Environment]::GetFolderPath('Desktop')
    if (-not $desktop -or -not (Test-Path -LiteralPath $desktop)) {
        throw "Percorso del desktop non determinabile ('$desktop'): lo script deve girare nel contesto dell'utente connesso, non come sistema."
    }
    $linkPath = Join-Path $desktop ($ShortcutName + '.lnk')

    # --- Forme candidate del percorso --------------------------------------------------
    $hostForms = @()
    $hostForms += [pscustomobject]@{ Kind = 'Address'; HostName = $NasAddress.Trim('\') }
    if ($NasName) { $hostForms += [pscustomobject]@{ Kind = 'Name'; HostName = $NasName.Trim('\') } }

    $credText = Get-StoredCredentialText
    $shell = New-Object -ComObject WScript.Shell

    $existingTarget = $null
    if (Test-Path -LiteralPath $linkPath) {
        $existingTarget = ($shell.CreateShortcut($linkPath)).TargetPath
    }

    # Punteggio di preferenza: piu' alto viene provato prima. Serve a non alternare forma a
    # ogni esecuzione e a rispettare la credenziale che l'utente ha davvero salvato.
    foreach ($f in $hostForms) {
        $unc = ('\\{0}\{1}' -f $f.HostName, $share)
        $score = 0
        if ($existingTarget -and ($existingTarget -ieq $unc)) { $score += 100 }
        if ($PreferredForm -eq $f.Kind) { $score += 50 }
        if ($credText -and ($credText -match [regex]::Escape($f.HostName))) { $score += 10 }
        if ($f.Kind -eq 'Address') { $score += 1 }   # a parita', l'indirizzo non dipende dalla risoluzione nomi
        Add-Member -InputObject $f -NotePropertyName 'Unc' -NotePropertyValue $unc -Force
        Add-Member -InputObject $f -NotePropertyName 'Score' -NotePropertyValue $score -Force
    }

    $ordered = @($hostForms | Sort-Object -Property Score -Descending)

    # --- Prova le forme in ordine ------------------------------------------------------
    $scelta = $null
    $diagnostica = @()
    foreach ($f in $ordered) {
        if ($f.Kind -eq 'Name' -and -not (Test-NameResolves -Name $f.HostName)) {
            $diagnostica += ("{0}: il nome non si risolve su questa postazione" -f $f.Unc)
            continue
        }
        if (Test-ShareAccess -Unc $f.Unc) { $scelta = $f; break }
        $conCred = ''
        if ($credText -and ($credText -match [regex]::Escape($f.HostName))) { $conCred = ', credenziale memorizzata presente' }
        $diagnostica += ("{0}: accesso non riuscito{1}" -f $f.Unc, $conCred)
    }

    if (-not $scelta) {
        $messaggio = "Nessuna forma del percorso e' accessibile per l'utente connesso. Dettaglio: " + ($diagnostica -join ' | ') + ". Cause tipiche in ordine di probabilita': la condivisione assegnata non e' di questo utente; manca una credenziale memorizzata per la destinazione provata, e le credenziali di Windows valgono per la forma esatta con cui sono state salvate; il NAS non e' raggiungibile in questo momento."
        if ($elevato) { $messaggio += " ATTENZIONE: la sessione e' elevata, ed e' la causa piu' probabile di questo esito - riprovare in una sessione non elevata dell'utente prima di cercare altrove." }
        if (-not $Force) { throw $messaggio }
        Write-Result 'AVVISO' ($messaggio + " Si procede con la prima forma perche' e' stato indicato -Force.")
        $scelta = $ordered[0]
    }

    if ($diagnostica.Count -gt 0) {
        Write-Warning ('Forme scartate prima di quella scelta: ' + ($diagnostica -join ' | '))
    }

    # --- Scrittura del collegamento ----------------------------------------------------
    if ($existingTarget) {
        if ($existingTarget -ieq $scelta.Unc) {
            Write-Result 'INVARIATO' "Il collegamento '$linkPath' punta gia' a $($scelta.Unc)."
            exit 0
        }
        # Se il collegamento esistente punta all'altra forma della stessa cartella e quella
        # forma funziona, non si riscrive: cambiarla non porterebbe beneficio e produrrebbe
        # una modifica a ogni esecuzione.
        $altraForma = @($hostForms | Where-Object { $_.Unc -ieq $existingTarget })
        if ($altraForma.Count -eq 1 -and (Test-ShareAccess -Unc $existingTarget)) {
            Write-Result 'INVARIATO' "Il collegamento punta a $existingTarget, altra forma valida della stessa cartella: lasciato invariato."
            exit 0
        }
        Write-Result 'CORREZIONE' "Il collegamento puntava a '$existingTarget': viene riscritto verso $($scelta.Unc)."
    }

    $shortcut = $shell.CreateShortcut($linkPath)
    $shortcut.TargetPath = $scelta.Unc
    $shortcut.Description = 'Cartella delle scansioni sul NAS'
    $shortcut.IconLocation = 'shell32.dll,275'
    $shortcut.Save()

    Write-Result 'CREATO' "Collegamento '$linkPath' verso $($scelta.Unc), forma $($scelta.Kind)."
    exit 0
}
catch {
    Write-Result 'ERRORE' $_.Exception.Message
    exit 1
}
