---
last-verified: 8a51761
---

## Direttiva permanente: cinque livelli di tracciamento (dal 16/07/2026)

L'utente ha fissato un obiettivo dichiarato: **certificazione ISO27001 entro marzo 2027** (vedi `roadmap.md` Fase 5). Da questa data, ogni interazione di questa sessione — non solo i micro-step espliciti — va tracciata su cinque livelli quando rilevante, non solo uno:

1. **Didattico** — narrazione estesa in `_notes/DIARIO.md`, stile dei grandi .docx originali ingeriti: spiega il concetto, non solo il fatto.
2. **Deep-dive tecnico** — la scheda tecnica pertinente in `docs/` o `.claude/context/` (sintassi verificata, dati reali, non inferenze).
3. **Comunicazione stakeholder** — il taglio riassuntivo/valore-per-CV richiesto per il resoconto finale di ogni intervento concluso.
4. **Linea cronologica** — `docs/infrastructure-timeline/*.md` e `.claude/memory/progress.md`, ordine temporale esplicito.
5. **ISO27001** — quando un fatto tocca un controllo Annex A (gap di segmentazione, accesso, flusso dati, patching, backup...), va registrato anche in `design-and-security.md` §Gap di sicurezza, a prescindere da quando la Fase 5 formale comincia.

Non ogni fatto attiva tutti e cinque i livelli (una correzione di sintassi in uno script non è materiale ISO27001), ma il controllo va fatto ad ogni passo, non solo a fine intervento.

---

# Lavoro corrente, riscritto l'08/09/2026

> Questa scheda dichiarava fino a oggi come attiva la Fase 1bis del 07/07/2026, cioè l'ingestione di OneDrive, conclusa da due mesi. Era la scheda più arretrata del progetto e il caso di scuola di ciò che ADR-026 combatte: un'affermazione vera quando fu scritta, che ha smesso di esserlo senza che nulla la contraddicesse. La storia di quel lavoro vive in `progress.md` e nella timeline, che sono i posti giusti; qui sta solo lo stato corrente.

## Il filo conduttore attuale

Nasce da una domanda operativa di fine agosto: aggiungere il traffico cifrato al gestore delle password. Per cifrare serve un certificato, per un certificato serve un nome, per un nome serve chi lo risolva, e per la firma serve un'autorità di cui qualcuno risponda. Nessuno dei quattro anelli esisteva.

Il terzo anello, la risoluzione dei nomi, è stato costruito e verificato. Il quarto, l'autorità di certificazione, è deciso e pronto ma non eseguito. Il primo, il gestore delle password, si è scoperto non collegato affatto. Lungo la strada il progetto ha costruito qualcosa che non era in programma e che ora vale più del filo da cui è nato, cioè l'impianto che gli impedisce di credere alle proprie affermazioni senza verificarle.

## Che cosa è in corso, in ordine di priorità

