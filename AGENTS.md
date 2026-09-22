# Istruzioni per Codex

Questo progetto usa un solo sistema di istruzioni e memoria per Claude Code e Codex. `CLAUDE.md` e' la fonte canonica delle istruzioni di progetto: leggilo per intero prima di operare e applicalo anche quando nomina Claude. I file sotto `.claude/memory/`, `.claude/context/` e `.claude/rules/` sono condivisi dai due agenti e conservano lo stesso significato.

All'inizio di ogni nuova sessione esegui `python tools/verifica-agent-bridge.py` e poi la procedura di ripresa descritta in `CLAUDE.md`, iniziando con `python tools/verifica-ripresa.py`. Le skill canoniche vivono in `.claude/skills/`; gli omonimi file sotto `.agents/skills/` sono adapter di discovery per Codex e devono rimandare alla skill canonica, non duplicarla.

Le operazioni di `git add`, commit, push e deploy restano manuali dell'utente. La memoria legittima e' solo quella versionata o privata dentro questo progetto; non creare memoria esterna o nascosta.
