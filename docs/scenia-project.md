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
- Sviluppatore esterno: Fabio Giorgini

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
| 25/08/2025 | Call con Francesca Caricchia: integrazione Power Automate / OneDrive per gestione file. Folder "backend_Trados_RWS" creato nella repo `full_stack_unimc`. |
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
| **Pending** | Invio Questionario_AIDAPT_misure_sicurezza a AIDAPT (30 punti tecnici); completare placeholder Parti DPA; negoziare massimali |

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
| Intrawelt S.a.s. | Responsabile del trattamento, sviluppo prodotto | privacy@intrawelt.com, Alessandro Potalivo |
| AIDAPT S.r.l. | Sub-responsabile, infrastruttura AWS/Azure | help@caity.it |
| Alessio Sopranzi | IT Manager, responsabile compliance GDPR/sicurezza lato IT | asopranzi@intrawelt.com |
| Francesca | Processo workflow traduzione | |
| Alessia Nasini | Coordinamento, GDPR, dati clienti | anasini@intrawelt.com |
| Fabio Giorgini | Sviluppatore esterno fullstack | |
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
| Ragione sociale | Intrawelt di Alessandro Potalivo & C. s.a.s. |
| Sede legale | Via Elpidiense 14, 63821 Porto Sant'Elpidio (FM) |
| P.IVA | 01287540445 |
| Legale rappresentante | Alessandro Potalivo |
| Referente privacy | Alessandro Potalivo — privacy@intrawelt.com |
| DPO | Alessandro Potalivo (designato internamente; soglia art. 37 da verificare con legale) |
| Foro competente | Fermo |
| Massimali responsabilità | Nessun cap proposto (no limite ex art. 82 GDPR) |
| Retention log/cronologie | 1 anno (standard dichiarato ai clienti) |
| Comunicazione cambi sub-responsabili | Email ai referenti dei clienti |
| Linguisti terzi HitL | Sì, tutti in UE |
| Avvio servizio ScenIA | Aprile 2026 |
| Team DPIA | Alessandro Potalivo (DPO, CEO, Referente) |
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
