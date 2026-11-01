# Lab 04 — Inventario de señales

⏱ Duración estimada: ~60 min

## Objetivo

Descubrir qué telemetría emite hoy cada pieza de la tienda, comprobándolo con comandos y no por suposición.

## Contexto

- Antes de añadir instrumentación conviene saber qué hay. A menudo la infraestructura ya expone mucho (PostgreSQL, RabbitMQ y Docker lo hacen) y lo que falta es la parte de la aplicación.
- Para cada pieza y señal, la respuesta es "sí", "no" o "parcial", con el comando que lo demuestra.

## Instrucciones

Trabaja desde la raíz del repositorio. Anota cada hallazgo en `starter/inventario.md`.

1. **Métricas de la aplicación.** ¿Algún servicio expone `/metrics`?
   ```bash
   for p in 18001 18002 18003 18004; do curl -s -o /dev/null -w "$p %{http_code}\n" http://127.0.0.1:$p/metrics; done
   ```

2. **Logs de la aplicación.** Mira 10 líneas de cada servicio y clasifica el formato (texto, JSON) y lo que contienen:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix --tail 10 catalogo
   ```
   ¿`notificaciones` registra cada petición HTTP? ¿Y cada mensaje que consume?

3. **Trazas.** ¿Viaja alguna cabecera de contexto entre servicios? Mira las cabeceras de una respuesta:
   ```bash
   curl -si http://127.0.0.1:18001/products/1 | head -12
   ```
   Busca `traceparent` en el código: `grep -rn traceparent app/`.

4. **PostgreSQL.** Tiene estadísticas internas aunque nadie las recoja:
   ```bash
   docker compose -f app/compose.yaml exec postgres psql -U tienda -c \
     'SELECT numbackends, xact_commit, xact_rollback, blks_hit, blks_read FROM pg_stat_database WHERE datname = $$tienda$$'
   ```

5. **Valkey y RabbitMQ.**
   ```bash
   docker compose -f app/compose.yaml exec valkey valkey-cli INFO stats | head -20
   curl -su tienda:tienda http://127.0.0.1:15672/api/overview | jq '.queue_totals, .message_stats.publish_details'
   ```

6. **Contenedores.** Docker conoce CPU, memoria y red de cada contenedor:
   ```bash
   docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}'
   ```

7. **El cliente.** k6 mide latencia y errores desde fuera (lab 02). ¿Lo guarda en algún sitio cuando termina?

8. Completa la tabla de `starter/inventario.md` y escribe la conclusión: ¿qué parte del sistema es más observable hoy y cuál menos?

## Criterios de éxito

- [ ] Cada celda de la tabla tiene "sí", "no" o "parcial" y su evidencia
- [ ] La conclusión distingue la infraestructura (observable a medias) de la aplicación (casi opaca)

## Reto extra

PostgreSQL trae la extensión `pg_stat_statements`, que registra el coste de cada consulta. ¿Está activada en la tienda? (`SELECT * FROM pg_extension`). ¿Qué haría falta para activarla?

---

[← Lab 03](../lab-03-depurar-a-ciegas/README.md) · [Lab 05 →](../lab-05-red-y-use-a-mano/README.md)
