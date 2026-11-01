# Plan de instrumentación (SOLUCIÓN)

## Preguntas

- ¿Cuántos pedidos por segundo entran y cuántos fallan?
- ¿Qué fracción de los pedidos fallidos se debe a `pagos` y qué fracción a `catalogo`?
- ¿Cuánto tarda un checkout en el percentil 50, 95 y 99?
- ¿Qué paso del checkout (precio, reserva, cobro, guardado) aporta más latencia?
- ¿Cuántos cobros aprueba `pagos` en pedidos que `pedidos` marca como fallidos?
- ¿Cuántos mensajes esperan en la cola de `notificaciones` y cuánto tarda un correo desde que se paga?
- ¿Qué porcentaje de las lecturas de producto sirve la caché de Valkey?
- ¿Qué consultas SQL consumen más tiempo en PostgreSQL?
- ¿Qué búsquedas del catálogo son las más lentas y por qué?
- ¿Qué cambió justo antes de que empeorara?

## Clasificación

| Pregunta | Señal | Por qué esa señal | Prioridad |
|---|---|---|:--:|
| ¿Cuántos pedidos por segundo entran y cuántos fallan? | Métricas | Recuento agregado en el tiempo: barato y sin detalle por pedido | ⭐ |
| ¿Qué fracción de los fallidos se debe a `pagos` y cuál a `catalogo`? | Métricas | Tasa de errores por servicio y destino de la llamada | ⭐ |
| ¿Cuánto tarda un checkout en p50, p95 y p99? | Métricas | Histograma de duración: la distribución, no la media | |
| ¿Qué paso del checkout aporta más latencia? | Trazas | Solo una traza desglosa el tiempo de una petición por cada salto | ⭐ |
| ¿Cuántos cobros aprueba `pagos` en pedidos fallidos? | Trazas y logs | Hace falta unir la petición de `pedidos` con la de `pagos` por un identificador común | |
| ¿Cuántos mensajes esperan y cuánto tarda un correo? | Métricas y trazas | Profundidad de cola (métrica) y tiempo desde la publicación (traza asíncrona) | |
| ¿Qué porcentaje de lecturas sirve la caché? | Métricas | Aciertos y fallos de caché, como proporción | |
| ¿Qué consultas SQL consumen más tiempo? | Métricas | `pg_stat_statements` expuesto con un exporter | |
| ¿Qué búsquedas son las más lentas y por qué? | Trazas y perfiles | La traza localiza la búsqueda lenta; el perfil, la función que gasta la CPU | |
| ¿Qué cambió justo antes de que empeorara? | Logs | Eventos de despliegue y de configuración (por ejemplo `PUT /admin/faults`) | |

Las tres ⭐ son las que habrían resuelto el lab 03 en minutos: tasa de errores por servicio (avería 1) y desglose de la latencia del checkout (avería 2).

## Plan

| Semana | Señal | Qué añade a la tienda |
|---|---|---|
| 02 | Logs | JSON con esquema común y `request_id` de punta a punta; sin datos personales |
| 03 | Métricas | `/metrics` con RED en los cuatro servicios y Prometheus recogiéndolas |
| 07 | Métricas | Alertas sobre síntomas (errores y latencia del checkout) |
| 08 | Logs | Logs centralizados en Loki |
| 09-10 | Trazas | Trazas de punta a punta, incluida la ruta asíncrona hasta `notificaciones` |
| 12 | Todas | Correlación métrica → traza → logs |
| 14 | Perfiles | Perfiles de CPU para encontrar el coste de la búsqueda |
| 15 | Métricas | SLOs sobre los SLIs del mapa |
| 16 | Métricas | `pg_stat_statements`, Valkey y RabbitMQ con exporters |
