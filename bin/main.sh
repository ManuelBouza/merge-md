#!/bin/bash
# ==============================================================================
# Script: main.sh
# Descripción: Script principal que coordina el merge y conversión a HTML
#              de múltiples archivos Markdown en una carpeta.
# Uso: merge-md <ruta_carpeta> [--keep]
# Dependencias: merge_md_folder.sh, md2html.sh, pandoc
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# --- Función para mostrar errores ---
err() {
  printf "❌ %s\n" "$*" >&2
}

# --- Función para abrir el HTML generado en el navegador ---
open_browser() {
  local file="$1"
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$file" >/dev/null 2>&1 &
  elif command -v open >/dev/null 2>&1; then
    open "$file" >/dev/null 2>&1 &
  elif command -v start >/dev/null 2>&1; then
    start "$file" >/dev/null 2>&1 &
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    # Compatibilidad con WSL
    powershell.exe start "\"$(wslpath -w "$file")\"" >/dev/null 2>&1 &
  else
    printf "⚠️  No se encontró un comando compatible para abrir el navegador.\n"
  fi
}

# --- Función principal ---
main() {
  if [[ $# -lt 1 ]]; then
    err "Uso: merge-md <ruta_carpeta> [--keep]"
    exit 64
  fi

  local input_dir="$1"
  local keep_files="${2:-}"

  if [[ ! -d "$input_dir" ]]; then
    err "Error: no existe el directorio '$input_dir'"
    exit 66
  fi

  # Resolver rutas absolutas y nombres
  local abs_dir folder_name md_file html_file
  abs_dir="$(cd "$input_dir" && pwd)"
  folder_name="$(basename "$abs_dir")"
  # <-- Ahora los archivos generados se colocan dentro de la carpeta de entrada
  md_file="${abs_dir}/${folder_name}.md"
  html_file="${abs_dir}/${folder_name}.html"

  # Obtener ruta real del script (resuelve enlaces simbólicos)
  local script_path script_dir
  script_path="$(readlink -f "${BASH_SOURCE[0]}")"
  script_dir="$(cd "$(dirname "$script_path")" && pwd)"

  printf "🚀 Iniciando proceso para: %s\n" "$abs_dir"

  # 1️⃣ Unir los .md
  printf "\n📘 [1/3] Combinando Markdown...\n"
  bash "${script_dir}/merge_md_folder.sh" "$abs_dir"

  # 2️⃣ Convertir a HTML
  printf "\n📄 [2/3] Generando HTML...\n"
  bash "${script_dir}/md2html.sh" "$md_file"

  # 3️⃣ Abrir en navegador
  printf "\n🌐 [3/3] Abriendo en navegador...\n"
  open_browser "$html_file"

  # Espera breve antes de limpiar, para permitir que el navegador cargue el archivo
  sleep 3

  # 🧹 4️⃣ Eliminar archivos temporales (por defecto)
  if [[ "$keep_files" != "--keep" ]]; then
    printf "\n🧹 Limpiando archivos temporales...\n"
    if [[ -f "$md_file" ]]; then
      rm -f "$md_file"
    fi
    if [[ -f "$html_file" ]]; then
      rm -f "$html_file"
    fi
    printf "✅ Archivos eliminados.\n"
  else
    printf "\n📦 Opción --keep detectada: se conservarán los archivos generados.\n"
  fi

  printf "\n✅ Proceso completado con éxito.\n"
}

main "$@"
