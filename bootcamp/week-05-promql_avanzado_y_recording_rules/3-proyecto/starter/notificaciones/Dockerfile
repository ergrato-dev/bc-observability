# syntax=docker/dockerfile:1
# Node.js 26 ya no trae corepack: pnpm se instala desde su release oficial,
# verificado con el sha256 que publica GitHub para cada arquitectura.
FROM node:26.13.0-trixie-slim AS base

FROM base AS pnpm-amd64
ADD --checksum=sha256:565ff81174a14f6f7bd5d84c1b17e51031a80230d370a1fe24be5d16bd02a825 \
    https://github.com/pnpm/pnpm/releases/download/v12.16.1/pnpm-linux-x64.tar.gz /tmp/pnpm.tar.gz

FROM base AS pnpm-arm64
ADD --checksum=sha256:f5847699e5d528f8f8e9bcfb385e58cb9fba7482af1b1aa7b70737be42277f81 \
    https://github.com/pnpm/pnpm/releases/download/v12.16.1/pnpm-linux-arm64.tar.gz /tmp/pnpm.tar.gz

FROM pnpm-${TARGETARCH} AS deps
RUN mkdir -p /opt/pnpm && tar -xzf /tmp/pnpm.tar.gz -C /opt/pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN /opt/pnpm/pnpm install --frozen-lockfile --prod

FROM base
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src
USER node
EXPOSE 3000
CMD ["node", "src/index.js"]
