#!/usr/bin/env bash
#
# reparar.sh — quita las averías del lab 03 y deja pagos con su configuración por defecto.

set -euo pipefail

curl -sf -X PUT "http://127.0.0.1:18003/admin/faults" -H 'Content-Type: application/json' \
  -d '{"error_rate":0.02,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}' >/dev/null
# 404 si la avería 2 no estaba activa: no es un error.
curl -s -o /dev/null -X DELETE "http://127.0.0.1:8474/proxies/pagos/toxics/lab03"
echo "Averías retiradas."
