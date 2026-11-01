# Lab 02 — Métricas RED con un histograma

⏱ Duración estimada: ~60 min

## Objetivo

Medir rate, errors y duration de cada endpoint de los servicios Python con un solo histograma y contar los pedidos y los cobros fallidos de `pedidos`.

## Contexto

- Un histograma cuenta cada observación en el bucket que le toca (`le`, *less or equal*) y mantiene además su suma (`_sum`) y su número (`_count`). De `_count` sale el rate; de `_count` filtrado por `status_code`, los errores; de los buckets, los percentiles.
- Cada combinación de valores de labels es una serie distinta, y un histograma multiplica: 14 buckets + `+Inf` + `_sum` + `_count` = 17 series por combinación. Los labels tienen que tener pocos valores posibles.
- El nombre sigue las convenciones de OpenTelemetry, `http_server_request_duration_seconds`, en segundos: así no cambia cuando en la semana 10 lo genere el SDK de OpenTelemetry.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada.

1. Copia `starter/metrics.py` sobre `$TIENDA/catalogo/app/metrics.py`. Ya trae el endpoint y la configuración del lab 01, y define dos métricas: el histograma `REQUEST_DURATION` con los labels `method`, `route` y `status_code`, y el gauge `ACTIVE_REQUESTS`.

2. Completa el TODO del paso 2 de `measure_requests` y regístralo en `main.py` después de `log_requests`:
   ```python
   from app.metrics import measure_requests, metrics
   ...
   app.middleware("http")(measure_requests)
   ```
   `ACTIVE_REQUESTS.track_inprogress()` es un gestor de contexto (`with`) que sube el gauge al entrar y lo baja al salir. Reconstruye y comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s '127.0.0.1:18001/products?limit=5' >/dev/null
   curl -s 127.0.0.1:18001/metrics | grep 'route="/products"'
   ```
   Lee los buckets de arriba abajo: cada uno incluye a los anteriores (son acumulados) y el de `le="+Inf"` es igual a `_count`.

3. Pide dos fichas distintas y mira qué series se crean:
   ```bash
   curl -s 127.0.0.1:18001/products/7 >/dev/null; curl -s 127.0.0.1:18001/products/8 >/dev/null
   curl -s 127.0.0.1:18001/metrics | grep '^http_server_request_duration_seconds_count'
   ```
   Tiene que haber una sola serie con `route="/products/{product_id}"`. Si ves `route="/products/7"`, estás usando la URL: con 500 productos serían 500 × 17 series para un solo endpoint. Completa el TODO del paso 3.

4. Prometheus pide `/metrics` cada 15 segundos y Docker pide `/health` cada 10: si los midieras, serían los endpoints con más tráfico de la tienda. Completa el TODO del paso 4 y comprueba que no aparecen:
   ```bash
   curl -s 127.0.0.1:18001/metrics | grep -c 'route="/\(health\|metrics\)"'
   ```

5. Lleva lo mismo a `pedidos` y a `pagos`: copia `metrics.py` a sus carpetas `app/`, registra el endpoint y el middleware en su `main.py` y haz que su `log_requests` ignore `/metrics` (lab 01, paso 4). Comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   for p in 18002 18003; do curl -s 127.0.0.1:$p/metrics | grep '^# TYPE http_server'; done
   ```

6. Añade a `pedidos` dos contadores de negocio, `orders_created_total` (sin labels) y `payment_failures_total` (label `reason`), y súmales uno donde se crea el pedido y donde falla el cobro. El motivo que devuelve `charge()` puede llevar el tipo de excepción (`pagos_unreachable: ConnectError`): quédate con lo que va antes de los dos puntos para que el label tenga pocos valores. Rompe `pagos` y comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s -X PUT 127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":1,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}'
   curl -s 127.0.0.1:18002/metrics | grep -E '^(orders_created|payment_failures)_total'
   curl -s -X PUT 127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.02,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}'
   ```
   Tras unos segundos de tráfico, `payment_failures_total{reason="pagos_status_503"}` tiene que ser mayor que 0.

7. Calcula a mano la duración media de `GET /products` desde el arranque: `_sum` / `_count`. Después mira en qué bucket se cruza la mitad de `_count`: ahí está la mediana. Es lo que `histogram_quantile` hará por ti en la semana 04.

## Criterios de éxito

- [ ] Los tres servicios Python exponen `http_server_request_duration_seconds` como `histogram`
- [ ] `route` vale la plantilla de la ruta (`/products/{product_id}`), nunca la URL
- [ ] Ni `/health` ni `/metrics` aparecen en el histograma
- [ ] `payment_failures_total` cuenta los cobros fallidos por motivo

## Reto extra

Añade un `Summary` con la misma duración y compara su salida con la del histograma. `prometheus-client` no calcula cuantiles en los summaries; aunque los calculara, ¿podrías sumar la mediana de dos réplicas de `catalogo` para obtener la mediana global? ¿Y con los buckets de un histograma?

---

[← Lab 01](../lab-01-primer-metrics/README.md) · [Lab 03 →](../lab-03-metricas-en-node/README.md)
