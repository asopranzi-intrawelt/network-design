---
last-verified: beccead
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

**R12, il completamento del servizio dei nomi.** I diciassette record sono pubblicati sul resolver del firewall e la catena è verificata su tutti e sette i passaggi sulla postazione dell'IT Manager. Manca portare le due impostazioni sulle altre ventiquattro macchine con la gestione endpoint, che non cambia nessun indirizzo ed è la ripetizione di una modifica già provata. **Corretto il 16/09/2026: non è più bloccato.** Questa scheda ha dichiarato fino a oggi R12 fermo in attesa della diagnosi di #185, e quella diagnosi era chiusa dall'08/09, cioè dal giorno prima della riscrittura che ha introdotto la frase. La causa di #185 è stata trovata leggendo per intero le politiche del firewall e non dedotta: la zona della Wi-Fi del personale, a differenza delle altre zone interne, non ha nessuna regola di permesso verso l'apparato stesso. Sulla LAN principale quella regola c'è già, quindi portare le due impostazioni sulle ventiquattro postazioni non tocca nessuna politica e non è la stessa modifica che ha rotto la Wi-Fi: è azionabile subito. La fonte che lo dimostra è `progress.md`, voci del 2026-09-08, ed è il motivo per cui su questo punto vale quel registro e non la prosa di questa scheda.

**#185, chiuso l'08/09/2026, e ciò che resta di suo è un rimedio da confermare.** Puntando la Wi-Fi del personale al firewall come server dei nomi i dispositivi avevano perso la risoluzione, ripristinata in pochi minuti. L'ipotesi dell'ambito DHCP è stata **esclusa** e non solo archiviata; la causa è l'assenza di una regola di permesso dalla zona di quella rete verso l'apparato, con la regola in uscita che esclude esplicitamente l'apparato stesso, quindi la richiesta al servizio dei nomi cadeva sulla regola finale che nega. Resta aperto e distinto **R20**, il rimedio scomposto, cioè una regola nuova limitata al solo servizio dei nomi invece del gruppo predefinito più largo, per non sostituire un guasto visibile con un rischio invisibile. Nessuna voce del registro conferma che R20 sia stato eseguito: va controllato in apertura, e non dipende da R12.

**#200, il backup delle macchine virtuali, arrivato da fuori il 16/09/2026.** Due lavori su otto sono falliti nella notte fra il 15 e il 16 per attesa scaduta sul lock di vzdump, e la causa non sta nei backup: la cache del controller RAID del nodo risulta disabilitata, con un pavimento di lettura cronico di circa un decimo di quello atteso. Il rimedio applicato dalla sessione che ha indagato è dichiarato come cerotto e va letto per quello che fa davvero: portando l'attesa sul lock a ventiquattro ore i lavori completano e restano lenti, e poiché la notifica scatta solo sul fallimento si è spento l'unico segnale che qualcuno riceveva. Tre cose, in quest'ordine. La **conferma diagnostica** con lo strumento del produttore, perché la causa è dedotta e non letta, ed è la sola cosa che giustifica una finestra di spegnimento del nodo. La **lettura della pagina dei task**, perché il silenzio della posta non è più una buona notizia. E la **misura del tempo di ripristino**, che la scheda di continuità lascia intendere e che nessuno ha mai cronometrato, su uno storage che riscrive lento quanto legge. La riparazione definitiva è la sostituzione di un componente interno e richiede lo spegnimento del nodo, quindi di tutte le macchine virtuali: si pianifica dopo la conferma, non prima. Vincoli dichiarati dall'IT Manager e da rispettare: frequenza giornaliera su tutti i guest e destinazioni di backup invariate.

**#117, il rischio più alto aperto.** Il portale documentale serve credenziali e documenti dei clienti in chiaro attraverso otto passaggi di rete pubblica. Il rimedio era identificato a luglio ed è fermo da sette settimane per nessuna ragione tecnica. Non dipende da nessuna delle altre voci.

**L'autorità di certificazione.** ADR-024 fissa i nomi, ADR-025 la custodia fuori linea con passphrase. `crea-autorita.sh` ed `emetti-certificato.sh` sono scritti, versionati, senza alcun valore reale e **mai eseguiti**. Indipendente da tutto il resto; una volta fatta, il gestore delle password diventa collegabile. La sequenza da non sbagliare è autorità, poi certificato del gestore, poi deposito della passphrase dentro il gestore: la passphrase non può stare nel gestore prima che il gestore funzioni.

