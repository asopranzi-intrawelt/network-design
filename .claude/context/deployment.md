---
last-verified: 20d4863
---

# Esecuzione script e aggiornamento snapshot

## Eseguire lo snapshot Proxmox

```powershell
# Dalla radice del progetto
.\scripts\Get-ProxmoxSnapshot.ps1 -ProxmoxHost 10.61.20.11
```

Lo script chiede username e password a runtime. Le credenziali non vengono mai salvate su disco. La password viene azzerata subito dopo l'autenticazione.

Output prodotto in `output/` (ignorato da git):
- `output/proxmox-snapshot.json` — dati grezzi completi (JSON)
- `output/proxmox-config.md` — report leggibile (Markdown)

## Prerequisiti

- PowerShell 5.1 o superiore
- Accesso di rete a `10.61.20.11:8006` (TCP 8006)
- Credenziali Proxmox con permessi API (root o utente PVEAudit)
- Nessun modulo esterno richiesto

## Parametri dello script

| Parametro | Default | Descrizione |
|---|---|---|
| `-ProxmoxHost` | — | IP/hostname del server Proxmox (obbligatorio) |
| `-OutputDir` | `.\output` | Directory di output |

## Profilo SSH e identita' git

Configurati a livello locale del repo (non globale). Vedere `.claude/rules/git-identity-and-repo.md` per la procedura.

```
user.name  = asopranzi
user.email = asopranzi@intrawelt.com
remote     = git@github-corp:asopranzi-intrawelt/network-design.git
```

## Cosa gira da solo, e cosa resta a mano (aggiornato l'08/09/2026)

La distinzione non e' di comodita' ed e' la sostanza di ADR-026: **si automatizza la verifica, non la misura**. All'avvio di ogni sessione girano quattro passi tramite l'hook `SessionStart` di `settings.local.json`, e tutti e quattro leggono file gia' sul disco senza aprire connessioni ne' usare credenziali: il delta delle tre radici documentali, la rigenerazione della timeline SVG, la riconciliazione della mappa di rete e il controllo di allineamento. I comandi usano `$CLAUDE_PROJECT_DIR`, quindi quel file si copia su un'altra macchina senza riscrivere percorsi.

Il **rinfresco** delle fonti vive gira invece su un'attivita' pianificata giornaliera che esegue `scripts/Invoke-RefreshFonti.ps1`, e non sull'hook: farlo all'avvio farebbe pagare a ogni sessione un minuto di chiamate al fornitore per una misura che cambia di rado. Copre Nebula e Proxmox, cioe' le due fonti le cui credenziali di sola lettura vivono nel blocco `env`; la gestione endpoint resta manuale perche' le sue credenziali sono del provider MSP (ADR-017).

Su Windows l'attivita' va creata con le condizioni sulla batteria **disattivate**: quelle predefinite impediscono l'avvio a batteria, ed e' la ragione per cui la prima versione dell'attivita' non e' mai partita per tre giorni senza che nulla lo dicesse. Su Linux l'equivalente e' una voce di `crontab` con PowerShell 7, e il `cd` nella radice non e' cosmetico perche' gli script scrivono in `output/` relativo ad essa.

## Prima di ogni commit che tocchi documentazione

Tre comandi, in quest'ordine, tutti eseguibili da qualunque cartella perche' risalgono da soli alla radice del repository.

```powershell
python scripts/Test-Anonymization.py
python tools/md-unwrap.py --check .
python scripts/Test-Allineamento.py
```

Il primo e' bloccante e passa i file tracciati **piu' quelli non tracciati e non ignorati**, che sono i candidati al prossimo commit: fino al 07/09/2026 guardava i soli tracciati, quindi un file nuovo era invisibile proprio nel momento in cui serviva guardarlo. Con `--tutti` conta anche il layer privato, senza bloccare, perche' quei file contengono valori reali per costruzione.

## Le catene di script, e in quale ordine si eseguono

La mappa di rete ha tre passi e l'ordine conta: `Export-PortMatrix.py` estrae la matrice delle porte dallo snapshot Nebula verso un file tracciato, `Build-NetworkMap.ps1` genera l'HTML dalla fonte piu' quella matrice, `Test-TopologyDrift.py` confronta la fonte con le misure vive. Solo il terzo e' automatizzato, perche' e' l'unico che non interroga nessuno.

L'autorita' di certificazione ha due script che **non si eseguono su una macchina della rete**: girano sulla cartella dell'autorita', che ADR-025 vuole fuori linea e protetta da passphrase. `crea-autorita.sh` una volta sola, poi solo `emetti-certificato.sh`. Al 08/09/2026 sono scritti e mai eseguiti.

Le ricognizioni su host si eseguono sempre tramite `Invoke-HostCensus.ps1` con `-Script`, mai incollando comandi: lo stesso comando si e' rotto per citazione quattro volte perche' attraversa PowerShell e poi una shell remota, e trasferire un file ed eseguirlo elimina il problema alla radice.

## Ingestione documenti Word

Per i documenti Word voluminosi della storia della rete usare la skill `docx-ingest`. I file Word restano in `_notes/` (ignorato da git). I mirror Markdown curati vanno in `docs/infrastructure-timeline/` (versionato).

## Portabilita' su un'altra macchina, Windows o Linux

Questa sezione stava nel `CLAUDE.md` fino al 13/10/2026 ed e' stata spostata qui verbatim. Del sottotitolo sul rinfresco pianificato resta la sola parte che la sezione "Cosa gira da solo" non dice gia', cioe' la riga di crontab e il presidio.

