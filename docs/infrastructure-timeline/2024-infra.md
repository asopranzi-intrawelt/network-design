# 2024 - Arrivo IT manager, primo interventi, decisione Vianova

## Ottobre 2024 - Inizio progetto SCENIA con UNIMC/VRAI Lab

Avvio della collaborazione con il laboratorio VRAI di UNIMC (Prof. Emanuele Frontoni)
per lo sviluppo di ScenIA, piattaforma SaaS AI per traduzione. Intrawelt e' Processor
GDPR Art. 28; il partner accademico e' il Titolare del trattamento nella fase iniziale.

Stack iniziale: LLM via API OpenAI, sviluppo prototipo RAG.
Responsabile tecnico Intrawelt: Alessio Sopranzi.
Responsabile accademico: Prof. Emanuele Frontoni + Persona-J (PM lato Intrawelt).

## Fine 2024 - Inizio sviluppo IntraLino RAG

Prima installazione Ollama (llama3.2) e ChromaDB su host locale. Sperimentazione
RAG per automazione interna (glossari Trados, recupero TM). Stack iniziale non
dockerizzato; evolve nel corso del 2025 verso architettura stabile con n8n 2.x
come orchestratore workflow.

## 24/10/2024 - Rinnovo certificato SSL VPN

Certificato SSL per vpn.intrawelt.com in scadenza. Procedura di rinnovo eseguita
tramite ZeroSSL con account it@intrawelt.com / [redacted]. Il certificato rinnovato
viene importato nel firewall ZYXEL USG FLEX 500 via Configuration > Object > Certificate.
Durante il cambio certificato l'utente Alessandro Nebbia viene disconnesso e poi
riconnesso manualmente. Il certificato viene archiviato in \\10.61.20.170\vpn\Certificati SSL.

## 06/11/2024 - Falso allarme licenza ABBYY scaduta

Persona-G riceve da ABBYY FineReader un messaggio di licenza scaduta. La causa
non e' una scadenza reale: superate le 5 licenze concurrent disponibili sul
license server, il client pesca in automatico la licenza Evaluation (trial,
effettivamente scaduta) e mostra l'avviso. Il problema rientra quando una
delle 5 licenze di rete si libera. Fonte: `Helpdesk_ABBYY/ABBYY.docx`
(contenuto anonimizzato secondo `.claude/rules/anonymization.md`).

## 20/11/2024 - Rinnovo licenza annuale Zyxel marketplace

Rinnovo abbonamento annuale Zyxel marketplace con carta di credito
aziendale (dettagli pagamento non riportati per policy amministrativa).
Device S/N: [redacted]
Device MAC: AA:BB:CC:00:00:20
Mail di conferma ricevuta il 20/11/2024 alle ore 09:41 (numero d'ordine e
license key non riportati per policy amministrativa).
Account migrato da persona-p@intrawelt.com a it@intrawelt.com / [redacted]

## 21-22/11/2024 - Black-out elettrico: crisi NAS INTRA2

Mancanza di corrente tra il 21 e il 22 novembre. Il NAS INTRA2 (QNAP TS-451U,
10.61.20.177) al ritorno dell'alimentazione comincia a registrare errori nel log.
Il backup incrementale si blocca all'1% per mancanza di spazio: il RAID 5 con
4 dischi da 2.73 TB e' quasi saturo. Soluzione temporanea applicata: riavvio del
NAS e pulizia parziale dei backup piu' vecchi nella cartella "Backup anni vecchi".
Il problema di fondo rimane. Soluzione definitiva decisa in conseguenza: sostituzione
uno-a-uno dei 4 dischi con dischi da 8 TB ciascuno.

## Novembre 2024 - Sviluppo app ENI ruolini (desktop Python)

Fonte: `Sviluppo_interno, scripting (IT on FIRE)/Progetto ENI ruolini (nov24)/Sviluppo app ENI ruolini.docx`

Prima soluzione per automazione conversione ruolini ENI: app desktop Python + PyQt6.
Problema: i ruolini ENI arrivano come file `.docx` Word con campi diversi da quelli
che T-Rex accetta nell'import Excel. Soluzione: script Python che legge il Word e
produce un `.xlsx` con i campi rinominati per T-Rex.

