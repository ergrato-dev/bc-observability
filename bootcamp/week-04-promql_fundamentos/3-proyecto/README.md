# Proyecto — Capa 04 de la tienda: la libreta de PromQL

⏱ 3 h

## Contexto

En la semana 01 escribiste las preguntas que la tienda tenía que poder responder: cuántos pedidos entran y cuántos fallan, cuánto tarda un checkout, qué paso es el lento, cuántos cobros se pierden. En la 03 la instrumentaste. Esta semana escribes las respuestas: veinte consultas PromQL, una por archivo, que cualquiera del equipo puede ejecutar y que serán los paneles de la semana 06 y las alertas de la 07.

## Punto de partida

```
starter/                     la solución de la semana 03, sin cambios de código
├── Dockerfile.python
├── catalogo/ pedidos/ pagos/ notificaciones/
├── prometheus/
│   └── prometheus.yml
└── libreta/                 nuevo: 20 archivos .promql con la pregunta y lo que debe devolver
    ├── 01-pedidos-por-segundo.promql
    ├── …
    └── 20-pedidos-en-la-ultima-hora.promql
```

Se arranca con:

```bash
export TIENDA=bootcamp/week-04-promql_fundamentos/3-proyecto/starter
./scripts/lab-up.sh metrics
```

Cada archivo empieza con dos comentarios: la pregunta y la forma exacta del resultado (qué labels lleva cada serie, en qué unidad y con qué ventana). Escribe la consulta debajo; puede ocupar varias líneas y llevar más comentarios. Evalúa cada una con:

```bash
./scripts/promql.sh bootcamp/week-04-promql_fundamentos/3-proyecto/starter/libreta/01-pedidos-por-segundo.promql
```

o toda la libreta con el `informe.sh` del lab 06.

## Entregables

1. **Las 20 consultas de la libreta**, cada una con exactamente los labels que pide su cabecera, en la unidad pedida y con la ventana pedida. Sin `by` de más ni de menos: un panel o una alerta dependen de esa forma.
2. **Percentiles bien calculados**: con `histogram_quantile` sobre la tasa de los buckets, sumados por `le`, nunca promediados.
3. **Contadores tratados como contadores**: `rate` o `increase` antes de cualquier agregación, nunca sobre un gauge.

El autograding deja la tienda con tráfico y provoca 30 s de cobros fallidos para que todas las preguntas tengan datos. Para que las consultas de 1 hora tengan sentido, deja la tienda en marcha un buen rato antes de entregar.

## ✅ Requisitos verificables

- La tienda de la entrega arranca con el perfil metrics y registra tráfico, también cobros fallidos (el autograding los provoca durante 30 s)
- 01-pedidos-por-segundo.promql — ¿Cuántos pedidos por segundo entran?
- 02-pedidos-fallidos-por-codigo.promql — ¿Cuántos pedidos por segundo fallan, y con qué código de estado?
- 03-fraccion-de-pedidos-fallidos.promql — ¿Qué fracción de los pedidos falla?
- 04-cobros-fallidos-por-motivo.promql — ¿Cuántos cobros han fallado en la última hora, y por qué motivo?
- 05-checkout-p50.promql — ¿Cuánto tarda un checkout en el percentil 50?
- 06-checkout-p95.promql — ¿Cuánto tarda un checkout en el percentil 95?
- 07-checkout-p99.promql — ¿Cuánto tarda un checkout en el percentil 99?
- 08-latencia-de-cada-paso.promql — ¿Qué paso del checkout tarda más? Percentil 95 de las tres llamadas que hace pedidos: la ficha y la reserva en catalogo y el cobro en pagos
- 09-cobros-fantasma-por-segundo.promql — ¿Cuántos cobros por segundo aprueba pagos en pedidos que acaban fallando?
- 10-aciertos-de-cache.promql — ¿Qué fracción de las lecturas de producto sirve la caché de Valkey?
- 11-notificaciones-por-resultado.promql — ¿Cuántas notificaciones por segundo se envían y cuántas se descartan?
- 12-peticiones-por-servicio.promql — ¿Cuántas peticiones por segundo atiende cada servicio?
- 13-errores-5xx-por-servicio.promql — ¿Qué fracción de las peticiones de cada servicio responde 5xx?
- 14-rutas-mas-lentas.promql — ¿Cuáles son las tres rutas más lentas de la tienda en el percentil 95?
- 15-memoria-por-servicio.promql — ¿Cuánta memoria usa cada servicio de la tienda?
- 16-cpu-por-servicio.promql — ¿Cuánta CPU usa cada servicio de la tienda?
- 17-cpu-del-host-ocupada.promql — ¿Qué fracción de la CPU del host está ocupada?
- 18-memoria-del-host-disponible.promql — ¿Qué fracción de la memoria del host está disponible?
- 19-reinicios-por-servicio.promql — ¿Cuántas veces se ha reiniciado cada servicio de la tienda en la última hora?
- 20-pedidos-en-la-ultima-hora.promql — ¿Cuántos pedidos se han creado en la última hora?
- Los percentiles del checkout están ordenados: p50 ≤ p95 ≤ p99
- Los cuatro percentiles de la libreta se calculan con histogram_quantile sobre los buckets, agrupando por le

Compruébalos desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 04
```

## Criterios de calidad (revisión manual)

| Criterio | Puntos |
|---|:--:|
| Cada consulta usa los selectores justos: filtra por `job` y `route` cuando la pregunta es de un endpoint, sin expresiones regulares donde basta `=` | 10 |
| Las consultas largas se leen: una operación por línea, sangrada, como las de la solución de los labs | 10 |
| Ninguna consulta repite un error del lab 05 (rate de gauge, rate después de sum, media de percentiles, histogram_quantile sin `le`) | 10 |
| Las consultas que pueden salir vacías o ruidosas (09, 12, 13) llevan un comentario que dice cuándo y por qué | 10 |

---

[← Lab 06](../2-practicas/lab-06-la-api-con-curl-y-jq/README.md) · [Rúbrica →](../rubrica-evaluacion.md)
