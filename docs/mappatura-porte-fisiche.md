# Mappatura porte fisiche - Via Pescolla 2, Porto Sant'Elpidio

Fonte: porte_fisiche_via_pescolla_2.xlsx (ARCHITETTURA SERVER-CLOUD-LINEE/Mappatura porte fisiche/).
Convenzione: `<Piano>-<Ufficio>-<Numero>`. R = rack/switch.

---

## Piano 0 (Terra)

### Reception (0-5)
| Porta | Tipo | Note |
|-------|------|------|
| 0-5-1 | Postazione | |
| 0-5-2 | Postazione | |
| 0-5-3 | Postazione | |
| 0-5-4 | Postazione | |
| 0-5-5 | Postazione | |
| 0-5-6 | Postazione | |
| 0-5-7 | Stampante | |
| 0-5-8 | Postazione | |

### Ufficio 1 (0-1) - 14 porte postazione
0-1-1 ... 0-1-12 Postazione, 0-1-13 Stampante, 0-1-14 Postazione.

### Ufficio 2 (0-2)
0-2-1 ... Postazioni (numero completo da verificare in Excel).

### Relax (0-6)
| Porta | Tipo | Note |
|-------|------|------|
| 0-6-1 | TV | TV ancora da installare |

### Infrastruttura Piano Terra
| Porta | Tipo | Note |
|-------|------|------|
| 0-7-1 | Access Point | AP Piano Terra, adattatore PoE (rimosso con XGS2220-30HP) |
| 0-8-1 | Locale Caldaia | Patch panel -> patch verso 0-9-1. Cisco switch qui (ora rimosso: sostituito da XGS2220-30HP) |
| 0-9-1 | Access Point | AP tetto irrigazione (raggiunto via patch 0.8.1->0.9.1 dal Cisco) |
| 0-10-1 | Lettore impronte | BioStar (IP 192.168.20.199). Cavo rete al lettore esterno; RS485 tra connettore interno ed esterno. Problemi dal 07/02/2025. |
| 0-R-18 | Router/Switch | Cisco (rimosso). Collegamento diretto al firewall Zyxel al Piano 2. Con la nuova dorsale SFP+ il Piano Terra e' collegato allo switch Piano 2 (XGS2220-54HP) via fibra. |

