# SCENIA – Piattaforma AI di Traduzione Assistita

Documentazione del progetto SCENIA: fullstack SaaS di traduzione automatica e assistita
basata su LLM. Intrawelt ricopre il ruolo di **Responsabile del trattamento (Processor)**
verso i clienti. Partner tecnologico: **AIDAPT S.r.l.** (chatbot Caity).

Owner: Alessio Sopranzi. Aggiornato: giugno 2026.

---

## Cos'è SCENIA

Piattaforma SaaS di traduzione automatica e assistita (CAT + LLM) per clienti B2B, sviluppata
internamente con AIDAPT come fornitore dell'infrastruttura cloud AI.

**Stack tecnologico:**
- LLM: `gpt-4.1` via Azure OpenAI (Azure Sweden Central, SEE)
- Vector store: Qdrant (AWS eu-west-1, Irlanda)
- Auth: Amazon Cognito (AWS eu-west-1)
- Storage: AWS RDS, S3
- CAT/TM: Trados Online (RWS, UK – adequacy decision UE rinnovata 19/12/2025)
- Monitoring: Grafana
- Backend: AIDAPT S.r.l. (infrastruttura AWS Organization dedicata per Intrawelt)
- Sviluppatore esterno: Collaboratore-Esterno-1

**Repository:**
- GitHub: `asopranzi-intrawelt/full_stack_unimc` (privato, accesso tramite account asopranzi-intrawelt)

**Ruoli GDPR:**
- Intrawelt = Responsabile del trattamento (Processor)
- Clienti finali = Titolari del trattamento (Controller)
- AIDAPT, RWS, AWS, Azure = Sub-responsabili

---

## Timeline del progetto

### Fase 0 – Ricerca e ideazione (ott 2024 – mar 2025)

| Data | Evento |
|------|--------|
| Ott 2024 | Prime discussioni con Prof. Emanuele Frontoni (UNIMC/VRAI Lab) su LLM per traduzione. Dataset TMX Intrawelt come base di addestramento. GPTs "intrawert plus" creato su ChatGPT4o per validazione concept. |
| Ott 2024 | Proposta UNIMC: infrastruttura cloud LangChain + LLaMA 3.2 per traduzione e arricchimento contenuti. 3 progetti paralleli (fine-tuning, multi-LLM, SEO stats). |
| 23/10/2024 | Briefing mattinale (TBC: ascolto registrazione) |
| 25/11/2024 | Mail Frontoni: definizione 2 ambiti – Traduzione (core) + Gestione Contenuti (SEO). Richiesta di commercializzazione oltre la ricerca. |
| 26/11/2024 | Alessia Nasini condivide punti di discussione + aggiunta GDPR/proprietà dati |
| 10/12/2024 | Meeting "Progetto di ricerca Intrawelt/UniMc": valutazione startup (rinviata a metà 2025). Frontoni co-founder di Jeff (Civitanova) per interfacce. |
| 18/12/2024 | Meeting "Presentazione Flusso": Francesca presenta flusso di lavoro per workflow traduzione |
| Dic 2024 – Mar 2025 | Progetto 1 UNIMC: Infrastruttura cloud modulare multi-LLM (Frontoni + Sernani + Santini, 25+45 gg/uu) |
| Gen 2025 – Set 2025 | Progetto 2 UNIMC: Ambiente multi-LLM per traduzioni e API (Sernani + Santini, 20+30 gg/uu) |
| Mar 2025 – Dic 2025 | Progetto 3 UNIMC: Statistiche testuali e SEO (Frontoni + Sernani + Santini, 30+50 gg/uu) |

### Fase 1 – Sviluppo con AIDAPT (apr 2025 – dic 2025)

| Data | Evento |
|------|--------|
| Apr 2025 | Avvio tracciamento mensile sviluppo SCENIA (SECURITY folder "00_Aprile 2025") |
| 2025 (Q2-Q3) | Passaggio da architettura UNIMC/LangChain ad AIDAPT come partner industriale |
| 25/08/2025 | Call con Persona-N: integrazione Power Automate / OneDrive per gestione file. Folder "backend_Trados_RWS" creato nella repo `full_stack_unimc`. |
| 08/09/2025 | Merge branch `homepage_superadmin` → main. PR creata e approvata senza conflitti. "Base stabile" post-cleanup. |
| Mag-Dic 2025 | Sviluppo fullstack SCENIA (portale AI): frontend, backend AWS, integrazione Trados, Qdrant Vector Store |
| Set-Dic 2025 | Integrazione Azure OpenAI gpt-4.1, embedding, RAG su Vector Store |
| Dic 2025 | ETSI EN 304 223 V2.1.1 adottato (08/12/2025) – standard sicurezza AI (recepimento nazionale entro 30/09/2026) |

### Fase 2 – Stabilizzazione e compliance (gen 2026 – mag 2026)

| Data | Evento |
|------|--------|
| 27/02/2026 | DRP (Disaster Recovery Plan) AIDAPT rev. 27/02/2026 |
| 30/04/2026 | BCP (Business Continuity Plan) AIDAPT approvato |
| 27/04/2026 | Call AIDAPT – documento riepilogativo prodotto |
| Mag 2026 | Sviluppo SCENIA: tracking mensile (00_Aprile 2025 → 13_Maggio 2026) |
| 27/05/2026 | Meeting AIDAPT (appunti con immagini su Meeting 27.05.2026.docx) |

### Fase 3 – Compliance GDPR/DPA (giu 2026 – in corso)

