#!/usr/bin/env python3
"""Servidor local para Flutter web — HarvestHands."""
import http.server
import mimetypes
import os

PORT = 8080
WEB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")

# MIME types que Python no siempre registra correctamente
mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("font/ttf", ".ttf")
mimetypes.add_type("font/otf", ".otf")
mimetypes.add_type("font/woff2", ".woff2")

# Extensiones que requieren Cross-Origin-Resource-Policy bajo COEP:require-corp.
# Bajo COEP, CUALQUIER sub-recurso cargado sin credenciales que no devuelva
# CORP: same-origin (o cross-origin) es bloqueado por el navegador.
# Eso incluye fuentes .ttf/.otf, imágenes, shaders .frag y binarios .bin.
_CORP_EXTENSIONS = {
    ".wasm", ".js", ".mjs",   # motor Flutter / CanvasKit
    ".ttf", ".otf", ".woff2", # fuentes (MaterialSymbolsOutlined, MaterialIcons…)
    ".png", ".jpg", ".jpeg", ".gif", ".webp",  # imágenes de assets
    ".frag", ".bin",           # shaders y datos CanvasKit
    ".json",                   # manifiestos de assets Flutter
}


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        # Necesarios para SharedArrayBuffer (SQLite worker).
        # COOP + COEP habilitan crossOriginIsolated = true en el navegador.
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")

        # CORP: same-origin en todos los assets locales.
        # Sin este header, COEP:require-corp bloquea la carga de fuentes,
        # imágenes y cualquier otro sub-recurso que no sea el documento raíz.
        ext = os.path.splitext(self.path.split("?")[0])[1].lower()
        if ext in _CORP_EXTENSIONS:
            self.send_header("Cross-Origin-Resource-Policy", "same-origin")

        super().end_headers()

    def log_message(self, fmt, *args):
        # Silenciar GETs exitosos de assets para no saturar la consola;
        # mostrar solo errores 4xx/5xx.
        code = args[1] if len(args) > 1 else ""
        if isinstance(code, str) and code.startswith(("4", "5")):
            super().log_message(fmt, *args)


if __name__ == "__main__":
    with http.server.HTTPServer(("", PORT), Handler) as httpd:
        print(f"HarvestHands web  →  http://localhost:{PORT}")
        print(f"Sirviendo desde: {WEB_DIR}")
        httpd.serve_forever()
