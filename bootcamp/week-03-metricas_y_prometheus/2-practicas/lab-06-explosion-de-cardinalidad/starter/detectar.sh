#!/usr/bin/env bash
# detectar.sh — ¿quién está llenando Prometheus de series?
set -euo pipefail

P=http://127.0.0.1:9090

q() {
  curl -s "$P/api/v1/query" --data-urlencode "query=$1" \
    | jq -r '.data.result[] | "\(.metric | to_entries | map("\(.key)=\(.value)") | join(" "))\t\(.value[1])"'
}

echo "== Series en memoria (head)"
q 'prometheus_tsdb_head_series'

echo "== Muestras por scrape, por job"
# TODO paso 4: scrape_samples_scraped, ordenado de mayor a menor.

echo "== Métricas con más series"
# TODO paso 4: seriesCountByMetricName de $P/api/v1/status/tsdb.

echo "== Labels con más valores distintos"
# TODO paso 4: labelValueCountByLabelName de la misma API.
