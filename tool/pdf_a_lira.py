#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Convierte un PDF (o un .txt) en los bloques que Lira guarda en chapters.body.

El PDF es solo la FUENTE. Lira nunca renderiza un PDF: guarda el texto en
bloques para poder reflotarlo en pantallas pequenas, medir el progreso por
capitulos e insertar las dinamicas entre bloques.

Uso tipico:

    # Un cuento sin capitulos, partido en 3 partes de lectura
    python tool/pdf_a_lira.py "El almohadon.pdf" --libro el-almohadon-de-plumas --partir-en 3

    # Una novela con capitulos marcados en el texto
    python tool/pdf_a_lira.py novela.pdf --libro aves-sin-nido --patron "CAP[IÍ]TULO"

    # Saltando portada, indice y prologo
    python tool/pdf_a_lira.py novela.pdf --libro aves-sin-nido --paginas 7-240

Genera en salida/<libro>/:
    capitulo_00.json ...  los bloques de cada capitulo
    insert.sql            listo para pegar en el SQL Editor de Supabase

Requiere: pip install pdfplumber   (solo para PDF; los .txt no lo necesitan)
"""

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

# Palabras por minuto de un lector de secundaria. Alimenta minutes_to_read.
PALABRAS_POR_MINUTO = 200

# Una linea que es solo un numero de pagina: "12", "- 12 -", "[12]", "pag. 12"
RE_NUMERO_PAGINA = re.compile(
    r"^\s*(?:[-\[\(]\s*)?(?:p[aá]g\.?\s*)?\d{1,4}\s*(?:[-\]\)]\s*)?$",
    re.IGNORECASE,
)

# Final de frase: si la linea acaba asi, la siguiente puede ser parrafo nuevo.
RE_FIN_FRASE = re.compile(r"[.!?:;»”\"']\s*$")

# Inicio de dialogo en literatura en espanol (raya, no guion corto).
RE_DIALOGO = re.compile(r"^\s*[—–]")


def leer_pdf(ruta: Path, primera: int, ultima: int) -> list[str]:
    """Devuelve el texto de cada pagina del PDF.

    Se prefiere **pdfplumber**: agrupa los caracteres por su posicion real y no
    parte palabras a mitad. pypdf, sobre el mismo PDF justificado, devolvia
    "bagat elas" o "jo venes". pypdf queda como reserva.
    """
    try:
        import pdfplumber
    except ImportError:
        pdfplumber = None

    if pdfplumber is not None:
        with pdfplumber.open(str(ruta)) as libro:
            total = len(libro.pages)
            desde = max(1, primera) - 1
            hasta = min(total, ultima if ultima > 0 else total)
            print(
                f"  PDF con {total} paginas; leyendo de la {desde + 1} "
                f"a la {hasta} (pdfplumber)"
            )
            return [
                libro.pages[i].extract_text() or "" for i in range(desde, hasta)
            ]

    try:
        from pypdf import PdfReader
    except ImportError:
        sys.exit(
            "Falta una libreria para leer PDF. Instalala con: pip install pdfplumber"
        )

    lector = PdfReader(str(ruta))
    total = len(lector.pages)
    desde = max(1, primera) - 1
    hasta = min(total, ultima if ultima > 0 else total)

    print(f"  PDF con {total} paginas; leyendo de la {desde + 1} a la {hasta}")
    return [lector.pages[i].extract_text() or "" for i in range(desde, hasta)]


# --- Limpieza de OCR -------------------------------------------------------
# Un escaneo pasado por OCR trae la raya de dialogo como guion simple o doble,
# y deja manchas del papel convertidas en lineas de uno o dos caracteres.

# Guion al principio de linea seguido de texto: es una raya de dialogo.
RE_OCR_DIALOGO = re.compile(
    r"^[ \t]*-{1,3}[ \t]*(?=[A-Za-zÁÉÍÓÚÑáéíóúñ¿¡])"
)

# Dos o tres guiones seguidos, en cualquier sitio: tambien es una raya.
RE_OCR_RAYA = re.compile(r"-{2,3}")

# Vinetas y puntos sueltos que el OCR pega al principio de la linea.
RE_OCR_VINETA = re.compile(r"^[ \t]*[•·∙‧][ \t]*")

# Guion suelto tras un espacio y pegado a una palabra: en un dialogo es la
# raya que cierra o abre el inciso ("-dijo ella"). Las palabras compuestas de
# verdad no llevan espacio delante, asi que no se tocan.
RE_OCR_RAYA_MEDIA = re.compile(r"(?<=\s)-(?=[A-Za-zÁÉÍÓÚÑáéíóúñ])")

# Guion pegado a una palabra y seguido de puntuacion: "tostada-." cierra un
# inciso de dialogo.
RE_OCR_RAYA_CIERRE = re.compile(r"(?<=[A-Za-zÁÉÍÓÚÑáéíóúñ])-(?=[.,;:!?])")


# Caracteres de control C0, menos el salto de linea y el tabulador.
#
# Un PDF los suelta cuando la fuente no trae tabla Unicode: los glifos existen
# en la pagina, se leen perfectamente en pantalla, y al extraerlos salen como
# \x00. Pasa con las versalitas de los titulos ("CAPITULO 2." -> "C\x00\x00…
# 2.") y con las llamadas de nota al pie.
#
# Hay que quitarlos SIEMPRE, no solo por limpieza: el jsonb de Postgres
# rechaza \u0000 con "unsupported Unicode escape sequence", asi que un solo
# caracter de estos tumba la migracion entera.
RE_CONTROL = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]+")

# A partir de aqui, la linea ha perdido tanto que ya no es texto: es un
# encabezado en una fuente que no se puede leer. Reconstruirlo seria
# inventarlo, asi que se tira.
PROPORCION_ILEGIBLE = 0.4


def quitar_controles(paginas: list[str]) -> list[str]:
    """Quita los caracteres que el PDF no supo mapear a Unicode.

    Una racha de dos o mas se sustituye por puntos suspensivos: ahi habia
    texto y no se pudo leer, y decirlo es mas honrado que cerrar el hueco
    como si nada ("de septiembre de 1651" -> "de septiembre de …"). Una racha
    de uno solo se borra: casi siempre es la llamada de una nota al pie.
    """
    limpias = []
    tiradas = 0
    huecos = 0

    for pagina in paginas:
        lineas = []
        for cruda in pagina.splitlines():
            rachas = RE_CONTROL.findall(cruda)
            if not rachas:
                lineas.append(cruda)
                continue

            perdidos = sum(len(r) for r in rachas)
            if cruda.strip() and perdidos / len(cruda) >= PROPORCION_ILEGIBLE:
                tiradas += 1
                continue

            huecos += sum(1 for r in rachas if len(r) >= 2)
            lineas.append(
                RE_CONTROL.sub(lambda m: "…" if len(m.group()) >= 2 else "", cruda)
            )
        limpias.append("\n".join(lineas))

    if tiradas or huecos:
        print(
            "  Caracteres sin Unicode: %d linea(s) ilegibles descartadas, "
            "%d hueco(s) marcados con …" % (tiradas, huecos)
        )
    return limpias


def limpiar_ocr(paginas: list[str]) -> list[str]:
    """Arregla los destrozos tipicos de un PDF escaneado y pasado por OCR.

    Sin esto los dialogos no se detectan —y en una novela juvenil el dialogo
    es la mitad del libro—, asi que el texto sale como un muro de prosa.
    """
    limpias = []
    manchas = 0

    for pagina in paginas:
        lineas = []
        for cruda in pagina.splitlines():
            linea = RE_OCR_VINETA.sub("", cruda)

            # Manchas del escaneo: una o dos marcas sueltas que no son texto.
            desnudo = linea.strip()
            if desnudo and len(desnudo) <= 3:
                alfanumericos = sum(1 for c in desnudo if c.isalnum())
                if alfanumericos <= 1 and not desnudo.isdigit():
                    manchas += 1
                    continue

            linea = RE_OCR_DIALOGO.sub("—", linea)
            linea = RE_OCR_RAYA.sub("—", linea)
            linea = RE_OCR_RAYA_MEDIA.sub("—", linea)
            linea = RE_OCR_RAYA_CIERRE.sub("—", linea)
            lineas.append(linea)
        limpias.append("\n".join(lineas))

    if manchas:
        print("  Limpieza de OCR: %d manchas sueltas descartadas" % manchas)
    return limpias


# Dos trozos de palabra separados por un espacio: "gus taba".
#
# El segundo trozo va en un *lookahead* a proposito: asi la coincidencia solo
# consume el primero y el barrido avanza palabra a palabra. Consumiendo los
# dos, "Nombre com pleto" probaba "Nombre+com", fallaba, y saltaba por encima
# de "com pleto" sin llegar a mirarlo.
RE_PARTIDA = re.compile(
    r"([A-Za-zÁÉÍÓÚÜÑáéíóúüñ]{2,})[ \t]+"
    r"(?=([A-Za-zÁÉÍÓÚÜÑáéíóúüñ]{2,6})(?![A-Za-zÁÉÍÓÚÜÑáéíóúüñ]))"
)


def cargar_lexico(ruta: Path) -> set:
    """Lee un lexico de una palabra por linea."""
    if not ruta.exists():
        sys.exit(
            "No encuentro el lexico: %s\n"
            "Generalo con: python tool/construir_lexico.py" % ruta
        )
    return {
        linea.strip().lower()
        for linea in ruta.read_text(encoding="utf-8").splitlines()
        if linea.strip()
    }


def unir_partidas(parrafos: list[str], lexico: set) -> list[str]:
    """Rejunta las palabras que el OCR partio en dos.

    Un escaneo mete espacios dentro de las palabras. Se arreglan solo cuando
    al unir los dos trozos sale una palabra del lexico **y** alguno de los
    trozos no lo es: asi "de mas" se queda como esta (ambos son palabras) y
    "gus taba" se junta.
    """
    if not lexico:
        return parrafos

    arreglos = [0]

    def reemplazo(coincidencia):
        izquierda = coincidencia.group(1)
        derecha = coincidencia.group(2)
        unido = (izquierda + derecha).lower()
        if unido in lexico and (
            izquierda.lower() not in lexico or derecha.lower() not in lexico
        ):
            arreglos[0] += 1
            # Se devuelve solo el trozo izquierdo: al comerse el espacio, queda
            # pegado al derecho, que sigue en el texto.
            return izquierda
        return coincidencia.group(0)

    salida = list(parrafos)
    # Dos pasadas: hay palabras rotas en tres trozos ("no mos trarlo").
    for _ in range(2):
        salida = [RE_PARTIDA.sub(reemplazo, parrafo) for parrafo in salida]

    if arreglos[0]:
        print("  Palabras partidas por el OCR y rejuntadas: %d" % arreglos[0])
    return salida


def quitar_repetidos(paginas: list[str]) -> list[str]:
    """Elimina encabezados y pies que se repiten pagina tras pagina.

    Un PDF de libro suele llevar el titulo arriba y el autor abajo en cada
    pagina. Si eso se cuela en el texto, aparece en mitad de la lectura.
    """
    if len(paginas) < 4:
        return paginas

    primeras = Counter()
    ultimas = Counter()
    for pagina in paginas:
        lineas = [ln.strip() for ln in pagina.splitlines() if ln.strip()]
        if not lineas:
            continue
        primeras[lineas[0]] += 1
        ultimas[lineas[-1]] += 1

    umbral = max(3, len(paginas) // 3)
    sospechosas = {
        texto
        for contador in (primeras, ultimas)
        for texto, veces in contador.items()
        if veces >= umbral and len(texto) < 90
    }

    if sospechosas:
        print(f"  Quitando {len(sospechosas)} encabezado(s)/pie(s) repetidos:")
        for texto in sorted(sospechosas):
            print(f"    - {texto[:70]}")

    limpias = []
    for pagina in paginas:
        lineas = [
            ln for ln in pagina.splitlines() if ln.strip() not in sospechosas
        ]
        limpias.append("\n".join(lineas))
    return limpias


PALABRAS_MINUSCULA = {
    'de', 'del', 'la', 'las', 'el', 'los', 'y', 'e', 'o', 'u', 'en', 'un',
    'una', 'unos', 'unas', 'a', 'al', 'por', 'con', 'que', 'se', 'su', 'sus',
    'para', 'sin', 'sobre', 'como', 'mas',
}


def es_titulo(linea: str) -> bool:
    """Una linea corta y sin minusculas: casi siempre un encabezado.

    Importa para no pegar "I  DIABLURAS DE TOM" al primer parrafo del
    capitulo, que es lo que rompe la deteccion de capitulos.
    """
    s = linea.strip()
    if not s or len(s) > 70:
        return False
    letras = [c for c in s if c.isalpha()]
    return bool(letras) and not any(c.islower() for c in letras)


# Numero romano al principio de un titulo: "I  DIABLURAS DE TOM".
RE_ROMANO_INICIAL = re.compile(r"^[IVXL]{1,6}[\s\.\-]+")


def titulo_bonito(texto: str, nombres: tuple = ()) -> str:
    """Pasa UN TITULO A GRITOS a uno legible en espanol.

    Quita el numero romano (la app ya muestra "CAPITULO 3 DE 35", repetirlo
    sobra), pasa a minusculas con mayuscula inicial --que es el estilo espanol,
    no el ingles de Capitalizar Todas Las Palabras-- y devuelve su mayuscula a
    los nombres propios que se indiquen con --nombres.
    """
    # Un romano suelto ("III") no es un titulo a gritos: es un numero, y
    # bajarlo a minusculas lo convierte en "Iii".
    desnudo = texto.strip().strip(" .-—–")
    if desnudo and re.fullmatch(r"[IVXLC]{1,7}", desnudo, re.IGNORECASE):
        return desnudo.upper()

    limpio = RE_ROMANO_INICIAL.sub("", texto.strip())
    if any(c.islower() for c in limpio):
        # Ya viene en caja mixta: se respeta tal cual, salvo el romano, que
        # esta edicion escribe "Escena iii." y no es un numero en minuscula.
        return _romanos_en_mayuscula(" ".join(limpio.split()))

    limpio = " ".join(limpio.lower().split())
    if not limpio:
        return texto.strip()

    # La mayuscula va en la primera LETRA, no en el primer caracter: hay
    # titulos que abren con comilla angular.
    for i, caracter in enumerate(limpio):
        if caracter.isalpha():
            limpio = limpio[:i] + caracter.upper() + limpio[i + 1:]
            break

    for nombre in nombres:
        propio = nombre.strip()
        if propio:
            limpio = re.sub(
                r"\b" + re.escape(propio.lower()) + r"\b", propio, limpio
            )
    return _romanos_en_mayuscula(limpio)


# Palabras que abren un encabezado numerado. Sólo detras de una de ellas se
# devuelve la mayuscula a un romano: asi "Escena ii" vuelve a ser "Escena II"
# sin que un titulo como "Lo que vi" acabe en "Lo que VI".
ENCABEZADOS_NUMERADOS = (
    "escena", "acto", "jornada", "capitulo", "capítulo", "parte", "cuadro",
    "libro", "canto", "rima",
)


def _romanos_en_mayuscula(titulo: str) -> str:
    palabras = titulo.split()
    if not palabras or palabras[0].lower().strip(".:") not in ENCABEZADOS_NUMERADOS:
        return titulo

    return " ".join(
        palabra.upper()
        if indice and re.fullmatch(r"[ivxlcIVXLC]{1,7}[.,:]?", palabra)
        else palabra
        for indice, palabra in enumerate(palabras)
    )


def a_parrafos(
    paginas: list[str], regex_capitulo=None, corte: float = 0.85
) -> list[str]:
    """Une las lineas sueltas del PDF en parrafos de verdad.

    La clave es el ANCHO DE LINEA: en un PDF justificado, todas las lineas de
    un parrafo llegan al margen derecho menos la ultima. Asi que una linea
    corta cierra parrafo y la siguiente abre uno nuevo.

    Sin esto salen bloques de 400 palabras que en un movil no hay quien lea, y
    no sirve fiarse de la sangria: muchos libros maquetados no la tienen.
    """
    # 1) Lineas utiles, para poder medir el ancho de la columna.
    utiles: list[list[str]] = []
    for pagina in paginas:
        lineas = []
        for cruda in pagina.splitlines():
            if not cruda.strip():
                lineas.append("")
                continue
            if RE_NUMERO_PAGINA.match(cruda.rstrip()):
                continue
            lineas.append(cruda.rstrip())
        utiles.append(lineas)

    largos = sorted(
        len(ln.strip())
        for pagina in utiles
        for ln in pagina
        if ln.strip() and not es_titulo(ln)
    )
    if largos:
        indice = min(int(len(largos) * 0.9), len(largos) - 1)
        ancho = largos[indice]
    else:
        ancho = 0
    # Cuanto mas corta que la columna tiene que ser una linea para que cierre
    # parrafo. Depende de la maquetacion: hay libros con el margen derecho muy
    # parejo (0.88 va bien) y otros mas irregulares, donde hay que bajarlo o se
    # parten las frases a mitad. Se mide con --corte.
    umbral = ancho * corte

    # 2) Montamos los parrafos.
    parrafos: list[str] = []
    actual: list[str] = []
    ultimo_titulo = False
    corta_anterior = True  # la primera linea siempre abre parrafo

    def cerrar():
        if actual:
            parrafos.append(" ".join(actual).strip())
            actual.clear()

    for pagina in utiles:
        for cruda in pagina:
            if not cruda.strip():
                cerrar()
                corta_anterior = True
                continue

            linea = cruda.strip()

            # Un encabezado de capitulo corta parrafo si o si: en un libro
            # siempre empieza pagina, y si la anterior acababa con una linea
            # completa se le quedaria pegado (y el capitulo desaparece).
            if regex_capitulo is not None and regex_capitulo.match(linea):
                cerrar()
                parrafos.append(linea)
                ultimo_titulo = False
                corta_anterior = True
                continue

            # Un encabezado corta parrafo antes y despues de si mismo. Si viene
            # partido en dos lineas --el romano arriba y el titulo debajo, que
            # es lo normal-- se vuelve a juntar.
            if es_titulo(linea):
                cerrar()
                if ultimo_titulo and parrafos:
                    parrafos[-1] = parrafos[-1] + "  " + linea
                else:
                    parrafos.append(linea)
                ultimo_titulo = True
                corta_anterior = True
                continue

            ultimo_titulo = False
            anterior = actual[-1] if actual else ""

            # Una raya solo abre dialogo si venimos de fin de frase. Si no,
            # es el cierre de un inciso que partio linea: "la vida de John
            # --y la de sus hermanas-- habia transcurrido...".
            abre_dialogo = bool(RE_DIALOGO.match(linea)) and (
                not actual or bool(RE_FIN_FRASE.search(anterior))
            )

            if not actual or corta_anterior or abre_dialogo:
                cerrar()
                actual.append(linea)
            elif anterior.endswith("-"):
                # Palabra cortada al final de linea: "pala-" + "bra".
                actual[-1] = anterior[:-1] + linea
            else:
                actual.append(linea)

            corta_anterior = len(linea) < umbral

    cerrar()

    # Las mayusculas capitulares dejan la primera palabra suelta: el PDF
    # devuelve "John" y luego "Wesley tenia cinco anos...". Se vuelven a pegar.
    unidos: list[str] = []
    for parrafo in parrafos:
        anterior = unidos[-1] if unidos else ""
        if (
            unidos
            and len(anterior.split()) <= 2
            and len(parrafo) > 60
            and not RE_FIN_FRASE.search(anterior)
            and not RE_DIALOGO.match(anterior)
            and not es_titulo(anterior)
        ):
            unidos[-1] = anterior + " " + parrafo
        else:
            unidos.append(parrafo)

    return [p for p in unidos if p]


def partir_por_patron(
    parrafos: list[str],
    patron: str,
    nombres: tuple = (),
    usar_siguiente: bool = True,
) -> list[tuple[str, list[str]]]:
    """Corta en capitulos alli donde un parrafo coincide con el patron.

    `usar_siguiente` toma como titulo la linea de debajo cuando la del patron
    no dice nada ("Capitulo 7"). En teatro hay que apagarlo: debajo de
    "Escena III" viene el reparto, y el capitulo acababa llamandose
    "Claudio, gertrudis, hamlet, polonio, laertes,".
    """
    regex = re.compile(patron, re.IGNORECASE)
    capitulos: list[tuple[str, list[str]]] = []
    titulo = "Inicio"
    cuerpo: list[str] = []

    indice = 0
    while indice < len(parrafos):
        parrafo = parrafos[indice].strip()

        # Un encabezado es una linea a gritos, o una linea corta que no
        # termina en punto. Sin este filtro, una frase normal que empiece por
        # "Vi" pasaria por capitulo.
        corto = len(parrafo) <= 40 and not RE_FIN_FRASE.search(parrafo)

        if (es_titulo(parrafo) or corto) and regex.match(parrafo):
            nuevo = titulo_bonito(parrafo, nombres)
            if cuerpo:
                capitulos.append((titulo, cuerpo))
                cuerpo = []
                titulo = nuevo
            elif not usar_siguiente and titulo != "Inicio":
                # Dos encabezados seguidos sin nada entre medias: es "ACTO
                # PRIMERO" y debajo "Escena primera". Si el segundo pisara al
                # primero, el acto desapareceria del libro entero.
                titulo = "%s · %s" % (titulo, nuevo)
            else:
                titulo = nuevo

            # "Capitulo 7" no dice nada y la app ya muestra el numero. Si justo
            # debajo viene el titulo de verdad, ese es el que se guarda.
            if usar_siguiente and indice + 1 < len(parrafos):
                siguiente = parrafos[indice + 1].strip()
                if (
                    4 <= len(siguiente) <= 60
                    and not RE_FIN_FRASE.search(siguiente)
                    and not regex.match(siguiente)
                ):
                    titulo = titulo_bonito(siguiente, nombres)
                    indice += 1
        else:
            cuerpo.append(parrafos[indice])

        indice += 1

    if cuerpo:
        capitulos.append((titulo, cuerpo))

    # Si el primer bloque quedo vacio de titulo real, se descarta.
    if capitulos and capitulos[0][0] == "Inicio" and not capitulos[0][1]:
        capitulos.pop(0)
    return capitulos


def partir_en_partes(parrafos: list[str], partes: int) -> list[tuple[str, list[str]]]:
    """Trocea un texto sin capitulos en partes de tamano parecido.

    Es el caso mas comun: los cuentos no traen capitulos, pero Lira necesita
    varias unidades para que el progreso signifique algo y para tener donde
    colgar las dinamicas.
    """
    partes = max(1, min(partes, len(parrafos)))

    # Se reparte por PALABRAS, no por numero de parrafos: en una novela los
    # parrafos van de una linea de dialogo a media pagina, y repartirlos a
    # partes iguales deja tramos de 1 minuto junto a otros de 5.
    resultado = []
    actual: list[str] = []
    acumulado = 0
    restante = sum(len(p.split()) for p in parrafos)

    for parrafo in parrafos:
        peso = len(parrafo.split())
        faltan = partes - len(resultado)

        # El objetivo se recalcula sobre lo que queda. Con un objetivo fijo,
        # cada tramo que cierra por debajo (porque el parrafo siguiente es
        # grande) va acumulando deuda, y el ultimo se queda con todo el resto.
        objetivo = restante / float(max(faltan, 1))

        if actual and faltan > 1 and acumulado + peso > objetivo:
            resultado.append((f"Parte {len(resultado) + 1}", actual))
            restante -= acumulado
            actual = []
            acumulado = 0

        actual.append(parrafo)
        acumulado += peso

    if actual:
        resultado.append((f"Parte {len(resultado) + 1}", actual))
    return resultado


def partir_largos(
    capitulos: list, maximo: int
) -> list:
    """Trocea en segmentos los capitulos que pasen de `maximo` palabras.

    Un capitulo de 2000 palabras son 10 minutos seguidos: demasiado para leer
    de una sentada en el movil, y deja poquisimos sitios donde colgar una
    dinamica. Partirlo en tramos de 4-5 minutos hace que el progreso avance
    visiblemente y que haya mas puntos de respiro.

    El corte cae siempre entre parrafos, nunca dentro de uno.
    """
    if maximo <= 0:
        return capitulos

    salida = []
    for titulo, cuerpo in capitulos:
        palabras = sum(len(p.split()) for p in cuerpo)
        if palabras <= maximo or len(cuerpo) < 2:
            salida.append((titulo, cuerpo))
            continue

        # Division hacia arriba: si redondeamos, un capitulo de 2230
        # palabras saldria en dos trozos de 1115, pasandose del tope.
        partes = max(2, (palabras + maximo - 1) // maximo)
        objetivo = palabras / float(partes)

        trozos: list = []
        actual: list = []
        acumulado = 0
        for parrafo in cuerpo:
            actual.append(parrafo)
            acumulado += len(parrafo.split())
            if acumulado >= objetivo and len(trozos) < partes - 1:
                trozos.append(actual)
                actual = []
                acumulado = 0
        if actual:
            trozos.append(actual)

        for numero, trozo in enumerate(trozos, start=1):
            salida.append(("%s (%d/%d)" % (titulo, numero, len(trozos)), trozo))

    return salida


def a_bloques(parrafos: list[str]) -> list[dict]:
    """Convierte parrafos en los bloques que entiende el lector de Lira.

    No emite bloques 'note': ese tipo es un aviso de Lira, nunca texto del
    autor, y meterlo aqui confundiria una cosa con la otra.
    """
    bloques = []
    for parrafo in parrafos:
        texto = RE_CONTROL.sub("", parrafo)
        texto = re.sub(r"\s+", " ", texto).strip()
        if not texto:
            continue
        if texto in {"***", "* * *", "---", "···"}:
            bloques.append({"type": "hr"})
        elif len(texto) < 60 and texto.isupper():
            bloques.append({"type": "h", "text": texto.title()})
        else:
            bloques.append({"type": "p", "text": texto})
    return bloques


def sql_escapado(valor: str) -> str:
    return valor.replace("'", "''")


def escribir_salida(libro: str, capitulos: list[tuple[str, list[str]]], destino: Path):
    destino.mkdir(parents=True, exist_ok=True)
    lineas_sql = [
        f"-- Capitulos de '{libro}' generados por tool/pdf_a_lira.py",
        "-- Revisa el texto antes de ejecutarlo: ninguna extraccion de PDF es perfecta.",
        "",
        "-- Si estas RE-cargando este libro, descomenta la linea siguiente.",
        f"-- delete from public.chapters where book_id = '{sql_escapado(libro)}';",
        "",
    ]

    total_palabras = 0
    for posicion, (titulo, parrafos) in enumerate(capitulos):
        bloques = a_bloques(parrafos)
        palabras = sum(len(b.get("text", "").split()) for b in bloques)
        total_palabras += palabras

        archivo = destino / f"capitulo_{posicion:02d}.json"
        archivo.write_text(
            json.dumps(bloques, ensure_ascii=False, indent=2), encoding="utf-8"
        )

        cuerpo = json.dumps(bloques, ensure_ascii=False)
        lineas_sql.append(
            "insert into public.chapters "
            "(book_id, position, title, body, word_count)\nvalues (\n"
            f"  '{sql_escapado(libro)}',\n"
            f"  {posicion},\n"
            f"  '{sql_escapado(titulo)}',\n"
            f"  $lira${cuerpo}$lira$::jsonb,\n"
            f"  {palabras}\n);"
        )
        lineas_sql.append("")
        print(f"  [{posicion:02d}] {titulo[:48]:<50} {len(bloques):>4} bloques, {palabras:>6} palabras")

    minutos = max(1, round(total_palabras / PALABRAS_POR_MINUTO))
    lineas_sql.append("-- Cuadra el catalogo con lo que acabas de cargar.")
    lineas_sql.append(
        "update public.books\n"
        f"set chapter_count = {len(capitulos)},\n"
        f"    minutes_to_read = {minutos}\n"
        f"where id = '{sql_escapado(libro)}';"
    )

    sql = destino / "insert.sql"
    sql.write_text("\n".join(lineas_sql), encoding="utf-8")

    print()
    print(f"  Total: {len(capitulos)} capitulos, {total_palabras} palabras, ~{minutos} min")
    print(f"  SQL listo -> {sql}")


def main():
    parser = argparse.ArgumentParser(
        description="Convierte un PDF o TXT en capitulos de Lira."
    )
    parser.add_argument("entrada", help="Archivo .pdf o .txt de la obra")
    parser.add_argument("--libro", required=True, help="id del libro, p.ej. paco-yunque")
    parser.add_argument("--patron", help="regex que marca el inicio de capitulo")
    parser.add_argument("--partir-en", type=int, default=0,
                        help="trocear en N partes si la obra no tiene capitulos")
    parser.add_argument("--paginas", default="", help="rango, p.ej. 7-240")
    parser.add_argument(
        "--ocr",
        action="store_true",
        help="el PDF viene de un escaneo: arregla rayas de dialogo y manchas",
    )
    parser.add_argument(
        "--lexico",
        default="",
        help="lexico para rejuntar palabras partidas por el OCR "
        "(genera uno con tool/construir_lexico.py)",
    )
    parser.add_argument(
        "--max-palabras",
        type=int,
        default=0,
        help="trocea los capitulos mas largos que esto (0 = no trocear)",
    )
    parser.add_argument(
        "--corte",
        type=float,
        default=0.85,
        help="que tan corta debe ser una linea para cerrar parrafo (0.70-0.90)",
    )
    parser.add_argument(
        "--nombres",
        default="",
        help="nombres propios separados por coma, para no perder su mayuscula",
    )
    parser.add_argument("--salida", default="salida", help="carpeta de destino")
    args = parser.parse_args()

    ruta = Path(args.entrada)
    if not ruta.exists():
        sys.exit(f"No encuentro el archivo: {ruta}")

    primera, ultima = 1, 0
    if args.paginas:
        trozos = args.paginas.split("-")
        primera = int(trozos[0])
        ultima = int(trozos[1]) if len(trozos) > 1 and trozos[1] else 0

    print(f"\nLeyendo {ruta.name}")
    if ruta.suffix.lower() == ".pdf":
        paginas = leer_pdf(ruta, primera, ultima)
        paginas = quitar_controles(paginas)
        if args.ocr:
            paginas = limpiar_ocr(paginas)
        paginas = quitar_repetidos(paginas)
    else:
        paginas = [ruta.read_text(encoding="utf-8", errors="replace")]

    regex_capitulo = (
        re.compile(args.patron, re.IGNORECASE) if args.patron else None
    )
    parrafos = a_parrafos(paginas, regex_capitulo, args.corte)
    if args.lexico:
        parrafos = unir_partidas(parrafos, cargar_lexico(Path(args.lexico)))
    print(f"  {len(parrafos)} parrafos tras limpiar\n")

    if not parrafos:
        sys.exit("No se extrajo texto. Si el PDF es un escaneo de imagenes, "
                 "necesitas OCR antes (ver supabase/contenido.md).")

    nombres = tuple(n for n in args.nombres.split(",") if n.strip())

    if args.patron:
        capitulos = partir_por_patron(parrafos, args.patron, nombres)
        if len(capitulos) < 2:
            print("  AVISO: el patron no encontro capitulos. Usa --partir-en.")
    elif args.partir_en:
        capitulos = partir_en_partes(parrafos, args.partir_en)
    else:
        capitulos = [("Texto completo", parrafos)]
        print("  AVISO: sin --patron ni --partir-en queda un solo capitulo,")
        print("         y el progreso del estudiante sera 0% o 100%.")

    if args.max_palabras:
        antes = len(capitulos)
        capitulos = partir_largos(capitulos, args.max_palabras)
        print(
            "  Troceado: %d capitulos en %d segmentos de hasta %d palabras"
            % (antes, len(capitulos), args.max_palabras)
        )

    escribir_salida(args.libro, capitulos, Path(args.salida) / args.libro)
    print("\nRevisa el texto generado antes de subirlo. Siempre queda algo que pulir.\n")


if __name__ == "__main__":
    main()
