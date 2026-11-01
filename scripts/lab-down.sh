#!/usr/bin/env bash
#
# lab-down.sh — para el laboratorio, todos los perfiles.
#   ./scripts/lab-down.sh            para y borra los contenedores, conserva los datos
#   ./scripts/lab-down.sh --limpiar  borra también los volúmenes (pedidos, colas, métricas...)

set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

args=(down --remove-orphans)
if [[ "${1:-}" == "--limpiar" ]]; then
  args+=(--volumes)
fi

docker compose -f "$RAIZ/app/compose.yaml" --profile '*' "${args[@]}"
