#!/usr/bin/env bash
#
# promql.sh — evalúa una consulta PromQL contra el Prometheus del laboratorio.
#
#   ./scripts/promql.sh 'sum by (job) (up)'
#   ./scripts/promql.sh libreta/01-pedidos-por-segundo.promql   (admite comentarios #)
#
# Imprime una línea por serie: sus labels (sin __name__) y su valor, con 4 decimales.
#   job="pagos" 0.0123
#   {} 0.4975                      <- serie sin labels
# Sale con 1 si la consulta da error o no devuelve nada.

set -euo pipefail

PROMETHEUS="${PROMETHEUS:-http://127.0.0.1:9090}"

if [[ $# -ne 1 ]]; then
  sed -n '3,12p' "${BASH_SOURCE[0]}" | sed 's|^# \?||' >&2
  exit 2
fi

if [[ -f "$1" ]]; then
  respuesta=$(curl -s "$PROMETHEUS/api/v1/query" --data-urlencode "query@$1")
else
  respuesta=$(curl -s "$PROMETHEUS/api/v1/query" --data-urlencode "query=$1")
fi

if [[ "$(jq -r '.status' <<<"$respuesta")" != "success" ]]; then
  echo "ERROR: $(jq -r '.error // "sin respuesta de Prometheus"' <<<"$respuesta")" >&2
  exit 1
fi

if ! salida=$(jq -er '
  .data as $d
  | if $d.resultType == "matrix" then error("devuelve un range vector; aplícale una función (rate, increase...) o léelo con curl")
    elif $d.resultType == "scalar" then [{metric: {}, value: $d.result}] else $d.result end
  | if length == 0 then error("la consulta no devuelve ninguna serie") else .[] end
  | (.metric | del(.__name__) | to_entries | sort_by(.key)
      | if length == 0 then "{}" else map("\(.key)=\"\(.value)\"") | join(",") end)
    + " "
    + (.value[1] | if test("^[-+]?[0-9.e+-]+$") then (tonumber * 10000 | round / 10000 | tostring) else . end)
' <<<"$respuesta" 2>&1); then
  echo "ERROR: ${salida##*: }" >&2
  exit 1
fi
echo "$salida"
