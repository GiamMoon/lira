-- Lo que hace falta para que las creaciones y las opiniones vivan en la nube.

-- 1) Una respuesta por dinámica y por estudiante -----------------------------
-- Sin índice único, el `upsert` no tiene contra qué resolver el conflicto y
-- cada vez que el estudiante editara su texto crearía una fila nueva.
-- Primero se limpian los duplicados que pudiera haber.
delete from public.activity_responses a
using public.activity_responses b
where a.user_id = b.user_id
  and a.activity_id = b.activity_id
  and a.ctid < b.ctid;

create unique index if not exists activity_responses_usuario_dinamica
  on public.activity_responses (user_id, activity_id);


-- 2) Las estrellas son opcionales --------------------------------------------
-- Regla de producto: se puede terminar un libro sólo con una reacción, sólo
-- con estrellas, o escribiendo un comentario sin calificar. El esquema las
-- exigía, así que un comentario sin estrellas no se podía guardar.
-- El `check (stars between 1 and 5)` sigue valiendo: un NULL no lo incumple.
alter table public.book_ratings
  alter column stars drop not null;


-- Comprobación.
select
  (select count(*) from public.reading_progress)    as progreso,
  (select count(*) from public.activity_responses)  as creaciones,
  (select count(*) from public.book_ratings)        as calificaciones,
  (select count(*) from public.book_reactions)      as reacciones;
