# Lab 03 — Agregaciones y aritmética

## Paso 2

- Peticiones por segundo de cada servicio: `sum by (job) (rate(http_server_request_duration_seconds_count[5m]))`
- Notificaciones por segundo por resultado: `sum by (result) (rate(notifications_total[5m]))`
- Pedidos por segundo que fallan, por `status_code`: `sum by (status_code) (rate(http_server_request_duration_seconds_count{job="pedidos", method="POST", route="/orders", status_code!="201"}[5m]))`
- Por qué `notificaciones` no sale en la primera: su histograma solo mide su API HTTP (`/stats`), y nadie la llama; consumir mensajes de RabbitMQ no es una petición HTTP. Sin peticiones en la ventana no hay series que sumar.

## Paso 4

- Fracción de pedidos que falla: ` sum(rate(http_server_request_duration_seconds_count{job="pedidos", method="POST", route="/orders", status_code!="201"}[5m])) / sum(rate(http_server_request_duration_seconds_count{job="pedidos", method="POST", route="/orders"}[5m]))`
- Fracción de lecturas que sirve la caché: ` sum(rate(catalog_cache_requests_total{result="hit"}[5m])) / sum(rate(catalog_cache_requests_total[5m]))`
- Fracción de 5xx de cada servicio: ` sum by (job) (rate(http_server_request_duration_seconds_count{status_code=~"5.."}[5m])) / sum by (job) (rate(http_server_request_duration_seconds_count[5m]))`
- Por qué la división sin agregar el denominador sale vacía: el numerador tiene el label `job` y el denominador no tiene ninguno; la división solo empareja series con los mismos labels.

## Paso 5

- Memoria de cada servicio de la tienda: `sum by (container_label_com_docker_compose_service) ( container_memory_working_set_bytes{container_label_com_docker_compose_project="tienda"} )`
- CPU de cada servicio, en núcleos: `sum by (container_label_com_docker_compose_service) ( rate(container_cpu_usage_seconds_total{container_label_com_docker_compose_project="tienda"}[5m]) )`
- Fracción de la CPU del host ocupada: `1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))`
- Fracción de la memoria del host disponible: `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes`

## Paso 6

- Cobros fantasma por segundo: ` sum(rate(http_server_request_duration_seconds_count{job="pagos", route="/charges", status_code="201"}[5m])) - sum(rate(orders_created_total[5m]))`

## Reto extra

- Rutas distintas de cada servicio: `count by (job) (sum by (job, route) (http_server_request_duration_seconds_count))`
- Servicio que más memoria usa: `topk(1, sum by (container_label_com_docker_compose_service) ( container_memory_working_set_bytes{container_label_com_docker_compose_project="tienda"} ))`
