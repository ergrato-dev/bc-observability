#!/usr/bin/env bash
#
# verificar-semana.sh — autograding declarativo del bootcamp.
#
# Uso:
#   ./scripts/verificar-semana.sh 03        comprueba la Semana 03
#   ./scripts/verificar-semana.sh --doctor  comprueba tu entorno
#   ENTREGA=solucion ./scripts/verificar-semana.sh 03
#                                           comprueba la solucion de referencia
#
# Este script no sabe nada de ninguna semana en concreto: lee las
# comprobaciones de bootcamp/week-NN-*/checks.json y las ejecuta en el host.
# Si necesitas logica especifica de una semana, el sitio es el checks.json,
# nunca este archivo. Contrato completo: docs/autograding.md.

set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

rojo()  { printf '\033[0;31m%s\033[0m\n' "$*"; }
verde() { printf '\033[0;32m%s\033[0m\n' "$*"; }
gris()  { printf '\033[0;90m%s\033[0m\n' "$*"; }

# ---------------------------------------------------------------------------
# --doctor: comprueba las dependencias antes de culpar al material
# ---------------------------------------------------------------------------
doctor() {
  local fallos=0

  comprobar() {
    local etiqueta="$1" resultado="$2" detalle="${3:-}"
    if [[ "$resultado" == ok ]]; then
      printf '  \033[0;32m✅\033[0m %-14s %s\n' "$etiqueta" "$detalle"
    else
      printf '  \033[0;31m❌\033[0m %-14s %s\n' "$etiqueta" "$detalle"
      fallos=$(( fallos + 1 ))
    fi
  }

  opcional() {
    if command -v "$1" >/dev/null 2>&1; then
      printf '  \033[0;32m✅\033[0m %-14s %s\n' "$1" "$("$@" 2>/dev/null | head -1)"
    else
      printf '  \033[0;33m➖\033[0m %-14s %s\n' "$1" "no instalado (${MOTIVO})"
    fi
  }

  echo "Obligatorio:"

  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    comprobar "docker" ok "$(docker version --format '{{.Server.Version}}' 2>/dev/null)"
    if docker compose version >/dev/null 2>&1; then
      comprobar "compose" ok "$(docker compose version --short)"
    else
      comprobar "compose" no "falta el plugin docker compose — docs/setup-entorno.md"
    fi
    # Memoria que Docker puede usar (en WSL2 y Docker Desktop, la de la VM).
    local mem_gb
    mem_gb=$(( $(docker info --format '{{.MemTotal}}') / 1024 / 1024 / 1024 ))
    if (( mem_gb >= 8 )); then
      comprobar "RAM docker" ok "${mem_gb} GB"
    else
      comprobar "RAM docker" no "${mem_gb} GB — se necesitan 8 GB (docs/perfiles-de-laboratorio.md)"
    fi
  else
    comprobar "docker" no "no disponible — el laboratorio no puede arrancar"
  fi

  local herramienta
  for herramienta in jq curl bash; do
    if command -v "$herramienta" >/dev/null 2>&1; then
      comprobar "$herramienta" ok "$("$herramienta" --version 2>/dev/null | head -1 | cut -d" " -f1-4)"
    else
      comprobar "$herramienta" no "no instalado — ver docs/setup-entorno.md"
    fi
  done

  echo
  echo "Para editar la tienda fuera de los contenedores:"
  MOTIVO="Python siempre con uv" opcional uv --version
  MOTIVO="notificaciones y web" opcional node --version
  MOTIVO="Node.js siempre con pnpm" opcional pnpm --version

  echo
  echo "Semana 18 (Kubernetes):"
  MOTIVO="docs/setup-entorno.md" opcional kind version
  MOTIVO="docs/setup-entorno.md" opcional kubectl version --client
  MOTIVO="docs/setup-entorno.md" opcional helm version --short

  echo
  if (( fallos == 0 )); then
    verde "Todo listo."
    return 0
  fi
  rojo "$fallos comprobacion(es) del entorno fallaron."
  return 1
}

