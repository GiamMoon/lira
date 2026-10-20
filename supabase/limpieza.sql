-- ===================================================================
--  Puesta a punto del catálogo de Lira
--  Pégalo entero en el SQL Editor de Supabase y pulsa Run.
--
--  Hace tres cosas:
--    1. Añade la categoría 'biografia' (la serie Héroes Cristianos son
--       biografías, no novelas).
--    2. Borra las tres obras de ejemplo que trajo el esquema inicial.
--    3. Deja John Wesley clasificado como biografía.
--
--  Ejecútalo ANTES de cargar los libros, o después: funciona igual.
-- ===================================================================

-- 1) La categoría nueva -----------------------------------------------
-- El check hay que recrearlo: Postgres no permite ampliarlo en sitio.
alter table public.books
  drop constraint if exists books_category_check;

alter table public.books
  add constraint books_category_check
  check (category in ('cuento', 'novela', 'biografia', 'poesia', 'teatro'));


-- 2) Fuera las obras de ejemplo ---------------------------------------
-- Los capítulos, dinámicas y progreso asociados caen solos por la clave
-- foránea (on delete cascade), así que basta con borrar el libro.
delete from public.books
where id in (
  'el-caballero-carmelo',
  'paco-yunque',
  'el-almohadon-de-plumas'
);


-- 3) Wesley es una biografía ------------------------------------------
-- No falla si todavía no lo has cargado: simplemente no afecta a nada.
update public.books
set category = 'biografia'
where id = 'john-wesley';


-- Comprobación: aquí deberían quedar solo tus libros.
select id, title, author, category, chapter_count, is_published
from public.books
order by title;
