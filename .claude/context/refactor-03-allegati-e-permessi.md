---
last-verified: ab92c4f
---

# Deep-dive 03: gli allegati sopra 3 MB, il permesso che non si concede e il collegamento al loro posto

Accompagna la voce 3 di `studio-didattico-master.md`. Gli estratti di codice vengono dall'adattatore di posta del sito, `src/utilities/posta.ts` sul ramo `posta-e-moduli`, letti il 29/10/2026 dalla VM 209 in sola lettura; quel codice non è ancora committato e appartiene al progetto del sito. Le affermazioni su Microsoft Graph ed Exchange vengono dalle pagine ufficiali citate in fondo, lette lo stesso giorno.

## Il meccanismo che crea la soglia

Graph riceve un messaggio da spedire come oggetto JSON. Gli allegati ci entrano codificati in base64, che rappresenta ogni tre byte con quattro caratteri: un file da 3 MB diventa circa 4 MB di testo. Il corpo di una singola richiesta ha un tetto, e per questo Microsoft documenta due strade, distinte per peso. L'adattatore del sito le implementa entrambe e sceglie con una somma:

```ts
const SOGLIA_IN_LINEA = 3 * 1024 * 1024

if (file.reduce((n, a) => n + a.dati.length, 0) <= SOGLIA_IN_LINEA) {
  const risposta = await chiama('/sendMail', 'POST', {
    message: { ...corpoMessaggio, attachments: file.map(allegatoGraph) },
    saveToSentItems: true,
  })
  // Graph risponde 202 Accepted: il messaggio è preso in carico, non ancora consegnato.
```

Sotto la soglia basta `sendMail`, che richiede il solo `Mail.Send`. Il commento sul 202 è esatto e importante: Graph conferma la presa in carico, non la consegna, che dipende dai limiti di Exchange Online.

## La strada sopra la soglia, e che cosa chiede

```ts
// Oltre la soglia Microsoft prescrive la bozza: la si crea nella casella, si caricano i file
// (quelli grandi a pezzi, con una sessione di caricamento) e la si spedisce. Serve il permesso
// di scrivere nella casella, Mail.ReadWrite, limitato a mailer@ come Mail.Send: senza, la
// prima chiamata risponde 403 e l'errore lo dice.
const creata = await chiama('/messages', 'POST', corpoMessaggio)
...
const s = await chiama(`/messages/${bozza.id}/attachments/createUploadSession`, 'POST', {
  AttachmentItem: { attachmentType: 'file', name: a.nome, size: a.dati.length, contentType: a.tipo },
})
```

La sequenza corrisponde alla documentazione: bozza, sessione di caricamento per ogni file sopra i 3 MB, byte caricati a pezzi da non più di 4 MB su un indirizzo che porta già la propria autorizzazione, infine l'invio della bozza. Il codice è scritto con cura anche dove fallisce: in caso di errore cancella la bozza, perché una bozza a metà non resti nella casella né parta più tardi per sbaglio. Il difetto non sta qui. Sta nel prezzo della prima riga, la creazione della bozza, che richiede di poter scrivere nella casella.

## Che cosa porta davvero `Mail.ReadWrite`

Nella tabella dei ruoli per applicazioni di Exchange Online, `Application Mail.ReadWrite` è descritto come il permesso di creare, leggere, aggiornare e cancellare la posta, e la stessa riga precisa che non include l'invio. Lo si può limitare a una sola casella con un campo di applicazione, come per `Mail.Send` in ADR-043. Anche limitato, però, dà all'applicazione la lettura di tutto ciò che la casella del sito riceve. La stessa pagina ricorda che i permessi concessi in Entra e quelli concessi in Exchange si sommano. Ne segue che ogni permesso in più è una seconda occasione di configurarlo male, perché basterebbe concederlo anche in Entra per estenderlo a tutte le caselle dell'organizzazione.

## La decisione, e dove cambia il codice

La modifica non tocca l'adattatore. Tocca il punto che prepara la notifica, cioè chi decide che cosa allegare: se la somma dei file supera la soglia, la notifica non passa gli allegati all'adattatore e aggiunge al testo l'elenco dei file e il collegamento alla richiesta nel pannello. L'adattatore, ricevendo un messaggio senza allegati, prende la strada di `sendMail` e non arriva mai alla bozza. Il ramo della bozza resta nel codice, inutilizzato, e il suo messaggio d'errore sul 403 resta come presidio: se un giorno qualcuno ripassasse gli allegati grandi senza concedere il permesso, l'errore direbbe esattamente che cosa manca.

## Il bordo da provare

`SOGLIA_IN_LINEA` vale 3 MiB, cioè 3 145 728 byte di allegati prima della codifica. In base64 diventano 4 194 304 caratteri, a cui si aggiungono il testo del messaggio e la struttura JSON. Se il tetto del corpo di una richiesta è 4 MB, un messaggio con allegati appena sotto la soglia può superarlo e venire rifiutato. Il valore esatto del tetto non è stato letto in una pagina Microsoft in questa sessione, quindi il fatto resta un'inferenza dal calcolo. La prova che la chiude è un invio con Graph attivo e allegati per circa 2,9 e 3,1 MiB: il primo deve partire con gli allegati, il secondo con il collegamento. Se il primo fallisce, la soglia va abbassata di quanto serve a far stare la codifica sotto il tetto.

## Fonti

[Attach large files to Outlook messages or events](https://learn.microsoft.com/en-us/graph/outlook-large-attachments); [attachment: createUploadSession](https://learn.microsoft.com/en-us/graph/api/attachment-createuploadsession), che riporta anche il limite predefinito di 35 MB per messaggio in Exchange Online; [user: sendMail](https://learn.microsoft.com/en-us/graph/api/user-sendmail); [Role Based Access Control for Applications in Exchange Online](https://learn.microsoft.com/en-us/exchange/permissions-exo/application-rbac). Tutte lette il 29/10/2026.
