# 🗺️ Temario detallado

Qué enseña cada semana, sus labs y la capa que su proyecto añade a la `tienda`. La tabla resumida vive en [`CLAUDE.md`](../CLAUDE.md), [`README.md`](../README.md), [`README_EN.md`](../README_EN.md) y [`bootcamp/README.md`](../bootcamp/README.md).

Este temario es el diseño aprobado. Al escribir cada semana, sus labs pueden ajustarse; si cambian, se actualiza aquí en la misma tanda.

## Fases

| Fase | Semanas | Horas | Al terminar el alumno… |
|---|:--:|:--:|---|
| 1 — Fundamentos: logs y métricas | 01-04 | 40 | instrumenta logs y métricas y responde preguntas con PromQL |
| 2 — Visualización, alertas y logs centralizados | 05-08 | 40 | tiene dashboards como código, alertas probadas y logs en Loki |
| 3 — Trazas y OpenTelemetry | 09-13 | 50 | traza la tienda de punta a punta, opera un Collector y controla el coste |
| 4 — Señales avanzadas y fiabilidad | 14-16 | 30 | usa perfiles, SLOs con burn rate y observa dependencias y frontend |
| 5 — Plataforma en producción | 17-22 | 60 | escala, lleva a Kubernetes, asegura el stack, aplica IA a la telemetría, resuelve incidentes y entrega el capstone |

## Contenido semana a semana

### Fase 1 — Fundamentos

**S01 `week-01-que_es_observabilidad`** — Monitoreo vs observabilidad, unknown-unknowns, las señales (logs, métricas, trazas, perfiles), RED, USE, 4 golden signals, cardinalidad (intro).
Labs: levantar la tienda + `--doctor` · generar carga con k6 · depurar un fallo solo con `docker compose logs` (sufrirlo a propósito) · inventario de qué señales existen hoy · aplicar RED/USE a la tienda en papel · diseñar el plan de instrumentación.
Proyecto: *Mapa de observabilidad* — diagrama de servicios, preguntas que hay que poder responder y SLIs candidatos.

**S02 `week-02-logs_estructurados`** — Logs JSON, niveles, esquema común de campos, request ID, `structlog` en FastAPI, `pino`/`pino-http` en Node, logs de contenedor (stdout, driver, rotación), qué no loguear (PII, secretos).
Labs: logging plano a JSON · middleware structlog con contexto · pino en `notificaciones` · propagar `X-Request-ID` entre servicios · redacción de PII · consultar logs con `jq`.
Proyecto: los 4 servicios con logs JSON de esquema común y request ID de punta a punta.

**S03 `week-03-metricas_y_prometheus`** — Modelo de datos, pull vs push, counter/gauge/histogram/summary, naming y unidades, labels y cardinalidad, `prometheus-client` y `prom-client`, scrape config, relabeling, node_exporter, cAdvisor, cuándo (no) usar Pushgateway.
Labs: primer `/metrics` en FastAPI · métricas RED con histogramas · `prom-client` en Node · Prometheus con service discovery de Docker · exporters de host y contenedor · explosión de cardinalidad y cómo detectarla.
Proyecto: métricas RED en todos los servicios + Prometheus con todos los targets en `UP`.

**S04 `week-04-promql_fundamentos`** — Instant vs range vectors, selectores y matchers, `rate`/`irate`/`increase`, resets de counters, `sum by`/`without`, `topk`, `histogram_quantile`, API HTTP de Prometheus.
Labs: selectores · tasas · agregaciones · percentiles · errores frecuentes (rate de gauge, avg de percentiles) · consultas desde la API con `curl` + `jq`.
Proyecto: libreta de 20 consultas que responden las preguntas de la S01, verificadas por autograding contra la API.

### Fase 2 — Visualización, alertas y logs centralizados

**S05 `week-05-promql_avanzado_y_recording_rules`** — Vector matching (`on`, `ignoring`, `group_left`), subqueries, `offset`/`@`, `absent`, `predict_linear`, native histograms, recording rules (`level:metric:operations`), análisis de cardinalidad (TSDB status), `promtool`.
Proyecto: recording rules de la tienda con tests unitarios de `promtool`.

