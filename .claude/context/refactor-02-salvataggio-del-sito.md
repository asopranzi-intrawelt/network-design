---
last-verified: c33edd7
---

# Deep-dive 02: il salvataggio notturno del sito, dalla copia sulla VPS alla copia verificata in sede

Accompagna la voce 2 di `studio-didattico-master.md`. Gli estratti sono quelli versionati in `deploy/backup-sito/` il 29/10/2026. Le prove citate sono state eseguite lo stesso giorno, su Windows e in un contenitore Debian trixie con PostgreSQL 17. Il contenitore `backup-sito` sul nodo non esiste ancora, e i passi che lo creano stanno nel runbook del primo rilascio.

## La forma di partenza

Il rilascio del 28/10 è registrato nel runbook con questa sequenza: copia logica della banca dati nella cartella dei salvataggi della VPS, verificata leggibile con l'elenco del suo contenuto, 343 blocchi di dati di tabella, poi un archivio delle due cartelle dei file caricati. Il lavoro è fatto bene per lo scopo che ha, cioè permettere di tornare indietro da un rilascio andato male. Ha però un limite che non dipende dalla cura con cui si fa: copia e originale stanno sulla stessa macchina.

## Chi va a prendere, e perché non chi spinge

Il primo pezzo del codice nuovo sta sulla VPS ed è il più corto. Si lega alla chiave del contenitore nel file `authorized_keys` dell'utente operativo:

```
restrict,command="/usr/local/sbin/copia-sito" ssh-ed25519 AAAA... backup-sito
```

`restrict` toglie alla chiave l'inoltro di porte, l'inoltro dell'agente e il terminale. `command=` fa sì che, qualunque cosa chieda il client, la VPS esegua quel file e nient'altro. Il comando richiesto finisce nella variabile `SSH_ORIGINAL_COMMAND`, che il file non legge di proposito: la chiave non ha parametri da manipolare.

```sh
set -eu
CARTELLA=/opt/intrawelt-new-website
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

cd "$CARTELLA"
docker compose exec -T postgres pg_dump -U intrawelt -d intrawelt -Fc > "$tmp/banca-dati.dump"
tar -cf - -C "$CARTELLA" media private-uploads -C "$tmp" banca-dati.dump
```

`set -eu` è la riga che conta di più. Se `pg_dump` fallisce, lo script esce prima di creare l'archivio, il codice d'uscita arriva al contenitore attraverso SSH e il contenitore dà allarme. Senza quella riga, `tar` impacchetterebbe un file vuoto e uscirebbe con zero. La copia della banca dati passa da una cartella temporanea che `trap` cancella anche in caso di interruzione, così sulla VPS non resta niente di durevole.

La direzione del collegamento è la scelta di architettura. Il filtro della VPS ammette già la sola provenienza della sede, quindi un contenitore in sede che si collega alla VPS non chiede nessuna apertura nuova. Il contrario, una VPS che scrive sul NAS, richiederebbe una strada dalla macchina esposta a Internet verso la rete interna.

## La verifica viene prima della conservazione

Nel contenitore, `salva_sito.py` riceve l'archivio in un file con un nome provvisorio e lo esamina prima di dargli un posto:

```python
with tarfile.open(archivio) as tar:
    nomi = tar.getnames()
    radici = {n.split("/", 1)[0] for n in nomi}
    for attesa in CARTELLE_ATTESE:
        if attesa not in radici:
            motivi.append(f"cartella {attesa} assente dalla copia")
    ...
    tar.extract(NOME_DUMP, tmp, filter="data")
    tabelle = contatore(Path(tmp) / NOME_DUMP, cfg.pg_restore)
```

Il contatore esegue `pg_restore --list` e conta le righe `TABLE DATA`: legge l'indice della copia senza ripristinarla, quindi non serve una banca dati di appoggio. Una copia troncata fa fallire `pg_restore`, ed è il caso provato su un dump tagliato a 2000 byte: esito allarme. Una copia leggibile ma con meno tabelle della soglia, misurata in produzione il 28/10, dà anch'essa allarme. Copre il caso in cui `pg_dump` abbia copiato la banca dati sbagliata o vuota.

L'ordine delle operazioni è la parte che una prima stesura sbaglia più spesso:

```python
motivi, misure = verifica(parziale, cfg, contatore)
if motivi:
    esito = Esito(ALLARME, motivi, misure)
else:
    misure["copia"] = conserva(parziale, cfg, adesso)
```

La potatura delle copie vecchie sta dentro `conserva`, quindi avviene solo dopo una verifica riuscita. Se la verifica fallisse per più notti di fila, le copie buone resterebbero tutte: la conservazione non avanza mai su una copia cattiva. Il file provvisorio si cancella in ogni caso, nel blocco `finally`, e una delle mutazioni provate consiste proprio nel toglierlo: le prove diventano rosse perché il NAS resta sporco di un parziale.

## Tre esiti, perché il silenzio non sia una risposta

Lo script distingue tre esiti con codici d'uscita diversi:

- `sano` (0): la copia è arrivata, è verificata ed è conservata;
- `allarme` (1): la copia è arrivata ma non vale, oppure il comando remoto è fallito;
- `copia_impossibile` (2): la destinazione non c'è o non si scrive, tipicamente il NAS non montato, oppure la configurazione è incompleta.

La distinzione serve a chi legge l'avviso. Il primo caso chiede di guardare la VPS, il secondo il NAS o il nodo. Un esito unico di errore costringerebbe a indagare tutte e due le strade ogni volta.

## Che cosa è stato provato, e che cosa no

Le prove senza rete sono nove, in `test_salva_sito.py`. Ognuna esercita il ramo che dichiara, e cinque mutazioni del codice le rendono rosse: soglia ignorata, cartelle non controllate, potatura assente, settimanale nel giorno sbagliato, parziale lasciato. La prova con PostgreSQL vero ha copiato una banca dati di tre tabelle con `pg_dump -Fc`, nella stessa forma che produce `copia-sito`. Con soglia 3 l'esito è sano, con soglia 4 è allarme; con il dump troncato è allarme, con la destinazione assente è copia impossibile.

Non sono provati il comando forzato sulla VPS vera, i permessi di lettura delle cartelle per l'utente operativo, il montaggio CIFS con la mappatura degli utenti del contenitore non privilegiato e il ripristino. Finché il ripristino non è cronometrato, il progetto può dire che la copia è leggibile, non quanto tempo serve a rimettere in piedi il sito.
