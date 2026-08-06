# Livello fisico ed elettrico

> Scheda aperta il 06/08/2026. Descrive la rete ai due livelli che il progetto aveva dichiarato di non conoscere: dove stanno fisicamente gli apparati e da dove prendono corrente. Fonte principale: il documento `STATO RETE INTRAWELT.docx`, scritto dall'IT Manager e comparso nella libreria `Documenti - IT` il 06/08/2026, sotto `Cybersec & IT Governance`. Le porte degli switch sono corroborate dallo snapshot Nebula del 06/08/2026; la parte elettrica non ha nessuna fonte automatica e vale quanto vale la dichiarazione di chi ha guardato.
>
> Convenzione. Modelli, nomi di apparato, numeri di porta e codici di presa a parete sono reali, perche' servono a operare e un segnaposto li renderebbe introvabili. Persone, indirizzi IP e MAC seguono i segnaposto di `.claude/rules/anonymization.md`; la traduzione vive in `_notes/.anonymization-map.md`. La controparte narrativa e non anonimizzata di questa scheda e' `_notes/livello-fisico-ed-elettrico.md`.
>
> Onesta' del contenuto. Cio' che e' misurato e' scritto come misurato; cio' che e' dedotto e' marcato come da verificare. Le lacune sono dichiarate invece di essere riempite per ipotesi, e nel caso del livello elettrico sono ancora la parte piu' grande.

---

## Perche' questa scheda esiste

Un'infrastruttura di cui non si sa che cosa resti acceso durante un black-out non ha un piano di continuita', ha una speranza. Fino al 06/08/2026 il progetto sapeva descrivere la rete a livello 2 e 3 con misure ripetibili, ma dell'alimentazione conosceva due sole cose: che l'iniettore *PoE*[^poe] dell'antenna sta sotto gruppo di continuita', e che esiste un UPS[^ups] Emerson Liebert censito in `runbook-anomalie.md` §UPS-001 perche' ha una scheda di rete e quindi compare in una scansione. Tutto il resto era ignoto, compreso il fatto elementare di quanti gruppi di continuita' esistano.

Il documento dell'IT Manager chiude buona parte di quella lacuna per il Piano 2, dove stanno i due armadi, e la lascia intera per il Piano Terra, la cui sezione nel documento sorgente e' aperta e vuota. Questa scheda registra cio' che si sa, e in coda elenca cio' che manca in una forma che si possa rilevare in un sopralluogo invece che discutere.

---

## 1. La catena fisica da Internet al firewall

La ricostruzione del 03-04/08/2026, fatta dal `startup-config.conf` e dalle risposte dell'IT Manager, e' confermata e completata. Il pezzo nuovo e' l'apparato di terminazione della fibra, che il progetto non aveva mai nominato.

```
   fibra (IN)
      |
  Aconnic Acceed 2102                      apparato di terminazione della fibra
      |  Ethernet in rame
  Vianova R-1000  (router 1, principale)   la WAN entra qui
      |                    \
      | P1                  \ P2
      |                      +--> Vianova R-1000 (router 2, backup)  P1
  MikroTik RB2011UiAS-RM            |  uscita xDSL su RJ11 -> linea VDSL
      | ETH1 (PoE in)                \
      |                               +--> Vianova S-1000  P7
      | ETH10                         +--> Vianova S-1000  P8   (porta la WAN)
  iniettore PoE dell'antenna
      |                          Vianova S-1000
  antenna sul tetto                 |        \
  (iniettore alimentato dal          | P4      \ P1
   gruppo di continuita' di Sala-1)  |          \
                                     |           +--> XGS2220-54HP porta 8   (fonia)
                          USG FLEX 500 porta P2
                             (WAN 1)
                                     |
                          USG FLEX 500 porta P5
                             (LAN 1)
                                     |
                          XGS2220-54HP porta 33
```

Tre cose vanno lette con attenzione perche' cambiano il modo di ragionare sui guasti.

La prima e' che i percorsi verso Internet restano tre, come gia' registrato, ma ora si vede dove si separano fisicamente: la fibra entra dall'Aconnic nel router principale, la VDSL entra dalla porta xDSL del router di backup, e la radio entra dalla ETH10 del MikroTik. Il *failover*[^failover] fra questi percorsi avviene dentro gli apparati del fornitore, prima del firewall, che vede una sola WAN sulla propria porta P2. Ne segue che il firewall non e' il posto dove si diagnostica una caduta di linea, e che nessuna configurazione del firewall puo' influire su quale delle tre linee sia in uso.

