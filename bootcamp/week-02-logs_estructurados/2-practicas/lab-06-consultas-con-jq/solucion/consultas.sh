#!/usr/bin/env bash
#
# consultas.sh <consulta> [ventana] — preguntas frecuentes a los logs de la tienda (SOLUCIÓN).
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
    logs | jq -s -r '
      map(select(.event == "http_request"))
      | group_by([.service, .route, .status_code])
      | map([length, .[0].service, .[0].route, .[0].status_code])
      | sort_by(-.[0])[] | @tsv'
    ;;
  errores)
    logs | jq -s -r '
      map(select(.level | IN("warning", "error", "critical")))
      | group_by([.service, .level, .event])
      | map([length, .[0].service, .[0].level, .[0].event])
      | sort_by(-.[0])[] | @tsv'
    ;;
  lentas)
    logs | jq -s -r '
      map(select(.event == "http_request"))
      | sort_by(-.duration_ms)[:10][]
      | [.duration_ms, .service, .route, .status_code, .request_id] | @tsv'
    ;;
  p95)
    logs | jq -s -r '
      map(select(.event == "http_request"))
      | group_by([.service, .route])[]
      | (map(.duration_ms) | sort) as $d
      | [.[0].service, .[0].route, length, $d[(length * 0.95 | floor)]] | @tsv'
    ;;
  *)
    echo "consulta desconocida: $consulta" >&2
    exit 1
    ;;
esac
