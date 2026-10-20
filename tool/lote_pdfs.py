# -*- coding: utf-8 -*-
"""Convierte el catálogo entero de una pasada y escribe UNA migración.

    python tool/lote_pdfs.py
    python tool/lote_pdfs.py --solo hamlet,edipo-rey     # sólo estos
    python tool/lote_pdfs.py --informe                   # sin escribir nada

Lo que `pdf_a_lira.py` hace para un libro, esto lo hace para cuarenta, y
además decide dos cosas que antes se calibraban a mano:

1. El `--corte`. Se barre de 0.50 a 0.94 y se mide qué porcentaje de párrafos
   NO termina en signo de puntuación. Ese porcentaje es directamente la
   proporción de frases partidas a mitad; el mínimo de la curva es el valor
   bueno. Antes esto era «mide la curva y quédate con el mínimo» escrito en
   CLAUDE.md, y había que hacerlo libro por libro.

2. Si el libro entra o no. Un escaneo con el OCR roto no da error: da texto
   que parece texto. Se mide la proporción de palabras imposibles en
   castellano (caracteres que no existen dentro de una palabra, cuatro
   consonantes seguidas, mayúsculas en medio) y, por debajo de la nota de
   corte, el libro se queda fuera y se dice por qué.

Nada de esto sustituye leer una página del resultado. Sí sustituye leer
cuarenta.
"""

import argparse
import json
import re
import sys
import unicodedata
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tool"))

import pdf_a_lira as conv  # noqa: E402
from catalogo import CATALOGO, DESCARTADOS  # noqa: E402
import dinamicas  # noqa: E402

PDFS = RAIZ / "pdfs"
MIGRACIONES = RAIZ / "supabase" / "migrations"

# Un capítulo de ~1100 palabras son unos 5 minutos: lo que dura la paciencia
# de alguien leyendo de pie en el micro.
MAX_PALABRAS = 1100
PALABRAS_POR_MINUTO = 200

# Nota mínima de legibilidad. Un PDF digital sano ronda 0.995; un escaneo
# decente, 0.97; el «Agua» roto se queda en 0.89.
NOTA_MINIMA = 0.955


# ─── Control de calidad ─────────────────────────────────────────────────────

VOCALES = set("aeiouáéíóúü")
# Grupos de consonantes que sí existen seguidos en castellano.
RE_CONSONANTES = re.compile(
    r"[bcdfghjklmnñpqrstvwxyz]{4,}", re.IGNORECASE
)
RE_BASURA = re.compile(r"[~^@#%&|\\{}<>=_\[\]°¨]")
RE_PALABRA = re.compile(r"[^\W\d_]+", re.UNICODE)


def _es_imposible(palabra: str) -> bool:
    """¿Esta 'palabra' puede existir en castellano?"""
    if len(palabra) < 3:
        return False
    if RE_BASURA.search(palabra):
        return True

    minuscula = palabra.lower()
    sin_tildes = "".join(
        c for c in unicodedata.normalize("NFD", minuscula)
        if unicodedata.category(c) != "Mn"
    )
    # Ninguna palabra castellana pasa de tres consonantes seguidas.
    if RE_CONSONANTES.search(sin_tildes):
        return True
    # Ni existe sin una sola vocal.
    if not any(c in VOCALES for c in minuscula):
        return True
    # Mayúscula en medio de palabra ('TKILCL' no, pero 'aBcd' sí es OCR roto).
    cuerpo = palabra[1:]
    if cuerpo != cuerpo.lower() and cuerpo != cuerpo.upper():
        return True
    return False


def nota_de_legibilidad(parrafos: list) -> tuple:
    """Proporción de palabras que sí podrían existir, y una muestra de las que no."""
    total = 0
    rotas = []
    for parrafo in parrafos:
        for palabra in RE_PALABRA.findall(parrafo):
            total += 1
            if _es_imposible(palabra):
                rotas.append(palabra)
    if not total:
        return 0.0, []
    return 1.0 - len(rotas) / total, rotas[:8]


