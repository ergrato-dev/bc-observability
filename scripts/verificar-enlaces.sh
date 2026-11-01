#!/usr/bin/env bash
# Verifica la integridad estructural del bootcamp:
#   1. Nombres de carpeta week-NN-slug y lab-NN-slug bien formados.
#   2. Enlaces relativos en markdown que resuelven a una ruta real.
#   3. Seccion "Navegacion" en el README de cada semana publicada.
#   4. Cada diagrama de 0-assets/ contiene un bloque mermaid.
#   5. checks.json valido como JSON.
#   6. Todo .sh con shebang `env bash`, `set -euo pipefail` y bit de ejecucion.
#   7. Archivos de teoria de semanas publicadas con 600 palabras o menos.
#   8. Imagenes de contenedor fijadas: sin tag o :latest no valen.
#   9. Tuteo: ninguna forma de voseo en el markdown.
#  10. Python con uv y Node.js con pnpm: sin requirements.txt, package-lock.json,
#      pip install, npm install ni npx.
#  11. Puertos de Compose publicados solo en 127.0.0.1.
#
# Las comprobaciones 3, 6 (en bootcamp/), 7 y 8 (en bootcamp/) solo se aplican
# a las semanas marcadas con ✅ en bootcamp/README.md.
#
# Uso: scripts/verificar-enlaces.sh
# Salida: lista de problemas encontrados; exit code 1 si hay al menos uno.

set -euo pipefail
cd "$(dirname "$0")/.."
export LC_ALL=C.UTF-8

fail=0

publicadas=$(grep -oE '^\| \[[0-9]{2}\]\(([a-z0-9_-]+)/README\.md\).*\| ✅ \|$' bootcamp/README.md \
             | sed -E 's/^\| \[[0-9]{2}\]\(([a-z0-9_-]+)\/README\.md\).*/\1/' || true)

esta_publicada() {
  local ruta="$1" slug
  for slug in $publicadas; do
    case "$ruta" in *"$slug"*) return 0 ;; esac
  done
  return 1
}

# Lo que no es una semana sin publicar: app/, scripts/ y semanas publicadas.
aplica() {
  case "$1" in
    bootcamp/*|./bootcamp/*) esta_publicada "$1" ;;
    *) return 0 ;;
  esac
}

if [ -z "$publicadas" ]; then
  echo "AVISO: ninguna semana marcada como ✅ en bootcamp/README.md."
fi

echo "== 1. Nombres de carpeta =="
while IFS= read -r d; do
  if ! [[ "$(basename "$d")" =~ ^week-[0-9]{2}-[a-z0-9_]+$ ]]; then
    echo "NOMBRE INVALIDO (week): $d"; fail=1
  fi
done < <(find bootcamp -mindepth 1 -maxdepth 1 -type d -iname "week-*")
while IFS= read -r d; do
  if ! [[ "$(basename "$d")" =~ ^lab-[0-9]{2}-[a-z0-9-]+$ ]]; then
    echo "NOMBRE INVALIDO (lab): $d"; fail=1
  fi
done < <(find bootcamp -mindepth 3 -maxdepth 3 -type d -path "*/2-practicas/*")

echo "== 2. Enlaces relativos en markdown =="
# No parsea markdown de verdad: quita los bloques ``` y busca "](...)".
# .claude/, .github/ y PLANTILLA-SEMANA.md tienen rutas de ejemplo por diseno.
while IFS= read -r f; do
  content=$(awk '/^```/{c=!c; next} !c' "$f")
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    clean="${link%%#*}"
    [ -z "$clean" ] && continue
    case "$clean" in http*|\<http*|ws*|mailto:*|/*) continue ;; esac
    if [ ! -e "$(realpath -m "$(dirname "$f")/$clean")" ]; then
      echo "ENLACE ROTO: $f -> $link"; fail=1
    fi
  done < <(printf '%s\n' "$content" | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\(//;s/\)$//' || true)
done < <(find . -iname "*.md" -not -path "./.git/*" -not -path "*/node_modules/*" \
           -not -path "./.claude/*" -not -path "./.github/*" -not -name "PLANTILLA-SEMANA.md")

echo "== 3. Navegacion en README de cada semana publicada =="
while IFS= read -r rm; do
  esta_publicada "$rm" || continue
  if ! grep -q "Navegación" "$rm"; then
    echo "SIN NAVEGACION: $rm"; fail=1
  fi
done < <(find bootcamp -mindepth 2 -maxdepth 2 -iname "README.md")

echo "== 4. Diagramas mermaid en 0-assets/ =="
while IFS= read -r d; do
  if ! grep -q '^```mermaid' "$d"; then
    echo "DIAGRAMA SIN BLOQUE MERMAID: $d"; fail=1
  fi
done < <(find bootcamp -path "*/0-assets/*" -name "*.md")

echo "== 5. checks.json valido =="
if command -v jq >/dev/null 2>&1; then
  while IFS= read -r cj; do
    if ! jq -e '.semana and .titulo and (.checks | length > 0)' "$cj" >/dev/null 2>&1; then
      echo "CHECKS.JSON INVALIDO (JSON o campos semana/titulo/checks): $cj"; fail=1
    fi
  done < <(find bootcamp -name "checks.json")
else
  echo "AVISO: jq no esta instalado, no se validan los checks.json"
fi

echo "== 6. Cabecera de los scripts bash =="
while IFS= read -r sh; do
  aplica "$sh" || continue
  if [ "$(head -1 "$sh")" != "#!/usr/bin/env bash" ]; then
    echo "SHEBANG INCORRECTO (debe ser '#!/usr/bin/env bash'): $sh"; fail=1
  fi
  if ! grep -q 'set -euo pipefail' "$sh"; then
    echo "SIN 'set -euo pipefail': $sh"; fail=1
  fi
  if [ ! -x "$sh" ]; then
    echo "SIN BIT DE EJECUCION (chmod +x): $sh"; fail=1
  fi
done < <(find scripts app bootcamp -name "*.sh" -not -path "*/node_modules/*" 2>/dev/null)

echo "== 7. Extension de los archivos de teoria (<= 600 palabras) =="
while IFS= read -r t; do
  esta_publicada "$t" || continue
  n=$(awk '/^```/{c=!c; next} !c' "$t" | wc -w)
  if [ "$n" -gt 600 ]; then
    echo "TEORIA DEMASIADO LARGA ($n palabras de prosa, max 600): $t"; fail=1
  fi
done < <(find bootcamp -path "*/1-teoria/*" -name "*.md")

echo "== 8. Imagenes fijadas (sin tag o :latest) =="
# Una referencia valida lleva ":<tag>" en su ultimo segmento o "@sha256:".
while IFS= read -r f; do
  aplica "$f" || continue
  # Etapas con nombre de un Dockerfile multi-stage ("FROM base"): no son imagenes.
  etapas=$(grep -ioE '^FROM[[:space:]].*[[:space:]]AS[[:space:]]+[a-z0-9_.-]+' "$f" | awk '{print $NF}' || true)
  while IFS= read -r linea; do
    ref=$(sed -E 's/^[[:space:]-]*(image:|FROM)[[:space:]]*//; s/[[:space:]]+(AS|as)[[:space:]].*$//; s/[[:space:]]+#.*$//; s/["'\'']//g' <<<"$linea")
    case "$ref" in *'<'*|*'$'*|*'{{'*|scratch) continue ;; esac   # placeholders, plantillas
    grep -qxF "$ref" <<<"$etapas" && continue
    ultimo="${ref##*/}"
    if { [[ "$ultimo" != *:* ]] && [[ "$ref" != *@sha256:* ]]; } || [[ "$ultimo" == *:latest ]]; then
      echo "IMAGEN SIN VERSION (sin tag o :latest): $f: $linea"; fail=1
    fi
  done < <(grep -E '^[[:space:]-]*image:[[:space:]]*[^[:space:]]|^FROM[[:space:]]' "$f" || true)
