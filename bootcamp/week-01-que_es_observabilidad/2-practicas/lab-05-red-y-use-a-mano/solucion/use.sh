#!/usr/bin/env bash
#
# use.sh — Utilization, Saturation y Errors de las dependencias de la tienda (SOLUCIÓN).

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
dc() { docker compose -f "$RAIZ/app/compose.yaml" "$@"; }
sql() { dc exec -T postgres psql -U tienda -d tienda -tA -F' ' -c "$1"; }

echo "PostgreSQL"
sql "SELECT count(*), current_setting('max_connections') FROM pg_stat_activity" \
  | awk '{ printf "  U: %d de %d conexiones (%.0f %%)\n", $1, $2, 100 * $1 / $2 }'
sql "SELECT count(*) FROM pg_stat_activity WHERE wait_event_type = 'Lock'" \
  | awk '{ printf "  S: %d sesiones esperando un lock\n", $1 }'
sql "SELECT xact_rollback, deadlocks FROM pg_stat_database WHERE datname = 'tienda'" \
  | awk '{ printf "  E: %d rollbacks y %d deadlocks desde el arranque\n", $1, $2 }'

echo "Valkey"
info=$(dc exec -T valkey valkey-cli INFO | tr -d '\r')
campo() { awk -F: -v k="$1" '$1 == k { print $2 }' <<<"$info"; }
echo "  U: $(campo used_memory_human) de memoria, $(campo connected_clients) clientes conectados"
echo "  S: $(campo blocked_clients) clientes bloqueados, $(campo evicted_keys) claves desalojadas"
echo "  E: $(campo rejected_connections) conexiones rechazadas"

echo "RabbitMQ (cola notificaciones.order-created)"
curl -sfu tienda:tienda "http://127.0.0.1:15672/api/queues/%2F/notificaciones.order-created" \
  | jq -r '"  U: \(.consumers) consumidor(es)",
           "  S: \(.messages_ready) mensajes esperando, \(.messages_unacknowledged) en proceso"'
curl -sf "http://127.0.0.1:18004/stats" | jq -r '"  E: \(.failed) mensajes descartados por notificaciones"' \
  || echo "  E: notificaciones no responde"