# ─── Calibración del corte ──────────────────────────────────────────────────

def _frases_partidas(parrafos: list) -> float:
    """Qué proporción de párrafos no termina en signo de puntuación."""
    utiles = [p for p in parrafos if len(p.split()) >= 5]
    if not utiles:
        return 1.0
    sueltos = sum(1 for p in utiles if not conv.RE_FIN_FRASE.search(p.strip()))
    return sueltos / len(utiles)


def calibrar_corte(paginas: list, regex, curva: bool = False) -> tuple:
    """Barre el umbral y se queda con la RODILLA de la curva.

    Cuidado con el mínimo a secas: cuanto más bajo el umbral, menos líneas
    cierran párrafo, y con 0.50 el libro entero se funde en cuatro bloques
    enormes que, por ser enormes, terminan todos en punto. El error sale
    precioso y el resultado es ilegible en un móvil.

    Lo que se busca es el umbral MÁS ALTO —el que más veces corta párrafo—
    que todavía no empiece a partir frases: todos los que quedan a menos de
    un punto del mínimo son igual de buenos, así que gana el mayor.
    """
    medidas = []
    for paso in range(50, 95, 2):
        corte = paso / 100.0
        medidas.append((corte, _frases_partidas(conv.a_parrafos(paginas, regex, corte))))

    if curva:
        for corte, error in medidas:
            print("    corte %.2f -> %.1f%% de párrafos sin cerrar"
                  % (corte, error * 100))

    minimo = min(error for _, error in medidas)
    buenos = [corte for corte, error in medidas if error <= minimo + 0.01]
    return max(buenos), minimo


# ─── Verso ──────────────────────────────────────────────────────────────────
# Un poema no se reflota. La lógica de ancho de línea que arma los párrafos en
# prosa aquí es justo lo contrario de lo que hace falta: en verso TODAS las
# líneas son cortas, así que el conversor las fundiría en un bloque de prosa y
# el poema dejaría de serlo. En verso manda el salto de línea del autor.

# Número de verso al margen ("5", "10"…) en las ediciones anotadas.
RE_NUMERO_VERSO = re.compile(r"^\s*\d{1,4}\s*$")


def a_estrofas(paginas: list) -> list:
    """Agrupa las líneas en estrofas. Una línea en blanco cierra estrofa."""
    estrofas: list = []
    actual: list = []

    def cerrar():
        if actual:
            estrofas.append("\n".join(actual))
            actual.clear()

    for pagina in paginas:
        for cruda in pagina.splitlines():
            linea = cruda.strip()
            if not linea:
                cerrar()
                continue
            if RE_NUMERO_VERSO.match(linea) or conv.RE_NUMERO_PAGINA.match(linea):
                continue
            # Un encabezado (el título del poema, el nombre del personaje que
            # habla) va suelto y corta la estrofa.
            if conv.es_titulo(linea):
                cerrar()
                estrofas.append(linea)
                continue
            actual.append(linea)

    # Ojo: el salto de página NO cierra estrofa. Cerrarlo ahí partía
    # en dos las estrofas que caen a caballo entre dos páginas, y en
    # un poema eso se ve enseguida.
    cerrar()
    return estrofas


# En una comedia en verso TODO nombre de personaje es un encabezado, así que
# cortar por encabezado daría un capítulo por réplica. Se corta por escena.
# "PRIMER ACTO" y "ACTO PRIMERO" conviven según la edición; "FIN DEL PRIMER
# ACTO" lleva las mismas palabras y no abre nada, así que se descarta aparte.
RE_ESCENA = re.compile(
    r"^\s*(?!FIN\b)(?:(?:ACTO|ESCENA|JORNADA|CUADRO|PARTE)\b"
    r"|(?:PRIMER|SEGUND|TERCER|CUART|QUINT)\w*\s+(?:ACTO|JORNADA|PARTE)\b)",
    re.IGNORECASE,
)


