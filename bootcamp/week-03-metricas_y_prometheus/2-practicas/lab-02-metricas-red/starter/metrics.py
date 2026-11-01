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
    # TODO paso 4: /health y /metrics no se miden (UNMEASURED).

    # TODO paso 2: mide con time.perf_counter() lo que tarda call_next(request),
    # cuenta la petición en ACTIVE_REQUESTS mientras dura y, al terminar (también
    # si falla: status_code 500), obsérvala en REQUEST_DURATION con sus labels.
    #
    # TODO paso 3: el label route sale de la ruta que atendió la petición,
    # request.scope.get("route"), no de request.url.path.
    return await call_next(request)


def metrics() -> Response:
    """GET /metrics: todas las métricas del proceso en formato de exposición."""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
