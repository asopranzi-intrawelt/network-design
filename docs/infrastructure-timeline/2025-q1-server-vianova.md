# 2025 Q1 - Gennaio-Marzo: server Proxmox, fibra Vianova, cablaggio rack

## 02/01/2025 - Primo appuntamento Fibercop saltato

Referente-Fibercop-1 (referente-fibercop-1@fibercop.it) invia mail il 02/01/2025 per
fissare un appuntamento relativo al sopralluogo fibra FTTO (riferimento pratica
<pratica-fibercop>). Alessio Sopranzi risponde confermando. L'appuntamento viene poi saltato
con scuse da parte di Referente-Fibercop-1.

## 10/01/2025 - Completamento migrazione dischi NAS INTRA2

Completata la sostituzione uno-a-uno dei 4 dischi del RAID 5 nel NAS INTRA2
(QNAP TS-451U, 10.61.20.177). La procedura per ogni disco e' stata: sostituzione
fisica del disco, attesa del rebuild automatico completo del RAID 5, poi passaggio
al disco successivo. Al termine dei 4 rebuild e' stata eseguita la funzione
"Espandi Volume" dal pannello QNAP per utilizzare lo spazio aggiuntivo.

Capacita' post-migrazione: circa 21 TB raw RAID 5 (4 dischi da 8 TB ciascuno).
Spazio disponibile dopo l'espansione: circa 14-15 TB (partendo da circa 8 TB usati
sui vecchi dischi da 2.73 TB).

I vecchi dischi liberati dalla migrazione (1x 4 TB, 3x 3 TB, 1x 2 TB nuovo) sono
dischi da 2.5 pollici. Possono essere montati negli slot aggiuntivi del NAS HERO
(10.61.20.169) per espansione dello storage storico.

## 13/01/2025 - Mail Vianova: 2FA obbligatoria dal 03/02/2025

Mail da info@vianova.it delle 12:54: dall'03/02/2025 l'accesso all'Area Clienti
Vianova richiede autenticazione a due fattori (codice SMS). Solo l'utente con
profilo Amministratore puo' abilitare la 2FA per tutti. Procedura: Area Clienti,
menu Impostazioni, clicca Sicurezza, spunta "autenticazione a due fattori", clicca
Conferma. FAQ 2FA: vianova.it/supporto/area-clienti/faq-autenticazione-a-due-fattori/

La 2FA viene abilitata per asopranzi@intrawelt.com. Mail secondaria per il recovery
scelta dall'IT manager: <casella-personale-autore>. I successivi accessi richiedono
codice a 6 cifre via SMS.

## 17/01/2025 - Controllo CrystalDisk sui dischi ex-NAS INTRA2

I vecchi dischi da 2.5 pollici (1x 4 TB, 3x 3 TB, 1x 2 TB) liberati dalla
migrazione NAS INTRA2 vengono controllati con CrystalDiskInfo per verificarne lo
stato SMART. I dischi risultano utilizzabili e vengono messi da parte per una
futura espansione del NAS HERO (10.61.20.169).

## 20/01/2025 - Sopralluogo TIM e sopralluogo Fibercop

Tecnico TIM in sede per sopralluogo finalizzato ad accomodare la nuova FTTO 1 Gbps
di Vianova. L'infrastruttura fisica della fibra rimane in capo a TIM come gestore
dell'infrastruttura passiva (ultimo miglio), indipendentemente dal provider dati.

Stesso giorno: sopralluogo Fibercop con Referente-Fibercop-1 (referente-fibercop-1@fibercop.it).
Esito del sopralluogo: nessun impedimento rilevante, nessuno scavo necessario,
percorso fibra gia' predisposto. Il verbale prodotto e' il file
<verbale-fibercop>_VERBALE_VIANOVA.pdf.

## 28/01/2025 - Verbale sopralluogo Fibercop inviato via mail

Referente-Fibercop-1 invia mail alle 09:30 con copia del verbale di sopralluogo
effettuato il 20/01/2025 (<verbale-fibercop>_VERBALE_VIANOVA.pdf). Comunica che si e' in
attesa di ulteriore risposta per tempi tecnici per la redazione del progetto.

## 28/01/2025 - Previsioni tempistiche da Referente-Vianova-2 (Vianova)

