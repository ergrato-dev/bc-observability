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
q 'sort_desc(sum by (job) (scrape_samples_scraped))'

echo "== Métricas con más series"
curl -s "$P/api/v1/status/tsdb" | jq -r '.data.seriesCountByMetricName[:5][] | "\(.name)\t\(.value)"'

echo "== Labels con más valores distintos"
curl -s "$P/api/v1/status/tsdb" | jq -r '.data.labelValueCountByLabelName[:5][] | "\(.name)\t\(.value)"'
