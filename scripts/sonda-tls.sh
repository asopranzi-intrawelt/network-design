#!/bin/sh
# Sonda TLS: interroga dalla rete gli endpoint indicati e ne stampa il certificato.
#
# Perche' esiste, accanto a ispeziona-tls.sh. Quello guarda dentro una macchina e
# dice come e' configurata; questo guarda da fuori e dice che cosa vede davvero un
# client, che e' la domanda che conta quando si valuta un certificato: e' il campo
# osservato dal navigatore a determinare se comparira' un avviso, non il file su
# disco. Serve anche nei casi in cui il certificato vive dentro un contenitore la cui
# immagine non porta gli strumenti per leggerlo, che e' il caso incontrato il
# 01/09/2026 sull'immagine minimale del contenitore di inoltro di IntraLino.
#
# Uso: sonda-tls.sh host:porta [host:porta ...]
# Non scrive nulla, non invia credenziali, non completa una sessione applicativa:
# apre la negoziazione cifrata, legge il certificato presentato e chiude.

if [ $# -eq 0 ]; then
  echo "nessun endpoint indicato: uso sonda-tls.sh host:porta [host:porta ...]"
  exit 0
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl non disponibile su questo host: la sonda non puo' girare da qui"
  exit 0
fi

for ep in "$@"; do
  echo "=== $ep ==="
  cert=$(echo | openssl s_client -connect "$ep" -servername "${ep%%:*}" 2>/dev/null | \
         sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p')
  if [ -z "$cert" ]; then
    echo "  nessun certificato presentato: la porta non risponde in cifrato oppure non e' raggiungibile"
    continue
  fi
  sub=$(echo "$cert" | openssl x509 -noout -subject 2>/dev/null)
  iss=$(echo "$cert" | openssl x509 -noout -issuer 2>/dev/null)
  echo "  $sub"
  echo "  $iss"
  echo "$cert" | openssl x509 -noout -dates 2>/dev/null | sed 's/^/  /'
  echo "$cert" | openssl x509 -noout -ext subjectAltName 2>/dev/null | sed 's/^/  /' | head -4
  ca=$(echo "$cert" | openssl x509 -noout -text 2>/dev/null | grep -c 'CA:TRUE')
  echo "  autorita' di certificazione: $([ "$ca" -gt 0 ] && echo si || echo no)"
  if [ "$sub" = "$(echo "$iss" | sed 's/^issuer=/subject=/')" ]; then
    echo "  autofirmato: SI, nessuna autorita' indipendente lo garantisce"
  else
    echo "  autofirmato: no, emesso da un'autorita' distinta dal soggetto"
  fi
done
echo "=== fine sonda ==="
