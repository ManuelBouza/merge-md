#!/bin/bash
# ==============================================================================
# Script: install.sh
# Descripción: Crea un enlace simbólico global hacia el script principal
#              (bin/main.sh) para ejecutar el comando `merge-md` desde cualquier lugar.
# Uso: sudo ./install.sh
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

APP_NAME="merge-md"
TARGET_DIR="/usr/local/bin"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PATH="${PROJECT_ROOT}/bin/main.sh"
LINK_PATH="${TARGET_DIR}/${APP_NAME}"

err() { printf "❌ %s\n" "$*" >&2; }

main() {
  printf "🔧 Instalando %s...\n" "$APP_NAME"

  if [[ $EUID -ne 0 ]]; then
    err "Este script debe ejecutarse con privilegios de administrador (sudo)."
    exit 1
  fi

  if [[ ! -f "$SOURCE_PATH" ]]; then
    err "No se encontró el script principal en: $SOURCE_PATH"
    exit 2
  fi

  # Si ya existe un enlace o archivo, preguntar antes de sobrescribir
  if [[ -e "$LINK_PATH" ]]; then
    printf "⚠️  Ya existe un archivo o enlace en %s\n" "$LINK_PATH"
    read -r -p "¿Deseas reemplazarlo? [s/N]: " response
    if [[ ! "$response" =~ ^[sS]$ ]]; then
      printf "❌ Instalación cancelada.\n"
      exit 0
    fi
    rm -f "$LINK_PATH"
  fi

  ln -s "$SOURCE_PATH" "$LINK_PATH"
  chmod +x "$SOURCE_PATH"

  printf "✅ Instalación completada.\n"
  printf "🔗 Enlace creado: %s → %s\n" "$LINK_PATH" "$SOURCE_PATH"
  printf "🚀 Ahora puedes ejecutar el comando:\n\n"
  printf "    %s <carpeta_con_md>\n\n" "$APP_NAME"
}

main "$@"
