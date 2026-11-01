"""Métricas de la tienda: el endpoint /metrics.

Lab 01: copia este archivo a $TIENDA/catalogo/app/metrics.py.
"""

from fastapi import Response
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest


def metrics() -> Response:
    """GET /metrics: todas las métricas del proceso en formato de exposición."""
    # TODO paso 2: devuelve el texto de generate_latest() con el content type
    # CONTENT_TYPE_LATEST, para que Prometheus sepa qué formato está leyendo.
    raise NotImplementedError


# TODO paso 5: sin las series *_created que prometheus-client añade a cada
# contador: duplican las series y Prometheus no las necesita.
