# -*- coding: utf-8 -*-
"""El catálogo de Lira: qué PDF es qué libro.

Una entrada por obra. `tool/lote_pdfs.py` lee esto y produce la migración
de Supabase; nada de esto se decide dentro del conversor.

Campos:
  id          slug del libro (clave primaria en `books`)
  titulo      cómo se llama de verdad la obra, no cómo se llama el archivo
  autor       el autor real, no el que sugiere el nombre del PDF
  categoria   cuento | novela | biografia | poesia | teatro
  sinopsis    dos líneas, sin spoilers, escritas para un estudiante
  archivos    uno o varios PDF; varios se concatenan en el orden dado
  patron      regex de inicio de capítulo; None = que lo detecte el conversor
  paginas     "7-240" para saltarse portada, índice y créditos legales
  corte       umbral de fin de párrafo; None = que lo calibre el conversor
  nombres     nombres propios que deben conservar su mayúscula en los títulos
  tags        etiquetas que se ven en la ficha

Los PDF que NO entran están al final, con el motivo. Se dejan escritos a
propósito: sin eso, el siguiente que abra la carpeta vuelve a intentarlo.
"""

CATALOGO = [
    # ─── Narrativa universal ────────────────────────────────────────────────
    dict(
        id="la-metamorfosis",
        titulo="La metamorfosis",
        autor="Franz Kafka",
        categoria="novela",
        sinopsis="Gregorio Samsa se despierta una mañana convertido en un "
                 "insecto enorme. Lo raro no es eso: es cómo reacciona su "
                 "familia.",
        archivos=["119-2014-02-11-Kafka.La metamorfosis.pdf"],
        paginas="3-0",
        tags=["clásico", "extrañeza", "familia"],
    ),
    dict(
        id="alicia-en-el-pais-de-las-maravillas",
        titulo="Alicia en el País de las Maravillas",
        autor="Lewis Carroll",
        categoria="novela",
        sinopsis="Alicia sigue a un conejo con reloj y cae por una madriguera "
                 "donde nada obedece a la lógica. Ni el tamaño de su propio "
                 "cuerpo.",
        archivos=["119-2014-02-19-Carroll.AliciaEnElPaisDeLasMaravillas.pdf"],
        paginas="7-0",
        tags=["clásico", "absurdo", "aventura"],
    ),
    dict(
        id="el-principito",
        titulo="El Principito",
        autor="Antoine de Saint-Exupéry",
        categoria="novela",
        sinopsis="Un piloto cae en el desierto y conoce a un niño que viene "
                 "de otro planeta y que hace preguntas incómodas sobre los "
                 "adultos.",
        archivos=["el principito.pdf"],
        tags=["clásico", "amistad", "para pensar"],
    ),
    dict(
        id="robinson-crusoe",
        titulo="Robinson Crusoe",
        autor="Daniel Defoe",
        categoria="novela",
        sinopsis="Un naufragio lo deja solo en una isla. Veintiocho años "
                 "después sigue ahí, y ha tenido que aprenderlo todo desde "
                 "cero.",
        # Ojo con esta edición: los títulos y las cifras van en una versalita
        # cuyo subconjunto de fuente no trae tabla Unicode, así que al extraer
        # sale la primera letra de cada palabra y nada más ("C\x00\x00… 2.").
        # No hay forma de recuperarlo —pdfplumber, pypdf y saltarse el
        # ToUnicode dan lo mismo— sin pasar un OCR por la página pintada.
        # La prosa entra entera; lo que se pierde son las fechas del diario,
        # que quedan marcadas con … en vez de inventadas.
        archivos=["Daniel Defoe Robinson Crusoe.pdf"],
        paginas="5-0",
        tags=["aventura", "supervivencia", "clásico"],
    ),
    dict(
        id="la-isla-del-tesoro",
        titulo="La isla del tesoro",
        autor="Robert Louis Stevenson",
        categoria="novela",
        sinopsis="Un mapa aparece en el baúl de un marinero muerto. Jim se "
                 "embarca a buscar el tesoro sin saber quién de la "
                 "tripulación es pirata.",
        archivos=["Robert Louis Stevenson La isla del tesoro.pdf"],
        paginas="4-0",
        tags=["aventura", "piratas", "clásico"],
    ),
    dict(
        id="viaje-al-centro-de-la-tierra",
        titulo="Viaje al centro de la Tierra",
        autor="Julio Verne",
        categoria="novela",
        sinopsis="Un mensaje cifrado en un libro antiguo promete un camino "
                 "hasta el corazón del planeta. El profesor Lidenbrock "
                 "decide comprobarlo.",
        archivos=["Julio Verne - Viaje al Centro de la Tierra (1).pdf"],
        paginas="3-0",
        tags=["aventura", "ciencia", "viaje"],
    ),
    dict(
        id="la-vuelta-al-mundo-en-80-dias",
        titulo="La vuelta al mundo en 80 días",
        autor="Julio Verne",
        categoria="novela",
        sinopsis="Phileas Fogg apuesta su fortuna a que puede dar la vuelta "
                 "al planeta en ochenta días. Sale esa misma noche.",
        archivos=["Julio Verne - Vuelta al Mundo en 80 Dias.pdf"],
        paginas="3-0",
        tags=["aventura", "viaje", "apuesta"],
    ),
    dict(
        id="el-extrano-caso-del-dr-jekyll-y-mr-hyde",
        titulo="El extraño caso del Dr. Jekyll y Mr. Hyde",
        autor="Robert Louis Stevenson",
        categoria="novela",
        sinopsis="Un abogado investiga por qué su amigo, un médico "
                 "respetable, protege a un hombre que da miedo a todo el que "
                 "lo mira.",
        archivos=["el_extraÃ±o_caso_del_dr_jekyll_y_mr_hyde.pdf"],
        tags=["misterio", "terror", "clásico"],
    ),
    dict(
        id="cuento-de-navidad",
        titulo="Cuento de Navidad",
        autor="Charles Dickens",
        categoria="novela",
        sinopsis="Scrooge odia la Navidad y a casi todo el mundo. Tres "
                 "fantasmas vienen a enseñarle lo que no quiere ver.",
        archivos=["Charles Dickens, Cuento de Navidad.pdf"],
        paginas="4-0",
        tags=["clásico", "fantasmas", "segunda oportunidad"],
    ),
    dict(
        id="platero-y-yo",
        titulo="Platero y yo",
        autor="Juan Ramón Jiménez",
        categoria="novela",
        sinopsis="Capítulos muy cortos sobre un burro pequeño y peludo y el "
                 "pueblo donde vive. Se puede leer uno cada día.",
        archivos=["Juan Ramón Jiménez  Platero y yo.pdf"],
        paginas="3-0",
        tags=["capítulos cortos", "animales", "clásico"],
    ),

    # ─── Cuento ─────────────────────────────────────────────────────────────
    dict(
        id="cuentos-de-edgar-allan-poe",
        titulo="Cuentos de Edgar Allan Poe",
        autor="Edgar Allan Poe",
        categoria="cuento",
        sinopsis="Cuatro relatos de miedo y de crimen: un corazón que no deja "
                 "de latir, un gato negro, una máscara y el primer detective "
                 "de la literatura.",
        archivos=["7Basico_Cuentos-de-Edgas-Allan-Poe.pdf", "2 El gato negro.pdf"],
        tags=["terror", "misterio", "relatos"],
    ),
    dict(
        id="el-principe-feliz-y-el-gigante-egoista",
        titulo="El príncipe feliz y El gigante egoísta",
        autor="Oscar Wilde",
        categoria="cuento",
        sinopsis="Dos cuentos cortos que parecen para niños y no lo son "
                 "del todo: una estatua que lo da todo y un gigante que "
                 "levanta un muro.",
        archivos=["el_principe_feliz_-_oscar_wilde.pdf",
                  "Oscar Wilde - El Gigante Egoista.pdf"],
        tags=["relatos", "para pensar", "clásico"],
    ),
    dict(
        id="cuentos-de-andersen",
        titulo="Dos cuentos de Andersen",
        autor="Hans Christian Andersen",
        categoria="cuento",
        sinopsis="El traje nuevo del emperador y El patito feo: dos cuentos "
                 "que todo el mundo cree conocer hasta que los lee enteros.",
        archivos=["Emperador.pdf", "patito_web.pdf"],
        tags=["relatos", "clásico", "cortos"],
    ),
    dict(
        id="cuentos-de-horacio-quiroga",
        titulo="Tres cuentos de Horacio Quiroga",
        autor="Horacio Quiroga",
        categoria="cuento",
        sinopsis="El almohadón de plumas, La gallina degollada y A la "
                 "deriva. Tres finales que se ven venir y aun así "
                 "sobrecogen.",
        archivos=["El almohadonV2018vCompleto_2.pdf",
                  "La-gallina-degollada-v1_584.pdf",
                  "a-la-deriva-h-quiroga.pdf"],
        tags=["terror", "relatos", "latinoamérica"],
    ),
    dict(
        id="azul",
        titulo="Azul…",
        autor="Rubén Darío",
        categoria="cuento",
        sinopsis="Cuentos y poemas del libro que cambió el castellano. El "
                 "rey burgués, El sátiro sordo, La muerte de la emperatriz "
                 "de la China.",
        archivos=["Rubén Darío  Azul.pdf"],
        paginas="5-0",
        tags=["modernismo", "relatos", "clásico"],
    ),
    dict(
        id="el-caballero-carmelo",
        titulo="El Caballero Carmelo y otros cuentos",
        autor="Abraham Valdelomar",
        categoria="cuento",
        sinopsis="Un gallo de pelea viejo que vuelve a casa, un circo de "
                 "pueblo, la costa peruana de principios del siglo XX.",
        archivos=["El Caballero Carmelo y Otros Cuentos.pdf"],
        paginas="17-0",
        tags=["perú", "relatos", "clásico"],
    ),
    dict(
        id="tradiciones-peruanas",
        titulo="Tradiciones peruanas",
        autor="Ricardo Palma",
        categoria="cuento",
        sinopsis="Historias breves de la Lima virreinal contadas con chisme, "
                 "humor y mala leche. Se leen sueltas, en cualquier orden.",
        archivos=["Tradiciones-Peruanas-I.pdf"],
        paginas="5-0",
        tags=["perú", "historia", "cortos"],
    ),
    dict(
        id="paco-yunque",
        titulo="Paco Yunque",
        autor="César Vallejo",
        categoria="cuento",
        sinopsis="El primer día de colegio de un niño pobre que entra a un "
                 "aula donde el hijo del patrón manda hasta sobre el "
                 "profesor.",
        archivos=["LAV152 - PacoYunque BD.pdf"],
        tags=["perú", "colegio", "injusticia"],
    ),
    dict(
        id="los-gallinazos-sin-plumas",
        titulo="Los gallinazos sin plumas",
        autor="Julio Ramón Ribeyro",
        categoria="cuento",
        sinopsis="Dos hermanos salen de madrugada a buscar comida en los "
                 "basurales de Lima para el cerdo de su abuelo.",
        archivos=["Julio Ramón Ribeyro. Los gallinazos sin plumas.pdf"],
        tags=["perú", "lima", "relatos"],
    ),
    dict(
        id="alienacion",
        titulo="Alienación",
        autor="Julio Ramón Ribeyro",
        categoria="cuento",
        sinopsis="Roberto quiere dejar de ser quien es: cambia de nombre, de "
                 "ropa y de idioma para que lo miren de otra manera.",
        archivos=["Ribeyro-Alienacion.pdf"],
        tags=["perú", "identidad", "corto"],
    ),
    dict(
        id="antologia-agua-y-almanaque",
        titulo="Agua · Historias de almanaque",
        autor="José María Arguedas y Bertolt Brecht",
        categoria="cuento",
        sinopsis="Antología del colegio: los relatos andinos de Arguedas "
                 "junto a las historias cortas y afiladas de Brecht.",
        archivos=["62566fb507ac17f8a1144276653faa2e.pdf"],
        tags=["antología", "perú", "relatos"],
    ),

    # ─── Novela peruana ─────────────────────────────────────────────────────
    dict(
        id="los-rios-profundos",
        titulo="Los ríos profundos",
        autor="José María Arguedas",
        categoria="novela",
        sinopsis="Ernesto entra interno en un colegio de Abancay. Fuera, el "
                 "mundo quechua de su infancia; dentro, otro que no lo "
                 "quiere.",
        archivos=["Los ríos profundos.pdf"],
        paginas="21-0",
        tags=["perú", "andes", "colegio"],
    ),

    # ─── Teatro ─────────────────────────────────────────────────────────────
    dict(
        id="romeo-y-julieta",
        titulo="Romeo y Julieta",
        autor="William Shakespeare",
        categoria="teatro",
        sinopsis="Dos familias que se odian, dos hijos que se enamoran en "
                 "una fiesta y cinco días que lo deciden todo.",
        archivos=["William Shakespeare Romeo y Julieta.pdf"],
        paginas="7-0",
        tags=["clásico", "amor", "tragedia"],
    ),
    dict(
        id="hamlet",
        titulo="Hamlet",
        autor="William Shakespeare",
        categoria="teatro",
        sinopsis="El fantasma de su padre le dice quién lo mató. Hamlet pasa "
                 "la obra entera decidiendo si le cree y qué hacer.",
        archivos=["William Shakespeare Hamlet.pdf"],
        paginas="7-0",
        tags=["clásico", "venganza", "tragedia"],
    ),
    dict(
        id="edipo-rey",
        titulo="Edipo Rey",
        autor="Sófocles",
        categoria="teatro",
        sinopsis="Tebas está apestada y el rey jura encontrar al culpable. "
                 "La investigación avanza hacia el único sitio donde no "
                 "quería mirar.",
        # El PDF viene con el nombre de Esquilo. La obra es de Sófocles.
        archivos=["Esquilo Edipo Rey.pdf"],
        tags=["clásico", "griego", "destino"],
    ),
    dict(
        id="fuenteovejuna",
        verso=True,   # comedia en verso: los versos no se reflotan
        titulo="Fuenteovejuna",
        autor="Lope de Vega",
        categoria="teatro",
        sinopsis="Un comandante abusa de un pueblo entero hasta que el "
                 "pueblo entero responde. Y luego nadie da un solo nombre.",
        archivos=["Lope de Vega - Fuente ovejuna.pdf"],
        tags=["clásico", "pueblo", "justicia"],
    ),
    dict(
        id="la-vida-es-sueno",
        verso=True,   # comedia en verso: los versos no se reflotan
        titulo="La vida es sueño",
        autor="Pedro Calderón de la Barca",
        categoria="teatro",
        sinopsis="Segismundo creció encerrado en una torre por una profecía. "
                 "Un día lo sacan sin avisarle y lo sientan en el trono.",
        archivos=["Pedro Calderón de la Barca La vida es sueño.pdf"],
        paginas="7-0",
        tags=["clásico", "libertad", "destino"],
    ),
    dict(
        id="don-juan-tenorio",
        verso=True,   # comedia en verso: los versos no se reflotan
        titulo="Don Juan Tenorio",
        autor="José Zorrilla",
        categoria="teatro",
        sinopsis="Don Juan apuesta en una taberna a que puede conquistar y "
                 "arruinar a quien quiera. Gana la apuesta. Luego llega la "
                 "cuenta.",
        archivos=["José Zorrilla Don Juan Tenorio.pdf"],
        paginas="7-0",
        tags=["clásico", "apuesta", "romanticismo"],
    ),
    dict(
        id="la-casa-de-bernarda-alba",
        titulo="La casa de Bernarda Alba",
        autor="Federico García Lorca",
        categoria="teatro",
        sinopsis="Muere el marido y Bernarda ordena ocho años de luto "
                 "encerradas. Cinco hijas, una casa y una sola puerta.",
        archivos=["la-casa-de-bernarda-alba.pdf"],
        tags=["clásico", "encierro", "tragedia"],
    ),
    dict(
        id="el-avaro",
        titulo="El avaro",
        autor="Molière",
        categoria="teatro",
        sinopsis="Harpagón quiere a su dinero más que a sus hijos, y lo "
                 "demuestra en cada escena. Comedia, aunque duela.",
        archivos=["Moliere-Avaro.pdf"],
        tags=["comedia", "clásico", "dinero"],
    ),
    dict(
        id="el-si-de-las-ninas",
        titulo="El sí de las niñas",
        autor="Leandro Fernández de Moratín",
        categoria="teatro",
        sinopsis="A una chica de dieciséis la casan con un hombre de "
                 "cincuenta y todos le preguntan si está de acuerdo. Ella "
                 "dice que sí.",
        archivos=["si_de_las_ninas_de_moratin.pdf"],
        paginas="7-0",
        tags=["clásico", "comedia", "libertad"],
    ),

    # ─── Poesía ─────────────────────────────────────────────────────────────
    dict(
        id="campos-de-castilla",
        titulo="Campos de Castilla",
        autor="Antonio Machado",
        categoria="poesia",
        sinopsis="El paisaje de Soria, los caminos y la muerte de Leonor. "
                 "Aquí está «caminante, no hay camino».",
        archivos=["Antonio Machado   Campos de Castilla.pdf"],
        paginas="4-0",
        tags=["poesía", "paisaje", "clásico"],
    ),
    dict(
        id="rimas",
        titulo="Rimas",
        autor="Gustavo Adolfo Bécquer",
        categoria="poesia",
        sinopsis="Poemas cortos sobre el amor y su final. Los más citados "
                 "del castellano caben en media página.",
        archivos=["rimas.pdf"],
        tags=["poesía", "amor", "cortos"],
    ),
    dict(
        id="veinte-poemas-de-amor",
        titulo="20 poemas de amor y una canción desesperada",
        autor="Pablo Neruda",
        categoria="poesia",
        sinopsis="Veinte poemas escritos a los diecinueve años y una "
                 "despedida al final. Se leen de uno en uno.",
        archivos=["Pablo_Neruda_-_20_poemas_de_amor(1).pdf"],
        tags=["poesía", "amor", "latinoamérica"],
    ),
    dict(
        id="prosas-profanas",
        titulo="Prosas profanas",
        autor="Rubén Darío",
        categoria="poesia",
        sinopsis="Cisnes, princesas y música: el modernismo en su momento "
                 "más deslumbrante y menos serio.",
        archivos=["prosas_profanas.pdf"],
        tags=["poesía", "modernismo", "clásico"],
    ),
    dict(
        id="poeta-en-nueva-york",
        titulo="Poeta en Nueva York",
        autor="Federico García Lorca",
        categoria="poesia",
        sinopsis="Lorca llega a Nueva York en 1929 y escribe lo que ve: "
                 "multitudes, dinero y una ciudad que no duerme ni deja "
                 "dormir.",
        archivos=["García Lorca Federico - Poeta.pdf"],
        tags=["poesía", "ciudad", "vanguardia"],
    ),
    dict(
        id="los-heraldos-negros",
        titulo="Los heraldos negros",
        autor="César Vallejo",
        categoria="poesia",
        sinopsis="El primer libro de Vallejo. Empieza con el verso más "
                 "conocido de la poesía peruana y sigue hacia abajo.",
        archivos=["libro_000007.pdf"],
        paginas="9-0",
        tags=["poesía", "perú", "clásico"],
    ),
]


