# Configurar Supabase en Lira

Guía completa, de cero a "la app lee de la nube". Al terminar, Lira mostrará el
catálogo y los textos que tú publiques, en vez de las semillas locales.

## Qué hace Supabase en Lira (y qué no, todavía)

| Dato | De dónde sale hoy |
|---|---|
| Catálogo de obras (`books`) | **Supabase**, si hay credenciales |
| Capítulos (`chapters`) | **Supabase**, si hay credenciales |
| Dinámicas (`activities`) | **Supabase**, si hay credenciales |
| Progreso de lectura | Dispositivo (local) |
| Respuestas a dinámicas | Dispositivo (local) |
| Reacción, estrellas y comentario | Dispositivo (local) |

Los tres últimos son locales **a propósito**: sus tablas están protegidas por RLS
contra `auth.uid()` y Lira todavía no tiene login. Ver el último apartado.

Lira lee el contenido de forma **anónima**. No hace falta que el estudiante
tenga cuenta para leer, y eso es deliberado: cuanta menos fricción, mejor.

---

## Paso 1 · Crear el proyecto

1. Entra en <https://supabase.com> y crea una cuenta.
2. **New project**. Elige organización, nombre (`lira`), y una contraseña de
   base de datos — guárdala, aunque para esto no la necesitarás.
3. Región: la más cercana a tus usuarios (para Perú, `South America (São Paulo)`).
4. Espera 1-2 minutos a que termine de aprovisionar.

El plan gratuito sobra para todo el desarrollo y para una prueba en un colegio.

## Paso 2 · Crear las tablas

1. En el panel, barra lateral → **SQL Editor** → **New query**.
2. Abre [`supabase/schema.sql`](schema.sql), copia **todo** el contenido y pégalo.
3. **Run**.

Debe terminar sin errores. Eso crea las ocho tablas, las políticas RLS y mete
tres obras de ejemplo ya publicadas.

Comprueba que fue bien con **Table Editor**: deberías ver `books`, `chapters`,
`activities`, `reading_progress`, `book_reactions`, `book_ratings`,
`activity_responses` y `profiles`.

> El script usa `create table if not exists` y `on conflict do nothing`, así que
> puedes volver a ejecutarlo sin romper nada. Las políticas (`create policy`) sí
> darían error la segunda vez: si lo relanzas, ignora esos errores concretos.

## Paso 3 · Credenciales

> **`env.json` y `env.example.json` son archivos de este proyecto**, en la raíz
> del repo (junto a `pubspec.yaml`). No existen dentro de Supabase ni hay nada
> que descargar del panel: allí sólo copias dos textos y los pegas aquí.

Los dos valores están en **páginas distintas** del panel. Ésta es la parte que
más se atasca:

**1. La clave** → Panel → ⚙ **Project Settings** → **API Keys** → pestaña
*Publishable and secret API keys* → fila **Publishable key**, botón de copiar.
Empieza por `sb_publishable_…`.

- Si tu proyecto es anterior al cambio de nombres de Supabase, usa la pestaña
  *Legacy anon, service_role API keys* y copia la **anon public**. Sirve igual.
- La fila **Secret key** (`sb_secret_…`) que verás justo debajo **no se usa
  aquí**. Nunca la pongas en la app. Ver el apartado de seguridad.

**2. La URL** → **no está en la página de API Keys.** Está en ⚙ **Project
Settings** → **Data API** → *Project URL*.

Atajo infalible: mírala en la barra de direcciones del panel. Si estás en

```
supabase.com/dashboard/project/pridqdgdnuoadzilmegr/settings/api-keys
                               └──── tu project ref ────┘
```

entonces tu URL es `https://pridqdgdnuoadzilmegr.supabase.co`.

**3. Rellena `env.json`** en la raíz del proyecto (si no existe, copia
`env.example.json`):

```json
{
  "SUPABASE_URL": "https://TU-PROJECT-REF.supabase.co",
  "SUPABASE_KEY": "sb_publishable_xxxxxxxxxxxxxxxxxxxx"
}
```

`env.json` ya está en `.gitignore`. **No lo subas al repo.**

> ⚠️ Rellénalo **entero** antes de arrancar. Lira considera que hay backend en
> cuanto los dos campos tienen algo escrito, así que con un valor de ejemplo a
> medias no cae a las semillas locales: intenta conectar, falla, y verás "No
> pudimos abrir la biblioteca".

## Paso 4 · Arrancar y comprobar que de verdad usa la nube

```sh
flutter run --dart-define-from-file=env.json
```

⚠️ **Esto es lo más importante de toda la guía:** si olvidas el flag, la app
arranca igual y muestra el catálogo semilla local. No da ningún error — y es
facilísimo creer que Supabase funciona cuando no se está usando.

