#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Riconciliazione fra la fonte della mappa di rete e le misure vive.

Perche' esiste
--------------
`data/network-topology.json` e' scritta a mano da chi legge uno snapshot e
trascrive cio' che ha capito. Dopo, niente la tiene allineata: se qualcuno
sposta un telefono di porta, cambia un PVID o aggiunge un apparato, il file non
se ne accorge e la mappa continua a disegnare la verita' di ieri con la stessa
sicurezza di prima. E' l'obsolescenza silenziosa che le regole del progetto
gia' nominano come rischio principale, applicata all'artefatto.

Questo script non aggiorna niente e non decide niente. Confronta e riporta:
la fonte dice X, l'apparato dice Y. Chi ha ragione lo stabilisce una persona.

Cosa confronta
--------------
Contro `output/nebula-snapshot.json`, per i due switch gestiti:
  - la porta dichiarata in un collegamento esiste sull'apparato
  - la porta e' abilitata
  - le VLAN dichiarate sul collegamento sono ammesse sulla porta
  - il PVID reale coincide con la VLAN dichiarata, sulle porte non trunk
  - gli apparati gestiti dell'inventario Nebula compaiono nella fonte

Contro `output/proxmox-snapshot.json`, per il livello di virtualizzazione:
  - i bridge dichiarati nella fonte esistono sull'host
  - ogni macchina virtuale della fonte esiste ancora
  - il bridge a cui la fonte la attesta e' quello reale

Su entrambi, l'eta' dello snapshot: una misura vecchia non e' una misura, e
confrontarcisi darebbe un verde che non vuol dire niente.

Cosa tocca, e cosa non tocca
----------------------------
Legge tre file gia' sul disco e stampa testo. Non scrive niente, non apre
connessioni di rete, non usa credenziali. E' deliberato: e' cio' che rende
questo script l'unico dei tre della catena che si possa far girare da un hook
senza pensarci. Chi rinfresca gli snapshot fa chiamate autenticate verso il
fornitore, e quella resta una decisione di una persona.

Nomi reali nell'output
----------------------
I nomi che vengono dalla fonte sono gia' pubblicabili, perche' la fonte e'
tracciata e passa il guard-rail di anonimizzazione. I nomi che vengono dagli
snapshot no: `output/` e' ignorato da git proprio perche' contiene nomi host
reali. Per questo, in modo predefinito, gli identificatori presi dagli snapshot
si stampano senza etichetta (solo il numero della macchina, solo il conteggio
degli apparati). Con `--nomi` si vedono per esteso, ed e' la modalita' per una
persona che sta guardando; senza, e' la modalita' per un hook. In nessun caso
l'output di questo script va rediretto dentro un file tracciato.

Uso
---
    python scripts/Test-TopologyDrift.py
    python scripts/Test-TopologyDrift.py --nomi          # etichette per esteso
    python scripts/Test-TopologyDrift.py --giorni 14     # soglia di eta'
    python scripts/Test-TopologyDrift.py --silenzioso    # solo il verdetto

