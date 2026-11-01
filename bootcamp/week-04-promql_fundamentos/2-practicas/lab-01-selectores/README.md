# Lab 01 — Selectores y vectores

⏱ Duración estimada: ~60 min

## Objetivo

Seleccionar exactamente las series que necesitas con matchers y distinguir un instant vector de un range vector.

## Contexto

- Una consulta PromQL se evalúa en un instante. Un **instant vector** devuelve, por cada serie, la última muestra anterior a ese instante (si tiene menos de 5 minutos). Un **range vector** (`[1m]`) devuelve todas las muestras de esa ventana.
- Los matchers filtran por labels: `=`, `!=`, `=~` y `!~`. Las expresiones regulares son RE2 y van **ancladas**: `=~"/prod"` solo casa con `/prod` exacto.
- `./scripts/promql.sh` evalúa una consulta y escribe una línea por serie. Lo usa el autograding y lo usarás en todos los labs; en el lab 06 verás qué hace por dentro.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada:

```bash
export TIENDA=bootcamp/week-04-promql_fundamentos/3-proyecto/starter
./scripts/lab-up.sh metrics
```

Copia `starter/consultas.md` a tu carpeta de trabajo y apunta en él cada consulta que escribas.

1. Abre `http://127.0.0.1:9090/query`, escribe `up` y pulsa *Execute* en la pestaña *Table*. Haz lo mismo desde la terminal:
   ```bash
   ./scripts/promql.sh up
   ```
   Siete series, una por target. Cada línea es un label set y su valor en este instante.

2. Escribe en `consultas.md` los selectores que devuelven:
   - `up` solo de `pagos`
   - `up` de todos los targets menos los exporters (`node-exporter` y `cadvisor`), con `!~`
   - `up` de `catalogo` y `pedidos`, con una sola expresión regular

   Comprueba cada uno con `./scripts/promql.sh`.

3. Mira qué series tiene el histograma de `catalogo`:
   ```bash
   ./scripts/promql.sh 'http_server_request_duration_seconds_count{job="catalogo"}'
   ```
   Escribe el selector que devuelve solo las rutas que empiezan por `/products/` (las de un producto concreto). Prueba antes `route=~"/products/"` y explica por qué no devuelve nada.

4. Selecciona por nombre de métrica con el label especial `__name__`:
   ```bash
   ./scripts/promql.sh '{__name__=~"orders_.*|payment_.*"}'
   ```
   Escribe el selector que devuelve todas las métricas de negocio de la tienda (las cuatro de la semana 03) y ninguna más.

5. Pide un range vector, primero a `promql.sh` y después a la API directamente:
   ```bash
   ./scripts/promql.sh 'up{job="pagos"}[1m]'
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=up{job="pagos"}[1m]' | jq -c '.data.result[0].values'
   ```
   Cuatro muestras, separadas unos 15 s: el `scrape_interval`. Repite con `[5m]` y cuenta las muestras. Un range vector no se puede dibujar ni comparar: se le aplica una función que lo convierte en un instant vector (`rate`, `increase`, `max_over_time`…), que es lo que hace el lab 02.

6. Prueba el *lookback* de 5 minutos. Detén `pagos` y consulta `up{job="pagos"}` cada 10 segundos durante medio minuto; después vuelve a arrancarlo:
   ```bash
   docker compose -f app/compose.yaml stop pagos
   ./scripts/promql.sh 'up{job="pagos"}'
   docker compose -f app/compose.yaml start pagos
   ```
   La serie desaparece en lugar de quedarse en su último valor durante 5 minutos: al dejar de ser target, Prometheus escribe una marca de obsolescencia (*staleness marker*).

## Criterios de éxito

- [ ] `consultas.md` tiene los selectores de los pasos 2, 3 y 4 y cada uno devuelve exactamente las series pedidas
- [ ] Sabes explicar por qué `route=~"/products/"` no devuelve nada
- [ ] Sabes cuántas muestras tiene `[5m]` con un `scrape_interval` de 15 s y por qué

## Reto extra

`up` vale 1 si el último scrape funcionó. Escribe la consulta que devuelve solo los targets caídos (los que existen pero no responden) y pruébala parando `pagos` con `docker compose -f app/compose.yaml pause pagos`. ¿Por qué ahora sí sale un 0, y con `stop` no? Vuelve a dejarlo como estaba con `unpause`.

---

[← Prácticas](../README.md) · [Lab 02 →](../lab-02-tasas/README.md)
