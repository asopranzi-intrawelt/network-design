# Fonti del progetto e protocollo di riallineamento: i casi osservati

> Riferimento esteso della regola `.claude/rules/fonti-e-riallineamento.md`, da cui queste sezioni sono state spostate verbatim il 13/10/2026 per non pagarle a ogni sessione. Non si carica all'avvio e non serve ad applicare la regola: serve a chi deve estenderla o rimetterla in discussione, perche' porta la misura, la data e la conseguenza di ciascuna prescrizione.

## Le tre guardie del rinfresco automatico delle fonti vive

Le tre guardie, che sono la ragione per cui esiste uno script invece di due comandi dentro un'attivita' pianificata. La misura buona non si sovrascrive mai: si scrive in una cartella temporanea, si valida, e solo allora si promuove; valido significa che contiene dispositivi, criterio che viene dal 05/08/2026, quando l'organizzazione declassata produsse uno snapshot formalmente corretto e **vuoto** che avrebbe cancellato l'ultima misura completa. Un rinfresco fallito lascia un marcatore in `output/` che il controllo di allineamento riporta in rosso, perche' un'automazione che fallisce in silenzio sostituisce un dubbio con una fiducia mal riposta. E le credenziali restano nel solo posto dove ADR-021 le mette, senza una seconda copia.

## La fonte che si e' spenta e riaccesa: la OpenAPI Nebula dipende dalla licenza

Registrato il 05-06/08/2026, gap NEB-002, decisione in ADR-022. Vale la pena tenerlo qui, in una regola che si carica a ogni sessione, perche' e' l'unico caso finora in cui una fonte di classe B e' morta per una ragione **amministrativa** e non tecnica.

Il fatto: il 05/08 alle 16:09 locali l'organizzazione Nebula e' stata declassata automaticamente a Base Pack e la OpenAPI ha smesso di autorizzare le chiamate; il 06/08 alle 08:51, dopo l'acquisto delle licenze mancanti, ha ripreso a rispondere da sola, senza rigenerare la chiave. Fra le due misure lo strumento di verifica su porte, PVID, VLAN e tabelle MAC semplicemente non esisteva.

La regola che governa la disponibilita' di questa fonte, verificata sui pannelli e non ricordata: il livello dell'organizzazione e' il **minimo** fra i suoi dispositivi, non la loro somma; **un solo** apparato senza licenza Plus o Pro la fa scendere a Base dopo **quindici giorni** di grazia; e la OpenAPI risponde **solo** in stato Pro, perche' il Plus non abilita nemmeno la generazione della chiave. La causa concreta e' stata l'ingresso dei tre access point della Fase B nell'organizzazione il 21/07 senza licenza: quindici giorni esatti dopo, il declassamento.

## Fonte automatica pianificata: lo USG FLEX 500 su Nebula

Annotato il 03/08/2026 su indicazione dell'IT Manager. Il firewall **verra' portato sull'organizzazione Nebula** che gia' gestisce i due switch e i tre access point. Non e' ancora possibile e la data non e' fissata, ma quando avverra' cambia la classe di appartenenza della fonte piu' importante che oggi non e' interrogabile.

Perche' conta piu' di un comodo in piu'. Oggi il firewall e' l'unico apparato centrale che vive in classe E e non in classe B: interfacce, ambiti DHCP, riserve, policy, oggetti indirizzo, DNS e NAT si leggono solo se l'IT Manager apre la GUI e produce uno screenshot. Ne segue che ogni affermazione di questo progetto sul firewall ha la freschezza dell'ultima volta che qualcuno ha guardato, e piu' di una correzione del luglio 2026 nasce esattamente da li' — l'intervallo degli indirizzi statici documentato come `.18-.84` invece di `.17-.95`, le interfacce residue di FW-013, le tabelle DNS credute assenti e poi trovate popolate su un suffisso sbagliato, la VLAN di gestione attribuita al segmento sbagliato in FW-002.

