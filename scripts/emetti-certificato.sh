#!/bin/sh
# Emette un certificato di servizio firmato dall'autorita' interna. Attua ADR-024 e ADR-025.
#
# Dove si esegue. Come crea-autorita.sh: sulla cartella dell'autorita', che vive su un
# supporto rimovibile. La chiave privata del servizio viene generata qui e va poi
# trasferita sulla macchina che serve quel nome; la chiave dell'autorita' non si sposta
# mai. Al termine lo script ricorda entrambe le cose.
#
# Perche' il nome alternativo e' obbligatorio e non un dettaglio. Dal 2017 i navigatori
# ignorano il nome comune del soggetto e leggono soltanto l'elenco dei nomi alternativi:
# un certificato che porti il nome solo nel soggetto viene rifiutato come se il nome non
# ci fosse. E' l'errore piu' comune quando si emette a mano, e questo script lo rende
# impossibile perche' costruisce sempre l'estensione.
#
# Sulla durata. Un'autorita' interna senza infrastruttura di revoca non ha modo di
# annullare un certificato prima della scadenza: la scadenza E' l'unico meccanismo di
# revoca. Da qui la durata breve predefinita, che obbliga a rinnovare ogni anno e ha un
# beneficio secondario non trascurabile, cioe' tenere viva una procedura che altrimenti
# si eseguirebbe una volta e si dimenticherebbe.
#
# Uso: emetti-certificato.sh <cartella-autorita> <nome.completo> [altro.nome ...]

CARTELLA=$1
shift 2>/dev/null
NOME=$1

if [ -z "$CARTELLA" ] || [ -z "$NOME" ]; then
  echo "Uso: emetti-certificato.sh <cartella-autorita> <nome.completo> [altro.nome ...]"
  echo "Esempio: sh emetti-certificato.sh /media/ca-aziendale vault.int.intrawelt.com"
  exit 1
fi
[ -f "$CARTELLA/ca.key" ] || { echo "Nessuna autorita' in '$CARTELLA': eseguire prima crea-autorita.sh"; exit 1; }

GIORNI=${GIORNI:-398}
BASE="$CARTELLA/$NOME"
[ -f "$BASE.key" ] && { echo "ERRORE: esiste gia' un certificato per '$NOME' in questa cartella."; exit 1; }

# Elenco dei nomi alternativi: il primo e' il nome principale, gli altri eventuali alias.
ALT="DNS:$NOME"
for a in "$@"; do
  [ "$a" = "$NOME" ] && continue
  ALT="$ALT,DNS:$a"
done

echo "Emissione di un certificato di servizio"
echo "  nome principale: $NOME"
echo "  nomi alternativi: $ALT"
echo "  validita': $GIORNI giorni"
echo

umask 077
openssl genrsa -out "$BASE.key" 2048 || exit 1
chmod 400 "$BASE.key"

openssl req -new -key "$BASE.key" -out "$BASE.csr" \
        -subj "/C=IT/O=Intrawelt/CN=$NOME" || exit 1

cat > "$BASE.ext" <<EXT
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=$ALT
EXT

echo "Verra' chiesta la passphrase della chiave dell'autorita'."
openssl x509 -req -in "$BASE.csr" -CA "$CARTELLA/ca.crt" -CAkey "$CARTELLA/ca.key" \
        -CAserial "$CARTELLA/ca.srl" -out "$BASE.crt" -days "$GIORNI" -sha256 \
        -extfile "$BASE.ext" || exit 1
chmod 444 "$BASE.crt"

echo
echo "Certificato emesso. Verifica dei campi che contano:"
openssl x509 -in "$BASE.crt" -noout -subject -issuer -dates -ext subjectAltName | sed 's/^/  /'
echo
echo "Da portare sulla macchina che serve '$NOME':"
echo "  $BASE.crt   certificato, pubblico"
echo "  $BASE.key   chiave privata: si trasferisce una volta sola, poi si cancella dal supporto"
echo "              di transito; sulla macchina va con permessi di sola lettura per il servizio"
echo
echo "NON si trasferisce mai ca.key, che resta su questo supporto."
echo "Sulla macchina di destinazione serve anche ca.crt se qualche componente deve"
echo "verificare altri servizi interni; per servire il proprio nome non e' necessario."
