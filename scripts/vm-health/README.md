# Presidi delle VM Linux: atop, controllo ogni 5 minuti, watchdog

Fonte unica dei presidi installati dentro le macchine virtuali. Nascono dal blocco della VM 204, rimasta ferma dal 12/09 al 05/10/2026 mentre Proxmox la dava `running` (#205-#208 in `docs/infrastructure-timeline/GAP-TBC.md`); la VM 204 e' il pilota, installato e collaudato il 05/10/2026. Gli altri progetti non ne tengono copia e rimandano qui. Si installano dalla postazione con `scripts/Install-VmHealth.ps1 -Target <alias>`.

## La catena degli allarmi, dal basso verso l'alto

| Livello | Pezzo | Che cosa fa | Dove finisce |
|---|---|---|---|
| Dentro la VM | watchdog | se il sistema resta bloccato per 30 secondi, Proxmox resetta la VM | agisce da solo, nessun avviso |
| Dentro la VM | `atop` | ogni 10 minuti registra quali processi usano CPU, memoria e disco, per 28 giorni | file in `/var/log/atop/`, si consulta |
| Dentro la VM | `vm-health-check` | ogni 5 minuti cerca un processo sopra l'80% di un core per 30 minuti, swap oltre 1 GiB, memoria sotto 200 MiB, OOM killer, servizi non attivi | journal della VM, tag `vm-health`; `NOTIFY_CMD` vuoto finche' non c'e' un relay SMTP |
| Postazione | `scripts/Watch-VmHealth.ps1` | ogni 30 minuti guarda da fuori SSH, siti, riavvii e allarmi di `vm-health` | una notifica di Windows per giro, solo sui cambi di stato |
| Collettore | heartbeat e controllo di silenzio | da fare in `D:/log-collector` (ADR-013) | mail, quando ci sara' il relay SMTP |

Il livello della postazione e' l'unico che oggi avvisa una persona, e lo fa solo quando la postazione e' accesa. Quello del collettore e' il controllo esterno definitivo.

## I file

`vm-health-check.py` e' il controllo; `vm-health-check.service` e `.timer` lo lanciano ogni 5 minuti; `vm-health.conf` porta soglie e servizi, generici qui e da compilare sulla macchina in `/etc/vm-health/vm-health.conf`. `60-watchdog.conf` fa alimentare a systemd il watchdog hardware ogni 15 secondi con timeout di 30. `i6300esb-watchdog.service` carica il driver del watchdog, che su Ubuntu e' in blacklist nei file `/lib/modprobe.d/blacklist_linux-*.conf`: `systemd-modules-load` rispetta la blacklist, `modprobe` per nome no. `install.sh` installa tutto ed e' idempotente.

## Come si leggono

Gli allarmi: `journalctl -t vm-health`. La cronologia dei processi: `atopsar -r /var/log/atop/atop_AAAAMMGG -c` per la CPU intervallo per intervallo, `-O` per i tre processi piu' pesanti di ogni intervallo, oppure `atop -r <file>` e i tasti `t` e `T` per muoversi nel tempo. Il watchdog: `wdctl` deve mostrare `i6300ESB timer`.

## Prerequisiti sul nodo e lezioni del pilota

Il watchdog funziona solo se la VM ha il dispositivo: `qm set <vmid> --watchdog model=i6300esb,action=reset` e uno spegnimento con riaccensione. Collaudo fatto sulla VM 204 con `echo c > /proc/sysrq-trigger`, con `kernel.panic = 0`: circa 48 secondi dal crash al nuovo avvio.

Dal pilota vengono tre correzioni di configurazione da portare sulle altre VM nella stessa finestra (#208): `cpu: host`, perche' `x86-64-v2-AES` nasconde AVX e AVX2 e rende inutilizzabile in console un desktop disegnato in software; `balloon` uguale a `memory`, perche' un minimo piu' basso lascia a Proxmox la facolta' di togliere RAM all'ospite quando il nodo supera l'80%; controller `virtio-scsi-single` con `iothread` e senza `cache=writethrough`, verificando prima che il driver `virtio_scsi` sia nel kernel o nell'initramfs dell'ospite e che il disco di sistema sia montato per UUID, e prendendo uno snapshot prima del cambio.
