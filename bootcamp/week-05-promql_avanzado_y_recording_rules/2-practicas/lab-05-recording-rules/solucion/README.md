# Solución del lab 05

Las reglas completas están en [`3-proyecto/solucion/prometheus/rules/tienda.yml`](../../../3-proyecto/solucion/prometheus/rules/tienda.yml) y la configuración en [`prometheus.yml`](../../../3-proyecto/solucion/prometheus/prometheus.yml).

## Paso 5

En el laboratorio, un panel de 1 h con un punto cada 15 s:

| Consulta | `totalQueryableSamples` |
|---|--:|
| `histogram_quantile(0.95, sum by (job, route, le) (rate(http_server_request_duration_seconds_bucket[5m])))` | ~500 000 |
| `job_route:http_server_request_duration_seconds:p95_rate5m` | ~500 |

Unas mil veces menos. Las cifras exactas dependen de cuántas rutas tengan tráfico y de cuánto tiempo lleve la regla evaluándose: antes de una hora, la regla tiene menos historia que leer.

## Reto extra

Sin `by (job)`, `job:http_server_requests:rate5m` es una sola serie sin labels. La regla de ratio divide un vector con `job` entre uno sin labels: no empareja y deja de producir series, sin error. Las alertas que dependan de ella se quedan mudas.

---

[← Lab 05](../README.md)
