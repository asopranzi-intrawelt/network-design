# Sito e VPS

Il sito aziendale gira su una VPS esterna di cui Intrawelt ha manutenzione e responsabilità, e il suo staging su una macchina virtuale della sede: per questo la sua produzione è materia di rete. Il codice del sito vive in un repository privato e non è documentato qui; qui stanno la macchina, il suo accesso, il suo hardening, i nomi e la zona DNS e le procedure di rilascio e di emergenza.

| Documento | Che cosa risponde | Natura |
|---|---|---|
| [Piano di produzione](piano-produzione-sito-nuovo.md) | censimento della VPS, accesso di amministrazione, hardening | piano |
| [Registro delle fonti](fonti-produzione-sito-vps.md) | su quale documentazione ufficiale si regge ogni decisione | registro delle fonti |
| [Stato interno della VPS](vps-sito-stato-interno.md) | che cosa si legge dall'interno della macchina | misura datata |
| [Canale di propagazione](sito-nuovo-integrazione.md) | come gli sviluppi del sito arrivano in questo progetto | scheda |
| [Baseline di una VPS](runbook-baseline-vps.md) | dalla consegna all'istantanea di ripristino | runbook |
| [Primo rilascio](runbook-primo-rilascio-sito.md) | in quale ordine si porta il sito in produzione | runbook |
| [Accesso di emergenza](runbook-accesso-emergenza-vps.md) | come si entra quando la via ordinaria non c'è | runbook |
| [DNS e domini](dns-domini-come-funziona.md) | nomi, zona e hosting di `intrawelt.com`, e che cosa cambia | spiegazione |
| [DNS e domini, versione illustrata](dns-domini-spiegato-semplice.html) | la stessa spiegazione per chi non è tecnico | spiegazione |

Torna alla [documentazione](../README.md).
