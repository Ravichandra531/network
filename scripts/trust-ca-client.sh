#!/usr/bin/env bash
# Run on each client Mac: ./trust-ca-client.sh /path/to/ca.crt
set -e
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$1"
echo "CA trusted. Restart your browser. Firefox: import manually in its settings."
