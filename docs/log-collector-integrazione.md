# Collettore dei log amministrativi: integrazione con la rete

## Stato verificato il 02/10/2026

`D:/log-collector` e' un progetto separato, registrato come fonte di classe D e riconciliato al commit `64f3f78`, che vive in `data/scadenze.json`. Raccoglie gli accessi degli amministratori di sistema richiesti dal provvedimento del Garante del 27/11/2008. Procedure, comandi ed esiti stanno nei runbook del progetto sorgente (`docs/runbook-componente-1.md`, `-2.md`, `-3-proxmox.md`, `-3-firewall.md`); qui si portano solo i fatti che cambiano la rete o il presidio.

La VM **esiste ed e' in esecuzione**: VMID 210, nome `ads-collector`, misurata nello snapshot Proxmox del 02/10/2026 alle 07:30. Debian 13.7, 2 core, 2 GB di RAM fissi, firmware OVMF con Secure Boot, macchina q35, due dischi sullo storage SERVIZI: `scsi0` da 16 GB per il sistema, `scsi1` da 60 GB per i log con `backup=0`, avvio automatico per primo e protezione dalla rimozione. Rete su `vmbr0` senza tag VLAN, perche' nessun bridge e' VLAN-aware e la LAN e' piatta; indirizzo fisso `10.61.20.26/19` nella serie dei server, gateway `10.61.20.1`, verificato libero il 30/09 prima dell'assegnazione. Il guest agent e' attivo con un elenco ristretto di comandi: dall'host `qm guest exec` e' rifiutato, quindi l'amministratore di Proxmox non esegue comandi nella VM. Sulla VM e' rimasto installato un ambiente desktop, per decisione del progetto sorgente (ADR-012).

Il nome `ads-collector.int.intrawelt.com` e' scritto nel certificato TLS del collettore ma **non e' ancora registrato** nel DNS: va aggiunto sul firewall secondo M25. Fino ad allora le sorgenti inviano all'indirizzo, verificando il certificato per nome.

## Regole di rete del collettore

Il firewall locale del collettore (nftables) ammette 514/udp e 6514/tcp da tutta la LAN `10.61.0.0/19`, perche' la LAN e' unica, e SSH sulla porta 22 soltanto dalle due postazioni fisse degli amministratori non MSP, nella serie delle postazioni. Verificato il 01/10/2026: dall'host Proxmox, che non e' fra le postazioni ammesse, la porta 22 va in timeout e la 6514 risponde. IPv6 e' disattivato sull'interfaccia. L'accesso SSH e' con chiave e account personale nel gruppo `ads-admin`, root e password disattivati; la chiave dell'host e' stata confrontata dalla console Proxmox con quella accettata dalla postazione al primo collegamento.

## Sorgenti abilitate

L'**host Proxmox** invia dal 01/10/2026 in TLS sulla 6514, con verifica del certificato del collettore per nome e coda su disco se il collettore e' fermo. Sull'host sono stati installati `rsyslog` e `rsyslog-gnutls` (non presenti prima) e aggiunti `/etc/rsyslog.d/90-ads.conf` e `/etc/rsyslog.d/tls/ca.pem`. Si inoltrano solo gli accessi: login SSH, autenticazioni di `pvedaemon` e, dall'access log dell'interfaccia web, le sole richieste di login; restano fuori le chiamate periodiche dell'interfaccia e i task sulle VM. Collaudo del 02/10/2026: login web e SSH, riusciti e falliti, arrivano con utente e postazione.

Il **firewall USG FLEX** invia dal 02/10/2026 in syslog UDP sulla 514 dall'interfaccia `10.61.10.1`. Modifiche fatte sul firewall, registrate nel changelog `docs/firewall-zyxel-usg-flex-500-live.conf`: Remote Server 1 verso il collettore con le sole categorie Authenticate e System, sottocategoria System Monitoring spenta; NTP su `ntp1.inrim.it` al posto di `0.pool.ntp.org`; fuso orario passato da quello sincronizzato automaticamente sul centro degli Stati Uniti a Roma, con ora legale europea impostata a mano. Collaudo del 02/10/2026: login riuscito, fallito e logout arrivano con account e postazione, e l'ora dichiarata coincide con quella di ricezione.

## Fatti emersi sulla rete, da gestire qui

L'host Proxmox accetta il login SSH di root con password, e ha 242 pacchetti non aggiornati e il repository `pve-no-subscription` configurato due volte. Firewall e host si amministrano con account generici, `admin` e `root`: il collettore registra la postazione ma non la persona. La serie dei server usa il gateway `10.61.20.1`, mentre il DHCP delle postazioni distribuisce `10.61.10.1`: la ragione dei due gateway va chiarita. La VM 210 non e' in nessun lavoro di backup: l'esclusione del disco dei log e' voluta, ma neppure il disco di sistema ha una copia. Il resto del collettore (NAS, custodia esterna della prova, analisi) e' ancora aperto nel progetto sorgente.

## Monitoraggio delle macchine virtuali: decisione del 05/10/2026 e cose da fare

