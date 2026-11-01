#!/usr/bin/env bash
# explotar.sh — pide N fichas de producto distintas a catalogo, 20 en paralelo.
# Los id que no existen devuelven 404: también cuentan.
#   ./explotar.sh [N]     (por defecto 3000)
set -euo pipefail

n="${1:-3000}"
seq 1 "$n" | xargs -P 20 -I{} curl -s -o /dev/null http://127.0.0.1:18001/products/{}
echo "Pedidas $n URL distintas a catalogo."
