# Firewall Zyxel USG FLEX 500 - Configurazione e architettura

Fonte: backup startup-config.conf del 19/05/2026 (generato automaticamente alle 05:59:32).
Analisi condotta il 29/05/2026 (Analisi_Zyxel_USG_FLEX_500.docx).
Piano di revisione e DMZ prodotto il 05/06/2026 (Revisione_Rete_DMZ_Proxmox.docx,
Piano_Operativo_Migrazione.docx).
Firmware: Zyxel ZLD 5.42(ABUJ.1). File di 2215 righe.

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

**wan1** (P2): 193.124.241.5/28, gateway 193.124.241.1 (Vianova FTTO).
Alias definiti ma in stato shutdown: 193.124.241.2, .3, .4, .254.
L'alias wan1:2 (193.124.241.3) e' previsto per la DMZ web (vedi sezione DMZ).

**wan2** (P3): 31.197.194.218/29, gateway 31.197.194.217 (TIM, linea non piu' connessa
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

**lan1** (P4+P5+P6 bridge): 192.168.10.1/19.
Le tre sottoreti condividono lo stesso segmento broadcast fisico.
DHCP pool LAN1_POOL: 192.168.10.200, 55 assegnazioni, lease 2 giorni.
22 PC fissi dichiarati come address-object con IP statici (range 192.168.10.18-84).

**lan1:1** (subnet server): 192.168.20.1/19. 9 host nominati come address-object:
NAS FTP (.168), INTRA (.168), INTRA2 (.177), HERO (.169), EGETRAD, EGETRAD_TEST,
DOMV (.116), server demo, server OpenVPN.

**lan1:2** (subnet stampanti): 192.168.30.1/19.

**lan2**: interfaccia logica 192.168.200.x, nessuna porta fisica assegnata.
Raggiungibile solo via rotta statica attraverso router downstream 192.168.100.1
(non piu' presente). Prevista dismissione.

**dmz** (ge6/P7): 192.168.201.1/24. Pool DHCP presente nella config attuale
(prevista rimozione: server DMZ devono usare IP statici). Porta da cablare
verso lo switch per la nuova architettura DMZ.

**guest** (ge7/P8 nella config corrente - nota: l'etichetta "OPT" in zona):
192.168.90.1/24. DNS Google (8.8.8.8, 8.8.4.4). Zona ospiti.

---

## Rotte statiche

```
ip route 192.168.2.0/24    via 192.168.10.1    (ricorsiva via LAN1)
ip route 192.168.100.0/24  via 192.168.10.1    (ricorsiva via LAN1)
ip route 192.168.200.0/24  via 192.168.100.1   (router downstream)
```

**Anomalia**: le rotte dipendono da un router downstream 192.168.100.1 che non e'
monitorato dal firewall. Con il router assente (LAN2 dismessa) le rotte puntano
a un gateway inesistente. Prevista rimozione completa di tutte e tre le rotte
statiche nella revisione (la tabella si riduce alle reti direttamente connesse
piu' la rotta di default verso wan1).

---

## VPN

### Tunnel IPsec site-to-site verso SEEWEB

Due profili verso lo stesso peer 37.9.228.27 (infrastruttura SEEWEB):

**PSE-SEEWEB**: IKEv1 modalita' aggressive, PSK, AES-128/SHA-1/DH2, lifetime 24h,
DPD 30s. Local-policy: RFC1918_3 (192.168.0.0/16). Remote-policy: 10.1.116.0/24.
PFS gruppo DH2.

**WIZ_VPN**: IKEv1 modalita' main, stessi parametri di cifratura.

Nota: AES-128/SHA-1/DH2 sono il minimo accettabile. Gruppo DH2 considerato obsoleto.
La presenza di due profili verso lo stesso peer indica transizione in corso o
configurazione ridondante.

### VPN remote-access IKEv2

**RemoteAccess_Wiz**: IKEv2 server, autenticazione RSA + EAP/MSCHAPv2.
Certificato: RemoteAccess_193.124.241.5. AES-128/SHA-256, gruppi DH 2/14/21.
Pool client: 192.168.50.0/27. DNS push: 192.168.10.1. Zona dedicata: VPN_To_WAN_SNAT.
Traffico client: 0.0.0.0/0 (tutto attraverso il tunnel).

### SSL VPN

**ssl_vpn_intrawelt**: porta TCP 443, TLS. Gruppo utenti: vpn-users.
Reti raggiungibili dai client: 192.168.10.0/19, 192.168.20.0/19,
192.168.30.0/19, 10.1.116.0/24.
Pool client: 192.168.230.10-250.
Filtro geografico: solo Italia e USA (regole 5 e 6 della security policy).

### 2FA

Google Authenticator (TOTP). Canale alternativo: email o SMS. Validita' codice: 5 minuti.
Attivo su: SSL VPN, accesso admin via SSH e Web UI, accesso NAS (URL aggiornato
a luglio 2025 da 5.98.88.x a 193.124.241.x).

---

## NAT e virtual server

10 dichiarazioni totali. 3 attive, 7 deactivate.

**Attive:**
- `Subnet_nat`: NAT 1-a-1 tra LAN1_SUBNET e RFC1918_3.
- `VPN_UDP_500`: port forwarding UDP 500 (IKE) su wan1 verso il firewall stesso.
- `VPN_UDP_4500`: port forwarding UDP 4500 (NAT-T) su wan1 verso il firewall stesso.

**Deactivate (storiche):**
DOMV_WEB, NAS_FTP_WEB, NAS_HERO_SUPPORT, EGETRAD_WEB, DEMO_SERVER_WEB, OpenVpn,
VPN_auth_LAN2.

**Disallineamento**: le secure-policy 8, 9, 10 (DOMV_WEB, DEMO_SERVER_WEB,
EGETRAD_WEB) sono attive ma i corrispondenti virtual server sono deactivate.
Le regole di firewall non producono traffico senza il NAT in ingresso.
Per riattivare la pubblicazione basta togliere `deactivate` dal virtual server;
se la pubblicazione non e' desiderata, disattivare anche le secure-policy.

**Pianificato (revisione 05/06/2026):**
- `DMZ_WEB_HTTPS`: wan1:2 (193.124.241.3) -> SRV-DMZ-WEB (192.168.201.10) porta 443.
- `DMZ_WEB_HTTP`: wan1:2 -> SRV-DMZ-WEB porta 80.

---

## Security policy

34 regole attive + default-deny (action deny log alert).
Organizzate per coppia di zone (sorgente, destinazione).

**Regola 1 - Anomalia critica**: `Blocco_Gruppo_IP_Phishing_Elisa`
- Sorgente: WAN. Action: **allow** (dovrebbe essere deny).
- Contiene 11 IP raccolti dall'incidente phishing 08/01/2026.
- Includeva anche 193.124.241.5 (IP pubblico del firewall stesso, rimosso).
- Poiche' e' la prima regola e il motore si ferma alla prima corrispondenza,
  quegli IP scavalcano tutti i controlli successivi.
- **Fix immediato**: cambiare action in deny, aggiungere log alert,
  rimuovere 193.124.241.5 dal gruppo Bad_IP_Phishing_Elisa_2026.

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
- VM senza tag: traffico LAN, IP 192.168.20.x, gateway 192.168.20.1.
- VM con tag 201: traffico DMZ, IP 192.168.201.x, gateway 192.168.201.1.
- Il bridge mantiene i due domini L2 separati anche tra VM sullo stesso host fisico.

**Firewall - interfaccia dmz** (config aggiornata):
```
interface dmz
  ip address 192.168.201.1 255.255.255.0
  type internal
  mtu 1500
  ! nessun ip dhcp-pool: indirizzamento statico
```

**Prima VM DMZ**: nginx reverse proxy a 192.168.201.10, esposto su wan1:2 (193.124.241.3).

### Sequenza di applicazione

1. Correzione immediata regola phishing (fuori finestra, subito).
2. Preparazione: backup datato firewall/switch, test console seriale (115200 baud)
   e sessione iLO, verifica 802.1Q su XGS2220-54HP, pianificazione finestra notturna.
3. Switch: VLAN 201, porta P7 in access, porta Proxmox in trunk.
4. Proxmox: bridge-vlan-aware da console iLO, VM di test con tag 201.
5. Cablaggio P7 -> switch, verifica L2 con arping (il ping puo' non rispondere
   finche' le policy DMZ non sono caricate: normale).
6. Caricamento startup-config aggiornato da console seriale:
   ```
   Router# apply /conf/startup-config-2026-06.conf
   # solo dopo verifica completa:
   Router# copy running-config startup-config
   ```
   Effetti previsti durante il caricamento: caduta sessioni VPN, shutdown wan2.
7. Verifica: LAN naviga, SSL VPN risponde, tunnel IPsec si rinuncia,
   VM DMZ raggiunge Internet e non raggiunge LAN (allarme in log = conferma).
8. 48h di osservazione log.

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
| FW-001 | Regola Blocco_Gruppo_IP_Phishing_Elisa: action allow invece di deny | Da correggere (urgente) |
| FW-002 | Regola malicious_IP_12052025: action allow invece di deny | Da correggere |
| FW-003 | secure-policy 8/9/10 attive ma virtual server corrispondenti deactivate | Verificare intento |
| FW-004 | Rotte statiche dipendono da router downstream 192.168.100.1 non monitorato | Da rimuovere con dismissione LAN2 |
| FW-005 | Alias wan1 (.2/.3/.4/.254) in shutdown: verificare se alcuni servono ancora | Verificare |
| FW-006 | VPN IKEv1/AES-128/SHA-1/DH2 PSE-SEEWEB: parametri sotto best practice attuali | Da aggiornare |
| FW-007 | Presenza di due profili IPsec verso 37.9.228.27 (PSE-SEEWEB e WIZ_VPN) | Verificare se transizione in corso o residuo |
| FW-008 | WAN_TRUNK con wan2 primary ma TIM non connessa da maggio 2025 | Da rimuovere nella revisione |
| FW-009 | DMZ pool DHCP presente: incompatibile con server a IP statico | Da rimuovere nella revisione |
| FW-010 | File draw.io prodotti dal lavoro di analisi: zyxel_usg_flex500_network.drawio e zyxel_usg_flex500_detailed.drawio - localizzare e archiviare | Da fare |
