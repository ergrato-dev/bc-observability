"""Logs JSON con esquema común para los servicios Python de la tienda (SOLUCIÓN DEL LAB 01).

Todas las líneas, las de la aplicación y las de uvicorn, salen por stdout como
un objeto JSON con timestamp, level, service y event.
"""

import logging
import os
import sys

import structlog


def configure_logging(service: str) -> None:
    def add_service(_logger, _method, event_dict):
        event_dict["service"] = service
        return event_dict

    # Se aplican a todas las líneas: las de structlog y las de logging (uvicorn).
    shared = [
        structlog.stdlib.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True, key="timestamp"),
        add_service,
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
