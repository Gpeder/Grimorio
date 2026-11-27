-- perfil de cada usuario do auth

create table public.perfis (
  id uuid primary key references auth.users on delete cascade,
  nome text not null check (char_length(trim(nome)) between 2 and 40),
  avatar text,
  papel text not null default 'jogador'
    check (papel in ('jogador', 'mestre', 'ambos')),
  edicao text not null default 'srd2014',
  magia text not null default 'espacos',
  subida text not null default 'xp',
  dicas_bonus boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- atualizado_em em todo update (reaproveitado nas outras tabelas)
create or replace function public.definir_atualizado_em()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

create trigger perfis_atualizado_em
  before update on public.perfis
  for each row execute function public.definir_atualizado_em();

-- cria o perfil quando a conta nasce, com o nome do cadastro
-- conta criada pelo painel (sem nome) usa o comeco do e-mail
create or replace function public.criar_perfil()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  nome_novo text := left(trim(coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'nome'), ''),
    split_part(coalesce(new.email, ''), '@', 1)
  )), 40);
begin
  if char_length(nome_novo) < 2 then
    nome_novo := 'Aventureiro';
  end if;
  insert into public.perfis (id, nome) values (new.id, nome_novo);
  return new;
end;
$$;

create trigger ao_criar_usuario
  after insert on auth.users
  for each row execute function public.criar_perfil();

-- cada um so ve e edita o proprio perfil
alter table public.perfis enable row level security;

create policy "perfis: ler o proprio"
  on public.perfis for select
  to authenticated
  using (id = (select auth.uid()));

create policy "perfis: editar o proprio"
  on public.perfis for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- o app nao cria nem apaga perfil
revoke insert, delete on public.perfis from anon, authenticated;
revoke execute on function public.criar_perfil() from public, anon, authenticated;
