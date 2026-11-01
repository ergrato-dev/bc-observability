# CLAUDE.md — bc-observability

Guía de autoría del bootcamp. Es la **fuente única de verdad** de cómo se escribe el contenido de este repositorio; se carga automáticamente en cada sesión.

---

## Identidad del proyecto

| Dato | Valor |
|---|---|
| Nombre | bc-observability |
| Tipo | Bootcamp técnico, 100% orientado a la práctica |
| Duración | 22 semanas × 10 h = 220 horas (Zero to Advanced) |
| Modalidad | Autoestudio asincrónico |
| Nivel de entrada | Linux CLI y Docker Compose (ver prerrequisitos) |
| Nivel de salida | Diseña, opera y defiende una plataforma de observabilidad open source completa: logs, métricas, trazas y perfiles con OpenTelemetry, SLOs, alertas, escala, Kubernetes e IA aplicada |
| Entorno de prácticas | Docker Compose con perfiles; kind solo en la Semana 18 |
| Proyecto hilo conductor | `tienda`, app de microservicios en `app/`, entregada sin instrumentar ([`docs/proyecto-hilo-conductor.md`](docs/proyecto-hilo-conductor.md)) |
| Idioma de la prosa | Español con **tuteo** |
| Idioma del código | Inglés (variables, funciones, nombres de métricas, atributos, labels) |

## Prerrequisitos del bootcamp

