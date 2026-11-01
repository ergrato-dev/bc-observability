# Semana 04 — PromQL: fundamentos

## Descripción

Escribes las respuestas a las preguntas de la semana 01 en PromQL: cuántos pedidos entran y cuántos fallan, cuánto tarda un checkout, qué paso es el lento, cuánta CPU y memoria usa cada servicio. Aprendes a elegir series, convertir contadores en tasas, agregarlas y calcular percentiles, y a reconocer las consultas que devuelven un número falso sin dar error. Al terminar, la tienda tiene una libreta de 20 consultas que serán los paneles de la semana 06 y las alertas de la 07.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Distinguir instant vectors, range vectors y escalares, y elegir series con matchers y expresiones regulares
- Convertir counters en tasas e incrementos con `rate`, `irate` e `increase`, sin que los reinicios los falseen
- Agregar con `sum by` y `without` y calcular proporciones entre dos consultas con los mismos labels
- Calcular percentiles con `histogram_quantile` y estimar su error según los buckets
- Detectar los errores de PromQL que devuelven números falsos: `rate` de un gauge, `rate` después de `sum`, media de percentiles
- Consultar Prometheus desde scripts con su API HTTP, `curl` y `jq`

## Prerrequisitos

- [Semana 03](../week-03-metricas_y_prometheus/README.md) completada
- Perfil de laboratorio: `metrics` (`./scripts/lab-up.sh metrics`, ~0,6 GB de RAM)
- Esta semana la tienda se construye desde tu copia en `3-proyecto/starter/`, que es la solución de la semana 03 sin cambios de código: `export TIENDA=bootcamp/week-04-promql_fundamentos/3-proyecto/starter` antes de `./scripts/lab-up.sh metrics`. Déjala en marcha: las consultas de 1 hora necesitan una hora de datos.

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-vectores-y-tasas.md](1-teoria/01-vectores-y-tasas.md) | 25 min |
| — | Teoría | [02-agregaciones-y-percentiles.md](1-teoria/02-agregaciones-y-percentiles.md) | 20 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-selectores](2-practicas/lab-01-selectores/README.md) | 60 min |
| 2 | Lab | [lab-02-tasas](2-practicas/lab-02-tasas/README.md) | 60 min |
| 3 | Lab | [lab-03-agregaciones](2-practicas/lab-03-agregaciones/README.md) | 60 min |
| 4 | Lab | [lab-04-percentiles](2-practicas/lab-04-percentiles/README.md) | 60 min |
| 5 | Lab | [lab-05-errores-frecuentes](2-practicas/lab-05-errores-frecuentes/README.md) | 60 min |
| 6 | Lab | [lab-06-la-api-con-curl-y-jq](2-practicas/lab-06-la-api-con-curl-y-jq/README.md) | 60 min |
| — | Proyecto | [Capa 04 de la tienda: la libreta de PromQL](3-proyecto/README.md) | 3 h |

**Total: 10 horas**

Diagramas de apoyo en [0-assets/](0-assets/01-rate-a-traves-de-un-reinicio.svg); recursos en [4-recursos/](4-recursos/webgrafia/README.md); términos en [5-glosario/](5-glosario/README.md).

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Matchers, expresiones regulares y range vectors
[60 min] lab-02 — rate, irate, increase y reinicios
[60 min] lab-03 — sum by, proporciones y cobros fantasma
[60 min] lab-04 — Percentiles y su error
[60 min] lab-05 — Cinco consultas que mienten sin dar error
[60 min] lab-06 — La API desde bash: informe de la libreta
[3 h]    Proyecto: las 20 consultas de la libreta
```

## Verificación de completitud

Desde la raíz del repositorio (el autograding reconstruye la tienda desde `3-proyecto/starter/` con el perfil `metrics` y evalúa cada consulta de la libreta contra la API de Prometheus):

```bash
./scripts/verificar-semana.sh 04
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Semana 03 — Métricas y Prometheus](../week-03-metricas_y_prometheus/README.md) | **Semana 04 — PromQL: fundamentos** | Semana 05 — PromQL avanzado y recording rules (próximamente) |

[← Volver al índice del bootcamp](../README.md)
