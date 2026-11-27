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

select plan(15);

-- dono
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
update public.personagens set hp_atual = 7, xp = 1100 where id = 'cccccccc-0000-4000-8000-000000000001';
select is(
  (select hp_atual from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  7,
  'dono edita o proprio heroi'
);
select throws_ok(
  $$ update public.personagens set campanha_id = null
     where id = 'cccccccc-0000-4000-8000-000000000001' $$,
  '42501',
  null,
  'dono nao troca campanha_id direto'
);
select throws_ok(
  $$ update public.personagens set dono_id = 'aaaaaaaa-0000-4000-8000-000000000003'
     where id = 'cccccccc-0000-4000-8000-000000000001' $$,
  '42501',
  null,
  'dono nao troca dono_id direto'
);
select lives_ok(
  $$ insert into public.personagens (nome, retrato, especie)
     values ('Novo', 'r', 'Humano') $$,
  'dono cria heroi sem campanha'
);
select is(
  (select dono_id from public.personagens where nome = 'Novo'),
  'aaaaaaaa-0000-4000-8000-000000000002'::uuid,
  'heroi novo e de quem criou'
);

-- outra heroina da mesa ve mas nao edita
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000003');
select is(
  (select nome from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  'Thorin',
  'outro heroi da mesa ve a ficha'
);
update public.personagens set hp_atual = 0 where id = 'cccccccc-0000-4000-8000-000000000001';

-- mestre ve mas so mexe por rpc
reset role;
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000001');
select is(
  (select nome from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  'Thorin',
  'mestre ve a ficha'
);
update public.personagens set hp_atual = 0, xp = 99999 where id = 'cccccccc-0000-4000-8000-000000000001';
select throws_ok(
  $$ insert into public.personagens (nome, retrato, especie, campanha_id)
     values ('Intruso', 'r', 'Humano', 'bbbbbbbb-0000-4000-8000-000000000001') $$,
  '42501',
  null,
  'ninguem cria heroi ja dentro de campanha'
);

reset role;
select is(
  (select hp_atual from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  7,
  'nem outro heroi nem o mestre editaram direto'
);
select is(
  (select xp from public.personagens where id = 'cccccccc-0000-4000-8000-000000000001'),
  1100,
  'xp continua o do dono'
);

-- um ativo por dono
select pg_temp.logar('aaaaaaaa-0000-4000-8000-000000000002');
select lives_ok(
  $$ select public.ativar_heroi('cccccccc-0000-4000-8000-000000000001') $$,
  'ativar o heroi'
);
select lives_ok(
  $$ select public.ativar_heroi('cccccccc-0000-4000-8000-000000000003') $$,
  'trocar o ativo'
);
select set_eq(
  $$ select nome from public.personagens where ativo $$,
  $$ values ('Reserva') $$,
  'so um heroi ativo por dono'
);
select throws_ok(
  $$ select public.ativar_heroi('cccccccc-0000-4000-8000-000000000002') $$,
  'P0001',
  'sem_permissao',
  'nao ativa heroi de outro'
);

-- mestre nao tem heroi na propria campanha (trigger)
reset role;
select throws_ok(
  $$ insert into public.personagens (dono_id, campanha_id, nome, retrato, especie)
     values ('aaaaaaaa-0000-4000-8000-000000000001',
             'bbbbbbbb-0000-4000-8000-000000000001', 'X', 'r', 'Humano') $$,
  'P0001',
  'mestre_nao_joga',
  'trigger barra heroi do mestre na propria campanha'
);

select * from finish();
rollback;
