# Lab 04 — Percentiles

## Paso 1

- Bucket donde se cruza el 95 % de los cobros: entre `le="0.1"` (unas tres cuartas partes del total) y `le="0.25"` (todos).

## Paso 2

- p50 de `POST /orders`: `histogram_quantile(0.5, sum by (le) (rate(http_server_request_duration_seconds_bucket{job="pedidos", method="POST", route="/orders"}[5m])))`
- p95 de `POST /orders`: `histogram_quantile(0.95, sum by (le) (rate(http_server_request_duration_seconds_bucket{job="pedidos", method="POST", route="/orders"}[5m])))`
- p99 de `POST /orders`: `histogram_quantile(0.99, sum by (le) (rate(http_server_request_duration_seconds_bucket{job="pedidos", method="POST", route="/orders"}[5m])))`

## Paso 3

- p95 de cada llamada del checkout: `histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket{job=~"catalogo|pagos", route=~`/products/\{product_id\}(/reserve)?|/charges`}[5m])))`
- Paso que aporta más latencia: el cobro en `pagos`, con mucha diferencia; las dos llamadas a `catalogo` tardan unos pocos milisegundos.

## Paso 4

- p95 estimado con latencia fija de 600 ms, y por qué no sale 0,6: unos 0,74 s. Todas las observaciones caen en el bucket entre 0,5 y 0,75 s, e `histogram_quantile` las supone repartidas de forma uniforme dentro de él: el 95 % queda en 0,5 + 0,95 × 0,25.
- Buckets que añadirías: límites más finos donde están los valores normales y los umbrales que importan (0,15, 0,2, 0,3…) y alguno por encima de 10 s (15, 30) para distinguir los cobros colgados.

## Paso 6

- Las tres rutas más lentas: `topk(3, histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket[5m]))))`

## Reto extra

- Fracción de pedidos en menos de 1 s: `sum(rate(http_server_request_duration_seconds_bucket{job="pedidos", method="POST", route="/orders", le="1.0"}[5m])) / sum(rate(http_server_request_duration_seconds_count{job="pedidos", method="POST", route="/orders"}[5m]))`. Con 0,8 s no se puede calcular exactamente: no hay bucket con ese límite, y cualquier valor sería una interpolación.
