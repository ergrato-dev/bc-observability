# Lab 05 — Errores frecuentes

## Paso 1 — rate sobre un gauge

- Falso: `rate(node_memory_MemAvailable_bytes[5m])` da cientos de millones de bytes por segundo.
- Correcto: `deriv(node_memory_MemAvailable_bytes[5m])` (pendiente por segundo) o `delta(node_memory_MemAvailable_bytes[5m])` (cambio en la ventana).
- Por qué: `rate` supone que la serie solo sube; cada bajada la interpreta como un reinicio y suma el valor completo.

## Paso 2 — rate después de sum

- Falso: `rate(sum(process_cpu_seconds_total{job=~"catalogo|pedidos|pagos|notificaciones"})[1h:])`.
- Correcto: `sum(rate(process_cpu_seconds_total{job=~"catalogo|pedidos|pagos|notificaciones"}[1h]))`.
- Por qué: `rate` detecta los reinicios serie a serie. Si suma antes, el reinicio de un servicio se ve como una bajada de la suma y se trata como el reinicio de todas.

## Paso 3 — la media de los percentiles

- Falso: `avg(histogram_quantile(0.95, sum by (job, le) (rate(http_server_request_duration_seconds_bucket{job=~"catalogo|pagos"}[5m]))))`.
- Correcto: `histogram_quantile(0.95, sum by (le) (rate(http_server_request_duration_seconds_bucket{job=~"catalogo|pagos"}[5m])))`.
- Por qué: la media trata igual a un servicio con 3 peticiones por segundo y a otro con 0,5. Los buckets son contadores y se suman; los percentiles, no.

## Paso 4 — histogram_quantile sin le

- Falso: `histogram_quantile(0.95, sum by (job) (rate(http_server_request_duration_seconds_bucket[5m])))` no devuelve nada.
- Correcto: `histogram_quantile(0.95, sum by (job, le) (rate(http_server_request_duration_seconds_bucket[5m])))`.
- Por qué: al agregar sin `le` se suman todos los buckets en uno y desaparece el histograma.

## Paso 5 — un filtro que se come las series

- Filtro: `... > 0` devuelve solo los servicios con errores.
- Con `bool`: `... > bool 0` devuelve 1 o 0 para cada servicio que tenga la serie.
- Por qué: las comparaciones sin `bool` filtran; con `bool` devuelven el resultado de la comparación. Ninguna de las dos crea series que no existen.

## Reto extra

`max_over_time` sobre una subconsulta: `max_over_time(rate(x[5m])[1h:5m])` conserva el pico de cada hora aunque el panel solo pinte un punto por hora.
