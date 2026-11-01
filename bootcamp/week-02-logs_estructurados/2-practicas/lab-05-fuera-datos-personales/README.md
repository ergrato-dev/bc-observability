# Lab 05 — Fuera datos personales

⏱ Duración estimada: ~60 min

## Objetivo

Eliminar los datos personales de los logs de la tienda y añadir una red de seguridad que los tape si alguien vuelve a escribirlos.

## Contexto

- `pedidos` y `notificaciones` escriben el email del cliente y, en `pedidos`, el número de tarjeta. Están marcados como antipatrón desde el primer día.
- Lo que entra en un log se copia a disco, a backups, a sistemas centralizados y a las pantallas de quien investiga. Borrar un dato personal de ahí después es casi imposible.
- La solución es no escribirlo. La redacción automática es la red por si alguien se equivoca, no la solución.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada.

1. Mide el problema. Completa la expresión regular de `starter/buscar-pii.sh` y ejecútalo:
   ```bash
   ./bootcamp/week-02-logs_estructurados/2-practicas/lab-05-fuera-datos-personales/starter/buscar-pii.sh
   ```
   `pedidos` y `notificaciones` tienen que salir con un número mayor que 0. Si `pedidos` sale con 0, mira cómo quedó en el lab 04 la línea `Nuevo pedido de %s con tarjeta %s`: structlog no interpola esos argumentos, los guarda en `positional_args`, y el dato sigue ahí.

2. Corrige la causa. En `pedidos`, borra la línea del antipatrón: el pedido ya queda registrado por su `http_request`. En `notificaciones`, sustituye la línea del correo por un evento sin el email:
   ```js
   log.info({ order_id: event.order_id }, "email_sent");
   ```
   Reconstruye, espera un minuto de tráfico y repite el paso 1: los cuatro servicios tienen que salir con 0.

3. Pon la red en Python. Sigue las instrucciones de `starter/redact_pii.py`, completa el TODO y copia el `logging_config.py` resultante a los tres servicios. Compruébalo sin tocar el código de la tienda:
   ```bash
   docker compose -f app/compose.yaml exec pedidos python -c '
   import structlog
   from app.logging_config import configure_logging
   configure_logging("prueba")
   structlog.get_logger().warning("prueba", email="ana@example.com", nota="pagó con 4111111111111111")'
   ```
   La salida tiene que mostrar `"email": "[REDACTED]"` y `"nota": "pagó con [CARD]"`.

4. Pon la red en Node.js. Añade a la configuración de pino en `logger.js`:
   ```js
   redact: { paths: ["email", "card_number", "*.email", "*.card_number"], censor: "[REDACTED]" },
   ```
   Reconstruye y comprueba:
   ```bash
   docker compose -f app/compose.yaml exec notificaciones node -e 'import("./src/logger.js").then(({ logger }) => logger.warn({ email: "ana@example.com", pedido: { email: "ana@example.com" } }, "prueba"))'
   ```
   pino tapa por ruta de campo, no por contenido: un email dentro de un texto libre no lo detecta. Por eso el paso 2 es la solución y este solo la red.

5. Piensa en el resto del camino. El email sigue viajando en el mensaje de RabbitMQ (`notificaciones` lo necesita para enviar el correo) y guardado en la tabla `orders`. Responde en tus notas: ¿quién puede leer cada uno de esos sitios? ¿Qué cambiaría si el evento llevara solo el `order_id` y `notificaciones` pidiera el email a `pedidos`?

## Criterios de éxito

- [ ] `buscar-pii.sh` devuelve 0 en los cuatro servicios con el tráfico de fondo en marcha
- [ ] Un log de Python con `email=...` sale con `[REDACTED]`, y un número de tarjeta dentro de un texto sale como `[CARD]`
- [ ] Un log de pino con `email` (también dentro de un objeto) sale con `[REDACTED]`
- [ ] Respondiste el paso 5 por escrito

## Reto extra

La expresión de tarjetas tapa cualquier número de 13 a 19 cifras, aunque no sea una tarjeta (un código de barras, un identificador largo). Implementa la comprobación de Luhn para tapar solo los números que pueden ser tarjetas. ¿Merece la pena el riesgo de dejar pasar una tarjeta real mal escrita?

---

[← Lab 04](../lab-04-propagar-el-request-id/README.md) · [Lab 06 →](../lab-06-consultas-con-jq/README.md)
