# Lab 01 — Levantar la tienda

⏱ Duración estimada: ~60 min

## Objetivo

Arrancar el laboratorio y seguir un pedido de punta a punta por todos los servicios de la tienda.

## Contexto

- La tienda es la app que observarás durante 22 semanas. Antes de instrumentarla tienes que saber qué hace cada pieza y qué rastro deja hoy.
- Todo corre en Docker Compose desde `app/compose.yaml`. Los puertos solo se publican en `127.0.0.1`.
- El servicio `trafico` (k6) genera tráfico de fondo desde el primer momento.

## Instrucciones

1. Desde la raíz del repositorio, comprueba tu entorno:
   ```bash
   ./scripts/verificar-semana.sh --doctor
   ```
   Todo lo obligatorio tiene que salir en ✅. Si falla la RAM, revisa [docs/perfiles-de-laboratorio.md](../../../../docs/perfiles-de-laboratorio.md).

2. Levanta la tienda y comprueba que todo está sano:
   ```bash
   ./scripts/lab-up.sh
   docker compose -f app/compose.yaml ps
   ```
   Los cuatro servicios (`catalogo`, `pedidos`, `pagos`, `notificaciones`) tienen que salir `healthy`.

3. Recorre la tienda como lo haría un cliente:
   ```bash
   curl -s 'http://127.0.0.1:18001/products?limit=3' | jq
   curl -s http://127.0.0.1:18001/products/42 | jq
   curl -s -X POST http://127.0.0.1:18002/orders -H 'Content-Type: application/json' \
     -d '{"customer":{"email":"tu@example.com","card_number":"4111111111111111"},"items":[{"product_id":42,"quantity":2}]}' | jq
   ```
   Apunta el `id` del pedido y consúltalo con `curl -s http://127.0.0.1:18002/orders/<id> | jq`.

4. Sigue el rastro de ese pedido:
   ```bash
   docker compose -f app/compose.yaml exec postgres psql -U tienda -c 'SELECT * FROM orders ORDER BY id DESC LIMIT 3'
   curl -s http://127.0.0.1:18004/stats
   ```
   Abre la consola de RabbitMQ en http://127.0.0.1:15672 (usuario y contraseña `tienda`) y busca la cola `notificaciones.order-created`.

5. Abre `starter/notas.md` y responde cada pregunta. Dibuja el diagrama de la tienda con todas sus piezas: lo reutilizarás en el proyecto.

6. Pasa la prueba de humo:
   ```bash
   ./app/scripts/smoke-test.sh
   ```

## Criterios de éxito

- [ ] `docker compose -f app/compose.yaml ps` muestra los cuatro servicios `healthy`
- [ ] Creaste un pedido y lo encontraste en PostgreSQL y en `/stats` de `notificaciones`
- [ ] `./app/scripts/smoke-test.sh` termina con `Smoke test superado.`
- [ ] `starter/notas.md` no tiene ningún `TODO`

## Reto extra

Lee `app/pedidos/app/main.py`. ¿En qué orden ocurren reservar stock, cobrar y guardar el pedido? ¿Qué pasa con el stock si `pagos` falla? ¿Y si `pedidos` muere justo después de cobrar?

---

[← Prácticas](../README.md) · [Lab 02 →](../lab-02-carga-con-k6/README.md)
