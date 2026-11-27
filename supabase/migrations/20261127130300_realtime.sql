-- mudancas da mesa ao vivo; a rls vale tambem no realtime

alter publication supabase_realtime add table
  public.campanhas,
  public.personagens,
  public.missoes,
  public.entradas_missao,
  public.npcs,
  public.sessoes,
  public.registros_mesa;

-- combinado para o app:
-- um canal por campanha aberta, com filtro campanha_id=eq.<id>
--   (na tabela campanhas o filtro e id=eq.<id>)
-- quando o mestre esconde algo (missao, entrada ou npc), o heroi nao recebe
--   evento: a rls corta a linha. o app recarrega a campanha ao abrir a tela
--   e no puxar para atualizar
-- evento de delete com rls chega so com a chave primaria e nao passa pelo
--   filtro; o app tira da lista pelo id