| Data | Evento |
|------|--------|
| 08/06/2026 | DPA bozza v1.1: inseriti dati AIDAPT S.r.l. da BCP/DRP |
| 11/06/2026 | DPA bozza v1.2: ETSI EN 304 223 V2.1.1 mappato nell'Allegato II §12 |
| 11/06/2026 | DPA bozza v1.3: tempistiche breach allineate a Linee guida EDPB 9/2022 (no soglie rigide) |
| 11/06/2026 | DPA bozza v1.4: salvaguardia dati artt. 9-10 GDPR + Art. 2-bis Obblighi Titolare |
| 11/06/2026 | DPA bozza v1.5: trigger SCC/TIA art. 12.4 + inquadramento AI Act Annex II §12.3 |
| 11/06/2026 | DPA bozza v1.6: propagati fatti confermati AIDAPT in Allegato II (MFA admin, tenant dedicato, SAST/DAST assenti, Qdrant audit log non configurato) |
| 11/06/2026 | DPA bozza v1.7: dati Intrawelt inseriti (sede, P.IVA, legale rappresentante, foro Fermo) |
| Giu 2026 | DPIA ScenIA in progress (edpb_dpia_template_2026_v1_en.docx adattato) |
| 29/06/2026 | DPIA: compilate le sezioni di necessita' ed efficacia (alternative considerate, opzione meno intrusiva) e di proporzionalita' (balancing test); data documento aggiornata al 29.06.2026 |
| 02/07/2026 | Allegati contrattuali scorporati in file separati A-K (piu' schema L definito); DPIA "ultima versione" consolidata; ricevute le Risposte Tecniche AIDAPT (chiude l'item ALTA che risultava da cercare) |
| 06/07/2026 | Call AIDAPT: quantizzazione Qdrant, RAM a 32 GB, igiene della Knowledge Base, seconda collezione per la specific knowledge (vedi sezione dedicata) |
| **Pending** | Completare placeholder Parti DPA per ciascun contratto (canale supporto, referente escalation, anagrafica Titolare); negoziare massimali (Allegato J: nessun massimale previsto, regole ordinarie art. 82 GDPR e 1229 c.c.) |

---

## DPIA ScenIA — stato al 02/07/2026

La DPIA (base: template EDPB 2026) non e' piu' un template vuoto: le sezioni
valutative centrali sono compilate. La valutazione di necessita' documenta le
alternative considerate e le scelte meno intrusive adottate: modalita' di
traduzione diretta in-memory senza persistenza come default; memoria di
traduzione opt-in segregata per organization_id (e, dalla versione ultima,
anche per argument); modalita' "common organization" confermata da AIDAPT per
tradurre da esempi condivisi senza caricare documenti propri; provider LLM in
stateless/Zero Data Retention senza training sui dati; trattamento solo SEE
(AWS eu-west-1, Azure Sweden Central; Bedrock non attivo) con unico
trasferimento verso il Regno Unito (RWS/Trados) coperto da decisione di
adeguatezza UE valida fino al 27/12/2031, senza necessita' di SCC. Il
balancing test conclude per la proporzionalita': nessuna profilazione ne'
decisione automatizzata con effetti giuridici, severita' tipica bassa-media
per contenuti B2B, alta solo in caso di dati art. 9 accidentali, mitigata da
esclusione contrattuale, filtro PII lato client (PLANNED) e misure tecniche.
Nelle misure e' entrata la non-ritenzione del contenuto tradotto con
cancellazione automatica delle Translation Unit dopo la generazione. Il
documento resta materiale di lavoro e non sostituisce il parere legale.

---

## Call AIDAPT 06/07/2026 — Qdrant e Knowledge Base

Fonte: `SCENIA/Useful Resources/call aidapt 6.7.2026.docx`. Sul fronte
infrastrutturale AIDAPT ha introdotto la quantizzazione per alleggerire il
carico su Qdrant nella ricerca degli esempi di traduzione e ha scalato
l'istanza a 32 GB di RAM; la versione 18 di Qdrant portera' la quantizzazione
turbo a 2 bit, con il vettore principale diviso in tre parti e le informazioni
principali concentrate nella prima.

Sul fronte della qualita' dei dati resta aperta la domanda se abbia senso
inserire tutti i segmenti nella Knowledge Base: a oggi circa lo 0,1 per cento
dei punti su Qdrant e' costituito da soli link. Le strade discusse sono la
pulizia con tecniche deterministiche standard (regex) oppure l'appalto del
lavoro a un agente AI, valutando ogni punto sia nelle sue caratteristiche
proprie sia in relazione agli altri (case sensitivity, numeri, caratteri
speciali). Per la specific knowledge i referenti AIDAPT (Referente-AIDAPT-1 e
Referente-AIDAPT-2) hanno consigliato una seconda collezione dentro la stessa
istanza Qdrant, perche' l'aggiunta di documenti nella specific knowledge mette
in difficolta' la collezione principale: in una traduzione con specific
knowledge le Translation Unit si pescano prima dalla collezione dedicata, con
la collezione principale come fallback.

## Checklist operativa caricamento nuovo customer (01/07/2026)

Fonte: `SCENIA/Checklist caricamento nuovo customer su Scenia.docx`. La
checklist interna per l'onboarding di un nuovo cliente sulla piattaforma
richiede sei elementi: combinazione linguistica, organigramma aziendale con le
email, project manager da associare, settori, nome esatto del customer e
documentazione del portale da consegnare al cliente.

---

## Gap di sicurezza SCENIA identificati (al 11/06/2026)

| Gap | Severity | Stato |
|-----|----------|-------|
| SAST/DAST assenti nel CI/CD | ALTA | Confermato assente da AIDAPT |
| VA/PT mai eseguiti | ALTA | Confermato assente |
| Qdrant audit log non configurato | ALTA | Gap noto, ETA da AIDAPT |
| API rate limiting non implementato | MEDIA | Gap noto, ETA incerta |
| Test di ripristino backup non documentati | MEDIA | Da confermare con AIDAPT |
| PII filter (mascheramento dati in segmenti) | MEDIA | PLANNED |
| Firma GPG/SSH commit non attiva | BASSA | Parziale |
| Separazione dev/staging/prod | BASSA | Da confermare |

---

## Parti coinvolte

| Soggetto | Ruolo | Contatto |
|----------|-------|---------|
| Intrawelt S.a.s. | Responsabile del trattamento, sviluppo prodotto | privacy@intrawelt.com, Persona-A |
| AIDAPT S.r.l. | Sub-responsabile, infrastruttura AWS/Azure | help@caity.it |
| Alessio Sopranzi | IT Manager, responsabile compliance GDPR/sicurezza lato IT | asopranzi@intrawelt.com |
| Francesca | Processo workflow traduzione | |
| Alessia Nasini | Coordinamento, GDPR, dati clienti | anasini@intrawelt.com |
| Collaboratore-Esterno-1 | Sviluppatore esterno fullstack | |
| Prof. Frontoni / VRAI Lab (UNIMC) | Partner accademico originario (fase 0) | |
| GAIA S.r.l. | Consulenza AI compliance (spin-off UNIMC, Benedetta Giovanola) | |

