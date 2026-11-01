#!/usr/bin/env bash
#
# consultas.sh <consulta> [ventana] — preguntas frecuentes a los logs de la tienda.
#
#   resumen   peticiones por servicio, ruta y código de estado
#   errores   líneas warning o peores, agrupadas por servicio y evento
#   lentas    las 10 peticiones más lentas
#   p95       percentil 95 de duration_ms por servicio y ruta

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
consulta="${1:?uso: consultas.sh <resumen|errores|lentas|p95> [ventana]}"
ventana="${2:-10m}"

logs() {
  docker compose -f "$RAIZ/app/compose.yaml" logs --no-log-prefix --since "$ventana" \
    catalogo pedidos pagos notificaciones
}

case "$consulta" in
  resumen)
    # TODO (paso 1): cuenta las líneas http_request por service, route y status_code.
    logs | jq -s -r 'length'
    ;;
  errores)
    # TODO (paso 2): las líneas con level warning, error o critical, contadas por
    # service y event, de más a menos.
    logs | jq -s -r 'length'
    ;;
  lentas)
    # TODO (paso 3): las 10 líneas http_request con mayor duration_ms, mostrando
    # duration_ms, service, route, status_code y request_id.
    logs | jq -s -r 'length'
    ;;
  p95)
    # TODO (paso 4): por service y route, el valor de duration_ms que deja por
    # debajo al 95 % de las peticiones (ordena y toma el índice floor(0.95 * n)).
    logs | jq -s -r 'length'
    ;;
  *)
    echo "consulta desconocida: $consulta" >&2
    exit 1
    ;;
esac
