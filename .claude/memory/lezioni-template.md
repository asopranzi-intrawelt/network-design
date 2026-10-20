# Lezioni per il template

> Le lezioni nate in questo progetto che valgono oltre il progetto, cioè che passano le due domande della sezione 16 di `.claude/PROJECT-SYSTEM.md`: restano vere tolti i nomi propri, e non sono già nella testa di chi lavora bene. Una voce per lezione, creata con `python .claude/templates/tools/lezioni-template.py nuova` nel giro di lavoro in cui la lezione nasce. Lo stato non si scrive qui: una lezione è recepita quando il template la elenca in `.claude/templates/lezioni-recepite.json`, che arriva con l'allineamento.

Adottato il: 2026-10-20

## L-001 - 2026-10-20 - Una prova di esistenza non misura una prestazione

Quando il valore di un servizio e' un tasso, cioe' quanto produce per unita' di tempo, un controllo che ne verifica l'esistenza non lo misura e non cambia stato mentre il servizio e' degradato. La skill prove-che-misurano gia' dice che un intervento il cui scopo e' un effetto misurabile non si chiude senza la misura; la stessa regola vale per i controlli in esercizio, dove la forma del difetto e' un gradino invisibile a porta aperta e processo attivo. Ne segue che ogni sorgente di un presidio dichiara da che cosa dipende il suo valore, raccoglie quel segnale accanto alla disponibilita' e conserva la serie, e che una misura presa su un sistema cosi' degradato va ricontrollata con la data accanto.

## L-002 - 2026-10-20 - Uno strumento invocato da un hook consegna il verdetto nel testo, non nel codice di uscita

Un controllo di avvio sessione che usa il codice di uscita per distinguere cio' che invecchia da cio' che e' rotto perde proprio il caso che gli interessa: l'agente che ospita l'hook tratta qualunque valore diverso da zero come un errore, scarta lo standard output e mostra una riga di fallimento priva di contenuto. Il rapporto arriva percio' in sessione quando non ha nulla da dire e sparisce quando ne ha, e il difetto si presenta come errore dell'infrastruttura invece che come silenzio del controllo, quindi nessuno lo attribuisce allo script. La forma corretta tiene separati i due chiamanti: la riga di comando, letta da una persona o da CI, conserva il codice di uscita parlante; l'hook riceve un modo dedicato che stampa lo stesso testo e ritorna sempre zero, con la gravita' nel testo. Chi scrive uno strumento destinato a un hook verifica quale sia il contratto dell'ospite sul codice di uscita prima di sceglierne uno, perche' il contratto non e' lo stesso di una shell.