def partir_estrofa(estrofa: str, maximo: int) -> list:
    """Trocea una tirada de versos que no cabe en un capítulo.

    Hay ediciones que no dejan línea en blanco entre estrofas: el acto entero
    sale como un solo bloque de seis mil palabras, y entonces no hay dónde
    cortar el capítulo. Se corta por líneas, buscando la que cierre frase para
    no partir una réplica por la mitad.
    """
    lineas = estrofa.split("\n")
    if len(estrofa.split()) <= maximo:
        return [estrofa]

    trozos, actual, palabras = [], [], 0
    for linea in lineas:
        actual.append(linea)
        palabras += len(linea.split())
        if palabras >= maximo and conv.RE_FIN_FRASE.search(linea.strip()):
            trozos.append("\n".join(actual))
            actual, palabras = [], 0
    if actual:
        trozos.append("\n".join(actual))
    return trozos


def agrupar_poemas(estrofas: list, minimo: int = 320, maximo: int = 900,
                   solo=None) -> list:
    """Corta un poemario por poemas, no por número de palabras.

    Partir a bulto es aceptable en una novela —un capítulo largo en dos
    tramos no molesta a nadie— y no lo es en poesía: deja al lector entrando
    a un capítulo por la mitad de un verso. Aquí cada capítulo empieza en un
    título de poema.

    Con una salvedad práctica: las Rimas de Bécquer son ochenta poemas de
    veinte versos, y ochenta capítulos de un minuto convierten la barra de
    progreso en confeti. Por eso los poemas cortos se agrupan hasta llegar a
    `minimo` palabras, y sólo se cierra cuando se pasa de ahí.
    """
    grupos: list = []
    actual: list = []
    titulo = ""
    palabras = 0

    def cerrar():
        if actual:
            grupos.append((titulo or "Parte %d" % (len(grupos) + 1), list(actual)))
            actual.clear()

    troceadas = []
    for estrofa in estrofas:
        troceadas.extend(partir_estrofa(estrofa, maximo))

    for estrofa in troceadas:
        lineas = [ln for ln in estrofa.split("\n") if ln.strip()]
        es_encabezado = len(lineas) == 1 and conv.es_titulo(lineas[0])
        # En teatro sólo abre capítulo lo que de verdad es una escena.
        if es_encabezado and solo is not None and not solo.match(lineas[0]):
            es_encabezado = False

        if es_encabezado and palabras >= minimo:
            cerrar()
            palabras = 0
            titulo = titulo_de_verso(lineas[0])

        if es_encabezado and not actual:
            titulo = titulo_de_verso(lineas[0])

        actual.append(estrofa)
        palabras += len(estrofa.split())

        # Un poema sólo, largísimo, tampoco cabe de una sentada.
        if palabras >= maximo and not es_encabezado:
            cerrar()
            palabras = 0
            titulo = ""

    cerrar()
    return grupos


def titulo_de_verso(linea: str) -> str:
    """Encabezados de poema y nombres de personaje, bien escritos.

    `titulo_bonito` baja a minúsculas los títulos que vienen a gritos, que es
    lo correcto en prosa castellana. Aquí no: un romano tiene que seguir
    siendo un romano y DON JUAN tiene que quedar en Don Juan, no en Don juan.
    """
    limpia = linea.strip().strip(" .-—–")
    if re.fullmatch(r"[IVXLC]{1,7}", limpia, re.IGNORECASE):
        return limpia.upper()

    if limpia.isupper() and len(limpia.split()) <= 4:
        palabras = limpia.split()
        return " ".join(
            palabra.upper()
            if re.fullmatch(r"[IVXLC]{1,7}", palabra, re.IGNORECASE)
            else palabra.lower()
            if indice and palabra.lower() in conv.PALABRAS_MINUSCULA
            else palabra.capitalize()
            for indice, palabra in enumerate(palabras)
        )
    return conv.titulo_bonito(limpia)


