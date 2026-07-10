# IT Backlog – Intrawelt S.a.s.

Registro attività IT strutturato. Fonte: `_Piano_Attivita_IT_v3.xlsx`.
114 task totali, 8 macro-categorie. Owner: Alessio Sopranzi.
Aggiornato: giugno 2026.

---

## Persone

| Nome | Mail | Ruolo |
|------|------|-------|
| Alessio Sopranzi | asopranzi@intrawelt.com | IT Manager |
| Persona-E | persona-e@intrawelt.com | Supporto IT / T-Rex |
| Persona-J | persona-j@intrawelt.com | Coordinamento operativo |
| Persona-M | persona-m@intrawelt.com | Azure admin, SCENIA VM |

---

## Legenda stati

| Stato | % | Significato |
|-------|---|-------------|
| Completata | 100% | Chiusa |
| Ci siamo quasi | 75% | Quasi completata |
| In corso | 50% | Lavori attivi |
| Molto da fare | 25% | Avviata con molto residuo |
| Bloccata | 0% | In attesa di prerequisiti |
| (vuoto) | 0% | Non avviata |

---

## TREX (Odoo gestionale)

| ID | Attività | Ore | Priorità | Stato |
|----|----------|-----|----------|-------|
| task_1 | Formazione T-Rex: stilare syllabus preciso | - | 1 | Bloccata |
| task_3 | Migrazione gestionale: supporto OpenForce | 120 | 1 | 0% |
| task_4 | Sviluppo specifiche feature moduli T-Rex | - | 1 | 0% |
| task_5 | Acknowledgment video formazione (3 video, Persona-E) | 8 | 1 | 0% |
| task_6 | Documento Alessio (dipende da task_5) | ? | 1 | 0% |
| task_7 | Formazione esterna sviluppo (4h rimanenti) | - | 1 | 0% |
| task_8 | Integrazione dati T-Rex dentro NinjaOne | - | - | 0% |
| task_107 | App query gestionale self-hostata in Proxmox | - | - | 0% |

---

## SYSADMIN (server, cloud, infrastruttura)

