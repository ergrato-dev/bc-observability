# Bootcamp Observabilidad — Zero to Advanced

22 semanas · 10 h/semana · 220 horas. Autoestudio asincrónico, 100% práctico, con una sola app — `tienda` — que observas un poco más cada semana.

La columna **Estado** dice la verdad sobre el repositorio: ✅ la semana está publicada al estándar de [`CLAUDE.md`](../CLAUDE.md), ⬜ todavía no se escribió. Las semanas sin publicar no llevan enlace. El contenido se escribe en orden.

---

## Índice de Semanas

### Fase 1 — Fundamentos: logs y métricas (S01-04, 40 h)

| Semana | Tema | Estado |
|:--:|---|:--:|
| [01](week-01-que_es_observabilidad/README.md) | Qué es observabilidad: señales, RED, USE y golden signals | ✅ |
| [02](week-02-logs_estructurados/README.md) | Logs estructurados con structlog y pino | ✅ |
| [03](week-03-metricas_y_prometheus/README.md) | Métricas e instrumentación con Prometheus | ✅ |
| [04](week-04-promql_fundamentos/README.md) | PromQL: fundamentos | ✅ |

### Fase 2 — Visualización, alertas y logs centralizados (S05-08, 40 h)

| Semana | Tema | Estado |
|:--:|---|:--:|
| 05 | PromQL avanzado y recording rules | ⬜ |
| 06 | Grafana y dashboards como código | ⬜ |
| 07 | Alertas y Alertmanager | ⬜ |
| 08 | Logs centralizados con Loki y patrones de logs | ⬜ |

### Fase 3 — Trazas y OpenTelemetry (S09-13, 50 h)

| Semana | Tema | Estado |
|:--:|---|:--:|
| 09 | Trazas distribuidas e instrumentación manual con Jaeger | ⬜ |
| 10 | OpenTelemetry: auto-instrumentación y propagación | ⬜ |
| 11 | OpenTelemetry Collector | ⬜ |
| 12 | Tempo y correlación de señales | ⬜ |
| 13 | Muestreo, cardinalidad y coste | ⬜ |

### Fase 4 — Señales avanzadas y fiabilidad (S14-16, 30 h)

| Semana | Tema | Estado |
|:--:|---|:--:|
| 14 | Profiling continuo y eBPF | ⬜ |
| 15 | SLOs, error budgets y anomalías | ⬜ |
| 16 | Observabilidad de dependencias y frontend | ⬜ |

### Fase 5 — Plataforma en producción (S17-22, 60 h)

| Semana | Tema | Estado |
|:--:|---|:--:|
| 17 | Escala y alta disponibilidad con Thanos | ⬜ |
| 18 | Observabilidad en Kubernetes | ⬜ |
| 19 | Seguridad, gobernanza y meta-monitoreo | ⬜ |
| 20 | IA aplicada a la observabilidad | ⬜ |
| 21 | Respuesta a incidentes y troubleshooting | ⬜ |
| 22 | Proyecto integrador | ⬜ |

---

## Antes de empezar

1. [Preparar el entorno](../docs/setup-entorno.md) — Docker Engine con el plugin `docker compose`, jq, curl.
2. `./scripts/verificar-semana.sh --doctor` desde la raíz del repo.
3. [Cómo funciona el autograding](../docs/autograding.md).
4. [Perfiles de laboratorio y RAM](../docs/perfiles-de-laboratorio.md).
