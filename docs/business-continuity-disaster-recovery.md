# Business Continuity e Disaster Recovery

Fonte: BCD_2026.docx (revisione 2026).
Politica di riferimento: PSGSI rev.1, 16/10/2025.
Standard: ISO/IEC 27001:2022.

---

## Struttura organizzativa

### Comitato di Gestione Crisi

| Ruolo | Nome |
|-------|------|
| Responsabile tecnico (RSGSI) | Alessio Sopranzi |
| Responsabile di produzione | Alessia Nasini |
| Direzione aziendale | Alessandro Potalivo, Sonia Martellini |

Responsabile Continuita' Operativa (RCO): contatta tutte le figure del Comitato,
redige la relazione per i clienti coinvolti nell'evento.

### Sedi

- Sede primaria: Via Pescolla 2A, Porto Sant'Elpidio (FM)
- Sede secondaria (DR): Via Elpidiense 14, Porto Sant'Elpidio (FM)

---

## Piano di Continuita' Operativa (BCP)

### Scenari di attivazione

- Indisponibilita' sede primaria per eventi atmosferici, allagamenti, incendi.
- Indisponibilita' energia elettrica prolungata.
- Indisponibilita' connettivita' internet prolungata.

Interruzioni parziali e temporanee senza perdita di dati non richiedono
attivazione del piano.

### Connettivita'

Tre linee internet indipendenti su tecnologie diversificate (affasciate con T-BOND).
Il failover e' automatico: l'IP pubblico non cambia anche con una o due linee inattive.
Router portatili alimentabili con powerbank disponibili per emergenze.

Vianova FTTO 1 Gbps + ponte radio Line Recovery Standard (100/20 Mbps) + WAN2 TIM
(disconnessa fisicamente da maggio 2025, contratto cessato luglio 2025). Da aggiornare:
il terzo link e' ora solo il ponte radio come backup; TIM e' dismessa.

### UPS e alimentazione

UPS alimentano: server, NAS, apparati hardware centralizzati (centralino).
Autonomia: ~15 minuti.
[TBC: modelli UPS, numero di UPS, potenza. Da VA: Emerson Liebert IntelliSlot
Web Card su 192.168.90.33 (management UPS).]

### PC portatili

Disponibili per continuita' operativa. Preconfigurati con software e accessi.
Autonomia: ~2 ore per unita'. Batterie verificate settimanalmente.

### Assistenza hardware

Punto Informatica (Daniele Colo'): contratto SLA 2 ore per guasti bloccanti.
Intervento da remoto e/o on-site. Fornisce anche PC sostitutivi per sede secondaria.

---

## Piano di Disaster Recovery (PDR)

### Storage e backup

Dati locali: NAS fleet (HERO .169, INTRA .168, INTRA2 .177, INTRA3 .172, documenti .170).
Dati cloud: Microsoft SharePoint (1000 GB), Outlook online.
Piattaforme: GroupShare (WINGROUPSHARE 10.1.116.3), T-Rex (Odoo, raggiungibili online).
Amazon: per backup e servizi cloud aggiuntivi.

Il dettaglio delle procedure di backup e' nel documento "Data protection.pdf".
DR per email e SharePoint e' garantito da Microsoft.
DR per GroupShare e T-Rex e' garantito dai rispettivi provider.

### Attivazione sito DR

1. Dichiarazione crisi da parte del RCO.
2. Mobilitazione Comitato di Gestione Crisi.
3. Valutazione gravita' evento.
4. Eventuale trasferimento a Via Elpidiense 14 con infrastrutture trasportabili.
5. Assistenza Punto Informatica per configurazione hardware.
6. Ripristino connettivita' internet (prerequisito per tutti i servizi cloud).
7. Rientro alla sede primaria deciso dal Comitato.

### Prerequisito critico DR

L'erogazione del servizio dipende dalla connettivita' internet per accedere a
GroupShare, T-Rex, Microsoft 365. Il ripristino della connessione e' la prima
azione del piano DR.

---

## Politica di Sicurezza (PSGSI rev.1, 16/10/2025)

### Scope SGSI

- Networking
- Sistemi Informativi
- Sviluppo e gestione soluzioni SaaS
- Servizi

### Obiettivi CIA

- Riservatezza: accesso solo al personale autorizzato.
- Integrita': dati protetti da modifiche non autorizzate.
- Disponibilita': servizi accessibili su richiesta in accordo con i contratti.
- Conformita': GDPR, ISO 27001:2022, requisiti legali e contrattuali.
- Miglioramento continuo: audit interni ed esterni, riesame periodico.

### Ruolo GDPR

Intrawelt opera prevalentemente come Titolare del trattamento.
In via residuale come Responsabile del trattamento.
Le nomine a responsabile ex art. 28 GDPR sono stipulate con i fornitori IT.

### Processi SGSI attivi

- Risk assessment: identificazione, valutazione, trattamento, monitoraggio.
- Incident reporting: tutto il personale segnala eventi negativi al RSGSI (Alessio Sopranzi).
- Audit interni ed esterni: periodicita' da definire.
- Riesame periodico del piano: almeno ogni due anni.

---

## Gap analysis ISO27001 (stato giugno 2026)

| Controllo | Descrizione | Stato | Note |
|-----------|-------------|-------|------|
| A.5.29 | Business Continuity | Parziale | BCP/PDR documentati, test periodici non documentati |
| A.5.30 | Ridondanza IT | Parziale | 3 linee (ora 2 attive: FTTO + radio), UPS 15min, nessun generatore |
| A.8.13 | Backup | Parziale | Procedure backup in "Data protection.pdf" (non analizzato in questo progetto) |
| A.7.11 | Supporti di continuita' (UPS) | Parziale | UPS presenti, autonomia 15min, nessun generatore |
| A.5.24 | Incident management | Gap | Processo segnalazione esiste (RSGSI), procedure formali non documentate |
| A.6.1 | Screening | [TBC] | Non documentato |
| A.5.2 | Ruoli sicurezza | Parziale | RSGSI = Alessio Sopranzi, ruoli BCP definiti, SoA non completato |
