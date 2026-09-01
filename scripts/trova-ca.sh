#!/bin/sh
# Individua l'autorita' di certificazione interna su un host e ne valuta la custodia.
#
# Perche' cercare per contenuto e non per nome. Una ricerca per nome di file annega
# nei certificati di sistema, che su qualunque distribuzione sono centinaia, e
# soprattutto non trova il file cercato se chi l'ha creato gli ha dato un nome
# diverso da quello atteso. Si cercano quindi i certificati che **dichiarano** di
# essere un'autorita' e il cui soggetto corrisponde al motivo cercato.
#
# Che cosa riporta di una chiave privata, e cosa no. Riporta il percorso, il
# proprietario, i permessi e se sia protetta da passphrase, che sono i quattro dati
# con cui si giudica la custodia. NON stampa mai il contenuto: della chiave legge la
# sola prima riga, che dichiara il tipo ed e' pubblica per costruzione, e la usa per
# distinguere una chiave cifrata da una in chiaro.
#
# Limite noto, e la correzione del 01/09/2026. Una ricerca per contenuto e' buona
# quanto l'elenco di percorsi che attraversa: la prima versione non comprendeva
# /var/lib/ca, ed e' esattamente dove la chiave si trovava, quindi concluse che non
# ci fosse. L'elenco e' stato esteso, ma il limite resta strutturale e va ricordato:
# un esito negativo di questo script significa "non trovato nei percorsi cercati", mai
# "non esiste". Se un servizio presenta un certificato, la chiave esiste da qualche
# parte, e la via piu' diretta per trovarla e' guardare da dove il servizio la legge,
# con scripts/trova-ca-container.sh per i contenitori.
#
# Uso: trova-ca.sh [motivo]   (motivo predefinito: "Internal CA")

MOTIVO=${1:-Internal CA}
echo "=== $(hostname): ricerca di un'autorita' interna, motivo: $MOTIVO ==="

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl assente: impossibile esaminare i certificati"
  echo "=== fine ==="
  exit 0
fi

echo
echo "--- 1. certificati di autorita' che corrispondono al motivo ---"
trovati=0
for base in /root /home /opt /srv /etc /var/lib/ca /var/lib/ssl /var/lib/docker/volumes /data /usr/local; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 6 \( -name '*.crt' -o -name '*.pem' -o -name '*.cer' \) \
       ! -path '*/ca-certificates/*' ! -path '*/ssl/certs/*' 2>/dev/null | while read -r c; do
    sub=$(openssl x509 -in "$c" -noout -subject 2>/dev/null) || continue
    case "$sub" in *"$MOTIVO"*) ;; *) continue;; esac
    ca=$(openssl x509 -in "$c" -noout -text 2>/dev/null | grep -c 'CA:TRUE')
    echo "  certificato: $c"
    echo "    $sub"
    echo "    $(openssl x509 -in "$c" -noout -issuer 2>/dev/null)"
    echo "    $(openssl x509 -in "$c" -noout -enddate 2>/dev/null)"
    echo "    e' un'autorita': $([ "$ca" -gt 0 ] && echo si || echo no)"
    echo "    proprietario e permessi: $(ls -l "$c" | awk '{print $3":"$4" "$1}')"
    echo "    impronta: $(openssl x509 -in "$c" -noout -fingerprint -sha1 2>/dev/null | cut -d= -f2)"
  done
done

echo
echo "--- 2. chiavi private accanto ai certificati trovati, e loro custodia ---"
for base in /root /home /opt /srv /etc /var/lib/ca /var/lib/ssl /var/lib/docker/volumes /data /usr/local; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 6 \( -name '*.key' -o -name '*key*.pem' \) \
       ! -path '*/doc/*' ! -path '*/examples/*' 2>/dev/null | while read -r k; do
    intestazione=$(head -1 "$k" 2>/dev/null)
    case "$intestazione" in *PRIVATE*KEY*) ;; *) continue;; esac
    cifrata=no
    case "$intestazione" in *ENCRYPTED*) cifrata=si;; esac
    if [ "$cifrata" = no ] && grep -qi 'Proc-Type.*ENCRYPTED' "$k" 2>/dev/null; then cifrata=si; fi
    echo "  chiave: $k"
    echo "    tipo dichiarato: $intestazione"
    echo "    protetta da passphrase: $cifrata"
    echo "    proprietario e permessi: $(ls -l "$k" | awk '{print $3":"$4" "$1}')"
  done
done

echo
echo "--- 3. copie dell'autorita' fra le attendibili di questo host ---"
ls -l /usr/local/share/ca-certificates/ 2>/dev/null | sed 's/^/  /' || echo "  nessuna"

echo
echo "--- 4. tracce di una procedura di emissione ---"
for base in /root /home /opt /srv; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 5 \( -name '*.cnf' -o -name '*.srl' -o -name 'index.txt' -o -name '*ca*.sh' \) 2>/dev/null \
    | grep -viE 'node_modules|/doc/' | head -10 | sed 's/^/  /'
done
echo "=== fine ==="
