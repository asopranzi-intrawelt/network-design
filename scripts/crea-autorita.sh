#!/bin/sh
# Genera l'autorita' di certificazione interna aziendale. Attua ADR-025.
#
# Si esegue UNA VOLTA SOLA, e da qui in avanti si usa soltanto emetti-certificato.sh.
#
# Dove si esegue. Sulla cartella dell'autorita', che secondo ADR-025 vive su un
# supporto rimovibile e non su una macchina: si collega il supporto, si lancia questo
# script indicandone il percorso, si scollega. Lo script non scrive nulla fuori da
# quella cartella, che e' la ragione per cui il percorso e' un parametro obbligatorio
# e non un valore predefinito: un valore predefinito finirebbe prima o poi sul disco
# della macchina di turno, che e' esattamente cio' che ADR-025 vieta.
#
# Che cosa produce: la chiave privata dell'autorita', protetta da passphrase e
# chiesta a runtime, il certificato dell'autorita' da distribuire alle postazioni,
# e il contatore dei numeri di serie.
#
# Uso: crea-autorita.sh <cartella> [anni]

CARTELLA=$1
ANNI=${2:-10}

if [ -z "$CARTELLA" ]; then
  echo "Uso: crea-autorita.sh <cartella-sul-supporto-rimovibile> [anni, predefinito 10]"
  echo "Esempio: sh crea-autorita.sh /media/ca-aziendale"
  exit 1
fi
if [ ! -d "$CARTELLA" ]; then
  echo "La cartella '$CARTELLA' non esiste: crearla sul supporto prima di procedere."
  exit 1
fi
if [ -f "$CARTELLA/ca.key" ]; then
  echo "ERRORE: in '$CARTELLA' esiste gia' una chiave di autorita'."
  echo "Questo script non sovrascrive: sovrascrivere una chiave di autorita' invalida in"
  echo "silenzio ogni certificato gia' emesso e ogni installazione gia' fatta."
  exit 1
fi

GIORNI=$((ANNI * 365))
# Il soggetto non contiene nomi di persona ne' indirizzi: identifica l'organizzazione
# e dichiara la natura dell'oggetto. Il nome comune dice che e' l'autorita' interna
# dell'azienda e non di un progetto, che e' la correzione rispetto all'autorita'
# preesistente descritta nel difetto #179.
SOGGETTO="/C=IT/O=Intrawelt/CN=Intrawelt Internal CA"

echo "Generazione dell'autorita' di certificazione interna"
echo "  cartella:  $CARTELLA"
echo "  soggetto:  $SOGGETTO"
echo "  validita': $ANNI anni"
echo
echo "Verra' chiesta una passphrase: e' quella che protegge la chiave dell'autorita'."
echo "Chi la conosce, insieme al file, puo' emettere certificati validi per qualunque"
echo "nome interno. Va scelta lunga, conservata secondo ADR-025 e mai scritta in un file."
echo

umask 077
openssl genrsa -aes256 -out "$CARTELLA/ca.key" 4096 || exit 1
chmod 400 "$CARTELLA/ca.key"

openssl req -x509 -new -key "$CARTELLA/ca.key" -sha256 -days "$GIORNI" \
        -out "$CARTELLA/ca.crt" -subj "$SOGGETTO" \
        -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" || exit 1
chmod 444 "$CARTELLA/ca.crt"
echo 1000 > "$CARTELLA/ca.srl"

echo
echo "Fatto. Nella cartella ora ci sono:"
ls -l "$CARTELLA" | sed 's/^/  /'
echo
echo "  ca.key  chiave privata, cifrata: NON esce mai dal supporto, non si copia, non si trasmette"
echo "  ca.crt  certificato dell'autorita': e' PUBBLICO e va distribuito a tutte le postazioni"
echo "  ca.srl  contatore dei numeri di serie, cresce a ogni certificato emesso"
echo
echo "Impronta del certificato, da confrontare al momento dell'installazione sulle postazioni:"
openssl x509 -in "$CARTELLA/ca.crt" -noout -fingerprint -sha256 | sed 's/^/  /'
echo
echo "Prossimo passo: emetti-certificato.sh per il primo servizio."
