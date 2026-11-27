begin;
create extension if not exists pgtap with schema extensions;

-- helpers: entrar como um usuario e voltar para o dono do banco
create function pg_temp.logar(usuario uuid) returns void
language sql as $$
  select set_config(
    'request.jwt.claims',
    json_build_object('sub', usuario, 'role', 'authenticated')::text,
    true
  );
  select set_config('role', 'authenticated', true);
$$;

-- cenario: mestre (M) com a campanha K; Ana (A) e Bia (B) jogam em K
-- Caio (C) nao e da mesa e mestra a K2
-- M aaaa...01  A aaaa...02  B aaaa...03  C aaaa...04
insert into auth.users (id, email, raw_user_meta_data) values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'mestre@teste.dev', '{"nome": "Mestre"}'),
  ('aaaaaaaa-0000-4000-8000-000000000002', 'ana@teste.dev', '{"nome": "Ana"}'),
  ('aaaaaaaa-0000-4000-8000-000000000003', 'bia@teste.dev', '{"nome": "Bia"}'),
  ('aaaaaaaa-0000-4000-8000-000000000004', 'caio@teste.dev', '{"nome": "Caio"}');

-- K bbbb...01 (do mestre)  K2 bbbb...02 (do caio)
insert into public.campanhas (id, mestre_id, nome) values
  ('bbbbbbbb-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000001', 'Mesa do Mestre'),
  ('bbbbbbbb-0000-4000-8000-000000000002', 'aaaaaaaa-0000-4000-8000-000000000004', 'Mesa do Caio');

-- thorin (ana, em K) cccc...01  lyra (bia, em K) cccc...02
-- reserva (ana, sem campanha) cccc...03  solo (caio, sem campanha) cccc...04
insert into public.personagens (id, dono_id, campanha_id, nome, retrato, especie, xp) values
  ('cccccccc-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000002', 'bbbbbbbb-0000-4000-8000-000000000001', 'Thorin', 'r', 'Anão', 1000),
  ('cccccccc-0000-4000-8000-000000000002', 'aaaaaaaa-0000-4000-8000-000000000003', 'bbbbbbbb-0000-4000-8000-000000000001', 'Lyra', 'r', 'Elfa', 500),
  ('cccccccc-0000-4000-8000-000000000003', 'aaaaaaaa-0000-4000-8000-000000000002', null, 'Reserva', 'r', 'Humano', 0),
  ('cccccccc-0000-4000-8000-000000000004', 'aaaaaaaa-0000-4000-8000-000000000004', null, 'Solo', 'r', 'Humano', 0);

-- missao revelada dddd...01 (300 xp + pocao) e oculta dddd...02
insert into public.missoes (id, campanha_id, titulo, revelada, recompensa_xp, recompensa_itens) values
  ('dddddddd-0000-4000-8000-000000000001', 'bbbbbbbb-0000-4000-8000-000000000001', 'Missão revelada', true, 300, '{pocao}'),
  ('dddddddd-0000-4000-8000-000000000002', 'bbbbbbbb-0000-4000-8000-000000000001', 'Missão oculta', false, 0, '{}');

-- entrada revelada eeee...01 e oculta eeee...02 na missao revelada
-- entrada revelada eeee...03 na missao oculta
insert into public.entradas_missao (id, missao_id, campanha_id, texto, revelada) values
  ('eeeeeeee-0000-4000-8000-000000000001', 'dddddddd-0000-4000-8000-000000000001', null, 'Pista aberta', true),
  ('eeeeeeee-0000-4000-8000-000000000002', 'dddddddd-0000-4000-8000-000000000001', null, 'Pista escondida', false),
  ('eeeeeeee-0000-4000-8000-000000000003', 'dddddddd-0000-4000-8000-000000000002', null, 'Pista da oculta', true);

-- npc revelado ffff...01 e oculto ffff...02
insert into public.npcs (id, campanha_id, nome, revelado) values
  ('ffffffff-0000-4000-8000-000000000001', 'bbbbbbbb-0000-4000-8000-000000000001', 'Bram', true),
  ('ffffffff-0000-4000-8000-000000000002', 'bbbbbbbb-0000-4000-8000-000000000001', 'Ilsa', false);

select plan(19);

-- ana (heroina de K)
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');

select set_eq(
  $$ select titulo from public.missoes $$,
  $$ values ('Missão revelada') $$,
  'heroi nao ve missao oculta'
);
select set_eq(
  $$ select texto from public.entradas_missao $$,
  $$ values ('Pista aberta') $$,
  'heroi nao ve entrada oculta nem entrada de missao oculta'
);
select set_eq(
  $$ select nome from public.npcs $$,
  $$ values ('Bram') $$,
  'heroi nao ve npc oculto'
);
select set_eq(
  $$ select nome from public.campanhas $$,
  $$ values ('Mesa do Mestre') $$,
  'heroi ve so a campanha dele'
);
select set_eq(
  $$ select nome from public.personagens $$,
  $$ values ('Thorin'), ('Lyra'), ('Reserva') $$,
  'heroi ve os proprios herois e os da mesa'
);
select set_eq(
  $$ select nome from public.perfis $$,
  $$ values ('Ana'), ('Bia'), ('Mestre') $$,
  'heroi ve o perfil de quem divide a mesa'
);

-- mestre ve tudo da campanha dele
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');

select is((select count(*)::int from public.missoes), 2, 'mestre ve todas as missoes');
select is((select count(*)::int from public.entradas_missao), 3, 'mestre ve todas as entradas');
select is((select count(*)::int from public.npcs), 2, 'mestre ve todos os npcs');
select is(
  (select count(*)::int from public.personagens where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001'),
  2,
  'mestre ve os herois da mesa'
);

-- caio nao e da mesa
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000004');

select is_empty(
  $$ select 1 from public.campanhas where id = 'bbbbbbbb-0000-4000-8000-000000000001' $$,
  'quem nao e da mesa nao ve a campanha'
);
select is_empty($$ select 1 from public.missoes $$, 'nem as missoes');
select is_empty($$ select 1 from public.entradas_missao $$, 'nem as entradas');
select is_empty($$ select 1 from public.npcs $$, 'nem os npcs');
select is_empty($$ select 1 from public.sessoes $$, 'nem as sessoes');
select is_empty($$ select 1 from public.registros_mesa $$, 'nem os registros');
select set_eq(
  $$ select nome from public.personagens $$,
  $$ values ('Solo') $$,
  'nem os herois da mesa'
);
select set_eq(
  $$ select nome from public.perfis $$,
  $$ values ('Caio') $$,
  'nem os perfis da mesa'
);

-- revelar a missao libera so as entradas reveladas dela
reset role;
update public.missoes set revelada = true where id = 'dddddddd-0000-4000-8000-000000000002';
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select set_eq(
  $$ select texto from public.entradas_missao $$,
  $$ values ('Pista aberta'), ('Pista da oculta') $$,
  'revelar a missao mostra as entradas reveladas dela'
);

select * from finish();
rollback;
