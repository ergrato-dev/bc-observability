// Tráfico sintético de la tienda: navegación, búsquedas y compras.
//
//   RATE      iteraciones por segundo (por defecto 2)
//   DURATION  duración total (por defecto 24h)
//
// Fondo continuo: el servicio "trafico" de compose.yaml.
// Pico puntual:   docker compose run --rm -e RATE=30 -e DURATION=2m trafico

import http from "k6/http";
import { check } from "k6";

const CATALOGO = __ENV.CATALOGO_URL || "http://catalogo:8000";
const PEDIDOS = __ENV.PEDIDOS_URL || "http://pedidos:8000";
const SEARCHES = ["cafe organico", "te premium", "taza", "molino artesanal", "termo"];

export const options = {
  // k6 cachea el DNS 5 minutos: al recrear un servicio cambia su IP y el tráfico
  // fallaría hasta entonces.
  dns: { ttl: "1s" },
  scenarios: {
    compra: {
      executor: "constant-arrival-rate",
      rate: Number(__ENV.RATE || 2),
      timeUnit: "1s",
      duration: __ENV.DURATION || "24h",
      preAllocatedVUs: 10,
      maxVUs: 100,
    },
  },
};

const pick = (list) => list[Math.floor(Math.random() * list.length)];
const productId = () => 1 + Math.floor(Math.random() * 500);

export default function () {
  const r = Math.random();

  if (r < 0.1) {
    const res = http.get(`${CATALOGO}/products?q=${encodeURIComponent(pick(SEARCHES))}`, {
      tags: { name: "GET /products?q" },
    });
    check(res, { "búsqueda 200": (x) => x.status === 200 });
  } else if (r < 0.4) {
    const res = http.get(`${CATALOGO}/products?limit=20`, { tags: { name: "GET /products" } });
    check(res, { "listado 200": (x) => x.status === 200 });
  } else if (r < 0.75) {
    const res = http.get(`${CATALOGO}/products/${productId()}`, {
      tags: { name: "GET /products/{id}" },
    });
    check(res, { "detalle 200": (x) => x.status === 200 });
  } else {
    const items = Array.from({ length: 1 + Math.floor(Math.random() * 3) }, () => ({
      product_id: productId(),
      quantity: 1 + Math.floor(Math.random() * 3),
    }));
    const body = JSON.stringify({
      customer: { email: `cliente${__VU}@example.com`, card_number: "4111111111111111" },
      items,
    });
    const res = http.post(`${PEDIDOS}/orders`, body, {
      headers: { "Content-Type": "application/json" },
      tags: { name: "POST /orders" },
    });
    // 402: el cobro falló (avería de pagos). Es una respuesta válida del negocio.
    check(res, { "pedido 201 o 402": (x) => x.status === 201 || x.status === 402 });
  }
}