**#192, la copia fuori sede.** Misurata l'08/09/2026: ne esiste una sola, copre due anni su tre, non è cifrata dal lato del cliente e la sua integrità non è mai stata verificata. Il passo più economico e più informativo è il primo controllo di integrità sulla copia cloud, che è a un clic.

## L'impianto costruito fra il 4 e l'8 settembre, e perché conta

Il progetto ha smesso di dipendere dalla memoria di chi lavora. **ADR-026** stabilisce che ogni affermazione dei file tracciati deve avere una verifica meccanica, una scadenza dichiarata dopo la quale torna a stato non verificata, oppure una marcatura esplicita di non verificabile con la domanda già scritta e la persona a cui porla. Non esiste un quarto caso.

L'attuazione è `data/scadenze.json`, tracciato, più `scripts/Test-Allineamento.py` che lo valuta all'avvio di ogni sessione insieme a cinque invarianti strutturali calcolati sul repository. Il rinfresco delle fonti vive è passato a un'attività pianificata con tre guardie, e dall'08/09 è verificato che parte da sola. **ADR-027** apre il confine verso il template per la sola risalita di una capacità che là manchi.

Il motivo per cui questo è la voce più importante della scheda: in cinque giorni quell'impianto ha trovato una copia di backup ferma da sei settimane che ogni documento dava per esistente, una scheda dello stack che elencava cinque script su ventuno, dodici prefissi reali che il guard-rail non cercava, un'automazione che non era mai partita, e una replica fuori sede documentata che non esiste. Nessuno di questi era una contraddizione visibile a un lettore attento.

## Le domande aperte che solo una persona può chiudere

Vivono nel blocco `asserzioni_umane` di `data/scadenze.json` e tornano a video a ogni avvio di sessione quando la loro validità scade. Al 16/09/2026 il registro è alla revisione 11 e ne porta tredici, di cui otto già chiuse con una risposta o una misura e conservate con l'esito scritto accanto, perché una domanda chiusa che sparisce lascia solo un'affermazione senza provenienza. Le tre più recenti nascono tutte dal backup del nodo: se la cache del controller sia spenta **perché** il modulo che la protegge è guasto, che è dedotto e non letto ed è la sola cosa che giustifica una finestra di spegnimento; se gli otto lavori notturni completino davvero da quando l'attesa sul lock è a ventiquattro ore, che ha validità di una settimana perché il rimedio ha spento la notifica che lo avrebbe detto; e quanto duri davvero un ripristino, che nessuno ha mai cronometrato. Le altre restano quelle di settembre, fra cui la chiave pre-condivisa del tunnel verso il fornitore di hosting, che l'IT Manager dichiara di non sapere se sia mai stata ruotata, il che ai fini operativi equivale a un no.

## Vincoli permanenti dell'IT Manager

Sul backup delle macchine virtuali, dichiarati il 16/09/2026: la frequenza resta **giornaliera per tutti i guest**, e una proposta di diradarne uno è stata esplicitamente rifiutata, quindi non si ripropone; le **destinazioni non cambiano**. Ne discende che ogni rimedio alla lentezza va cercato sullo storage e non sul calendario.

I collegamenti fisici del server non si spostano, quindi #157 non si risolve ricablando e la DMZ deve appoggiarsi al bridge già su porta gestita. Nessun intervento deve togliere agli endpoint l'accesso ai servizi interni: segmentare significa rendere esplicito e filtrato ciò che oggi è implicito e non filtrato, non interrompere. Gli indirizzi delle postazioni restano statici, che è compatibile con tutto perché indirizzo e server dei nomi sono impostazioni distinte. Il portale documentale deve restare raggiungibile da fuori, ed esposizione e cifratura sono proprietà indipendenti.

## Definition of done della fase corrente

R12 chiuso su tutte le postazioni, R20 eseguito e verificato (#185 è diagnosticato e chiuso dall'08/09/2026, e questa riga lo chiedeva ancora), l'autorità di certificazione generata con la sua chiave fuori linea, e il gestore delle password raggiungibile in cifrato con un certificato emesso da quell'autorità. A quel punto il filo conduttore da cui tutto è partito è completo, e la fase successiva è la segmentazione di M22.
