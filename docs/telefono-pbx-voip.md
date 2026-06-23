# Telefonia e PBX - Stato e migrazione Vianova

## Stato attuale (giugno 2026)

### Centralino fisico: Panasonic KX-NCP1000

Il centralino fisico Panasonic KX-NCP1000 e' installato in sede e gestisce la
telefonia interna. Il gateway SIP verso la linea Vianova e' il Patton SmartNode 5551.

Linee telefoniche Vianova attive fisicamente dal 17/04/2025, gestite attraverso
il contratto myOffice firmato il 18/12/2024 (6 canali voce, 984 euro/mese,
centralino cloud previsto).

### Terminali VoIP installati

Telefoni Yealink connessi alla rete:
- Alessandro Potalivo: SIP-T34W (Piano Terra, switch XGS2220-30HP)
- Sonia Martellini: SIP-T34W (Piano Terra)
- Martina Renzi: SIP-T34W (Piano Terra)
- Marsk Marini: SIP-T31G (Piano 2, switch XGS2220-54HP, porta 3 o 5 PoE)
- Sala Conero: SIP-T31G (Piano 2, switch XGS2220-54HP, porta 44 PoE)

[TBC: modello esatto, IP e MAC dei telefoni. Numero totale terminali da aggiornare.]

---

## Voice VLAN (configurazione giugno 2026)

### Scelta tecnica

Voice VLAN ID: **2**.
Metodo di assegnazione: **LLDP-MED** (Link Layer Discovery Protocol - Media Endpoint
Discovery, TIA-1057). Entrambi i modelli Yealink T31G e T34W supportano LLDP-MED.

LLDP-MED e' preferito a OUI perche':
- Bidirezionale: lo switch comunica attivamente al telefono la VLAN da usare.
- Non richiede manutenzione manuale della lista OUI.
- La negoziazione e' verificabile nei log dello switch.

### Priorita' e QoS

802.1p CoS (Class of Service): **5** (valore standard IEEE per voce RTP).
DSCP: **46** (EF - Expedited Forwarding, RFC 3246, standard voce).
[TBC: il default Nebula mostra DSCP 44 - verificare se e' stato modificato a 46.]

### Configurazione porte

**Porte telefoni (Piano Terra, XGS2220-30HP, porte 21 e 23):**
```
Type: Access
VLAN type: Voice VLAN (LLDP-MED)
PVID: 1  (traffico dati untagged sulla VLAN 1)
LLDP: Enabled
Mgmt VLAN control: Disabled
```

**Porte telefoni (Piano 2, XGS2220-54HP, porte 3, 5, 44 - contrassegnate con PoE):**
Stessa configurazione: Access, Voice VLAN, PVID 1, LLDP Enabled.

**Porta uplink fibra SFP+ tra i due switch:**
```
Type: Trunk
VLAN ammesse: VLAN dati (untagged) + VLAN 2 voce (tagged)
```

**Porte PC (tutte le restanti):**
```
Type: Access
VLAN type: None
PVID: 1
```
[TBC: 28 porte Piano Terra configurate via selezione multipla su Nebula - verificare
che la configurazione sia stata salvata.]

### Flusso LLDP-MED

Il telefono Yealink si connette alla porta Access. Lo switch invia via LLDP-MED
il Network Policy TLV con VLAN ID 2, CoS 5, DSCP 46. Il telefono registra la VLAN
e invia il traffico voce taggato VLAN 2. Il traffico PC che attraversa il telefono
(porta passante) resta untagged, assegnato al PVID 1.

---

## Porte SIP/RTP per centralino virtuale Vianova

Verifica del 23/03/2026 (mail myOffice/Vianova a.liberati@myofficegroup.it):
nessuno dei seguenti range e' bloccato dal firewall Zyxel USG FLEX 500 in uscita.
Verifica condotta su policy e log del 23/03/2026.

| Destinazione         | Protocollo | Porte           | Uso              |
|----------------------|-----------|-----------------|------------------|
| 185.158.118.128/26   | TCP       | 5061            | SIP              |
| 185.158.118.128/26   | UDP       | 20000-40000     | RTP (media)      |
| 103.26.124.0/24      | TCP       | 5039            | SIP alternativo  |
| 185.158.118.27       | TCP       | 433             | gestione         |
| 185.158.116.29       | TCP       | 5222            | XMPP/segnalazione|
| 94.138.161.187       | TCP/UDP   | 6050            | media            |
| 94.138.161.180/30    | TCP       | 14000-14999     | media            |
| 94.138.161.180/30    | UDP       | 15000-15999     | media            |

Risultato: nessun blocco esistente. La migrazione al centralino virtuale Vianova
non richiede modifiche alle security policy del firewall per il traffico in uscita.

Oggetti Address e Service creati nel firewall durante la verifica (23/03/2026):
SUBNET_185_158_118_128_26, SUBNET_103_26_124_0_24, HOST_185_158_118_27,
HOST_185_158_116_29, HOST_94_138_161_187, SUBNET_94_138_161_180_30
e i corrispondenti Service Objects TCP_5061, UDP_20000_40000, TCP_5039,
TCP_433, TCP_5222, TCP_6050, UDP_6050, TCP_14000_14999, UDP_15000_15999.

---

## Migrazione centralino cloud Vianova

### Stato (giugno 2026)

La migrazione al centralino cloud Vianova e' in corso. Il meeting con myOffice
e' avvenuto il 09/06/2026. [TBC: dettagli steps dal meeting 09/06/2026 - Alessio
ha screenshot nella cartella steps.]

### Prerequisiti verificati

- Linee Vianova attive da aprile 2025.
- Porte SIP/RTP non bloccate dal firewall (verifica 23/03/2026).
- Voice VLAN 2 configurata sugli switch (interventi 29/05/2026).
- Telefoni Yealink T31G e T34W supportano LLDP-MED e SIP.
- VPN Unmanaged Vianova attiva (prerequisito per IPsec, attivata 04/06/2025).

### Aperto

[TBC: piano di migrazione completo dal centralino fisico Panasonic KX-NCP1000
al centralino cloud. Routing interno, piano di numerazione, eventuali IVR,
deviazioni di chiamata, configurazione Patton SmartNode durante la transizione.]

---

## Procedure operative esistenti (Telefono-PBX folder)

Documenti disponibili per il centralino Panasonic KX-NCP1000:
- Centralino.doc: documentazione tecnica principale (CA client).
- procedura_deviazione_standard.docx: deviazione chiamate standard.
- procedura_deviazione_gruppo.docx: deviazione per gruppo di operatori.
- procedura_intercettare_chiamate_gruppo_operatori.docx: intercettazione chiamate.
- segreteria_personale.docx: configurazione segreteria personale.
- NuovoMessaggioCentralino.docx: procedura cambio messaggio centralino.
- x_avere_telefono_su_PC.docx: configurazione softphone su PC.

[TBC: verificare quali procedure restano valide con il centralino cloud Vianova
e quali diventano obsolete. Da aggiornare dopo la migrazione.]
