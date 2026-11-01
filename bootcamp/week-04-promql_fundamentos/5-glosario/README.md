# Glosario — Semana 04

[A](#a) · [E](#e) · [I](#i) · [L](#l) · [M](#m) · [P](#p) · [R](#r) · [S](#s)

## A

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Agregación | Operador que combina varias series en una por grupo de labels | `sum by (job) (...)` |

## E

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Emparejamiento de vectores | Regla con la que un operador binario une las series de sus dos lados: por defecto, las de labels idénticos | `sum by (job) (a) / sum by (job) (b)` |
| Extrapolación | Ajuste con el que `rate` e `increase` estiman la tasa hasta los bordes de la ventana, por eso `increase` rara vez da un entero | `increase(orders_created_total[1h])` → `461.34` |

## I

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| `increase` | Aumento total de un counter en la ventana, corrigiendo los reinicios | `increase(payment_failures_total[1h])` |
| Instant vector | Resultado con una muestra por serie, la última antes del instante de evaluación | `up` |
| Interpolación | Estimación de `histogram_quantile` dentro de un bucket, suponiendo las observaciones repartidas de forma uniforme | p95 de 0,22 s con el real en 0,116 s |

## L

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Lookback | Antigüedad máxima (5 min) de la muestra que un instant vector acepta como valor actual | Una serie sin muestras en 5 min no sale en `up` |

## M

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Marca de obsolescencia | Muestra especial que Prometheus escribe cuando un target desaparece, para que su serie deje de salir al momento | *staleness marker* tras `docker compose stop pagos` |
| Matcher | Condición sobre un label dentro de un selector: `=`, `!=`, `=~` o `!~` | `route=~"/products/.+"` |

## P

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Percentil | Valor por debajo del cual queda una fracción de las observaciones | p95 del checkout: el 95 % tarda menos |
| PromQL | Lenguaje de consulta de Prometheus, evaluado en un instante o en un rango de tiempo | `sum(rate(orders_created_total[5m]))` |

## R

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Range vector | Resultado con todas las muestras de cada serie dentro de una ventana | `up[5m]` |
| `rate` | Aumento por segundo de un counter, promediado en la ventana y corrigiendo los reinicios | `rate(orders_created_total[5m])` |
| Reinicio de contador | Vuelta a 0 de un counter cuando su proceso arranca de nuevo; `rate` lo detecta porque el valor baja | `resets(process_cpu_seconds_total[1h])` |

## S

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Selector | Nombre de métrica y matchers que eligen las series de una consulta | `up{job="pagos"}` |

---

[← Webgrafía](../4-recursos/webgrafia/README.md) · [Semana 04 →](../README.md)
