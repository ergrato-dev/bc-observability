# Autograding

`scripts/verificar-semana.sh` te dice qué te falta antes de entregar. No sabe nada de ninguna semana en concreto: lee `bootcamp/week-NN-*/checks.json` y ejecuta lo que ahí ponga, en tu máquina, contra el laboratorio levantado.

---

## Uso

```bash
./scripts/verificar-semana.sh --doctor   # comprueba tu entorno
./scripts/lab-up.sh metrics              # el perfil que pide la semana
./scripts/verificar-semana.sh 03         # comprueba la Semana 03
```

Salida:

```
Semana 03 — Métricas e instrumentación con Prometheus  [perfil: metrics]

  ✅ catalogo expone /metrics en formato Prometheus
  ✅ Prometheus tiene todos los servicios de la tienda en UP
  ❌ pedidos mide la duración de las peticiones con un histograma
     pista: 2-practicas/lab-02-metricas-red/README.md, paso 4

  8/9 comprobaciones superadas.
```

Sale con 0 si pasan todas, con 1 si falla alguna. **Cada pista dice en qué lab y en qué paso se arregla**: si una pista no lleva ahí, es un fallo del material y merece un issue.

---

## Formato de `checks.json`

Un archivo por semana, en la raíz de la carpeta de la semana.

```json
{
  "semana": "03",
  "titulo": "Métricas e instrumentación con Prometheus",
  "perfil": "metrics",
  "checks": [
    {
      "id": "catalogo-metrics",
      "descripcion": "catalogo expone /metrics en formato Prometheus",
      "cmd": "curl -sf http://127.0.0.1:8001/metrics",
      "assert": "stdout~^# TYPE ",
      "pista": "2-practicas/lab-01-primer-metrics/README.md, paso 3"
    },
    {
      "id": "targets-up",
      "descripcion": "Prometheus tiene todos los servicios de la tienda en UP",
      "cmd": "curl -sf 'http://127.0.0.1:9090/api/v1/query' --data-urlencode 'query=min(up{job=~\"tienda-.*\"})' | jq -r '.data.result[0].value[1]'",
      "assert": "stdout~^1$",
      "pista": "2-practicas/lab-04-service-discovery/README.md, paso 3"
    }
  ]
}
```

### Campos

| Campo | Obligatorio | Qué es |
|---|:--:|---|
| `semana` | sí | Dos dígitos |
| `titulo` | sí | Tema de la semana, igual que en el índice |
| `perfil` | no | Perfil de laboratorio que tiene que estar levantado (solo informativo) |
| `checks[].id` | sí | Identificador estable en kebab-case. **Nunca se renombra** |
| `checks[].descripcion` | sí | Qué se comprueba, en una línea. **Se copia literal** a `3-proyecto/README.md` |
| `checks[].cmd` | sí | Comando bash que se ejecuta desde la raíz del repositorio |
| `checks[].assert` | sí | Qué tiene que cumplirse. Ver la tabla siguiente |
| `checks[].pista` | sí | Archivo y paso donde se arregla |

### Aserciones

| `assert` | Se cumple si |
|---|---|
| `exit0` | el comando sale con código 0 |
| `exit!=0` | el comando sale distinto de 0 |
| `exit=N` | el comando sale exactamente con el código `N` |
| `stdout~RE` | la salida (stdout + stderr) casa con la expresión regular extendida `RE` |
| `stdout!~RE` | la salida **no** casa con `RE` |

Ningún campo puede contener un tabulador ni un salto de línea.

### Marcadores

| Marcador | Se sustituye por |
|---|---|
| `{raiz}` | Ruta absoluta del repositorio |
| `{semana}` | Ruta de la carpeta de la semana, p. ej. `bootcamp/week-03-metricas_y_prometheus` |
| `{proyecto}` | `{semana}/3-proyecto/starter`; con `ENTREGA=solucion`, `{semana}/3-proyecto/solucion` |

Apunta a los archivos del proyecto siempre con `{proyecto}`, nunca con `3-proyecto/starter` literal: así la misma comprobación valida la solución de referencia con `ENTREGA=solucion ./scripts/verificar-semana.sh NN`.

