-- Una dinámica en cada capítulo.
--
-- Las seis por libro escritas a mano (las de escenas concretas) ya
-- estaban; esto rellena el resto con un banco de 45 consignas abiertas
-- que rotan entre Reflexionar, Crear y ¿Qué harías tú?.
--
-- El "not exists" del final hace la migración repetible: si un capítulo
-- ya tiene dinámica, no se le añade otra.

-- ==== el-camino-de-sherlock ====
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué parte de esto se te quedó dando vueltas?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 0
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Qué habrías hecho tú en su lugar?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 2
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Hubo algo aquí que te molestara?', 'Molestar no es malo. A veces es la señal de que algo importa.'
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 3
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Escribe el mensaje que un personaje le mandaría a otro si tuvieran celular.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 4
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', 'Si pudieras cambiar una sola decisión de este tramo, ¿cuál?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 5
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Ponle tu propio título a este tramo.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 7
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Te callarías o hablarías?', 'Las dos cosas cuestan algo distinto.'
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 8
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿A quién de tu vida se parece alguno de estos personajes?', 'No hace falta que se parezcan en todo.'
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 9
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Cuenta esta escena usando sólo sonidos. Nada de cómo se ve.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 10
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Te quedarías o te irías?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 11
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué crees que aquí no se está diciendo en voz alta?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 12
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿A quién ayudarías primero?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 14
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué personaje te cae peor ahora mismo? No tiene que ser el malo.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 15
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Inventa lo que pasa cinco minutos después.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 16
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', 'Si te lo pidieran a ti, ¿aceptarías?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 17
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué te habría dado más miedo si estuvieras ahí?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 18
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Escribe el pensamiento que el personaje no dijo.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 19
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué crees que va a salir mal?', 'Vale equivocarse. Vuelve al final del libro a ver si acertaste.'
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 21
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Haz la lista de lo que llevarías si estuvieras en su lugar.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 22
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Lo perdonarías?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 23
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Te pasó algo parecido alguna vez, aunque fuera mucho más pequeño?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 24
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Cuenta la misma escena desde los ojos de otro personaje.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 25
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Cuánto esperarías antes de rendirte?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 26
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué detalle mínimo se te quedó grabado?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 27
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Qué no harías nunca por conseguirlo?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 29
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Hay alguien aquí equivocándose sin darse cuenta?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 30
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Escribe el final que a ti te gustaría.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 31
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Irías solo o buscarías a alguien?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 32
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿Qué le preguntarías al que cuenta esta historia?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 33
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', '¿Qué canción sonaría aquí? Di por qué en una línea.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 34
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Qué le dirías a la cara si lo tuvieras delante?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 35
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'crear', 'Escribe una frase que podría ir en la portada de este libro.', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 37
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'que_harias', '¿Le darías otra oportunidad?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 38
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'el-camino-de-sherlock', c.id, 'reflexionar', '¿De quién te fiarías y de quién no?', null
from public.chapters c
where c.book_id = 'el-camino-de-sherlock' and c.position = 39
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);

