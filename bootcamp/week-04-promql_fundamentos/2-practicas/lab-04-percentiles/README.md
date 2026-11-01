# Lab 04 — Percentiles con histogram_quantile

⏱ Duración estimada: ~60 min

## Objetivo

Calcular percentiles de latencia con `histogram_quantile`, por servicio y por ruta, y medir cuánto se equivoca la estimación según dónde caigan los buckets.

## Contexto

- `histogram_quantile(0.95, ...)` recibe la tasa de cada bucket y estima el percentil interpolando dentro del bucket donde cae: supone que las observaciones se reparten de forma uniforme entre sus dos límites.
- El patrón es siempre el mismo: `histogram_quantile(φ, sum by (le, <lo que quieras conservar>) (rate(x_bucket[5m])))`. Sin `le` en el `by`, no hay buckets y no hay resultado.
- La media sale de `_sum` y `_count`. Los percentiles cuentan lo que la media esconde: el 5 % de clientes que espera mucho.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md` y apunta en él cada consulta.

1. Mira la tasa de cada bucket del cobro en `pagos`:
   ```bash
   ./scripts/promql.sh 'sum by (le) (rate(http_server_request_duration_seconds_bucket{job="pagos", route="/charges"}[5m]))'
   ```
   Son acumulados: cada bucket incluye a los anteriores, y `+Inf` es el total. ¿En qué bucket se cruza el 95 % del total?

2. Escribe los percentiles 50, 95 y 99 de `POST /orders` en `pedidos`, cada uno como un solo número en segundos: consultas `05`, `06` y `07` de la libreta. Comprueba que salen ordenados (p50 ≤ p95 ≤ p99). Prueba también a quitar `le` del `sum by`: no sale nada.

3. Escribe el percentil 95 de cada una de las tres llamadas que hace `pedidos` durante un checkout: la ficha (`GET /products/{product_id}`) y la reserva en `catalogo`, y el cobro en `pagos`. Una serie por `job` y `route`: consulta `08`. Para elegir las rutas con una expresión regular sin escapar las llaves dentro de comillas dobles, PromQL acepta cadenas entre comillas invertidas: ``route=~`/products/\{product_id\}` ``. ¿Qué paso aporta más latencia al checkout?

4. Mide el error de la estimación. `pagos` tarda entre 40 y 120 ms (80 ± 40), repartidos de forma uniforme: su p95 real es 116 ms. Compáralo con la consulta 08. La estimación sale cerca de 220 ms porque el p95 cae en el bucket entre 0,1 y 0,25 s, que es muy ancho, y la interpolación lo coloca por la mitad. Ahora fija la latencia en 600 ms exactos y espera cinco minutos:
   ```bash
   curl -s -X PUT 127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.02,"latency_ms":600,"jitter_ms":0,"timeout_rate":0}'
   ```
   El p95 real es 0,6 s. ¿Cuánto estima `histogram_quantile`? Prueba después con `timeout_rate` a 0.3: los cobros que se cuelgan 30 s caen en el bucket `+Inf`, y el p99 sale exactamente 10, el último bucket finito. Por encima de él, el histograma no sabe nada. Deja `pagos` como estaba (`latency_ms` 80, `jitter_ms` 40, `timeout_rate` 0) y apunta qué buckets añadirías.

5. Calcula la duración media del cobro y compárala con su p95:
   ```bash
   ./scripts/promql.sh 'sum(rate(http_server_request_duration_seconds_sum{job="pagos", route="/charges"}[5m])) / sum(rate(http_server_request_duration_seconds_count{job="pagos", route="/charges"}[5m]))'
   ```
   La media es exacta (no depende de los buckets), pero un 5 % de cobros de 30 s apenas la mueve si el resto es rápido. Para la experiencia del cliente, el percentil.

6. Escribe las tres rutas más lentas de la tienda en el percentil 95, con `topk(3, ...)` sobre el percentil por `job` y `route`: consulta `14`. Las rutas sin tráfico en la ventana dan `NaN`, y `topk` las deja fuera.

## Criterios de éxito

- [ ] Las consultas 05, 06, 07, 08 y 14 devuelven los labels pedidos y los percentiles salen ordenados
- [ ] Sabes explicar por qué el p95 de `pagos` sale cerca de 0,22 s cuando el real es 0,116 s
- [ ] Sabes qué devuelve `histogram_quantile` cuando el percentil cae en el bucket `+Inf`

## Reto extra

El SLO de latencia candidato de la semana 01 era "`POST /orders` en menos de 1 s". Con los buckets actuales, ¿puedes calcular exactamente qué fracción de pedidos tarda menos de 1 s? Escríbelo con el bucket de 1 s entre el total. Ojo con el valor: Prometheus 3 guarda `le` normalizado como número decimal, `le="1.0"`, aunque `notificaciones` lo exponga como `le="1"`. ¿Y si el umbral fuera 0,8 s? En la semana 15 verás por qué los buckets se eligen a partir de los SLO.

---

[← Lab 03](../lab-03-agregaciones/README.md) · [Lab 05 →](../lab-05-errores-frecuentes/README.md)
