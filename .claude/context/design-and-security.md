---
last-verified: 347f79c
---

# Design e sicurezza della rete — angolo ISO27001

## Paradigma architetturale

La rete Intrawelt usa una segmentazione L2 tramite Linux bridge di Proxmox. Ogni bridge
corrisponde a una porta fisica del BCM5719 quad-port e definisce un segmento di rete
logicamente separato. La segmentazione attuale e' fisica (bridge separati) ma non e'
supportata da firewall attivi o VLAN tagging.

## Nodo pve (snapshot v4, 08/07/2026)

| Parametro | Valore |
|---|---|
| CPU | 48 core, 2x Xeon Gold 6126 |
| RAM | 125.4 GB totali (upgrade dei 64 GB ordinati il 14/11/2025 confermato in campo), 92.2 GB usati |
| PVE | 8.3.4, kernel 6.8.12-8-pve |
| Cluster | "Intrawelt", nodo singolo |

Anomalia da chiarire: lo stato cluster riporta come IP del nodo 10.61.1.71,
che coincide con l'indirizzo documentato della iLO5, mentre vmbr0 e'
10.61.20.11/19 (gap #108).

## Segmenti di rete documentati (snapshot v4)

| Bridge | Porta | Subnet | Scopo |
|---|---|---|---|
| vmbr0 | eno1 | 10.61.20.11/19 (LAN unica /19) | Rete principale servizi (VM100/202/810 e, dal 21/07/2026, VM208) |
| vmbr1 | eno2 | — | Seconda NIC VM100 WinServer2022 |
| vmbr2 | eno3 | — | Intrasite (VM206) |
| vmbr3 | eno4 | — | Servizi separati (VM203/204/205/207/602) |

Nessun bridge e' VLAN-aware (la configurazione target di M5 non e' ancora
applicata). Lo snapshot v4 conferma che la LAN e' una /19, non una /24: le
"classi" .10/.20/.30/.90 sono convenzioni di piano di indirizzamento dentro
un unico dominio L2/L3.

## Inventario VM (snapshot v4 dell'08/07/2026, riconciliato live il 27/07/2026)

