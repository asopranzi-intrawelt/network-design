# Telefonia e PBX – Intrawelt S.a.s.

Centralino fisico e procedure operative. Owner: Alessio Sopranzi.
Aggiornato: giugno 2026.

---

## Centralino Panasonic

**Modello:** Panasonic KX-TDA100 (con espansioni KX-T76xx)
**Integrazione VoIP:** Patton SmartNode 5551 (gateway SIP → PSTN Vianova)
**Linea attiva:** Vianova (da aprile 2025, sostituisce TIM)

Documentazione hardware: `ARCHITETTURA SERVER-CLOUD-LINEE/Telefono-PBX/KXTDA100.pdf`

**Discrepanza rafforzata (10/07/2026)**: sia `2023-baseline.md` (voci
23/03/2023 e 01/02/2024) sia la sezione "Piano 2 Rack SX" di
ARCHITETTURA.docx descrivono indipendentemente il centralino storico come
Panasonic **KX-NCP1000**, non KX-TDA100 come scritto in questa scheda.
Anche la data di inizio servizio telefonico Vianova risulta **aprile 2024**
in `2023-baseline.md` e `2024-infra.md`, non aprile 2025 come scritto qui.
Con due fonti indipendenti concordi su KX-NCP1000, l'ipotesi piu' probabile
e' che questa scheda riporti il modello sbagliato (forse per il documento
sorgente `KXTDA100.pdf` mal identificato), ma resta da confermare con
l'utente prima di correggere: non si esclude un cambio di centralino
avvenuto tra il 2024 e l'estrazione di questa scheda, non ancora tracciato.

---

## Gruppi interni principali

| ID Gruppo | Nome | Comportamento |
|-----------|------|---------------|
| 357 | Operatori | Riceve chiamate dall'esterno se l'utente non digita interno |
| 359 | Germania | Chiamate provenienti dalla Germania |

---

## Procedure PBX

### Deviazione di chiamata – standard (singolo interno)

Per deviare tutte le chiamate di un interno verso un numero esterno (es. cellulare):

```
*710[numero_destinazione]#
```

Esempio: deviare verso il cellulare 3338027116:
```
*7103338027116#
```

Per rimuovere la deviazione:
```
*7100
```

### Deviazione di chiamata – gruppo

Per deviare un intero gruppo (es. Operatori 357) verso un cellulare, digitare dal
telefono di un membro del gruppo la sequenza fornita nell'allegato al documento
`procedura_deviazione_gruppo.docx`.

### Intercettare chiamate del gruppo Operatori

Da un telefono **non appartenente** al gruppo Operatori:
```
Alzare cornetta → premere 6
```

### Segreteria personale

Ogni interno ha una casella vocale dedicata. Il LED del telefono si accende quando
è presente un messaggio non ascoltato.

| Azione | Codice |
|--------|--------|
| Registrare messaggio di assenza | Sganciare → `*381` → tono → registrare |
| Riprodurre messaggi | Sganciare → `*382` |
| Cancellare messaggi | Sganciare → `*380` |

**Attivazione casella vocale (deviazione su occupato e mancata risposta):**
```
*71 ⇒ 0 ⇒ 5 ⇒ 391 ⇒ #
```

Opzioni secondo blocco (tipo di chiamata da deviare):
- `0` = interne ed esterne
- `1` = solo esterne
- `2` = solo interne

Opzioni terzo blocco (condizione di deviazione):
- `2` = tutte le chiamate
- `3` = solo se occupato
- `4` = solo se non risponde
- `0` = cancella deviazione

---

## Messaggi IVR centralino

### Messaggio di benvenuto (standard, orario lavorativo)

> IT: *Digitare l'interno desiderato ora o rimanere in linea per parlare con il primo
> operatore disponibile. Grazie!*
>
> EN: *Press the desired extension now or stay in line to talk to the first available
> operator. Thank you!*

### Messaggio di segreteria (fuori orario / assenza)

> IT: *Al momento non siamo disponibili. Vi preghiamo di lasciare un messaggio e vi
> richiameremo prima possibile. Grazie!*
>
> EN: *We are not available at the moment. Please leave a message and we will call you
> back as soon as possible. Thank you!*

File audio: `ARCHITETTURA SERVER-CLOUD-LINEE/Telefono-PBX/SEGRETERIA INTRAWELT/`
(MP3 e WAV: INTRAWELT_MSG_1, INTRAWELT_MSG_1_fast, INTRAWELT_MSG_2)

---

## Opzioni softphone (telefono su PC)

Fonte: chat Persona-P (informativa costi PBX).

| Tipo | Costo licenza (fascia) | Note |
|------|--------------|------|
| SIP phone | Fascia bassa | Richiede client VoIP terzo (molti gratuiti) |
| Softphone Panasonic | Fascia alta rispetto al SIP phone | Replica software del telefono fisico, identico per tasti e LED |
| IP phone | Fascia bassa + hardware | Come postazione MARSK; richiede VPN fissa + telefono fisico |

---

## Documentazione PBX disponibile

| File | Contenuto |
|------|-----------|
| `Centralino.doc` | Documentazione principale PBX (formato .doc, non estraibile con python-docx) |
| `procedura_deviazione_standard.docx` | Deviazione singolo interno |
| `procedura_deviazione_gruppo.docx` | Deviazione gruppo con allegato sequenze |
| `procedura_intercettare_chiamate_gruppo_operatori.docx` | Intercetta gruppo Operatori |
| `segreteria_personale.docx` | Codici segreteria personale |
| `NuovoMessaggioCentralino.docx` | Testi messaggi IVR standard/segreteria |
| `istruzioni casella vocale Panasonic.pdf` | Guida utente casella vocale |
| `KX-T76xx.pdf` | Manuale telefono |
| `KXTDA100.pdf` | Manuale centralino |