La seconda e' che la voce e i dati si separano dentro lo S-1000 e non nel firewall: la porta P4 porta i dati al firewall, la porta P1 porta la fonia direttamente alla porta 8 del 54HP. E' la conferma fisica dell'architettura gia' descritta in `docs/telefono-pbx-voip.md`, cioe' che la LAN telefonica non passa dal firewall per progetto.

La terza e' che l'antenna del tetto termina sul MikroTik e non sullo switch del Piano Terra. Questo scioglie una parte dell'ambiguita' aperta il 03/08 in `docs/mappatura-porte-fisiche.md` §La catena verso l'esterno, dove l'IT Manager aveva segnalato l'esistenza di una seconda catena, distinta da quella della porta 4, con un'antenna e un gruppo di continuita' dedicato. Quella catena e' questa. Resta invece non descritto il media converter che la stessa nota citava, e resta aperta la domanda su che cosa sia davvero l'apparato in fondo alla porta 4 del 30HP.

Asset che questa catena porta in inventario e che il progetto non aveva: l'Aconnic Acceed 2102 e il gruppo di continuita' di Sala-1 che alimenta l'iniettore. Il MikroTik e l'iniettore erano gia' tracciati come non censiti in NET-018.

---

## 2. I due armadi

Gli armadi sono due, entrambi nel CED del Piano 2, e la divisione dei ruoli e' netta.

L'armadio di sinistra contiene tutto cio' che sta fra Internet e la LAN, piu' i due apparati di commutazione principali: l'Aconnic, i due R-1000, lo S-1000, il MikroTik, il firewall USG FLEX 500, lo switch core XGS2220-54HP e lo switch QNAP QSW-1208-8c. E' la parte della rete che, se si spegne, spegne tutto.

L'armadio di destra contiene lo storage e il calcolo: il server HP ProLiant Gen10, il NAS-HERO, il NAS-INTRA, il NAS-INTRA2 e il PC di backup Proxmox.

Cio' che di questi armadi non si sa e' quanto serve per montarci qualcosa senza andare a vedere: quale apparato occupa quale unita', da che lato entrano i cavi, quali porte del patch panel sono libere, dove passa la fibra della dorsale e quante prese IEC restano disponibili su ciascun gruppo di continuita'. E' rilievo da sopralluogo, elencato in coda.

---

## 3. Alimentazione

### Armadio di sinistra: due gruppi di continuita' e una catena di ciabatte

| Sorgente | Alimenta |
|---|---|
| Ciabatta 4 SX, alimentata **da parete** | ingresso dell'APC Smart-UPS SC 1500; ingresso dell'APC Back-UPS ES 400 |
| APC Smart-UPS SC 1500 | switch QNAP QSW-1208-8c; switch XGS2220-54HP; "scatolina bianca SX" |
| "scatolina bianca SX" | Ciabatta 2 SX; Ciabatta 3 SX |
| Ciabatta 2 SX | MikroTik RB2011UiAS-RM; Vianova S-1000; Ciabatta 1 SX |
| Ciabatta 1 SX | USG FLEX 500, e nient'altro |
| Ciabatta 3 SX | Vianova R-1000 (router 2, backup); Aconnic Acceed 2102 |
| APC Back-UPS ES 400 | dispositivo voce Grandstream; Vianova R-1000 (router 1, principale) |

Ambiguita' sciolta il 06/08/2026 dall'IT Manager. La quarta presa dello Smart-UPS e' il suo **ingresso** dalla rete elettrica, non un'uscita protetta: la Ciabatta 4 SX e' quindi la sorgente non protetta a monte, non un carico. Ne discende una conseguenza che il documento sorgente non rendeva visibile e che la tabella ora mostra: **entrambi** i gruppi di continuita' dell'armadio di sinistra prendono corrente dalla stessa ciabatta a parete. Sono due gruppi indipendenti a valle e un solo punto di guasto a monte, quindi la ridondanza apparente fra Smart-UPS e Back-UPS non copre il guasto piu' banale, che e' la ciabatta o la presa da cui pendono tutti e due.

