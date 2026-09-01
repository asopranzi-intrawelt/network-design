# network-design

> Istruzioni di team, versionate. Indice del progetto e procedura di ripresa. Le preferenze personali vivono in `CLAUDE.local.md`, ignorato da git, non qui.

## Cos'e' questo progetto

Progetto di documentazione e progettazione della rete Intrawelt. Raccoglie la storia completa degli interventi infrastrutturali di rete, lo snapshot corrente dell'infrastruttura Proxmox, la documentazione del firewall e degli altri componenti, e definisce gli step di intervento futuri. La documentazione segue un doppio layer: narrativo (locale, in `_notes/`) per le spiegazioni dettagliate e la storyline, e tecnico (versionato, in `.claude/context/`) per i documenti strutturati. Il progetto adotta un angolo ISO27001 per la documentazione della sicurezza di rete.

## Procedura di ripresa in una sessione nuova

Leggere per primo `.claude/memory/index.md` (branch, commit di riferimento, stato schede, punto di ripresa). Leggere poi `.claude/context/current-work.md` se c'e' una feature attiva. Seguire il protocollo di `.claude/rules/fonti-e-riallineamento.md`: il repository e' una sola delle cinque classi di fonti e le altre quattro non notificano, quindi vanno interrogate — in particolare va letto per intero il blocco `RILEVANTI PER LA RETE` dell'output del delta, e va chiesto all'IT Manager che cosa e' cambiato sulla rete in altre sessioni di lavoro o per intervento manuale. Invocare la skill `sync-context` per verificare il drift tra schede e codice. Leggere solo le schede pertinenti al task, mai tutte insieme. Per documenti Word voluminosi usare la skill `docx-ingest` che applica la disclosure progressiva (livello 1: TOC, livello 2: sezioni chiave, livello 3: sezione completa su richiesta).

## Due layer documentali

Il layer narrativo vive in `_notes/`, ignorato da git: contiene spiegazioni dettagliate, diario operativo, resoconto esteso, trascrizioni e materiale grezzo. Non va in git perche' e' narrativo, personale e spesso voluminoso.

Il layer tecnico vive in `.claude/context/` e `docs/`, versionato: contiene le schede strutturate con frontmatter di riconciliazione, i diagrammi, la timeline degli interventi in formato Markdown, la documentazione ISO27001. E' la fonte di verita' recuperabile da un clone.

## Script Proxmox

`scripts/Get-ProxmoxSnapshot.ps1` interroga l'API REST di Proxmox VE (IP reale in `_notes/.anonymization-map.md`, non qui: repo pubblico) e produce lo snapshot completo dell'infrastruttura in `output/proxmox-snapshot.json` e `output/proxmox-config.md`. L'output e' ignorato da git (dati infrastrutturali sensibili). Eseguire dalla radice del progetto passando l'host reale a `-ProxmoxHost` (vedi `.claude/rules/anonymization.md`).

## Script snapshot NinjaOne (gestione endpoint)

`scripts/Get-NinjaSnapshot.ps1` fotografa in **sola lettura** la gestione endpoint su NinjaOne (RMM): organizzazioni, dispositivi, policy, script, automazioni e interrogazioni diagnostiche, fra cui le interfacce di rete per dispositivo, che sono la fonte piu' rapida per il censimento degli indirizzi statici di M22a. Serve a questo progetto perche' gli endpoint non sono gestiti a mano: policy e automazioni agiscono su di loro e le password locali ruotano ogni trenta giorni, quindi qualunque credenziale di postazione memorizzata in un apparato di rete si rompe alla rotazione. Autenticazione OAuth2 client credentials con scope di sola lettura; il segreto si risolve da parametro, variabile d'ambiente o prompt a runtime e non viene mai scritto su disco. **Le credenziali API appartengono al provider MSP che gestisce l'RMM**: nessuno scope di scrittura, nessun valore nel repository. L'output va in `output/` (ignorato da git) perche' contiene nomi host, utenti e indirizzi reali. Decisione e vincoli in ADR-017 (`.claude/memory/decisions.md`).

