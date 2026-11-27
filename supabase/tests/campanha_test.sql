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

select plan(17);

-- codigo gerado pelo banco
select ok(
  (select codigo_convite ~ '^MESA-[0-9]{4}$' from public.campanhas where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
  'codigo com 4 letras do nome e 4 digitos'
);
insert into public.campanhas (mestre_id, nome) values ('aaaaaaaa-0000-4000-8000-000000000001', 'Ó é');
select ok(
  (select codigo_convite ~ '^OEXX-[0-9]{4}$' from public.campanhas where nome = 'Ó é'),
  'sem acento e completa com X'
);

-- heroi nao edita a campanha
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
update public.campanhas set nome = 'Hackeada' where id = 'bbbbbbbb-0000-4000-8000-000000000001';
delete from public.campanhas where id = 'bbbbbbbb-0000-4000-8000-000000000001';
reset role;
select is(
  (select nome from public.campanhas where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
  'Mesa do Mestre',
  'heroi nao edita nem apaga a campanha'
);

-- colunas so por rpc
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');
select throws_ok(
  $$ update public.campanhas set mestre_id = 'aaaaaaaa-0000-4000-8000-000000000002'
     where id = 'bbbbbbbb-0000-4000-8000-000000000001' $$,
  '42501',
  null,
  'mestre nao troca mestre_id direto'
);
select throws_ok(
  $$ update public.campanhas set codigo_convite = 'AAAA-0000'
     where id = 'bbbbbbbb-0000-4000-8000-000000000001' $$,
  '42501',
  null,
  'mestre nao troca codigo_convite direto'
);
select throws_ok(
  $$ update public.campanhas set em_sessao = true
     where id = 'bbbbbbbb-0000-4000-8000-000000000001' $$,
  '42501',
  null,
  'sessao so por rpc'
);
update public.campanhas set nome = 'Mesa Nova', progresso = 0.5 where id = 'bbbbbbbb-0000-4000-8000-000000000001';
select is(
  (select nome from public.campanhas where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
  'Mesa Nova',
  'mestre edita nome e progresso'
);

-- criar campanha
select lives_ok(
  $$ insert into public.campanhas (nome) values ('Minha Mesa') $$,
  'cria campanha como mestre'
);
select is(
  (select mestre_id from public.campanhas where nome = 'Minha Mesa'),
  'aaaaaaaa-0000-4000-8000-000000000001'::uuid,
  'mestre_id e de quem criou'
);
select throws_ok(
  $$ insert into public.campanhas (nome, mestre_id)
     values ('Falsa', 'aaaaaaaa-0000-4000-8000-000000000002') $$,
  '42501',
  null,
  'nao cria campanha no nome de outro'
);

-- novo codigo
select isnt(
  public.novo_codigo('bbbbbbbb-0000-4000-8000-000000000001'),
  (select codigo_convite from public.campanhas where nome = 'Ó é'),
  'mestre gera outro codigo'
);
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select throws_ok(
  $$ select public.novo_codigo('bbbbbbbb-0000-4000-8000-000000000001') $$,
  'P0001',
  'sem_permissao',
  'heroi nao gera codigo'
);

-- sair e remover
select lives_ok(
  $$ select public.sair_campanha('cccccccc-0000-4000-8000-000000000001') $$,
  'dono tira o heroi da campanha'
);
select is(
  (select campanha_id from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  null,
  'heroi ficou sem campanha'
);
select throws_ok(
  $$ select public.remover_heroi('cccccccc-0000-4000-8000-000000000002') $$,
  'P0001',
  'sem_permissao',
  'heroi nao remove outro heroi'
);
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');
select lives_ok(
  $$ select public.remover_heroi('cccccccc-0000-4000-8000-000000000002') $$,
  'mestre remove heroi da campanha dele'
);
reset role;
select is(
  (select campanha_id from public.personagens where id = 'cccccccc-0000-4000-8000-000000000002'),
  null,
  'heroi removido ficou sem campanha'
);

select * from finish();
rollback;
