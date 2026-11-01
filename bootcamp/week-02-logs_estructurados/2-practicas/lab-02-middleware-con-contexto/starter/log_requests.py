# Lab 02 — Middleware de logs de acceso.
#
# 1. Añade estos imports arriba de app/logging_config.py:
#      import time
#      from uuid import uuid4
#      from fastapi import Request
# 2. Pega el resto de este archivo al final de app/logging_config.py.
# 3. Regístralo en app/main.py, justo después de crear la app:
#      app.middleware("http")(log_requests)

REQUEST_ID_HEADER = "X-Request-ID"

log = structlog.get_logger()


async def log_requests(request: Request, call_next):
    """Middleware HTTP: un request_id por petición y una línea http_request al terminar."""
    # TODO (paso 3): si la ruta es /health, atiende la petición sin registrar nada.

    # TODO (paso 4): toma el request_id de la cabecera X-Request-ID o genera uno
    # con uuid4().hex. Limpia el contexto de la petición anterior y enlaza el nuevo:
    #   structlog.contextvars.clear_contextvars()
    #   structlog.contextvars.bind_contextvars(request_id=...)

    start = time.perf_counter()
    response = await call_next(request)

    # TODO (paso 2): una línea "http_request" con method, path, route (la plantilla
    # de la ruta: request.scope["route"].path), status_code y duration_ms.

    # TODO (paso 4): devuelve el request_id en la cabecera X-Request-ID de la respuesta.
    return response