---

## SLA dichiarati da AIDAPT

| Tipo | SLA |
|------|-----|
| Uptime infrastruttura | ≥ 99.0% annuale |
| RPO | < 24 ore |
| RTO | 8-12 ore |
| Supporto Critica | 2 ore (09:00-18:00 CET) |
| Supporto Alta | 4 ore |
| Supporto Media | 8 ore |
| Supporto Bassa | 24 ore |
| Rilascio ciclo | Trimestrale; bugfix urgenti fuori ciclo |
| Preavviso modifiche impattanti | ≥ 7 giorni |

**Service Credit (da Allegato E DPA):**
| Uptime | Credito |
|--------|---------|
| 98.0–98.9% | 5% |
| 95.0–97.9% | 10% |
| < 95% | 20% |
Cap massimo annuo: 20%.

**Esclusioni SLA:** malfunzionamenti AWS/Azure/OpenAI, superamento flussi LLM o
mancata ricarica credito, manutenzioni programmate, errori logici modelli (allucinazioni).

---

## Documenti di riferimento

| Documento | Percorso |
|-----------|---------|
| CLAUDE.md (contesto sessione DPA) | SCENIA/SECURITY/DPA/CLAUDE.md |
| DPA bozza v1.7 | SCENIA/SECURITY/DPA/DPA_ScenIA_Intrawelt_v1.0_bozza.md |
| DPIA ScenIA (in lavorazione) | SCENIA/SECURITY/DPA/Copia di edpb_dpia_template_2026_v1_en_scenia.docx |
| BCP AIDAPT | SCENIA/SECURITY/DPA/Caity_BCP (1).pdf |
| DRP AIDAPT | SCENIA/SECURITY/DPA/Caity_DRP (4).pdf |
| Questionario AIDAPT (da inviare) | SCENIA/SECURITY/DPA/Questionario_AIDAPT_misure_sicurezza_2026-06-11.md |
| Meetings con AIDAPT | SCENIA/MEETINGS WITH AIDAPT.docx |
| Call AIDAPT 27/04/2026 | SCENIA/Documento Riepilogativo Call AIDAPT 27042026.docx |

---

## Meeting DPIA/DPA – 27/05/2026

Sessione di lavoro tecnico su DPIA ScenIA (template EDPB v1.0). Presenti: Alessio + AIDAPT.

**Architettura e flussi SCENIA:**
- Rotta "translate diretta": traduzione senza passaggio per vector store per documenti usa-e-getta
  (load → vector store solo per documenti da riutilizzare come knowledge base)
- Logica ottimizzazione punti Qdrant: eliminazione punti con <4 caratteri, filtraggio caratteri speciali
- Segregazione: i dati di ogni organizzazione sono logicamente separati nel vector store

**GDPR / DPIA – Dati trattati:**

| Categoria | Scopo | Storage limitation |
|-----------|-------|--------------------|
| Documenti da tradurre (.sdlxliff, testo) | Traduzione | Rotta translate non salva; altri rimangono → serve meccanismo eliminazione esplicita |
| Mail e hint utente | Traduzione e context | Data minimization applicabile |
| Dati aziendali (P.IVA, telefono, mail) | Registrazione | Limitare al minimo |
| Knowledge base (segmenti validati) | RAG per traduzioni contestuali | Conservazione necessaria; diritto all'oblio supportato |
| Feedback utente | Miglioramento qualità | Separare da dati traduzione |

**Principi GDPR e stato:**

| Principio | Stato | Note |
|-----------|-------|------|
| Trasparenza | Da implementare | Dialog "Carica" con spiegazione trattamento dati; "Non mostrare più" successivo |
| Limitazione di conservazione | Parziale | Rotta translate OK; documenti "test" rimangono senza scadenza |
| Minimizzazione | Pianificato | Non raccogliere dati aziendali non necessari; data minimization su segmenti |
| Accuratezza | OK | RAG su esempi validati da linguisti + post-validazione umana |
| Diritto all'oblio | Supportato | Eliminazione documenti singoli da interfaccia |
| Portabilità | Da implementare | Export documenti caricati (almeno per documento singolo) |
| Diritto alla rettifica | Da verificare | Eliminazione documento caricato in precedenza |

**PII Filter (OpenAI Privacy Filter):**
- Algoritmo LLM che riconosce e maschera dati personali (nomi, dati biometrici, ecc.) in testo
- Stato: **PLANNED** – da abilitare come opzione utente (default on/off da decidere)
- Disponibile come open source su HuggingFace: https://huggingface.co/spaces/openai/privacy-filter
- Supporta italiano e multilingual; funziona anche su portatile (leggero)
- Alternativa: NLP classica senza LLM (meno precisa per nomi propri contestuali)

**Rischio principale identificato:**
Il meccanismo RAG crea un canale potenziale di diffusione dati: segmenti di un documento di
organizzazione A potrebbero essere usati come contesto per tradurre documenti di organizzazione B.
Mitigazione: segregazione logica Qdrant per organizzazione è architetturale; l'LLM riceve in
prompt esplicito che gli esempi servono solo come contesto, non arricchiscono il documento.
L'impatto è limitato: singoli segmenti non contengono informazioni auto-contenute.

**Documento DPIA:**
- Template EDPB v1.0 2026 in compilazione (DPIA_SCENIA_2026.docx)
- Sezione 2 (analisi) da rivedere con avvocato
- Privacy policy utente da scrivere (spiega come funziona il trattamento)
- DPO: non obbligatorio per Intrawelt

**Aggiunto al riferimento documenti:** `SCENIA/SECURITY/DPA/Meeting 27.05.2026.docx`

---

## Dati Intrawelt per DPA ScenIA (compilati 11/06/2026)

Da `Domande_interne_Intrawelt_2026-06-11.md` — risposte già inserite da Intrawelt.