| ID | Attività | Ore | Priorità | Stato |
|----|----------|-----|----------|-------|
| task_9 | SEEWEB: indagare comunicazione LAN↔Seeweb (GroupShare dopo migrazione Vianova) | 10 | 3 | 0% |
| task_10 | CMS: interventi su sito per modifica contenuti | - | 8 | 0% |
| task_11 | CMS: restauro (pagine con destinazioni morte, HTML vecchio Ubuntu 14) | - | - | 0% |
| task_12 | CMS: project management tecnico re-branding | - | - | 0% |
| task_13 | Manutenzione backup e storage (Posta, VM, NAS, anni vecchi, CMS) | 15 | 3 | **75%** |
| task_14 | Patch management (NinjaOne): rimozione AnyDesk/TeamViewer/app non usate | 10 | - | **25%** |
| task_15 | Documentazione IT (PATRIMONIO AZIENDALE) | 100 | 2 | **50%** |
| task_16 | Pulizia NAS-HERO (file Trados, SharePoint) | - | - | **50%** |
| task_29 | Disaster Recovery avanzato (Proxmox Backup Server 4.0) | 40 | - | 0% |
| task_30 | Aggiornamenti Proxmox (v8→v9) – v9 disponibile da ago 2025 | 10 | - | 0% |
| task_35 | Sistemazione torrette MAC sala server | - | - | 0% |
| task_36 | Mappatura topologia rete (con flussi backup) | - | - | 0% |
| task_37 | Ispezione server DHCP multipli (IP anomali Proxmox: .10.239 e .90.103) | - | - | 0% |
| task_38 | Sistemazione cartella Utili con gestione accessi | 8 | 4 | Bloccata |
| task_39 | Proxmox: assegnare vmbr2 (Linux servizi) e vmbr3 (Linux programmazione) | 2 | - | Bloccata |
| task_40 | Proxmox: creazione VM Cybersec (VM501, VM502…) | 2 | - | Bloccata |
| task_41 | Proxmox: check schede rete virtuali, setup, gestione cluster | - | - | 0% |
| task_42 | Proxmox: config NAS, backup, VM, storage pool, disaster recovery | ? | - | 0% |
| task_43 | NinjaOne: notifiche su Telegram | - | - | 0% |
| task_44 | Mappatura porte fisiche azienda | - | - | Bloccata |
| task_45 | Studio backup memorie FILEBASED (TM + Multiterm su SharePoint → NAS .169) | - | - | 0% |
| task_46 | Studio switch e router Piano Terra (ridondanza cavo fibra) | 10 | 1 | Bloccata |
| task_47 | Network Security: DHCP, VLAN isolation, segmentazione IP, FW review | 80 | 1 | Bloccata |
| task_48 | Accesso Nebula con Microsoft Entra ID | - | - | 0% |
| task_49 | Telefonia: dismettere centralino Panasonic, VOIP Vianova, alfabetizzazione utenti | 40 | 1 | Bloccata |
| task_50 | Riorganizzazione postazioni ufficio (dipende da task_49) | 40 | 3 | 0% |
| task_51 | Ticket verso esterni (Microsoft, Seeweb, AWS) | ? | - | ongoing |
| task_52 | Organizzazione storage NAS-HERO (pool, logica, destinazione) | - | - | 0% |
| task_53 | Studio smart-versioning NAS-HERO | - | - | 0% |
| task_54 | Gestione utenze stampanti per scanner | - | - | 0% |
| task_55 | Accesso utente cartella posta archiviata (QNAP INTRA2) | 10 | - | 0% |
| task_76 | Monitoraggio job backup Veeam | - | - | 0% |
| task_78 | Monitoraggio tutti i job di backup | - | - | 0% |
| task_79 | Backup incrementale .pst su server (dipende da task_61) | - | - | 0% |
| task_80 | Manutenzione dischi: sostituzione fine vita, migrazione a caldo | - | - | 0% |
| task_81 | Anni vecchi: completare riordinamento e disponibilità dischi | - | - | 0% |
| task_82 | Migrazione completa GroupShare | 20 | 2 | 0% |
| task_84 | Gestione utenze e accessi risorse rete | - | - | 0% |
| task_85 | Crittografia: audit annuale (dischi a riposo, connessioni) | - | - | 0% |

---

## Cybersec, Governance, ISO, GDPR

| ID | Attività | Ore | Priorità | Stato |
|----|----------|-----|----------|-------|
| task_17 | Roadmap cybersec + aggiornamento documentazione | 20 | 1 | 0% |
| task_18 | Documento stato dell'arte sicurezza | 20 | 1 | 0% |
| task_19 | Normativa e certificazioni (con Consulente-ISO27001-1) | 270 | 1 | 0% |
| task_20 | Distribuire privacy policy NinjaOne a tutti gli utenti | - | - | 0% |
| task_21 | Studio varie questioni sicurezza avanzata (SIEM, DLP, PAM, SDLC…) | 10 | - | 0% |
| task_22 | Ethical hacking su VM Proxmox (dipende da task_40) | - | - | 0% |
| task_23 | Ethical hacking da telefono esterno WiFi (dipende da task_47) | - | - | 0% |
| task_24 | Rimuovere possibilità accesso OneDrive personale | - | - | 0% |
| task_25 | Rimuovere possibilità connessione dischi esterni (USB) | - | - | 0% |
| task_26 | Formazione Alessio: CompTIA Security+ | - | - | 0% |
| task_27 | Rimozione VM obsolete Proxmox (Egetrad, Ubuntu EOL) | 6 | - | 0% |
| task_28 | Valutazione commerciale piattaforme SOC | - | - | 0% |
| task_31 | Bitdefender GravityZone: sostituzione ESET, distribuzione centralizzata | 10 | 1 | **75%** |
| task_32 | Bitdefender su Windows Server (WINGROUPSHARE, WINSRV2019, WIN-V712I9QHQT9) | 5 | 1 | 0% |
| task_33 | Password policy: modifica tutte le password aziendali, policy scadenza | 15 | - | **25%** |
| task_34 | Cleanup mail Persona-P e Persona-R (account MS chiusi set 2025) | 20 | 2 | **50%** |
| task_56 | Studio ciclo vita dati posta (Exchange, quarantena, traccia) | - | - | 0% |
| task_57 | Studio Microsoft Purview + Defender integration | - | - | 0% |

