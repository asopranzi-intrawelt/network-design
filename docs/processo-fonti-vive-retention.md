# Processo delle fonti vive e retention degli snapshot

Stato al 16/10/2026: task della postazione verificato, retention implementata e provata in isolamento; abilitazione della cancellazione pianificata e primo giro reale ancora da osservare. Procedura operativa collegata a ISO-41, rischi da trattare in ISO-38 e perimetro della postazione in ISO-29/ISO-36. La scelta interna di 90 giorni segue la richiesta dell’IT Manager; non è un periodo imposto da ISO/IEC 27001.

## Scopo, asset e responsabilità

Il processo acquisisce fotografie tecniche in sola lettura da Proxmox e Nebula e le usa come fonti del progetto rete. Non è il collettore degli accessi AdS, una copia di backup delle VM o il registro delle autenticazioni. Gli snapshot contengono dati infrastrutturali reali: `output/`, `.env` e `_notes/` restano privati e ignorati da git. Codice, decisioni e procedura anonimizzata sono versionati.

L’esecuzione vive sulla postazione Windows dell’operatore, distinta dagli apparati interrogati. Il titolare operativo è l’IT Manager; in fase di formalizzazione del SGSI vanno confermati proprietario del rischio, delegato, inventario e regime dell’asset, accessi consentiti e recupero. La frase «la mia macchina» identifica la postazione indicata dall’operatore, non basta a classificarne proprietà e trattamento come dispositivo personale. Il nome reale, l’account e il comando compilato sono nell’evidenza privata del task.

