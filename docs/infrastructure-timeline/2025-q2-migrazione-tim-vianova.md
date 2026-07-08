# 2025 Q2 - Aprile-Giugno: attivazione Vianova, switch WAN, tunnel SEEWEB

## 29/03/2025 - Consegna materiale Vianova (primo router R-1000)

Alessia Liberati (a.liberati@myofficegroup.it) invia mail il 31/12/2025 (data di
spedizione effettiva: fine marzo 2025) con il numero di spedizione GLS LU660066022.
Il pacco arriva il 01/04/2025. Contiene il Router Vianova R-1000 (codice articolo
6052). Questo e' il primo dei due router previsti dalla configurazione HSRP.

## 02/04/2025 - Ricezione ordine di lavoro e primo appuntamento fissato

Alle 16:29 del 02/04 il numero +39 3783041550 (Alessandro Mancinelli, myOffice)
scrive ad Alessio Sopranzi: "buon pomeriggio Alessio, ci e' arrivato l'ordine di
lavoro per l'attivazione Vianova, gli apparati dovrebbero essere arrivati, se per
te va bene possiamo far venire il tecnico venerdi' mattina". Alessio risponde
preferendo lunedi' mattina. L'appuntamento viene confermato per lunedi' 07/04/2025.

## 07/04/2025 - Primo tentativo attivazione: ordine di lavoro incompleto

Tecnico Camillo (myOffice) arriva in sede. Problema riscontrato: l'ordine di lavoro
non prevede uno schema con il router di backup e non contiene una richiesta di
ritiro dell'apparato preesistente. Il tecnico Ciccarelli specifica che Vianova stava
usando uno schema obsoleto riferito ad un tipo di apparato non piu' in uso.
Prima di aprire e spacchettare il materiale si attende che richiami Vianova.

Nel pomeriggio alle 15:44 arriva mail da Serena Cortesi (serena.cortesi@vianova.it,
Customer Care, telefono 145) ad Alessandro Potalivo (apotalivo@intrawelt.com):
"Buona sera, per la sede in oggetto abbiamo eseguito la variazione profilo richiesta.
Il profilo Vianova e' adesso: a progetto 6 canali, FTTO fino a 1Gbps TIM, Opzione
Line Recovery Radio Standard."

## 08/04/2025 - Alessandro Mancinelli conferma invio mail a Vianova

Mail di Alessandro Mancinelli (a.mancinelli@myofficegroup.it) ad Alessio Sopranzi
e Alessandro Potalivo (CC: supporto@myofficegroup.it): comunica che mandera' mail
a Vianova per chiarire cosa va installato per avere il backup tra le due connettivita'.
File di risposta di Alessio Sopranzi: "R router back up.eml".

## 09/04/2025 - Nuovo ordine di lavoro Vianova: router + switch

Arriva mail da info@vianova.it con il nuovo ordine di lavoro che prevede sia il
router principale che il router di backup R-1000 e lo switch S-1000. Configurazione
definitiva confermata:
Router principale R-1000 per fibra FTTO.
Router backup R-1000 (HSRP) per il ponte radio Line Recovery Standard.
Switch S-1000 Vianova: una porta dati verso il firewall Zyxel USG FLEX 500, una
porta fonia per la linea VoIP.

Alessandro Mancinelli richiama lo stesso 09/04/2025 dicendo che appena arriva
l'ordine di lavoro ufficiale da Vianova ricontatta telefonicamente Alessio Sopranzi
per accordarsi sull'appuntamento.

## 11/04/2025 - Consegna fisica secondo router Vianova

Alle 16:29 del 11/04 arriva in sede il secondo router Vianova. Alessandro Potalivo
lo consegna fisicamente nell'ufficio di Alessio Sopranzi alle 16:41 (foto nella
cartella 11042025).

## 14/04/2025 - Nuovo ordine di lavoro e appuntamento definitivo