**Note task_21 (studio sicurezza avanzata):**
SOC II type 2, classificazione dati, GDPR art.37, crypto-shredding, supply chain risk,
IDS/IPS (Bitdefender), DDoS protection, DLP, CVSS >9.0 patch SLA, MFA ovunque,
password hashed, PIM/PAM, crittografia backup, SDLC DevOps, RPO/RTO, incident management,
eDiscovery, cloud forensics, physical security.

**task_31 – Bitdefender pendente su 3 macchine:**
- WINGROUPSHARE (10.77.116.3) – sotto Seeweb
- WINSRV2019 (10.77.116.4) – sotto Seeweb
- WIN-V712I9QHQT9 (10.61.20.13) – Proxmox

---

## Microsoft 365

| ID | Attività | Ore | Priorità | Stato | Deadline |
|----|----------|-----|----------|-------|---------|
| task_58 | Teams turni: inserimento 2x/anno | - | - | ongoing | - |
| task_59 | Pulizia cassette postali Exchange | 15 | - | 0% | - |
| task_60 | Manutenzione spazio SharePoint | - | - | 0% | - |
| task_61 | Backup mail: raccogliere input utenti, esportare .pst su NAS | - | - | 0% | - |
| task_62 | Pulizia licenze e account M365 | - | - | 0% | - |
| task_63 | Aggiornare deleghe caselle postali | - | - | 0% | - |
| task_65 | Azure MFA enforcement | 1 | - | **100%** | 01/10/2025 |
| task_66 | Power Automate: monitoraggio e creazione flussi | - | - | 0% | - |
| task_67 | Problematiche varie posta da sistemare | - | - | 0% | - |
| task_68 | Phishing analisi (caso Persona-J maggio 2025) | 2 | - | 0% | - |

---

## Helpdesk

| ID | Attività | Ore | Priorità | Stato |
|----|----------|-----|----------|-------|
| task_50 | Riorganizzazione postazioni ufficio | 40 | 3 | 0% |
| task_51 | Ticket verso esterni | ? | - | ongoing |
| task_64 | Supporto connessione VPN remota | - | - | ongoing |
| task_69 | Manutenzione hardware occasionale | - | - | ongoing |
| task_70 | Web scraping preventivi | - | - | ongoing |
| task_71 | Problemi Trados licenze/disconnessioni | 8 | - | ongoing |
| task_72 | Analisi problemi operativi T-Rex | - | - | ongoing |
| task_73 | Troubleshooting quotidiano (stampe, scanner, postazioni) | - | - | ongoing |
| task_74 | Compilazione questionari clienti | 20 | - | ongoing |
| task_75 | Onboarding/Outboarding sistemi e licenze | - | - | ongoing |
| task_77 | Monitoraggio macchine NinjaOne | - | - | ongoing |
| task_83 | Timbracartellini (BioStar): varie problematiche | ? | - | ongoing |
| task_111 | Inventario hardware (controllo periodico con Daniele) | - | - | ongoing |
| task_112 | NinjaOne: notifiche su Teams | - | - | 0% |
| task_113 | NinjaOne: backup cloud | - | - | 0% |
| task_114 | NinjaOne: definire accessi | - | - | 0% |

---

## Amministrazione IT

| ID | Attività | Ore | Stato |
|----|----------|-----|-------|
| task_86 | IVA addebitata wrong + fattura Aruba non arriva | - | 0% |
| task_87 | Problema fattura Sonia Aruba (mail 03/02/2025) | - | 0% |
| task_88 | IVA addebitata wrong Aruba | - | 0% |
| task_89 | Controllo e gestione problemi fatturazione IT annuale | - | ongoing |
| task_90 | Gestione NAS-HERO Azure | - | 0% |

