#!/usr/bin/env python3
"""Sonda del sito nuovo: disponibilita', tempo di risposta e scadenza del certificato.

Voce G13 del go-live. Gira dalla LAN della sede e non dalla VPS, per due ragioni: un
sito non puo' avvisare della propria caduta, e finche' il sito vive sul nome di
anteprima il proxy ammette la sola provenienza aziendale, quindi una sonda esterna
leggerebbe soltanto un 403.

Per ADR-037 la sonda guarda la prestazione e non la sola raggiungibilita': misura il
tempo al primo byte di due percorsi. La pagina pubblica e' pre-generata e servita dalla
cache, quindi dice che cosa vede il visitatore; il percorso applicativo passa per
l'applicazione e per la banca dati, quindi dice se il sito sa ancora comporre. Le
soglie si fissano sul riferimento misurato della macchina sana, scritto nel runbook,
non su un valore di catalogo, e ogni esecuzione aggiunge una riga alla serie.

Tre esiti, con codice d'uscita distinto: 0 sano, 1 allarme, 2 misura impossibile. La
misura e' impossibile quando il sito non risponde e non risponde nemmeno il bersaglio
di riferimento esterno: e' caduto il collegamento della sede, non il sito, e chiamarlo
allarme insegnerebbe a ignorare gli allarmi.

L'avviso parte solo al cambio di stato confermato per un numero di esecuzioni
consecutive, in entrambe le direzioni, cosi' un guasto produce un messaggio e il suo
rientro un altro, invece di uno ogni cinque minuti.

Solo libreria standard. La configurazione arriva dall'ambiente, perche' nomi e
destinatari sono scelte di esercizio e questo file e' versionato in un repository
pubblico: il modello dei nomi sta in sonda-sito.conf.esempio.
"""

from __future__ import annotations

import http.client
import json
import os
import shlex
import socket
import ssl
import statistics
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlsplit

SANO, ALLARME, IMPOSSIBILE = "sano", "allarme", "misura_impossibile"
CODICI = {SANO: 0, ALLARME: 1, IMPOSSIBILE: 2}

# Le richieste della sonda compaiono nel registro degli accessi del proxy: un agente
# riconoscibile permette di toglierle dalla misura del traffico (ADR-039).
AGENTE = "sonda-sito-intrawelt/1"
RIGHE_SERIE_MAX = 20000  # circa settanta giorni a un'esecuzione ogni cinque minuti


@dataclass
class Configurazione:
    url_pagina: str
    url_app: str
    marcatore_pagina: str
    marcatore_app: str
    soglia_pagina_s: float
    soglia_app_s: float
    giorni_certificato: int
    riferimento: str
    campioni: int
    timeout_s: float
    consecutivi: int
    cartella_stato: Path
    comando_avviso: str

    @classmethod
    def da_ambiente(cls, env: dict[str, str] | None = None) -> "Configurazione":
        env = dict(os.environ if env is None else env)
        mancanti = [n for n in ("SONDA_URL_PAGINA", "SONDA_URL_APP") if not env.get(n)]
        if mancanti:
            raise ValueError("variabili assenti: " + ", ".join(mancanti))
        return cls(
            url_pagina=env["SONDA_URL_PAGINA"],
            url_app=env["SONDA_URL_APP"],
            marcatore_pagina=env.get("SONDA_MARCATORE_PAGINA", "</html>"),
            marcatore_app=env.get("SONDA_MARCATORE_APP", '"docs"'),
            soglia_pagina_s=float(env.get("SONDA_SOGLIA_PAGINA_S", "1.0")),
            soglia_app_s=float(env.get("SONDA_SOGLIA_APP_S", "1.0")),
            giorni_certificato=int(env.get("SONDA_GIORNI_CERTIFICATO", "20")),
            riferimento=env.get("SONDA_RIFERIMENTO", "1.1.1.1:443"),
            campioni=int(env.get("SONDA_CAMPIONI", "3")),
            timeout_s=float(env.get("SONDA_TIMEOUT_S", "10")),
            consecutivi=int(env.get("SONDA_CONSECUTIVI", "2")),
            cartella_stato=Path(env.get("SONDA_CARTELLA_STATO") or env.get("STATE_DIRECTORY") or "."),
            comando_avviso=env.get("SONDA_COMANDO_AVVISO", ""),
        )


