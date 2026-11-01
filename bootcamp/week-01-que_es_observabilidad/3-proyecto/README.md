# Proyecto — Capa 01 de la tienda: mapa de observabilidad

⏱ 3 h

## Contexto

Mañana te toca la guardia de la tienda y hoy no podrías explicar por qué falla un checkout. Antes de instrumentar nada necesitas un mapa: qué piezas hay, qué preguntas tienes que poder responder, qué medirías en cada servicio y recurso, y en qué orden añadirás cada señal. Este documento es la base de las 21 semanas siguientes: las consultas de la semana 04 y los SLOs de la semana 15 salen de aquí.

## Punto de partida

```
starter/
└── mapa-observabilidad.md   # plantilla con las seis secciones y TODO
```

Trabaja sobre `starter/mapa-observabilidad.md`. Respeta los encabezados `##` y el formato de las tablas: el autograding los lee.

## Entregables

1. `mapa-observabilidad.md` completo, sin ningún `TODO`.
2. **Arquitectura**: diagrama Mermaid con los cuatro servicios, PostgreSQL, Valkey y RabbitMQ, distinguiendo llamadas síncronas de asíncronas (lab 01).
3. **Preguntas**: al menos 8 preguntas que la tienda tiene que poder responder, una por línea, empezando por `- ` y terminando en `?` (lab 06).
4. **RED por servicio** y **USE por recurso**: una fila por cada servicio y por PostgreSQL, Valkey y RabbitMQ, sin celdas vacías (lab 05).
5. **SLIs candidatos**: al menos 3, cada uno como proporción de eventos buenos sobre eventos totales ([teoría](../1-teoria/02-red-use-y-golden-signals.md#slis)).
6. **Plan de instrumentación**: semana, señal y qué añade, cubriendo logs, métricas, trazas y perfiles (lab 06).

## ✅ Requisitos verificables

- Los cuatro servicios de la tienda están healthy
- El tráfico de fondo ha creado pedidos en los últimos 5 minutos
- El mapa existe y no tiene TODO pendientes
- La sección Arquitectura contiene un diagrama mermaid
- El diagrama incluye los cuatro servicios y las tres dependencias
- La sección Preguntas tiene al menos 8 preguntas
- La tabla RED tiene una fila por cada servicio de la tienda
- Ninguna celda de la tabla RED está vacía
- La tabla USE cubre PostgreSQL, Valkey y RabbitMQ
- Ninguna celda de la tabla USE está vacía
- Hay al menos 3 SLIs candidatos
- Ninguna celda de la tabla de SLIs está vacía
- El plan de instrumentación asigna semana a logs, métricas, trazas y perfiles

## Calidad (40 pts)

| Criterio | Puntos |
|---|:--:|
| Las preguntas son concretas de la tienda (nombran servicios, endpoints o pasos del checkout), no genéricas | 10 |
| RED separa los errores del sistema (5xx) de las respuestas de negocio (402, 404, 409) | 10 |
| Cada SLI mide algo que nota el usuario y se puede calcular con datos que la tienda tendrá | 10 |
| El plan prioriza lo que habría acortado el diagnóstico del lab 03 | 10 |
| **Total** | **40** |

## Entrega

```bash
./scripts/verificar-semana.sh 01
git add . && git commit -m "feat(semana-01): mapa de observabilidad de la tienda"
```

---

[← Lab 06](../2-practicas/lab-06-plan-de-instrumentacion/README.md) · [Rúbrica →](../rubrica-evaluacion.md)
