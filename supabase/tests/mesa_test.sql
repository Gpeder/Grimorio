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

select plan(24);

reset role;
update public.personagens set inventario = '[{"id": "pocao", "nome": "Poção", "quantidade": 1}]'
where id = 'cccccccc-0000-4000-8000-000000000001';

-- dar xp
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');
select lives_ok(
  $$ select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001',
       array['cccccccc-0000-4000-8000-000000000001', 'cccccccc-0000-4000-8000-000000000002']::uuid[],
       1200) $$,
  'mestre da xp para dois herois'
);
select is(
  (select xp from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  2200,
  'xp somado'
);
select set_eq(
  $$ select texto from public.registros_mesa where tipo = 'xp' $$,
  $$ values ('+1.200 XP para Thorin'), ('+1.200 XP para Lyra') $$,
  'um registro por heroi, com o texto do app'
);
select throws_ok(
  $$ select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001',
       array['cccccccc-0000-4000-8000-000000000004']::uuid[], 100) $$,
  'P0001', 'heroi_fora_da_campanha', 'heroi de fora'
);
select throws_ok(
  $$ select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001',
       array['cccccccc-0000-4000-8000-000000000001']::uuid[], 0) $$,
  'P0001', 'valor_invalido', 'xp zero'
);

-- xp nao fica negativo
select lives_ok(
  $$ select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001',
       array['cccccccc-0000-4000-8000-000000000002']::uuid[], -5000) $$,
  'tirar mais xp do que tem'
);
select is(
  (select xp from public.personagens where id = 'cccccccc-0000-4000-8000-000000000002'),
  0,
  'xp para em zero'
);
select is(
  (select valor from public.registros_mesa where texto = '-1.700 XP para Lyra'),
  -1700,
  'registro guarda o que de fato saiu'
);

-- desfazer xp
select lives_ok(
  $$ select public.desfazer_registro(
       (select id from public.registros_mesa where texto = '+1.200 XP para Thorin')) $$,
  'desfazer xp'
);
select is(
  (select xp from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  1000,
  'xp voltou'
);
select is_empty(
  $$ select 1 from public.registros_mesa where texto = '+1.200 XP para Thorin' $$,
  'registro apagado'
);

-- dar item empilha e desfazer tira uma unidade
select lives_ok(
  $$ select public.dar_item('bbbbbbbb-0000-4000-8000-000000000001',
       'cccccccc-0000-4000-8000-000000000001',
       '{"id": "x", "nome": "Poção", "quantidade": 1}', 'pocao', 'Poção de cura') $$,
  'mestre da item'
);
select is(
  (select (inventario -> 0 ->> 'quantidade')::int from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  2,
  'item igual empilha'
);
select lives_ok(
  $$ select public.dar_item('bbbbbbbb-0000-4000-8000-000000000001',
       'cccccccc-0000-4000-8000-000000000001',
       '{"nome": "Corda"}', 'corda', 'Corda') $$,
  'item novo'
);
select is(
  (select jsonb_array_length(inventario) from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  2,
  'item novo acrescenta'
);
select is(
  (select texto from public.registros_mesa where item_key = 'pocao'),
  'Poção de cura para Thorin',
  'registro do item'
);
select lives_ok(
  $$ select public.desfazer_registro(
       (select id from public.registros_mesa where item_key = 'pocao')) $$,
  'desfazer item'
);
select is(
  (select (inventario -> 0 ->> 'quantidade')::int from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  1,
  'desfazer tira uma unidade'
);
select lives_ok(
  $$ select public.desfazer_registro(
       (select id from public.registros_mesa where item_key = 'corda')) $$,
  'desfazer o item de uma unidade'
);
select is(
  (select inventario from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  '[{"id": "pocao", "nome": "Poção", "quantidade": 1}]'::jsonb,
  'item com uma unidade some'
);

-- heroi chamando
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select throws_ok(
  $$ select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001',
       array['cccccccc-0000-4000-8000-000000000001']::uuid[], 100) $$,
  'P0001', 'sem_permissao', 'heroi nao da xp'
);
select throws_ok(
  $$ select public.dar_item('bbbbbbbb-0000-4000-8000-000000000001',
       'cccccccc-0000-4000-8000-000000000001', '{}', 'pocao', 'Poção') $$,
  'P0001', 'sem_permissao', 'heroi nao da item'
);
select set_eq(
  $$ select texto from public.registros_mesa $$,
  $$ select texto from public.registros_mesa
     where personagem_id = 'cccccccc-0000-4000-8000-000000000001' $$,
  'heroi ve so os registros do proprio heroi'
);
select throws_ok(
  $$ insert into public.registros_mesa (campanha_id, tipo, texto)
     values ('bbbbbbbb-0000-4000-8000-000000000001', 'xp', 'falso') $$,
  '42501', null, 'registro so por rpc'
);

select * from finish();
rollback;
