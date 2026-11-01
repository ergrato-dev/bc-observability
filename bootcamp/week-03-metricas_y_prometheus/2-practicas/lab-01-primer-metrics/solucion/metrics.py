"""Métricas de la tienda: el endpoint /metrics.

Lab 01: copia este archivo a $TIENDA/catalogo/app/metrics.py.
"""

from fastapi import Response
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    disable_created_metrics,
    generate_latest,
)

# Sin las series *_created que prometheus-client añade a cada contador:
# duplican las series y Prometheus no las necesita.
disable_created_metrics()


def metrics() -> Response:
    """GET /metrics: todas las métricas del proceso en formato de exposición."""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
