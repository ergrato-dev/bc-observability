// Métricas RED con los mismos nombres, labels y buckets que los servicios
// Python de la tienda: así una sola consulta sirve para los cuatro.
//
// Lab 03: copia este archivo a $TIENDA/notificaciones/src/metrics.js.

import { collectDefaultMetrics, Counter, Gauge, Histogram, register } from "@prometheus-io/client";

const UNMEASURED = new Set(["/health", "/metrics"]);

// TODO paso 2: activa las métricas por defecto del proceso y de Node.js.

const requestDuration = new Histogram({
  name: "http_server_request_duration_seconds",
  help: "Duración de las peticiones HTTP atendidas por el servicio",
  labelNames: ["method", "route", "status_code"],
  // TODO paso 4: los mismos buckets que prometheus-client en Python.
});
const activeRequests = new Gauge({
  name: "http_server_active_requests",
  help: "Peticiones HTTP en curso en este momento",
});

// TODO paso 5: el contador notifications_total con el label result.

// Middleware de Express: observa la duración de cada petición en el histograma.
export function measureRequests(req, res, next) {
  if (UNMEASURED.has(req.path)) return next();
  // TODO paso 3: cuenta la petición en activeRequests y, cuando la respuesta
  // termine (res.on("finish")), obsérvala en requestDuration. Para medir,
  // requestDuration.startTimer() devuelve una función que se llama al final
  // con los labels que faltan. route: req.route?.path ?? "".
  next();
}

// GET /metrics
export async function metrics(_req, res) {
  res.set("Content-Type", register.contentType);
  res.send(await register.metrics());
}
