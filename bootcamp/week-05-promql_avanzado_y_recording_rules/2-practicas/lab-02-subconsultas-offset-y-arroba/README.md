# Lab 02 — Subconsultas, offset y @

⏱ Duración estimada: ~60 min

## Objetivo

Mover una consulta en el tiempo con `offset` y `@`, y aplicar funciones `_over_time` al resultado de otra consulta con subconsultas.

## Contexto

- `offset 1h` evalúa un selector una hora antes del instante de la consulta: sirve para comparar ahora con antes. `@ <timestamp>` lo fija en un instante absoluto, haga la gráfica lo que haga.
- Las funciones `_over_time` (`max_over_time`, `avg_over_time`, `quantile_over_time`…) reciben un range vector. Si lo que quieres resumir es el resultado de una consulta (una tasa, una suma), una **subconsulta** `expr[30m:1m]` evalúa `expr` cada minuto durante 30 minutos y te da ese rango.
- Las subconsultas son caras: evalúan la consulta interior muchas veces. Si una se repite, se convierte en recording rule (lab 05).

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md`.

1. El pico de pedidos por segundo de la última media hora. `max_over_time` necesita un range vector, y `sum(rate(...))` es un instant vector:
   ```bash
   ./scripts/promql.sh 'max_over_time(sum(rate(orders_created_total[1m]))[30m:])'
   ./scripts/promql.sh 'max_over_time(sum(rate(orders_created_total[1m]))[30m:1m])'
   ```
   Sin paso explícito (`[30m:]`), la subconsulta usa el `evaluation_interval` global. Apunta el pico y el mínimo (`min_over_time`) de la media hora.

2. Recuerda el reto del lab 05 de la semana 04: un panel de 30 días pinta un punto cada pocas horas y pierde los picos. Escribe el pico de la tasa de 5xx de `pagos` en cada hora, con un paso de 1 minuto:
   ```
   max_over_time(sum(rate(http_server_request_duration_seconds_count{job="pagos", status_code=~"5.."}[5m]))[1h:1m])
   ```

3. Compara ahora con hace 30 minutos:
   ```bash
   ./scripts/promql.sh 'sum(rate(orders_created_total[5m])) / sum(rate(orders_created_total[5m] offset 30m))'
   ```
   Cerca de 1: la tienda va al mismo ritmo. `offset` va dentro del selector, pegado al rango, no al final de la consulta. Escribe la diferencia del p95 del checkout entre ahora y hace 30 minutos.

4. Fija una consulta en un instante con `@`. Toma el timestamp de hace 20 minutos y evalúa la misma consulta de dos formas:
   ```bash
   t=$(( $(date +%s) - 1200 ))
   ./scripts/promql.sh "sum(rate(orders_created_total[5m] @ $t))"
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=sum(rate(orders_created_total[5m]))' -d time=$t | jq -r '.data.result[0].value[1]'
   ```
   Mismo valor: `@` mueve el selector, el parámetro `time` mueve la consulta entera. La diferencia se ve en una gráfica: con `@`, todos los puntos valen lo mismo.

5. `@ end()` en una gráfica. En *Graph*, con un rango de 1 h, dibuja las tres rutas más lentas en el percentil 95:
   ```
   topk(3, histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket[5m]))))
   ```
   La leyenda muestra más de tres rutas: `topk` se evalúa en cada punto y el top cambia. Ahora fija el ranking al final del rango:
   ```
   histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket[5m])))
     and topk(3, histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket[5m] @ end()))))
   ```
   Tres líneas en todo el rango: las tres que eran las más lentas al final.

6. Mide cuánto cuesta una subconsulta. La API devuelve estadísticas con `stats=all`:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query -d stats=all \
     --data-urlencode 'query=max_over_time(sum(rate(http_server_request_duration_seconds_count[5m]))[1h:15s])' \
     | jq '.data.stats.samples'
   ```
   `samplesRead` son las muestras leídas del almacenamiento; `peakSamples`, las que llegó a tener en memoria a la vez. Repite con `[1h:1m]` y con `[1h:5m]`. Las leídas apenas cambian; el pico de memoria baja con el paso, porque la subconsulta guarda un resultado intermedio por cada paso (con 15 s, 240 evaluaciones de la consulta interior).

## Criterios de éxito

- [ ] Las consultas de los pasos 1, 2 y 3 devuelven un valor y sabes qué rango mira cada una
- [ ] Sabes explicar la diferencia entre `offset`, `@` y el parámetro `time`
- [ ] Tienes las cifras del paso 6 y sabes por qué `peakSamples` baja al alargar el paso

## Reto extra

`predict_linear` y `deriv` también aceptan subconsultas. ¿Cuál es la tendencia de los pedidos por segundo en la última hora? `deriv(sum(rate(orders_created_total[5m]))[1h:1m])`. Un valor positivo pequeño, ¿es crecimiento real o ruido? Compáralo con el valor de la tasa.

---

[← Lab 01](../lab-01-vector-matching/README.md) · [Lab 03 →](../lab-03-absent-y-predict-linear/README.md)
