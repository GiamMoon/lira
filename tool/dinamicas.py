# -*- coding: utf-8 -*-
"""Banco de dinámicas de Lira.

Reglas que no se negocian (están en CLAUDE.md y hay tests que las vigilan):

  - Ninguna dinámica tiene respuesta correcta.
  - Ninguna es un ejercicio de comprensión lectora ("¿quién era el padre
    de X?"). Si se puede corregir con el libro delante, sobra.
  - Son cortas: una línea, dos como mucho.

Hay tres bancos porque un poema no se lee como una novela: preguntarle a
alguien "¿qué habrías hecho tú en su lugar?" después de un soneto no
significa nada. El banco se elige por la categoría del libro.
"""

# (kind, prompt, hint)
NARRATIVA = [
    ("reflexionar", "¿Qué parte de esto se te quedó dando vueltas?", None),
    ("reflexionar", "¿Qué detalle mínimo se te quedó grabado?", None),
    ("reflexionar", "¿Qué crees que aquí no se está diciendo en voz alta?", None),
    ("reflexionar", "¿Hay alguien aquí equivocándose sin darse cuenta?", None),
    ("reflexionar", "¿De quién te fiarías y de quién no?", None),
    ("reflexionar", "¿En qué momento habrías parado tú?", None),
    ("reflexionar", "¿Qué te habría dado más miedo si estuvieras ahí?", None),
    ("reflexionar", "¿Qué le preguntarías al que cuenta esta historia?", None),
    ("reflexionar", "¿Qué personaje te cae peor ahora mismo? No tiene que ser el malo.", None),
    ("reflexionar", "Si esto fuera tu vida, ¿a quién llamarías?", None),
    ("reflexionar", "¿Hubo algo aquí que te molestara?",
     "Molestar no es malo. A veces es la señal de que algo importa."),
    ("reflexionar", "¿Qué crees que va a salir mal?",
     "Vale equivocarse. Vuelve al final del libro a ver si acertaste."),
    ("reflexionar", "¿A quién de tu vida se parece alguno de estos personajes?",
     "No hace falta que se parezcan en todo."),
    ("reflexionar", "¿Te pasó algo parecido alguna vez, aunque fuera mucho más pequeño?", None),
    ("reflexionar", "Si tuvieras que contarle este tramo a alguien en una sola frase, ¿cuál sería?", None),

    ("crear", "Ponle tu propio título a este tramo.", None),
    ("crear", "Tres palabras que resuman lo que acabas de leer.", None),
    ("crear", "Escribe el pensamiento que el personaje no dijo.", None),
    ("crear", "Cuenta la misma escena desde los ojos de otro personaje.", None),
    ("crear", "Inventa lo que pasa cinco minutos después.", None),
    ("crear", "Escribe el final que a ti te gustaría.", None),
    ("crear", "Escribe el diario de ese personaje esta noche, en tres líneas.", None),
    ("crear", "Escribe el mensaje que un personaje le mandaría a otro si tuvieran celular.", None),
    ("crear", "Describe el objeto más importante de este tramo.", None),
    ("crear", "Haz la lista de lo que llevarías si estuvieras en su lugar.", None),
    ("crear", "Escribe una frase que podría ir en la portada de este libro.", None),
    ("crear", "Cuenta esta escena usando sólo sonidos. Nada de cómo se ve.", None),
    ("crear", "¿Qué canción sonaría aquí? Di por qué en una línea.", None),
    ("crear", "Describe a un personaje como para reconocerlo en la calle.",
     "Tres detalles bastan. Los zapatos dicen mucho."),
    ("crear", "Describe el lugar donde pasa esto. Un detalle basta.",
     "Si te sale mejor dibujarlo, dibújalo y cuéntalo en una línea."),

    ("que_harias", "¿Qué habrías hecho tú en su lugar?", None),
    ("que_harias", "¿Te quedarías o te irías?", None),
    ("que_harias", "¿Lo perdonarías?", None),
    ("que_harias", "¿Le darías otra oportunidad?", None),
    ("que_harias", "¿A quién ayudarías primero?", None),
    ("que_harias", "¿Irías solo o buscarías a alguien?", None),
    ("que_harias", "¿Se lo contarías en tu casa?", None),
    ("que_harias", "¿Seguirías adelante sabiendo lo que ya sabes?", None),
    ("que_harias", "¿Cuánto esperarías antes de rendirte?", None),
    ("que_harias", "¿Qué no harías nunca por conseguirlo?", None),
    ("que_harias", "¿Qué le dirías a la cara si lo tuvieras delante?", None),
    ("que_harias", "Si pudieras cambiar una sola decisión de este tramo, ¿cuál?", None),
    ("que_harias", "Si te lo pidieran a ti, ¿aceptarías?", None),
    ("que_harias", "¿Qué mentira dirías para salir de esta?",
     "O ninguna. Eso también es una respuesta."),
    ("que_harias", "¿Te callarías o hablarías?",
     "Las dos cosas cuestan algo distinto."),
]

