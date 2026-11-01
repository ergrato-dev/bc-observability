# Lab 02 — Tasas: rate, irate e increase

⏱ Duración estimada: ~60 min

## Objetivo

Convertir contadores en tasas y en incrementos con `rate`, `irate` e `increase`, y comprobar que sobreviven al reinicio de un servicio.

## Contexto

- El valor de un counter no dice nada: depende de cuándo arrancó el proceso. Lo que interesa es cuánto sube.
- `rate(x[5m])` es el aumento por segundo, promediado en los últimos 5 minutos. `increase(x[1h])` es el aumento total en la última hora: `rate` multiplicado por la ventana. `irate` usa solo las dos últimas muestras.
- Las tres detectan los reinicios: si el contador baja, entienden que volvió a 0 y siguen contando desde ahí. Por eso **nunca se aplican a un gauge**.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md` y apunta en él cada consulta.

1. Mira el contador en crudo, en la pestaña *Graph* de `http://127.0.0.1:9090/query` con un rango de 1 h:
   ```
   orders_created_total
   ```
   Crece en rampa y cae a 0 cada vez que se reconstruyó `pedidos`. Esa gráfica no sirve para nada operativo.

2. Ahora su tasa, con tres ventanas:
   ```bash
   for w in 20s 1m 5m; do echo "[$w]"; ./scripts/promql.sh "rate(orders_created_total[$w])"; done
   ```
   Con `[20s]` a veces no sale nada: `rate` necesita al menos dos muestras dentro de la ventana, y con un scrape cada 15 s no siempre las hay. Dibuja `[1m]` y `[5m]` en *Graph*: la de 1 minuto es más nerviosa, la de 5 minutos más estable y más lenta en reaccionar. Regla práctica: la ventana, al menos cuatro veces el `scrape_interval`.

3. Calcula los pedidos por segundo que **entran** en la tienda (pagados o no) con el histograma de duración, que cuenta todas las peticiones a `POST /orders`:
   ```bash
   ./scripts/promql.sh 'rate(http_server_request_duration_seconds_count{job="pedidos", method="POST", route="/orders"}[5m])'
   ```
   Sale una serie por `status_code`. Envuélvelo en `sum(...)` para obtener un solo número: es la consulta `01` de la libreta del proyecto. Compárala con `rate(orders_created_total[5m])`: ¿por qué es mayor?

4. Compara `rate` con `irate` en *Graph*, rango de 15 minutos:
   ```
   rate(http_server_request_duration_seconds_count{job="catalogo", route="/products"}[5m])
   irate(http_server_request_duration_seconds_count{job="catalogo", route="/products"}[5m])
   ```
   `irate` dibuja cada salto; `rate`, la tendencia. Para dashboards y alertas se usa `rate`: `irate` cambia según en qué instante mires.

5. Cuenta lo que pasó en la última hora con `increase`:
   ```bash
   ./scripts/promql.sh 'increase(orders_created_total[1h])'
   ./scripts/promql.sh 'increase(payment_failures_total[1h])'
   ```
   El resultado no es entero: Prometheus extrapola hasta los bordes de la ventana. Escribe en `consultas.md` los pedidos creados en la última hora como un solo número, con `sum(...)`, y los cobros fallidos de la última hora con una serie por `reason`, con `sum by (reason) (...)`. Son las consultas `20` y `04` de la libreta.

6. Reinicia `pedidos` y comprueba qué pasa con el contador y con su tasa:
   ```bash
   ./scripts/promql.sh 'orders_created_total'
   docker compose -f app/compose.yaml restart pedidos
   ```
   Tras dos scrapes, el contador ha vuelto a empezar, pero `rate(orders_created_total[5m])` sigue en su sitio. `resets()` cuenta cuántas veces bajó un contador: escribe cuántas veces se ha reiniciado cada uno de los cuatro servicios en la última hora, con una serie por `job`, usando `process_cpu_seconds_total`, que todos exponen. Es la consulta `19`.

## Criterios de éxito

- [ ] Sabes por qué `rate(x[20s])` puede devolver vacío y qué ventana mínima usar
- [ ] Las consultas de los pasos 3, 5 y 6 devuelven un valor con los labels pedidos
- [ ] Tras reiniciar `pedidos`, `rate` no cae a 0 y `resets` cuenta el reinicio

## Reto extra

`increase(orders_created_total[1h])` y `rate(orders_created_total[1h]) * 3600` dan lo mismo. ¿Y `orders_created_total - orders_created_total offset 1h`? Pruébalo antes y después de reiniciar `pedidos` y explica la diferencia.

---

[← Lab 01](../lab-01-selectores/README.md) · [Lab 03 →](../lab-03-agregaciones/README.md)
