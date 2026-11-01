# /gen-semana

Genera el contenido completo de una semana del bootcamp bc-observability.

## Uso

```
/gen-semana <NN>
```

Ejemplo: `/gen-semana 01`

---

## Instrucciones para Claude

1. Lee `CLAUDE.md`, `bootcamp/PLANTILLA-SEMANA.md`, la entrada de la semana `$ARGUMENTS` en `docs/temario.md` y su fila en `docs/proyecto-hilo-conductor.md`. Si la semana anterior existe, lee su `3-proyecto/solucion/`: es el punto de partida de esta.
2. Verifica y fija en `docs/stack-versions.md` (fecha y fuente) toda versión nueva que use la semana. Nunca inventes una versión ni un enlace.
3. Escribe `checks.json` **primero** (contrato en `docs/autograding.md`).
4. Genera, en este orden:
   - `README.md` de la semana con su perfil de laboratorio
   - `0-assets/` (≥ 3 diagramas SVG con la paleta de `CLAUDE.md`, enlazados desde la teoría o los labs)
   - `1-teoria/` (1–3 archivos, ≤ 600 palabras de prosa c/u)
   - `2-practicas/README.md` y los 6 labs, cada uno con `README.md`, `starter/` y `solucion/`
   - `3-proyecto/` con `README.md`, `starter/` y `solucion/`; los requisitos verificables son las `descripcion` de `checks.json`, literales
   - `rubrica-evaluacion.md`
   - `4-recursos/` (ebooks-free, videografia, webgrafia) y `5-glosario/`
5. Valida:
   ```bash
   ./scripts/verificar-enlaces.sh
   ./scripts/verificar-semana.sh NN                     # debe fallar contra starter/
   ENTREGA=solucion ./scripts/verificar-semana.sh NN    # debe pasar contra solucion/
   ```
6. Mide la RAM del perfil (`docker stats --no-stream`) y actualiza `docs/perfiles-de-laboratorio.md`.
7. Solo si todo pasa: marca la semana ✅ y enlázala en `bootcamp/README.md`, y actualiza la navegación de la semana anterior.

Tuteo siempre, nunca voseo. Python con uv, Node.js con pnpm. Imágenes con tag fijado, puertos en `127.0.0.1`.

Al terminar, lista los archivos creados y el resultado de las tres validaciones.
