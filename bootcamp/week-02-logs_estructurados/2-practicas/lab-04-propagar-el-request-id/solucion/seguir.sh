#!/usr/bin/env bash
#
# seguir.sh <request_id> [ventana] — todas las líneas de una petición en los
# cuatro servicios de la tienda, en orden cronológico (SOLUCIÓN).

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
request_id="${1:?uso: seguir.sh <request_id> [ventana, p. ej. 10m]}"
ventana="${2:-10m}"

docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "$ventana" \
  catalogo pedidos pagos notificaciones \
  | jq -s -r --arg r "$request_id" '
      map(select(.request_id == $r))
      | sort_by(.timestamp)[]
      | [.timestamp, .service, .level, .event,
         (del(.timestamp, .service, .level, .event, .request_id) | tojson)]
      | @tsv'
