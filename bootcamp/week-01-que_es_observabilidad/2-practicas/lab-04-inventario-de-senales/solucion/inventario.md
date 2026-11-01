# Inventario de señales de la tienda (SOLUCIÓN)

Valores: **sí**, **no** o **parcial**, con la evidencia que lo demuestra.

| Pieza | Logs | Métricas | Trazas | Evidencia |
|---|---|---|---|---|
| catalogo | parcial | no | no | Solo logs de acceso de uvicorn en texto, sin duración. `/metrics` da 404. Sin `traceparent` |
| pedidos | parcial | no | no | Logs de acceso y una línea por pedido (con datos personales). Errores de `pagos` solo si son de red |
| pagos | parcial | no | no | Solo logs de acceso: un 503 no explica la causa |
| notificaciones | parcial | no | no | Una línea por correo enviado. No registra las peticiones HTTP |
| PostgreSQL | parcial | sí | — | `pg_stat_database` y `pg_stat_activity` tienen conexiones, commits, rollbacks y caché. Logs solo de arranque y errores |
| Valkey | parcial | sí | — | `INFO` da clientes, memoria, aciertos y fallos de caché, desalojos |
| RabbitMQ | sí | sí | — | API de gestión con colas, mensajes listos y tasas de publicación |
| Contenedores (Docker) | sí | sí | — | `docker stats` da CPU, memoria y red; `docker compose logs` recoge el stdout de todos |
| Cliente (k6) | — | parcial | — | Mide latencia y errores, pero el resumen se pierde al terminar si no se exporta |

## Conclusión

La infraestructura es lo más observable: PostgreSQL, Valkey, RabbitMQ y Docker ya exponen métricas de uso, saturación y errores, aunque nadie las recoja ni las guarde en el tiempo. La aplicación es casi opaca: sus logs no tienen duración, ni estructura, ni un identificador común, y no hay métricas ni trazas. Por eso, cuando algo falla en el checkout, puedes ver que la base de datos está bien pero no por qué el pedido tardó 2 s. Las semanas 02 a 10 instrumentan justo esa parte.
