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
- Persona-A: SIP-T34W (Piano Terra, switch XGS2220-30HP)
- Persona-B: SIP-T34W (Piano Terra)
- Persona-C: SIP-T34W (Piano Terra)
- Persona-D: SIP-T31G (Piano 2, switch XGS2220-54HP, porta 3 o 5 PoE)
- Sala-1: SIP-T31G (Piano 2, switch XGS2220-54HP, porta 44 PoE)

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

Verifica del 23/03/2026 (mail myOffice/Vianova referente-vianova-1@myofficegroup.it):
nessuno dei seguenti range e' bloccato dal firewall Zyxel USG FLEX 500 in uscita.
Verifica condotta su policy e log del 23/03/2026.

| Destinazione         | Protocollo | Porte           | Uso              |
|----------------------|-----------|-----------------|------------------|
| <RANGE-VIANOVA-SIP-1>   | TCP       | 5061            | SIP              |
| <RANGE-VIANOVA-SIP-1>   | UDP       | 20000-40000     | RTP (media)      |
| <RANGE-VIANOVA-SIP-2>      | TCP       | 5039            | SIP alternativo  |
| <IP-VIANOVA-MGMT>       | TCP       | 433             | gestione         |
| <IP-VIANOVA-SIP-3>       | TCP       | 5222            | XMPP/segnalazione|
| <IP-VIANOVA-MEDIA-1>       | TCP/UDP   | 6050            | media            |
| <RANGE-VIANOVA-MEDIA-2>    | TCP       | 14000-14999     | media            |
| <RANGE-VIANOVA-MEDIA-2>    | UDP       | 15000-15999     | media            |

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
e' avvenuto il 09/06/2026 (Referente-Vianova-1). Nella stessa giornata sono stati
eseguiti i primi passi operativi concreti, documentati dagli screenshot della
cartella `08062026 (steps)` e dalla mail `Messagistica centrale telefonica.eml`.

### Provisioning utente Area Clienti Vianova (09/06/2026)

Il portale di gestione del centralino cloud e' Area Clienti Vianova
(areaclienti.vianova.it). Alessio (asopranzi@intrawelt.com, profilo
Amministratore Area Clienti) ha creato un secondo utente, Persona-E
(reparto IT), profilo "Base", senza privilegi di amministratore Area Clienti
ne' di amministratore PBX Centrex. Procedura osservata:

1. Impostazioni > Utenti > Aggiungi: inserire nome, cognome, reparto, email.
2. Il sistema segnala se il dominio email e' esterno al cliente (caso Persona-E,
   dominio intrawelt.com diverso dal dominio Vianova): la password verra'
   impostata dall'utente stesso alla conferma dell'invito, non da chi crea
   l'account.
3. L'utente riceve una mail da Vianova (info@vianova.it) con un link di
   conferma valido 15 giorni.
4. Al primo accesso l'utente sceglie una password, indica un numero di
   cellulare per il 2FA via SMS ed eventualmente un indirizzo email
   alternativo per i codici.
5. Registrazione completata: l'utente accede da quel momento con le proprie
   credenziali.

E' stato inoltre scaricato l'installer di **Vianova One**
(`VianovaOneInstaller-1.4.0.6.exe`, versione 1.4.0.6), l'applicazione unificata
Vianova per chiamate, chat e videoconferenza inclusa nella licenza
Collaboration UC, disponibile per Windows/macOS/iOS/Android, per verificarne
il funzionamento su una seconda postazione.

### Riconfigurazione porte switch (09/06/2026)

Sullo switch Nebula con MAC `AA:BB:CC:00:00:01` sono state rinominate e
riconfigurate due porte: la porta 8 ("Vianova DHCP server fonia") e' passata
da PVID 1 a PVID 2 restando di tipo Voice VLAN; la porta 3 ("SIP-T34W
Persona-A") resta Voice VLAN con PVID 1. [TBC: il pannello Nebula di
questo switch mostra 54 porte, compatibili solo con lo XGS2220-54HP di Piano 2,
mentre `interventi 29052026.docx` (29/05/2026) descrive esplicitamente
un'assegnazione diversa e coerente con quanto gia' scritto sopra in questa
scheda: i tre T34W (Persona-A, Persona-B, Persona-C) sulle porte 21/23 dello
switch Piano Terra XGS2220-30HP, i due T31G (Persona-D, Sala-1) sulle porte
3/5/44 dello switch Piano 2 XGS2220-54HP con PoE. L'etichetta "SIP-T34W
Persona-A" sulla porta 3 del Piano 2, undici giorni dopo, e' quindi
piu' probabilmente un errore di etichettatura, forse per riferimento incrociato
con il modello di telefono sbagliato, che un reale spostamento fisico: da
verificare con Alessio prima di consolidare la mappatura IP/MAC/porta.]

### Messaggistica IVR - decisione aperta (09/06/2026)

myOffice (Referente-MyOffice-1, reparto Telefonia) ha richiesto via mail il
testo dei messaggi da caricare sulla centrale telefonica cloud:

Messaggio GIORNO, a scelta tra due modalita'. La prima e' un semplice
messaggio di attesa ("SIETE IN LINEA CON INTRAWELT, SIETE PREGATI DI
ATTENDERE, GRAZIE"), con eventuale sottofondo musicale royalty-free, in cui
squilla uno o piu' interni oppure prima la reception e poi, dopo 3-4 squilli,
altri interni. La seconda e' un IVR con instradamento per reparto ("SIETE IN
LINEA CON INTRAWELT, PREMERE 1 PER L'AMMINISTRAZIONE, PREMERE 2 PER IL
COMMERCIALE, ATTENDERE IN LINEA PER UN OPERATORE"), in cui la selezione fa
squillare un gruppo di interni distinto per reparto, e l'assenza di selezione
instrada al gruppo operatore generico.

Messaggio NOTTE, unico: comunica gli orari di apertura ("SIETE IN LINEA CON
INTRAWELT, I NOSTRI UFFICI SONO APERTI DAL LUNEDI' AL VENERDI' DALLE 9 ALLE 13
E DALLE 14 ALLE 17, GRAZIE PER AVER CHIAMATO"), con o senza squillo di un
interno prima del messaggio.

**Decisione ancora aperta al 01/07/2026**: non risulta una risposta di Alessio
a myOffice su quale modalita' adottare per il messaggio giorno (semplice
attesa o IVR con instradamento reparti) ne' sui dettagli del messaggio notte.

### Prerequisiti verificati

- Linee Vianova attive da aprile 2025.
- Porte SIP/RTP non bloccate dal firewall (verifica 23/03/2026).
- Voice VLAN 2 configurata sugli switch (interventi 29/05/2026).
- Telefoni Yealink T31G e T34W supportano LLDP-MED e SIP.
- VPN Unmanaged Vianova attiva (prerequisito per IPsec, attivata 04/06/2025).
- Provisioning utente Area Clienti e app Vianova One verificati (09/06/2026).

### Aperto

Piano di migrazione completo dal centralino fisico Panasonic KX-NCP1000 al
centralino cloud: routing interno, piano di numerazione, testo IVR (vedi
sopra, decisione pendente), deviazioni di chiamata, configurazione Patton
SmartNode durante la transizione. [TBC: nessuna di queste voci risulta ancora
formalizzata nei documenti disponibili al 01/07/2026.]

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
