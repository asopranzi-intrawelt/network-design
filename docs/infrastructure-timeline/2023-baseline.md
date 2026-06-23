# 2023 - Baseline pre-IT-manager

## Contesto di ingresso

Alessio Sopranzi prende in carico l'IT di Intrawelt S.a.s. nell'ottobre 2024,
subentrandoa Pasquale Sconciafurno. Il materiale di riferimento per ricostruire
la situazione precedente e' il file "Architettura Server Intrawelt-punto-informatica.ppt"
e i file "PC-server-stampanti-attivi.xlsx" e "Studio Intrawelt bozza.xlsx" allegati
alla mail inviata da Giordano Mandolesi (gmandolesi@intrawelt.com) a Daniele Colo'
(daniele@puntoinformatica.com) con in CC Tommaso Vezeni in data 03/07/2024.
Lo stesso file di Studio Intrawelt bozza.xlsx viene poi integrato e salvato come
Studio Intrawelt bozza_ALE.xlsx nell'archivio punti-informatica_ADDED.rar.

---

## Switch e topologia LAN

### Piano Terra

Due apparati in produzione al Piano Terra:

ZYXEL GS1900-24 (managed, L2, 24 porte GbE). Switch principale del Piano Terra,
gestisce gli endpoint e gli access point del piano.

Cisco (router fisico) con adattatore PoE esterno dedicato. La connessione fisica
e' la seguente: il Cisco e' attaccato al patch panel 0.8.1, da 0.8.1 c'e' una
patch che fa ponte verso 0.9.1, dove sta attaccato un Access Point esterno. Dal
Cisco esce anche il cavo verso l'adattatore PoE, che a sua volta alimenta l'AP
sulla porta 0.7.1. La terza porta del Cisco va direttamente verso 0-R-18.

### Piano 2 Rack SX

Zyxel XGS2220-54HP (L3 managed, 48 porte GbE + 6 porte SFP+ 10Gbps, PoE++).
Switch principale del Piano 2. Gestito tramite Nebula cloud. Porta 33 connessa al
firewall Zyxel USG FLEX 500 a 1Gbps rame. Porta SFP+ (poi la 52 configurata come
trunk uplink) verso Piano Terra.

QNAP QSW-1208-8c (unmanaged L2, 12 porte 10GbE SFP+). Switch non gestito per
connessioni ad alta velocita' interne tra server e NAS. Presente nello stesso rack.

---

## Connettivita' WAN

### TIM (provider principale)

Tre linee dati separate. Velocita' massima per linea: 100 Mbit/s. Le tre linee
aggregano potenzialmente 300 Mbit/s ma non sono in bonding, ogni linea e' gestita
separatamente.

IP pubblici TIM WAN1: 5.98.88.x / 5.98.88.x / 5.98.88.x
IP pubblico TIM WAN2: 31.197.194.x

In fattura TIM erano presenti servizi inutili mai notati:
Affitto router extra (bimestrale, staccato da almeno ottobre 2024 quando arriva
Alessio Sopranzi, molto probabilmente staccato da molto prima). Servizio "Nuvola IT
Sinfonia" (monitoraggio superfluo che Intrawelt paga a TIM). 8 indirizzi IP pubblici
aggiuntivi mai utilizzati. Taurus Bond firewall in comodato d'uso a TIM (mai connesso,
trovato fisicamente in sede staccato, va restituito). Costo stimato complessivo dei
servizi inutili: oltre 1.000 euro bimestrale.

TIM gestisce anche la fonia: linee ISDN con problemi ricorrenti dal febbraio 2024.
Il centralino fisico e' un Panasonic KX-NCP1000.

### Vianova (provider secondario dal 2024)

Al momento dell'ingresso di Alessio Sopranzi Vianova e' gia' attiva per la voce e
come servizio radio di backup. La prima fattura Vianova per Intrawelt S.a.s. risale
ad aprile 2024, osservata da Giordano Mandolesi tramite mail a gmandolesi@intrawelt.com.

