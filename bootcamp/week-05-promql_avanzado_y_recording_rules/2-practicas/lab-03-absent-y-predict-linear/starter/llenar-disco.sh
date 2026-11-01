#!/usr/bin/env bash
#
# llenar-disco.sh — escribe 1,5 GB en un volumen de Docker a razón de 50 MB
# cada 10 s (unos 5 minutos), para que node_exporter vea cómo baja el espacio libre.
#
#   ./llenar-disco.sh            empieza a llenar (en segundo plano)
#   ./llenar-disco.sh --vaciar   para y borra el volumen
#
# El volumen vive en el disco de Docker: en Linux y WSL2, normalmente el
# mismo que /; en Docker Desktop, el disco de su máquina virtual.

set -euo pipefail

IMAGEN=prom/prometheus:v3.15.1   # ya descargada: trae sh y dd

if [[ "${1:-}" == "--vaciar" ]]; then
  docker rm -f tienda-relleno >/dev/null 2>&1 || true
  docker volume rm tienda-relleno >/dev/null 2>&1 || true
  echo "Volumen tienda-relleno borrado."
  exit 0
fi

docker run -d --rm --name tienda-relleno -u 0 -v tienda-relleno:/relleno \
  --entrypoint sh "$IMAGEN" \
  -c 'for i in $(seq 30); do dd if=/dev/zero of=/relleno/f$i bs=1M count=50 2>/dev/null; sync; sleep 10; done' >/dev/null

docker volume inspect tienda-relleno -f 'Llenando {{.Mountpoint}} (1,5 GB en ~5 min). Vacíalo con: ./llenar-disco.sh --vaciar'
