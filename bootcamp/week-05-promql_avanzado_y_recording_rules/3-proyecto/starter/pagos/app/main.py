"""pagos: pasarela de pago simulada.

Las averías se configuran al arrancar con variables de entorno y se cambian en
caliente con PUT /admin/faults. /admin solo es alcanzable desde 127.0.0.1
(ver compose.yaml): en un servicio real necesitaría autenticación.

Semana 02: logs JSON con esquema común y request_id (ver logging_config.py).
Semana 03: métricas RED en /metrics (ver metrics.py).
"""

import asyncio
import os
import random
from decimal import Decimal
from uuid import uuid4

import structlog
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from app.logging_config import configure_logging, log_requests
from app.metrics import measure_requests, metrics

configure_logging("pagos")
log = structlog.get_logger()


class Faults(BaseModel):
    error_rate: float = Field(
        ge=0, le=1, description="Fracción de cobros que fallan con 503"
    )
    latency_ms: int = Field(ge=0, description="Latencia media de cada cobro")
    jitter_ms: int = Field(ge=0, description="Variación aleatoria de la latencia (±)")
    timeout_rate: float = Field(
        ge=0, le=1, description="Fracción de cobros que se cuelgan 30 s"
    )


class Charge(BaseModel):
    amount: Decimal = Field(gt=0)
    card_number: str = Field(pattern=r"^[0-9]{13,19}$")


faults = Faults(
    error_rate=float(os.getenv("PAGOS_ERROR_RATE", "0.02")),
    latency_ms=int(os.getenv("PAGOS_LATENCY_MS", "80")),
    jitter_ms=int(os.getenv("PAGOS_JITTER_MS", "40")),
    timeout_rate=float(os.getenv("PAGOS_TIMEOUT_RATE", "0")),
)

app = FastAPI(title="pagos")
app.middleware("http")(log_requests)
app.middleware("http")(measure_requests)
app.get("/metrics", include_in_schema=False)(metrics)


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/charges", status_code=201)
async def create_charge(charge: Charge):
    delay = faults.latency_ms + random.uniform(-faults.jitter_ms, faults.jitter_ms)
    await asyncio.sleep(max(delay, 0) / 1000)
    if random.random() < faults.timeout_rate:
        log.warning("charge_stalled", stall_seconds=30)
        await asyncio.sleep(30)
    if random.random() < faults.error_rate:
        log.error(
            "charge_failed", amount=float(charge.amount), reason="gateway_unavailable"
        )
        raise HTTPException(503, "Pasarela no disponible")
    charge_id = uuid4().hex
    log.info("charge_approved", charge_id=charge_id, amount=float(charge.amount))
    return {"id": charge_id, "amount": charge.amount, "status": "approved"}


@app.get("/admin/faults")
async def get_faults() -> Faults:
    return faults


@app.put("/admin/faults")
async def set_faults(new: Faults) -> Faults:
    global faults
    log.warning(
        "faults_updated", previous=faults.model_dump(), current=new.model_dump()
    )
    faults = new
    return faults