Modelli e date di acquisto verificati il 06/08/2026 sui documenti del fornitore, che correggono e completano la fonte in tre punti.

Il gruppo dell'armadio di destra e' un **Naicon UPServer 4000 VA rack**, non "Elsist UPServer 4.0" come lo nomina il documento sorgente: il "4.0" e' la taglia in kVA e non una versione. Acquistato e installato nel **febbraio 2025**. Dati di targa: online a doppia conversione, 4 kVA e 2,70 kW, ingresso monofase 110-290 V, uscita 200-240 V configurabile, tempo di commutazione nullo, sei batterie 12V 9Ah, batteria sostituibile a caldo, spegnimento selettivo del carico, display LCD, e comunicazione **USB e RS232**, cioe' nessuna interfaccia di rete di serie: e' la conferma documentale, e non piu' solo un'assenza dalla descrizione, che questo gruppo non puo' mandare allarmi a nessuno.

Dello **Smart-UPS SC 1500** si conosce ora un dato che ELE-001 chiedeva: il pacco batterie originale APCRBC59 e' stato sostituito nel **novembre 2024**. Al 06/08/2026 le batterie hanno quindi circa ventuno mesi, che per un pacco di quella classe e' dentro la vita attesa ma vicino alla meta': e' il gruppo per cui conviene fissare adesso la prima verifica programmata, invece di scoprirlo alla prossima mancanza di rete.

Del **Back-UPS ES 400** non risulta nessun documento di acquisto o di manutenzione presso il fornitore abituale, quindi eta' e stato delle batterie restano ignoti. E' anche il gruppo piu' piccolo dei tre e alimenta due apparati del tratto WAN.

### Armadio di destra: un gruppo online a doppia conversione

| Sorgente | Alimenta |
|---|---|
| Naicon UPServer 4000 VA rack, online a doppia conversione, alimentato da parete tramite la "scatolina bianca DX" | Ciabatta 1 DX; Ciabatta 2 DX |
| Ciabatta 1 DX | uno dei due alimentatori del NAS-HERO; PC di backup Proxmox |
| Ciabatta 2 DX | il secondo alimentatore del NAS-HERO; NAS-INTRA2; NAS-INTRA; server HP ProLiant Gen10, alimentatore unico |

La scelta di un gruppo *online a doppia conversione*[^online] su questo armadio e' quella tecnicamente corretta per storage e server, perche' il carico e' alimentato sempre dall'inverter e non subisce il tempo di commutazione di un gruppo *line interactive*. Vale la pena notarlo perche' e' l'unico dei tre gruppi con questa caratteristica, e i due apparati piu' sensibili a una micro-interruzione, il firewall e il core switch, stanno invece sui due gruppi line interactive dell'altro armadio.

Sul server HP ProLiant Gen10 la domanda aperta e' chiusa dall'IT Manager il 06/08/2026: **ha un solo alimentatore**, collegato alla Ciabatta 2 DX. Non e' quindi un secondo alimentatore scollegato da ricollegare, e' una macchina senza ridondanza elettrica per costruzione. La riga della tabella e' stata corretta di conseguenza, e la conseguenza va detta invece che lasciata implicita: il nodo di virtualizzazione, cioe' l'apparato che esegue le dieci macchine virtuali dell'azienda, dipende da un singolo alimentatore e da una singola presa. Un guasto all'alimentatore lo ferma anche a rete elettrica presente e anche a gruppo di continuita' perfettamente funzionante, che e' lo scenario che un secondo alimentatore esiste per coprire.

### Cinque osservazioni che discendono da questo quadro

La prima riguarda il firewall, ed e' quella che salta all'occhio: e' alimentato in fondo a tre ciabatte in cascata, gruppo di continuita' verso "scatolina bianca SX" verso Ciabatta 2 SX verso Ciabatta 1 SX. La Ciabatta 1 alimenta lui e nient'altro, il che suggerisce che la cascata sia nata per dedicargli una presa e non per sbadataggine, ma il risultato resta che l'apparato che porta tutto il traffico interno verso Internet dipende da quattro connessioni elettriche in serie invece che da una. Ogni giunto e' un punto di guasto singolo, e il carico complessivo sulla catena non risulta misurato. Tracciato come ELE-002.

