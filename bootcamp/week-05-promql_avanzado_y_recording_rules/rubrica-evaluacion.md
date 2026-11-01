# Rúbrica de evaluación — Semana 05

> PromQL avanzado y recording rules. Se aprueba con un **mínimo del 70 % en cada evidencia**, no en el promedio.

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | 10 preguntas conceptuales, respuestas en `<details>` |
| 💪 Desempeño | 40% | Labs 01 a 06 y sus criterios de éxito |
| 📦 Producto | 30% | 60 pts de autograding + 40 pts de calidad manual |

## 🧠 Conocimiento (30%)

Responde por escrito antes de abrir cada respuesta. Cada pregunta vale 3 puntos: 1 por la idea correcta y 2 por el razonamiento.

**1.** ¿Por qué Prometheus da error en `a / ignoring(route) b` cuando `a` tiene una serie por ruta y `b` una por `job`, en lugar de dividir sin más?

<details>
<summary>Respuesta</summary>

Porque cada serie de `b` casa con varias de `a`: es un emparejamiento muchos a uno, y Prometheus no adivina qué lado es el "muchos" ni qué labels debe tener el resultado. `group_left` lo dice explícitamente: el izquierdo es el "muchos" y el resultado conserva sus labels.

</details>

**2.** ¿Qué ventaja tiene `on(job)` sobre `ignoring(route)` si mañana alguien añade el label `region` al lado izquierdo?

<details>
<summary>Respuesta</summary>

`on(job)` solo mira `job`, así que sigue emparejando igual. `ignoring(route)` compara todos los labels menos `route`, incluido el nuevo `region`, que no existe en el lado derecho: el emparejamiento deja de encontrar parejas y la consulta sale vacía, sin error.

</details>

**3.** ¿Para qué sirve `up * on(job, instance) group_left(version) python_info` si multiplicar por 1 no cambia el valor?

<details>
<summary>Respuesta</summary>

Para copiar el label `version` de la métrica *info* a `up`. El valor es lo de menos; lo que se gana es poder filtrar o agrupar por versión: qué versión corre en el servicio que falla, o si los errores empezaron con un despliegue.

</details>

**4.** ¿Qué diferencia hay entre `rate(x[5m] offset 1h)`, `rate(x[5m] @ 1793500000)` y pasar `time=` a la API?

<details>
<summary>Respuesta</summary>

`offset` desplaza el selector una hora atrás respecto al instante de evaluación: en una gráfica, la curva se desplaza. `@` lo fija en un instante absoluto: en una gráfica, una línea plana. `time` cambia el instante de evaluación de toda la consulta, no de un selector.

</details>

**5.** ¿Por qué una alerta "errores > 0" no detecta que `pagos` ha dejado de exponer métricas, y cómo lo cubrirías?

<details>
<summary>Respuesta</summary>

Si `pagos` no expone nada, la serie de errores no existe y la comparación no devuelve ninguna serie: la alerta no tiene nada sobre lo que saltar. `absent(up{job="pagos"})` o `absent_over_time(...)` devuelven 1 precisamente cuando falta la serie.

</details>

**6.** ¿Por qué "el disco se llena en menos de 4 horas" con `predict_linear` es mejor alerta que "el disco está al 90 %"?

<details>
<summary>Respuesta</summary>

Porque dice cuánto tiempo queda para actuar. Un disco de 2 TB al 90 % puede tardar meses en llenarse; uno al 60 % que se llena a 1 GB/s se llena en minutos. `predict_linear` combina el espacio libre con la velocidad a la que baja. Su punto débil es la ventana: corta, salta con cada escritura puntual; larga, reacciona tarde.

</details>

**7.** El histograma clásico de Prometheus da un p90 de 0,09 s para sus consultas y el nativo, unos milisegundos. ¿Cuál es correcto y por qué?

<details>
<summary>Respuesta</summary>

El nativo. El primer bucket clásico va de 0 a 0,1 s, todas las consultas caen en él, y `histogram_quantile` las supone repartidas de forma uniforme: el p90 sale en el 90 % de 0,1. El nativo tiene buckets exponenciales muy estrechos en esa zona, así que su estimación está cerca del valor real.

</details>

**8.** ¿Por qué la regla del p95 se calcula sobre `job_route_le:…_bucket:rate5m` y no sobre los datos en crudo?

<details>
<summary>Respuesta</summary>

Porque la tasa de los buckets ya está agregada y guardada: calcular el percentil sobre ella es barato. Además, cualquier otro percentil (p50, p99) o cualquier fracción por debajo de un umbral sale de la misma regla sin volver a leer los datos en crudo. Guardar solo el p95 obligaría a repetir la agregación para cada percentil nuevo.

</details>

**9.** Una recording rule se llama `job:http_server_requests:rate5m` pero su consulta es `sum(rate(...[5m]))`, sin `by (job)`. ¿Qué se rompe y por qué no da error?

<details>
<summary>Respuesta</summary>

El nombre promete una serie por `job` y la regla guarda una sola serie sin labels. Las reglas y alertas que la usen esperando `job` dejan de emparejar: un ratio entre ella y otra regla por `job` sale vacío. No da error porque la consulta es válida; solo es otra consulta. Un test unitario con valores por `job` lo detecta.

</details>

**10.** Tus tests de `promtool` pasan. ¿Cómo sabes que valen para algo?

<details>
<summary>Respuesta</summary>

Rompiendo la regla a propósito y comprobando que fallan. Si las series de entrada no contienen el caso que la regla debe tratar (un 404, un reinicio del contador), la regla rota y la correcta dan el mismo resultado y el test no distingue entre ellas. Un test que no puede fallar no prueba nada.

</details>

## 💪 Desempeño (40%)

| Lab | Criterio | Puntos |
|---|---|:--:|
| 01 — Vector matching | Proporciones con `ignoring`/`on` y `group_left`; `up` enriquecido con la versión | 6 |
| 02 — Subconsultas, offset y @ | Pico de la última media hora, comparación con `offset` y coste de la subconsulta medido | 6 |
| 03 — absent y predict_linear | `absent` con `pagos` parado y condición de "disco lleno en 4 h"; volumen vaciado | 6 |
| 04 — Native histograms y TSDB | Native histograms ingeridos y comparados con los clásicos; cardinalidad leída de la API | 6 |
| 05 — Recording rules | Las 8 reglas cargadas, sanas y con nombres que cumplen la convención | 8 |
| 06 — Tests con promtool | Tests que pasan y fallan con la regla de errores rota y con `deriv` | 8 |
| **Total** | | **40** |

## 📦 Producto (30%)

**Autograding (60 puntos)**: `./scripts/verificar-semana.sh 05` con 19/19. Cada comprobación en rojo resta 60/19 puntos.

**Calidad manual (40 puntos)**: los cuatro criterios de [`3-proyecto/README.md`](3-proyecto/README.md#criterios-de-calidad-revisión-manual), 10 puntos cada uno.

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Secreto real comiteado | Grave: −10 y retirarlo del historial |
| Datos personales en logs, métricas o labels | Grave: −10 |
| Imagen sin tag o con `latest` | Grave: −5 |
| Puerto publicado en `0.0.0.0` en lugar de `127.0.0.1` | Grave: −5 |
| `pip`/`requirements.txt` o `npm`/`package-lock.json` en la entrega | −5 |
| Configuración hecha con clics y no provisionada en archivos | −3 |
| `TODO` sin resolver en la entrega | −1 por cada uno |

---

[← Proyecto](3-proyecto/README.md) · [Ebooks gratuitos →](4-recursos/ebooks-free/README.md)