Il numero +39 3783041550 scrive ad Alessio Sopranzi alle 10:43: "e' appena arrivato
l'ordine di lavoro da Vianova per la variazione / configurazione connettivita',
possiamo mandare il tecnico domani mattina h. 9 circa?". Alessio risponde che si
trova in malattia imprevista e propone giovedi' o venerdi'. Il numero risponde:
"ok facciamo giovedi' h.9", confermando il 17/04/2025 alle ore 09:00.

## 17/04/2025 - ATTIVAZIONE FISICA VIANOVA: connettivita' operativa

Alessandro Mancinelli (a.mancinelli@myofficegroup.it) arriva in sede alle 09:00.
Durante l'installazione e' in chiamata diretta con il supporto tecnico Vianova.

Installazione eseguita:
Switch Vianova S-1000 configurato e connesso.
Router R-1000 principale configurato con la configurazione inviata da Vianova.
Router R-1000 backup configurato con i parametri per il ponte radio.

Nota tecnica riscontrata durante l'installazione: il Taurus Bond (firewall in
comodato TIM, mai connesso) stava fisicamente in sede ma non verra' mai utilizzato
perche' e' parte di un vecchio pacchetto TIM e il firewall attivo e' lo Zyxel.

Dalla sera del 17/04/2025 la fibra FTTO 1 Gbps e' fisicamente attiva in sede e
connessa allo switch S-1000 Vianova. La WAN1 del firewall Zyxel USG FLEX 500
rimane pero' ancora configurata sull'IP TIM (5.98.88.x): il traffico dati di
Intrawelt esce ancora da TIM fino all'08/05/2025.

## 23/04/2025 - Segnalazione Vianova: ponte radio giu'

Vianova chiama il 23/04/2025: la fibra di backup e' up mentre il ponte radio e'
giu'. Il ponte radio e' fisicamente attaccato al router R-1000 e fa parte della
configurazione Line Recovery Standard.

## 30/04/2025 - Analisi servizi attivi sull'IP TIM prima dello switch

Documento di analisi prodotto da Alessio Sopranzi (mail tra asopranzi@intrawelt.com,
apotalivo@intrawelt.com e daniele@puntoinformatica.com del mattino del 30/04/2025).

Servizi che alla data del 30/04/2025 usano ancora l'IP TIM 5.98.88.x:

1. Redirect domini secondari alla VM DOMV (Ubuntu 14.04, intrawelt.com come
   sottodominio in Fastnet): gia' risolto il 02/02/2025 da Tommaso Vezeni con
   completamento tabella redirect su Aruba. Da dismettere.

