# network-design

> Istruzioni di team, versionate. Indice del progetto e procedura di ripresa. Le preferenze personali vivono in `CLAUDE.local.md`, ignorato da git, non qui.

## Cos'e' questo progetto

Documentazione e progettazione della rete Intrawelt: interventi passati e futuri, snapshot Proxmox, firewall, altri componenti e sicurezza ISO 27001. Il layer narrativo locale e' in `_notes/`; quello tecnico, strutturato e versionato, in `.claude/context/`.

## Procedura di ripresa in una sessione nuova

Eseguire prima `python tools/verifica-agent-bridge.py`, che rende visibile una divergenza fra le skill scoperte da Claude Code e quelle scoperte da Codex. Invocare poi la skill `riprendi`, che esegue `python tools/verifica-ripresa.py` e verifica il file di ripresa prima di fidarsene. Leggere quindi `.claude/memory/index.md` (branch, commit di riferimento, stato schede, punto di ripresa) e `.claude/context/current-work.md` se c'e' una feature attiva. Seguire poi i cinque passi del protocollo di riallineamento di `.claude/rules/fonti-e-riallineamento.md`, perche' il repository e' una sola delle cinque classi di fonti e le altre quattro non notificano. Invocare la skill `sync-context` per verificare il drift tra schede e codice. Leggere solo le schede pertinenti al task, mai tutte insieme. Per documenti Word voluminosi usare la skill `docx-ingest` che applica la disclosure progressiva (livello 1: TOC, livello 2: sezioni chiave, livello 3: sezione completa su richiesta). A fine sessione, dopo i commit manuali dell'utente e l'aggiornamento di `_notes/RESUME_PROMPT.md`, registrare l'impronta con `python tools/verifica-ripresa.py --registra`.

## Fonti delle decisioni tecniche

Per ogni decisione tecnica nuova o rettificata si collega nel registro ADR o nel runbook la documentazione ufficiale pertinente con URL diretto. Si distinguono comportamento documentato, misura locale e inferenza. Anche le decisioni pregresse si riconciliano in un indice delle fonti; una scelta interna senza fonte esterna si dichiara tale, senza inventare citazioni.

## Due layer documentali

`_notes/` raccoglie spiegazioni, diario, resoconti, trascrizioni e materiale grezzo. E' ignorato da Git perche' spesso personale o voluminoso.

Il layer tecnico vive in `.claude/context/` e `docs/`, versionato: contiene le schede strutturate con frontmatter di riconciliazione, i diagrammi, la timeline degli interventi in formato Markdown, la documentazione ISO27001. E' la fonte di verita' recuperabile da un clone.

## Gli script, e dove sta la loro descrizione

Questo repository e' la fonte unica degli strumenti di rete: gli altri progetti, come il convertitore dei ruolini, non ne tengono copia e rimandano qui. L'indice esaustivo degli script e' la tabella in testa a `.claude/context/STACK.md`, e la descrizione estesa di ogni famiglia, cioe' che cosa fa, che cosa scrive e quali vincoli rispetta, sta nella sezione "Descrizione estesa delle famiglie di script" della stessa scheda. Si legge quando si tocca uno script, non a ogni sessione. Qui restano le sole regole che valgono comunque.

Gli artefatti derivati non si modificano mai a mano. La timeline SVG, la mappa `docs/network-map.html`, la roadmap ISO con le sue copie su Desktop e in OneDrive, la matrice delle porte e la riconciliazione Onova nascono tutte da una fonte tracciata e da uno script: se un dato e' sbagliato si corregge la fonte e si rigenera, altrimenti nasce una seconda verita' accanto alla prima.

L'agente registra automaticamente, senza chiedere all'utente di lanciare comandi, ogni avanzamento o correzione ISO nella stessa sessione in cui aggiorna il progetto o riceve la notizia: `python scripts/IsoRoadmap.py advance <ID> --stato <stato> --nota "..."`, con `--evidenza "..."` quando lo stato e' `completato`. Il comando rigenera la vista di progetto e le copie private. Il registro puo' seguire un avanzamento comunicato o verificato, ma non scoprire un cambiamento fisico su un apparato non interrogabile: quel limite si dichiara e si chiede evidenza, invece di promuovere un rilievo a risolto senza prova.

Gli output che contengono valori reali restano fuori da git: `output/` e `_notes/` sono ignorati per costruzione, ed e' la ragione per cui il guard-rail elenca i loro riscontri a parte e non bloccanti. Come ci si collega alle macchine virtuali, e perche' si parte da `_notes/registro-credenziali.md` invece che da una domanda all'IT Manager, sta in `.claude/context/deployment.md`.

## Guard-rail di anonimizzazione

