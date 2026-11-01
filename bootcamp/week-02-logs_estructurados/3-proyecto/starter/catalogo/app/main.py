"""catalogo: productos, stock y caché de la tienda.

Sin instrumentar: solo los logs de acceso de uvicorn. Cada semana del bootcamp
le añade una capa de observabilidad.
"""

import json
import os
import unicodedata
from contextlib import asynccontextmanager
from difflib import SequenceMatcher

import redis.asyncio as redis
from fastapi import FastAPI, HTTPException
from fastapi.encoders import jsonable_encoder
from psycopg.rows import dict_row
from psycopg_pool import AsyncConnectionPool
from pydantic import BaseModel, Field

DATABASE_URL = os.environ["DATABASE_URL"]
VALKEY_URL = os.environ["VALKEY_URL"]
CACHE_TTL_SECONDS = int(os.getenv("CACHE_TTL_SECONDS", "30"))

# Valkey habla el protocolo de Redis: el cliente redis-py funciona sin cambios.
cache = redis.from_url(VALKEY_URL, decode_responses=True)
pool = AsyncConnectionPool(DATABASE_URL, open=False, kwargs={"row_factory": dict_row})


@asynccontextmanager
async def lifespan(_app: FastAPI):
    await pool.open(wait=True)
    yield
    await pool.close()
    await cache.aclose()


app = FastAPI(title="catalogo", lifespan=lifespan)


class Quantity(BaseModel):
    quantity: int = Field(gt=0, le=100)


def normalize(text: str) -> str:
    return (
        unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode().lower()
    )


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/products")
async def list_products(q: str | None = None, limit: int = 20):
    async with pool.connection() as conn:
        if q:
            rows = await conn.execute(
                "SELECT id, name, description, price, stock, category_id FROM products"
            )
            products = await rows.fetchall()
            needle = normalize(q)
            scored = [
                (
                    SequenceMatcher(
                        None, needle, normalize(f"{p['name']} {p['description']}")
                    ).ratio(),
                    p,
                )
                for p in products
            ]
            scored.sort(key=lambda pair: pair[0], reverse=True)
            products = [p for score, p in scored if score > 0.2][:limit]
        else:
            rows = await conn.execute(
                "SELECT id, name, description, price, stock, category_id"
                " FROM products ORDER BY id LIMIT %s",
                (limit,),
            )
            products = await rows.fetchall()

        for product in products:
            row = await conn.execute(
                "SELECT name FROM categories WHERE id = %s",
                (product.pop("category_id"),),
            )
            product["category"] = (await row.fetchone())["name"]
    return products


@app.get("/products/{product_id}")
async def get_product(product_id: int):
    key = f"product:{product_id}"
    if cached := await cache.get(key):
        return json.loads(cached)

    async with pool.connection() as conn:
        row = await conn.execute(
            "SELECT p.id, p.name, p.description, p.price, p.stock, c.name AS category"
            " FROM products p JOIN categories c ON c.id = p.category_id WHERE p.id = %s",
            (product_id,),
        )
        product = await row.fetchone()
    if product is None:
        raise HTTPException(404, "Producto no encontrado")

    data = jsonable_encoder(product)
    await cache.set(key, json.dumps(data), ex=CACHE_TTL_SECONDS)
    return data


@app.post("/products/{product_id}/reserve")
async def reserve(product_id: int, body: Quantity):
    async with pool.connection() as conn:
        row = await conn.execute(
            "UPDATE products SET stock = stock - %s WHERE id = %s AND stock >= %s RETURNING stock",
            (body.quantity, product_id, body.quantity),
        )
        updated = await row.fetchone()
        if updated is None:
            exists = await (
                await conn.execute(
                    "SELECT 1 FROM products WHERE id = %s", (product_id,)
                )
            ).fetchone()
            raise HTTPException(
                409 if exists else 404,
                "Sin stock" if exists else "Producto no encontrado",
            )
    await cache.delete(f"product:{product_id}")
    return updated


@app.post("/products/{product_id}/release")
async def release(product_id: int, body: Quantity):
    async with pool.connection() as conn:
        row = await conn.execute(
            "UPDATE products SET stock = stock + %s WHERE id = %s RETURNING stock",
            (body.quantity, product_id),
        )
        updated = await row.fetchone()
    if updated is None:
        raise HTTPException(404, "Producto no encontrado")
    await cache.delete(f"product:{product_id}")
    return updated
