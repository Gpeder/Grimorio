-- regras da mesa como funcoes no postgres
-- o que o mestre faz no heroi de outra pessoa passa por aqui
-- erros: raise exception '<chave>' using errcode = 'P0001'; o app traduz a chave

-- apoio interno (sem execute para o app)

-- usuario logado ou sem_permissao
create or replace function public._usuario()
returns uuid
language plpgsql
stable
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  return uid;
end;
$$;

-- trava a campanha e confere que o logado e o mestre
create or replace function public._campanha_do_mestre(campanha uuid)
returns public.campanhas
language plpgsql
set search_path = ''
as $$
declare
  c public.campanhas;
begin
  select * into c from public.campanhas where id = campanha for update;
  if not found or c.mestre_id <> public._usuario() then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  return c;
end;
$$;

-- heroi travado e dentro da campanha
create or replace function public._heroi_da_campanha(personagem uuid, campanha uuid)
returns public.personagens
language plpgsql
set search_path = ''
as $$
declare
  p public.personagens;
begin
  select * into p from public.personagens where id = personagem for update;
  if not found or p.campanha_id is distinct from campanha then
    raise exception 'heroi_fora_da_campanha' using errcode = 'P0001';
  end if;
  return p;
end;
$$;

-- 1200 vira 1.200, igual ao formatarMilhar do app
create or replace function public._milhar(n int)
returns text
language sql
immutable
set search_path = ''
as $$
  select case when n < 0 then '-' else '' end
    || regexp_replace(abs(n)::text, '(\d)(?=(\d{3})+$)', '\1.', 'g');
$$;

-- registro da mesa com o numero da sessao aberta
create or replace function public._registrar(
  campanha uuid,
  tipo text,
  texto text,
  personagem uuid default null,
  valor int default null,
  item_key text default null
)
returns void
language sql
set search_path = ''
as $$
  insert into public.registros_mesa
    (campanha_id, tipo, texto, personagem_id, valor, item_key, sessao)
  select c.id, tipo, texto, personagem, valor, item_key,
    case when c.em_sessao then c.sessao_atual end
  from public.campanhas c
  where c.id = campanha;
$$;

-- igual ao GerenciadorInventario.receber: empilha pelo id ou acrescenta
create or replace function public._receber_item(inventario jsonb, item jsonb)
returns jsonb
language plpgsql
immutable
set search_path = ''
as $$
declare
  qtd int := greatest(coalesce((item ->> 'quantidade')::int, 1), 1);
begin
  item := jsonb_set(item, '{quantidade}', to_jsonb(qtd));
  if not exists (
    select 1 from jsonb_array_elements(inventario) e
    where e ->> 'id' = item ->> 'id'
  ) then
    return inventario || jsonb_build_array(item);
  end if;
  return (
    select jsonb_agg(
      case when e ->> 'id' = item ->> 'id'
        then jsonb_set(
          e, '{quantidade}',
          to_jsonb(coalesce((e ->> 'quantidade')::int, 1) + qtd)
        )
        else e
      end
      order by ordem
    )
    from jsonb_array_elements(inventario) with ordinality as t(e, ordem)
  );
end;
$$;

-- igual ao removerUmaUnidade: tira uma, com 1 ou menos some
create or replace function public._remover_uma_unidade(inventario jsonb, chave text)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select coalesce(
    jsonb_agg(
      case when e ->> 'id' = chave
        then jsonb_set(
          e, '{quantidade}',
          to_jsonb(coalesce((e ->> 'quantidade')::int, 1) - 1)
        )
        else e
      end
      order by ordem
    ) filter (
      where e ->> 'id' is distinct from chave
        or coalesce((e ->> 'quantidade')::int, 1) > 1
    ),
    '[]'::jsonb
  )
  from jsonb_array_elements(inventario) with ordinality as t(e, ordem);
$$;

-- campanha

