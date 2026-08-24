#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Estrae da uno snapshot Nebula la matrice delle porte dei due switch gestiti e la
scrive in `data/port-matrix.json`, che e' tracciato.

Perche' un file intermedio invece di leggere lo snapshot direttamente
-------------------------------------------------------------------
Lo snapshot vive in `output/`, che e' ignorato da git perche' contiene indirizzi
MAC reali e nomi host. La mappa invece e' pubblica. Se il generatore leggesse lo
snapshot, la mappa non sarebbe piu' rigenerabile da un clone e l'anonimizzazione
dipenderebbe da un passaggio invisibile dentro il generatore. Con un file
intermedio tracciato, invece, cio' che finisce in pubblico e' un file che si
puo' leggere, controllare con il guard-rail dell'anonimizzazione insieme a tutti
gli altri, e diffare fra due revisioni.

Cosa esce e cosa no
-------------------
Escono numero di porta, stato di abilitazione, modalita' trunk, PVID, VLAN
ammesse, presenza e stato dell'alimentazione PoE, velocita' del collegamento.
Sono numeri di configurazione: non identificano nessuno.

Non escono gli indirizzi MAC. Della tabella MAC sopravvivono due aggregati, che
sono la parte informativa: quante stazioni distinte si vedono su quella porta, e
in quali VLAN. Servono a rispondere a "questa porta e' viva?" e soprattutto a
"il traffico che passa di qui sta nella VLAN che mi aspettavo?", che e' la
domanda con cui si scoprono le porte configurate in un modo e usate in un altro.

Prima di scrivere, il file prodotto viene ripassato in cerca di indirizzi MAC: se
ne trova uno, non scrive. E' lo stesso schema di Build-NetworkMap.ps1 e
Build-TimelineSvg.ps1, e vale la stessa ragione.

Uso
---
    python scripts/Export-PortMatrix.py
    python scripts/Export-PortMatrix.py --verifica     # non scrive, dice cosa cambierebbe
"""

import argparse
import io
import json
import os
import re
import sys
from collections import OrderedDict, defaultdict

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SNAPSHOT = os.path.join(RADICE, "output", "nebula-snapshot.json")
TOPOLOGIA = os.path.join(RADICE, "data", "network-topology.json")
USCITA = os.path.join(RADICE, "data", "port-matrix.json")

RE_MAC = re.compile(r"\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b")


def normalizza_velocita(grezzo):
    """Da `AUTO_1000M` a `1 Gb/s`, e da `OFFLINE` a niente. Nella forma grezza
    OFFLINE e' una stringa non vuota, quindi un conteggio ingenuo dei
    collegamenti attivi la conta come attiva: e' successo al primo giro."""
    if not grezzo or str(grezzo).upper() in ("OFFLINE", "DOWN", "LINK_DOWN"):
        return None
    m = re.search(r"(\d+)\s*([MG])", str(grezzo).upper())
    if not m:
        return str(grezzo)
    valore, unita = int(m.group(1)), m.group(2)
    if unita == "M" and valore >= 1000:
        return "%g Gb/s" % (valore / 1000.0)
    return "%d %sb/s" % (valore, "M" if unita == "M" else "G")


def leggi(percorso, obbligatorio=True):
    if not os.path.exists(percorso):
        if obbligatorio:
            print("File assente: %s" % percorso)
            sys.exit(2)
        return None
    with io.open(percorso, encoding="utf-8-sig") as f:
        return json.load(f)