Il servizio Vianova attivo nel 2024 comprende:
Ponte radio (uso come backup e voce). L'offerta successiva prevede 100 Mbps download
e 20 Mbps upload sul ponte radio come Line Recovery Standard.

---

## Firewall

ZYXEL USG FLEX 500. IP LAN: 192.168.20.1. Configurato originariamente da Pasquale
Sconciafurno.

Accesso da LAN: https://192.168.20.1
Accesso da WAN: https://5.98.88.x
Credenziali: admin / [redacted]

Account Zyxel marketplace: psconciafurno@intrawelt.com (poi migrato a it@intrawelt.com)
License Key al momento del rinnovo 20/11/2024: [redacted]
Device S/N: S232L12101347, MAC: FC:22:F4:E9:A4:4C

Problemi noti alla configurazione Zyxel trovati da Alessio Sopranzi:
Regola NAT obsoleta DOMV_WEB per Ubuntu-1404-DOMV (vecchi IP pubblici TIM).
Regola di routing statico obsoleta: 10.10.10.10 verso 192.168.20.114 (cancellata).
VPN_auth_LAN2 attiva su WAN2 ma non necessaria.
Certificato SSL VPN in scadenza il 24/10/2024 (primo intervento di Alessio Sopranzi).

---

## VPN e tunnel cloud

Tunnel IPsec tra ZYXEL USG FLEX 500 e firewall cloud SEEWEB.
IP pubblico locale (lato Intrawelt): 5.98.88.x (TIM WAN1).
IP pubblico SEEWEB: 212.35.202.x.
Rete privata SEEWEB: 10.1.116.0/24.

Firewall cloud SEEWEB: OPNsense su 10.1.116.1.
Credenziali firewall cloud: user1 / [redacted].
URL accesso: https://10.1.116.1/firewall_rules.php?if=wan

---

## Virtualizzazione

Tre host di virtualizzazione presenti:

HP G5 (VMware ESXi fisico in sede). 4 VM attive: 2 Linux + 2 Windows. Le restanti
VM presenti sono: una spenta, tre "azzurre" (VMware standard) non necessarie.
IP presumibile: 192.168.20.8 (quello noto come IP del vecchio vSphere, da spegnere).

HP G9 (VMware ESXi fisico in sede). Spento definitivamente il 19/12/2024 da
Daniele Colo' (Punto Informatica). Al momento del sopralluogo del 19/12/2024
Daniele Colo' e' entrato nell'interfaccia NAS INTRA2 da 192.168.20.177:8080.

SEEWEB FoundationServer PRO (cloud IaaS). Tipo: Foundation Server Pro con
processori Intel Xeon. Storage SAN ad alte prestazioni e scalabile. Banda: 10 Gbps.
Accesso cloud center: https://cloudcenter.seeweb.it/ con fs20608 / [redacted].
Accesso ESXi: https://10.1.116.2/ui/#/login con root / [redacted].
Rete privata: net006287 (VLAN ID 437).
Due VM attive su SEEWEB:

WINGROUPSHARE (10.1.116.3): Windows Server con backup delle TM (translation memory),
glossari e backup della cartella UTILI. Backup eseguiti via Cobian Backup. Usata da
freelance e collaboratori esterni che non devono accedere ai server interni Intrawelt.
Accesso RDP: Administrator / [redacted].
URL groupshare: http://gs.intrawelt.com/
Riavvio servizi Trados GroupShare: via Trados GroupShare Console, icone sulla barra,
colonna "Restart Services".

WINSRV2019 (10.1.116.4): Windows Server 2019. Desktop remoti per PM e DTP.
Accesso RDP: utente analisi1.

L'accesso alle VM SEEWEB e' consentito solo da indirizzi locali (policy firewall
OPNsense). Modifica policy: accedere a https://10.1.116.1/

---

## NAS fleet

Tutti i NAS sono connessi alla rete 192.168.20.0/24.

