#!/bin/sh
# Censimento in sola lettura dell'esposizione di un host Linux (micro-step M27-7).
#
# Interroga i quattro livelli a cui puo' vivere un filtro, perche' guardarne uno
# solo produce un quadro parziale: e' l'errore corretto il 31/08/2026 dopo che il
# censimento con il solo `ufw` aveva mancato la restrizione per indirizzo attiva
# sulla VM 204. Vedi docs/esposizione-servizi-interni.md.
#
# Non scrive nulla sull'host e non apre connessioni. Va eseguito come root.
# Si lancia dalla postazione con scripts/Invoke-HostCensus.ps1, che lo copia,
# lo esegue e ne raccoglie l'esito in output/, ignorato da git.

echo "=== $(hostname) | $(hostname -I 2>/dev/null) ==="
grep -h PRETTY_NAME /etc/os-release 2>/dev/null
echo "data rilievo: $(date -Iseconds)"

echo
echo "--- 1. filtro di pacchetti del kernel ---"
if command -v ufw >/dev/null 2>&1; then ufw status verbose; else echo "ufw: non installato"; fi
if command -v nft >/dev/null 2>&1; then
  n=$(nft list ruleset 2>/dev/null | grep -cvE '^\s*$')
  if [ "${n:-0}" -gt 0 ]; then echo "nftables: $n righe"; nft list ruleset 2>/dev/null | head -60
  else echo "nftables: nessuna regola"; fi
else echo "nft: comando assente"; fi
if command -v iptables >/dev/null 2>&1; then
  echo "iptables (filter, senza le politiche predefinite):"
  iptables -S 2>/dev/null | grep -v '^-P' | head -40
  echo "iptables (nat, catene di Docker escluse dal conteggio):"
  iptables -t nat -S 2>/dev/null | grep -v '^-P' | grep -vc DOCKER
else echo "iptables: comando assente"; fi

echo
echo "--- 2. server web: direttive di ammissione per indirizzo ---"
grep -rniE '^[[:space:]]*(allow|deny)[[:space:]]' /etc/nginx /etc/apache2 /etc/httpd 2>/dev/null | head -40 \
  || echo "nessuna direttiva allow/deny nei percorsi standard"
grep -rliE '(allow|deny)[[:space:]]+[0-9]{1,3}\.' /etc/nginx /etc/apache2 /etc/httpd 2>/dev/null | head -10 \
  | sed 's/^/file con liste di indirizzi: /'

echo
echo "--- 3. porte in ascolto, con il processo ---"
ss -tulpn 2>/dev/null | grep -E 'LISTEN|UNCONN'

echo
echo "--- 4. contenitori ---"
if command -v docker >/dev/null 2>&1; then
  docker ps --format '{{.Names}} | {{.Image}} | {{.Ports}}' 2>/dev/null || echo "docker presente ma non interrogabile"
else echo "docker: comando assente"; fi

echo
echo "--- 5. autenticazione SSH ammessa ---"
grep -hiE '^[[:space:]]*(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)' \
  /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null | sort -u
echo "=== fine $(hostname) ==="
