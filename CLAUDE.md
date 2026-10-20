# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Lira es una app Flutter de biblioteca digital para estudiantes de secundaria. El código y los comentarios están en español; mantén ese idioma al escribir código nuevo.

## Comandos

```sh
# Ejecutar (sin credenciales arranca contra las semillas locales)
flutter run -d chrome
flutter run --dart-define-from-file=env.json   # con Supabase

# Generación de código — OBLIGATORIA tras tocar cualquier @riverpod o @JsonSerializable
dart run build_runner build
dart run build_runner watch   # durante sesiones largas

flutter analyze
flutter test
flutter test test/features/library/library_view_model_test.dart
flutter test --plain-name "dejar un libro conserva el avance"
```

`build_runner` no es opcional: los providers (`libraryViewModelProvider`, `bookRepositoryProvider`, …) y los `fromJson` sólo existen en los `.g.dart`. Si aparecen decenas de errores "Undefined name '…Provider'", falta generar, no falta código.

`flutter analyze` siempre reporta un aviso de Dart sobre el sistema de plugins del analizador (por `custom_lint` en `analysis_options.yaml`). Es de la plataforma; el objetivo es cero problemas *aparte* de ese.

## Arquitectura

MVVM por feature. Cada una en `lib/features/<feature>/`:

- `domain/` — entidades e **interfaces** de repositorio. Sin Flutter, sin Supabase, sin JSON.
- `data/` — DTOs, semillas locales e implementaciones de esas interfaces, más un fichero `*_providers.dart` con la DI de la feature.
- `presentation/` — `view/` (widgets), `view_model/` (estado inmutable + ViewModel Riverpod), `widgets/`.

`lib/core/` es transversal (theme, storage, config, network, di, widgets) y `lib/app/` monta el router y el shell.

**Regla que sostiene todo lo demás:** los ViewModels dependen de interfaces de `domain/`, nunca de plugins ni del cliente de Supabase. Por eso los tests corren en milisegundos sin emulador ni red, inyectando dobles con `overrideWithValue`.

### El interruptor de backend

Sólo dos ficheros saben si existe backend: `features/library/data/library_providers.dart` y `features/reader/data/reader_providers.dart`. Ambos hacen lo mismo:

```dart
AppConfig.hasRemoteBackend ? SupabaseXRepository(...) : const SeedXRepository()
```

Sin `env.json` la app funciona entera contra semillas locales (`data/sources/*_seed.dart`). No añadas condicionales de backend en ningún otro sitio.

Credenciales por `--dart-define-from-file=env.json` (ignorado en git; plantilla en `env.example.json`). Puesta en marcha paso a paso en `supabase/README.md`, esquema SQL en `supabase/schema.sql`, y cómo cargar textos reales en `supabase/contenido.md`.

Las credenciales se inyectan **en tiempo de compilación**: una APK construida sin el flag se publica con las semillas locales dentro y sin ningún error visible. Vale también para `flutter build apk/appbundle --release`, no sólo para `run`.

### Inyección de dependencias

`sharedPreferencesProvider` (en `core/di/core_providers.dart`) lanza `UnimplementedError` y se sobreescribe en `main()` con `overrideWithValue`. Es la única raíz de composición: todo lo asíncrono se resuelve antes de `runApp` y el árbol de widgets nunca espera un `Future`.

### Contenido de los libros

El texto **no es PDF**: cada capítulo es una lista de bloques (`p`, `v`, `h`, `quote`, `note`, `hr`) en `chapters.body` (jsonb). Eso permite reflotar en móvil, medir progreso por capítulos e insertar dinámicas entre bloques. Un `type` desconocido degrada a párrafo en vez de romper la lectura.

`NoteBlock` es un aviso **de Lira**, nunca texto del autor, y se pinta distinto a propósito.

`VerseBlock` (`v`) es una **estrofa entera**, con los versos separados por `
` dentro del mismo bloque. No es un párrafo: un poema reflotado deja de ser el poema. Los versos de una estrofa viajan juntos para que el espacio entre estrofas se distinga del espacio entre versos.

Las semillas locales (`data/sources/*_seed.dart`) son el respaldo sin `env.json` y llevan **texto auténtico de dominio público** (capítulo 1 de *Tom Sawyer*). Nunca inventes prosa y la atribuyas a un autor: si falta texto, deja la obra sin capítulos y el lector mostrará "Todavía no cargamos este texto". El texto con licencia (la serie Héroes Cristianos) va sólo a Supabase, nunca al repo.

### La cadena de conversión

`tool/pdf_a_lira.py` convierte **un** PDF o TXT. `tool/lote_pdfs.py` convierte **el catálogo entero** y escribe una sola migración:

```sh
python tool/lote_pdfs.py --informe          # analiza y resume, sin escribir
python tool/lote_pdfs.py --solo hamlet      # sólo ese libro
python tool/lote_pdfs.py                    # escribe supabase/migrations/<fecha>_…sql
```

Qué PDF es qué obra está en **`tool/catalogo.py`** (id, título, autor real, categoría, sinopsis, archivos, páginas a saltar). Ahí también está la lista `DESCARTADOS`, con el motivo de cada PDF que no entra: está escrita a propósito para que nadie vuelva a intentarlo.

