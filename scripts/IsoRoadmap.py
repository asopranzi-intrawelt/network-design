#!/usr/bin/env python3
"""Registro operativo ISO 27001: fonte e vista di progetto, export HTML su richiesta.

Uso:
  python scripts/IsoRoadmap.py build
  python scripts/IsoRoadmap.py build --desktop
  python scripts/IsoRoadmap.py advance ISO-01 --stato in_corso --nota "..."
  python scripts/IsoRoadmap.py advance ISO-01 --stato completato --nota "..." --evidenza "docs/..."
  python scripts/IsoRoadmap.py check
  python scripts/IsoRoadmap.py check --desktop

`advance` aggiorna sempre la fonte e la vista nel progetto. L'HTML e' un
export di sola lettura, aggiornato solo con `build --desktop` o con
`advance --desktop` esplicitamente richiesto; ogni export scrive Desktop
e copia nella cartella ISO configurata nel livello privato.
"""

from __future__ import annotations

import argparse
import base64
import html
import json
import os
import re
import sys
from collections import Counter
from datetime import date
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "data" / "iso27001-interventi.json"
MARKDOWN = ROOT / "docs" / "roadmap-iso27001-operativa.md"
STYLE = ROOT / "scripts" / "iso-roadmap-style.css"
INTERACTIONS = ROOT / "scripts" / "iso-roadmap-interactions.js"
GLOSSARY = ROOT / "data" / "iso27001-glossario.json"
PRIVATE_BRAND = ROOT / "_notes" / "iso-roadmap-brand.json"
DESKTOP_NAME = "Roadmap ISO 27001 - rete.html"
STATI = {"da_fare", "in_corso", "bloccato", "completato", "non_applicabile"}
FORNITURE = {"nessuna", "necessaria", "condizionata", "da_verificare"}
LABEL_STATI = {
    "da_fare": "Da fare", "in_corso": "In corso", "bloccato": "Bloccato",
    "completato": "Completato", "non_applicabile": "Non applicabile",
}
LABEL_FORNITURE = {
    "nessuna": "Nessuna fornitura prevista",
    "necessaria": "FORNITURA NECESSARIA",
    "condizionata": "FORNITURA CONDIZIONATA",
    "da_verificare": "FORNITURA DA VERIFICARE",
}
REFERENCE_PATTERN = re.compile(
    r"(?<!\w)(?:#\d+|R\d+(?:-R\d+)?|M\d+[a-z]?(?:-\d+)?(?:-M\d+[a-z]?(?:-\d+)?)?"
    r"|ADR-\d+|FW-\d+|A\.[5-8]\.\d+|ISO-\d{2}"
    r"|ISO/IEC 27001:2022(?:/Amd 1:2024)?)(?!\w)"
)


def glossary(data: dict) -> dict:
    with GLOSSARY.open(encoding="utf-8") as handle:
        source = json.load(handle)
    entries = source["voci"]
    for code, entry in entries.items():
        if not isinstance(entry, list) or len(entry) != 2 or not all(isinstance(part, str) and part.strip() for part in entry):
            raise ValueError(f"Voce glossario incompleta: {code}")
    catalog = {code: {"titolo": value[0], "spiegazione": value[1]} for code, value in entries.items()}
    for item in data["interventi"]:
        catalog[item["id"]] = {
            "titolo": item["titolo"],
            "spiegazione": item["azione"],
        }
    found = {match.group() for match in REFERENCE_PATTERN.finditer(json.dumps(data, ensure_ascii=False))}
    found.update(control for item in data["interventi"] for control in item["controlli"])
    missing = sorted(found - catalog.keys())
    if missing:
        raise ValueError("Mancano le spiegazioni di: " + ", ".join(missing))
    return catalog


