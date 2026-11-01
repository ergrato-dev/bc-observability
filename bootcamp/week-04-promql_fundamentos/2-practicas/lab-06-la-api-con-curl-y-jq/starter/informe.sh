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
  # La pregunta es la primera línea del archivo, sin el "# " inicial.
  pregunta=$(head -1 "$archivo" | sed 's/^# //')
  echo "== $(basename "$archivo" .promql): $pregunta"

  # TODO: evalúa el archivo con /api/v1/query y --data-urlencode "query@...".
  respuesta='{}'

  # TODO: si status no es "success", imprime "   ERROR: <error>", suma un fallo y pasa al siguiente.

  # TODO: si data.result está vacío, imprime "   (vacío)", suma un fallo y pasa al siguiente.

  # TODO: imprime una línea por serie: "   <labels sin __name__> <valor con 4 decimales>".
  echo "$respuesta" >/dev/null
done

echo
echo "$fallos consultas con error o vacías."
[[ $fallos -eq 0 ]]
