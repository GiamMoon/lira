"""Genera los iconos del navegador desde el logo de Lira, sin tocar Android.

Ejecutar: python tool/generar_iconos_web.py
Requiere Pillow: python -m pip install pillow
"""

from pathlib import Path

from PIL import Image, ImageChops


RAIZ = Path(__file__).resolve().parent.parent
CREMA = (248, 238, 219)


def generar():
    original = Image.open(RAIZ / 'assets/images/lira_logo_icon.jpeg').convert('RGB')
    fondo = Image.new('RGB', original.size, CREMA)
    diferencia = ImageChops.difference(original, fondo)
    canales = diferencia.split()
    mascara = ImageChops.lighter(ImageChops.lighter(canales[0], canales[1]), canales[2])
    limites = mascara.point(lambda valor: 255 if valor > 14 else 0).getbbox()
    dibujo = original.crop(limites) if limites else original
    destino = RAIZ / 'web/icons'
    destino.mkdir(parents=True, exist_ok=True)

    def icono(lado, ocupacion):
        copia = dibujo.copy()
        copia.thumbnail((round(lado * ocupacion), round(lado * ocupacion)), Image.Resampling.LANCZOS)
        lienzo = Image.new('RGB', (lado, lado), CREMA)
        lienzo.paste(copia, ((lado - copia.width) // 2, (lado - copia.height) // 2))
        return lienzo

    for lado in (192, 512):
        icono(lado, 0.86).save(destino / f'Icon-{lado}.png')
        # El dibujo cabe dentro del círculo seguro del icono enmascarable.
        icono(lado, 0.58).save(destino / f'Icon-maskable-{lado}.png')
    icono(32, 0.9).save(RAIZ / 'web/favicon.png')
    print('Iconos web de Lira generados.')


if __name__ == '__main__':
    generar()
