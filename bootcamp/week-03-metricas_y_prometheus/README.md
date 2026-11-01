# Semana 03 — Métricas e instrumentación con Prometheus

## Descripción

Instrumentas los cuatro servicios de la tienda con métricas RED y de negocio, en Python y en Node.js, con los mismos nombres, labels y buckets. Prometheus las descubre solo en Docker y las guarda junto con las del host y las de cada contenedor. Al terminar, cuántas peticiones fallan y cuánto tardan dejan de ser una cuenta sobre los logs y pasan a ser una serie que se consulta en milisegundos.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Elegir entre counter, gauge, histogram y summary y nombrar cada métrica con su unidad y sus labels
- Instrumentar RED con un histograma en FastAPI con `prometheus-client` y en Express con `@prometheus-io/client`
- Configurar Prometheus con descubrimiento en Docker y reglas de relabeling que den a cada target un `job` y un `instance` estables
- Medir el host con node_exporter y cada contenedor con cAdvisor
- Detectar una explosión de cardinalidad con la API de Prometheus y frenarla en la configuración y en el código

## Prerrequisitos

- [Semana 02](../week-02-logs_estructurados/README.md) completada
- Perfil de laboratorio: `metrics` (`./scripts/lab-up.sh metrics`, ~0,6 GB de RAM)
- Esta semana la tienda se construye desde tu copia en `3-proyecto/starter/`: `export TIENDA=bootcamp/week-03-metricas_y_prometheus/3-proyecto/starter` antes de `./scripts/lab-up.sh metrics`. Los clientes de Prometheus ya están en los lockfiles: no necesitas uv ni pnpm en tu máquina.

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-metricas-y-tipos.md](1-teoria/01-metricas-y-tipos.md) | 25 min |
| — | Teoría | [02-prometheus-y-descubrimiento.md](1-teoria/02-prometheus-y-descubrimiento.md) | 20 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-primer-metrics](2-practicas/lab-01-primer-metrics/README.md) | 60 min |
| 2 | Lab | [lab-02-metricas-red](2-practicas/lab-02-metricas-red/README.md) | 60 min |
| 3 | Lab | [lab-03-metricas-en-node](2-practicas/lab-03-metricas-en-node/README.md) | 60 min |
| 4 | Lab | [lab-04-service-discovery-de-docker](2-practicas/lab-04-service-discovery-de-docker/README.md) | 60 min |
| 5 | Lab | [lab-05-exporters-de-host-y-contenedores](2-practicas/lab-05-exporters-de-host-y-contenedores/README.md) | 60 min |
| 6 | Lab | [lab-06-explosion-de-cardinalidad](2-practicas/lab-06-explosion-de-cardinalidad/README.md) | 60 min |
| — | Proyecto | [Capa 03 de la tienda: métricas RED y Prometheus](3-proyecto/README.md) | 3 h |

**Total: 10 horas**

Diagramas de apoyo en [0-assets/](0-assets/01-un-histograma-por-dentro.svg); recursos en [4-recursos/](4-recursos/webgrafia/README.md); términos en [5-glosario/](5-glosario/README.md).

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — /metrics en catalogo y el contador de la caché
[60 min] lab-02 — Histograma RED en los servicios Python y métricas de pedidos
[60 min] lab-03 — notificaciones con los mismos nombres, labels y buckets
[60 min] lab-04 — Prometheus descubre los targets en Docker
[60 min] lab-05 — USE del host y memoria de cada contenedor
[60 min] lab-06 — Provocar, detectar y frenar una explosión de cardinalidad
[3 h]    Proyecto: métricas RED en los cuatro servicios y todos los targets en UP
```

## Verificación de completitud

Desde la raíz del repositorio (el autograding reconstruye la tienda desde `3-proyecto/starter/` con el perfil `metrics`):

```bash
./scripts/verificar-semana.sh 03
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Semana 02 — Logs estructurados](../week-02-logs_estructurados/README.md) | **Semana 03 — Métricas y Prometheus** | [Semana 04 — PromQL: fundamentos](../week-04-promql_fundamentos/README.md) |

[← Volver al índice del bootcamp](../README.md)
