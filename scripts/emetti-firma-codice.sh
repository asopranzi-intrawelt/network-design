#!/bin/sh
# Emette il certificato di firma del codice per le applicazioni interne, firmato
# dall'autorita' aziendale. Attua ADR-025 e la richiesta del progetto collegato
# integrita-docs (ADR-009 di quel progetto).
#
# Dove si esegue. Come crea-autorita.sh: sul supporto rimovibile dell'autorita'. La chiave
# di firma resta anch'essa fuori linea, nella sottocartella firma-codice/ dello stesso
# supporto, protetta da una passphrase propria e diversa da quella dell'autorita': chi
# firma un rilascio collega il supporto, firma, scollega. Non si copia su una postazione.
#
# Perche' un certificato dedicato e non uno di servizio. Il certificato porta come uso esteso
# soltanto codeSigning e non serverAuth: se la chiave venisse sottratta, non servirebbe a
# impersonare un servizio interno, e un certificato di servizio sottratto non servirebbe a
# firmare eseguibili. Se un antivirus autorizzasse i file per impronta di questo certificato,
# chi ne ottenesse la chiave potrebbe far passare qualunque eseguibile: da qui la passphrase
# propria e la durata breve, che anche qui e' l'unico meccanismo di revoca.
#
# Che cosa produce, in <cartella-autorita>/firma-codice/:
#   firma-codice.key  chiave privata cifrata (AES-256), passphrase propria
#   firma-codice.crt  certificato, pubblico
#   firma-codice.pfx  chiave e catena in PKCS#12 per Set-AuthenticodeSignature, con una
#                     password di esportazione; si usa dal supporto, senza importarlo
#
# Uso: emetti-firma-codice.sh <cartella-autorita>

CARTELLA=$1

if [ -z "$CARTELLA" ]; then
  echo "Uso: emetti-firma-codice.sh <cartella-autorita>"
  echo "Esempio: sh emetti-firma-codice.sh /k/ca-aziendale"
  exit 1
fi
[ -f "$CARTELLA/ca.key" ] || { echo "Nessuna autorita' in '$CARTELLA': eseguire prima crea-autorita.sh"; exit 1; }

GIORNI=${GIORNI:-397}
DIR="$CARTELLA/firma-codice"
BASE="$DIR/firma-codice"
[ -f "$BASE.key" ] && { echo "ERRORE: in '$DIR' esiste gia' una chiave di firma. Per rinnovare, spostarla prima in un archivio."; exit 1; }
mkdir -p "$DIR" || exit 1

SOGGETTO="/C=IT/O=Intrawelt/CN=Intrawelt Code Signing"
echo "Emissione del certificato di firma del codice"
echo "  soggetto:  $SOGGETTO"
echo "  uso:       codeSigning soltanto"
echo "  validita': $GIORNI giorni"
echo

umask 077
echo "1/4  Chiave di firma: verra' chiesta una passphrase NUOVA, diversa da quella dell'autorita'."
openssl genrsa -aes256 -out "$BASE.key" 3072 || exit 1
chmod 400 "$BASE.key"

echo "2/4  Richiesta di certificato: verra' chiesta la passphrase della chiave di firma."
openssl req -new -key "$BASE.key" -out "$BASE.csr" -subj "$SOGGETTO" || exit 1

cat > "$BASE.ext" <<EXT
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature
extendedKeyUsage=critical,codeSigning
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EXT

echo "3/4  Firma dell'autorita': verra' chiesta la passphrase della chiave dell'AUTORITA'."
openssl x509 -req -in "$BASE.csr" -CA "$CARTELLA/ca.crt" -CAkey "$CARTELLA/ca.key" \
        -CAserial "$CARTELLA/ca.srl" -out "$BASE.crt" -days "$GIORNI" -sha256 \
        -extfile "$BASE.ext" || exit 1
chmod 444 "$BASE.crt"

echo "4/4  PKCS#12 per Windows: prima la passphrase della chiave di firma, poi una password"
echo "     di esportazione, che si chiede a ogni firma (puo' coincidere con la passphrase di firma)."
openssl pkcs12 -export -inkey "$BASE.key" -in "$BASE.crt" -certfile "$CARTELLA/ca.crt" \
        -name "Intrawelt Code Signing" -out "$BASE.pfx" \
        -keypbe AES-256-CBC -certpbe AES-256-CBC -macalg SHA256 || exit 1
chmod 400 "$BASE.pfx"
rm -f "$BASE.csr"

echo
echo "Certificato emesso. Verifica dei campi che contano:"
openssl x509 -in "$BASE.crt" -noout -subject -issuer -dates -ext extendedKeyUsage,keyUsage,basicConstraints | sed 's/^/  /'
echo
echo "Impronte, da registrare (SHA-1 per un'eventuale esclusione GravityZone di tipo"
echo "Certificate hash, SHA-256 per il registro dei rilasci):"
openssl x509 -in "$BASE.crt" -noout -fingerprint -sha1 | sed 's/^/  /'
openssl x509 -in "$BASE.crt" -noout -fingerprint -sha256 | sed 's/^/  /'
echo
echo "firma-codice.key e firma-codice.pfx restano su questo supporto e sulla sua copia."