2. VPN collaboratori esterni via Zywall Secure Extender: solo due utenti attivi,
   Alessia Nasini (accesso da casa al suo PC in ufficio) e Marco Perri (accesso da
   casa al server dell'ufficio). Nessun altro ha necessita' di VPN SSL. Alessio
   Sopranzi usa NinjaOne per il proprio PC da remoto, nessuna VPN SSL necessaria.

3. Tunnel IPsec verso SEEWEB (rete 10.1.116.0/24): da mantenere obbligatoriamente.
   Il server SEEWEB garantisce business continuity per i freelance che ci lavorano
   in varie fasce orarie e non devono avere accesso ai server interni Intrawelt.
   Il tunnel deve essere riconfigurato con il nuovo IP Vianova.

## 08/05/2025 - SWITCH WAN1: da TIM a Vianova

Sequenza completa dell'operazione eseguita il 08/05/2025:

Stato iniziale: WAN2 TIM (31.197.194.x) attiva come backup. Dall'esterno Intrawelt
viene vista con l'IP 31.197.194.x (confermato con speedtest e verifica IP esterno).

Passo 1: viene disattivata temporaneamente la WAN1. Speedtest con solo WAN2: rimane
identico, la connettivita' e' garantita da TIM WAN2.

Passo 2: staccato fisicamente il cavo WAN1 (quello di TIM). Lo speedtest rimane
uguale.

Passo 3: modificato l'indirizzo IP statico della WAN1 nel firewall Zyxel con i
parametri Vianova:
WAN1 IP: 193.124.241.x (oggetto WAN_IP: INTERFACE IP wan1-193.124.241.x)
Subnet: /28 (255.255.255.240)
Gateway: 193.124.241.x
IP aggiuntivi configurati: 193.124.241.x, 193.124.241.x, 193.124.241.x, 193.124.241.x
Oggetto lan_remota_fs_seeweb gia' presente: SUBNET 10.1.116.0/24 con Reference 3.
Oggetto WIZ_VPN_REMOTE gia' presente: SUBNET 10.1.116.0/28 con Reference 0.
Cliccato "Apply".

Passo 4: attaccato il cavo Vianova sulla porta WAN1. Test di connettivita' da
hotspot smartphone esterno: ok. Dall'esterno Intrawelt viene ora vista con il nuovo
IP pubblico Vianova.

Passo 5: spenta la WAN2 TIM. La connettivita' rimane stabile solo con WAN1 Vianova.
Staccato fisicamente anche il cavo WAN2 TIM. Speedtest con solo Vianova: up to 1 Gbps.

Dall'08/05/2025 Intrawelt naviga esclusivamente con la connettivita' Vianova FTTO.
IP pubblico WAN1 definitivo: 193.124.241.x su subnet 193.124.241.x/28.

Conseguenza immediata: il tunnel IPsec verso SEEWEB smette di funzionare perche'
il peer locale configurato lato SEEWEB era ancora 5.98.88.x (IP TIM).

## 08/05/2025 - Inizio debugging tunnel IPsec SEEWEB

Immediatamente dopo lo switch WAN1, il tunnel IPsec Intrawelt-SEEWEB cade.
Analisi iniziale: il firewall OPNsense di SEEWEB (10.1.116.1) ha ancora configurato
il peer remoto con l'IP TIM 5.98.88.x. Accesso al cloud center SEEWEB:
https://cs.cloudcenter.seeweb.it/foundation/v2/servers/fs20608/ con fs20608 / [redacted].
Firewall cloud SEEWEB: https://10.1.116.1 con user1 / [redacted].

Prima ipotesi: sufficiente modificare il remote peer da 5.98.88.x a 193.124.241.x
nel firewall OPNsense SEEWEB senza toccare il resto.

## 14/05/2025 - Ticket N.1317639 SEEWEB: supporto tunnel IPsec

Aperto ticket SEEWEB N.1317639 il 14/05/2025 per supporto nella riconfigurazione
del tunnel IPsec con il nuovo IP Vianova. Il ticket inizia la serie di tentativi
per ripristinare il tunnel.

## 15/05/2025 - Disdetta TIM: 6 PEC inviate

In data 15/05/2025 vengono inviate 6 PEC separate a telecomitalia@pec.telecomitalia.it,
una per ciascuno dei 6 servizi TIM attivi in fattura. L'analisi delle fatture e'
stata svolta in collaborazione con Sonia Martellini via chat Microsoft Teams il
15/05/2025 (file TIM.xlsx come riferimento).

Nota: la fonia TIM era gia' stata disdettata in precedenza in una tranche separata
(marzo 2024: disdetta della linea 0734 228131). Al momento delle 6 PEC del 15/05/2025
la fonia passa gia' su Vianova e rientra nel centralino Panasonic KX-NCP1000.

Materiale da restituire a TIM (in affitto): Router Huawei NetEngine AR651W, Router
Huawei AR1220E, Firewall Taurus Bond (mai connesso). Documentazione fotografica
nella cartella "FOTO - materiale da restituire" e "FOTO - situazione pre disdetta".

## 15/05/2025 - Secondo ticket SEEWEB (ore 13:23): porte 500/4500

Aperto secondo ticket SEEWEB alle 13:23 del 15/05/2025. Il tunnel IPsec parte ma
la fase 2 IKE non si completa. Il traffico esce dalla LAN Intrawelt ma il tunnel
non scambia dati. Allegato al ticket: screenshot del tracert.

Risposta SEEWEB: dal loro lato il nostro firewall sembra bloccare le porte UDP 500
(IKE) e UDP 4500 (NAT-T). Ipotesi: le porte vengono bloccate dal router R-1000 di
Vianova a monte del firewall Zyxel, prima che il traffico raggiunga il firewall.

## 22/05/2025 - TIM: conferme cessazione linee via PEC

Due PEC da TIM arrivano il 22/05/2025 entrambe alle ore 08:35:15:
File DMSB.999TO.20250522.01.TXT.EMAIL.20250522202037.001.35326577.067TO.pdf:
  numero prot. C36869874, oggetto "cessazione linea 073413517900", data
  comunicazione Intrawelt 15/05/2025.
File DMSB.999TO.20250522.01.TXT.EMAIL.20250522200038.001.35326551.067TO.pdf:
  seconda linea confermata.

Materiale da restituire indicato nelle PEC: Router Huawei NetEngine AR651W,
Router Huawei AR1220E, Firewall Taurus Bond.

## 22/05/2025 - Problema VPN NAS per Marco Perri

Marco Perri segnala che non riesce piu' ad entrare nel NAS da remoto con Zywall
Secure Extender. La causa e' il cambio IP pubblico: nel campo server il client
aveva ancora 5.98.88.x:10443 (IP TIM). La correzione e' inserire 193.124.241.x:10443.
Credenziali di accesso: password della mail personale Intrawelt dell'utente.

Problema aggiuntivo identificato: la mail di autenticazione 2FA del NAS invia
ancora il link con il vecchio IP TIM 5.98.88.x. Soluzione: Configuration > Object >
Auth > Two Factor Authentication nel Zyxel USG FLEX 500, aggiornare l'URL da
5.98.88.x a 193.124.241.x.

## 27/05/2025 - Chiamata con Daniele Colo': porte chiuse dal router Vianova

Chiamata con Daniele Colo' il 27/05/2025. Test eseguito da yougetsignal.com/tools/open-ports
sull'IP 193.124.241.x (da smartphone, per avere traffico genuinamente esterno alla rete):
porta 443 (HTTPS): aperta.
porta 500 (IKE UDP): chiusa.
porta 4500 (NAT-T UDP): chiusa.

Nota: il test funziona solo se c'e' un servizio attivo in ascolto su quelle porte.
Il firewall Zyxel ha la VPN attiva e pronta a rispondere, quindi il test e' valido.

La configurazione NAT eseguita sul Zyxel nel frattempo (non risolutiva da sola,
documentata per completezza):

Oggetti Address gia' presenti nel Zyxel:
WAN_IP: INTERFACE IP, wan1-193.124.241.x, Reference 1.
WIZ_VPN_REMOTE: SUBNET 10.1.116.0/28, Reference 0.
lan_remota_fs_seeweb: SUBNET 10.1.116.0/24, Reference 3.

Oggetti Service gia' presenti nel Zyxel:
IKE: UDP=500, Reference 2.
NATT: UDP=4500, Reference 1.

Regole NAT create in Configuration > Network > NAT:
Regola VPN_UDP_500: Classification Virtual Server, Incoming Interface wan1,
  Source IP Any, User-Defined External IP WAN_IP (193.124.241.x),
  User-Defined Internal IP WAN_IP (stesso, il traffico termina sul firewall stesso),
  Port Mapping Type Port, External Port 500, Internal Port 500, NAT Loopback abilitato.
Regola VPN_UDP_4500: identica alla precedente tranne Rule Name VPN_UDP_4500,
  External Port 4500, Internal Port 4500.

Regole Policy Control create in Configuration > Security Policy > Policy Control:
Allow_VPN_UDP_500: Name Allow_VPN_UDP_500, From WAN, To ZYWALL,
  Source Any, Destination WAN_IP (193.124.241.x), Service IKE (UDP 500), Action Allow.
Allow_VPN_UDP_4500: identica con Service NATT (UDP 4500).

Conclusione: nonostante la configurazione corretta sul Zyxel, le porte rimangono
chiuse dall'esterno. Il problema e' a monte: il router R-1000 Vianova non sta
passando le porte 500 e 4500 verso il firewall Zyxel.

## 27/05/2025 - Mail a myOffice per sblocco porte router Vianova

Alessio Sopranzi invia mail a myOffice il 27/05/2025 spiegando che le porte 500
e 4500 sono chiuse sul 193.124.241.x mentre HTTPS (443) e' l'unica aperta. Si
richiede condivisione desktop remoto con il tecnico myOffice per il router R-1000.
La chiamata avviene con condivisione schermo. Il tecnico myOffice non riesce a
capire il motivo del blocco. Risposta successiva di myOffice: "Sembra essere colpa
del router Vianova. Sicuramente quel servizio VPN inoltra le porte verso un loro
servizio cloud invece che verso il firewall."

Guida tecnica studiata nel frattempo:
mysupport.zyxel.com/hc/en-us/articles/360005745060 (Site-to-Site VPN manuale).
mysupport.zyxel.com/hc/en-us/articles/360003880919 (port forwarding su ZyWALL USG).

## 28/05/2025 - Odoo 12: procedura di restore del dump di produzione in locale

Fonte: `Sviluppo_T-Rex (Odoo)/Odoo_12/28052025 - Risoluzione problema restore/`
(registrazione della sessione, transcript e 54 screenshot; testo estratto in
`_notes/.tmp-docx-odoo-restore/`). Sessione guidata con lo sviluppatore
OpenForce per consolidare la procedura di ricostruzione dell'ambiente di
sviluppo locale di Odoo 12: ambiente Docker `intrawelt-docker-env` sulla
partizione Ubuntu di una postazione di sviluppo (10.61.10.57), restore del
dump di produzione (27/05/2025) dal database manager sulla porta 8070.

Le precauzioni operative sono la parte piu' rilevante: il database ripristinato
si nomina sempre con prefisso `test_` per non confonderlo con la produzione;
prima del restore si stacca la connessione internet e, dal container
PostgreSQL, si disattivano tutti i cron (`update ir_cron set active='f'`) per
impedire che l'ambiente di test scarichi o invii posta reale. Il rischio non
e' teorico: e' gia' accaduto che da un ambiente di test partissero notifiche
verso clienti, con reset dello stato di fatture gia' inviate. Seguono il reset
delle password utente e la pulizia degli attachment degli asset con le query
raccolte nel file `dev_database_manager.csv` dell'ambiente, l'update di tutti
i moduli e il rientro nel normale ciclo di sviluppo (aggiornamento di singolo
modulo, verifica delle viste ereditate col plugin di debug, `git pull` sul
branch di test 12.0-test). La procedura completa e' documentata in
`helpdesk-operations.md`. Il sorgente contiene la master password del
database manager e la password di reset degli utenti: non riportate.

## 03/06/2025 - Scoperta: il servizio VPN Unmanaged Vianova non e' attivo

Alessio Sopranzi chiama il numero 145 (supporto Vianova). Confermato: il servizio
"VPN Unmanaged" nel contratto Intrawelt NON e' attivo. Questo servizio e' necessario
per consentire il passthrough del traffico IPsec (porte UDP 500 e 4500) attraverso
il router R-1000 di Vianova verso il firewall Zyxel retrostante.

Senza VPN Unmanaged, il router R-1000 intercetta e blocca il traffico IKE/NAT-T
perche' Vianova offre di default una VPN gestita da loro (verso la propria infrastruttura
cloud), non un passthrough verso apparati del cliente.

