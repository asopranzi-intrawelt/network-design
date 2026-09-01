#!/bin/sh
# Ricognizione in sola lettura dello stato TLS di un host (intervento su gap #160).
#
# Risponde a tre domande che vanno chiuse prima di aggiungere HTTPS a un servizio
# interno: quale server web e' davanti all'applicazione e come le parla, se il
# supporto TLS e' gia' predisposto, e se sulla macchina esistano gia' certificati
# e di che natura siano, cioe' autofirmati oppure emessi da un'autorita' interna.
#
# L'ultima domanda e' quella che orienta la scelta fra un certificato per servizio
# e un'autorita' interna: vedi docs/esposizione-servizi-interni.md.
#
# Non scrive nulla e non legge nessuna chiave privata: dei certificati stampa solo
# i campi pubblici (soggetto, emittente, validita'), mai il contenuto delle chiavi.

echo "=== $(hostname) | $(hostname -I 2>/dev/null) ==="

echo
echo "--- 1. server web presenti e in esecuzione ---"
for s in apache2 nginx caddy httpd; do
  if command -v "$s" >/dev/null 2>&1 || [ -d "/etc/$s" ]; then
    stato=$(systemctl is-active "$s" 2>/dev/null || echo "n/d")
    echo "$s: presente, stato $stato"
  fi
done

echo
echo "--- 2. host virtuali attivi ---"
for d in /etc/apache2/sites-enabled /etc/nginx/sites-enabled /etc/nginx/conf.d; do
  [ -d "$d" ] || continue
  echo "[$d]"
  ls -l "$d" 2>/dev/null | sed 's/^/  /'
  for f in "$d"/*; do
    [ -f "$f" ] || [ -L "$f" ] || continue
    echo "  ----- $f"
    grep -vE '^\s*#|^\s*$' "$f" 2>/dev/null | sed 's/^/    /'
  done
done

echo
echo "--- 3. moduli TLS e proxy ---"
if command -v apache2ctl >/dev/null 2>&1; then
  apache2ctl -M 2>/dev/null | grep -E 'ssl|proxy|rewrite|headers' || echo "  nessun modulo TLS o proxy attivo"
fi
if command -v nginx >/dev/null 2>&1; then
  nginx -V 2>&1 | tr ' ' '\n' | grep -E 'ssl' | sed 's/^/  /'
fi

echo
echo "--- 4. porte su cui il server web e' predisposto ---"
[ -f /etc/apache2/ports.conf ] && grep -vE '^\s*#|^\s*$' /etc/apache2/ports.conf | sed 's/^/  /'

echo
echo "--- 5. certificati presenti, solo campi pubblici ---"
for d in /etc/ssl/certs /etc/ssl/private /etc/apache2/ssl /etc/nginx/ssl /etc/letsencrypt/live /opt /srv /root; do
  [ -d "$d" ] || continue
  find "$d" -maxdepth 3 \( -name '*.crt' -o -name '*.pem' -o -name '*.cer' \) 2>/dev/null | head -12 | while read -r c; do
    case "$c" in /etc/ssl/certs/*) continue;; esac
    sub=$(openssl x509 -in "$c" -noout -subject 2>/dev/null)
    [ -n "$sub" ] || continue
    iss=$(openssl x509 -in "$c" -noout -issuer 2>/dev/null)
    val=$(openssl x509 -in "$c" -noout -enddate 2>/dev/null)
    ca=$(openssl x509 -in "$c" -noout -text 2>/dev/null | grep -c 'CA:TRUE')
    echo "  file: $c"
    echo "    $sub"
    echo "    $iss"
    echo "    $val | autorita' di certificazione: $([ "$ca" -gt 0 ] && echo si || echo no)"
    echo "    autofirmato: $([ "$sub" = "$(echo "$iss" | sed 's/^issuer=/subject=/')" ] && echo si || echo no)"
  done
done

echo
echo "--- 6. autorita' interne gia' considerate attendibili dal sistema ---"
ls /usr/local/share/ca-certificates/ 2>/dev/null | sed 's/^/  /' || echo "  nessuna"

echo
echo "--- 7. contenitori e loro pubblicazione ---"
if command -v docker >/dev/null 2>&1; then
  docker ps --format '{{.Names}} | {{.Image}} | {{.Ports}}' 2>/dev/null || echo "  non interrogabile"
fi
echo "=== fine $(hostname) ==="
