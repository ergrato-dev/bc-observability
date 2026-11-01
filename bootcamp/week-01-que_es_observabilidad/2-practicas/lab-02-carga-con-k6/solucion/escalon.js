// Lab 02 — Prueba en escalón contra el checkout de la tienda (SOLUCIÓN).
//
// Ejecútala desde la carpeta del lab:
//   docker compose -f ../../../../app/compose.yaml run --rm \
//     -v "$PWD/solucion:/lab:ro" trafico run /lab/escalon.js

import http from "k6/http";
import { check } from "k6";

const CATALOGO = "http://catalogo:8000";
const PEDIDOS = "http://pedidos:8000";

// 402 es un cobro rechazado: una respuesta válida del negocio, no un fallo
// del sistema. Sin esto, http_req_failed lo contaría como error.
http.setResponseCallback(http.expectedStatuses({ min: 200, max: 299 }, 402));

export const options = {
  scenarios: {
    escalon: {
      executor: "ramping-arrival-rate",
      startRate: 5,
      timeUnit: "1s",
      preAllocatedVUs: 20,
      maxVUs: 200,
      stages: [
        { target: 20, duration: "20s" },
        { target: 20, duration: "20s" },
        { target: 60, duration: "20s" },
        { target: 60, duration: "20s" },
      ],
    },
  },
  thresholds: {
    "http_req_duration{name:POST /orders}": ["p(95)<500"],
    http_req_failed: ["rate<0.05"],
  },
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
