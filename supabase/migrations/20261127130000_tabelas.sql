-- tabelas do grimorio: campanhas, herois, missoes e a mesa
-- nomes das colunas iguais as chaves do toJson dos models

-- campanhas

create table public.campanhas (
  id uuid primary key default gen_random_uuid(),
  mestre_id uuid not null default auth.uid()
    references public.perfis on delete cascade,
  nome text not null check (char_length(trim(nome)) between 1 and 60),
  capitulo text not null default '',
  capa text,
  progresso numeric(3, 2) not null default 0
    check (progresso between 0 and 1),
  codigo_convite text not null unique,
  sessao_atual int not null default 0 check (sessao_atual >= 0),
  em_sessao boolean not null default false,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index campanhas_mestre_id_idx on public.campanhas (mestre_id);

create trigger campanhas_atualizado_em
  before update on public.campanhas
  for each row execute function public.definir_atualizado_em();

-- 4 letras do nome sem acento (completa com X) + 4 digitos: SOMB-4821
-- definer para enxergar os codigos de todas as campanhas
create or replace function public.gerar_codigo_convite(nome text)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  letras text;
  codigo text;
begin
  letras := upper(translate(
    coalesce(nome, ''),
    'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ',
    'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN'
  ));
  letras := rpad(left(regexp_replace(letras, '[^A-Z]', '', 'g'), 4), 4, 'X');
  loop
    codigo := letras || '-' || lpad(floor(random() * 10000)::int::text, 4, '0');
    exit when not exists (
      select 1 from public.campanhas c where c.codigo_convite = codigo
    );
  end loop;
  return codigo;
end;
$$;

-- o codigo sempre nasce no banco, o que o app mandar e ignorado
create or replace function public.definir_codigo_convite()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.codigo_convite := public.gerar_codigo_convite(new.nome);
  return new;
end;
$$;

create trigger campanhas_codigo_convite
  before insert on public.campanhas
  for each row execute function public.definir_codigo_convite();

-- notas do mestre, separadas porque o heroi le campanhas

create table public.notas_mestre (
  campanha_id uuid primary key references public.campanhas on delete cascade,
  texto text not null default '',
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create trigger notas_mestre_atualizado_em
  before update on public.notas_mestre
  for each row execute function public.definir_atualizado_em();

create or replace function public.criar_notas_mestre()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notas_mestre (campanha_id) values (new.id);
  return new;
end;
$$;

create trigger campanhas_notas_mestre
  after insert on public.campanhas
  for each row execute function public.criar_notas_mestre();

-- herois

create table public.personagens (
  id uuid primary key default gen_random_uuid(),
  dono_id uuid not null default auth.uid()
    references public.perfis on delete cascade,
  campanha_id uuid references public.campanhas on delete set null,
  ativo boolean not null default false,
  nome text not null check (char_length(trim(nome)) between 1 and 60),
  retrato text not null,
  especie text not null,
  antecedente text,
  alinhamento text,
  historia text not null default '',
  xp int not null default 0 check (xp >= 0),
  hp_max int not null default 0 check (hp_max >= 0),
  hp_atual int not null default 0,
  hp_temp int not null default 0 check (hp_temp >= 0),
  ca int not null default 10,
  deslocamento_m numeric not null default 9,
  inspiracao boolean not null default false,
  classes jsonb not null default '[]',
  atributos jsonb not null default '{}',
  salvaguardas jsonb not null default '[]',
  pericias jsonb not null default '[]',
  idiomas jsonb not null default '[]',
  magias jsonb not null default '[]',
  magias_preparadas jsonb not null default '[]',
  espacos_de_magia jsonb not null default '[]',
  inventario jsonb not null default '[]',
  condicoes jsonb not null default '[]',
  moedas jsonb not null default '{"ouro": 0, "prata": 0, "cobre": 0}',
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- um ativo por dono e um heroi por dono em cada campanha
create unique index personagens_um_ativo_idx
  on public.personagens (dono_id) where ativo;
create unique index personagens_um_por_campanha_idx
  on public.personagens (campanha_id, dono_id) where campanha_id is not null;
create index personagens_dono_id_idx on public.personagens (dono_id);
create index personagens_campanha_id_idx on public.personagens (campanha_id);

create trigger personagens_atualizado_em
  before update on public.personagens
  for each row execute function public.definir_atualizado_em();

-- mestre nao tem heroi na propria campanha
create or replace function public.conferir_mestre_nao_joga()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.campanha_id is not null and exists (
    select 1 from public.campanhas c
    where c.id = new.campanha_id and c.mestre_id = new.dono_id
  ) then
    raise exception 'mestre_nao_joga' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

create trigger personagens_mestre_nao_joga
  before insert or update of campanha_id, dono_id on public.personagens
  for each row execute function public.conferir_mestre_nao_joga();

-- diario do heroi, so o dono ve

create table public.notas_heroi (
  id uuid primary key default gen_random_uuid(),
  personagem_id uuid not null references public.personagens on delete cascade,
  dono_id uuid not null default auth.uid()
    references public.perfis on delete cascade,
  titulo text not null default '',
  texto text not null default '',
  data_ms bigint not null
    default (extract(epoch from now()) * 1000)::bigint,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index notas_heroi_personagem_id_idx on public.notas_heroi (personagem_id);
create index notas_heroi_dono_id_idx on public.notas_heroi (dono_id);

create trigger notas_heroi_atualizado_em
  before update on public.notas_heroi
  for each row execute function public.definir_atualizado_em();

-- missoes

create table public.missoes (
  id uuid primary key default gen_random_uuid(),
  campanha_id uuid not null references public.campanhas on delete cascade,
  titulo text not null check (char_length(trim(titulo)) between 1 and 80),
  tipo text not null default 'secundaria'
    check (tipo in ('principal', 'secundaria')),
  regiao text not null default '',
  descricao text not null default '',
  estado text not null default 'ativa'
    check (estado in ('ativa', 'concluida', 'falhou')),
  revelada boolean not null default false,
  recompensa_xp int not null default 0 check (recompensa_xp >= 0),
  recompensa_itens text[] not null default '{}',
  npc_ids uuid[] not null default '{}',
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index missoes_campanha_id_idx on public.missoes (campanha_id);

create trigger missoes_atualizado_em
  before update on public.missoes
  for each row execute function public.definir_atualizado_em();

-- entradas do diario da missao
-- campanha_id repetido para a rls e o filtro do realtime

create table public.entradas_missao (
  id uuid primary key default gen_random_uuid(),
  missao_id uuid not null references public.missoes on delete cascade,
  campanha_id uuid not null references public.campanhas on delete cascade,
  texto text not null default '',
  sessao int not null default 0,
  objetivo boolean not null default false,
  concluida boolean not null default false,
  revelada boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index entradas_missao_missao_id_idx on public.entradas_missao (missao_id);
create index entradas_missao_campanha_id_idx
  on public.entradas_missao (campanha_id);

create trigger entradas_missao_atualizado_em
  before update on public.entradas_missao
  for each row execute function public.definir_atualizado_em();

-- a campanha da entrada e sempre a da missao
create or replace function public.definir_campanha_da_entrada()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  select m.campanha_id into new.campanha_id
  from public.missoes m
  where m.id = new.missao_id;
  return new;
end;
$$;

create trigger entradas_missao_campanha
  before insert or update of missao_id, campanha_id on public.entradas_missao
  for each row execute function public.definir_campanha_da_entrada();

-- npcs

create table public.npcs (
  id uuid primary key default gen_random_uuid(),
  campanha_id uuid not null references public.campanhas on delete cascade,
  nome text not null check (char_length(trim(nome)) between 1 and 60),
  funcao text not null default '',
  imagem text,
  revelado boolean not null default false,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index npcs_campanha_id_idx on public.npcs (campanha_id);

create trigger npcs_atualizado_em
  before update on public.npcs
  for each row execute function public.definir_atualizado_em();

-- sessoes encerradas

create table public.sessoes (
  id uuid primary key default gen_random_uuid(),
  campanha_id uuid not null references public.campanhas on delete cascade,
  numero int not null check (numero > 0),
  data timestamptz not null default now(),
  resumo text not null default '',
  xp_total int not null default 0,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (campanha_id, numero)
);

create trigger sessoes_atualizado_em
  before update on public.sessoes
  for each row execute function public.definir_atualizado_em();

-- registros da mesa, mais novo primeiro pelo criado_em
-- clock_timestamp para manter a ordem dentro da mesma rpc

create table public.registros_mesa (
  id uuid primary key default gen_random_uuid(),
  campanha_id uuid not null references public.campanhas on delete cascade,
  tipo text not null check (tipo in ('xp', 'item', 'missao', 'entrada', 'sessao')),
  texto text not null,
  personagem_id uuid references public.personagens on delete set null,
  valor int,
  item_key text,
  sessao int,
  criado_em timestamptz not null default clock_timestamp(),
  atualizado_em timestamptz not null default now()
);

create index registros_mesa_campanha_id_idx
  on public.registros_mesa (campanha_id, criado_em desc);
create index registros_mesa_personagem_id_idx
  on public.registros_mesa (personagem_id);

create trigger registros_mesa_atualizado_em
  before update on public.registros_mesa
  for each row execute function public.definir_atualizado_em();
