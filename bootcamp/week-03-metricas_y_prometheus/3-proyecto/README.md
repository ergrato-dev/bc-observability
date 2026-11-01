# Proyecto — Capa 03 de la tienda: métricas RED y Prometheus

⏱ 3 h

## Contexto

En la semana 02 la tienda aprendió a contar lo que le pasa a cada pedido, línea a línea. Esta semana aprende a contarlo en números: cuántas peticiones atiende cada endpoint, cuántas fallan y cuánto tardan, en los cuatro servicios y con los mismos nombres. Prometheus los descubre solo en Docker y los guarda junto con las métricas del host y de cada contenedor. Es la base de las consultas de la semana 04, los dashboards de la 06 y las alertas de la 07.

## Punto de partida

```
starter/                     la solución de la semana 02, con prometheus-client y @prometheus-io/client ya en los lockfiles
├── Dockerfile.python
├── catalogo/                FastAPI + uv
├── pedidos/                 FastAPI + uv
├── pagos/                   FastAPI + uv
├── notificaciones/          Express + pnpm
└── prometheus/
    └── prometheus.yml       nuevo: la configuración de Prometheus es parte de tu entrega
```

Los labs ya hicieron buena parte del trabajo en `starter/`. Se construye y se arranca con:

```bash
export TIENDA=bootcamp/week-03-metricas_y_prometheus/3-proyecto/starter
./scripts/lab-up.sh metrics
```

## Entregables

1. **`/metrics` en los cuatro servicios**, sin que las peticiones de Prometheus aparezcan en los logs. El mismo `metrics.py` en los tres servicios Python y `metrics.js` en `notificaciones`.
2. **RED con un histograma**: `http_server_request_duration_seconds` con los labels `method`, `route` (la plantilla de la ruta) y `status_code`, los mismos buckets en Python y en Node.js, y el gauge `http_server_active_requests`. `/health` y `/metrics` no se miden.
3. **Métricas de negocio**, como mínimo:

   | Servicio | Métrica | Tipo | Labels |
   |---|---|---|---|
   | `catalogo` | `catalog_cache_requests_total` | counter | `result` (`hit`, `miss`) |
   | `pedidos` | `orders_created_total` | counter | — |
   | `pedidos` | `payment_failures_total` | counter | `reason` (`pagos_timeout`, `pagos_status_503`…) |
   | `notificaciones` | `notifications_total` | counter | `result` (`sent`, `discarded`) |

4. **Prometheus con descubrimiento en Docker**: un solo job con `docker_sd_configs` que scrapea los contenedores con `prometheus.io/scrape=true` en el puerto de `prometheus.io/port`, con `job` igual al servicio de Compose e `instance` igual al nombre del contenedor, y un `sample_limit` como freno.
5. **Cardinalidad bajo control**: ningún label con valores sin límite; los cuatro servicios suman menos de 1000 series.

## ✅ Requisitos verificables

- La tienda de la entrega se construye con el perfil metrics y sus cuatro servicios y Prometheus quedan healthy
- catalogo expone en /metrics el histograma http_server_request_duration_seconds
- pedidos expone en /metrics el histograma http_server_request_duration_seconds
- pagos expone en /metrics el histograma http_server_request_duration_seconds
- notificaciones expone en /metrics el histograma http_server_request_duration_seconds
- El histograma usa la ruta (route) y no la URL: /products/7 y /products/8 cuentan en /products/{product_id}
- Ni /health ni /metrics cuentan en el histograma de ningún servicio
- notificaciones usa los mismos buckets que los servicios Python
- catalogo cuenta los aciertos y fallos de su caché en catalog_cache_requests_total
- pedidos cuenta los pedidos creados en orders_created_total
- pedidos cuenta los cobros fallidos por motivo en payment_failures_total
- notificaciones cuenta los mensajes procesados por resultado en notifications_total
- promtool da por válida la configuración de Prometheus
- Prometheus descubre en Docker y tiene en UP a los cuatro servicios, Prometheus, node-exporter y cadvisor
- El label instance es el nombre del contenedor, no su IP
- Prometheus guarda el histograma de duración de los cuatro servicios
- Prometheus tiene la memoria disponible del host (node_exporter)
- Prometheus tiene la memoria de cada contenedor de la tienda, identificado por su servicio (cAdvisor)
- Los cuatro servicios de la tienda suman menos de 1000 series

Compruébalos desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 03
```

## Criterios de calidad (revisión manual)

| Criterio | Puntos |
|---|:--:|
| Los nombres siguen las convenciones: unidad base en el nombre, `_total` en los counters, lo que varía en un label | 10 |
| Ningún label puede tener valores sin límite (ids, emails, URL, mensajes de error completos) | 10 |
| `prometheus.yml` está comentado: se entiende qué hace cada regla de relabeling sin abrir la documentación | 10 |
| El código de métricas está separado del de negocio: un módulo por servicio y una o dos líneas en cada punto que cuenta algo | 10 |

---

[← Lab 06](../2-practicas/lab-06-explosion-de-cardinalidad/README.md) · [Rúbrica →](../rubrica-evaluacion.md)
