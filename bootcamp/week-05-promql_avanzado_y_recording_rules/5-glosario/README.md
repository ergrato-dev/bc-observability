# Glosario — Semana 05

[A](#a) · [C](#c) · [E](#e) · [G](#g) · [M](#m) · [N](#n) · [O](#o) · [P](#p) · [R](#r) · [S](#s) · [T](#t)

## A

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| `absent` | Función que devuelve 1 cuando un selector no encuentra ninguna serie | `absent(up{job="pagos"})` |

## C

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Convención `level:metric:operations` | Forma de nombrar una recording rule: labels que conserva, métrica de origen y operaciones aplicadas | `job:http_server_requests:rate5m` |

## E

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Evaluation interval | Cada cuánto evalúa Prometheus sus reglas | `evaluation_interval: 15s` |

## G

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| `group_left` | Modificador que permite emparejar varias series del lado izquierdo con una del derecho, y copiar labels de este | `up * on(job, instance) group_left(version) python_info` |

## M

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Métrica *info* | Serie con valor 1 cuyos labels describen algo (versión, plataforma) para unirlos a otras métricas | `python_info{version="3.14.10"}` |
| Modificador `@` | Fija la evaluación de un selector en un instante absoluto | `rate(x[5m] @ end())` |

## N

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Native histogram | Histograma guardado como una sola serie con buckets exponenciales dentro de cada muestra | `histogram_quantile(0.9, sum(rate(prometheus_http_request_duration_seconds[5m])))` |

## O

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| `offset` | Desplaza un selector hacia atrás respecto al instante de evaluación | `rate(x[5m] offset 1h)` |

## P

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| `predict_linear` | Valor estimado de un gauge dentro de N segundos, siguiendo la recta de su ventana | `predict_linear(node_filesystem_avail_bytes[1h], 4 * 3600) < 0` |

## R

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Recording rule | Consulta que Prometheus evalúa periódicamente y guarda como una serie nueva | `record: job:orders_created:rate5m` |

## S

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Subconsulta | Evalúa una consulta a intervalos dentro de una ventana y devuelve el resultado como range vector | `max_over_time(sum(rate(x[1m]))[30m:1m])` |

## T

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Test unitario de reglas | Archivo de `promtool` con series inventadas y resultados esperados para comprobar las reglas | `promtool test rules tests/tienda_test.yml` |
| TSDB status | Endpoint de la API con el recuento de series por métrica y por label | `/api/v1/status/tsdb` |

---

[← Webgrafía](../4-recursos/webgrafia/README.md) · [Semana 05 →](../README.md)