## Portabilita' su un'altra macchina, Windows o Linux

Irrobustita il 07/09/2026. Il criterio adottato e' che **nessun file tracciato contenga un percorso di macchina**, e che cio' che resta specifico viva nei tre posti che per questo progetto non sono versionati: il `.env` privato e gli hook di `.claude/settings.local.json`, il layer privato `_notes/`, e gli output in `output/`.

Cosa e' stato reso indipendente dalla macchina, e come. I due controlli Python **risalgono alla radice del repository dalla posizione del proprio file** invece di fidarsi della cartella corrente, cercando `.git` sia come cartella sia come file perche' in un worktree e' un file che punta altrove; accettano `--radice` per i casi in cui la risalita non basti, e `Test-Anonymization.py` accetta `--patterns` per un layer privato organizzato diversamente. La ragione del cambio e' che la cartella corrente dipende da chi invoca, e chi invoca puo' essere una sessione, un hook, un'attivita' pianificata o un altro script: quattro cartelle diverse per lo stesso comando. Prima quello strumento si rifiutava perfino di partire se non lo si lanciava dalla radice.

Negli script PowerShell i percorsi si compongono con `Join-Path` annidato e non con stringhe che contengono la barra rovesciata, perche' su Linux quella barra e' un carattere valido in un nome di file: `'.claude\settings.local.json'` non e' un percorso di due livelli ma un nome unico bizzarro, e il guasto si manifesta solo fuori da Windows, cioe' quando nessuno lo sta guardando.

La radice della libreria documentale **si risolve e si valida**, non si scrive. L'ordine dei candidati va da `ONEDRIVE_ROOT` nell'ambiente alle variabili che il client imposta da se', fino a una ricerca sotto il profilo utente; ogni candidato viene poi verificato controllando che contenga davvero almeno una delle tre librerie sorvegliate. La validazione non e' zelo: su questa macchina la variabile `OneDriveCommercial` punta al **doppio aggancio** con il suffisso numerico, che di quelle librerie non ha nessuna, ed e' un problema noto e documentato del progetto. Una risoluzione che si fida della prima variabile disponibile e' peggio di un percorso cablato, perche' sembra portabile e non lo e'. Se piu' radici risultano valide lo script lo dichiara, perche' due copie della stessa libreria divergono.

I comandi dell'hook di avvio usano `$CLAUDE_PROJECT_DIR`, che Claude Code espande, quindi `settings.local.json` si copia su un'altra macchina senza riscrivere quattro percorsi. Le quattro chiavi operative si provisionano invece nel `.env` privato con ACL appropriato sulla macchina di destinazione.

L'unica differenza irriducibile fra i due sistemi e' il **nome dell'interprete**, e va dichiarata invece di essere scoperta: su Windows sono `powershell` e `python`, su Linux `pwsh` e `python3`. E' l'unico elemento da sostituire nei comandi dell'hook quando il progetto si sposta.

### Il rinfresco pianificato, nelle due forme

Su Linux l'equivalente dell'attivita' pianificata di Windows e' una voce di `crontab -e`, con PowerShell 7 installato. Il `cd` non e' cosmetico: serve perche' gli script scrivono in `output/` relativo alla radice.

```
30 7 * * * cd /percorso/di/network-design && pwsh -NoProfile -File ./scripts/Invoke-RefreshFonti.ps1 >> output/cron.log 2>&1
```

In entrambi i casi il presidio non e' lo scheduler ma il controllo di allineamento, che sorveglia l'eta' del registro del rinfresco con cadenza di due giorni: se l'attivita' si spegne, per qualunque ragione e su qualunque sistema, la cosa si vede al primo avvio di sessione utile e non alla prossima scadenza della fonte.

### Cosa verificare al primo avvio su una macchina nuova, e cosa non e' provato

Nell'ordine: che `python` e `powershell` rispondano con i nomi giusti per quel sistema; che `_notes/` contenga il file dei pattern, la mappa dei segnaposto e le tre baseline, che non essendo versionati vanno portati a mano; che il `.env` privato contenga le quattro chiavi operative con ACL adeguato alla macchina; e che `python scripts/Test-Allineamento.py` giri, perche' e' il controllo che dichiara da se' cosa manca.

Va detto con onesta' cio' che **non e' stato provato**: tutto quanto sopra e' verificato su Windows, e la portabilita' verso Linux e' stata ottenuta togliendo i costrutti che la impedivano, non eseguendola la'. Gli script di snapshot dichiarano di gestire entrambe le versioni di PowerShell e `Get-ProxmoxSnapshot.ps1` ha effettivamente il ramo con `-SkipCertificateCheck` per PowerShell 7, ma nessuno li ha ancora eseguiti su Linux. Fino a quella prova la riga corretta e' "non risultano ostacoli noti", non "funziona".

## Collegarsi alle macchine virtuali

Si consulta `_notes/registro-credenziali.md` prima di chiedere alias o utenti all'IT Manager, confrontando la tabella con `docs/esposizione-servizi-interni.md`. La nota privata conserva la corrispondenza fra identificatore e nome Proxmox, prompt della macchina, alias `Host`, utente e nome del file chiave. Non si leggono ne' si copiano contenuti delle chiavi private e non si salvano password. Se la configurazione SSH della macchina cambia, la tabella si aggiorna nella stessa sessione.
