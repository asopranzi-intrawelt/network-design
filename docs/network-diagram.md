# Diagramma di rete Intrawelt - Via Pescolla 2A

Fonte: Analisi_Zyxel_USG_FLEX_500.docx, ARCHITETTURA SERVER-CLOUD-LINEE 20052026.docx,
       interventi 29052026.docx, mappatura porte fisiche.xlsx.
Aggiornato: maggio 2026. Stato: post installazione XGS2220-30HP (08/05/2026).

---

## Topologia generale

```
INTERNET
   |
   +-- Vianova FTTO 1 Gbps (WAN1) ─ media converter TIM ─ Router Vianova R-1000 x2 (HSRP)
   |   IP pubblico pool: 203.0.113.x/28 (14 IP utilizzabili)
   |
   +-- Ponte Radio 100/20 Mbps (WAN2) ─ backup automatico
       [TIM ADSL dismessa fisicamente mag 2025, contratto cessato lug 2025]

               │ wan1 (primary) + wan2 (backup)
               ▼
   ┌──────────────────────────────────────────────────────────────────┐
   │  Zyxel USG FLEX 500                                              │
   │  P1  = wan1 (Vianova FTTO)                                       │
   │  P2  = wan2 (ponte radio)                                        │
   │  P3  = opt (non usata)                                           │
   │  P4+P5+P6 = bridge L2 → lan1 → Switch Piano 2 (P4 attiva)       │
   │                                                                  │
   │  VPN attive:                                                     │
   │    PSE-SEEWEB   IKEv1 aggressive  peer 37.9.228.x               │
   │    RemoteAccess IKEv2             pool 10.61.50.0/27           │
   │    SSL VPN 443                    pool 10.61.230.10-250        │
   │                                                                  │
   │  UTM: BPP + CIP, SSL inspection, sandbox, IP reputation HIGH     │
   │  CRITICAL FW-001: Blocco_Gruppo_IP_Phishing_Elisa action=ALLOW   │
   └──────────────────────────────────────────────────────────────────┘
               │ 1 Gbps copper (collo di bottiglia vs backbone 10G)
               │ P4 → porta 33 switch Piano 2
               ▼
   ┌──────────────────────────────────────────────────────────────┐
   │  Switch Piano 2 – Zyxel XGS2220-54HP  (Nebula managed)        │
   │  10.61.20.x/24 management, VLAN trunk: tutte le VLAN ammesse  │
   │  Porta 33 = uplink firewall (1G copper)                       │
   │  Porta 52 = SFP+ 10G, dorsale diretta -> Switch Piano Terra   │
   │  Porta 51 = SFP+ 10G, verso QNAP QSW-1208-8c (ramo separato)  │
   │  Porta 8  = Vianova DHCP+gateway fonia, PVID 2 (FW-012)       │
   │  Porta 6  = PVID 2 come porta 8, ruolo da chiarire (aperto)   │
   └──────────────────────────────────────────────────────────────┘
          │                                    │
          │ Porta 52: dorsale diretta,          │ Porta 51: ramo separato,
          │ trunk VLAN dati PT untagged         │ non piu' inline sulla dorsale
          │ + VLAN 2 fonia tagged               │
          │ (confermato 17/07/2026)             │
          ▼                                    ▼
   ┌─────────────────────────┐        ┌───────────────────────────┐
   │ Switch Piano Terra       │        │  QNAP QSW-1208-8c          │
   │ XGS2220-30HP (apr 2026)  │        │  (unmanaged, 10 GbE)        │
   │ PoE+ 400W                │        └──────────┬──────────┬─────┘
   │ 0-7-1 AP PT              │                   │          │
   │ 0-9-1 AP tetto           │                   ▼          ▼
   │ 0-10-1 BioStar .20.199   │         ┌───────────────┐ ┌──────────────────┐
   │ Piano 0 utenti           │         │  NAS Fleet     │ │ Server / Proxmox │
   │ 2× telefoni IP: non      │         │  10.61.20.x    │ │ 10.61.20.11      │
   │ visibili (TEL-002)       │         │  HERO   .169   │ │ HP G5 (Proxmox)  │
   └─────────────────────────┘         │  INTRA  .168   │ │ HP G9 (spento)   │
                                        │  INTRA2 .177   │ │ WINGROUPSHARE .3 │
                                        │  (10GbE)       │ │ (GroupShare)     │
                                        │  INTRA3 .172   │ │ VM Seeweb IaaS   │
                                        │  DOC    .170   │ │ domv.intrawelt.com│
                                        └───────────────┘ └──────────────────┘

   Piano 1 (AP 1-8-1, postazioni Persona-A/Persona-B/Alessio)
   Piano 2 (AP 2-5-1 CED, AP 2-7-1 tetto esterno)

   Yealink IP phones (Voice VLAN 2, LLDP-MED, CoS 5 / DSCP 46):
     T34W Piano Terra: Persona-A 1-1, Persona-B 1-2, Persona-C 0-x (operativi)
     T31G Piano 2:     Persona-D 2-x, Sala-1 2-x (operativi)
     2× IP Piano Terra: non visibili, causa non isolata (TEL-002)
     PBX cloud Vianova [TBC: transizione in corso]
```

