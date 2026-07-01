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

**guest** (ge7/P8 nella config corrente - nota: l'etichetta "OPT" in zona):
10.61.90.1/24. DNS Google (8.8.8.8, 8.8.4.4). Zona ospiti.

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
a luglio 2025 da 5.98.88.x a 203.0.113.x).

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
- `DMZ_WEB_HTTPS`: wan1:2 (203.0.113.3) -> SRV-DMZ-WEB (10.61.201.10) porta 443.
- `DMZ_WEB_HTTP`: wan1:2 -> SRV-DMZ-WEB porta 80.

---

## Security policy

34 regole attive + default-deny (action deny log alert).
Organizzate per coppia di zone (sorgente, destinazione).

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

Nota: i diagrammi "target" descrivono lo stato pianificato, non ancora applicato
(vedi sezione precedente). Il consolidamento in un unico diagramma Mermaid
versionato in `.claude/context/diagrams/network-topology.mmd` e' rimandato al
termine della fase di ottimizzazione, per non ricostruirlo a ogni singolo
micro-intervento (vedi `.claude/context/roadmap.md`).

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
| FW-012 | Porta 8 dello switch 54HP (MAC AA:BB:CC:00:00:01) rinominata "Vianova DHCP server fonia" e passata a PVID 2 il 09/06/2026: verificare la funzione effettiva e se sostituisce il DHCP server classe .90 da rimuovere (vedi network-diagram.md) | Verificare |
