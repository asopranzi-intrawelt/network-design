# Rete

Quest'area descrive la rete di sede dal cavo fino al nome: dove stanno gli apparati e da dove prendono corrente, come sono separati i segmenti oggi e come lo saranno, come il server fisico e le sue macchine virtuali raggiungono la rete, quali servizi interni sono esposti e come si risolvono i loro nomi. Il firewall ha un'area propria.

| Documento | Che cosa risponde | Natura |
|---|---|---|
| [Segmentazione della LAN (M22)](segmentazione-lan-m22.md) | come si passa dalla LAN piatta a segmenti separati | progetto |
| [Livello fisico ed elettrico](livello-fisico-ed-elettrico.md) | armadi, apparati, alimentazione e continuità | scheda |
| [Mappatura delle porte fisiche](mappatura-porte-fisiche.md) | quale presa a muro arriva a quale porta dello switch | scheda |
| [Proxmox e bridge](virtualizzazione-proxmox-e-bridge.md) | come il server Gen10 e le VM sono attaccati alla rete | scheda |
| [Esposizione dei servizi interni](esposizione-servizi-interni.md) | quali porte ascoltano su quali macchine, e con quale protezione host-based | censimento |
| [Risoluzione dei nomi interni](risoluzione-nomi-interni.md) | DNS interno, file hosts e schema `int.intrawelt.com` | scheda |
| [Collegamento o unità di rete](collegamento-vs-unita-di-rete.md) | quale meccanismo usare per raggiungere una cartella sul NAS | nota tecnica |
| [Micro-interventi di robustezza](interventi-robustezza.md) | gli interventi piccoli e indipendenti emersi dalle analisi | registro |

Torna alla [documentazione](../README.md).
