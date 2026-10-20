# Cómo cargar el texto de las obras

El lector de Lira **no usa PDF**. Cada capítulo se guarda como una lista de
bloques en `chapters.body` (jsonb). Eso es lo que permite que el texto se
adapte a cualquier pantalla, que el progreso sea real ("3 de 8") y que las
dinámicas puedan aparecer entre bloques sin pelearse con una maqueta fija.

## Formato de un capítulo

```json
[
  { "type": "note",  "text": "Aviso de Lira, no del autor." },
  { "type": "p",     "text": "Un párrafo normal." },
  { "type": "v",     "text": "Un verso
y el siguiente" },
  { "type": "h",     "text": "Un subtítulo dentro del capítulo" },
  { "type": "quote", "text": "Una línea destacada." },
  { "type": "hr" }
]
```

Un `type` desconocido se pinta como párrafo, así que el formato puede crecer
sin romper versiones antiguas de la app.

`v` es una **estrofa entera**, con los versos separados por `
` dentro del
mismo bloque. Un poema no se reflota: si se guardara como párrafos, dejaría de
ser el poema.

## El camino corto: convertir muchos PDF de una vez

Si lo que tienes es una carpeta de PDF, no los conviertas de uno en uno.
Describe cada obra en `tool/catalogo.py` (id, título, autor, categoría,
sinopsis, archivos) y lanza:

```sh
python tool/lote_pdfs.py --informe    # analiza y resume, sin escribir nada
python tool/lote_pdfs.py              # escribe una migración con todo
supabase db push                      # la sube (te pedirá la contraseña)
```

El lote calibra solo el corte de párrafo, detecta los capítulos, genera una
dinámica por capítulo y **deja fuera los PDF cuyo OCR está roto**, diciendo
por qué. La migración es repetible: cada libro borra sus capítulos antes de
insertarlos, así que se puede volver a pasar sin duplicar nada.

Lo que sigue es el camino largo, libro a libro, que sigue valiendo cuando hay
que afinar una obra concreta.

## El camino completo, en orden

Para **cada** libro, de principio a fin. Saltarse el orden es el error más
común: los capítulos apuntan al libro por clave foránea, así que el libro va
primero.

1. **Consigue el texto** — tu PDF, o Wikisource (más abajo; suele salir mejor).

2. **Crea la fila del libro** en el SQL Editor de Supabase:

   ```sql
   insert into public.books
     (id, title, author, synopsis, category, chapter_count, minutes_to_read, tags, is_published)
   values
     ('paco-yunque', 'Paco Yunque', 'César Vallejo',
      'El primer día de clase de un niño pobre…',
      'cuento', 0, 0, '{Perú,Colegio}', false);
   ```

   Ojo: `is_published` en `false` de momento. Así no aparece a medio cargar.
   `chapter_count` y `minutes_to_read` en 0: los calcula el conversor.

3. **Convierte** el archivo:

   ```sh
   python tool/pdf_a_lira.py "Paco Yunque.pdf" --libro paco-yunque --partir-en 3
   ```

4. **Revisa** los `salida/paco-yunque/capitulo_NN.json`. Lee el principio y el
   final de cada uno. Siempre queda algo que pulir.

5. **Ejecuta** `salida/paco-yunque/insert.sql` en el SQL Editor. Trae dentro el
   `update` que cuadra `chapter_count` y `minutes_to_read`.

6. **Añade las dinámicas** (una a tres por libro; ver el final de este archivo).

7. **Publica**: `update public.books set is_published = true where id = 'paco-yunque';`

8. **Compruébalo en la app**:

   ```sh
   flutter run --dart-define-from-file=env.json
   ```

Repite por cada obra. Con el conversor ya hecho, cada libro son unos 10 minutos,
casi todos de revisar el texto.

## Si tienes el libro en PDF

Tener la obra en PDF está bien: **el PDF es la fuente, no el formato final.**
Lo que Lira no hace es *renderizar* un PDF al estudiante, porque una maqueta de
papel no reflota en un móvil, no permite medir "capítulo 3 de 8" y no deja
hueco para insertar las dinámicas.

La conversión se hace **una sola vez por libro**, desde tu máquina, con
[`tool/pdf_a_lira.py`](../tool/pdf_a_lira.py):

```sh
pip install pdfplumber   # solo la primera vez

# Un cuento sin capítulos, partido en 3 partes de lectura
python tool/pdf_a_lira.py "El almohadon.pdf" --libro el-almohadon-de-plumas --partir-en 3

# Una novela que sí trae capítulos marcados en el texto
python tool/pdf_a_lira.py novela.pdf --libro aves-sin-nido --patron "CAP[IÍ]TULO"

# Saltando portada, índice y prólogo
python tool/pdf_a_lira.py novela.pdf --libro aves-sin-nido --paginas 7-240
```

