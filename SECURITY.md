# Política de Seguridad

## Versiónes Soportadas

| Versión | Soportada |
| ------- | --------- |
| main    | Sí        |

## Reportar una vulnerabilidad

Si descubres una vulnerabilidad de seguridad en este material o en los scripts del repositorio, te pedimos que la reportes de manera responsable.

### NO hacer público el reporte

Por favor, **NO** abras un issue público para reportar vulnerabilidades de seguridad.

### Cómo reportar

1. **Abre un Security Advisory privado** en GitHub:
   - Ve a la pestaña "Security" del repositorio
   - Haz clic en "Report a vulnerability"
   - Completa el formulario con los detalles

2. **Incluye en tu reporte**:
   - Descripción detallada de la vulnerabilidad
   - Pasos para reproducir el problema
   - Impacto potencial
   - Sugerencias de solución (si las tienes)

### Tiempo de respuesta

- **Confirmación inicial**: 48 horas
- **Evaluación**: 7 días
- **Resolución**: Dependiendo de la severidad

---

## Qué se considera vulnerabilidad en este repositorio

Este es material educativo, no un servicio en producción. Cuentan como vulnerabilidad:

- **Un secreto real comiteado** en cualquier archivo del repositorio (API keys, tokens de Grafana, contraseñas de backends).
- **Un ejemplo que enseña un antipatrón sin marcarlo como tal** y que un alumno copiaría a producción: loguear datos personales o tokens, exponer `/metrics` o el Collector a internet sin autenticación, Grafana con `admin/admin`.
- **Un script de `scripts/` con inyección de comandos**, escalada de privilegios o borrado fuera de su directorio.
- **Una imagen de contenedor sin versión fijada** (`latest` o sin tag) o que corre como root sin justificación.
- **Un puerto de un backend de telemetría publicado fuera de `127.0.0.1`** en un `compose.yaml` del repositorio.

## Prácticas de seguridad que enseña este bootcamp

### La telemetría no lleva datos personales ni secretos

Logs, atributos de spans y labels de métricas terminan en sistemas con más lectores y más retención que la base de datos original. Se redactan en origen (el SDK o el logger) y, como segunda barrera, en el OpenTelemetry Collector:

```yaml
processors:
  transform/redactar:
    log_statements:
      - context: log
        statements:
          - replace_pattern(body, "[0-9]{13,19}", "****")
```

### Los backends se publican solo en localhost

```yaml
# ANTIPATRÓN: Grafana accesible desde toda la red local
ports: ["3000:3000"]

# CORRECTO
ports: ["127.0.0.1:3000:3000"]
```

### Ningún dato de telemetría sale a un LLM externo

La Semana 20 usa modelos open-weight servidos en local con Ollama. Enviar logs o trazas a un servicio de IA de terceros es enviar datos de producción a terceros.

### Credenciales fuera del repositorio

Todos los `.env*` (salvo `.env.example`) van en `.gitignore`. Las contraseñas de ejemplo del laboratorio solo valen en `127.0.0.1` y se cambian antes de cualquier otro uso.

## Dependencias

Este bootcamp referencia:

- Docker Engine con el plugin `docker compose` (ver [`docs/stack-versions.md`](docs/stack-versions.md))
- bash, jq, curl y shellcheck para los scripts de verificación
- Python siempre con uv y Node.js siempre con pnpm, con versiones fijadas
- Imágenes oficiales de los proyectos open source del stack, siempre con tag fijado

---

Gracias por ayudar a mantener este proyecto seguro.
