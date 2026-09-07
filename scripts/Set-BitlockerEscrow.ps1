<#
.SYNOPSIS
    Deposita in NinjaOne la password di ripristino BitLocker del volume di sistema.
.DESCRIPTION
    Payload da eseguire SULL'ENDPOINT tramite un'automazione NinjaOne, come Sistema.
    Non e' uno script da lanciare dalla postazione di lavoro: legge lo stato BitLocker
    locale, che richiede privilegi elevati, e scrive il risultato in un campo
    personalizzato del dispositivo, cosa che solo l'agente sa fare.

    Perche' esiste. Lo snapshot del 07/09/2026 ha misurato venti dispositivi su
    ventisette con il campo `bitlockerKey` valorizzato. Dei sette scoperti, l'host
    dell'hypervisor e' Linux e il campo non gli si applica, due postazioni sono in
    edizione Windows 11 Home, che non espone BitLocker gestibile ma solo la device
    encryption automatica senza deposito centralizzato della chiave, e uno e' un
    server. Restano tre postazioni Windows 11 Pro senza alcun vincolo tecnico: su
    quelle il deposito non e' mai stato eseguito, ed e' cio' che questo script chiude.

    Distinzione che questo script tiene ferma, perche' confonderla e' l'errore che ha
    generato il gap. La presenza della chiave nel campo personalizzato prova il
    DEPOSITO, non la CIFRATURA del volume: un disco puo' essere cifrato con l'escrow
    mai riuscito, e un campo valorizzato in passato puo' sopravvivere a un volume nel
    frattempo decifrato. Lo script riporta quindi sempre entrambi gli stati, e il suo
    codice di uscita distingue il caso in cui non c'e' nulla da depositare da quello
    in cui il deposito e' fallito.

    Cosa NON fa, deliberatamente. Non attiva BitLocker su un volume che non lo ha:
    cifrare il disco di una postazione in uso e' un cambiamento che va deciso e
    pianificato, non un effetto collaterale di uno script di inventario. In quel caso
    esce con codice 1 e lo dichiara.

    La password di ripristino non viene mai scritta sull'output standard, nel flusso
    di errore o in un file temporaneo: finirebbe nel registro attivita' della console,
    che e' leggibile da chiunque abbia accesso al pannello e non e' il posto dove una
    chiave di ripristino deve vivere. Viene passata soltanto alla funzione di scrittura
    del campo personalizzato.
.PARAMETER Unita
    Lettera del volume da trattare. Default 'C:', cioe' il volume di sistema.
.PARAMETER NomeCampo
    Nome del campo personalizzato NinjaOne su cui depositare. Default 'bitlockerKey',
    che e' quello gia' in uso sui venti dispositivi conformi: cambiarlo creerebbe un
    secondo deposito parallelo, che e' peggio di nessun deposito.
.PARAMETER NonCreareProtettore
    Se il volume e' cifrato ma privo di un protettore di tipo RecoveryPassword non ne
    crea uno e si limita a segnalarlo. Senza questo interruttore il protettore viene
    creato, operazione additiva che non tocca i protettori esistenti e non ricifra il
    volume, perche' senza di esso non esiste alcuna chiave da depositare.
.EXAMPLE
    .\Set-BitlockerEscrow.ps1
.EXAMPLE
    .\Set-BitlockerEscrow.ps1 -Unita 'C:' -NonCreareProtettore
.NOTES
    Codici di uscita: 0 deposito eseguito o gia' allineato; 1 niente da depositare
    (BitLocker non attivo, oppure protettore assente con -NonCreareProtettore, oppure
    edizione Windows che non espone BitLocker gestibile); 2 errore nell'esecuzione.
#>

[CmdletBinding()]
param(
    [string] $Unita = 'C:',
    [string] $NomeCampo = 'bitlockerKey',
    [switch] $NonCreareProtettore
)

$ErrorActionPreference = 'Stop'

