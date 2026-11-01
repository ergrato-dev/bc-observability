# Lab 04 — Native histograms y el estado de la TSDB

## Paso 1

- p90 de `/api/v1/query` con el histograma clásico: `histogram_quantile(0.9, sum by (le) (rate(prometheus_http_request_duration_seconds_bucket{handler="/api/v1/query"}[5m])))` = 0,09 s.

## Paso 3

- p90 con el native histogram: `histogram_quantile(0.9, sum(rate(prometheus_http_request_duration_seconds{handler="/api/v1/query"}[5m])))`, del orden de 0,002 s.
- Por qué difieren: el clásico solo sabe que todas tardan menos de 0,1 s y supone un reparto uniforme entre 0 y 0,1: el p90 sale en 0,09. El nativo tiene buckets de unos pocos microsegundos de ancho en esa zona, así que su estimación está muy cerca del valor real.

## Paso 4

- Fracción de consultas en menos de 1 ms: `histogram_fraction(0, 0.001, rate(prometheus_http_request_duration_seconds{handler="/api/v1/query"}[5m]))`, alrededor de 0,65 en el laboratorio.

## Paso 5

- Series en la head, métricas y labels: dependen de cada máquina. En la tienda, `http_server_request_duration_seconds_bucket` es la métrica con más series y `route` o `__name__` el label con más valores (`route` se dispara si queda rastro del lab 06 de la semana 03).

## Paso 6

- Series del histograma clásico frente al nativo: unas 70 series `_bucket` (10 buckets por cada handler con tráfico) frente a 7 series nativas, una por handler.

## Reto extra

Cada límite es el anterior multiplicado por 1,0905, que es 2^(1/8): el *schema* 3. Ocho buckets por cada duplicación del valor, así que el error relativo de cualquier percentil queda por debajo del 5 %, esté donde esté.
