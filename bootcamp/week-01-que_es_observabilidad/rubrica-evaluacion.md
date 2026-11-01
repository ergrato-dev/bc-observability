# Rúbrica de evaluación — Semana 01

> Qué es observabilidad: señales, RED, USE y golden signals. Se aprueba con un **mínimo del 70 % en cada evidencia**, no en el promedio.

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | 10 preguntas conceptuales, respuestas en `<details>` |
| 💪 Desempeño | 40% | Labs 01 a 06 y sus criterios de éxito |
| 📦 Producto | 30% | 60 pts de autograding + 40 pts de calidad manual |

## 🧠 Conocimiento (30%)

Responde por escrito antes de abrir cada respuesta. Cada pregunta vale 3 puntos: 1 por la idea correcta y 2 por el razonamiento.

**1.** El dashboard de la tienda muestra CPU y memoria en verde, pero los clientes no pueden pagar. ¿Por qué un buen monitoreo de infraestructura no basta para detectarlo?

<details>
<summary>Respuesta</summary>

Porque mide causas posibles, no el síntoma que sufre el usuario. Un checkout puede fallar con la máquina ociosa: un timeout con `pagos`, un cobro rechazado, un bug. Hay que medir lo que ve el cliente (tasa de errores y latencia del checkout) y tener datos con contexto para averiguar el porqué cuando el fallo es nuevo.

</details>

**2.** ¿Qué diferencia hay entre un *known unknown* y un *unknown unknown*? Pon un ejemplo de cada uno en la tienda.

<details>
<summary>Respuesta</summary>

Un *known unknown* es un fallo que puedes prever aunque no sepas cuándo ocurrirá: "`pagos` puede devolver 503", y se cubre con una alerta. Un *unknown unknown* es uno que nadie imaginó: cobros aprobados en pedidos marcados como fallidos por un timeout (lab 03). El monitoreo cubre los primeros; para los segundos necesitas explorar datos que ya estabas guardando.

</details>

**3.** ¿Por qué un 402 de `POST /orders` no debería contar como error en RED, y un 503 sí?

<details>
<summary>Respuesta</summary>

El 402 significa que el sistema funcionó y el cobro fue rechazado: es una respuesta de negocio. El 503 significa que el sistema no pudo hacer su trabajo. Si los mezclas, una campaña con muchas tarjetas rechazadas parecería una caída, y una caída real quedaría diluida entre rechazos normales.

</details>

**4.** 99 checkouts tardan 100 ms y uno tarda 10 s. ¿Qué te dice la media y qué te dice el p99? ¿Cuál usarías para una alerta?

<details>
<summary>Respuesta</summary>

La media sale 199 ms: parece sano y esconde al cliente que esperó 10 s. El p99 sale cerca de 10 s y lo muestra. Para la alerta, un percentil alto (p95 o p99) o mejor aún la proporción de peticiones por debajo de un umbral, que es un SLI. La media mezcla casos distintos y oculta la cola de la distribución.

</details>

**5.** ¿Cuándo aplicas RED y cuándo USE? ¿Por qué necesitas los dos?

<details>
<summary>Respuesta</summary>

RED a cada servicio que atiende peticiones (lo que ve quien llama). USE a cada recurso finito: conexiones de PostgreSQL, una cola, CPU. RED detecta el síntoma ("el checkout va lento") y USE suele explicar la causa ("la cola está saturada"). Con solo RED sabes que algo va mal pero no qué; con solo USE ves recursos sin saber si el usuario lo nota.

</details>

**6.** En el lab 05, `red.sh notificaciones` no encuentra peticiones. ¿Significa que `notificaciones` no tiene tráfico? ¿Cómo medirías su Rate?

<details>
<summary>Respuesta</summary>

No. `notificaciones` recibe su trabajo por RabbitMQ, no por HTTP, así que no tiene logs de acceso. Su Rate son los mensajes consumidos por segundo, su Errors los mensajes descartados y su Duration el tiempo desde que se publica el evento hasta que se envía el correo. RED se aplica igual; solo cambia qué es una "petición".

</details>

**7.** ¿Por qué meter el `email` del cliente como label de una métrica es un problema, aunque no fuera dato personal?

<details>
<summary>Respuesta</summary>