def reference_html(value: str, catalog: dict, controls: bool = False) -> str:
    """Link interni per i codici noti; il resto del testo resta escaped."""
    terms = sorted(catalog, key=len, reverse=True)
    if not controls:
        terms = [term for term in terms if not re.fullmatch(r"\d+(?:\.\d+)*|4-10", term)]
    pattern = re.compile(r"(?<![\w])(?:" + "|".join(re.escape(term) for term in terms) + r")(?![\w])")
    pieces = []
    previous = 0
    for match in pattern.finditer(str(value)):
        pieces.append(html.escape(str(value)[previous:match.start()], quote=True))
        code = match.group()
        pieces.append(f"<a class='ref-link' href='#ref={quote(code, safe='')}' title='Apri spiegazione di {html.escape(code, quote=True)}'>{html.escape(code)}</a>")
        previous = match.end()
    pieces.append(html.escape(str(value)[previous:], quote=True))
    return "".join(pieces)


def load() -> dict:
    with SOURCE.open(encoding="utf-8") as handle:
        data = json.load(handle)
    validate(data)
    glossary(data)
    return data


def validate(data: dict) -> None:
    if not isinstance(data.get("fasi"), list) or not isinstance(data.get("interventi"), list):
        raise ValueError("Mancano fasi o interventi")
    phases = {phase["id"] for phase in data["fasi"]}
    ids = [item["id"] for item in data["interventi"]]
    if len(ids) != len(set(ids)):
        raise ValueError("Identificativi duplicati")
    for item in data["interventi"]:
        for key in ("id", "fase", "titolo", "azione", "verifica", "responsabile", "fonti", "controlli", "fornitura", "stato_iniziale"):
            if key not in item:
                raise ValueError(f"{item.get('id', '?')}: manca {key}")
        if item["fase"] not in phases or item["stato_iniziale"] not in STATI:
            raise ValueError(f"{item['id']}: fase o stato iniziale invalido")
        if item["fornitura"]["stato"] not in FORNITURE:
            raise ValueError(f"{item['id']}: stato fornitura invalido")
        if item["fornitura"]["stato"] != "nessuna" and not item["fornitura"].get("dettaglio"):
            raise ValueError(f"{item['id']}: descrivere la fornitura")
        if any(dep not in ids for dep in item.get("dipende_da", [])):
            raise ValueError(f"{item['id']}: dipendenza sconosciuta")
        if not item["fonti"] or not item["controlli"]:
            raise ValueError(f"{item['id']}: fonti e controlli sono obbligatori")
    for event in data.get("eventi", []):
        if event["id"] not in ids or event["stato"] not in STATI:
            raise ValueError("Evento con ID o stato invalido")
        date.fromisoformat(event["data"])
        if not event.get("nota", "").strip():
            raise ValueError("Ogni avanzamento richiede una nota")
        if event["stato"] == "completato" and not event.get("evidenza", "").strip():
            raise ValueError("La chiusura richiede un'evidenza")


def current(data: dict) -> dict:
    states = {item["id"]: {"stato": item["stato_iniziale"], "nota": item.get("stato_nota", ""), "data": data["data_base"], "evidenza": ""} for item in data["interventi"]}
    for event in data.get("eventi", []):
        states[event["id"]] = event
    return states


def md_escape(value: str) -> str:
    return str(value).replace("|", "\\|").replace("\n", " ")


def brand_logo_uri() -> str:
    """Incorpora il solo logo locale nell'export; nessun asset entra nel repository."""
    if not PRIVATE_BRAND.exists():
        return ""
    config = json.loads(PRIVATE_BRAND.read_text(encoding="utf-8"))
    path = Path(config["logo_png"])
    if path.suffix.lower() != ".png" or not path.is_file():
        raise ValueError("Logo PNG locale non trovato o non valido nella configurazione privata")
    raw = path.read_bytes()
    if len(raw) > 2_000_000:
        raise ValueError("Il logo supera 2 MB")
    return "data:image/png;base64," + base64.b64encode(raw).decode("ascii")