# ─── Lo que NO entra, y por qué ─────────────────────────────────────────────
# Si alguien vuelve a abrir la carpeta pdfs/ y se pregunta por estos, aquí
# está la respuesta. Todos se probaron; ninguno se descartó por pereza.
DESCARTADOS = {
    "1000018160-0001.pdf":
        "Escaneo antiguo de «Agua» con el OCR destrozado ('enc-no.igo', "
        "'coraz.ón'). El mismo texto entra limpio por la antología del "
        "colegio (antologia-agua-y-almanaque).",
    "2016-ad-una-cino-antigona-sofocles.pdf":
        "Maquetado a dos columnas que pdfplumber funde en una sola línea "
        "('MENSAJERO: CORIFEO:'), y con la fuente sin tabla Unicode, así que "
        "las tildes salen como (cid:211) y Ø.",
    "romancero.pdf":
        "Mismo problema de dos columnas fundidas: cada verso del Romancero "
        "gitano queda pegado al de la columna de al lado.",
    "libro_000044.pdf":
        "«Trilce» en el escaneo de 1922. El OCR es ilegible: 'umbé eim "
        "novedad por la h a d a c alle'. Reconstruirlo sería inventarlo.",
    "Mark Twain - Las Aventuras de Tom Sawyer.pdf":
        "Ya está en el catálogo con 96 capítulos desde otra edición mejor.",
    "Abraham Valdelomar - El Vuelo de los Condores.pdf":
        "El cuento ya viene dentro de «El Caballero Carmelo y otros cuentos».",
}