---

## UNIMC / SCENIA (progetto AI)

| ID | Attività | Ore | Priorità | Stato | Deadline |
|----|----------|-----|----------|-------|---------|
| task_91 | Allineare cartelle OneDrive dopo uscita Francesca | 2 | 1 | **100%** | 08/09/2025 |
| task_92 | Gestione aspetti outsourcing UNIMC | 8 | 1 | **100%** | - |
| task_93 | Creazione report progetto | - | - | 0% | - |
| task_94 | Dare accesso Proxmox ad Attilio per VM | 2 | 1 | **50%** | - |
| task_95 | Git version control pulito – STEP 1 | 10 | 1 | Bloccata | - |
| task_96 | Scriptare set minimo comandi per ambiente | 4 | 1 | Bloccata | - |
| task_97 | Gestione flusso OneDrive Trados dopo account Francesca | 6 | 1 | Bloccata | - |
| task_98 | Continuare sviluppo applicazione (DB, .venv backend, OneDrive) | 10 | 2 | Bloccata | - |
| task_99 | Call bisettimanali AIDAPT + report | 3/call | - | ongoing | 04/09/2025 |
| task_100 | Esporre VM602 fuori Proxmox per accesso esterno | - | - | 0% | - |

**Note:** Francesca ha lasciato Intrawelt prima del 08/09/2025. I flussi SCENIA che dipendevano dal suo account OneDrive sono bloccati (task_95-98).

---

## Sviluppo Interno Aziendale

| ID | Attività | Ore | Priorità | Stato |
|----|----------|-----|----------|-------|
| task_101 | Password manager aziendale (Vaultwarden self-hosted) | 40 | 10 | 0% |
| task_102 | IntraLino chatbot RAG | ? | 10 | 0% |
| task_103 | Soluzioni ad hoc per clienti (es. Legami, mail 01/09/2025) | - | 10 | 0% |
| task_104 | Valutazione progetti pending Persona-R (su SSD D:\ PC-ALESSIO) | - | - | 0% |
| task_105 | Distribuzione app servizi ruolini (10.61.20.22:3000, problemi CORS) | - | - | 0% |
| task_106 | DocuWikiTickets | - | - | 0% |

---

## Studio

| ID | Attività | Stato |
|----|----------|-------|
| task_26 | CompTIA Security+ SY0-701 (Alessio) | In corso |
| task_108 | Notes con relazioni: IT Glue, mappatura documentazione NinjaOne | 0% |
| task_109 | Studio tecnologia flusso automazione AI | 0% |
| task_110 | Cheshire Cat AI (agente AI locale open-source) | 0% |

---

## Task critici aperti (PRIORITY 1, Bloccati)

| ID | Task | Stima | Dipende da |
|----|------|-------|-----------|
| task_47 | Network Security completo (VLAN isolation, FW review, segmentazione) | 80h | - |
| task_49 | Telefonia VOIP (dismissione Panasonic, Vianova VOIP) | 40h | - |
| task_46 | Switch Piano Terra (ridondanza fibra) | 10h | task_44 |
| task_3 | Migrazione T-Rex gestionale | 120h | task_1 |
| task_1 | Formazione T-Rex (syllabus preciso) | - | - |
| task_19 | Certificazione ISO 27001 con Consulente-ISO27001-1 | 270h | - |

**Nota task_47 (network security):**
Il testo originale richiede una revisione completa dell'infrastruttura di rete:
DHCP multipli, VLAN isolation reale (attualmente le subnet .10/.20/.90 non sono isolate a livello firewall),
WiFi guest separato su .90 con isolamento vero, VPN che vede rete .10 locale,
accesso ethernet da MAC non noti sulla LAN management.
Soluzione proposta: whitelist MAC su switch, regole firewall tra VLAN, revisione ACL Nebula.