def render_markdown(data: dict) -> str:
    states = current(data)
    counts = Counter(value["stato"] for value in states.values())
    supply_counts = Counter(item["fornitura"]["stato"] for item in data["interventi"])
    lines = [
        "# Roadmap operativa ISO 27001 della rete",
        "",
        "> File generato da `data/iso27001-interventi.json` con `python scripts/IsoRoadmap.py build`. Non modificare questa vista a mano.",
        "",
        f"Fotografia iniziale: {data['data_base']}. Ultimo avanzamento registrato: {data['aggiornato']}. Obiettivo di progetto: marzo 2027. Le scadenze delle fasi sono proposte operative, non attestazioni di conformita'.",
        "",
        "## Come si usa",
        "",
        "- Aprire questa lista per scegliere il prossimo intervento. Ogni voce specifica azione, prova di chiusura, responsabile, dipendenze e fornitura.",
        "- **Stati:** da fare = non iniziato; in corso = avviato ma senza prova di chiusura; bloccato = in attesa di un prerequisito; completato = chiuso con evidenza datata; non applicabile = esclusione motivata.",
        "- **Forniture:** necessaria = serve un acquisto o servizio; condizionata = solo se diagnosi o decisione lo richiedono; da verificare = controllare prima se esiste gia'; nessuna = non prevista.",
        "- Per ogni avanzamento comunicato o realizzato, l'agente aggiorna il registro nella stessa sessione: azione, stato, fornitura e nota datata. Il comando `advance` rigenera questa vista nel progetto, senza richiedere azioni all'utente.",
        "- L'HTML e' una copia di sola lettura: si esporta solo su richiesta con `python scripts/IsoRoadmap.py build --desktop`, che aggiorna insieme Desktop e cartella ISO OneDrive configurata privatamente. Puo' essere piu' vecchio del registro; non va modificato a mano.",
        "- Nell'HTML le sigle aprono una vista interna allo stesso file. Le spiegazioni vivono in `data/iso27001-glossario.json`; quelle dei controlli ISO sono parafrasi operative, non il testo della norma.",
        "- Una voce si chiude solo con una prova datata (`--evidenza`); non trascrivere dati reali o segreti nel registro pubblico.",
        "- Cambiamenti fisici non ancora comunicati o misurabili non possono essere rilevati dal registro: in quel caso la voce resta da verificare fino a sopralluogo o evidenza.",
        "- Prima del commit manuale eseguire `python scripts/IsoRoadmap.py check`, `python scripts/Test-Anonymization.py` e `python tools/md-unwrap.py --check .`.",
        "",
        "## Stato del programma",
        "",
        f"- Interventi: **{len(states)}**; da fare {counts['da_fare']}, in corso {counts['in_corso']}, bloccati {counts['bloccato']}, completati {counts['completato']}, non applicabili {counts['non_applicabile']}.",
        f"- Forniture: **{supply_counts['necessaria']} necessarie**, {supply_counts['condizionata']} condizionate da diagnosi o decisione, {supply_counts['da_verificare']} da verificare. Le etichette indicano una necessita' tecnica o di servizio, non un acquisto autorizzato.",
        "- Le configurazioni di firewall, il ripristino dei backup e l'indipendenza elettrica richiedono ancora prove dirette; la riconciliazione della mappa non li certifica.",
        "- La checklist ISO locale conta 93 controlli ma non contiene prove compilate; lo Statement of Applicability va riconciliato con misure e documenti datati.",
        "",
        "## Forniture e decisioni di approvvigionamento",
        "",
    ]
    for state in ("necessaria", "condizionata", "da_verificare"):
        entries = [item for item in data["interventi"] if item["fornitura"]["stato"] == state]
        lines.append(f"### {LABEL_FORNITURE[state].capitalize()}")
        lines.append("")
        for item in entries:
            f = item["fornitura"]
            suffix = f" Decisione: {f['decisione']}." if f.get("decisione") else ""
            lines.append(f"- **{item['id']} - {md_escape(item['titolo'])}:** {md_escape(f['dettaglio'])}.{md_escape(suffix)}")
        lines.append("")
    lines += ["## Elenco dettagliato", ""]
    for phase in data["fasi"]:
        lines += [f"### {phase['titolo']} - {phase['orizzonte']}", ""]
        for item in [entry for entry in data["interventi"] if entry["fase"] == phase["id"]]:
            state = states[item["id"]]
            f = item["fornitura"]
            deps = ", ".join(item.get("dipende_da", [])) or "nessuna"
            supply_text = LABEL_FORNITURE[f["stato"]]
            if f.get("dettaglio"):
                supply_text += ". " + md_escape(f["dettaglio"])
            lines += [
                f"- **{item['id']} | {md_escape(item['titolo'])}** - **{LABEL_STATI[state['stato']]}**; {supply_text}.",
                f"  - **Azione:** {md_escape(item['azione'])}",
                f"  - **Chiusura verificabile:** {md_escape(item['verifica'])}",
                f"  - **Responsabile:** {md_escape(item['responsabile'])}. **Dipendenze:** {deps}. **Controlli:** {', '.join(item['controlli'])}.",
                f"  - **Fonti:** {', '.join(md_escape(source) for source in item['fonti'])}.",
            ]
            if state.get("nota"):
                lines.append(f"  - **Ultimo stato ({state['data']}):** {md_escape(state['nota'])}")
            if state.get("evidenza"):
                lines.append(f"  - **Evidenza:** {md_escape(state['evidenza'])}")
            lines.append("")
    lines += [
        "## Limiti delle fonti",
        "",
        "- Baseline di rete documentale al 23/09/2026, tratta esterna corretta dall'IT Manager il 28/09/2026 e riconciliazione automatica Nebula/Proxmox al 28/09/2026: 39 confronti, zero scostamenti sulle sole proprieta' controllate. Il GS-105B non gestito non e' verificabile direttamente da Nebula: la sua eventuale presenza fisica residua richiede sopralluogo.",
        "- Lo snapshot NinjaOne aveva 20 giorni al 28/09/2026; le tre baseline del delta OneDrive ne avevano 20 contro la cadenza di 7 giorni. Il delta generale non e' stato completato durante la ricognizione.",
        "- Le licenze Nebula e Gold Security Pack hanno letture discordanti nel registro: rileggere il pannello prima di proporre un rinnovo. La vecchia scadenza del nuovo access point e' superata dalla misura del 10/09/2026.",
        "- Lo standard di riferimento e' ISO/IEC 27001:2022 con Amd 1:2024; questa lista copre il lavoro emerso dal progetto, non sostituisce la valutazione di applicabilita' di tutti i controlli.",
        "",
    ]
    return "\n".join(lines)