## Script di controllo delta OneDrive

`scripts/Check-OneDriveDelta.ps1` confronta la cartella OneDrive "Documenti - IT" con una baseline locale (`_notes/.onedrive-manifest.json`, ignorata da git perche' contiene nomi di file reali) e riporta file nuovi, modificati ed eliminati rispetto all'ultimo triage della checklist di ingestione (`docs/infrastructure-timeline/ingestion-checklist.md`). Gira automaticamente a ogni avvio di sessione tramite hook SessionStart in `.claude/settings.local.json` (non versionato, percorsi di macchina). Dopo aver registrato in checklist le variazioni segnalate, rieseguirlo con `-UpdateBaseline`.

## Script timeline SVG

`scripts/Build-TimelineSvg.ps1` genera `docs/infrastructure-timeline/timeline.svg` (versionato, anonimizzato) dai file Markdown della timeline. Gira a ogni avvio di sessione tramite hook SessionStart (settings.local.json, non versionato). Ogni riga e' un accordion: il paragrafo che segue l'intestazione datata nel Markdown sorgente (il dettaglio ricostruito dai .docx ingeriti) diventa un pannello espandibile via script SVG nativo incorporato nel file (nessuna dipendenza esterna, resta un solo file .svg). L'interattivita' funziona quando l'SVG e' navigato direttamente o incluso via `<object>`/`<iframe>`/ inline nel DOM della pagina ospite; se la pagina esterna lo include con un tag `<img>`, il browser disabilita gli script per quel contesto e le righe restano leggibili ma non si espandono. I titoli legacy con nomi reali vengono anonimizzati a valle tramite `_notes/.svg-name-replacements.txt` (privato); un guard-rail avvisa se nei titoli o nei pannelli di dettaglio compare un IP non-placeholder. Lo script scrive solo dentro questo repository: vedi "Confine con E:\projects" piu' sotto.

## Script di scrittura dei segreti

`scripts/Set-ProjectSecret.ps1` scrive o ruota un segreto nel blocco `env` di `.claude/settings.local.json`, che secondo ADR-021 e' l'unico posto dove vivono i token di questo progetto. Il valore si digita a runtime come SecureString e non passa mai per una chat, per la cronologia del terminale o per un file temporaneo. La sostituzione e' mirata sul valore della singola chiave, quindi formattazione, hook e permessi del file restano identici; dopo la scrittura il JSON viene rivalidato e, se non e' valido, il backup viene ripristinato da solo. Il backup viene rimosso a validazione riuscita, perche' un backup di un file di segreti e' una copia in piu' del segreto (SEC-024); `-KeepBackup` lo conserva quando serve. La chiave deve gia' esistere nel blocco `env`: crearne una nuova cambia la configurazione del progetto e si fa a mano. Dopo la scrittura la sessione va **riavviata**, perche' il blocco `env` si legge all'avvio. Lo script e' versionato e non contiene nessun valore; il file che modifica non e' versionato.

## Script della mappa di rete interattiva

`scripts/Build-NetworkMap.ps1` genera `docs/network-map.html`, la mappa interattiva della topologia, a partire dalla fonte strutturata `data/network-topology.json` e dal template `scripts/templates/network-map.template.html`. E' l'attuazione di **ADR-023** e del micro-step **M26**, sullo stesso schema che gia' funziona per la timeline SVG: il deterministico prima del linguistico, e l'artefatto derivato nasce da uno script. Tre vincoli che lo script fa rispettare. Il file generato **non si modifica mai a mano**, e porta l'avvertenza in testa: se un dato e' sbagliato si corregge la fonte e si rigenera, altrimenti nasce una seconda verita' accanto alla prima. L'HTML e' **autoconsistente**, senza librerie esterne ne' richieste di rete, quindi si apre con un doppio clic anche offline. E la mappa **eredita l'anonimizzazione**: prima di scrivere, lo script cerca nel risultato indirizzi fuori dagli intervalli di documentazione e MAC non segnaposto, e si rifiuta di scrivere se ne trova. Lo script valida anche la fonte, cioe' rifiuta identificatori duplicati e riferimenti che non risolvono, che e' il modo in cui un file di topologia scritto a mano si rompe per primo.

Dalla revisione 3 del 24/08/2026 il template disegna un grafo vero invece di elencare schede: la disposizione si calcola a ogni apertura dalla sola fonte (ranghi per corsia, nodi fittizi sugli archi lunghi, ordinamento per baricentro, compattazione dei vuoti, attacchi distribuiti sul bordo dei nodi perche' altrimenti sotto lo switch con venti collegamenti si forma un pettine illeggibile). Quattro viste: Logica, Fisica come matrice luogo-per-corsia, Segmenti sui soli archi che dichiarano una VLAN con la ricaduta scritta nella pagina, ed Elettrica dalla presa a parete all'apparato. La capacita' su cui si regge l'uso operativo e' l'isolamento di un ramo, che mostra tutto cio' che dipende da un apparato piu' due salti di contesto a monte: si attiva dalla scheda, con doppio clic sul nodo, con il tasto `i`, o aprendo il file con il frammento `#isola=<identificatore>`. Il frammento accetta anche il nome di una vista, e le due cose si combinano con la virgola.

## Script della matrice delle porte

`scripts/Export-PortMatrix.py` estrae dallo snapshot Nebula la configurazione completa delle porte dei due switch gestiti e la scrive in `data/port-matrix.json`, che e' **tracciato**. Esiste un file intermedio invece di leggere lo snapshot direttamente per una ragione precisa: lo snapshot vive in `output/`, ignorato da git perche' contiene MAC reali e nomi host, mentre la mappa e' pubblica. Se il generatore leggesse lo snapshot, la mappa non sarebbe piu' rigenerabile da un clone e l'anonimizzazione dipenderebbe da un passaggio invisibile dentro il generatore; con un file intermedio tracciato, invece, cio' che finisce in pubblico si legge, si controlla con il guard-rail insieme a tutto il resto, e si diffa fra due revisioni. Escono numero di porta, abilitazione, modalita' trunk, PVID, VLAN ammesse, stato del PoE e velocita' negoziata, che sono numeri di configurazione e non identificano nessuno. **Non escono gli indirizzi MAC**: della tabella MAC sopravvivono due aggregati, quante stazioni distinte si vedono su quella porta e in quali VLAN, che sono la parte informativa e servono a rispondere a "questa porta e' viva" e a "il traffico passa nella VLAN che mi aspettavo". Prima di scrivere, il risultato viene ripassato in cerca di MAC e in caso lo script non scrive, come gia' fanno gli altri due generatori. Il file alimenta la vista Porte della mappa; se manca, la mappa si costruisce lo stesso con una vista in meno invece che con un errore.

## Script di riconciliazione della mappa

`scripts/Test-TopologyDrift.py` confronta la fonte della mappa con le misure vive e riporta dove non coincidono. Non aggiorna niente e non decide niente: dice che la fonte afferma una cosa e l'apparato un'altra, e chi ha ragione lo stabilisce una persona. Esiste perche' `data/network-topology.json` la scrive a mano chi legge uno snapshot, e dopo niente la tiene allineata: se qualcuno sposta un telefono di porta o cambia un PVID, la mappa continua a disegnare la verita' di ieri con la stessa sicurezza di prima. Contro lo snapshot Nebula verifica che ogni porta dichiarata in un collegamento esista, sia abilitata, ammetta le VLAN dichiarate e abbia il PVID coerente, e che l'inventario degli apparati gestiti corrisponda; la corrispondenza fra nodo e dispositivo Nebula e' esplicita e vive nel campo `nebula` dei nodi della fonte, perche' un confronto per somiglianza di nome produce falsi positivi (gli access point la fonte li chiama per ruolo e Nebula per etichetta di sito). Contro lo snapshot Proxmox verifica che i bridge esistano, che ogni macchina virtuale della fonte esista ancora e che il bridge di attestazione sia quello reale. Su entrambi controlla l'eta' dello snapshot e si rifiuta di dichiarare un verde che non ha calcolato: se una fonte viva manca o e' piu' vecchia della soglia esce con codice 2 e lo dice. Si lancia con `python scripts/Test-TopologyDrift.py`, accetta `--giorni` per la soglia di eta' e `--silenzioso` per il solo verdetto, ed esce con 0 se allineata, 1 se ci sono scostamenti, 2 se non e' giudicabile. Le etichette che vengono dagli snapshot, cioe' nomi host e nomi di apparato, **non si stampano** se non con `--nomi`: quelle della fonte sono gia' pubblicabili perche' la fonte e' tracciata e passa il guard-rail, quelle di `output/` no, ed e' il motivo per cui quella cartella e' ignorata da git. L'output non va mai rediretto dentro un file tracciato.

Gira automaticamente a ogni avvio di sessione tramite hook SessionStart (`settings.local.json`, non versionato), accanto al delta OneDrive e alla timeline SVG. E' l'unico dei tre script della catena della mappa che si possa automatizzare senza pensarci, e la ragione e' precisa: legge tre file gia' sul disco, non scrive niente, non apre connessioni e non usa credenziali. Gli script che **rinfrescano** gli snapshot restano invece manuali, per scelta e non per dimenticanza: fanno chiamate autenticate al fornitore, hanno una cadenza gia' concordata in `.claude/rules/fonti-e-riallineamento.md`, scrivono una copia datata a ogni esecuzione, e soprattutto se si rinfrescassero da soli il confronto non potrebbe piu' dire "questa misura e' vecchia", che e' meta' del suo valore.

## Guard-rail di anonimizzazione

`scripts/Test-Anonymization.py` passa tutti i file tracciati da git e riporta indirizzi reali, MAC reali, nomi propri di persona, caselle di posta personali, importi, numeri di telefono, IBAN, partite IVA e i segreti letterali gia' noti. Esce con codice diverso da zero se trova qualcosa nelle categorie bloccanti, e va eseguito prima di ogni commit che tocchi documentazione: `python scripts/Test-Anonymization.py`. Lo script e' versionato e non contiene nessun valore reale, perche' cio' che deve cercare vive in `_notes/.anonymization-patterns.json`, ignorato da git accanto alla mappa dei segnaposto; se quel file manca lo script si ferma invece di dare un verde non calcolato. Il primo passaggio, il 06/08/2026, ha trovato centoquarantotto riscontri su ottantanove file, nessuno introdotto di proposito: il controllo va fatto sull'intero albero e non sui soli file toccati, perche' un residuo non si introduce, si eredita. Dettaglio in `.claude/rules/anonymization.md`.

## Confine con E:\projects

Questo repository non scrive mai in `E:\projects` (il sito MkDocs dei progetti personali) ne' in nessun altro repository esterno a `D:\network-design`. La direzione di lettura e' invertita: se il sito `E:\projects` vuole un asset aggiornato di questo progetto, come la timeline SVG per la pagina "Progettazione e documentazione della rete aziendale", e' quel progetto a leggerlo da qui per conto proprio (con un proprio script o hook nella propria configurazione), non questo repository a spingerlo la' per copia. Vale per qualunque script o hook futuro definito qui: nessun `Copy-Item`, nessuna scrittura, nessuna creazione di cartelle al di fuori dell'albero di `D:\network-design`.

## Indice dei file satellite tracciati

Memoria e meta-stato, sotto `.claude/memory/`, letti sempre a inizio sessione.

```
.claude/memory/index.md       snapshot e tabella di sincronizzazione, da leggere per primo
.claude/memory/progress.md    work-log append-only di passi e riconciliazioni
.claude/memory/decisions.md   registro ADR-lite delle decisioni architetturali
```

Schede tecniche, sotto `.claude/context/`, con frontmatter di riconciliazione.

```
.claude/context/STACK.md                stack, script, ruolo architetturale dei file
.claude/context/design-and-security.md  paradigmi ISO27001, sicurezza di rete
.claude/context/deployment.md           esecuzione script, aggiornamento snapshot
.claude/context/dev-testing.md          verifica output snapshot, casi limite
.claude/context/current-work.md         feature attiva, definition of done
.claude/context/roadmap.md              fasi del progetto, timeline interventi
.claude/context/diagrams/               topologie di rete e diagrammi infrastrutturali
```

Documentazione strutturata, sotto `docs/`.

```
docs/infrastructure-timeline/     storia cronologica degli interventi di rete
docs/pendenze-aperte.md           vista consolidata di cio' che resta da sanare; non e' una fonte, punta ai registri
docs/livello-fisico-ed-elettrico.md  armadi, alimentazione, catena fisica WAN, mappa porta-apparato, censimento NAS
docs/virtualizzazione-proxmox-e-bridge.md  come il server Gen10 e' attaccato alla rete: cinque cavi, quattro bridge, misurato vs dedotto
docs/esposizione-servizi-interni.md  matrice delle porte in ascolto per macchina virtuale e stato della protezione host-based
docs/autorita-certificazione-interna.md  nomi dei servizi interni, autorita' di certificazione, procedura di emissione
```

Regole modulari caricate su necessita', sotto `.claude/rules/`.

```
.claude/rules/interaction-style.md     stile di documentazione e di risposta (caricare sempre)
.claude/rules/token-economy.md         pratiche di risparmio di contesto (caricare sempre)
.claude/rules/git-identity-and-repo.md profili SSH, identita git, bootstrap del remoto
.claude/rules/manual-screenshots.md    flusso di cattura screenshot per verifica visiva
.claude/rules/anonymization.md         anonimizzazione IP/MAC/nomi propri (repo pubblico, caricare sempre)
.claude/rules/fonti-e-riallineamento.md  le cinque classi di fonti e da dove riallinearsi (caricare sempre)
```

Skill richiamabili, sotto `.claude/skills/`.

```
.claude/skills/sync-context/    verifica drift schede vs codice; usare a inizio sessione
.claude/skills/repo-status/     riepilogo branch, commit recenti, diff non committato
.claude/skills/git-sync/        aggiorna contesto dopo un git pull o merge
.claude/skills/docx-ingest/     ingestione progressiva di documenti Word voluminosi
```

Agent specializzati, sotto `.claude/agents/`.

```
.claude/agents/iso27001-reviewer/   verifica aderenza ISO27001 della documentazione
```

## Vincoli di team

Le operazioni di git add, commit e push restano sempre manuali dell'utente. L'identita' git e' impostata a livello locale del repo secondo `.claude/rules/git-identity-and-repo.md`. Lo stile di documentazione e' quello di `.claude/rules/interaction-style.md`. Lo standard di sistema completo e' in `.claude/PROJECT-SYSTEM.md`.

## Nota MCP

Il server MCP `proxmox` e' configurato in `.mcp.json` (radice, mai sotto `.claude/`) sul pacchetto PyPI `proxmox-mcp` via uvx. Autentica solo con token API: la decisione, il razionale e la procedura di attivazione (token PVEAuditor di sola lettura piu' tre variabili d'ambiente utente) sono in ADR-007 (`.claude/memory/decisions.md`). Il file tracciato non contiene valori reali: URL e token si espandono da variabili d'ambiente della macchina. In alternativa e per lo snapshot completo resta canonico `scripts/Get-ProxmoxSnapshot.ps1`.
