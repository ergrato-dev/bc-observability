# Lab 02 — Middleware con contexto

⏱ Duración estimada: ~60 min

## Objetivo

Registrar cada petición HTTP de `catalogo` como una línea `http_request` con su duración, y enlazar todas las líneas de una petición con un `request_id`.

## Contexto

- El log de acceso de uvicorn es una frase: no tiene la duración y no se puede filtrar por código de estado sin expresiones regulares. Lo sustituyes por uno propio.
- `structlog.contextvars` guarda campos que se añaden solos a todas las líneas que se escriben mientras dura la petición. Funciona con `async` porque cada petición tiene su propio contexto.
- `route` es la plantilla de la ruta (`/products/{product_id}`) y `path` la ruta concreta (`/products/42`). Para agrupar se usa `route`: tiene pocos valores distintos.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada como en el lab 01.

1. Intenta contar las respuestas 404 de `catalogo` con lo que hay ahora:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -r '.event' | grep -c '" 404'
   ```
   Funciona de casualidad, con una expresión regular sobre una frase. No hay forma de saber cuánto tardó ninguna petición.

2. Abre `starter/log_requests.py` y sigue sus instrucciones para pegarlo en `$TIENDA/catalogo/app/logging_config.py` y registrarlo en `main.py`. Completa el TODO del paso 2. Desactiva el log de acceso de uvicorn, que ya sobra, al final de `configure_logging`:
   ```python
   logging.getLogger("uvicorn.access").disabled = True
   ```
   Reconstruye con `./scripts/lab-up.sh` y comprueba:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix --tail 5 catalogo | jq -c 'select(.event == "http_request")'
   ```

3. El healthcheck de Docker llama a `/health` cada 10 segundos: es ruido. Completa el TODO del paso 3, reconstruye y espera medio minuto:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -s 'map(select(.path == "/health")) | length'
   ```
   Tiene que salir `0`.

4. Completa los TODO del paso 4 y añade `structlog.contextvars.merge_contextvars` al principio de la lista `shared`. Reconstruye y comprueba que el identificador que mandas vuelve en la respuesta y aparece en los logs:
   ```bash
   curl -si -H 'X-Request-ID: lab02-1' 'http://127.0.0.1:18001/products?q=cafe' | grep -i x-request-id
   docker compose -f app/compose.yaml logs --no-log-prefix catalogo | jq -c 'select(.request_id == "lab02-1")'
   ```
   Debes ver **dos** líneas: `product_search` y `http_request`. Las dos llevan el mismo `request_id` sin que lo pasaras a mano a `product_search`.

5. Investiga. Las cinco peticiones más lentas de `catalogo` en los últimos 5 minutos:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix --since 5m catalogo \
     | jq -s -c 'map(select(.event == "http_request")) | sort_by(-.duration_ms) | .[:5][] | {duration_ms, route, request_id}'
   ```
   ¿Qué ruta concentra las peticiones lentas? Toma el `request_id` de la más lenta y mira todas sus líneas: si fue una búsqueda, ¿cuántos productos dice `scanned` que revisó para devolver unos pocos resultados?

6. Compara la duración media de `/products` con y sin búsqueda:
   ```bash
   docker compose -f app/compose.yaml logs --no-log-prefix --since 5m catalogo | jq -s '
     (map(select(.event == "product_search") | .request_id)) as $busquedas
     | map(select(.event == "http_request" and .route == "/products"))
     | group_by(.request_id | IN($busquedas[]))
     | map({busqueda: (.[0].request_id | IN($busquedas[])), peticiones: length, media_ms: (map(.duration_ms) | add / length)})'
   ```
   Acabas de unir dos tipos de evento por `request_id`. Sin ese campo, esta pregunta no tendría respuesta. Apunta las dos medias: el listado y la búsqueda tienen cada uno un coste escondido que estudiarás en las semanas 14 y 16. Los logs te dicen **cuánto** tarda cada petición, pero no **en qué** se va el tiempo.

## Criterios de éxito

- [ ] Cada petición a `catalogo` produce una línea `http_request` con `method`, `path`, `route`, `status_code` y `duration_ms`
- [ ] Ninguna línea tiene `path` igual a `/health`
- [ ] `curl -si -H 'X-Request-ID: x' http://127.0.0.1:18001/products/1` devuelve la cabecera `x-request-id: x`
- [ ] Explicas, con los datos de los pasos 5 y 6, qué ruta de `catalogo` es la más lenta y cuánto tarda la búsqueda frente al listado

## Reto extra

Haz que un endpoint falle con una excepción no controlada (por ejemplo, para Valkey con `docker compose -f app/compose.yaml stop valkey` y pide `/products/1`). ¿Se registra la petición con `status_code` 500? Si no, mira cómo lo resuelve `solucion/log_requests.py` con `finally`.

---

[← Lab 01](../lab-01-logs-json-con-structlog/README.md) · [Lab 03 →](../lab-03-pino-en-notificaciones/README.md)
