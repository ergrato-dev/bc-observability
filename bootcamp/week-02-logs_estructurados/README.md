# Semana 02 — Logs estructurados con structlog y pino

## Descripción

Conviertes los logs de texto de la tienda en líneas JSON con un esquema común en Python y en Node.js. Cada línea lleva un `request_id` que viaja de servicio a servicio, también por RabbitMQ, y ningún dato personal. Al terminar, las preguntas que en la semana 01 respondías a ojo se responden con una consulta de `jq`, entre ellas cuántos clientes cobró `pagos` en pedidos fallidos.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Configurar structlog para que todas las líneas de un servicio FastAPI, incluidas las de uvicorn, salgan en JSON con un esquema común
- Configurar pino para que un servicio Node.js cumpla el mismo esquema
- Registrar cada petición HTTP con su duración y enlazar todas sus líneas con un `request_id`
- Propagar el `request_id` por HTTP y por RabbitMQ para seguir un pedido por los cuatro servicios
- Eliminar los datos personales de los logs y añadir una red de redacción automática
- Responder preguntas operativas con `jq` y limitar el disco que ocupan los logs de Docker

## Prerrequisitos

- [Semana 01](../week-01-que_es_observabilidad/README.md) completada
- Perfil de laboratorio: `core` (`./scripts/lab-up.sh`, ~0,5 GB de RAM)
- Esta semana la tienda se construye desde tu copia en `3-proyecto/starter/`: `export TIENDA=bootcamp/week-02-logs_estructurados/3-proyecto/starter` antes de `./scripts/lab-up.sh`. structlog y pino ya están en los lockfiles: no necesitas uv ni pnpm en tu máquina.

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-logs-estructurados.md](1-teoria/01-logs-estructurados.md) | 20 min |
| — | Teoría | [02-contexto-y-datos-personales.md](1-teoria/02-contexto-y-datos-personales.md) | 25 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-logs-json-con-structlog](2-practicas/lab-01-logs-json-con-structlog/README.md) | 60 min |
| 2 | Lab | [lab-02-middleware-con-contexto](2-practicas/lab-02-middleware-con-contexto/README.md) | 60 min |
| 3 | Lab | [lab-03-pino-en-notificaciones](2-practicas/lab-03-pino-en-notificaciones/README.md) | 60 min |
| 4 | Lab | [lab-04-propagar-el-request-id](2-practicas/lab-04-propagar-el-request-id/README.md) | 60 min |
| 5 | Lab | [lab-05-fuera-datos-personales](2-practicas/lab-05-fuera-datos-personales/README.md) | 60 min |
| 6 | Lab | [lab-06-consultas-con-jq](2-practicas/lab-06-consultas-con-jq/README.md) | 60 min |
| — | Proyecto | [Capa 02 de la tienda: logs JSON de punta a punta](3-proyecto/README.md) | 3 h |

**Total: 10 horas**

Diagramas de apoyo en [0-assets/](0-assets/01-pipeline-de-un-log.svg); recursos en [4-recursos/](4-recursos/webgrafia/README.md); términos en [5-glosario/](5-glosario/README.md).

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Logs JSON con structlog en catalogo
[60 min] lab-02 — Middleware de acceso con request_id
[60 min] lab-03 — pino en notificaciones con el mismo esquema
[60 min] lab-04 — Propagar el request_id y contar los cobros fantasma
[60 min] lab-05 — Fuera datos personales
[60 min] lab-06 — Consultas con jq y rotación de logs
[3 h]    Proyecto: logs JSON de punta a punta en los cuatro servicios
```

## Verificación de completitud

Desde la raíz del repositorio (el autograding reconstruye la tienda desde `3-proyecto/starter/`):

```bash
./scripts/verificar-semana.sh 02
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Semana 01 — Qué es observabilidad](../week-01-que_es_observabilidad/README.md) | **Semana 02 — Logs estructurados** | [Semana 03 — Métricas y Prometheus](../week-03-metricas_y_prometheus/README.md) |

[← Volver al índice del bootcamp](../README.md)
