# Rúbrica de evaluación — Semana 04

> PromQL: fundamentos. Se aprueba con un **mínimo del 70 % en cada evidencia**, no en el promedio.

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | 10 preguntas conceptuales, respuestas en `<details>` |
| 💪 Desempeño | 40% | Labs 01 a 06 y sus criterios de éxito |
| 📦 Producto | 30% | 60 pts de autograding + 40 pts de calidad manual |

## 🧠 Conocimiento (30%)

Responde por escrito antes de abrir cada respuesta. Cada pregunta vale 3 puntos: 1 por la idea correcta y 2 por el razonamiento.

**1.** ¿Por qué `up[5m]` no se puede dibujar en una gráfica y `rate(x[5m])` sí?

<details>
<summary>Respuesta</summary>

`up[5m]` es un range vector: para cada serie devuelve todas las muestras de la ventana, una lista de valores por instante. Una gráfica necesita un valor por serie y por instante. `rate` reduce cada lista a un número, el aumento por segundo, y devuelve un instant vector que sí se dibuja y se compara.

</details>

**2.** `route=~"/products"` no devuelve las rutas `/products/{product_id}`. ¿Por qué, y cómo se escribe?

<details>
<summary>Respuesta</summary>

Las expresiones regulares de PromQL están ancladas al principio y al final: casan con el valor entero, no con una parte. `"/products"` solo casa con `/products`. Para el prefijo hace falta `"/products.*"` o, solo las de un producto, `"/products/.+"`.

</details>

**3.** `pedidos` se reinicia y `orders_created_total` vuelve a 0. ¿Qué pasa con `rate(orders_created_total[5m])` y con `orders_created_total - orders_created_total offset 5m`?

<details>
<summary>Respuesta</summary>

`rate` detecta que el valor bajó, entiende que el contador se reinició y suma el valor previo, así que la tasa sigue siendo correcta. La resta usa los valores en crudo: da negativo o demasiado pequeño. Por eso los counters se leen siempre con `rate` o `increase`.

</details>

**4.** ¿Por qué `rate(x[20s])` puede salir vacío con un `scrape_interval` de 15 s, y qué ventana usarías?

<details>
<summary>Respuesta</summary>

`rate` necesita al menos dos muestras dentro de la ventana. Con un scrape cada 15 s, una ventana de 20 s a veces contiene solo una, y entonces no hay tasa. La regla práctica es una ventana de al menos cuatro veces el intervalo (1 minuto), para tener margen aunque falle algún scrape.

</details>

**5.** `rate(node_memory_MemAvailable_bytes[5m])` devuelve cientos de millones. ¿Qué ha pasado y qué usarías?

<details>
<summary>Respuesta</summary>

Es un gauge: sube y baja. `rate` supone que la serie solo sube y toma cada bajada por el reinicio de un contador, sumando el valor completo cada vez. No da error, da un número falso. Para la tendencia de un gauge se usa `deriv()` (pendiente por segundo) o `delta()` (cambio en la ventana).

</details>

**6.** ¿Por qué hay que aplicar `rate` antes de `sum` y no al revés?

<details>
<summary>Respuesta</summary>

`rate` detecta los reinicios serie a serie. Si primero se suman los contadores de varios servicios, el reinicio de uno se ve como una bajada de la suma, y `rate` la trata como el reinicio de todos: suma de golpe el total anterior y la tasa se dispara. Primero la tasa de cada serie; después se suman las tasas.

</details>

**7.** Al dividir los 5xx por `job` entre el total de peticiones sin agrupar, el resultado sale vacío. ¿Por qué?

<details>
<summary>Respuesta</summary>

Un operador binario empareja las series de los dos lados que tienen exactamente los mismos labels. El numerador tiene el label `job` y el denominador no tiene ninguno, así que ninguna serie encuentra pareja y el resultado es vacío, sin error. Hay que agregar los dos lados por los mismos labels (`sum by (job)`).

</details>

**8.** `pagos` tarda entre 40 y 120 ms y su p95 real es 116 ms, pero `histogram_quantile` dice 220 ms. ¿Por qué?

<details>
<summary>Respuesta</summary>

Prometheus no conoce las observaciones, solo cuántas caben en cada bucket. El 95 % cae en el bucket entre 0,1 y 0,25 s, y `histogram_quantile` supone las observaciones repartidas de forma uniforme dentro de él: interpola en línea recta y coloca el p95 hacia el 80 % del bucket. Cuanto más ancho el bucket alrededor del valor, más error. Se arregla con buckets más finos donde importa.

</details>

**9.** ¿Por qué no se puede calcular el p95 de toda la tienda como la media del p95 de cada servicio?

<details>
<summary>Respuesta</summary>

Porque la media trata igual a todos los servicios, atiendan las peticiones que atiendan, y los percentiles no se combinan con aritmética: el p95 de dos grupos no es la media de sus p95. Los buckets sí son contadores y se suman: se agregan los buckets de todos los servicios por `le` y se calcula el percentil una sola vez.

</details>

**10.** En la API, ¿cómo distingues una consulta mal escrita de una consulta correcta que no encuentra nada? ¿Por qué importa en un script?

<details>
<summary>Respuesta</summary>

La mal escrita responde `"status": "error"` con `errorType` y `error`. La correcta sin datos responde `"status": "success"` con `data.result` vacío. Un script que solo mira si hay resultados confunde un error de sintaxis con "no pasa nada", y una alerta o un informe basados en él callan justo cuando deberían avisar.

</details>

## 💪 Desempeño (40%)

| Lab | Criterio | Puntos |
|---|---|:--:|
| 01 — Selectores y vectores | Selectores con matchers y expresiones regulares que devuelven exactamente las series pedidas | 6 |
| 02 — Tasas | Tasas e incrementos con la ventana adecuada; `rate` y `resets` comprobados tras reiniciar `pedidos` | 7 |
| 03 — Agregaciones y aritmética | Agregaciones y proporciones con los labels pedidos; cobros fantasma visibles con la avería | 8 |
| 04 — Percentiles | Percentiles por endpoint y por paso del checkout; error de la estimación medido y explicado | 7 |
| 05 — Errores frecuentes | Los cinco errores con su resultado falso, la consulta correcta y la explicación | 6 |
| 06 — La API con curl y jq | `informe.sh` evalúa la libreta, distingue errores de vacíos y pasa `shellcheck` | 6 |
| **Total** | | **40** |

## 📦 Producto (30%)

**Autograding (60 puntos)**: `./scripts/verificar-semana.sh 04` con 23/23. Cada comprobación en rojo resta 60/23 puntos.

**Calidad manual (40 puntos)**: los cuatro criterios de [`3-proyecto/README.md`](3-proyecto/README.md#criterios-de-calidad-revisión-manual), 10 puntos cada uno.

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Secreto real comiteado | Grave: −10 y retirarlo del historial |
| Datos personales en logs, métricas o labels | Grave: −10 |
| Imagen sin tag o con `latest` | Grave: −5 |
| Puerto publicado en `0.0.0.0` en lugar de `127.0.0.1` | Grave: −5 |
| `pip`/`requirements.txt` o `npm`/`package-lock.json` en la entrega | −5 |
| Consulta copiada de la solución sin entenderla (no sabe explicar su forma) | −3 por consulta |
| `TODO` sin resolver en la entrega | −1 por cada uno |

---

[← Proyecto](3-proyecto/README.md) · [Ebooks gratuitos →](4-recursos/ebooks-free/README.md)