El lote decide solo dos cosas que antes se calibraban a mano:

- **El `--corte`.** Se barre de 0.50 a 0.94 midiendo qué porcentaje de párrafos no cierra en signo de puntuación, y se coge la **rodilla**, no el mínimo: cuanto más bajo el umbral, menos líneas cierran párrafo, así que con 0.50 el libro se funde en cuatro bloques enormes que —por enormes— terminan todos en punto. El error sale precioso y el texto es ilegible. La regla es el umbral **más alto** que siga a menos de un punto del mínimo.
- **Si el libro entra.** Un OCR roto no da error: da texto que parece texto. Se mide la proporción de palabras imposibles en castellano (caracteres que no existen dentro de una palabra, cuatro consonantes seguidas, mayúscula en medio) y por debajo de `NOTA_MINIMA` el libro se queda fuera diciendo por qué. Un PDF digital sano ronda 0.999; el escaneo destrozado de *Trilce*, 0.93.

**Los caracteres de control se quitan siempre**, y no es cosmética: el `jsonb` de Postgres rechaza `\u0000` con *"unsupported Unicode escape sequence"*, así que un solo carácter de esos tumba la migración entera —y lo hace a mitad de la carga, en el capítulo 146 de 1177—. Un PDF los suelta cuando la fuente no trae tabla Unicode: los glifos se ven perfectos en pantalla y al extraerlos salen como `\x00`. `quitar_controles` tira la línea si ha perdido más del 40% (era un encabezado en versalitas, y reconstruirlo sería inventarlo) y marca con `…` los huecos más pequeños, porque decir que ahí faltaba algo es más honrado que cerrar el hueco como si nada. `sql_de_libro` revienta si alguno sobrevive hasta el final.

**El verso no pasa por ahí.** La lógica de ancho de línea es justo lo contrario de lo que hace falta en poesía, donde todas las líneas son cortas. Los libros con `verso=True` (toda la poesía, más las comedias del Siglo de Oro) se agrupan por estrofas y se cortan **por poema**, no por número de palabras. En teatro en verso el corte es la escena: si se cortara por encabezado, cada nombre de personaje abriría capítulo.

Las dinámicas las pone `tool/dinamicas.py`, con un banco por tipo de obra —narrativa, poesía, teatro— porque «¿qué habrías hecho tú en su lugar?» no significa nada después de un soneto. La elección es determinista: el mismo libro y capítulo dan siempre la misma consigna.

`tool/wikisource_a_txt.py` baja obras de dominio público.

### Navegación y persistencia

Rutas tipadas en el enum `AppRoute`; nunca escribas paths a mano. El cierre sustituye al lector en la pila (`pushReplacementNamed`), así que al terminar un libro se vuelve a la biblioteca, no al último capítulo. La biblioteca refresca su ViewModel al volver del lector, porque el lector escribe el progreso directamente en el repositorio.

La app abre una **sesión anónima** al arrancar (`core/network/supabase_session.dart`, llamada desde `main`). Sin ella las tablas del estudiante son inalcanzables: todas están protegidas por RLS contra `auth.uid()`. Se eligió anónima porque pedirle a un estudiante que se registre para leer un cuento es justo la fricción que Lira quita; el precio es que la sesión vive en ese dispositivo. Si falla —proveedor desactivado, sin red— la app sigue: todo se queda en local.

**El progreso se guarda en los dos sitios.** `SyncedReadingProgressRepository` envuelve el local y el remoto con dos reglas: el dispositivo nunca falla (se escribe ahí primero, siempre), y al leer gana la versión con `updatedAt` más reciente, copiando a cada lado lo que le falte. Eso hace que el avance guardado antes de haber sesión suba solo la primera vez que hay conexión.

Lo mismo vale para las **respuestas a dinámicas** (`SyncedActivityResponseRepository`) y las **opiniones de cierre** (`SyncedBookFeedbackRepository`). Los tres decoradores siguen el mismo patrón, así que si añades otra cosa que el estudiante genere, cópialo: local + remoto, local manda cuando algo falla, gana la fecha más reciente.

Las opiniones viven en dos tablas porque son dos cosas: `book_ratings` (una fila por libro, estrellas y comentario **los dos opcionales**) y `book_reactions` (una fila por emoji, porque se marcan varios). Al guardar, las reacciones se reescriben enteras: es una lista corta y así se refleja igual lo que quitó que lo que añadió.

## Reglas de producto que el código debe respetar

No son preferencias de estilo: son la razón de ser de la app y hay tests que las vigilan.

- **Nada obligatorio.** Ningún cuestionario de comprensión lectora. Las dinámicas son opcionales, cortas y **sin respuesta correcta**; "Seguir leyendo" tiene el mismo peso visual que las demás opciones.
- **Dejar un libro nunca borra el avance**, sólo lo saca de "leyendo" (`ReadingStatus.abandoned`).
- **Volver atrás no reduce el progreso guardado**: releer no es desleer.
- **Al cerrar una obra todo es opcional**: se puede terminar sólo con estrellas, sólo con una reacción, o sin decir nada. Por eso `stars` y `comment` son nullables.
- Lo que el estudiante crea es suyo y no sale de su dispositivo.

