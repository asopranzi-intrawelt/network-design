---
last-verified: 8fbe3c2
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

# Lavoro corrente, riallineato il 22/09/2026

> Questa scheda dichiarava fino a oggi come attiva la Fase 1bis del 07/07/2026, cioè l'ingestione di OneDrive, conclusa da due mesi. Era la scheda più arretrata del progetto e il caso di scuola di ciò che ADR-026 combatte: un'affermazione vera quando fu scritta, che ha smesso di esserlo senza che nulla la contraddicesse. La storia di quel lavoro vive in `progress.md` e nella timeline, che sono i posti giusti; qui sta solo lo stato corrente.

## Il filo conduttore attuale

Nasce da una domanda operativa di fine agosto: aggiungere il traffico cifrato al gestore delle password. Per cifrare serve un certificato, per un certificato serve un nome, per un nome serve chi lo risolva, e per la firma serve un'autorità di cui qualcuno risponda. Nessuno dei quattro anelli esisteva.

Il terzo anello, la risoluzione dei nomi, è stato costruito e verificato. Il quarto, l'autorità di certificazione, è deciso e pronto ma non eseguito. Il primo, il gestore delle password, si è scoperto non collegato affatto. Lungo la strada il progetto ha costruito qualcosa che non era in programma e che ora vale più del filo da cui è nato, cioè l'impianto che gli impedisce di credere alle proprie affermazioni senza verificarle.

## Che cosa è in corso, in ordine di priorità

**M13c, la tratta esterna: assetto corretto dall'IT Manager il 28/09/2026.** Il WBE530 è stato acquistato, adottato in Nebula, montato nel cappotto da esterno e messo in servizio; la centrale di irrigazione si connette via Wi-Fi al nuovo AP e l'inverter è collegato alla **seconda porta Ethernet del WBE530**. **Non serve acquistare uno switch per questa tratta.** La diagnostica aveva misurato due coppie a cinquantaquattro metri e due a zero, ma la porta 4 è poi tornata a negoziare un gigabit: l'ipotesi di una tratta permanentemente limitata a 100 Mb/s è caduta. Il vecchio GS-105B v5 è documentato nella configurazione precedente e non fa parte del percorso attivo; la sua presenza fisica residua va verificata, senza dedurne un nuovo acquisto. M13c-10 diventa il riscontro dell'alimentazione del WBE530 e dell'anagrafica dell'inverter; M13c-8 resta il progetto VLAN 60. Per la licenza del WBE530 vale la misura del 10/09/2026 in `data/scadenze.json`, non la vecchia data di grazia del 24/09.

**R12, il completamento del servizio dei nomi.** I diciassette record sono pubblicati sul resolver del firewall e la catena è verificata su tutti e sette i passaggi sulla postazione dell'IT Manager. Manca portare le due impostazioni sulle altre ventiquattro macchine con la gestione endpoint, che non cambia nessun indirizzo ed è la ripetizione di una modifica già provata. **Corretto il 16/09/2026: non è più bloccato.** Questa scheda ha dichiarato fino a oggi R12 fermo in attesa della diagnosi di #185, e quella diagnosi era chiusa dall'08/09, cioè dal giorno prima della riscrittura che ha introdotto la frase. La causa di #185 è stata trovata leggendo per intero le politiche del firewall e non dedotta: la zona della Wi-Fi del personale, a differenza delle altre zone interne, non ha nessuna regola di permesso verso l'apparato stesso. Sulla LAN principale quella regola c'è già, quindi portare le due impostazioni sulle ventiquattro postazioni non tocca nessuna politica e non è la stessa modifica che ha rotto la Wi-Fi: è azionabile subito. La fonte che lo dimostra è `progress.md`, voci del 2026-09-08, ed è il motivo per cui su questo punto vale quel registro e non la prosa di questa scheda.

**#185, chiuso l'08/09/2026, e ciò che resta di suo è un rimedio da confermare.** Puntando la Wi-Fi del personale al firewall come server dei nomi i dispositivi avevano perso la risoluzione, ripristinata in pochi minuti. L'ipotesi dell'ambito DHCP è stata **esclusa** e non solo archiviata; la causa è l'assenza di una regola di permesso dalla zona di quella rete verso l'apparato, con la regola in uscita che esclude esplicitamente l'apparato stesso, quindi la richiesta al servizio dei nomi cadeva sulla regola finale che nega. Resta aperto e distinto **R20**, il rimedio scomposto, cioè una regola nuova limitata al solo servizio dei nomi invece del gruppo predefinito più largo, per non sostituire un guasto visibile con un rischio invisibile. Nessuna voce del registro conferma che R20 sia stato eseguito: va controllato in apertura, e non dipende da R12.

**#200, chiuso il 16/09/2026; il seguito vero è #204.** La diagnosi iniziale sul controller era sbagliata: batteria, controller, tre SSD, lettura grezza del volume, compressione e bus `ide0` sono stati assolti da misure dirette, quindi non si ordina alcun componente e non serve una finestra di spegnimento per questa causa. Lo stesso backup eseguito su disco locale ha raggiunto 519,8 MiB/s contro 233 minuti verso il deposito di rete. Il collo di bottiglia è il NAS principale, che scrive a 10,5 MB/s e legge a 15,8 MB/s mentre l'altro deposito, dallo stesso nodo e sulla stessa sottorete, scrive a 110 MB/s. Il lavoro corrente è **M28-8 / #204 (STOR-007)**: leggere dal pannello del NAS stato dei dischi e dell'insieme, carico, lavori in corso, firmware, versione massima di SMB, velocità e aggregazione delle due interfacce. SMB 2.1 è un indizio, non ancora una causa. In parallelo **#203 è chiuso** perché le VM 207, 208 e 209 hanno ora un lavoro di backup, ma la catena è salita a dieci lavori e resta una collisione alle 04:30 da sciogliere; gli orari si ridimensionano dopo aver sanato M28-8. Restano da leggere l'ora di conclusione dell'ultimo lavoro e da cronometrare un ripristino reale. Vincoli invariati: frequenza giornaliera per tutti i guest e destinazioni di backup invariate.