Referente-Vianova-2 (referente-vianova-2@vianova.it) scrive alle 15:33: considerando che
nel verbale non sono riportati impedimenti o lavorazioni complesse, stima che tra
una ventina di giorni verra' pianificata la consegna del cavo ottico. Di li' ad un
paio di settimane, salvo imprevisti, si arriva al collaudo finale. Stima complessiva:
completamento tra febbraio e marzo 2025.

## 28/01/2025 - Conversazione WhatsApp con Persona-H: server Proxmox

Da conversazione WhatsApp privata con Persona-H (referente-puntoinformatica-1@puntoinformatica.com):
conferma dell'utilizzo di 48 CPU (2x24 core) sul nuovo server HP ProLiant DL380 Gen10.

## 30/01/2025 - Primo accensione HP ProLiant DL380 Gen10

Il server HP ProLiant DL380 Gen10 viene acceso per la prima volta nell'ufficio di
Persona-H (Punto Informatica). Il server ha Proxmox VE 8.3.4 preinstallato
incluso nell'acquisto (documento di riferimento: Preventivo-9_2025-INTRAWELT-di-
Alessandro-Persona-A--c-Sas.pdf). Il preventivo include anche la creazione e
installazione di 2 VM Linux e 1 VM Windows Server 2022, piu' la licenza Windows
Server 2022 Standard ESD.

Al primo accensione la scheda iLO5 prende indirizzo IP di default 10.61.1.71
(indirizzo di fabbrica, poi cambiato). Credenziali iLO5 di fabbrica scritte
fisicamente sopra al server: Administrator / [redacted].

Proxmox VE sulla scheda di rete 1 prende indirizzo DHCP dalla rete di Punto
Informatica: 10.61.90.103. Rete dell'ufficio di Persona-H: 10.61.90.0/xx.

Il server viene poi trasportato fisicamente in sede Intrawelt e connesso al rack DX
Piano 2, collegato allo switch Zyxel XGS2220-54HP.

Dopo il trasporto e la connessione alla rete Intrawelt, l'Advanced IP Scanner
(usato dal portatile privato di Persona-H connesso alla porta di rete 1.3.8 o
1.3.9 dello stesso switch) rileva il server. Gli vengono assegnati gli indirizzi IP
definitivi:

