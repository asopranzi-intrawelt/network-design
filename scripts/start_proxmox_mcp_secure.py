"""Candidate network-design launcher: private env, verified TLS, read-only MCP."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from urllib.parse import urlparse


REQUIRED = ("PROXMOX_URL", "PROXMOX_TOKEN_NAME", "PROXMOX_TOKEN_VALUE")
ALLOWED = set(REQUIRED) | {"NEBULA_API_KEY"}
LINE = re.compile(r'^([A-Z_][A-Z0-9_]*)=("(?:[^"\\]|\\.)*")$')
BASE_ENV = ("SystemRoot", "WINDIR", "PATH", "USERPROFILE", "APPDATA", "LOCALAPPDATA", "TEMP", "TMP", "HOMEDRIVE", "HOMEPATH")


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


def child_env(values: dict[str, str], ca_file: Path) -> dict[str, str]:
    host = urlparse(values["PROXMOX_URL"]).hostname
    if not values["PROXMOX_URL"].startswith("https://") or not host:
        raise ValueError("URL Proxmox HTTPS non valido")
    if not ca_file.is_file():
        raise ValueError("CA Proxmox privata mancante")
    env = {key: os.environ[key] for key in BASE_ENV if key in os.environ}
    env.update({key: values[key] for key in REQUIRED})
    env.update({
        "PROXMOX_VERIFY_SSL": "true",
        "PROXMOX_ALLOW_DANGER": "false",
        "SSL_CERT_FILE": str(ca_file),
        "NO_PROXY": host,
    })
    return env


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    try:
        values = load_env(root / ".env")
        ca_file = root / "_notes" / "certs" / "proxmox-root-ca.pem"
        env = child_env(values, ca_file)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"Avvio MCP impossibile: {type(exc).__name__}", file=sys.stderr)
        return 2
    command = shutil.which("uvx")
    if not command:
        print("Avvio MCP impossibile: uvx non trovato", file=sys.stderr)
        return 2
    runner = root / "scripts" / "proxmox_mcp_readonly.py"
    if not runner.is_file():
        print("Avvio MCP impossibile: filtro di sola lettura mancante", file=sys.stderr)
        return 2
    return subprocess.call([command, "--offline", "--from", "proxmox-mcp==0.1.0", "python", str(runner)], env=env)


if __name__ == "__main__":
    raise SystemExit(main())
