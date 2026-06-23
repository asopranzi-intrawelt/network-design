# Runbook Anomalie di Rete e Sicurezza – Intrawelt

Runbook operativi per le anomalie documentate in GAP-TBC.md e VA 2025.
Ogni runbook segue lo stesso schema: Verifica → Impatto → Fix → Verifica post-fix.

---

## FW-001: Regola Blocco_Gruppo_IP_Phishing_Elisa con action=ALLOW

**Severity**: CRITICA  
**Origine**: VA Onova nov 2025, confermato analisi manuale  
**Stato**: APERTO

### Contesto
La regola di sicurezza perimetrale `Blocco_Gruppo_IP_Phishing_Elisa` esiste sulla USG FLEX 500 per bloccare un gruppo di IP associati a campagne phishing/spoofing verso Elisa/gruppo. L'azione è configurata come `ALLOW` invece di `DENY`, rendendo la regola completamente inoperante.

### Verifica pre-fix

```powershell
# 1. Verifica tramite CLI SSH al firewall (o export config XML)
#    Accedere alla Web GUI: https://192.168.20.1:443 (o IP mgmt FW)
#    Security Policy > Firewall Rules > cerca "Phishing_Elisa"
#    Verificare il campo Action (deve essere DROP o REJECT, non ALLOW)

# 2. Verifica export configurazione
#    Maintenance > Configuration > Export
#    Aprire XML e cercare:
#    <action>allow</action> dentro il blocco <name>Blocco_Gruppo_IP_Phishing_Elisa</name>
```

### Procedura fix

1. Accedere alla Web GUI USG FLEX 500 come Admin
2. Navigare: `Security Policy > Policy Control > IPv4 Rules`
3. Trovare la regola `Blocco_Gruppo_IP_Phishing_Elisa`
4. Cliccare Modifica (matita)
5. Campo `Action`: cambiare da `Allow` a `Deny`
6. Salvare e applicare
7. **Non** riavviare il firewall (cambio applicato in live)

**Alternativa CLI (SSH):**
```
configure
security-policy ipv4 name "Blocco_Gruppo_IP_Phishing_Elisa"
action deny
commit
exit
```

### Verifica post-fix

```powershell
# Testare da postazione interna che un IP del gruppo sia irraggiungibile:
# 1. Estrarre un IP dal gruppo "Gruppo_IP_Phishing_Elisa" dalla Web GUI
# 2. Da cmd/PS: Test-NetConnection -ComputerName <IP_dal_gruppo> -Port 80
#    Atteso: TCP connection timeout (non refused) = firewall droppat

# 3. Verificare log firewall che compaia DROP per quel gruppo
#    Monitor > Log > Firewall: filtrare per rule name phishing
```

### Rollback
Se la modifica blocca traffico legittimo (falso positivo), ripristinare `Action = Allow` e aprire ticket di analisi gruppo IP per revisionare la composizione del gruppo.

---

## FW-002: Switch management su VLAN Guest (192.168.90.37)

**Severity**: CRITICA  
**Origine**: VA Onova nov 2025  
**Stato**: APERTO

### Contesto
L'interfaccia di management dello switch (Zyxel XGS2220-54HP o XGS2220-30HP) è raggiungibile sull'IP 192.168.90.37, che appartiene alla VLAN 90 (Guest/IoT). Chiunque sulla VLAN Guest può raggiungere e tentare di amministrare lo switch.

### Verifica pre-fix

```powershell
# Da rete LAN (VLAN 20):
Test-NetConnection -ComputerName 192.168.90.37 -Port 443
# Se risponde: switch management esposto su VLAN guest

# Verifica accesso web: aprire browser su https://192.168.90.37
# Non deve essere raggiungibile dalla VLAN utenti (e tanto meno dalla VLAN guest)
```

### Procedura fix

