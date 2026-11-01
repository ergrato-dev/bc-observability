# Lab 03 — Agregaciones y aritmética

⏱ Duración estimada: ~60 min

## Objetivo

Agregar series con `sum by` y `sum without`, calcular proporciones entre dos consultas y combinar métricas de servicios distintos para responder preguntas de la semana 01.

## Contexto

- Los operadores de agregación (`sum`, `avg`, `max`, `min`, `count`, `topk`…) juntan series. `by (labels)` dice qué labels se conservan; `without (labels)`, cuáles se quitan.
- Entre dos instant vectors, `/`, `-` o `*` emparejan las series que tienen **exactamente los mismos labels**. Si un lado tiene un label que el otro no tiene, no hay pareja y el resultado sale vacío, sin error.
- Por eso el patrón de casi toda proporción es: agrega los dos lados por los mismos labels y divide.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md` y apunta en él cada consulta.

1. Peticiones por segundo de toda la tienda, en un solo número:
   ```bash
   ./scripts/promql.sh 'sum(rate(http_server_request_duration_seconds_count[5m]))'
   ```
   Quita el `sum` y cuenta cuántas series salen: cada una es una combinación de `job`, `instance`, `method`, `route` y `status_code`.

2. Agrupa con `by`. Escribe en `consultas.md`:
   - peticiones por segundo de cada servicio (una serie por `job`): consulta `12` de la libreta
   - notificaciones por segundo por resultado (una serie por `result`): consulta `11`
   - pedidos por segundo que fallan, por `status_code` (todos menos 201): consulta `02`

   ¿Por qué `notificaciones` no sale en la primera? Llama a `curl -s 127.0.0.1:18004/stats` unas cuantas veces y repite.

3. Lo mismo con `without`:
   ```bash
   ./scripts/promql.sh 'sum without (instance, method, status_code) (rate(http_server_request_duration_seconds_count[5m]))'
   ```
   Te quedas con `job` y `route`. `by` es más explícito; `without` conserva los labels que no conoces, y eso importa cuando otro equipo añade uno nuevo (por ejemplo `region`) y no quieres perderlo.

4. Proporciones. Escribe:
   - la fracción de pedidos que falla (no responde 201), entre 0 y 1: consulta `03`
   - la fracción de lecturas de producto que sirve la caché (`catalog_cache_requests_total`): consulta `10`
   - la fracción de peticiones de cada servicio que responde 5xx, una serie por `job`: consulta `13`

   En la última, prueba a dividir sin agregar el denominador por `job`:
   ```bash
   ./scripts/promql.sh 'sum by (job) (rate(http_server_request_duration_seconds_count{status_code=~"5.."}[5m])) / sum(rate(http_server_request_duration_seconds_count[5m]))'
   ```
   Vacío: a la izquierda hay un label `job`, a la derecha ninguno. Arréglalo agregando los dos lados igual.

5. Recursos con los exporters de la semana 03. Escribe:
   - memoria de cada servicio de la tienda, una serie por `container_label_com_docker_compose_service`, solo del proyecto `tienda`: consulta `15`
   - CPU de cada servicio en núcleos (`rate` de `container_cpu_usage_seconds_total`): consulta `16`
   - fracción de la CPU del host ocupada: `node_cpu_seconds_total` tiene una serie por CPU y por modo; el tiempo `idle` es el libre. Usa `avg`: consulta `17`
   - fracción de la memoria del host disponible (`node_memory_MemAvailable_bytes` entre `node_memory_MemTotal_bytes`): consulta `18`. Aquí no hace falta agregar: las dos métricas tienen los mismos labels.

6. Combina dos servicios: los cobros fantasma de la semana 01. `pagos` cuenta los cobros aprobados (`route="/charges"`, `status_code="201"`) y `pedidos` los pedidos creados (`orders_created_total`). La diferencia por segundo son cobros aprobados en pedidos que acabaron fallando: escríbela como un solo número (consulta `09`). Sin avería sale cerca de 0, con unas centésimas arriba o abajo: `rate` extrapola cada serie por separado y los dos servicios no se scrapean en el mismo instante. Ahora rompe `pagos` como en la semana 01:
   ```bash
   curl -s -X PUT 127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.02,"latency_ms":80,"jitter_ms":40,"timeout_rate":0.3}'
   ```
   Espera dos minutos y repite la consulta 09 y `sum by (reason) (rate(payment_failures_total[5m]))`. Los timeouts de `pedidos` se convierten en cobros que `pagos` aprueba 30 s después. Deja `timeout_rate` otra vez a 0.

## Criterios de éxito

- [ ] Las consultas de los pasos 2, 4 y 5 devuelven los labels pedidos y nada más
- [ ] Sabes por qué la división del paso 4 sin agregar el denominador sale vacía
- [ ] Con la avería, la consulta 09 sube claramente por encima del ruido y vuelve cerca de 0 al quitarla

## Reto extra

`count`, `max` y `topk` también son agregaciones. Escribe en una sola consulta cuántas rutas distintas tiene cada servicio (`count by (job)` sobre algo que tenga una serie por ruta) y cuál es el servicio que más memoria usa (`topk(1, ...)` sobre la consulta 15).

---

[← Lab 02](../lab-02-tasas/README.md) · [Lab 04 →](../lab-04-percentiles/README.md)
