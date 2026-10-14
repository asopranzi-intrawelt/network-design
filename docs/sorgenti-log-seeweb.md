# Sorgenti Seeweb e raccolta dei log

## Stato comune al 14/10/2026

Questa ricognizione è parte della stessa timeline del collettore. Il dettaglio tecnico è in D:/log-collector/docs/sorgenti-log-seeweb.md; la rete conserva anche inventario reale e prove nel proprio livello privato, così la ripresa non dipende dalla chat dell'altro progetto. Il lettore delle due email è versionato e pubblicato in a5fe489 del collettore. Non è un servizio di raccolta della posta o dei login Seeweb sulla VM. La verifica SSH successiva al push era fallita; la lettura successiva di GitHub conferma il commit, impronta precedente ancora non registrata.

| ID | Punto di accesso, valori privati nell'inventario | Stato e verifica successiva |
|---|---|---|
| SWB-01 | <URL_SEEWEB_BACKUP>, Cloud Backup | Due report del 12 e 13/10: sei stati per unità, due Error nel secondo. Job, cause, cadenza, copie e audit del pannello da verificare |
| SWB-02 | <URL_SEEWEB_APPLIANCE_PUBBLICO>, Cloud Appliance VPN | Il Word lo associa a SWB-07 nella stessa voce firewall; confrontare identità/versione e registri GUI/VPN/SSH |
| SWB-03 | <URL_SEEWEB_CLIENTI>, area clienti | Mantenuto nel censimento admin con priorità inferiore per il backup; audit e export del provider non verificati |
| SWB-04 | <URL_SEEWEB_SUPPORTO>, ticket | Accessi e metadati operativi solo se disponibili e pertinenti; un ticket non prova un login sull'apparato |
| SWB-05 | <URL_SEEWEB_CLOUDCENTER> | Tre schermate lette, Eventi soltanto visibile; autenticazioni, retention ed export non provati |
| SWB-06 | <URL_SEEWEB_ESXI> | Hypervisor confermato, famiglia VMware 7 indicata nelle fonti; build corrente, log e Syslog da ricognire |
| SWB-07 | <URL_SEEWEB_FIREWALL_PRIVATO> | Secondo ingresso storico della stessa appliance di SWB-02; relazione corrente e prodotto da verificare prima di deduplicare |

Sette ingressi non diventano sette nuovi nodi della topologia. Le VM Windows, GroupShare, database e backup mantengono registri propri; l'audit dell'hypervisor non li sostituisce. Gli URL attuali vengono dall'operatore; il Word di architettura è storico, ultima modifica 07/07/2026, SHA beac5702ebe722aa84955e687aa1642b8d21aace3be5b932ce1d92cbd889d114 riconfermato sull'originale il 14/10. La tabella accessi aiuta a identificarli, senza usare le credenziali per una nuova autenticazione.

Le tre schermate correnti mostrano Foundation e appliance sulla stessa rete privata, 16 core, 128 GB RAM, 250 GB disco, etichetta VMware 7 e datacenter Milano. Build dell'host e inventario delle VM non letti. Backup: Nessun Backup è il campo del prodotto Foundation; non è una prova dell'assenza del diverso Cloud Backup delle mail. Identificativi, indirizzi, VLAN e hostname stanno in _notes/seeweb-access-inventory-20261014.json; immagini e provenienza in _notes/seeweb-census-20261014, ignorati da git.

## Canali candidati, nessuno attivato

La [guida Seeweb del pannello](https://docs.seeweb.it/hosting/cloudserver/Cloud-Server/pannello/) descrive gestione e console; la [REST API pubblicata](https://docs.seeweb.it/hosting/cloudserver/rest-api/API-Endpoints/) riguarda Shared CPU e non certifica un export dell'audit Foundation/Cloud Center. Per [Cloud Backup](https://www.seeweb.it/prodotti/cloud-backup) lo schema email deriva dai due campioni, non da una specifica garantita. La documentazione ufficiale e i limiti precisi sono registrati nel runbook del collettore.

I [registri ESXi](https://knowledge.broadcom.com/external/article/306962/location-of-esxi-log-files.html) e l'[invio Syslog](https://knowledge.broadcom.com/external/article/318939/configuring-syslog-on-esxi.html) sono candidati dopo verifica della release e delle righe reali: auth.log copre la Shell e da solo non prova tutti i login web. La [Cloud Appliance attuale](https://www.seeweb.it/prodotti/cloud-appliance/appliance-vpn) cita OPNsense/FortiGate ma non identifica il prodotto storico del tenant. Il canale firewall si sceglierà dal manuale della versione effettiva. Nessuna richiesta ai pannelli, modifica a tunnel/regole/backup o installazione sul collettore in questo giro.

Prossima misura: dashboard dell'appliance per prodotto/versione e confronto dei due ingressi, poi registri già esistenti ed export. Prima della produzione servono canale consentito, permessi minimi, eventi con identità e tempi, completezza/retention, silenzio e prova di ricezione. Restano la copia reale della mail, job/cause dei due Error del 13/10 e gli altri servizi da censire. Tre archivi sulla stessa VM, frontend sysadmin e correlazione successivi conservati; offline AdS Nebula rimandato dall'utente, D7 e gate aperti. ISO-30 rimane in_corso. Task Proxmox pianificato, PowerShell 7, dieci guest-agent 403 e audit delle fonti restano da ricordare.