La seconda riguarda il NAS-HERO, che ha due alimentatori e li ha entrambi sulla stessa sorgente, il Naicon, su due ciabatte diverse. La ridondanza che ne risulta e' quella dell'alimentatore, non quella della sorgente: se cade il Naicon, o la presa a parete che lo alimenta, cadono tutti e due. Un apparato con doppio alimentatore e' progettato per prendere corrente da due sorgenti indipendenti, ed e' esattamente quello che oggi non succede. Tracciato come ELE-003, insieme al fatto ora accertato che il server HP ProLiant Gen10 ha un **solo** alimentatore: li' non c'e' una ridondanza da sistemare, c'e' una ridondanza che non esiste e che va dichiarata nel piano di continuita' invece di essere data per scontata dal fatto che l'apparato sta sotto gruppo.

La terza e' che il Piano Terra non compare in nessuna delle due tabelle. Lo switch XGS2220-30HP non risulta sotto gruppo di continuita', e con lui cadono al primo black-out tutti i suoi carichi in *PoE*: i due telefoni IP del piano, l'access point del Piano Terra, il terminale timbracartellini e la tratta che esce verso l'esterno. E' anche la risposta alla domanda che il preventivo del 31/07/2026 aveva lasciato aperta, cioe' che cosa dovrebbe alimentare l'UPS rack Addpower proposto per il Piano Terra: la risposta e' lo switch, prima di ogni altra cosa, e con lui la parte di rete e di fonia che oggi non ha protezione. Tracciato come ELE-004.

La quarta e' che nessuno dei tre gruppi di continuita' d'armadio ha una scheda di rete, e per il Naicon questo non e' piu' un'assenza dalla descrizione ma un dato di targa: le sue porte di comunicazione sono USB e RS232. Ne segue che nessuno riceve i loro allarmi, nessuno sa quando una batteria si degrada, e la prima notizia di un guasto all'alimentazione e' l'apparato che si spegne. L'unico gruppo di continuita' che risulti mai stato visibile in rete e' l'Emerson Liebert di UPS-001, che ha una web card e per questo compare nel referto della vulnerability assessment di novembre 2025, attestato per giunta su un segmento dove non dovrebbe stare. Va pero' detto che **oggi non risponde**: la scansione indipendente del 21/07/2026 non lo trova ne' sul segmento del referto ne' su quello delle postazioni, quindi o e' spento, o e' stato rimosso, o la sua web card e' morta. Se questa lettura regge, gli allarmi di alimentazione che raggiungono qualcuno in questa azienda sono **zero**, non uno. La scheda SNMP dell'UPS Addpower, che il preventivo dichiara opzionale, va letta in questa luce: non e' un accessorio, e' l'unico modo perche' il prossimo gruppo di continuita' sappia dire qualcosa prima di arrendersi. Va notato che due dei tre gruppi hanno comunque una porta USB o seriale libera, quindi un monitoraggio esiste ed e' a costo quasi nullo: basta collegarli a una macchina che sta gia' accesa in armadio e che puo' riportarne lo stato. Tracciato come ELE-001.

La quinta e' che di nessuno dei tre gruppi si conosce il **carico effettivo** ne' la data di un test di scarica, e l'autonomia dichiarata resta un dato di targa e non una misura sul carico reale. I documenti di acquisto hanno pero' chiuso due caselle su quattro: il Naicon e' un 4 kVA / 2,70 kW installato nel febbraio 2025 con sei batterie 12V 9Ah, e le batterie dello Smart-UPS SC 1500 sono state sostituite nel novembre 2024. Restano senza un solo dato il Back-UPS ES 400, di cui non esiste documentazione presso il fornitore abituale, e il gruppo di Sala-1. Anche questo sta in ELE-001.

### Il quarto gruppo, quello di Sala-1: cercato e non trovato

La domanda era se il gruppo di continuita' che alimenta l'iniettore PoE dell'antenna coincida con l'Emerson Liebert di UPS-001, che e' l'unico gruppo oggi visibile in rete. Cercata il 06/08/2026 in tutti i documenti del fornitore abituale dal 2024 in avanti e nella libreria amministrativa: **nessuna traccia** di apparati Emerson o Liebert, ne' in preventivi, ne' in ordini, ne' in fatture. L'apparato e' quindi anteriore al 2024 oppure proviene da un altro canale, e la domanda resta aperta e va posta al fornitore.