def main():
    ap = argparse.ArgumentParser(description="Estrae la matrice delle porte dallo snapshot Nebula.")
    ap.add_argument("--verifica", action="store_true",
                    help="non scrive: riporta soltanto se il file su disco e' diverso")
    args = ap.parse_args()

    neb = leggi(SNAPSHOT)
    topo = leggi(TOPOLOGIA)

    # Corrispondenza nodo della topologia -> dispositivo Nebula, dichiarata nella
    # fonte con il campo `nebula`. Stessa chiave usata da Test-TopologyDrift.py:
    # una sola corrispondenza, in un posto solo.
    per_nome = {}
    for n in topo["nodi"]:
        if n.get("nebula"):
            per_nome[n["nebula"]] = n

    org = (neb.get("organizations") or [{}])[0]
    if org.get("mode") and org["mode"] != "PRO":
        print("Attenzione: organizzazione in modalita' %s, lo snapshot puo' essere parziale."
              % org["mode"])

    switch = []
    for sito in org.get("sites") or []:
        for sw in sito.get("switches") or []:
            nome = sw.get("name") or ""
            nodo = per_nome.get(nome)
            impostazioni = (sw.get("port_settings") or {}).get("value") or []
            stato = {p["portNum"]: p for p in (sw.get("ports_status") or {}).get("value") or []}

            # aggregati dalla tabella MAC: conteggi e VLAN, mai gli indirizzi
            stazioni = defaultdict(set)
            vlan_viste = defaultdict(set)
            for voce in (sw.get("l2_mac_table") or {}).get("value") or []:
                pn = voce.get("portNum")
                if pn is None:
                    continue
                stazioni[pn].add(voce.get("macAddress"))
                if voce.get("vlan") is not None:
                    vlan_viste[pn].add(voce["vlan"])

            porte = []
            for p in sorted(impostazioni, key=lambda x: x.get("portNum", 0)):
                n = p.get("portNum")
                voce = OrderedDict()
                voce["n"] = n
                voce["attiva"] = bool(p.get("enabled"))
                voce["trunk"] = bool(p.get("trunk"))
                voce["pvid"] = p.get("portVid")
                voce["vlan-ammesse"] = p.get("allowedVLAN") or []
                if p.get("hasPse"):
                    voce["poe"] = bool(p.get("pseEnabled"))
                voce["collegamento"] = normalizza_velocita((stato.get(n) or {}).get("linkSpeed"))
                voce["stazioni"] = len(stazioni.get(n, ()))
                if vlan_viste.get(n):
                    voce["vlan-viste"] = sorted(vlan_viste[n])
                porte.append(voce)

            switch.append(OrderedDict([
                ("nodo", nodo["id"] if nodo else None),
                ("modello", sw.get("model")),
                ("porte-totali", len(porte)),
                ("porte", porte),
            ]))
            if nodo is None:
                print("Attenzione: lo switch \"%s\" non e' rivendicato da nessun nodo della fonte "
                      "con il campo `nebula`: la matrice non si potra' agganciare alla mappa." % nome)

    switch.sort(key=lambda s: -(s["porte-totali"]))

    risultato = OrderedDict()
    risultato["meta"] = OrderedDict([
        ("titolo", "Matrice delle porte degli switch gestiti"),
        ("misura-del", neb.get("generated_at")),
        ("estratto-da", "output/nebula-snapshot.json (ignorato da git)"),
        ("generatore", "scripts/Export-PortMatrix.py"),
        ("avvertenza",
         "File derivato e tracciato. Non si modifica a mano: si rilancia lo snapshot Nebula e poi "
         "questo script. Contiene solo dati di configurazione delle porte piu' due aggregati della "
         "tabella MAC, cioe' il numero di stazioni distinte viste e le VLAN in cui si vedono. "
         "Gli indirizzi MAC non escono da qui per costruzione, e un controllo lo verifica prima di scrivere."),
        ("campi",
         "n numero di porta; attiva abilitazione amministrativa; trunk modalita' 802.1Q; pvid VLAN "
         "nativa; vlan-ammesse elenco o \"all\"; poe presente solo sulle porte con alimentazione, "
         "vero se erogante; collegamento velocita' negoziata o nullo se la porta e' spenta o scollegata; "
         "stazioni numero di indirizzi distinti nella tabella MAC; vlan-viste VLAN in cui quel traffico appare."),
    ])
    risultato["switch"] = switch

    testo = json.dumps(risultato, ensure_ascii=False, indent=2) + "\n"

    # Guard-rail: nessun MAC puo' uscire di qui.
    trovati = sorted(set(RE_MAC.findall(testo)))
    if trovati:
        print("Guard-rail: indirizzi MAC nel risultato, non scrivo.")
        for m in trovati[:10]:
            print("   ", m)
        sys.exit(1)

    vecchio = None
    if os.path.exists(USCITA):
        vecchio = io.open(USCITA, encoding="utf-8").read()

    n_porte = sum(s["porte-totali"] for s in switch)
    n_att = sum(1 for s in switch for p in s["porte"] if p["collegamento"])
    n_trunk = sum(1 for s in switch for p in s["porte"] if p["trunk"])
    n_poe = sum(1 for s in switch for p in s["porte"] if p.get("poe"))

    if args.verifica:
        if vecchio == testo:
            print("Matrice invariata: %d porte su %d switch." % (n_porte, len(switch)))
            return 0
        print("La matrice sul disco e' diversa dallo snapshot corrente: rilancia senza --verifica.")
        return 1

    io.open(USCITA, "w", encoding="utf-8", newline="\n").write(testo)
    print("Matrice porte: %s" % USCITA)
    print("  %d switch, %d porte totali, %d con collegamento attivo, %d in trunk, %d che erogano PoE"
          % (len(switch), n_porte, n_att, n_trunk, n_poe))
    print("  Misura del %s. Nessun indirizzo MAC nel risultato." % (neb.get("generated_at") or "data ignota"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
