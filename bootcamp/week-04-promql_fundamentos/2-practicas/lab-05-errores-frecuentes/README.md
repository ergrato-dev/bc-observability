# Lab 05 — Errores frecuentes

⏱ Duración estimada: ~60 min

## Objetivo

Reconocer los cinco errores de PromQL que más números falsos producen, ver qué devuelve cada uno y escribir su versión correcta.

## Contexto

- La mayoría de errores de PromQL no dan error: devuelven un número. Un número plausible y falso en un dashboard es peor que un panel vacío, porque alguien toma decisiones con él.
- Cada paso de este lab rompe una consulta a propósito. Apunta en `consultas.md` el resultado falso, el correcto y por qué difieren.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md`.

1. **`rate` sobre un gauge.** La memoria disponible del host sube y baja:
   ```bash
   ./scripts/promql.sh 'rate(node_memory_MemAvailable_bytes[5m])'
   ```
   Sale un número enorme y positivo: `rate` interpreta cada bajada como un reinicio de contador y suma el valor entero. Para la tendencia de un gauge se usa `deriv()` (pendiente por segundo) o `delta()` (cambio en la ventana). Escribe la versión correcta y compara.

2. **`rate` después de `sum`.** Primero la forma correcta, la CPU total de los cuatro servicios:
   ```bash
   ./scripts/promql.sh 'sum(rate(process_cpu_seconds_total{job=~"catalogo|pedidos|pagos|notificaciones"}[1h]))'
   ```
   Ahora al revés. `rate(sum(...)[5m])` ni siquiera se acepta; hace falta una subconsulta (`[1h:]`, semana 05):
   ```bash
   ./scripts/promql.sh 'rate(sum(process_cpu_seconds_total{job=~"catalogo|pedidos|pagos|notificaciones"})[1h:])'
   ```
   Si algún servicio se reinició en esa hora, los resultados difieren. Al sumar primero, el reinicio de uno solo se ve como una bajada de la suma, y `rate` la toma por un reinicio de la suma entera. Regla: **primero `rate`, después `sum`**.

3. **La media de los percentiles.**
   ```bash
   ./scripts/promql.sh 'avg(histogram_quantile(0.95, sum by (job, le) (rate(http_server_request_duration_seconds_bucket{job=~"catalogo|pagos"}[5m]))))'
   ./scripts/promql.sh 'histogram_quantile(0.95, sum by (le) (rate(http_server_request_duration_seconds_bucket{job=~"catalogo|pagos"}[5m])))'
   ```
   La primera promedia el p95 de `catalogo` y el de `pagos` como si atendieran el mismo número de peticiones; `catalogo` atiende muchas más. La segunda suma los buckets y calcula el p95 de todas las peticiones juntas. Los percentiles no se promedian: se suman los buckets.

4. **`histogram_quantile` sin `le`.**
   ```bash
   ./scripts/promql.sh 'histogram_quantile(0.95, sum by (job) (rate(http_server_request_duration_seconds_bucket[5m])))'
   ```
   Vacío: al agregar por `job` se han sumado todos los buckets en uno, y sin el label `le` no hay histograma. Corrígelo.

5. **Un filtro que se come las series.** Las comparaciones (`>`, `==`…) filtran: devuelven solo las series que las cumplen.
   ```bash
   ./scripts/promql.sh 'sum by (job) (rate(http_server_request_duration_seconds_count{status_code=~"5.."}[5m])) > 0'
   ./scripts/promql.sh 'sum by (job) (rate(http_server_request_duration_seconds_count{status_code=~"5.."}[5m])) > bool 0'
   ```
   La primera lista los servicios con errores. La segunda devuelve 1 o 0 para cada uno. En un panel, la primera dibuja huecos donde no hay errores, y alguien leerá un hueco como "sin datos". Ten en cuenta también que un servicio sin ningún 5xx en su historia no tiene esa serie: no sale ni con `bool`.

6. Repasa la libreta del proyecto con estos cinco errores en mente. Revisa en concreto que la consulta 17 (CPU del host) aplica `rate` antes de `avg` y que ningún percentil se promedia.

## Criterios de éxito

- [ ] `consultas.md` tiene, para cada paso, el resultado falso, la consulta correcta y la explicación
- [ ] Sabes por qué `rate` sobre un gauge da un número enorme y no un error
- [ ] Sabes por qué se suman buckets y no percentiles

## Reto extra

El sexto error frecuente es la ventana más corta que dos scrapes (lab 02, paso 2). Hay un séptimo: usar `rate(x[5m])` en un panel que muestra 30 días. Cada punto de la gráfica es una tasa de 5 minutos tomada cada pocas horas, y los picos entre medias no se ven. ¿Qué función `_over_time` usarías para no perder el máximo de cada tramo? Pista: [funciones](https://prometheus.io/docs/prometheus/latest/querying/functions/#aggregation_over_time).

---

[← Lab 04](../lab-04-percentiles/README.md) · [Lab 06 →](../lab-06-la-api-con-curl-y-jq/README.md)
