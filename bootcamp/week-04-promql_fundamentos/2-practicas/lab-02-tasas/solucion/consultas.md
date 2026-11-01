# Lab 02 — Tasas

## Paso 2

- Por qué `rate(x[20s])` puede salir vacío: `rate` necesita al menos dos muestras en la ventana, y con un scrape cada 15 s una ventana de 20 s a veces solo contiene una.
- Ventana mínima con `scrape_interval` de 15 s: 1m (cuatro veces el intervalo), para tener margen si falla algún scrape.

## Paso 3

- Pedidos por segundo que entran, un solo número: `sum(rate(http_server_request_duration_seconds_count{job="pedidos", method="POST", route="/orders"}[5m]))`
- Por qué es mayor que `rate(orders_created_total[5m])`: el histograma cuenta todas las peticiones, también las que acaban en 402 (cobro fallido), 404 o 409; `orders_created_total` solo cuenta los pedidos cobrados.

## Paso 5

- Pedidos creados en la última hora, un solo número: `sum(increase(orders_created_total[1h]))`
- Cobros fallidos en la última hora, una serie por `reason`: `sum by (reason) (increase(payment_failures_total[1h]))`

## Paso 6

- Reinicios de cada servicio en la última hora, una serie por `job`: `sum by (job) (resets(process_cpu_seconds_total{job=~"catalogo|pedidos|pagos|notificaciones"}[1h]))`

## Reto extra

La resta con `offset` usa los valores en crudo: si `pedidos` se reinició dentro de la hora, el contador actual es menor que el de hace una hora y la resta sale negativa o demasiado pequeña. `increase` y `rate` detectan el reinicio y lo compensan.
