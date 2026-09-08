---
last-verified: 8a51761
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
