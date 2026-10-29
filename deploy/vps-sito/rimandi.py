#!/usr/bin/env python3
"""Rimandi dagli indirizzi del sito attuale a quelli del sito nuovo (G8 del go-live).

Il punto di partenza e' la tabella dei rimandi, una riga per indirizzo del sito attuale,
con le colonne `url_vecchio` e `destinazione`. La tabella vive nel layer privato, perche'
nasce dall'inventario del sito attuale; questo strumento e' versionato e non contiene
indirizzi.

Tre comandi.

  genera   scrive le righe dei rimandi fra le marche RINVII-INIZIO e RINVII-FINE di
           Caddyfile.produzione. Ogni indirizzo vecchio produce due righe, con e senza
           barra finale, perche' i collegamenti esterni arrivano in entrambe le forme.
           Una destinazione `410` produce una risposta "non esiste piu'". Le righe senza
           destinazione valida non si scrivono e si elencano: l'uscita e' 1 se ce ne sono.

  prova    interroga un proxy che ha gia' quelle righe, senza seguire i rimandi, e
           controlla per ogni indirizzo vecchio codice e destinazione.

  destinazioni  interroga il sito nuovo e controlla che ogni destinazione esista (200),
           perche' un rimando verso una pagina che non c'e' sposta il 404 senza toglierlo.

Con --bozza la destinazione si prende dalla colonna `destinazione_proposta` della bozza
del 28/10/2026, quando comincia con un percorso; serve a provare la catena prima che le
destinazioni siano confermate, non a pubblicarle.
"""

from __future__ import annotations

import argparse
import csv
import http.client
import re
import ssl
import sys
from pathlib import Path
from urllib.parse import urlsplit

INIZIO, FINE = "# RINVII-INIZIO", "# RINVII-FINE"
AGENTE = "rimandi-sito-intrawelt/1"


def destinazione(riga: dict, bozza: bool) -> str | None:
    """La destinazione di una riga, o None se non e' utilizzabile."""
    valore = (riga.get("destinazione") or "").strip()
    if not valore and bozza:
        proposta = (riga.get("destinazione_proposta") or "").strip()
        if "410" in proposta:
            valore = "410"
        else:
            primo = proposta.split(" ")[0]
            # "/chi-siamo o /soluzioni" e simili restano da decidere: niente scelta automatica.
            valore = primo if primo.startswith("/") and " o /" not in proposta else ""
    if valore == "410" or re.fullmatch(r"/[A-Za-z0-9._~/%-]*", valore or ""):
        return valore
    return None


def leggi_tabella(percorso: Path, bozza: bool) -> tuple[list[tuple[str, str]], list[str]]:
    coppie, scartate = [], []
    with percorso.open(encoding="utf-8", newline="") as f:
        for riga in csv.DictReader(f):
            vecchio = urlsplit(riga["url_vecchio"]).path or "/"
            dest = destinazione(riga, bozza)
            if dest is None:
                scartate.append(f"{vecchio}  ({(riga.get('destinazione') or riga.get('destinazione_proposta') or '').strip()})")
            elif dest != vecchio:
                coppie.append((vecchio, dest))
    return coppie, scartate


def righe_caddy(coppie: list[tuple[str, str]]) -> list[str]:
    righe = []
    for vecchio, dest in coppie:
        varianti = [vecchio] + ([vecchio.rstrip("/")] if vecchio.endswith("/") and vecchio != "/" else [])
        for v in varianti:
            righe.append(f"respond {v} 410" if dest == "410" else f"redir {v} {dest} 301")
    return righe


def genera(args) -> int:
    coppie, scartate = leggi_tabella(Path(args.tabella), args.bozza)
    caddyfile = Path(args.caddyfile)
    testo = caddyfile.read_bytes().decode("utf-8")
    inizio, fine = testo.find(INIZIO), testo.find(FINE)
    if inizio < 0 or fine < inizio or testo.count(INIZIO) != 1 or testo.count(FINE) != 1:
        print(f"marche {INIZIO} / {FINE} assenti o ripetute in {caddyfile}", file=sys.stderr)
        return 2
    rientro = testo[testo.rfind("\n", 0, inizio) + 1 : inizio]
    blocco = "".join(f"{rientro}{r}\n" for r in righe_caddy(coppie))
    nuovo = testo[: inizio + len(INIZIO)] + "\n" + blocco + rientro + testo[fine:]
    caddyfile.write_bytes(nuovo.encode("utf-8"))
    print(f"{len(coppie)} indirizzi, {blocco.count(chr(10))} righe scritte in {caddyfile}")
    if scartate:
        print(f"{len(scartate)} righe senza destinazione valida, non scritte:")
        for s in scartate:
            print("  " + s)
        return 1
    return 0


def richiesta(base: str, percorso: str) -> tuple[int, str]:
    parti = urlsplit(base)
    classe = http.client.HTTPSConnection if parti.scheme == "https" else http.client.HTTPConnection
    extra = {"context": ssl.create_default_context()} if parti.scheme == "https" else {}
    conn = classe(parti.hostname, parti.port, timeout=15, **extra)
    try:
        conn.request("GET", percorso, headers={"User-Agent": AGENTE, "Host": parti.netloc})
        r = conn.getresponse()
        r.read()
        return r.status, r.getheader("Location", "")
    finally:
        conn.close()


def prova(args) -> int:
    coppie, _ = leggi_tabella(Path(args.tabella), args.bozza)
    errori = 0
    for vecchio, dest in coppie:
        varianti = [vecchio] + ([vecchio.rstrip("/")] if vecchio.endswith("/") and vecchio != "/" else [])
        for v in varianti:
            stato, luogo = richiesta(args.base, v)
            atteso = 410 if dest == "410" else 301
            if stato != atteso or (atteso == 301 and urlsplit(luogo).path != dest):
                errori += 1
                print(f"ERRORE {v}: {stato} {luogo!r}, atteso {atteso} {dest}")
    totale = sum(2 if v.endswith("/") and v != "/" else 1 for v, _ in coppie)
    print(f"{totale - errori} rimandi corretti su {totale}")
    return 1 if errori else 0


def destinazioni(args) -> int:
    coppie, _ = leggi_tabella(Path(args.tabella), args.bozza)
    mancanti = 0
    for dest in sorted({d for _, d in coppie if d != "410"}):
        stato, luogo = richiesta(args.base, dest)
        conta = sum(1 for _, d in coppie if d == dest)
        segno = "ok " if stato == 200 else "NO "
        mancanti += stato != 200
        print(f"{segno}{stato} {dest}  ({conta} indirizzi){'  -> ' + luogo if luogo else ''}")
    return 1 if mancanti else 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="comando", required=True)
    for nome, funzione in (("genera", genera), ("prova", prova), ("destinazioni", destinazioni)):
        s = sub.add_parser(nome)
        s.add_argument("tabella", help="tabella CSV dei rimandi")
        s.add_argument("--bozza", action="store_true", help="usa destinazione_proposta dove manca destinazione")
        if nome == "genera":
            s.add_argument("--caddyfile", default=str(Path(__file__).parent / "caddy" / "Caddyfile.produzione"))
        else:
            s.add_argument("--base", required=True, help="per esempio https://anteprima.example")
        s.set_defaults(funzione=funzione)
    args = p.parse_args()
    return args.funzione(args)


if __name__ == "__main__":
    sys.exit(main())
