#!/usr/bin/env bash
#
# use.sh — Utilization, Saturation y Errors de las dependencias de la tienda.

set -euo pipefail

RAIZ="$(git rev-parse --show-toplevel)"
dc() { docker compose -f "$RAIZ/app/compose.yaml" "$@"; }
sql() { dc exec -T postgres psql -U tienda -d tienda -tA -F' ' -c "$1"; }

echo "PostgreSQL"
sql "SELECT count(*), current_setting('max_connections') FROM pg_stat_activity" \
  | awk '{ printf "  U: %d de %d conexiones (%.0f %%)\n", $1, $2, 100 * $1 / $2 }'
# TODO (paso 5): S = sesiones esperando un lock (pg_stat_activity.wait_event_type)
# TODO (paso 5): E = rollbacks y deadlocks de la base tienda (pg_stat_database)

echo "Valkey"
# TODO (paso 6): U, S y E a partir de "valkey-cli INFO" (ojo: termina las líneas en \r)

echo "RabbitMQ (cola notificaciones.order-created)"
# TODO (paso 6): U y S desde la API de gestión (http://127.0.0.1:15672/api/queues/...)
# TODO (paso 6): E desde GET http://127.0.0.1:18004/stats