def render_html(data: dict, logo_uri: str = "", exported_on: str | None = None) -> str:
    states = current(data)
    counts = Counter(value["stato"] for value in states.values())
    supply_counts = Counter(item["fornitura"]["stato"] for item in data["interventi"])
    catalog = glossary(data)
    related = {code: [] for code in catalog}
    for item in data["interventi"]:
        references = {match.group() for match in REFERENCE_PATTERN.finditer(json.dumps(item, ensure_ascii=False))}
        references.update(item["controlli"])
        for code in references:
            if code in related:
                related[code].append(item["id"])
    payload = json.dumps({"voci": catalog, "collegati": related}, ensure_ascii=False, separators=(",", ":")).replace("<", "\\u003c")
    e = lambda value: html.escape(str(value), quote=True)
    ref = lambda value: reference_html(value, catalog)
    cards = []
    for phase in data["fasi"]:
        cards.append(f"<section class='phase'><h2>{e(phase['titolo'])}<small>{e(phase['orizzonte'])}</small></h2><ul>")
        for item in [entry for entry in data["interventi"] if entry["fase"] == phase["id"]]:
            state = states[item["id"]]
            supply = item["fornitura"]
            deps = ", ".join(item.get("dipende_da", [])) or "nessuna"
            note = f"<p><b>Ultimo stato ({e(state['data'])}):</b> {ref(state['nota'])}</p>" if state.get("nota") else ""
            proof = f"<p><b>Evidenza:</b> {ref(state['evidenza'])}</p>" if state.get("evidenza") else ""
            cards.append(
                f"<li id='intervento-{e(item['id'])}' tabindex='-1' class='card supply-{supply['stato']}' data-supply='{supply['stato']}' data-status='{state['stato']}'>"
                f"<div class='top'><span class='id'>{ref(item['id'])}</span><h3>{ref(item['titolo'])}</h3>"
                f"<span class='status'>{e(LABEL_STATI[state['stato']])}</span>"
                f"<span class='badge'>{e(LABEL_FORNITURE[supply['stato']])}</span></div>"
                f"<p class='supply-detail'>{ref(supply.get('dettaglio', ''))}</p>"
                f"<p><b>Azione:</b> {ref(item['azione'])}</p>"
                f"<p><b>Chiusura verificabile:</b> {ref(item['verifica'])}</p>"
                f"<p class='meta'><b>Responsabile:</b> {ref(item['responsabile'])} · <b>Dipendenze:</b> {ref(deps)} · <b>Controlli:</b> {reference_html(', '.join(item['controlli']), catalog, controls=True)}</p>"
                f"<p class='meta'><b>Fonti:</b> {ref(', '.join(item['fonti']))}</p>{note}{proof}</li>"
            )
        cards.append("</ul></section>")
    style = STYLE.read_text(encoding="utf-8")
    script = INTERACTIONS.read_text(encoding="utf-8")
    logo = f"<img class='brand-logo' src='{e(logo_uri)}' alt='Logo aziendale'>" if logo_uri else "<span class='brand-wordmark'>Roadmap ISO 27001</span>"
    return (
        "<!doctype html><html lang='it'><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>"
        f"<title>Roadmap ISO 27001 - rete</title><style>{style}</style><body>"
        "<header class='site-header'><div class='site-header-inner'>"
        f"{logo}<span class='header-label'>Cybersecurity<br>e governance IT</span></div></header>"
        "<main><div id='roadmap-view'><div class='hero'><p class='eyebrow'>Piano operativo · ISO/IEC 27001</p>"
        "<h1>Roadmap della rete e della sicurezza</h1>"
        f"<p class='lead'>Fonte del progetto: data/iso27001-interventi.json · Fotografia {e(data['data_base'])} · Ultimo avanzamento {e(data['aggiornato'])} · Obiettivo marzo 2027</p>"
        f"<p class='export-note'>Copia di sola lettura esportata il {exported_on or date.today().isoformat()}. Lo stato di riferimento vive nel progetto; questa pagina si rigenera su richiesta.</p>"
        "<p class='reference-note'>Le sigle sottolineate aprono una scheda rapida in questa pagina. Le descrizioni ISO sono parafrasi operative, non il testo della norma.</p></div>"
        "<section class='reading-guide' aria-labelledby='reading-guide-title'>"
        "<p class='eyebrow'>Guida rapida</p><h2 id='reading-guide-title'>Come leggere questa pagina</h2>"
        "<ol class='reading-steps'>"
        "<li><b>1. Scegli cosa vedere</b><span><strong>Solo aperti</strong> mostra gli interventi non chiusi; <strong>Solo forniture</strong> mostra quelli che richiedono un acquisto o una verifica di disponibilita'.</span></li>"
        "<li><b>2. Leggi una scheda dall'alto</b><span>ID e titolo identificano l'intervento. Poi leggi stato e fornitura; sotto trovi azione, prova necessaria per chiudere, responsabile e dipendenze.</span></li>"
        "<li><b>3. Apri le sigle sottolineate</b><span><code>ISO-xx</code> identifica un intervento del progetto; <code>A.x.x</code> un controllo Annex A; <code>#...</code> un rilievo. Clicca una sigla per la spiegazione rapida e gli interventi collegati.</span></li>"
        "</ol><div class='reading-legends'>"
        "<p><b>Stato:</b> Da fare = non iniziato; In corso = avviato ma senza prova di chiusura; Bloccato = in attesa di un prerequisito; Completato = chiuso con evidenza datata.</p>"
        "<p><b>Fornitura:</b> Necessaria = serve un acquisto o servizio; Condizionata = solo se una diagnosi o decisione lo richiede; Da verificare = controllare prima se esiste gia'; Nessuna = non prevista.</p>"
        "</div><p class='reading-export'>Questa pagina e' una fotografia di sola lettura: la data di esportazione e' indicata sopra. Gli avanzamenti si registrano nel progetto; quando vuoi la copia aggiornata, chiedi <strong>Aggiorna l'HTML ISO</strong>.</p></section>"
        "<div class='summary'><b>Stato del programma</b><ul>"
        f"<li>{len(states)} interventi: {counts['da_fare']} da fare, {counts['in_corso']} in corso, {counts['bloccato']} bloccati, {counts['completato']} completati.</li>"
        f"<li>Forniture: {supply_counts['necessaria']} necessarie, {supply_counts['condizionata']} condizionate, {supply_counts['da_verificare']} da verificare; le altre non ne prevedono.</li>"
        "<li>Il riquadro dettagliato di ogni intervento indica cosa fare e quale prova serve per chiuderlo.</li>"
        "</ul></div><nav class='filters' aria-label='Viste della roadmap'><button type='button' data-filter='tutti' class='active'>Tutti</button><button type='button' data-filter='forniture'>Solo forniture</button><button type='button' data-filter='aperti'>Solo aperti</button><a class='nav-link' href='#glossario'>Glossario dei codici</a></nav>"
        + "".join(cards)
        + "</div><section id='glossary-view' class='glossary-page' hidden><nav class='back-links'><a href='#roadmap'>← Torna alla roadmap</a></nav><p class='eyebrow'>Guida rapida</p><h1>Glossario dei codici</h1><p>Seleziona una sigla per leggere il suo significato. Tutte le voci sono incorporate in questo file.</p><label for='glossary-search'>Cerca per codice o parola</label><input id='glossary-search' type='search' autocomplete='off'><ul id='glossary-list' class='glossary-list'></ul></section>"
        + "<section id='reference-view' class='glossary-page' hidden><nav class='back-links'><a href='#roadmap'>← Torna alla roadmap</a><a href='#glossario'>Tutte le sigle</a></nav><p id='reference-kind' class='eyebrow'></p><h1 id='reference-title'></h1><p id='reference-code' class='reference-code'></p><p id='reference-description' class='reference-description'></p><div id='reference-related' class='reference-related'></div><p id='reference-source' class='reference-source'></p></section>"
        + "</main><footer class='page-footer'><div><p>Limiti: topologia riconciliata su 39 confronti al 28/09/2026; la presenza fisica residua del GS-105B richiede verifica sul posto. Policy firewall, ripristini e alimentazioni richiedono prove dirette. La checklist ISO locale non contiene evidenze compilate.</p></div></footer>"
        + f"<script type='application/json' id='glossary-data'>{payload}</script><script>{script}</script></body></html>"
    )


