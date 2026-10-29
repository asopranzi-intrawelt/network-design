#!/usr/bin/env python3
"""Salvataggio notturno del sito nuovo (G17, ADR-044), eseguito dal contenitore backup-sito.

Il contenitore va a prendere la copia, la VPS non la spinge: la VPS non deve poter
raggiungere la rete della sede, mentre la sede raggiunge gia' la VPS. La chiave usata
sulla VPS e' legata al solo comando `copia-sito`, che restituisce un archivio tar con la
copia logica della banca dati e le due cartelle dei file caricati.

Ogni notte:
  1. controlla che la destinazione sul NAS sia montata e scrivibile;
  2. riceve l'archivio in un file temporaneo;
  3. lo verifica: contiene la banca dati e le due cartelle, e pg_restore elenca almeno
     il numero di tabelle atteso; una copia che non supera la verifica non sostituisce
     nessuna copia buona;
  4. lo conserva fra le giornaliere, la domenica anche fra le settimanali e il primo del
     mese anche fra le mensili, e tiene in ciascuna cartella solo le piu' recenti;
  5. scrive lo stato e una riga di serie.

Tre esiti, con codice d'uscita distinto: 0 sano, 1 allarme (la copia e' arrivata ma non
supera la verifica, o il comando remoto e' fallito), 2 copia impossibile (destinazione
assente o non scrivibile, configurazione incompleta). In caso di esito diverso da sano
l'avviso parte a ogni esecuzione: e' un lavoro notturno, uno al giorno.

Solo libreria standard, piu' `pg_restore` del pacchetto del client PostgreSQL. La
configurazione arriva dall'ambiente: il modello dei nomi sta in salva-sito.conf.esempio.
"""

from __future__ import annotations

import json
import os
import shlex
import shutil
import subprocess
import sys
import tarfile
import tempfile
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

SANO, ALLARME, IMPOSSIBILE = "sano", "allarme", "copia_impossibile"
CODICI = {SANO: 0, ALLARME: 1, IMPOSSIBILE: 2}
NOME_DUMP = "banca-dati.dump"
CARTELLE_ATTESE = ("media", "private-uploads")
RIGHE_SERIE_MAX = 2000


@dataclass
class Configurazione:
    destinazione: Path
    comando: list[str]
    tabelle_minime: int
    giornaliere: int
    settimanali: int
    mensili: int
    timeout_s: int
    cartella_stato: Path
    comando_avviso: str
    pg_restore: str

    @classmethod
    def da_ambiente(cls, env: dict[str, str] | None = None) -> "Configurazione":
        env = dict(os.environ if env is None else env)
        if env.get("SALVA_COMANDO"):
            comando = shlex.split(env["SALVA_COMANDO"])
        else:
            mancanti = [n for n in ("SALVA_SSH", "SALVA_CHIAVE", "SALVA_KNOWN_HOSTS") if not env.get(n)]
            if mancanti:
                raise ValueError("variabili assenti: " + ", ".join(mancanti))
            comando = [
                "ssh", "-i", env["SALVA_CHIAVE"],
                "-o", "BatchMode=yes", "-o", "IdentitiesOnly=yes",
                "-o", "StrictHostKeyChecking=yes", "-o", f"UserKnownHostsFile={env['SALVA_KNOWN_HOSTS']}",
                "-o", "ConnectTimeout=20", env["SALVA_SSH"], "copia-sito",
            ]
        if not env.get("SALVA_DESTINAZIONE"):
            raise ValueError("variabile assente: SALVA_DESTINAZIONE")
        return cls(
            destinazione=Path(env["SALVA_DESTINAZIONE"]),
            comando=comando,
            tabelle_minime=int(env.get("SALVA_TABELLE_MINIME", "1")),
            giornaliere=int(env.get("SALVA_GIORNALIERE", "14")),
            settimanali=int(env.get("SALVA_SETTIMANALI", "8")),
            mensili=int(env.get("SALVA_MENSILI", "12")),
            timeout_s=int(env.get("SALVA_TIMEOUT_S", "1800")),
            cartella_stato=Path(env.get("SALVA_CARTELLA_STATO") or env.get("STATE_DIRECTORY") or "."),
            comando_avviso=env.get("SALVA_COMANDO_AVVISO", ""),
            pg_restore=env.get("SALVA_PG_RESTORE", "pg_restore"),
        )


@dataclass
class Esito:
    stato: str
    motivi: list[str] = field(default_factory=list)
    misure: dict = field(default_factory=dict)


def destinazione_pronta(cartella: Path) -> str:
    """Stringa vuota se si puo' scrivere, altrimenti il motivo."""
    if not cartella.is_dir():
        return f"destinazione {cartella} assente"
    prova = cartella / ".prova-scrittura"
    try:
        prova.write_bytes(b"ok")
        prova.unlink()
    except OSError as exc:
        return f"destinazione {cartella} non scrivibile: {exc}"
    return ""


def conta_tabelle(dump: Path, pg_restore: str) -> int:
    """Blocchi di dati di tabella nella copia, letti con pg_restore senza ripristinare."""
    uscita = subprocess.run([pg_restore, "--list", str(dump)], capture_output=True, text=True, check=True)
    return sum(1 for riga in uscita.stdout.splitlines() if " TABLE DATA " in riga)