La ricerca ha pero' prodotto un fatto collaterale che vale la pena registrare, perche' aggiunge un apparato al conto. Il 01/07/2025 e' stata sostituita, su intervento del fornitore di connettivita' e con reso in garanzia, una **alimentazione di backup da 700 VA di proprieta' del fornitore stesso**, che era entrata in allarme e si spegneva dopo poco. Non era un gruppo di continuita' dell'azienda: era parte del corredo degli apparati di linea. Ne segue che nel tratto WAN esiste, o e' esistita, una protezione elettrica del fornitore distinta dai gruppi dell'azienda, e che il rapporto fra quell'apparato e il Back-UPS ES 400 oggi descritto sui due router va chiarito: se l'ES 400 sia il suo sostituto, se convivano, o se il sostituito fosse un terzo apparato ancora. E' l'ennesima occorrenza dello schema per cui il perimetro si allarga senza che l'inventario lo sappia.

---

## 4. Mappa porta e apparato

### XGS2220-54HP, switch core del Piano 2

Le assegnazioni vengono dal documento dell'IT Manager; PVID e VLAN ammesse dallo snapshot Nebula del 06/08/2026. Dove le due fonti coprono la stessa porta, concordano.

| Porta | Apparato collegato | PVID | VLAN ammesse | Note |
|---|---|---|---|---|
| 2 | NAS-INTRA, prima scheda di rete | 1 | — | |
| 3 | telefono IP Yealink | 2 | tutte | NET-019 |
| 4 | NAS-INTRA, seconda scheda di rete | 1 | — | |
| 5 | telefono IP Yealink | 2 | solo 2 | configurazione di riferimento |
| 6 | adattatore analogico Grandstream HT812 v2 | 2 | tutte | uscita verso la presa 2.8.1, ascensore; NET-019 |
| 7 | server HP ProLiant Gen10, eth2 | 1 | — | |
| 8 | consegna fonia del fornitore | 2 | tutte | tre MAC appresi, uno e' un indirizzo virtuale VRRP; NET-019 |
| 9 | server HP ProLiant Gen10, eth3 | 1 | — | |
| 11 | server HP ProLiant Gen10, eth4 | 1 | — | |
| 14 | PC di backup Proxmox | 1 | — | ex postazione di Persona-D |
| 22 | server HP ProLiant Gen10, interfaccia iLO | 1 | — | gestione fuori banda su segmento non descritto come tale |
| 33 | USG FLEX 500, porta P5 (LAN 1) | 1 | 1, 40, 90 | uplink verso il firewall, 1 Gbps in rame |
| 38 | NAS-INTRA3 | 1 | — | |
| 41 | access point Zyxel NWA130BE, Piano 1 | 1 | 1, 40, 90 | trunk multi-SSID |
| 44 | telefono IP Yealink, Sala-1 | 2 | tutte | NET-019 |
| 45 | access point Zyxel NWA130BE, Piano 2 | 1 | 1, 40, 90 | trunk multi-SSID |
| 46 | host Ollama del progetto IntraLino | 1 | — | migliaia di link flap, NET-010 |
| 51 (SFP+) | XGS2220-30HP, dorsale | 1 | tutte | 10 Gbps in fibra |
| 52 (SFP+) | QNAP QSW-1208-8c, porta P4 | 1 | tutte | 10 Gbps in fibra, ramo storage |

Va notato che le porte 2 e 4 attestano le due schede di rete dello stesso NAS su due porte dello stesso switch: e' aggregazione o ridondanza di scheda, non di apparato, e come e' configurata lato NAS non e' documentato.

Va notato anche che l'uplink verso il firewall e' l'unica porta a 1 Gbps in rame in una rete che internamente ha una dorsale a 10 Gbps. Il fatto era gia' registrato in `docs/segmentazione-lan-m22.md`; qui si conferma dal lato fisico.

### QNAP QSW-1208-8c, ramo storage e postazioni a 10 Gbps

