# Anonimizzazione della documentazione tecnica

> Regola modulare, da caricare sempre. Il repository e' pubblico su GitHub
> (`asopranzi-intrawelt/network-design`, verificato via API il 01/07/2026):
> tutto cio' che si scrive nei file tracciati e' visibile a chiunque, per
> sempre, anche dopo un'eventuale correzione successiva (la storia git resta
> consultabile finche' non viene riscritta). Questa regola vale per ogni nuovo
> contenuto scritto d'ora in avanti nei file tracciati sotto `docs/` e
> `.claude/context/`.

## Cosa si anonimizza sempre

Ogni indirizzo IP pubblico reale di Intrawelt o di un fornitore/collaboratore
(blocco WAN, peer VPN, VPS di progetti clienti), ogni indirizzo IP privato
RFC1918 reale (192.168.x.x e ogni altra subnet interna), ogni MAC address di
un dispositivo reale, e ogni nome proprio completo di una persona fisica
(dipendenti, referenti di fornitori, collaboratori esterni), vanno sostituiti
con un placeholder prima di scrivere in un file tracciato.

## Cosa resta reale

Il nome della societa' (Intrawelt) e dei fornitori/vendor (Vianova, myOffice,
Zyxel, Seeweb, QNAP, eccetera): sono nomi di organizzazione, non dati
personali, e il repository stesso dichiara gia' pubblicamente di trattare la
rete Intrawelt. Le caselle di posta funzionali non personali (`info@`,
`enivipa@` e simili). Il nome dell'autore dei commit e la sua casella
(`asopranzi` / `asopranzi@intrawelt.com`): coincidono gia' con i metadati
visibili su ogni commit della storia git, quindi anonimizzarli nel testo
prosa non avrebbe alcun effetto protettivo. Gli IP di minaccia noti (threat
intel, IP di attaccanti citati per scopi di sicurezza): non sono informazioni
aziendali, sono dati pubblici sulla minaccia. I nomi di oggetti di
configurazione letterali gia' presenti su un dispositivo reale (per esempio
una regola firewall che contiene un nome proprio nel suo nome tecnico):
restano verbatim quando servono per guidare un intervento operativo preciso
sulla GUI o CLI del dispositivo, perche' un placeholder li renderebbe
introvabili; l'eccezione va sempre dichiarata esplicitamente nel testo.

## Convenzione dei placeholder

Gli IP pubblici Intrawelt vanno sostituiti con gli intervalli di
documentazione RFC 5737 (`203.0.113.0/24`, `198.51.100.0/24`,
`192.0.2.0/24`), che non sono mai instradabili su Internet reale. Gli IP
privati vanno spostati su un blocco RFC1918 diverso da quello reale
mantenendo invariati gli ottetti che portano significato (VLAN, ruolo host),
cosi' la documentazione resta leggibile e coerente con se stessa: per esempio
se la LAN reale usa `192.168.20.0/24` per i server, il placeholder puo' essere
`10.61.20.0/24`, preservando il ".20" che identifica la subnet server. I MAC
address diventano `AA:BB:CC:00:00:NN` progressivi. Le persone diventano
`Persona-A`, `Persona-B` in ordine di prima apparizione nel documento
corrente, oppure un'etichetta di ruolo quando il ruolo e' piu' informativo del
nome (`Referente-<Fornitore>-1`, `Collaboratore-Esterno-1`,
`Consulente-<Ambito>-1`). Le sale riunioni o altri luoghi con nome proprio
diventano `Sala-N`.

## Dove vive la mappatura

La traduzione placeholder -> valore reale non si scrive mai in un file
tracciato: vive in `_notes/.anonymization-map.md`, ignorato da git, e si
estende con nuove voci mano a mano che si anonimizzano altri documenti,
riusando lo stesso placeholder se la stessa persona o lo stesso indirizzo
ricompaiono altrove. Chi opera davvero sulla rete consulta quel file in
locale per tradurre i placeholder ai valori reali.

## Cosa fare quando si trova un valore reale gia' pubblicato

Non si riscrive la storia git da soli: la riscrittura di una storia condivisa
e pubblica e' un'operazione pianificata, con backup e comunicazione preventiva
se ci sono altri collaboratori, mai un'azione improvvisata a valle di una
singola sessione. Segnalare il valore trovato, aggiungerlo alla mappa privata,
correggerlo nel file tracciato corrente, e annotare la necessita' di una
pulizia della storia come lavoro a parte (vedi lo stato della Fase B in
`.claude/context/roadmap.md`).
