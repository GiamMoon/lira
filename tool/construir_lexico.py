# -*- coding: utf-8 -*-
"""Construye un lexico de espanol a partir de los libros ya convertidos.

Sirve para reparar las palabras que el OCR parte en dos ("gus taba"): si al
unir dos trozos sale una palabra que ya aparece en otro libro del catalogo,
casi con seguridad estaban partidas.

    python tool/construir_lexico.py

Cuanto mas catalogo tengas convertido, mejor repara. Vuelve a ejecutarlo
despues de anadir libros nuevos.
"""

import glob
import io
import json
import re

SALIDA = 'tool/lexico_es.txt'

palabras = set()
archivos = 0
for ruta in glob.glob('salida/*/capitulo_*.json'):
    archivos += 1
    with io.open(ruta, encoding='utf-8') as f:
        for bloque in json.load(f):
            texto = bloque.get('text', '').lower()
            for palabra in re.findall(r'[a-záéíóúüñ]+', texto):
                if len(palabra) >= 2:
                    palabras.add(palabra)

with io.open(SALIDA, 'w', encoding='utf-8', newline='\n') as f:
    for palabra in sorted(palabras):
        f.write(palabra + '\n')

print('%d archivos leidos' % archivos)
print('%d palabras distintas -> %s' % (len(palabras), SALIDA))
