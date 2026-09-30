#!/usr/bin/env python3
"""Aggiunge alla checklist VA privata una fotografia datata del progetto.

Uso: python scripts/Build-OnovaReconciliation.py preview|apply|check
La configurazione con percorso e identificativi degli host vive solo in
_notes/onova-reconciliation.json, ignorato da Git. Le spunte e i dati storici
della checklist rimangono invariati.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import os
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "_notes" / "onova-reconciliation.json"
ISO_DATA = ROOT / "data" / "iso27001-interventi.json"
PREVIEW = ROOT / "output" / "onova-reconciliation-preview.html"
START = "<!-- PROJECT-RECONCILIATION-START -->"
END = "<!-- PROJECT-RECONCILIATION-END -->"


def load_config() -> dict:
    cfg = json.loads(CONFIG.read_text(encoding="utf-8"))
    for key in ("source_html", "backup_html", "data", "intro", "priorita", "hosts", "source_files", "verified_digest"):
        if not cfg.get(key):
            raise ValueError(f"Configurazione privata incompleta: {key}")
    source = Path(cfg["source_html"])
    backup = Path(cfg["backup_html"])
    if source == backup or not source.is_file() or source.suffix.lower() != ".html":
        raise ValueError("Percorsi della checklist privata non validi")
    if backup.parent != source.parent:
        raise ValueError("La copia originale deve restare nella cartella della checklist")
    return cfg


def source_digest(paths: list[str]) -> str:
    digest = hashlib.sha256()
    for relative in sorted(set(paths)):
        path = (ROOT / relative).resolve()
        if not path.is_relative_to(ROOT) or not path.is_file():
            raise ValueError(f"Fonte di progetto non valida: {relative}")
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def project_states() -> dict:
    data = json.loads(ISO_DATA.read_text(encoding="utf-8"))
    states = {item["id"]: item["stato_iniziale"] for item in data["interventi"]}
    for event in data.get("eventi", []):
        states[event["id"]] = event["stato"]
    return states


def validate(cfg: dict, states: dict) -> None:
    if source_digest(cfg["source_files"]) != cfg["verified_digest"]:
        raise ValueError("Le fonti del progetto sono cambiate: rivedere la riconciliazione privata prima di rigenerare")
    ips = [entry["ip_va"] for entry in cfg["hosts"]]
    if len(ips) != len(set(ips)):
        raise ValueError("Host VA duplicato nella riconciliazione")
    for entry in cfg["hosts"]:
        if entry.get("mapping_status") and entry["mapping_status"] not in {"replaced", "removed", "unknown"}:
            raise ValueError(f"Stato di mappatura non valido: {entry['ip_va']}")
    for entry in cfg["hosts"] + cfg["priorita"]:
        if not entry.get("iso_ids") or not all(code in states for code in entry["iso_ids"]):
            raise ValueError("Intervento ISO mancante o sconosciuto nella riconciliazione")


def render_panel(cfg: dict) -> str:
    e = lambda value: html.escape(str(value), quote=True)
    roadmap_path = None
    brand_path = ROOT / "_notes" / "iso-roadmap-brand.json"
    if brand_path.is_file():
        brand = json.loads(brand_path.read_text(encoding="utf-8"))
        if brand.get("archive_dir"):
            roadmap_path = (Path(brand["archive_dir"]) / "Roadmap ISO 27001 - rete.html").resolve()
    roadmap_link = (
        f"<a class='pr-roadmap-link' href='{e(roadmap_path.as_uri())}'>Apri la Roadmap ISO 27001</a>"
        if roadmap_path else "Roadmap ISO 27001 - rete.html nella cartella ISO su Desktop/OneDrive"
    )
    priority = []
    for item in cfg["priorita"]:
        priority.append(
            f"<li><details class='pr-priority-detail'>"
            f"<summary>{e(item['livello'])}: {e(item['titolo'])}</summary>"
            f"<p>{e(item['dettaglio'])}</p></details></li>"
        )
    rows = []
    for item in cfg["hosts"]:
        anchor = "va-project-host-" + re.sub(r"[^A-Za-z0-9-]", "-", item["ip_va"])
        rows.append(
            f"<tr><th scope='row'>{e(item['ip_va'])}</th>"
            f"<td><strong>{e(item['stato'])}</strong>"
            f"<details class='pr-row-detail'><summary>Spiegazione e fonti</summary>"
            f"<p>{e(item['spiegazione'])}</p>"
            f"<p class='pr-sources'>Fonti: {e('; '.join(item['fonti']))}</p>"
            f"</details></td>"
            f"<td><a href='#{anchor}' data-target-ip='{e(item['ip_va'])}'>Apri rilievi VA</a></td></tr>"
        )
    address_count = sum(item["ip_va"] != "ORGANIZATIVO" for item in cfg["hosts"])
    organizational_count = len(cfg["hosts"]) - address_count
    payload = json.dumps({"hosts": cfg["hosts"]}, ensure_ascii=False, separators=(",", ":")).replace("<", "\\u003c")
    return f"""{START}
