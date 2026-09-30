#!/usr/bin/env bash
# Run on Mac 2. Creates local CA + server cert in $PKI_DIR
set -e
cd "$(dirname "$0")/.."
source config/env.sh
mkdir -p "$PKI_DIR" && cd "$PKI_DIR"
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 825 \
  -subj "/C=IN/O=${TEAM}/CN=${TEAM} Local CA" -out ca.crt
openssl genrsa -out app.key 2048
openssl req -new -key app.key -subj "/CN=app.${TEAM}.test" -out app.csr
cat > san.ext <<EOT
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names
[alt_names]
DNS.1=app.${TEAM}.test
DNS.2=api.${TEAM}.test
EOT
openssl x509 -req -in app.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out app.crt -days 365 -sha256 -extfile san.ext
openssl verify -CAfile ca.crt app.crt
echo "Share ONLY $PKI_DIR/ca.crt with clients. Never share/commit *.key."