| Porta | Apparato collegato | Mezzo |
|---|---|---|
| 1 | NAS-HERO (ts-h1677xv-rp), una delle due schede | fibra |
| 3 | NAS-INTRA2 (ts-435XeU), unica scheda | fibra |
| 4 | XGS2220-54HP, porta 52 | fibra |
| 5 | presa 1.6.8, postazione denominata "Monitor Bianco" | rame |
| 6 | presa 1.5.3, postazione di Persona-AK | rame |
| 7 | presa 1.5.2, seconda postazione di Persona-AB (Mac Mini) | rame |
| 8 | presa 1.5.9, postazione di Persona-G | rame |
| 10 | presa 1.5.12, postazione di Persona-AB | rame |
| 12 | presa 1.3.3, postazione dell'IT Manager | rame |

Il server HP ProLiant Gen10 si collega a questo switch dalla propria eth1, oltre alle tre interfacce attestate sul 54HP.

Questo ramo merita un'osservazione di postura. Il QNAP e' uno switch non gestito: le sei postazioni collegate qui e i due NAS stanno sullo stesso dominio di broadcast senza che esista alcun controllo di livello 2 su quel tratto, e quando M22 introdurra' le VLAN questo ramo non potra' partecipare al tagging. E' il punto della rete che rende piu' difficile la segmentazione, e non compare come tale nel design di M22b.

### XGS2220-30HP, switch di distribuzione del Piano Terra

| Porta | Apparato collegato | PVID | VLAN ammesse | Note |
|---|---|---|---|---|
| 1 | access point Zyxel NWA130BE, Piano Terra | 1 | 1, 40, 90 | trunk multi-SSID |
| 3 | terminale timbracartellini Suprema, unita' master | 1 | tutte | identificato il 06/08/2026, NET-021 |
| 4 | tratta verso l'esterno: presa 0-8-1, ponte 0-9-1, GS-105B non gestito | 1 | tutte | 100 Mbps, NET-020 |
| 6 | multifunzione Kyocera TASKalfa 2552ci | 1 | — | |
| 13 | telefono IP Yealink | 2 | tutte | NET-019 |
| 19 | nessun link | 90 | — | residuo del test del 22/07, R5 |
| 21 | — | 1 | solo 2 | difetto opposto, NET-015 |
| 23 | telefono IP Yealink | 2 | solo 2 | configurazione di riferimento |
| 29 (SFP+) | XGS2220-54HP, dorsale | 1 | 1, 2, 40, 90 | 10 Gbps in fibra, trentanove MAC appresi |

L'identificazione della porta 3 chiude una domanda aperta in NET-020: l'apparato e' il terminale master del sistema di rilevazione presenze, coerente con la presa 0-10-1 del rilievo del 2020 che censiva un lettore di impronte. Ne segue anche che il MAC che `_notes/.anonymization-map.md` teneva dal 23/07 come "dispositivo non identificato su 30HP porta 3" ha un nome. Cio' che l'identificazione non chiude e' il problema: il terminale e' un dispositivo IoT/OT su LAN piatta, non presente in nessun inventario di asset, su una porta che accetta qualunque VLAN taggata e che negozia 100 Mbps. Tracciato come NET-021 e aggiunto ai carichi di M22c.

---

## 5. Censimento dei NAS

Il progetto nominava alcuni di questi apparati sparsi fra la scheda di continuita' operativa, il runbook e la timeline, senza averne mai fatto un elenco unico. Questo e' l'elenco, e la colonna che conta e' l'ultima.

| Apparato | Modello | Attestazione | Alimentazione | Funzione documentata |
|---|---|---|---|---|
| NAS-HERO | QNAP ts-h1677xv-rp | QNAP QSW-1208-8c porta 1, fibra | doppio alimentatore, entrambi su Elsist | storage Proxmox; destinazione di backup |
| NAS-INTRA | non documentato | XGS2220-54HP porte 2 e 4, due schede | Ciabatta 2 DX, Elsist | share `Backup`, dump delle VM |
| NAS-INTRA2 | QNAP ts-435XeU | QNAP QSW-1208-8c porta 3, fibra | Ciabatta 2 DX, Elsist | destinazione delle scansioni dopo R8; share `utili` |
| NAS-INTRA3 | non documentato | XGS2220-54HP porta 38, rame | non documentata | due schede di rete note dagli indirizzi; funzione non documentata |

