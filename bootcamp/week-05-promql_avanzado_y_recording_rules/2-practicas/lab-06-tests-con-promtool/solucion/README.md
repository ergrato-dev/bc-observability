# Solución del lab 06

Los tests completos están en [`3-proyecto/solucion/prometheus/tests/tienda_test.yml`](../../../3-proyecto/solucion/prometheus/tests/tienda_test.yml).

## Paso 4

Con la serie 404 a 0,2/s, `pedidos` atiende 0,6 + 0,2 + 0,2 = 1 petición por segundo, 0,2 de ellas 5xx: el ratio esperado es 0,2. Con la regla rota, los 404 cuentan como errores y el ratio sale 0,4: el test falla.

## Paso 5

La ventana `(1m, 6m]` contiene las muestras 30…60 y, tras el reinicio, 6…84. `rate` suma el valor previo al reinicio y obtiene 114 en 285 s, que extrapolado a 300 s es 0,4/s. `deriv` ajusta una recta a muestras que suben, caen a 6 y vuelven a subir: la pendiente sale lejos de 0,4 y el test falla.

## Paso 6

Para el percentil: 15 cobros cada 15 s, 9 en `le="0.1"` y 15 en `le="0.25"`. El 95 % cae en el bucket de 0,1 a 0,25 s, que empieza en el 60 %: 0,1 + (0,95 − 0,6) / (1 − 0,6) × 0,15 = 0,23125.

## Reto extra

`--run` acepta una expresión regular sobre el `name` de los grupos de test.

---

[← Lab 06](../README.md)
