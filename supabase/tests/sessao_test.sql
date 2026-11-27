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
select is(public.iniciar_sessao('bbbbbbbb-0000-4000-8000-000000000001'), 1, 'iniciar abre a sessao 1');
select throws_ok(
  $$ select public.iniciar_sessao('bbbbbbbb-0000-4000-8000-000000000001') $$,
  'P0001', 'sessao_aberta', 'iniciar duas vezes'
);
select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001', array['cccccccc-0000-4000-8000-000000000001']::uuid[], 200);
select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001', array['cccccccc-0000-4000-8000-000000000001', 'cccccccc-0000-4000-8000-000000000002']::uuid[], 50);
select lives_ok(
  $$ select public.encerrar_sessao('bbbbbbbb-0000-4000-8000-000000000001', ' Boa sessão ') $$,
  'encerrar'
);
select is(
  (select xp_total from public.sessoes where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001' and numero = 1),
  300,
  'xp_total soma os registros de xp da sessao'
);
select is(
  (select resumo from public.sessoes where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001' and numero = 1),
  'Boa sessão',
  'resumo sem espacos'
);
select throws_ok(
  $$ select public.encerrar_sessao('bbbbbbbb-0000-4000-8000-000000000001', '') $$,
  'P0001', 'sem_sessao', 'encerrar sem sessao aberta'
);

-- xp fora de sessao e da sessao anterior nao entram
select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001', array['cccccccc-0000-4000-8000-000000000002']::uuid[], 999);
select is(public.iniciar_sessao('bbbbbbbb-0000-4000-8000-000000000001'), 2, 'proxima sessao e a 2');
select public.dar_xp('bbbbbbbb-0000-4000-8000-000000000001', array['cccccccc-0000-4000-8000-000000000002']::uuid[], 10);
select public.encerrar_sessao('bbbbbbbb-0000-4000-8000-000000000001', 'Segunda');
select is(
  (select xp_total from public.sessoes where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001' and numero = 2),
  10,
  'xp_total so da sessao atual'
);
select set_eq(
  $$ select texto from public.registros_mesa where tipo = 'sessao' $$,
  $$ values ('Sessão 1 iniciada'), ('Sessão 1 encerrada'),
            ('Sessão 2 iniciada'), ('Sessão 2 encerrada') $$,
  'registros de sessao com o texto do app'
);

-- mestre so troca o resumo
update public.sessoes set resumo = 'Editado' where numero = 2;
select is(
  (select resumo from public.sessoes where campanha_id = 'bbbbbbbb-0000-4000-8000-000000000001' and numero = 2),
  'Editado',
  'mestre edita o resumo'
);
select throws_ok(
  $$ update public.sessoes set xp_total = 0 $$,
  '42501', null, 'xp_total nao muda direto'
);

-- heroi le mas nao mexe
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select is((select count(*)::int from public.sessoes), 2, 'heroi ve as sessoes');
select throws_ok(
  $$ select public.iniciar_sessao('bbbbbbbb-0000-4000-8000-000000000001') $$,
  'P0001', 'sem_permissao', 'heroi nao abre sessao'
);

select * from finish();
rollback;