function Scrivi-Campo {
    <#
        Scrive il valore nel campo personalizzato del dispositivo. L'agente NinjaOne
        inietta Ninja-Property-Set nella sessione dello script; fuori da quel contesto
        si ripiega sull'eseguibile a riga di comando dell'agente. Se nessuno dei due
        e' raggiungibile la funzione fallisce invece di fingere: un deposito creduto
        riuscito e mai avvenuto e' esattamente il difetto che stiamo chiudendo.
    #>
    param([string] $Nome, [string] $Valore)

    if (Get-Command -Name 'Ninja-Property-Set' -ErrorAction SilentlyContinue) {
        Ninja-Property-Set $Nome $Valore
        return 'Ninja-Property-Set'
    }

    $cli = Join-Path $env:ProgramData 'NinjaRMMAgent\ninjarmm-cli.exe'
    if (Test-Path -LiteralPath $cli) {
        $Valore | & $cli set $Nome
        if ($LASTEXITCODE -ne 0) { throw "ninjarmm-cli set ha restituito $LASTEXITCODE" }
        return 'ninjarmm-cli'
    }

    throw 'Nessun canale disponibile per scrivere il campo personalizzato: ne Ninja-Property-Set ne ninjarmm-cli.exe.'
}

try {
    if (-not (Get-Module -ListAvailable -Name BitLocker)) {
        Write-Output "ESITO: modulo BitLocker non disponibile su questa edizione di Windows ($((Get-CimInstance Win32_OperatingSystem).Caption))."
        Write-Output 'Nessun deposito possibile: e'' il caso atteso sulle edizioni Home.'
        exit 1
    }

    $volume = Get-BitLockerVolume -MountPoint $Unita

    Write-Output "Volume            : $Unita"
    Write-Output "Stato protezione  : $($volume.ProtectionStatus)"
    Write-Output "Stato volume      : $($volume.VolumeStatus)"
    Write-Output "Metodo cifratura  : $($volume.EncryptionMethod)"
    Write-Output "Percentuale       : $($volume.EncryptionPercentage)"
    Write-Output "Protettori        : $(($volume.KeyProtector | ForEach-Object { $_.KeyProtectorType }) -join ', ')"

    if ($volume.ProtectionStatus -ne 'On') {
        Write-Output 'ESITO: BitLocker non e'' attivo su questo volume. Nessuna chiave da depositare.'
        Write-Output 'L''attivazione non viene eseguita da questo script: e'' una modifica da pianificare.'
        exit 1
    }

    $recupero = @($volume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' })

    if ($recupero.Count -eq 0) {
        if ($NonCreareProtettore) {
            Write-Output 'ESITO: nessun protettore RecoveryPassword e creazione disattivata. Niente da depositare.'
            exit 1
        }
        Write-Output 'Nessun protettore RecoveryPassword presente: ne viene aggiunto uno (operazione additiva).'
        Add-BitLockerKeyProtector -MountPoint $Unita -RecoveryPasswordProtector | Out-Null
        $volume = Get-BitLockerVolume -MountPoint $Unita
        $recupero = @($volume.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' })
        if ($recupero.Count -eq 0) { throw 'Creazione del protettore RecoveryPassword non riuscita.' }
    }

    if ($recupero.Count -gt 1) {
        Write-Output "Attenzione: $($recupero.Count) protettori RecoveryPassword presenti. Viene depositato il primo; gli altri restano validi e vanno riconciliati a mano."
    }

    $canale = Scrivi-Campo -Nome $NomeCampo -Valore $recupero[0].RecoveryPassword

    Write-Output "Campo             : $NomeCampo"
    Write-Output "Canale scrittura  : $canale"
    Write-Output 'ESITO: password di ripristino depositata. Il valore non compare in questo output per costruzione.'
    exit 0
}
catch {
    Write-Output "ERRORE: $($_.Exception.Message)"
    exit 2
}
