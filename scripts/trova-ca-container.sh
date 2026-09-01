#!/bin/sh
# Individua da dove un contenitore prende il proprio certificato.
#
# Serve quando la ricerca sull'host non trova nulla ma il servizio presenta un
# certificato valido, che e' la situazione incontrata il 01/09/2026 su IntraLino: il
# certificato esiste, perche' la sonda dalla rete lo legge, ma non sta in nessuna
# cartella dell'host fra quelle esaminate. Le possibilita' sono tre e questo script
# le distingue: il certificato e' incorporato nell'immagine, oppure arriva da un
# volume del motore dei contenitori, oppure da una cartella dell'host innestata nel
# contenitore. Solo l'ultimo caso lascia un file su disco dove qualcuno lo cerchi.
#
# Non stampa mai il contenuto di una chiave: dei file riporta percorso, permessi e
# proprietario, e dei certificati i soli campi pubblici.

echo "=== $(hostname): origine dei certificati dei contenitori ==="
if ! command -v docker >/dev/null 2>&1; then
  echo "motore dei contenitori assente"
  echo "=== fine ==="
  exit 0
fi

docker ps --format '{{.Names}}' 2>/dev/null | while read -r c; do
  echo
  echo "--- contenitore $c ---"
  echo "  innesti dichiarati (sorgente sull'host -> destinazione nel contenitore):"
  docker inspect "$c" --format '{{range .Mounts}}    {{.Type}} {{.Source}} -> {{.Destination}} {{if .RW}}(scrivibile){{else}}(sola lettura){{end}}
{{end}}' 2>/dev/null

  echo "  riferimenti a certificati nella configurazione interna:"
  docker exec "$c" sh -c 'grep -rhE "ssl_certificate|ssl_certificate_key|SSLCertificate" /etc/nginx /etc/apache2 /etc/caddy 2>/dev/null | head -8' 2>/dev/null | sed 's/^/    /'

  echo "  file di certificato presenti nel contenitore:"
  docker exec "$c" sh -c 'find /etc /certs /ssl /data /opt -maxdepth 5 \( -name "*.crt" -o -name "*.pem" -o -name "*.key" \) ! -path "*/ca-certificates/*" ! -path "*/ssl/certs/*" 2>/dev/null | head -8' 2>/dev/null | sed 's/^/    /'
done
echo
echo "=== fine ==="