# ---------------------------------------------------------------------------
# Evaluacion de una asercion
#   exit0        el comando sale con 0
#   exit!=0      el comando sale distinto de 0
#   exit=N       el comando sale exactamente con N
#   stdout~RE    la salida casa con la expresion regular extendida RE
#   stdout!~RE   la salida NO casa con RE
# ---------------------------------------------------------------------------
evaluar() {
  local asercion="$1" codigo="$2" salida="$3"

  case "$asercion" in
    exit0)      [[ "$codigo" -eq 0 ]] ;;
    "exit!=0")  [[ "$codigo" -ne 0 ]] ;;
    exit=*)     [[ "$codigo" -eq "${asercion#exit=}" ]] ;;
    "stdout!~"*) ! grep -qE "${asercion#stdout!~}" <<<"$salida" ;;
    stdout~*)   grep -qE "${asercion#stdout~}" <<<"$salida" ;;
    *)
      rojo "ASERCION DESCONOCIDA: '$asercion'"
      gris "Validas: exit0, exit!=0, exit=N, stdout~RE, stdout!~RE"
      return 2
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Ejecucion de una semana
# ---------------------------------------------------------------------------
verificar_semana() {
  local semana="$1"

  if ! [[ "$semana" =~ ^[0-9]{2}$ ]]; then
    rojo "La semana se indica con dos digitos: 01, 02 ... 22"
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    rojo "Falta jq. ./scripts/verificar-semana.sh --doctor"
    exit 1
  fi

  local dir
  dir=$(find bootcamp -maxdepth 1 -type d -name "week-${semana}-*" | head -1)
  if [[ -z "$dir" ]]; then
    rojo "No existe la carpeta de la Semana $semana."
    exit 1
  fi

  local archivo="$dir/checks.json"
  if [[ ! -f "$archivo" ]]; then
    rojo "La Semana $semana todavia no tiene checks.json."
    gris "Se escribe antes que el contenido: ver docs/autograding.md"
    exit 1
  fi

  if ! jq -e . "$archivo" >/dev/null 2>&1; then
    rojo "checks.json invalido: $archivo"
    exit 1
  fi

  echo "Semana $semana — $(jq -r '.titulo' "$archivo")  [perfil: $(jq -r '.perfil // "ninguno"' "$archivo")]"
  echo

  local total=0 pasados=0
  local descripcion cmd asercion pista codigo salida

  # El primer campo (id) se descarta con "_": este script reporta por descripcion.
  while IFS=$'\t' read -r _ descripcion cmd asercion pista; do
    total=$(( total + 1 ))

    # Los marcadores dejan el checks.json independiente de rutas.
    cmd=${cmd//\{semana\}/$dir}
    cmd=${cmd//\{raiz\}/$RAIZ}
    # El estudiante trabaja en starter/; el instructor valida solucion/.
    cmd=${cmd//\{proyecto\}/$dir/3-proyecto/${ENTREGA:-starter}}

    # `if` alrededor: con `set -e`, capturar el codigo de un comando que falla
    # a proposito requiere que la ejecucion este en un contexto condicional.
    # </dev/null: un comando no puede comerse el resto de checks.json.
    if salida=$(bash -c "$cmd" </dev/null 2>&1); then codigo=0; else codigo=$?; fi

    if evaluar "$asercion" "$codigo" "$salida"; then
      printf '  \033[0;32m✅\033[0m %s\n' "$descripcion"
      pasados=$(( pasados + 1 ))
    else
      printf '  \033[0;31m❌\033[0m %s\n' "$descripcion"
      printf '     \033[0;90mpista: %s\033[0m\n' "$pista"
    fi
  # join(), no @tsv: @tsv duplica cada backslash literal y read -r nunca lo
  # deshace, asi que una regex con \. se rompe en silencio. join() es seguro
  # mientras ningun campo tenga un tab o salto de linea.
  done < <(jq -r '.checks[] | [.id, .descripcion, .cmd, .assert, .pista] | join("\t")' "$archivo")

  echo
  if (( pasados == total )); then
    verde "$pasados/$total comprobaciones superadas."
    return 0
  fi
  rojo "$pasados/$total comprobaciones superadas."
  gris "Cada pista dice en que lab y en que paso se arregla."
  return 1
}

# ---------------------------------------------------------------------------
case "${1:-}" in
  --doctor)      doctor ;;
  -h|--help|"")  sed -n '3,14p' "${BASH_SOURCE[0]}" | sed 's|^# \?||' ;;
  *)             verificar_semana "$1" ;;
esac
