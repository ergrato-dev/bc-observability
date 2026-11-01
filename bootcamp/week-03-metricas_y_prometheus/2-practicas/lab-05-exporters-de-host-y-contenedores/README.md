# Lab 05 — Exporters de host y contenedores

⏱ Duración estimada: ~60 min

## Objetivo

Aplicar el método USE al host con node_exporter y medir la memoria de cada contenedor de la tienda con cAdvisor, sin tocar el código de ningún servicio.

## Contexto

- Un exporter traduce a métricas de Prometheus algo que no las expone por sí mismo: el kernel de Linux (node_exporter) o los cgroups de los contenedores (cAdvisor). En el perfil `metrics` los dos ya corren y llevan las etiquetas `prometheus.io/*`: tu configuración del lab 04 los scrapea sin cambios.
- En WSL2 o en Colima, el "host" que ve node_exporter es la máquina virtual Linux donde corre Docker, no tu Windows o tu macOS.
- USE es para recursos: utilización, saturación y errores. RED, para servicios. La semana 01 los aplicó en papel; hoy salen de una consulta.

## Instrucciones

Desde la raíz del repositorio, con el perfil `metrics` levantado y la configuración del lab 04.

1. Mira qué expone cada exporter y cuánto:
   ```bash
   curl -s 127.0.0.1:9100/metrics | grep '^# HELP node_memory_MemAvailable_bytes'
   curl -s 127.0.0.1:9100/metrics | grep -vc '^#'
   curl -s 127.0.0.1:8080/metrics | grep -vc '^#'
   ```
   Abre también `http://127.0.0.1:8080` en el navegador: es la interfaz propia de cAdvisor.

2. Copia `starter/use.sh` a tu carpeta de trabajo, hazlo ejecutable y ejecútalo: la primera consulta ya funciona. Completa el TODO del paso 2. Si `node_memory_MemAvailable_bytes` no sale, revisa que `node-exporter` esté en `up` en el lab 04.

3. Completa los TODO del paso 3. La carga media cuenta los procesos que quieren CPU: por encima del número de CPU, hay cola, y eso es saturación. En otra terminal, desde la raíz del repositorio, genera carga durante dos minutos:
   ```bash
   docker compose -f app/compose.yaml run --rm -e RATE=50 -e DURATION=2m trafico
   ```
   Mientras corre, ejecuta `./use.sh` cada 20 segundos y mira cómo sube la carga.
   La utilización de CPU es un contador de segundos (`node_cpu_seconds_total`): convertirla en un porcentaje necesita `rate()`, de la semana 04.

4. Completa el TODO del paso 4 y compara con lo que dice Docker:
   ```bash
   ./use.sh | tail -16
   docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}'
   ```
   cAdvisor ve todos los contenedores de la máquina, también los de otros proyectos tuyos: filtra por `container_label_com_docker_compose_project="tienda"`. Esa etiqueta y la del servicio llegan como labels porque `app/compose.yaml` las añade a la lista de `--whitelisted_container_labels` de cAdvisor.

5. Recrea un servicio y cuenta sus series de memoria:
   ```bash
   docker compose -f app/compose.yaml up -d --force-recreate --no-deps pagos
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=container_memory_working_set_bytes{container_label_com_docker_compose_service="pagos"}' \
     | jq -r '.data.result[] | .metric.id'
   ```
   Durante un rato salen dos: cAdvisor identifica cada contenedor por su `id`, y un contenedor recreado es otro. Por eso las consultas agregan por servicio (`sum by`) y no por contenedor. Es *churn*: series que nacen y mueren y que Prometheus guarda igual.

6. Cuenta cuántas series aporta cada target:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=sort_desc(scrape_samples_scraped)' \
     | jq -r '.data.result[] | "\(.metric.job)\t\(.value[1])"'
   ```
   Compara los exporters con los servicios de la tienda. Esas series cuestan memoria en Prometheus: el lab 06 va de eso.

## Criterios de éxito

- [ ] `./use.sh` muestra la memoria disponible, las CPU, la carga y los errores de red del host
- [ ] `./use.sh` muestra la memoria de los cuatro servicios de la tienda sumada por servicio, sin contenedores de otros proyectos
- [ ] Sabes qué target aporta más series y por qué

## Reto extra

node_exporter mide el host y cAdvisor los contenedores, pero ninguno sabe si RabbitMQ acumula mensajes. La imagen de RabbitMQ de la tienda ya trae activo su plugin `rabbitmq_prometheus`, que expone métricas en el puerto 15692 ([documentación](https://www.rabbitmq.com/docs/prometheus)). ¿Qué tendrías que añadir para que tu Prometheus lo scrapee sin tocar `prometheus.yml`? En la semana 16 observarás así las dependencias de la tienda.

---

[← Lab 04](../lab-04-service-discovery-de-docker/README.md) · [Lab 06 →](../lab-06-explosion-de-cardinalidad/README.md)
