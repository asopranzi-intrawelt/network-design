# Anonimizzazione della documentazione tecnica

> Regola modulare, da caricare sempre. Il repository e' pubblico su GitHub (`asopranzi-intrawelt/network-design`, verificato via API il 01/07/2026): tutto cio' che si scrive nei file tracciati e' visibile a chiunque, per sempre, anche dopo un'eventuale correzione successiva (la storia git resta consultabile finche' non viene riscritta). Questa regola vale per ogni nuovo contenuto scritto d'ora in avanti nei file tracciati sotto `docs/` e `.claude/context/`.

## Cosa si anonimizza sempre

Ogni indirizzo IP pubblico reale di Intrawelt o di un fornitore/collaboratore (blocco WAN, peer VPN, VPS di progetti clienti), ogni indirizzo IP privato RFC1918 reale (di qualunque blocco: 10.x.x.x, 172.16-31.x.x, 192.168.x.x), ogni MAC address di un dispositivo reale, e ogni nome proprio completo di una persona fisica (dipendenti, referenti di fornitori, collaboratori esterni), vanno sostituiti con un placeholder prima di scrivere in un file tracciato.

## Dati amministrativi e commerciali: mai in un file tracciato

Il repository e' pubblico: nessuna informazione aziendale trapela, e questo vale a maggior ragione per i dati di natura amministrativa e commerciale, non solo per IP/MAC/nomi propri. Non si scrivono mai in un file tracciato, nemmeno come dettaglio a corredo di un fatto tecnico: importi contrattuali e canoni (mensili, annuali, a consumo), prezzi di acquisto di hardware o licenze, percentuali di sconto negoziate, numeri di fattura/ordine/preventivo, numeri di linea telefonica o di interno reali, IBAN e altri dati bancari, partita IVA e codice fiscale di controparti (fornitori, clienti), termini contrattuali specifici quando rivelano condizioni economiche (durata con penale, importo del contributo di installazione). Il fatto operativo resta raccontabile, il numero no: si scrive "e' stato acquistato un nuovo switch tramite un preventivo Punto Informatica" e non il prezzo o il numero del preventivo; si scrive "rinnovo del canone Vianova" e non l'importo mensile; si scrive "una linea telefonica dismessa" e non il numero. Le eccezioni dell'anonimizzazione IP/MAC/nomi (nome della societa' e dei fornitori, caselle funzionali) restano valide: e' il *nome* del fornitore che si puo' scrivere, mai la cifra o il riferimento del documento amministrativo.

## Cosa resta reale

Il nome della societa' (Intrawelt) e dei fornitori/vendor (Vianova, myOffice, Zyxel, Seeweb, QNAP, eccetera): sono nomi di organizzazione, non dati personali, e il repository stesso dichiara gia' pubblicamente di trattare la rete Intrawelt. Le caselle di posta funzionali non personali (`info@`, `enivipa@` e simili). Il nome dell'autore dei commit e la sua casella (`asopranzi` / `asopranzi@intrawelt.com`): coincidono gia' con i metadati visibili su ogni commit della storia git, quindi anonimizzarli nel testo prosa non avrebbe alcun effetto protettivo. Gli IP di minaccia noti (threat intel, IP di attaccanti citati per scopi di sicurezza): non sono informazioni aziendali, sono dati pubblici sulla minaccia. I nomi di oggetti di configurazione letterali gia' presenti su un dispositivo reale (per esempio una regola firewall che contiene un nome proprio nel suo nome tecnico): restano verbatim quando servono per guidare un intervento operativo preciso sulla GUI o CLI del dispositivo, perche' un placeholder li renderebbe introvabili; l'eccezione va sempre dichiarata esplicitamente nel testo.

## Convenzione dei placeholder

Gli IP pubblici Intrawelt vanno sostituiti con gli intervalli di documentazione RFC 5737 (`203.0.113.0/24`, `198.51.100.0/24`, `192.0.2.0/24`), che non sono mai instradabili su Internet reale. Gli IP privati vanno spostati su un blocco RFC1918 diverso da quello reale mantenendo invariati gli ottetti che portano significato (VLAN, ruolo host), cosi' la documentazione resta leggibile e coerente con se stessa: per esempio se una LAN reale usasse `172.30.40.0/24` per la videosorveglianza, il placeholder potrebbe essere `10.9.40.0/24`, preservando il ".40" che identifica quella subnet (valori di puro esempio, estranei sia alla rete reale sia ai placeholder in uso: l'esempio non deve mai rivelare la mappatura vera). I MAC address diventano `AA:BB:CC:00:00:NN` progressivi. Le persone diventano `Persona-A`, `Persona-B` in ordine di prima apparizione nel documento corrente, oppure un'etichetta di ruolo quando il ruolo e' piu' informativo del nome (`Referente-<Fornitore>-1`, `Collaboratore-Esterno-1`, `Consulente-<Ambito>-1`). Le sale riunioni o altri luoghi con nome proprio diventano `Sala-N`.

