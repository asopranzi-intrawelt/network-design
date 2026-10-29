"""Prove del salvataggio notturno, senza rete e senza PostgreSQL: il contatore delle
tabelle e il comando remoto sono sostituiti. La prova con pg_dump vero sta nel registro
del runbook (contenitore Debian e PostgreSQL 17, 29/10/2026).
"""

import io
import json
import sys
import tarfile
import tempfile
import unittest
from datetime import datetime
from pathlib import Path

import salva_sito as s


def archivio(percorso: Path, dump=True, cartelle=("media", "private-uploads")) -> Path:
    with tarfile.open(percorso, "w") as tar:
        for c in cartelle:
            info = tarfile.TarInfo(f"{c}/file.bin")
            dati = b"x" * 10
            info.size = len(dati)
            tar.addfile(info, io.BytesIO(dati))
        if dump:
            info = tarfile.TarInfo(s.NOME_DUMP)
            info.size = 4
            tar.addfile(info, io.BytesIO(b"PGDM"))
    return percorso


class Base(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.radice = Path(self.tmp.name)
        self.nas = self.radice / "nas"
        self.nas.mkdir()
        self.sorgente = archivio(self.radice / "sorgente.tar")

    def tearDown(self):
        self.tmp.cleanup()

    def cfg(self, **extra):
        env = {
            "SALVA_DESTINAZIONE": str(self.nas),
            "SALVA_COMANDO": f'"{sys.executable}" -c "import sys,shutil;shutil.copyfileobj(open(sys.argv[1],\'rb\'),sys.stdout.buffer)" "{self.sorgente}"',
            "SALVA_TABELLE_MINIME": "10",
            "SALVA_CARTELLA_STATO": str(self.radice / "stato"),
        }
        env.update(extra)
        return s.Configurazione.da_ambiente(env)


class Verifica(Base):
    def test_copia_completa_e_sana(self):
        e = s.esegui(self.cfg(), datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        self.assertEqual(e.stato, s.SANO)
        self.assertTrue((self.nas / "giornaliere" / "sito-20261103-0230.tar").exists())
        self.assertEqual(json.loads((self.radice / "stato" / "stato.json").read_text())["tabelle"], 343)

    def test_poche_tabelle_e_allarme_e_non_conserva(self):
        e = s.esegui(self.cfg(), datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 3, avvisatore=lambda *a: None)
        self.assertEqual(e.stato, s.ALLARME)
        self.assertFalse((self.nas / "giornaliere").exists())
        self.assertEqual(list(self.nas.iterdir()), [])  # nessun parziale lasciato

    def test_senza_banca_dati_e_allarme(self):
        archivio(self.sorgente, dump=False)
        e = s.esegui(self.cfg(), datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        self.assertEqual(e.stato, s.ALLARME)
        self.assertIn("banca dati", e.motivi[0])

    def test_senza_file_riservati_e_allarme(self):
        archivio(self.sorgente, cartelle=("media",))
        e = s.esegui(self.cfg(), datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        self.assertEqual(e.stato, s.ALLARME)

    def test_comando_fallito_e_allarme(self):
        cfg = self.cfg(SALVA_COMANDO=f'"{sys.executable}" -c "import sys;sys.exit(3)"')
        e = s.esegui(cfg, datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        self.assertEqual(e.stato, s.ALLARME)

    def test_destinazione_assente_e_impossibile(self):
        cfg = self.cfg(SALVA_DESTINAZIONE=str(self.radice / "non-montato"))
        e = s.esegui(cfg, datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        self.assertEqual(e.stato, s.IMPOSSIBILE)

    def test_avviso_solo_se_non_sano(self):
        inviati = []
        s.esegui(self.cfg(), datetime(2026, 11, 3, 2, 30), contatore=lambda *a: 343, avvisatore=lambda c, t: inviati.append(t))
        s.esegui(self.cfg(), datetime(2026, 11, 4, 2, 30), contatore=lambda *a: 3, avvisatore=lambda c, t: inviati.append(t))
        self.assertEqual(len(inviati), 1)


class Conservazione(Base):
    def test_domenica_e_primo_del_mese(self):
        # 01/11/2026 e' una domenica: la copia va in tutte e tre le cartelle.
        s.esegui(self.cfg(), datetime(2026, 11, 1, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        for c in ("giornaliere", "settimanali", "mensili"):
            self.assertTrue((self.nas / c / "sito-20261101-0230.tar").exists(), c)

    def test_giornaliere_tenute_quattordici(self):
        for g in range(1, 21):
            s.esegui(self.cfg(), datetime(2026, 12, g, 2, 30), contatore=lambda *a: 343, avvisatore=lambda *a: None)
        rimaste = sorted(p.name for p in (self.nas / "giornaliere").iterdir())
        self.assertEqual(len(rimaste), 14)
        self.assertEqual(rimaste[0], "sito-20261207-0230.tar")
        self.assertEqual(len(list((self.nas / "settimanali").iterdir())), 3)  # 6, 13, 20 dicembre
        self.assertEqual(len(list((self.nas / "mensili").iterdir())), 1)


if __name__ == "__main__":
    unittest.main()