-- heroi do usuario entra pelo codigo; devolve o id da campanha
create or replace function public.entrar_campanha(codigo text, personagem uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := public._usuario();
  c public.campanhas;
  p public.personagens;
begin
  select * into c from public.campanhas
  where codigo_convite = upper(trim(codigo));
  if not found then
    raise exception 'codigo_invalido' using errcode = 'P0001';
  end if;

  select * into p from public.personagens where id = personagem for update;
  if not found or p.dono_id <> uid then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  if c.mestre_id = uid then
    raise exception 'mestre_nao_joga' using errcode = 'P0001';
  end if;
  if p.campanha_id = c.id then
    return c.id;
  end if;
  if p.campanha_id is not null then
    raise exception 'heroi_em_outra_campanha' using errcode = 'P0001';
  end if;
  if exists (
    select 1 from public.personagens x
    where x.campanha_id = c.id and x.dono_id = uid
  ) then
    raise exception 'ja_tem_heroi' using errcode = 'P0001';
  end if;

  update public.personagens set campanha_id = c.id where id = p.id;
  return c.id;
end;
$$;

-- dono tira o proprio heroi da campanha
create or replace function public.sair_campanha(personagem uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  p public.personagens;
begin
  select * into p from public.personagens where id = personagem for update;
  if not found or p.dono_id <> public._usuario() then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  if p.campanha_id is null then
    raise exception 'heroi_fora_da_campanha' using errcode = 'P0001';
  end if;
  update public.personagens set campanha_id = null where id = p.id;
end;
$$;

-- mestre tira um heroi da campanha dele
create or replace function public.remover_heroi(personagem uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  p public.personagens;
begin
  select * into p from public.personagens where id = personagem for update;
  if not found or p.campanha_id is null then
    raise exception 'heroi_fora_da_campanha' using errcode = 'P0001';
  end if;
  perform public._campanha_do_mestre(p.campanha_id);
  update public.personagens set campanha_id = null where id = p.id;
end;
$$;

-- outro codigo, o velho para de funcionar
create or replace function public.novo_codigo(campanha uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  c public.campanhas := public._campanha_do_mestre(campanha);
  codigo text := public.gerar_codigo_convite(c.nome);
begin
  update public.campanhas set codigo_convite = codigo where id = c.id;
  return codigo;
end;
$$;

-- sessao

create or replace function public.iniciar_sessao(campanha uuid)
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  c public.campanhas := public._campanha_do_mestre(campanha);
  numero int := c.sessao_atual + 1;
begin
  if c.em_sessao then
    raise exception 'sessao_aberta' using errcode = 'P0001';
  end if;
  update public.campanhas
  set sessao_atual = numero, em_sessao = true
  where id = c.id;
  perform public._registrar(c.id, 'sessao', 'Sessão ' || numero || ' iniciada');
  return numero;
end;
$$;

-- xp_total soma so os registros de xp da sessao que fecha
create or replace function public.encerrar_sessao(campanha uuid, resumo text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  c public.campanhas := public._campanha_do_mestre(campanha);
  total int;
  nova uuid;
begin
  if not c.em_sessao then
    raise exception 'sem_sessao' using errcode = 'P0001';
  end if;

  select coalesce(sum(r.valor), 0) into total
  from public.registros_mesa r
  where r.campanha_id = c.id and r.tipo = 'xp' and r.sessao = c.sessao_atual;

  insert into public.sessoes (campanha_id, numero, resumo, xp_total)
  values (c.id, c.sessao_atual, coalesce(trim(resumo), ''), total)
  on conflict (campanha_id, numero) do update
    set resumo = excluded.resumo, xp_total = excluded.xp_total, data = now()
  returning id into nova;

  perform public._registrar(
    c.id, 'sessao', 'Sessão ' || c.sessao_atual || ' encerrada'
  );
  update public.campanhas set em_sessao = false where id = c.id;
  return nova;
end;
$$;

-- xp e itens

-- xp nunca fica negativo; o registro guarda o que de fato mudou
create or replace function public.dar_xp(campanha uuid, personagens uuid[], valor int)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  c public.campanhas := public._campanha_do_mestre(campanha);
  alvo uuid;
  p public.personagens;
  novo int;
begin
  if coalesce(valor, 0) = 0 or coalesce(cardinality(personagens), 0) = 0 then
    raise exception 'valor_invalido' using errcode = 'P0001';
  end if;

  -- confere todos antes de mexer em qualquer um
  foreach alvo in array personagens loop
    perform public._heroi_da_campanha(alvo, c.id);
  end loop;

  for alvo in select distinct x from unnest(personagens) x loop
    select * into p from public.personagens where id = alvo;
    novo := greatest(0, p.xp + valor);
    continue when novo = p.xp;
    update public.personagens set xp = novo where id = p.id;
    perform public._registrar(
      c.id, 'xp',
      case when novo > p.xp then '+' else '' end
        || public._milhar(novo - p.xp) || ' XP para ' || p.nome,
      p.id, novo - p.xp
    );
  end loop;
end;
$$;

-- item e o ItemInventario.toJson montado no app, o id vira a key do srd
create or replace function public.dar_item(
  campanha uuid,
  personagem uuid,
  item jsonb,
  item_key text,
  nome text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  c public.campanhas := public._campanha_do_mestre(campanha);
  p public.personagens;
begin
  if coalesce(trim(item_key), '') = '' or jsonb_typeof(item) is distinct from 'object' then
    raise exception 'valor_invalido' using errcode = 'P0001';
  end if;
  p := public._heroi_da_campanha(personagem, c.id);
  item := item || jsonb_build_object('id', item_key);

  update public.personagens
  set inventario = public._receber_item(inventario, item)
  where id = p.id;

  perform public._registrar(
    c.id, 'item',
    coalesce(nullif(trim(nome), ''), item ->> 'nome', item_key) || ' para ' || p.nome,
    p.id, null, item_key
  );
end;
$$;

-- so xp e item tem volta; apaga o registro
create or replace function public.desfazer_registro(registro uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.registros_mesa;
  c public.campanhas;
begin
  select * into r from public.registros_mesa where id = registro;
  if not found then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  c := public._campanha_do_mestre(r.campanha_id);

  if r.personagem_id is null
    or not (r.tipo = 'xp' and r.valor is not null
      or r.tipo = 'item' and r.item_key is not null)
  then
    raise exception 'valor_invalido' using errcode = 'P0001';
  end if;
  perform public._heroi_da_campanha(r.personagem_id, c.id);

  if r.tipo = 'xp' then
    update public.personagens
    set xp = greatest(0, xp - r.valor)
    where id = r.personagem_id;
  else
    update public.personagens
    set inventario = public._remover_uma_unidade(inventario, r.item_key)
    where id = r.personagem_id;
  end if;

  delete from public.registros_mesa where id = r.id;
end;
$$;

-- missao

-- destinos = {item_key: personagem_id}, itens = {item_key: ItemInventario}
create or replace function public.concluir_missao(missao uuid, destinos jsonb, itens jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.missoes;
  c public.campanhas;
  p public.personagens;
  chave text;
  destino uuid;
  item jsonb;
begin
  select * into m from public.missoes where id = missao for update;
  if not found then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  c := public._campanha_do_mestre(m.campanha_id);
  if m.estado <> 'ativa' then
    raise exception 'missao_fechada' using errcode = 'P0001';
  end if;

  -- xp para todos os herois da campanha
  if m.recompensa_xp > 0 then
    for p in
      select * from public.personagens
      where campanha_id = c.id
      order by criado_em, id
      for update
    loop
      update public.personagens set xp = xp + m.recompensa_xp where id = p.id;
      perform public._registrar(
        c.id, 'xp',
        '+' || public._milhar(m.recompensa_xp) || ' XP para ' || p.nome,
        p.id, m.recompensa_xp
      );
    end loop;
  end if;

  -- cada item para o heroi escolhido; sem destino o item fica
  foreach chave in array m.recompensa_itens loop
    destino := nullif(destinos ->> chave, '')::uuid;
    continue when destino is null;
    item := itens -> chave;
    if jsonb_typeof(item) is distinct from 'object' then
      raise exception 'valor_invalido' using errcode = 'P0001';
    end if;
    item := item || jsonb_build_object('id', chave);
    p := public._heroi_da_campanha(destino, c.id);
    update public.personagens
    set inventario = public._receber_item(inventario, item)
    where id = p.id;
    perform public._registrar(
      c.id, 'item',
      coalesce(item ->> 'nome', chave) || ' para ' || p.nome,
      p.id, null, chave
    );
  end loop;

  update public.missoes set estado = 'concluida' where id = m.id;
  perform public._registrar(c.id, 'missao', 'Missão concluída: ' || m.titulo);
end;
$$;

create or replace function public.falhar_missao(missao uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.missoes;
  c public.campanhas;
begin
  select * into m from public.missoes where id = missao for update;
  if not found then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  c := public._campanha_do_mestre(m.campanha_id);
  if m.estado <> 'ativa' then
    raise exception 'missao_fechada' using errcode = 'P0001';
  end if;
  update public.missoes set estado = 'falhou' where id = m.id;
  perform public._registrar(c.id, 'missao', 'Missão falhou: ' || m.titulo);
end;
$$;

-- heroi

-- troca o heroi ativo em dois passos por causa do indice unico
create or replace function public.ativar_heroi(personagem uuid)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null or not exists (
    select 1 from public.personagens where id = personagem and dono_id = uid
  ) then
    raise exception 'sem_permissao' using errcode = 'P0001';
  end if;
  update public.personagens set ativo = false
  where dono_id = uid and ativo and id <> personagem;
  update public.personagens set ativo = true where id = personagem;
end;
$$;

-- conta

-- a play store exige; o resto vai por cascade
-- campanhas do usuario somem e os herois dos outros ficam sem campanha
create or replace function public.apagar_minha_conta()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from auth.users where id = public._usuario();
end;
$$;

-- permissoes

revoke execute on function
  public._usuario(),
  public._campanha_do_mestre(uuid),
  public._heroi_da_campanha(uuid, uuid),
  public._milhar(int),
  public._registrar(uuid, text, text, uuid, int, text),
  public._receber_item(jsonb, jsonb),
  public._remover_uma_unidade(jsonb, text)
from public, anon, authenticated;

revoke execute on function
  public.entrar_campanha(text, uuid),
  public.sair_campanha(uuid),
  public.remover_heroi(uuid),
  public.novo_codigo(uuid),
  public.iniciar_sessao(uuid),
  public.encerrar_sessao(uuid, text),
  public.dar_xp(uuid, uuid[], int),
  public.dar_item(uuid, uuid, jsonb, text, text),
  public.desfazer_registro(uuid),
  public.concluir_missao(uuid, jsonb, jsonb),
  public.falhar_missao(uuid),
  public.ativar_heroi(uuid),
  public.apagar_minha_conta()
from public, anon;

grant execute on function
  public.entrar_campanha(text, uuid),
  public.sair_campanha(uuid),
  public.remover_heroi(uuid),
  public.novo_codigo(uuid),
  public.iniciar_sessao(uuid),
  public.encerrar_sessao(uuid, text),
  public.dar_xp(uuid, uuid[], int),
  public.dar_item(uuid, uuid, jsonb, text, text),
  public.desfazer_registro(uuid),
  public.concluir_missao(uuid, jsonb, jsonb),
  public.falhar_missao(uuid),
  public.ativar_heroi(uuid),
  public.apagar_minha_conta()
to authenticated;
