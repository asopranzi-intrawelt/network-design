# Storage degli anni vecchi - consolidamento backup storico 2009-2023

> Fonte: `Intrawelt_anni_vecchi_2026-05-20_15-44.html`, uno strumento
> interattivo autocontenuto (HTML+JS con dati incorporati, palette Scenia)
> costruito per tracciare la migrazione dell'archivio storico. Lo strumento
> conserva uno snapshot iniziale datato 08/01/2026 e un secondo snapshot
> incorporato al momento del salvataggio del file, il 20/05/2026 15:44, che
> e' la fotografia usata come stato corrente in questa pagina. La cartella
> sorgente e' `ARCHITETTURA SERVER-CLOUD-LINEE/` (root, file sciolto).

## Cos'e' l'archivio "anni vecchi"

Ogni anno di attivita' aziendale (traduzioni, documenti, dati di produzione)
viene consolidato in un archivio annuale che rappresenta l'anno intero e
serve come backup storico a lungo termine, distinto dai backup operativi
correnti. Il progetto tracciato in questo file e' la riorganizzazione di
questi archivi 2009-2022 su una nuova infrastruttura fisica, con doppia
copia e verifica di integrita' per ogni anno tramite FreeFileSync, dopo anni
di dispersione su piu' NAS, un vecchio hard disk esterno ("Toshibino") e
copie scaricate da AWS Glacier.

## Architettura di archiviazione secondo l'ultimo snapshot

| Storage | Percorso / ruolo | Stato |
|---|---|---|
| NAS INTRA2 (10.61.20.177) | `\\10.61.20.177\Backup_Ufficio\AnniVecchi` | Attivo, NAS di backup principale (transito) |
| TOSHIBA NUOVO 4TB #1 | Anni 2009-2017, 2.64 TB su 3.63 TB | Attivo, blocco anni vecchi (~3456.62 GB) |
| TOSHIBA NUOVO 4TB #2 | Anni 2018-2021, 3.63 TB pieno | Attivo, blocco anni medi (~3362.63 GB) |
| Disco Toshiba 3TB (meccanico) | 2.72 TB | **Rotto**, R.I.P. 02/10/2025, non leggibile, da smaltire |
| TOSHIBA NUOVO 4TB #3 | Anni 2022+, in espansione, 3.63 TB pieno | Attivo, blocco anni recenti |
| NAS INTRA2 (dati ex .170) | `\\10.61.20.177\Backup_Ufficio\AnniVecchi\dati (che stava sul .170)` | Attivo, contenuti ex NAS documenti .170 |
| NAS INTRA 3 | — | Progetto NAS abbandonato (aborted) |
| CONFRONTI | meta-colonna | Riferimento ai 14 confronti FreeFileSync (tabella sotto) |
| NAS HERO (10.61.20.169) - Anni vecchi | `\\10.61.20.169\Anni vecchi` | **Destinazione finale primaria** (Storage Pool 2, solo HDD riciclati), doppia copia statica |

## Allocazione finale per anno

Ogni anno da 2009 a 2022 e' presente, verificato tramite confronto
FreeFileSync e in doppia copia su NAS HERO; il peso in GB e' quello
catalogato nello strumento (totale complessivo 7969.25 GB su 18 anni
tracciati).

| Anno | Peso (GB) | Destinazione fisica finale | Confronto FFS |
|---|---|---|---|
| 2009 | 162.59 | TOSHIBA NUOVO #1 | confronto_1 |
| 2010 | 190.97 | TOSHIBA NUOVO #1 | confronto_2 |
| 2011 | 225.21 | TOSHIBA NUOVO #1 | confronto_3 |
| 2012 | 226.89 | TOSHIBA NUOVO #1 | confronto_4 |
| 2013 | 316.24 | TOSHIBA NUOVO #1 | confronto_5 |
| 2014 | 373.45 | TOSHIBA NUOVO #1 | confronto_6 |
| 2015 | 515.29 | TOSHIBA NUOVO #1 | confronto_7 |
| 2016 | 567.97 | TOSHIBA NUOVO #1 | confronto_8 |
| 2017 | 878.01 | TOSHIBA NUOVO #1 | confronto_9 |
| 2018 | 682.58 | TOSHIBA NUOVO #2 | confronto_10 |
| 2019 | 660.02 | TOSHIBA NUOVO #2 | confronto_11 |
| 2020 | 570.03 | TOSHIBA NUOVO #2 | confronto_12 |
| 2021 | 1450.00 | TOSHIBA NUOVO #2 | confronto_13 |
| 2022 | 1150.00 | TOSHIBA NUOVO #3 | confronto_14 |