Codici di uscita: 0 nessuno scostamento; 1 scostamenti trovati; 2 impossibile
giudicare, perche' uno snapshot manca o e' troppo vecchio.
"""

import argparse
import io
import json
import os
import re
import sys
from datetime import datetime, timedelta

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RADICE, "data", "network-topology.json")
NEBULA = os.path.join(RADICE, "output", "nebula-snapshot.json")
PROXMOX = os.path.join(RADICE, "output", "proxmox-snapshot.json")

# Corrispondenza fra gli identificatori dei nodi della fonte e i modelli reali.
# Sta qui e non nella fonte perche' e' una chiave di confronto fra due mondi,
# non un fatto della topologia.
SWITCH = {"sw54": "XGS2220-54HP", "sw30": "XGS2220-30HP"}

ROSSO = "\033[31m"
GIALLO = "\033[33m"
VERDE = "\033[32m"
GRIGIO = "\033[90m"
FINE = "\033[0m"


# Interruttore globale: le etichette che vengono dagli snapshot si stampano solo
# se una persona le ha chieste. I nomi che vengono dalla fonte non passano di qui,
# perche' quelli sono gia' pubblicabili per costruzione.
MOSTRA_NOMI = False


def etichetta(nome):
    """Restituisce ' \"nome\"' se le etichette sono ammesse, stringa vuota altrimenti."""
    if not nome:
        return ""
    return ' "%s"' % nome if MOSTRA_NOMI else ""


def colora(testo, colore):
    if os.environ.get("NO_COLOR") or not sys.stdout.isatty():
        return testo
    return colore + testo + FINE


def leggi_json(percorso):
    """I file di PowerShell escono con il BOM, quelli scritti da qui no."""
    if not os.path.exists(percorso):
        return None
    with io.open(percorso, encoding="utf-8-sig") as f:
        return json.load(f)


def eta_giorni(iso):
    if not iso:
        return None
    testo = str(iso).replace("Z", "")
    for fmt in ("%Y-%m-%dT%H:%M:%S", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d"):
        try:
            return (datetime.now() - datetime.strptime(testo[:19], fmt)).days
        except ValueError:
            continue
    return None


class Esito(object):
    def __init__(self):
        self.scostamenti = []
        self.avvisi = []
        self.confrontati = 0
        self.non_giudicabile = False

    def scosta(self, ambito, dettaglio):
        self.scostamenti.append((ambito, dettaglio))

    def avvisa(self, testo):
        self.avvisi.append(testo)


# ---------------------------------------------------------------------------
# Nebula
# ---------------------------------------------------------------------------
def controlla_nebula(topo, neb, esito, giorni_max):
    if neb is None:
        esito.avvisa("Snapshot Nebula assente. Rilancia scripts/Get-NebulaSnapshot.ps1.")
        esito.non_giudicabile = True
        return

    eta = eta_giorni(neb.get("generated_at"))
    if eta is None:
        esito.avvisa("Snapshot Nebula senza data leggibile: non posso valutarne l'eta'.")
    elif eta > giorni_max:
        esito.avvisa(
            "Snapshot Nebula di %d giorni fa (soglia %d). Una misura vecchia non e' una misura: "
            "rilancia scripts/Get-NebulaSnapshot.ps1 prima di fidarti del verde."
            % (eta, giorni_max)
        )
        esito.non_giudicabile = True

    org = (neb.get("organizations") or [{}])[0]
    if org.get("mode") and org["mode"] != "PRO":
        esito.avvisa(
            "L'organizzazione Nebula risulta in modalita' %s e non PRO: la OpenAPI risponde solo "
            "in PRO, quindi lo snapshot potrebbe essere parziale (vedi NEB-002)." % org["mode"]
        )

    switch_reali = {}
    for sito in org.get("sites") or []:
        for sw in sito.get("switches") or []:
            switch_reali[sw.get("model", "")] = sw

    # --- porte dichiarate dai collegamenti della fonte ---------------------
    nomi = {n["id"]: n["nome"] for n in topo["nodi"]}
    for coll in topo["collegamenti"]:
        if coll.get("stato") == "progetto":
            continue  # cio' che non esiste non puo' divergere
        for lato, campo in (("da", "porta-a"), ("a", "porta-b")):
            sid = coll[lato]
            if sid not in SWITCH:
                continue
            grezzo = coll.get(campo)
            if not grezzo:
                continue
            m = re.match(r"^\s*(\d+)", str(grezzo))
            if not m:
                continue
            numero = int(m.group(1))
            sw = switch_reali.get(SWITCH[sid])
            if sw is None:
                esito.scosta(
                    "nebula",
                    "%s: lo switch %s non compare nello snapshot" % (sid, SWITCH[sid]),
                )
                continue
            porte = {p["portNum"]: p for p in (sw.get("port_settings") or {}).get("value") or []}
            altro = coll["a"] if lato == "da" else coll["da"]
            eti = nomi.get(altro, altro)
            porta = porte.get(numero)
            if porta is None:
                esito.scosta(
                    "nebula",
                    "%s porta %d (verso %s): la porta non esiste nello snapshot"
                    % (sid, numero, eti),
                )
                continue
            esito.confrontati += 1
            if not porta.get("enabled", True):
                esito.scosta(
                    "nebula",
                    "%s porta %d (verso %s): disabilitata sull'apparato, la fonte la da' in uso"
                    % (sid, numero, eti),
                )
            dichiarate = coll.get("vlan") or []
            if not dichiarate:
                continue
            ammesse = porta.get("allowedVLAN") or []
            if ammesse != ["all"]:
                mancanti = [v for v in dichiarate if str(v) not in ammesse]
                if mancanti:
                    esito.scosta(
                        "nebula",
                        "%s porta %d (verso %s): la fonte dichiara VLAN %s, la porta ammette %s"
                        % (sid, numero, eti, mancanti, ammesse),
                    )
            if not porta.get("trunk") and dichiarate[0] != porta.get("portVid"):
                esito.scosta(
                    "nebula",
                    "%s porta %d (verso %s): PVID reale %s, la fonte dichiara %s"
                    % (sid, numero, eti, porta.get("portVid"), dichiarate),
                )

    # --- inventario, per corrispondenza dichiarata -------------------------
    # Il confronto e' esatto e bidirezionale perche' poggia sul campo `nebula` dei
    # nodi, cioe' sul nome con cui l'apparato compare nel pannello del fornitore.
    # Il primo tentativo confrontava il modello contro i nomi dei nodi e produceva
    # tre falsi positivi sugli access point, che la fonte chiama per ruolo e Nebula
    # per etichetta di sito: una somiglianza di stringhe non e' una corrispondenza.
    dichiarati = {}
    for n in topo["nodi"]:
        if n.get("nebula"):
            dichiarati[n["nebula"]] = n
    reali = {}
    for sito in org.get("sites") or []:
        for dev in sito.get("devices") or []:
            reali[dev.get("name") or "(senza nome)"] = dev

    for nome, dev in sorted(reali.items()):
        if nome not in dichiarati:
            esito.scosta(
                "nebula",
                "inventario: un apparato gestito (%s) esiste in Nebula e nessun nodo della fonte "
                "lo rivendica con il campo `nebula`%s"
                % (dev.get("model") or "modello ignoto", etichetta(nome)),
            )
        else:
            esito.confrontati += 1
    for nome, nodo in sorted(dichiarati.items()):
        if nome not in reali:
            esito.scosta(
                "nebula",
                "inventario: il nodo %s dichiara di essere \"%s\" in Nebula, che pero' non compare "
                "nell'inventario dell'organizzazione" % (nodo["id"], nome),
            )


# ---------------------------------------------------------------------------
# Proxmox
# ---------------------------------------------------------------------------
def raccogli_proxmox(prox):
    """Lo schema dello snapshot cambia con la versione dello script che lo produce,
    quindi si cerca per forma invece che per percorso fisso."""
    bridge, vm = set(), {}

    def scava(o):
        if isinstance(o, dict):
            tipo = o.get("type")
            nome = o.get("iface") or o.get("name")
            if tipo == "bridge" and isinstance(nome, str) and nome.startswith("vmbr"):
                bridge.add(nome)
            if "vmid" in o:
                # Le schede stanno sotto `config`, non sull'oggetto che porta il
                # vmid: la prima versione le cercava solo al primo livello e il
                # confronto dei bridge non e' mai scattato, saltando in silenzio
                # perche' l'insieme misurato risultava vuoto. Un controllo che non
                # scatta e' peggio di nessun controllo, perche' produce un verde.
                reti = {}
                for sorgente in (o, o.get("config") if isinstance(o.get("config"), dict) else {}):
                    for k, v in (sorgente or {}).items():
                        if re.match(r"^net\d+$", str(k)) and isinstance(v, str):
                            mb = re.search(r"bridge=(\w+)", v)
                            if mb:
                                reti[k] = mb.group(1)
                if reti or "name" in o:
                    prec = vm.get(o["vmid"], {})
                    unione = dict(prec.get("bridge") or {})
                    unione.update(reti)
                    vm[o["vmid"]] = {
                        "nome": o.get("name") or prec.get("nome"),
                        "bridge": unione,
                    }
            for v in o.values():
                scava(v)
        elif isinstance(o, list):
            for v in o:
                scava(v)

    scava(prox)
    return bridge, vm


def controlla_proxmox(topo, prox, esito, giorni_max):
    if prox is None:
        esito.avvisa("Snapshot Proxmox assente. Rilancia scripts/Get-ProxmoxSnapshot.ps1.")
        esito.non_giudicabile = True
        return

    eta = eta_giorni(prox.get("generated_at") or prox.get("generatedAt"))
    if eta is not None and eta > giorni_max:
        esito.avvisa(
            "Snapshot Proxmox di %d giorni fa (soglia %d): gli scostamenti che seguono possono "
            "essere invecchiamento della misura, non della fonte. Rilancia lo snapshot."
            % (eta, giorni_max)
        )
    elif eta is None:
        esito.avvisa("Snapshot Proxmox senza data leggibile: non posso valutarne l'eta'.")

    bridge_reali, vm_reali = raccogli_proxmox(prox)
    if not vm_reali:
        esito.avvisa("Nello snapshot Proxmox non ho trovato macchine virtuali: schema inatteso.")
        return

    # bridge dichiarati dalla fonte
    for nodo in topo["nodi"]:
        if nodo["tipo"] != "bridge":
            continue
        if bridge_reali and nodo["id"] not in bridge_reali:
            esito.scosta(
                "proxmox",
                "il bridge %s e' nella fonte ma non nello snapshot dell'host" % nodo["id"],
            )
        else:
            esito.confrontati += 1

    # macchine virtuali: esistenza e bridge di attestazione
    per_id = {n["id"]: n for n in topo["nodi"]}
    attestazione = {}
    for coll in topo["collegamenti"]:
        if coll.get("stato") == "progetto":
            continue
        if re.match(r"^vmbr\d+$", coll["da"]) and re.match(r"^vm\d+$", coll["a"]):
            attestazione.setdefault(coll["a"], set()).add(coll["da"])

    for nid, nodo in sorted(per_id.items()):
        m = re.match(r"^vm(\d+)$", nid)
        if not m:
            continue
        if nodo.get("stato") == "progetto":
            continue
        vmid = int(m.group(1))
        reale = vm_reali.get(vmid)
        if reale is None:
            esito.scosta(
                "proxmox",
                "la macchina %d (%s) e' nella fonte ma non nello snapshot: spenta, spostata o rimossa"
                % (vmid, nodo["nome"]),
            )
            continue
        esito.confrontati += 1
        dichiarati = attestazione.get(nid) or set()
        effettivi = set((reale.get("bridge") or {}).values())
        if not dichiarati or not effettivi:
            continue
        if not (dichiarati & effettivi):
            esito.scosta(
                "proxmox",
                "la macchina %d (%s): la fonte la attesta su %s, lo snapshot su %s"
                % (vmid, nodo["nome"], ", ".join(sorted(dichiarati)), ", ".join(sorted(effettivi))),
            )

    # macchine reali che la fonte non conosce, escluse quelle coperte dal gruppo
    gruppo = any(n["id"] == "vm-altre" for n in topo["nodi"])
    sconosciute = [
        (vmid, dati.get("nome"))
        for vmid, dati in sorted(vm_reali.items())
        if "vm%d" % vmid not in per_id
    ]
    if sconosciute and not gruppo:
        for vmid, nome in sconosciute:
            esito.scosta("proxmox",
                         "la macchina %d esiste e non e' nella fonte%s" % (vmid, etichetta(nome)))
    elif sconosciute:
        esito.avvisa(
            "%d macchine non hanno un nodo proprio nella fonte e ricadono nel gruppo "
            "'Altre VM di servizio' (%s). E' una scelta di perimetro, non uno scostamento."
            % (len(sconosciute),
               ", ".join(("%d%s" % (v, etichetta(n))) for v, n in sconosciute))
        )


# ---------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description="Riconcilia la fonte della mappa con le misure vive.")
    ap.add_argument("--giorni", type=int, default=10,
                    help="eta' massima accettata per uno snapshot, in giorni (default 10)")
    ap.add_argument("--silenzioso", action="store_true", help="stampa solo il verdetto finale")
    ap.add_argument("--nomi", action="store_true",
                    help="stampa per esteso le etichette prese dagli snapshot (nomi host e nomi "
                         "di apparato). Senza questa opzione restano fuori, perche' output/ e' "
                         "ignorato da git proprio per quelli.")
    args = ap.parse_args()

    global MOSTRA_NOMI
    MOSTRA_NOMI = args.nomi

    topo = leggi_json(FONTE)
    if topo is None:
        print(colora("Fonte non trovata: %s" % FONTE, ROSSO))
        return 2

    esito = Esito()
    controlla_nebula(topo, leggi_json(NEBULA), esito, args.giorni)
    controlla_proxmox(topo, leggi_json(PROXMOX), esito, args.giorni)

    if not args.silenzioso:
        print("Riconciliazione mappa di rete - fonte revisione %s del %s"
              % (topo["meta"].get("revisione"), topo["meta"].get("aggiornato")))
        print("-" * 78)
        for testo in esito.avvisi:
            print(colora("  avviso   ", GIALLO) + testo)
        if esito.avvisi:
            print("-" * 78)
        for ambito, dettaglio in esito.scostamenti:
            print(colora("  %-9s" % ambito, ROSSO) + dettaglio)
        if esito.scostamenti:
            print("-" * 78)

    n = len(esito.scostamenti)
    riepilogo = "%d confronti, %d scostamenti" % (esito.confrontati, n)
    if n:
        print(colora("SCOSTAMENTI: " + riepilogo, ROSSO))
        print("  La fonte e la rete non coincidono. Guarda ogni riga e decidi chi ha ragione:")
        print("  se ha ragione la rete si corregge data/network-topology.json e si rigenera la")
        print("  mappa con scripts/Build-NetworkMap.ps1; se ha ragione la fonte, e' cambiato")
        print("  qualcosa sugli apparati che nessuno ha registrato.")
        return 1
    if esito.non_giudicabile:
        print(colora("NON GIUDICABILE: " + riepilogo, GIALLO))
        print("  Nessuno scostamento trovato, ma una fonte viva manca o e' troppo vecchia:")
        print("  questo verde non e' stato calcolato su tutto. Vedi gli avvisi qui sopra.")
        return 2
    print(colora("ALLINEATA: " + riepilogo, VERDE))
    print(colora("  La mappa dice il vero su cio' che e' confrontabile.", GRIGIO))
    return 0


if __name__ == "__main__":
    sys.exit(main())
