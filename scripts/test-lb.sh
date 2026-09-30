#!/usr/bin/env bash
# Run on a client: shows alternating X-Backend headers
source "$(dirname "$0")/../config/env.sh"
for i in $(seq 1 ${1:-6}); do
  curl -sI https://app.${TEAM}.test/api/status | grep -i x-backend
done
