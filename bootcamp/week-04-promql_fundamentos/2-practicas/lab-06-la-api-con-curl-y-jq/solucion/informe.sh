#!/usr/bin/env bash
#
# informe.sh — evalúa cada consulta de la libreta contra Prometheus.
#
#   ./informe.sh <carpeta-de-la-libreta>

set -euo pipefail

PROMETHEUS="${PROMETHEUS:-http://127.0.0.1:9090}"
libreta="${1:?uso: ./informe.sh <carpeta-de-la-libreta>}"
fallos=0

for archivo in "$libreta"/*.promql; do
  pregunta=$(head -1 "$archivo" | sed 's/^# //')
  echo "== $(basename "$archivo" .promql): $pregunta"

  respuesta=$(curl -s "$PROMETHEUS/api/v1/query" --data-urlencode "query@$archivo")

  if [[ "$(jq -r .status <<<"$respuesta")" != "success" ]]; then
    echo "   ERROR: $(jq -r '.error // "sin respuesta de Prometheus"' <<<"$respuesta")"
    fallos=$((fallos + 1))
    continue
  fi

  if [[ "$(jq '.data.result | length' <<<"$respuesta")" -eq 0 ]]; then
    echo "   (vacío)"
    fallos=$((fallos + 1))
    continue
  fi

  jq -r '
    .data.result[]
    | (.metric | del(.__name__) | to_entries | map("\(.key)=\(.value)") | join(" ")) as $labels
    | (.value[1] | tonumber? // . | if type == "number" then (. * 10000 | round / 10000) else . end) as $valor
    | "   \(if $labels == "" then "{}" else $labels end) \($valor)"
  ' <<<"$respuesta"
done

echo
echo "$fallos consultas con error o vacías."
[[ $fallos -eq 0 ]]
