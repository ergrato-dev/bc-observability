# PLANTILLA DE SEMANA — bc-observability

> Archivo de referencia. Copia esta estructura al crear contenido nuevo.
> Reglas completas en [`CLAUDE.md`](../CLAUDE.md); generación con `.claude/commands/gen-semana.md`.

---

## README.md de semana

~~~markdown
# Semana NN — Título del Tema

## Descripción

<2-3 oraciones. Qué aprenderás. Por qué importa cuando algo falla en producción.>

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Instrumentar <qué> con <herramienta>
- Diagnosticar <avería concreta> con <señal>
- Construir <artefacto verificable> para la tienda

## Prerrequisitos

- Semanas 01–NN-1 completadas
- Perfil de laboratorio: `<perfil>` (`./scripts/lab-up.sh <perfil>`, ~X GB de RAM)

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-contexto.md](1-teoria/01-contexto.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-nombre](2-practicas/lab-01-nombre/) | 60 min |
| 2 | Lab | [lab-02-nombre](2-practicas/lab-02-nombre/) | 60 min |
| 3 | Lab | [lab-03-nombre](2-practicas/lab-03-nombre/) | 60 min |
| 4 | Lab | [lab-04-nombre](2-practicas/lab-04-nombre/) | 60 min |
| 5 | Lab | [lab-05-nombre](2-practicas/lab-05-nombre/) | 60 min |
| 6 | Lab | [lab-06-nombre](2-practicas/lab-06-nombre/) | 60 min |
| — | Proyecto | [Capa NN de la tienda](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — <tema>
...
[60 min] lab-06 — <tema>
[3 h]    Proyecto: <nombre>
```

## Verificación de completitud

Desde la raíz del repositorio, con el laboratorio levantado:

```bash
./scripts/verificar-semana.sh NN
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Semana NN-1 — Tema](../week-NN-1-slug/README.md) | **Semana NN — Tema** | [Semana NN+1 — Tema](../week-NN+1-slug/README.md) |

[← Volver al índice del bootcamp](../README.md)
~~~

---

## README.md de lab

~~~markdown
# Lab NN — Título del Lab

⏱ Duración estimada: ~60 min

## Objetivo

<Verbo en infinitivo> <qué> usando <qué herramienta o señal>.

## Contexto

<Máx. 3 párrafos o 5 bullets. Sin repetir la teoría.>

## Instrucciones

1. Levanta el perfil de la semana:
   ```bash
   ./scripts/lab-up.sh <perfil>
   ```
2. Abre `starter/<archivo>` y resuelve los `TODO`.
3. Comprueba:
   ```bash
   curl -s 'http://127.0.0.1:9090/api/v1/query?query=up' | jq '.data.result | length'
   ```
   Debes ver:
   ```
   <salida esperada exacta>
   ```

## Criterios de éxito

- [ ] <consulta o comando> devuelve <valor>
- [ ] <la avería inyectada> aparece en <señal> en menos de <tiempo>

## Reto extra

<Extensión opcional.>

---

[← Lab anterior](../lab-0N-1-nombre/README.md) · [Lab siguiente →](../lab-0N+1-nombre/README.md)
~~~

---

## rubrica-evaluacion.md

~~~markdown
# Rúbrica de evaluación — Semana NN

> <Tema>. Se aprueba con un **mínimo del 70 % en cada evidencia**, no en el promedio.

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | 10 preguntas conceptuales, respuestas en `<details>` |
| 💪 Desempeño | 40% | Labs 01 a 06 y sus criterios de éxito |
| 📦 Producto | 30% | 60 pts de autograding + 40 pts de calidad manual |

## 🧠 Conocimiento (30%)

Responde por escrito antes de abrir cada respuesta. Cada pregunta vale 3 puntos: 1 por la idea correcta y 2 por el razonamiento.

**1.** <Escenario concreto que pide explicar el porqué, no recordar sintaxis.>

<details>
<summary>Respuesta</summary>

<Respuesta razonada.>

</details>

## 💪 Desempeño (40%)

| Lab | Criterio | Puntos |
|---|---|:--:|
| 01 — <nombre> | <criterio verificable> | X |
| **Total** | | **40** |

## 📦 Producto (30%)

**Autograding (60 puntos)**: `./scripts/verificar-semana.sh NN` con N/N. Cada comprobación en rojo resta 60/N puntos.

**Calidad manual (40 puntos)**:

| Criterio | Puntos |
|---|:--:|
| <criterio> | X |
| **Total** | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Secreto real comiteado | Grave: −10 y retirarlo del historial |
| Datos personales en logs, spans o labels | Grave: −10 |
| Imagen sin tag o con `latest` | Grave: −5 |
| Puerto publicado en `0.0.0.0` en lugar de `127.0.0.1` | Grave: −5 |
| `pip`/`requirements.txt` o `npm`/`package-lock.json` en la entrega | −5 |
| Configuración hecha con clics y no provisionada en archivos | −3 |
| `TODO` sin resolver en la entrega | −1 por cada uno |

---

[← Proyecto](3-proyecto/README.md) · [Ebooks gratuitos →](4-recursos/ebooks-free/README.md)
~~~

---

## 3-proyecto/README.md

~~~markdown
# Proyecto — Capa NN de la tienda: <nombre>

⏱ 3 h

## Contexto

<Situación concreta: qué pregunta no se puede responder hoy sobre la tienda y quién la necesita.>

## Punto de partida

```
starter/
├── <archivos que entrega el starter>
```

## Entregables

1. <entregable verificable>

## ✅ Requisitos verificables

<Las `descripcion` de checks.json, copiadas literalmente, una por línea.>

## Calidad (40 pts)

<Criterios de la rúbrica.>

## Entrega

```bash
./scripts/verificar-semana.sh NN
git add . && git commit -m "feat(semana-NN): <capa>"
```

---

[← Lab 06](../2-practicas/lab-06-nombre/README.md) · [Rúbrica →](../rubrica-evaluacion.md)
~~~

---

## checks.json

Contrato completo en [`docs/autograding.md`](../docs/autograding.md).

```json
{
  "semana": "NN",
  "titulo": "Tema",
  "perfil": "core",
  "checks": [
    {
      "id": "targets-up",
      "descripcion": "Prometheus tiene todos los servicios de la tienda en UP",
      "cmd": "curl -sf 'http://127.0.0.1:9090/api/v1/query?query=min(up{job=~\"tienda-.*\"})' | jq -r '.data.result[0].value[1]'",
      "assert": "stdout~^1$",
      "pista": "2-practicas/lab-04-service-discovery/README.md, paso 3"
    }
  ]
}
```
