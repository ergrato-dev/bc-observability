# Semana 01 — Qué es observabilidad: señales, RED, USE y golden signals

## Descripción

Levantas la tienda, la cargas con k6 y la rompes. Después intentas diagnosticar las averías solo con logs de texto plano, y así ves por qué hace falta observabilidad. Terminas con un mapa de qué medir en cada servicio y recurso, que guía el resto del bootcamp.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Distinguir monitoreo de observabilidad y elegir qué señal (log, métrica, traza, perfil) responde cada pregunta
- Generar carga controlada con k6 y fijar umbrales de latencia y errores
- Diagnosticar una avería de `pagos` y un timeout de red usando solo `docker compose logs`, y explicar qué datos te faltaron
- Aplicar RED a los servicios y USE a PostgreSQL, Valkey y RabbitMQ con scripts de bash
- Definir SLIs candidatos como proporción de eventos buenos sobre totales
- Construir el mapa de observabilidad de la tienda

## Prerrequisitos

- [Entorno preparado](../../docs/setup-entorno.md) y prerrequisitos del bootcamp
- Perfil de laboratorio: `core` (`./scripts/lab-up.sh`, ~0,5 GB de RAM)

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-observabilidad-y-senales.md](1-teoria/01-observabilidad-y-senales.md) | 20 min |
| — | Teoría | [02-red-use-y-golden-signals.md](1-teoria/02-red-use-y-golden-signals.md) | 25 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-levantar-la-tienda](2-practicas/lab-01-levantar-la-tienda/README.md) | 60 min |
| 2 | Lab | [lab-02-carga-con-k6](2-practicas/lab-02-carga-con-k6/README.md) | 60 min |
| 3 | Lab | [lab-03-depurar-a-ciegas](2-practicas/lab-03-depurar-a-ciegas/README.md) | 60 min |
| 4 | Lab | [lab-04-inventario-de-senales](2-practicas/lab-04-inventario-de-senales/README.md) | 60 min |
| 5 | Lab | [lab-05-red-y-use-a-mano](2-practicas/lab-05-red-y-use-a-mano/README.md) | 60 min |
| 6 | Lab | [lab-06-plan-de-instrumentacion](2-practicas/lab-06-plan-de-instrumentacion/README.md) | 60 min |
| — | Proyecto | [Capa 01 de la tienda: mapa de observabilidad](3-proyecto/README.md) | 3 h |

**Total: 10 horas**

Diagramas de apoyo en [0-assets/](0-assets/01-arquitectura-tienda.svg); recursos en [4-recursos/](4-recursos/webgrafia/README.md); términos en [5-glosario/](5-glosario/README.md).

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Levantar la tienda y seguir un pedido
[60 min] lab-02 — Prueba en escalón con k6
[60 min] lab-03 — Diagnosticar dos averías solo con logs
[60 min] lab-04 — Inventario de la telemetría que existe hoy
[60 min] lab-05 — RED y USE con bash
[60 min] lab-06 — Plan de instrumentación
[3 h]    Proyecto: mapa de observabilidad de la tienda
```

## Verificación de completitud

Desde la raíz del repositorio, con el laboratorio levantado:

```bash
./scripts/verificar-semana.sh 01
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Índice del bootcamp](../README.md) | **Semana 01 — Qué es observabilidad** | [Semana 02 — Logs estructurados](../week-02-logs_estructurados/README.md) |

[← Volver al índice del bootcamp](../README.md)
