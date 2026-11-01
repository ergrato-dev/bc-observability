# Semana 05 — PromQL avanzado y recording rules

## Descripción

Cruzas métricas con labels distintos, mueves las consultas en el tiempo y detectas las series que faltan o el recurso que se va a agotar. Después conviertes las consultas que más se van a repetir en recording rules con tests unitarios de `promtool`, la base sobre la que se construyen los dashboards, las alertas y los SLO de las próximas semanas. Por el camino comparas los native histograms con los clásicos y mides la cardinalidad de Prometheus con su API.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Emparejar series con `on`, `ignoring`, `group_left` y `group_right`, y enriquecer métricas con métricas *info*
- Comparar con el pasado con `offset` y `@`, y resumir resultados de consultas con subconsultas
- Detectar series ausentes con `absent` y anticipar el agotamiento de un recurso con `predict_linear`
- Ingerir native histograms y medir la cardinalidad con `/api/v1/status/tsdb`
- Escribir recording rules con la convención `level:metric:operations` y medir cuánto ahorran
- Probar las reglas con `promtool test rules` y demostrar que los tests detectan reglas rotas

## Prerrequisitos

- [Semana 04](../week-04-promql_fundamentos/README.md) completada
- Perfil de laboratorio: `metrics` (`./scripts/lab-up.sh metrics`, ~0,7 GB de RAM)
- Esta semana la tienda se construye desde tu copia en `3-proyecto/starter/`, la solución de la semana 04: `export TIENDA=bootcamp/week-05-promql_avanzado_y_recording_rules/3-proyecto/starter` antes de `./scripts/lab-up.sh metrics`. El lab 03 escribe 1,5 GB en un volumen de Docker durante 5 minutos y lo borra al terminar.

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-vector-matching-y-el-tiempo.md](1-teoria/01-vector-matching-y-el-tiempo.md) | 20 min |
| — | Teoría | [02-recording-rules-y-tests.md](1-teoria/02-recording-rules-y-tests.md) | 25 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-vector-matching](2-practicas/lab-01-vector-matching/README.md) | 60 min |
| 2 | Lab | [lab-02-subconsultas-offset-y-arroba](2-practicas/lab-02-subconsultas-offset-y-arroba/README.md) | 60 min |
| 3 | Lab | [lab-03-absent-y-predict-linear](2-practicas/lab-03-absent-y-predict-linear/README.md) | 60 min |
| 4 | Lab | [lab-04-native-histograms-y-tsdb](2-practicas/lab-04-native-histograms-y-tsdb/README.md) | 60 min |
| 5 | Lab | [lab-05-recording-rules](2-practicas/lab-05-recording-rules/README.md) | 60 min |
| 6 | Lab | [lab-06-tests-con-promtool](2-practicas/lab-06-tests-con-promtool/README.md) | 60 min |
| — | Proyecto | [Capa 05 de la tienda: recording rules con tests](3-proyecto/README.md) | 3 h |

**Total: 10 horas**

Diagramas de apoyo en [0-assets/](0-assets/01-group-left-muchos-a-uno.svg); recursos en [4-recursos/](4-recursos/webgrafia/README.md); términos en [5-glosario/](5-glosario/README.md).

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — on, ignoring, group_left y métricas info
[60 min] lab-02 — Subconsultas, offset y @
[60 min] lab-03 — Series ausentes y un disco que se llena
[60 min] lab-04 — Native histograms y estado de la TSDB
[60 min] lab-05 — Recording rules RED y de negocio
[60 min] lab-06 — Tests unitarios con promtool
[3 h]    Proyecto: las 8 reglas con tests que detectan reglas rotas
```

## Verificación de completitud

Desde la raíz del repositorio (el autograding reconstruye la tienda desde `3-proyecto/starter/` con el perfil `metrics`, recarga Prometheus y ejecuta tus tests contra versiones rotas de tus reglas):

```bash
./scripts/verificar-semana.sh 05
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Semana 04 — PromQL: fundamentos](../week-04-promql_fundamentos/README.md) | **Semana 05 — PromQL avanzado y recording rules** | Semana 06 — Grafana y dashboards como código (próximamente) |

[← Volver al índice del bootcamp](../README.md)
