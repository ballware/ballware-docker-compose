#!/usr/bin/env sh
# scripts/preseed.sh
set -eu

# ----- Defaults -----
: "${TEMPLATE_DIR:=/templates}"
: "${OUT_DIR:=/out}"
: "${CERTS_OUT_DIR:=/certs-out}"

: "${CERT_CN:=localhost}"
: "${CERT_DAYS:=365}"
: "${CERT_SAN_DNS:=localhost}"
: "${CERT_SAN_IP:=127.0.0.1}"

: "${MAKE_PKCS12:=false}"
: "${KEYSTORE_PASSWORD:=changeit}"
: "${PKCS12_NAME:=keycloak}"
: "${PKCS12_FILE:=keystore.p12}"

echo "[preseed] installing tools..."
apk add --no-cache gettext openssl >/dev/null

echo "[preseed] rendering realm templates from ${TEMPLATE_DIR} -> ${OUT_DIR}"
mkdir -p "${OUT_DIR}"
shoptf=0
# BusyBox ash doesn't have shopt; simple glob guard:
set +e; ls "${TEMPLATE_DIR}"/*.tpl >/dev/null 2>&1; has_tpl=$?; set -e
if [ "$has_tpl" -eq 0 ]; then
  for f in "${TEMPLATE_DIR}"/*.tpl; do
    [ -f "$f" ] || continue
    base="$(basename "${f%.tpl}.json")"
    envsubst < "$f" > "${OUT_DIR}/${base}"
    echo "  rendered: $(basename "$f") -> ${base}"
  done
else
  echo "  (no *.tpl files found, skipping rendering)"
fi

echo "[preseed] generating certificates into ${CERTS_OUT_DIR}"
mkdir -p "${CERTS_OUT_DIR}"

PEM_KEY="${CERTS_OUT_DIR}/tls.key"
PEM_CRT="${CERTS_OUT_DIR}/tls.crt"

if [ -f "${PEM_KEY}" ] && [ -f "${PEM_CRT}" ]; then
  echo "  PEM already exists, skipping generation."
else
  echo "  creating OpenSSL config with SANs…"
  cnf="/tmp/openssl.cnf"
  {
    echo "[req]"
    echo "distinguished_name = dn"
    echo "x509_extensions = v3_req"
    echo "prompt = no"
    echo "[dn]"
    echo "CN = ${CERT_CN}"
    echo "[v3_req]"
    echo "keyUsage = keyEncipherment,dataEncipherment,digitalSignature"
    echo "extendedKeyUsage = serverAuth"
    echo "subjectAltName = @alt_names"
    echo "[alt_names]"
    i=1
    OLDIFS="$IFS"; IFS=','; for d in $CERT_SAN_DNS; do
      [ -n "$d" ] && echo "DNS.$i = $d" && i=$((i+1))
    done
    j=1
    for ip in $CERT_SAN_IP; do
      [ -n "$ip" ] && echo "IP.$j  = $ip" && j=$((j+1))
    done
    IFS="$OLDIFS"
  } > "$cnf"

  echo "  generating self-signed certificate (${CERT_DAYS} days)…"
  openssl req -x509 -newkey rsa:2048 -nodes -days "${CERT_DAYS}" \
    -keyout "${PEM_KEY}" -out "${PEM_CRT}" -config "$cnf"
  echo "  created: ${PEM_CRT}, ${PEM_KEY}"
fi

if [ "${MAKE_PKCS12}" = "true" ]; then
  P12_PATH="${CERTS_OUT_DIR}/${PKCS12_FILE}"
  if [ -f "${P12_PATH}" ]; then
    echo "  PKCS#12 already exists, skipping generation."
  else
    echo "  generating PKCS#12 keystore (${P12_PATH})…"
    openssl pkcs12 -export \
      -inkey "${PEM_KEY}" -in "${PEM_CRT}" \
      -out "${P12_PATH}" -name "${PKCS12_NAME}" \
      -passout "pass:${KEYSTORE_PASSWORD}"
    echo "  created: ${P12_PATH}"
  fi
fi

chmod 0644 "${PEM_KEY}" "${PEM_CRT}"
chmod 0755 "${CERTS_OUT_DIR}"

echo "[preseed] done."
