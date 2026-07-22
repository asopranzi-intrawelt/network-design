# Firewall Zyxel USG FLEX 500 - Configurazione e architettura

Fonte: backup startup-config.conf del 19/05/2026 (generato automaticamente alle 05:59:32).
Analisi condotta il 29/05/2026 (Analisi_Zyxel_USG_FLEX_500.docx).
Piano di revisione e DMZ prodotto il 05/06/2026 (Revisione_Rete_DMZ_Proxmox.docx,
Piano_Operativo_Migrazione.docx, LE SEI FASI.txt).
Firmware: Zyxel ZLD 5.42(ABUJ.1). File di 2215 righe.

**Stato al 01/07/2026: Fase 0 applicata, Fasi 1-6 ancora da eseguire.** Il file
`startup-config.conf` datato 05/06/2026 resta la configurazione target preparata
per il caricamento in blocco (Fase 5), non ancora eseguito. La sola Fase 0
(correzione immediata della regola phishing) e' stata applicata via GUI il
01/07/2026, guidata passo per passo e verificata su screenshot indipendenti:
dettaglio completo in `docs/firewall-zyxel-usg-flex-500-live.conf`, il changelog
incrementale delle modifiche live sul dispositivo. FW-001 e FW-002 sono quindi
**risolte**; FW-004, FW-008, FW-009 (rimozione LAN2/WAN_TRUNK, attivazione DMZ)
restano aperte in attesa della finestra di manutenzione per le Fasi 1-6. Vedi la
roadmap tracciata in `.claude/context/roadmap.md`, micro-step M1 (fatto) e M2
(prossimo).

---

## Porte fisiche e mapping interfacce

Il dispositivo ha 8 porte fisiche P1-P8. P1 e' uno slot SFP fibra (ge1/sfp),
le restanti sono Ethernet RJ45 GbE.

| Porta | Interfaccia logica | Nome         | Stato         |
|-------|--------------------|--------------|---------------|
| P1    | ge1                | sfp          | non in uso    |
| P2    | ge2                | wan1         | attiva        |
| P3    | ge3                | wan2         | attiva (TBC shutdown) |
| P4    | ge4                | lan1         | attiva        |
| P5    | ge5                | lan2         | bridge con lan1 (vedi port-grouping) |
| P6    | ge6                | dmz          | bridge con lan1 (vedi port-grouping) |
| P7    | ge7                | guest        | dmz fisica (vedi port-grouping) |
| P8    | ge8                | reserved     | guest (vedi port-grouping) |

### Port-grouping effettivo (governa l'assegnazione fisica, non interface-name)

```
port-grouping wan1    port 2
port-grouping wan2    port 3
port-grouping lan1    port 4, 5, 6    (bridge L2 su tre porte fisiche)
port-grouping dmz     port 7
port-grouping guest   port 8
port-grouping lan2    (nessuna porta assegnata - routed only)
port-grouping reserved (nessuna porta assegnata)
```

Conseguenza: P4, P5, P6 sono in bridge L2 sotto lan1. Le etichette "lan2" e "dmz"
su ge5/ge6 non corrispondono al traffico che trasportano fisicamente: entrambe
contribuiscono al bridge della LAN principale.

---

## Interfacce e indirizzamento

### WAN

**wan1** (P2): 203.0.113.5/28, gateway 203.0.113.1 (Vianova FTTO).
Alias definiti ma in stato shutdown: 203.0.113.2, .3, .4, .254.
L'alias wan1:2 (203.0.113.3) e' previsto per la DMZ web (vedi sezione DMZ).

**wan2** (P3): 198.51.100.218/29, gateway 198.51.100.217 (TIM, linea non piu' connessa
fisicamente da maggio 2025). Pianificato shutdown amministrativo nella revisione.

**WAN_TRUNK**: gruppo logico che unisce wan1 e wan2 con algoritmo Weighted Round Robin
(WRR) in outbound. wan2 configurata come link primario (weight 1), wan1 configurata
come passive (failover). Con la dismissione di TIM il trunk e' previsto da rimuovere:
il firewall vedra' il solo wan1 come uscita predefinita.

```
interface-group WAN_TRUNK
  algorithm wrr
  loadbalancing-index outbound
  interface 1 wan1 passive
  interface 2 wan2 weight 1
system default-interface-group WAN_TRUNK
```

### LAN

**lan1** (P4+P5+P6 bridge): 10.61.10.1/19.
Le tre sottoreti condividono lo stesso segmento broadcast fisico.
DHCP pool LAN1_POOL: 10.61.10.200, 55 assegnazioni, lease 2 giorni.
22 PC fissi dichiarati come address-object con IP statici (range 10.61.10.18-84).

**lan1:1** (subnet server): 10.61.20.1/19. 9 host nominati come address-object:
NAS FTP (.168), INTRA (.168), INTRA2 (.177), HERO (.169), EGETRAD, EGETRAD_TEST,
DOMV (.116), server demo, server OpenVPN.

**lan1:2** (subnet stampanti): 10.61.30.1/19.

