#!/usr/bin/env bash
# use.sh — USE (utilización, saturación, errores) del host y memoria de los
# contenedores de la tienda, preguntando a Prometheus por su API.
set -euo pipefail

q() {
  curl -s 127.0.0.1:9090/api/v1/query --data-urlencode "query=$1" \
    | jq -r '.data.result[] | "\(.metric | del(.__name__) | to_entries | map("\(.key)=\(.value)") | join(" "))\t\(.value[1])"'
}

echo "== Memoria disponible del host (bytes)"
q 'node_memory_MemAvailable_bytes'

echo "== CPUs del host"
q 'count(node_cpu_seconds_total{mode="idle"})'

echo "== Saturación: carga media de 1 minuto"
q 'node_load1'

echo "== Errores: paquetes recibidos con error, por interfaz"
q 'node_network_receive_errs_total'

echo "== Memoria de cada contenedor de la tienda (bytes)"
q 'sum by (container_label_com_docker_compose_service) (container_memory_working_set_bytes{container_label_com_docker_compose_project="tienda"})'