`python scripts/Test-Anonymization.py` si esegue prima di ogni commit che tocchi documentazione. Il suo perimetro e' cio' che sta per essere pubblicato, cioe' i file tracciati piu' i non tracciati e non ignorati, e il codice di uscita e' diverso da zero se trova un valore reale in una categoria bloccante. Cio' che cerca vive in `_notes/.anonymization-patterns.json`, ignorato da git accanto alla mappa dei segnaposto: se quel file manca lo script si ferma invece di dare un verde non calcolato. La norma sta in `.claude/rules/anonymization.md`, la storia del controllo e l'allargamento del perimetro del 07/09/2026 in `.claude/context/STACK.md`.

## Portabilita' su un'altra macchina

Nessun file tracciato contiene un percorso di macchina: cio' che resta specifico vive nei tre posti non versionati, cioe' il `.env` privato con gli hook di `.claude/settings.local.json`, il layer privato `_notes/` e gli output in `output/`. Come e' stato ottenuto, che cosa verificare al primo avvio su una macchina nuova e che cosa non e' ancora provato su Linux stanno in `.claude/context/deployment.md`, sezione "Portabilita' su un'altra macchina, Windows o Linux".

## Confine con E:\projects

Questo repository non scrive mai in `E:\projects`, il sito MkDocs dei progetti personali, ne' in nessun altro repository esterno a `D:\network-design`: nessun `Copy-Item`, nessuna scrittura e nessuna creazione di cartelle fuori dal proprio albero, e il vincolo vale per qualunque script o hook futuro definito qui. La direzione di lettura e' invertita: se il sito vuole un asset aggiornato di questo progetto, come la timeline SVG, e' quel progetto a leggerlo da qui per conto proprio, non questo repository a spingerlo la' per copia.

La sola deroga circoscritta e' **ADR-027**: quando si scopre che una capacita' di questo progetto manca o e' fragile in `E:\template-claude-developing`, cioe' nel template da cui questo progetto discende, la capacita' risale al template su un ramo dedicato, generalizzata e spogliata di ogni riferimento a questo progetto, con il commit che resta manuale dell'utente perche' quel repository ha un'altra identita' git. Vale solo verso il template e solo per la risalita di una capacita'.

**Eccezioni esplicite del 28-29/09 e del 07/10/2026 richieste dall'utente**, descritte per esteso in `.claude/context/STACK.md`: `scripts/IsoRoadmap.py` scrive la copia derivata della roadmap ISO sul Desktop e nella cartella ISO privata di OneDrive a ogni avanzamento registrato, e `scripts/Build-OnovaReconciliation.py apply` aggiorna la checklist VA privata di `_notes/onova-reconciliation.json` dopo averne conservato l'originale. Non autorizzano scritture verso `E:\projects` o altri repository; le fonti pubbliche restano qui e i percorsi reali soltanto nelle configurazioni private.

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

Documentazione strutturata, sotto `docs/`. L'indice con i percorsi di lettura e' `docs/README.md`, che li elenca tutti e resta la porta d'ingresso: qui bastano le tre viste che si aprono piu' spesso.

```
docs/README.md                    indice della documentazione e percorsi di lettura
docs/snapshot-infrastruttura.md   fotografia documentale datata: fonti, topologia, limiti e pendenze
docs/pendenze-aperte.md           vista consolidata di cio' che resta da sanare; non e' una fonte, punta ai registri
```

Regole sempre attive, sotto `.claude/rules/`. Ogni file qui dentro entra in contesto a ogni sessione e concorre al budget che `python .claude/templates/tools/misura-istruzioni.py --root .` misura. Le prime due sono di questo progetto, le altre arrivano dal template; i casi che le giustificano stanno in `.claude/norme/`, che non si carica all'avvio.

```
.claude/rules/anonymization.md           anonimizzazione IP/MAC/nomi propri, repo pubblico
.claude/rules/fonti-e-riallineamento.md  le cinque classi di fonti e da dove riallinearsi
.claude/rules/chat-non-e-memoria.md      cio' che si scrive in sessione si scrive anche su disco
.claude/rules/documenti-personali.md     documenti personali mai letti senza richiesta espressa
.claude/rules/git-commands-format.md     formato dei comandi git da eseguire a mano
.claude/rules/interaction-style.md       stile di documentazione e di risposta
.claude/rules/manual-screenshots.md      flusso di cattura screenshot per verifica visiva
.claude/rules/security-permissions.md    modalita' di permesso, sandbox, agent team
.claude/rules/token-economy.md           pratiche di risparmio di contesto
```

Skill richiamabili, sotto `.claude/skills/`.

