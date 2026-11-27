-- permissao de mestre e heroi garantida no banco
-- sempre (select auth.uid()): o postgres calcula uma vez por consulta

-- apoio, definer para a policy de uma tabela nao cair na rls de outra

create or replace function public.eh_mestre(campanha uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.campanhas c
    where c.id = campanha and c.mestre_id = (select auth.uid())
  );
$$;

-- tem heroi na campanha
create or replace function public.eh_membro(campanha uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.personagens p
    where p.campanha_id = campanha and p.dono_id = (select auth.uid())
  );
$$;

-- os dois estao na mesma campanha, como mestre ou heroi
create or replace function public.divide_campanha(outro uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with minhas as (
    select c.id from public.campanhas c
    where c.mestre_id = (select auth.uid())
    union
    select p.campanha_id from public.personagens p
    where p.dono_id = (select auth.uid()) and p.campanha_id is not null
  )
  select exists (
    select 1 from minhas m
    join public.campanhas c on c.id = m.id
    where c.mestre_id = outro
      or exists (
        select 1 from public.personagens p
        where p.campanha_id = m.id and p.dono_id = outro
      )
  );
$$;

-- rls ligada em todas

alter table public.campanhas enable row level security;
alter table public.notas_mestre enable row level security;
alter table public.personagens enable row level security;
alter table public.notas_heroi enable row level security;
alter table public.missoes enable row level security;
alter table public.entradas_missao enable row level security;
alter table public.npcs enable row level security;
alter table public.sessoes enable row level security;
alter table public.registros_mesa enable row level security;

-- anon nao toca em nada
revoke all on table
  public.perfis, public.campanhas, public.notas_mestre, public.personagens,
  public.notas_heroi, public.missoes, public.entradas_missao, public.npcs,
  public.sessoes, public.registros_mesa
from anon;

-- perfis: o proprio e quem divide campanha (so leitura)

drop policy "perfis: ler o proprio" on public.perfis;

create policy "perfis: ler o proprio e os da mesa"
  on public.perfis for select
  to authenticated
  using (id = (select auth.uid()) or public.divide_campanha(id));

-- id e datas nao mudam pelo app
revoke update on public.perfis from authenticated;
grant update (nome, avatar, papel, edicao, magia, subida, dicas_bonus)
  on public.perfis to authenticated;

-- campanhas

create policy "campanhas: mestre ou membro le"
  on public.campanhas for select
  to authenticated
  using (mestre_id = (select auth.uid()) or public.eh_membro(id));

create policy "campanhas: cria como mestre"
  on public.campanhas for insert
  to authenticated
  with check (mestre_id = (select auth.uid()));

create policy "campanhas: mestre edita"
  on public.campanhas for update
  to authenticated
  using (mestre_id = (select auth.uid()))
  with check (mestre_id = (select auth.uid()));

create policy "campanhas: mestre apaga"
  on public.campanhas for delete
  to authenticated
  using (mestre_id = (select auth.uid()));

-- mestre, codigo e sessao so por rpc
revoke insert, update on public.campanhas from authenticated;
grant insert (id, nome, capitulo, capa, progresso) on public.campanhas
  to authenticated;
grant update (nome, capitulo, capa, progresso) on public.campanhas
  to authenticated;

-- notas do mestre

create policy "notas_mestre: mestre le"
  on public.notas_mestre for select
  to authenticated
  using (public.eh_mestre(campanha_id));

create policy "notas_mestre: mestre edita"
  on public.notas_mestre for update
  to authenticated
  using (public.eh_mestre(campanha_id))
  with check (public.eh_mestre(campanha_id));

revoke insert, update, delete on public.notas_mestre from authenticated;
grant update (texto) on public.notas_mestre to authenticated;

-- herois

create policy "personagens: dono, mestre e mesa leem"
  on public.personagens for select
  to authenticated
  using (
    dono_id = (select auth.uid())
    or (
      campanha_id is not null
      and (public.eh_mestre(campanha_id) or public.eh_membro(campanha_id))
    )
  );

create policy "personagens: dono cria fora de campanha"
  on public.personagens for insert
  to authenticated
  with check (dono_id = (select auth.uid()) and campanha_id is null);

create policy "personagens: dono edita"
  on public.personagens for update
  to authenticated
  using (dono_id = (select auth.uid()))
  with check (dono_id = (select auth.uid()));

create policy "personagens: dono apaga"
  on public.personagens for delete
  to authenticated
  using (dono_id = (select auth.uid()));

-- dono e campanha so por rpc
revoke insert, update on public.personagens from authenticated;
grant insert (
  id, ativo, nome, retrato, especie, antecedente, alinhamento, historia, xp,
  hp_max, hp_atual, hp_temp, ca, deslocamento_m, inspiracao, classes,
  atributos, salvaguardas, pericias, idiomas, magias, magias_preparadas,
  espacos_de_magia, inventario, condicoes, moedas
) on public.personagens to authenticated;
grant update (
  ativo, nome, retrato, especie, antecedente, alinhamento, historia, xp,
  hp_max, hp_atual, hp_temp, ca, deslocamento_m, inspiracao, classes,
  atributos, salvaguardas, pericias, idiomas, magias, magias_preparadas,
  espacos_de_magia, inventario, condicoes, moedas
) on public.personagens to authenticated;

-- diario do heroi, so o dono

create policy "notas_heroi: dono le"
  on public.notas_heroi for select
  to authenticated
  using (dono_id = (select auth.uid()));

create policy "notas_heroi: dono cria no proprio heroi"
  on public.notas_heroi for insert
  to authenticated
  with check (
    dono_id = (select auth.uid())
    and exists (
      select 1 from public.personagens p
      where p.id = personagem_id and p.dono_id = (select auth.uid())
    )
  );

create policy "notas_heroi: dono edita"
  on public.notas_heroi for update
  to authenticated
  using (dono_id = (select auth.uid()))
  with check (dono_id = (select auth.uid()));

create policy "notas_heroi: dono apaga"
  on public.notas_heroi for delete
  to authenticated
  using (dono_id = (select auth.uid()));

revoke update on public.notas_heroi from authenticated;
grant update (titulo, texto, data_ms) on public.notas_heroi to authenticated;

-- missoes: membro so as reveladas

create policy "missoes: mestre ou membro se revelada"
  on public.missoes for select
  to authenticated
  using (
    public.eh_mestre(campanha_id)
    or (revelada and public.eh_membro(campanha_id))
  );

create policy "missoes: mestre cria"
  on public.missoes for insert
  to authenticated
  with check (public.eh_mestre(campanha_id));

create policy "missoes: mestre edita"
  on public.missoes for update
  to authenticated
  using (public.eh_mestre(campanha_id))
  with check (public.eh_mestre(campanha_id));

create policy "missoes: mestre apaga"
  on public.missoes for delete
  to authenticated
  using (public.eh_mestre(campanha_id));

-- estado muda pelas rpcs de concluir e falhar
revoke update on public.missoes from authenticated;
grant update (
  titulo, tipo, regiao, descricao, revelada, recompensa_xp, recompensa_itens,
  npc_ids
) on public.missoes to authenticated;

-- entradas: membro so se a entrada e a missao estao reveladas

create policy "entradas_missao: mestre ou membro se reveladas"
  on public.entradas_missao for select
  to authenticated
  using (
    public.eh_mestre(campanha_id)
    or (
      revelada
      and public.eh_membro(campanha_id)
      and exists (
        select 1 from public.missoes m
        where m.id = missao_id and m.revelada
      )
    )
  );

create policy "entradas_missao: mestre cria"
  on public.entradas_missao for insert
  to authenticated
  with check (public.eh_mestre(campanha_id));

create policy "entradas_missao: mestre edita"
  on public.entradas_missao for update
  to authenticated
  using (public.eh_mestre(campanha_id))
  with check (public.eh_mestre(campanha_id));

create policy "entradas_missao: mestre apaga"
  on public.entradas_missao for delete
  to authenticated
  using (public.eh_mestre(campanha_id));

-- npcs: membro so os revelados

create policy "npcs: mestre ou membro se revelado"
  on public.npcs for select
  to authenticated
  using (
    public.eh_mestre(campanha_id)
    or (revelado and public.eh_membro(campanha_id))
  );

create policy "npcs: mestre cria"
  on public.npcs for insert
  to authenticated
  with check (public.eh_mestre(campanha_id));

create policy "npcs: mestre edita"
  on public.npcs for update
  to authenticated
  using (public.eh_mestre(campanha_id))
  with check (public.eh_mestre(campanha_id));

create policy "npcs: mestre apaga"
  on public.npcs for delete
  to authenticated
  using (public.eh_mestre(campanha_id));

-- sessoes: nascem pela rpc, mestre so troca o resumo

create policy "sessoes: mestre ou membro le"
  on public.sessoes for select
  to authenticated
  using (public.eh_mestre(campanha_id) or public.eh_membro(campanha_id));

create policy "sessoes: mestre edita"
  on public.sessoes for update
  to authenticated
  using (public.eh_mestre(campanha_id))
  with check (public.eh_mestre(campanha_id));

create policy "sessoes: mestre apaga"
  on public.sessoes for delete
  to authenticated
  using (public.eh_mestre(campanha_id));

revoke insert, update on public.sessoes from authenticated;
grant update (resumo) on public.sessoes to authenticated;

-- registros: mestre ve todos, membro so os do proprio heroi; escrita so por rpc

create policy "registros_mesa: mestre ou dono do heroi le"
  on public.registros_mesa for select
  to authenticated
  using (
    public.eh_mestre(campanha_id)
    or exists (
      select 1 from public.personagens p
      where p.id = personagem_id and p.dono_id = (select auth.uid())
    )
  );

revoke insert, update, delete on public.registros_mesa from authenticated;

-- funcoes internas: trigger e apoio nao sao chamadas pelo app
revoke execute on function
  public.definir_atualizado_em(),
  public.gerar_codigo_convite(text),
  public.definir_codigo_convite(),
  public.criar_notas_mestre(),
  public.conferir_mestre_nao_joga(),
  public.definir_campanha_da_entrada()
from public, anon, authenticated;

-- as policies chamam estas como authenticated
revoke execute on function
  public.eh_mestre(uuid),
  public.eh_membro(uuid),
  public.divide_campanha(uuid)
from public, anon;
grant execute on function
  public.eh_mestre(uuid),
  public.eh_membro(uuid),
  public.divide_campanha(uuid)
to authenticated;
