# Lab 01 — Logs JSON con structlog

⏱ Duración estimada: ~60 min

## Objetivo

Convertir todos los logs de `catalogo`, los suyos y los de uvicorn, en líneas JSON con el esquema común de la tienda usando structlog.

## Contexto

- Esta semana trabajas sobre tu propia copia de la tienda, en `3-proyecto/starter/`. Ya trae `structlog` y `pino` en sus `uv.lock` y `pnpm-lock.yaml`, así que no necesitas uv ni pnpm en tu máquina.
- `./scripts/lab-up.sh` construye la tienda desde la carpeta de la variable `TIENDA`. Sin ella construye `app/`, la tienda sin instrumentar. Expórtala en cada terminal que abras.
- Un log que `jq` no puede leer no es un log estructurado, aunque lo parezca.

## Instrucciones

1. Desde la raíz del repositorio, levanta tu tienda y comprueba el punto de partida:
   ```bash
   export TIENDA=bootcamp/week-02-logs_estructurados/3-proyecto/starter
   ./scripts/lab-up.sh
   docker compose -f app/compose.yaml logs --no-log-prefix --tail 3 catalogo | jq .
   ```
   Debes ver `parse error`: son líneas de texto de uvicorn.

2. Copia el módulo de logging en `catalogo` y llámalo al arrancar:
   ```bash
   cp bootcamp/week-02-logs_estructurados/2-practicas/lab-01-logs-json-con-structlog/starter/logging_config.py "$TIENDA/catalogo/app/"
   ```
   En `$TIENDA/catalogo/app/main.py`, justo después de los imports:
   ```python
   import structlog

   from app.logging_config import configure_logging

   configure_logging("catalogo")
   log = structlog.get_logger()
   ```

3. Completa los TODO del paso 3 de `logging_config.py`: el campo `service`, el `timestamp` ISO 8601 en UTC con la clave `timestamp` y el `JSONRenderer` como último procesador. Esos cuatro campos (`timestamp`, `level`, `service`, `event`) son el esquema común de la tienda.

4. Completa el TODO del paso 5: uvicorn configuró sus propios loggers antes de importar tu código. Si no los rediriges, sus líneas siguen saliendo en texto plano.

5. Reconstruye y comprueba que **todas** las líneas son JSON:
   ```bash
   ./scripts/lab-up.sh
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -e . >/dev/null && echo "todo JSON"
   ```
   Mira una línea de acceso: `docker compose -f app/compose.yaml logs --no-log-prefix --tail 1 catalogo | jq .`. Es JSON, pero el método, la ruta y el código de estado siguen metidos en una frase dentro de `event`. Lo arreglas en el lab 02.

6. Escribe tu primer evento propio. En `list_products`, después de ordenar los resultados de la búsqueda:
   ```python
   log.info("product_search", query_length=len(q), scanned=len(scored), results=len(products))
   ```
   Reconstruye, busca y filtra:
   ```bash
   curl -s 'http://127.0.0.1:18001/products?q=cafe' >/dev/null
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -c 'select(.event == "product_search")'
   ```
   El `event` es un nombre fijo y los datos van en campos aparte: así se puede agrupar y contar.

7. Niveles. En `get_product` añade `log.debug("product_cache", product_id=product_id, hit=True)` cuando la caché acierta, y `hit=False` cuando falla. Reconstruye con `LOG_LEVEL=DEBUG ./scripts/lab-up.sh` y cuenta aciertos y fallos:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -r 'select(.event == "product_cache") | .hit' | sort | uniq -c
   ```
   Vuelve a `./scripts/lab-up.sh` (nivel INFO): las líneas `debug` desaparecen sin tocar el código.

## Criterios de éxito

- [ ] `docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -e . >/dev/null` sale con 0
- [ ] Cada línea de `catalogo` tiene `timestamp`, `level`, `service` y `event`, y `service` vale `catalogo`
- [ ] Una búsqueda con `?q=` produce una línea `product_search` con `scanned` y `results`
- [ ] Con `LOG_LEVEL=DEBUG` ves `product_cache`; con el nivel por defecto, no

## Reto extra

Provoca un error de verdad: para PostgreSQL (`docker compose -f app/compose.yaml stop postgres`) y pide `GET /products`. ¿La traza de la excepción sale como JSON? Busca en la línea el campo `exception` y explica qué procesador lo produce. Arranca PostgreSQL al terminar.

---

[← Prácticas](../README.md) · [Lab 02 →](../lab-02-middleware-con-contexto/README.md)
