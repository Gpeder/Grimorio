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

select plan(10);

reset role;
update public.campanhas set codigo_convite = 'MESA-1234' where id = 'bbbbbbbb-0000-4000-8000-000000000001';
update public.campanhas set codigo_convite = 'CAIO-5678' where id = 'bbbbbbbb-0000-4000-8000-000000000002';

-- caio entra na mesa do mestre com o solo
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000004');
select is(
  public.entrar_campanha('  mesa-1234 ', 'cccccccc-0000-4000-8000-000000000004'),
  'bbbbbbbb-0000-4000-8000-000000000001'::uuid,
  'codigo certo entra, sem diferenciar maiuscula e com trim'
);
select is(
  (select campanha_id from public.personagens where id = 'cccccccc-0000-4000-8000-000000000004'),
  'bbbbbbbb-0000-4000-8000-000000000001'::uuid,
  'heroi ficou na campanha'
);
select is(
  (select count(*)::int from public.missoes),
  1,
  'depois de entrar ve as missoes reveladas'
);

-- erros
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select throws_ok(
  $$ select public.entrar_campanha('ERRADO-0000', 'cccccccc-0000-4000-8000-000000000003') $$,
  'P0001', 'codigo_invalido', 'codigo errado'
);
select throws_ok(
  $$ select public.entrar_campanha('MESA-1234', 'cccccccc-0000-4000-8000-000000000003') $$,
  'P0001', 'ja_tem_heroi', 'segundo heroi na mesma campanha'
);
select throws_ok(
  $$ select public.entrar_campanha('CAIO-5678', 'cccccccc-0000-4000-8000-000000000002') $$,
  'P0001', 'sem_permissao', 'heroi de outro usuario'
);
select throws_ok(
  $$ select public.entrar_campanha('CAIO-5678', 'cccccccc-0000-4000-8000-000000000001') $$,
  'P0001', 'heroi_em_outra_campanha', 'heroi que ja esta em outra campanha'
);

-- caio e mestre da K2 e tenta jogar nela
reset role;
update public.personagens set campanha_id = null where id = 'cccccccc-0000-4000-8000-000000000004';
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000004');
select throws_ok(
  $$ select public.entrar_campanha('CAIO-5678', 'cccccccc-0000-4000-8000-000000000004') $$,
  'P0001', 'mestre_nao_joga', 'mestre com heroi na propria campanha'
);

-- sem login
reset role;
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ select public.entrar_campanha('MESA-1234', 'cccccccc-0000-4000-8000-000000000004') $$,
  'P0001', 'sem_permissao', 'sem login nao entra'
);

-- anon nem executa
reset role;
set local role anon;
select throws_ok(
  $$ select public.entrar_campanha('MESA-1234', 'cccccccc-0000-4000-8000-000000000004') $$,
  '42501', null, 'anon nao executa rpc'
);

select * from finish();
rollback;
