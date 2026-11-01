#!/usr/bin/env bash
#
# lab-up.sh — levanta el laboratorio con el perfil que pide la semana.
#
#   ./scripts/lab-up.sh            la tienda (perfil core)
#   ./scripts/lab-up.sh metrics    tienda + métricas
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

args=()
for p in "${perfiles[@]}"; do args+=(--profile "$p"); done

# --wait: no vuelve hasta que todos los healthchecks están en verde.
docker compose -f "$RAIZ/app/compose.yaml" "${args[@]}" up -d --build --wait
docker compose -f "$RAIZ/app/compose.yaml" "${args[@]}" ps --format 'table {{.Service}}\t{{.Status}}\t{{.Ports}}'
echo
echo "Laboratorio listo: perfil $perfil"
