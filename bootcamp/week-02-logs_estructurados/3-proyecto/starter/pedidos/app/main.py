"""pedidos: checkout de la tienda.

Por cada pedido: consulta el precio en catalogo, reserva stock, cobra en pagos,
guarda el pedido y publica el evento order.created en RabbitMQ. Si el cobro
falla, libera el stock reservado.

Sin instrumentar: logs de texto plano y los de acceso de uvicorn.
"""

import json
import logging
import os
from contextlib import asynccontextmanager
from decimal import Decimal

import aio_pika
import httpx
from fastapi import FastAPI, HTTPException
from psycopg.rows import dict_row
from psycopg_pool import AsyncConnectionPool
from pydantic import BaseModel, Field

DATABASE_URL = os.environ["DATABASE_URL"]
RABBITMQ_URL = os.environ["RABBITMQ_URL"]
CATALOGO_URL = os.environ["CATALOGO_URL"]
PAGOS_URL = os.environ["PAGOS_URL"]
PAGOS_TIMEOUT_SECONDS = float(os.getenv("PAGOS_TIMEOUT_SECONDS", "2"))

log = logging.getLogger("uvicorn.error")
pool = AsyncConnectionPool(DATABASE_URL, open=False, kwargs={"row_factory": dict_row})
http = httpx.AsyncClient(timeout=5)
broker: dict = {}


@asynccontextmanager
async def lifespan(_app: FastAPI):
    await pool.open(wait=True)
    broker["connection"] = await aio_pika.connect_robust(RABBITMQ_URL)
    channel = await broker["connection"].channel()
    broker["exchange"] = await channel.declare_exchange(
        "tienda", aio_pika.ExchangeType.TOPIC, durable=True
    )
    yield
    await broker["connection"].close()
    await http.aclose()
    await pool.close()


app = FastAPI(title="pedidos", lifespan=lifespan)


class Customer(BaseModel):
    email: str = Field(max_length=254)
    card_number: str = Field(pattern=r"^[0-9]{13,19}$")


class Item(BaseModel):
    product_id: int
    quantity: int = Field(gt=0, le=100)


class OrderIn(BaseModel):
    customer: Customer
    items: list[Item] = Field(min_length=1, max_length=10)


@app.get("/health")
async def health():
    return {"status": "ok"}


async def release(items: list[Item]) -> None:
    for item in items:
        try:
            await http.post(
                f"{CATALOGO_URL}/products/{item.product_id}/release",
                json={"quantity": item.quantity},
            )
        except httpx.HTTPError:
            log.warning("No se pudo liberar el stock del producto %s", item.product_id)


async def reserve_items(
    items: list[Item],
) -> tuple[list[Item], list[tuple[Item, Decimal]]]:
    reserved: list[Item] = []
    priced: list[tuple[Item, Decimal]] = []
    try:
        for item in items:
            r = await http.get(f"{CATALOGO_URL}/products/{item.product_id}")
            if r.status_code == 404:
                raise HTTPException(404, f"El producto {item.product_id} no existe")
            r.raise_for_status()
            price = Decimal(str(r.json()["price"]))

            r = await http.post(
                f"{CATALOGO_URL}/products/{item.product_id}/reserve",
                json={"quantity": item.quantity},
            )
            if r.status_code == 409:
                raise HTTPException(409, f"Sin stock del producto {item.product_id}")
            r.raise_for_status()
            reserved.append(item)
            priced.append((item, price))
    except Exception:
        await release(reserved)
        raise
    return reserved, priced


async def charge(total: Decimal, card_number: str) -> bool:
    try:
        r = await http.post(
            f"{PAGOS_URL}/charges",
            json={"amount": str(total), "card_number": card_number},
            timeout=PAGOS_TIMEOUT_SECONDS,
        )
    except httpx.HTTPError as exc:
        log.error("Error llamando a pagos: %r", exc)
        return False
    return r.status_code == 201


@app.post("/orders", status_code=201)
async def create_order(order: OrderIn):
    # ANTIPATRÓN deliberado: datos personales en el log. Se corrige en la Semana 02.
    log.info(
        "Nuevo pedido de %s con tarjeta %s",
        order.customer.email,
        order.customer.card_number,
    )

    reserved, priced = await reserve_items(order.items)
    total = sum((price * item.quantity for item, price in priced), Decimal(0))

    paid = await charge(total, order.customer.card_number)
    if not paid:
        await release(reserved)
    status = "paid" if paid else "payment_failed"

    async with pool.connection() as conn:
        row = await conn.execute(
            "INSERT INTO orders (email, total, status) VALUES (%s, %s, %s) RETURNING id",
            (order.customer.email, total, status),
        )
        order_id = (await row.fetchone())["id"]
        async with conn.cursor() as cur:
            await cur.executemany(
                "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (%s, %s, %s, %s)",
                [
                    (order_id, item.product_id, item.quantity, price)
                    for item, price in priced
                ],
            )

    if not paid:
        raise HTTPException(402, {"id": order_id, "status": status})

    await broker["exchange"].publish(
        aio_pika.Message(
            body=json.dumps(
                {
                    "order_id": order_id,
                    "email": order.customer.email,
                    "total": str(total),
                }
            ).encode(),
            content_type="application/json",
            delivery_mode=aio_pika.DeliveryMode.PERSISTENT,
        ),
        routing_key="order.created",
    )
    return {"id": order_id, "status": status, "total": total}


@app.get("/orders/{order_id}")
async def get_order(order_id: int):
    async with pool.connection() as conn:
        row = await conn.execute(
            "SELECT id, email, total, status, created_at FROM orders WHERE id = %s",
            (order_id,),
        )
        order = await row.fetchone()
        if order is None:
            raise HTTPException(404, "Pedido no encontrado")
        rows = await conn.execute(
            "SELECT product_id, quantity, price FROM order_items WHERE order_id = %s",
            (order_id,),
        )
        order["items"] = await rows.fetchall()
    return order
