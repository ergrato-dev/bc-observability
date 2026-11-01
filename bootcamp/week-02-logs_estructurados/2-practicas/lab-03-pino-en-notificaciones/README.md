# Lab 03 — pino en notificaciones

⏱ Duración estimada: ~60 min

## Objetivo

Hacer que `notificaciones` (Node.js) escriba sus logs con pino y con el mismo esquema que los servicios Python, de forma que una consulta con `jq` sirva igual para los cuatro servicios.

## Contexto

- Un esquema común solo es común si lo cumplen todos los lenguajes. pino y structlog tienen valores por defecto distintos: hay que alinearlos en la configuración, no en cada línea.
- pino escribe JSON en stdout y es muy rápido. Los campos se pasan como primer argumento: `logger.info({ order_id }, "email_sent")`.
- `logger.child({ request_id })` crea un logger que añade ese campo a todas sus líneas: es el equivalente a `bind_contextvars` de structlog.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada.

1. Mira cómo escribe pino si no lo configuras y compáralo con una línea de `catalogo`:
   ```bash
   docker compose -f app/compose.yaml exec notificaciones node -e 'import("pino").then(({ default: pino }) => pino().warn({ order_id: 1 }, "prueba"))'
   docker compose -f app/compose.yaml logs --no-log-prefix --tail 1 catalogo
   ```
   Apunta cada diferencia: nombre del mensaje, nivel, hora, campos sobrantes, campo que falta.

2. Copia `starter/logger.js` a `$TIENDA/notificaciones/src/` y completa el TODO del paso 2 para corregir cada diferencia del paso anterior. Documentación: [opciones de pino](https://github.com/pinojs/pino/blob/main/docs/api.md).

3. En `$TIENDA/notificaciones/src/index.js`, importa `logger` y sustituye cada `console.log` y `console.error` por un evento del esquema:
   - el arranque del servidor, `server_started` con `port`
   - el cierre de la conexión con RabbitMQ, `rabbitmq_connection_closed` con nivel `fatal`
   - el mensaje descartado, `message_discarded` con nivel `error` y el motivo en `error`

   La línea del correo enviado pásala a `logger.info` sin cambiar su texto, con el email incluido: es un antipatrón que corriges en el lab 05. Reconstruye y comprueba:
   ```bash
   ./scripts/lab-up.sh
   docker compose -f app/compose.yaml logs --no-log-prefix notificaciones | jq -e . >/dev/null && echo "todo JSON"
   ```
   Si falla, busca la línea culpable con `docker compose -f app/compose.yaml logs --no-log-prefix notificaciones | grep -v '^{'`.

4. Completa `logRequests` (TODO del paso 4) y regístralo con `app.use(logRequests)` justo después de crear la app de Express. Comprueba:
   ```bash
   curl -s -H 'X-Request-ID: lab03-1' http://127.0.0.1:18004/stats
   docker compose -f app/compose.yaml logs --no-log-prefix notificaciones | jq -c 'select(.event == "http_request")'
   ```
   La línea tiene que llevar `request_id: "lab03-1"`, y ninguna línea puede tener `path` igual a `/health`.

5. Comprueba que los dos lenguajes hablan el mismo esquema. Esta consulta lista los campos que aparecen en las líneas `http_request` de cada servicio:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo notificaciones \
     | jq -s -c 'map(select(.event == "http_request")) | group_by(.service)[] | {service: .[0].service, campos: (map(keys) | add | unique)}'
   ```
   Las dos listas tienen que ser idénticas.

## Criterios de éxito

- [ ] `docker compose -f app/compose.yaml logs --no-log-prefix notificaciones | jq -e . >/dev/null` sale con 0
- [ ] Las líneas de `notificaciones` usan `timestamp` ISO 8601 en UTC y `level` en texto (`info`, `warning`, `error`)
- [ ] `GET /stats` produce una línea `http_request` con el `request_id` recibido
- [ ] El paso 5 devuelve la misma lista de campos para `catalogo` y `notificaciones`

## Reto extra

pino tiene `pino-http`, un middleware que hace lo mismo que `logRequests`. Léete sus opciones: ¿qué tendrías que configurar para que su salida cumpliera el esquema común? ¿Compensa una dependencia más frente a 20 líneas propias?

---

[← Lab 02](../lab-02-middleware-con-contexto/README.md) · [Lab 04 →](../lab-04-propagar-el-request-id/README.md)