## Diseño

Colores, tipografía, espaciado, radios y duraciones viven en `lib/core/theme/` (`AppColors`, `AppTypography`, `Insets`, `Radii`, `Motion`). Ningún widget declara un `Color(0x…)` ni un número mágico propio: si un token no existe, se añade ahí.

Marca: crema `#F8EEDB`, vino `#6B2639`. El splash se muestra siempre en paleta clara aunque el dispositivo esté en oscuro.

El repertorio de movimiento vive en `lib/core/widgets/` y se reutiliza, no se reinventa: `GlassSurface` (el "liquid glass"), `Pressable` (hundido + háptico al tocar), `StaggeredEntrance` (entrada en cascada por índice) y `AnimatedProgressBar` (el progreso viaja hasta su valor en vez de aparecer lleno).

`StaggeredEntrance` y `AnimatedProgressBar` consultan `MediaQuery.disableAnimationsOf`: cualquier animación nueva debe respetar igual la preferencia de accesibilidad "reducir movimiento".

**Menús, diálogos, hojas y avisos toman el color del tema**, nunca de `AppColors` a mano: fijarlos en crema dejaba texto claro sobre fondo claro —un rectángulo blanco ilegible— cuando el móvil está en oscuro. Están centralizados en `AppTheme` (`popupMenuTheme`, `dialogTheme`, `bottomSheetTheme`, `snackBarTheme`). Los cremas que sí son correctos van **sobre vino**: portadas, la tarjeta de "Sigue donde lo dejaste" y los chips seleccionados.

En la rejilla de la biblioteca la portada **no va dentro de un `Expanded`**: si lo está, un título de dos líneas le roba alto y esa portada sale más pequeña que la de al lado. Manda siempre su proporción 2:3, y el bloque de texto tiene alto fijo.

El progreso se pinta con `ReadingProgress.fractionOf(book.chapterCount)`, no con `.fraction`: el total guardado es el que había al guardar el avance, y el catálogo cambia (un libro de 1 capítulo que pasa a 96 marcaría 100% para siempre).

El lector guarda el tamaño de letra elegido (`ReaderSettings` + `StorageKeys.readerTextSize`): quien necesita letra grande la necesita siempre, no por libro.

### Personalización

`features/settings/` guarda lo que el estudiante decide sobre la app: modo de tema, letra de lectura y cómo quiere que le llamen (`Preferences` + `AppPreferences`). Vive en el dispositivo y **no sube a Supabase**: es una preferencia, no un dato de la cuenta.

- El **tema elegido manda sobre el del sistema** (`themeMode` en `LiraApp`). Quien lee de noche quiere oscuro aunque el móvil siga en claro. El cambio se funde con `themeAnimationDuration`, no salta.
- Las **tres letras de lectura** viven en `AppTypography` (`readingSerif`, `readingSans`, `readingLegible`); `ReadingFont` sólo elige cuál. La tercera es Atkinson Hyperlegible, diseñada para baja visión: no es una variante decorativa de las otras dos, y el test lo vigila.
- El **nombre es opcional y se puede borrar**. Vacío = saludo a secas; nunca se inventa uno.
- `ChapterContent` recibe el `TextStyle` ya resuelto. No sabe de ajustes, y por eso se sigue pudiendo probar sin providers.

### Gestos

- **Deslizar a los lados en el lector** cambia de capítulo (`SwipeNavigator`, en `core/widgets/`). Es un atajo: el botón sigue estando. Sólo cuenta un gesto rápido y con recorrido, porque con un umbral flojo cualquier arrastre en diagonal mientras se lee cambiaba de capítulo.
- La página nueva entra **por el lado que corresponde al sentido**: si entrara siempre por la derecha, volver atrás se sentiría como seguir avanzando.
- **Mantener pulsado un libro** en la estantería lo abre directo, sin pasar por la ficha (`Pressable.onLongPress`, con háptico más firme que el del toque).

## Trampas de API ya encontradas

Riverpod 3.1 / supabase_flutter 2.17 — no las reintroduzcas:

- No existe `notifier.stream`; en tests se observa con `container.listen`.
- No existe `AsyncValue.valueOrNull`: es `.value` (nullable) o `.requireValue`.
- Los providers de función reciben `Ref` a secas, no `XxxRef`.
- **`.order('columna')` de postgrest-dart ordena DESCENDENTE por defecto** (`bool ascending = false`). Sin `ascending: true` el libro se lee del último capítulo al primero y el catálogo sale de la Z a la A. No da error: simplemente todo está al revés.
- `Supabase.initialize(anonKey:)` está deprecado → `publishableKey:` (no valida formato, acepta también claves anon legacy).
- Para probar un `build` que **falla**: no uses `container.read(provider.future)` — el provider se queda colgado en `loading` y el future no resuelve nunca. Sostén un `container.listen`, `await pumpEventQueue()` y comprueba `container.read(provider).error`. Para un build que tiene éxito, `.future` va bien.
