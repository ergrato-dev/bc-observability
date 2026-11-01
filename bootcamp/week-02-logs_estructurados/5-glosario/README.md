# Glosario — Semana 02

[D](#d) · [E](#e) · [L](#l) · [M](#m) · [N](#n) · [P](#p) · [R](#r) · [S](#s) · [V](#v)

## D

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Driver de logging | Componente de Docker que recoge el stdout de un contenedor y lo guarda o lo envía | `json-file` |

## E

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Esquema común | Conjunto de campos que todos los servicios escriben con el mismo nombre y formato | `timestamp`, `level`, `service`, `event` |
| Evento | Nombre fijo de lo que pasó, sin datos variables dentro | `payment_failed` |

## L

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Log estructurado | Registro en el que cada dato va en un campo con nombre y tipo, legible por una máquina | Una línea JSON con `status_code: 402` |
| Logger hijo | Logger de pino que añade campos fijos a todas sus líneas | `logger.child({ request_id })` |

## M

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Middleware | Código que se ejecuta en cada petición HTTP antes y después del endpoint | `log_requests` escribe `http_request` |

## N

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Nivel | Gravedad de una línea de log, usada para filtrar | `warning` para un cobro rechazado |

## P

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| PII | Información que identifica a una persona y no debe aparecer en la telemetría | Email o número de tarjeta |
| Procesador | Función de structlog que recibe el diccionario de una línea y lo transforma | `TimeStamper` añade `timestamp` |
| Propagación | Envío del identificador de la petición en cada llamada saliente | Cabecera `X-Request-ID` hacia `pagos` |

## R

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Redacción | Sustitución automática de datos sensibles en los logs | `email` sale como `[REDACTED]` |
| request_id | Identificador único de una petición que llevan todas sus líneas | `7be7316fdfb644b8aa4815ab31315872` |
| Rotación | Cerrar un archivo de log al llegar a un tamaño y conservar solo los N últimos | `max-size: 10m`, `max-file: 3` |

## S

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| stdout | Salida estándar del proceso; el único destino de logs de un servicio en contenedor | `logging.StreamHandler(sys.stdout)` |

## V

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Variable de contexto | Valor ligado a la petición en curso que se añade solo a cada línea | `bind_contextvars(request_id=...)` |

---

[← Webgrafía](../4-recursos/webgrafia/README.md) · [Semana 02 →](../README.md)