| Campo | Valore |
|-------|--------|
| Ragione sociale | Intrawelt di Persona-A & C. s.a.s. |
| Sede legale | Via Elpidiense 14, 63821 Porto Sant'Elpidio (FM) |
| P.IVA | Non riportata per policy amministrativa |
| Legale rappresentante | Persona-A |
| Referente privacy | Persona-A — privacy@intrawelt.com |
| DPO | Persona-A (designato internamente; soglia art. 37 da verificare con legale) |
| Foro competente | Fermo |
| Massimali responsabilità | Nessun cap proposto (no limite ex art. 82 GDPR) |
| Retention log/cronologie | 1 anno (standard dichiarato ai clienti) |
| Comunicazione cambi sub-responsabili | Email ai referenti dei clienti |
| Linguisti terzi HitL | Sì, tutti in UE |
| Avvio servizio ScenIA | Aprile 2026 |
| Team DPIA | Persona-A (DPO, CEO, Referente) |
| Prima stesura DPIA | 11/06/2026 |

**Pending blocchi DPA firma:** A1-A4 (dati Intrawelt ✅ completati), E1-E2 (dati Cliente, per ogni contratto),
B2 massimali (nessun cap), C3 trasparenza AI Act art. 50, C4 informativa utenti, D2-D3 AI Act + revisione legale.

---

## Requisiti di Sicurezza a AIDAPT — aree a/b/c/d (giu 2026)

Da `SCENIA/SECURITY/Condivisione con AIDAPT/a), b), c), d)/` — note Intrawelt con i
requisiti tecnici da formalizzare per scritto da AIDAPT.

**a) Sicurezza applicativa:** cifratura E2E TLS 1.2/1.3 (client→API→LLM) e a riposo (KMS?);
IAM con least privilege, rotazione chiavi, chiavi separate per DB/vector store/backup;
multitenant isolation: backend deve impedire interrogazione risorse di altro cliente;
protezione rotte API (token temporizzati, replay attack, rate limiting, lock per brute force);
SAST sul codice sorgente, DAST sull'applicazione in esecuzione; SDLC sicuro (branch protection,
dipendenze/CVE patching continuo).

**b) Sicurezza operativa:** audit trail e supervisione eventi (eventuale SIEM/SOC); backup con
dettaglio per ogni componente (RDS, vector store, S3, config, segreti): tecnologia, verifica
integrità (checksum/hash), versionamento, account separati, retention + cancellazione alla
scadenza, test di restore periodici; RPO/RTO concordati; modello responsabilità AIDAPT vs AWS;
differenziazione backup operativi / compliance / DR; log audit delle operazioni di backup.

**c) Governance del dato:** classificazione dati + regole conservazione per categoria; versioning
glossari/TM; onboarding/offboarding clienti con garanzie di cancellazione reale; auditabilità
verso clienti; gestione richieste interessati (artt. 15-22 GDPR); documentazione data breach;
registro trattamenti formalizzato.

**d) LLM security e governance:** prompt hardening (separazione system/developer/user prompt,
sanitizzazione input); validazione output e controlli hallucination (confidence scoring RAG);
versioning prompt + test regressione dopo update modelli; filtraggio contesto vector store
prima dell'LLM; logging sicuro interazioni (prompt, contesto, output, metadata — senza PII
e senza segreti); retention log LLM separata da dati applicativi; limiti etici documentati;
monitoraggio drift comportamentale modelli.

> **Nota:** AIDAPT è responsabile della sicurezza applicativa in quanto sviluppatori
> delle rotte API — non sufficiente dire "è tutto su AWS". Il cliente finale B2B verrà
> a chiedere queste garanzie e Intrawelt dovrà rispondervi in quanto erogatore del SaaS.

---

## Risposte Tecniche AIDAPT (allegato tecnico, ricevute — estratto in DPA/extracted)

Documento di risposta di AIDAPT ai requisiti a/b/c/d, perimetrato al backend
e all'infrastruttura AWS secondo il modello di responsabilita' condivisa
(Intrawelt: autenticazione utenti finali, UI, logica frontend; AIDAPT:
backend traduzione e AI). Punti salienti: tenant dedicato con AWS
Organization autonoma per Intrawelt (segregazione a livello di account, non
solo logica; chiavi di cifratura non condivise); cifratura AES-256 su RDS e
SSE-S3 su snapshot Qdrant, TLS >= 1.2 in transito con endpoint LLM in region
europee; API key dedicate con rotazione e JWT via Cognito per la dashboard;
rate limiting dichiarato "in deploy nella prossima release"; CI/CD con
linting e test piu' Dependabot per le CVE; log centralizzati su Grafana di
natura tecnica senza payload (niente PII nei log); backup giornalieri
application-consistent con retention tecnica 7 giorni RDS e 10 giorni Vector
Store; RPO < 24 ore e RTO 8-12 ore lavorative da DRP; garanzia No Training
sancita dal DPA (Art A.5.3) con accordi Enterprise Zero Data Retention verso
i provider; filtri contenuti nativi (Azure Content Safety); notifica breach
a Intrawelt entro 48 ore dalla conoscenza; export via API dei glossari e
primitive di cancellazione puntuale e massiva per organizzazione.

Nota di riconciliazione: la retention tecnica dei backup dichiarata qui
(7/10 giorni) e' piu' stretta dei 60 giorni massimi di rotazione indicati
nell'Allegato I; e la notifica breach "entro 48 ore" e' piu' specifica dello
standard EDPB 9/2022 "senza ingiustificato ritardo" recepito nel DPA. Da
armonizzare in sede di consolidamento contrattuale.

## Questionario AIDAPT — Stato 30 punti (precompilato 11/06/2026)

`Questionario_AIDAPT_PRECOMPILATO_2026-06-11.md` — NON è risposta AIDAPT: ricostruzione
Intrawelt da documenti ricevuti (RT 9/02/2026, RM 19/02/2026, SLA, DRP, BCP, DPIA meeting).

**Sintesi: ✅ 1 / ⚠️ 11 / ❌ 18**

