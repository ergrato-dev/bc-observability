#!/usr/bin/env bash
#
# buscar-pii.sh [ventana] — cuenta, por servicio, las líneas de log con un email
# o un número de tarjeta (SOLUCIÓN).

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
ventana="${1:-10m}"
# Un email, o un número de 13 a 19 cifras que no forme parte de una palabra más larga.
PATRON='[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+[.][A-Za-z]{2,}|(^|[^0-9A-Za-z])[0-9]{13,19}([^0-9A-Za-z]|$)'

for servicio in catalogo pedidos pagos notificaciones; do
  n=$(docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "$ventana" "$servicio" \
    | grep -cE "$PATRON" || true)
  printf '%-15s %s\n' "$servicio" "$n"
done
