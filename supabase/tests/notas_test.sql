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

select plan(9);

reset role;
insert into public.notas_heroi (personagem_id, dono_id, titulo, texto)
values ('cccccccc-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000002', 'Diário', 'Segredo da Ana');
update public.notas_mestre set texto = 'Plano do mestre' where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001';

-- heroi
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select is_empty($$ select 1 from public.notas_mestre $$, 'heroi nao le notas_mestre');
select is(
  (select texto from public.notas_heroi),
  'Segredo da Ana',
  'dono le o proprio diario'
);
update public.notas_mestre set texto = 'hackeado';
select lives_ok(
  $$ insert into public.notas_heroi (personagem_id, titulo, texto)
     values ('cccccccc-0000-4000-8000-000000000003', 't', 'x') $$,
  'dono escreve no diario do proprio heroi'
);
select throws_ok(
  $$ insert into public.notas_heroi (personagem_id, titulo, texto)
     values ('cccccccc-0000-4000-8000-000000000002', 't', 'x') $$,
  '42501',
  null,
  'ninguem escreve no diario do heroi de outro'
);

-- outra heroina da mesa
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000003');
select is_empty($$ select 1 from public.notas_heroi $$, 'outro heroi nao le o diario');

-- mestre
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');
select is_empty($$ select 1 from public.notas_heroi $$, 'mestre nao le notas_heroi');
select is(
  (select texto from public.notas_mestre where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001'),
  'Plano do mestre',
  'mestre le as proprias notas e o heroi nao mudou nada'
);
update public.notas_mestre set texto = 'Plano novo' where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001';
select is(
  (select texto from public.notas_mestre where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001'),
  'Plano novo',
  'mestre edita as notas'
);

-- notas nascem com a campanha
reset role;
select is(
  (select count(*)::int from public.notas_mestre where campanha_id in ('bbbbbbbb-0000-4000-8000-000000000001', 'bbbbbbbb-0000-4000-8000-000000000002')),
  2,
  'cada campanha nasce com as notas do mestre'
);

select * from finish();
rollback;
