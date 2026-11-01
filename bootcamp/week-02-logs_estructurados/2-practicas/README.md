# Prácticas — Semana 02

Todos los labs usan el perfil `core` y trabajan sobre **tu copia de la tienda** en `3-proyecto/starter/`. En cada terminal, desde la raíz del repositorio:

```bash
export TIENDA=bootcamp/week-02-logs_estructurados/3-proyecto/starter
./scripts/lab-up.sh
```

`lab-up.sh` reconstruye solo lo que cambió. Si lo ejecutas sin `TIENDA`, construye `app/`, la tienda sin instrumentar, y tus cambios dejan de estar en marcha (no se pierden: están en tu carpeta).

Cada lab deja algo hecho en la tienda; el proyecto lo completa en los cuatro servicios.

| # | Lab | Objetivo | Tiempo |
|---|---|---|:--:|
| 01 | [Logs JSON con structlog](lab-01-logs-json-con-structlog/README.md) | Todas las líneas de `catalogo` en JSON con el esquema común | 60 min |
| 02 | [Middleware con contexto](lab-02-middleware-con-contexto/README.md) | Una línea `http_request` por petición, con duración y `request_id` | 60 min |
| 03 | [pino en notificaciones](lab-03-pino-en-notificaciones/README.md) | El mismo esquema en Node.js | 60 min |
| 04 | [Propagar el request_id](lab-04-propagar-el-request-id/README.md) | Seguir un pedido por los cuatro servicios y contar los cobros fantasma | 60 min |
| 05 | [Fuera datos personales](lab-05-fuera-datos-personales/README.md) | Quitar los datos personales y poner una red de seguridad | 60 min |
| 06 | [Consultas con jq](lab-06-consultas-con-jq/README.md) | Responder preguntas frecuentes y limitar el disco de los logs | 60 min |

---

[← Contexto y datos personales](../1-teoria/02-contexto-y-datos-personales.md) · [Lab 01 →](lab-01-logs-json-con-structlog/README.md)
