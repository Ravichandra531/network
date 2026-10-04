source ~/cn-team.env
mkdir -p ~/team-certs && cd ~/team-certs

# 1) Our team's CA (the "trust anchor"). The 4096-bit key takes a few seconds
openssl genrsa -out team-CA.key 4096
openssl req -x509 -new -nodes -key team-CA.key -sha256 -days 365 \
  -out team-CA.pem -subj "/CN=$TEAM Local Root CA"

# 2) Server key + certificate signing request (CSR)
openssl genrsa -out app.key 2048
openssl req -new -key app.key -out app.csr -subj "/CN=app.$TEAM.test"

# 3) Extensions. SAN is required: browsers ignore CN for matching the hostname
cat > app.ext <<EOF
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:app.$TEAM.test, DNS:api.$TEAM.test
EOF

# 4) The CA signs the server certificate
openssl x509 -req -in app.csr -CA team-CA.pem -CAkey team-CA.key \
  -CAcreateserial -out app.crt -days 365 -sha256 -extfile app.ext

# 5) Check it (screenshot this)
openssl x509 -in app.crt -noout -text | grep -A1 -E "Issuer|Subject:|Alternative"
openssl verify -CAfile team-CA.pem app.crt        # must print: app.crt: OK

# 6) Give nginx its copy
cp app.crt app.key "$(brew --prefix)/etc/nginx/certs/"
chmod 600 "$(brew --prefix)/etc/nginx/certs/app.key"