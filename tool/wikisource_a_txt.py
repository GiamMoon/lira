#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Descarga una obra de Wikisource y la deja en texto plano limpio.

Wikisource es la mejor fuente para literatura hispanoamericana de dominio
publico: el texto ya viene sin columnas, sin numeros de pagina, sin cabeceras
repetidas y sin las palabras partidas que arrastra cualquier PDF. Cuando la
obra esta ahi, este camino gana siempre al de convertir un PDF.

Uso:

    python tool/wikisource_a_txt.py "Paco Yunque" --salida textos/paco-yunque.txt

Y despues, igual que cualquier otro texto:

    python tool/pdf_a_lira.py textos/paco-yunque.txt --libro paco-yunque --partir-en 3

Ojo con el titulo: tiene que ser EXACTO. Si falla, buscalo en
https://es.wikisource.org y copia el titulo tal cual aparece.
"""

import argparse
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

API = "https://es.wikisource.org/w/index.php?title={}&action=raw"
AGENTE = "LiraBot/1.0 (proyecto educativo)"

# Muchas obras no guardan el texto en su propia pagina: lo transcluyen desde
# las paginas escaneadas de un libro.  <pages index="Libro.pdf" include=101-106/>
RE_TRANSCLUSION = re.compile(
    r'<pages\s+index="([^"]+)"[^>]*?(?:include|from)=(\d+)(?:[-–]|"?\s+to=")(\d+)',
    re.IGNORECASE,
)

# Final de frase: si una linea no acaba asi y la siguiente empieza en
# minuscula, es que la frase continua (pasa al cruzar pagina).
RE_FIN_FRASE = re.compile(r"[.!?:;»”\"']\s*$")


def pedir(titulo: str) -> str:
    url = API.format(urllib.parse.quote(titulo.replace(" ", "_")))
    pedido = urllib.request.Request(url, headers={"User-Agent": AGENTE})
    with urllib.request.urlopen(pedido, timeout=60) as respuesta:
        return respuesta.read().decode("utf-8", errors="replace")


def descargar(titulo: str) -> str:
    datos = pedir(titulo)

    if datos.lstrip().startswith("<!DOCTYPE html"):
        sys.exit(
            "Wikisource no tiene ninguna pagina con ese titulo exacto:\n"
            "  " + titulo + "\n"
            "Buscalo en https://es.wikisource.org y copialo tal cual."
        )

    coincidencia = RE_TRANSCLUSION.search(datos)
    if not coincidencia:
        return datos

    indice, desde, hasta = coincidencia.group(1), int(
        coincidencia.group(2)
    ), int(coincidencia.group(3))
    print(
        "  La obra se transcluye de %s, paginas %d-%d. Bajando una a una."
        % (indice, desde, hasta)
    )

    trozos = []
    for numero in range(desde, hasta + 1):
        pagina = pedir("Página:%s/%d" % (indice, numero))
        if pagina.lstrip().startswith("<!DOCTYPE html"):
            print("    pagina %d: no existe, se salta" % numero)
            continue
        # Lo que va en <noinclude> son cabeceras y pies del escaneo.
        pagina = re.sub(
            r"<noinclude>.*?</noinclude>", "", pagina, flags=re.DOTALL
        )
        pagina = re.sub(r"</?noinclude>", "", pagina)
        trozos.append(pagina.strip("\n"))
        print("    pagina %d: %d caracteres" % (numero, len(pagina)))

    return unir_paginas(trozos)


def unir_paginas(trozos: list) -> str:
    """Pega las paginas respetando las frases cortadas por el salto."""
    salida = ""
    for trozo in trozos:
        if not salida:
            salida = trozo
            continue
        ultima = salida.rstrip().rsplit("\n", 1)[-1]
        if RE_FIN_FRASE.search(ultima):
            salida += "\n\n" + trozo
        else:
            salida = salida.rstrip() + " " + trozo.lstrip()
    return salida


def limpiar(wiki: str) -> str:
    """Convierte el wikitexto en prosa limpia."""
    texto = wiki

    # Comentarios y plantillas {{...}}, incluidas las anidadas.
    texto = re.sub(r"<!--.*?-->", "", texto, flags=re.DOTALL)
    for _ in range(3):
        texto = re.sub(r"\{\{[^{}]*\}\}", "", texto)

    # Categorias y archivos: no son parte de la obra.
    texto = re.sub(
        r"\[\[(?:Categor[ií]a|Archivo|File|Image):[^\]]*\]\]", "", texto
    )

    # Enlaces internos: [[destino|texto]] -> texto ; [[texto]] -> texto
    texto = re.sub(r"\[\[[^\]|]*\|([^\]]*)\]\]", r"\1", texto)
    texto = re.sub(r"\[\[([^\]]*)\]\]", r"\1", texto)

    # Enlaces externos: [url texto] -> texto
    texto = re.sub(r"\[https?://\S+ ([^\]]*)\]", r"\1", texto)

    # Encabezados de seccion en MAYUSCULAS: asi el conversor los reconoce
    # como titulo y no los pega al parrafo siguiente.
    texto = re.sub(
        r"^\s*=+\s*(.+?)\s*=+\s*$",
        lambda m: m.group(1).upper(),
        texto,
        flags=re.MULTILINE,
    )

    # Negritas y cursivas del wikitexto.
    texto = texto.replace("'''''", "").replace("'''", "").replace("''", "")

    # Etiquetas HTML sueltas.
    texto = re.sub(r"<[^>]+>", "", texto)

    # La raya de dialogo suele venir seguida de tabulador.
    texto = texto.replace("—\t", "—").replace("–\t", "—")

    # Espacios y lineas en blanco sobrantes.
    texto = re.sub(r"[ \t]+", " ", texto)
    texto = re.sub(r" *\n *", "\n", texto)
    texto = re.sub(r"\n{3,}", "\n\n", texto)

    return texto.strip() + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Descarga una obra de Wikisource en texto plano."
    )
    parser.add_argument("titulo", help="titulo exacto en es.wikisource.org")
    parser.add_argument("--salida", required=True, help="archivo .txt de destino")
    args = parser.parse_args()

    print("Descargando: " + args.titulo)
    crudo = descargar(args.titulo)
    limpio = limpiar(crudo)

    if len(limpio.split()) < 50:
        sys.exit(
            "Salieron menos de 50 palabras. Probablemente la pagina solo sea\n"
            "un indice. Abrela en el navegador y busca el titulo del texto."
        )

    destino = Path(args.salida)
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(limpio, encoding="utf-8")

    lineas = [p for p in limpio.split("\n") if p.strip()]
    print(
        "  %d caracteres, %d palabras, %d lineas con texto"
        % (len(limpio), len(limpio.split()), len(lineas))
    )
    print("  Guardado en %s" % destino)


if __name__ == "__main__":
    main()