Nota fisica confermata dall'utente il 17/07/2026, corroborata da uno screenshot del
pannello porte Nebula del 54HP (porta 33 con icona uplink, porte 3/5/44 con icona PoE,
porte 51 e 52 a 10 Gbps): il QNAP QSW-1208-8c non e' un hop intermedio sulla dorsale.
Dalla porta 51 dello switch Piano 2 parte un ramo a 10 Gbps dedicato verso il QNAP, che
aggrega NAS fleet e le postazioni ad alta velocita' senza toccare il traffico dati/fonia
diretto verso il Piano Terra sulla porta 52. Il pannello d'insieme di Nebula non mostra
il PVID di ciascuna porta, quindi il ruolo della porta 6 (che condivide il PVID 2 con la
porta 8 Vianova) resta da chiarire con una vista di dettaglio della porta stessa.

---

## Segmentazione VLAN

| VLAN | ID | Subnet | Scopo | Note |
|------|-----|--------|-------|------|
| Management/Server | 10 | 10.61.10.0/24 | Infrastruttura IT | Switch, AP, server |
| Utenti LAN | 20 | 10.61.20.0/24 | Postazioni, NAS, Proxmox | Default LAN |
| [TBC] | 30 | 10.61.30.0/24 | [TBC] | |
| Guest | 90 | 10.61.90.0/24 | Ospiti, dispositivi IoT | [ANOMALIA: switch mgmt qui] |
| Voice | 2 | - | VoIP Yealink LLDP-MED | CoS 5, DSCP EF |
| Fonia (target) | 100 | 10.61.100.0/24 | Telefoni IP centralino cloud | Target 08/07/2026: zona VOICE su FLEX 500 (interfaccia ge5, gw .1), DHCP sul firewall, SIP ALG off. Non ancora applicato |
| DMZ | 201 | [TBC] | Segmento DMZ pianificato | VLAN 802.1Q su Proxmox bridge-vlan-aware |

Aggiornamento confermato il 17/07/2026: il secondo collegamento in trunk
802.1Q tra lo switch 30 porte del Piano Terra e il 54 porte del Piano 2,
pianificato l'08/07/2026, e' oggi attivo (confermato dall'utente, corroborato
da screenshot del pannello porte Nebula). Porta la VLAN dati del Piano Terra
untagged e la VLAN 2 fonia tagged; l'ID VLAN fonia realmente in uso resta 2
(DHCP+gateway Vianova sulla porta 8 del 54HP, isolati dal firewall, FW-012),
non 100: il disegno alternativo a VLAN 100 con DHCP sul FLEX 500, nel
diagramma dell'utente `rete_fonia_voip_08072026_2.drawio-claudio.drawio`, non
e' quello implementato e resta storico. La topologia corrente e' in
`rete_stato_attuale_17072026.drawio` (`.claude/context/diagrams/firewall-dmz-2026/`),
che supera sia quel diagramma sia `rete_stato_target_08072026.drawio` per la
parte di dorsale/QNAP. Il QNAP QSW-1208-8c non e' un hop intermedio sulla
dorsale: resta un ramo a parte, sulla porta 51 del 54HP, verso NAS fleet e le
postazioni a 10 Gbps, invariato rispetto a prima.

