// notificaciones: consume order.created de RabbitMQ y "envía" el correo de
// confirmación de cada pedido.
//
// Sin instrumentar: console.log en texto plano.

import { setTimeout as sleep } from "node:timers/promises";
import amqp from "amqplib";
import express from "express";

const RABBITMQ_URL = process.env.RABBITMQ_URL;
const PORT = Number(process.env.PORT ?? 3000);
const DELAY_MS = Number(process.env.NOTIFICACIONES_DELAY_MS ?? 50);

let sent = 0;
let failed = 0;

const connection = await amqp.connect(RABBITMQ_URL);
connection.on("close", () => {
  console.error("Conexión con RabbitMQ cerrada; el contenedor se reinicia");
  process.exit(1);
});

const channel = await connection.createChannel();
await channel.assertExchange("tienda", "topic", { durable: true });
const { queue } = await channel.assertQueue("notificaciones.order-created", { durable: true });
await channel.bindQueue(queue, "tienda", "order.created");
await channel.prefetch(10);

await channel.consume(queue, async (msg) => {
  try {
    const event = JSON.parse(msg.content.toString());
    await sleep(DELAY_MS); // el "envío" del correo
    sent += 1;
    // ANTIPATRÓN deliberado: el email del cliente en el log. Se corrige en la Semana 02.
    console.log(`Correo enviado a ${event.email} para el pedido ${event.order_id}`);
    channel.ack(msg);
  } catch (err) {
    failed += 1;
    console.error(`Mensaje descartado: ${err.message}`);
    channel.nack(msg, false, false);
  }
});

const app = express();
app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.get("/stats", (_req, res) => res.json({ sent, failed }));
app.listen(PORT, () => console.log(`notificaciones escuchando en :${PORT}`));
