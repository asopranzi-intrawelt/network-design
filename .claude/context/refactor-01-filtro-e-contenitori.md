---
last-verified: 0945f4d
---

# Deep-dive 01: il filtro di sistema e le porte pubblicate dai contenitori

Accompagna la voce 1 di `studio-didattico-master.md`. Gli estratti sono reali, letti il 20/10/2026 sulla VM 209 attraverso il canale di propagazione; gli indirizzi seguono i segnaposto di `.claude/rules/anonymization.md`.

## La misura che apre il caso

Il censimento dell'agosto 2026 registrava sulla VM 209 una porta applicativa e la porta del database in ascolto su tutte le interfacce. La rilettura del 20/10/2026 restituisce questo.

```
tcp 0.0.0.0:22
tcp 0.0.0.0:3000
tcp 0.0.0.0:3001
tcp 0.0.0.0:3002
tcp 0.0.0.0:5432
tcp 127.0.0.1:1025
tcp 127.0.0.1:631
tcp 127.0.0.1:8025
```

Le due righe che contano sono di natura diversa, e la differenza è il contenuto di questo documento. Le tre porte `3000`, `3001` e `3002` appartengono a tre processi `next-server` che girano sull'*host*. La porta `5432` è pubblicata da un *contenitore*, e lo dichiara il motore stesso.

```
{"5432/tcp":[{"HostIp":"","HostPort":"5432"}]}
```

Il campo `HostIp` vuoto è la forma in cui il motore scrive "tutti gli indirizzi". Che la porta risponda davvero sull'indirizzo di rete locale, e non soltanto sull'interfaccia di anello, è stato provato aprendo una connessione verso l'indirizzo di LAN della macchina stessa invece di dedurlo dalla tabella.

## Perché il filtro non copre la seconda riga

La documentazione del motore dei container dichiara che quando si pubblica una porta il traffico verso quel contenitore viene deviato prima di passare dalle impostazioni del filtro, perché le regole del motore vivono nella tabella `nat` e precedono la catena su cui il filtro agisce, ignorando di fatto la configurazione del filtro.

Ne discende la proprietà che rende l'errore insidioso: il comando che mostra lo stato del filtro continua a rispondere correttamente, elencando la politica di rifiuto e le tre porte ammesse, mentre una quarta porta risponde. Nessuno dei due output mente; mentono messi insieme da chi li legge come se parlassero della stessa cosa.

La stessa documentazione aggiunge un limite di versione che va verificato e non assunto: nelle versioni anteriori alla `28.0.0` gli host dello stesso segmento di livello due raggiungevano anche le porte pubblicate sull'anello locale, il che renderebbe inefficace proprio il rimedio che si sta per applicare. Sulla VM 209 il motore è alla `29.7.2`, quindi il rimedio tiene. Su una macchina più vecchia non terrebbe, e questa è la ragione per cui la versione si legge prima di applicare la correzione.

## La forma precedente e quella nuova

Il descrittore dei servizi contiene oggi questa pubblicazione.

```yaml
    ports:
      - '5432:5432'
```

La forma senza indirizzo significa, per la documentazione del motore, pubblicazione su tutti gli indirizzi dell'host, e la pagina dichiara la pubblicazione *insicura per difetto*. La forma corretta nomina l'indirizzo su cui si vuole essere raggiungibili.

```yaml
    ports:
      - '127.0.0.1:5432:5432'
```

La correzione funziona in questo progetto per una ragione che va letta nel descrittore stesso, in testa al file, e che non è generalizzabile ad altre macchine senza verificarla.

```
# Qui c'è SOLO il database. L'applicazione non è containerizzata: gira sull'host come
# servizio systemd `intrawelt-dev`, ed è per questo che in .env DATABASE_URL punta a
# localhost:5432 e non a un hostname di rete Docker.
```