@dataclass
class Lettura:
    """Un campione su un percorso: esito HTTP, tempi e giorni residui del certificato."""

    stato_http: int | None = None
    primo_byte_s: float | None = None
    totale_s: float | None = None
    giorni_certificato: float | None = None
    marcatore_trovato: bool = False
    errore: str = ""


@dataclass
class Esito:
    stato: str
    motivi: list[str] = field(default_factory=list)
    misure: dict = field(default_factory=dict)


def leggi(url: str, marcatore: str, timeout_s: float) -> Lettura:
    """Una richiesta GET su HTTPS con verifica del certificato, cronometrata dall'inizio.

    Il tempo al primo byte comprende risoluzione, connessione e negoziazione TLS, come
    il `time_starttransfer` di curl con cui e' stato misurato il riferimento.
    """
    parti = urlsplit(url)
    percorso = parti.path or "/"
    if parti.query:
        percorso += "?" + parti.query
    inizio = time.monotonic()
    conn = http.client.HTTPSConnection(
        parti.hostname, parti.port or 443, timeout=timeout_s, context=ssl.create_default_context()
    )
    try:
        conn.request("GET", percorso, headers={"User-Agent": AGENTE, "Accept-Encoding": "identity"})
        # Il certificato si legge qui: se il server chiude la connessione, getresponse
        # libera il socket e dopo non ci sarebbe piu' niente da leggere.
        certificato = conn.sock.getpeercert() if conn.sock else None
        risposta = conn.getresponse()
        primo_byte = time.monotonic() - inizio
        corpo = risposta.read()
        totale = time.monotonic() - inizio
        giorni = None
        if certificato and certificato.get("notAfter"):
            giorni = (ssl.cert_time_to_seconds(certificato["notAfter"]) - time.time()) / 86400
        return Lettura(
            stato_http=risposta.status,
            primo_byte_s=primo_byte,
            totale_s=totale,
            giorni_certificato=giorni,
            marcatore_trovato=marcatore.encode() in corpo,
        )
    except (OSError, http.client.HTTPException, ssl.SSLError) as exc:
        return Lettura(errore=f"{type(exc).__name__}: {exc}")
    finally:
        conn.close()


def raggiungibile(riferimento: str, timeout_s: float) -> bool:
    host, _, porta = riferimento.rpartition(":")
    try:
        with socket.create_connection((host, int(porta)), timeout=timeout_s):
            return True
    except OSError:
        return False


def valuta(cfg: Configurazione, letture: dict[str, list[Lettura]], riferimento_ok) -> Esito:
    """Classifica i campioni. `riferimento_ok` si chiama solo se qualcosa non risponde."""
    soglie = {"pagina": cfg.soglia_pagina_s, "app": cfg.soglia_app_s}
    misure: dict = {}
    guasti: list[str] = []
    lenti: list[str] = []
    giorni_cert: list[float] = []

    for nome, campioni in letture.items():
        validi = [c for c in campioni if not c.errore]
        errori = [c.errore for c in campioni if c.errore]
        if errori:
            guasti.append(f"{nome}: {errori[0]}")
        for c in validi:
            if c.stato_http != 200:
                guasti.append(f"{nome}: risposta HTTP {c.stato_http}")
                break
            if not c.marcatore_trovato:
                guasti.append(f"{nome}: contenuto inatteso, marcatore assente")
                break
        tempi = [c.primo_byte_s for c in validi if c.primo_byte_s is not None]
        if tempi:
            mediana = statistics.median(tempi)
            misure[f"{nome}_primo_byte_s"] = round(mediana, 3)
            if mediana > soglie[nome]:
                lenti.append(f"{nome}: primo byte {mediana:.2f} s oltre la soglia di {soglie[nome]:.2f} s")
        giorni_cert += [c.giorni_certificato for c in validi if c.giorni_certificato is not None]

    if giorni_cert:
        misure["giorni_certificato"] = round(min(giorni_cert), 1)

    if guasti:
        if not riferimento_ok():
            return Esito(IMPOSSIBILE, guasti + [f"anche il riferimento {cfg.riferimento} non risponde"], misure)
        return Esito(ALLARME, guasti, misure)
    motivi = list(lenti)
    if giorni_cert and min(giorni_cert) < cfg.giorni_certificato:
        motivi.append(
            f"certificato in scadenza fra {min(giorni_cert):.0f} giorni, soglia {cfg.giorni_certificato}: "
            "il rinnovo automatico del proxy non e' avvenuto"
        )
    return Esito(ALLARME if motivi else SANO, motivi, misure)


