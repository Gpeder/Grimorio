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

select plan(13);

select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');
select lives_ok(
  $$ select public.concluir_missao(
       'dddddddd-0000-4000-8000-000000000001',
       '{"pocao": "cccccccc-0000-4000-8000-000000000002"}',
       '{"pocao": {"nome": "Poção de cura", "quantidade": 1}}') $$,
  'concluir missao'
);
select is(
  (select xp from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  1300,
  'xp da recompensa para thorin'
);
select is(
  (select xp from public.personagens where id = 'cccccccc-0000-4000-8000-000000000002'),
  800,
  'xp da recompensa para lyra'
);
select is(
  (select inventario -> 0 ->> 'id' from public.personagens where id = 'cccccccc-0000-4000-8000-000000000002'),
  'pocao',
  'item para o heroi escolhido, com a key como id'
);
select is(
  (select jsonb_array_length(inventario) from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  0,
  'quem nao foi escolhido nao recebe o item'
);
select is(
  (select estado from public.missoes where id = 'dddddddd-0000-4000-8000-000000000001'),
  'concluida',
  'missao concluida'
);
select set_eq(
  $$ select texto from public.registros_mesa $$,
  $$ values ('+300 XP para Thorin'), ('+300 XP para Lyra'),
            ('Poção de cura para Lyra'), ('Missão concluída: Missão revelada') $$,
  'registros iguais ao GerenciadorMissoes.concluir'
);
select throws_ok(
  $$ select public.concluir_missao('dddddddd-0000-4000-8000-000000000001', '{}', '{}') $$,
  'P0001', 'missao_fechada', 'concluir duas vezes'
);

-- falhar
select lives_ok(
  $$ select public.falhar_missao('dddddddd-0000-4000-8000-000000000002') $$,
  'falhar missao'
);
select is(
  (select texto from public.registros_mesa where texto like 'Missão falhou%'),
  'Missão falhou: Missão oculta',
  'registro da falha'
);
select throws_ok(
  $$ select public.falhar_missao('dddddddd-0000-4000-8000-000000000002') $$,
  'P0001', 'missao_fechada', 'falhar missao fechada'
);
select throws_ok(
  $$ update public.missoes set estado = 'ativa' $$,
  '42501', null, 'estado so por rpc'
);

-- heroi nao conclui
reset role;
update public.missoes set estado = 'ativa' where id = 'dddddddd-0000-4000-8000-000000000001';
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select throws_ok(
  $$ select public.concluir_missao('dddddddd-0000-4000-8000-000000000001', '{}', '{}') $$,
  'P0001', 'sem_permissao', 'heroi nao conclui missao'
);

select * from finish();
rollback;
