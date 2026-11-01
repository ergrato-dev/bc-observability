"""Logs JSON con esquema común para los servicios Python de la tienda.

Todas las líneas, las de la aplicación y las de uvicorn, salen por stdout como
un objeto JSON con timestamp, level, service y event. Las que ocurren dentro de
una petición llevan además su request_id.

Este archivo es idéntico en catalogo, pedidos y pagos.
"""

import logging
import os
import re
import sys
import time
from uuid import uuid4

import structlog
from fastapi import Request

REQUEST_ID_HEADER = "X-Request-ID"
SENSITIVE_KEYS = {"email", "card_number", "password", "authorization", "token"}
CARD_NUMBER = re.compile(r"\b[0-9]{13,19}\b")
EMAIL = re.compile(r"[\w.+-]+@[\w-]+(\.[\w-]+)+")

log = structlog.get_logger()


def redact_pii(_logger, _method, event_dict):
    """Red de seguridad: si un dato personal llega a un log, sale tapado."""
    for key, value in event_dict.items():
        if key in SENSITIVE_KEYS:
            event_dict[key] = "[REDACTED]"
        elif isinstance(value, str):
            event_dict[key] = EMAIL.sub("[EMAIL]", CARD_NUMBER.sub("[CARD]", value))
    return event_dict


def configure_logging(service: str) -> None:
    def add_service(_logger, _method, event_dict):
        event_dict["service"] = service
        return event_dict

    # Se aplican a todas las líneas: las de structlog y las de logging (uvicorn).
    shared = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True, key="timestamp"),
        add_service,
        redact_pii,
    ]
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            *shared,
            structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
        ],
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )
    formatter = structlog.stdlib.ProcessorFormatter(
        foreign_pre_chain=shared,
        processors=[
            structlog.stdlib.ProcessorFormatter.remove_processors_meta,
            structlog.processors.dict_tracebacks,
            structlog.processors.JSONRenderer(ensure_ascii=False),
        ],
    )
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)
    root = logging.getLogger()
    root.handlers = [handler]
    root.setLevel(os.getenv("LOG_LEVEL", "INFO").upper())

    # uvicorn ya configuró sus loggers al arrancar: que pasen por el nuestro.
    for name in ("uvicorn", "uvicorn.error", "uvicorn.access"):
        logging.getLogger(name).handlers.clear()
        logging.getLogger(name).propagate = True
    # El log de acceso lo escribe log_requests, con request_id y duración.
    logging.getLogger("uvicorn.access").disabled = True
    # httpx escribe una línea INFO por cada llamada saliente: ruido que http_request ya cubre.
    logging.getLogger("httpx").setLevel(logging.WARNING)


async def log_requests(request: Request, call_next):
    """Middleware HTTP: un request_id por petición y una línea http_request al terminar."""
    if request.url.path == "/health":
        return await call_next(request)

    request_id = request.headers.get(REQUEST_ID_HEADER) or uuid4().hex
    structlog.contextvars.clear_contextvars()
    structlog.contextvars.bind_contextvars(request_id=request_id)
    start = time.perf_counter()
    status_code = 500
    try:
        response = await call_next(request)
        status_code = response.status_code
    finally:
        route = request.scope.get("route")
        log.info(
            "http_request",
            method=request.method,
            path=request.url.path,
            route=getattr(route, "path", None),
            status_code=status_code,
            duration_ms=round((time.perf_counter() - start) * 1000, 1),
        )
    response.headers[REQUEST_ID_HEADER] = request_id
    return response


async def propagate_request_id(request) -> None:
    """Hook de httpx: las llamadas salientes llevan el request_id de la petición en curso."""
    if request_id := structlog.contextvars.get_contextvars().get("request_id"):
        request.headers[REQUEST_ID_HEADER] = request_id
