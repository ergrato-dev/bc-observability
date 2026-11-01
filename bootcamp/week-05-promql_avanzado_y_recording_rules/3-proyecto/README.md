# Proyecto — Capa 05 de la tienda: recording rules con tests

⏱ 3 h

## Contexto

La libreta de la semana 04 responde las preguntas de la tienda, pero cada panel y cada alerta que la use recalculará la consulta entera sobre los datos en crudo, cada pocos segundos. Esta semana precalculas lo que se va a consultar sin parar: RED por servicio, percentiles por ruta y las métricas de negocio. Las semanas 06 (dashboards), 07 (alertas) y 15 (SLO) se construyen sobre estas reglas, así que llevan tests: si alguien las rompe, falla un test y no una alerta en producción.

## Punto de partida

```
starter/                     la solución de la semana 04
├── Dockerfile.python
├── catalogo/ pedidos/ pagos/ notificaciones/
├── libreta/                 las 20 consultas de la semana 04
└── prometheus/
    ├── prometheus.yml       sin rule_files: lo añades en el lab 05
    ├── rules/
    │   └── tienda.yml       nuevo: una regla a medias
    └── tests/
        └── tienda_test.yml  nuevo: sin tests
```

Se arranca con:

```bash
export TIENDA=bootcamp/week-05-promql_avanzado_y_recording_rules/3-proyecto/starter
./scripts/lab-up.sh metrics
```

## Entregables

1. **Las 8 recording rules**, con estos nombres exactos, en dos grupos:

   | Grupo | Regla | Contenido |
   |---|---|---|
   | `tienda_red` | `job:http_server_requests:rate5m` | Peticiones por segundo |
   | `tienda_red` | `job:http_server_requests_errors:rate5m` | Peticiones 5xx por segundo |
   | `tienda_red` | `job:http_server_requests_errors:ratio_rate5m` | Fracción de 5xx, calculada con las dos anteriores |
   | `tienda_red` | `job_route_le:http_server_request_duration_seconds_bucket:rate5m` | Tasa de cada bucket |
   | `tienda_red` | `job_route:http_server_request_duration_seconds:p95_rate5m` | p95 por ruta, calculado sobre la anterior |
   | `tienda_negocio` | `job:orders_created:rate5m` | Pedidos creados por segundo |
   | `tienda_negocio` | `job_reason:payment_failures:rate5m` | Cobros fallidos por segundo y motivo |
   | `tienda_negocio` | `job:catalog_cache_hits:ratio_rate5m` | Fracción de lecturas que sirve la caché |

   Todas con ventana de 5 minutos y los labels que dice su *level*.
2. **`prometheus.yml`** carga `rules/*.yml`, evalúa cada 15 s e ingiere native histograms conservando los clásicos.
3. **Tests unitarios** en `tests/` que cubren las 8 reglas y detectan dos errores concretos: contar los 4xx como errores y no corregir el reinicio de un contador.

## ✅ Requisitos verificables

- La tienda de la entrega arranca con el perfil metrics, Prometheus carga su configuración y registra tráfico, también cobros fallidos (el autograding los provoca durante 30 s)
- promtool da por válidas la configuración de Prometheus y sus recording rules
- Prometheus ha cargado al menos 8 recording rules y todas se evalúan sin error
- Todas las recording rules siguen la convención level:metric:operations
- job:http_server_requests:rate5m se evalúa en Prometheus con los labels job
- job:http_server_requests_errors:rate5m se evalúa en Prometheus con los labels job
- job:http_server_requests_errors:ratio_rate5m se evalúa en Prometheus con los labels job
- job_route_le:http_server_request_duration_seconds_bucket:rate5m se evalúa en Prometheus con los labels job,le,route
- job_route:http_server_request_duration_seconds:p95_rate5m se evalúa en Prometheus con los labels job,route
- job:orders_created:rate5m se evalúa en Prometheus con los labels job
- job_reason:payment_failures:rate5m se evalúa en Prometheus con los labels job,reason
- job:catalog_cache_hits:ratio_rate5m se evalúa en Prometheus con los labels job
- job:http_server_requests:rate5m da lo mismo (±10 %) que la consulta en crudo que sustituye
- El percentil 95 se calcula sobre la recording rule de los buckets, no sobre los datos en crudo
- Los tests unitarios de tests/ pasan con promtool test rules
- Cada recording rule de rules/ aparece en algún test de tests/
- Los tests fallan si la regla de errores cuenta también los 4xx
- Los tests fallan si job:orders_created:rate5m usa deriv en lugar de rate: cubren un reinicio de pedidos
- Prometheus ingiere como native histogram su propio prometheus_http_request_duration_seconds

Las dos comprobaciones «Los tests fallan si…» rompen tus reglas en una copia temporal (`5..` pasa a `[45]..`, y `rate(orders_created_total` pasa a `deriv(orders_created_total`) y exigen que tus tests fallen. Escribe la regla de errores con `status_code=~"5.."`.

Compruébalos desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 05
```

## Criterios de calidad (revisión manual)

| Criterio | Puntos |
|---|:--:|
| Ninguna regla repite una consulta en crudo que ya calcula otra regla (el ratio usa las de tasa; el p95, la de buckets) | 10 |
| `rules/tienda.yml` está comentado: se entiende qué guarda cada regla y quién la va a usar | 10 |
| Cada valor esperado de los tests lleva al lado cómo se ha calculado | 10 |
| Los tests prueban también lo que **no** debe salir (una ruta sin errores no tiene ratio) | 10 |

---

[← Lab 06](../2-practicas/lab-06-tests-con-promtool/README.md) · [Rúbrica →](../rubrica-evaluacion.md)