Stessa data: Alessio Sopranzi scrive a l.olivieri@myofficegroup.it (Leonardo
Olivieri) spiegando la situazione. Leonardo Olivieri risponde lo stesso giorno:
allega il documento precompilato per la modifica contrattuale da inviare firmato
e timbrato a info@vianova.it. Nota esplicita nel documento: "si tratta di una sola
VPN Point-To-Point."

Nota di Alessio Sopranzi: "Le porte erano aperte col gestore precedente, avrebbero
dovuto esserlo pure con loro. E' una questione di principio, ci siamo stati a
sbattere un mese e il problema era il router loro non configurato."

## 04/06/2025 - VPN Unmanaged Vianova attivata

Il 04/06/2025 alle 14:32 Vianova conferma che il servizio VPN Unmanaged e'
attivato. Nessun costo aggiuntivo applicato rispetto al canone esistente.

## 05/06/2025 - Tunnel ancora non funziona dopo VPN Unmanaged

Nonostante la VPN Unmanaged attiva, il tunnel IPsec non si completa. Alessio
Sopranzi scrive a Leonardo Olivieri (l.olivieri@myofficegroup.it) il 05/06/2025.

Log del firewall Zyxel: il tunnel parte (fase 1 IKE ok), l'IP sorgente usato e'
193.124.241.x, il traffico e' visibile in uscita lato Zyxel. Dal firewall cloud
SEEWEB (OPNsense) non arriva nulla.

