# 🛒 Proyecto hilo conductor: `tienda`

Un solo proyecto atraviesa las 22 semanas: una tienda online pequeña hecha de microservicios. Vive en [`app/`](../app/README.md) y se entrega **sin instrumentar**: no emite logs útiles, no tiene `/metrics` y no propaga contexto. Cada semana le añades una capa de observabilidad y la siguiente parte de ella.

`web` y `asistente` no existen todavía: se añaden a `app/` en la semana que los usa (16 y 20).

## Componentes

| Servicio | Tecnología | Qué hace | Por qué está |
|---|---|---|---|
| `catalogo` | FastAPI + uv | Productos, búsqueda y stock, con caché en Valkey | Consultas a base de datos, caché, el N+1 de la S16 y el hot path de la S14 |
| `pedidos` | FastAPI + uv | Orquesta el checkout: consulta `catalogo`, cobra en `pagos`, publica un evento | Llamadas encadenadas: la traza distribuida de las S09-10 |
| `pagos` | FastAPI + uv | Simula una pasarela de pago | Averías configurables por variables de entorno: latencia, tasa de error, timeouts |
| `notificaciones` | Node.js + Express + pnpm | Consume eventos de RabbitMQ y "envía" correos | Segundo lenguaje y propagación de contexto asíncrona |
| `web` | Vite + pnpm | Frontend mínimo de la tienda | RUM y propagación navegador → backend en la S16 |
| `asistente` | FastAPI + uv + Ollama | Responde preguntas sobre el catálogo con un LLM local | Observabilidad de apps con LLM en la S20 (perfil `ai`) |
| PostgreSQL | imagen oficial | Datos de `catalogo` y `pedidos` | Dependencia con estado |
| Valkey | imagen oficial | Caché de `catalogo` | Dependencia rápida que puede degradarse |
| RabbitMQ | imagen oficial | Cola de eventos de pedidos | Mensajería y colas que se saturan |
| k6 | imagen oficial | Tráfico sintético reproducible | Sin carga no hay señal que observar |
| toxiproxy | imagen oficial | Latencia y cortes de red entre servicios | Averías de red controladas |

## Por qué esta app

- Tiene lo justo para que cada señal haga falta de verdad: llamadas síncronas encadenadas (trazas), una cola (contexto asíncrono), una base de datos y una caché (dependencias), dos lenguajes (instrumentación heterogénea) y un frontend (RUM).
- Las averías son reproducibles: `pagos` y toxiproxy fallan cuando y como diga la semana, así que dos alumnos ven el mismo problema.
- Es pequeña: el esfuerzo se va a observar, no a entender el negocio.

## Capas por semana

| Semana | Capa que se añade |
|:--:|---|
| 01 | Mapa de observabilidad: diagrama de servicios, preguntas que hay que poder responder, SLIs candidatos |
| 02 | Logs JSON con esquema común y request ID de punta a punta en los 4 servicios |
| 03 | `/metrics` con métricas RED en todos los servicios y Prometheus con todos los targets en `UP` |
| 04 | Libreta de consultas PromQL que responde las preguntas de la S01 |
| 05 | Recording rules de la tienda con tests unitarios de `promtool` |
| 06 | Dashboards provisionados: overview, por servicio e infraestructura |
| 07 | Alertas con runbooks, enrutadas por severidad y probadas con promtool |
| 08 | Logs en Loki, dashboard de errores, alerta LogQL y patrones de logs |
| 09 | Flujo "crear pedido" trazado a mano `catalogo → pedidos → pagos` |
| 10 | Tienda entera auto-instrumentada, incluida la ruta asíncrona hasta `notificaciones` |
| 11 | Collector gateway: todo por OTLP, reparto a Prometheus, Loki y Jaeger, redacción de PII |
| 12 | Correlación: de un pico de latencia a la traza y a sus logs en tres clics |
| 13 | ≥70% menos volumen conservando el 100% de las trazas con error |
| 14 | Hot path de `catalogo` encontrado y corregido con perfiles |
| 15 | SLOs del checkout con alertas de burn rate y detección de anomalías |
| 16 | N+1 y cola saturada detectados; vista de punta a punta desde el navegador |
| 17 | Dos Prometheus en HA + Thanos con vista global y retención larga |
| 18 | La tienda en kind con la misma observabilidad, declarada con CRDs |
| 19 | Stack endurecido (TLS, autenticación, multi-tenancy) + alerta Watchdog |
| 20 | `asistente` observado de punta a punta + investigación asistida por IA verificada con consultas |
| 21 | Game day: 5 incidentes inyectados, resueltos y con postmortem |
| 22 | Capstone: plataforma completa desde cero para un servicio nuevo |

---

[← Volver al índice de documentación](README.md)
