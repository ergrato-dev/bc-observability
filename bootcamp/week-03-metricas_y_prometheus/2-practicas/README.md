# Prácticas — Semana 03

Seis labs de unos 60 minutos. Todos trabajan sobre tu copia de la tienda, la del proyecto de la semana: lo que hagas aquí es parte de tu entrega. Antes de empezar, desde la raíz del repositorio:

```bash
export TIENDA=bootcamp/week-03-metricas_y_prometheus/3-proyecto/starter
./scripts/lab-up.sh metrics
```

Cada vez que cambies código, `./scripts/lab-up.sh metrics` reconstruye solo lo que cambió. Cada vez que cambies `prometheus.yml`, basta con recargarlo (lab 04, paso 3).

| # | Lab | Qué haces | Duración |
|---|---|---|:--:|
| 01 | [Primer /metrics](lab-01-primer-metrics/README.md) | `/metrics` en `catalogo` y el contador de la caché | 60 min |
| 02 | [Métricas RED con un histograma](lab-02-metricas-red/README.md) | El histograma de duración en los servicios Python y los contadores de pedidos | 60 min |
| 03 | [Métricas en Node.js](lab-03-metricas-en-node/README.md) | `notificaciones` con los mismos nombres, labels y buckets | 60 min |
| 04 | [Service discovery de Docker](lab-04-service-discovery-de-docker/README.md) | Prometheus encuentra los targets solo y les pone `job` e `instance` | 60 min |
| 05 | [Exporters de host y contenedores](lab-05-exporters-de-host-y-contenedores/README.md) | USE del host con node_exporter y memoria por servicio con cAdvisor | 60 min |
| 06 | [Explosión de cardinalidad](lab-06-explosion-de-cardinalidad/README.md) | Provocar, detectar y frenar una explosión de series | 60 min |

---

[← Prometheus y descubrimiento](../1-teoria/02-prometheus-y-descubrimiento.md) · [Lab 01 →](lab-01-primer-metrics/README.md)