-- ==== john-wesley ====
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Describe el lugar donde pasa esto. Un detalle basta.', 'Si te sale mejor dibujarlo, dibújalo y cuéntalo en una línea.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 1
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Qué habrías hecho tú en su lugar?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 2
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Hubo algo aquí que te molestara?', 'Molestar no es malo. A veces es la señal de que algo importa.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 3
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Escribe el mensaje que un personaje le mandaría a otro si tuvieran celular.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 4
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', 'Si pudieras cambiar una sola decisión de este tramo, ¿cuál?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 5
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', 'Si tuvieras que contarle este tramo a alguien en una sola frase, ¿cuál sería?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 6
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Ponle tu propio título a este tramo.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 7
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Te callarías o hablarías?', 'Las dos cosas cuestan algo distinto.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 8
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Cuenta esta escena usando sólo sonidos. Nada de cómo se ve.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 10
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Te quedarías o te irías?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 11
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué crees que aquí no se está diciendo en voz alta?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 12
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Tres palabras que resuman lo que acabas de leer.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 13
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿A quién ayudarías primero?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 14
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué personaje te cae peor ahora mismo? No tiene que ser el malo.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 15
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Inventa lo que pasa cinco minutos después.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 16
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', 'Si te lo pidieran a ti, ¿aceptarías?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 17
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué te habría dado más miedo si estuvieras ahí?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 18
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Se lo contarías en tu casa?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 20
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué crees que va a salir mal?', 'Vale equivocarse. Vuelve al final del libro a ver si acertaste.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 21
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Lo perdonarías?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 23
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Te pasó algo parecido alguna vez, aunque fuera mucho más pequeño?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 24
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Cuenta la misma escena desde los ojos de otro personaje.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 25
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Cuánto esperarías antes de rendirte?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 26
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué detalle mínimo se te quedó grabado?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 27
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Qué no harías nunca por conseguirlo?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 29
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Hay alguien aquí equivocándose sin darse cuenta?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 30
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Escribe el final que a ti te gustaría.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 31
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Irías solo o buscarías a alguien?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 32
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué le preguntarías al que cuenta esta historia?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 33
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', '¿Qué canción sonaría aquí? Di por qué en una línea.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 34
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Qué le dirías a la cara si lo tuvieras delante?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 35
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿En qué momento habrías parado tú?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 36
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Escribe una frase que podría ir en la portada de este libro.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 37
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Le darías otra oportunidad?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 38
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿De quién te fiarías y de quién no?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 39
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Describe a un personaje como para reconocerlo en la calle.', 'Tres detalles bastan. Los zapatos dicen mucho.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 40
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Qué mentira dirías para salir de esta?', 'O ninguna. Eso también es una respuesta.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 41
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', 'Si esto fuera tu vida, ¿a quién llamarías?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 42
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Escribe el diario de ese personaje esta noche, en tres líneas.', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 43
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Seguirías adelante sabiendo lo que ya sabes?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 44
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'reflexionar', '¿Qué parte de esto se te quedó dando vueltas?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 45
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'crear', 'Describe el lugar donde pasa esto. Un detalle basta.', 'Si te sale mejor dibujarlo, dibújalo y cuéntalo en una línea.'
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 46
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'john-wesley', c.id, 'que_harias', '¿Qué habrías hecho tú en su lugar?', null
from public.chapters c
where c.book_id = 'john-wesley' and c.position = 47
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);

