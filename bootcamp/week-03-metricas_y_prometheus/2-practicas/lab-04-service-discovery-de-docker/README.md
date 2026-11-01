# Lab 04 — Service discovery de Docker

⏱ Duración estimada: ~60 min

## Objetivo

Configurar Prometheus para que descubra solo, en Docker, los servicios de la tienda y los exporters, y guarde cada uno con un `job` y un `instance` legibles y estables.

## Contexto

- Prometheus lee (*pull*) cada target en su `/metrics`. Si un target no responde, la serie `up` de ese target vale 0: el modelo pull te da el estado de cada servicio sin escribir nada.
- Con `docker_sd_configs`, Prometheus pregunta a Docker qué contenedores hay y los convierte en targets con metadatos `__meta_docker_*`: nombre, IP, puertos y etiquetas del contenedor. Para eso lee el socket de Docker, montado en `app/compose.yaml`.
- `relabel_configs` decide, con esos metadatos, qué targets se scrapean y con qué labels. Los labels que empiezan por `__` se descartan al terminar.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada y el perfil `metrics` levantado.

1. Mira qué scrapea Prometheus ahora y qué contenedores se dejan scrapear:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/targets | jq -r '.data.activeTargets[] | "\(.labels.job) \(.health)"'
   grep -B2 -A2 'prometheus.io' app/compose.yaml | head -20
   ```
   Cada contenedor que quiere ser scrapeado lo declara con dos etiquetas: `prometheus.io/scrape: "true"` y `prometheus.io/port`. Es *opt-in*: PostgreSQL o RabbitMQ no las llevan y no se scrapean.

2. Lee en `app/compose.yaml` cómo se monta `/var/run/docker.sock` en `prometheus` y para qué sirve `group_add`. Quien puede leer ese socket puede controlar Docker entero. En tu laboratorio se acepta con la advertencia escrita al lado; en producción el descubrimiento se hace contra la API de Kubernetes (semana 18) o de la nube, con permisos de solo lectura.

3. Copia `starter/prometheus.yml` sobre `$TIENDA/prometheus/prometheus.yml` y completa el TODO del paso 3 con un `filters` de `docker_sd_configs` ([documentación](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#docker_sd_config)). Valida antes de recargar, siempre:
   ```bash
   docker compose -f app/compose.yaml exec prometheus promtool check config /etc/prometheus/prometheus.yml
   curl -s -X POST 127.0.0.1:9090/-/reload
   curl -s 127.0.0.1:9090/api/v1/targets | jq '.data.activeTargets | length'
   ```
   Salen muchos targets, casi todos `down`: uno por cada puerto expuesto de cada contenedor del proyecto, PostgreSQL y RabbitMQ incluidos. Mira los metadatos que tienes para filtrarlos:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/targets | jq '.data.activeTargets[0].discoveredLabels'
   ```

4. Completa el TODO del paso 4 con dos reglas de `relabel_configs`: `action: keep` sobre `__meta_docker_container_label_prometheus_io_scrape`, y `__address__` construido con `__meta_docker_network_ip` y `__meta_docker_container_label_prometheus_io_port` unidos por `:` (`separator`). Valida, recarga y comprueba:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/targets | jq -r '.data.activeTargets[] | "\(.labels.job) \(.labels.instance) \(.health)"'
   ```
   Tienen que salir siete targets en `up`: los cuatro servicios, `prometheus`, `node-exporter` y `cadvisor`. Todos con `job="docker"` y una IP como `instance`.

5. Una IP cambia cada vez que se recrea el contenedor, y `instance` forma parte de la identidad de cada serie: con la IP, cada `./scripts/lab-up.sh` crearía series nuevas. Completa el TODO del paso 5: `job` a partir de `__meta_docker_container_label_com_docker_compose_service` e `instance` a partir de `__meta_docker_container_name` sin la barra inicial (`regex: "/(.+)"`). Comprueba:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/targets | jq -r '.data.activeTargets[] | "\(.labels.job) \(.labels.instance) \(.health)"'
   ```
   Salida esperada: `catalogo tienda-catalogo-1 up` y así hasta siete líneas.

6. Pregunta a Prometheus por el histograma de los cuatro servicios:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=count by (job) (http_server_request_duration_seconds_count)' \
     | jq -r '.data.result[] | "\(.metric.job) \(.value[1])"'
   ```
   Abre también `http://127.0.0.1:9090/targets` en el navegador: es la misma información.

7. Para un servicio y mira qué ve Prometheus:
   ```bash
   docker compose -f app/compose.yaml stop pagos
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=up' | jq -r '.data.result[] | "\(.metric.job) \(.value[1])"'
   docker compose -f app/compose.yaml start pagos
   ```
   Repite la consulta durante medio minuto. `pagos` no sale con `up` igual a 0: desaparece. El descubrimiento solo ve contenedores en marcha, así que un contenedor parado deja de ser target y Prometheus marca sus series como obsoletas. Si `pagos` siguiera en marcha pero sin responder, `up` sí valdría 0. Apúntalo: en la semana 07 alertarás de las dos situaciones.

## Criterios de éxito

- [ ] `promtool check config` da por válida tu configuración
- [ ] Siete targets en `up`, cada uno con `job` igual a su servicio de Compose
- [ ] `instance` es el nombre del contenedor (`tienda-catalogo-1`), no una IP
- [ ] Prometheus tiene `http_server_request_duration_seconds_count` de los cuatro servicios

## Reto extra

Los labels que te interesan no tienen por qué ser solo `job` e `instance`. Añade un label `service_version` a todos los targets de la tienda a partir de la etiqueta `org.opencontainers.image.version` de la imagen (pista: añádela en el `Dockerfile` con `LABEL`). ¿Qué ventaja tiene sobre ponerla dentro de cada métrica desde el código?

---

[← Lab 03](../lab-03-metricas-en-node/README.md) · [Lab 05 →](../lab-05-exporters-de-host-y-contenedores/README.md)
