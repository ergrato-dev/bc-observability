#!/usr/bin/env bash
#
# red.sh <servicio> [segundos] — Rate y Errors de un servicio de la tienda a
# partir de sus logs de acceso.

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
servicio="${1:?uso: red.sh <servicio> [segundos]}"
ventana="${2:-60}"

# TODO (paso 1): guarda en "peticiones" solo las líneas de acceso del servicio
# en la ventana ("GET /x HTTP/1.1" 200). Descarta las del healthcheck.
peticiones=$(docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "${ventana}s" "$servicio")

# Mira qué hay dentro antes de contar nada.
head -5 <<<"$peticiones"

# TODO (paso 2): cuenta el total, los 5xx y los 4xx.
total=0
errores=0
rechazos=0

if (( total == 0 )); then
  echo "Sin peticiones de $servicio en los últimos ${ventana}s. ¿Tiene logs de acceso?" >&2
  exit 1
fi

# TODO (paso 2): imprime Rate (peticiones/s), Errors (% de 5xx) y 4xx (%).
# ¿Puedes calcular la Duration? Explica por qué en tu hoja.
echo "$servicio: $total peticiones, $errores errores, $rechazos rechazos"