POESIA = [
    ("reflexionar", "¿Qué verso te quedaste releyendo?", "No hace falta que sepas por qué."),
    ("reflexionar", "¿De qué color te suena esto?", None),
    ("reflexionar", "¿Lo leerías en voz alta o en silencio?", None),
    ("reflexionar", "¿A quién se lo mandarías?", None),
    ("reflexionar", "¿Te suena a alguien hablando contigo o a alguien hablando solo?", None),
    ("reflexionar", "¿Qué imagen se te quedó en la cabeza?", None),
    ("reflexionar", "¿Esto te suena alegre o triste? Puede ser las dos.", None),
    ("reflexionar", "¿Qué palabra de aquí no habías usado nunca?", None),
    ("reflexionar", "Si esto fuera una foto, ¿qué se vería?", None),
    ("reflexionar", "¿Hay algo aquí que no entiendas del todo y aun así te guste?",
     "Pasa mucho con la poesía. No es un problema."),

    ("crear", "Escribe un solo verso que podría ir después.", None),
    ("crear", "Cámbiale el título.", None),
    ("crear", "Róbale una palabra y escribe una frase tuya con ella.", None),
    ("crear", "Escríbelo como si se lo contaras a un amigo por mensaje.", None),
    ("crear", "Dibuja o describe la escena en una línea.", None),
    ("crear", "Tres palabras que resuman cómo te dejó.", None),
    ("crear", "Escribe la respuesta de la persona a quien le hablan.", None),
    ("crear", "¿Qué canción le pondrías detrás?", None),
    ("crear", "Escribe el mismo poema en una sola frase.", None),
    ("crear", "Escribe lo que te habría gustado que dijera.", None),

    ("que_harias", "Si te lo dedicaran a ti, ¿qué contestarías?", None),
    ("que_harias", "¿Lo publicarías o te lo guardarías?", None),
    ("que_harias", "¿Se lo dirías a esa persona o te lo callarías?", None),
    ("que_harias", "¿Te atreverías a leerlo en voz alta en clase?",
     "No hay que hacerlo. Sólo decirlo."),
    ("que_harias", "Si pudieras borrar un verso, ¿cuál?", None),
]

TEATRO = [
    ("reflexionar", "¿Quién manda de verdad en esta escena?", "No siempre es el que más habla."),
    ("reflexionar", "¿Qué personaje está fingiendo?", None),
    ("reflexionar", "¿Qué se dice aquí de más y qué se calla?", None),
    ("reflexionar", "¿A quién le crees y a quién no?", None),
    ("reflexionar", "¿Qué pasaría si uno de ellos dijera la verdad?", None),
    ("reflexionar", "¿Qué personaje te gustaría interpretar? ¿Y cuál no?", None),
    ("reflexionar", "¿Esta escena te suena a algo que hayas visto en la vida real?", None),
    ("reflexionar", "¿Quién se va a arrepentir de lo que acaba de decir?", None),
    ("reflexionar", "¿Qué se te quedó dando vueltas?", None),
    ("reflexionar", "¿Con qué tono lo dirías tú?", "Grítalo por dentro y verás si cambia."),

    ("crear", "Escribe la réplica que falta.", None),
    ("crear", "Describe el escenario: qué se ve, qué se oye.", None),
    ("crear", "Escribe la acotación que tú pondrías aquí.",
     "Una acotación es lo que el actor hace sin hablar."),
    ("crear", "Ponle a esta escena un título de capítulo.", None),
    ("crear", "Reescribe una línea como se diría hoy.", None),
    ("crear", "Escribe lo que un personaje piensa mientras el otro habla.", None),
    ("crear", "Elige la ropa de un personaje. Tres prendas.", None),
    ("crear", "Tres palabras que resuman la escena.", None),
    ("crear", "Escribe cómo acabaría esto si fuera una comedia.", None),
    ("crear", "¿Qué música sonaría al bajar el telón?", None),

    ("que_harias", "¿Qué habrías hecho tú en su lugar?", None),
    ("que_harias", "¿Entrarías a la escena a decir algo o te quedarías callado?", None),
    ("que_harias", "¿De qué lado te pondrías?", None),
    ("que_harias", "¿Le contarías a alguien lo que acabas de oír?", None),
    ("que_harias", "Si pudieras parar la obra un momento, ¿a quién avisarías?", None),
]

BANCOS = {
    "novela": NARRATIVA,
    "cuento": NARRATIVA,
    "biografia": NARRATIVA,
    "poesia": POESIA,
    "teatro": TEATRO,
}


def para_capitulo(libro_id: str, categoria: str, posicion: int):
    """Elige la dinámica de un capítulo. Determinista y sin repetir seguido.

    El banco se recorre con un paso primo respecto a su tamaño, así que dos
    capítulos consecutivos nunca caen en la misma consigna y el recorrido
    entero pasa por todas antes de repetir. El desplazamiento inicial depende
    del id del libro para que dos obras no arranquen con la misma pregunta.
    """
    banco = BANCOS.get(categoria, NARRATIVA)
    paso = 7 if len(banco) % 7 else 8
    inicio = sum(ord(c) for c in libro_id) % len(banco)
    return banco[(inicio + posicion * paso) % len(banco)]
