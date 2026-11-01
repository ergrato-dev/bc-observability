// Lab 02 — Prueba en escalón contra el checkout de la tienda.
//
// Ejecútala desde la carpeta del lab:
//   docker compose -f ../../../../app/compose.yaml run --rm \
//     -v "$PWD/starter:/lab:ro" trafico run /lab/escalon.js

import http from "k6/http";
import { check } from "k6";

const CATALOGO = "http://catalogo:8000";
const PEDIDOS = "http://pedidos:8000";

// TODO (paso 4): haz que k6 trate el 402 como respuesta esperada.
//   Pista: http.setResponseCallback(http.expectedStatuses(...))

export const options = {
  scenarios: {
    escalon: {
      executor: "ramping-arrival-rate",
      startRate: 5,
      timeUnit: "1s",
      preAllocatedVUs: 20,
      maxVUs: 200,
      // TODO (paso 2): cuatro etapas de 20 s: sube a 20 it/s, mantén,
      // sube a 60 it/s, mantén.
      stages: [{ target: 5, duration: "20s" }],
    },
  },
  // TODO (paso 3): umbrales. p95 de POST /orders por debajo de 500 ms y
  // menos de un 5 % de peticiones fallidas.
  thresholds: {},
};

const productId = () => 1 + Math.floor(Math.random() * 500);

export default function () {
  if (Math.random() < 0.7) {
    const res = http.get(`${CATALOGO}/products/${productId()}`, {
      tags: { name: "GET /products/{id}" },
    });
    check(res, { "detalle 200": (r) => r.status === 200 });
    return;
  }
  const res = http.post(
    `${PEDIDOS}/orders`,
    JSON.stringify({
      customer: { email: "escalon@example.com", card_number: "4111111111111111" },
      items: [{ product_id: productId(), quantity: 1 }],
    }),
    { headers: { "Content-Type": "application/json" }, tags: { name: "POST /orders" } },
  );
  check(res, { "pedido 201 o 402": (r) => r.status === 201 || r.status === 402 });
}
