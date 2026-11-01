# Lab 04 — Propagar el request_id

⏱ Duración estimada: ~60 min

## Objetivo

Propagar el `request_id` de un pedido desde `pedidos` hasta `catalogo`, `pagos` y, a través de RabbitMQ, `notificaciones`, y usarlo para resolver los cobros fantasma de la semana 01.

## Contexto

- Un `request_id` que se queda en un servicio solo sirve dentro de ese servicio. Para seguir un pedido, cada llamada saliente tiene que llevarlo: en HTTP, como cabecera; en RabbitMQ, como cabecera del mensaje.
- Quien recibe la petición no tiene que hacer nada nuevo: el middleware del lab 02 ya lee `X-Request-ID` si viene.
- Esto es una versión manual de lo que hace la propagación de contexto de OpenTelemetry (`traceparent`), que llegará en la semana 09.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada.

1. Lleva el esquema a `pedidos` y `pagos`. Copia `$TIENDA/catalogo/app/logging_config.py` a `$TIENDA/pedidos/app/` y a `$TIENDA/pagos/app/`. En cada `main.py`, llama a `configure_logging` con el nombre del servicio, registra el middleware con `app.middleware("http")(log_requests)` y crea `log = structlog.get_logger()`. En `pedidos`, borra `log = logging.getLogger("uvicorn.error")` y convierte sus llamadas a eventos, por ejemplo `log.warning("stock_release_failed", product_id=item.product_id)`. Reconstruye y comprueba:
   ```bash
   ./scripts/lab-up.sh
   docker compose -f app/compose.yaml logs --no-log-prefix --tail 3 pedidos | jq -c 'select(.event == "http_request")'
   ```

2. Propaga por HTTP. Añade al final de `logging_config.py` (en los tres servicios Python, para que el archivo siga siendo idéntico):
   ```python
   async def propagate_request_id(request) -> None:
       """Hook de httpx: las llamadas salientes llevan el request_id de la petición en curso."""
       if request_id := structlog.contextvars.get_contextvars().get("request_id"):
           request.headers[REQUEST_ID_HEADER] = request_id
   ```
   En `pedidos/app/main.py`, pásalo al cliente: `httpx.AsyncClient(timeout=5, event_hooks={"request": [propagate_request_id]})`. Reconstruye y haz un pedido con un identificador tuyo:
   ```bash
   curl -s -X POST http://127.0.0.1:18002/orders -H 'Content-Type: application/json' -H 'X-Request-ID: lab04-1' \
     -d '{"customer":{"email":"tu@example.com","card_number":"4111111111111111"},"items":[{"product_id":7,"quantity":1}]}'
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -c 'select(.request_id == "lab04-1") | {event, route}'
   ```
   Debes ver dos peticiones en `catalogo`: el precio y la reserva.

3. Comprueba que el mismo hook cubre `pagos`:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix pagos | jq -c 'select(.request_id == "lab04-1") | {event, route, status_code}'
   ```
   Las cabeceras viajan a través de toxiproxy sin cambios: es un proxy TCP.

4. Propaga por RabbitMQ. Al publicar `order.created`, añade las cabeceras al mensaje:
   ```python
   aio_pika.Message(
       ...,
       headers={"x-request-id": structlog.contextvars.get_contextvars().get("request_id")},
   )
   ```

5. Recógelo en `notificaciones`. Al principio del callback de `channel.consume`, crea un logger hijo y úsalo en lugar de `logger` dentro del callback:
   ```js
   const log = logger.child({ request_id: msg.properties.headers?.["x-request-id"] ?? null });
   ```
   Reconstruye, repite el pedido del paso 2 con `X-Request-ID: lab04-2` y busca ese identificador en `notificaciones`.

6. Completa `starter/seguir.sh` y sigue el pedido por los cuatro servicios en orden:
   ```bash
   ./bootcamp/week-02-logs_estructurados/2-practicas/lab-04-propagar-el-request-id/starter/seguir.sh lab04-2
   ```
   Debes ver, en orden: las llamadas de `catalogo`, el cobro en `pagos`, el `http_request` de `pedidos` y el correo de `notificaciones`.

7. Vuelve a los cobros fantasma de la semana 01. Activa la avería 2, espera un minuto y cuenta los pedidos que `pedidos` dio por fallidos (402) aunque `pagos` los cobró (201):
   ```bash
   S01=bootcamp/week-01-que_es_observabilidad/2-practicas/lab-03-depurar-a-ciegas
   $S01/romper.sh 2 && sleep 60
   docker compose -f app/compose.yaml logs --no-log-prefix --since 1m pedidos pagos | jq -s '
     (map(select(.service == "pagos" and .route == "/charges" and .status_code == 201) | .request_id)) as $cobrados
     | map(select(.service == "pedidos" and .route == "/orders" and .status_code == 402 and (.request_id | IN($cobrados[]))))
     | length'
   $S01/reparar.sh
   ```
   En la semana 01 solo podías sospecharlo. Ahora tienes la cifra exacta y la lista de pedidos afectados.

## Criterios de éxito

- [ ] `pedidos` y `pagos` escriben solo JSON, con `http_request` por cada petición
- [ ] Un pedido con `X-Request-ID: x` deja líneas con `request_id: "x"` en `catalogo`, `pagos` y `notificaciones`
- [ ] `seguir.sh` muestra las líneas de un pedido de los cuatro servicios, ordenadas por `timestamp`
- [ ] Con la avería 2 activa, el paso 7 devuelve un número mayor que 0

## Reto extra

¿Qué pasa con el `request_id` si un cliente manda `X-Request-ID: '; DROP TABLE orders; --` o una cadena de 10 000 caracteres? Decide qué validación pondrías en el middleware (longitud, caracteres permitidos) y por qué un identificador que viene de fuera no es de fiar.

---

[← Lab 03](../lab-03-pino-en-notificaciones/README.md) · [Lab 05 →](../lab-05-fuera-datos-personales/README.md)
