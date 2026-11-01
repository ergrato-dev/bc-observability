# Lab 01 — Selectores y vectores

## Paso 2

- `up` solo de `pagos`: `up{job="pagos"}`
- `up` de todos los targets menos los exporters: `up{job!~"node-exporter|cadvisor"}`
- `up` de `catalogo` y `pedidos` con una expresión regular: `up{job=~"catalogo|pedidos"}`

## Paso 3

- Rutas de un producto concreto en `catalogo`: `http_server_request_duration_seconds_count{job="catalogo", route=~"/products/.+"}`
- Por qué `route=~"/products/"` no devuelve nada: las expresiones regulares de PromQL están ancladas al principio y al final, así que solo casan con el valor `/products/` exacto, que no existe.

## Paso 4

- Las cuatro métricas de negocio de la tienda: `{__name__=~"catalog_cache_requests_total|orders_created_total|payment_failures_total|notifications_total"}`

## Paso 5

- Muestras en `[5m]` con `scrape_interval` de 15 s, y por qué: unas 20 (300 s / 15 s). Pueden salir 19 o 21 según dónde caiga el borde de la ventana respecto a los scrapes.

## Reto extra

`up == 0`. Con `pause`, el contenedor sigue existiendo: Docker lo sigue listando, Prometheus lo sigue scrapeando y el scrape falla por timeout, así que `up` vale 0. Con `stop`, el contenedor deja de estar en marcha, el service discovery lo quita de los targets y la serie desaparece.
