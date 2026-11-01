# Lab 06 — Consultas con jq

⏱ Duración estimada: ~60 min

## Objetivo

Responder con `jq` las preguntas frecuentes sobre la tienda a partir de sus logs estructurados, y limitar cuánto disco pueden ocupar esos logs.

## Contexto

- Con el esquema común, una misma consulta sirve para los cuatro servicios y para cualquier ventana de tiempo.
- `jq -s` lee todas las líneas como un único array: así puedes agrupar (`group_by`), ordenar (`sort_by`) y contar (`length`).
- Docker guarda el stdout de cada contenedor con el driver `json-file`. Sin límites, ese archivo crece hasta llenar el disco.

## Instrucciones

Desde la raíz del repositorio, con `TIENDA` exportada y la tienda de los labs anteriores en marcha. Antes de empezar, deja que el tráfico de fondo corra al menos cinco minutos.

1. Completa `resumen` en `starter/consultas.sh`: cuántas peticiones hubo por servicio, ruta y código de estado.
   ```bash
   ./bootcamp/week-02-logs_estructurados/2-practicas/lab-06-consultas-con-jq/starter/consultas.sh resumen 5m
   ```
   Debe salir una línea por combinación, con la cuenta delante, de mayor a menor.

2. Completa `errores`: las líneas con nivel `warning` o peor, contadas por servicio y evento. Inyecta errores en `pagos` durante un minuto y compruébalo:
   ```bash
   curl -s -X PUT http://127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.3,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}'
   sleep 60
   ./bootcamp/week-02-logs_estructurados/2-practicas/lab-06-consultas-con-jq/starter/consultas.sh errores 2m
   curl -s -X PUT http://127.0.0.1:18003/admin/faults -H 'Content-Type: application/json' \
     -d '{"error_rate":0.02,"latency_ms":80,"jitter_ms":40,"timeout_rate":0}'
   ```
   Tienen que aparecer los fallos de `pagos` y los cobros fallidos de `pedidos`, con cuentas parecidas. Si añadiste `faults_updated` en `pagos`, también verás quién cambió la configuración y cuándo.

3. Completa `lentas`: las 10 peticiones más lentas, con su `request_id`. Pasa el `request_id` de la primera a `seguir.sh` (lab 04) y explica de dónde salió su tiempo.

4. Completa `p95`: el percentil 95 de `duration_ms` por servicio y ruta. Compara el p95 de `POST /charges` en `pagos` con el de `POST /orders` en `pedidos`: la diferencia es lo que añade `pedidos` por su cuenta (catalogo, PostgreSQL, RabbitMQ).

5. Mide cuánto tarda cada consulta con `time`. Piensa en una tienda real: 40 servicios, una semana de logs, millones de líneas. ¿Qué pasa con este método? Lo resolverás en la semana 08 con Loki.

6. Mira cómo guarda Docker los logs de un contenedor:
   ```bash
   docker inspect tienda-pedidos-1 -f '{{json .HostConfig.LogConfig}}'
   ```
   `Config` vacío significa sin límite. Completa `starter/compose.logging.yaml` (archivos de 10 MB como máximo, 3 archivos) y aplícalo sin reconstruir:
   ```bash
   TIENDA_SRC="$PWD/$TIENDA" docker compose -f app/compose.yaml \
     -f bootcamp/week-02-logs_estructurados/2-practicas/lab-06-consultas-con-jq/starter/compose.logging.yaml \
     up -d --no-build --wait
   docker inspect tienda-pedidos-1 -f '{{json .HostConfig.LogConfig}}'
   ```
   Debes ver `"max-file":"3","max-size":"10m"`.

## Criterios de éxito

- [ ] `consultas.sh resumen`, `errores`, `lentas` y `p95` devuelven datos de los cuatro servicios
- [ ] Con `pagos` al 30 % de errores, `errores` muestra `charge_failed` en `pagos` y `payment_failed` en `pedidos`
- [ ] Explicas la diferencia entre el p95 de `pagos` y el de `pedidos`
- [ ] `docker inspect` muestra `max-size` y `max-file` en los contenedores de la tienda

## Reto extra

El p95 de `consultas.sh` es exacto porque lee todas las líneas. Prometheus no puede guardar cada duración: usa histogramas con cubos y estima el percentil. ¿Qué precisión se pierde? Lo verás en la semana 03.

---

[← Lab 05](../lab-05-fuera-datos-personales/README.md) · [Proyecto →](../../3-proyecto/README.md)
