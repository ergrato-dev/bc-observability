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
# TODO paso 2: cuenta las CPU (node_cpu_seconds_total tiene una serie por CPU y modo).

echo "== Saturación: carga media de 1 minuto"
# TODO paso 3: node_load1. Compárala con el número de CPU.

echo "== Errores: paquetes recibidos con error, por interfaz"
# TODO paso 3: node_network_receive_errs_total.

echo "== Memoria de cada contenedor de la tienda (bytes)"
# TODO paso 4: container_memory_working_set_bytes, sumada por servicio de Compose.