def write_if_changed(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_text(encoding="utf-8") == content:
        return
    temp = path.with_name(path.name + ".tmp")
    temp.write_text(content, encoding="utf-8", newline="\n")
    os.replace(temp, path)


def desktop_path() -> Path:
    override = os.environ.get("ISO_ROADMAP_DESKTOP")
    folder = Path(override).expanduser() if override else Path.home() / "Desktop"
    if not folder.is_dir():
        raise FileNotFoundError(f"Desktop non trovato: {folder}")
    return folder / DESKTOP_NAME


def archive_path() -> Path:
    override = os.environ.get("ISO_ROADMAP_ARCHIVE_DIR")
    if override:
        folder = Path(override).expanduser()
    elif PRIVATE_BRAND.exists():
        config = json.loads(PRIVATE_BRAND.read_text(encoding="utf-8"))
        if not config.get("archive_dir"):
            raise ValueError("Cartella ISO OneDrive non configurata nel livello privato")
        folder = Path(config["archive_dir"])
    else:
        raise ValueError("Cartella ISO OneDrive non configurata nel livello privato")
    if not folder.is_dir():
        raise FileNotFoundError(f"Cartella ISO OneDrive non trovata: {folder}")
    return folder / DESKTOP_NAME


def build(data: dict, desktop: bool) -> None:
    write_if_changed(MARKDOWN, render_markdown(data))
    print(f"Progetto aggiornato: {MARKDOWN}")
    if desktop:
        path = desktop_path()
        archive = archive_path()
        page = render_html(data, brand_logo_uri())
        write_if_changed(archive, page)
        print("Copia ISO aggiornata nella cartella configurata")
        write_if_changed(path, page)
        print(f"Desktop aggiornato: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    p_build = sub.add_parser("build", help="Rigenera la lista del progetto")
    p_build.add_argument("--desktop", action="store_true", help="Esporta su richiesta la copia HTML sul Desktop")
    p_check = sub.add_parser("check", help="Verifica che la lista del progetto coincida con la fonte")
    p_check.add_argument("--desktop", action="store_true", help="Verifica anche l'export HTML quando richiesto")
    p_advance = sub.add_parser("advance", help="Registra un avanzamento e rigenera la vista nel progetto")
    p_advance.add_argument("id", help="ID dell'intervento, per esempio ISO-01")
    p_advance.add_argument("--stato", choices=sorted(STATI), required=True)
    p_advance.add_argument("--nota", required=True, help="Che cosa e' stato fatto o che cosa blocca")
    p_advance.add_argument("--evidenza", default="", help="Percorso o descrizione della prova datata; obbligatoria per completato")
    p_advance.add_argument("--data", default=date.today().isoformat(), help="Data ISO YYYY-MM-DD")
    p_advance.add_argument("--fornitura-stato", choices=sorted(FORNITURE), help="Aggiorna la necessita' di fornitura nella stessa registrazione")
    p_advance.add_argument("--fornitura-dettaglio", help="Che cosa va fornito; necessario per uno stato diverso da nessuna")
    p_advance.add_argument("--fornitura-decisione", help="Condizione o decisione prima di un ordine")
    desktop_mode = p_advance.add_mutually_exclusive_group()
    desktop_mode.add_argument("--desktop", action="store_true", help="Esporta anche l'HTML sul Desktop se richiesto")
    desktop_mode.add_argument("--solo-progetto", action="store_true", help="Compatibilita': il progetto e' gia' la destinazione predefinita")
    args = parser.parse_args()
    data = load()
    if args.command == "check":
        expected = render_markdown(data)
        if not MARKDOWN.exists() or MARKDOWN.read_text(encoding="utf-8") != expected:
            print("Roadmap non allineata: eseguire python scripts/IsoRoadmap.py build", file=sys.stderr)
            return 1
        if args.desktop:
            desktop = desktop_path()
            page = desktop.read_text(encoding="utf-8") if desktop.exists() else ""
            exported = re.search(r"Copia di sola lettura esportata il (\d{4}-\d{2}-\d{2})", page)
            archive = archive_path()
            archived = archive.read_text(encoding="utf-8") if archive.exists() else ""
            if not exported or page != render_html(data, brand_logo_uri(), exported.group(1)) or archived != page:
                print("Export HTML diverso dalla fonte corrente o copie divergenti: riesportare con build --desktop", file=sys.stderr)
                return 1
            print("Roadmap ISO 27001: progetto, Desktop e cartella ISO allineati")
            return 0
        print("Roadmap ISO 27001: vista di progetto allineata; export Desktop non verificato")
        return 0
    if args.command == "advance":
        if args.id not in {item["id"] for item in data["interventi"]}:
            parser.error(f"ID sconosciuto: {args.id}")
        if not args.nota.strip():
            parser.error("--nota non puo' essere vuota")
        if args.stato == "completato" and not args.evidenza.strip():
            parser.error("Per completare serve --evidenza")
        date.fromisoformat(args.data)
        event = {"id": args.id, "data": args.data, "stato": args.stato, "nota": args.nota.strip()}
        if args.evidenza.strip():
            event["evidenza"] = args.evidenza.strip()
        if args.fornitura_stato:
            item = next(item for item in data["interventi"] if item["id"] == args.id)
            detail = (args.fornitura_dettaglio or "").strip()
            if args.fornitura_stato != "nessuna" and not detail:
                parser.error("--fornitura-dettaglio e' necessario per la nuova fornitura")
            item["fornitura"] = {"stato": args.fornitura_stato}
            if detail:
                item["fornitura"]["dettaglio"] = detail
            if args.fornitura_decisione:
                item["fornitura"]["decisione"] = args.fornitura_decisione.strip()
            event["fornitura"] = item["fornitura"].copy()
        data.setdefault("eventi", []).append(event)
        data["aggiornato"] = args.data
        validate(data)
        glossary(data)
        write_if_changed(SOURCE, json.dumps(data, ensure_ascii=False, indent=2) + "\n")
        build(data, args.desktop)
        return 0
    build(data, args.desktop)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError) as error:
        print(f"Errore: {error}", file=sys.stderr)
        sys.exit(2)