Restano aperti NET-008 (VLAN 1 non taggabile sulla dorsale senza perdere il
NAS-HERO; l'ipotesi del native VLAN mismatch causato dal QNAP inline decade
ora che la dorsale e' un trunk diretto, ma la causa resta da isolare), TEL-002
(i due telefoni IP del Piano Terra non risultano visibili nonostante il trunk
diretto, causa non isolata) e un nuovo punto aperto sulla porta 6 del 54HP
(PVID 2 come la porta 8, ruolo non confermato).

---

## VLAN Guest 90 - dispositivi anomali (da VA nov 2025)

| IP | Dispositivo | Criticita |
|----|-------------|-----------|
| 10.61.90.37 | Switch management | CRITICA: management su VLAN guest |
| 10.61.90.33 | UPS Emerson Liebert IntelliSlot | ALTA: gestione UPS esposta |
| 10.61.90.40 | MyHome Server (CentOS 7.6, EOL) | ALTA: OS EOL |
| 10.61.90.41 | Bticino Classe100X citofono | MEDIA: Linux 2.6 EOL |

---

## VPN e accessi remoti

| Tunnel | Protocollo | Endpoint remoto | Pool locale |
|--------|-----------|-----------------|-------------|
| PSE-SEEWEB | IKEv1 aggressive mode | 37.9.228.x (Seeweb) | - |
| RemoteAccess_Wiz | IKEv2 | - | 10.61.50.0/27 |
| SSL VPN | HTTPS/443 | - | 10.61.230.10-250 |

Virtual server VPN_UDP_500 e VPN_UDP_4500 attivi. 7 virtual server disattivati (disattivare quelli inutilizzati e documentare).

---

## Architettura DMZ pianificata (VLAN 201)

```
Firewall USG FLEX 500 (L3 only)
   │
   │ VLAN 201 tagged
   ▼
Switch XGS2220-54HP (802.1Q tagging)
   │
   │ VLAN 201 trunk
   ▼
Proxmox bridge-vlan-aware (vmbr0 + VLAN aware ON)
   │
   ├── VM Pubblica (VLAN 201, IP DMZ) ─ visibile da internet
   └── VM Interna (VLAN 20, IP LAN) ─ solo rete interna
```

Firewall gestisce routing/NAT tra DMZ e LAN. Il firewall rimane L3. Lo switch taglia VLAN 201 al Proxmox. Il bridge Proxmox separa le VM al livello L2 per VLAN.

---

## Connettivita cloud e VPN site-to-site

```
Intrawelt LAN (10.61.20.0/24)
   │
   │ IPsec PSE-SEEWEB (IKEv1, always-on)
   ▼
Seeweb IaaS (cloud VE)
   │
   ├── VM domv.intrawelt.com (siti web aziendali)
   └── VM altri servizi cloud
```

GroupShare: 10.77.116.3 (WINGROUPSHARE) - raggiungibile via LAN/VPN.

---

## Infrastruttura elettrica

UPS: alimentano server, NAS, centralino. Autonomia 15 min. Modello Emerson Liebert IntelliSlot Web Card (IP 10.61.90.33, porta 6004).
Fotovoltaico: mini-gruppo di continuita aggiuntivo (2025).
Cambiato gruppo di continuita: febbraio 2025.

---

## Gap e TBC topologici

| Gap | Descrizione |
|-----|-------------|
| Mappatura IP AP | Tutti gli AP (tetto, Piano 1, CED, esterno) hanno IP [TBC] |
| Switch mgmt VLAN | Switch 10.61.90.37 va spostato su VLAN management |
| WAN_TRUNK | Configurazione WRR ancora presente su firewall, da rimuovere (TIM dismessa); previsto nel piano di revisione del 05/06/2026, non ancora applicato |
| DMZ VLAN 201 | Architettura pianificata (piano del 05/06/2026, sei fasi), non ancora implementata |
| Patch panel | Mappatura patch panel -> porte switch Piano 2 non completata |
| Porta Persona-A (nuovo, 01/07/2026) | Screenshot del 09/06/2026 mostrano il telefono SIP-T34W di Persona-A etichettato sulla porta 3 di uno switch a 54 porte (MAC AA:BB:CC:00:00:01, compatibile solo con XGS2220-54HP Piano 2, confermato anche da app Nebula il 01/07/2026), ma sia questa scheda sia `interventi 29052026.docx` lo collocano su Piano Terra, switch XGS2220-30HP, porte 21/23. Probabile errore di etichettatura sulla porta 3 (che dovrebbe ospitare un T31G, non un T34W), da verificare con Alessio prima di consolidare la mappatura IP/MAC telefoni (GAP-TBC #67, #99) |
| Switch Nebula offline intermittente (nuovo, 01/07/2026) | Entrambi gli switch (XGS2220-54HP e XGS2220-30HP) risultano occasionalmente offline sul pannello Nebula con rete dati funzionante: sintomo del solo canale di gestione cloud, non dello switching locale. Ipotesi principale legata a FW-008 (WAN_TRUNK con wan2 morto ancora primario); vedi GAP-TBC #101 e roadmap M20/M21 |
| Porta 6 del 54HP (nuovo, 17/07/2026) | Ha PVID 2 come la porta 8 (Vianova DHCP fonia, FW-012), ma il ruolo non e' confermato: il pannello d'insieme di Nebula non mostra il PVID per porta, serve la vista di dettaglio della singola porta. Vedi GAP-TBC #102/#103 |

Diagrammi sorgente (drawio/svg) dell'analisi firewall/DMZ del 29/05-05/06/2026
sono archiviati in `.claude/context/diagrams/firewall-dmz-2026/` e registrati
nella tabella diagrammi di `docs/firewall-zyxel-usg-flex-500.md`. Il
consolidamento in un unico diagramma Mermaid aggiornato di questa topologia
e' rimandato alla fine della fase di ottimizzazione rete in corso (vedi
`.claude/context/roadmap.md`), per evitare di ricostruirlo a ogni micro-intervento.
