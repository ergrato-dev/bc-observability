#!/usr/bin/env bash
#
# romper.sh <1|2> — activa una avería del lab 03.
# No lo leas antes de diagnosticarla: el lab consiste en encontrarla sin saberla.

set -euo pipefail

PAGOS="http://127.0.0.1:18003"
TOXIPROXY="http://127.0.0.1:8474"

case "${1:-}" in
  1)
    curl -sf -X PUT "$PAGOS/admin/faults" -H 'Content-Type: application/json' \
      -d '{"error_rate":0.35,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}' >/dev/null
    ;;
  2)
    curl -sf -X POST "$TOXIPROXY/proxies/pagos/toxics" -d \
      '{"name":"lab03","type":"latency","stream":"downstream","attributes":{"latency":1800,"jitter":800}}' >/dev/null
    ;;
  *)
    echo "uso: romper.sh <1|2>" >&2
    exit 1
    ;;
esac
echo "Avería $1 activa. Diagnostícala solo con docker compose logs."