| VMID | Nome | Stato | Bridge(s) | IP | Note |
|---|---|---|---|---|---|
| VM100 | WinServer2022 | running | vmbr0+vmbr1 | .12/.13 | 64 GB RAM (meta' del nodo), doppia NIC |
| VM202 | PasswordManager | running | vmbr0 | .21 | firewall=1 su NIC, Docker interno |
| VM203 | templateMicroservice | stopped | vmbr3 | — | Template microservizi (base disk) |
| VM204 | ConvertitoreRuoliniENI | running | vmbr3 | .22 | |
| VM205 | GanttTool | running | vmbr3 | — | Guest agent non in esecuzione |
| VM206 | intrasite | running | vmbr2 | .23 | Docker interno |
| VM207 | websiteAnalyst | running | vmbr3 | .24 | 6 vCPU, 16 GB RAM, dischi 32G+96G su storage SERVIZI; ospita il progetto website-analyst. Nuova alla documentazione, non all'infrastruttura: il `ctime` del file di configurazione la data all'**08/02/2025**, mentre la prima verifica documentale e' del 13/07/2026 |
| VM208 | portaleAsset | running | vmbr0, `firewall=1` | .25 | **Creata il 21/07/2026** (`ctime` del config), assente dallo snapshot v4: 4 core, 8 GB RAM con balloon a 4 GB, disco 100G su storage SERVIZI (`cache=writethrough`), `onboot=1`, guest agent attivo, VGA qxl con sessione grafica. Ospita il pilota interno LAN del progetto Portale Asset IT. Appartenenza al pool "Servizi" non verificata |
| VM602 | Intralino | running | vmbr3 | — | Rinominata (era ITdeveloping); pool Programmazione, disco 200G su storage PROGRAMMAZIONE; no agent |
| VM810 | TESTNEWEGETRADBOOT | running | vmbr0 | — | 260G; sostituisce la VM809 dei log di febbraio; no agent |

Rimosse rispetto al v3: VM803. Rimosse rispetto ai log vzdump di febbraio
2026: VM101, 201, 601, 801-803, 809, 900-902 (gap #106 riconciliato). Pool
risorse: "Servizi" (100, 202-207, 810) e "Programmazione" (602).

Riconciliazione live del 27/07/2026 (interrogazione diretta del nodo via MCP
Proxmox, non un nuovo snapshot completo): le VM sono **dieci**, nove in esecuzione
piu' la VM203 template ferma. Il nodo `pve` risulta scarico (48 core al 4%, 96.7
GiB di RAM occupati su 125.4, uptime di 68 giorni) e nulla e' cambiato su storage,
job di backup e stato del firewall. Il conteggio a nove VM scritto in
`dev-testing.md` era quindi superato: aggiornato nella stessa sessione. Il
prossimo `Get-ProxmoxSnapshot.ps1` (M18) sostituira' questa riconciliazione
parziale con uno snapshot v5 completo.

## VM207 e VM208: progetti applicativi ospitati (verificato live il 27/07/2026)

Le due VM piu' recenti ospitano progetti software con repository, documentazione e
ciclo di vita propri, esterni a questo repository. Qui interessano come *asset di
rete*: cosa espongono, su quale segmento, con quale postura. Lo stato di
avanzamento del loro sviluppo resta nei rispettivi progetti, non qui.

La VM207 esegue un servizio di estrazione contenuti da siti web: backend FastAPI
sotto systemd con utente di servizio dedicato, in ascolto in HTTP non cifrato sulla
porta 8000 legata all'indirizzo di LAN della VM (non su loopback), piu' un secondo
servizio HTTP sulla porta 80. Monta in CIFS una condivisione del NAS (10.61.20.177)
con un account di servizio dedicato, che e' la scelta corretta, e tiene i dati su un
disco separato montato su `/srv`. La VM e' sul bridge `vmbr3`, quello dei servizi
separati. Due elementi di postura aperti: il parametro `-vnc 0.0.0.0:77` nella
configurazione QEMU e un file di credenziali in chiaro nella home dell'utente
(gap SRV-005).

La VM208 esegue il pilota interno del portale di supporto ISO27001: uno stack
container con database PostgreSQL, cache Redis, identity provider Keycloak, API e
reverse proxy Caddy che pubblica la SPA in HTTPS su 80 e 443. Verificato che
l'endpoint di prontezza dell'API risponde `ready`. Convivono sulla stessa VM due
progetti compose distinti, il pilota che pubblica su tutte le interfacce e un
insieme di soli servizi dati per lo sviluppo, questo invece legato a `127.0.0.1`.
La differenza sostanziale rispetto alla VM207 e' il segmento: la VM208 e' su
`vmbr0`, cioe' direttamente sulla LAN piatta `/19` condivisa con postazioni e
stampanti, e vi pubblica un'applicazione con identity provider senza alcun filtro
interposto (gap NET-011). Il nome del portale si risolve per file `hosts` su ogni
client e la fiducia nel certificato dipende da una CA interna importata a mano
macchina per macchina (gap SEC-016). L'esposizione pubblica del portale e'
esplicitamente rimandata dal progetto stesso a una fase successiva, dietro la DMZ
pianificata in M7/M9 di questo progetto: il gancio architetturale esiste, la DMZ no
(non ancora attivata).

**VM206 "intrasite" (verificato live il 09/07/2026)**: serve una copia
interna del sito WordPress pubblico `intrawelt.com`. Le postazioni con
voci hosts locali che puntano `intrawelt.com`/`www.intrawelt.com` a
10.61.20.23 raggiungono questa VM invece del sito pubblico ospitato da
Fastnet — verosimilmente per test/sviluppo locale senza toccare il sito in
produzione, o per evitare hairpin NAT dalla LAN verso il proprio IP
pubblico (causale non confermata da una fonte, solo inferita). La VM
presenta un certificato TLS **auto-firmato** (non pensato per la fiducia
pubblica, coerente con un uso puramente interno): non e' un problema sul
sito pubblico reale, che ha un certificato Let's Encrypt valido (vedi
`scenia-project.md` §Architettura domini).

## Storage e backup (snapshot v4)

| Storage | Tipo | Totale | Usato |
|---|---|---|---|
| SERVIZI | lvmthin | 1000 GB | 537 GB |
| PROGRAMMAZIONE | lvmthin (nuovo rispetto al v3) | 1500 GB | 100 GB |
| NAS_INTRA | cifs | 5.5 TB | 2.5 TB |
| NAS_HERO | cifs | 5.0 TB | 0.2 TB |
| NAS_INTRA2 | cifs | 22.1 TB | 14.5 TB |

