# Glosario — Semana 01

| Término | Definición en una línea | Ejemplo |
|---|---|---|
| Observabilidad | Capacidad de deducir el estado interno de un sistema a partir de lo que emite | Averiguar por qué fallan los checkouts sin desplegar código nuevo |
| Monitoreo | Vigilancia de condiciones conocidas de antemano con umbrales y dashboards | Avisar si `pedidos` supera un 5 % de 5xx |
| Telemetría | Datos que un sistema emite para ser observado | Logs, métricas, trazas y perfiles de la tienda |
| Señal | Cada tipo de telemetría, con su modelo de datos y su coste | Las métricas son una señal; las trazas, otra |
| Log | Registro de un evento con su contexto | `Error llamando a pagos: ReadTimeout('')` |
| Métrica | Valor numérico agregado y medido en el tiempo | Pedidos por segundo |
| Traza | Recorrido de una petición por todos los servicios que toca | `pedidos → catalogo → pagos` para un checkout |
| Perfil | Muestras de dónde gasta CPU o memoria el código | La función de búsqueda de `catalogo` |
| Cardinalidad | Número de valores distintos de un atributo | `status_code` tiene pocos; `email`, uno por cliente |
| RED | Rate, Errors, Duration: lo que medir de cada servicio | p95 de `POST /orders` |
| USE | Utilization, Saturation, Errors: lo que medir de cada recurso | Mensajes esperando en la cola de RabbitMQ |
| Golden signals | Latencia, tráfico, errores y saturación, según el SRE de Google | Las cuatro gráficas mínimas del checkout |
| SLI | Medida de lo bien que funciona un servicio, como proporción de eventos buenos | `POST /orders` sin 5xx / todas las `POST /orders` |
| *Unknown unknowns* | Fallos que nadie previó y que ninguna alerta cubre | Cobros aprobados en pedidos marcados como fallidos |
| Tráfico sintético | Carga generada para ejercitar el sistema de forma controlada | El servicio `trafico` (k6) de la tienda |

---

[← Webgrafía](../4-recursos/webgrafia/README.md) · [Semana 01 →](../README.md)
