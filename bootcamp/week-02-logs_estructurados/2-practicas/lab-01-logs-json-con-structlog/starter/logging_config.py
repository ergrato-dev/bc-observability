"""Logs JSON con esquema común para los servicios Python de la tienda.

Todas las líneas, las de la aplicación y las de uvicorn, salen por stdout como
un objeto JSON con timestamp, level, service y event.
"""

import logging
import os
import sys

import structlog


def configure_logging(service: str) -> None:
    def add_service(_logger, _method, event_dict):
        # TODO (paso 3): añade el nombre del servicio en la clave "service".
        return event_dict

    # Se aplican a todas las líneas: las de structlog y las de logging (uvicorn).
    shared = [
        structlog.stdlib.add_log_level,
        # TODO (paso 3): timestamp ISO 8601 en UTC en la clave "timestamp".
        #   Pista: structlog.processors.TimeStamper(fmt=..., utc=..., key=...)
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
            # TODO (paso 3): el último procesador convierte el diccionario en una línea.
            #   Ahora sale texto pensado para humanos: cámbialo por JSON, con
            #   ensure_ascii=False para que "ó" no salga como "\u00f3".
            structlog.dev.ConsoleRenderer(colors=False),
        ],
    )
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)
    root = logging.getLogger()
    root.handlers = [handler]
    root.setLevel(os.getenv("LOG_LEVEL", "INFO").upper())

    # TODO (paso 5): uvicorn configuró sus propios loggers al arrancar y siguen
    # escribiendo texto plano. Quítales los handlers y haz que propaguen al root
    # ("uvicorn", "uvicorn.error", "uvicorn.access").
