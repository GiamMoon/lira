-- ============================================================================
--  Lira — esquema de base de datos (Supabase / PostgreSQL)
-- ============================================================================
--  Cómo aplicarlo:
--    1. Crea el proyecto en supabase.com
--    2. SQL Editor → pega este archivo → Run
--    3. Copia Project URL y anon key a tu env.json (ver README)
--
--  Principio de diseño: el CONTENIDO es público y cacheable; lo que produce el
--  estudiante (progreso, reacciones, creaciones) es privado y suyo. Eso es lo
--  que separan las políticas RLS del final.
-- ============================================================================

-- ─── Perfiles ───────────────────────────────────────────────────────────────
-- Extiende auth.users con lo que Lira necesita mostrar.
create table if not exists public.profiles (
  id          uuid primary key references auth.users on delete cascade,
  display_name text not null default 'Lector',
  grade        text,
  created_at   timestamptz not null default now()
);

-- ─── Catálogo ───────────────────────────────────────────────────────────────
create table if not exists public.books (
  id              text primary key,              -- slug legible: 'paco-yunque'
  title           text not null,
  author          text not null,
  synopsis        text not null default '',
  category        text not null check (category in ('cuento','novela','biografia','poesia','teatro')),
  chapter_count   integer not null default 0,
  minutes_to_read integer not null default 0,
  cover_url       text,
  tags            text[] not null default '{}',
  is_published    boolean not null default false,
  created_at      timestamptz not null default now()
);

create index if not exists books_category_idx on public.books (category);

-- ─── Capítulos ──────────────────────────────────────────────────────────────
-- El texto vive estructurado, NO en PDF: así se puede reflotar en pantallas
-- pequeñas, medir progreso real e insertar dinámicas entre bloques.
--   body = array de bloques: [{"type":"p","text":"…"}, {"type":"quote", …}]
create table if not exists public.chapters (
  id          uuid primary key default gen_random_uuid(),
  book_id     text not null references public.books on delete cascade,
  position    integer not null,
  title       text not null default '',
  body        jsonb not null default '[]'::jsonb,
  word_count  integer not null default 0,
  unique (book_id, position)
);

create index if not exists chapters_book_idx on public.chapters (book_id, position);

-- ─── Dinámicas ──────────────────────────────────────────────────────────────
-- Actividades ancladas al final de un capítulo. Nunca obligatorias y sin
-- respuesta correcta: 'kind' define el tono, no un tipo de examen.
create table if not exists public.activities (
  id          uuid primary key default gen_random_uuid(),
  book_id     text not null references public.books on delete cascade,
  chapter_id  uuid references public.chapters on delete cascade,
  kind        text not null check (kind in ('reflexionar','crear','que_harias')),
  prompt      text not null,
  hint        text,
  created_at  timestamptz not null default now()
);

-- ─── Progreso de lectura ────────────────────────────────────────────────────
create table if not exists public.reading_progress (
  user_id       uuid not null references auth.users on delete cascade,
  book_id       text not null references public.books on delete cascade,
  chapters_read integer not null default 0,
  chapter_count integer not null default 0,
  status        text not null default 'reading'
                check (status in ('reading','finished','abandoned')),
  updated_at    timestamptz not null default now(),
  primary key (user_id, book_id)
);

-- ─── Cierre de una obra: reacción + calificación ────────────────────────────
-- Varias reacciones por libro (el brief pide multi-selección).
create table if not exists public.book_reactions (
  user_id    uuid not null references auth.users on delete cascade,
  book_id    text not null references public.books on delete cascade,
  reaction   text not null check (reaction in ('sorpresa','pena','molestia','pensativo','gusto')),
  created_at timestamptz not null default now(),
  primary key (user_id, book_id, reaction)
);

create table if not exists public.book_ratings (
  user_id    uuid not null references auth.users on delete cascade,
  book_id    text not null references public.books on delete cascade,
  stars      smallint not null check (stars between 1 and 5),
  comment    text,                                  -- opcional, siempre
  created_at timestamptz not null default now(),
  primary key (user_id, book_id)
);

-- ─── Respuestas a las dinámicas ─────────────────────────────────────────────
-- Lo que el estudiante crea. Privado por defecto; 'is_shared' es lo que un día
-- alimentará el muro de creaciones del colegio.
create table if not exists public.activity_responses (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users on delete cascade,
  activity_id uuid not null references public.activities on delete cascade,
  content     text not null default '',
  media_path  text,                                 -- objeto en Storage
  is_shared   boolean not null default false,
  created_at  timestamptz not null default now()
);

-- ============================================================================
--  Row Level Security
-- ============================================================================
alter table public.profiles            enable row level security;
alter table public.books               enable row level security;
alter table public.chapters            enable row level security;
alter table public.activities          enable row level security;
alter table public.reading_progress    enable row level security;
alter table public.book_reactions      enable row level security;
alter table public.book_ratings        enable row level security;
alter table public.activity_responses  enable row level security;

-- Contenido publicado: lectura para cualquiera (incluso anónimo).
create policy "catalogo publicado visible" on public.books
  for select using (is_published);

create policy "capitulos de libros publicados" on public.chapters
  for select using (
    exists (select 1 from public.books b where b.id = book_id and b.is_published)
  );

create policy "dinamicas de libros publicados" on public.activities
  for select using (
    exists (select 1 from public.books b where b.id = book_id and b.is_published)
  );

-- Datos del estudiante: sólo suyos, para leer y escribir.
create policy "mi perfil" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "mi progreso" on public.reading_progress
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "mis reacciones" on public.book_reactions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "mis calificaciones" on public.book_ratings
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "mis creaciones" on public.activity_responses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Creaciones compartidas: visibles para cualquier usuario autenticado.
create policy "creaciones compartidas" on public.activity_responses
  for select using (is_shared and auth.role() = 'authenticated');
