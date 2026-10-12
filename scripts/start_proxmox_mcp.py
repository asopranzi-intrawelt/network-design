"""Avvia proxmox-mcp con le sole credenziali Proxmox da .env privato."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


REQUIRED = ("PROXMOX_URL", "PROXMOX_TOKEN_NAME", "PROXMOX_TOKEN_VALUE")
ALLOWED = set(REQUIRED) | {"NEBULA_API_KEY"}
LINE = re.compile(r'^([A-Z_][A-Z0-9_]*)=("(?:[^"\\]|\\.)*")$')


def load_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8-sig").splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        match = LINE.fullmatch(raw)
        if not match:
            raise ValueError("Formato .env non valido")
        key = match.group(1)
        if key not in ALLOWED or key in values:
            raise ValueError("Chiave non ammessa o duplicata in .env")
        value = json.loads(match.group(2))
        if not isinstance(value, str) or not value or any(ord(c) < 32 for c in value):
            raise ValueError("Valore .env non valido")
        values[key] = value
    if any(not values.get(name) for name in REQUIRED):
        raise ValueError("Credenziali Proxmox mancanti")
    return values


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    try:
        values = load_env(root / ".env")
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"Avvio MCP impossibile: {type(exc).__name__}", file=sys.stderr)
        return 2
    command = shutil.which("uvx")
    if not command:
        print("Avvio MCP impossibile: uvx non trovato", file=sys.stderr)
        return 2
    env = os.environ.copy()
    env.pop("NEBULA_API_KEY", None)
    env.update({key: values[key] for key in REQUIRED})
    # stdin, stdout e stderr sono ereditati intatti: nessun testo sul canale MCP.
    return subprocess.call([command, "proxmox-mcp"], env=env)


if __name__ == "__main__":
    raise SystemExit(main())
