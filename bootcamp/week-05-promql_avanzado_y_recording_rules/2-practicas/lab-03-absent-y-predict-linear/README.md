# Lab 03 — absent y predict_linear

⏱ Duración estimada: ~60 min

## Objetivo

Detectar series que faltan con `absent` y `absent_over_time`, y anticipar cuándo se agota un recurso con `deriv` y `predict_linear`.

## Contexto

- Una consulta sobre una serie que no existe no devuelve 0: no devuelve nada. Una alerta sobre "errores > 0" no puede saltar si el servicio ha dejado de exponer métricas. `absent(x)` devuelve una serie con valor 1 justo cuando `x` no tiene ninguna.
- `deriv(gauge[1h])` es la pendiente de un gauge por segundo, por regresión lineal. `predict_linear(gauge[1h], 4*3600)` estima su valor dentro de 4 horas siguiendo esa recta. Es la base de "el disco se llena en menos de 4 h", mejor alerta que "el disco está al 90 %".
- Ninguna de las dos funciona sobre counters: para eso están `rate` e `increase`.

## Instrucciones

Desde la raíz del repositorio, con la tienda de la semana levantada. Copia `starter/consultas.md` y `starter/llenar-disco.sh`.

1. Una serie que falta. Detén `pagos` y espera 30 s:
   ```bash
   docker compose -f app/compose.yaml stop pagos
   ./scripts/promql.sh 'up{job="pagos"} == 0'
   ./scripts/promql.sh 'absent(up{job="pagos"})'
   ```
   La primera no devuelve nada: la serie ya no existe (lab 01 de la semana 04). La segunda devuelve `job="pagos" 1`: `absent` copia los labels de igualdad del selector. Arranca `pagos` otra vez y repite.

2. `absent_over_time(x[5m])` devuelve 1 si `x` no ha tenido **ninguna** muestra en 5 minutos. Escribe la consulta que detecta que `pedidos` lleva 5 minutos sin crear ningún pedido. Pista: `orders_created_total` sigue existiendo aunque no suba; lo que deja de existir con 0 pedidos es su tasa por encima de 0. Compara con `absent_over_time(orders_created_total[5m])` y explica qué detecta cada una.

3. El espacio libre del disco donde Docker guarda los volúmenes:
   ```bash
   ./scripts/promql.sh 'node_filesystem_avail_bytes{mountpoint="/"}'
   ```
   Si tu Docker tiene `/var/lib/docker` en otro disco (`docker info | grep "Root Dir"` y `df` te lo dicen), usa ese `mountpoint`. Empieza a llenarlo:
   ```bash
   ./llenar-disco.sh
   ```

4. Pasados tres minutos, la pendiente en bytes por segundo:
   ```bash
   ./scripts/promql.sh 'deriv(node_filesystem_avail_bytes{mountpoint="/"}[3m])'
   ```
   Unos −5 MB/s (50 MB cada 10 s), más lo que escriba el resto de tu máquina. Dibújala en *Graph* con `rate(node_filesystem_avail_bytes{mountpoint="/"}[3m])` al lado: `rate` sobre un gauge que baja da un disparate (semana 04, lab 05).

5. ¿Cuándo se llena? Dos formas:
   ```bash
   ./scripts/promql.sh 'predict_linear(node_filesystem_avail_bytes{mountpoint="/"}[3m], 3600)'
   ./scripts/promql.sh 'node_filesystem_avail_bytes{mountpoint="/"} / -deriv(node_filesystem_avail_bytes{mountpoint="/"}[3m]) / 3600'
   ```
   La primera es el espacio libre estimado dentro de una hora. La segunda, las horas que faltan para llegar a 0 al ritmo actual. Escribe la condición de una alerta que salte si el disco se llenará en menos de 4 horas, con `predict_linear` y `< 0`.

6. Vacía el disco y mira cómo cambia la predicción:
   ```bash
   ./llenar-disco.sh --vaciar
   ```
   Con `[3m]`, la predicción da un salto en cuanto el volumen se borra y otro cuando la ventana deja de ver el llenado. Repite el paso 5 con `[30m]`: más estable y más lenta. La ventana decide cuánto historial cuenta como tendencia.

## Criterios de éxito

- [ ] Sabes por qué `up{job="pagos"} == 0` no devuelve nada con `pagos` parado y qué devuelve `absent`
- [ ] La consulta del paso 2 devuelve 1 solo cuando no hay pedidos
- [ ] Tienes la condición de alerta del paso 5 y has vaciado el volumen

## Reto extra

`predict_linear` acepta subconsultas. Proyecta la tasa de pedidos dentro de una hora con `predict_linear(sum(rate(orders_created_total[5m]))[30m:1m], 3600)`. ¿Tiene sentido para un tráfico generado por k6? ¿Y para el tráfico real de una tienda, que sube por la mañana y baja por la noche?

---

[← Lab 02](../lab-02-subconsultas-offset-y-arroba/README.md) · [Lab 04 →](../lab-04-native-histograms-y-tsdb/README.md)
