# Lab 04 — Native histograms y el estado de la TSDB

⏱ Duración estimada: ~60 min

## Objetivo

Ingerir native histograms, comparar su precisión y su coste con los clásicos, y medir la cardinalidad de Prometheus con su API de estado.

## Contexto

- Un histograma clásico es una serie por bucket, con límites fijos que eliges al instrumentar. Un **native histogram** es una sola serie cuyas muestras contienen todos los buckets, con límites exponenciales que el cliente ajusta solo: más precisión y menos series.
- Desde Prometheus 3.9 se activan por scrape con `scrape_native_histograms: true` y necesitan el formato protobuf. Los clientes que usa la tienda siguen exponiendo histogramas clásicos; el propio Prometheus ya expone los suyos de las dos formas, así que lo usas a él para comparar.
- La API `/api/v1/status/tsdb` dice qué métricas y qué labels tienen más series. Es lo primero que se mira cuando Prometheus empieza a gastar memoria.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md`.

1. El histograma clásico de la duración de las peticiones HTTP del propio Prometheus:
   ```bash
   ./scripts/promql.sh 'sum by (le) (prometheus_http_request_duration_seconds_bucket{handler="/api/v1/query"})'
   ```
   El bucket más pequeño es 0,1 s, y casi todas las consultas tardan unos pocos milisegundos: caen todas en el primero. Calcula su p90 con `histogram_quantile` y apunta el resultado.

2. Activa los native histograms en tu `prometheus/prometheus.yml`, en el job `docker`:
   ```yaml
       sample_limit: 10000
       # Ingiere native histograms de los targets que los exponen (el propio
       # Prometheus) y conserva también sus buckets clásicos.
       scrape_native_histograms: true
       always_scrape_classic_histograms: true
   ```
   Sin `always_scrape_classic_histograms`, un target que expone las dos formas solo guarda la nativa, y los paneles que usan `_bucket` se quedan vacíos. Valida y recarga:
   ```bash
   docker run --rm -v "$PWD/$TIENDA/prometheus:/w" -w /w --entrypoint promtool prom/prometheus:v3.15.1 check config prometheus.yml
   curl -s -X POST 127.0.0.1:9090/-/reload
   ```

3. Tras un par de scrapes, la serie nativa existe con el nombre de la métrica, sin sufijo:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=prometheus_http_request_duration_seconds{handler="/api/v1/query"}' \
     | jq '.data.result[0].histogram[1] | {count, sum, buckets: (.buckets | length)}'
   ```
   Un solo valor con decenas de buckets dentro. Pídele el p90 sin `le` y sin `_bucket`:
   ```bash
   ./scripts/promql.sh 'histogram_quantile(0.9, sum(rate(prometheus_http_request_duration_seconds{handler="/api/v1/query"}[5m])))'
   ```
   Compara con el paso 1: el clásico dice 0,09 s porque interpola dentro de su primer bucket (de 0 a 0,1 s); el nativo da unos pocos milisegundos, el valor real.

4. Las funciones que solo existen para native histograms:
   ```bash
   ./scripts/promql.sh 'histogram_count(rate(prometheus_http_request_duration_seconds{handler="/api/v1/query"}[5m]))'
   ./scripts/promql.sh 'histogram_avg(rate(prometheus_http_request_duration_seconds{handler="/api/v1/query"}[5m]))'
   ./scripts/promql.sh 'histogram_fraction(0, 0.001, rate(prometheus_http_request_duration_seconds{handler="/api/v1/query"}[5m]))'
   ```
   La última es la fracción de consultas que tardan menos de 1 ms. Con el clásico solo podrías preguntarlo para los límites que existen (0,1, 0,2…).

5. El estado de la TSDB:
   ```bash
   curl -s '127.0.0.1:9090/api/v1/status/tsdb?limit=5' | jq '.data.headStats.numSeries, .data.seriesCountByMetricName, .data.labelValueCountByLabelName'
   ```
   Apunta el total de series, las cinco métricas con más series y los labels con más valores. Si el lab 06 de la semana 03 dejó rastro, `route` tendrá miles de valores: siguen en la *head* hasta que se compacta (unas 2 h).

6. Cuenta cuántas series ocupa cada forma del mismo histograma:
   ```bash
   ./scripts/promql.sh 'count({__name__=~"prometheus_http_request_duration_seconds_bucket"})'
   ./scripts/promql.sh 'count(prometheus_http_request_duration_seconds)'
   ```
   El clásico multiplica por el número de buckets (más `_sum` y `_count`); el nativo es una serie por combinación de labels. En la semana 13 volverás a esta cuenta para recortar el coste de la tienda.

## Criterios de éxito

- [ ] `count(prometheus_http_request_duration_seconds{job="prometheus"})` devuelve más de 0
- [ ] Tienes el p90 clásico y el nativo del paso 3 y sabes por qué difieren
- [ ] Sabes qué métrica y qué label tienen más series en tu Prometheus

## Reto extra

Los native histograms tienen un factor de crecimiento (`schema`): cuanto más alto, más buckets y más precisión. Lee el campo `buckets` de la respuesta del paso 3: cada bucket es `[tipo de límite, inferior, superior, cuenta]`. ¿Cuánto crece cada límite respecto al anterior?

---

[← Lab 03](../lab-03-absent-y-predict-linear/README.md) · [Lab 05 →](../lab-05-recording-rules/README.md)
