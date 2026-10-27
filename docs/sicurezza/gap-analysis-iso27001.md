# Gap analysis ISO 27001:2022 degli artefatti della rete

> Prima verifica degli artefatti ISO 27001 di questo progetto con la skill `iso27001` del pacchetto `grc-skills` (release `v2.1.0` della raccolta Sushegaad, ADR-042), eseguita il 27/10/2026. Edizione di riferimento ISO/IEC 27001:2022 con l'emendamento 1:2024, l'unica certificabile. Il documento è una verifica datata: descrive gli artefatti del 27/10/2026 e non si aggiorna a mano quando il registro cambia; si ripete, e la ripetizione si confronta con questa.

## Perimetro e metodo

Gli artefatti verificati sono quattro. Il registro `data/iso27001-interventi.json`, che dichiara 47 interventi in quattro fasi verso l'obiettivo della certificazione entro marzo 2027, con i controlli dell'Annex A a cui ciascuno risponde e la storia degli avanzamenti in 126 eventi. La sua vista `docs/sicurezza/roadmap-iso27001-operativa.md`, generata. La sezione SGSI[^1] di `docs/sicurezza/cybersecurity-governance.md`, che riassume la politica firmata, il perimetro, gli obiettivi e il processo dei rischi, e le sezioni su password, protezione degli endpoint, GDPR e data breach dello stesso documento. E la scheda `.claude/context/design-and-security.md` per i principi.

La copertura dell'Annex A è calcolata da codice e non letta a occhio: lo stato corrente di ogni intervento è l'ultimo evento del registro, o lo stato iniziale se non ne ha, e ogni controllo citato si confronta con l'elenco dei 93 controlli del riferimento `references/annex-a-2022.md` della skill. La ricerca dei controlli non coperti dal registro nei documenti è testuale, su `docs/` e `.claude/context/`, per parole chiave italiane e inglesi.

Tre limiti vanno dichiarati prima dei risultati. I documenti originali stanno in OneDrive e non sono stati riletti: la politica del 16/10/2025, la procedura data breach e la policy password sono valutate attraverso il riassunto che ne dà la scheda di governance, quindi un «parziale» qui può essere un «implementato» nel documento originale, o il contrario. Lo stato degli interventi è quello registrato, non misurato sugli apparati. E un'evidenza, nel senso dell'audit, è un documento approvato o una registrazione datata: la presenza di un argomento in una scheda tecnica non lo è.

## Il risultato in breve

Al 27/10/2026 il registro conta 1 intervento completato, 17 in corso e 29 da fare. Cita 40 dei 93 controlli dell'Annex A; gli altri 53 non hanno nessun intervento. La cifra va letta con cura, perché mescola tre situazioni diverse. Una parte dei 53 è già trattata in documenti del progetto che il registro non collega, come la politica SGSI, la protezione degli endpoint o il trattamento dei dati personali. Una parte è pertinente alla rete e manca davvero, come l'autenticazione forte, la sincronizzazione degli orologi o la sicurezza fisica della sala server. E una parte dipende da una decisione di perimetro non ancora presa: il perimetro scritto nella politica comprende lo sviluppo di una soluzione SaaS[^2], e se resta tale i controlli sullo sviluppo sicuro sono applicabili ma non stanno in questo progetto.

Le lacune critiche per il calendario sono quattro, e nessuna è tecnica. Il perimetro del sistema di gestione (ISO-36) è in corso e condiziona tutto il resto, dalla dichiarazione di applicabilità all'ente che verrà a verificare. L'audit interno (ISO-45) e il riesame della direzione (ISO-46) sono da fare, e un ente di certificazione non avvia lo stadio 2 senza almeno un ciclo completo di entrambi. La dichiarazione di applicabilità (ISO-39) è da fare, e dovrà giustificare 93 controlli uno per uno. E i ruoli non sono assegnati per iscritto: la scheda di governance dichiara dal 07/10/2026 che non esiste una nomina individuale degli amministratori di sistema.

## Clausole 4-10

