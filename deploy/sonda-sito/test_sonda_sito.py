"""Prove della sonda del sito, senza rete: le letture sono costruite a mano.

Ogni caso esercita il ramo che dichiara, e due mutazioni sono state provate contro
queste prove nel giorno in cui sono nate (registro del runbook, 29/10/2026).
"""

import json
import tempfile
import unittest
from pathlib import Path

import sonda_sito as s


def cfg(cartella: Path, **extra) -> s.Configurazione:
    env = {
        "SONDA_URL_PAGINA": "https://sito.example/",
        "SONDA_URL_APP": "https://sito.example/api/pages?limit=1",
        "SONDA_CARTELLA_STATO": str(cartella),
    }
    env.update(extra)
    return s.Configurazione.da_ambiente(env)


def buona(primo_byte=0.15, giorni=80.0):
    return s.Lettura(200, primo_byte, primo_byte + 0.1, giorni, True)


class Valutazione(unittest.TestCase):
    def setUp(self):
        self.c = cfg(Path("."))

    def letture(self, pagina, app):
        return {"pagina": pagina, "app": app}

    def test_sano(self):
        e = s.valuta(self.c, self.letture([buona()] * 3, [buona(0.18)] * 3), lambda: True)
        self.assertEqual(e.stato, s.SANO)
        self.assertEqual(e.misure["app_primo_byte_s"], 0.18)

    def test_lento_oltre_soglia_e_allarme(self):
        e = s.valuta(self.c, self.letture([buona()] * 3, [buona(1.5)] * 3), lambda: True)
        self.assertEqual(e.stato, s.ALLARME)
        self.assertIn("app: primo byte", e.motivi[0])

    def test_un_campione_lento_non_basta(self):
        e = s.valuta(self.c, self.letture([buona()] * 3, [buona(), buona(), buona(3.0)]), lambda: True)
        self.assertEqual(e.stato, s.SANO)

    def test_http_500_e_allarme(self):
        rotta = s.Lettura(500, 0.1, 0.1, 80.0, False)
        e = s.valuta(self.c, self.letture([buona()] * 3, [rotta] * 3), lambda: True)
        self.assertEqual(e.stato, s.ALLARME)

    def test_200_senza_marcatore_e_allarme(self):
        vuota = s.Lettura(200, 0.1, 0.1, 80.0, False)
        e = s.valuta(self.c, self.letture([vuota] * 3, [buona()] * 3), lambda: True)
        self.assertEqual(e.stato, s.ALLARME)
        self.assertIn("marcatore", e.motivi[0])

    def test_errore_con_riferimento_raggiungibile_e_allarme(self):
        giu = s.Lettura(errore="ConnectionRefusedError")
        e = s.valuta(self.c, self.letture([giu] * 3, [giu] * 3), lambda: True)
        self.assertEqual(e.stato, s.ALLARME)

    def test_errore_senza_riferimento_e_misura_impossibile(self):
        giu = s.Lettura(errore="timeout")
        e = s.valuta(self.c, self.letture([giu] * 3, [giu] * 3), lambda: False)
        self.assertEqual(e.stato, s.IMPOSSIBILE)

    def test_riferimento_non_interrogato_se_il_sito_risponde(self):
        def esplode():
            raise AssertionError("riferimento interrogato senza motivo")

        s.valuta(self.c, self.letture([buona()] * 3, [buona()] * 3), esplode)

    def test_certificato_vicino_alla_scadenza_e_allarme(self):
        e = s.valuta(self.c, self.letture([buona(giorni=12)] * 3, [buona(giorni=12)] * 3), lambda: True)
        self.assertEqual(e.stato, s.ALLARME)
        self.assertIn("certificato", e.motivi[0])


class Transizioni(unittest.TestCase):
    def test_avviso_solo_dopo_due_esecuzioni_e_al_rientro(self):
        stato, inviati = {}, []
        sequenza = [s.SANO, s.ALLARME, s.ALLARME, s.ALLARME, s.SANO, s.SANO, s.SANO]
        for st in sequenza:
            stato, avvisa = s.transizione(stato, s.Esito(st), 2)
            inviati.append(avvisa)
        self.assertEqual(inviati, [False, False, True, False, False, True, False])

    def test_oscillazione_non_avvisa(self):
        stato, inviati = {}, []
        for st in [s.ALLARME, s.SANO, s.ALLARME, s.SANO]:
            stato, avvisa = s.transizione(stato, s.Esito(st), 2)
            inviati.append(avvisa)
        self.assertEqual(inviati, [False] * 4)


class Esecuzione(unittest.TestCase):
    def test_avviso_fallito_si_ritenta(self):
        with tempfile.TemporaryDirectory() as d:
            c = cfg(Path(d))
            giu = lambda *a: s.Lettura(500, 0.1, 0.1, 80.0, False)
            esiti = []
            for recapita in (False, False, True, True):
                chiamate = []

                def avvisatore(_c, testo, chiamate=chiamate, ok=recapita):
                    chiamate.append(testo)
                    return ok

                s.esegui(c, lettore=giu, sonda_riferimento=lambda *a: True, avvisatore=avvisatore)
                esiti.append(len(chiamate))
            # giro 1: serie 1, niente; giro 2: tentativo fallito; giro 3: ritenta e riesce; giro 4: gia' notificato
            self.assertEqual(esiti, [0, 1, 1, 0])
            stato = json.loads((Path(d) / "stato.json").read_text())
            self.assertEqual(stato["notificato"], s.ALLARME)
            self.assertEqual(len((Path(d) / "serie.jsonl").read_text().splitlines()), 4)

    def test_configurazione_incompleta_e_misura_impossibile(self):
        with self.assertRaises(ValueError):
            s.Configurazione.da_ambiente({"SONDA_URL_PAGINA": "https://x/"})


if __name__ == "__main__":
    unittest.main()