Tutti e quattordici sono confermati "OK" su NAS HERO come doppia copia
finale. Gli anni 2023-2026 restano fuori da questo consolidamento: sono in
backup giornaliero corrente verso NAS INTRA2 (`BackupNasHero\daily_hero_to_intra2`)
con doppia copia su QNAP cloud, non ancora spostati sullo storage degli anni
vecchi. Il 2023 e' l'eccezione: risulta gia' copiato manualmente su un nuovo
HDD (movimenti del 09 e 19/01/2026 sotto), in attesa di essere spostato
definitivamente sullo storage pool degli anni vecchi dopo l'espansione a
caldo del disco.

## Confronti FreeFileSync: dati salvati dall'analisi

Per ogni anno con piu' di una copia dispersa (Toshibino, NAS, download da
AWS Glacier) e' stato eseguito un confronto FreeFileSync prima di eliminare
le copie ridondanti, per evitare di perdere file presenti solo in una delle
fonti. Due casi documentano un salvataggio di dati concreto: il confronto
dell'anno 2014 ("Aggiorna", impossibile la sincronizzazione a due vie per
spazio insufficiente sul Toshibino) ha recuperato un ulteriore 1 GB di dati
aziendali; il confronto dell'anno 2016 ("Due vie", mancavano file da
entrambe le parti) ne ha recuperati altri 191 GB. Il confronto dell'anno
2022 rende esplicito il rischio evitato: senza l'analisi si sarebbero persi
177 GB di dati aziendali (677 GB attesi contro 500 GB nella versione piu'
recente conservata). Gli anni 2010, 2011, 2013, 2015, 2018 e 2020 hanno
richiesto sincronizzazioni a due vie o aggiornamenti con esiti minori; gli
anni 2017, 2019 e 2021 non hanno richiesto confronto (istanza unica o
gia' spostati in passato).

## Cronologia dei movimenti (Teracopy/FreeFileSync)

Lo strumento registra 66 movimenti reali su disco. Otto movimenti piu'
antichi non portano una data (marcati "data ignota" nella fonte): riguardano
lo svuotamento progressivo del vecchio NAS documenti (.170) verso il
Toshibino, inclusa un'analisi di una copia sparsa dell'anno 2020 documentata
con screenshot dedicati (`anno_2020_SyncSettings.ffs_gui`, `screenshot_14.png`
a `screenshot_18.png`, non versionati). Dal 28/02/2025 la cronologia diventa
puntualmente datata.

## 28/02-27/06/2025 - primi spostamenti da NAS INTRA e NAS documenti (.170)

28/02/2025: eliminato `Public\Anni Vecchi\2019` dal NAS documenti. Tra
31/03 e 08/04/2025 una serie di movimenti e copie senza nota dettagliata; il
04/04/2025 la versione dell'anno 2020 datata 19/02/2021, che stava sul NAS
INTRA (10.61.20.168) sotto `Public\Anni vecchi`, viene spostata sul NAS
INTRA2 (10.61.20.177) per confrontarla con quella sul Toshibino. Il
17/06/2025 viene copiata l'intera cartella dati del NAS documenti (.170)
per gli anni 2021 e 2022. Il 20/06/2025 alcune VM del NAS INTRA (.168)
vengono spostate tra cartelle e le versioni vecchie eliminate (backup
presente). Il 24/06/2025 viene eliminato un vecchio backup NAS documenti
inutilizzato sul .177; il 26/06/2025 tutta la cartella "utili" viene
copiata in "utili(new)"; il 27/06/2025 un backup temporaneo manuale di prova
del 18/06/2025 viene eliminato per liberare spazio sul .177.

## 30/06-11/07/2025 - prima ondata di consolidamento verso NAS HERO

Il 30/06/2025 avviene la "PRIMA COPIA DEGLI ANNI VECCHI ULTIMA VERSIONE":
l'anno 2017 (scaricato da AWS Glacier) viene copiato dal NAS INTRA2
(10.61.20.177, `Backup_Ufficio\AnniVecchi\downloaded_from_AWS\Anno 2017`)
sul NAS HERO (10.61.20.169, `Anni vecchi`), la nuova cartella di
destinazione sullo Storage Pool 2 (solo HDD riciclati), rilanciata dopo un
blackout di fine settimana. Segue una settimana intensa di copie ed
eliminazioni parallele per liberare spazio sul .177 mentre si popola il
NAS HERO: 01/07 (elimina 2017 dopo copia, libera 878 GB; elimina versione
2022 del 06/12/2024 per liberare 500,3 GB; copia 2022 dai dati ex-.170),
03/07 (elimina un job di backup Veeam del PC-ALESISO errato che aveva
tirato su tutto il Toshibino sul .177, liberando 2500 GB; copia 2021, 2020 e
2019 dal Toshibino), 04/07 (elimina 2022 non completato da Teracopy,
liberando 1150 GB; sposta 2018 dai dati AWS), 07/07 (elimina 2021 dai dati
ex-.170 liberando 1450 GB; elimina 2020 e 2018 residui; sposta 2015 dal
Toshibino), 08/07 (sposta ed elimina 2016 e 2015; copia 2011, 2010 e 2014
dal Toshibino/AWS). Il 10/07/2025 lo spostamento dell'anno 2013 avrebbe
dovuto avvenire il 09/07 ma il computer si e' spento di notte durante il
trasferimento; rilanciato non nello stesso processo Teracopy. L'11/07/2025
si completano 2012 e 2009 dal Toshibino, con eliminazione delle rispettive
copie AWS sul .177.

## 16/07-31/10/2025 - pulizia hardware e secondo giro di copie

Il 16/07/2025 viene eliminata (da Windows, non da Teracopy) la cartella
"Anno 2014_new(PC-GIORDANO)" dal vecchio Toshiba 3TB. Il 19/09/2025 il
Toshiba 3TB viene formattato (non veloce) e usato per una copia temporanea
degli anni 2009-2013 dal Toshibino, poi eliminati manualmente dal
Toshibino. Il 30/09/2025 gli anni 2014 e 2016 vengono copiati dal .177 su
un nuovo hard disk (rinominando "Anno 2014 (from AWS)" in "Anno 2014"), ed
eliminati dal .177 il 01/10/2025. Il 02/10/2025 avviene la copia definitiva
sul Toshiba 3TB nuovo degli anni 2009-2016 con i pesi finali per anno (2009
163 GB, 2010 191 GB, 2011 225 GB, 2012 227 GB, 2013 316 GB, 2014 373 GB,
2015 515 GB, 2016 568 GB) — la stessa data in cui il vecchio Toshiba 3TB
meccanico viene dichiarato definitivamente rotto. Tra il 14 e il 31/10/2025
si copiano dal NAS HERO ai nuovi HDD gli anni 2018-2021 (in piu' passaggi,
uno dei quali direttamente dalla dashboard del NAS, lento ma funzionante),
2010-2017, 2009, 2022 e infine 2020-2021.

## 09-19/01/2026 - chiusura del 2023

Il 09/01/2026 l'anno 2023, zippato dentro il NAS HERO, viene copiato su un
nuovo hard disk. Il 19/01/2026 lo zip temporaneo viene eliminato e il 2023
viene spostato dallo storage principale (dove il file `.zip` era appoggiato
temporaneamente) allo storage pool degli anni vecchi, una volta espanso a
caldo il disco; la copia e' stata fatta direttamente dentro il NAS HERO,
poi il 2023 e' stato di nuovo eliminato dalla cartella principale del NAS
HERO. Questo e' l'ultimo movimento registrato nello strumento.

## Azioni aperte, tutte completate secondo l'ultimo snapshot

Lo snapshot dell'08/01/2026 elencava sette azioni aperte: backup giornaliero
NAS HERO verso il .177 per gli anni 2023-2026; espansione dello storage
pool HDD del NAS HERO; copia del 2023 dopo lo zip e l'espansione storage;
revisione della policy di storage pool con RAID 5 su HDD (creato il
17/01/2025 sul NAS HERO); doppia copia statica aggiuntiva degli anni
vecchi; smaltimento del Toshiba 3TB meccanico rotto; verifica della doppia
copia QNAP cloud per il 2025 e successivi. Nello snapshot incorporato al
20/05/2026 tutte le sette risultano completate.
