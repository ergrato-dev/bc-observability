# Lab 05 — RED y USE a mano

⏱ Duración estimada: ~60 min

## Objetivo

Calcular RED de los servicios a partir de los logs y USE de las dependencias a partir de sus estadísticas, con dos scripts de bash.

## Contexto

- Hacerlo a mano una vez enseña dos cosas: qué significa cada letra en la tienda concreta y qué datos faltan para hacerlo bien.
- Los logs de acceso de uvicorn tienen este formato: `INFO:     192.168.48.10:40672 - "POST /orders HTTP/1.1" 201 Created`.
- Las tablas que salgan de aquí son las de RED y USE de tu proyecto.

## Instrucciones

Trabaja en la carpeta de este lab. Los scripts localizan el repositorio con `git rev-parse`.

1. Abre `starter/red.sh` y ejecútalo para ver qué recoge: `./starter/red.sh pedidos`. Filtra solo las líneas de acceso (`" [0-9]{3} `) y descarta `GET /health`: es el healthcheck de Docker, no tráfico de clientes.

2. Cuenta el total, los 5xx y los 4xx, e imprime Rate en peticiones por segundo y Errors y 4xx en porcentaje. Comprueba:
   ```bash
   ./starter/red.sh pedidos 120
   ```
   Debes ver un Rate cercano a 0,5 peticiones/s (las compras del tráfico de fondo) y algo de 4xx (los cobros rechazados).

3. Ejecútalo para `catalogo`, `pagos` y `notificaciones`. Con `notificaciones` falla: explica por qué en la tabla RED de tu proyecto y propón cómo medir su Rate.

4. Escribe en la tabla RED de `3-proyecto/starter/mapa-observabilidad.md` qué medirías para cada servicio, incluida la Duration que hoy no puedes calcular.

5. Abre `starter/use.sh`. La parte de PostgreSQL de Utilization está hecha: añade Saturation (sesiones esperando un lock) y Errors (rollbacks y deadlocks).

6. Completa Valkey (`valkey-cli INFO`: `used_memory_human`, `connected_clients`, `blocked_clients`, `evicted_keys`, `rejected_connections`) y RabbitMQ (API de gestión y `/stats` de `notificaciones`).

7. Escribe la tabla USE del proyecto con PostgreSQL, Valkey y RabbitMQ.

8. Satura la cola a propósito y mira cómo cambia USE:
   ```bash
   docker compose -f ../../../../app/compose.yaml stop notificaciones
   sleep 30 && ./starter/use.sh
   docker compose -f ../../../../app/compose.yaml start notificaciones
   ```

## Criterios de éxito

- [ ] `./starter/red.sh pedidos 120` imprime Rate, Errors y 4xx
- [ ] `./starter/use.sh` imprime U, S y E de PostgreSQL, Valkey y RabbitMQ
- [ ] Con `notificaciones` parado, la S de RabbitMQ crece; al arrancarlo, vuelve a 0
- [ ] Las tablas RED y USE del proyecto no tienen celdas vacías

## Reto extra

`red.sh` de la solución lista los endpoints más llamados. Mira los de `catalogo`: ¿por qué `GET /products/302` y `GET /products/53` salen como endpoints distintos? Así se ve un problema de cardinalidad, que volverá en la semana 03.

---

[← Lab 04](../lab-04-inventario-de-senales/README.md) · [Lab 06 →](../lab-06-plan-de-instrumentacion/README.md)
