# Rúbrica de evaluación — Semana 03

> Métricas e instrumentación con Prometheus. Se aprueba con un **mínimo del 70 % en cada evidencia**, no en el promedio.

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | 10 preguntas conceptuales, respuestas en `<details>` |
| 💪 Desempeño | 40% | Labs 01 a 06 y sus criterios de éxito |
| 📦 Producto | 30% | 60 pts de autograding + 40 pts de calidad manual |

## 🧠 Conocimiento (30%)

Responde por escrito antes de abrir cada respuesta. Cada pregunta vale 3 puntos: 1 por la idea correcta y 2 por el razonamiento.

**1.** En la semana 02 ya contabas los cobros fallidos con `jq` sobre los logs. ¿Qué gana la tienda con `payment_failures_total`?

<details>
<summary>Respuesta</summary>

Contar con logs exige leer y procesar todas las líneas, y cuesta más cuanto más tráfico hay; el contador cuesta lo mismo con mil fallos que con un millón, porque el servicio solo suma uno en memoria. Además Prometheus lo guarda como serie temporal: se puede ver cómo evoluciona, compararlo con otras métricas y alertar sobre él. Los logs siguen siendo los que dicen *qué* pedido falló y por qué.

</details>

**2.** ¿Por qué nunca se mira el valor de un counter tal cual, sino cuánto sube por segundo?

<details>
<summary>Respuesta</summary>

Porque su valor absoluto depende de cuándo arrancó el proceso: vuelve a 0 en cada reinicio y no dice nada sobre lo que pasa ahora. Lo que interesa es su ritmo de crecimiento, que es comparable entre réplicas y en el tiempo. `rate()` (semana 04) calcula ese ritmo y además detecta los reinicios del contador.

</details>

**3.** ¿Por qué el label es `route="/products/{product_id}"` y no `path="/products/42"`?

<details>
<summary>Respuesta</summary>

Porque cada valor distinto de un label crea una serie, y en un histograma, 17. `path` tiene un valor por producto (y por cada URL que alguien invente, incluidas las que dan 404): la cardinalidad no tiene límite. `route` tiene un valor por endpoint, que además es lo que se quiere comparar. El lab 06 lo demuestra: 3000 URL convierten 70 líneas de `/metrics` en 50 000.

</details>

**4.** ¿Por qué la tienda usa un histograma y no un summary para la duración de las peticiones?

<details>
<summary>Respuesta</summary>

Un summary calcula el percentil dentro de cada proceso, y los percentiles no se pueden combinar: la media de la p95 de dos réplicas no es la p95 global. Los buckets de un histograma son contadores y sí se suman entre réplicas y servicios; Prometheus calcula el percentil después, sobre la suma. El precio es la precisión, que depende de dónde estén los límites de los buckets.

</details>

**5.** `notificaciones` usaba los buckets por defecto de su cliente y los servicios Python los suyos. Las dos métricas se llaman igual. ¿Qué se rompe?

<details>
<summary>Respuesta</summary>

Agregarlas. Para calcular un percentil de varios servicios hay que sumar sus buckets por `le`, y si un servicio no tiene `le="0.075"`, ese bucket de la suma está incompleto y el percentil resultante es falso sin que nada avise. Un nombre común solo es común si también coinciden los labels y los buckets.

</details>

**6.** ¿Qué te dice `up` que un modelo push no te daría gratis? ¿Y cuándo sí tiene sentido empujar métricas?

<details>
<summary>Respuesta</summary>

Con pull, Prometheus sabe si cada target respondió al scrape: `up` vale 0 si no lo hizo. Con push, el silencio de un servicio es ambiguo: puede estar caído o no tener nada que contar. Empujar a un Pushgateway solo tiene sentido para jobs por lotes que viven menos que un intervalo de scrape; para servicios, el Pushgateway guarda su último valor aunque mueran.

</details>

**7.** ¿Por qué `instance` es el nombre del contenedor y no `IP:puerto`, que es lo que pone Prometheus por defecto?

<details>
<summary>Respuesta</summary>

Porque `instance` forma parte de la identidad de cada serie. La IP cambia cada vez que se recrea el contenedor, así que cada `lab-up.sh` crearía series nuevas para el mismo servicio: historia partida y más cardinalidad. El nombre del contenedor es estable, y además es legible.

</details>

**8.** ¿Qué diferencia hay entre `relabel_configs` y `metric_relabel_configs`?

<details>
<summary>Respuesta</summary>

`relabel_configs` se aplica a cada target antes del scrape, con los metadatos del descubrimiento: decide qué se scrapea, en qué dirección y con qué labels de target (`job`, `instance`). `metric_relabel_configs` se aplica a cada muestra después del scrape y antes de guardarla: sirve para descartar métricas o labels que no quieres pagar.

</details>

**9.** El lab 06 puso `sample_limit: 10000`. ¿Qué protege y qué cuesta?

<details>
<summary>Respuesta</summary>

Protege a Prometheus, y con él a todos los demás servicios: un target que de repente expone 50 000 muestras falla el scrape en lugar de llenar la memoria. El coste es que ese target se queda sin ninguna métrica, también las buenas, hasta que se corrija. Por eso el límite se fija bastante por encima de lo normal y se combina con arreglar la causa en el código.

</details>

**10.** cAdvisor y node_exporter aportan más series que los cuatro servicios juntos. ¿Por qué merecen la pena y cuándo dejarían de merecerla?

<details>
<summary>Respuesta</summary>

Porque dan USE de recursos que el código no ve: memoria y CPU de cada contenedor, carga y disco del host. Sin ellos, un servicio lento por falta de memoria parecería un problema del código. Dejan de merecer la pena cuando su coste supera su uso: series que nadie consulta, labels de contenedores efímeros que generan churn. Entonces se recortan con flags del exporter o con `metric_relabel_configs` (semana 13).

</details>

## 💪 Desempeño (40%)

| Lab | Criterio | Puntos |
|---|---|:--:|
| 01 — Primer /metrics | `/metrics` en `catalogo` sin series `_created` y sin líneas de log; contador de caché por resultado | 6 |
| 02 — Métricas RED con un histograma | Histograma con `route` en los tres servicios Python, sin `/health` ni `/metrics`; contadores de pedidos | 8 |
| 03 — Métricas en Node.js | `notificaciones` con el mismo histograma, los mismos buckets y `notifications_total` | 6 |
| 04 — Service discovery de Docker | Siete targets en `up` con `job` e `instance` estables; configuración validada con `promtool` | 8 |
| 05 — Exporters de host y contenedores | `use.sh` con USE del host y memoria por servicio, solo de la tienda | 6 |
| 06 — Explosión de cardinalidad | Culpable encontrado con la API, freno con `sample_limit` y causa corregida | 6 |
| **Total** | | **40** |

## 📦 Producto (30%)

**Autograding (60 puntos)**: `./scripts/verificar-semana.sh 03` con 19/19. Cada comprobación en rojo resta 60/19 puntos.

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