def transizione(stato_salvato: dict, esito: Esito, consecutivi: int) -> tuple[dict, bool]:
    """Aggiorna lo stato persistito e dice se va mandato un avviso.

    Si avvisa quando lo stato misurato differisce da quello gia' notificato per
    `consecutivi` esecuzioni di fila. Al primo avvio lo stato notificato e' sano, cosi'
    un sito gia' guasto quando la sonda parte produce comunque un avviso.
    """
    notificato = stato_salvato.get("notificato", SANO)
    if esito.stato == stato_salvato.get("ultimo"):
        serie = stato_salvato.get("serie", 0) + 1
    else:
        serie = 1
    nuovo = {"ultimo": esito.stato, "serie": serie, "notificato": notificato}
    if esito.stato != notificato and serie >= consecutivi:
        nuovo["notificato"] = esito.stato
        return nuovo, True
    return nuovo, False


def messaggio(cfg: Configurazione, esito: Esito, istante: str) -> str:
    titoli = {
        SANO: "Sito nuovo: rientrato, di nuovo sano",
        ALLARME: "Sito nuovo: ALLARME",
        IMPOSSIBILE: "Sito nuovo: misura impossibile dalla sede",
    }
    righe = [titoli[esito.stato], "", f"Istante: {istante}", f"Pagina: {cfg.url_pagina}", f"Applicazione: {cfg.url_app}"]
    righe += [f"- {m}" for m in esito.motivi]
    righe += [f"{k}: {v}" for k, v in esito.misure.items()]
    if esito.stato == IMPOSSIBILE:
        righe += ["", "Non dice che il sito e' giu': dice che dalla sede non si esce. Verificare il collegamento."]
    return "\n".join(righe) + "\n"


def avvisa(cfg: Configurazione, testo: str) -> bool:
    if not cfg.comando_avviso:
        print("AVVISO (nessun comando configurato):\n" + testo, file=sys.stderr)
        return True
    try:
        subprocess.run(shlex.split(cfg.comando_avviso), input=testo, text=True, check=True, timeout=60)
        return True
    except (OSError, subprocess.SubprocessError) as exc:
        print(f"avviso non recapitato: {exc}", file=sys.stderr)
        return False


def accoda_serie(percorso: Path, riga: dict) -> None:
    righe = percorso.read_text(encoding="utf-8").splitlines() if percorso.exists() else []
    righe.append(json.dumps(riga, ensure_ascii=False))
    percorso.write_text("\n".join(righe[-RIGHE_SERIE_MAX:]) + "\n", encoding="utf-8")


def esegui(cfg: Configurazione, lettore=leggi, sonda_riferimento=raggiungibile, avvisatore=avvisa) -> Esito:
    letture = {
        "pagina": [lettore(cfg.url_pagina, cfg.marcatore_pagina, cfg.timeout_s) for _ in range(cfg.campioni)],
        "app": [lettore(cfg.url_app, cfg.marcatore_app, cfg.timeout_s) for _ in range(cfg.campioni)],
    }
    esito = valuta(cfg, letture, lambda: sonda_riferimento(cfg.riferimento, cfg.timeout_s))
    istante = datetime.now(timezone.utc).isoformat(timespec="seconds")

    cfg.cartella_stato.mkdir(parents=True, exist_ok=True)
    file_stato = cfg.cartella_stato / "stato.json"
    salvato = json.loads(file_stato.read_text(encoding="utf-8")) if file_stato.exists() else {}
    nuovo, da_avvisare = transizione(salvato, esito, cfg.consecutivi)
    if da_avvisare and not avvisatore(cfg, messaggio(cfg, esito, istante)):
        # Avviso fallito: lo stato notificato resta quello vecchio e si ritenta al giro dopo.
        nuovo["notificato"] = salvato.get("notificato", SANO)
    file_stato.write_text(json.dumps(nuovo), encoding="utf-8")
    accoda_serie(cfg.cartella_stato / "serie.jsonl", {"t": istante, "stato": esito.stato, **esito.misure})

    print(f"{esito.stato} {json.dumps(esito.misure)}" + "".join(f"\n  {m}" for m in esito.motivi))
    return esito


def main() -> int:
    try:
        cfg = Configurazione.da_ambiente()
    except ValueError as exc:
        print(f"configurazione: {exc}", file=sys.stderr)
        return CODICI[IMPOSSIBILE]
    return CODICI[esegui(cfg).stato]


if __name__ == "__main__":
    sys.exit(main())
