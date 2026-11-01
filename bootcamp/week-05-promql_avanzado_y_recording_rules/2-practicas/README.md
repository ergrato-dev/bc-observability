# Prácticas — Semana 05

Seis labs de unos 60 minutos. Los cuatro primeros amplían PromQL; los dos últimos construyen el entregable de la semana en tu copia de la tienda: las recording rules y sus tests. Antes de empezar, desde la raíz del repositorio:

```bash
export TIENDA=bootcamp/week-05-promql_avanzado_y_recording_rules/3-proyecto/starter
./scripts/lab-up.sh metrics
```

Cada vez que cambies `prometheus.yml` o un archivo de `rules/`, valida con `promtool` y recarga con `curl -s -X POST 127.0.0.1:9090/-/reload` (lab 05, paso 3).

| # | Lab | Qué haces | Duración |
|---|---|---|:--:|
| 01 | [Vector matching](lab-01-vector-matching/README.md) | `on`, `ignoring`, `group_left` y métricas *info* | 60 min |
| 02 | [Subconsultas, offset y @](lab-02-subconsultas-offset-y-arroba/README.md) | Mover consultas en el tiempo y resumir el resultado de otra consulta | 60 min |
| 03 | [absent y predict_linear](lab-03-absent-y-predict-linear/README.md) | Series que faltan y un disco que se llena | 60 min |
| 04 | [Native histograms y TSDB](lab-04-native-histograms-y-tsdb/README.md) | Precisión y coste de los native histograms; cardinalidad con la API | 60 min |
| 05 | [Recording rules](lab-05-recording-rules/README.md) | RED y negocio precalculados con `level:metric:operations` | 60 min |
| 06 | [Tests con promtool](lab-06-tests-con-promtool/README.md) | Tests unitarios que detectan reglas rotas | 60 min |

---

[← Recording rules y tests](../1-teoria/02-recording-rules-y-tests.md) · [Lab 01 →](lab-01-vector-matching/README.md)