**#117, il rischio più alto aperto.** Il portale documentale serve credenziali e documenti dei clienti in chiaro attraverso otto passaggi di rete pubblica. Il rimedio era identificato a luglio ed è fermo da sette settimane per nessuna ragione tecnica. Non dipende da nessuna delle altre voci.

**L'autorità di certificazione.** ADR-024 fissa i nomi, ADR-025 la custodia fuori linea con passphrase. `crea-autorita.sh` ed `emetti-certificato.sh` sono scritti, versionati, senza alcun valore reale e **mai eseguiti**. Indipendente da tutto il resto; una volta fatta, il gestore delle password diventa collegabile. La sequenza da non sbagliare è autorità, poi certificato del gestore, poi deposito della passphrase dentro il gestore: la passphrase non può stare nel gestore prima che il gestore funzioni.

**#192, la copia fuori sede.** Misurata l'08/09/2026: ne esiste una sola, copre due anni su tre, non è cifrata dal lato del cliente e la sua integrità non è mai stata verificata. Il passo più economico e più informativo è il primo controllo di integrità sulla copia cloud, che è a un clic.

## L'impianto costruito fra il 4 e l'8 settembre, e perché conta

Il progetto ha smesso di dipendere dalla memoria di chi lavora. **ADR-026** stabilisce che ogni affermazione dei file tracciati deve avere una verifica meccanica, una scadenza dichiarata dopo la quale torna a stato non verificata, oppure una marcatura esplicita di non verificabile con la domanda già scritta e la persona a cui porla. Non esiste un quarto caso.

L'attuazione è `data/scadenze.json`, tracciato, più `scripts/Test-Allineamento.py` che lo valuta all'avvio di ogni sessione insieme a cinque invarianti strutturali calcolati sul repository. Il rinfresco delle fonti vive è passato a un'attività pianificata con tre guardie, e dall'08/09 è verificato che parte da sola. **ADR-027** apre il confine verso il template per la sola risalita di una capacità che là manchi.

Il motivo per cui questo è la voce più importante della scheda: in cinque giorni quell'impianto ha trovato una copia di backup ferma da sei settimane che ogni documento dava per esistente, una scheda dello stack che elencava cinque script su ventuno, dodici prefissi reali che il guard-rail non cercava, un'automazione che non era mai partita, e una replica fuori sede documentata che non esiste. Nessuno di questi era una contraddizione visibile a un lettore attento.

## Le domande aperte che solo una persona può chiudere

Vivono nel blocco `asserzioni_umane` di `data/scadenze.json` e tornano a video a ogni avvio di sessione quando la loro validità scade. Al 22/09/2026 il registro è alla revisione 17. Le ipotesi su cache, batteria, dischi, compressione, bus e collegamento a 100 Mb/s sono conservate con la loro smentita, perché una domanda chiusa che sparisce lascia solo un'affermazione senza provenienza. Le domande vive del filone backup sono ora quattro: perché il NAS principale sia dieci volte più lento dell'altro; se la collisione delle 04:30 sia stata sciolta e a che ora finisca l'ultimo dei dieci lavori; quanto duri davvero un ripristino; e se i due alimentatori del server siano cablati a linee distinte. Restano inoltre le domande precedenti, fra cui la garanzia del server acquistato usato e la chiave pre-condivisa del tunnel verso il fornitore di hosting, che l'IT Manager dichiara di non sapere se sia mai stata ruotata, il che ai fini operativi equivale a un no. L'IT Manager ha confermato il 22/09/2026 che dal 16/09/2026 non è cambiato nulla sulla rete fuori dal repository.

## Vincoli permanenti dell'IT Manager

Sul backup delle macchine virtuali, dichiarati il 16/09/2026: la frequenza resta **giornaliera per tutti i guest**, e una proposta di diradarne uno è stata esplicitamente rifiutata, quindi non si ripropone; le **destinazioni non cambiano**. Ne discende che ogni rimedio alla lentezza va cercato sullo storage e non sul calendario.

I collegamenti fisici del server non si spostano, quindi #157 non si risolve ricablando e la DMZ deve appoggiarsi al bridge già su porta gestita. Nessun intervento deve togliere agli endpoint l'accesso ai servizi interni: segmentare significa rendere esplicito e filtrato ciò che oggi è implicito e non filtrato, non interrompere. Gli indirizzi delle postazioni restano statici, che è compatibile con tutto perché indirizzo e server dei nomi sono impostazioni distinte. Il portale documentale deve restare raggiungibile da fuori, ed esposizione e cifratura sono proprietà indipendenti.

## Definition of done della fase corrente

R12 chiuso su tutte le postazioni, R20 eseguito e verificato (#185 è diagnosticato e chiuso dall'08/09/2026, e questa riga lo chiedeva ancora), l'autorità di certificazione generata con la sua chiave fuori linea, e il gestore delle password raggiungibile in cifrato con un certificato emesso da quell'autorità. A quel punto il filo conduttore da cui tutto è partito è completo, e la fase successiva è la segmentazione di M22.