La [presentazione ufficiale ISO/IEC 27001:2022](https://www.iso.org/standard/27001) descrive la gestione dei rischi e la protezione di riservatezza, integrità e disponibilità. Questa procedura ne documenta l’applicazione operativa al processo; i collegamenti a ISO-29/36/38/41 e ai controlli della roadmap sono una mappatura interna da riesaminare nella SoA approvata. Non si attribuisce alla pagina pubblica la lettura del testo completo della norma.

## Automazione osservata il 16/10/2026

| Proprietà del task | Misura locale | Implicazione |
|---|---|---|
| Frequenza | Ogni giorno alle 07:30, DaysInterval=1 | Il rinfresco è pianificato dalla postazione |
| Azione | Windows PowerShell, `scripts/Invoke-RefreshFonti.ps1` | Proxmox e Nebula, entrambe le fonti predefinite |
| Identità | Account locale dell’operatore, LogonType=Interactive, RunLevel=Limited | Richiede una sessione utente già aperta; privilegi non elevati |
| Esecuzione osservata | 16/10 alle 07:30:01+02:00, LastTaskResult=0 | Esito del task precedente alla nuova retention, non collaudo della cancellazione |
| Prossimo avvio riportato | 17/10 alle 07:30+02:00 | Pianificazione osservata, non promessa di esecuzione |
| Recupero e batteria | StartWhenAvailable=true, blocchi a batteria=false | Possibile recupero quando le condizioni lo permettono; non elimina il requisito di sessione |
| Riattivazione e concorrenza | WakeToRun=false, MultipleInstances=IgnoreNew | Non risveglia la postazione; una nuova istanza non si sovrappone al task già attivo |

Fonte: letture locali di Get-ScheduledTask/Get-ScheduledTaskInfo, conservate nel livello privato. La verifica iniziale nella sandbox era stata respinta; la successiva lettura autorizzata è riuscita. [Microsoft](https://learn.microsoft.com/en-us/windows/win32/taskschd/principal-logontype) documenta il requisito di sessione esistente per il tipo interattivo. Il task non è stato modificato o avviato durante queste letture.

## Acquisizione, segreti e promozione

Il launcher legge le chiavi ammesse dal `.env` privato tramite Read-ProjectEnv. Il processo di migrazione M30 resta la fonte per ACL, revoca, rotazione e ricostruzione: la verifica del task odierno non ripete tutti quei controlli. I token non vanno nei file versionati, nel report di retention o nei messaggi di errore. Il consumer Proxmox verifica TLS con il client dedicato e i pin già descritti nel dossier; PowerShell 7 e revoca X.509 restano prove distinte.

Ogni fonte scrive in una directory temporanea. Il launcher valida la misura, conserva prima una copia datata e solo dopo aggiorna i puntatori correnti. Un fallimento lascia la precedente misura buona e produce il registro e il marcatore `.refresh-fallito-<FONTE>.txt`, letto dal controllo di allineamento. Il nuovo passo di retention segue soltanto un rinfresco complessivamente riuscito; non gira nel DryRun delle API. Un suo errore restituisce codice 3 e marcatore dedicato, senza annullare le misure già promosse.

## Politica di conservazione

| Oggetto | Regola |
|---|---|
| Copie JSON datate | Giorno corrente più 89 precedenti; cutoff calcolato dalla data nel nome, non dall’ultima copia del file |
| Famiglie ammesse | Soltanto proxmox-YYYYMMDD-HHMMSS.json, nebula-YYYYMMDD-HHMMSS.json e nebula-snapshot-YYYYMMDD-HHMMSS.json, nella sola radice output |
| Copie correnti e ultima per famiglia | Alias correnti sempre esclusi; copie con lo stesso SHA-256 e ultima copia di ogni famiglia protette |
| Evidenze | Pin privati con nome e SHA-256, più riferimenti nei file pubblicabili del repository; nessuna scadenza automatica finché protette |
| Storico presente alla ricognizione | 127 copie, 36817388 byte (35,11 MiB), indicizzate come pin iniziali per preservare il materiale già usato nelle analisi |
| JSON non interpretabili | Conservati e contati per revisione; non cancellati come se fossero copie ordinarie |
| Budget di avviso | 512 MiB per le famiglie gestite, parametrizzabile; superarlo produce segnalazione e codice non zero, senza anticipare la scadenza dei dati |
| Altri file | Nessuna pulizia di screenshot, documenti, report, log, sottocartelle, `.env`, pin o archivio del collettore |

L’indice dei pin iniziale è privato e contiene impronte e motivi di conservazione, non credenziali. Una nuova evidenza usata soltanto nel livello privato va aggiunta ai pin prima della sua scadenza. La protezione dei riferimenti pubblicabili non sostituisce questo adempimento. I pin possono crescere: il budget li rende visibili, non li elimina in silenzio. Prima di liberarli occorre verificare dipendenze e collocazione dell’evidenza con chi la usa.

Il codice rifiuta directory radice del disco, junction/reparse point e nomi fuori dalle tre forme ammesse. Non percorre ricorsivamente output. Prima di rimuovere ricontrolla pin, alias e impronte dei candidati; usa Remove-Item con LiteralPath su singoli file già verificati. Mancanza o variazione di un’evidenza protetta interrompe il passo. Fonti: [Get-FileHash](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-5.1) e [Remove-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-5.1).

## Comandi, attivazione e ripristino

Destinazione: PowerShell della postazione, radice del progetto rete. L’anteprima non cancella file e non interroga API.

```powershell
cd "<RADICE_PROGETTO>"
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Invoke-SnapshotRetention.ps1
```

Dopo il versionamento manuale, l’operatore può abilitare i futuri giri riusciti. Il comando scrive la sola politica privata con i parametri scelti; non avvia il task e non cancella subito le copie.

```powershell
cd "<RADICE_PROGETTO>"
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Invoke-SnapshotRetention.ps1 -EnableScheduled -KeepDays 90
```

Per una pulizia manuale si usa il parametro Apply dopo aver riesaminato l’anteprima e i pin. Il codice non è una fonte di recupero di un file cancellato: i file rimossi richiederebbero una copia esterna. Per disattivare i giri futuri, impostare enabled=false nel file privato `_notes/snapshot-retention-policy.json`; il launcher torna alla sola anteprima. Non disabilitare il task delle fonti per fermare la sola retention. Le credenziali e i pin non vanno rimossi durante il ripristino.

## Rischi e verifiche ancora aperte

| Scenario | Presidio osservato o preparato | Verifica o trattamento aperto |
|---|---|---|
| Postazione spenta, sospesa o utente non connesso | Pianificazione, StartWhenAvailable e verifica di freschezza quando si apre il progetto | Proprietario/delegato, soglia di mancato aggiornamento e osservatore indipendente; valutare un nodo di servizio |
| Segreti accessibili da processi dello stesso account | Loader e livello privato già censiti da M30 | Riesame ACL, account dedicato o isolamento, revoca e ricostruzione su perdita della postazione |
| Copia datata rimossa mentre è ancora evidenza | Pin con SHA, riferimenti pubblicabili, piano e ricontrolli | Disciplina di pin per nuove evidenze private e riesame periodico delle eccezioni |
| Crescita dei pin o di file non coperti | Budget per le tre famiglie; perimetro esplicito | Capienza totale del volume, copia esterna e recupero di output/pin; gli altri artefatti richiedono la propria politica |
| Script modificato o pulizia fallita | Versionamento manuale, prove isolate, registro e marcatore del launcher | Prima attivazione e primo giro pianificato reali, risultato e conteggi; revisione del cambio |

Queste voci sono il contributo del processo al registro rischi ISO-38; assegnazione formale, accettazione del residuo e verifica indipendente restano nel percorso SGSI. La retention locale degli snapshot è distinta dai 213 giorni previsti per gli originali AdS e dai 90 giorni tecnici iLO sulla VM collettore.

## Evidenze e fonti

Sono conservati privatamente metadati del task, inventario delle 127 copie con impronte, pin iniziali, anteprima reale e prova isolata. La suite ha 11 prove, cinque scenari del launcher e nessuna prova saltata; rimuovendo la protezione dei pin o della soglia temporale le rispettive prove falliscono. Le fixture includono effettive cancellazioni di file temporanei; non hanno usato API, task o snapshot di produzione. Il primo tentativo del runner era bloccato dai permessi della sandbox Windows, poi rieseguito nel contesto autorizzato; non è contato come prova funzionale riuscita. I primi test di junction sono stati corretti e ripetuti senza saltarli.

Fonti ufficiali consultate il 16/10/2026: [ISO/IEC 27001, presentazione pubblica](https://www.iso.org/standard/27001), [Get-ScheduledTaskInfo](https://learn.microsoft.com/en-us/powershell/module/scheduledtasks/get-scheduledtaskinfo?view=windowsserver2025-ps), [LogonType](https://learn.microsoft.com/en-us/windows/win32/taskschd/principal-logontype), [Get-FileHash](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-5.1), [Remove-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-5.1). La regola dei 90 giorni, il budget e i pin iniziali sono scelte di progetto; il codice e le prove, non quei manuali, attestano il comportamento della retention realizzata.

Anteprima reale del 16/10/2026 sulla cartella output: mode=plan, 127 copie per 36817388 byte, zero candidati, zero byte candidati e zero eliminati, nessun avviso di budget. I 127 pin iniziali sono tutti presenti; tre copie hanno anche la protezione dell’alias corrente, perciò il riepilogo espone 124 con motivo pin/riferimento. Attivazione non eseguita. Controlli completi di chiusura della rete superati; prove, indice e metadati del task restano nel livello privato.

## Abilitazione ricevuta, 16/10/2026

L’operatore ha poi pubblicato la milestone bff861b, con remoto verificato, ed eseguito EnableScheduled a 90 giorni: mode=enable, 127 copie, 36817388 byte, zero candidati ed eliminati. Policy locale riletta enabled=true. Il primo successivo giro pianificato di pulizia resta da osservare; questa abilitazione non ha cancellato file.
