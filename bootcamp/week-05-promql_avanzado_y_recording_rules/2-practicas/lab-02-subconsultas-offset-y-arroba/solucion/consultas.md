# Lab 02 — Subconsultas, offset y @

## Paso 1

- Pico de pedidos por segundo en la última media hora: `max_over_time(sum(rate(orders_created_total[1m]))[30m:1m])`
- Mínimo: `min_over_time(sum(rate(orders_created_total[1m]))[30m:1m])`

## Paso 3

- Diferencia del p95 del checkout entre ahora y hace 30 minutos: `histogram_quantile(0.95, sum by (le) (rate(http_server_request_duration_seconds_bucket{job="pedidos", route="/orders"}[5m]))) - histogram_quantile(0.95, sum by (le) (rate(http_server_request_duration_seconds_bucket{job="pedidos", route="/orders"}[5m] offset 30m)))`

## Paso 4

- Diferencia entre `@`, `offset` y el parámetro `time`: `offset` desplaza un selector hacia atrás respecto al instante de evaluación; `@` lo clava en un instante absoluto, sea cual sea el instante de evaluación; `time` cambia el instante de evaluación de toda la consulta. En una gráfica, `offset` dibuja la curva desplazada, `@` una línea plana y `time` no existe (lo fijan `start`, `end` y `step`).

## Paso 6

- `peakSamples` con pasos de 15s, 1m y 5m: del orden de 1950, 490 y 115 en la tienda del laboratorio (cambia con el número de series).
- Por qué cambia: la subconsulta evalúa la consulta interior una vez por paso y guarda cada resultado; con un paso cuatro veces más corto hay cuatro veces más resultados intermedios en memoria. Las muestras leídas del almacenamiento son casi las mismas, porque las ventanas de 5 minutos se solapan.

## Reto extra

`deriv(sum(rate(orders_created_total[5m]))[1h:1m])` sale del orden de 0,0001 o menos, en pedidos/s por segundo. Multiplicado por 3600 da el cambio por hora, y hay que leerlo contra la tasa (unos 0,5 pedidos/s). k6 genera un tráfico constante, así que la tendencia real es 0: lo que se ve es ruido, que cambia de signo de una consulta a otra. Para hablar de crecimiento hacen falta ventanas largas y una pendiente estable.