**lan2**: interfaccia logica 10.61.200.x, nessuna porta fisica assegnata.
Raggiungibile solo via rotta statica attraverso router downstream 10.61.100.1
(non piu' presente). Prevista dismissione.

**dmz** (ge6/P7): 10.61.201.1/24. Pool DHCP presente nella config attuale
(prevista rimozione: server DMZ devono usare IP statici). Porta da cablare
verso lo switch per la nuova architettura DMZ.

**guest** (`vlan90`, interfaccia 802.1Q su base port `lan1`, VID 90, zona OPT,
Interface Type `general` — nessun mascheramento automatico, vedi §Policy Route):
10.61.90.1/24. DNS Google (8.8.8.8, 8.8.4.4). Zona ospiti. Nota: verificato il
22/07/2026 su `Network > Interface` che la guest e' una VLAN su `lan1` (come la
`vlan40` staff), non piu' la porta fisica ge7/P8 come indicato in una versione
precedente di questa scheda.

**vlan40** (interfaccia taggata 802.1Q su base port `lan1`, nessuna porta
fisica dedicata): 10.61.40.1/24, zona **WIFI_STAFF** dedicata (creata e
assegnata il 16/07/2026, spostata dalla zona di default LAN1 subito dopo
la creazione). Applicata realmente sul dispositivo lo stesso giorno
tramite GUI, verificata su screenshot (Object > Zone: WIFI_STAFF con
`vlan40` come unico membro, LAN1 tornata a contenere solo `lan1`). Vedi
§Fase A rete Wi-Fi (M13a) piu' sotto per il piano completo e la security
policy associata, ancora da applicare al momento di questa nota.

---

## Rotte statiche

```
ip route 10.61.2.0/24    via 10.61.10.1    (ricorsiva via LAN1)
ip route 10.61.100.0/24  via 10.61.10.1    (ricorsiva via LAN1)
ip route 10.61.200.0/24  via 10.61.100.1   (router downstream)
```

