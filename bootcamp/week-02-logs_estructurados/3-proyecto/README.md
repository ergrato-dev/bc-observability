# Proyecto — Capa 02 de la tienda: logs JSON de punta a punta

⏱ 3 h

## Contexto

En la semana 01 diagnosticaste dos averías con logs de texto y apuntaste lo que te faltó: duración, un identificador común, estructura y ningún dato personal. Esta semana se lo das a la tienda entera. Cuando termines, cualquier pregunta sobre un pedido concreto se responderá con una consulta de `jq` que funcione igual en los cuatro servicios.

## Punto de partida

```
starter/                     tu copia de la tienda: la de app/, con structlog y pino ya en los lockfiles
├── Dockerfile.python
├── catalogo/                FastAPI + uv
├── pedidos/                 FastAPI + uv
├── pagos/                   FastAPI + uv
└── notificaciones/          Express + pnpm
```

Los labs ya hicieron buena parte del trabajo en `starter/`. Se construye y se arranca con:

```bash
export TIENDA=bootcamp/week-02-logs_estructurados/3-proyecto/starter
./scripts/lab-up.sh
```

## Entregables

1. **Solo JSON en los cuatro servicios**, incluidas las líneas de uvicorn y las de arranque. El mismo `logging_config.py` en los tres servicios Python y `logger.js` en `notificaciones`.
2. **Esquema común**: `timestamp` (ISO 8601 UTC), `level` (`debug`, `info`, `warning`, `error`, `critical`), `service` y `event` en cada línea; `request_id` en las que ocurren dentro de una petición o de un mensaje; una línea `http_request` por petición con `method`, `path`, `route`, `status_code` y `duration_ms`, salvo `/health`.
3. **Eventos de negocio con nombre fijo y datos en campos**, como mínimo:

   | Servicio | Evento | Nivel | Campos |
   |---|---|---|---|
   | `catalogo` | `product_search` | info | `query_length`, `scanned`, `results` |
   | `catalogo` | `stock_unavailable` | warning | `product_id`, `quantity` |
   | `pedidos` | `order_created` | info | `order_id`, `total`, `items` |
   | `pedidos` | `payment_failed` | warning | `order_id`, `total`, `reason` (`pagos_timeout`, `pagos_status_503`…) |
   | `pagos` | `charge_approved` / `charge_failed` | info / error | `charge_id` o `reason`, `amount` |
   | `pagos` | `faults_updated` | warning | configuración anterior y nueva |
   | `notificaciones` | `email_sent` / `message_discarded` | info / error | `order_id` o `error` |

   Para `payment_failed`, haz que `charge()` en `pedidos` devuelva el motivo del fallo en lugar de `True` o `False`.
4. **`request_id` de punta a punta**: cabecera `X-Request-ID` en HTTP (se respeta la que llega o se genera una) y cabecera `x-request-id` en los mensajes de RabbitMQ.
5. **Sin datos personales**: ni emails ni números de tarjeta en ninguna línea, con la redacción automática como red en Python y en Node.js.

## ✅ Requisitos verificables

- La tienda de la entrega se construye y sus cuatro servicios quedan healthy
- Todas las líneas de log de catalogo son JSON
- Todas las líneas de log de pedidos son JSON
- Todas las líneas de log de pagos son JSON
- Todas las líneas de log de notificaciones son JSON
- Cada línea de log lleva timestamp, level, service y event
- El timestamp de todas las líneas es ISO 8601 en UTC
- El level de todas las líneas es debug, info, warning, error o critical
- Cada servicio se identifica con su nombre en el campo service
- Los healthchecks no se registran en los logs
- pedidos registra cada POST /orders con status_code y duration_ms
- Los cuatro servicios devuelven el X-Request-ID que reciben
- El request_id de un pedido llega a los logs de catalogo
- El request_id de un pedido llega a los logs de pagos
- El request_id de un pedido llega a los logs de notificaciones
- pedidos registra cada cobro fallido como warning o error con su motivo
- Ningún log contiene emails ni números de tarjeta

El autograding reconstruye la tienda desde `starter/`, hace pedidos con un `X-Request-ID` propio y, para comprobar el cobro fallido, pone `pagos` al 100 % de errores unos segundos y deja la configuración como estaba.

## Calidad (40 pts)

| Criterio | Puntos |
|---|:--:|
| Los nombres de evento son estables y en `snake_case`, y los datos variables van en campos, nunca dentro de `event` | 10 |
| Los niveles se usan con criterio: `warning` para fallos de negocio que el sistema maneja, `error` para fallos del sistema | 10 |
| Sin ruido: ni healthchecks, ni una línea por llamada de httpx, ni eventos que nadie consultaría | 10 |
| `logging_config.py` es idéntico en los tres servicios Python y `logger.js` produce exactamente los mismos campos | 10 |
| **Total** | **40** |

## Entrega

```bash
./scripts/verificar-semana.sh 02
git add . && git commit -m "feat(semana-02): logs JSON con esquema común y request_id de punta a punta"
```

---

[← Lab 06](../2-practicas/lab-06-consultas-con-jq/README.md) · [Rúbrica →](../rubrica-evaluacion.md)
