// Métricas RED con los mismos nombres, labels y buckets que los servicios
// Python de la tienda: así una sola consulta sirve para los cuatro.

import { collectDefaultMetrics, Counter, Gauge, Histogram, register } from "@prometheus-io/client";

// Los buckets por defecto de prometheus-client (Python). Los de este cliente
// son otros: con buckets distintos no se pueden sumar los histogramas.
const BUCKETS = [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1, 2.5, 5, 7.5, 10];
const UNMEASURED = new Set(["/health", "/metrics"]);

collectDefaultMetrics();

const requestDuration = new Histogram({
  name: "http_server_request_duration_seconds",
  help: "Duración de las peticiones HTTP atendidas por el servicio",
  labelNames: ["method", "route", "status_code"],
  buckets: BUCKETS,
});
const activeRequests = new Gauge({
  name: "http_server_active_requests",
  help: "Peticiones HTTP en curso en este momento",
});

export const notifications = new Counter({
  name: "notifications_total",
  help: "Mensajes order.created procesados, por resultado",
  labelNames: ["result"],
});

// Middleware de Express: observa la duración de cada petición en el histograma.
export function measureRequests(req, res, next) {
  if (UNMEASURED.has(req.path)) return next();
  activeRequests.inc();
  const end = requestDuration.startTimer({ method: req.method });
  res.on("finish", () => {
    activeRequests.dec();
    end({ route: req.route?.path ?? "", status_code: res.statusCode });
  });
  next();
}

// GET /metrics
export async function metrics(_req, res) {
  res.set("Content-Type", register.contentType);
  res.send(await register.metrics());
}