Log SEEWEB confermano: il firewall cloud e' raggiungibile dalla WAN cloud, ma il
traffico proveniente da Intrawelt non arriva. Nella dashboard del firewall cloud
la configurazione sembra corretta.

Nuova ipotesi formulata: in mezzo alla comunicazione c'e' un host intermedio del
fornitore Vianova. Dopo il gateway della subnet /29 (WAN dello Zyxel), c'e' un
hop intermedio Vianova che mette come indirizzo sorgente del pacchetto il proprio
gateway, non 193.124.241.x. Il firewall SEEWEB vede come sorgente il gateway della
subnet Vianova invece dell'IP pubblico di Intrawelt.

## 24/06/2025 - RISOLUZIONE TUNNEL SEEWEB

Dopo una parentesi intermedia in cui Intrawelt ha viaggiato sulla connettivita' di
backup del ponte radio, il 24/06/2025 viene eseguita un'ulteriore chiamata con il
supporto tecnico SEEWEB.

Analisi del problema in chiamata: partendo da un dispositivo sulla LAN Intrawelt,
viene tracciato il percorso del pacchetto verso SEEWEB. La fase 1 del tunnel IKE
passa, la fase 2 ha problemi.

Lunga chiamata con operazioni eseguite lato SEEWEB:

Root cause confermata: tra l'IP pubblico Vianova 193.124.241.x e il firewall SEEWEB
c'e' un hop intermedio introdotto da Vianova. L'IP che arriva nel pacchetto al
firewall SEEWEB non e' 193.124.241.x ma il gateway della subnet /29 della WAN dello
Zyxel (la subnet assegnata da Vianova alla WAN). Vianova fa un NAT intermedio che
altera l'indirizzo sorgente. Questa pratica e' comune tra i provider.