NAS HERO (.169): QNAP con QuTS hero. Archivio principale dei progetti PM, mappato
come drive H: sui client. RAID attivo. Usato come storage primario di lavoro.

NAS INTRA (.168): QNAP TS-410U. Target primario dei backup Cobian e MKSBackup VM.
Archivio secondario.

NAS INTRA2 (.177): QNAP TS-451U. RAID 5 con 4 dischi da circa 2.73 TB ciascuno
(capacita' totale raw circa 10.92 TB, disponibile RAID 5 circa 8.19 TB). Usato
per backup del NAS HERO e della cartella utili. Alla fine del 2024 lo spazio e'
quasi esaurito, con fail su backup incrementale bloccato all'1%.

NAS INTRA3 (.172 / .173): QNAP TS-210. Dismesso di fatto dal 2022. Fisicamente
era nella sede precedente in Via Pescolla. Contiene solo backup di Glossari,
Multiterm e TM del periodo 2020-2021-2022. Credenziali: admin / [redacted].
URL: https://192.168.20.172/cgi-bin/

NAS documenti (.170): HPX1400. Archivio cartella utili. Target backup generico.
Archivio certificati SSL: \\192.168.20.170\vpn\Certificati SSL

---

## Domotica e impianti

MH Server (Myhome, Piano 2). Gestisce luci, allarme, termostati. Il bus domotica
e' separato dall'ethernet e non e' di interesse per la rete dati. La centrale
allarme e' connessa in rete sopra il CED. Il Myhome server controlla accensioni e
spegnimenti generali, la centrale allarme, i termostati per ufficio (testine di
zona su collettori per il riscaldamento con curva climatica impostata dall'idraulico).

Concentratore termoregolazione Piano Terra: dispositivo separato per visualizzare
i parametri del sistema di riscaldamento. Non e' gestibile tramite l'ethernet.

---

## Credenziali e account (eredita' da Pasquale Sconciafurno)

Zyxel USG FLEX 500 locale: admin / [redacted]
Zyxel marketplace (migrato): it@intrawelt.com / [redacted]
SSL VPN (ZeroSSL/sslforfree): it@intrawelt.com / [redacted]
SEEWEB cloud center: fs20608 / [redacted]
SEEWEB firewall OPNsense: user1 / [redacted]
SEEWEB ESXi: root / [redacted]
WINGROUPSHARE RDP: Administrator / [redacted]
NAS (pattern generico): admin / [redacted]

---

## 23/03/2023 - Mail Pasquale Sconciafurno su telefonia

Pasquale Sconciafurno conferma a Daniele Colo' che il numero storico 0734993744
resta attivo sul centralino Panasonic KX-NCP1000 collegato alle 2 linee ISDN TIM.
Numerazioni passanti su un numero tipo 07342010XX (non ancora definitivo al momento).
Potenziale: 6 linee VoIP vs 4 ISDN attuali.

## 01/02/2024 - Offerta TIM centralino virtuale VoIP (non accettata)

TIM invia a Pasquale Sconciafurno due proposte commerciali:
TIM COMUNICA Centralino Virtuale (voce e telefoni fisici inclusi).
TIM Trunking Comunica (solo trunking VoIP, senza telefoni).
Proposta non accettata. Il centralino fisico Panasonic KX-NCP1000 resta in uso.

## 03/07/2024 - Inventario Punto Informatica

Giordano Mandolesi invia a Daniele Colo' (CC Tommaso Vezeni) il check infrastruttura
con tre file allegati: Architettura Server Intrawelt-punto-informatica.ppt,
PC-server-stampanti-attivi.xlsx, Studio Intrawelt bozza.xlsx.
File rinominato e archiviato come punti-informatica_ADDED.rar con Studio Intrawelt
bozza_ALE.xlsx.

## Aprile 2024 - Prima fattura Vianova

Prima fattura Vianova per Intrawelt S.a.s. per servizio voce e ponte radio.
Osservata da Giordano Mandolesi via mail gmandolesi@intrawelt.com.