## Dove vive la mappatura

La traduzione placeholder -> valore reale non si scrive mai in un file tracciato: vive in `_notes/.anonymization-map.md`, ignorato da git, e si estende con nuove voci mano a mano che si anonimizzano altri documenti, riusando lo stesso placeholder se la stessa persona o lo stesso indirizzo ricompaiono altrove. Chi opera davvero sulla rete consulta quel file in locale per tradurre i placeholder ai valori reali.

## Il controllo automatico, e perche' non basta la buona volonta'

Dal 06/08/2026 esiste `scripts/Test-Anonymization.py`, che passa **tutti** i file tracciati da git e riporta indirizzi reali, MAC reali, nomi propri di persona, caselle di posta personali, importi, numeri di telefono, IBAN, partite IVA e i segreti letterali gia' noti. Si lancia dalla radice del progetto, esce con codice diverso da zero se trova qualcosa nelle categorie bloccanti, e va eseguito **prima di ogni commit** che tocchi documentazione.

```powershell
python scripts/Test-Anonymization.py
```

Lo script e' versionato e non contiene nessun valore reale: cio' che deve cercare vive in `_notes/.anonymization-patterns.json`, ignorato da git accanto alla mappa dei segnaposto. Se quel file manca lo script si ferma e lo dichiara, invece di restituire un esito verde che non ha calcolato. Quando la mappa cresce, cresce anche quel file: sono due facce dello stesso dato.

La ragione per cui questo controllo esiste, e va usato, e' un numero. Il primo passaggio, il 06/08/2026, ha trovato **centoquarantotto riscontri** su ottantanove file tracciati, di cui una trentina erano valori reali veri: indirizzi cablati dentro tre script, MAC di switch dentro due script di scrittura, indirizzi pubblici di macchine virtuali di progetto, caselle di posta personali di dipendenti e referenti, importi contrattuali, e un caso che vale da solo la regola, cioe' una voce di work-log che pubblicava **la corrispondenza fra un segnaposto e la persona reale**, che e' il dato piu' sensibile di tutta la materia perche' rende reversibile ogni altra anonimizzazione. Nessuno di quei residui era stato introdotto di proposito, e nessuno apparteneva alla sessione che li ha scoperti.

Ne discende la regola operativa: il controllo si fa sull'**intero albero tracciato**, non sui soli file toccati dalla sessione. Un residuo non si introduce, si eredita, e restare puliti sui propri file non dice niente sul repository.

Due cose che lo script non puo' fare e restano umane. Non distingue un falso positivo da un leak quando il valore e' ambiguo, per esempio un numero di versione che somiglia a un indirizzo: quei riscontri finiscono nelle categorie non bloccanti e vanno guardati. E non conosce il contesto: un nome dentro la ragione sociale legale e' ammesso, lo stesso nome in una frase narrativa no, e la lista delle eccezioni di contesto va tenuta aggiornata a mano nel file dei pattern.

## Cosa fare quando si trova un valore reale gia' pubblicato

Non si riscrive la storia git da soli: la riscrittura di una storia condivisa e pubblica e' un'operazione pianificata, con backup e comunicazione preventiva se ci sono altri collaboratori, mai un'azione improvvisata a valle di una singola sessione. Segnalare il valore trovato, aggiungerlo alla mappa privata, correggerlo nel file tracciato corrente, e annotare la necessita' di una pulizia della storia come lavoro a parte (vedi lo stato della Fase B in `.claude/context/roadmap.md`).