Nove job di backup schedulati (zstd, snapshot mode), scaglionati tra le
21:00 e le 06:00 verso NAS_INTRA (uno generale "tutte" piu' job per-VM),
con un secondo job della VM100 verso NAS_HERO alle 00:30.

## Stato firewall (snapshot v4)

- Firewall cluster: INATTIVO, 0 regole — invariato dal v3
- VM202: `firewall=1` a livello NIC, 0 regole esplicite — nessun effetto pratico
- Tutte le altre VM: firewall non abilitato

## Gap di sicurezza identificati (ISO27001 Annex A)

Gap analysis completata il 10/07/2026 incrociando lo snapshot Proxmox v4, il
piano firewall a micro-step (Fase 3 di `roadmap.md`) e `GAP-TBC.md`. I
controlli sotto sono quelli con evidenza concreta raccolta sulla rete
Intrawelt; non e' una Statement of Applicability formale (vedi Fase 5).

| Controllo | Stato | Gap / evidenza |
|---|---|---|
| A.8.20 Network security | Parziale | Nessun firewall attivo tra segmenti Proxmox (0 regole cluster); il firewall perimetrale Zyxel USG FLEX 500 e' configurato ma con anomalie aperte (FW-001/FW-010). **Aggiornamento 27/07/2026**: sullo switch del Piano Terra le protezioni di livello 2 contro un server DHCP abusivo sono disattivate — DHCP Server Guard (nome Zyxel del DHCP snooping) e IP source guard entrambi off, verificato il 23/07 (NET-012, `GAP-TBC.md` #122). Su una LAN piatta significa che un dispositivo collegato a qualunque presa puo' dirottare i client dell'intera `/19` su gateway e DNS arbitrari. L'attivazione va pianificata segmento per segmento dentro M22, marcando trusted il solo trunk verso il firewall: attivarla in blocco sulla rete piatta rischia di scartare le offerte DHCP legittime. Residuo correlato: la porta 19 dello stesso switch e' ancora su PVID 90, cioe' consegna in rete ospiti chi vi si collega (NET-013, #123) |
| A.8.22 Segregation in networks | Parziale | Segmentazione fisica (bridge separati) ma nessun VLAN tagging ne' policy enforcement lato Proxmox (M4/M5 del piano); a livello LAN, switch di management erroneamente sulla VLAN Guest (NET-001, M12); **la LAN principale e' un'unica rete flat `/19`** (PC .10, server .20, stampanti .30 sono alias IP, non VLAN separate — NET-009, M22, identificato il 15/07/2026). Implicazione concreta segnalata dall'utente il 16/07/2026: le stampanti multifunzione con scan-to-folder possono raggiungere direttamente le cartelle condivise di un PC Windows 11 invece di essere confinate a una destinazione unica e presidiata (es. un NAS), un fronte di sanificazione dei flussi dato distinto dalla sola segmentazione di rete (si veda anche A.8.3 Information access restriction) — da riprendere quando si pianifica M22. **Tentativo 16/07/2026**: la VLAN
Wi-Fi staff e' stata applicata e poi ripristinata in giornata — i tre AP
EOL hanno smesso di trasmettere l'SSID al cambio di VLAN nativa sulla
porta switch, per una causa non verificabile (AP inaccessibili). Nessun
impatto sulla produzione oltre l'interruzione stessa (rilevata e risolta
in circa 15 minuti). Lezione di change management (rilevante anche per
A.5.37/procedure operative): il rollout porta-per-porta con verifica
immediata (gia' in uso) ha contenuto l'incidente a una finestra breve,
ma un test con presenza fisica avrebbe permesso di distinguere subito un
guasto reale da un AP che si stava solo re-inizializzando. **Aggiornamento
27/07/2026**: la LAN piatta non e' piu' solo un rischio potenziale. La VM208,
attestata su `vmbr0`, pubblica il pilota del portale ISO27001 con il suo
identity provider su TCP/80 e TCP/443 verso l'intero dominio di broadcast della
`/19` (NET-011, GAP-TBC #118), e il flag `firewall=1` sulla sua NIC non produce
effetto perche' il firewall di cluster resta inattivo. Questo aggiunge un
requisito concreto a M22: la segmentazione delle tre classi deve prevedere anche
un segmento per i servizi applicativi interni, non solo la tripartizione
PC/server/stampanti. **Design aperto il 27/07/2026** in
`docs/segmentazione-lan-m22.md`: cinque segmenti, matrice dei flussi con default
deny e log, piano operativo che parte dalle stampanti perche' e' il carico con
accoppiamento minimo; diagramma target in
`.claude/context/diagrams/segmentazione-target-m22.mmd`. Il design ha fatto
emergere un fronte ulteriore dello stesso controllo, non ancora deciso: la
gestione degli apparati non ha un segmento proprio — l'interfaccia di gestione
dello switch del Piano Terra vive nella classe delle postazioni (verificato
23/07/2026) e la iLO5 del server su una classe `.1` che nessun documento descrive
come segmento (SRV-003, #108), quindi una postazione compromessa vede oggi il
piano di gestione della rete. Rilevante anche per A.9.4, accesso privilegiato |
| A.5.14 Information transfer / A.8.3 Information access restriction | **Gap misurato** | Le destinazioni di scansione della multifunzione del Piano Terra sono quattro su quattro cartelle condivise di **singole postazioni** (SMB/445), nessuna verso un NAS presidiato: i documenti scansionati, che tipicamente contengono dati personali, si depositano su endpoint, e l'apparato conserva al proprio interno le credenziali di accesso a quelle condivisioni, con almeno un'utenza nominale invece di un account di servizio (SEC-020, `GAP-TBC.md` #126; misurato il 29/07/2026). Non e' un difetto di rete ma di *politica di destinazione*, quindi la sola segmentazione non lo chiude: la VLAN decide chi parla con chi, la politica decide dove finiscono i documenti. Rimedio staccato dalla segmentazione ed eseguibile subito come interventi R8 e R9 di `docs/interventi-robustezza.md`. Aggancio con A.9.2 per l'utenza nominale usata da un apparato, non attribuibile e destinata a rompersi alla dismissione dell'account |
| A.8.16 Monitoring activities | Non verificato | Logging traffico di rete non documentato; nessuna policy di raccolta/retention log firewall o switch |
| A.5.37 Documented operating procedures | In corso | Questo progetto (network-design), piu' PSGSI rev.1 firmata il 16/10/2025 (avvio formale SGSI) |
| A.8.8 Management of technical vulnerabilities | Non verificato | Patch management di switch Nebula, firewall e firmware NAS non documentato (Fase 4 step 1); un VA esterno non credenzialato (06/11/2025, Onova) ha rilevato 8 anomalie, dettaglio in `vulnerability-assessment-nov2025.md` |
| A.8.21 Security of network services | Parziale | Tunnel IPsec verso Seeweb ancora su IKEv1 aggressive mode con parametri deboli (AES-128/SHA-1/DH2 citati nel piano di aggiornamento, M14); upgrade a IKEv2 non ancora pianificato in una finestra di manutenzione |
| A.8.1 User endpoint devices | Conforme (endpoint) / Parziale (gestione centralizzata) | BitLocker XTS-AES 128 bit attivo su tutti gli endpoint Windows dal 03/07/2026, chiavi in escrow su NinjaOne; manca pero' Microsoft Intune (MDM) perche' la licenza M365 e' Business Standard, non Premium — nessuna policy di conformita' dispositivo centralizzata oltre l'AV Bitdefender (GAP-TBC #113, SEC-014) |
| A.8.13 Information backup | Documentato | Inventario NAS fleet consolidato in `vendor-management.md` §QNAP – NAS (RAID, capacita', backup per dispositivo); NAS HERO replicato offsite su Azure Blob Storage. Resta [TBC] la verifica periodica dei restore (non documentata) |
| A.7.1 Physical security perimeter | Parziale | CED con badge lettore impronte (BioStar) gia' attivo; badge dedicato per l'accesso alla sala server ancora da implementare (azione emersa dalla gap analysis ISO 27001 del 18/04/2025, vedi `cybersecurity-governance.md`) |
| A.8.24 Use of cryptography | Non verificato | Nessuna policy crittografica documentata a livello aziendale; a livello di rete, il wildcard SSL su Plesk/Fastnet ha un limite tecnico noto (vedi `scenia-project.md` §Architettura domini) e la VM interna "intrasite" (VM206) usa un certificato auto-firmato, coerente con l'uso puramente interno. **Aggiornamento 27/07/2026**: il pilota sulla VM208 introduce una terza catena di fiducia interna, una CA generata dal reverse proxy la cui root va importata a mano su ogni client, senza inventario delle macchine coinvolte ne' procedura di revoca o rinnovo (SEC-016, GAP-TBC #119). Tre soluzioni diverse per lo stesso problema — certificato pubblico, auto-firmato, CA interna — sono il segnale che la policy crittografica va scritta prima che i servizi interni si moltiplichino |
| A.8.4 Access to source code / A.8.31 Separation of environments | Non normato | I progetti applicativi ospitati sulle VM aziendali (VM207, VM208) non hanno una regola scritta su dove viva il codice: uno dei due repository ha un secondo remote verso l'account GitHub personale di un collaboratore e l'identita' di commit locale di quella persona (SEC-017, GAP-TBC #121). Sul lato separazione degli ambienti, il pilota della VM208 ha una decisione di progetto per isolare pre-produzione e produzione sulla stessa VM (progetti container e hostname distinti), ma alla verifica del 27/07/2026 risultava attuata solo a livello di configurazione: la seconda copia di lavoro e il relativo ramo non erano ancora stati creati, e accanto al pilota girava un insieme di servizi dati di sviluppo |

## Prossimi passi di hardening (da pianificare)

1. Attivare e configurare firewall cluster Proxmox con policy di default DROP
2. Definire regole per segmento (vmbr0: management only, vmbr3: isolamento servizi)
3. Documentare e verificare patch level Proxmox e VM
4. Valutare VLAN tagging per segmentazione ulteriore

## Decisioni di sicurezza di design

- Le credenziali Proxmox vengono chieste a runtime, mai scritte su disco
- `output/` mai in git (IP, MAC, nomi VM, configurazioni)
- Il codice dello script non contiene segreti hardcoded
