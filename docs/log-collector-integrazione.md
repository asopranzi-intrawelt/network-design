# Collettore dei log amministrativi: integrazione con la rete

## Stato verificato il 30/09/2026

`D:/log-collector` e' un progetto separato, registrato come fonte di classe D. Il commit riconciliato e' `c7d9af6` e vive in `data/scadenze.json`. Il progetto ha versionato il primo componente per VM Debian, firewall locale, sincronizzazione oraria e TLS e ha deciso di usare due account personali di amministratori non MSP (`ADR-007` e `ADR-008` nel progetto sorgente). Il codice e la configurazione versionati non sono una distribuzione e non costituiscono una nuova fotografia della rete.

La VM `ads-collector` e' **pianificata, non presente nell'inventario Proxmox acquisito il 30/09**. VMID e nome DNS sono stati scelti nel progetto sorgente; l'indirizzo e' ancora da confermare e verificare libero, e l'eventuale VLAN server resta una decisione di rete. Nessun bridge Proxmox risulta oggi VLAN-aware e la LAN e' ancora piatta: la VM potrebbe nascere su `vmbr0` senza tag, ma la scelta va confermata con chi gestisce la rete prima della creazione. Non attribuire al collettore traffico, copertura dei log o esiti di prova finche' la VM e le sorgenti non saranno verificate dal vivo. Il riferimento di sviluppo e' `D:/log-collector/docs/handoff-sviluppo-collettore.md`; il file `config/parametri.example.yaml` elenca i parametri da compilare nel livello privato del progetto sorgente.

## Cosa portare in questo progetto a ogni avanzamento

1. Eseguire `python scripts/Test-Allineamento.py` alla ripresa; il controllo gira anche nell'hook locale di avvio. Se segnala nuovi commit di `log-collector`, leggere il diff dal commit riconciliato a HEAD. Il controllo avvisa anche quando lo snapshot Proxmox rinnovato contiene la VM prevista e lo stato SSH Windows e' ancora `da_configurare`.
2. Portare in `network-design` solo i fatti che cambiano la rete o il presidio: VM creata e VMID, VLAN/indirizzo in forma anonimizzata, porte e ACL, sorgenti abilitate, custodia e backup dei log, test di ricezione, allarme e ripristino. I valori operativi reali restano nel livello privato.
3. Aggiornare l'inventario Proxmox e la documentazione di rete solo dopo una misura live. Registrare gli avanzamenti pertinenti in `ISO-30` con `scripts/IsoRoadmap.py advance`; la progettazione da sola non chiude il controllo.
4. Soltanto dopo il triage aggiornare `progetti_collegati[].commit_riconciliato` e `riconciliato_il` in `data/scadenze.json`. Un commit nuovo non aggiorna automaticamente la topologia: il controllo segnala la differenza e obbliga alla riconciliazione esplicita.

## Collegamento SSH Windows da completare alla creazione della VM

Il nome previsto e' `ads-collector`; SSH sulla porta 22 usera' chiavi e account personali nel gruppo autorizzato, con accesso root e password disabilitati. Il vecchio account condiviso `adsadmin` e' stato escluso da ADR-008. Le due postazioni amministrative hanno indirizzo fisso, che va ammesso esplicitamente dalla regola locale del collettore. Quando la VM esiste, verificare VMID, IP o FQDN stabile, scelta della VLAN, regola di accesso dal PC Windows, utenza personale effettiva e chiave pubblica installata.

Sul PC Windows, aggiungere a `C:/Users/Utente/.ssh/config` un alias `Host ads-collector` con `HostName`, `User`, `IdentityFile`, `IdentitiesOnly yes` e `StrictHostKeyChecking yes`; usare la chiave dedicata approvata e verificare la fingerprint del server da console Proxmox prima del primo accesso. Verificare quindi `ssh ads-collector`, registrare alias, utenza e prova nel registro privato `_notes/registro-credenziali.md` e portare `ssh_windows_stato` a `configurato` in `data/scadenze.json`. Il file SSH e le chiavi non sono versionati qui. Finche' mancano destinazione e chiave host non c'e' una connessione da dichiarare funzionante.
