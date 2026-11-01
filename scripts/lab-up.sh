#!/usr/bin/env bash
#
# lab-up.sh — levanta el laboratorio con el perfil que pide la semana.
#
#   ./scripts/lab-up.sh            la tienda (perfil core)
#   ./scripts/lab-up.sh metrics    tienda + métricas
#
#   TIENDA=<carpeta> construye la tienda desde esa carpeta en lugar de app/.
#   Desde la semana 02 apunta al proyecto de la semana, por ejemplo:
#   TIENDA=bootcamp/week-02-logs_estructurados/3-proyecto/starter ./scripts/lab-up.sh
#
# Perfiles, qué incluye cada uno y RAM: docs/perfiles-de-laboratorio.md
# Idempotente: si algo ya corre, lo deja como está (o lo recrea si cambió).

set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
perfil="${1:-core}"

case "$perfil" in
  core)     perfiles=() ;;
  metrics)  perfiles=(metrics) ;;
  logs)     perfiles=(metrics logs) ;;
  traces)   perfiles=(metrics logs traces) ;;
  profiles) perfiles=(metrics logs traces profiles) ;;
  scale)    perfiles=(metrics scale) ;;
  ai)       perfiles=(metrics logs traces ai) ;;
  *)
    echo "Perfil desconocido: $perfil" >&2
    echo "Perfiles: core, metrics, logs, traces, profiles, scale, ai" >&2
    exit 1
    ;;
esac

# compose.yaml construye los servicios desde ${TIENDA_SRC:-.} (relativo a app/).
if [[ -n "${TIENDA:-}" ]]; then
  TIENDA_SRC="$(cd "$TIENDA" && pwd)"
  export TIENDA_SRC
fi

args=()
for p in "${perfiles[@]}"; do args+=(--profile "$p"); done

# Prometheus lee el socket de Docker para descubrir sus targets: necesita el
# grupo dueño del socket tal como lo ve un contenedor (en Colima no es el del host).
if [[ " ${perfiles[*]} " == *" metrics "* ]]; then
  DOCKER_GID="$(docker run --rm --entrypoint stat -v /var/run/docker.sock:/s prom/prometheus:v3.15.1 -c %g /s)"
  export DOCKER_GID
fi

# --wait: no vuelve hasta que todos los healthchecks están en verde.
docker compose -f "$RAIZ/app/compose.yaml" "${args[@]}" up -d --build --wait
docker compose -f "$RAIZ/app/compose.yaml" "${args[@]}" ps --format 'table {{.Service}}\t{{.Status}}\t{{.Ports}}'
echo
echo "Laboratorio listo: perfil $perfil, tienda de ${TIENDA_SRC:-$RAIZ/app}"