-- ==== las-aventuras-de-tom-sawyer ====
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué parte de esto se te quedó dando vueltas?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 0
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Describe el lugar donde pasa esto. Un detalle basta.', 'Si te sale mejor dibujarlo, dibújalo y cuéntalo en una línea.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 1
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué habrías hecho tú en su lugar?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 2
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Hubo algo aquí que te molestara?', 'Molestar no es malo. A veces es la señal de que algo importa.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 3
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el mensaje que un personaje le mandaría a otro si tuvieran celular.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 4
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', 'Si tuvieras que contarle este tramo a alguien en una sola frase, ¿cuál sería?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 6
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Ponle tu propio título a este tramo.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 7
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Te callarías o hablarías?', 'Las dos cosas cuestan algo distinto.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 8
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿A quién de tu vida se parece alguno de estos personajes?', 'No hace falta que se parezcan en todo.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 9
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Cuenta esta escena usando sólo sonidos. Nada de cómo se ve.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 10
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Te quedarías o te irías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 11
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué crees que aquí no se está diciendo en voz alta?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 12
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Tres palabras que resuman lo que acabas de leer.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 13
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿A quién ayudarías primero?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 14
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué personaje te cae peor ahora mismo? No tiene que ser el malo.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 15
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Inventa lo que pasa cinco minutos después.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 16
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', 'Si te lo pidieran a ti, ¿aceptarías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 17
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué te habría dado más miedo si estuvieras ahí?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 18
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el pensamiento que el personaje no dijo.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 19
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Se lo contarías en tu casa?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 20
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué crees que va a salir mal?', 'Vale equivocarse. Vuelve al final del libro a ver si acertaste.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 21
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Haz la lista de lo que llevarías si estuvieras en su lugar.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 22
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Lo perdonarías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 23
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Te pasó algo parecido alguna vez, aunque fuera mucho más pequeño?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 24
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Cuenta la misma escena desde los ojos de otro personaje.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 25
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Cuánto esperarías antes de rendirte?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 26
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué detalle mínimo se te quedó grabado?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 27
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué no harías nunca por conseguirlo?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 29
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Hay alguien aquí equivocándose sin darse cuenta?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 30
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el final que a ti te gustaría.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 31
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Irías solo o buscarías a alguien?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 32
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué le preguntarías al que cuenta esta historia?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 33
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', '¿Qué canción sonaría aquí? Di por qué en una línea.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 34
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué le dirías a la cara si lo tuvieras delante?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 35
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿En qué momento habrías parado tú?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 36
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe una frase que podría ir en la portada de este libro.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 37
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿De quién te fiarías y de quién no?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 39
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Describe a un personaje como para reconocerlo en la calle.', 'Tres detalles bastan. Los zapatos dicen mucho.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 40
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué mentira dirías para salir de esta?', 'O ninguna. Eso también es una respuesta.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 41
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', 'Si esto fuera tu vida, ¿a quién llamarías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 42
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el diario de ese personaje esta noche, en tres líneas.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 43
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Seguirías adelante sabiendo lo que ya sabes?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 44
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué parte de esto se te quedó dando vueltas?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 45
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Describe el lugar donde pasa esto. Un detalle basta.', 'Si te sale mejor dibujarlo, dibújalo y cuéntalo en una línea.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 46
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué habrías hecho tú en su lugar?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 47
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Hubo algo aquí que te molestara?', 'Molestar no es malo. A veces es la señal de que algo importa.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 48
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', 'Si pudieras cambiar una sola decisión de este tramo, ¿cuál?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 50
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', 'Si tuvieras que contarle este tramo a alguien en una sola frase, ¿cuál sería?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 51
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Ponle tu propio título a este tramo.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 52
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Te callarías o hablarías?', 'Las dos cosas cuestan algo distinto.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 53
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿A quién de tu vida se parece alguno de estos personajes?', 'No hace falta que se parezcan en todo.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 54
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Cuenta esta escena usando sólo sonidos. Nada de cómo se ve.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 55
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Te quedarías o te irías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 56
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué crees que aquí no se está diciendo en voz alta?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 57
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Tres palabras que resuman lo que acabas de leer.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 58
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿A quién ayudarías primero?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 59
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué personaje te cae peor ahora mismo? No tiene que ser el malo.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 60
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Inventa lo que pasa cinco minutos después.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 61
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', 'Si te lo pidieran a ti, ¿aceptarías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 62
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué te habría dado más miedo si estuvieras ahí?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 63
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Se lo contarías en tu casa?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 65
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué crees que va a salir mal?', 'Vale equivocarse. Vuelve al final del libro a ver si acertaste.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 66
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Haz la lista de lo que llevarías si estuvieras en su lugar.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 67
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Lo perdonarías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 68
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Te pasó algo parecido alguna vez, aunque fuera mucho más pequeño?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 69
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Cuenta la misma escena desde los ojos de otro personaje.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 70
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Cuánto esperarías antes de rendirte?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 71
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué detalle mínimo se te quedó grabado?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 72
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Describe el objeto más importante de este tramo.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 73
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué no harías nunca por conseguirlo?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 74
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Hay alguien aquí equivocándose sin darse cuenta?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 75
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el final que a ti te gustaría.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 76
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Irías solo o buscarías a alguien?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 77
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué le preguntarías al que cuenta esta historia?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 78
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', '¿Qué canción sonaría aquí? Di por qué en una línea.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 79
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué le dirías a la cara si lo tuvieras delante?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 80
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe una frase que podría ir en la portada de este libro.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 82
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Le darías otra oportunidad?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 83
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿De quién te fiarías y de quién no?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 84
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Describe a un personaje como para reconocerlo en la calle.', 'Tres detalles bastan. Los zapatos dicen mucho.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 85
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué mentira dirías para salir de esta?', 'O ninguna. Eso también es una respuesta.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 86
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', 'Si esto fuera tu vida, ¿a quién llamarías?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 87
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el diario de ese personaje esta noche, en tres líneas.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 88
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Seguirías adelante sabiendo lo que ya sabes?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 89
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Qué parte de esto se te quedó dando vueltas?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 90
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Describe el lugar donde pasa esto. Un detalle basta.', 'Si te sale mejor dibujarlo, dibújalo y cuéntalo en una línea.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 91
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', '¿Qué habrías hecho tú en su lugar?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 92
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'reflexionar', '¿Hubo algo aquí que te molestara?', 'Molestar no es malo. A veces es la señal de que algo importa.'
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 93
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'crear', 'Escribe el mensaje que un personaje le mandaría a otro si tuvieran celular.', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 94
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'las-aventuras-de-tom-sawyer', c.id, 'que_harias', 'Si pudieras cambiar una sola decisión de este tramo, ¿cuál?', null
from public.chapters c
where c.book_id = 'las-aventuras-de-tom-sawyer' and c.position = 95
  and not exists (select 1 from public.activities a where a.chapter_id = c.id);

