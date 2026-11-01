#!/usr/bin/env bash
#
# seguir.sh <request_id> [ventana] — todas las líneas de una petición en los
# cuatro servicios de la tienda, en orden cronológico.

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
request_id="${1:?uso: seguir.sh <request_id> [ventana, p. ej. 10m]}"
ventana="${2:-10m}"

docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "$ventana" \
  catalogo pedidos pagos notificaciones \
  | jq -s -r --arg r "$request_id" '
      # TODO (paso 6): quédate con las líneas de ese request_id, ordénalas por
      # timestamp e imprime cada una como: timestamp  servicio  level  event
      # seguido del resto de campos en JSON compacto.
      .[] | tostring'