Deja en `salida/<libro>/` un `capitulo_NN.json` por capítulo y un `insert.sql`
listo para pegar en el SQL Editor. El SQL incluye al final el `update` que cuadra
`chapter_count` y `minutes_to_read` con lo que acabas de cargar, que es el error
más fácil de cometer a mano.

El script hace el trabajo sucio que tiene un PDF: une las frases que el PDF
parte a lo ancho de la página, recompone las palabras cortadas con guion
(`sol-` + `tarse` → `soltarse`), separa los párrafos midiendo el ancho de
la columna, elimina los números de página y los
encabezados que se repiten en cada hoja, y respeta los diálogos con raya como
párrafos propios.

**Calibra `--corte` en cada libro.** Es el ajuste que mas cambia el resultado:
dice cuanto mas corta que la columna tiene que ser una linea para cerrar
parrafo. Si te pasas, las frases se parten a mitad; si te quedas corto, salen
parrafos larguisimos.

Para elegirlo no hace falta ojo: **un parrafo bien cortado termina en signo de
puntuacion**. Prueba varios valores y quedate con el que menos parrafos deje
sin punto final. En Tom Sawyer el minimo esta en 0.80 (3,5% de fallos, frente
al 8,3% con 0.88) y en John Wesley en 0.78.

**Qué revisar siempre después.** Ninguna extracción de PDF es perfecta:

- Abre un par de `capitulo_NN.json` y lee el principio y el final de cada uno.
- Si la obra no trae capítulos, `--partir-en` corta por número de párrafos, así
  que el corte cae donde toque: muévelo a mano si parte una escena.
- Las notas al pie suelen colarse dentro del párrafo. Bórralas.
- Si el PDF es un **escaneo de imágenes**, no hay texto que extraer: el script
  te avisa. Necesitas pasarle OCR antes (Tesseract, o Acrobat, o subirlo a
  Google Drive y abrirlo con Documentos de Google, que lo hace gratis).

**Sobre derechos:** que tengas el PDF no significa que puedas publicarlo en la
app. Mantén el catálogo en dominio público; para eso están las fuentes de abajo,
que además vienen en texto limpio y te ahorran toda esta conversión.

**¿Y si quieres conservar el PDF original?** Tiene sentido como *adjunto
opcional* —"material de aula" para descargar— no como el lector. Subes el
archivo a Supabase Storage y guardas su ruta en una columna nueva de `books`.
Eso todavía no está implementado; dímelo si lo quieres.

## De dónde sacar los textos

Sólo obras de **dominio público** (autor fallecido hace más de 70 años):

- **Wikisource en español** — https://es.wikisource.org — la mejor fuente para
  literatura hispanoamericana: Valdelomar, Vallejo, Palma, Matto de Turner.
- **Project Gutenberg** — https://www.gutenberg.org — clásicos traducidos y en
  inglés (Poe, Shelley, Wilde).

Descarga el texto plano, córtalo por capítulos y sube cada uno como una fila.

## Insertar un capítulo

```sql
insert into public.chapters (book_id, position, title, body, word_count)
values (
  'paco-yunque',
  0,
  'El salón',
  '[{"type":"p","text":"Primer párrafo…"},
    {"type":"p","text":"Segundo párrafo…"}]'::jsonb,
  412
);
```

Recuerda actualizar `books.chapter_count` con el total, porque de ahí sale el
porcentaje que ve el estudiante:

```sql
update public.books
set chapter_count = (select count(*) from public.chapters where book_id = 'paco-yunque')
where id = 'paco-yunque';
```

## Insertar una dinámica

Regla de oro al escribirlas: si la pregunta tiene una respuesta correcta, no va.
Apunta al lector, nunca al texto.

```sql
insert into public.activities (book_id, chapter_id, kind, prompt, hint)
select 'paco-yunque', id, 'que_harias',
       'Estás en ese patio y lo ves todo. ¿Qué haces tú?', null
from public.chapters
where book_id = 'paco-yunque' and position = 1;
```

`kind` sólo acepta `reflexionar`, `crear` o `que_harias`.

## Mientras tanto

Sin credenciales de Supabase, la app usa el catálogo y los capítulos de muestra
de `lib/features/*/data/sources/`. Ese texto es relleno de desarrollo y sale
marcado con un aviso visible en la propia pantalla — no es la obra original.