| Area | # | Punto | Stato |
|------|---|-------|-------|
| Cifratura | 1 | Rotazione chiavi AWS KMS | ⚠️ Segregate per account, policy rotazione non esplicitata |
| Cifratura | 2 | Filtro PII | ❌ PLANNED, non attivo |
| Accessi | 3 | MFA amministrativa | ✅ Attiva su infrastruttura |
| Accessi | 4 | PAM / just-in-time | ❌ Non trattato |
| Accessi | 5 | Revoca credenziali personale cessato | ❌ Non trattato |
| Accessi | 6 | Separazione dev/staging/prod | ❌ Non risposto da AIDAPT |
| Riservatezza | 7 | Policy interne + revisione | ⚠️ Esistono, frequenza revisione non indicata |
| Riservatezza | 8 | Formazione protezione dati | ❌ Non trattato |
| Riservatezza | 9 | Formazione AI-security (ETSI) | ❌ Non trattato |
| Riservatezza | 10 | Separazione compiti dev/ops | ❌ Least privilege dichiarato, segregazione formale non dettagliata |
| Integrità | 12 | Audit log Qdrant | ❌ Gap confermato — docker default, ETA non fornita |
| Integrità | 13 | Audit log modifiche system prompt (ETSI) | ❌ Non trattato |
| Disponibilità | 14 | Test ripristino periodici | ❌ Backup app-consistent dichiarati, test restore non menzionati |
| Disponibilità | 15 | Rate limiting API | ⚠️ Non implementato; ETA in conflitto tra documenti |
| Disponibilità | 16 | DRP adattato ad attacchi IA (ETSI) | ⚠️ DRP esiste, non tarato su IA-specific |
| Sviluppo | 17 | SAST / DAST | ❌ Assente (confermato da RM §5) |
| Sviluppo | 18 | Patch management / dipendenze | ⚠️ Dependabot attivo, code review obbligatorie, no SLA patching formale |
| Sviluppo | 19 | Procedura rollback formale | ❌ Non trattato |
| Sviluppo | 20 | Supply chain / SBOM (ETSI) | ⚠️ Dependabot, no SBOM formale |
| Sviluppo | 21 | Vulnerability disclosure policy (ETSI) | ❌ Non trattato |
| Test | 22 | VA / Penetration test | ❌ Nessun pentest menzionato |
| Test | 23 | Threat modelling IA (ETSI) | ❌ Non fornito |
| Test | 24 | Robustezza adversariale (ETSI) | ⚠️ Prompt hardening + Azure Content Safety; no valutazione formale |
| Test | 25 | Inventario asset IA (ETSI) | ⚠️ System Card documenta modelli; inventario formale non confermato |
| Monitoraggio | 26 | Monitoraggio drift / data poisoning (ETSI) | ❌ Solo Grafana infrastrutturale |
| Monitoraggio | 27 | Cancellazione sicura backup | ⚠️ Proposta registro cancellazioni ~1gg lavorativo, non attivo |
| Monitoraggio | 28 | Casi d'uso vietati / limiti (ETSI) | ⚠️ Questionario esclusione art.9, Azure Content Safety; comunicazione formale mancante |
| Notifica | 29 | Tempistiche breach (allineamento) | ❌ DRP §6 = 48h fissa vs "senza ingiustificato ritardo" |
| Notifica | 30 | Momento T₀ della "conoscenza" | ❌ Incerto senza audit log Qdrant |

**3 discrepanze da riconciliare prima di aggiornare il DPA:**
1. **Retention backup:** RT = 7-10 gg; DRP §4 = 60 gg → NON aggiornare All. II finché non chiarito
2. **Rate limiting ETA:** RT = "prossima release"; RM = "non pianificato prossimo rilascio (apr 2026)" → confermare
3. **Modello tenant:** DRP = multi-tenancy logico; RT §2.2 = AWS Organization dedicata → dichiarare "segregazione infrastrutturale a livello di account + separazione logica organization_id" (non "isolamento fisico")

**Fatti confermati → All. II DPA:**
- MFA admin ✅; KMS segregate per account tenant dedicato; AWS Organization dedicata Intrawelt
- Code review obbligatorie PR; secret via GitHub Actions Secrets; Dependabot CVE monitoring
- Commit GPG/SSH **non firmati** (gap confermato); SAST/DAST **assenti** (confermato)
- Bedrock non attivo; tutto in UE (eu-west-1 + Sweden Central); ZDR Azure OpenAI dichiarato

---

## Memo Notifica Violazioni — Catena breach ScenIA (11/06/2026)

```
AIDAPT (Sub-resp.) ──▶ Intrawelt (Resp.) ──▶ Cliente (Titolare) ──▶ Autorità
   art. 33(2) GDPR       art. 33(2) GDPR       art. 33(1): 72h
```

**Problema nel DRP §6:** soglia fissa "48h" → può erodere le 72h del Titolare verso l'Autorità.

**Soluzione DPA v1.3:** tutto allineato a "senza ingiustificato ritardo" (EDPB Linee guida 9/2022).
Le indicazioni orarie restano obiettivi operativi interni non vincolanti.

**Azioni richieste ad AIDAPT (da Memo 11/06/2026):**
1. Aggiornare DRP §6 → "senza ingiustificato ritardo"
2. Recepire clausola breach back-to-back nel DPA Intrawelt–AIDAPT
3. Notifica con contenuto minimo art. 33(3) + possibilità integrazioni progressive
4. Indicare referente e canale dedicati (email/PEC + reperibile urgente)
5. Fornire log e supporto tecnico su richiesta Intrawelt

**Punto aperto:** T₀ della "conoscenza" incerto finché audit log Qdrant non configurato
→ AIDAPT deve chiarire come rilevano e datano una violazione su backend/RDS/S3/Qdrant.

---

## FAQ portale ScenIA (documento clienti)

Fonte: `SCENIA/FAQ portale AI.docx` (25 KB)

Documento di supporto commerciale/utente. Punti chiave:

