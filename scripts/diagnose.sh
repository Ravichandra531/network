#!/usr/bin/env bash
# Layer-by-layer diagnosis: DNS -> TCP -> TLS -> HTTP
source "$(dirname "$0")/../config/env.sh"
H="app.${TEAM}.test"
echo "== 1. DNS =="; dig +short $H
echo "== 2. IP / TCP =="; ping -c 2 "$MAC2_IP"; nc -vz "$MAC2_IP" "$HTTPS_PORT"
echo "== 3. TLS =="; openssl s_client -connect $H:$HTTPS_PORT -servername $H </dev/null 2>&1 | grep -E "subject=|issuer=|Verify return|Verification"
echo "== 4. HTTP =="; curl -sv https://$H:$HTTPS_PORT/api/status 2>&1 | grep -E "^< |^\{"
