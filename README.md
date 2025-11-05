Perfecto 🚀
Aquí tienes el **`README.md`** completo y bien estructurado para tu proyecto **`merge-md`**.
Incluye instalación, uso, dependencias, estructura, ejemplos y créditos.

---

## 🧾 Archivo: `README.md`

```markdown
# 🧩 merge-md

**merge-md** es una herramienta de línea de comandos que automatiza la unión y conversión de múltiples archivos Markdown (`.md`) en un único documento HTML con formato profesional, compatible con *Markdown PDF (VS Code)* y *Mermaid*.

Ideal para documentaciones técnicas, reportes o libros generados a partir de varios capítulos `.md`.

---

## 🚀 Características

- 🔗 **Une** todos los archivos `.md` de una carpeta en un único archivo.
- 🧠 **Corrige rutas de imágenes** automáticamente (`./imagenes/ → ./<carpeta>/imagenes/`).
- 🎨 **Convierte a HTML** con estilo similar a *Markdown PDF (VS Code)*.
- 📊 **Soporta Mermaid**, resaltado de código y fórmulas matemáticas (*MathJax*).
- 🌐 **Abre automáticamente** el resultado final en tu navegador.

---

## 🗂️ Estructura del proyecto

```

merge-md/
├── bin/
│   ├── main.sh              # Punto de entrada (coordinador principal)
│   ├── merge_md_folder.sh   # Une los .md de una carpeta
│   ├── md2html.sh           # Convierte Markdown a HTML
├── install.sh               # Instala el comando global `merge-md`
└── README.md                # Este archivo

````

---

## ⚙️ Instalación

### Requisitos previos
- **Bash** ≥ 4.0  
- **Pandoc** ≥ 2.x  
  ```bash
  sudo apt install pandoc
````

* (Opcional) **Mermaid** y **highlight.js** se cargan automáticamente desde CDN.

---

### Instalar globalmente

Desde la raíz del proyecto:

```bash
sudo ./install.sh
```

Esto creará un enlace simbólico:

```
/usr/local/bin/merge-md → /ruta/al/proyecto/bin/main.sh
```

✅ Ahora podrás ejecutar el comando **desde cualquier carpeta**:

```bash
merge-md ./mi_documentacion
```

---

## 🧭 Uso

```bash
merge-md <carpeta_con_md>
```

### Ejemplo

Supón que tienes esta estructura:

```
docs/
├── 1-introduccion.md
├── 2-uso.md
├── 3-conclusiones.md
└── imagenes/
    └── diagrama.png
```

Ejecuta:

```bash
merge-md ./docs
```

Salida esperada:

```
🚀 Iniciando proceso para: /ruta/docs
📘 [1/3] Combinando Markdown...
📄 [2/3] Generando HTML...
🌐 [3/3] Abriendo en navegador...
✅ Proceso completado con éxito.
```

El resultado:

```
docs.md
docs.html
```

Y el archivo HTML se abrirá automáticamente en tu navegador predeterminado.

---

## 🧰 Scripts internos

| Script               | Descripción                                                            |
| -------------------- | ---------------------------------------------------------------------- |
| `merge_md_folder.sh` | Une todos los archivos `.md` en uno solo, ajustando rutas de imágenes. |
| `md2html.sh`         | Convierte el `.md` resultante a `.html` autónomo, con CSS y Mermaid.   |
| `main.sh`            | Coordina todo el proceso (merge → conversión → navegador).             |
| `install.sh`         | Crea el enlace simbólico `merge-md` en `/usr/local/bin`.               |

---

## 🧑‍💻 Desarrollo

Puedes ejecutar los scripts manualmente si deseas probarlos por separado:

```bash
bash ./bin/merge_md_folder.sh ./docs
bash ./bin/md2html.sh ./docs.md
bash ./bin/main.sh ./docs
```

---

## 🧹 Desinstalación

Si deseas eliminar el comando global:

```bash
sudo rm /usr/local/bin/merge-md
```

---

## 🧠 Licencia

MIT License © 2025
Autor: *Tu Nombre / Organización*

---

## 📚 Créditos

* [Pandoc](https://pandoc.org) — Conversor universal de documentos.
* [Mermaid](https://mermaid.js.org) — Diagramas en texto dentro de Markdown.
* [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — Guía de buenas prácticas para Bash.
* [Markdown PDF (VS Code)](https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf) — Estilos base de visualización.

---

> ✨ *merge-md: convierte tus carpetas Markdown en documentos HTML listos para compartir.*

```

---