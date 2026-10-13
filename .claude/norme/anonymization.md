# Anonimizzazione della documentazione tecnica: i casi osservati

> Riferimento esteso della regola `.claude/rules/anonymization.md`, da cui questi paragrafi sono stati spostati verbatim il 13/10/2026 per non pagarli a ogni sessione. Non si carica all'avvio e non serve ad applicare la regola: dice da quale misura e da quale fallimento viene ciascuna prescrizione.

## La lacuna del perimetro vecchio, chiusa il 07/09/2026

Fino a quella data lo script passava i soli file **tracciati**, e ne derivava una lacuna che si vedeva solo guardandola dal verso giusto: un file **nuovo**, scritto e non ancora aggiunto all'indice, era invisibile al controllo proprio nel momento in cui serviva guardarlo, cioe' prima di pubblicarlo. E' accaduto il 04/09/2026 con tre file nuovi, che sono passati puliti ma per fortuna e non per verifica. Il difetto e' della stessa famiglia degli altri due gia' corretti in questo progetto, la cartella esclusa dal delta e i pattern di rilevanza: non si sbaglia su cio' che si conosce, si sbaglia sul confine.

## L'affermazione sul file dei pattern, che era falsa

**Dal 07/09/2026 quell'ultima frase non e' piu' un impegno ma un controllo.** Era un'affermazione senza verifica, ed era falsa: i due file erano divergenti su dodici prefissi reali, fra cui le due LAN principali, quindi per quelle subnet il guard-rail classificava un valore reale come ambiguita' da valutare invece che come fuga. Nessuno se n'era accorto perche' nessuno confrontava i due file. Ora lo fa `scripts/Test-Allineamento.py` a ogni avvio di sessione, contando i prefissi presenti nella mappa e assenti dai pattern senza mai stamparli, perche' entrambi i file vivono nel layer privato e l'esito del controllo finisce sotto gli occhi di chiunque guardi la sessione.

## Il numero del primo passaggio

La ragione per cui questo controllo esiste, e va usato, e' un numero. Il primo passaggio, il 06/08/2026, ha trovato **centoquarantotto riscontri** su ottantanove file tracciati, di cui una trentina erano valori reali veri: indirizzi cablati dentro tre script, MAC di switch dentro due script di scrittura, indirizzi pubblici di macchine virtuali di progetto, caselle di posta personali di dipendenti e referenti, importi contrattuali, e un caso che vale da solo la regola, cioe' una voce di work-log che pubblicava **la corrispondenza fra un segnaposto e la persona reale**, che e' il dato piu' sensibile di tutta la materia perche' rende reversibile ogni altra anonimizzazione. Nessuno di quei residui era stato introdotto di proposito, e nessuno apparteneva alla sessione che li ha scoperti.
