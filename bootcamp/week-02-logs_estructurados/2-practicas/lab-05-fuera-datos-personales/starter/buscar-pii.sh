#!/usr/bin/env bash
#
# buscar-pii.sh [ventana] — cuenta, por servicio, las líneas de log con un email
# o un número de tarjeta.

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
ventana="${1:-10m}"
# TODO (paso 1): una expresión regular extendida que case con un email o con un
# número de 13 a 19 cifras que no forme parte de una palabra más larga.
PATRON='TODO'

for servicio in catalogo pedidos pagos notificaciones; do
  n=$(docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "$ventana" "$servicio" \
    | grep -cE "$PATRON" || true)
  printf '%-15s %s\n' "$servicio" "$n"
done