| Bootcamp | Qué se asume |
|---|---|
| [`bc-linux-commandline`](https://github.com/ergrato-dev/bc-linux-commandline) | Shell, procesos, red desde la CLI, `jq`, bash con `set -euo pipefail` |
| [`bc-docker`](https://github.com/ergrato-dev/bc-docker) | Imágenes, Dockerfile multi-stage, redes, volúmenes, `docker compose` |
| [`bc-fastapi`](https://github.com/ergrato-dev/bc-fastapi) (recomendado) | Leer y modificar código FastAPI sin esfuerzo |
| [`bc-kubernetes`](https://github.com/ergrato-dev/bc-kubernetes) S01-04 | Solo para la Semana 18 |

---

## Reglas no negociables

1. **Tuteo, nunca voseo.** "puedes", "configura", "ejecuta", "tienes"; nunca "podés", "configurá", "ejecutá", "tenés", "vos". `scripts/verificar-enlaces.sh` lo comprueba.
2. **Solo open source ampliamente reconocido**: proyectos CNCF, OpenTelemetry, Prometheus, Grafana OSS y equivalentes con licencia aprobada por OSI. Nada SaaS, nada propietario, nada con licencias no OSI (ELv2, BSL, SSPL). Si una herramienta tiene edición comunitaria y comercial, se usa solo la comunitaria y se dice.
3. **Python = FastAPI + uv.** `pyproject.toml` + `uv.lock` comiteado, `uv sync --locked`, `uv run`. Nunca `pip`, nunca `requirements.txt`, nunca `venv` a mano. En Docker: `COPY --from=ghcr.io/astral-sh/uv:<versión fijada>`.
4. **Node.js = pnpm.** `pnpm-lock.yaml` comiteado, `pnpm install --frozen-lockfile`. Nunca `npm`, nunca `package-lock.json`, nunca `npx` (usa `pnpm dlx` o `pnpm exec`).
5. **Base de datos = PostgreSQL.** Toda persistencia relacional usa PostgreSQL (imagen oficial). Valkey solo como caché, RabbitMQ solo como cola.
6. **Imágenes con tag fijado.** Nunca `latest` ni sin tag. Versiones solo de [`docs/stack-versions.md`](docs/stack-versions.md); una versión entra ahí verificada (fecha y fuente) en la tanda que escribe la semana que la usa.
7. **Puertos solo en `127.0.0.1`.** Ningún `compose.yaml` publica un backend en `0.0.0.0`.
8. **La telemetría no lleva datos personales ni secretos.** Todo ejemplo que muestre PII la redacta o la marca como antipatrón.
9. **Ningún dato de telemetría sale a un LLM externo.** La IA del bootcamp corre en local con Ollama y modelos open-weight.
10. **Sin herramientas deprecadas.** Promtail (EOL), Jaeger v1, OpenTracing, OpenCensus y `docker-compose` v1 no aparecen salvo como nota histórica.

## Filosofía de contenido: 100% práctica

- **Teoría mínima:** solo el contexto indispensable para no perderse en el lab. Máximo 45 min por semana.
- **Labs primero:** el estudiante aprende haciendo, no leyendo.
- **Averías intencionadas:** la `tienda` trae fallos inyectables (`pagos` con latencia y errores configurables, toxiproxy, hot paths). El estudiante los diagnostica con la señal que esa semana enseña.
- **Progresión real:** cada semana añade una capa a la `tienda` y la siguiente parte de ella.
- **Verificable:** cada ejercicio termina en algo que se consulta (una query de Prometheus, una traza en Jaeger/Tempo, una línea en Loki), no en "debería verse bien".

## Distribución de tiempo por semana (10 h)

| Sección | Tiempo | Descripción |
|---|---|---|
| 1-teoria | 45 min | Contexto mínimo + referencia rápida (1–3 archivos) |
| Conocimiento | 15 min | 10 preguntas de la rúbrica, respondidas por escrito |
| 2-practicas | 6 h | 6 labs progresivos (~60 min c/u) |
| 3-proyecto | 3 h | Capa semanal de la `tienda` |

---

## Fases y semanas

| Fase | Semanas | Horas | Al terminar el alumno… |
|---|:--:|:--:|---|
| 1 — Fundamentos: logs y métricas | 01-04 | 40 | instrumenta logs y métricas y responde preguntas con PromQL |
| 2 — Visualización, alertas y logs centralizados | 05-08 | 40 | tiene dashboards como código, alertas probadas y logs en Loki |
| 3 — Trazas y OpenTelemetry | 09-13 | 50 | traza la tienda de punta a punta, opera un Collector y controla el coste |
| 4 — Señales avanzadas y fiabilidad | 14-16 | 30 | usa perfiles, SLOs con burn rate y observa dependencias y frontend |
| 5 — Plataforma en producción | 17-22 | 60 | escala, lleva a Kubernetes, asegura el stack, aplica IA, resuelve incidentes y entrega el capstone |

| Semana | Carpeta | Tema |
|:--:|---|---|
| 01 | `week-01-que_es_observabilidad` | Qué es observabilidad: señales, RED, USE y golden signals |
| 02 | `week-02-logs_estructurados` | Logs estructurados con structlog y pino |
| 03 | `week-03-metricas_y_prometheus` | Métricas e instrumentación con Prometheus |
| 04 | `week-04-promql_fundamentos` | PromQL: fundamentos |
| 05 | `week-05-promql_avanzado_y_recording_rules` | PromQL avanzado y recording rules |
| 06 | `week-06-grafana_y_dashboards_como_codigo` | Grafana y dashboards como código |
| 07 | `week-07-alertas_y_alertmanager` | Alertas y Alertmanager |
| 08 | `week-08-logs_centralizados_con_loki` | Logs centralizados con Loki y patrones de logs |
| 09 | `week-09-trazas_distribuidas_y_jaeger` | Trazas distribuidas e instrumentación manual con Jaeger |
| 10 | `week-10-opentelemetry_autoinstrumentacion` | OpenTelemetry: auto-instrumentación y propagación |
| 11 | `week-11-opentelemetry_collector` | OpenTelemetry Collector |
| 12 | `week-12-tempo_y_correlacion_de_senales` | Tempo y correlación de señales |
| 13 | `week-13-muestreo_cardinalidad_y_coste` | Muestreo, cardinalidad y coste |
| 14 | `week-14-profiling_continuo_y_ebpf` | Profiling continuo y eBPF |
| 15 | `week-15-slos_y_error_budgets` | SLOs, error budgets y anomalías |
| 16 | `week-16-observabilidad_de_dependencias_y_frontend` | Observabilidad de dependencias y frontend |
| 17 | `week-17-escala_y_alta_disponibilidad` | Escala y alta disponibilidad con Thanos |
| 18 | `week-18-observabilidad_en_kubernetes` | Observabilidad en Kubernetes |
| 19 | `week-19-seguridad_gobernanza_y_metamonitoreo` | Seguridad, gobernanza y meta-monitoreo |
| 20 | `week-20-ia_aplicada_a_la_observabilidad` | IA aplicada a la observabilidad |
| 21 | `week-21-respuesta_a_incidentes_y_troubleshooting` | Respuesta a incidentes y troubleshooting |
| 22 | `week-22-proyecto_integrador` | Proyecto integrador |

> **Esta tabla vive en cuatro archivos**: aquí, `README.md`, `README_EN.md` y `bootcamp/README.md`. Si cambia una, cambian todas. El temario detallado de cada semana (labs y proyecto) está en [`docs/temario.md`](docs/temario.md).

---

## Estructura del repositorio

```
bc-observability/
├── README.md · README_EN.md   # Contrato con el alumno y su espejo en inglés
├── CLAUDE.md                  # Esta guía
├── LICENSE · SECURITY.md · CODE_OF_CONDUCT.md
├── assets/                    # Solo recursos visuales globales
├── app/                       # tienda (sin instrumentar) + compose.yaml con perfiles
├── docs/                      # Lo que aplica a todas las semanas
├── scripts/                   # Verificación y laboratorio
└── bootcamp/week-NN-tema/     # El contenido
```

Regla de reparto: si algo aplica a **todas** las semanas va en `docs/`; si aplica a una, va dentro de su semana.

## Estructura de carpetas por semana

```
week-NN-nombre_del_tema/
├── README.md                  # Descripción, objetivos, tabla de contenidos, navegación
├── rubrica-evaluacion.md      # Conocimiento 30 / Desempeño 40 / Producto 30
├── checks.json                # Autograding (ver docs/autograding.md)
├── 0-assets/                  # Diagramas SVG, los que la semana necesite, enlazados desde algún .md
├── 1-teoria/                  # 1–3 archivos, ≤ 600 palabras de prosa c/u
├── 2-practicas/
│   ├── README.md              # Índice de labs con duración
│   └── lab-NN-nombre/
│       ├── README.md          # Enunciado, instrucciones, criterios de éxito
│       ├── starter/           # Punto de partida con TODOs
│       └── solucion/          # Solución de referencia
├── 3-proyecto/
│   ├── README.md              # Capa de la tienda: entregables y requisitos verificables
│   ├── starter/
│   └── solucion/
├── 4-recursos/
│   ├── ebooks-free/README.md
│   ├── videografia/README.md
│   └── webgrafia/README.md
└── 5-glosario/README.md       # Término | Definición | Ejemplo
```

Plantillas de cada archivo: [`bootcamp/PLANTILLA-SEMANA.md`](bootcamp/PLANTILLA-SEMANA.md).

## Convenciones de naming

| Elemento | Convención | Ejemplo |
|---|---|---|
| Carpeta de semana | `week-NN-nombre_con_guion_bajo` | `week-03-metricas_y_prometheus` |
| Carpeta de lab | `lab-NN-nombre-con-guion` | `lab-02-metricas-red` |
| Archivos de teoría | `NN-nombre-con-guion.md` | `01-contexto.md` |
| Servicios de la tienda | minúsculas, una palabra | `catalogo`, `pedidos` |
| Métricas Prometheus | `snake_case` con unidad base y sufijo | `http_server_request_duration_seconds`, `orders_created_total` |
| Atributos y spans OTel | [semantic conventions](https://opentelemetry.io/docs/specs/semconv/) | `http.route`, `db.system.name` |
| Labels de Loki | pocos y de baja cardinalidad | `service_name`, `level` |
| Recording rules | `level:metric:operations` | `job:http_requests:rate5m` |

## La tienda (`app/`)

- Puertos en el host: `catalogo` 18001, `pedidos` 18002, `pagos` 18003, `notificaciones` 18004, RabbitMQ 15672, toxiproxy 8474. Los backends de observabilidad que añada cada semana usan sus puertos estándar (Prometheus 9090, Grafana 3000, etc.), siempre en `127.0.0.1`.
- Averías latentes que el alumno descubre (no se anuncian en el código): consulta N+1 de categorías en `GET /products`, búsqueda `?q=` que puntúa en Python todo el catálogo (el hot path de la S14; su coste se ajusta al escribir esa semana), y datos personales en los logs de `pedidos` y `notificaciones` (marcados como antipatrón, se corrigen en la S02).
- `./app/scripts/smoke-test.sh` tiene que pasar después de cualquier cambio en `app/`.
- `app/` es siempre la tienda **sin instrumentar**. Las semanas que cambian código traen su propia copia de los servicios en `3-proyecto/starter/` (la `solucion/` de la semana anterior, o `app/` si es la primera), con la misma estructura que `app/`: `Dockerfile.python`, `catalogo/`, `pedidos/`, `pagos/`, `notificaciones/` y, desde la S03, la configuración de los backends (`prometheus/`…), que `compose.yaml` monta desde `${TIENDA_SRC:-.}`. Las dependencias nuevas de la semana ya van en sus lockfiles. `TIENDA=<carpeta> ./scripts/lab-up.sh` la construye; el primer check de `checks.json` lo hace con `TIENDA={proyecto}`.

## Estándares de código

- **Python:** FastAPI, Python fijado en `stack-versions.md`, `pyproject.toml` + `uv.lock`, ruff para lint y formato, pytest. Logs con `structlog`; métricas con `prometheus-client` (S03-08) y luego OpenTelemetry SDK.
- **Node.js:** Express, `pnpm`, ES modules, logs con `pino`.
- **Compose:** plugin `docker compose` (nunca `docker-compose` v1), `compose.yaml`, perfiles por señal, `127.0.0.1:` en todos los `ports`, healthchecks, contenedores no root cuando la imagen oficial lo permite.
- **Configuración de backends** (Prometheus, Alertmanager, Loki, Tempo, Collector, Grafana): archivos YAML/JSON versionados, nunca clics en la UI. Lo que se crea en la UI se exporta y se provisiona.
- **Scripts bash:** `#!/usr/bin/env bash`, `set -euo pipefail`, ejecutables, pasan `shellcheck`.

## Estándares de idioma

- Prosa, enunciados, comentarios y mensajes de log de ejemplo: español con tuteo.
- Código, nombres de métricas, atributos, labels, endpoints: inglés.
- Nunca mezclar idiomas en la misma línea de prosa.

---

## Estructura de un lab (README.md de lab)

1. **Título y duración estimada**
2. **Objetivo** — una sola oración con el verbo en infinitivo
3. **Contexto** — máx. 3 párrafos o bullets; no repetir lo que ya está en 1-teoria
4. **Instrucciones** — pasos numerados, con comandos exactos y salida esperada
5. **Criterios de éxito** — verificables con una consulta o un comando (`curl -s localhost:9090/api/v1/query ...` devuelve X)
7. **Reto extra** (opcional)

## Estructura del README.md de semana

1. Título y número de semana
2. Descripción (2-3 oraciones)
3. Objetivos de aprendizaje (verbos de acción)
4. Prerrequisitos y **perfil de laboratorio** que usa la semana (ver [`docs/perfiles-de-laboratorio.md`](docs/perfiles-de-laboratorio.md))
5. Tabla de contenidos con tiempos
6. Distribución del tiempo
7. Verificación: `./scripts/verificar-semana.sh NN`
8. `## 🔗 Navegación` (anterior / actual / siguiente + volver al índice)

Todo archivo de contenido de una semana publicada termina con un pie de navegación `← anterior · siguiente →`.

## Rúbrica de evaluación

Tres evidencias, **mínimo 70% en cada una** (no en el promedio):

- 🧠 Conocimiento 30%: 10 preguntas conceptuales (3 pts c/u) que piden explicar el porqué, con la respuesta en `<details>`.
- 💪 Desempeño 40%: los 6 labs, con criterios verificables.
- 📦 Producto 30%: capa de la `tienda` — 60 pts de autograding (`checks.json`) + 40 pts de calidad manual, con tabla de penalizaciones (secreto comiteado, imagen sin tag, puerto en `0.0.0.0`, PII en la telemetría, `npm`/`pip` en lugar de `pnpm`/`uv`).

Bandas: Sobresaliente 90–100, Notable 80–89, Aprobado 70–79.

---

## Contenido esperado por sección

### 0-assets/
Diagramas **SVG** (`NN-nombre.svg`, en orden de lectura): **los que la semana necesite, que no sobren ni falten**. Cada concepto que se entiende mejor con un dibujo (una arquitectura, un flujo entre servicios, una secuencia en el tiempo) lleva el suyo; ningún diagrama decora ni repite una tabla que ya está en el texto. Cada uno va incrustado como imagen o enlazado desde algún `.md` de la semana, con la ruta relativa `../0-assets/NN-nombre.svg`. Nunca arte ASCII ni Mermaid en `0-assets/`; Mermaid solo vale en los entregables del alumno, donde el autograding lo lee como texto.

- `viewBox`, `role="img"`, `<title>` y `<desc>` (la explicación del diagrama, para lectores de pantalla) obligatorios.
- Tema oscuro, sin degradados, sans-serif. Una línea de subtítulo bajo el título dice qué hay que mirar.
- Paleta, la misma de `assets/bootcamp-header.svg`:

  | Color | Hex | Uso |
  |---|---|---|
  | Lienzo | `#0d1117` | Fondo |
  | Superficie | `#161b22` | Cajas |
  | Borde | `#30363d` | Líneas y separadores |
  | Texto | `#e6edf3` / `#8b949e` | Principal / anotaciones |
  | Ámbar OpenTelemetry | `#F5A800` | Servicios de la tienda, elemento principal, franja izquierda |
  | Azul | `#79c0ff` | Llamadas síncronas, métricas |
  | Morado | `#d2a8ff` | Eventos asíncronos, perfiles, metadatos |
  | Verde | `#3fb950` | Éxito, logs |
  | Rojo | `#f85149` | Error, fallo |

### 1-teoria/
≤ 600 palabras de prosa por archivo. Abre con "¿Por qué importa esto?", sigue con una referencia rápida (tabla o snippet) y un ejemplo mínimo que funciona al pegarlo. Termina enlazando al lab-01.

### 4-recursos/
- `ebooks-free/`: `| Título | Formato | Descripción | Enlace |`, mínimo 2.
- `videografia/`: `| Título | Canal | Duración | Enlace |`, mínimo 3; en español si existe con calidad.
- `webgrafia/`: `| Recurso | Descripción |`, 3–5, priorizando documentación oficial del proyecto.

Solo enlaces comprobados al escribir la semana; nada inventado.

### 5-glosario/
8–15 términos nuevos de esa semana, **en orden alfabético y agrupados por letra**: un índice de letras al principio (`[A](#a) · [C](#c) …`) y una sección `## A`, `## C`… por cada letra con términos, cada una con su tabla `| Término | Definición en una línea | Ejemplo |`. El orden ignora tildes y mayúsculas.

---

## Comandos útiles durante la autoría

```bash
./scripts/verificar-enlaces.sh              # estructura, enlaces, voseo, uv/pnpm, imágenes
./scripts/verificar-semana.sh --doctor      # entorno
./scripts/verificar-semana.sh NN            # autograding contra starter/
ENTREGA=solucion ./scripts/verificar-semana.sh NN   # autograding contra solucion/
```

## Notas para Claude al generar contenido

- Lee este archivo y `bootcamp/PLANTILLA-SEMANA.md` antes de generar.
- Cada semana nueva lleva `checks.json` escrito **antes** que el contenido; debe fallar contra `starter/` y pasar contra `solucion/`.
- Las soluciones se moverán al repo privado `ergrato-dev/bc-observability-instructor` (misma ruta relativa); hasta entonces viven aquí.
- Antes de fijar una versión, verifícala (tag existente, fecha, fuente) y anótala en `docs/stack-versions.md`. Nunca inventes una versión ni un enlace.
- Mide la RAM real de cada perfil al escribir su semana y reemplaza la estimación de `docs/perfiles-de-laboratorio.md`.
- No generes contenido de semanas futuras si no se pidió explícitamente.
- Marca una semana como ✅ en `bootcamp/README.md` (y enlázala) solo cuando pasa `verificar-enlaces.sh` y su solución pasa el autograding.
- Tono: directo, sin relleno, orientado al profesional.
