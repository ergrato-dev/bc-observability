# Lab 06 — Plan de instrumentación

⏱ Duración estimada: ~60 min

## Objetivo

Convertir las preguntas que la tienda tiene que poder responder en una lista priorizada de señales, ordenada como la añadirás en el bootcamp.

## Contexto

- Instrumentar "todo" es caro y no sirve: la instrumentación se diseña a partir de preguntas.
- Cada pregunta pide una señal: "¿cuánto?" pide una métrica, "¿dónde se fue el tiempo?" una traza, "¿qué pasó con este pedido?" un log, "¿qué función es cara?" un perfil.
- Usa lo que has sufrido esta semana: el lab 03 y lo que te faltó son tu mejor fuente de preguntas.

## Instrucciones

1. En `starter/plan.md`, escribe al menos 8 preguntas que querrías poder responder durante un incidente de la tienda. Una por línea, empezando por `- ` y terminando en `?`. Al menos dos tienen que salir de tu diagnóstico del lab 03.

2. Clasifica cada pregunta en la tabla: qué señal la responde mejor y por qué.

3. Prioriza: marca con ⭐ las tres preguntas cuya respuesta habría acortado más el lab 03.

4. Asigna cada señal a la semana del bootcamp en la que se añade ([docs/temario.md](../../../../docs/temario.md)). La tabla tiene que tener al menos una fila de logs, una de métricas, una de trazas y una de perfiles.

5. Copia las preguntas y el plan a las secciones "Preguntas" y "Plan de instrumentación" de tu proyecto.

## Criterios de éxito

- [ ] Al menos 8 preguntas que terminan en `?`
- [ ] Cada pregunta tiene una señal y una justificación
- [ ] Las tres preguntas prioritarias salen de una avería real
- [ ] El plan cubre logs, métricas, trazas y perfiles

## Reto extra

Elige una de tus preguntas y escribe qué atributos necesitaría su señal para responderla (por ejemplo: "duración de `POST /charges` por código de estado"). ¿Alguno de esos atributos es de alta cardinalidad?

---

[← Lab 05](../lab-05-red-y-use-a-mano/README.md) · [Proyecto →](../../3-proyecto/README.md)
