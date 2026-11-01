# Lab 02 — Carga con k6

⏱ Duración estimada: ~60 min

## Objetivo

Generar tráfico controlado contra la tienda con k6 y leer qué puede y qué no puede decirte un cliente sobre el sistema.

## Contexto

- Sin tráfico no hay señal que observar. El servicio `trafico` genera 2 iteraciones por segundo de fondo; una prueba en escalón sube la carga a propósito.
- k6 mide desde fuera: ve latencias y errores tal como los ve el cliente. Es una forma de observabilidad, pero ciega a lo que pasa dentro.
- `ramping-arrival-rate` fija cuántas iteraciones empiezan por segundo, tarde lo que tarde cada una. Así la carga no baja cuando el sistema se pone lento, como pasa con los usuarios reales.

## Instrucciones

1. Mira el tráfico de fondo y cuántos pedidos crea:
   ```bash
   docker compose -f app/compose.yaml logs --tail 5 trafico
   docker compose -f app/compose.yaml exec postgres psql -U tienda -tAc \
     "SELECT count(*) FROM orders WHERE created_at > now() - interval '1 minute'"
   ```
   Lee `app/k6/compra.js`: ¿qué proporción de iteraciones son compras?

2. Abre `starter/escalon.js` y completa las cuatro etapas de 20 s: sube a 20 it/s, mantén, sube a 60 it/s, mantén.

3. Añade los umbrales: p95 de `POST /orders` por debajo de 500 ms (`http_req_duration{name:POST /orders}`) y menos de un 5 % de peticiones fallidas (`http_req_failed`).

4. Ejecuta la prueba desde la carpeta de este lab:
   ```bash
   docker compose -f ../../../../app/compose.yaml run --rm \
     -v "$PWD/starter:/lab:ro" trafico run --quiet /lab/escalon.js
   ```
   `http_req_failed` sale por encima del 0 % aunque la tienda funcione: k6 cuenta los 402 como fallos. Haz que trate el 402 como respuesta esperada con `http.setResponseCallback(http.expectedStatuses({ min: 200, max: 299 }, 402))` y repite.

5. Degrada `pagos` y repite la prueba:
   ```bash
   curl -s -X PUT http://127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.02,"latency_ms":600,"jitter_ms":100,"timeout_rate":0}'
   ```
   El umbral de latencia de `POST /orders` tiene que salir en rojo (✗) y k6 tiene que terminar con código distinto de 0.

6. Restaura `pagos`:
   ```bash
   curl -s -X PUT http://127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.02,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}'
   ```

## Criterios de éxito

- [ ] Con la tienda sana, los dos umbrales salen en verde (✓) y la prueba sostiene 60 it/s
- [ ] Con `pagos` a 600 ms, el umbral de `POST /orders` sale en rojo
- [ ] Sabes responder: con el resumen de k6, ¿puedes saber **qué servicio** causó la lentitud?

## Reto extra

Busca el punto de ruptura: sube las etapas a 150 y 300 it/s. ¿Qué empieza a fallar primero, la latencia o los errores? ¿Puedes saber por qué solo con k6?

---

[← Lab 01](../lab-01-levantar-la-tienda/README.md) · [Lab 03 →](../lab-03-depurar-a-ciegas/README.md)