iLO5: 10.61.20.9 (poi presente nel file corosync anche come .71, da verificare
l'allineamento). Mask IPv4: 255.255.224.0. Gateway IPv4: 10.61.10.1.
Proxmox VE: 10.61.20.11, porta 8006. Mask: 255.255.224.0. Gateway: 10.61.10.1.

Credenziali Proxmox: root / [redacted].
Accesso iLO5 da PC-ALESSIO: https://10.61.20.9 con Administrator / [redacted].
Accesso Proxmox: https://10.61.20.11:8006 con root / [redacted].

Specifiche server HP ProLiant DL380 Gen10:
2 processori Intel Xeon 24 core ciascuno (48 core totali).
Proxmox VE 8.3.4 (8.2 introduce wizard import VMware ESXi, firewall nftables
sperimentale, device passthrough LXC da UI, backup con parametri performance,
ACME con CA personalizzate).

## 30/01/2025 - Avvio richiesta migrazione licenze Trados

Mail di Persona-J a referente-rws-1@rws.com (Referente-RWS-1, RWS/SDL): richiesta
migrazione del license manager Trados da Windows Server 2012 (vecchio server
licserver) a Windows Server 2022 su VM100 del nuovo Proxmox. Il processo richiede
prima la procedura di "return" delle licenze esistenti, poi la reinstallazione.

## 31/01/2025 - Risposta RWS su migrazione Trados

Referente-RWS-1 risponde: documentazione per reinstallazione disponibile sul
portale RWS. Il processo di "return" delle licenze e' necessario prima della
migrazione. E' possibile una "smooth migration" con licenze temporanee durante la
finestra di migrazione per non interrompere l'operativita'.

## 02/02/2025 - Completamento migrazione domini Aruba

Persona-E completa la tabella preparata da Alessio Sopranzi e i redirect dal
pannello Aruba. Tutti i domini secondari di Intrawelt vengono correttamente migrati
e i redirect da Aruba verso Fastnet sono operativi. Da questa data l'IP pubblico
TIM 192.0.2.50 non serve piu' per i redirect dei domini secondari alla VM DOMV
(Ubuntu 14.04).

## 03/02/2025 - 2FA Vianova Area Clienti operativa

Da questa data tutti gli accessi all'area clienti Vianova per il profilo
asopranzi@intrawelt.com richiedono il codice SMS a 6 cifre come secondo fattore.

## 04/02/2025 - Aggiornamento Fibercop: nessuna data precisa

Referente-Fibercop-1 (referente-fibercop-1@fibercop.com) aggiorna: "Buongiorno sig.
Alessio, in questa fase ancora non e' possibile darle un indicazione puntuale, ma
di sicuro faremo di tutto per consegnare il rilegamento richiesto nel piu' breve
tempo possibile." Stessa comunicazione inviata due volte nella stessa data.

## 06-07/02/2025 - Cablaggio e fascettatura rack DX Piano 2

Tutti i server del rack DX vengono fisicamente connessi alle porte dello switch
Zyxel XGS2220-54HP. I cavi vengono raggruppati e fascettati per chiarezza. La
configurazione iniziale del layout switch vs connessioni fisiche viene documentata
(versione "VECCHIA") e poi aggiornata con il layout definitivo.

## 07/02/2025 - Mail da Referente-BioStar2-1 su migrazione BioStar2

Mail proveniente da tecnico2@giudiciepolidori.it verso info@lucianiimpianti.it,
girata da persona-b@intrawelt.com ad asopranzi@intrawelt.com. Contiene link
alle istruzioni per la migrazione del sistema BioStar2 (controllo accessi fisici):
support.supremainc.com/en/support/solutions/articles/24000005907

## 07-09/02/2025 - Esperimenti Proxmox di Persona-H

Persona-H conduce prove di Proxmox su un mini-server homemade (Lenovo Tiny i5)
installando 4 VM Linux raggruppate in 2 pool, con storage diviso su 120 GB + 120 GB
su un disco da 240 GB totali, gestione RAM e CPU. Dettagli nel file allegato alla
mail di domenica 09/02/2025 alle 17:37. Le prove sono replicabili su Intrawelt
(storage diverso, VM da importare).

## 10/02/2025 - Problema accesso Proxmox: risolto

Proxmox irraggiungibile su 10.61.20.11:8006. Causa probabile: durante i lavori
di cablaggio del rack del 07/02, la scheda di rete e' stata collegata alla porta
sbagliata, oppure il DHCP le ha riassegnato l'indirizzo 10.61.1.71 (quello preso
inizialmente nell'ufficio di Punto Informatica). Risoluzione: IP riportato a
10.61.20.11 manualmente.

## 11/02/2025 - Test Trados Studio 2024 da Persona-J

Mail di Persona-J a Referente-RWS-1: installato Studio 2024 su un PC di test.
Richiesta di 2-3 licenze trial per testare prima del deployment su tutti i computer
aziendali. Nota: Studio 2024 non prevede un periodo trial di 30 giorni gratuito
come le versioni precedenti; richiede una licenza attiva fin dall'installazione.

## 12/02/2025 - Sollecito Vianova tramite myOffice

Persona-A chiama Referente-Vianova-1 (referente-vianova-1@myofficegroup.it) per
sollecitare lo stato dell'attivazione Vianova.

Referente-Vianova-1 invia mail il 12/02/2025 alle 10:47 a info@vianova.it (CC: Antonio
Pomponio referente-vianova-5@vianova.it, Referente-Vianova-2 referente-vianova-2@vianova.it,
wi wi@myofficegroup.it), oggetto "cliente Intrawelt S.a.s.". Scrive
di aver visionato il pannello Merlino/Provisioning: il prossimo step interno e'
fissato al 19 febbraio. Ricorda che la posa e' prevista entro 120 giorni dalla
contrattualizzazione del 24/12/2024. Il cliente lamenta appuntamenti andati a vuoto
e ritiene non necessario alcuno scavo perche' la fibra arriva gia' in sede.

Stessa data alle 11:54: risposta di Referente-Vianova-6 (referente-vianova-6@vianova.it,
CC: Referente-Vianova-2, Referente-Vianova-5, wi). Referente-Vianova-6 chiarisce che il
percorso fibra e' gia' predisposto e nel verbale di sopralluogo non si menzionano
lavorazioni particolari. Non ci sono step prefissati al 19/02 ma solo monitoraggio.
Il cavo passera' entro fine febbraio, poi a seguire nei giorni successivi installazione
del catalyst (switch Cisco Catalyst con porte SFP/SFP+ per connessioni fino a 10 Gbps).
Le tempistiche sono contrattualmente nei limiti dei 120 giorni (scadenza aprile 2025).
Vianova si scusa per gli appuntamenti disattesi e chiede di essere avvisata
tempestivamente in futuro per avere basi di reclamo verso il proprio fornitore.

Stessa data alle 16:25: Referente-Vianova-1 risponde ad Alessio Sopranzi confermando
di non poter dare una data precisa e che aggiornera' appena possibile. Si e'
contrattualmente nei tempi massimi entro aprile 2025.

## 12/02/2025 - Conferma quantita' licenze trial Trados

Referente-RWS-1 (RWS) chiede quante licenze trial (con codice vero) servono.
Persona-J risponde: 3 licenze.

## 13/02/2025 - Chiamata con Referente-BioStar2-1 per BioStar2

Chiamata alle 10:00 con Referente-BioStar2-1: e' necessario aggiornare il firmware
del dispositivo BioStar prima della migrazione del sistema di controllo accessi.

## 17/02/2025 - 3 licenze Trados Studio 2024 trial disponibili

Referente-RWS-1 (RWS) conferma: 3 licenze Trados Studio 2024 con codice attivo
disponibili nell'account Intrawelt (account cliente RWS), valide fino al 17/03/2025.

## Febbraio 2025 - Onboarding Persona-Q

Creazione account NAS HERO (10.61.20.169) per Persona-Q, nuova dipendente.
Account persona-q@intrawelt.com, gruppo pm-junior. Configurazione replicata
dall'account persona-d (modello di riferimento per i PM junior).

## 21/02/2025 - Accesso e formattazione NAS INTRA3

Accesso al NAS INTRA3 (QNAP TS-210, 10.61.20.172 / 10.61.20.173). Credenziali:
admin / [redacted]. URL: https://10.61.20.172/cgi-bin/
Contenuto trovato: solo backup del 2020, 2021 e 2022 di Glossari, Multiterm e TM
(Translation Memory). Tutto il contenuto e' obsoleto (dati dalla sede precedente
in Via Pescolla, anni di dismissione 2022). NAS formattato. Il dispositivo rimane
fisicamente presente ma vuoto e disponibile.