def bloques_de_verso(estrofas: list) -> list:
    """Convierte estrofas en bloques del lector, conservando los saltos."""
    bloques = []
    for estrofa in estrofas:
        limpia = conv.RE_CONTROL.sub("", estrofa)
        lineas = [ln.strip() for ln in limpia.split("\n") if ln.strip()]
        if not lineas:
            continue
        if len(lineas) == 1 and conv.es_titulo(lineas[0]):
            bloques.append({"type": "h", "text": titulo_de_verso(lineas[0])})
        else:
            bloques.append({"type": "v", "text": "\n".join(lineas)})
    return bloques


# ─── Detección de capítulos ─────────────────────────────────────────────────

CANDIDATOS = [
    ("capítulo", r"^\s*CAP[IÍ]TULO\b"),
    ("capitulo llano", r"^\s*Cap[ií]tulo\b"),
    ("acto o escena", r"^\s*(ACTO|JORNADA|CUADRO|ESCENA)\b"),
    ("acto", r"^\s*(ACTO|JORNADA)\b"),
    ("acto llano", r"^\s*(Acto|Jornada)\b"),
    ("escena", r"^\s*ESCENA\b"),
    ("romano", r"^\s*[IVXLC]{1,7}\s*$"),
    ("número", r"^\s*\d{1,3}\s*$"),
]


# Nombres de patrón que son de teatro: cambian cómo se titulan los capítulos.
TEATRALES = ("acto", "acto llano", "escena", "acto o escena")

# Encabezado que abre un acto entero, no una escena suelta.
RE_ACTO = re.compile(r"^\s*(ACTO|JORNADA|CUADRO)\b", re.IGNORECASE)


def es_teatral(nombre) -> bool:
    return nombre in TEATRALES


def titulos_de_teatro(capitulos: list) -> list:
    """Arrastra el acto hasta el título de cada escena.

    Sin esto los capítulos se llaman "Escena I", "Escena II"… y vuelven a
    empezar en cada acto: cinco capítulos distintos con el mismo nombre. Con
    el acto delante, "Acto II · Escena I" dice dónde está uno.
    """
    salida = []
    acto = ""
    for titulo, cuerpo in capitulos:
        # El conversor ya encadenó "Acto primero · Escena primera" cuando los
        # dos encabezados venían pegados: de ahí se saca el acto en curso.
        if RE_ACTO.match(titulo):
            acto = titulo.split(" · ", 1)[0]
            salida.append((titulo, cuerpo))
            continue
        salida.append((f"{acto} · {titulo}" if acto else titulo, cuerpo))
    return salida


def detectar_patron(paginas: list) -> tuple:
    """Prueba los patrones típicos y se queda con el que parta mejor el libro.

    Válido es: entre 3 y 150 capítulos y ninguno ridículo. Sin ese filtro, el
    patrón de número suelto casa con los números de página y devuelve
    trescientos capítulos de dos líneas.

    Entre los válidos gana el que deja el capítulo más grande más pequeño, no
    el primero de la lista. Importa: el Hamlet de esta edición escribe los
    actos a gritos («ACTO SEGUNDO») y las escenas en caja baja («Escena III»),
    así que el patrón de acto era válido —y se quedaba con actos enteros de
    ocho mil palabras— mientras el de escena, que parte mucho mejor, no
    llegaba a probarse.
    """
    parrafos = conv.a_parrafos(paginas, None, 0.80)
    palabras = sum(len(p.split()) for p in parrafos)

    mejor = None
    for orden, (nombre, patron) in enumerate(CANDIDATOS):
        regex = re.compile(patron, re.IGNORECASE)
        capitulos = conv.partir_por_patron(
            parrafos, patron, usar_siguiente=not es_teatral(nombre)
        )
        if not 3 <= len(capitulos) <= 150:
            continue
        medias = [sum(len(p.split()) for p in c) for _, c in capitulos]
        # Un capítulo de menos de 60 palabras no es un capítulo: es un número
        # de página que se ha colado.
        if sum(1 for m in medias if m < 60) > len(medias) * 0.2:
            continue
        if palabras and max(medias) > palabras * 0.6:
            continue

        nota = (max(medias), orden)
        if mejor is None or nota < mejor[0]:
            mejor = (nota, nombre, regex)

    return (mejor[1], mejor[2]) if mejor else (None, None)