Sono quattro, non cinque, e vale la pena dire da dove veniva il cinque perche' il modo in cui si scioglie e' istruttivo. Il conteggio a cinque nasce da una riga di `docs/business-continuity-disaster-recovery.md` che elenca "NAS fleet (HERO, INTRA, INTRA2, INTRA3, documenti)", dove l'ultima voce e' un indirizzo distinto dagli altri quattro. Quell'indirizzo pero' e' noto altrove come la share `utili`, cioe' un nome di condivisione e non necessariamente un apparato: la lista mescola quattro apparati e una destinazione, ed e' il tipo di elenco che si legge come inventario senza esserlo.

Ne segue che la domanda giusta non e' "quanti NAS ci sono" ma "che cosa risponde a quell'indirizzo": se e' una share su uno dei quattro, l'inventario e' chiuso a quattro; se e' un apparato a se', il documento dell'IT Manager non lo descrive e va cercato. Si chiude con una lettura, non con un ragionamento.

Tre lacune restano aperte su tutti e quattro: la finestra di backup di ciascuno, la funzione del NAS-INTRA3, e l'alimentazione del NAS-INTRA3 che non compare in nessuna delle due tabelle elettriche.

---

## 6. Cosa resta da rilevare

Elenco pensato per essere portato in un sopralluogo e compilato sul posto, non discusso. Ogni voce e' una misura o una lettura, non un giudizio.

| Ambito | Da rilevare |
|---|---|
| Piano Terra | l'intera sezione fisica ed elettrica: la sezione corrispondente del documento sorgente e' aperta e vuota |
| Alimentazione | carico effettivo e data dell'ultimo test di scarica dei tre gruppi; eta' delle batterie del solo Back-UPS ES 400, per gli altri due e' nota |
| Alimentazione | modello, fornitore ed eta' del gruppo di continuita' di Sala-1: non compare in nessun documento del fornitore abituale dal 2024, va chiesto |
| Alimentazione | il rapporto fra l'alimentazione di backup del fornitore di linea sostituita il 01/07/2025 e il Back-UPS ES 400 oggi descritto sui due router |
| Alimentazione | quante prese IEC restano libere su ciascun gruppo, dato che serve per decidere l'UPS del Piano Terra |
| Armadi | occupazione per unita' rack, lato di ingresso dei cavi, porte libere del patch panel, percorso della fibra della dorsale |
| Rete | il media converter della catena dell'antenna, citato dall'IT Manager e non descritto in nessuna fonte |
| Rete | che cosa sia oggi l'apparato in fondo alla porta 4 del 30HP, e come e' alimentato dopo l'inserimento del GS-105B |
| Rete | funzione, modello e alimentazione del NAS-INTRA3; esistenza di un quinto NAS |
| Rete | come sono configurate lato NAS-INTRA le due schede attestate sulle porte 2 e 4 del 54HP |
| Fonia | su quale segmento sta davvero il citofono, vedi la nota di contraddizione in `docs/telefono-pbx-voip.md` |

---

## Riferimenti

Catena WAN e configurazione del firewall: `docs/firewall-zyxel-usg-flex-500.md` e `docs/network-diagram.md`. Prese a parete e rilievo del 2020: `docs/mappatura-porte-fisiche.md`. Continuita' operativa e UPS-001: `docs/business-continuity-disaster-recovery.md` e `docs/runbook-anomalie.md`. Segmentazione e VLAN target: `docs/segmentazione-lan-m22.md`. Difetti citati: `docs/infrastructure-timeline/GAP-TBC.md`.

[^poe]: *PoE*, Power over Ethernet - alimentazione dell'apparato attraverso lo stesso cavo di rete che ne porta i dati; se un apparato non PoE viene interposto sulla tratta, l'alimentazione si interrompe.

[^ups]: *UPS*, Uninterruptible Power Supply - gruppo di continuita', apparato che alimenta un carico da batteria quando manca la rete elettrica.

[^failover]: *failover* - passaggio automatico da un collegamento guasto a uno di riserva, qui interno agli apparati del fornitore e non visibile al firewall.

[^online]: *online a doppia conversione* - architettura in cui il carico e' alimentato sempre dall'inverter del gruppo, che quindi non ha tempo di commutazione quando manca la rete; l'alternativa, *line interactive*, alimenta il carico dalla rete e commuta sulla batteria in qualche millisecondo.
