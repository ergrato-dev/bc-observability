# Lab 03 — Métricas en Node.js

⏱ Duración estimada: ~60 min

## Objetivo

Instrumentar `notificaciones` con `@prometheus-io/client` usando los mismos nombres, labels y buckets que los servicios Python, de forma que una sola consulta sirva para los cuatro servicios.

## Contexto

- `@prometheus-io/client` es el cliente oficial de Prometheus para Node.js. Hasta agosto de 2026 se publicaba como `prom-client`, que ya no recibe versiones: si lo ves en un tutorial, es el mismo código con otro nombre.
- Igual que en los logs, un nombre de métrica común solo es común si coinciden también los labels y, en los histogramas, los buckets. Los valores por defecto de los dos clientes no coinciden.
- `collectDefaultMetrics()` añade las métricas del proceso y de Node.js, entre ellas el retraso del event loop: la saturación de un servicio Node.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada.

1. Copia `starter/metrics.js` a `$TIENDA/notificaciones/src/metrics.js`. En `src/index.js`, impórtalo, registra `app.use(measureRequests)` después de `logRequests` y añade la ruta `app.get("/metrics", metrics)`. En `src/logger.js`, haz que `logRequests` ignore `/metrics` igual que `/health`.

2. Completa el TODO del paso 2, reconstruye y mira qué expone por defecto:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:18004/metrics | grep '^# TYPE' | head -30
   curl -s 127.0.0.1:18004/metrics | grep '^nodejs_eventloop_lag_p99_seconds'
   ```

3. Completa el TODO del paso 3 y comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:18004/stats >/dev/null
   curl -s 127.0.0.1:18004/metrics | grep '^http_server_request_duration_seconds_count'
   ```
   Tiene que salir `route="/stats"`.

4. Compara los buckets de `notificaciones` con los de `catalogo`:
   ```bash
   for p in 18001 18004; do
     curl -s 127.0.0.1:$p/metrics | grep '^http_server_request_duration_seconds_bucket' \
       | grep -o 'le="[^"]*"' | sort -u | paste -sd ' '
   done
   ```
   No coinciden: faltan `0.075`, `0.75` y `7.5`. Para calcular un percentil de los cuatro servicios juntos hay que sumar sus buckets, y no se puede sumar un bucket que un servicio no tiene. Completa el TODO del paso 4 con los buckets de Python y repite la comparación.

5. Completa el TODO del paso 5: `notifications_total` con el label `result`, exportado, y súmale uno en `index.js` con `result: "sent"` al enviar el correo y `result: "discarded"` al descartar un mensaje. Comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:18004/metrics | grep '^notifications_total'
   ```

6. Comprueba que los dos lenguajes hablan la misma métrica: la línea `# TYPE` y los nombres de los labels del histograma tienen que ser idénticos en `catalogo` y en `notificaciones`:
   ```bash
   for p in 18001 18004; do
     curl -s 127.0.0.1:$p/metrics | grep '^http_server_request_duration_seconds_count' | head -1 \
       | grep -o '[a-z_]*=' | sort | paste -sd ' '
   done
   ```

## Criterios de éxito

- [ ] `notificaciones` expone `http_server_request_duration_seconds` como `histogram` con `route="/stats"`
- [ ] Los buckets de `notificaciones` y de `catalogo` son los mismos
- [ ] `notifications_total{result="sent"}` crece con el tráfico de pedidos
- [ ] `/metrics` no aparece en los logs de `notificaciones`

## Reto extra

`nodejs_eventloop_lag_p99_seconds` es un percentil que calcula el propio cliente, como un summary. Bloquea el event loop un segundo con un endpoint de prueba (`while (Date.now() - t < 1000)`) y mira cómo cambia. ¿Por qué esta métrica es más útil para la saturación de `notificaciones` que la CPU del contenedor?

---

[← Lab 02](../lab-02-metricas-red/README.md) · [Lab 04 →](../lab-04-service-discovery-de-docker/README.md)