**Anomalia**: le rotte dipendono da un router downstream 10.61.100.1 che non e'
monitorato dal firewall. Con il router assente (LAN2 dismessa) le rotte puntano
a un gateway inesistente. Prevista rimozione completa di tutte e tre le rotte
statiche nella revisione (la tabella si riduce alle reti direttamente connesse
piu' la rotta di default verso wan1).

---

## VPN

### Tunnel IPsec site-to-site verso SEEWEB

Due profili verso lo stesso peer <IP-SEEWEB-PEER> (infrastruttura SEEWEB):

**PSE-SEEWEB**: IKEv1 modalita' aggressive, PSK, AES-128/SHA-1/DH2, lifetime 24h,
DPD 30s. Local-policy: RFC1918_3 (10.61.0.0/16). Remote-policy: 10.77.116.0/24.
PFS gruppo DH2.

**WIZ_VPN**: IKEv1 modalita' main, stessi parametri di cifratura.

Nota: AES-128/SHA-1/DH2 sono il minimo accettabile. Gruppo DH2 considerato obsoleto.
La presenza di due profili verso lo stesso peer indica transizione in corso o
configurazione ridondante.

### VPN remote-access IKEv2

**RemoteAccess_Wiz**: IKEv2 server, autenticazione RSA + EAP/MSCHAPv2.
Certificato: RemoteAccess_203.0.113.5. AES-128/SHA-256, gruppi DH 2/14/21.
Pool client: 10.61.50.0/27. DNS push: 10.61.10.1. Zona dedicata: VPN_To_WAN_SNAT.
Traffico client: 0.0.0.0/0 (tutto attraverso il tunnel).

### SSL VPN

**ssl_vpn_intrawelt**: porta TCP 443, TLS. Gruppo utenti: vpn-users.
Reti raggiungibili dai client: 10.61.10.0/19, 10.61.20.0/19,
10.61.30.0/19, 10.77.116.0/24.
Pool client: 10.61.230.10-250.
Filtro geografico: solo Italia e USA (regole 5 e 6 della security policy).

### 2FA

Google Authenticator (TOTP). Canale alternativo: email o SMS. Validita' codice: 5 minuti.
Attivo su: SSL VPN, accesso admin via SSH e Web UI, accesso NAS (URL aggiornato
a luglio 2025 da 192.0.2.50 a 203.0.113.x).

---

## NAT e virtual server

10 dichiarazioni totali. 3 attive, 7 deactivate.

**Attive:**
- `Subnet_nat`: NAT 1-a-1 tra LAN1_SUBNET e RFC1918_3.
- `VPN_UDP_500`: port forwarding UDP 500 (IKE) su wan1 verso il firewall stesso.
- `VPN_UDP_4500`: port forwarding UDP 4500 (NAT-T) su wan1 verso il firewall stesso.

**Deactivate (storiche):**
DOMV_WEB, NAS_FTP_WEB, NAS_HERO_SUPPORT, EGETRAD_WEB, DEMO_SERVER_WEB, OpenVpn,
VPN_auth_LAN2 (disattivata il 15/05/2025, perche' con la sola connettivita'
Vianova la WAN2 non e' piu' utilizzata; puntava all'host interno
10.61.100.2 su wan2, presumibilmente un server VPN di autenticazione
remota legacy).

**Disallineamento (RISOLTO il 16/07/2026)**: le secure-policy 8, 9, 10
(DOMV_WEB, DEMO_SERVER_WEB, EGETRAD_WEB) erano attive ma i corrispondenti
virtual server sono deactivate da tempo — nessun traffico reale prodotto
senza il NAT in ingresso, ma un rischio latente se il NAT fosse mai stato
riattivato per errore. Durante la sessione di pulizia per M13a, l'utente ha
verificato e rimosso non solo queste tre ma anche altre quattro regole
nella stessa condizione (`EGETRAD_WEB_TEST`, `NAS_HERO_SUPPORT`,
`NAS_HERO_SUPPORT2`, `NAS_FTP_WEB` — le ultime due coerenti con
`NAS_FTP_WEB`/`NAS_HERO_SUPPORT` gia' elencate sopra tra i virtual server
deactivate), piu' due regole di egress nominative per due postazioni
specifiche (non legate al disallineamento NAT, verificate separatamente
dall'utente come non piu' necessarie). Rimosse 9 secure-policy in totale,
applicate sul dispositivo lo stesso giorno.

**Pianificato (revisione 05/06/2026):**
- `DMZ_WEB_HTTPS`: wan1:2 (203.0.113.3) -> SRV-DMZ-WEB (10.61.201.10) porta 443.
- `DMZ_WEB_HTTP`: wan1:2 -> SRV-DMZ-WEB porta 80.

---

## Policy Route (SNAT)

Fino al 22/07/2026 la tabella Policy Route era vuota. Sullo ZLD il SNAT verso la
WAN e' automatico solo per le interfacce LAN nate con la configurazione di
fabbrica (il SNAT implicito, che maschera l'IP privato con quello della WAN in
uscita cosi' che la risposta sappia tornare); le interfacce aggiunte a mano non
ne sono coperte e richiedono una policy route di SNAT esplicita. Per questo la
rete guest (VLAN 90, 10.61.90.0/24), pur avendo DHCP funzionante sull'interfaccia
guest (.90.1) e la security policy `GUEST_Outgoing` che ne permette l'uscita,
prendeva l'indirizzo ma non navigava: i pacchetti uscivano con IP sorgente
privato e la risposta non poteva tornare.

La diagnosi del 22/07/2026 ha isolato la causa a strati: livello 2 verso il
gateway guest integro (l'ARP del client risolve il MAC dell'interfaccia guest del
firewall), traffico guest verso WAN permesso dalla regola 12 senza alcun drop nel
log, tabella NAT con soli virtual server e tabella Policy Route vuota. Restava il
solo SNAT mancante.

Regola creata il 22/07/2026, risolutiva:

```
GUEST_SNAT
  Incoming:     any (Excluding ZyWALL)
  Source:       GUEST_SUBNET (10.61.90.0/24)
  Destination:  any
  Next-Hop:     Auto
  SNAT:         outgoing-interface
```

Verificata sul campo: dopo l'applicazione il client guest raggiunge Internet
(ping verso 8.8.8.8 con risposta) e i dispositivi sull'SSID ospiti navigano.
Intervento non distruttivo, reversibile disattivando la regola o portando lo SNAT
a `none`.

Nota (correzione 22/07/2026). La Wi-Fi staff su `vlan40` naviga gia' (verificato
dall'utente), pur con la Policy Route vuota: il firewall le applica quindi il
mascheramento verso la WAN in automatico, a differenza della guest. La verifica del
22/07 su `Network > Interface` ha dato la risposta definitiva: la differenza sta
nel campo `Interface Type` dell'interfaccia. La `vlan40` staff e' di tipo
`internal`, la `vlan90` guest e' di tipo `general` (entrambe VLAN sulla stessa
porta base `lan1`, quindi non c'entrano ne' la porta base ne' la subnet). Sullo
ZLD il mascheramento automatico verso la WAN si applica al traffico che esce da
un'interfaccia `internal` verso un'interfaccia `external`: e' l'etichetta
`internal` a farlo scattare. La `vlan40` (internal) lo ottiene di default e naviga
senza regole; la `vlan90` (general) non lo ottiene, ed e' esattamente per questo
che ha richiesto la policy route `GUEST_SNAT` esplicita. Il rinumero della staff
all'indirizzamento corretto della classe interna (22/07; nel modello documentale
la staff resta `10.61.40.x`, i valori reali stanno in `_notes/` per policy di
anonimizzazione) lo conferma indirettamente: cambiata la subnet, la staff
continua a navigare, quindi il mascheramento non dipende dall'indirizzo ma dal
tipo di interfaccia.

Nota di sicurezza: per una rete ospiti tenere la `vlan90` su `general` con SNAT
esplicito e' preferibile a marcarla `internal`, perche' cosi' il firewall non la
tratta come rete interna fidata. Il fix scelto (policy route dedicata) e' quindi
anche il piu' corretto, non un ripiego. Le due alternative equivalenti per dare
Internet alla guest erano: la `GUEST_SNAT` esplicita (scelta) oppure cambiare
`Interface Type` della `vlan90` in `internal`. L'intervento SNAT sulla guest resta comunque
corretto e necessario, e la `vlan40` NON richiede uno `STAFF_SNAT` perche' gia'
naviga.

Restano due affinamenti. La regola 12 `GUEST_Outgoing` ha `To: any` troppo largo
e va ristretta alla sola WAN per la segmentazione (la guest oggi potrebbe
raggiungere anche le zone interne): meglio farlo sul firewall che sull'access
point, perche' il toggle Guest Network di Nebula fa isolamento L2 ma su una rete
VLAN richiede di aggiungere a mano il MAC del gateway alla lista di isolamento,
pena la perdita del gateway stesso. Sul fronte staff resta invece il solo
rinumero della `vlan40` all'indirizzamento reale (voce operativa privata),
verificando poi che la navigazione regga.

---

## Security policy

Stato al 19/05/2026 (backup di riferimento): 34 regole attive +
default-deny (action deny log alert). **Aggiornato il 16/07/2026**: 9
regole rimosse durante la pulizia per M13a (vedi §NAT e virtual server,
Disallineamento risolto), poi 2 regole nuove aggiunte per la VLAN 40
(`WIFI_STAFF_to_LAN1_deny` priorita' 1, `WIFI_STAFF_Outgoing` priorita' 2 —
l'ordine e' stato invertito una volta per errore in fase di creazione e
corretto con "Move" prima di Apply, stesso principio dell'anomalia FW-001:
il motore valuta dall'alto in basso e si ferma alla prima corrispondenza)
— **27 regole attive** dopo l'applicazione. Organizzate per coppia di zone
(sorgente, destinazione).

**Regola 1 - Anomalia critica**: `Blocco_Gruppo_IP_Phishing_Elisa`
- Sorgente: WAN. Action: **allow** (dovrebbe essere deny).
- Contiene 11 IP raccolti dall'incidente phishing 08/01/2026.
- Includeva anche 203.0.113.5 (IP pubblico del firewall stesso, rimosso).
- Poiche' e' la prima regola e il motore si ferma alla prima corrispondenza,
  quegli IP scavalcano tutti i controlli successivi.
- **Fix immediato**: cambiare action in deny, aggiungere log alert,
  rimuovere 203.0.113.5 dal gruppo Bad_IP_Phishing_Elisa_2026.

**Regola gemella - Anomalia**: `malicious_IP_12052025`
- Blocco in uscita verso 4.207.164.234, anche questa con action allow.
- Fix: cambiare in deny.

**Regole 5-6**: accesso SSL VPN solo da Italia e USA (blocco geografico).
**Regola RDP ospiti**: consentiva RDP dalla rete guest verso LAN. Rimossa nella revisione.

Struttura generale:
- LAN -> WAN: allow (uscita generale)
- VPN -> LAN: allow (client VPN verso risorse interne)
- WAN -> ZyWALL: allow su porte di management e servizio
- WAN -> LAN: deny (default, con eccezioni per virtual server attivi)
- Guest -> LAN: deny
- DMZ -> LAN: deny log alert (nuova regola, revisione 05/06/2026)
- DMZ -> WAN: allow (aggiornamenti e certificati)
- WIFI_STAFF -> LAN1: deny log (nuova regola, M13a, 16/07/2026 — isolamento Wi-Fi staff da NET-005)
- WIFI_STAFF -> WAN/altre zone: allow (nuova regola, M13a, 16/07/2026 — uscita generale, stesso pattern di LAN1_Outgoing)

---

## UTM

**Content filter**: due profili.
- BPP: categorie tipicamente bloccate in ambito aziendale.
- CIP: schema restrittivo orientato alla protezione dei minori.

**SSL inspection**: attiva con aggiornamento automatico certificati radice.
Eccezione: *.intrawebsite.it escluso dall'ispezione.

**Sandbox**: abilitata per exe, documenti Office, archivi compressi, PDF, Flash, RTF.

**IP reputation**: livello high, aggiornamento giornaliero alle 03:00.
Categorie bloccate: spam, exploit, scanner, botnet, phishing, DoS, Tor.

**App patrol**: profilo default_profile, blocca con drop e log oltre 60 application ID.

---

## Architettura DMZ pianificata (05/06/2026)

### Principio

La DMZ non e' in serie tra Internet e LAN: e' un braccio parallelo con centro
nel firewall (topologia a stella). LAN esce da P4 (ge4), DMZ esce da P7 (ge6).
I percorsi non si incrociano.

L'analisi comparativa del 29/05/2026 (`zyxel-dmz-proxmox.md`, diagrammi
`dmz_con_trunk.svg` e `dmz_senza_trunk.svg` archiviati in
`.claude/context/diagrams/firewall-dmz-2026/`) aveva messo a confronto due
opzioni per collocare una VM Proxmox in DMZ: un secondo cavo dedicato da P7 a
una seconda NIC del server, con Proxmox dotato di due bridge fisici separati
(vmbr0 LAN, vmbr1 DMZ), oppure il trunk 802.1Q qui descritto. La prima opzione
e' stata scartata perche' rigida, consuma una porta fisica aggiuntiva e non
scala; il trunk e' stato scelto perche' un solo cavo, lato firewall e lato
Proxmox, porta sia il traffico LAN sia la VLAN 201 DMZ, distinti dal tag,
lasciando al bridge Proxmox VLAN-aware il compito di separarli internamente.
L'unico prerequisito non confermato al momento dell'analisi comparativa era il
supporto 802.1Q dello switch XGS2220-54HP, verificato poi in Fase 1 del piano
operativo (sezione successiva).

### Implementazione VLAN 201

Il firewall non esegue tagging VLAN: resta a L3. Il tagging 802.1Q e' delegato allo switch.

**Switch XGS2220-54HP**:
- VLAN 201 creata con nome DMZ.
- Porta da P7 del firewall: access, PVID 201, untagged.
- Porta verso Proxmox: trunk, traffico LAN untagged (PVID corrente) + VLAN 201 tagged.

**Proxmox HP Gen10** (bridge vmbr0):
```
bridge-vlan-aware yes
bridge-vids 2-4094
# applicazione a caldo da console iLO: ifreload -a
```
- VM senza tag: traffico LAN, IP 10.61.20.x, gateway 10.61.20.1.
- VM con tag 201: traffico DMZ, IP 10.61.201.x, gateway 10.61.201.1.
- Il bridge mantiene i due domini L2 separati anche tra VM sullo stesso host fisico.

**Firewall - interfaccia dmz** (config aggiornata):
```
interface dmz
  ip address 10.61.201.1 255.255.255.0
  type internal
  mtu 1500
  ! nessun ip dhcp-pool: indirizzamento statico
```

**Prima VM DMZ**: nginx reverse proxy a 10.61.201.10, esposto su wan1:2 (203.0.113.3).

---

## Fase A rete Wi-Fi (M13a): piano firewall per VLAN 40

VLAN confermata dall'utente il 15/07/2026: **40**. Lato switch, l'assegnazione
delle tre porte AP e' automatizzata da `scripts/Set-NebulaWifiVlan.ps1`
(dry-run di default, ADR-010); la propagazione sulla dorsale non serve, e'
gia' verificato sui dati reali che ogni porta di entrambi gli switch ha
`allowedVLAN: "all"` — nessun filtro per numero di VLAN, qualunque VLAN
taggata attraversa gia' ogni collegamento inter-switch, dorsale compresa.
Lato firewall non esiste un canale API (vedi nota piu' sotto): il piano
seguente va applicato a mano, con lo stesso metodo gia' verificato per M1 —
GUI passo passo con screenshot di conferma
(`.claude/rules/manual-screenshots.md`), non incolla di comandi CLI grezzi
in una sessione SSH.

### Interfaccia VLAN 40

Indirizzamento coerente con la convenzione del progetto (ottetto = ID VLAN,
vedi `.claude/rules/anonymization.md`): **10.61.40.0/24**, gateway
**10.61.40.1**. Sintassi di riferimento nello stesso idioma verificato di
questo dispositivo (estratto dalla configurazione target 05/06/2026, sezione
DMZ sopra):

```
interface vlan40
  ip address 10.61.40.1 255.255.255.0
  type internal
  mtu 1500
  ip dhcp-pool WIFI40_POOL start 10.61.40.10 count 200 lease 1
```

**DHCP applicato realmente il 16/07/2026** (GUI, Edit VLAN > Show Advanced
Settings > DHCP Setting — sezione non ovvia, nascosta dietro un link non
espanso di default, stessa cautela delle altre GUI di questo progetto):
DHCP Server, IP Pool Start Address `10.61.40.10`, Pool Size `200`, First
DNS `8.8.8.8`, Second DNS `1.1.1.1` (stesso principio del DNS pubblico gia'
usato per la rete Guest, ma Cloudflare al posto del secondo DNS Google),
Default Router auto su `vlan40 IP`, Lease Time **2 giorni** (coerente con
`LAN1_POOL`). Nessun DNS interno configurato: se i client Wi-Fi staff
dovessero risolvere nomi interni (NAS, server) andra' rivisto.

Percorso GUI equivalente (Network > Interface > VLAN > Add): VLAN ID 40, IP
sopra. **Porta fisica sottostante (corretto 15/07/2026, la versione
precedente di questa nota era imprecisa)**: tutte le 8 porte fisiche del
firewall sono gia' assegnate (nessuna porta libera come per la DMZ, che ha
una P7 dedicata), quindi vlan40 va legata allo stesso port-group **lan1**
(P4/P5/P6) gia' in uso per la LAN principale, come interfaccia taggata sullo
stesso cavo fisico. Verificato che questo funziona senza toccare lo switch:
la porta 33 del 54HP (dove termina la P4 del firewall, `network-diagram.md`)
ha anch'essa `allowedVLAN: "all"` — il tag 802.1Q per la VLAN 40 attraversa
gia' quel collegamento, lan1 (nativa/untagged) e vlan40 (taggata) condividono
lo stesso cavo senza interferire, esattamente come qualunque coppia
nativo+taggato su un trunk 802.1Q. **Zona**: da assegnare dal menu a tendina
della GUI al momento della creazione, non ipotizzata qui in CLI — il dump
consultato non mostra la riga `zone` per le interfacce esistenti in forma
scriptabile certa, e sbagliare la zona a mano libera invaliderebbe la regola
di security policy successiva senza errore visibile. Suggerimento: una zona
dedicata (es. `WIFI_STAFF`), non la stessa della VLAN 90 Guest/IoT legacy ne'
la zona LAN1.

### Security policy (ACL di isolamento)

Sintassi verificata sullo stesso dispositivo (stessa forma delle regole
applicate per M1, `firewall-zyxel-usg-flex-500-live.conf`):

```
secure-policy N
 name Wifi40_to_LAN1_deny
 from WIFI_STAFF
 to LAN1
 sourceip any
 destinationip any
 action deny
 log alert
```

`WIFI_STAFF` e `LAN1` vanno confermati con i nomi zona reali scelti/esistenti
sulla GUI (LAN1 e' presumibilmente il nome della zona che ospita l'interfaccia
lan1/10.61.10.0/19, coerente con "VLAN 10 management" citata in NET-005 e
GAP-TBC, ma non riletto da un dump di zone completo in questa sessione: da
confermare sulla pagina Object > Zone prima di creare la regola). `N` e' il
primo numero di regola libero in Policy Control al momento dell'intervento,
da inserire PRIMA di qualunque regola generica "LAN -> WAN: allow" che
altrimenti la precederebbe nell'ordine di valutazione (stesso principio
dell'anomalia FW-001: il motore si ferma alla prima corrispondenza).

### Checklist di applicazione

Ordine corretto per non scollegare un AP live prima che il resto sia pronto
(verificato il 15/07/2026: niente pre-creazione VLAN necessaria, il PVID in
Nebula e' un campo libero — vedi ADR-010). **Aggiornamento stesso giorno**:
verificato sui dati reali che ogni porta di entrambi gli switch, dorsale
inclusa, ha gia' `allowedVLAN: ["all"]` — la VLAN 40 attraversa gia' il
collegamento tra i due switch senza bisogno di modifiche esplicite sui
trunk (`Set-NebulaWifiVlan.ps1 -Only Trunk` risulta a zero modifiche, passo
verificato ma non piu' necessario). Il passo 1 originale (propagazione
trunk) e' quindi saltato:

1. **Fatto 16/07/2026.** Interfaccia `vlan40` creata sul firewall via GUI
   (Base Port lan1, IP 10.61.40.1/24), zona dedicata `WIFI_STAFF` creata e
   assegnata (spostata dalla zona di default LAN1). DHCP configurato nella
   stessa sessione (era rimasto su "None" al primo giro, corretto prima di
   proseguire): pool 10.61.40.10-209, DNS 8.8.8.8/1.1.1.1, lease 2 giorni.
2. **Fatto 16/07/2026.** Security policy create: `WIFI_STAFF_to_LAN1_deny`
   (priorita' 1) e `WIFI_STAFF_Outgoing` (priorita' 2, allow verso
   WAN/altre zone) — ordine corretto con "Move" dopo un primo tentativo
   invertito, verificato prima di Apply. In parallelo, pulizia di 9
   secure-policy disattivate non piu' necessarie (vedi §NAT e virtual
   server, Disallineamento risolto).
3. **Tentato e ripristinato 16/07/2026.** `Set-NebulaWifiVlan.ps1 -Only
   Access -ApName <nome> -Apply` eseguito una porta alla volta, ciascuna
   verificata correttamente lato switch (portVid/allowedVLAN, tabella MAC
   L2) — ma entro pochi minuti l'SSID ha smesso di essere trasmesso dai
   tre AP, confermato con due dispositivi diversi. Rollback immediato
   (`-VlanId 1 -Apply`) e servizio Wi-Fi confermato tornato. Dettaglio
   completo, ipotesi di causa e conseguenze per la roadmap in
   `runbook-anomalie.md` §NET-005 "Incidente 16/07/2026". La configurazione
   di questo file (passi 1-2) resta applicata e valida per un nuovo
   tentativo.
4. Da rifare con procedura piu' prudente (presenza fisica a un AP alla
   volta, finestra di osservazione piu' lunga, eventuale power-cycle
   manuale) oppure con un meccanismo che non tocchi il PVID della porta AP
   (es. `Layer 2 Isolation` del firewall, non ancora esplorato) prima di
   poter completare i passi seguenti.
