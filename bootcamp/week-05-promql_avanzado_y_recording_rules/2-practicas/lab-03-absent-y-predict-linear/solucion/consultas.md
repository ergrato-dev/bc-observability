# Lab 03 — absent y predict_linear

## Paso 1

- Por qué `up{job="pagos"} == 0` no devuelve nada con `pagos` parado: el contenedor parado deja de ser target, Prometheus escribe una marca de obsolescencia y la serie `up{job="pagos"}` desaparece. No hay serie que comparar con 0.

## Paso 2

- `pedidos` lleva 5 minutos sin crear pedidos: `absent_over_time((rate(orders_created_total[1m]) > 0)[5m:])`. Otra forma sin subconsulta: `sum(increase(orders_created_total[5m])) == 0`, que necesita que la serie exista.
- Qué detecta `absent_over_time(orders_created_total[5m])`: que la métrica no ha tenido ninguna muestra en 5 minutos: `pedidos` caído o sin scrapear. No detecta que deje de vender; para eso hay que mirar si sube.

## Paso 4

- Pendiente medida (bytes/s): unos −4,8 MB/s.

## Paso 5

- Condición de alerta "el disco se llena en menos de 4 horas": `predict_linear(node_filesystem_avail_bytes{mountpoint="/"}[30m], 4 * 3600) < 0`. En una alerta real la ventana es larga (30 min a 6 h) para no saltar con cada escritura puntual.

## Reto extra

La proyección de k6 es casi plana: su tráfico es constante. En una tienda real, una ventana de 30 minutos a las 9 de la mañana proyecta el pico de subida como si fuera a seguir toda la hora. `predict_linear` supone una recta; para tráfico con estacionalidad se compara con la misma hora de otro día (`offset 1d`) o se usan las técnicas de la semana 15.
