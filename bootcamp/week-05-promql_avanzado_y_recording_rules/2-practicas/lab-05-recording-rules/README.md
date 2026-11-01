# Lab 05 — Recording rules

⏱ Duración estimada: ~60 min

## Objetivo

Precalcular las consultas RED y de negocio de la tienda con recording rules que sigan la convención `level:metric:operations`, y medir cuánto ahorran.

## Contexto

- Una recording rule evalúa una consulta cada `evaluation_interval` y guarda el resultado como una serie nueva. Los dashboards y las alertas leen esa serie, que ya está agregada, en lugar de recalcular sobre los datos en crudo cada vez.
- El nombre dice qué contiene: `level:metric:operations`. *level*, los labels que quedan (`job`, `job_route`); *metric*, la métrica de origen sin `_total`; *operations*, lo que se le ha hecho (`rate5m`, `ratio_rate5m`). `job:http_server_requests:rate5m` se lee "peticiones por segundo, tasa de 5 min, por job".
- Las reglas de un grupo se evalúan en orden: una regla puede usar el resultado de otra anterior del mismo grupo.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Trabajas en tu copia: `$TIENDA/prometheus/rules/tienda.yml`.

1. Lo que cuesta sin reglas. Un panel de 1 h con el p95 de todas las rutas, un punto cada 15 s:
   ```bash
   now=$(date +%s)
   curl -s 127.0.0.1:9090/api/v1/query_range -d start=$((now-3600)) -d end=$now -d step=15 -d stats=all \
     --data-urlencode 'query=histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket[5m])))' \
     | jq '.data.stats.samples.totalQueryableSamples'
   ```
   Cientos de miles de muestras para dibujar ocho líneas. Y el panel se refresca cada 30 s, para cada persona que lo tenga abierto.

2. La primera regla. Añade a `prometheus.yml`, debajo de `global` (que también gana `evaluation_interval`):
   ```yaml
   global:
     scrape_interval: 15s
     evaluation_interval: 15s

   rule_files:
     - rules/*.yml
   ```
   En `rules/tienda.yml`, cambia el `expr: vector(0)` del starter por la tasa de peticiones por servicio (consulta 12 de la libreta de la semana 04). El nombre ya está puesto y sigue la convención.

3. Valida y recarga. `promtool check config` valida también las reglas de `rule_files`:
   ```bash
   docker run --rm -v "$PWD/$TIENDA/prometheus:/w" -w /w --entrypoint promtool prom/prometheus:v3.15.1 check config prometheus.yml
   curl -s -X POST 127.0.0.1:9090/-/reload
   curl -s 127.0.0.1:9090/api/v1/rules | jq '.data.groups[].rules[] | {name, health, lastError}'
   ./scripts/promql.sh 'job:http_server_requests:rate5m'
   ```
   `health: "ok"` y una serie por `job`. Si escribes mal la consulta, `promtool` lo dice antes de que Prometheus la cargue; si la consulta es válida pero falla al evaluarse, lo dice `lastError`.

4. Completa RED en el grupo `tienda_red`:
   - `job:http_server_requests_errors:rate5m`: peticiones 5xx por segundo, por `job`
   - `job:http_server_requests_errors:ratio_rate5m`: la anterior dividida entre `job:http_server_requests:rate5m`, sin repetir las consultas en crudo

   Comprueba que la regla da lo mismo que la consulta que sustituye:
   ```bash
   ./scripts/promql.sh 'job:http_server_requests:rate5m{job="catalogo"}'
   ./scripts/promql.sh 'sum by (job) (rate(http_server_request_duration_seconds_count{job="catalogo"}[5m]))'
   ```
   Casi igual, no idéntico: la regla se evaluó hasta 15 s antes.

5. Duration. Guarda la tasa de los buckets una vez y calcula el percentil sobre ella:
   - `job_route_le:http_server_request_duration_seconds_bucket:rate5m`: `sum by (job, route, le)` de la tasa de los buckets
   - `job_route:http_server_request_duration_seconds:p95_rate5m`: `histogram_quantile(0.95, …)` sobre la regla anterior

   Recarga y repite la medida del paso 1 con `query=job_route:http_server_request_duration_seconds:p95_rate5m`. Apunta las dos cifras. ¿Y si mañana alguien quiere el p99? Con la regla de los buckets ya guardada, es una consulta barata más.

6. Negocio, en un grupo nuevo `tienda_negocio`:
   - `job:orders_created:rate5m`: pedidos creados por segundo
   - `job_reason:payment_failures:rate5m`: cobros fallidos por segundo, por `job` y `reason`
   - `job:catalog_cache_hits:ratio_rate5m`: fracción de lecturas que sirve la caché

   Recarga y comprueba las tres en `/api/v1/rules` y con `promql.sh`. Si `job_reason:payment_failures:rate5m` sale vacía, provoca cobros fallidos (lab 01, paso 3): un counter con labels no existe hasta que se incrementa por primera vez.

## Criterios de éxito

- [ ] `curl -s 127.0.0.1:9090/api/v1/rules` muestra las 8 reglas con `health: "ok"`
- [ ] Todas las reglas siguen `level:metric:operations` y su *level* coincide con los labels del resultado
- [ ] Tienes las dos cifras de muestras del paso 5

## Reto extra

Una regla con un `by` equivocado no da error: guarda otra cosa con el nombre correcto. Cambia `sum by (job)` por `sum` en `job:http_server_requests:rate5m`, recarga y mira qué pasa con `job:http_server_requests_errors:ratio_rate5m`. Deshazlo. Detectar esto antes de desplegar es el trabajo del lab 06.

---

[← Lab 04](../lab-04-native-histograms-y-tsdb/README.md) · [Lab 06 →](../lab-06-tests-con-promtool/README.md)