def verifica(archivio: Path, cfg: Configurazione, contatore=conta_tabelle) -> tuple[list[str], dict]:
    """Motivi di scarto (lista vuota se la copia e' buona) e misure."""
    motivi, misure = [], {"byte": archivio.stat().st_size}
    try:
        with tarfile.open(archivio) as tar:
            nomi = tar.getnames()
            radici = {n.split("/", 1)[0] for n in nomi}
            for attesa in CARTELLE_ATTESE:
                if attesa not in radici:
                    motivi.append(f"cartella {attesa} assente dalla copia")
            misure["file"] = sum(1 for m in tar.getmembers() if m.isfile())
            if NOME_DUMP not in nomi:
                motivi.append("copia della banca dati assente")
                return motivi, misure
            with tempfile.TemporaryDirectory() as tmp:
                tar.extract(NOME_DUMP, tmp, filter="data")
                tabelle = contatore(Path(tmp) / NOME_DUMP, cfg.pg_restore)
    except (tarfile.TarError, OSError, subprocess.CalledProcessError) as exc:
        motivi.append(f"copia illeggibile: {type(exc).__name__}: {exc}")
        return motivi, misure
    misure["tabelle"] = tabelle
    if tabelle < cfg.tabelle_minime:
        motivi.append(f"{tabelle} tabelle nella copia, ne sono attese almeno {cfg.tabelle_minime}")
    return motivi, misure


def conserva(archivio: Path, cfg: Configurazione, adesso: datetime) -> str:
    """Mette la copia buona al suo posto e applica la conservazione. Restituisce il nome."""
    nome = f"sito-{adesso:%Y%m%d-%H%M}.tar"
    giornaliere = cfg.destinazione / "giornaliere"
    giornaliere.mkdir(exist_ok=True)
    finale = giornaliere / nome
    # Su CIFS il collegamento fisico non e' garantito: la settimanale e la mensile sono copie.
    shutil.move(str(archivio), finale)
    if adesso.isoweekday() == 7:
        (cfg.destinazione / "settimanali").mkdir(exist_ok=True)
        shutil.copyfile(finale, cfg.destinazione / "settimanali" / nome)
    if adesso.day == 1:
        (cfg.destinazione / "mensili").mkdir(exist_ok=True)
        shutil.copyfile(finale, cfg.destinazione / "mensili" / nome)
    for cartella, tenere in (("giornaliere", cfg.giornaliere), ("settimanali", cfg.settimanali), ("mensili", cfg.mensili)):
        pota(cfg.destinazione / cartella, tenere)
    return nome


def pota(cartella: Path, tenere: int) -> list[str]:
    """Tiene le `tenere` copie piu' recenti; il nome porta la data, quindi l'ordine e' quello del nome."""
    if not cartella.is_dir():
        return []
    copie = sorted(p for p in cartella.glob("sito-*.tar"))
    via = copie[:-tenere] if tenere > 0 else copie
    for p in via:
        p.unlink()
    return [p.name for p in via]


def avvisa(cfg: Configurazione, testo: str) -> None:
    if not cfg.comando_avviso:
        print("AVVISO (nessun comando configurato):\n" + testo, file=sys.stderr)
        return
    try:
        subprocess.run(shlex.split(cfg.comando_avviso), input=testo, text=True, check=True, timeout=60)
    except (OSError, subprocess.SubprocessError) as exc:
        print(f"avviso non recapitato: {exc}", file=sys.stderr)


def esegui(cfg: Configurazione, adesso: datetime | None = None, contatore=conta_tabelle, avvisatore=avvisa) -> Esito:
    adesso = adesso or datetime.now()
    motivo = destinazione_pronta(cfg.destinazione)
    if motivo:
        esito = Esito(IMPOSSIBILE, [motivo])
    else:
        parziale = cfg.destinazione / f".in-arrivo-{adesso:%Y%m%d-%H%M%S}.tar"
        try:
            with parziale.open("wb") as f:
                ricevuta = subprocess.run(cfg.comando, stdout=f, stderr=subprocess.PIPE, timeout=cfg.timeout_s)
            if ricevuta.returncode != 0:
                errore = ricevuta.stderr.decode(errors="replace").strip()[-400:]
                esito = Esito(ALLARME, [f"comando di copia uscito con {ricevuta.returncode}: {errore}"])
            else:
                motivi, misure = verifica(parziale, cfg, contatore)
                if motivi:
                    esito = Esito(ALLARME, motivi, misure)
                else:
                    misure["copia"] = conserva(parziale, cfg, adesso)
                    esito = Esito(SANO, [], misure)
        except (OSError, subprocess.SubprocessError) as exc:
            esito = Esito(ALLARME, [f"copia non ricevuta: {type(exc).__name__}: {exc}"])
        finally:
            if parziale.exists():
                parziale.unlink()

    istante = datetime.now(timezone.utc).isoformat(timespec="seconds")
    cfg.cartella_stato.mkdir(parents=True, exist_ok=True)
    (cfg.cartella_stato / "stato.json").write_text(
        json.dumps({"istante": istante, "stato": esito.stato, "motivi": esito.motivi, **esito.misure}), encoding="utf-8"
    )
    serie = cfg.cartella_stato / "serie.jsonl"
    righe = serie.read_text(encoding="utf-8").splitlines() if serie.exists() else []
    righe.append(json.dumps({"t": istante, "stato": esito.stato, **esito.misure}))
    serie.write_text("\n".join(righe[-RIGHE_SERIE_MAX:]) + "\n", encoding="utf-8")

    if esito.stato != SANO:
        avvisatore(cfg, f"Salvataggio del sito: {esito.stato}\nIstante: {istante}\n" + "".join(f"- {m}\n" for m in esito.motivi))
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
