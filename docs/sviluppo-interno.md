# Sviluppo Interno e IT on FIRE – Intrawelt

Cronologia dei progetti di sviluppo interno IT: IntraLino RAG chatbot, scripting,
automazioni, strumenti interni. Owner: Alessio Sopranzi.
Aggiornato: giugno 2026.

---

## IntraLino – RAG Chatbot Aziendale

**Obiettivo**: Chatbot per helpdesk IT interno basato su documenti aziendali (knowledge base),
con dati interamente on-premise (nessun dato inviato a servizi cloud).

**Stack finale (marzo 2026):**
- Ollama (llama3.2) – LLM locale, porta 11500 su Ubuntu, avviato come servizio systemd
- ChromaDB v2 – Vector store locale, porta 8000
- n8n 2.12.3 – Orchestratore workflow (Docker Desktop)
- Knowledge base: documenti PDF da SharePoint
- Embedding: llama3.2 locale (nessun dato verso provider esterni)

### Timeline IntraLino

| Data | Evento |
|------|--------|
| 2024 (fine) | Studio architetture RAG self-hosted: Zep + Ollama + Ubuntu come candidati |
| Q1 2025 | Studio Zep CE come memory server + ChromaDB + LangChain; valutazione ZEP on-prem vs cloud |
| Mar 2025 | Avvio implementazione concreta: Ubuntu VM con Ollama, ChromaDB, n8n |
| Q2 2025 | Primo workflow n8n funzionante: ingest PDF da SharePoint → embedding Ollama → ChromaDB → AI Agent → risposta |
| Set-Dic 2025 | Ottimizzazione pipeline; studio metriche qualità RAG |
| Gen 2026 | Valutazione migrazione da ChromaDB a Zep CE v3 come memory server avanzato |
| 25/03/2026 | Decisione: Zep abortito. Il nodo n8n ufficiale Zep è deprecato dal team n8n (incompatibile con Zep CE v3+). Soluzioni community (n8n-nodes-zep-v3) disponibili ma non adottate. |
| Mar 2026 | Stato dell'arte: sistema funzionante con Ollama + ChromaDB + n8n. Architettura stabile. |
| 2026 (Q2) | [TBC] Valutazione Qdrant come sostituto ChromaDB (coerenza con stack SCENIA) |

### Architettura IntraLino (stato marzo 2026)

```
SharePoint (PDF aziendali)
   │
   │ OAuth2 download
   ▼
n8n workflow (orchestratore)
   │
   ├── Ingest pipeline:
   │   Estrai testo → chunk → embedding (Ollama llama3.2) → ChromaDB /add
   │
   └── Conversational pipeline:
       User query → embedding (Ollama) → ChromaDB similarity search
       → AI Agent (Ollama Chat Model + Simple Memory) → risposta utente
       
Ollama: Ubuntu VM, porta 11500, systemd service
ChromaDB: Ubuntu VM, porta 8000
n8n: Docker Desktop 2.12.3
```

**Caratteristiche di sicurezza:**
- Dati non escono dalla rete Intrawelt (no servizi cloud AI)
- Embedding locale con llama3.2
- Accesso solo da LAN interna

**Limitazioni note:**
- Simple Memory non persistente (reset ad ogni esecuzione n8n)
- Codice JavaScript custom necessario per payload ChromaDB v2
- Nessuna GPU dedicata (inferenza CPU-only → latenze elevate con modelli grandi)
- Zep non adottato (deprecazione nodo n8n)

---

## Scripting e Automazioni IT

### Export giornaliero automatico TM GroupShare

| Campo | Dettaglio |
|-------|-----------|
| Scopo | Export automatico Translation Memory da GroupShare per backup e analytics |
| Stack | Script PowerShell / Python (GroupShare API) |
| Schedule | Giornaliero |
| Output | File TMX in cartella backup NAS |
| Cartella | `Sviluppo_interno/Script e Documentazione per Export Giornaliero Automatico TM GROUPSHARE` |

### Script manipolazione dati traduzione

| Campo | Dettaglio |
|-------|-----------|
| Scopo | Preparazione, manipolazione ed estrazione dati per flussi di traduzione |
| Stack | Python, script batch |
| Cartella | `Sviluppo_interno/Script per preparazioni, manipolazioni e estrazioni di dati da tradurre` |

### Proxmox Snapshot Automation

| Campo | Dettaglio |
|-------|-----------|
| Scopo | Snapshot automatico VM Proxmox, verifica stato VM |
| Script | `scripts/Get-ProxmoxSnapshot.ps1` (PowerShell) |
| API | Proxmox VE REST API (192.168.20.11:8006) |
| Output | `output/proxmox-snapshots.json` (gitignored) |

### Security Anomaly Checker

| Campo | Dettaglio |
|-------|-----------|
| Scopo | Verifica anomalie sicurezza documentate (FW-001, switch mgmt VLAN, UPS, EOL) |
| Script | `scripts/Check-SecurityAnomalies.ps1` (PowerShell) |
| Output | `output/security-anomaly-check.txt` (gitignored) |

---

## Progetti di Studio e Ricerca Interna

### Notes (thinking lab) 12/01/2026

| Campo | Dettaglio |
|-------|-----------|
| Data | 12/01/2026 |
| Contenuto | 18 paragrafi - note di riflessione su sviluppi tecnici (contenuto interno, non estratto per privacy) |
| Percorso | `Sviluppo_interno/Notes (thinking lab) 12012026.docx` |

### OpenProject – Project Management

Studio e implementazione di OpenProject come strumento PM interno.  
Cartella: `Sviluppo_interno/OpenProject/`

### [TBC] Password Manager aziendale

Valutazione e implementazione password manager per team IT.  
Stato: pianificato.

### [TBC] DNS server personalizzato

Studio deployment DNS server su macchina fisica interna.  
Stato: pianificato.

### [TBC] Cheshire Cat AI

Studio framework Cheshire Cat per agente AI conversazionale alternativo.  
Stato: studio.

### Tool AI coding assistance

Studio di tool AI per coding assistance (Copilot/Claude Code).  
Cartella: `Sviluppo_interno/TOOL AI coding assistance/`

---

## Progetto ENI Ruolini (nov 2024)

| Campo | Dettaglio |
|-------|-----------|
| Data | Novembre 2024 |
| Scopo | Progetto specifico cliente ENI – elaborazione ruolini |
| Stack | [TBC] |
| Cartella | `Sviluppo_interno/Progetto ENI ruolini (nov24)/` |

---

## Sviluppo NinjaOne

Automazioni e scripting per NinjaOne RMM.  
Cartella: `Sviluppo_NinjaOne/`  
Contenuto: script personalizzati per monitoraggio, alerting, manutenzione endpoint.

---

## Sviluppo Proxmox

Automazioni Proxmox: snapshot, backup, gestione VM via API.  
Cartella: `Sviluppo_Proxmox/`  
Principale: `scripts/Get-ProxmoxSnapshot.ps1`

---

## Note operative

**Privacy**: Le credenziali nei file `_credenziali*.txt` e `_Piano_Attivita_IT_v3.xlsx`
non vengono mai ingerite nel progetto network-design.

**Architettura di riferimento**: Per la topologia di rete che ospita tutte queste VM
e servizi, vedere `docs/network-diagram.md`.