**Nota post-installazione XGS2220-30HP (aprile 2026):**
Il Cisco switch e l'adattatore PoE esterno sono stati rimossi. Il nuovo switch Layer 3
Zyxel XGS2220-30HP gestisce tutte le porte del Piano Terra con PoE+ integrato.
L'uplink verso il Piano 2 e' ora SFP+ 10 Gbps su fibra (operativo dall'08/05/2026).

---

## Piano 1

### Ufficio 1 - Alessandro Potalivo (1-1)
| Porta | Tipo | Posizione |
|-------|------|-----------|
| 1-1-1 | Postazione | Sotto scrivania |
| 1-1-2 | Postazione | Sotto scrivania |
| 1-1-3 | Postazione | Sotto scrivania |
| 1-1-4 | Postazione | Sotto scrivania |
| 1-1-5 | Postazione | Presa muro separatore con scale |
| 1-1-6 | Postazione | Presa muro separatore con scale |

### Ufficio 2 - Sonia Martellini (1-2)
| Porta | Tipo | Posizione |
|-------|------|-----------|
| 1-2-1 | Postazione | Presa muro separatore con Ufficio IT |
| 1-2-2 | Postazione | Presa muro separatore con Ufficio IT |
| 1-2-3 | Postazione | Presa muro separatore con Ufficio Alessandro |
| 1-2-4 | Postazione | Presa muro separatore con Ufficio Alessandro |
| 1-2-5 | Postazione | Presa muro separatore con Ufficio Alessandro |
| 1-2-6 | Postazione | Presa muro separatore con Ufficio Alessandro |

### Ufficio 3 - Ufficio IT / Alessio (1-3)
| Porta | Tipo | Posizione |
|-------|------|-----------|
| 1-3-1 ... 1-3-6 | Postazione | |
| 1-3-7 | Postazione | A sx dell'ingresso, sotto appendiabiti |
| 1-3-8 | Postazione | A sx dell'ingresso, sotto appendiabiti |
| 1-3-9 ... 1-3-14 | Postazione | |

### Infrastruttura Piano 1
| Porta | Tipo | Note |
|-------|------|------|
| 1-7-1 | Stampante | Atrio |
| 1-7-2 | (libera) | Atrio |
| 1-8-1 | Access Point | |

---

## Piano 2

### Sala Riunioni (2-1)
| Porta | Tipo | Note |
|-------|------|------|
| 2-1-1 | Postazione | Relatore |
| 2-1-2 | Postazione | |
| 2-1-3 | Postazione | |
| 2-1-4 | Stampante | |
| 2-1-5 | Postazione | |
| 2-1-6 | Postazione | TV |

### Sala Convegni (2-2)
| Porta | Tipo | Note |
|-------|------|------|
| 2-2-1 | Postazione | Relatore |
| 2-2-2 | Postazione | |
| 2-2-3 | Postazione | |
| 2-2-4 | Postazione | TV |

### Ufficio Piano 2 (2-3) - 18 porte
| Porte | Tipo | Posizione |
|-------|------|-----------|
| 2-3-1 ... 2-3-8 | Postazione | Torretta ovest |
| 2-3-9 ... 2-3-10 | Postazione | Torretta est |
| 2-3-11 | Stampante | Torretta est |
| 2-3-12 ... 2-3-16 | Postazione | Torretta est |
| 2-3-17 | Stampante | |
| 2-3-18 | (varia) | |

### CED - Sala Server Piano 2 (2-4, 2-5, 2-6, 2-7)
| Porta | Tipo | Note |
|-------|------|------|
| 2-4-1 | Postazione IT | Postazione sud |
| 2-4-2 | Postazione IT | Postazione sud |
| 2-4-3 | Postazione IT | Postazione sud |
| 2-4-4 | Postazione IT | Postazione ovest |
| 2-4-5 | Postazione IT | Postazione ovest |
| 2-4-6 | Postazione IT | Postazione ovest |
| 2-5-1 | Access Point | AP CED (sotto) |
| 2-5-2 | MH Server | MyHome Server domotica (BUS domotica su quadro elettrico Piano 2, non Ethernet) |
| 2-6-1 | Domotica | Concentratore parametri riscaldamento (termoregolazione). [TBC: tipo dispositivo] |
| 2-6-2 | Allarme | Centrale allarme intrusione (connessa in rete) |
| 2-7-1 | Access Point | AP esterno tetto |

**Note domotica (da Excel):**
Il sistema BUS domotica arriva via cavo non Ethernet al quadro elettrico del Piano 2.
Il MH Server (MyHome server Bticino) al Piano 2 gestisce OFF generali, accensioni,
spegnimenti, luci allarme (tutte le luci si accendono in caso di allarme).
La centrale allarme e' connessa in rete sopra il CED.
I termostati degli uffici lavorano su collettori di zona per piano con testine
motorizzate (valvole). Il concentratore di rete a 0-6-1 visualizza solo i parametri
del riscaldamento; i comandi effettivi vengono dai termostati locali e dal MH server.

---

## Riepilogo dispositivi speciali

| Dispositivo | Porta | IP | Note |
|-------------|-------|----|------|
| Cisco switch Piano Terra | 0-R-18 | N/A | Rimosso aprile 2026, sostituito da XGS2220-30HP |
| AP irrigazione/tetto (tetto) | 0-9-1 | N/A | Raggiunto via patch da Cisco (poi da XGS2220-30HP) |
| AP Piano Terra | 0-7-1 | N/A | PoE (ora da XGS2220-30HP) |
| BioStar lettore impronte | 0-10-1 | 192.168.20.199 | RS485 interno/esterno |
| MH Server domotica | 2-5-2 | 192.168.90.40 | CentOS 7.6, porte 8080/8081 (da VA) |
| Bticino Classe100X (citofono) | [TBC] | 192.168.90.41 | Linux 2.6, TLSv1.2 |
| UPS Liebert IntelliSlot | [TBC] | 192.168.90.33 | Web card porta 6004 (da VA) |
| Allarme intrusione | 2-6-2 | [TBC] | Connessa in rete |
| AP esterno tetto | 2-7-1 | [TBC] | |
| AP CED | 2-5-1 | [TBC] | |
| AP Piano 1 | 1-8-1 | [TBC] | |

[TBC: IP di tutti gli AP. Modelli AP (Ubiquiti da VA, Debian 7). Porte patch panel
corrispondenti alle porte switch. Mappatura completa patch panel -> switch Piano 2 -> dispositivi.]
