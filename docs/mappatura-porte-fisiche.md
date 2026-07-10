# Mappatura porte fisiche - Via Pescolla 2, Porto Sant'Elpidio

Fonti: `porte_fisiche_via_pescolla_2.xlsx` (trascrizione, ultimo aggiornamento
aprile 2026) e `intrawelt rete dati.pdf` (scansione del rilievo manoscritto
"Prese dati" di Luciani Impianti, installatore elettrico, datato 20/08/2020),
entrambe in `ARCHITETTURA SERVER-CLOUD-LINEE/Mappatura porte fisiche/`.
Ingestione completa del 07/07/2026, in sostituzione dell'estratto parziale
precedente.

Convenzione: `<Piano>-<Ufficio>-<Numero>`. R = rack/switch. Per ogni piano il
numero dell'ufficio decresce in senso orario, partendo dall'ufficio a sinistra.

## Nome progettato e nome attuale

Il rilievo del 2020 e la trascrizione Excel portano due colonne: il nome
porta di progetto e il "nome porta attuale", cioe' l'etichetta realmente
presente. Le due colonne NON coincidono per molte prese: al momento del
rilievo diverse etichette risultavano permutate (esempio Reception: la presa
di progetto 0-5-1 portava l'etichetta 0-5-7 e viceversa; la coppia stampante
0-x-13/14 di ogni ufficio del Piano 0 era marcata "da fare" con etichetta
0-x-1/2). Questa permutazione sistematica di etichette e' la spiegazione
piu' probabile della contraddizione NET-007 sulla porta del telefono di
Persona-A (GAP-TBC #67/#99): un errore di etichettatura, non uno spostamento
fisico. Le tabelle sotto riportano il nome di progetto e, dove differisce,
l'etichetta attuale rilevata.

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
0-1-1 .. 0-1-12 postazioni, 0-1-13 stampante, 0-1-14 postazione. Etichette
attuali permutate al rilievo 2020 (0-1-1 -> "0-1-7", 0-1-7 -> "0-1-13",
eccetera); coppia 0-1-13/14 etichettata 0-1-1/2, relabeling "da fare".

### Ufficio 2 (0-2), 13 porte in Excel
0-2-1 .. 0-2-11 postazioni, 0-2-12 stampante, 0-2-13 postazione. [TBC: il
rilievo 2020 mostra 14 porte con stampante in 0-2-13 come per l'Ufficio 1;
la trascrizione Excel ne riporta 13 con stampante in 0-2-12. Verificare sul
posto quale delle due e' corretta.]

### Ufficio 3 (0-3), 14 porte
0-3-1 .. 0-3-14, tutte postazioni in Excel (nessuna stampante censita).
Nel rilievo 2020 marcato "OK" (etichette gia' corrette).

Aggiornamento 10/07/2026: la postazione di Persona-D, in seguito a un
cambio di indirizzo IP, e' stata spostata dalla presa 0-3-3 alla presa
0-R-4 (patch diretta verso il rack, vedi Infrastruttura Piano Terra). La
0-3-3 risulta libera.

### Ufficio 4 (0-4), 14 porte
0-4-1 .. 0-4-14, tutte postazioni. Ufficio condiviso da quattro postazioni
nominative (i nomi propri restano nel file sorgente, non qui). Nel rilievo
2020 marcato "OK".

### Relax (0-6)
| Porta | Tipo | Note |
|-------|------|------|
| 0-6-1 | TV | TV ancora da installare |

### Infrastruttura Piano Terra
| Porta | Tipo | Note |
|-------|------|------|
| 0-7-1 | Access Point | AP Piano Terra, adattatore PoE (rimosso con XGS2220-30HP) |
| 0-8-1 | Locale Caldaia | Patch panel -> patch verso 0-9-1. Qui stava il Cisco switch (rimosso: sostituito da XGS2220-30HP) |
| 0-9-1 | Access Point | AP tetto per centrale irrigazione (raggiunto via ponte 0-8-1 -> 0-9-1) |
| 0-10-1 | Lettore impronte | BioStar (IP 10.61.20.199). Cavo rete al lettore esterno; RS485 tra connettore interno ed esterno; la rete lo vede come dispositivo unico. Problemi dal 07/02/2025. |
| 0-R-18 | Router/Switch | Cisco (rimosso). Collegava direttamente il firewall Zyxel al Piano 2. Con la dorsale SFP+ il Piano Terra e' collegato allo switch Piano 2 (XGS2220-54HP) via fibra. |
| 0-R-4 | Postazione | Persona-D, dal 10/07/2026 (ex 0-3-3, vedi Ufficio 3). Patch diretta al rack a seguito di un aggiornamento dell'indirizzo IP della postazione. |

**Nota post-installazione XGS2220-30HP (aprile 2026):**
Il Cisco switch e l'adattatore PoE esterno sono stati rimossi. Il nuovo switch
Layer 3 Zyxel XGS2220-30HP gestisce tutte le porte del Piano Terra con PoE+
integrato. L'uplink verso il Piano 2 e' SFP+ 10 Gbps su fibra (operativo
dall'08/05/2026).

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

Nel rilievo 2020 la 1-2-5 di progetto era la stampante; nella trascrizione
Excel le sei porte risultano tutte postazioni. [TBC: presenza stampante.]

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

Permutazione ciclica completa delle etichette (rilevata gia' nel 2020,
confermata nella trascrizione 2026).

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

**Note domotica (da Excel):**
Il sistema BUS domotica arriva via cavo non Ethernet al quadro elettrico del
Piano 2. Il MH Server (MyHome server Bticino) al Piano 2 gestisce OFF
generali, accensioni, spegnimenti, luci allarme (tutte le luci si accendono
in caso di allarme). La centrale allarme e' connessa in rete sopra il CED.
I termostati degli uffici lavorano su collettori di zona per piano con
testine motorizzate (valvole). Il concentratore di rete visualizza solo i
parametri del riscaldamento; i comandi effettivi vengono dai termostati
locali e dal MH server.

---

## Storia della fonte

Il rilievo originale delle prese dati e' del 20/08/2020 (Luciani Impianti,
installatore elettrico di Porto Sant'Elpidio, modulo manoscritto "Prese
dati" in tre pagine, una per piano, scansionato in
`intrawelt rete dati.pdf`). Gia' in quel rilievo la colonna "attuale"
censiva le etichette permutate e marcava "da fare" i relabeling delle coppie
stampante. La trascrizione strutturata in Excel e' stata aggiornata fino ad
aprile 2026 e riporta le stesse permutazioni: il relabeling fisico non
risulta mai completato. Nessuna delle due fonti contiene informazioni su
VLAN o tagging delle porte switch: quella parte della configurazione vive
solo sugli switch (vedi nota PORT-TAGGING in
`docs/infrastructure-timeline/ingestion-checklist.md`).

## Riepilogo dispositivi speciali

| Dispositivo | Porta | IP | Note |
|-------------|-------|----|------|
| Cisco switch Piano Terra | 0-R-18 | N/A | Rimosso aprile 2026, sostituito da XGS2220-30HP |
| AP irrigazione (tetto) | 0-9-1 | N/A | Raggiunto via ponte da 0-8-1 |
| AP Piano Terra | 0-7-1 | N/A | PoE (ora da XGS2220-30HP) |
| BioStar lettore impronte | 0-10-1 | 10.61.20.199 | RS485 interno/esterno |
| MH Server domotica | 2-5-2 | 10.61.90.40 | CentOS 7.6, porte 8080/8081 (da VA) |
| Bticino Classe100X (citofono) | [TBC] | 10.61.90.41 | Linux 2.6, TLSv1.2 |
| UPS Liebert IntelliSlot | [TBC] | 10.61.90.33 | Web card porta 6004 (da VA) |
| Allarme intrusione | 2-6-2 | [TBC] | Connessa in rete |
| AP esterno tetto | 2-7-1 | [TBC] | |
| AP CED | 2-5-1 | [TBC] | |
| AP Piano 1 | 1-8-1 | [TBC] | |

[TBC: IP di tutti gli AP. Modelli AP (Ubiquiti da VA, Debian 7). Porte patch
panel corrispondenti alle porte switch. Mappatura completa patch panel ->
switch Piano 2 -> dispositivi. Relabeling fisico delle etichette permutate
mai completato dal 2020.]
