# Lab 06 — Explosión de cardinalidad

⏱ Duración estimada: ~60 min

## Objetivo

Provocar una explosión de cardinalidad en `catalogo`, encontrar al culpable con la API de Prometheus y frenarla en la configuración y en el código.

## Contexto

- Cada combinación distinta de nombre y labels es una serie, y Prometheus guarda en memoria todas las series recientes (el *head*). Un label con un valor por usuario, por pedido o por URL crea series sin límite: la memoria de Prometheus crece hasta que el contenedor muere.
- El fallo no avisa: el código funciona, las consultas funcionan, y un día Prometheus tarda minutos en responder.
- Hay dos frenos: `sample_limit` en la configuración de scrape protege a Prometheus de un target que se desmadra; corregir el label en el código elimina la causa.

## Instrucciones

Desde la raíz del repositorio, con el perfil `metrics` levantado y la configuración del lab 04.

1. Copia `starter/detectar.sh` y `starter/explotar.sh` a tu carpeta de trabajo y apunta la línea base:
   ```bash
   ./detectar.sh
   ```
   Anota cuántas series tiene el head.

2. Introduce el error. En `$TIENDA/catalogo/app/metrics.py`, cambia el label `route` para que use la URL:
   ```python
   route = request.url.path
   ```
   Reconstruye y pide 3000 fichas distintas:
   ```bash
   ./scripts/lab-up.sh metrics
   ./explotar.sh 3000
   curl -s 127.0.0.1:18001/metrics | grep -c '^http_server_request_duration_seconds'
   ```
   Más de 50 000 líneas en un `/metrics` que tenía unas 70.

3. Espera un scrape (15 s) y vuelve a ejecutar `./detectar.sh`. El head ha pasado de unas 6000 series a casi 60 000. Mira también la memoria de Prometheus en `docker stats --no-stream tienda-prometheus-1`.

4. Encuentra al culpable sin mirar el código: completa los TODO del paso 4 de `detectar.sh` con `scrape_samples_scraped` y con la API `/api/v1/status/tsdb`, que lista las métricas con más series y los labels con más valores. Las tres respuestas señalan lo mismo: qué job, qué métrica y qué label.

5. Pon el freno de emergencia: añade `sample_limit: 10000` al job `docker` de `$TIENDA/prometheus/prometheus.yml`, valida y recarga (lab 04, paso 3). Comprueba:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.labels.job == "catalogo") | "\(.health) \(.lastError)"'
   ```
   `catalogo` sale `down` con `sample limit exceeded`: Prometheus ya no guarda sus series nuevas, pero tampoco las buenas. El freno protege al resto de la plataforma a costa de dejar ciego ese servicio. Por eso el límite es alto (10 000) y deja margen a cAdvisor, que es el target más grande.

6. Corrige la causa: vuelve a la ruta (`request.scope.get("route")`, lab 02, paso 3) y reconstruye. Tras un scrape, comprueba:
   ```bash
   ./scripts/lab-up.sh metrics
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=count({job=~"catalogo|pedidos|pagos|notificaciones"})' | jq -r '.data.result[0].value[1]'
   ./detectar.sh
   ```
   Los cuatro servicios vuelven a sumar unos pocos cientos de series y `catalogo` está en `up`. El head, en cambio, sigue alto: las series antiguas ya no reciben muestras, pero no salen de memoria hasta la siguiente compactación (cada dos horas). Lo mismo le pasa a `/api/v1/status/tsdb`: cuenta lo que hay en el head, no lo que sigue vivo. La explosión se paga aunque dure un minuto.

## Criterios de éxito

- [ ] `detectar.sh` señala el job, la métrica y el label culpables
- [ ] Con `sample_limit`, `catalogo` sale `down` con `sample limit exceeded`
- [ ] Tras la corrección, los cuatro servicios suman menos de 1000 series y `catalogo` vuelve a `up`

## Reto extra

`metric_relabel_configs` se aplica a cada muestra después del scrape y antes de guardarla. Escribe una regla que descarte solo `http_server_request_duration_seconds_bucket` de `catalogo` y conserve `_count` y `_sum`. ¿Qué pierdes y qué conservas? ¿Por qué no sirve una regla `labeldrop` que quite el label `route`?

---

[← Lab 05](../lab-05-exporters-de-host-y-contenedores/README.md) · [Proyecto →](../../3-proyecto/README.md)
