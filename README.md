# network-design

Documentazione e progettazione della rete Intrawelt. Il punto di ingresso e' l'[indice della documentazione](docs/README.md); lo [snapshot dell'infrastruttura](docs/snapshot-infrastruttura.md) racconta lo stato censito e la [mappa interattiva](docs/network-map.html) ne mostra la topologia. Il repository e' pubblico: gli indirizzi e gli identificativi dei dispositivi usano segnaposto, mentre le misure complete restano nel livello privato.

La topologia modificabile vive in [`data/network-topology.json`](data/network-topology.json), la matrice pubblicabile delle porte in [`data/port-matrix.json`](data/port-matrix.json). La mappa HTML si rigenera con `powershell -NoProfile -File scripts/Build-NetworkMap.ps1`; `python scripts/Test-TopologyDrift.py` la confronta con gli snapshot locali quando sono disponibili. Gli script operativi sono in `scripts/`, i documenti tematici in `docs/` e la storia in `docs/infrastructure-timeline/`. `output/` e `_notes/` sono ignorati da Git: contengono misure e narrazione privata, non dati da pubblicare.

Per riprendere una sessione di lavoro e leggere le istruzioni condivise da Claude Code e Codex, seguire [CLAUDE.md](CLAUDE.md) e [AGENTS.md](AGENTS.md). Lo stato corrente delle schede tecniche e del lavoro e' in `.claude/context/` e `.claude/memory/`.
