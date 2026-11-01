# Rúbrica de evaluación — Semana 02

> Logs estructurados con structlog y pino. Se aprueba con un **mínimo del 70 % en cada evidencia**, no en el promedio.

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | 10 preguntas conceptuales, respuestas en `<details>` |
| 💪 Desempeño | 40% | Labs 01 a 06 y sus criterios de éxito |
| 📦 Producto | 30% | 60 pts de autograding + 40 pts de calidad manual |

## 🧠 Conocimiento (30%)

Responde por escrito antes de abrir cada respuesta. Cada pregunta vale 3 puntos: 1 por la idea correcta y 2 por el razonamiento.

**1.** Una línea JSON con `"event": "El pedido 3312 falló por timeout de pagos"` es JSON válido. ¿Por qué no es un buen log estructurado?

<details>
<summary>Respuesta</summary>

Porque los datos variables (el pedido, el motivo) están dentro de una frase. Para contar los fallos por motivo o buscar un pedido hay que volver a las expresiones regulares, que se rompen cuando alguien cambia la redacción. Bien hecho: `event: "payment_failed"` con `order_id: 3312` y `reason: "pagos_timeout"` en campos aparte.

</details>

**2.** ¿Por qué el `timestamp` va en UTC y en ISO 8601, y no en la hora local del servidor o en milisegundos desde 1970?

<details>
<summary>Respuesta</summary>

Para poder ordenar y comparar líneas de servicios distintos: con horas locales, dos máquinas en zonas distintas (o un cambio de horario) desordenan los eventos. ISO 8601 es legible por personas y por cualquier herramienta, y en UTC se ordena como texto. Los milisegundos son precisos pero ilegibles al leer un log, y pino y Python no coinciden en la unidad.

</details>

**3.** pino escribe el nivel como número (`40`) y structlog como texto (`"warning"`). ¿Qué problema concreto da eso en la tienda y dónde se arregla?

<details>
<summary>Respuesta</summary>

Una consulta como `select(.level == "warning")` deja fuera a `notificaciones`, y un recuento de errores por servicio sale mal sin que nada avise. Se arregla una sola vez en la configuración de pino (`formatters.level`, con `warn` traducido a `warning`), no en cada consulta ni en cada línea.

</details>

**4.** ¿Por qué `route` (`/products/{product_id}`) es mejor que `path` (`/products/42`) para agrupar peticiones?

<details>
<summary>Respuesta</summary>

`path` tiene un valor por producto: agrupar por él da cientos de grupos de una petición cada uno, y no dice nada del endpoint. `route` tiene un valor por endpoint, que es lo que se quiere comparar. Es la misma idea de cardinalidad de la semana 01, y en las métricas de la semana 03 será obligatoria.

</details>

**5.** Dos pedidos llegan a la vez a `pedidos`. ¿Por qué el `request_id` de uno no aparece en las líneas del otro si los dos usan `bind_contextvars`?

<details>
<summary>Respuesta</summary>

Porque las variables de contexto (`contextvars`) son propias de cada tarea `async`: cada petición se atiende en su propio contexto y lo que una enlaza no lo ve la otra. Una variable global sí mezclaría los identificadores. Por eso además se llama a `clear_contextvars()` al empezar cada petición.

</details>

**6.** Añadiste el `request_id` a las llamadas HTTP pero no al mensaje de RabbitMQ. ¿Qué parte del recorrido de un pedido queda invisible y por qué?

<details>
<summary>Respuesta</summary>

Todo lo que pasa en `notificaciones`. El mensaje es la única conexión entre `pedidos` y `notificaciones`; si no lleva el identificador en sus cabeceras, el consumidor no tiene de dónde sacarlo y sus líneas no se pueden unir con el pedido. Un pedido sin correo de confirmación no se podría investigar.

</details>

**7.** En la avería de los cobros fantasma, ¿qué dos campos de los logs permiten ahora contar exactamente los clientes afectados, y cómo?

<details>
<summary>Respuesta</summary>

`request_id` y `status_code` (junto con `route`). Se buscan las peticiones a `/charges` que `pagos` respondió con 201 y las peticiones a `/orders` que `pedidos` respondió con 402; las que comparten `request_id` son cobros aprobados en pedidos fallidos. En la semana 01 no había ni identificador común ni código de estado como campo.

</details>

**8.** Tienes la redacción automática de emails. ¿Por qué hay que quitar igualmente la línea que escribía el email?

<details>
<summary>Respuesta</summary>

Porque la redacción es una red con agujeros: la de pino solo tapa rutas de campo conocidas, y la de expresiones regulares no reconoce todos los formatos y cuesta CPU en cada línea. Un dato que nunca se escribe no puede filtrarse. La redacción está para el error que alguien cometa mañana, no para justificar el de hoy.

</details>

**9.** ¿Por qué un servicio en un contenedor escribe sus logs en stdout y no en un archivo propio con rotación?

<details>
<summary>Respuesta</summary>

Porque guardar, rotar y enviar los logs es responsabilidad de la plataforma, no de cada aplicación. En stdout, Docker los recoge con su driver (y rota con `max-size` y `max-file`); en la semana 08, Fluent Bit los enviará a Loki sin cambiar el código. Un archivo dentro del contenedor se pierde al recrearlo y obliga a cada servicio a reimplementar la rotación.

</details>

**10.** ¿Por qué no se registran las peticiones a `/health`?

<details>
<summary>Respuesta</summary>

Porque las hace el healthcheck de Docker cada 10 segundos en cada servicio: son miles de líneas al día que no responden ninguna pregunta y entierran las que sí. Si `/health` falla, el propio Docker lo marca como `unhealthy`. Cada línea de log tiene coste (disco, transporte, almacenamiento en la semana 08) y tiene que ganarse su sitio.

</details>

## 💪 Desempeño (40%)

| Lab | Criterio | Puntos |
|---|---|:--:|
| 01 — Logs JSON con structlog | Todas las líneas de `catalogo` en JSON con el esquema común; `product_search` y niveles funcionando | 7 |
| 02 — Middleware con contexto | `http_request` con duración y `request_id`, sin `/health`; búsqueda frente a listado medidos | 7 |
| 03 — pino en notificaciones | `notificaciones` en JSON con los mismos campos que `catalogo` | 6 |
| 04 — Propagar el request_id | Un pedido seguido por los cuatro servicios; cobros fantasma contados | 8 |
| 05 — Fuera datos personales | Cero datos personales con tráfico; redacción probada en Python y Node.js | 6 |
| 06 — Consultas con jq | Las cuatro consultas funcionan; rotación aplicada y comprobada | 6 |
| **Total** | | **40** |

## 📦 Producto (30%)

**Autograding (60 puntos)**: `./scripts/verificar-semana.sh 02` con 17/17. Cada comprobación en rojo resta 60/17 puntos.

**Calidad manual (40 puntos)**:

| Criterio | Puntos |
|---|:--:|
| Los nombres de evento son estables y en `snake_case`, y los datos variables van en campos, nunca dentro de `event` | 10 |
| Los niveles se usan con criterio: `warning` para fallos de negocio que el sistema maneja, `error` para fallos del sistema | 10 |
| Sin ruido: ni healthchecks, ni una línea por llamada de httpx, ni eventos que nadie consultaría | 10 |
| `logging_config.py` es idéntico en los tres servicios Python y `logger.js` produce exactamente los mismos campos | 10 |
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
