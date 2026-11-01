"""Métricas RED para los servicios Python de la tienda.

Un solo histograma da las tres señales RED de cada endpoint:
  Rate      el contador _count
  Errors    el mismo _count filtrado por status_code
  Duration  los buckets, para percentiles

Este archivo es idéntico en catalogo, pedidos y pagos.
"""

import time

from fastapi import Request, Response
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Gauge,
    Histogram,
    disable_created_metrics,
    generate_latest,
)

# Sin las series *_created que prometheus-client añade a cada contador e
# histograma: duplican las series y Prometheus no las necesita.
disable_created_metrics()

UNMEASURED = {"/health", "/metrics"}

REQUEST_DURATION = Histogram(
    "http_server_request_duration_seconds",
    "Duración de las peticiones HTTP atendidas por el servicio",
    ["method", "route", "status_code"],
)
ACTIVE_REQUESTS = Gauge(
    "http_server_active_requests", "Peticiones HTTP en curso en este momento"
)


async def measure_requests(request: Request, call_next):
    """Middleware HTTP: observa la duración de cada petición en el histograma."""
    if request.url.path in UNMEASURED:
        return await call_next(request)

    start = time.perf_counter()
    status_code = 500
    with ACTIVE_REQUESTS.track_inprogress():
        try:
            response = await call_next(request)
            status_code = response.status_code
            return response
        finally:
            # route, no path: /products/{product_id} es un valor; /products/42, miles.
            route = getattr(request.scope.get("route"), "path", "")
            REQUEST_DURATION.labels(request.method, route, str(status_code)).observe(
                time.perf_counter() - start
            )


def metrics() -> Response:
    """GET /metrics: todas las métricas del proceso en formato de exposición."""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