L'applicazione raggiunge il database da `localhost`. Legare la pubblicazione all'anello locale toglie l'accesso alla rete e lascia intatto l'accesso dell'applicazione. Se l'applicazione fosse anch'essa in contenitore, la correzione giusta sarebbe diversa: non pubblicare affatto la porta e lasciare che i due servizi si parlino sulla rete interna del motore, che è ciò che il descrittore stesso prevede nella sua ultima riga per il giorno in cui l'applicazione verrà containerizzata.

## Perché modificare il file non basta

Il descrittore porta un avviso che cambia la procedura di applicazione.

```
# Il container che gira in questo momento, `intrawelt-pg`, NON è stato creato da questo
# file: è stato avviato a mano con `docker run` il 12.08.2026, prima che questo compose
# descrivesse Postgres. Questo file è stato riallineato al container reale il 24.08.2026
```

La pubblicazione di un contenitore si fissa alla creazione e non si rilegge dal descrittore a ogni avvio: riavviare il contenitore non applica la modifica, ricrearlo sì. Ne segue che la correzione comporta una breve indisponibilità del database, accettabile su una macchina di sviluppo e da pianificare su una di produzione.

Il rischio della ricreazione è il volume. Il descrittore lo dichiara esterno e con il nome reale, e la verifica diretta conferma che il contenitore in esercizio monta quel volume.

```
volume intrawelt-pgdata -> /var/lib/postgresql/data
```

Senza la dichiarazione esterna, il motore costruirebbe un nome derivato dalla cartella del progetto, monterebbe un volume nuovo e vuoto, e il database ripartirebbe senza dati *senza produrre alcun errore*. È la stessa famiglia di guasti di cui parla questo documento: una configurazione che risponde correttamente mentre descrive un'altra cosa.

## L'esito, misurato il 21/10/2026

La correzione è stata applicata. Il binding letto dal motore è passato da `HostIp` vuoto a `127.0.0.1`, la tabella di ascolto del sistema da `0.0.0.0:5432` a `127.0.0.1:5432`, e la stessa prova di connessione verso l'indirizzo di LAN che prima riusciva riceve adesso un rifiuto.

```
{"5432/tcp":[{"HostIp":"127.0.0.1","HostPort":"5432"}]}
```

L'integrità dopo la ricreazione è confermata da un conteggio e non da un'impressione: trecentoquarantatré tabelle presenti e volume `intrawelt-pgdata` invariato. L'applicazione non è stata toccata e continua a raggiungere il database su loopback.

Due comandi di verifica del blocco consegnato sono falliti, e la ragione appartiene a questa stessa famiglia di errori. Le opzioni di formato del motore, che contengono parentesi graffe e virgolette, hanno attraversato PowerShell e poi una shell remota e sono arrivate spezzate: il comando ha risposto con un errore d'uso invece che con il dato. Non ha compromesso nulla, perché la prova decisiva era la terza e ha funzionato, ma è il promemoria che un comando con virgolette annidate che attraversa due interpreti si rompe per citazione prima di poter essere sbagliato nel merito. Le verifiche sono state rifatte da questa sessione, dove il livello di citazione è uno solo.

## Come si estende il principio

Tre domande chiudono il ragionamento e si riusano ogni volta che si valuta l'esposizione di un servizio, su questa rete e altrove.

La prima è a quale livello vive il servizio, se sull'host o dentro un contenitore, perché da quella risposta dipende se il filtro di sistema sia o no il livello a cui il perimetro viene applicato. La seconda è se la pubblicazione nomini un indirizzo, perché l'assenza dell'indirizzo è la forma in cui si scrive "ovunque" senza accorgersene. La terza è se la porta risponda davvero da dove non dovrebbe, perché una tabella di ascolto si interpreta e una connessione riuscita no.

Ne segue anche una prescrizione su come il progetto scrive, non solo su come configura. Dove una scheda afferma che un filtro protegge qualcosa, l'affermazione va qualificata con il livello a cui vale, altrimenti la scheda ripete per anni una conclusione che era vera per i servizi dell'host e falsa per quelli in contenitore. Le occorrenze note sono state corrette con i difetti #239 e #236; le future si prevengono scrivendo la qualificazione fin dalla prima stesura.
