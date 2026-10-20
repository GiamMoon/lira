-- La primerísima línea de Tom Sawyer.
--
-- El PDF de origen perdió la apertura de exclamación: dejaba "—Tom!" donde el
-- original dice "—¡Tom!". Es la primera frase que lee un estudiante, así que
-- vale la pena.
--
-- La condición del final hace la migración idempotente: si ya está corregida,
-- no toca nada.
update public.chapters
set body = jsonb_set(body, '{0,text}', '"—¡Tom!"'::jsonb)
where book_id = 'las-aventuras-de-tom-sawyer'
  and position = 0
  and body -> 0 ->> 'text' = '—Tom!';
