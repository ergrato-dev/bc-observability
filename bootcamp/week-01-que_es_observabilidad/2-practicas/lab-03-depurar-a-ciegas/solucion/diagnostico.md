# Diagnóstico del lab 03 (SOLUCIÓN)

Las cifras exactas cambian en cada ejecución; las proporciones no.

## Avería 1

- **Síntoma** (qué ve el cliente): un tercio de los checkouts devuelven 402 (cobro rechazado). El resto de la tienda funciona.
- **Servicio origen:** `pagos`, que responde 503 a cerca del 35 % de los cobros.
- **Evidencia** (comandos y salida):

  ```
  $ docker compose ... logs --no-log-prefix --since 60s pedidos | grep 'POST /orders' | grep -oE '" [0-9]{3} ' | sort | uniq -c
       16 " 201
        9 " 402
  $ docker compose ... logs --no-log-prefix --since 60s pagos | grep 'POST /charges' | grep -oE '" [0-9]{3} ' | sort | uniq -c
       16 " 201
        9 " 503
  ```

  Mismo número de 402 en `pedidos` que de 503 en `pagos`: la relación es directa. `catalogo` no muestra errores.

- **Pedidos afectados** (% aproximado): 35 %.

## Avería 2

- **Síntoma:** cerca de la mitad de los checkouts devuelven 402 y tardan unos 2 s.
- **Servicio origen:** la red entre `pedidos` y `pagos` (latencia de 1 a 2,6 s). `pagos` está sano.
- **Evidencia:**

  ```
  $ docker compose ... logs --no-log-prefix --since 60s pedidos | grep -E 'POST /orders|ERROR' | ...
       13 "POST /orders HTTP/1.1" 402 Payment Required
       12 ERROR:    Error llamando a pagos: ReadTimeout('')
        9 "POST /orders HTTP/1.1" 201 Created
  $ docker compose ... logs --no-log-prefix --since 60s pagos | grep -oE '"POST /charges[^"]*" [0-9]{3}' | sort | uniq -c
       21 "POST /charges HTTP/1.1" 201
        1 "POST /charges HTTP/1.1" 503
  ```

- **¿Por qué `pagos` y `pedidos` cuentan historias distintas?** `pagos` cobra y responde 201, pero la respuesta tarda más de 2 s en llegar. `pedidos` corta a los 2 s (`PAGOS_TIMEOUT_SECONDS`), libera el stock, guarda el pedido como `payment_failed` y responde 402. Resultado: clientes cobrados sin pedido. Los dos logs son ciertos; sin duración ni un identificador común no hay forma de unirlos.

## Lo que me faltó

| Avería | Dato que me faltó | Para qué lo habría usado |
|---|---|---|
| 1 | Tasa de errores por servicio, ya calculada | Ver de un vistazo que el único servicio con errores era `pagos` |
| 1 | El motivo del 402 en la línea de `pedidos` | Saber que el cobro falló por un 503 sin cruzar logs a mano |
| 2 | Duración de cada petición, en `pedidos` y en `pagos` | Ver que `pagos` respondía rápido y `pedidos` esperaba 2 s: el tiempo se perdía entre los dos |
| 2 | Un identificador común entre la petición de `pedidos` y la de `pagos` | Unir "cobro aprobado" con "pedido fallido" y contar cobros fantasma |
| Ambas | Logs con estructura (JSON) | Filtrar por campo en lugar de por regex |