| Clausola | Requisito | Stato | Evidenza attesa | Che cosa manca |
|---|---|---|---|---|
| 4.1, 4.2 | Contesto e parti interessate | Non implementato | Analisi del contesto e registro delle parti interessate con i loro requisiti | ISO-37 da fare |
| 4.3 | Perimetro dell'SGSI | Parziale | Documento di perimetro approvato, con confini, interfacce ed esclusioni | La politica elenca tre ambiti (rete e sistemi, sviluppo SaaS, servizi di traduzione); ISO-36 è in corso. Va deciso se lo sviluppo SaaS entra nel primo certificato |
| 4.4 | Sistema di gestione | Parziale | Processi dell'SGSI e loro interazioni | Coperto da ISO-36 insieme al perimetro |
| 5.1 | Leadership e impegno | Parziale | Registrazioni di decisioni e risorse assegnate dalla direzione | La politica è firmata; mancano verbali che mostrino la direzione nel ciclo |
| 5.2 | Politica | Implementato, da verificare | Politica firmata, comunicata, disponibile | PSGSI rev. 1 del 16/10/2025, firmata secondo la scheda di governance; comunicazione al personale non documentata qui |
| 5.3 | Ruoli, responsabilità e autorità | Non implementato | Organigramma della sicurezza, nomine firmate | Nessuna nomina individuale degli amministratori di sistema (lacuna dichiarata il 07/10/2026); nessun intervento nel registro |
| 6.1.1 | Rischi e opportunità | Parziale | Azioni pianificate su rischi e opportunità | Il processo è descritto in quattro fasi nella politica |
| 6.1.2 | Valutazione del rischio | Parziale | Metodo documentato, criteri di accettazione, risultati ripetibili | ISO-38 in corso; criteri di accettazione non visti |
| 6.1.3 | Trattamento del rischio e SoA[^3] | Non implementato | Piano di trattamento approvato dai titolari del rischio; dichiarazione di applicabilità | ISO-39 da fare |
| 6.2 | Obiettivi | Parziale | Obiettivi misurabili, con responsabile, scadenza e metodo di misura | La politica dichiara cinque obiettivi qualitativi, non misurabili; ISO-40 da fare |
| 6.3 | Pianificazione dei cambiamenti | Non implementato | Cambi dell'SGSI pianificati e registrati | Nessun intervento; requisito introdotto dall'edizione 2022 |
| 7.1 | Risorse | Parziale | Risorse assegnate | Le forniture sono censite nella roadmap; l'approvazione della direzione non è documentata |
| 7.2 | Competenza | Non implementato | Registrazioni di competenza per i ruoli | Nessun intervento |
| 7.3 | Consapevolezza | Non implementato | Registri della formazione | ISO-44 da fare |
| 7.4 | Comunicazione | Non implementato | Piano di comunicazione interna ed esterna | Nessun intervento |
| 7.5 | Informazioni documentate | Parziale | Controllo di versioni, approvazioni, distribuzione e conservazione | Il repository versiona la documentazione tecnica, ma i documenti dell'SGSI vivono in OneDrive senza un controllo documentale dichiarato |
| 8.1 | Pianificazione e controllo operativo | Parziale | Procedure operative e cambi controllati | ISO-41 in corso |
| 8.2, 8.3 | Esecuzione di valutazione e trattamento | Parziale | Risultati datati di valutazione e trattamento | Dipendono da ISO-38 e ISO-39; i due VA esterni sono evidenza a supporto |
| 9.1 | Monitoraggio e misurazione | Non implementato | Indicatori misurati e analizzati | ISO-40 da fare; il collettore dei log (ISO-30) potrà alimentarli |
| 9.2 | Audit interno | Non implementato | Programma, criteri, rapporti | ISO-45 da fare; la politica lo dava pianificato nel 2026 |
| 9.3 | Riesame della direzione | Non implementato | Verbale con gli input e le decisioni prescritti | ISO-46 da fare |
| 10.1 | Miglioramento continuo | Non implementato | Evidenza di miglioramento | ISO-46 da fare |
| 10.2 | Non conformità e azioni correttive | Parziale | Registro delle non conformità e delle azioni | Il registro delle pendenze e i rilievi del VA funzionano di fatto come tale, ma non sono dichiarati registro delle non conformità |

