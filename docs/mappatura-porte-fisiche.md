# Mappatura porte fisiche - Via Pescolla 2, Porto Sant'Elpidio

Fonti: `porte_fisiche_via_pescolla_2.xlsx` (trascrizione, ultimo aggiornamento aprile 2026) e `intrawelt rete dati.pdf` (scansione del rilievo manoscritto "Prese dati" di Luciani Impianti, installatore elettrico, datato 20/08/2020), entrambe in `ARCHITETTURA SERVER-CLOUD-LINEE/Mappatura porte fisiche/`. Ingestione completa del 07/07/2026, in sostituzione dell'estratto parziale precedente.

Convenzione: `<Piano>-<Ufficio>-<Numero>`. R = rack/switch. Per ogni piano il numero dell'ufficio decresce in senso orario, partendo dall'ufficio a sinistra.

## Nome progettato e nome attuale

Il rilievo del 2020 e la trascrizione Excel portano due colonne: il nome porta di progetto e il "nome porta attuale", cioe' l'etichetta realmente presente. Le due colonne NON coincidono per molte prese: al momento del rilievo diverse etichette risultavano permutate (esempio Reception: la presa di progetto 0-5-1 portava l'etichetta 0-5-7 e viceversa; la coppia stampante 0-x-13/14 di ogni ufficio del Piano 0 era marcata "da fare" con etichetta 0-x-1/2). Questa permutazione sistematica di etichette e' la spiegazione piu' probabile della contraddizione NET-007 sulla porta del telefono di Persona-A (GAP-TBC #67/#99): un errore di etichettatura, non uno spostamento fisico. Le tabelle sotto riportano il nome di progetto e, dove differisce, l'etichetta attuale rilevata.

---

## Piano 0 (Terra)

### Reception (0-5), 8 porte
| Porta | Tipo | Etichetta attuale |
|-------|------|-------------------|
| 0-5-1 | Postazione | 0-5-7 |
| 0-5-2 | Postazione | 0-5-8 |
| 0-5-3 | Postazione | 0-5-9 |
| 0-5-4 | Postazione | = |
| 0-5-5 | Postazione | = (nota "da controllare") |
| 0-5-6 | Postazione | = |
| 0-5-7 | Stampante | 0-5-1 |
| 0-5-8 | Postazione | 0-5-2 |

### Ufficio 1 (0-1), 14 porte
0-1-1 .. 0-1-12 postazioni, 0-1-13 stampante, 0-1-14 postazione. Etichette attuali permutate al rilievo 2020 (0-1-1 -> "0-1-7", 0-1-7 -> "0-1-13", eccetera); coppia 0-1-13/14 etichettata 0-1-1/2, relabeling "da fare".

### Ufficio 2 (0-2), 13 porte in Excel
0-2-1 .. 0-2-11 postazioni, 0-2-12 stampante, 0-2-13 postazione. [TBC: il rilievo 2020 mostra 14 porte con stampante in 0-2-13 come per l'Ufficio 1; la trascrizione Excel ne riporta 13 con stampante in 0-2-12. Verificare sul posto quale delle due e' corretta.]

### Ufficio 3 (0-3), 14 porte
0-3-1 .. 0-3-14, tutte postazioni in Excel (nessuna stampante censita). Nel rilievo 2020 marcato "OK" (etichette gia' corrette).

Aggiornamento 10/07/2026: la postazione di Persona-D, in seguito a un cambio di indirizzo IP, e' stata spostata dalla presa 0-3-3 alla presa 0-R-4 (patch diretta verso il rack, vedi Infrastruttura Piano Terra). La 0-3-3 risulta libera.

### Ufficio 4 (0-4), 14 porte
0-4-1 .. 0-4-14, tutte postazioni. Ufficio condiviso da quattro postazioni nominative (i nomi propri restano nel file sorgente, non qui). Nel rilievo 2020 marcato "OK".

### Relax (0-6)
| Porta | Tipo | Note |
|-------|------|------|
| 0-6-1 | TV | TV ancora da installare |

### Infrastruttura Piano Terra
| Porta | Tipo | Note |
|-------|------|------|
| 0-7-1 | Access Point | AP Piano Terra, adattatore PoE (rimosso con XGS2220-30HP) |
| 0-8-1 | Locale Caldaia | Patch panel -> patch verso 0-9-1. Qui stava il Cisco switch (rimosso: sostituito da XGS2220-30HP). Da parete arriva alla **porta 4 del XGS2220-30HP** |
| 0-9-1 | Derivazione tetto | Fa ponte con 0-8-1. **Non e' un access point**: da qui parte un cavo di categoria 6 verso la centrale di irrigazione, e in mezzo gli elettricisti hanno inserito uno **Zyxel GS-105B v5** per diramare l'access point esterno e l'inverter del fotovoltaico. Correzione del 03/08/2026, vedi sotto |
| 0-10-1 | Lettore impronte | BioStar (IP 10.61.20.199). Cavo rete al lettore esterno; RS485 tra connettore interno ed esterno; la rete lo vede come dispositivo unico. Problemi dal 07/02/2025. **Attestazione identificata il 06/08/2026**: e' l'unita' master del sistema di rilevazione presenze Suprema, collegata alla **porta 3 del XGS2220-30HP** (100 Mbps, PVID 1, `allowedVLAN` uguale ad `all`). Chiude la domanda aperta di NET-020 sulla porta 3; apre NET-021 sull'asset non inventariato |
| 0-R-18 | Router/Switch | Cisco (rimosso). Collegava direttamente il firewall Zyxel al Piano 2. Con la dorsale SFP+ il Piano Terra e' collegato allo switch Piano 2 (XGS2220-54HP) via fibra. |
| 0-R-4 | Postazione | Persona-D, dal 10/07/2026 (ex 0-3-3, vedi Ufficio 3). Patch diretta al rack a seguito di un aggiornamento dell'indirizzo IP della postazione. |

**Nota post-installazione XGS2220-30HP (aprile 2026):** Il Cisco switch e l'adattatore PoE esterno sono stati rimossi. Il nuovo switch Layer 3 Zyxel XGS2220-30HP gestisce tutte le porte del Piano Terra con PoE+ integrato. L'uplink verso il Piano 2 e' SFP+ 10 Gbps su fibra (operativo dall'08/05/2026).

---

## Piano 1

Totale prese dati rilevate nel 2020: 53 + 2 (annotazione a margine del rilievo).

### Ufficio 1 - Persona-A (1-1), 6 porte
| Porta | Tipo | Posizione |
|-------|------|-----------|
| 1-1-1 .. 1-1-4 | Postazione | Sotto scrivania |
| 1-1-5 .. 1-1-6 | Postazione | Presa muro separatore con scale |

Nel rilievo 2020 l'ufficio e' marcato "OK" (etichette corrette).

### Ufficio 2 - Persona-B (1-2), 6 porte
| Porta | Tipo | Etichetta attuale | Posizione |
|-------|------|-------------------|-----------|
| 1-2-1 | Postazione | 1-2-5 | Presa muro separatore con Ufficio IT |
| 1-2-2 | Postazione | 1-2-6 | Presa muro separatore con Ufficio IT |
| 1-2-3 | Postazione | = | Presa muro separatore con Ufficio Persona-A |
| 1-2-4 | Postazione | = | Presa muro separatore con Ufficio Persona-A |
| 1-2-5 | Postazione | 1-2-1 | Presa muro separatore con Ufficio Persona-A |
| 1-2-6 | Postazione | 1-2-2 | Presa muro separatore con Ufficio Persona-A |

Nel rilievo 2020 la 1-2-5 di progetto era la stampante; nella trascrizione Excel le sei porte risultano tutte postazioni. [TBC: presenza stampante.]

### Ufficio 3 - Ufficio IT / Alessio (1-3), 14 porte
| Porta | Tipo | Etichetta attuale | Posizione |
|-------|------|-------------------|-----------|
| 1-3-1 | Postazione | 1-3-7 | |
| 1-3-2 | Postazione | 1-3-8 | |
| 1-3-3 .. 1-3-6 | Postazione | = | |
| 1-3-7 | Postazione | 1-3-13 | A sx dell'ingresso, sotto appendiabiti |
| 1-3-8 | Postazione | 1-3-14 | A sx dell'ingresso, sotto appendiabiti |
| 1-3-9 .. 1-3-12 | Postazione | = | |
| 1-3-13 | Postazione | 1-3-1 | (stampante nel rilievo 2020) |
| 1-3-14 | Postazione | 1-3-2 | |

### Ufficio 4 (1-4), 14 porte
1-4-1 .. 1-4-14, tutte postazioni, etichette coerenti. Nel rilievo 2020 "OK".

### Ufficio 5 (1-5), 14 porte
1-5-1 .. 1-5-14, tutte postazioni, etichette coerenti. Nel rilievo 2020 "OK".

### Ufficio 6 (1-6), 11 porte
| Porta | Tipo | Etichetta attuale |
|-------|------|-------------------|
| 1-6-1 | Postazione | 1-6-7 |
| 1-6-2 | Postazione | 1-6-8 |
| 1-6-3 .. 1-6-6 | Postazione | = |
| 1-6-7 | Postazione | 1-6-10 |
| 1-6-8 | Postazione | 1-6-11 |
| 1-6-9 | Postazione | = |
| 1-6-10 | Postazione | 1-6-1 (stampante nel rilievo 2020) |
| 1-6-11 | Postazione | 1-6-2 |

### Infrastruttura Piano 1
| Porta | Tipo | Note |
|-------|------|------|
| 1-7-1 | Stampante | Atrio |
| 1-7-2 | (libera) | Atrio |
| 1-8-1 | Access Point | |

---

## Piano 2

Totale prese dati rilevate nel 2020: 39 (annotazione a margine del rilievo).

### Sala Riunioni (2-1), 6 porte
| Porta | Tipo | Note |
|-------|------|------|
| 2-1-1 | Postazione | Relatore |
| 2-1-2 | Postazione | |
| 2-1-3 | Postazione | |
| 2-1-4 | Stampante | |
| 2-1-5 | Postazione | |
| 2-1-6 | Postazione | TV |

Etichette "OK" al rilievo 2020.

### Sala Convegni (2-2), 4 porte
| Porta | Tipo | Etichetta attuale | Note |
|-------|------|-------------------|------|
| 2-2-1 | Postazione | 2-2-2 | Relatore |
| 2-2-2 | Postazione | 2-2-3 | |
| 2-2-3 | Postazione | 2-2-4 | |
| 2-2-4 | Postazione | 2-2-1 | TV |

Permutazione ciclica completa delle etichette (rilevata gia' nel 2020, confermata nella trascrizione 2026).

### Ufficio Piano 2 (2-3), 18 porte
| Porte | Tipo | Posizione |
|-------|------|-----------|
| 2-3-1 .. 2-3-8 | Postazione | Torretta ovest |
| 2-3-9 .. 2-3-10 | Postazione | Torretta est |
| 2-3-11 | Stampante | Torretta est |
| 2-3-12 .. 2-3-16 | Postazione | Torretta est |
| 2-3-17 | Stampante | |
| 2-3-18 | (varia) | |

Etichette coerenti ("OK" al rilievo).

### CED - Sala Server Piano 2 (2-4, 2-5, 2-6, 2-7)
| Porta | Tipo | Etichetta attuale | Note |
|-------|------|-------------------|------|
| 2-4-1 | Postazione IT | = | Postazione sud |
| 2-4-2 | Postazione IT | = | Postazione sud |
| 2-4-3 | Postazione IT | = | Postazione sud (il rilievo 2020 annota "2-4-3 -> 2-4-4") |
| 2-4-4 | Postazione IT | 2-4-5 | Postazione ovest |
| (2-4-5) | Postazione IT | 2-4-6 | Postazione ovest (senza nome di progetto in Excel) |
| (2-4-6) | Postazione IT | 2-4-7 | Postazione ovest (senza nome di progetto in Excel) |
| 2-4-8 | Stampante | = | Postazione ovest |
| 2-5-1 | Access Point | = | AP CED (sotto) |
| 2-5-2 | MH Server | = | MyHome Server domotica |
| 2-6-1 | Domotica | = | Concentratore parametri riscaldamento (termoregolazione). [TBC: tipo dispositivo] |
| 2-6-2 | Allarme | = | Centrale allarme intrusione (connessa in rete) |
| 2-7-1 | Access Point | = | AP esterno tetto |

**Note domotica (da Excel):** Il sistema BUS domotica arriva via cavo non Ethernet al quadro elettrico del Piano 2. Il MH Server (MyHome server Bticino) al Piano 2 gestisce OFF generali, accensioni, spegnimenti, luci allarme (tutte le luci si accendono in caso di allarme). La centrale allarme e' connessa in rete sopra il CED. I termostati degli uffici lavorano su collettori di zona per piano con testine motorizzate (valvole). Il concentratore di rete visualizza solo i parametri del riscaldamento; i comandi effettivi vengono dai termostati locali e dal MH server.

---

## Storia della fonte

Il rilievo originale delle prese dati e' del 20/08/2020 (Luciani Impianti, installatore elettrico di Porto Sant'Elpidio, modulo manoscritto "Prese dati" in tre pagine, una per piano, scansionato in `intrawelt rete dati.pdf`). Gia' in quel rilievo la colonna "attuale" censiva le etichette permutate e marcava "da fare" i relabeling delle coppie stampante. La trascrizione strutturata in Excel e' stata aggiornata fino ad aprile 2026 e riporta le stesse permutazioni: il relabeling fisico non risulta mai completato. Nessuna delle due fonti contiene informazioni su VLAN o tagging delle porte switch: quella parte della configurazione vive solo sugli switch (vedi nota PORT-TAGGING in `docs/infrastructure-timeline/ingestion-checklist.md`).

## Riepilogo dispositivi speciali

| Dispositivo | Porta | IP | Note |
|-------------|-------|----|------|
| Cisco switch Piano Terra | 0-R-18 | N/A | Rimosso aprile 2026, sostituito da XGS2220-30HP |
| AP irrigazione (tetto) | 0-9-1 | N/A | Raggiunto via ponte da 0-8-1 |
| AP Piano Terra | 0-7-1 | N/A | PoE (ora da XGS2220-30HP), sostituito da NWA130BE su porta 1 |
| BioStar lettore impronte / master Suprema | 0-10-1 | 10.61.20.199 | RS485 interno/esterno; attestato su **30HP porta 3**, identificato il 06/08/2026 |
| MH Server domotica | 2-5-2 | 10.61.90.40 | CentOS 7.6, porte 8080/8081 (da VA) |
| Bticino Classe100X (citofono) | nessuna, connesso in radio | l'indirizzo `10.61.90.41` del referto VA e' **superato** | L'IT Manager dichiara il 06/08/2026 che il citofono e' connesso alla Wi-Fi staff (VLAN 40) con la propria scheda di rete. La scansione indipendente del 21/07/2026 corrobora che il referto e' vecchio: sulla classe `.90` il Bticino risultava **inattivo** e l'unico apparato Bticino attivo stava sulla classe delle postazioni. Restano due cose da chiarire sull'apparato e non a tavolino: se si sia spostato due volte, cioe' guest poi cablato poi radio, e se gli apparati Bticino siano **due**, perche' la scansione ne censiva due indirizzi MAC distinti dello stesso produttore |
| UPS Liebert IntelliSlot | [TBC] | `10.61.90.33` secondo la VA nov 2025, **non risponde dal 21/07/2026** | Web card porta 6004 (da VA). Era l'unico gruppo di continuita' visibile in rete, ma la scansione del 21/07/2026 non lo trova ne' sulla classe `.90` ne' su quella delle postazioni: o e' spento, o e' stato rimosso, o la web card e' morta. Da riverificare, perche' se non risponde **nessun** gruppo di continuita' in sede manda allarmi (ELE-001). Collocazione fisica ignota, vedi `docs/livello-fisico-ed-elettrico.md` |
| Allarme intrusione | 2-6-2 | [TBC] | Connessa in rete |
| AP esterno tetto | 2-7-1 | [TBC] | |
| AP CED | 2-5-1 | [TBC] | |
| AP Piano 1 | 1-8-1 | [TBC] | NWA130BE su 54HP porta 41 |
| Telefono IP, amministrazione Piano 1 | 1.1.2 | — | Yealink SIP-T34W su 54HP porta 3 |
| Telefono IP, amministrazione Piano 1 | 1.2.1 | — | Yealink SIP-T31G su 54HP porta 5 |
| Telefono IP, Sala-1 | 2.3.7 | — | Yealink SIP-T31G su 54HP porta 44 |
| Telefono IP, ufficio centrale Piano Terra | 0.3.1 | — | Yealink SIP-T31G su 30HP porta 13 |
| Telefono IP, reception | 0.5.3 | — | Yealink SIP-T34W su 30HP porta 23 |
| Telefono dell'ascensore | 2.8.1 | — | Servito dall'adattatore analogico Grandstream HT812 v2 attestato su 54HP porta 6 |
| Postazioni a 10 Gbps sul QNAP | 1.6.8, 1.5.3, 1.5.2, 1.5.9, 1.5.12, 1.3.3 | — | Vedi `docs/livello-fisico-ed-elettrico.md` §Mappa porta e apparato |

Le cinque righe dei telefoni, quella dell'ascensore e quella delle postazioni a 10 Gbps sono state aggiunte il 06/08/2026 dal documento `STATO RETE INTRAWELT.docx` e dalla scheda dei telefoni restituita compilata dall'IT Manager. La corrispondenza completa fra porta dello switch e apparato, per tutti e tre gli switch, sta ora in `docs/livello-fisico-ed-elettrico.md`: qui restano le prese a parete, che sono il taglio proprio di questa scheda.

[TBC: IP di tutti gli AP. Modelli AP (Ubiquiti da VA, Debian 7). Porte patch panel corrispondenti alle porte switch. Mappatura completa patch panel -> switch Piano 2 -> dispositivi. Relabeling fisico delle etichette permutate mai completato dal 2020.]

---

## La catena verso l'esterno dallo switch del Piano Terra (NET-017)

> **Sezione in revisione al 03/08/2026, non usare per operare.** La prima stesura di questa sezione, di poche ore prima, si chiamava "la catena del tetto" e conteneva due errori di attribuzione che l'IT Manager ha corretto. Primo: questa non e' la catena del tetto, e' la catena che parte dallo switch del Piano Terra e va **verso l'esterno**; la connessione radio del tetto e' una cosa distinta. Secondo: l'apparato sulla porta 4 non e' un access point che serve la centrale di irrigazione via Wi-Fi, ma una **connessione radio di backup verso l'esterno** — cioe' l'ipotesi "ponte radio" che M13c-1 aveva classificato come improbabile era quella giusta. Esiste inoltre una seconda catena, che parte dallo switch del Piano 2 e comprende un media converter, un cavo che esce verso un'antenna e un gruppo di continuita' dedicato, e che questa sezione non descrive affatto.
>
> Cio' che resta valido e verificato: l'esistenza dello **Zyxel GS-105B v5** sulla tratta, interposto dagli elettricisti, e le tre utenze che ne derivano fra cui l'inverter del fotovoltaico mai censito. Cio' che e' contestato e da riscrivere: il ruolo dell'apparato radio, il fatto che la centrale sia raggiunta via cavo o via radio, e la relazione fra questa catena e quella del Piano 2. Riscrittura in attesa dei dati dell'IT Manager.
>
> **Aggiornamento del 06/08/2026, un pezzo dei tre si chiude.** La seconda catena, quella che l'IT Manager segnalava come partente dal Piano 2 con un'antenna e un gruppo di continuita' dedicato, e' ora descritta: l'antenna sul tetto entra in un iniettore PoE alimentato dal gruppo di continuita' di Sala-1 e da li' nella porta ETH10 del MikroTik RB2011UiAS-RM, cioe' termina **a monte del firewall**, dentro il tratto WAN del fornitore, e non su nessuno dei due switch. E' un terzo percorso verso Internet, non un ramo della LAN. Dettaglio in `docs/livello-fisico-ed-elettrico.md` §La catena fisica da Internet al firewall. Restano contestati gli altri due punti, cioe' che cosa sia l'apparato in fondo alla porta 4 e come sia raggiunta la centrale di irrigazione, e resta non descritto il media converter che la stessa nota citava.

Fonte: dichiarazione dell'IT Manager, sollecitata da una verifica di copertura documentale. Nessuna fonte automatica poteva produrre questa informazione, perche' l'apparato intermedio non e' gestito e non compare nell'inventario Nebula.

```
XGS2220-30HP porta 4  (PoE, negozia 100 Mbps)
        |
    0-8-1  presa a parete, locale caldaia
        |  ponte / patch
    0-9-1  derivazione sul tetto
        |
   Zyxel GS-105B v5   <-- inserito dagli elettricisti, non da IT
    5 porte, non gestito, non PoE
        |
        +--- cavo cat. 6 --> centrale di irrigazione
        +--------------------> access point esterno (Ubiquiti EOL, "EsternoIrrigazione")
        +--------------------> inverter del fotovoltaico (montato nuovo)
```

Prima dell'inserimento dello switch, dal punto 0-9-1 partiva un solo cavo di categoria 6 diretto alla centrale di irrigazione. Gli elettricisti hanno interposto il GS-105B v5 per diramare due utenze nuove, l'access point esterno e l'inverter del fotovoltaico appena installato.

### Quattro conseguenze, e tre ribaltano quanto il progetto dava per assodato

**La centrale di irrigazione e' cablata, non servita via radio.** Tutta la documentazione precedente, a partire dall'etichetta "AP tetto per centrale irrigazione" del rilievo 2020, descriveva l'access point come il mezzo con cui la centrale veniva raggiunta. Non e' cosi': la centrale ha un cavo di categoria 6 dedicato. Ne segue che la prima opzione di M13c-3, quella formulata come "se la centrale espone una porta Ethernet il collegamento diventa cablato e l'access point sparisce", non e' un'opzione da valutare: **e' gia' lo stato dei fatti**. La domanda si sposta e diventa piu' semplice, cioe' a cosa serva oggi quell'access point, dato che non serve la centrale. Se la risposta e' "a niente di necessario", si rimuove senza sostituirlo e il preventivo del WBE530 non serve.

**I 100 Mbps sono quasi certamente il cavo e non l'apparato.** Il GS-105B v5 e' uno switch gigabit: se il collegamento fra la porta 4 e quello switch negozia 100 Mbps, il limite non puo' essere ne' il 30HP ne' il GS-105B, quindi resta la tratta fisica fra 0-8-1 e 0-9-1 — cavo di categoria vecchia oppure coppie interrotte. Questa e' un'inferenza forte, non ancora una misura, e la verifica costa poco: si legge la velocita' negoziata sulle porte del GS-105B. Se confermata, **sostituire l'access point non porta un solo Mbps in piu'**, ed e' esattamente la ragione per cui M13c-5 e' stato promosso ad ALTA prima dell'ordine.

**L'alimentazione dell'access point e' una domanda aperta.** La porta 4 erogava PoE all'apparato, ma il GS-105B v5 non e' PoE e non ne fa passare: interposto sulla tratta, taglia l'alimentazione. Ne segue che l'access point ha oggi un'alimentazione propria, oppure esiste un iniettore non censito, oppure il GS-105B stesso e' alimentato dalla porta 4 tramite un adattatore. Va guardato, perche' cambia il piano di sostituzione: un WBE530 si alimenta in PoE 802.3at, e su quella tratta il PoE oggi non arriva.

**L'inverter del fotovoltaico e' un asset di rete nuovo e mai censito.** Un inverter moderno espone tipicamente un'interfaccia web e contatta il cloud del produttore, quindi e' un dispositivo IoT/OT collegato senza filtri alla LAN piatta, esattamente come gli altri residui che M22c deve raccogliere. Va inventariato con marca, modello, indirizzo e porte esposte, e collocato nel segmento IoT/OT insieme alla centrale di irrigazione quando quel segmento esistera'. Fino a quel momento e' raggiungibile da tutta la `/19`.

### Il fatto organizzativo, che vale oltre questo caso

Due dispositivi sono entrati in rete per mano di **elettricisti**, durante un lavoro di impianto fotovoltaico, senza che l'IT lo registrasse. Non e' una critica agli elettricisti: e' la dimostrazione che il perimetro di rete si allarga anche quando nessuno in IT sta lavorando sulla rete, e che l'inventario degli asset non puo' dipendere dal fatto che chi installa avverta. Un controllo periodico della tabella MAC porta per porta e' l'unico modo di accorgersene dal lato IT: quattro indirizzi appresi su una porta che dovrebbe averne uno erano l'indizio, ed era disponibile da mesi in ogni snapshot. Rilevante per A.8.1 sull'inventario e per A.5.19-A.5.22 sui rapporti con i fornitori.