---

## Reglas de diseño

1. **El `checks.json` se escribe antes que el contenido.** Define qué es entregable y, por tanto, qué tienen que enseñar los labs.
2. **Entre 6 y 18 comprobaciones**, creciendo con la complejidad de la semana.
3. **Una comprobación, un hecho.** Si la descripción necesita una "y", son dos.
4. **`descripcion` se copia palabra por palabra** a `3-proyecto/README.md § ✅ Requisitos verificables`.
5. **Cero lógica de la semana en `verificar-semana.sh`.** Si una comprobación necesita código imperativo, va a la rúbrica manual.
6. **La comprobación no puede pasar por accidente.** `test -f prometheus.yml` se cumple con un archivo vacío. Comprueba comportamiento: consulta el backend y mira qué devuelve.
7. **Solo `127.0.0.1`.** Ninguna comprobación sale a internet ni necesita privilegios.
8. **Tolerante al tiempo.** Las señales tardan en llegar (intervalo de scrape, batch del Collector). Si una comprobación depende de tráfico reciente, consulta una ventana (`[5m]`) o genera el tráfico en el propio `cmd` y espera con un bucle acotado, nunca con un `sleep` fijo largo.

---

## Lo que sí se puede comprobar

Cada backend tiene una API HTTP, así que casi todo es verificable con `curl` + `jq`:

```json
{ "id": "logs-json",
  "descripcion": "pedidos escribe sus logs en JSON con request_id",
  "cmd": "docker compose -f app/compose.yaml logs --no-log-prefix --tail 20 pedidos | jq -e 'select(.request_id)' >/dev/null",
  "assert": "exit0",
  "pista": "2-practicas/lab-02-structlog/README.md, paso 5" }
```

```json
{ "id": "regla-alerta",
  "descripcion": "Las reglas de alerta pasan sus tests unitarios",
  "cmd": "docker run --rm -v {raiz}/{proyecto}:/w -w /w --entrypoint promtool prom/prometheus:<versión> test rules tests.yml",
  "assert": "stdout~SUCCESS",
  "pista": "2-practicas/lab-05-promtool/README.md, paso 2" }
```

```json
{ "id": "traza-asincrona",
  "descripcion": "La traza de un pedido llega hasta notificaciones",
  "cmd": "curl -sf 'http://127.0.0.1:16686/api/traces?service=pedidos&limit=20' | jq -r '[.data[].processes[].serviceName] | unique | join(\",\")'",
  "assert": "stdout~notificaciones",
  "pista": "2-practicas/lab-04-rabbitmq/README.md, paso 6" }
```

```json
{ "id": "sin-pii",
  "descripcion": "Ningún log de Loki contiene un número de tarjeta",
  "cmd": "curl -sfG http://127.0.0.1:3100/loki/api/v1/query_range --data-urlencode 'query={service_name=~\".+\"} |~ \"[0-9]{16}\"' | jq '.data.result | length'",
  "assert": "stdout~^0$",
  "pista": "2-practicas/lab-05-redaccion/README.md, paso 3" }
```

## Lo que no se puede comprobar

- Que un dashboard sea **útil** o una alerta **accionable**. Eso es rúbrica manual.
- Que entiendas lo que configuraste. Eso son las preguntas de Conocimiento.
- Que el diseño sea **el bueno**.

Por eso el Producto vale 30% y solo 60 de sus 100 puntos son automáticos.

---

## Escribir una comprobación nueva

1. Ejecuta el comando **a mano**, con un caso que pasa y otro que falla. Si no distingue los dos, la comprobación no vale.
2. Comprueba el código de salida con `echo $?`.
3. Añádela al `checks.json` con su `pista`.
4. Copia la `descripcion` al `3-proyecto/README.md`.
5. Corre `./scripts/verificar-semana.sh NN`: tiene que **fallar** contra el starter y **pasar** contra la solución. Una comprobación que nunca ha estado en rojo no se ha probado.

---

[← Volver al índice de documentación](README.md)
