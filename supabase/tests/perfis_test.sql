begin;
create extension if not exists pgtap with schema extensions;

select plan(11);

-- dois usuarios, o trigger cria os perfis
insert into auth.users (id, email, raw_user_meta_data)
values
  ('11111111-1111-1111-1111-111111111111', 'a@teste.com', '{"nome": "Ana"}'),
  ('22222222-2222-2222-2222-222222222222', 'b@teste.com', '{"nome": "Bruno"}'),
  ('44444444-4444-4444-4444-444444444444', 'lia@teste.com', '{}');

select is(
  (select count(*)::int from public.perfis where id in (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '44444444-4444-4444-4444-444444444444'
  )),
  3,
  'trigger cria um perfil por usuario'
);

select is(
  (select nome from public.perfis
   where id = '44444444-4444-4444-4444-444444444444'),
  'lia',
  'sem nome no cadastro usa o comeco do e-mail'
);

select is(
  (select nome from public.perfis
   where id = '11111111-1111-1111-1111-111111111111'),
  'Ana',
  'nome vem do cadastro'
);

-- entra como A
set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub": "11111111-1111-1111-1111-111111111111", "role": "authenticated"}',
  true
);

select is(
  (select count(*)::int from public.perfis),
  1,
  'A so enxerga o proprio perfil'
);

select is(
  (select nome from public.perfis),
  'Ana',
  'A le o proprio perfil'
);

select is_empty(
  $$ select * from public.perfis
     where id = '22222222-2222-2222-2222-222222222222' $$,
  'A nao le o perfil de B'
);

update public.perfis set nome = 'Ana Lima'
where id = '11111111-1111-1111-1111-111111111111';

select is(
  (select nome from public.perfis),
  'Ana Lima',
  'A edita o proprio perfil'
);

-- update no perfil de B nao acha linha
update public.perfis set nome = 'Hacker'
where id = '22222222-2222-2222-2222-222222222222';

select throws_ok(
  $$ update public.perfis set nome = 'A'
     where id = '11111111-1111-1111-1111-111111111111' $$,
  '23514',
  null,
  'nome com 1 letra falha'
);

select throws_ok(
  $$ insert into public.perfis (id, nome)
     values ('33333333-3333-3333-3333-333333333333', 'Caio') $$,
  '42501',
  null,
  'app nao cria perfil'
);

select throws_ok(
  $$ delete from public.perfis $$,
  '42501',
  null,
  'app nao apaga perfil'
);

-- volta para o dono do banco e confere B
reset role;

select is(
  (select nome from public.perfis
   where id = '22222222-2222-2222-2222-222222222222'),
  'Bruno',
  'A nao edita o perfil de B'
);

select * from finish();
rollback;