5. Verificare che un client sulla Wi-Fi raggiunga Internet ma non un host
   noto della LAN1 (es. non risponda a un ping verso 10.61.10.1).
6. Aggiornare `network-diagram.md`, `GAP-TBC.md` (NET-005) e la timeline;
   registrare il commit come singolo micro-step (M13a) secondo
   `.claude/rules/git-commands-format.md`.

Nota di sicurezza residua (non risolta da questo intervento, vedi
`runbook-anomalie.md` §NET-005 "Correzioni emerse eseguendo Fase A"):
`allowedVLAN: "all"` universale su ogni porta e' un limite di postura L2
preesistente su tutta la rete, non solo sul perimetro Wi-Fi — irrigidirlo
ovunque e' un hardening a parte, non bloccante per M13a.

### Perche' non un'API per il firewall

Verificato il 15/07/2026 (due fetch della documentazione ufficiale Nebula
OpenAPI + controllo dell'inventario dispositivi in `output/nebula-config.md`):
questo firewall non e' adottato in Nebula (solo i due switch compaiono come
dispositivi dell'organizzazione) e gira in modalita' standalone ZLD classica,
senza alcuna API REST nello stato attuale. L'unico canale scriptabile
esistente e' l'SSH amministrativo gia' attivo (riga precedente, 2FA Google
Authenticator, validita' 5 minuti): richiede un umano per il secondo fattore
a ogni sessione, quindi non e' automatizzabile end-to-end come lo script
Nebula. Da qui la scelta di un piano scritto passo-passo invece di uno script
che si autentica e scrive da solo (ADR-010).

### Sequenza di applicazione: le sei fasi (LE SEI FASI.txt, 05/06/2026)

Il piano operativo (`Piano_Operativo_Migrazione.docx`) organizza l'applicazione
in sei fasi numerate da 0, ciascuna con un proprio punto di ritorno esplicito:
se una fase fallisce la verifica, si torna allo stato precedente invece di
proseguire alla successiva.

**Fase 0 - Correzione immediata.** Chiude subito la falla della regola phishing
via GUI, senza attendere la finestra di manutenzione notturna: e' l'unica fase
che non richiede downtime ne' preparazione.

**Fase 1 - Preparazione.** Backup datato di firewall e switch, verifica fisica
di console seriale (115200 baud) e accesso iLO, conferma del prerequisito non
ancora validato che lo switch XGS2220-54HP supporti 802.1Q, pianificazione
della finestra notturna.

**Fasi 2 e 3 - Switch e bridge Proxmox.** VLAN 201 sullo switch (porta P7 in
access, porta verso Proxmox in trunk) e bridge-vlan-aware su Proxmox (da
console iLO, con `ifreload -a`): a impatto nullo sulla produzione, perche' il
cavo fisico non e' ancora spostato e nessuna VM ha ancora il tag 201.

**Fase 4 - Cablaggio e validazione L2.** Posa del cavo da P7 allo switch e
verifica della catena con `arping`/`tcpdump` prima di toccare la configurazione
del firewall: un ping ordinario puo' legittimamente non rispondere in questo
momento, perche' le policy DMZ non sono ancora caricate.

**Fase 5 - Applicazione dal seriale.** Caricamento della configurazione
aggiornata con doppia rete di protezione: lo startup-config precedente resta
intatto finche' la verifica non e' conclusa, e un meccanismo di `lastgood`
automatico lato firewall interviene se il caricamento produce una
configurazione non raggiungibile.
   ```
   Router# apply /conf/startup-config-2026-06.conf
   # solo dopo verifica completa:
   Router# copy running-config startup-config
   ```
   Effetti previsti durante il caricamento: caduta sessioni VPN, shutdown wan2.

**Fase 6 - Verifica e chiusura.** Verifica nell'ordine in cui gli utenti se ne
accorgerebbero: prima la navigazione LAN, poi la SSL VPN, poi il tunnel IPsec,
infine il raggiungimento della VM DMZ (che deve uscire su Internet e *non*
raggiungere la LAN: un allarme in log su questo tentativo e' la conferma che
la segregazione funziona). Consolidamento con 48 ore di osservazione log e
chiusura con le pulizie fisiche del cablaggio provvisorio.

**Stato: fasi 0-6 non ancora eseguite sul dispositivo fisico** (verificato con
l'utente il 01/07/2026). Il file di configurazione datato 05/06/2026 e' il
target preparato per la Fase 5, non un log di quanto gia' applicato.

---

## Diagrammi

Diagrammi prodotti durante l'analisi del 29/05-05/06/2026, archiviati in
`.claude/context/diagrams/firewall-dmz-2026/` (risolve FW-010).

| File | Data | Contenuto |
|------|------|-----------|
| `zyxel_usg_flex500_network_29052026.drawio` | 29/05/2026 | Schema di rete generale del firewall, stato rilevato dal backup del 19/05 |
| `zyxel_usg_flex500_detailed_29052026.drawio` | 29/05/2026 | Schema dettagliato interfacce/VPN/NAT del firewall |
| `rete_stato_attuale_29052026.drawio` | 29/05/2026 | Topologia di rete completa, stato attuale pre-intervento |
| `dmz_con_trunk.svg` / `dmz_senza_trunk.svg` | 29/05/2026 | Confronto architetturale trunk 802.1Q vs cavo dedicato per la DMZ Proxmox |
| `zyxel_usg_flex500_network_target_05062026.drawio` | 05/06/2026 | Schema di rete del firewall nello stato target post-revisione |
| `rete_stato_target_05062026.drawio` | 05/06/2026 | Topologia di rete completa nello stato target |
| `topologia_stella_lan_dmz_proxmox_05062026.svg` | 05/06/2026 | Topologia a stella LAN/DMZ/Proxmox del piano finale |
| `rete_stato_target_08072026.drawio` | 08/07/2026 | Revisione dello stato target: secondo trunk 802.1Q tra lo switch 30 porte (Piano Terra) e il 54 porte (Piano 2) che porta la VLAN dati del Piano Terra e la VLAN fonia (ID fissato a 100 dal diagramma fonia sotto; aperti NET-008 e TEL-002) |
| `rete_fonia_voip_08072026_2.drawio-claudio.drawio` | 08/07/2026 | Target fonia VoIP (prodotto dall'utente): VLAN 100 fonia (10.61.100.0/24), interfaccia VLAN 100 su ge5 del FLEX 500 con zona VOICE, DHCP sul firewall e SIP ALG disattivato; trunk VLAN 1 untagged + VLAN 100 tagged su entrambi gli switch e sulla fibra di dorsale; porte telefoni access PVID 100 con PoE priority High (3 al Piano 2, 2 al Piano Terra); PBX cloud, telefoni in uscita via WAN; ordine di implementazione in cinque step (1-2 hitless). Nota: i modelli sono etichettati GS2220-50HP/28HP, altrove documentati come XGS2220-54HP/30HP — refuso probabile. Rispetto allo stato attuale (FW-012: DHCP fonia Vianova isolato dal firewall) questo target sposta DHCP e policy della fonia sul firewall: converge con M11/M12. **Annotato 17/07/2026 come non applicato**: la fonia realmente implementata resta su VLAN 2 con DHCP Vianova sulla porta 8 del 54HP, non su VLAN 100/firewall |
| `rete_stato_attuale_17072026.drawio` | 17/07/2026 | Topologia corrente confermata dall'utente (corroborata da screenshot del pannello porte Nebula del 54HP): la dorsale Piano Terra <-> Piano 2 e' un trunk 802.1Q diretto tra i due switch XGS2220 (porta 52 del 54HP, VLAN dati PT untagged + VLAN 2 fonia tagged); il QNAP QSW-1208-8c non e' un hop intermedio, resta un ramo separato sulla porta 51 verso NAS fleet e le postazioni a 10 Gbps (invariato). Riporta anche gli aperti: porta 6 del 54HP con PVID 2 come la porta 8 ma ruolo non confermato, e i due telefoni IP del Piano Terra non visibili (TEL-002). Supera, per la sola parte di dorsale/QNAP, sia `rete_stato_attuale_29052026.drawio` sia `rete_stato_target_08072026.drawio` |

Nota: i diagrammi "target" descrivono lo stato pianificato: alcuni sono stati
nel frattempo confermati come applicati (la dorsale diretta PT<->P2 e il QNAP
come ramo separato, vedi `rete_stato_attuale_17072026.drawio`), altri restano
non applicati (il disegno VLAN 100/DHCP-su-firewall della fonia). Il
consolidamento in un unico diagramma Mermaid versionato in
`.claude/context/diagrams/network-topology.mmd` e' rimandato al termine della
fase di ottimizzazione, per non ricostruirlo a ogni singolo micro-intervento
(vedi `.claude/context/roadmap.md`).

---

## Utenti locali e gruppi VPN

24 utenti locali dichiarati nel file di configurazione. Credenziali in forma cifrata.
Gruppo vpn-users per l'accesso SSL VPN.
Accesso admin via Web UI e SSH con 2FA.

---

## Backup configurazione

Backup schedulato: generazione automatica alle 06:00 con invio via mail.
File: startup-config.conf. Percorso menu: Maintenance > File Manager > Configuration File.
Backup datato del 19/05/2026 usato come base per l'analisi del 29/05/2026.

---

## Anomalie e TBC aperti

| ID | Descrizione | Stato |
|----|-------------|-------|
| FW-001 | Regola Blocco_Gruppo_IP_Phishing_Elisa: action allow invece di deny | **Corretto 01/07/2026** (deny + log alert, IP_09_phishing_2026_Elisa/203.0.113.5 rimosso dal gruppo) |
| FW-002 | Regola malicious_IP_12052025: action allow invece di deny | **Corretto 01/07/2026** (deny, log gia' presente) |
| FW-003 | secure-policy 8/9/10 attive ma virtual server corrispondenti deactivate | Verificare intento |
| FW-004 | Rotte statiche dipendono da router downstream 10.61.100.1 non monitorato | Da rimuovere con dismissione LAN2 |
| FW-005 | Alias wan1 (.2/.3/.4/.254) in shutdown: verificare se alcuni servono ancora | Verificare |
| FW-006 | VPN IKEv1/AES-128/SHA-1/DH2 PSE-SEEWEB: parametri sotto best practice attuali | Da aggiornare |
| FW-007 | Presenza di due profili IPsec verso <IP-SEEWEB-PEER> (PSE-SEEWEB e WIZ_VPN) | Verificare se transizione in corso o residuo |
| FW-008 | WAN_TRUNK con wan2 primary ma TIM non connessa da maggio 2025 | Da rimuovere nella revisione |
| FW-009 | DMZ pool DHCP presente: incompatibile con server a IP statico | Da rimuovere nella revisione |
| FW-010 | File draw.io prodotti dal lavoro di analisi: zyxel_usg_flex500_network.drawio e zyxel_usg_flex500_detailed.drawio - localizzare e archiviare | Fatto (01/07/2026, `.claude/context/diagrams/firewall-dmz-2026/`) |
| FW-011 | Il piano di revisione a sei fasi (05/06/2026): Fase 0 applicata 01/07/2026 (FW-001/002 risolte), Fasi 1-6 non ancora eseguite: FW-004/008/009 restano aperte in produzione | Fasi 1-6 da applicare (prossima finestra di manutenzione) |
| FW-012 | Porta 8 dello switch 54HP (MAC AA:BB:CC:00:00:01) rinominata "Vianova DHCP server fonia" e passata a PVID 2 il 09/06/2026 | Funzione confermata (07/07/2026): DHCP+gateway della LAN telefoni forniti da Vianova, untagged su porta 8, isolati dal firewall per progetto; Vianova vi accede via VPN verso myOffice. Resta da valutare se sostituisce il DHCP classe .90 (M11) |
