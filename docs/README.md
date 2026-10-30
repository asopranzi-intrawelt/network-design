# Documentazione della rete

Questa è la porta d'ingresso della documentazione tecnica della rete Intrawelt. È anche la nota iniziale del vault Obsidian, che coincide con la radice del repository: aprendo `D:\network-design` come vault, le cartelle qui sotto compaiono come aree e ogni area si apre dalla propria pagina indice. Il repository è pubblico, quindi indirizzi, persone, clienti e identificativi amministrativi compaiono soltanto come segnaposto; i valori reali e i documenti che non riguardano la rete vivono nel livello privato `_notes/`, che Git ignora.

## Le aree

| Area | Che cosa contiene | Da dove partire |
|---|---|---|
| [Stato e pendenze](stato/README.md) | la fotografia corrente della rete, la mappa interattiva e la vista consolidata di ciò che resta aperto | [snapshot](stato/snapshot-infrastruttura.md) |
| [Rete](rete/README.md) | segmentazione, livello fisico ed elettrico, porte, nomi interni, servizi esposti, collegamento del server | [segmentazione M22](rete/segmentazione-lan-m22.md) |
| [Firewall](firewall/README.md) | il firewall di sede e quello del datacenter, con il registro delle modifiche applicate | [USG FLEX 500](firewall/firewall-zyxel-usg-flex-500.md) |
| [Telefonia](telefonia/README.md) | centralino, VoIP e migrazione al centralino cloud | [telefonia e PBX](telefonia/telefono-pbx-voip.md) |
| [Sicurezza e ISO 27001](sicurezza/README.md) | roadmap ISO, governance, vulnerability assessment, continuità operativa, autorità di certificazione, segreti della postazione | [roadmap ISO](sicurezza/roadmap-iso27001-operativa.md) |
| [Log e osservabilità](osservabilita/README.md) | collettore dei log amministrativi, osservabilità Linux, fonti vive e retention degli snapshot | [integrazione del collettore](osservabilita/log-collector-integrazione.md) |
| [Sito e VPS](sito-vps/README.md) | la VPS esterna del sito, il suo hardening, i nomi e la zona DNS, i runbook di rilascio e di emergenza | [piano di produzione](sito-vps/piano-produzione-sito-nuovo.md) |
| [Operatività](operativita/README.md) | runbook delle anomalie e registro dei fornitori | [runbook delle anomalie](operativita/runbook-anomalie.md) |
| [Timeline degli interventi](infrastructure-timeline/README.md) | la storia della rete per periodi e il registro dei difetti | [SVG interattivo](infrastructure-timeline/timeline.svg) |
| [Archivio](archivio/README.md) | documenti superati, conservati per la storia e non come istruzione | |

Fuori da `docs/` stanno le altre due metà del progetto. Le schede tecniche di stato e la memoria di sessione sono in `.claude/context/` e `.claude/memory/`, con la [roadmap](../.claude/context/roadmap.md) delle fasi e il [registro delle decisioni](../.claude/memory/decisions.md); Obsidian non mostra le cartelle che iniziano con un punto, quindi da qui si raggiungono solo per collegamento. Le fonti dati modificabili sono in `data/`, gli script in `scripts/`.

## Percorsi di lettura

| Domanda | Documento |
|---|---|
| Che cosa è collegato e quanto è verificato? | [Snapshot](stato/snapshot-infrastruttura.md), [mappa](stato/network-map.html) e [guida alla topologia](stato/network-diagram.md) |
| Da che cosa comincio, fra i lavori aperti? | [Fronti di lavoro](stato/fronti-di-lavoro.md), che li ordina e dice che cosa sblocca ciascuno |
| Che cosa resta aperto e quali vincoli ci sono? | [Pendenze consolidate](stato/pendenze-aperte.md), [registro dei difetti](infrastructure-timeline/GAP-TBC.md) e [roadmap](../.claude/context/roadmap.md) |
| Dove stanno cavi, armadi, corrente e porte fisiche? | [Livello fisico ed elettrico](rete/livello-fisico-ed-elettrico.md) e [mappatura delle porte](rete/mappatura-porte-fisiche.md) |
| Come il server e le VM raggiungono la rete? | [Proxmox e bridge](rete/virtualizzazione-proxmox-e-bridge.md) e [servizi esposti](rete/esposizione-servizi-interni.md) |
| Come sono separati oggi i segmenti e come cambieranno? | [Segmentazione M22](rete/segmentazione-lan-m22.md), [firewall](firewall/firewall-zyxel-usg-flex-500.md), [risoluzione dei nomi](rete/risoluzione-nomi-interni.md) e [autorità di certificazione](sicurezza/autorita-certificazione-interna.md) |
| Quali configurazioni del firewall del datacenter conosciamo e quali interventi derivano? | [Firewall Seeweb](firewall/firewall-seeweb-opnsense.md), roadmap M31/M14 e gap 210-214 |
| Quali interventi servono per ISO 27001 e quali richiedono forniture? | [Roadmap ISO 27001 operativa](sicurezza/roadmap-iso27001-operativa.md), generata dal [registro degli interventi](../data/iso27001-interventi.json) |
| Che cosa ha trovato l'ultima verifica di vulnerabilità esterna? | [VA ottobre 2026](sicurezza/vulnerability-assessment-ott2026.md), che sostituisce il [VA novembre 2025](sicurezza/vulnerability-assessment-nov2025.md) come base della riconciliazione |
| Come funziona e come si verifica la sicurezza del MCP Proxmox? | [Dossier tecnico](sicurezza/dossier-sicurezza-mcp-proxmox.md), [registro delle evidenze](sicurezza/evidenze-sicurezza-mcp-proxmox.md) e [runbook M30](sicurezza/runbook-migrazione-segreti-locali.md) |
| Da dove arrivano gli snapshot automatici e come si conservano senza perdere evidenze? | [Processo fonti vive e retention](osservabilita/processo-fonti-vive-retention.md), ISO-41/38 e perimetro della postazione |
| Come osservare le macchine Linux, l'host di inferenza e i loro log da una console? | [Studio Netdata e osservabilità Linux](osservabilita/osservabilita-linux-netdata.md), [runbook del pilota GPU](osservabilita/runbook-monitoraggio-linux.md), M32 e relazione con M29 |
| Perché un servizio raggiungibile può essere guasto, e che cosa deve misurare il presidio? | [Inferenza: la GPU persa al riavvio](osservabilita/inferenza-gpu-persa-al-riavvio.md), ADR-037, M32g e gap 222-223 |
| Quali pannelli Seeweb sono censiti e quali log sono realmente raccolti? | [Sorgenti Seeweb](osservabilita/sorgenti-log-seeweb.md) e [integrazione del collettore](osservabilita/log-collector-integrazione.md) |
| Come si porta il sito nuovo in produzione sulla VPS esterna, e in quale ordine? | [Piano di produzione](sito-vps/piano-produzione-sito-nuovo.md), [registro delle fonti](sito-vps/fonti-produzione-sito-vps.md) e [canale di propagazione dalla VM](sito-vps/sito-nuovo-integrazione.md); i concetti di nomi, zona e hosting stanno in [come funzionano DNS e domini](sito-vps/dns-domini-come-funziona.md), con la [versione illustrata](sito-vps/dns-domini-spiegato-semplice.html) |
| Come si interviene su un caso concreto? | [Runbook delle anomalie](operativita/runbook-anomalie.md) e [continuità operativa](sicurezza/business-continuity-disaster-recovery.md) |
| Come si è arrivati allo stato attuale? | [Timeline degli interventi](infrastructure-timeline/README.md) e [SVG interattivo](infrastructure-timeline/timeline.svg) |

