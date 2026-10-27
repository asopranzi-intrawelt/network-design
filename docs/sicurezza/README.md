# Sicurezza e ISO 27001

Quest'area raccoglie ciò che serve al percorso ISO 27001 della rete: la roadmap degli interventi, generata dal registro `data/iso27001-interventi.json`, la governance e la dichiarazione di applicabilità, le verifiche di vulnerabilità esterne, la continuità operativa, l'autorità di certificazione interna e la custodia dei segreti della postazione di amministrazione. La scheda tecnica di design e sicurezza vista dal lato degli apparati è un'altra, in `.claude/context/design-and-security.md`, e non va confusa con quella di governance qui sotto.

| Documento | Che cosa risponde | Natura |
|---|---|---|
| [Roadmap ISO 27001 operativa](roadmap-iso27001-operativa.md) | quali interventi servono, in quale fase, con quali forniture | generato da `scripts/IsoRoadmap.py` |
| [Design e sicurezza](design-and-security.md) | principi, dichiarazione di applicabilità e piano di implementazione | governance |
| [Governance della sicurezza](cybersecurity-governance.md) | cronologia e stato delle attività di sicurezza 2024-2026 | registro |
| [VA ottobre 2026](vulnerability-assessment-ott2026.md) | il secondo ciclo di verifica esterna, base corrente della riconciliazione | sintesi |
| [VA novembre 2025](vulnerability-assessment-nov2025.md) | il primo ciclo, conservato per i rilievi storici | storico |
| [Continuità operativa](business-continuity-disaster-recovery.md) | ruoli, procedure d'urgenza, backup e ripristino | piano |
| [Autorità di certificazione interna](autorita-certificazione-interna.md) | come nasce e dove vive la chiave dell'autorità aziendale | scheda |
| [Migrazione dei segreti locali (M30)](runbook-migrazione-segreti-locali.md) | come i segreti della postazione passano al file privato e con quali gate | runbook |
| [Dossier MCP Proxmox](dossier-sicurezza-mcp-proxmox.md) | credenziali, policy e TLS del client MCP | dossier |
| [Evidenze MCP Proxmox](evidenze-sicurezza-mcp-proxmox.md) | le prove misurate che il dossier richiama | registro |
| [Igiene di caselle e archivio storico](igiene-caselle-spazi-e-archivio-storico.md) | dove finiscono i file condivisi e gli spazi di chi esce | nota |

Torna alla [documentazione](../README.md).