# ─── Un libro ───────────────────────────────────────────────────────────────

def _rango(texto: str) -> tuple:
    if not texto:
        return 1, 0
    if "-" in texto:
        a, b = texto.split("-", 1)
        return int(a or 1), int(b or 0)
    return int(texto), 0


def procesar(entrada: dict, lexico: set) -> dict:
    """Devuelve el libro convertido, o su motivo de descarte."""
    archivos = entrada["archivos"]
    primera, ultima = _rango(entrada.get("paginas", ""))

    # Cada archivo es una sección: en los libros de varios cuentos, cada
    # cuento es su propia unidad y no se mezcla con el siguiente.
    secciones = []
    for indice, nombre in enumerate(archivos):
        ruta = PDFS / nombre
        if not ruta.exists():
            return {"error": "no encuentro %s" % nombre}

        desde, hasta = (primera, ultima) if indice == 0 else (1, 0)
        paginas = conv.leer_pdf(ruta, desde, hasta)
        paginas = conv.quitar_controles(paginas)
        paginas = conv.quitar_repetidos(paginas)
        paginas = conv.limpiar_ocr(paginas)
        secciones.append(paginas)

    todas = [p for seccion in secciones for p in seccion]

    verso = entrada.get("verso", entrada["categoria"] == "poesia")
    if verso:
        capitulos = []
        solo = RE_ESCENA if entrada["categoria"] == "teatro" else None
        for paginas in secciones:
            capitulos.extend(agrupar_poemas(a_estrofas(paginas), solo=solo))
        return _cerrar(entrada, capitulos, corte=None, patron="poemas",
                       verso=True)

    # Patrón: el del catálogo, o el que se detecte.
    patron = entrada.get("patron")
    if patron:
        regex, nombre_patron = re.compile(patron, re.IGNORECASE), "del catálogo"
    else:
        nombre_patron, regex = detectar_patron(todas)

    corte = entrada.get("corte")
    if corte is None:
        corte, error = calibrar_corte(todas, regex, curva=entrada.get("curva", False))
    else:
        error = None

    nombres = tuple(entrada.get("nombres", ()))

    capitulos = []
    if regex is not None:
        parrafos = conv.a_parrafos(todas, regex, corte)
        parrafos = conv.unir_partidas(parrafos, lexico)
        capitulos = conv.partir_por_patron(
            parrafos,
            regex.pattern,
            nombres,
            usar_siguiente=not es_teatral(nombre_patron),
        )
        if es_teatral(nombre_patron):
            capitulos = titulos_de_teatro(capitulos)
    else:
        # Sin capítulos propios: cada archivo entra como una parte y los
        # tramos largos se trocean después.
        titulos = entrada.get("titulos", [])
        for indice, paginas in enumerate(secciones):
            parrafos = conv.a_parrafos(paginas, None, corte)
            parrafos = conv.unir_partidas(parrafos, lexico)
            if not parrafos:
                continue
            titulo = titulos[indice] if indice < len(titulos) else ""
            capitulos.append((titulo or "Parte %d" % (indice + 1), parrafos))

    return _cerrar(entrada, capitulos, corte, nombre_patron, verso=False)