Por cardinalidad. Cada valor distinto de un label crea una serie temporal nueva; con un label por cliente tendrías tantas series como clientes, y el coste de memoria y de consulta del backend se dispararía. Ese detalle pertenece a logs o trazas, no a métricas. Y como además es un dato personal, no debería estar en ninguna señal.

</details>

**8.** En la avería 2 del lab 03, `pagos` registró cobros con 201 y `pedidos` los marcó como fallidos. ¿Qué dos datos faltaban en los logs para unir las dos versiones?

<details>
<summary>Respuesta</summary>

La duración de cada llamada (para ver que `pagos` respondía y que el tiempo se perdía entre los dos servicios, hasta superar el timeout de 2 s) y un identificador común entre la petición de `pedidos` y la de `pagos` (para emparejar cada cobro aprobado con su pedido fallido). La duración llega con las métricas de la semana 03; el identificador, con el `request_id` de la semana 02 y las trazas de la semana 09.

</details>

**9.** ¿Por qué un SLI se expresa como "eventos buenos / eventos totales" y no como "número de errores por minuto"?

<details>
<summary>Respuesta</summary>

Porque la proporción no depende del tráfico: 10 errores por minuto es grave a las 4 de la mañana y despreciable en un pico de ventas. Una proporción va de 0 a 1, se entiende sin contexto y se compara directamente con un objetivo ("99,5 % de checkouts sin 5xx"), que es lo que convierte un SLI en un SLO.

</details>

**10.** ¿Por qué el plan de instrumentación empieza por las preguntas y no por "instrumentarlo todo"?

<details>
<summary>Respuesta</summary>

Porque cada señal tiene coste (almacenamiento, cardinalidad, rendimiento, mantenimiento) y la pregunta decide cuál es la adecuada: un recuento pide una métrica, un desglose del tiempo pide una traza. Instrumentar sin preguntas produce mucho dato que nadie consulta y, aun así, deja sin responder la pregunta del incidente.

</details>

## 💪 Desempeño (40%)

| Lab | Criterio | Puntos |
|---|---|:--:|
| 01 — Levantar la tienda | Cuatro servicios `healthy`, pedido seguido hasta PostgreSQL y `notificaciones`, smoke test superado | 6 |
| 02 — Carga con k6 | Prueba en escalón a 60 it/s con umbrales en verde, y en rojo con `pagos` degradado | 7 |
| 03 — Depurar a ciegas | Dos averías diagnosticadas con comandos reproducibles; cobros fantasma explicados | 8 |
| 04 — Inventario de señales | Tabla completa con evidencia y conclusión infraestructura frente a aplicación | 6 |
| 05 — RED y USE a mano | `red.sh` y `use.sh` funcionan; la saturación de la cola se ve al parar `notificaciones` | 8 |
| 06 — Plan de instrumentación | 8 preguntas clasificadas por señal, 3 priorizadas desde averías reales | 5 |
| **Total** | | **40** |

## 📦 Producto (30%)

**Autograding (60 puntos)**: `./scripts/verificar-semana.sh 01` con 13/13. Cada comprobación en rojo resta 60/13 puntos.

**Calidad manual (40 puntos)**:

| Criterio | Puntos |
|---|:--:|
| Las preguntas son concretas de la tienda (nombran servicios, endpoints o pasos del checkout), no genéricas | 10 |
| RED separa los errores del sistema (5xx) de las respuestas de negocio (402, 404, 409) | 10 |
| Cada SLI mide algo que nota el usuario y se puede calcular con datos que la tienda tendrá | 10 |
| El plan prioriza lo que habría acortado el diagnóstico del lab 03 | 10 |
| **Total** | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Secreto real comiteado | Grave: −10 y retirarlo del historial |
| Datos personales en logs, spans o labels | Grave: −10 |
| Imagen sin tag o con `latest` | Grave: −5 |
| Puerto publicado en `0.0.0.0` en lugar de `127.0.0.1` | Grave: −5 |
| `pip`/`requirements.txt` o `npm`/`package-lock.json` en la entrega | −5 |
| Configuración hecha con clics y no provisionada en archivos | −3 |
| `TODO` sin resolver en la entrega | −1 por cada uno |

---

[← Proyecto](3-proyecto/README.md) · [Ebooks gratuitos →](4-recursos/ebooks-free/README.md)
