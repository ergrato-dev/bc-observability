# Versiones del stack

Última revisión: 2026-10-31. Regla: versión completa fijada, nunca `latest`.

Una versión entra en la tabla de **Fijadas** solo cuando la semana que la usa se escribe, y entra verificada: el tag existe, no tiene avisos de seguridad sin parchear, es compatible con el resto del stack, y se anotan la fecha y la fuente. Hasta entonces la pieza está en **Pendientes**, sin número: es preferible no tener versión a tener una inventada.

## Fijadas

Verificadas el 2026-10-31 contra Docker Hub, ghcr.io, PyPI, el registro de npm y las releases de GitHub, salvo donde se indica.

| Pieza | Versión | Semana | Notas |
|---|---|:--:|---|
| Python | `python:3.14.10-slim-trixie` | 01 | 3.15 salió el 2026-10-09; se adopta cuando lo soporten las librerías de OpenTelemetry |
| uv | 0.13.6 (`ghcr.io/astral-sh/uv:0.13.6`) | 01 | Release del 2026-10-27. Desde 0.13 la Python por defecto es la 3.15: los proyectos fijan `requires-python = ">=3.14,<3.15"` |
| ruff | 0.17.3 | 01 | Lint y formato, grupo `dev` de cada servicio |
| FastAPI / uvicorn | 0.162.0 / 0.54.0 | 01 | Fijadas en cada `uv.lock` |
| psycopg / psycopg-pool | 3.3.6 / 3.3.3 | 01 | Cliente de PostgreSQL, modo async |
| redis (cliente Python) | 8.1.0 | 01 | Contra el servidor Valkey: habla el mismo protocolo y, a diferencia de `valkey-py`, tiene instrumentación de OpenTelemetry |
| httpx / aio-pika | 0.28.1 / 10.2.1 | 01 | Dentro del rango que soporta la instrumentación de OpenTelemetry (aio-pika < 11) |
| Node.js | `node:26.13.0-trixie-slim` | 01 | Active LTS desde 2026-10-28. **No trae corepack** |
| pnpm | 12.16.1 | 01 | Release del 2026-10-27, binario nativo. En Docker se descarga de la release de GitHub verificando su sha256 |
| Express / amqplib | 5.3.0 / 2.2.0 | 01 | amqplib dentro del rango de `@opentelemetry/instrumentation-amqplib` (< 3) |
| PostgreSQL | `postgres:18.6-alpine` | 01 | Volumen en `/var/lib/postgresql` (cambio de la imagen 18) |
| Valkey | `valkey/valkey:9.1.3-alpine` | 01 | |
| RabbitMQ | `rabbitmq:4.3.7-management-alpine` | 01 | 4.4.0 salió el 2026-10-28; se espera a su primer parche |
| k6 | `grafana/k6:1.8.2` | 01 | |
| toxiproxy | `ghcr.io/shopify/toxiproxy:2.13.0` | 01 | Release del 2026-10-14 |
| Docker Engine | 29 o superior (probado con 29.9.2) | 01 | Con cgroup v2. Las de abajo, heredadas de `bc-kubernetes` (2026-10-30) |
| Docker Compose | plugin `docker compose`, probado con 5.6.1 | 01 | Comprobado en el equipo de autoría el 2026-10-31. v1 (`docker-compose`) está en EOL desde 2023 |
| kind | v0.33.0 | 18 | Imagen de nodo por defecto `kindest/node:v1.37.0` |
| kubectl | v1.37.2 | 18 | Dentro del sesgo ±1 minor con el clúster |
| jq | 1.6 o superior | 01 | Lo necesita `verificar-semana.sh` |

## Pendientes: se fijan al escribir su semana

| Pieza | Semana | Imagen o paquete |
|---|:--:|---|
| structlog | 02 | PyPI |
| pino, pino-http | 02 | npm registry, instalado con pnpm |
| Prometheus y promtool | 03 | `prom/prometheus` |
| prometheus-client | 03 | PyPI |
| prom-client | 03 | npm registry, instalado con pnpm |
| node_exporter | 03 | `prom/node-exporter` |
| cAdvisor | 03 | `gcr.io/cadvisor/cadvisor` |
| Grafana OSS | 06 | `grafana/grafana` (nunca la edición Enterprise) |
| Alertmanager | 07 | `prom/alertmanager` |
| blackbox_exporter | 07 | `prom/blackbox-exporter` |
| Loki | 08 | `grafana/loki` |
| Fluent Bit | 08 | `fluent/fluent-bit` |
| Drain3 | 08 | PyPI |
| OpenTelemetry SDK Python y contrib | 09-10 | PyPI (`opentelemetry-*`) |
| Jaeger v2 | 09 | `jaegertracing/jaeger` |
| OpenTelemetry SDK Node.js | 10 | npm registry (`@opentelemetry/*`), instalado con pnpm |
| OpenTelemetry Collector contrib | 11 | `otel/opentelemetry-collector-contrib` |
| ocb (builder) | 11 | Releases de opentelemetry-collector |
| Tempo | 12 | `grafana/tempo` |
| Pyroscope | 14 | `grafana/pyroscope` |
| OBI (OpenTelemetry eBPF Instrumentation) | 14 | Releases de opentelemetry-ebpf-instrumentation |
| Sloth | 15 | `ghcr.io/slok/sloth` |
| postgres_exporter | 16 | `quay.io/prometheuscommunity/postgres-exporter` |
| OpenTelemetry JS web | 16 | npm registry, instalado con pnpm |
| Thanos | 17 | `quay.io/thanos/thanos` |
| Helm | 18 | Releases de helm |
| kube-prometheus-stack | 18 | Chart de prometheus-community |
| OpenTelemetry Operator | 18 | Chart de open-telemetry |
| Ollama | 20 | `ollama/ollama` + modelo open-weight pequeño |
| OpenLLMetry | 20 | PyPI (`opentelemetry-instrumentation-*` de traceloop) |
| Langfuse | 20 | `langfuse/langfuse` (solo funcionalidades MIT) |
| mcp-grafana | 20 | Releases de grafana/mcp-grafana |
| HolmesGPT | 20 | Releases de HolmesGPT (CNCF sandbox) |
| K8sGPT | 20 | Releases de k8sgpt (CNCF sandbox) |
| statsmodels, scikit-learn | 20 | PyPI |

## Excluidas

| Pieza | Por qué |
|---|---|
| Promtail | EOL; su sustituto es Grafana Alloy o el Collector |
| Jaeger v1, OpenTracing, OpenCensus | Reemplazados por Jaeger v2 y OpenTelemetry |
| Arize Phoenix | Licencia ELv2, no aprobada por OSI |
| MinIO | En modo mantenimiento; el almacenamiento de objetos del laboratorio usa el backend `filesystem` de cada proyecto |
| Imágenes Bitnami | Catálogo gratuito congelado |

---

[← Volver al índice de documentación](README.md)