def _cerrar(entrada: dict, capitulos: list, corte, patron, verso: bool) -> dict:
    """Trocea lo largo, tira lo vacío y decide si el libro pasa el corte."""
    # En verso el tope es más bajo: un capítulo de mil palabras de poesía se
    # lee mucho más despacio que mil palabras de novela.
    if not verso:
        capitulos = conv.partir_largos(capitulos, MAX_PALABRAS)
    capitulos = [(t, c) for t, c in capitulos
                 if sum(len(p.split()) for p in c) >= 40]

    if not capitulos:
        return {"error": "no salió ni un capítulo con texto"}

    todo = [p for _, cuerpo in capitulos for p in cuerpo]
    nota, muestra = nota_de_legibilidad(todo)
    if nota < NOTA_MINIMA:
        return {"error": "texto ilegible (nota %.3f): %s"
                         % (nota, ", ".join(muestra))}

    palabras = sum(len(p.split()) for p in todo)
    return {
        "capitulos": capitulos,
        "verso": verso,
        "nota": nota,
        "corte": corte,
        "patron": patron,
        "palabras": palabras,
        # La poesía se lee a la mitad de velocidad. Prometer 40 minutos y que
        # sean 80 es peor que no decir nada.
        "minutos": max(1, round(palabras / (100 if verso else PALABRAS_POR_MINUTO))),
    }


# ─── SQL ────────────────────────────────────────────────────────────────────

def esc(valor: str) -> str:
    return str(valor).replace("'", "''")


def arreglo_sql(valores) -> str:
    return "array[" + ", ".join("'%s'" % esc(v) for v in valores) + "]::text[]"