**S06 `week-06-grafana_y_dashboards_como_codigo`** — Datasources, paneles, variables, transformaciones, anotaciones, provisioning por archivos versionados en git, dashboards RED/USE, anti-patrones (muros de gráficas).
Proyecto: dashboards provisionados de la tienda (overview, por servicio, infraestructura), cero clics manuales.

**S07 `week-07-alertas_y_alertmanager`** — Alerting rules, `for`/`keep_firing_for`, labels y annotations, `runbook_url`, routing, `group_by`, inhibición, silencios, receptor webhook propio (FastAPI), blackbox_exporter para sondas sintéticas, `promtool test rules`, síntoma vs causa, fatiga de alertas.
Proyecto: alertas con runbooks, enrutadas por severidad, probadas con promtool y con un fallo inyectado.

**S08 `week-08-logs_centralizados_con_loki`** — Arquitectura de Loki, labels de baja cardinalidad, structured metadata, Fluent Bit leyendo logs de Docker, LogQL (filtros, parsers, métricas desde logs), ruler, retención, detección de patrones de logs (Loki patterns y Drain3: agrupar millones de líneas en plantillas).
Proyecto: logs de la tienda en Loki, dashboard de errores y alerta LogQL.

### Fase 3 — Trazas y OpenTelemetry

**S09 `week-09-trazas_distribuidas_y_jaeger`** — Trace, span, contexto, W3C Trace Context, atributos, eventos, status, instrumentación manual con el SDK OTel de Python, OTLP hacia Jaeger v2, waterfall y camino crítico.
Proyecto: flujo "crear pedido" trazado a mano `catalogo → pedidos → pagos`.

**S10 `week-10-opentelemetry_autoinstrumentacion`** — Auto-instrumentación Python (FastAPI, psycopg, httpx, aio-pika) y Node (`--import` de auto-instrumentations-node), manual + auto, propagación por RabbitMQ (parent vs links), baggage, resource attributes, semantic conventions, métricas y logs vía SDK OTel.
Proyecto: tienda entera trazada, incluida la ruta asíncrona hasta `notificaciones`.

**S11 `week-11-opentelemetry_collector`** — Receivers, processors, exporters, connectors, extensions; pipelines por señal; `memory_limiter`, `batch`, `resource`, `transform` con OTTL; `filelog` receiver; agent vs gateway; zpages y health; core vs contrib; distribución propia con `ocb`.
Proyecto: un Collector gateway que recibe todo por OTLP y reparte a Prometheus, Loki y Jaeger, con redacción de PII.

**S12 `week-12-tempo_y_correlacion_de_senales`** — Tempo y TraceQL, exemplars (métrica → traza), `trace_id` en logs (log ↔ traza), conectores `spanmetrics` y `servicegraph`, drilldown en Grafana.
Proyecto: de un pico de latencia a la traza y a sus logs en tres clics.

**S13 `week-13-muestreo_cardinalidad_y_coste`** — Head sampling (`parentbased_traceidratio`), tail sampling en el Collector, `loadbalancing` exporter, control de cardinalidad (relabel/drop, límites), volumen de logs, retención por señal, presupuesto de telemetría.
Proyecto: recortar ≥70% del volumen conservando el 100% de las trazas con error, con medición antes/después.

### Fase 4 — Señales avanzadas y fiabilidad

**S14 `week-14-profiling_continuo_y_ebpf`** — Perfiles de CPU y memoria, flamegraphs, Pyroscope (SDK Python y Node), span profiles (traza → perfil), OBI: auto-instrumentación eBPF sin tocar código.
Proyecto: encontrar y corregir un hot path inyectado en `catalogo` con evidencia de perfiles antes/después.

