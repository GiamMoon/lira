"""Comprueba el acceso público al catálogo sin imprimir claves ni contenido.

Uso: python tool/verificar_supabase.py [env.json]
"""
import base64
import json
from pathlib import Path
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def verificar(ruta):
    config = json.loads(Path(ruta).read_text(encoding='utf-8-sig'))
    url = config.get('SUPABASE_URL', '').rstrip('/')
    clave = config.get('SUPABASE_KEY') or config.get('SUPABASE_ANON_KEY', '')
    if not url.startswith('https://') or not clave:
        raise ValueError('Configura SUPABASE_URL y la clave publicable en env.json.')
    if clave.startswith('sb_secret_'):
        raise ValueError('La web requiere una clave publicable, no una clave secreta.')
    if clave.count('.') == 2:
        payload = clave.split('.')[1]
        datos = json.loads(base64.urlsafe_b64decode(payload + '=' * (-len(payload) % 4)))
        if datos.get('role') != 'anon':
            raise ValueError('La clave JWT debe tener el rol anon para publicarse en web.')
    peticion = Request(url + '/rest/v1/books?select=id&is_published=eq.true&limit=1',
                       headers={'apikey': clave, 'Prefer': 'count=exact'})
    with urlopen(peticion, timeout=20) as respuesta:
        obras = json.load(respuesta)
        total = respuesta.headers.get('Content-Range', '*/?').split('/')[-1]
    if not obras:
        raise ValueError('El catálogo no tiene obras publicadas accesibles. Revisa contenido y RLS.')
    print(f'Supabase verificado: catálogo accesible, {total} obras publicadas.')


if __name__ == '__main__':
    try:
        verificar(sys.argv[1] if len(sys.argv) > 1 else 'env.json')
    except (ValueError, OSError, HTTPError, URLError) as error:
        print(f'No se puede publicar todavía: {error}', file=sys.stderr)
        sys.exit(1)
