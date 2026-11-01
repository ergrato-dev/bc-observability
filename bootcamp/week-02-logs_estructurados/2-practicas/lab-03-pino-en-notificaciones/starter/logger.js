// Logs JSON con el mismo esquema que los servicios Python de la tienda:
// timestamp, level, service y event en cada línea, request_id cuando lo hay.

import { randomUUID } from "node:crypto";
import pino from "pino";

const level = (process.env.LOG_LEVEL ?? "info").toLowerCase();

export const logger = pino({
  level,
  // TODO (paso 2): el esquema común no coincide con el que pino trae de serie.
  //   - el mensaje va en "event", no en "msg"           -> messageKey
  //   - "service": "notificaciones", sin pid ni hostname  -> base
  //   - "timestamp" en ISO 8601 UTC, no "time" en ms      -> timestamp
  //   - el nivel como texto ("info"), no como número (30) -> formatters.level
  //     y con los nombres de Python: "warning" en lugar de "warn"
  //     y "critical" en lugar de "fatal".
});

// Middleware de Express: el mismo http_request que escriben los servicios Python.
export function logRequests(req, res, next) {
  // TODO (paso 4): sin registrar /health, guarda en req.log un logger hijo con el
  // request_id (cabecera x-request-id o randomUUID()), devuélvelo en la respuesta
  // y, cuando la respuesta termine (res.on("finish", ...)), escribe una línea
  // "http_request" con method, path, route, status_code y duration_ms.
  next();
}