Modifiche eseguite dal tecnico SEEWEB sul firewall OPNsense cloud:
Aperte le porte UDP 500 e 4500 a tutti sulla regola Firewall > LAN di OPNsense
(sicuro perche' il server IPsec dello Zyxel filtra comunque il peer IP, nessun
problema di sicurezza aggiuntivo).
Configurazione del peer remoto del tunnel aggiornata per accettare il traffico
dall'IP del gateway intermedio Vianova invece di 193.124.241.x direttamente.

Verifica finale il 24/06/2025 alle ore 16:46:
RDP su 10.1.116.3 (WINGROUPSHARE) con Administrator / [redacted]: accesso riuscito.
RDP su 10.1.116.4 (WINSRV2019) con utente analisi1: accesso riuscito.
Verifica da Sergio Marini su DTP1 e DTP2: funziona.

Il tunnel IPsec Intrawelt-SEEWEB e' pienamente operativo su IP Vianova 193.124.241.x.
Durata totale del processo di risoluzione: dall'08/05 al 24/06/2025, 47 giorni.

## 26/06/2025 - Problema VPN NAS Marco Perri: porta 8008

Il 26/06/2025 Marco Perri si disconnette dal NAS e prova a reinserirsi usando
193.124.241.x:8008 invece della porta 10443. La porta 8008 e' la porta HTTP del
pannello admin QNAP, non la porta SSL per Zywall Secure Extender.
