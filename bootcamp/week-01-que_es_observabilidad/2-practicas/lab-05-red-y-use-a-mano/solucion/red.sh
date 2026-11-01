#!/usr/bin/env bash
#
# red.sh <servicio> [segundos] — Rate y Errors de un servicio de la tienda a
# partir de sus logs de acceso (SOLUCIÓN). La Duration no se puede calcular:
# los logs de acceso de uvicorn no registran cuánto tardó cada petición.

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
servicio="${1:?uso: red.sh <servicio> [segundos]}"
ventana="${2:-60}"

# Solo las líneas de acceso ("GET /x HTTP/1.1" 200), sin el healthcheck de Docker.
peticiones=$(docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "${ventana}s" "$servicio" \
  | grep -E '" [0-9]{3} ' | grep -v 'GET /health' || true)

total=$(grep -c . <<<"$peticiones" || true)
if (( total == 0 )); then
  echo "Sin peticiones de $servicio en los últimos ${ventana}s. ¿Tiene logs de acceso?" >&2
  exit 1
fi
errores=$(grep -cE '" 5[0-9]{2} ' <<<"$peticiones" || true)
rechazos=$(grep -cE '" 4[0-9]{2} ' <<<"$peticiones" || true)

awk -v s="$servicio" -v v="$ventana" -v t="$total" -v e="$errores" -v r="$rechazos" 'BEGIN {
  printf "%s, últimos %ds (%d peticiones)\n", s, v, t
  printf "  Rate:     %.2f peticiones/s\n", t / v
  printf "  Errors:   %.1f %% (5xx)\n", 100 * e / t
  printf "  4xx:      %.1f %% (respuestas de negocio, no fallos del sistema)\n", 100 * r / t
  printf "  Duration: no disponible en los logs de acceso\n"
}'

echo "  Endpoints más llamados:"
awk -F'"' '{ split($2, p, " "); print "    " p[1] " " p[2] }' <<<"$peticiones" | sort | uniq -c | sort -rn | head -5