def sql_de_libro(entrada: dict, resultado: dict) -> list:
    libro = entrada["id"]
    lineas = [
        "-- ─── %s · %s ───" % (entrada["titulo"], entrada["autor"]),
        "delete from public.chapters where book_id = '%s';" % esc(libro),
        "",
        "insert into public.books "
        "(id, title, author, synopsis, category, chapter_count, "
        "minutes_to_read, tags, is_published)",
        "values ('%s', '%s', '%s', '%s', '%s', %d, %d, %s, true)"
        % (
            esc(libro), esc(entrada["titulo"]), esc(entrada["autor"]),
            esc(entrada["sinopsis"]), entrada["categoria"],
            len(resultado["capitulos"]), resultado["minutos"],
            arreglo_sql(entrada.get("tags", [])),
        ),
        "on conflict (id) do update set",
        "  title = excluded.title, author = excluded.author,",
        "  synopsis = excluded.synopsis, category = excluded.category,",
        "  chapter_count = excluded.chapter_count,",
        "  minutes_to_read = excluded.minutes_to_read,",
        "  tags = excluded.tags, is_published = true;",
        "",
    ]

    for posicion, (titulo, parrafos) in enumerate(resultado["capitulos"]):
        bloques = (bloques_de_verso(parrafos) if resultado["verso"]
                   else conv.a_bloques(parrafos))
        palabras = sum(len(b.get("text", "").split()) for b in bloques)
        cuerpo = json.dumps(bloques, ensure_ascii=False)
        # Red final. El jsonb de Postgres rechaza cualquier escape de control
        # ("unsupported Unicode escape sequence") y tumba la migración entera
        # en el capítulo 146 de 1177, después de diez minutos subiendo. Mejor
        # reventar aquí, en frío, y con el libro y el capítulo delante.
        if any("\\u%04x" % c in cuerpo for c in list(range(9)) + [11, 12] + list(range(14, 32))):
            raise ValueError(
                "%s, capítulo %d: quedan caracteres de control en el texto"
                % (libro, posicion)
            )
        lineas.append(
            "insert into public.chapters "
            "(book_id, position, title, body, word_count)\n"
            "values ('%s', %d, '%s', $lira$%s$lira$::jsonb, %d);"
            % (esc(libro), posicion, esc(titulo), cuerpo, palabras)
        )

    lineas.append("")
    for posicion in range(len(resultado["capitulos"])):
        kind, prompt, hint = dinamicas.para_capitulo(
            libro, entrada["categoria"], posicion
        )
        pista = "'%s'" % esc(hint) if hint else "null"
        lineas.append(
            "insert into public.activities (book_id, chapter_id, kind, prompt, hint)\n"
            "select '%s', c.id, '%s', '%s', %s from public.chapters c\n"
            "where c.book_id = '%s' and c.position = %d;"
            % (esc(libro), kind, esc(prompt), pista, esc(libro), posicion)
        )

    lineas.append("")
    return lineas


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--solo", default="", help="ids separados por coma")
    parser.add_argument("--informe", action="store_true",
                        help="analiza y resume, pero no escribe la migración")
    parser.add_argument("--salida", default="",
                        help="ruta de la migración (por defecto, una con fecha)")
    args = parser.parse_args()

    pedidos = {s.strip() for s in args.solo.split(",") if s.strip()}
    entradas = [e for e in CATALOGO if not pedidos or e["id"] in pedidos]
    if pedidos:
        faltan = pedidos - {e["id"] for e in entradas}
        if faltan:
            sys.exit("No están en el catálogo: %s" % ", ".join(sorted(faltan)))

    lexico = conv.cargar_lexico(RAIZ / "tool" / "lexico_es.txt")

    cuerpo, resumen, fuera = [], [], []
    for entrada in entradas:
        print("\n=== %s (%s)" % (entrada["titulo"], entrada["id"]))
        try:
            resultado = procesar(entrada, lexico)
        except Exception as fallo:            # noqa: BLE001
            resultado = {"error": "%s: %s" % (type(fallo).__name__, fallo)}

        if "error" in resultado:
            print("  FUERA: %s" % resultado["error"])
            fuera.append((entrada, resultado["error"]))
            continue

        corte = resultado["corte"]
        print("  %d capítulos, %d palabras, ~%d min | corte %s | "
              "capítulos por %s | nota %.3f"
              % (len(resultado["capitulos"]), resultado["palabras"],
                 resultado["minutos"],
                 "%.2f" % corte if corte else "n/a",
                 resultado["patron"] or "partes iguales", resultado["nota"]))

        resumen.append((entrada, resultado))
        cuerpo.extend(sql_de_libro(entrada, resultado))

    print("\n" + "=" * 72)
    print("DENTRO: %d libros, %d capítulos, %d palabras"
          % (len(resumen),
             sum(len(r["capitulos"]) for _, r in resumen),
             sum(r["palabras"] for _, r in resumen)))
    for entrada, motivo in fuera:
        print("FUERA:  %-40s %s" % (entrada["id"], motivo[:70]))
    print("Descartados de antemano: %d PDF (ver tool/catalogo.py)"
          % len(DESCARTADOS))

    if args.informe or not resumen:
        return

    destino = Path(args.salida) if args.salida else (
        MIGRACIONES / ("%s_catalogo_cultura_general.sql"
                       % datetime.now().strftime("%Y%m%d%H%M%S"))
    )
    cabecera = [
        "-- Catálogo de cultura general, generado por tool/lote_pdfs.py",
        "--",
        "-- %d obras convertidas desde los PDF del colegio. Cada libro borra"
        % len(resumen),
        "-- sus capítulos antes de insertarlos, así que la migración se puede",
        "-- volver a pasar sin duplicar nada.",
        "--",
        "-- Los PDF que no entraron, y el motivo, están en tool/catalogo.py.",
        "",
        "-- Sin begin/commit explicito: `supabase db push` ya envuelve cada",
        "-- migracion en su propia transaccion, y anidar otra da error.",
        "",
    ]
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(
        "\n".join(cabecera + cuerpo + ["commit;", ""]), encoding="utf-8"
    )
    print("\nMigración -> %s (%.1f MB)"
          % (destino, destino.stat().st_size / 1024 / 1024))


if __name__ == "__main__":
    main()
