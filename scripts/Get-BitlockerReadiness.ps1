<#
.SYNOPSIS
    Diagnostica in sola lettura del perche' BitLocker non si attiva su un endpoint.
.DESCRIPTION
    Payload da eseguire SULL'ENDPOINT tramite un'automazione NinjaOne, come Sistema.
    Non modifica nulla: legge e riporta. Nato il 07/09/2026 dopo il fallimento
    dell'attivazione su una postazione con HRESULT 0x80070002, cioe' "impossibile
    trovare il file specificato", che e' un errore generico e non dice quale file
    manchi. Le cause compatibili con quel codice sono poche e si distinguono solo
    guardando lo stato reale della macchina, che e' quello che questo script raccoglie.

    Le cinque cose che determinano l'esito, nell'ordine in cui conviene guardarle.
    L'edizione di Windows, perche' Home non espone BitLocker gestibile. Il TPM, che
    deve essere presente, abilitato e pronto: se manca, l'attivazione con protettore
    TPM non parte. Il tipo di avvio e Secure Boot, perche' su firmware legacy il
    quadro cambia. L'ambiente di ripristino WinRE, che e' la causa piu' frequente di
    questo specifico HRESULT quando la sua immagine e' assente o la partizione di
    ripristino e' stata rimossa da un ridimensionamento del disco. E infine le policy
    di gruppo sotto FVE, che possono imporre un protettore o un percorso di backup
    che sulla macchina non esiste, ed e' l'altra strada per cui un file non si trova.

    Lo script non stampa nessuna password di ripristino e non ne crea: e' diagnostica.
.EXAMPLE
    .\Get-BitlockerReadiness.ps1
.NOTES
    Codici di uscita: 0 nessun impedimento rilevato; 1 rilevato almeno un
    impedimento, elencato in coda; 2 errore nell'esecuzione della diagnostica.
#>

[CmdletBinding()]
param(
    [string] $Unita = 'C:'
)

$ErrorActionPreference = 'Continue'
$impedimenti = New-Object System.Collections.Generic.List[string]

function Riga { param([string] $Etichetta, $Valore) Write-Output ("{0,-26}: {1}" -f $Etichetta, $Valore) }

try {
    Write-Output '=== Sistema ==='
    $os = Get-CimInstance Win32_OperatingSystem
    Riga 'Edizione'        $os.Caption
    Riga 'Versione'        "$($os.Version) build $($os.BuildNumber)"
    if ($os.Caption -match 'Home') { $impedimenti.Add('Edizione Home: BitLocker gestibile non disponibile.') }

    Write-Output ''
    Write-Output '=== Firmware e avvio ==='
    $firmware = if ($env:firmware_type) { $env:firmware_type } else { (Get-CimInstance Win32_ComputerSystem).BootupState }
    Riga 'Tipo firmware'   $firmware
    try { Riga 'Secure Boot' (Confirm-SecureBootUEFI) } catch { Riga 'Secure Boot' "non determinabile ($($_.Exception.Message))" }

    Write-Output ''
    Write-Output '=== TPM ==='
    try {
        $tpm = Get-Tpm
        Riga 'Presente'    $tpm.TpmPresent
        Riga 'Pronto'      $tpm.TpmReady
        Riga 'Abilitato'   $tpm.TpmEnabled
        Riga 'Attivato'    $tpm.TpmActivated
        Riga 'Posseduto'   $tpm.TpmOwned
        if (-not $tpm.TpmPresent) { $impedimenti.Add('TPM assente: nessun protettore TPM possibile.') }
        elseif (-not $tpm.TpmReady) { $impedimenti.Add('TPM presente ma non pronto: va inizializzato dal firmware o da tpm.msc.') }
    } catch { Riga 'TPM' "non interrogabile ($($_.Exception.Message))"; $impedimenti.Add('TPM non interrogabile.') }

    Write-Output ''
    Write-Output '=== Ambiente di ripristino (WinRE) ==='
    $reagent = (& "$env:SystemRoot\System32\reagentc.exe" /info) 2>&1 | Out-String
    Write-Output $reagent.Trim()
    if ($reagent -notmatch 'Enabled|Abilitato') { $impedimenti.Add('WinRE non abilitato: causa frequente di HRESULT 0x80070002 in fase di attivazione.') }

    Write-Output ''
    Write-Output '=== Partizioni del disco di sistema ==='
    try {
        $volSys = Get-Partition | Where-Object { $_.DriveLetter -eq $Unita.TrimEnd(':') }
        $disco = $volSys.DiskNumber
        Get-Partition -DiskNumber $disco | Select-Object PartitionNumber, DriveLetter, Type, @{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}}, IsSystem, IsBoot | Format-Table -AutoSize | Out-String | Write-Output
        $ripristino = Get-Partition -DiskNumber $disco | Where-Object { $_.Type -eq 'Recovery' }
        if (-not $ripristino) { $impedimenti.Add('Nessuna partizione di ripristino sul disco di sistema.') }
    } catch { Write-Output "Layout non leggibile: $($_.Exception.Message)" }

    Write-Output ''
    Write-Output '=== Stato BitLocker ==='
    try {
        $v = Get-BitLockerVolume -MountPoint $Unita
        Riga 'Stato protezione'  $v.ProtectionStatus
        Riga 'Stato volume'      $v.VolumeStatus
        Riga 'Metodo cifratura'  $v.EncryptionMethod
        Riga 'Percentuale'       $v.EncryptionPercentage
        Riga 'Protettori'        (($v.KeyProtector | ForEach-Object { $_.KeyProtectorType }) -join ', ')
    } catch { Write-Output "Stato non leggibile: $($_.Exception.Message)" }

    Write-Output ''
    Write-Output '=== Policy di gruppo FVE ==='
    $fve = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'
    if (Test-Path $fve) {
        Get-ItemProperty -Path $fve | Select-Object -Property * -ExcludeProperty PS* | Format-List | Out-String | Write-Output
        Write-Output 'Nota: una policy che impone il backup della chiave su Active Directory su una macchina in workgroup fa fallire l''attivazione con un errore di file o oggetto non trovato.'
    } else {
        Write-Output 'Nessuna policy FVE impostata.'
    }

    Write-Output ''
    Write-Output '=== Esito ==='
    if ($impedimenti.Count -eq 0) {
        Write-Output 'Nessun impedimento rilevato dai controlli previsti.'
        exit 0
    }
    Write-Output "Impedimenti rilevati: $($impedimenti.Count)"
    $i = 1
    foreach ($x in $impedimenti) { Write-Output "  $i. $x"; $i++ }
    exit 1
}
catch {
    Write-Output "ERRORE: $($_.Exception.Message)"
    exit 2
}
