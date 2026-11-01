# Glosario — Semana 03

[B](#b) · [C](#c) · [E](#e) · [G](#g) · [H](#h) · [L](#l) · [P](#p) · [R](#r) · [S](#s) · [T](#t)

## B

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Bucket | Contador de un histograma con las observaciones menores o iguales que su límite | `le="0.25"` |

## C

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Cardinalidad | Número de series distintas de una métrica: el producto de los valores de sus labels | 3 métodos × 10 rutas × 4 códigos × 17 = 2040 series |
| Counter | Métrica que solo sube y vuelve a 0 al reiniciar el proceso | `orders_created_total` |

## E

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Exporter | Proceso que traduce a métricas de Prometheus algo que no las expone por sí mismo | node_exporter, cAdvisor |

## G

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Gauge | Métrica que sube y baja | `http_server_active_requests` |

## H

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Histogram | Métrica que cuenta observaciones en buckets, con su suma y su número | `http_server_request_duration_seconds` |

## L

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Label | Par clave-valor que distingue las series de una misma métrica | `status_code="503"` |

## P

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Pull | Modelo en el que Prometheus va a buscar las métricas a cada target | Un scrape cada 15 s a `/metrics` |
| Pushgateway | Intermediario donde un job por lotes deja sus métricas para que Prometheus las lea | Un backup nocturno que dura 20 s |

## R

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Relabeling | Reglas que eligen targets y reescriben sus labels antes del scrape | `action: keep` sobre `prometheus.io/scrape` |

## S

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| sample_limit | Máximo de muestras por scrape; si se supera, el scrape entero falla | `sample_limit: 10000` |
| Scrape | Lectura del `/metrics` de un target por Prometheus | `GET http://catalogo:8000/metrics` |
| Serie | Nombre de métrica más un conjunto de labels, con sus muestras en el tiempo | `up{job="pagos", instance="tienda-pagos-1"}` |
| Service discovery | Mecanismo con el que Prometheus obtiene la lista de targets de otro sistema | `docker_sd_configs` |

## T

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Target | Dirección que Prometheus scrapea, con sus labels `job` e `instance` | `tienda-catalogo-1` |

---

[← Webgrafía](../4-recursos/webgrafia/README.md) · [Semana 03 →](../README.md)
