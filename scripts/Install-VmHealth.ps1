<#
.SYNOPSIS
    Installa su una o piu' VM Linux i presidi di scripts/vm-health/: atop, controllo
    ogni 5 minuti e configurazione del watchdog interno.
.DESCRIPTION
    Copia la cartella scripts/vm-health/ in una cartella temporanea della VM, lancia
    install.sh con sudo e la rimuove. La password di sudo si digita a schermo, quindi
    va lanciato da una finestra PowerShell interattiva e non dentro una sessione che
    non ha un terminale.

    La fonte dei presidi e' questo repository: gli altri progetti, come quello del
    convertitore dei ruolini, non ne tengono una copia e rimandano qui. Il pilota e'
    la VM 204, installata il 05/10/2026 (#205-#208).

    Non tocca la configurazione della VM su Proxmox. Perche' il watchdog funzioni
    serve anche, sul nodo, il dispositivo virtuale con uno spegnimento e una
    riaccensione:
        qm set <vmid> --watchdog model=i6300esb,action=reset
    Nella stessa finestra conviene allineare il resto della roadmap di #208:
    cpu: host, balloon uguale a memory, controller virtio-scsi-single con iothread.

    Dopo la prima installazione i servizi da sorvegliare si compilano sulla VM in
    /etc/vm-health/vm-health.conf, che l'installatore non sovrascrive.
.PARAMETER Target
    Alias SSH delle VM, come nel ~/.ssh/config della postazione.
.EXAMPLE
    .\scripts\Install-VmHealth.ps1 -Target vm207
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string[]] $Target
)

$sorgente = Join-Path $PSScriptRoot 'vm-health'
foreach ($alias in $Target) {
    Write-Host "== $alias" -ForegroundColor Cyan
    & scp.exe -q -r $sorgente "${alias}:/tmp/vm-health-install"
    if ($LASTEXITCODE -ne 0) { Write-Warning "$alias : copia non riuscita, salto"; continue }
    & ssh.exe -t $alias "sudo bash /tmp/vm-health-install/install.sh; rc=`$?; rm -rf /tmp/vm-health-install; exit `$rc"
    if ($LASTEXITCODE -ne 0) { Write-Warning "$alias : installazione terminata con errore $LASTEXITCODE" }
}
