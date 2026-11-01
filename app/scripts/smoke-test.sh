#!/usr/bin/env bash
#
# smoke-test.sh — comprueba que la tienda funciona de punta a punta:
# salud de los servicios, un pedido pagado que llega a notificaciones y un
# pedido con el cobro fallido que devuelve 402.
#
# Uso (con el laboratorio levantado): ./app/scripts/smoke-test.sh

set -euo pipefail

CATALOGO="http://127.0.0.1:18001"
PEDIDOS="http://127.0.0.1:18002"
PAGOS="http://127.0.0.1:18003"
NOTIFICACIONES="http://127.0.0.1:18004"

ok()    { printf '  \033[0;32m✅\033[0m %s\n' "$*"; }
fallo() { printf '  \033[0;31m❌\033[0m %s\n' "$*"; exit 1; }

pedido() {
  curl -s -o /dev/null -w '%{http_code}' -X POST "$PEDIDOS/orders" \
    -H 'Content-Type: application/json' \
    -d '{"customer":{"email":"smoke@example.com","card_number":"4111111111111111"},"items":[{"product_id":1,"quantity":1}]}'
}

for url in "$CATALOGO" "$PEDIDOS" "$PAGOS" "$NOTIFICACIONES"; do
  curl -sf "$url/health" >/dev/null || fallo "$url/health no responde"
done
ok "Los cuatro servicios responden /health"

[[ "$(curl -sf "$CATALOGO/products?limit=5" | jq length)" == 5 ]] || fallo "catalogo no lista productos"
ok "catalogo lista productos"

# Averías bajo control durante la prueba; al salir se restauran las que había.
averias=$(curl -sf "$PAGOS/admin/faults")
trap 'curl -sf -X PUT "$PAGOS/admin/faults" -H "Content-Type: application/json" -d "$averias" >/dev/null' EXIT
sin_averias='{"error_rate":0,"latency_ms":10,"jitter_ms":0,"timeout_rate":0}'
curl -sf -X PUT "$PAGOS/admin/faults" -H 'Content-Type: application/json' -d "$sin_averias" >/dev/null

enviados=$(curl -sf "$NOTIFICACIONES/stats" | jq .sent)
[[ "$(pedido)" == 201 ]] || fallo "Un pedido sin averías no devuelve 201"
ok "Un pedido sin averías se cobra (201)"

for _ in $(seq 20); do
  (( $(curl -sf "$NOTIFICACIONES/stats" | jq .sent) > enviados )) && break
  sleep 0.5
done
(( $(curl -sf "$NOTIFICACIONES/stats" | jq .sent) > enviados )) || fallo "notificaciones no recibió el evento"
ok "notificaciones recibe el evento del pedido"

curl -sf -X PUT "$PAGOS/admin/faults" -H 'Content-Type: application/json' \
  -d '{"error_rate":1,"latency_ms":10,"jitter_ms":0,"timeout_rate":0}' >/dev/null
[[ "$(pedido)" == 402 ]] || fallo "Con pagos caído, el pedido no devuelve 402"
ok "Con pagos caído, el pedido devuelve 402"

echo
echo "Smoke test superado."
