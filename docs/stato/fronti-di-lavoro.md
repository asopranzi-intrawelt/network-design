---
last-verified: 2026-10-30
---

# Fronti di lavoro aperti

> Vista di primo livello, creata il 30/10/2026 su richiesta dell'IT Manager. Risponde a una domanda sola, cioe' che cosa affrontare adesso, e non sostituisce nessun registro: `docs/stato/pendenze-aperte.md` resta la fonte di che cosa e' aperto, `.claude/memory/decisions.md` di perche' si e' deciso cosi', `docs/sicurezza/roadmap-iso27001-operativa.md` dello stato ISO. Qui stanno i fronti, il loro ordine e cio' che li sblocca. Si rilegge a ogni ripresa di sessione e si aggiorna quando un fronte cambia stato, non a ogni passo.

## L'ordine, e perche'

Primo il sito, perche' e' l'unico fronte con una data che non dipende da noi e con un committente che aspetta; e perche' finche' resta aperto tiene fermi due lavori che gli sono stati esplicitamente subordinati, cioe' il censimento dei certificati e il controllo di sicurezza sullo stack. Secondo la postura endpoint, perche' il lavoro del 30/10 ha lasciato tre decisioni pronte da prendere e una di esse, la licenza del modulo delle patch, blocca l'evidenza di un controllo ISO. Terzo la custodia dei segreti, che non ha scadenza ma ha il miglior rapporto fra effetto e costo, essendo fatta per meta' di spostare due file. Gli altri due fronti procedono per conto loro e non competono con questi.

## 1. Deploy del sito nuovo — il piu' urgente

Piano di insieme in [piano-produzione-sito-nuovo.md](../sito-vps/piano-produzione-sito-nuovo.md); runbook del primo rilascio in `docs/sito-vps/runbook-primo-rilascio-sito.md`; le voci aperte stanno nella sezione del parco VPS di `pendenze-aperte.md`. Il versionamento del sito non e' lavoro di questo progetto, e' del progetto del sito sulla VM 209.

Quattro cose lo bloccano, e tre non sono tecniche. Le tre decisioni del committente su quale versione va online, in quali lingue e con quale misura del traffico precedono ogni lavoro tecnico, perche' cambiano che cosa si pubblica, quanti indirizzi si reindirizzano e se serve il banner di consenso. Il riferimento di rilascio del progetto del sito non e' ancora nominato, e senza quello la fase di distribuzione non ha un punto di partenza. La discesa di `main` nei due rami di lavoro si e' fermata su un conflitto di contenuto gia' risolto a monte dal committente. Il modello di rilascio non e' scelto, e i due documentati sono incompatibili.

Prima del passaggio del dominio vanno chiusi il controllo di sicurezza sullo stack e la decisione sulla posta, gia' presa, che replica il comportamento del sito attuale. Dopo la messa in produzione, e non prima, si aprono il censimento dei certificati e il piano di manutenzione concordato con chi sviluppa.

## 2. Postura endpoint, vulnerabilita' e registro ISO — tre decisioni pronte

Scheda in [bitdefender-gravityzone-api.md](../sicurezza/bitdefender-gravityzone-api.md), decisione in ADR-049, strumento `scripts/Get-BitdefenderSnapshot.ps1`. Misurato il 30/10/2026 e funzionante.

La decisione che pesa di piu' e' se licenziare il modulo Patch Management, oggi fuori licenza: senza di esso il progetto non ha nessuna fonte di CVE per endpoint e l'evidenza del controllo sulla gestione delle vulnerabilita' tecniche resta una casella vuota, che il Vulnerability Assessment non puo' colmare perche' era una scansione non autenticata su un solo segmento. La seconda e' se licenziare Integrity Monitoring o dichiarare mancante il controllo sull'accesso ai dati che gli era attribuito. La terza riguarda la coda degli incidenti: 195 aperti da un anno, nessuno assegnato, con settanta che sono probabilmente il rumore degli strumenti di questo progetto e, sotto, trentadue URL di phishing su otto postazioni e un episodio di sottrazione credenziali su tre postazioni nello stesso giorno.

Due cose si possono fare subito e senza decidere niente: sanare le tre postazioni con le firme antivirus non aggiornate, e aprire i tre incidenti dell'08/01/2026 per stabilire se siano un episodio unico.

## 3. Custodia dei segreti operativi — effetto alto, costo basso

Scheda in [custodia-dei-segreti-operativi.md](../sicurezza/custodia-dei-segreti-operativi.md).

Due gesti chiudono la parte piu' esposta: togliere il file delle passphrase dalla cartella che contiene il materiale dell'autorita' che quelle passphrase proteggono, e cancellare la copia in chiaro della chiave API ora custodita nel file privato del progetto. Restano poi da fare le due misure che la scheda dichiara non eseguite, cioe' guardare le condivisioni attive del servizio cloud e i permessi locali della cartella, e la decisione sul supporto nuovo dell'autorita' dopo il guasto del 26/10. La migrazione nel gestore delle password, quando ci sara', ruota ogni voce che migra.

## 4. Firma del codice degli strumenti — deciso, non ancora eseguito

ADR-050, strumento `scripts/Sign-ProjectScripts.ps1`, mai eseguito perche' il percorso del materiale di firma lo passa l'IT Manager.

L'ordine conta: prima si firma, poi si chiede al fornitore l'esclusione per editore invece che per percorso. La misura del 30/10 dice quanto vale, perche' i settanta incidenti di auto-osservazione sono precisamente cio' che un'esclusione per editore toglie dalla coda. Resta la dipendenza dichiarata, cioe' che la radice dell'autorita' non e' ancora distribuita alle postazioni, quindi oggi la firma e' verificabile solo dove quella radice e' gia' installata.

## 5. Collettore dei log, pilot Seeweb e ISO-30 — in corso altrove

Stato in `.claude/context/current-work.md` e in `docs/osservabilita/log-collector-integrazione.md`. Il lavoro vive in larga parte nel progetto del collettore, e qui arriva cio' che cambia la rete. Aspettano il test UDP concordato con il fornitore e l'aggiornamento dell'apparato nella finestra serale, che sono due attivita' separate e non vanno confuse.

## 6. Migrazione dei segreti locali, M30 — regola di tracciamento attiva

Runbook in `docs/sicurezza/runbook-migrazione-segreti-locali.md`. Vale la regola M30 dichiarata nel `CLAUDE.md`: ogni passo aggiorna nello stesso giro runbook, ADR, registro delle pendenze, timeline e registro ISO. Finche' i gate non passano, il design resta distinto dall'esercizio.
