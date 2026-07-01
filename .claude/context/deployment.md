---
last-verified: PENDING-FIRST-COMMIT
---

# Esecuzione script e aggiornamento snapshot

## Eseguire lo snapshot Proxmox

```powershell
# Dalla radice del progetto
.\scripts\Get-ProxmoxSnapshot.ps1 -ProxmoxHost 10.61.20.11
```

Lo script chiede username e password a runtime. Le credenziali non vengono mai salvate
su disco. La password viene azzerata subito dopo l'autenticazione.

Output prodotto in `output/` (ignorato da git):
- `output/proxmox-snapshot.json` — dati grezzi completi (JSON)
- `output/proxmox-config.md` — report leggibile (Markdown)

## Prerequisiti

- PowerShell 5.1 o superiore
- Accesso di rete a `10.61.20.11:8006` (TCP 8006)
- Credenziali Proxmox con permessi API (root o utente PVEAudit)
- Nessun modulo esterno richiesto

## Parametri dello script

| Parametro | Default | Descrizione |
|---|---|---|
| `-ProxmoxHost` | — | IP/hostname del server Proxmox (obbligatorio) |
| `-OutputDir` | `.\output` | Directory di output |

## Profilo SSH e identita' git

Configurati a livello locale del repo (non globale). Vedere
`.claude/rules/git-identity-and-repo.md` per la procedura.

```
user.name  = asopranzi
user.email = asopranzi@intrawelt.com
remote     = git@github-corp:asopranzi-intrawelt/network-design.git
```

## Ingestione documenti Word

Per i documenti Word voluminosi della storia della rete usare la skill `docx-ingest`.
I file Word restano in `_notes/` (ignorato da git). I mirror Markdown curati vanno in
`docs/infrastructure-timeline/` (versionato).
