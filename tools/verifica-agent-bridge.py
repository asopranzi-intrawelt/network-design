#!/usr/bin/env python3
"""Verifica che Claude Code e Codex vedano le stesse skill di progetto."""

from __future__ import annotations

import argparse
from pathlib import Path


def trova_radice(partenza: Path) -> Path:
    for candidata in (partenza, *partenza.parents):
        if (candidata / ".git").exists() or (candidata / "CLAUDE.md").exists():
            return candidata
    raise RuntimeError("radice del progetto non trovata")


def nomi_skill(cartella: Path) -> set[str]:
    if not cartella.is_dir():
        return set()
    return {p.parent.name for p in cartella.glob("*/SKILL.md") if p.is_file()}


def verifica(radice: Path) -> list[str]:
    errori: list[str] = []
    claude = radice / ".claude" / "skills"
    codex = radice / ".agents" / "skills"
    canoniche = nomi_skill(claude)
    adapter = nomi_skill(codex)
    if not (radice / "CLAUDE.md").is_file():
        errori.append("manca CLAUDE.md")
    if not (radice / "AGENTS.md").is_file():
        errori.append("manca AGENTS.md")
    for nome in sorted(canoniche - adapter):
        errori.append(f"manca adapter Codex per la skill {nome}")
    for nome in sorted(adapter - canoniche):
        errori.append(f"adapter Codex orfano: {nome}")
    for nome in sorted(canoniche & adapter):
        file_adapter = codex / nome / "SKILL.md"
        riferimento = f"../../../.claude/skills/{nome}/SKILL.md"
        if riferimento not in file_adapter.read_text(encoding="utf-8"):
            errori.append(f"adapter {nome} non rimanda alla skill canonica")
    return errori


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--radice", type=Path, help="radice da verificare")
    args = parser.parse_args()
    radice = args.radice.resolve() if args.radice else trova_radice(Path(__file__).resolve().parent)
    errori = verifica(radice)
    if errori:
        print("Bridge Claude/Codex: ERRORE")
        for errore in errori:
            print(f"- {errore}")
        return 1
    print(f"Bridge Claude/Codex: OK ({len(nomi_skill(radice / '.claude' / 'skills'))} skill condivise)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