## Annex A: i 40 controlli citati dal registro

Il registro concentra gli interventi sui controlli tecnici di rete, ed è coerente con la natura del progetto. A.8.20 (sicurezza delle reti) è citato da 12 interventi e A.8.22 (segregazione delle reti) da 9; seguono il backup (A.8.13) e la crittografia (A.8.24) con 4 ciascuno. L'unico intervento completato è ISO-05, il database della VM 209 (A.8.3, A.8.20). Fra i controlli nuovi dell'edizione 2022 sono coperti A.5.23, A.5.30, A.8.9 e A.8.16; restano senza intervento A.5.7, A.7.4, A.8.10, A.8.11, A.8.12, A.8.23 e A.8.28.

Il registro cita anche le clausole come se fossero controlli, per esempio `4.3` o `6.1.3` negli interventi della fase SGSI, e una volta l'intervallo `4-10`. Non è un errore, ma lo strumento che conterà i controlli dell'Annex A per la dichiarazione di applicabilità deve saperle distinguere.

## Annex A: i 53 controlli senza intervento

La classificazione che segue è una proposta, da confermare quando il perimetro (ISO-36) sarà deciso. Ogni controllo finirà comunque nella dichiarazione di applicabilità, applicabile con la sua attuazione o escluso con la sua giustificazione.

**Già trattati altrove.** Sono in un documento del progetto, ma il registro non li collega. A.5.1 (politiche), dalla PSGSI del 16/10/2025. A.5.10 (uso accettabile), dal registro delle firme sull'utilizzo dei sistemi informatici. A.5.31 (requisiti legali) e A.5.34 (dati personali), dalla sezione GDPR, dal registro dei sub-responsabili e dal riferimento al provvedimento del Garante sugli amministratori di sistema. A.6.6 (riservatezza), dal quadro degli accordi di riservatezza e delle nomine dei responsabili. A.8.7 (malware), da Bitdefender GravityZone attivo su tutti gli endpoint secondo la scheda. A.7.7 (schermo pulito), in parte, dal blocco automatico dopo cinque minuti. Basta collegarli: un intervento di sola evidenza, o una colonna della dichiarazione di applicabilità che punti al documento.

**Mancanti nella rete.** Sono pertinenti alla rete e all'infrastruttura, e nessun documento li tratta. A.5.2, A.5.3 e A.5.4, ruoli, separazione dei compiti e responsabilità della direzione, che coincidono con la nomina degli amministratori di sistema e sono la lacuna più visibile a un auditor. A.8.5, autenticazione sicura: il registro non ha un intervento sull'autenticazione a più fattori[^4] per gli accessi amministrativi e remoti, e la policy password riassunta nella scheda (otto caratteri, scadenza a 180 giorni) è più debole di quanto oggi si raccomandi. A.8.17, sincronizzazione degli orologi, che è anche il presupposto perché i log del collettore (ISO-30) siano confrontabili. A.7.1-A.7.6 e A.7.13-A.7.14, sicurezza fisica della sala server, manutenzione e dismissione sicura degli apparati. A.8.18 e A.8.19, programmi privilegiati e installazione di software sui sistemi. A.8.23, filtraggio web, che il firewall supporta. A.5.7, informazioni sulle minacce. A.5.27, apprendimento dagli incidenti, da aggiungere a ISO-42. A.6.7, lavoro da remoto, legato alle VPN di ISO-25. A.5.5, contatti con le autorità, cioè Garante e, se la NIS2 si applica, il CSIRT[^5] nazionale.

**Organizzativi.** Stanno fuori dal lavoro sulla rete ma dentro l'SGSI. A.5.6, A.5.8, A.5.11-A.5.13, A.5.32, A.5.33, A.5.35, A.6.1, A.6.2 per la parte non coperta da ISO-40, A.6.4, A.6.5, A.7.9, A.7.10, A.8.10, A.8.11, A.8.12 e A.8.34. Spettano alla direzione, alle risorse umane e al consulente ISO; questo progetto ne è al massimo una fonte.

