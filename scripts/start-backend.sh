#!/usr/bin/env bash
# Usage: ./start-backend.sh A   (Mac 3)   or   ./start-backend.sh B   (Mac 4)
cd "$(dirname "$0")/.."
source config/env.sh
case "$1" in
  A) exec python3 backend/backend.py A "$PORT_A" ;;
  B) exec python3 backend/backend.py B "$PORT_B" ;;
  *) echo "Usage: $0 A|B"; exit 1 ;;
esac
