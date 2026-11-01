# Lab 01 — Primer /metrics

⏱ Duración estimada: ~60 min

## Objetivo

Exponer en `catalogo` un endpoint `/metrics` que Prometheus pueda leer y añadir el primer contador de negocio: los aciertos y fallos de la caché.

## Contexto

- Una métrica de Prometheus es un número con nombre y labels que el propio servicio mantiene en memoria. Prometheus lo lee cada 15 segundos de `/metrics`, en texto plano.
- `prometheus-client` ya está en el lockfile de tu copia de la tienda. Además de lo que tú definas, expone por defecto métricas del proceso (`process_*`) y de Python (`python_*`).
- Un contador solo sube. Si el proceso se reinicia, vuelve a cero: Prometheus lo sabe y lo tiene en cuenta al calcular tasas (semana 04).

## Instrucciones

Desde la raíz del repositorio.

1. Levanta el perfil `metrics` con tu copia de la tienda y lee el formato de exposición en las métricas del propio Prometheus:
   ```bash
   export TIENDA=bootcamp/week-03-metricas_y_prometheus/3-proyecto/starter
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:9090/metrics | grep -A4 '^# HELP prometheus_http_requests_total'
   ```
   Cada métrica trae una línea `# HELP` (qué mide), una `# TYPE` (de qué tipo es) y una línea por serie: nombre, labels entre llaves y valor. Apunta qué labels distinguen las series de `prometheus_http_requests_total`.

2. Copia `starter/metrics.py` a `$TIENDA/catalogo/app/metrics.py` y completa el TODO del paso 2.

3. Registra el endpoint en `$TIENDA/catalogo/app/main.py`, justo después de los middlewares:
   ```python
   from app.metrics import metrics
   ...
   app.get("/metrics", include_in_schema=False)(metrics)
   ```
   Reconstruye y comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:18001/metrics | grep '^# TYPE'
   ```
   Salida esperada: unas 10 métricas `process_*` y `python_*`. ¿De qué tipo es `process_cpu_seconds_total`? ¿Y `process_resident_memory_bytes`? Fíjate en el sufijo y en la unidad de cada nombre.

4. Prometheus va a pedir `/metrics` cada 15 segundos: con el middleware de logs de la semana 02, cada petición sería una línea `http_request` que no le interesa a nadie. En `$TIENDA/catalogo/app/logging_config.py`, haz que `log_requests` ignore `/metrics` igual que ignora `/health`:
   ```python
   if request.url.path in ("/health", "/metrics"):
   ```

5. Añade a `main.py` un contador con el resultado de cada consulta a la caché de productos:
   ```python
   from prometheus_client import Counter

   CACHE_REQUESTS = Counter(
       "catalog_cache_requests_total",
       "Consultas a la caché de productos, por resultado",
       ["result"],
   )
   ```
   En `get_product`, súmale uno con `CACHE_REQUESTS.labels("hit").inc()` cuando la ficha sale de Valkey y con `labels("miss")` cuando no. Completa también el TODO del paso 5 de `metrics.py`. Reconstruye y comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:18001/products/3 >/dev/null; curl -s 127.0.0.1:18001/products/3 >/dev/null
   curl -s 127.0.0.1:18001/metrics | grep '^catalog_cache'
   ```
   Tienen que salir dos series, `result="hit"` y `result="miss"`, y ninguna `catalog_cache_requests_created`.

6. Reinicia `catalogo` y vuelve a mirar el contador:
   ```bash
   docker compose -f app/compose.yaml restart catalogo
   curl -s 127.0.0.1:18001/metrics | grep '^catalog_cache'
   ```
   Ha vuelto a empezar. Por eso nunca se consulta el valor de un contador sino cuánto sube por segundo.

## Criterios de éxito

- [ ] `curl -s 127.0.0.1:18001/metrics` devuelve métricas en formato de exposición con `# HELP` y `# TYPE`
- [ ] `catalog_cache_requests_total` tiene una serie por resultado (`hit` y `miss`) y no hay series `_created`
- [ ] Las peticiones a `/metrics` no aparecen en los logs: `docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -r 'select(.path == "/metrics")' | wc -l` da 0

## Reto extra

¿Qué pasaría si usaras `product_id` como label de `catalog_cache_requests_total` para saber qué productos fallan más en caché? Calcula cuántas series tendría el contador con los 500 productos de la tienda y piensa qué señal de la semana 02 responde mejor esa pregunta.

---

[← Prácticas](../README.md) · [Lab 02 →](../lab-02-metricas-red/README.md)
