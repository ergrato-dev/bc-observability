"""pagos: pasarela de pago simulada.

Las averías se configuran al arrancar con variables de entorno y se cambian en
caliente con PUT /admin/faults. /admin solo es alcanzable desde 127.0.0.1
(ver compose.yaml): en un servicio real necesitaría autenticación.

Sin instrumentar: solo los logs de acceso de uvicorn.
"""

import asyncio
import os
import random
from decimal import Decimal
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field


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


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/charges", status_code=201)
async def create_charge(charge: Charge):
    delay = faults.latency_ms + random.uniform(-faults.jitter_ms, faults.jitter_ms)
    await asyncio.sleep(max(delay, 0) / 1000)
    if random.random() < faults.timeout_rate:
        await asyncio.sleep(30)
    if random.random() < faults.error_rate:
        raise HTTPException(503, "Pasarela no disponible")
    return {"id": uuid4().hex, "amount": charge.amount, "status": "approved"}


@app.get("/admin/faults")
async def get_faults() -> Faults:
    return faults


@app.put("/admin/faults")
async def set_faults(new: Faults) -> Faults:
    global faults
    faults = new
    return faults
