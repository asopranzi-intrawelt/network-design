---
name: fonti-di-rete
description: >
  Tabelle complete delle cinque classi di fonti di questo progetto di rete: file del repository,
  fonti vive (Nebula, Proxmox, NinjaOne, MCP, GUI del firewall e degli apparati), radici OneDrive
  sorvegliate e fuori perimetro, progetti e sessioni della classe D, ruolo dell'IT Manager, con
  cadenze confermate e punti ciechi. Si carica quando un task tocca porte, VLAN, access point,
  VM o postazioni e va scelta la fonte viva da rileggere; quando si triagia il delta OneDrive;
  quando un altro progetto o sessione cambia la rete; quando la licenza Nebula scade o si adotta
  un apparato nuovo; quando si porta il firewall su Nebula; quando si estende o si corregge la
  regola fonti-e-riallineamento o `data/scadenze.json`.
---

## Che cosa fa questa skill

La regola sempre attiva `.claude/rules/fonti-e-riallineamento.md` dice il principio, le cinque classi e il protocollo di riallineamento. Il dettaglio con cui si applicano sta in `RIFERIMENTO.md`, accanto a questo file, e va letto prima di operare su una fonte: quale script legge quale fonte e su che cosa è autorevole, quali tre radici OneDrive su diciannove sono sorvegliate, quali progetti della classe D toccano la rete, quale cadenza ha confermato l'IT Manager per ciascuna fonte.

## Procedura minima

Si legge la sezione della classe pertinente in `RIFERIMENTO.md`, si rilegge la fonte viva secondo la sua cadenza e non a memoria, e si confronta l'età della misura con quanto riporta `scripts/Test-Allineamento.py` all'avvio. Una cadenza o una fonte nuova si scrive nel riferimento e, se ha una scadenza, in `data/scadenze.json` nello stesso giro.

## Vincoli

La chiave Nebula resta di sola lettura (ADR-009) e il canale di scrittura verso gli switch non si usa per configurazioni di sicurezza (ADR-010). Un apparato nuovo nell'organizzazione Nebula si licenzia entro quindici giorni, altrimenti la fonte si spegne per tutti (ADR-022).
