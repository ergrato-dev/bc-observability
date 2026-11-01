# Lab 06 — Tests unitarios con promtool

⏱ Duración estimada: ~60 min

## Objetivo

Escribir tests unitarios de las recording rules con `promtool test rules`, con series de entrada inventadas y valores esperados calculados a mano, y comprobar que detectan los errores que importan.

## Contexto

- Una regla mal escrita no da error: guarda un número falso con un nombre correcto (reto del lab 05). Un test fija unas series de entrada, evalúa las reglas en un instante y compara el resultado con lo que tú has calculado.
- Las series se escriben en notación de expansión: `'0+9x40'` empieza en 0 y suma 9 en cada uno de 40 pasos. Con un `interval` de 15 s, eso es una tasa de 0,6/s. `_` es un hueco sin muestra y `stale`, una marca de obsolescencia.
- Un test que pasa no demuestra nada si también pasaría con la regla rota. La prueba de un test es romper la regla a propósito y ver que falla.

## Instrucciones

Desde la raíz del repositorio. Trabajas en `$TIENDA/prometheus/tests/tienda_test.yml`. Para no repetir el comando de Docker, define una función en tu terminal:

```bash
promtool() { docker run --rm -u "$(id -u)" -v "$PWD/$TIENDA/prometheus:/w" -w /w --entrypoint promtool prom/prometheus:v3.15.1 "$@"; }
promtool test rules tests/tienda_test.yml
```

1. El starter tiene `tests: []`: pasa sin probar nada. Ese es el primer peligro de un test.

2. El primer test. Cambia `tests: []` por un grupo con dos series de `pedidos`, una con `status_code="201"` a 0,6/s y otra con `"503"` a 0,2/s, y una de `catalogo` con `"200"` a 2/s. Evalúa `job:http_server_requests:rate5m` a los 10 minutos:
   ```yaml
   tests:
     - name: RED de pedidos y catalogo
       interval: 15s
       input_series:
         - series: 'http_server_request_duration_seconds_count{job="pedidos", instance="tienda-pedidos-1", method="POST", route="/orders", status_code="201"}'
           values: '0+9x40'      # 0,6/s
         # TODO: la serie 503 de pedidos y la 200 de catalogo
       promql_expr_test:
         - expr: job:http_server_requests:rate5m
           eval_time: 10m
           exp_samples:
             - labels: 'job:http_server_requests:rate5m{job="pedidos"}'
               value: 0.8
             # TODO: catalogo
   ```
   Ejecuta `promtool test rules tests/tienda_test.yml`. Si falla con `got: 7.999999999999999E-01`, añade `fuzzy_compare: true` al principio del archivo: compara con tolerancia.

3. Errores y su ratio. Añade al mismo grupo los `promql_expr_test` de `job:http_server_requests_errors:rate5m` y de `job:http_server_requests_errors:ratio_rate5m`, con sus valores calculados a mano. Añade también uno que compruebe que `catalogo`, sin ninguna serie 5xx, **no** tiene ratio:
   ```yaml
         - expr: job:http_server_requests_errors:ratio_rate5m{job="catalogo"}
           eval_time: 10m
           exp_samples: []
   ```

4. ¿Detecta tu test que la regla de errores cuente también los 4xx? Rómpela en una copia y ejecuta los tests contra ella:
   ```bash
   t=$(mktemp -d); cp -r "$TIENDA/prometheus/." "$t"; sed -i 's/5\.\./[45]../' "$t"/rules/*.yml
   docker run --rm -v "$t:/w" -w /w --entrypoint promtool prom/prometheus:v3.15.1 test rules tests/tienda_test.yml; rm -rf "$t"
   ```
   Pasa: tus series de entrada no tienen ningún 4xx, así que contar o no los 4xx da igual. Añade una serie `status_code="404"` de `pedidos` a 0,2/s, recalcula los valores esperados (el total cambia, los errores no) y repite: ahora la regla rota falla.

5. Un reinicio. `rate` corrige los reinicios de los counters y `deriv` no; sobre una serie que sube recta las dos dan lo mismo. Escribe un test para `job:orders_created:rate5m` con un `orders_created_total` a 0,4/s que se reinicia a los 2,5 minutos, y evalúalo a los 6 minutos, con el reinicio dentro de la ventana:
   ```yaml
         values: '0+6x10 6+6x20'   # tras el reinicio, el primer scrape ya ve 6
   ```
   Comprueba que con `deriv` en lugar de `rate` (rompiendo la regla en una copia, como en el paso 4) el test falla.

6. Cobertura. Escribe un grupo para el percentil (cuatro buckets de `pagos`; calcula el p95 a mano como en la teoría) que pruebe también la regla de los buckets, y otro para el negocio (`orders_created`, `payment_failures` con dos `reason`, la caché con `hit` y `miss`). Al final, cada regla de `rules/` tiene que aparecer en algún test:
   ```bash
   for r in $(grep -ho 'record: *[^ ]*' "$TIENDA"/prometheus/rules/*.yml | awk '{print $2}'); do
     grep -qF "$r" "$TIENDA"/prometheus/tests/*.yml || echo "sin test: $r"
   done
   ```

## Criterios de éxito

- [ ] `promtool test rules tests/tienda_test.yml` devuelve `SUCCESS`
- [ ] Con la regla de errores rota (`[45]..`) o la de pedidos con `deriv`, los tests fallan
- [ ] Ninguna regla sale en el bucle del paso 6

## Reto extra

`promtool test rules` también prueba alertas (`alert_rule_test`), que llegan en la semana 07. Mientras tanto, añade `--run` para ejecutar un solo grupo por nombre (`promtool test rules --run 'Negocio' tests/tienda_test.yml`): útil cuando el archivo crece.

---

[← Lab 05](../lab-05-recording-rules/README.md) · [Proyecto →](../../3-proyecto/README.md)