1. Accedere allo switch via Nebula cloud portal (https://nebula.zyxel.com)
2. Selezionare il dispositivo switch
3. Navigare a `Configure > Switch > Management`
4. Cambiare `Management VLAN` da VLAN 90 a VLAN 10 (Management/Server)
5. Impostare `Management IP`: scegliere un IP in 192.168.10.0/24 (es. 192.168.10.10)
6. Applicare la configurazione via Nebula (zero-touch)

**In alternativa (accesso locale prima della modifica):**
- CLI locale: `ip management vlan 10 ip 192.168.10.10 mask 255.255.255.0`
- Aggiornare DNS/documentazione con il nuovo IP di management

**Regola firewall da aggiungere:**
- Source: VLAN 10 (192.168.10.0/24), Destination: 192.168.10.10, Port: 443/22 → ALLOW
- Source: qualsiasi altra VLAN, Destination: 192.168.10.10 → DENY

### Verifica post-fix

```powershell
# Da VLAN Guest (o test simulato):
Test-NetConnection -ComputerName 192.168.10.10 -Port 443
# Atteso: timeout/reset (firewall blocca)

# Da VLAN management (192.168.10.x):
Test-NetConnection -ComputerName 192.168.10.10 -Port 443
# Atteso: risposta (OK)
```

---

## FW-003: DMZ VLAN 201 – Setup e isolamento

**Severity**: MEDIA (pianificato, non urgente)  
**Origine**: Design review, raccomandazione VA  
**Stato**: PIANIFICATO – Q3 2026

### Contesto
Non esiste un segmento DMZ fisico o logico. I server pubblici (se esistenti) o i servizi esposti risiedono nella stessa VLAN utenti/server. La VLAN 201 è pianificata come DMZ per isolare servizi pubblicati da internet.

### Architettura target

```
Internet → Firewall (NAT/policy) → VLAN 201 (DMZ: 192.168.201.0/24)
                                              ↓ solo policy esplicite
                                      VLAN 20 (LAN interna)
```

### Procedura di setup VLAN 201

**Fase 1 – Firewall USG FLEX 500**

1. GUI: `Network > Interface > Add`
   - Name: `dmz201`
   - Type: VLAN
   - VLAN ID: 201
   - Parent: `lan1` (bridge P4/P5/P6)
   - IP/Mask: 192.168.201.1/24
   - DHCP: Server (pool 192.168.201.10-100)
   - Zone: DMZ (creare zona se non esiste)

2. Regole firewall da aggiungere:
   - `WAN → DMZ`: DENY di default, ALLOW solo porte pubblicate (80, 443)
   - `DMZ → LAN`: DENY di default, ALLOW solo connessioni necessarie (es. DB specifico)
   - `LAN → DMZ`: ALLOW per management (porta 22/443 da VLAN 10 solo)
   - `DMZ → WAN`: ALLOW (per aggiornamenti) con log

**Fase 2 – Switch XGS2220-54HP**

Via Nebula:
1. Creare VLAN 201
2. Impostare la porta verso il server DMZ come `untagged VLAN 201`
3. La porta verso il firewall (porta 33) resta trunk (tutte le VLAN tagged)

**Fase 3 – Proxmox (se VM in DMZ)**

1. Abilitare `bridge-vlan-aware` su `vmbr0`:
   ```
   # /etc/network/interfaces su host Proxmox
   bridge-vlan-aware yes
   bridge-vids 2-4094
   ```
2. Alla VM in DMZ: assegnare interface con `vlan tag = 201`
3. La VM riceverà IP da DHCP VLAN 201 (192.168.201.x)

### Verifica

```powershell
# Da VM in DMZ: verificare routing e isolamento
# Ping verso LAN (192.168.20.1) deve essere bloccato dal firewall
# Ping verso internet deve funzionare (se regola lo permette)
Test-NetConnection -ComputerName 192.168.20.1 -Port 80
# Atteso: timeout (firewall DMZ→LAN deny)
```

---

## FW-004: Rimozione configurazione WAN_TRUNK residua (TIM dismessa)

**Severity**: BASSA  
**Origine**: Analisi post-migrazione Vianova  
**Stato**: APERTO

### Contesto
Dopo la dismissione completa della connettività TIM (luglio 2025), rimangono configurazioni residue nel firewall (WRR load balancing, oggetti TIM) che potrebbero causare confusione e route incorrette in caso di ripristino errato.

### Procedura fix

1. GUI: `Network > Interface`: verificare che WAN2 non sia più configurata con IP TIM
2. `Network > Policy Route`: rimuovere eventuali regole che referenziano l'interfaccia TIM/WAN_TRUNK
3. `Network > Trunk`: rimuovere o disabilitare WAN_TRUNK se esiste
4. `Object > Address`: eliminare oggetti address con IP TIM pubblici
5. Eseguire backup configurazione prima di ogni modifica

---

## AP-001: Access Point con Debian 7 (EOL) – 0-9-1 tetto

**Severity**: ALTA  
**Origine**: VA Onova nov 2025  
**Stato**: APERTO

### Contesto
L'AP sul tetto (identificatore 0-9-1) è gestito con firmware basato su Debian 7 (EOL dal 2018). Non riceve aggiornamenti di sicurezza. Vulnerabile a exploit noti (CVE multipli su Debian 7).

### Procedura fix

1. Verificare modello esatto AP: login SSH sull'AP o verifica Nebula
2. Cercare se esiste firmware aggiornato da Zyxel per quel modello
3. Se aggiornamento disponibile: aggiornare via Nebula (OTA) o manuale
4. Se il dispositivo non supporta firmware aggiornato: pianificare sostituzione
5. Nel frattempo: isolare l'AP in VLAN guest-only, senza accesso a VLAN management

### Verifica

```powershell
# Dopo aggiornamento firmware:
# Nebula > Dispositivo > Firmware version: verificare versione aggiornata
# Oppure SSH all'AP: cat /etc/os-release
```

---

## UPS-001: UPS Emerson Liebert su VLAN Guest

**Severity**: ALTA  
**Origine**: VA Onova nov 2025  
**Stato**: APERTO

### Contesto
L'UPS (Emerson Liebert IntelliSlot, IP 192.168.90.33, porta gestione 6004) è sulla VLAN Guest. Un attaccante sulla rete WiFi guest potrebbe raggiungere la console di gestione UPS e causare shutdown non autorizzato dell'infrastruttura.

### Procedura fix

1. Spostare l'interfaccia di rete del modulo IntelliSlot su VLAN 10 (Management)
2. Assegnare IP in 192.168.10.0/24 (es. 192.168.10.20)
3. Aggiornare regole firewall: solo VLAN 10 può raggiungere l'UPS
4. Testare notifiche SNMP/mail dell'UPS dopo la modifica

---

*Runbook aggiornato: giugno 2026. Owner: Alessio Sopranzi.*
