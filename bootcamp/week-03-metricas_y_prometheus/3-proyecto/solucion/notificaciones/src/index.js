// notificaciones: consume order.created de RabbitMQ y "envía" el correo de
// confirmación de cada pedido.
//
// Semana 02: logs JSON con el esquema común de la tienda (ver logger.js).
// Semana 03: métricas RED en /metrics y mensajes procesados (ver metrics.js).

import { setTimeout as sleep } from "node:timers/promises";
import amqp from "amqplib";
import express from "express";
import { logger, logRequests } from "./logger.js";
import { measureRequests, metrics, notifications } from "./metrics.js";

const RABBITMQ_URL = process.env.RABBITMQ_URL;
const PORT = Number(process.env.PORT ?? 3000);
const DELAY_MS = Number(process.env.NOTIFICACIONES_DELAY_MS ?? 50);

let sent = 0;
let failed = 0;

const connection = await amqp.connect(RABBITMQ_URL);
connection.on("close", () => {
  logger.fatal("rabbitmq_connection_closed");
  process.exit(1);
});

const channel = await connection.createChannel();
await channel.assertExchange("tienda", "topic", { durable: true });
const { queue } = await channel.assertQueue("notificaciones.order-created", { durable: true });
await channel.bindQueue(queue, "tienda", "order.created");
await channel.prefetch(10);

await channel.consume(queue, async (msg) => {
  const log = logger.child({ request_id: msg.properties.headers?.["x-request-id"] ?? null });
  try {
    const event = JSON.parse(msg.content.toString());
    await sleep(DELAY_MS); // el "envío" del correo
    sent += 1;
    notifications.inc({ result: "sent" });
    log.info({ order_id: event.order_id }, "email_sent");
    channel.ack(msg);
  } catch (err) {
    failed += 1;
    notifications.inc({ result: "discarded" });
    log.error({ error: err.message }, "message_discarded");
    channel.nack(msg, false, false);
  }
});

const app = express();
app.use(logRequests);
app.use(measureRequests);
app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.get("/stats", (_req, res) => res.json({ sent, failed }));
app.get("/metrics", metrics);
app.listen(PORT, () => logger.info({ port: PORT }, "server_started"));
