#!/bin/bash
# ==============================================================================
# Script: md2html.sh
# Descripción: Convierte un archivo Markdown (.md) a HTML autónomo con estilos
#              similares a "Markdown PDF" (VS Code), incluyendo CSS y Mermaid.
# Uso: ./md2html.sh <ruta/archivo.md>
# Reqs: pandoc >= 2.x
# ==============================================================================
set -euo pipefail
IFS=$'\n\t'

err() { printf "%s\n" "$*" >&2; }

cleanup() {
  [[ -n "${TMP_HEADER:-}" && -f "${TMP_HEADER:-}" ]] && rm -f "$TMP_HEADER"
  [[ -n "${TMP_PREBODY:-}" && -f "${TMP_PREBODY:-}" ]] && rm -f "$TMP_PREBODY"
}
trap cleanup EXIT

main() {
  if [[ $# -ne 1 ]]; then
    err "Uso: $0 <ruta/archivo.md>"
    exit 64
  fi

  local md_in="$1"
  if [[ ! -f "$md_in" ]]; then
    err "Error: no existe el archivo: $md_in"
    exit 66
  fi

  if ! command -v pandoc >/dev/null 2>&1; then
    err "Error: se requiere 'pandoc'. Instálalo e inténtalo de nuevo."
    exit 69
  fi

  local md_abs
  md_abs="$(cd "$(dirname "$md_in")" && pwd)/$(basename "$md_in")"

local base out_html
base="$(basename "$md_in")"
out_html="${md_abs%.*}.html"


  # Archivos temporales para inyectar estilos y scripts
  TMP_HEADER="$(mktemp)"
  TMP_PREBODY="$(mktemp)"

  # Si existe un markdown-pdf.css junto al .md, lo enlazamos además
  local css_sidecar=""
  local md_dir
  md_dir="$(dirname "$md_abs")"
  if [[ -f "${md_dir}/markdown-pdf.css" ]]; then
    # Usamos ruta file:// absoluta para evitar problemas de carga
    css_sidecar="<link rel=\"stylesheet\" href=\"file://${md_dir}/markdown-pdf.css\" type=\"text/css\">"
  fi

  # --- HEADER: Estilos VS Code / Markdown PDF + Highlight (Tomorrow) ---
  cat > "$TMP_HEADER" <<'EOF'
<style>
/* VS Code markdown.css (adaptado) */
body {
  font-family: var(--vscode-markdown-font-family, -apple-system, BlinkMacSystemFont, "Segoe WPC", "Segoe UI", "Ubuntu", "Droid Sans", sans-serif);
  font-size: var(--vscode-markdown-font-size, 14px);
  padding: 0 26px;
  line-height: var(--vscode-markdown-line-height, 22px);
  word-wrap: break-word;
}
img { max-width: 100%; max-height: 100%; }
a { text-decoration: none; }
a:hover { text-decoration: underline; }
hr { border: 0; height: 2px; border-bottom: 2px solid; }
h1 { padding-bottom: .3em; line-height: 1.2; border-bottom: 1px solid; }
h1, h2, h3 { font-weight: normal; }
table { border-collapse: collapse; }
table thead tr th { text-align: left; border-bottom: 1px solid; }
table thead tr th, table thead tr td, table tbody tr th, table tbody tr td { padding: 5px 10px; }
table tbody tr + tr td { border-top: 1px solid; }
blockquote { margin: 0 7px 0 5px; padding: 0 16px 0 10px; border-left: 5px solid; }
code {
  font-family: Menlo, Monaco, Consolas, "Droid Sans Mono", "Courier New", monospace, "Droid Sans Fallback";
  font-size: 1em;
  line-height: 1.357em;
}
pre:not(.hljs), pre.hljs code > div {
  padding: 16px; border-radius: 3px; overflow: auto;
}
.vscode-light pre { background-color: rgba(220,220,220,.4); }
.vscode-dark pre  { background-color: rgba(10,10,10,.4);  }
.vscode-high-contrast pre { background-color: #000; }
.vscode-high-contrast h1 { border-color: #000; }
.vscode-light table thead tr th { border-color: rgba(0,0,0,.69); }
.vscode-dark table thead tr th  { border-color: rgba(255,255,255,.69); }
.vscode-light h1, .vscode-light hr, .vscode-light table tbody tr + tr td { border-color: rgba(0,0,0,.18); }
.vscode-dark h1, .vscode-dark hr, .vscode-dark table tbody tr + tr td { border-color: rgba(255,255,255,.18); }
</style>

<style>
/* Markdown PDF CSS (núcleo) */
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe WPC", "Segoe UI", "Ubuntu", "Droid Sans", sans-serif, "Meiryo";
  margin: 0 auto;
  max-width: 900px;       /* Igual al ancho visual de Markdown PDF */
  padding: 0 50px 40px;   /* Márgenes más amplios y espacio inferior */
  line-height: 1.6;       /* Mejora la legibilidad */
  background: #fff;
}
pre {
  background-color: #f8f8f8; border: 1px solid #ccc; border-radius: 3px;
  overflow-x: auto; white-space: pre-wrap; overflow-wrap: break-word;
}
pre:not(.hljs) { padding: 23px; line-height: 19px; }
blockquote { background: rgba(127,127,127,.1); border-color: rgba(0,122,204,.5); }
.emoji { height: 1.4em; }
code { font-size: 14px; line-height: 19px; }
/* inline code */
:not(pre):not(.hljs) > code { color: #C9AE75; font-size: inherit; }
/* Page Break helper: <div class="page"></div> */
.page { page-break-after: always; }
</style>

<style>
/* Highlight.js - Tomorrow Theme (resumen) */
.hljs-comment, .hljs-quote { color: #8e908c; }
.hljs-variable, .hljs-template-variable, .hljs-tag, .hljs-name,
.hljs-selector-id, .hljs-selector-class, .hljs-regexp, .hljs-deletion { color: #c82829; }
.hljs-number, .hljs-built_in, .hljs-builtin-name, .hljs-literal,
.hljs-type, .hljs-params, .hljs-meta, .hljs-link { color: #f5871f; }
.hljs-attribute { color: #eab700; }
.hljs-string, .hljs-symbol, .hljs-bullet, .hljs-addition { color: #718c00; }
.hljs-title, .hljs-section { color: #4271ae; }
.hljs-keyword, .hljs-selector-tag { color: #8959a8; }
.hljs { display: block; overflow-x: auto; color: #4d4d4c; padding: .5em; }
.hljs-emphasis { font-style: italic; }
.hljs-strong { font-weight: bold; }
</style>
EOF

  # Inyecta (si existe) el CSS sidecar como en el ejemplo del usuario
  if [[ -n "$css_sidecar" ]]; then
    printf "%s\n" "$css_sidecar" >> "$TMP_HEADER"
  fi

  # --- PRE-BODY: Carga e inicializa Mermaid (como el ejemplo) ---
  cat > "$TMP_PREBODY" <<'EOF'
<script src="https://unpkg.com/mermaid/dist/mermaid.min.js"></script>
<script>
  (function() {
    try {
      mermaid.initialize({
        startOnLoad: true,
        theme: (document.body.classList.contains('vscode-dark') ||
                document.body.classList.contains('vscode-high-contrast')) ? 'dark' : 'default'
      });
    } catch (e) {
      console && console.warn && console.warn('Mermaid init skipped:', e);
    }
  })();
</script>
EOF

  printf "📝 Archivo de entrada: %s\n" "$md_abs"
  printf "📄 Generando HTML: %s\n" "$out_html"

  pandoc \
    --from=gfm \
    --to=html5 \
    --standalone \
    --metadata "title=${base}" \
    --include-in-header "$TMP_HEADER" \
    --include-before-body "$TMP_PREBODY" \
    --highlight-style=pygments \
    --mathjax \
    -o "$out_html" \
    "$md_abs"

  printf "✅ Conversión completa: %s\n" "$out_html"
}

main "$@"