```
.claude/skills/sync-context/      verifica drift schede vs codice; usare a inizio sessione
.claude/skills/riprendi/          verifica il resume contro commit e working tree prima di leggerlo
.claude/skills/repo-status/       riepilogo branch, commit recenti, diff non committato
.claude/skills/git-sync/          aggiorna contesto dopo un git pull o merge
.claude/skills/docx-ingest/       ingestione progressiva di documenti Word voluminosi
.claude/skills/studio-didattico/  studio guidato di un argomento sul materiale del progetto
```

Dal template arrivano inoltre `alberi-di-lavoro`, `fonti-non-recuperabili`, `identita-git`, `prove-che-misurano` e `separazione-ambienti`, che portano una norma e si invocano sulle situazioni elencate piu' sotto, e `gate-pacchetti`, `init-project-system` e `onboard`, che servono all'inizializzazione e all'adozione dei pacchetti opzionali.

Codex scopre le stesse skill tramite adapter sottili e versionati sotto `.agents/skills/`. La logica resta soltanto in `.claude/skills/`; `tools/verifica-agent-bridge.py` impedisce che i due cataloghi divergano.

Agent specializzati, sotto `.claude/agents/`.

```
.claude/agents/iso27001-reviewer/   verifica aderenza ISO27001 della documentazione
```

Norme caricate su richiesta, una riga per situazione con le parole con cui si presenta, così che il caricamento non dipenda dal ricordare che la norma esista.

- `git worktree list` mostra più di un albero, se ne crea o se ne rimuove uno, si deve decidere da dove leggere la memoria versionata: skill `alberi-di-lavoro`.
- Un recupero web fallisce con 403 o con una pagina di verifica anti-bot, la fonte sta su Reddit o su Discord, serve la trascrizione di un video, si sta per annotare una fonte non letta: skill `fonti-non-recuperabili`.
- Si imposta o si verifica user.name e user.email, si collega o si cambia il remoto o l'alias SSH, si inizializza un repository, un push fallisce per permessi, `/status` mostra un account Claude diverso da quello atteso, si autentica o si usa `gh`: skill `identita-git`.
- Si scrive o si valuta una prova automatica, si chiude un difetto, una verifica manuale smentisce una suite verde, si sta per dichiarare completo un intervento il cui scopo era un effetto misurabile: skill `prove-che-misurano`.
- Si inizializza o si allinea il progetto, oppure cambia il modo in cui si prova e si rilascia, e va deciso come separare test e produzione: skill `separazione-ambienti`.

## Vincoli di team

Le operazioni di git add, commit e push restano sempre manuali dell'utente. Per una milestone completa su Windows, l'agente prepara il messaggio in `_notes/COMMIT-MSG.txt` e propone il comando `chiudi` da PowerShell nella radice del progetto; `tools/chiudi-sessione.ps1` esegue i controlli e chiede conferma all'utente prima di commit e push. L'identita' git e' impostata a livello locale del repo con il profilo di lavoro, cioe' alias SSH `github-corp`, identita aziendale e `core.sshCommand` forzato all'OpenSSH di sistema; i valori correnti stanno in `.claude/context/deployment.md` e la procedura, con i casi in cui serve, nella skill `identita-git`. Lo stile di documentazione e' quello di `.claude/rules/interaction-style.md`. Lo standard di sistema completo e' in `.claude/PROJECT-SYSTEM.md`.

## Regola M30: tracciamento a ogni gate

Per ogni passo della migrazione dei segreti locali, aggiornare nello stesso giro `docs/runbook-migrazione-segreti-locali.md`, ADR-031, SEC-052 (#209), M30, `docs/pendenze-aperte.md`, `docs/infrastructure-timeline/2026-q4-segreti-e-collettore.md` e rigenerare `timeline.svg`; aggiornare `data/iso27001-interventi.json` con `IsoRoadmap.py advance` e verificare HTML `output`, Desktop e archivio ISO. Scrivere esito, evidenza priva di valori, stato del rollback, memoria e resume. Finche' i gate non passano, distinguere sempre il design dall'esercizio.

## Nota MCP

Il server MCP `proxmox` e' configurato in `.mcp.json`, nella radice e mai sotto `.claude/`, sul pacchetto PyPI `proxmox-mcp` via uvx, e autentica solo con un token API di sola lettura che il launcher legge dal `.env` privato: decisione e procedura in ADR-007, cutover M30 del 09/10/2026 in ADR-031. Il file tracciato non contiene valori reali. Il task pianificato è stato osservato il 16/10/2026 con esito 0; richiede la sessione interattiva della postazione. Processo e retention sono descritti in `docs/processo-fonti-vive-retention.md`; attivazione della pulizia e primo giro reale restano da osservare. Per lo snapshot completo resta canonico `scripts/Get-ProxmoxSnapshot.ps1`.