<style>
#project-reconciliation {{ margin: 16px 0 20px; padding: 20px; border: 1px solid #cfc6e6; border-left: 5px solid #4d11a7; border-radius: 8px; background: #f7f4fc; color: #171321; }}
#project-reconciliation h2 {{ margin: 0 0 7px; color: #4d11a7; font: 600 21px/1.25 Georgia, serif; }}
#project-reconciliation h3 {{ margin: 20px 0 9px; color: #171321; font-size: 15px; }}
#project-reconciliation p {{ margin: 6px 0 10px; }}
#project-reconciliation .pr-date {{ font-size: 12px; font-weight: 700; color: #4d11a7; text-transform: uppercase; letter-spacing: .08em; }}
#project-reconciliation .pr-priority {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: 10px; padding: 0; list-style: none; }}
#project-reconciliation .pr-priority li {{ background: #fff; border: 1px solid #ddd6ee; border-radius: 6px; padding: 12px; }}
#project-reconciliation .pr-priority p {{ font-size: 12px; }}
#project-reconciliation .pr-priority-detail {{ margin: 0; }}
#project-reconciliation .pr-priority-detail summary {{ list-style: none; }}
#project-reconciliation .pr-priority-detail summary::-webkit-details-marker {{ display: none; }}
#project-reconciliation .pr-priority-detail summary::before {{ content: '▸ '; }}
#project-reconciliation .pr-priority-detail[open] summary::before {{ content: '▾ '; }}
#project-reconciliation details {{ margin-top: 14px; }}
#project-reconciliation summary {{ cursor: pointer; font-weight: 700; color: #4d11a7; }}
#project-reconciliation table {{ width: 100%; border-collapse: collapse; margin-top: 12px; background: #fff; }}
#project-reconciliation th, #project-reconciliation td {{ padding: 11px; text-align: left; vertical-align: top; border: 1px solid #e5e0ed; font-size: 12px; }}
#project-reconciliation th {{ width: 145px; white-space: nowrap; }}
#project-reconciliation td:last-child {{ width: 120px; }}
#project-reconciliation a {{ color: #4d11a7; }}
#project-reconciliation a.pr-roadmap-link {{ color: #fff; }}
#project-reconciliation .pr-sources {{ color: #5d556b; font-size: 11px; }}
#project-reconciliation .pr-roadmap-link {{ display: inline-block; margin-top: 6px; padding: 7px 11px; border-radius: 6px; background: #4d11a7; color: #fff; font-weight: 700; text-decoration: none; }}
#project-reconciliation .pr-roadmap-link:hover {{ background: #351078; }}
#project-reconciliation .pr-findings-link {{ display: inline-block; margin-top: 4px; font-weight: 700; }}
#project-reconciliation .pr-start {{ margin: 13px 0; padding: 13px 15px; border: 1px solid #ddd6ee; border-radius: 7px; background: #fff; }}
#project-reconciliation .pr-start ol {{ margin: 8px 0 0 20px; padding: 0; }}
#project-reconciliation .pr-start li {{ margin: 5px 0; }}
#project-reconciliation .pr-note {{ margin-top: 10px; font-size: 12px; color: #514963; }}
#project-reconciliation .pr-explain {{ margin: 8px 0 0; font-size: 13px; }}
#project-reconciliation .pr-row-detail {{ margin-top: 7px; }}
#project-reconciliation .pr-row-detail p {{ margin: 7px 0 0; }}
#project-reconciliation .pr-table-scroll {{ overflow-x: auto; }}
.project-host-note {{ margin: 0 14px 10px; padding: 10px 12px; border-left: 3px solid #4d11a7; background: #f7f4fc; font-size: 12px; }}
.project-host-note strong {{ color: #4d11a7; }}
.toolbar-help {{ flex-basis: 100%; margin: 0; color: var(--muted); font-size: 12px; }}
.advanced-toolbar {{ flex-basis: 100%; border-top: 1px solid var(--border); padding-top: 8px; }}
.advanced-toolbar summary {{ cursor: pointer; color: var(--muted); font-size: 12px; font-weight: 600; }}
.advanced-toolbar-grid {{ display: flex; flex-wrap: wrap; align-items: center; gap: 8px; padding-top: 10px; }}
.mapping-picker {{ display: flex; flex-wrap: wrap; align-items: center; gap: 6px; flex-basis: 100%; border-top: 1px solid var(--border); padding-top: 9px; }}
.mapping-picker-label {{ width: 100%; color: var(--text); font-size: 12px; font-weight: 700; }}
.mapping-picker button {{ border: 1px solid var(--border); border-radius: 999px; background: var(--bg); color: var(--text); padding: 6px 10px; font-size: 12px; cursor: pointer; }}
.mapping-picker button[aria-pressed="true"] {{ background: #4d11a7; border-color: #4d11a7; color: #fff; }}
.mapping-picker button:hover {{ border-color: #4d11a7; }}
.mapping-picker .mapping-note {{ width: 100%; color: var(--muted); font-size: 11px; }}
.mapping-picker #mapping-empty {{ width: 100%; color: var(--crit); font-size: 12px; }}
.toolbar label[hidden] {{ display: none; }}
.va-findings-intro {{ margin: 4px 0 14px; color: var(--muted); font-size: 13px; }}
@media (max-width: 700px) {{
  #project-reconciliation {{ padding: 15px; }}
  #project-reconciliation th {{ width: auto; white-space: normal; }}
  .toolbar {{ position: static; }}
  .mapping-picker {{ display: block; overflow-x: auto; white-space: nowrap; }}
  .mapping-picker-label, .mapping-picker .mapping-note, .mapping-picker #mapping-empty {{ display: block; width: auto; white-space: normal; }}
  .mapping-picker button {{ margin: 6px 4px 0 0; }}
}}
</style>
<section id="project-reconciliation" aria-labelledby="project-reconciliation-title">
  <p class="pr-date">Stato del progetto al {e(cfg['data'])} · fotografia documentale</p>
  <h2 id="project-reconciliation-title">Che cosa è cambiato dal VA 2025</h2>
  <p>La scansione Onova descrive la rete del 2025. Qui trovi i fatti successivi documentati nel progetto e le verifiche da fare oggi.</p>
  <p>Attività, forniture e prove ISO: {roadmap_link}</p>
  <div class="pr-start"><strong>Come usarla</strong><ol>
    <li>Leggi le priorità qui sotto e apri la scheda dell'host interessato.</li>
    <li>Considera l'IP Onova un riferimento storico: verifica la nota di riconciliazione e l'asset attuale.</li>
    <li>Spunta un rilievo solo dopo aver verificato la correzione; annota la prova e scarica una copia con lo stato.</li>
  </ol><p class="pr-note">Le segnalazioni derivano da una scansione non autenticata del 06/11/2025. Una spunta registra il tuo esito nella checklist; non sostituisce una nuova verifica tecnica.</p><a class="pr-findings-link" href="#va-findings-heading">Vai all'elenco dei rilievi del VA</a></div>
  <details><summary>Contesto, limiti e indirizzi storici del VA</summary><p>{e(cfg['intro'])}</p></details>
  <h3>Da verificare adesso</h3>
  <ul class="pr-priority">{''.join(priority)}</ul>
  <p class="pr-explain">Queste voci confrontano {address_count} indirizzi del VA 2025 con ciò che il progetto documenta oggi. La voce ORGANIZATIVO raccoglie attività generali, senza un host. Apri “Spiegazione e fonti” per capire il motivo dello stato; “Apri rilievi VA” porta alla scheda originale. Gli stati qui non chiudono automaticamente le vulnerabilità.</p>
  <details><summary>Mostra {address_count} indirizzi del VA e {organizational_count} voce organizzativa</summary>
    <div class="pr-table-scroll"><table><thead><tr><th>Riferimento nel VA 2025</th><th>Che cosa sappiamo oggi</th><th>Apri scheda</th></tr></thead><tbody>{''.join(rows)}</tbody></table></div>
  </details>
</section>
<script type="application/json" id="project-reconciliation-data">{payload}</script>
<script>
document.addEventListener('DOMContentLoaded', () => {{
  const records = JSON.parse(document.getElementById('project-reconciliation-data').textContent).hosts;
  const byIp = new Map(records.map(record => [record.ip_va, record]));
  const container = document.getElementById('hosts-container');
  const applyProjectMappings = () => {{
    let changed = false;
    for (const record of records) {{
      if (!['removed', 'replaced', 'unknown'].includes(record.mapping_status)) continue;
      const host = DATA.find(item => item.ip === record.ip_va);
      if (!host) continue;
      if (hostState[host.id]) continue;
      hostState[host.id] = {{
        currentIp: host.ip,
        hostname: '',
        customNotes: '',
        mappingStatus: record.mapping_status,
        replacedByIp: record.replaced_by_ip || ''
      }};
      changed = true;
    }}
    if (changed) {{ saveHostState(); renderAll(); }}
    return changed;
  }};
  const mappingSelect = document.getElementById('mapping-filter');
  const mappingButtons = [...document.querySelectorAll('[data-mapping-view]')];
  const syncMappingButtons = () => {{
    mappingButtons.forEach(button => button.setAttribute('aria-pressed', String(button.dataset.mappingView === mappingSelect.value)));
    const visible = container.querySelector('.host-block:not(.hidden)');
    document.getElementById('mapping-empty').hidden = !!visible;
  }};
  const annotate = () => {{
    if (!container.querySelector('.host-block')) return;
    if (applyProjectMappings()) return;
    for (const block of container.querySelectorAll('.host-block')) {{
      const record = byIp.get(block.dataset.ip);
      if (!record) continue;
      if (block.querySelector('.project-host-note')) continue;
      block.id = 'va-project-host-' + record.ip_va.replace(/[^A-Za-z0-9-]/g, '-');
      const note = document.createElement('div');
      note.className = 'project-host-note';
      const strong = document.createElement('strong');
      strong.textContent = 'Stato del progetto al {e(cfg['data'])}: ' + record.stato + '. ';
      note.append(strong, document.createTextNode(record.spiegazione));
      block.querySelector('.host-header').after(note);
    }}
    syncMappingButtons();
  }};
  new MutationObserver(annotate).observe(container, {{childList: true}});
  annotate();
  document.querySelectorAll('details').forEach(detail => {{ detail.open = false; }});
  mappingButtons.forEach(button => button.addEventListener('click', () => {{
    mappingSelect.value = button.dataset.mappingView;
    document.getElementById('status-filter').value = 'all';
    document.getElementById('sev-filter').value = 'all';
    document.getElementById('cvss-filter').value = '0';
    document.getElementById('search').value = '';
    applyFilters();
    container.querySelectorAll('.host-block').forEach(block => block.classList.remove('open', 'editing'));
    syncMappingButtons();
  }}));
  document.addEventListener('change', event => {{
    if (!event.target.matches('[data-field="mappingStatus"], [data-field="currentIp"]')) return;
    applyFilters();
    syncMappingButtons();
  }});
  syncMappingButtons();
  document.querySelectorAll('#project-reconciliation [data-target-ip]').forEach(link => link.addEventListener('click', event => {{
    const record = byIp.get(link.dataset.targetIp);
    if (!record) return;
    const block = document.getElementById('va-project-host-' + record.ip_va.replace(/[^A-Za-z0-9-]/g, '-'));
    if (!block) return;
    event.preventDefault();
    document.getElementById('status-filter').value = 'all';
    document.getElementById('sev-filter').value = 'all';
    document.getElementById('mapping-filter').value = 'all';
    document.getElementById('cvss-filter').value = '0';
    document.getElementById('search').value = '';
    applyFilters();
    syncMappingButtons();
    block.classList.add('open');
    block.scrollIntoView({{behavior: 'smooth', block: 'start'}});
    history.replaceState(null, '', '#' + block.id);
  }}));
}});
</script>
{END}"""


def strip_panel(page: str) -> str:
    if START not in page and END not in page:
        return page
    if page.count(START) != 1 or page.count(END) != 1:
        raise ValueError("Marcatori di riconciliazione incompleti o duplicati")
    first = page.index(START)
    if page[max(0, first - 2):first] == "\r\n":
        first -= 2
    elif page[max(0, first - 1):first] == "\n":
        first -= 1
    last = page.index(END) + len(END)
    return page[:first] + page[last:]


def compose(page: str, cfg: dict, states: dict) -> str:
    base = strip_panel(page)
    if "const DATA = [" not in base or "const SNAPSHOT_ID" not in base or 'id="hosts-container"' not in base:
        raise ValueError("Struttura della checklist Onova non riconosciuta")
    base = simplify_static_sections(base, cfg)
    base = simplify_toolbar(base)
    match = re.search(r'<div class="subtitle">[^\n]*</div>', base)
    if not match:
        raise ValueError("Intestazione della checklist Onova non trovata")
    newline = "\r\n" if "\r\n" in base else "\n"
    panel = render_panel(cfg).replace("\n", newline)
    return base[:match.end()] + newline + panel + base[match.end():]


def simplify_static_sections(page: str, cfg: dict) -> str:
    """Replace repeated instructions without touching findings or browser state."""
    page = re.sub(
        r'<h1>[^<]*</h1>\s*<div class="subtitle">[^<]*</div>',
        '<h1>Checklist VA Onova</h1>\n'
        f'<div class="subtitle">Rilievi del 06/11/2025 · riconciliazione di rete al {html.escape(cfg["data"])}</div>',
        page,
        count=1,
    )
    page = page.replace('<strong>Avanzamento complessivo</strong>', '<strong>Esiti registrati sui rilievi VA 2025</strong>')
    banner = (
        '<div class="save-snapshot-banner">'
        'Le spunte e le note si salvano in questo browser. '
        'Usa “Scarica copia con stato” per archiviare una copia HTML aggiornata.'
        '</div>'
    )
    page = re.sub(r'<div class="save-snapshot-banner">[\s\S]*?</div>', banner, page, count=1)
    page = re.sub(r'\s*<div class="legend">[\s\S]*?</div>', '', page, count=1)
    page = page.replace('Esporta il tutto con "Salva snapshot HTML"', 'Usa "Scarica copia con stato"')
    page = page.replace('const STATUS_LABEL = { original: "Originale",', 'const STATUS_LABEL = { original: "Originale VA",')
    page = page.replace('>Originale (non modificato)</option>', '>Originale VA (non verificato)</option>')
    if 'id="va-findings-heading"' not in page:
        page = page.replace(
            '  <details class="source-info">',
            '  <h2 id="va-findings-heading">Rilievi della scansione 2025</h2>\n'
            '  <p class="va-findings-intro">Apri una scheda per leggere i rilievi e registrare la verifica. I filtri per stato mostrano sempre le schede chiuse.</p>\n'
            '  <details class="source-info">',
            1,
        )
    page = page.replace(
        '    if (host && host.ip === "ORGANIZATIVO") mappingOk = true;',
        '    if (host && host.ip === "ORGANIZATIVO") mappingOk = mappingFilter === "all" || mappingFilter === "organizational";\n'
        '    else if (mappingFilter === "organizational") mappingOk = false;',
    )
    page = page.replace(
        '    if ((sevFilter !== "all" || statusFilter !== "all" || mappingFilter !== "all" || cvssMin > 0 || search) && anyVisible && mappingOk) {\n'
        '      block.classList.add("open");\n'
        '    }\n',
        '',
    )
    return page


def simplify_toolbar(page: str) -> str:
    """Keep common actions visible and tuck infrequent controls into a disclosure."""
    match = re.search(r'<div class="toolbar">([\s\S]*?)</div>\s*(?=<div id="hosts-container">)', page)
    if not match:
        raise ValueError("Barra degli strumenti della checklist non trovata")
    body = match.group(1)

    def label_for(control_id: str) -> str:
        marker = 'id="' + control_id + '"'
        position = body.find(marker)
        if position < 0:
            raise ValueError(f"Controllo filtro non trovato: {control_id}")
        start = body.rfind("<label", 0, position)
        end = body.find("</label>", position)
        if start < 0 or end < 0:
            raise ValueError(f"Etichetta del filtro non valida: {control_id}")
        return body[start:end + len("</label>")]

    def button_for(button_id: str) -> str:
        found = re.search(r'<button\b[^>]*id="' + re.escape(button_id) + r'"[^>]*>[\s\S]*?</button>', body)
        if not found:
            raise ValueError(f"Pulsante checklist non trovato: {button_id}")
        return found.group(0)

    status = label_for("status-filter")
    status = re.sub(r'(<option value="open") selected>', r'\1>', status)
    status = re.sub(r'(<option value="all")>', r'\1 selected>', status)
    status = status.replace('<label>Stato:', '<label>Esito VA:')
    status = status.replace('>Da fare</option>', '>Senza esito</option>')
    status = status.replace('>Completati</option>', '>Spuntati</option>')
    status = status.replace('>Risk Accepted</option>', '>Rischio accettato</option>')
    search = label_for("search")
    primary_save = re.sub(r">Salva snapshot HTML<", ">Scarica copia con stato<", button_for("save-snapshot-btn"))

    mapping_label = re.sub(r'^<label[^>]*>', '<label hidden>', label_for("mapping-filter"), count=1)
    if 'value="organizational"' not in mapping_label:
        mapping_label = mapping_label.replace('</select>', '<option value="organizational">Organizzativo</option>\n      </select>')
    mapping_options = (
        ("all", "Tutti", "Tutte le schede del VA"),
        ("original", "Originale VA", "Indirizzo del rapporto, non ancora rimappato: la presenza attuale non è confermata"),
        ("remapped", "Rimappato", "Stesso dispositivo, indirizzo cambiato"),
        ("replaced", "Sostituito", "Dispositivo sostituito nel percorso attivo; la rimozione fisica può richiedere verifica"),
        ("unknown", "Da identificare", "Collocazione o corrispondenza attuale non confermata"),
        ("removed", "Rimosso", "Dispositivo dismesso o rimosso"),
        ("organizational", "Organizzativo", "Attività generali senza un host"),
    )
    mapping_buttons = "\n".join(
        f'<button type="button" data-mapping-view="{value}" aria-pressed="{str(value == "all").lower()}" title="{html.escape(hint, quote=True)}">{label}</button>'
        for value, label, hint in mapping_options
    )
    advanced_labels = "\n".join(label_for(key) for key in ("sev-filter", "cvss-filter"))
    advanced_buttons = "\n".join(button_for(key) for key in (
        "expand-all", "collapse-all", "save-json-btn", "import-snapshot-btn",
        "export-btn", "export-csv-btn", "reset-btn"
    ))
    replacement = f'''<div class="toolbar">
    <p class="toolbar-help">Filtra gli esiti annotati sul VA storico o cerca un host. Le altre opzioni sono raccolte qui sotto.</p>
    {status}
    {search}
    {primary_save}
    <div class="mapping-picker" role="group" aria-label="Mostra schede per stato della mappatura">
      <span class="mapping-picker-label">Mostra schede per stato</span>
      {mapping_buttons}
      <span class="mapping-note">“Originale VA” indica un indirizzo del vecchio rapporto ancora da rimappare; non conferma che il dispositivo sia attivo oggi.</span>
      <span id="mapping-empty" hidden>Nessuna scheda con i filtri attuali.</span>
    </div>
    {mapping_label}
    <details class="advanced-toolbar"><summary>Altri filtri, esportazioni e strumenti</summary>
      <div class="advanced-toolbar-grid">{advanced_labels}{advanced_buttons}</div>
    </details>
  </div>'''
    return page[:match.start()] + replacement + page[match.end():]


def write_if_changed(path: Path, body: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_bytes() == body:
        return
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_bytes(body)
    os.replace(temporary, path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("preview", "apply", "check"))
    args = parser.parse_args()
    cfg = load_config()
    states = project_states()
    validate(cfg, states)
    source = Path(cfg["source_html"])
    backup = Path(cfg["backup_html"])
    original_bytes = source.read_bytes()
    original = original_bytes.decode("utf-8")
    result = compose(original, cfg, states).encode("utf-8")
    if args.command == "check":
        if original_bytes != result:
            print("Checklist Onova non allineata alla fotografia privata corrente", file=sys.stderr)
            return 1
        print("Checklist Onova allineata alla fotografia del progetto")
        return 0
    if args.command == "preview":
        write_if_changed(PREVIEW, result)
        print(f"Anteprima privata aggiornata: {PREVIEW}")
        return 0
    if not backup.exists():
        if START in original:
            raise ValueError("La copia originale non esiste e la checklist contiene gia' la riconciliazione")
        write_if_changed(backup, original_bytes)
        print(f"Originale preservato: {backup}")
    write_if_changed(source, result)
    print(f"Checklist Onova aggiornata: {source}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError) as error:
        print(f"Errore: {error}", file=sys.stderr)
        sys.exit(2)