**Dipendenti dal perimetro.** A.8.4 e A.8.25-A.8.31, più A.8.33: accesso al codice sorgente, ciclo di sviluppo sicuro, requisiti applicativi, architettura, codifica sicura, test, sviluppo esternalizzato, separazione degli ambienti e dati di test. Sono applicabili se lo sviluppo SaaS resta nel perimetro del primo certificato, e in quel caso la loro attuazione sta nel repository di quel prodotto e non qui. Se il perimetro si restringe a rete e sistemi, si escludono con giustificazione.

## Una domanda aperta sulla NIS2

La cronologia del progetto registra l'incarico a uno studio legale per un'analisi di applicabilità della direttiva NIS2 a Intrawelt, ma l'esito non è scritto in nessun documento del repository. La skill `nis2` del pacchetto è installata per questo: se l'analisi conclude che Intrawelt è un soggetto importante o essenziale, gli obblighi dell'articolo 21 si sovrappongono in gran parte ai controlli sopra, quelli dell'articolo 23 fissano tempi di notifica degli incidenti diversi dai 72 ore del GDPR, e la procedura di risposta agli incidenti (ISO-42) va scritta tenendone conto fin dall'inizio. Finché l'esito non è noto, è un'inferenza: non lo si presume in nessuna delle due direzioni.

## Priorità proposte

L'ordine discende dal calendario della certificazione e non dalla gravità tecnica, che la roadmap già governa.

Primo, chiudere il perimetro (ISO-36), perché decide quali controlli sono applicabili e quanto pesa la dichiarazione di applicabilità. Secondo, assegnare per iscritto ruoli e nomine degli amministratori di sistema (clausola 5.3, A.5.2-A.5.4), che è un documento e non un intervento tecnico. Terzo, avviare la dichiarazione di applicabilità (ISO-39) partendo dalla classificazione qui sopra, collegando subito i controlli già trattati altrove. Quarto, aprire nel registro gli interventi di rete mancanti, almeno A.8.5, A.8.17, A.7.1-A.7.6 e A.8.23. Quinto, fissare le date dell'audit interno e del riesame della direzione (ISO-45 e ISO-46) a ritroso dalla data dell'audit di certificazione, lasciando il tempo per chiudere le non conformità che l'audit interno troverà.

## Riferimenti

La norma e il riferimento ai 93 controlli sono quelli della skill `iso27001`, copia del template di `Sushegaad/Claude-Skills-Governance-Risk-and-Compliance` alla release `v2.1.0` (https://github.com/Sushegaad/Claude-Skills-Governance-Risk-and-Compliance), che dichiara di fornire informazione generale e non consulenza: le scelte di applicabilità restano del consulente ISO e dell'ente di certificazione. Il testo della norma è ISO/IEC 27001:2022 (https://www.iso.org/standard/27001), non letto direttamente in questa sessione. Il provvedimento del Garante sugli amministratori di sistema è quello citato nella scheda di governance.

[^1]: *SGSI*, sistema di gestione della sicurezza delle informazioni, in inglese ISMS: l'insieme di politiche, processi e controlli che la norma ISO/IEC 27001 chiede di stabilire, attuare, mantenere e migliorare.
[^2]: *SaaS*, software as a service: un'applicazione erogata come servizio in rete invece che installata presso chi la usa.
[^3]: *SoA*, Statement of Applicability, dichiarazione di applicabilità: il documento che per ciascuno dei 93 controlli dell'Annex A dice se è applicabile, perché, e com'è attuato o perché è escluso.
[^4]: *MFA*, multi-factor authentication: un accesso che chiede almeno due prove di identità di natura diversa, per esempio una password e un codice generato da un dispositivo.
[^5]: *CSIRT*, Computer Security Incident Response Team: in Italia il CSIRT nazionale presso l'Agenzia per la cybersicurezza nazionale, destinatario delle notifiche NIS2.