Nasce dal blocco della VM 204, rimasta irraggiungibile dal 12/09 al 05/10/2026 mentre Proxmox la dava `running` (#205, #206, #207). L'IT Manager ha deciso che il presidio riguarda **tutte** le macchine dell'hypervisor, che la VM 204 ne e' il pilota, e che il lavoro comune appartiene a `D:/log-collector`: questo progetto registra la decisione e cio' che resta da fare, il progetto sorgente lo esegue con i suoi runbook e collaudi, e alla ripresa il triage di `Test-Allineamento.py` riporta qui gli avanzamenti.

**La separazione dei flussi e' la decisione.** Il collettore custodisce la prova degli accessi degli amministratori, con file giornalieri catenati, marca temporale e copia WORM, e la sua mail va alla Direzione: gli allarmi tecnici non entrano in quei file ne' in quella mail. Ne discendono due flussi sulla stessa infrastruttura. Il primo e' quello AdS: ogni VM diventa sorgente del collettore con i soli accessi (`sshd`, `sudo`, `su`, login) in TLS sulla 6514 con coda su disco, piu' un heartbeat periodico; il controllo di silenzio `ads-silence.sh` (D6) e' cosi' anche il controllo esterno di disponibilita' che oggi manca, perche' una VM bloccata smette di inviare l'heartbeat. Il secondo e' quello tecnico: ogni VM controlla da se' le proprie risorse e spedisce gli allarmi a un destinatario tecnico. Cio' che i due flussi condividono e' il relay SMTP.

**Cose da fare, in ordine:**

1. Scegliere il relay SMTP. E' il blocco comune: senza, ne' `ads-silence.sh` ne' gli allarmi tecnici escono. In `log-collector` e' gia' registrato come bloccante (`smtp_relay`, `mail_direzione`). Con Microsoft 365 la via preferibile e' un connettore di inoltro legato all'indirizzo pubblico dell'ufficio, senza credenziali sulle VM; la decisione spetta a chi amministra il tenant.
2. In `log-collector`: aggiungere le VM come sorgenti attese, una per volta, con runbook e collaudi dei punti 3 e 7, cominciando dalla VM 204; anticipare `ads-silence.sh` con l'heartbeat delle sorgenti Linux, e valutare una cadenza piu' fitta di quella notturna, perche' un controllo al giorno trova un blocco entro ventiquattro ore e non entro minuti.
3. Sul nodo, per ogni VM: aggiungere il watchdog (`qm set <vmid> --watchdog model=i6300esb,action=reset`) e, dentro l'ospite, `RuntimeWatchdogSec`; ogni VM richiede uno spegnimento e una riaccensione, da raggruppare con altre manutenzioni. Per la VM 100, Windows, verificare prima il driver.
4. Sui lavori di backup: attivare il *fleecing* (#207) e sanare il deposito lento (#204).
5. Portare su tutte le VM Linux il controllo di risorse della VM 204, generalizzato: `atop` e il timer di `ops/vm-health/` del repository del convertitore, oggi scritti per quella macchina. La versione comune va mantenuta in un posto solo, da decidere con `log-collector`.

**Stato del pilota al 05/10/2026.** Sulla VM 204 sono installati e attivi `atop`, il controllo ogni 5 minuti con allarmi nel journal e il watchdog: dispositivo `i6300esb` con `action=reset` sul nodo, `RuntimeWatchdogSec=30s` nell'ospite, verificato con `wdctl`. Due lezioni valgono per ogni VM Ubuntu e vanno nella versione comune: i driver watchdog sono in blacklist nei file del kernel e `systemd-modules-load` la rispetta, quindi il modulo va caricato per nome con un'unita' dedicata; e un `balloon` inferiore a `memory` lascia a Proxmox la facolta' di togliere RAM all'ospite quando il nodo supera l'80% di uso, soglia vicina allo stato attuale del nodo. La VM 204 e' passata a 4 GB fissi (`memory` e `balloon` a 4096). Restano da fare la VM come sorgente del collettore, l'invio delle notifiche e il collaudo del watchdog con un blocco simulato.

## Cosa portare in questo progetto a ogni avanzamento

1. Eseguire `python scripts/Test-Allineamento.py` alla ripresa; il controllo gira anche nell'hook locale di avvio. Se segnala nuovi commit di `log-collector`, leggere il diff dal commit riconciliato a HEAD.
2. Portare in `network-design` solo i fatti che cambiano la rete o il presidio: VM e VMID, indirizzi in forma anonimizzata, porte e ACL, sorgenti abilitate, modifiche agli apparati, custodia e backup dei log, test di ricezione, allarme e ripristino. I valori operativi reali restano nel livello privato.
3. Aggiornare l'inventario Proxmox e la documentazione di rete solo dopo una misura live. Registrare gli avanzamenti pertinenti in `ISO-30` con `scripts/IsoRoadmap.py advance`; la progettazione da sola non chiude il controllo.
4. Soltanto dopo il triage aggiornare `progetti_collegati[].commit_riconciliato` e `riconciliato_il` in `data/scadenze.json`.

## Collegamento SSH Windows

Funziona dal 01/10/2026 dalla postazione dell'amministratore, con la chiave dedicata indicata esplicitamente nel comando (`ssh -i ...`). Resta da aggiungere a `C:/Users/Utente/.ssh/config` l'alias `Host ads-collector` con `HostName`, `User`, `IdentityFile`, `IdentitiesOnly yes` e `StrictHostKeyChecking yes`, e da registrare alias, utenza e prova nel registro privato `_notes/registro-credenziali.md`: per questo `ssh_windows_stato` in `data/scadenze.json` resta `da_configurare`. Il file SSH e le chiavi non sono versionati qui.
