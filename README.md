# network-design

Documentazione e progettazione della rete Intrawelt.

## Struttura

```
scripts/                    script operativi
  Get-ProxmoxSnapshot.ps1   snapshot infrastruttura Proxmox
docs/
  infrastructure-timeline/  storia cronologica interventi di rete
output/                     output runtime (ignorato da git)
_notes/                     layer narrativo locale (ignorato da git)
.claude/                    contesto strutturato per sessioni Claude Code
```

## Uso rapido

```powershell
# Aggiornare lo snapshot Proxmox
.\scripts\Get-ProxmoxSnapshot.ps1 -ProxmoxHost 10.61.20.11
```

## Documentazione

Vedere `CLAUDE.md` per la procedura di ripresa in sessione e l'indice completo dei file di contesto.
