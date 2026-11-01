# 🧪 Perfiles de laboratorio

Todo el laboratorio corre en Docker Compose desde `app/compose.yaml`, salvo la Semana 18, que usa kind. Cada señal nueva suma contenedores y RAM. Si la memoria se acaba, Docker mata procesos (OOM) y la práctica falla por razones que no tienen nada que ver con lo que estás aprendiendo. Por eso el `compose.yaml` va por **perfiles** y cada semana declara cuál usa.

```bash
./scripts/lab-up.sh <perfil>      # levanta el perfil (y los que incluye)
./scripts/lab-down.sh             # para todo, conserva los volúmenes
```

| Perfil | Qué levanta | Incluye | Semanas | RAM aprox. |
|---|---|---|:--:|:--:|
| `core` | tienda (4 servicios), PostgreSQL, Valkey, RabbitMQ, k6, toxiproxy | — | 01-02 | ~0,5 GB (medido el 2026-10-31) |
| `metrics` | Prometheus, node_exporter, cAdvisor; Grafana (06) y Alertmanager (07) | `core` | 03-07 | ~0,6 GB en la semana 03 y ~0,7 GB en la 05, con las recording rules y una hora de datos (medido el 2026-11-01) |
| `logs` | Loki, Fluent Bit | `metrics` | 08 | ~4 GB |
| `traces` | Jaeger, Collector, Tempo | `logs` | 09-13 | ~5-6 GB |
| `profiles` | Pyroscope, OBI | `traces` | 14-16 | ~6-7 GB |
| `scale` | Segundo Prometheus, Thanos | `metrics` | 17 | ~5 GB |
| `ai` | Ollama, asistente, Langfuse | `traces` | 20 | ~8-9 GB |

La Semana 18 no usa Compose: `./scripts/lab-down.sh` primero y después el clúster kind de la semana (~6-7 GB con kube-prometheus-stack, Loki y el Collector).

> [!IMPORTANT]
> Salvo `core`, las cifras son estimaciones del diseño. Cada una se reemplaza por la medida real al escribir su semana. Hasta entonces, el `compose.yaml` solo tiene los servicios de `core`: los demás perfiles se añaden en la semana que los usa.

Mínimo para seguir el bootcamp completo: **8 GB asignados a Docker/WSL2, libres**; **12 GB** para las semanas 18 y 20 sin apagar nada más. En WSL2 la memoria se asigna en `%UserProfile%\.wslconfig` (`[wsl2]` → `memory=12GB`).

Para medir el consumo real en cualquier momento:

```bash
docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}'
```

---

[← Volver al índice de documentación](README.md)