**S15 `week-15-slos_y_error_budgets`** — SLI, SLO, SLA, ventanas, error budget, alertas multi-ventana/multi-burn-rate, Sloth y especificación OpenSLO, dashboard de presupuesto, política de error budget, detección de anomalías con PromQL (z-score con `stddev_over_time`, bandas adaptativas) frente a umbrales fijos.
Proyecto: SLOs de disponibilidad y latencia del checkout con alertas de burn rate probadas con promtool y con fallo inyectado.

**S16 `week-16-observabilidad_de_dependencias_y_frontend`** — postgres_exporter y `pg_stat_statements`, N+1 visto en trazas, métricas de RabbitMQ y Valkey, RUM con OTel JS en `web` (Web Vitals, propagación navegador → backend, CORS de `traceparent`).
Proyecto: detectar un N+1 y una cola saturada; vista de punta a punta desde el navegador.

### Fase 5 — Plataforma en producción

**S17 `week-17-escala_y_alta_disponibilidad`** — Límites de un Prometheus, `remote_write`, Thanos (sidecar, query, store, compactor, downsampling), pares HA y deduplicación, Alertmanager en clúster, modos de despliegue de Loki/Tempo, por qué evitar la federación.
Proyecto: dos Prometheus HA + Thanos con vista global y retención larga.

**S18 `week-18-observabilidad_en_kubernetes`** — kind, kube-prometheus-stack con Helm, ServiceMonitor/PodMonitor/PrometheusRule, kube-state-metrics, kubelet/cAdvisor, OpenTelemetry Operator (`Instrumentation` CR), Collector DaemonSet + `k8sattributes`, logs de pods a Loki.
Proyecto: la tienda en kind con la misma observabilidad que en Compose, declarada con CRDs.

**S19 `week-19-seguridad_gobernanza_y_metamonitoreo`** — TLS/mTLS SDK → Collector → backends, extensiones de autenticación, multi-tenancy (`X-Scope-OrgID`), RBAC y carpetas en Grafana, PII y retención, meta-monitoreo del stack (Watchdog / dead man's switch), gobierno de convenciones (semantic conventions, OTel Weaver).
Proyecto: stack endurecido + alerta Watchdog funcionando.

**S20 `week-20-ia_aplicada_a_la_observabilidad`** — Dos caras. (a) Observar apps con LLM: OTel GenAI semantic conventions (modelo, tokens, latencia, coste), OpenLLMetry, Langfuse para prompts y evaluaciones, instrumentar `asistente`. (b) IA para analizar telemetría: servicio FastAPI de anomalías sobre la API de Prometheus (statsmodels/scikit-learn), mcp-grafana como puente LLM ↔ Prometheus/Loki/Tempo, HolmesGPT investigando alertas de Alertmanager, K8sGPT en kind. Límites: alucinaciones (toda conclusión se verifica con la consulta real), PII, coste y latencia; la IA es copiloto, no autopiloto.
Labs: trazas GenAI de `asistente` · métricas de tokens y coste en Grafana · Langfuse con evaluación de respuestas · detector de anomalías vs umbral fijo · agente con mcp-grafana respondiendo preguntas de la S01 · HolmesGPT sobre una alerta real y contraste con la investigación manual.
Proyecto: `asistente` observado de punta a punta + informe donde el agente propone causas de 3 alertas y cada hipótesis queda confirmada o refutada con consultas.

**S21 `week-21-respuesta_a_incidentes_y_troubleshooting`** — Flujo de investigación (alerta → dashboard → traza → log → perfil), caos con toxiproxy, game day, roles de incidente, postmortem sin culpables, tests de instrumentación (`InMemorySpanExporter`), observability-driven development.
Proyecto: game day con 5 incidentes inyectados, resueltos y con postmortem; el agente de IA se usa como copiloto y su acierto se registra en el postmortem.

**S22 `week-22-proyecto_integrador`** — Capstone: plataforma de observabilidad completa desde cero para un servicio nuevo (Compose o kind): señales, Collector, dashboards como código, alertas, SLOs, muestreo y runbooks; defensa escrita. Los labs se sustituyen por hitos.

---

[← Volver al índice de documentación](README.md)
