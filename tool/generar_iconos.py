# -*- coding: utf-8 -*-
"""Genera el icono de Lira para Android en todas las densidades.

    python tool/generar_iconos.py

Cambia el logo en assets/images/lira_logo_icon.jpeg y vuelve a ejecutarlo.
Requiere: pip install pillow

Dos juegos, porque Android necesita los dos:

  - `ic_launcher`: el icono clásico, cuadrado, con el fondo crema de la marca.
  - `ic_launcher_foreground` + color de fondo: el icono adaptativo de Android 8
    en adelante, que el sistema recorta en círculo, cuadrado redondeado o gota
    según el lanzador. Por eso el dibujo va más pequeño: todo lo que se salga
    del 66% central se puede perder en el recorte.

El logo original es apaisado, así que primero se recorta a lo que de verdad
hay dibujado (descartando el crema de alrededor) y luego se centra.
"""

import io
import os

from PIL import Image

RAIZ = '.'  # se ejecuta desde la raiz del proyecto
ORIGEN = RAIZ + '/assets/images/lira_logo_icon.jpeg'
RES = RAIZ + '/android/app/src/main/res'

CREMA = (248, 238, 219)

# densidad -> (lado del icono clasico, lado del adaptativo)
DENSIDADES = {
    'mdpi': (48, 108),
    'hdpi': (72, 162),
    'xhdpi': (96, 216),
    'xxhdpi': (144, 324),
    'xxxhdpi': (192, 432),
}


def recortar_al_dibujo(imagen, tolerancia=14):
    """Quita el crema de alrededor y deja sólo lo dibujado."""
    rgb = imagen.convert('RGB')
    ancho, alto = rgb.size
    pixeles = rgb.load()

    izq, der, arr, aba = ancho, 0, alto, 0
    for y in range(0, alto, 2):
        for x in range(0, ancho, 2):
            r, g, b = pixeles[x, y]
            if (
                abs(r - CREMA[0]) > tolerancia
                or abs(g - CREMA[1]) > tolerancia
                or abs(b - CREMA[2]) > tolerancia
            ):
                if x < izq:
                    izq = x
                if x > der:
                    der = x
                if y < arr:
                    arr = y
                if y > aba:
                    aba = y

    if der <= izq or aba <= arr:
        return rgb

    margen = int(max(der - izq, aba - arr) * 0.04)
    return rgb.crop((
        max(0, izq - margen),
        max(0, arr - margen),
        min(ancho, der + margen),
        min(alto, aba + margen),
    ))


def encajar(dibujo, lado, ocupacion, fondo):
    """Centra el dibujo en un lienzo cuadrado ocupando `ocupacion` del lado."""
    objetivo = int(lado * ocupacion)
    copia = dibujo.copy()
    copia.thumbnail((objetivo, objetivo), Image.LANCZOS)

    lienzo = Image.new('RGBA', (lado, lado), fondo)
    lienzo.paste(
        copia.convert('RGBA'),
        ((lado - copia.width) // 2, (lado - copia.height) // 2),
        copia.convert('RGBA'),
    )
    return lienzo


original = Image.open(ORIGEN)
dibujo = recortar_al_dibujo(original)
print('Original %dx%d -> recortado a %dx%d'
      % (original.width, original.height, dibujo.width, dibujo.height))

for densidad, (lado_clasico, lado_adaptativo) in DENSIDADES.items():
    carpeta = '%s/mipmap-%s' % (RES, densidad)
    if not os.path.isdir(carpeta):
        os.makedirs(carpeta)

    # Clásico: el crema de la marca como fondo, dibujo generoso.
    encajar(dibujo, lado_clasico, 0.86, CREMA + (255,)).save(
        carpeta + '/ic_launcher.png'
    )

    # Adaptativo: fondo transparente (lo pone el sistema) y dibujo dentro de
    # la zona segura.
    encajar(dibujo, lado_adaptativo, 0.58, (0, 0, 0, 0)).save(
        carpeta + '/ic_launcher_foreground.png'
    )

    print('  mipmap-%-8s %3dpx clasico + %3dpx adaptativo'
          % (densidad, lado_clasico, lado_adaptativo))

# --- El XML del icono adaptativo -------------------------------------------
anydpi = RES + '/mipmap-anydpi-v26'
if not os.path.isdir(anydpi):
    os.makedirs(anydpi)

io.open(anydpi + '/ic_launcher.xml', 'w', encoding='utf-8', newline='\n').write(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@color/ic_launcher_background" />\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
    '</adaptive-icon>\n'
)

valores = RES + '/values'
if not os.path.isdir(valores):
    os.makedirs(valores)

io.open(valores + '/ic_launcher_background.xml', 'w', encoding='utf-8',
        newline='\n').write(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<resources>\n'
    '    <!-- El crema de Lira. -->\n'
    '    <color name="ic_launcher_background">#F8EEDB</color>\n'
    '</resources>\n'
)

print('\nIcono adaptativo y color de fondo escritos.')