Con il firewall su Nebula quelle letture diventano interrogabili con lo stesso script e la stessa chiave gia' in uso, e la conseguenza pratica e' che **la verifica del firewall entra nella cadenza automatica** invece di dipendere da una richiesta. Da fare quando succede: estendere `Get-NebulaSnapshot.ps1` agli endpoint del firewall, spostare la riga corrispondente da classe E a classe B in questo documento, fissarne la cadenza, e aggiungere la checklist di verifica in `_notes/TEST-CHECKLIST.md` sul modello di quella degli switch.

Tre precisazioni acquisite il 06/08/2026 dai pannelli di NCC, che spostano il piano da "quando succede" a "in quale delle due modalita'". La prima e' che il firewall e' **gia' nell'inventario Nebula** dal 09/12/2025, in stato `Unused`, cioe' registrato nell'organizzazione ma non assegnato a un sito, e con l'acquisto del 05/08 e' coperto da Nebula Professional fino al **25/11/2027**: il lato licenza e' gia' pagato e non e' piu' un ostacolo. Da non confondere con il **Gold Security Pack** che il firewall porta a parte, licenza di servizio di sicurezza con scadenza propria al **19/12/2026**.

La seconda e' che le modalita' sono due e la differenza non e' di grado ma di **chi comanda la configurazione**. In *Cloud Monitoring Mode* il firewall resta gestito localmente, la configurazione continua a vivere sul dispositivo e a modificarsi dalla sua interfaccia, e Nebula si limita a osservare, cioe' mostra stato, traffico, log e avvisi e tiene un backup della configurazione sul cloud: nessun reset, niente da rifare. In *Cloud Mode* il cervello diventa NCC, la configurazione vive nel cloud e il dispositivo la esegue, ma per entrarci serve un **reset di fabbrica** e la configurazione attuale **si perde**, perche' i formati non sono compatibili e non esiste uno strumento di importazione: andrebbe ricostruita a mano in NCC, e alcune funzionalita' dell'USG FLEX non sono ancora disponibili in quella modalita'. Per un firewall che porta regole, VPN, NAT, oggetti indirizzo e ambiti DHCP costruiti negli anni, e che questo progetto sta ancora finendo di documentare, la seconda strada e' un progetto a se' e non un cambio di modalita'.

La terza discende dalle prime due: se l'obiettivo dichiarato e' spostare il firewall da classe E a classe B, cioe' renderlo **leggibile** senza screenshot, il candidato e' il *Cloud Monitoring Mode*, che non rischia nulla. Misurato il 06/08/2026, e vale come risposta parziale: nello stato attuale `Unused` il firewall **compare gia' nella risposta della OpenAPI**, in un gruppo con `siteId` nullo, ma con la sola anagrafica — tipo, modello, numero di serie, indirizzo fisico. Nessuna porta, nessuna tabella, nessuna configurazione, il che e' coerente con un apparato non assegnato a un sito. Resta quindi da verificare la sola domanda che conta davvero, e non va data per scontata: **che cosa esponga una volta assegnato a un sito in sola supervisione**. La prova costa poco e va fatta prima di annunciare che la fonte ha cambiato classe.

## Classe C: il perimetro delle radici documentali

Le sedici fuori perimetro, per trasparenza: `AI adoption`, `App`, `Attachments`, `Desktop`, `Documenti - Certificazioni`, `Documenti - Projects`, `Documenti condivisi - Resources`, `Documenti`, `File chat di Microsoft Copilot`, `Immagini`, `Marketing`, `Microsoft Teams Chat Files`, `Registrazioni`, `Riunioni`, `Scansioni`, `Whiteboards`. Due meritano un pensiero se il perimetro si allarga: `Documenti - Certificazioni` quando comincera' la Fase 5 ISO27001, e `Scansioni` se il servizio di scansione dovesse cambiare destinazione.

Esistono inoltre sul disco altre due librerie montate, `OneDrive` personale e `OneDrive - Intrawelt S.a.s (1)`, che sembra un doppio aggancio della stessa libreria aziendale: nessuna delle due e' sorvegliata, e la seconda va chiarita perche' un doppio mount produce copie divergenti.