**M13c, la tratta esterna: intervento aperto e deciso il 09/09/2026.** Il baricentro non è più la sostituzione del quarto access point EOL ma quella dell'apparato di diramazione: **ADR-029** stabilisce che il GS-105B non gestito lasci il posto a uno switch gestito e PoE collegato alla porta 4 del XGS2220-30HP, con l'access point nuovo appeso a quello in PoE e in cappotto da esterno, e con centrale di irrigazione e inverter del fotovoltaico che restano cablati. Due fatti misurati lo hanno determinato: dal GS-105B escono tre rami mentre l'access point del preventivo porta un uplink più una sola porta LAN, e la VLAN 60 di M13c-8 richiede un apparato che sappia taggare. Tre cose vanno fatte in quest'ordine e nessuna è rimandabile. La **Cable diagnostic** sulle porte 3 e 4, fuori da una finestra di irrigazione, perché entrambe negoziano 100 Mb/s con zero errori su dorsale in 6a e il sospetto è una terminazione a quattro fili (#196): decide se la tratta va ri-terminata nella stessa uscita in cui si monta il cappotto, e se l'apparato Wi-Fi 7 acquistato resta strozzato per sempre. L'ordine, con la conferma che l'access point del preventivo del 31/07 sia stato davvero ordinato, che nessuna fonte conferma. E le **due licenze Nebula** entro quindici giorni da ciascuna adozione, co-terminate al 22/11/2027, perché gli apparati che entrano in organizzazione sono due e un solo apparato scoperto spegne la OpenAPI per tutti (M13c-9, NEB-002). Il sotto-passo nuovo è **M13c-10**, la sostituzione fisica con la ricostruzione dei tre rami e la lettura dell'anagrafica dell'inverter, che è l'unico momento in cui costa poco.

**R12, il completamento del servizio dei nomi.** I diciassette record sono pubblicati sul resolver del firewall e la catena è verificata su tutti e sette i passaggi sulla postazione dell'IT Manager. Manca portare le due impostazioni sulle altre ventiquattro macchine con la gestione endpoint, che non cambia nessun indirizzo ed è la ripetizione di una modifica già provata. **È bloccato da #185** e non va fatto prima: la stessa modifica sulla Wi-Fi del personale ha causato un'interruzione di cui non si conosce la causa, e ripeterla su venticinque macchine senza aver capito sarebbe imprudente.

**#185, l'incidente da diagnosticare.** Puntando la Wi-Fi del personale al firewall come server dei nomi, i dispositivi hanno perso la risoluzione; ripristinato in pochi minuti. Una prima ipotesi è stata verificata e smentita. Le due da verificare, in ordine, sono la politica di sicurezza dalla zona di quella rete verso l'apparato stesso e quale indirizzo l'apparato distribuisca come server dei nomi. Richiede la GUI del firewall, quindi richiede l'IT Manager con uno screenshot.

**#117, il rischio più alto aperto.** Il portale documentale serve credenziali e documenti dei clienti in chiaro attraverso otto passaggi di rete pubblica. Il rimedio era identificato a luglio ed è fermo da sette settimane per nessuna ragione tecnica. Non dipende da nessuna delle altre voci.

**L'autorità di certificazione.** ADR-024 fissa i nomi, ADR-025 la custodia fuori linea con passphrase. `crea-autorita.sh` ed `emetti-certificato.sh` sono scritti, versionati, senza alcun valore reale e **mai eseguiti**. Indipendente da tutto il resto; una volta fatta, il gestore delle password diventa collegabile. La sequenza da non sbagliare è autorità, poi certificato del gestore, poi deposito della passphrase dentro il gestore: la passphrase non può stare nel gestore prima che il gestore funzioni.

**#192, la copia fuori sede.** Misurata l'08/09/2026: ne esiste una sola, copre due anni su tre, non è cifrata dal lato del cliente e la sua integrità non è mai stata verificata. Il passo più economico e più informativo è il primo controllo di integrità sulla copia cloud, che è a un clic.

## L'impianto costruito fra il 4 e l'8 settembre, e perché conta

Il progetto ha smesso di dipendere dalla memoria di chi lavora. **ADR-026** stabilisce che ogni affermazione dei file tracciati deve avere una verifica meccanica, una scadenza dichiarata dopo la quale torna a stato non verificata, oppure una marcatura esplicita di non verificabile con la domanda già scritta e la persona a cui porla. Non esiste un quarto caso.

L'attuazione è `data/scadenze.json`, tracciato, più `scripts/Test-Allineamento.py` che lo valuta all'avvio di ogni sessione insieme a cinque invarianti strutturali calcolati sul repository. Il rinfresco delle fonti vive è passato a un'attività pianificata con tre guardie, e dall'08/09 è verificato che parte da sola. **ADR-027** apre il confine verso il template per la sola risalita di una capacità che là manchi.

Il motivo per cui questo è la voce più importante della scheda: in cinque giorni quell'impianto ha trovato una copia di backup ferma da sei settimane che ogni documento dava per esistente, una scheda dello stack che elencava cinque script su ventuno, dodici prefissi reali che il guard-rail non cercava, un'automazione che non era mai partita, e una replica fuori sede documentata che non esiste. Nessuno di questi era una contraddizione visibile a un lettore attento.

## Le domande aperte che solo una persona può chiudere

Vivono nel blocco `asserzioni_umane` di `data/scadenze.json` e tornano a video a ogni avvio di sessione quando la loro validità scade. All'08/09/2026 sono quattro: di quale macchina parli il documento sulla crittografia del disco, se la chiave pre-condivisa del tunnel verso il fornitore di hosting sia ancora quella del 2018, se la scansione verso cartella del multifunzione funzioni dopo l'aggiornamento del firmware del 25/08, e quanti posti liberi restino sull'abbonamento di protezione endpoint, che al 07/09 erano due su trenta.

## Vincoli permanenti dell'IT Manager

I collegamenti fisici del server non si spostano, quindi #157 non si risolve ricablando e la DMZ deve appoggiarsi al bridge già su porta gestita. Nessun intervento deve togliere agli endpoint l'accesso ai servizi interni: segmentare significa rendere esplicito e filtrato ciò che oggi è implicito e non filtrato, non interrompere. Gli indirizzi delle postazioni restano statici, che è compatibile con tutto perché indirizzo e server dei nomi sono impostazioni distinte. Il portale documentale deve restare raggiungibile da fuori, ed esposizione e cifratura sono proprietà indipendenti.

## Definition of done della fase corrente

R12 chiuso su tutte le postazioni, #185 diagnosticato, l'autorità di certificazione generata con la sua chiave fuori linea, e il gestore delle password raggiungibile in cifrato con un certificato emesso da quell'autorità. A quel punto il filo conduttore da cui tutto è partito è completo, e la fase successiva è la segmentazione di M22.