Para salir de dudas, haz una prueba que no admita interpretación. En el SQL
Editor:

```sql
insert into public.books
  (id, title, author, synopsis, category, chapter_count, minutes_to_read, is_published)
values
  ('prueba-conexion', 'PRUEBA DE CONEXIÓN', 'Nadie',
   'Si ves esto en la app, estás leyendo de Supabase.', 'cuento', 1, 1, true);
```

Arranca la app con el flag. Si aparece *PRUEBA DE CONEXIÓN* en la biblioteca,
está conectado. Luego bórralo:

```sql
delete from public.books where id = 'prueba-conexion';
```

Otra señal rápida: el catálogo local tiene **11 obras**; el que crea el esquema
tiene **3**. Si ves 11, estás en local.

## Paso 5 · Cargar tu contenido

El detalle está en [`contenido.md`](contenido.md). Resumen de lo que la app
espera, porque un nombre de columna mal escrito se traduce en pantalla vacía:

**`books`** — la app pide `is_published = true` y ordena por `title`.

| Columna | Notas |
|---|---|
| `id` | slug legible: `paco-yunque`. Es la clave que usan capítulos y rutas |
| `category` | sólo `cuento`, `novela`, `poesia`, `teatro` (sin tilde en poesia) |
| `chapter_count` | **debe coincidir** con el número real de capítulos |
| `minutes_to_read` | se muestra en la portada; ≤ 20 marca la obra como corta |
| `tags` | `text[]`, p. ej. `'{Perú,Colegio}'` |
| `cover_url` | opcional; si es nulo, Lira dibuja la portada |

**`chapters`** — `position` empieza en **0**. El cuerpo va en `body` (jsonb) como
lista de bloques (`p`, `h`, `quote`, `note`, `hr`).

**`activities`** — `kind` sólo acepta `reflexionar`, `crear`, `que_harias`, y
`chapter_id` debe apuntar a un capítulo real: una dinámica sin capítulo válido
simplemente no se ofrece nunca.

Si `chapter_count` no cuadra con los capítulos reales, el porcentaje de la
biblioteca y el del lector se contradicen. Después de cargar capítulos:

```sql
update public.books b
set chapter_count = (select count(*) from public.chapters c where c.book_id = b.id)
where exists (select 1 from public.chapters c where c.book_id = b.id);
```

## Compilar para publicar

Las credenciales se inyectan **en tiempo de compilación**. Si construyes la APK
sin el flag, se publica sin credenciales y los estudiantes verán el catálogo
semilla:

```sh
flutter build apk --release --dart-define-from-file=env.json
flutter build appbundle --release --dart-define-from-file=env.json
```

El permiso de INTERNET ya está en `android/app/src/main/AndroidManifest.xml`
(Flutter sólo lo pone en debug y profile por defecto).

## Si algo no sale

| Síntoma | Causa más probable |
|---|---|
| La biblioteca muestra 11 obras que tú no cargaste | Falta `--dart-define-from-file=env.json` |
| La biblioteca sale vacía | `is_published` en `false`, o no ejecutaste las políticas RLS |
| Una obra abre con "Todavía no cargamos este texto" | No hay filas en `chapters` para ese `book_id` |
| "No pudimos abrir la biblioteca" | URL o clave mal copiadas, o sin conexión |
| Nunca aparece la invitación a actividad | `activities.chapter_id` no coincide con ningún capítulo |
| En release no conecta, en debug sí | Compilaste el release sin el flag de credenciales |

Para ver qué responde el servidor de verdad, el panel tiene **Logs → API**.

## Seguridad

La clave publicable (o `anon`) **está pensada para vivir en el cliente**: va
dentro de la app y cualquiera puede extraerla. Lo que protege los datos no es la
clave, son las políticas RLS del esquema — por eso el contenido publicado se
puede leer y los datos de cada estudiante no.

La clave **`service_role`** salta todas las políticas. Nunca la pongas en la
app, ni en `env.json`, ni en el repo. Es sólo para scripts de administración que
corras tú desde tu máquina.

## Lo que falta: sincronizar el progreso

Hoy el progreso y las opiniones viven sólo en el dispositivo. Para que un
estudiante pueda cambiar de teléfono sin perder su avance hace falta **auth**:

1. Activar un proveedor en **Authentication → Providers** (email, o Google).
2. Añadir el flujo de sesión en la app.
3. Sustituir `LocalReadingProgressRepository`, `LocalActivityResponseRepository`
   y `LocalBookFeedbackRepository` por implementaciones de Supabase.

El JSON que guardan en local ya usa los mismos nombres que las columnas, así que
ese último paso es traducción directa, no rediseño.
