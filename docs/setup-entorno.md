# ⚙️ Preparar el entorno

Todo el stack corre en contenedores: en el host solo necesitas Docker con el plugin `docker compose`, `jq`, `curl` y `bash`. Python, Node.js, Prometheus, Grafana y compañía viven dentro de las imágenes. Versiones exactas: [`stack-versions.md`](stack-versions.md).

## 1. Docker Engine + plugin `docker compose`

| Sistema | Cómo |
|---|---|
| Linux | Docker Engine desde el repositorio oficial de tu distro en [docs.docker.com/engine/install](https://docs.docker.com/engine/install/). Incluye el plugin `docker compose` |
| Windows | WSL2 con Ubuntu 24.04 y Docker Engine instalado **dentro** de WSL2 (como en Linux) |
| macOS | Docker Engine en una VM ligera con [Colima](https://github.com/abiosoft/colima) (`colima start --memory 8`) |

Comprueba:

```bash
docker version --format '{{.Server.Version}}'
docker compose version
```

`docker-compose` con guion es Compose v1, en EOL desde 2023: no sirve. El plugin actual se versiona como 2.x o superior (5.x en 2026).

## 2. Memoria

El laboratorio pide **8 GB libres para Docker** y 12 GB en las semanas 18 y 20 ([perfiles](perfiles-de-laboratorio.md)). En WSL2, crea o edita `%UserProfile%\.wslconfig` en Windows:

```ini
[wsl2]
memory=12GB
```

y reinicia con `wsl --shutdown` desde PowerShell.

## 3. Utilidades del host

```bash
# Debian / Ubuntu / WSL2
sudo apt-get update && sudo apt-get install -y jq curl

# macOS
brew install jq curl
```

## 4. Opcional: editar la tienda fuera de los contenedores

Solo si quieres autocompletado o ejecutar tests en el host. Python siempre con **uv**, Node.js siempre con **pnpm**:

```bash
# uv (instalador oficial: https://docs.astral.sh/uv/getting-started/installation/)
uv --version
uv python install 3.14

# Node.js 26 LTS (con el gestor de versiones que prefieras) y pnpm vía corepack
corepack enable pnpm
pnpm --version
```

## 5. Semana 18: Kubernetes

Instala `kind`, `kubectl` y `helm` desde sus releases oficiales, verificando el checksum que publica cada proyecto. Versiones en [`stack-versions.md`](stack-versions.md).

## 6. Comprobación final

```bash
./scripts/verificar-semana.sh --doctor
```

Todo lo obligatorio tiene que salir en ✅.

---

[← Volver al índice de documentación](README.md)
