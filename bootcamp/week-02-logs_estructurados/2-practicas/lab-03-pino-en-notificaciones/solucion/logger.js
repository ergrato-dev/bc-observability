// SOLUCIÓN DEL LAB 03.
// Logs JSON con el mismo esquema que los servicios Python de la tienda:
// timestamp, level, service y event en cada línea, request_id cuando lo hay.

import { randomUUID } from "node:crypto";
import pino from "pino";

// pino y Python no nombran igual los niveles: el esquema común usa los de Python.
const TO_PYTHON = { warn: "warning", fatal: "critical" };
const FROM_PYTHON = { warning: "warn", critical: "fatal" };
const level = (process.env.LOG_LEVEL ?? "info").toLowerCase();

export const logger = pino({
  level: FROM_PYTHON[level] ?? level,
  messageKey: "event",
  base: { service: "notificaciones" },
  timestamp: () => `,"timestamp":"${new Date().toISOString()}"`,
  formatters: { level: (label) => ({ level: TO_PYTHON[label] ?? label }) },
});

// Middleware de Express: el mismo http_request que escriben los servicios Python.
export function logRequests(req, res, next) {
  if (req.path === "/health") return next();
  const requestId = req.get("x-request-id") ?? randomUUID().replaceAll("-", "");
  const start = process.hrtime.bigint();
  req.log = logger.child({ request_id: requestId });
  res.set("x-request-id", requestId);
  res.on("finish", () => {
    req.log.info(
      {
        method: req.method,
        path: req.path,
        route: req.route?.path ?? null,
        status_code: res.statusCode,
        duration_ms: Math.round(Number(process.hrtime.bigint() - start) / 1e5) / 10,
      },
      "http_request",
    );
  });
  next();
}
