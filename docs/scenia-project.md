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

## Stato attuale (giugno 2026)

Il prodotto ScenIA è in produzione. La compliance GDPR (DPA con clienti, DPIA) è in fase
finale di redazione. I gap di sicurezza tecnici (SAST/DAST, VA/PT, Qdrant audit log) sono
stati identificati e portati all'attenzione di AIDAPT tramite questionario formale.
Il DPA richiede completamento dei placeholder delle Parti (dati Cliente per ogni contratto)
e negoziazione dei massimali di responsabilità prima della firma.