done < <(find app bootcamp \( -name "*.yaml" -o -name "*.yml" -o -name "Dockerfile*" \) \
           -not -path "*/node_modules/*" 2>/dev/null)

echo "== 9. Tuteo, sin voseo =="
# CLAUDE.md cita las formas prohibidas como ejemplo.
VOSEO='podés|tenés|querés|sabés|hacé|usá|configurá|ejecutá|revisá|fijate|mirá|probá|instalá|corré|creá|agregá|dejá|empezá|verificá|comprobá|poné|vení|andá|decí|vos'
while IFS= read -r f; do
  if out=$(grep -nwiE "$VOSEO" "$f"); then
    printf 'VOSEO: %s\n%s\n' "$f" "$(sed 's/^/  /' <<<"$out")"; fail=1
  fi
done < <(find . -iname "*.md" -not -path "./.git/*" -not -path "*/node_modules/*" -not -name "CLAUDE.md")

echo "== 10. Python con uv, Node.js con pnpm =="
while IFS= read -r f; do
  echo "GESTOR PROHIBIDO (usa uv.lock o pnpm-lock.yaml): $f"; fail=1
done < <(find . \( -name requirements.txt -o -name "requirements*.in" -o -name package-lock.json \
           -o -name yarn.lock -o -name Pipfile \) -not -path "./.git/*" -not -path "*/node_modules/*")
while IFS= read -r f; do
  aplica "$f" || continue
  if out=$(grep -nE '(^|[^a-z])(pip3? install|python -m pip|npm (install|ci|run|i|exec)|npx )' "$f"); then
    printf 'GESTOR PROHIBIDO: %s\n%s\n' "$f" "$(sed 's/^/  /' <<<"$out")"; fail=1
  fi
done < <(find app bootcamp docs \( -name "*.md" -o -name "*.sh" -o -name "Dockerfile*" -o -name "*.yaml" \
           -o -name "*.yml" -o -name "*.json" \) -not -path "*/node_modules/*" -not -name "PLANTILLA-SEMANA.md" 2>/dev/null)

echo "== 11. Puertos de Compose solo en 127.0.0.1 =="
while IFS= read -r f; do
  aplica "$f" || continue
  if out=$(grep -nE '^[[:space:]]*-[[:space:]]*["'\'']?([0-9]+(-[0-9]+)?:|0\.0\.0\.0:)' "$f"); then
    printf 'PUERTO ABIERTO A LA RED (usa "127.0.0.1:HOST:CONTENEDOR"): %s\n%s\n' "$f" "$(sed 's/^/  /' <<<"$out")"; fail=1
  fi
done < <(find app bootcamp \( -name "compose*.yaml" -o -name "compose*.yml" -o -name "docker-compose*.y*ml" \) \
           -not -path "*/node_modules/*" 2>/dev/null)

if [ "$fail" -eq 0 ]; then
  echo "OK: sin problemas detectados."
fi
exit "$fail"