Quando due documenti raccontano date diverse, il registro del fatto e la misura datata hanno precedenza sulla sintesi: la pagina di snapshot indica sempre il proprio limite di verifica.

## Che cosa non sta qui, e perché

Il 26/10/2026 la documentazione è stata riordinata per aree e ripulita di ciò che non riguarda la rete o che non può stare in un repository pubblico. Cinque documenti descrivevano altri progetti o l'operatività interna e sono passati nel livello privato: la scheda del prodotto Prodotto-1, la cronologia dello sviluppo interno, il backlog IT, le procedure di helpdesk e la storia della costruzione del sito, ora in `_notes/progetti-collegati/`. La checklist di ingestione dei documenti OneDrive, che ne cataloga i nomi di file e di cartella, è passata in `_notes/ingestione/`, dove la legge e la aggiorna lo script del delta. I collegamenti verso quei file funzionano solo su una copia di lavoro che ha il livello privato. La tabella che fa corrispondere ogni vecchio percorso al nuovo è nel registro di lavoro, `.claude/memory/progress.md`, alla voce del 26/10/2026.

## Come si aggiorna

La topologia pubblica si corregge nella fonte JSON e si rigenera con `powershell -NoProfile -File scripts/Build-NetworkMap.ps1`, che scrive `docs/stato/network-map.html`. La matrice delle porte è una seconda fonte tracciata derivata dallo snapshot Nebula privato tramite `python scripts/Export-PortMatrix.py`; va aggiornata quando cambia la misura, senza inserire MAC o nomi reali nel repository. Il confronto `python scripts/Test-TopologyDrift.py` legge gli snapshot privati di Nebula e Proxmox e può riportare un verde solo sulle proprietà che controlla. La verifica `python scripts/Test-Anonymization.py` resta necessaria prima del commit documentale.

La roadmap ISO ha una sola fonte modificabile, `data/iso27001-interventi.json`. Quando un intervento avanza o cambia una fornitura, l'agente registra l'evento nella stessa sessione senza richiedere comandi all'utente: `python scripts/IsoRoadmap.py advance` aggiorna la vista `docs/sicurezza/roadmap-iso27001-operativa.md` e rigenera l'export HTML nel progetto, sul Desktop e nella cartella ISO privata di OneDrive. Lo stato `completato` richiede una prova datata. `python scripts/IsoRoadmap.py check` verifica che la vista di progetto sia allineata alla fonte, `build --desktop` ricostruisce a mano tutte le copie e `check --desktop` le confronta. L'export incorpora il logo dalla configurazione privata `_notes/iso-roadmap-brand.json`, include le spiegazioni dei codici da `data/iso27001-glossario.json` e porta le interazioni di `scripts/iso-roadmap-interactions.js`. Gli apparati non interrogabili richiedono una conferma fisica: il registro non può rilevare cambiamenti non comunicati.

La checklist VA Onova privata conserva i 174 rilievi storici. `scripts/Build-OnovaReconciliation.py` aggiunge una fotografia documentale datata allo stesso HTML: `preview` prepara una copia in `output/`, `apply` conserva l'originale e aggiorna la checklist privata, `check` controlla il risultato. La configurazione privata `_notes/onova-reconciliation.json` lega le note alle fonti del progetto; la sintesi pubblica, senza indirizzi reali, è in [VA novembre 2025](sicurezza/vulnerability-assessment-nov2025.md).

La timeline SVG si rigenera da sola a ogni apertura di sessione dai file Markdown di `infrastructure-timeline/`. Nessuno dei tre artefatti generati si modifica a mano: se un dato è sbagliato si corregge la fonte e si rigenera.