| # | Domanda | Risposta sintetica |
|---|---------|-------------------|
| 1 | Tempi dipendono dalla lunghezza? | Sì, parzialmente. Dipende anche dal formato e dai servizi (post-editing, revisione). |
| 2 | Formati supportati? | Tutti i formati diffusi. PDF/Excel: raccomandato pre-processing. |
| 3 | Affidabilità traduzione automatica? | Molto elevata su contenuti standardizzati. Consigliato post-editing umano per contenuti critici. |
| 4 | Sicurezza vs motori pubblici? | LLM riceve solo unità di traduzione isolate; dati non conservati né usati per training; isolamento per cliente. |
| 5 | Modello di costo? | A crediti: prevedibile, scalabile. Crediti acquistati contattando customer service. |
| 6 | Integrazione con PIM industriale? | Sì, via connettori API dedicati (sviluppo custom). |
| 7 | Vantaggi vs gestione interna? | Standardizzazione terminologia, automazione, tracciabilità, scalabilità multi-lingua. |
| 8 | Coesistenza con fornitori tradizionali? | Sistema si affianca al fornitore tradizionale per volumi ricorrenti; il fornitore rimane per contenuti critici. |
| 9 | Crediti inutilizzati scadono? | No, rimangono per tutta la durata dell'abbonamento. Extra crediti disponibili a condizioni agevolate. |
| 10 | ROI vs spesa storica? | Sistema progettato per ridurre costo medio su volumi standard; difficile superare la spesa storica annuale. |

---

## Stato attuale (giugno 2026)

Il prodotto ScenIA è in produzione. La compliance GDPR (DPA con clienti, DPIA) è in fase
finale di redazione. I gap di sicurezza tecnici (SAST/DAST, VA/PT, Qdrant audit log) sono
stati identificati e portati all'attenzione di AIDAPT tramite questionario formale.
Il DPA richiede completamento dei placeholder delle Parti (dati Cliente per ogni contratto)
e negoziazione dei massimali di responsabilità prima della firma.

**Pending DPIA (post-meeting 27/05/2026):**
- Scrivere privacy policy per utenti ScenIA (trasparenza trattamento)
- Implementare meccanismo eliminazione esplicita documenti "test" (storage limitation)
- Implementare PII filter come opzione utente (planned)
- Aggiungere diritto portabilità (export documenti caricati)
- Completare sezione 2 DPIA con avvocato (analisi legal)

---

## Infrastruttura VPS SCENIA (Aruba Cloud)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx`

### VPS produzione

| Parametro | Valore |
|-----------|--------|
| Provider | Aruba Cloud (ID ARU-340414) |
| Piano | O2A4 |
| CPU | 4 vCPUs |
| RAM | 8 GB |
| Storage | 80 GB |
| Data transfer | 50 TB/mese (in + out) |
| OS | Ubuntu 22.04 LTS |
| IP pubblico | 80.211.141.50 |
| Hypervisor | OpenStack (Aruba-managed) |

**Stack applicativo:**
- Nginx (reverse proxy, HTTP 80 → Next.js 3000)
- Next.js / TypeScript (portale ScenIA)
- Certbot (TLS, chiavi in /etc/letsencrypt/live e /archive → incluse nel backup VPS)

### VPS staging

| Parametro | Valore |
|-----------|--------|
| Piano | O2A4 (piano simile a produzione) |
| IP pubblico | 93.186.255.24 |
| Ruolo | staging-portal.scenia.it (proxato Cloudflare) |

### Backup VPS

Ticket Aruba **18346774A** (13/02/2026): analisi opzioni backup.
- Backup disponibile tramite funzionalità cloud Aruba (guida kb.cloud.it/public-cloud/backup)
- INIZIALIZZA: reset a stato iniziale (perde tutti i dati)
- Codice sorgente: GitHub (asopranzi-intrawelt/full_stack_unimc → Intrawelt-SaaS organization)
- Priorità: backup DB + dati caricati (file); codice su GitHub

---

## Architettura domini scenia.it (stato aprile 2026)

Dominio registrato su Register.it il 03/02/2026 (registrante: Alessandro Potalivo
per Intrawelt Di Alessandro Potalivo & C. Sas, ragione sociale registrata come
tale nel WHOIS; stato iniziale `inactive, dnsHold` fino al completamento della
procedura), scadenza 03/02/2027 con rinnovo automatico attivo. Nameserver
delegati a Cloudflare (kaiser.ns.cloudflare.com, tara.ns.cloudflare.com).

| Sottodominio | IP / Destinazione | Ruolo |
|-------------|-------------------|-------|
| scenia.it | 80.211.141.50 | Sito istituzionale (one-page, vendor management) |
| portal.scenia.it | 80.211.141.50 | Portale produzione → Trados Accelerate (Flowhandler) |
| contact.scenia.it | 80.211.141.50 | Landing form contatti (design Attilio) |
| staging-portal.scenia.it | 93.186.255.24 | Portale staging (proxato Cloudflare Zero Trust) |
| scenia.intrawelt.com | wildcard cert intrawelt.com | Landing interna sito Intrawelt (TBC) |

Nota (09/07/2026): il certificato *wildcard* di `intrawelt.com` presso Fastnet
e' stato riemesso **senza wildcard** l'11/05/2026 per un limite tecnico Plesk
(vedi `vendor-management.md` §Fastnet). Se `scenia.intrawelt.com` dipende
ancora dal wildcard di `intrawelt.com`, va verificato che il certificato
attuale copra effettivamente questo sottodominio.

---

## Security Architecture SCENIA VPS (post-Collaboratore-Esterno-1, 2026)

Fonte: `SCENIA/SECURITY/DPA/SaaS security.docx` — decisione architetturale 11/05/2026.

### Cloudflare Zero Trust (Free)

- cloudflared daemon installato su VPS
- Porte 80/443 chiuse con `ufw deny` → unico canale HTTP = tunnel Cloudflare
- IP server mascherato: attacchi DDoS diretti non raggiungono la VPS
- Team name: scenia.cloudflareaccess.com

### Controlli accesso

- SSH: solo chiavi ED25519 (root login disabilitato), porta consentita solo da
  IP Intrawelt pubblico e IP Collaboratore-Esterno-1 (IP nella mappa locale)
- Fail2Ban: ban automatico dopo 3-4 tentativi SSH falliti
- ufw: policy DROP su input/forward, ACCEPT su output (eccetto regole esplicite)

### Email transazionale

- Provider: Mailtrap (form contatto sito, webhook portale)
- Register.it: piano a 5.000 invii/giorno valutato come alternativa (costo non riportato)

### Audit

- Lynis: tool di auditing OS VPS
- pnpm audit: scansione dipendenze npm periodica

---

## CVE History SCENIA (2026)

