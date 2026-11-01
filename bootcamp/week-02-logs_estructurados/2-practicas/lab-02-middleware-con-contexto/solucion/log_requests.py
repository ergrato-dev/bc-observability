# Lab 02 — Middleware de logs de acceso (SOLUCIÓN).
#
# 1. Añade estos imports arriba de app/logging_config.py:
#      import time
#      from uuid import uuid4
#      from fastapi import Request
# 2. Pega el resto de este archivo al final de app/logging_config.py.
# 3. Regístralo en app/main.py, justo después de crear la app:
#      app.middleware("http")(log_requests)
# 4. Añade structlog.contextvars.merge_contextvars al principio de la lista
#    shared de configure_logging y desactiva el log de acceso de uvicorn:
#      logging.getLogger("uvicorn.access").disabled = True

REQUEST_ID_HEADER = "X-Request-ID"

log = structlog.get_logger()


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
        # En finally: si el endpoint lanza una excepción, la petición también queda registrada.
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
