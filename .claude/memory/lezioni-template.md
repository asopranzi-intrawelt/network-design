# Lezioni per il template

> Le lezioni nate in questo progetto che valgono oltre il progetto, cioè che passano le due domande della sezione 16 di `.claude/PROJECT-SYSTEM.md`: restano vere tolti i nomi propri, e non sono già nella testa di chi lavora bene. Una voce per lezione, creata con `python .claude/templates/tools/lezioni-template.py nuova` nel giro di lavoro in cui la lezione nasce. Lo stato non si scrive qui: una lezione è recepita quando il template la elenca in `.claude/templates/lezioni-recepite.json`, che arriva con l'allineamento.

Adottato il: 2026-10-20

## L-001 - 2026-10-20 - Una prova di esistenza non misura una prestazione

Quando il valore di un servizio e' un tasso, cioe' quanto produce per unita' di tempo, un controllo che ne verifica l'esistenza non lo misura e non cambia stato mentre il servizio e' degradato. La skill prove-che-misurano gia' dice che un intervento il cui scopo e' un effetto misurabile non si chiude senza la misura; la stessa regola vale per i controlli in esercizio, dove la forma del difetto e' un gradino invisibile a porta aperta e processo attivo. Ne segue che ogni sorgente di un presidio dichiara da che cosa dipende il suo valore, raccoglie quel segnale accanto alla disponibilita' e conserva la serie, e che una misura presa su un sistema cosi' degradato va ricontrollata con la data accanto.
