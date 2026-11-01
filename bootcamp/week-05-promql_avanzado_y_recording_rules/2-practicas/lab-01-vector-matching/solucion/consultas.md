# Lab 01 — Vector matching

## Paso 1

- Fracción del tráfico de cada servicio que se lleva cada ruta: `sum by (job, route) (rate(http_server_request_duration_seconds_count[5m])) / ignoring(route) group_left sum by (job) (rate(http_server_request_duration_seconds_count[5m]))`
- Qué significa el error sin `group_left`: al ignorar `route`, cada serie de la derecha (una por `job`) casa con varias de la izquierda (una por ruta). Prometheus solo empareja uno a uno salvo que le digas qué lado es el "muchos".

## Paso 2

- La misma consulta con `on`: `sum by (job, route) (rate(http_server_request_duration_seconds_count[5m])) / on(job) group_left sum by (job) (rate(http_server_request_duration_seconds_count[5m]))`
- Cuándo prefieres `on` y cuándo `ignoring`: `on(job)` sigue funcionando si el lado izquierdo gana un label nuevo (por ejemplo `region`), porque solo mira `job`. `ignoring(route)` dejaría de emparejar: el label nuevo no está a la derecha. `ignoring` es más cómodo cuando solo sobra uno y quieres conservar el resto en el resultado.

## Paso 3

- Fracción de errores por `job` y `status_code`: `sum by (job, status_code) (rate(http_server_request_duration_seconds_count{status_code=~"5.."}[5m])) / ignoring(status_code) group_left sum by (job) (rate(http_server_request_duration_seconds_count[5m]))`

## Paso 4

- `up` de `notificaciones` con su versión de Node.js: `up * on(job, instance) group_left(version) nodejs_version_info`

## Paso 6

- `node_memory_MemTotal_bytes / on() group_right sum by (container_label_com_docker_compose_service) (container_memory_working_set_bytes{container_label_com_docker_compose_project="tienda"})`. Calcula la inversa: cuántas veces cabe la memoria de cada servicio en la del host. El resultado conserva los labels del lado "muchos", el derecho.

## Reto extra

`up * on(job, instance) group_left(version) (python_info or nodejs_version_info)`. Las dos métricas info tienen `job`, `instance` y `version`, así que `or` las une sin `label_replace`: el resultado tiene una serie por servicio. El `version` de Node empieza por `v` (`v26.13.0`); si quieres normalizarlo, `label_replace(nodejs_version_info, "version", "$1", "version", "v(.*)")`.
