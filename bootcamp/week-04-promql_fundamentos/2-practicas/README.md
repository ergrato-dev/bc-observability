# Prácticas — Semana 04

Seis labs de unos 60 minutos. Esta semana no cambias código: consultas la tienda que instrumentaste en la semana 03. Las consultas que escribas aquí son las de la libreta del proyecto. Antes de empezar, desde la raíz del repositorio:

```bash
export TIENDA=bootcamp/week-04-promql_fundamentos/3-proyecto/starter
./scripts/lab-up.sh metrics
```

Deja la tienda en marcha unos minutos antes del lab 02: las ventanas de 5 minutos necesitan 5 minutos de datos, y las de 1 hora, una hora.

| # | Lab | Qué haces | Duración |
|---|---|---|:--:|
| 01 | [Selectores y vectores](lab-01-selectores/README.md) | Matchers, expresiones regulares ancladas, instant y range vectors | 60 min |
| 02 | [Tasas](lab-02-tasas/README.md) | `rate`, `irate`, `increase` y los reinicios de los contadores | 60 min |
| 03 | [Agregaciones y aritmética](lab-03-agregaciones/README.md) | `sum by`, `without`, proporciones y los cobros fantasma | 60 min |
| 04 | [Percentiles](lab-04-percentiles/README.md) | `histogram_quantile` y su error según los buckets | 60 min |
| 05 | [Errores frecuentes](lab-05-errores-frecuentes/README.md) | Cinco consultas que devuelven un número falso sin dar error | 60 min |
| 06 | [La API con curl y jq](lab-06-la-api-con-curl-y-jq/README.md) | Consultas desde la terminal y un informe de la libreta en bash | 60 min |

---

[← Agregaciones y percentiles](../1-teoria/02-agregaciones-y-percentiles.md) · [Lab 01 →](lab-01-selectores/README.md)