| Data | Milestone |
|------|-----------|
| 12/11/2024 | Verifica output regex con T-Rex test: primo approccio parsing Word |
| 14/11/2024 | Persona-N inizia `ENI_word_to_excel.py` (parsing + mapping campi) |
| 15/11/2024 | Studio formato `.xlsx` e formattazione date (problema Date vs Testo in openpyxl) |
| 18/11/2024 | Installazione PyQt6 + Visual C++ Build Tools; prima GUI PyQt6 funzionante |
| 18/11/2024 | Fix: eliminare file `.xlsx` vuoto esistente prima di "Run Script" |
| 19/11/2024 | Pulizia Qt Designer mockup + integrazione GUI con script `ENI_word_to_excel_date.py` |

Stack: Python 3.12 (venv), python-docx, openpyxl, PyQt6. GUI creata con Qt Designer
(`.ui` → `main_mod_icon.py`). Campi mappati: "Operatore"→"Richiedente",
"Lingua Transizione"→"Lingua di transizione", "Tipo attività"→"Servizio Aggiuntivo".

Questa è la PRIMA versione dell'automazione ruolini ENI (app desktop locale).
La seconda versione (IntraPanel React+Flask su PC-GIORDANO) è quella attualmente in
produzione (documentata in helpdesk-operations.md §ENI VIPA).

Repository GitHub: eni-report-api, intrapanel-UI (link URL nel progetto).

## Ottobre-Novembre 2024 - Analisi costi TIM e servizi inutili

Identificati in fattura TIM i seguenti servizi inutili o sospesi senza che siano
stati disdettati:
Affitto router extra staccato fisicamente almeno da ottobre 2024, bimestrale.
"Nuvola IT Sinfonia": servizio di monitoraggio traffico dati di TIM, superfluo
perche' il monitoraggio avviene gia' dentro il firewall Zyxel.
8 indirizzi IP pubblici aggiuntivi non utilizzati da nessun servizio attivo.
Taurus Bond firewall in comodato d'uso TIM: trovato fisicamente staccato in sede,
mai connesso, da restituire a TIM.
Costo complessivo stimato dei servizi inutili: superiore a 1.000 euro bimestrale.

