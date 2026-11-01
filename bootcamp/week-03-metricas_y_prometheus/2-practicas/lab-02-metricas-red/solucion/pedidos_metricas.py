# Fragmentos de $TIENDA/pedidos/app/main.py (lab 02, paso 6).

from prometheus_client import Counter

ORDERS_CREATED = Counter("orders_created_total", "Pedidos cobrados y creados")
PAYMENT_FAILURES = Counter(
    "payment_failures_total",
    "Pedidos cuyo cobro falló, por motivo",
    ["reason"],
)

# En create_order, cuando el cobro falla:
#     # "pagos_unreachable: ConnectError" -> "pagos_unreachable": un label, pocos valores.
#     PAYMENT_FAILURES.labels(failure.split(":")[0]).inc()
#
# Y justo antes de log.info("order_created", ...):
#     ORDERS_CREATED.inc()