| Data | CVE | Componente | CVSS | Impatto | Fix |
|------|-----|-----------|------|---------|-----|
| Gen 2026 | CVE-2025-66478 / CVE-2025-55182 | React.js / Next.js | 10.0 (critical) | Server-side RCE via React Server Components | Migrazione versione patchata + rotazione credenziali. Fine gen 2026. |
| Feb 2026 | CVE-2026-23864 | Next.js App Router (RSC) | Alta | DoS remoto: deserializzazione HTTP non limitata → OOM/CPU spike | Next.js ≥ 16.1.5 |
| Feb 2026 | CVE-2025-59471 | Next.js Image Optimizer | Alta | Memory bomb: arrayBuffer() scarica file intero prima di validare | Next.js ≥ 16.1.5 (streaming + size limit) |

Processo: `pnpm audit` + monitoraggio advisory nextjs.org e NVD.

---

## Descrizione Servizio ScenIA (Allegato B DPA)

Workflow end-to-end:
```
UI → Backend Intrawelt → Trados Online → API AIDAPT → gpt-4.1 → Ritorno → Trados Online → UI
```

**Due modalità di traduzione:**

| Modalità | Attivazione | Stack |
|----------|-------------|-------|
| Automatica | Cliente NON seleziona servizi aggiuntivi | gpt-4.1 + memory vettoriale Qdrant |
| Assistita (Human-in-the-Loop) | Cliente seleziona almeno un servizio aggiuntivo | OM/PM umano + linguisti madrelingua + Trados |

