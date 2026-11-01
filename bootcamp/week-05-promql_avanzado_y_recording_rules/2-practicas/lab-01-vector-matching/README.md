# Lab 01 — Vector matching: on, ignoring y group_left

⏱ Duración estimada: ~60 min

## Objetivo

Combinar series con labels distintos usando `on`, `ignoring`, `group_left` y `group_right`, y enriquecer una métrica con los labels de otra.

## Contexto

- En la semana 04 dividías dos lados con **exactamente** los mismos labels. Cuando no los tienen, `on (labels)` dice con cuáles emparejar e `ignoring (labels)`, cuáles no mirar.
- Si a un lado le corresponden varias series del otro (muchos a uno), hay que decirlo con `group_left` (el lado izquierdo es el "muchos") o `group_right`. Sin eso, Prometheus da error en lugar de adivinar.
- `group_left (labels)` además copia esos labels del lado "uno" al resultado. Es la forma de añadir a una métrica la versión, el equipo o el nodo que vienen en una métrica *info*.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada:

```bash
export TIENDA=bootcamp/week-05-promql_avanzado_y_recording_rules/3-proyecto/starter
./scripts/lab-up.sh metrics
```

Copia `starter/consultas.md` y apunta en él cada consulta.

1. Qué parte del tráfico de cada servicio se lleva cada ruta. Arriba, una serie por `job` y `route`; abajo, una por `job`:
   ```bash
   ./scripts/promql.sh 'sum by (job, route) (rate(http_server_request_duration_seconds_count[5m])) / ignoring(route) sum by (job) (rate(http_server_request_duration_seconds_count[5m]))'
   ```
   `ERROR: multiple matches for labels: many-to-one matching must be explicit (group_left/group_right)`. Cada `job` de la derecha casa con varias rutas de la izquierda. Añade `group_left` después de `ignoring(route)` y repite: la suma por `job` de los resultados es 1.

2. Lo mismo con `on`: en lugar de decir qué label ignorar, di con cuál emparejar (`on(job)`). Comprueba que el resultado es idéntico. ¿Cuándo preferirías cada uno? Piensa en qué pasa si mañana el lado izquierdo gana un label nuevo.

3. Fracción de errores por código. Escribe una serie por `job` y `status_code` (solo 5xx) dividida entre el total de su `job`. Provoca errores para tener algo que ver:
   ```bash
   curl -s -X PUT 127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.3,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}'
   ```
   Espera dos minutos, ejecuta tu consulta y deja `error_rate` otra vez en 0.02.

4. Métricas *info*. Los clientes de Prometheus exponen una serie con valor 1 cuyos labels describen el proceso:
   ```bash
   ./scripts/promql.sh 'python_info'
   ./scripts/promql.sh 'nodejs_version_info'
   ```
   Añade la versión de Python a `up` de los servicios Python:
   ```bash
   ./scripts/promql.sh 'up * on(job, instance) group_left(version) python_info'
   ```
   Multiplicar por 1 no cambia el valor; `group_left(version)` copia el label. Escribe la misma consulta para `notificaciones` con `nodejs_version_info`.

5. Un lado sin labels. Fracción de la memoria del host que usa cada servicio de la tienda: a la izquierda, una serie por servicio (consulta 15 de la semana 04); a la derecha, `node_memory_MemTotal_bytes`, con labels `instance` y `job` que no tienen nada que ver. `on()` empareja por ningún label: todas con la única de la derecha.
   ```bash
   ./scripts/promql.sh 'sum by (container_label_com_docker_compose_service) (container_memory_working_set_bytes{container_label_com_docker_compose_project="tienda"}) / on() group_left node_memory_MemTotal_bytes'
   ```

6. `group_right` es el espejo: el lado "muchos" es el derecho. Reescribe la consulta del paso 5 con `node_memory_MemTotal_bytes` a la izquierda (necesitarás invertir la división: usa `node_memory_MemTotal_bytes / on() group_right (...)` y explica qué calcula ahora).

## Criterios de éxito

- [ ] Sabes por qué el paso 1 da error sin `group_left` y qué significa "muchos a uno"
- [ ] Las consultas de los pasos 3 y 4 devuelven los labels pedidos
- [ ] Sabes explicar la diferencia entre `on(job)` e `ignoring(route)` cuando aparece un label nuevo

## Reto extra

`up` de los servicios con la versión, para los cuatro servicios en una sola consulta. Pista: `or` une dos vectores; une `python_info` y `nodejs_version_info` antes de emparejar. Node escribe la versión con una `v` delante: quítasela con `label_replace`.

---

[← Prácticas](../README.md) · [Lab 02 →](../lab-02-subconsultas-offset-y-arroba/README.md)
