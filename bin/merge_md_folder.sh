#!/bin/bash
# ==============================================================================
# Script: merge_md_folder.sh
# Descripción: Une todos los archivos .md en una carpeta en un solo archivo .md
#              con el mismo nombre de la carpeta origen, preservando las rutas
#              de imágenes (./imagenes → ./<carpeta>/imagenes).
# Uso: ./merge_md_folder.sh <ruta_carpeta>
# Ejemplo: ./merge_md_folder.sh ./docs
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

main() {
  if [[ $# -ne 1 ]]; then
    printf "Uso: %s <ruta_carpeta>\n" "$0" >&2
    exit 64
  fi

  local input_dir="$1"

  if [[ ! -d "$input_dir" ]]; then
    printf "Error: No existe el directorio '%s'\n" "$input_dir" >&2
    exit 66
  fi

  # Obtener nombre de carpeta y definir archivo de salida
  local folder_name output_file
  folder_name="$(basename "$input_dir")"
  output_file="${folder_name}.md"

  printf "📘 Uniendo archivos .md desde: %s\n" "$input_dir"
  printf "📄 Archivo de salida: %s\n" "$output_file"

  # Limpia el archivo de salida si ya existe
  : > "$output_file"

  # Ordenar los .md en orden natural (1,2,3,...)
  while IFS= read -r md_file; do
    local file_name
    file_name="$(basename "$md_file")"
    printf "➕ Agregando: %s\n" "$file_name"

    # Corrige referencias a imágenes (solo si existen ./imagenes/)
    sed "s|\.\./\?imagenes/|./${folder_name}/imagenes/|g; s|\./imagenes/|./${folder_name}/imagenes/|g" \
      "$md_file" >> "$output_file"

    # Insertar salto de página entre documentos
    printf "\n<div style=\"page-break-after: always;\"></div>\n\n" >> "$output_file"
  done < <(find "$input_dir" -maxdepth 1 -type f -name "*.md" | sort -V)

  printf "✅ Combinación completada: %s\n" "$output_file"
}

main "$@"