Informazioni discusse con Persona-B via chat Microsoft Teams il 15/05/2025
(in riferimento all'analisi svolta in questo periodo).

## 05/12/2024 - Analisi fatture linee attive

Persona-B invia alle 11:37 le fatture per le linee telefoniche e internet di
novembre 2024. Situazione:
Vianova: 1 fattura mensile, importo variabile ma di poco.
TIM: 6 fatture separate, ognuna corrispondente a un singolo servizio o linea.

Le 6 fatture TIM coprono: le tre linee dati (massimo 100 Mbit/s ciascuna), i servizi
extra (affitto router, Nuvola Sinfonia, IP aggiuntivi) e il Taurus Bond in comodato.

La prima fattura Vianova per Intrawelt S.a.s. risale ad aprile 2024. Osservata dalla
mail di persona-r@intrawelt.com.

## 10/12/2024 - Decisione: porting linea dati a Vianova

Persona-A decide di passare anche la connettivita' dati a Vianova.
La situazione attuale con TIM prevede tre linee dati separate per un totale
teorico di 300 Mbit/s, ma senza aggregazione effettiva. L'obiettivo e' ottenere
una FTTO simmetrica da 1 Gbps con Vianova, eliminando tutti i contratti TIM dati.

## 17/12/2024 - Riunione in sede con Referente-Vianova-1 (myOffice): preventivo Vianova

Riunione in sede con Referente-Vianova-1 (referente-vianova-1@myofficegroup.it) di myOffice.
Dettaglio preventivo presentato (documento "Riepilogo offerta economica" allegato):

Canone mensile: 984,00 euro IVA esclusa. Costi di attivazione: azzerati.
Nessun costo una-tantum.

Componenti incluse nel canone:
Opzione traffico flat: 24,00 euro/mese. L'analisi dell'area clienti Vianova mostra
che il consumo medio sfora quasi sempre la soglia non-flat, quindi l'opzione flat
conviene. In area clienti: circa 300 chiamate in entrata al mese mediamente.
6 canali voce: contestualita' di 6 conversazioni telefoniche simultanee (entranti
o uscenti). Le chiamate interne non occupano linee. Analisi chiamate perse per
occupato: solo il 12/07 c'era stata una dozzina di chiamate senza risposta, caso
isolato. 6 canali sono piu' che sufficienti.
FTTO fino a 1 Gbps simmetrica nominale (tecnologia TIM su fibra dedicata FTTO).
Nota tecnica di Referente-Vianova-1: la sede di Intrawelt non e' coperta da rete GPON,
solo da collegamenti dedicati FTTO. I tempi di attivazione su circuiti dedicati sono
entro 120 giorni. L'opzione 2 Gbps costerebbe 1.600 euro/mese (non scelto perche'
firewall e schede di rete dei PC sono a 1 Gbps e non trarrebbero beneficio).
Router Vianova R-1000 principale (gestisce sia fibra che ponte radio).
Router Vianova R-1000 backup in HSRP (Hot Standby Router Protocol, protocollo
Cisco per fault-tolerance tra router). Se la fibra cade, Vianova switcha in automatico
sul ponte radio mantenendo gli stessi indirizzi IP pubblici.
Switch Vianova S-1000.
UPS dedicato agli apparati Vianova.
Opzione Line Recovery Radio Standard: ponte radio con 100 Mbps download e 20 Mbps
upload. La variante "a progetto" (simmetrica dedicata, piu' performante) avrebbe
costi piu' elevati. La Standard e' sufficiente come paracadute.
Pool di 16 indirizzi IP pubblici: 203.0.113.x/28 (14 utilizzabili: .1 gateway,
.15 broadcast).

Servizi inclusi senza costi aggiuntivi e non scorporabili dal canone: posta elettronica,
hosting spazio web, Drive (tipo WeTransfer per file pesanti), Fax virtuale, Conference
Call, spazio disco, videoconferenza (tipo Zoom/Teams), Desk (remote desktop senza
intervento), PEC legata al dominio, Numero Verde 800 (numero associato alla ragione
sociale, chi chiama non paga, Intrawelt paga i minuti, utile per gare di appalto).

Nota operativa: il canone attuale Vianova per voce e radio non viene pagato finche'
non avviene il passaggio fisico. Ci sara' un periodo di doppio operatore di circa
due settimane durante il quale TIM non viene ancora disdettata per evitare interruzioni.
Router R-1000, R-1000 backup e UPS si restituiscono a myOffice (che li ridara' a
Vianova) in caso di eventuale disdetta futura. Non hanno canone aggiuntivo.

Referente-Vianova-1 risponde il 17/12/2024 alle 17:03 confermando che l'offerta e'
gia' quella concordata e riallega il documento.

## 18/12/2024 - Firma contratto Vianova dati

Persona-A accetta il preventivo. La firma digitale e' di Sara. Il documento
firmato viene rimandato a myOffice.
Data di contrattualizzazione: 24/12/2024. Da questa data decorrono i 120 giorni
massimi per l'attivazione (scadenza massima: 24/04/2025).

Il 18/12/2024 alle 11:08 arriva la mail di invito all'area clienti Vianova:
"Intrawelt di Alessandro Potalivo & C. sas ti ha invitato ad accedere alla propria
Area Clienti. Per accettare l'invito e' necessario selezionare il seguente link
entro 15 giorni." Link: areaclienti.vianova.it (token aPjsbp4S).

Account area clienti creato:
Username: asopranzi@intrawelt.com
Password: [redacted]

Il 27/12/2024 arriva mail di conferma. Il foglio contrattuale viene rimandato con
intestazione e firma il giorno stesso.

## 19/12/2024 - Spegnimento HP G9

HP G9 (VMware ESXi fisico) spento definitivamente da Persona-H. Nello stesso
pomeriggio Persona-H accede a NAS INTRA2 via 10.61.20.177:8080 per il
controllo stato prima del suo intervento.

## 20/12/2024 - Ordine 4 dischi 8 TB per NAS INTRA2

Deciso l'acquisto di 4 dischi HDD da 8 TB per la migrazione a caldo del RAID 5
del NAS INTRA2 (QNAP TS-451U, 10.61.20.177). La migrazione avviene un disco alla
volta: sostituzione del disco, attesa del rebuild automatico, poi disco successivo.
Al termine dei 4 rebuild: espansione del volume tramite la funzione "Espandi Volume"
del QNAP. Capacita' post-migrazione attesa: circa 21 TB raw RAID 5 (circa 14-15 TB
disponibili netti, al netto dello spazio gia' occupato dai dati esistenti).
