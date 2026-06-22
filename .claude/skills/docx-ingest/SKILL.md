# Skill: docx-ingest

> Ingestione progressiva di documenti Word voluminosi con ottimizzazione del contesto.
> Si basa sulla disclosure progressiva descritta in `rules/token-economy.md`.

## Quando usarla

Quando l'utente vuole lavorare su un documento Word (.doc/.docx) presente in `_notes/`.
Tipicamente per ricostruire la storia della rete da documenti esistenti.

## Tre livelli di disclosure

### Livello 1 — TOC e skeleton

Estrarre solo la struttura del documento (indice, titoli di sezione).
Restituire l'elenco numerato delle sezioni. Costo minimo di token.

```powershell
# Usare python-docx via python, oppure pandoc se disponibile
# Estrarre solo headings (Heading 1, Heading 2)
pandoc ".\path\al\file.docx" --to markdown | Select-String "^#+\s"
```

Output: elenco sezioni con numero e titolo. Chiedere all'utente quali sezioni leggere.

### Livello 2 — Anteprima sezioni

Per le sezioni di interesse, estrarre le prime N righe (tipicamente 20-30) per capire
il contenuto senza leggere tutto.

```powershell
# Estrarre il documento completo una volta sola, salvare in _notes/.tmp-docx-<nome>/
# poi accedere per indice di sezione
```

Output: anteprima testuale di ogni sezione selezionata.

### Livello 3 — Sezione completa

Per la sezione specifica richiesta dall'utente, restituire il testo completo.

## Manifesto anti-rilettura

Al primo accesso a un documento, creare `_notes/.manifest-docx.json`:

```json
{
  "documents": [
    {
      "path": "_notes/docs-word/documento.docx",
      "hash": "<sha256>",
      "last_modified": "2026-06-22",
      "extracted_at": "2026-06-22",
      "sections": ["1. Introduzione", "2. Configurazione", ...],
      "tmp_dir": "_notes/.tmp-docx-documento/"
    }
  ]
}
```

Se il documento non e' cambiato (hash identico), usare l'estrazione gia' presente
in `_notes/.tmp-docx-<nome>/`. Evitare riletture costose.

## Procedura operativa

1. Verificare se il documento e' nel manifesto con hash corrente
2. Se no: estrarre con pandoc/python-docx in `_notes/.tmp-docx-<nome>/`
3. Aggiornare il manifesto
4. Presentare il Livello 1 (TOC)
5. Attendere la selezione delle sezioni
6. Presentare Livello 2 (anteprime) delle sezioni selezionate
7. Attendere richiesta di lettura completa per sezione specifica
8. Presentare Livello 3 per la sezione richiesta
9. Per gli eventi rilevanti estratti: proporre aggiunta a `docs/infrastructure-timeline/`

## Output versionato

I mirror Markdown curati delle sezioni rilevanti vanno in `docs/infrastructure-timeline/`
con nome file `YYYY-MM-DD_evento-breve.md`. Quelli grezzi restano in `_notes/.tmp-docx-*/`.

## Strumenti da verificare prima di usare

```powershell
pandoc --version
python --version; python -c "import docx"
```

Se nessuno dei due e' disponibile, segnalare all'utente prima di procedere.