La seconda libreria e' quella che il progetto sottovalutava. Un preventivo e un documento di trasporto non sembrano documentazione tecnica, ma sono l'unico posto dove compare un apparato nuovo prima che entri in rete, e sono l'unico posto dove si legge che un contratto e' stato firmato. I tre ritrovamenti del 03/08/2026 vengono tutti da li'.

## Classe D: quante sessioni convivono, e il caso dei due handoff invisibili

Su questa macchina convivono piu' installazioni dell'assistente, ciascuna con i propri progetti: al 03/08/2026 sono ventidue su un account, venti su un altro, quindici su un terzo, con sovrapposizioni. Alcuni di quei progetti toccano direttamente la rete che questo repository documenta.

Il caso che dimostra il difetto, scoperto il 03/08/2026: due documenti di handoff sul dimensionamento della VM207, datati 13/07/2026, con i valori reali di memoria, processori, disco e bridge di una macchina che questo progetto documenta come asset di rete, piu' un `CLAUDE.md` di progetto, si trovavano dentro una cartella che la lista di esclusione del delta scartava come "mirror di siti esterni". L'esclusione era corretta quando fu scritta, nel luglio 2026; poi un'altra sessione ha usato quella cartella per altro. Erano invisibili per costruzione, non per distrazione. Correzione applicata: i file il cui nome contiene `handoff` e i `CLAUDE.md` non vengono mai esclusi in base alla cartella, e compaiono nel blocco delle voci rilevanti.

## Classe E: la correzione che nessuna misura avrebbe prodotto

Esempio del 03/08/2026: la scheda descriveva due telefoni del Piano Terra come privi di lease DHCP, fotografia corretta al 23/07. La correzione — tutti e cinque collegati, ciascuno su una porta che prende la VLAN della fonia, lavoro concluso in sessioni precedenti — e' arrivata da qui, e solo dopo la misura l'ha corroborata. Nessuna interrogazione automatica l'avrebbe prodotta, perche' la tabella MAC dice dove sta un apparecchio, non che il lavoro e' finito.

## La storia di ADR-026: perche' il rinfresco e' diventato automatico

**Aggiornamento del 04/09/2026 (ADR-026): due di queste fonti non vanno piu' interrogate a mano.** Nebula e Proxmox si rinfrescano da un'attivita' pianificata che esegue `scripts/Invoke-RefreshFonti.ps1`. La regola che questo documento portava fino a ieri, cioe' che il rinfresco restasse manuale, e' superata: delle sue quattro ragioni tre reggono e sono attuate come guardie dello script, mentre la quarta — che rinfrescando da soli il confronto non potrebbe piu' dire "questa misura e' vecchia" — va rovesciata, perche' se le misure sono sempre fresche ogni scostamento diventa senza ambiguita' un documento sbagliato, che e' il caso che interessa. La **gestione endpoint resta manuale**: le sue credenziali appartengono al provider MSP (ADR-017) e non stanno in questo repository.

Della tabella delle cadenze e' stata tolta anche questa coda, che vale come misura: le scadenze di licenza e di contratto raccolte in `data/scadenze.json` prima vivevano sparse nella prosa dei documenti e non erano guardate da nessun meccanismo; erano sedici, e ogni incidente che in questo progetto ha fatto danno era una di quelle date.

## Le misure che hanno fatto nascere la regola

Il 03/08/2026 il progetto ha misurato tre affermazioni obsolete insieme — la distribuzione dei telefoni, il parco telefonico stimato un quinto del reale, e due acquisti di hardware di rete mai censiti — e nessuna delle tre era una contraddizione: erano affermazioni giuste che avevano smesso di esserlo. Tre delle correzioni di quel giorno sono venute dalle fonti vive e non da un documento.

Stato attuale della copertura, dal quale dipende la cadenza qui sopra: tutti e sei i dispositivi in inventario sono coperti con Professional Pack e le scadenze sono co-terminate; la data che vincola l'organizzazione e' la piu' vicina, il **22/11/2027**. Da presidiare in anticipo, perche' la grazia corre in silenzio e l'unico segnale e' una mail automatica.