**Vector Store (Qdrant):**
- Interrogato ad ogni invocazione del modello (memory non disattivabile dall'utente)
- Metadata: trans_unit_id, document_id, language, argument, organization_id, content_hash
- Nessun audit log Qdrant configurato

**Logging e conservazione:**
- Tracciati: progetti, upload, traduzioni, PM, task memory, glossari, cancellazioni
- Conservazione Trados: 90 giorni → eliminazione automatica
- AIDAPT non accede ai contenuti dei progetti di traduzione

**Limiti attuali:**
- Rate limiting non ancora implementato (nessuna ETA)
- Nessun audit log Qdrant
- Retention backup non configurabile da Intrawelt

---

## Change Control ScenIA (Allegato G DPA)

Canale CR: **help@caity.it**

| Voce | Dettaglio |
|------|-----------|
| Classificazione CR | Bug vs Feature (no classificazione minor/major/breaking formale) |
| Ciclo rilascio | Trimestrale (4 rilasci/anno); bugfix urgenti fuori ciclo |
| Preavviso impatto | ≥ 7 giorni |
| Changelog | Fornito dopo ogni rilascio |
| Analisi CR | Sviluppatore specializzato AIDAPT: fattibilità + effort (gg/uomo) |
| Costo bugfix | A carico AIDAPT (zero per Intrawelt) |
| Costo nuove funzionalità | Plafond annuale Intrawelt; stima gg/uomo da validare |
| Test | Solo test funzionali interni; no SAST/DAST, no staging formale |
| Rollback | Non fornito da AIDAPT (gap DPA) |

Nota: Intrawelt è su macchina dedicata → modalità flessibili concordabili caso per caso.

---

## Sub-processor SCENIA (Allegato K DPA)

| Sub-processor | Funzione | Regione AWS/Azure |
|---------------|----------|-------------------|
| AWS | Hosting core, RDS (PostgreSQL), S3, Cognito, Vector Store (Qdrant) | eu-west-1 (Irlanda) |
| Azure OpenAI | LLM (gpt-4.1), embedding | Sweden (EU) |
| Amazon Bedrock | Potenziale provider LLM futuro | EU (non attivo) |

**Definizioni chiave (Allegato A DPA):**

- **Zero Data Retention (ZDR)**: Azure OpenAI stateless per default; abuse monitoring
  NON disattivato nel setup AIDAPT (richiede approvazione Microsoft).
- **Abuse Monitoring**: disattivazione completa richiede approvazione MS, non ancora
  attiva → dato di traduzione transitoriamente accessibile per monitoring Azure.
- **Memory / Qdrant**: similarity search injectata nel prompt ad ogni invocazione;
  non disattivabile dall'utente finale.

---

## Allegati contrattuali separati A-L (02/07/2026)

Il 02/07/2026 gli allegati del contratto ScenIA sono stati scorporati in
file autonomi sotto `SCENIA/SECURITY/Allegati/` (A Definizioni, B
Descrizione servizio, E SLA, F Supporto, G Change Control, H Sicurezza, I
Backup/Retention/DR, J DPA, K Subprocessor; lo schema complessivo in
`definizioni allegati.txt` prevede anche C Trial, D Prezzi e L
Audit/certificazioni). B, E, G e K erano gia' documentati nelle sezioni
dedicate di questa scheda; i contenuti nuovi sono F, H, I e J.

Allegato F, supporto tecnico: orario 9-18 CET lun-ven con eventuale
reperibilita' H24 per severita' critica; escalation a tre livelli (supporto
Intrawelt, team tecnico del gestore del framework, management) con trigger
automatico al superamento dei tempi; matrice severita' S1-S4 con risposta
2/4/8/24 ore e obiettivi di risoluzione da 8 ore lavorative (S1, workaround)
a 10 giorni (S4). Canale di supporto e referente escalation restano
placeholder da completare per contratto.

Allegato H, sicurezza: consolida le TOM lungo la catena Intrawelt/AIDAPT con
i gap dichiarati in trasparenza: rate limiting applicativo non implementato,
audit log Qdrant non configurato, SAST/DAST assenti, commit non firmati,
nessun VA/PT formale eseguito, nessuna certificazione formale (percorso in
corso). MFA utenti finali e filtro PII lato client sono esplicitamente in
carico a Intrawelt/Cliente. Allineamento volontario a ETSI EN 304 223.

Allegato I, backup e DR: backup giornalieri cifrati nel SEE con rotazione a
60 giorni massimi non configurabile; progetti Trados eliminati dopo 90
giorni, log 90 giorni, TU e glossari per la durata contrattuale cancellabili
per organization_id; diritto all'oblio sui backup gestito tramite registro
delle cancellazioni AIDAPT (in fase di attivazione) piu' rotazione; RPO < 24
ore e RTO 8-12 ore lavorative unici per tutti gli scenari (guasto
componente, outage regionale best effort, ransomware); BCP approvato il
30/04/2026, DRP revisionato il 27/02/2026, test periodici di ripristino non
documentati (gap da colmare).

Allegato J, DPA in forma sintetica: Intrawelt come Responsabile ex art. 28
(referente privacy Persona-A, privacy@intrawelt.com; anagrafica completa nel
sorgente locale, non qui); categorie di dati (TU con eventuali dati di terzi,
metadati, glossari e memorie, dati di onboarding, dati dei linguisti, log
pseudonimi) con esclusione artt. 9-10 su dichiarazione del Titolare e
clausola di salvaguardia; sub-responsabili con autorizzazione generale
(AIDAPT, AWS eu-west-1, Azure OpenAI Sweden Central, RWS/Trados UE-UK in
adeguatezza); breach notification "senza ingiustificato ritardo" secondo
EDPB 9/2022 con le 72 ore verso l'autorita' a carico del solo Titolare;
nessun massimale di responsabilita' (art. 82 GDPR, art. 1229 c.c.).

---

## Ricerca UNIMC – Benchmark ScenIA

Fonte: `SCENIA/Ricerca Unimc/Benchmark Study per Intrawelt.docx` (31 KB)
Autori: UNIMC/VRAI Lab (Frontoni, Sernani, Santini). Periodo: 2024-2025.

### Obiettivi

Misurare l'accuratezza della tecnologia ScenIA usando le TM Intrawelt come dataset di valutazione. Identificare le metriche che riflettono meglio le esigenze di Intrawelt e dei clienti.

### Dataset

Intrawelt dispone di memorie di traduzione su **oltre 140 combinazioni linguistiche** sfruttabili per costruire un benchmark MT multidimensionale (language pair, dominio, generalizzabilità).

**Strategia proposta:**

| Split | Coppie | Campione | Totale frasi |
|-------|--------|----------|-------------|
| High-resource (10 coppie più frequenti) | 10 | 100 doc × 10 frasi/doc | 10.000 |
| Low-resource (10 coppie meno frequenti) | 10 | 10-50 doc × 10 frasi | 1.000–5.000 |

**Nota critica (data leakage):** ScenIA esegue RAG su knowledge base contenente le stesse TM. Per evitare leakage, i documenti del dataset devono essere rimossi temporaneamente dalla knowledge base prima del testing.

### Metriche

| Metrica | Tipo | Note |
|---------|------|------|
| COMET-22 (Rei et al., 2020) | Neurale (cross-encoder) | Standard di fatto MT; input: source + hypothesis + reference → score 0-1 |
| XCOMET-XL (Guerreiro et al., 2023) | Neurale (MQM-based) | Stato dell'arte; fornisce score + annotazione errori classificati per tassonomia MQM |
| BLEU (Papineni et al., 2002) | String-based | N-gram overlap; ancora valido per bassa variazione attesa dal gold standard |

ScenIA confrontabile con: ChatGPT (solo prompt, no TM) e modelli open-source specializzati MT.

### Architettura SCENIA descritta da UNIMC

> "ScenIA è un agente basato su ChatGPT che opera facendo retrieval augmented generation su basi di conoscenza che contengono memorie di traduzione."

(Conferma indipendente dell'architettura RAG+LLM documentata in § Cos'è SCENIA.)

---

## Knowledge Base ScenIA – Metriche (25/05/2026)

Fonte: `SCENIA/analisi knowledgebase/metriche_documenti_25-05-2026.json` (83 KB)
Snapshot del Vector Store (Qdrant) al 25/05/2026.

**Struttura dati (per documento):**

| Campo | Descrizione |
|-------|-------------|
| `document_id` | UUID documento nel Vector Store |
| `language` | Lingua (Italian, EnglishGB, ChineseSimplified, …) |
| `argument` | Categoria dominio (finance, marketing, …) |
| `organization_id` | "common" (KB condivisa) o ID cliente |
| `total_chunks` | Numero totale chunk del documento |
| `chunks_for_knowledge` | Chunk indicizzati per retrieval |
| `chunks_available` | Chunk attualmente disponibili (0 = documento non disponibile) |
| `is_for_knowledge` | Flag: se il documento contribuisce alla knowledge base |
| `available` | True/False |

**Nota:** alcuni documenti risultano `available: False` (es. `chunks_available: 0`) — documenti disabilitati o in errore di indicizzazione. La dimensione dei chunk varia molto (da 10 a 55.386 per documento); i documenti finanziari sono tipicamente i più voluminosi.

---

## Checklist Sicurezza SCENIA (gap analysis in corso)

Fonte: `SCENIA/SECURITY/DPA/Checklist_Sicurezza_Dropdown.xlsx`
Stato: tutti gli item "Da fare" — documento di gap analysis preparato da Alessio Sopranzi.

### A) Sicurezza applicativa
Cifratura transito+riposo, TLS 1.2/1.3, chiamate LLM su rete privata AWS, IAM/POLP/rotazione
chiavi, segregazione chiavi DB/vector store/backup, separazione tenant, RBAC, protezione API
(token/firme/anti-replay/rate limiting), SAST, DAST, CI/CD sicuro, Secure SDLC, commit
firmati/branch protection, gestione CVE/patching, hardening container.

### B) Sicurezza operativa
Audit trail accessi, integrazione SIEM/SOC, snapshot RDS/backup logici/export, verifica
integrità backup (checksum), frequenza/posizione/versionamento backup, account separati per
backup, retention policy GDPR/ISO27001, RPO/RTO definiti, test di restore, piano DR,
modello responsabilità AIDAPT vs AWS, log e audit trail backup.

### C) Governance del dato
Classificazione dati, regole conservazione per categoria, portabilità, versionamento
glossari/TM, minimizzazione, processi onboarding/offboarding documentati, auditabilità,
DSAR GDPR, documentazione data breach, SLA informativi, registro trattamenti formalizzato.

### D) LLM Security & Governance
Hardening prompt (system/developer/user), sanitizzazione input, validazione output
anti-hallucination (RAG scoring), scelta/manutenzione modelli, versioning prompt,
monitoring model drift, test regressione output, filtraggio contesto pre-LLM,
documentazione limiti etici, logging sicuro (esclusione PII dai log), retention log LLM.
