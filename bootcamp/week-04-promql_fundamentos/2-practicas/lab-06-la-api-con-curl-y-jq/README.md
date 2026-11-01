# Lab 06 — La API de Prometheus con curl y jq

⏱ Duración estimada: ~60 min

## Objetivo

Consultar Prometheus desde la terminal con su API HTTP y escribir un informe en bash que responda las preguntas de la libreta sin abrir el navegador.

## Contexto

- Todo lo que hace la UI pasa por la API HTTP: `/api/v1/query` (un instante), `/api/v1/query_range` (una gráfica), `/api/v1/series` y `/api/v1/label/<nombre>/values` (qué existe). Grafana, el autograding y cualquier script usan la misma.
- La respuesta es JSON con `status`, y `data.resultType` y `data.result` si va bien, o `errorType` y `error` si no. El valor de cada muestra es una pareja `[timestamp, "valor"]`: el valor viene **como cadena**, porque puede ser `NaN` o `+Inf`.
- `./scripts/promql.sh`, que llevas usando toda la semana, son 40 líneas de esto. Léelo antes de empezar.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada.

1. Una consulta instantánea. `--data-urlencode` codifica llaves, comillas y espacios por ti:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=up' | jq .
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=up' | jq -r '.data.result[] | [.metric.job, .value[1]] | @tsv'
   ```
   La segunda forma es la que se usa en scripts: una línea por serie, campos separados por tabuladores.

2. Qué existe, sin traer muestras:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/label/job/values | jq -c .data
   curl -s 127.0.0.1:9090/api/v1/series --data-urlencode 'match[]=orders_created_total' | jq -c .data
   ```
   Con `/label/route/values` lista todas las rutas que conoce Prometheus. Es lo primero que se hace con una métrica desconocida.

3. Una consulta en otro instante y un rango. El parámetro `time` fija el instante de evaluación; `query_range` evalúa la consulta en cada `step` entre `start` y `end`, que es lo que dibuja una gráfica:
   ```bash
   now=$(date +%s)
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=sum(up)' -d time=$((now-600)) | jq -c .data.result
   curl -s 127.0.0.1:9090/api/v1/query_range --data-urlencode 'query=sum(rate(orders_created_total[1m]))' \
     -d start=$((now-300)) -d end=$now -d step=60 | jq -c '.data.result[0].values'
   ```
   Seis puntos, uno por minuto. Ahora `resultType` es `matrix` y cada serie trae `values` (plural).

4. Los errores. Prometheus responde `status: "error"` con un mensaje que dice dónde falla:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query --data-urlencode 'query=sum(up' | jq -c .
   ```
   Un script tiene que comprobar `status` antes de leer `data`, y distinguir entre "error" y "resultado vacío": una consulta bien escrita sobre una métrica que no existe responde `success` con `result: []`.

5. Una consulta desde un archivo. `curl` lee el valor de `--data-urlencode 'query@archivo'`, y Prometheus acepta comentarios `#` dentro de la consulta. Así evalúa el autograding la libreta:
   ```bash
   curl -s 127.0.0.1:9090/api/v1/query \
     --data-urlencode "query@bootcamp/week-04-promql_fundamentos/3-proyecto/starter/libreta/01-pedidos-por-segundo.promql" | jq -c .
   ```
   En el starter da `parse error: no expression found in input`: el archivo solo tiene comentarios. Cuando la escribas, el mismo comando devuelve el resultado.

6. Escribe el informe. Copia `starter/informe.sh` y completa sus TODO: recibe la carpeta de la libreta, evalúa cada `.promql` con la API, imprime la pregunta (la primera línea del archivo) y debajo cada serie con sus labels y su valor redondeado, y avisa de las consultas que dan error o vienen vacías. Al final sale con 1 si alguna falló.
   ```bash
   ./informe.sh bootcamp/week-04-promql_fundamentos/3-proyecto/starter/libreta
   ```
   Contra la libreta del starter, las 20 consultas fallan. Úsalo durante el proyecto para ver tu avance.

## Criterios de éxito

- [ ] Sabes leer el valor de una muestra con `jq` y por qué viene como cadena
- [ ] Distingues una consulta con error de una consulta vacía por el JSON de la respuesta
- [ ] `informe.sh` pasa `shellcheck`, imprime las 20 preguntas con sus resultados y sale con 1 si alguna consulta falla

## Reto extra

Añade a `informe.sh` una opción `--hace <minutos>` que evalúe toda la libreta en ese instante del pasado con el parámetro `time`. Compara la tienda ahora y hace 30 minutos.

---

[← Lab 05](../lab-05-errores-frecuentes/README.md) · [Proyecto →](../../3-proyecto/README.md)
