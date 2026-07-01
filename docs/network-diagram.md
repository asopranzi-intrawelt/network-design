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
   ┌────────────────────────────────────────────────────────────────────────┐
   │  Switch Piano 2 – Zyxel XGS2220-54HP  (Nebula managed)                │
   │  10.61.20.x/24 management                                            │
   │  VLAN trunk: tutte le VLAN ammesse                                     │
   │  Porta 33 = uplink firewall (1G copper)                                │
   │  Porta 52 = SFP+ 10G uplink → Switch Piano Terra                       │
   └────────────────────────────────────────────────────────────────────────┘
          │                    │                    │
          │ 10G SFP+           │ Gigabit            │ Gigabit
          ▼                    ▼                    ▼
   ┌─────────────┐   ┌─────────────────────┐   ┌──────────────────────────┐
   │ Switch       │   │  NAS Fleet           │   │  Server / Proxmox        │
   │ Piano Terra  │   │  10.61.20.x/24     │   │  10.61.20.11           │
   │ XGS2220-30HP │   │                      │   │                          │
   │ (apr 2026)   │   │  HERO   .169 QNAP    │   │  HP G5 (Proxmox host)    │
   │              │   │  INTRA  .168 QNAP    │   │  HP G9 (spento 19/12/24) │
   │ PoE+ 400W    │   │  INTRA2 .177 10GbE   │   │  WINGROUPSHARE .3        │
   │              │   │  INTRA3 .172         │   │  (10.77.116.3 GroupShare)  │
   │ 0-7-1 AP PT  │   │  DOC    .170 HPX1400 │   │                          │
   │ 0-9-1 AP tetto│  │                      │   │  VM Seeweb IaaS (cloud)   │
   │ 0-10-1 BioStar│  │  10G link INTRA2 ─── │   │  domv.intrawelt.com       │
   │    .20.199   │   │    ─ XGS2220-54HP     │   │                          │
   │              │   └─────────────────────┘   └──────────────────────────┘
   │ Piano 0 utenti│
   └─────────────┘

   Piano 1 (AP 1-8-1, postazioni Persona-A/Persona-B/Alessio)
   Piano 2 (AP 2-5-1 CED, AP 2-7-1 tetto esterno)

   Yealink IP phones (Voice VLAN 2, LLDP-MED, CoS 5 / DSCP 46):
     T34W Piano Terra: Persona-A 1-1, Persona-B 1-2, Persona-C 0-x
     T31G Piano 2:     Persona-D 2-x, Sala-1 2-x
     PBX cloud Vianova [TBC: transizione in corso]
```

---

## Segmentazione VLAN

| VLAN | ID | Subnet | Scopo | Note |
|------|-----|--------|-------|------|
| Management/Server | 10 | 10.61.10.0/24 | Infrastruttura IT | Switch, AP, server |
| Utenti LAN | 20 | 10.61.20.0/24 | Postazioni, NAS, Proxmox | Default LAN |
| [TBC] | 30 | 10.61.30.0/24 | [TBC] | |
| Guest | 90 | 10.61.90.0/24 | Ospiti, dispositivi IoT | [ANOMALIA: switch mgmt qui] |
| Voice | 2 | - | VoIP Yealink LLDP-MED | CoS 5, DSCP EF |
| DMZ | 201 | [TBC] | Segmento DMZ pianificato | VLAN 802.1Q su Proxmox bridge-vlan-aware |

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

Diagrammi sorgente (drawio/svg) dell'analisi firewall/DMZ del 29/05-05/06/2026
sono archiviati in `.claude/context/diagrams/firewall-dmz-2026/` e registrati
nella tabella diagrammi di `docs/firewall-zyxel-usg-flex-500.md`. Il
consolidamento in un unico diagramma Mermaid aggiornato di questa topologia
e' rimandato alla fine della fase di ottimizzazione rete in corso (vedi
`.claude/context/roadmap.md`), per evitare di ricostruirlo a ogni micro-intervento.