## 20/03/2025 - Posatura fibra FTTO (non avvisata)

Un'azienda incaricata da Fibercop posa fisicamente la fibra ottica fino all'armadio
rack di Intrawelt. Alessio Sopranzi viene avvisato casualmente: Referente-Vianova-2
(+39 08544244596, numero interno 145) chiama mentre i tecnici avevano gia' suonato
il campanello aziendale alle 16:13.

Alessio Sopranzi invia mail di protesta ad Referente-Vianova-1 (referente-vianova-1@myofficegroup.it,
CC: wi@myofficegroup.it) il 20/03/2025, chiedendo preavviso per le visite.

Comunicazione ricevuta dai tecnici presenti: entro una settimana o qualche giorno
verra' installato un apparato per il collaudo, poi le installazioni esterne sono
finite e interverra' myOffice per portare Vianova a livello dati.

Documentazione fisica: foto e video nell'archivio _Posatura Fibra 20032025.7z
(dimensione superiore a 25 MB, non allegabile via mail).

Il 21/03/2025 alle 16:49 Referente-Vianova-1 risponde: "Gli aggiornamenti che ci hai
gentilmente fornito coincidono con quanto riportato nel pannello di controllo che
Vianova ci mette a disposizione. Appena ci arrivera' ordine di lavoro ti avviseremo
con congruo anticipo di alcuni giorni per programmare l'attivazione definitiva da
parte del ns personale tecnico." La mail include uno screenshot del pannello Vianova.

## 28/03/2025 - Tecnico TIM installa terminale linea fibra FTTO

Un tecnico TIM installa il terminale della fibra sul circuito parallelo a quello
gia' esistente. Il configuratore TIM raggiunge la macchina correttamente alle 12:06.
Il dispositivo TIM eroga il servizio per Vianova: e' l'ultimo intervento
infrastrutturale lato TIM nella sede Intrawelt.

Alessio Sopranzi invia ulteriore mail nel thread "R: rif tempistiche fibra" ad
referente-vianova-1@myoffice confermando l'avvenuta installazione e ribadendo la richiesta
di ricevere preavviso per le visite in presenza.
