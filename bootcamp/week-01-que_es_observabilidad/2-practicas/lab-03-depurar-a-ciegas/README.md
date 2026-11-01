# Lab 03 — Depurar a ciegas

⏱ Duración estimada: ~60 min

## Objetivo

Diagnosticar dos averías de la tienda usando solo `docker compose logs`, para conocer de primera mano los límites de unos logs sin estructura.

## Contexto

- `romper.sh` activa una avería; `reparar.sh` las quita todas. **No leas `romper.sh` antes de terminar el diagnóstico**: el lab consiste en encontrar la causa sin saberla.
- Herramientas permitidas: `docker compose logs` (con `--since`, `--tail` y nombre de servicio), `grep`, `awk`, `sort`, `uniq -c`. Nada más.
- El tráfico de fondo sigue corriendo: la avería afecta a pedidos reales de la tienda.

## Instrucciones

1. Desde la carpeta de este lab, activa la primera avería y espera un minuto:
   ```bash
   ./romper.sh 1
   ```

2. Encuentra el síntoma. Cuenta códigos de estado de `POST /orders` en el último minuto:
   ```bash
   docker compose -f ../../../../app/compose.yaml logs --no-log-prefix --since 60s pedidos \
     | grep 'POST /orders' | grep -oE '" [0-9]{3} ' | sort | uniq -c
   ```

3. Encuentra la causa: repite la cuenta en `pagos` y en `catalogo`. Rellena la sección "Avería 1" de `starter/diagnostico.md`: síntoma, servicio origen, evidencia (los comandos y su salida) y porcentaje aproximado de pedidos afectados.

4. Repara y activa la segunda avería:
   ```bash
   ./reparar.sh && ./romper.sh 2
   ```
   Espera un minuto y repite los pasos 2 y 3. Esta vez busca también líneas `ERROR` en `pedidos`.

5. Compara las dos versiones de la historia: ¿cuántos `POST /charges` respondió `pagos` con 201? ¿Cuántos pedidos marcó `pedidos` como 402? Explica la diferencia en la sección "Avería 2". Pista: [0-assets/04-cobros-fantasma.svg](../../0-assets/04-cobros-fantasma.svg), pero léela solo después de intentarlo.

6. Repara:
   ```bash
   ./reparar.sh
   ```

7. Responde la sección "Lo que me faltó" de `starter/diagnostico.md`: qué dato concreto te habría ahorrado tiempo en cada avería.

## Criterios de éxito

- [ ] Avería 1: identificas el servicio origen y el código de error con un comando reproducible
- [ ] Avería 2: explicas por qué `pagos` registra cobros aprobados en pedidos que fallaron
- [ ] "Lo que me faltó" nombra al menos tres datos que los logs actuales no tienen
- [ ] Después de `./reparar.sh`, `./app/scripts/smoke-test.sh` vuelve a pasar

## Reto extra

En la avería 2, ¿qué consecuencia tiene para el negocio? Busca en PostgreSQL cuántos pedidos `payment_failed` hubo durante la avería y piensa cuántos clientes pagaron sin recibir su pedido.

---

[← Lab 02](../lab-02-carga-con-k6/README.md) · [Lab 04 →](../lab-04-inventario-de-senales/README.md)
