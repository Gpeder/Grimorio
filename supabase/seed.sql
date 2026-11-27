-- dados do mock para testar no supabase start
-- so local: nunca rodar no projeto de producao
-- senha de todos: grimorio123

-- usuarios (o trigger cria os perfis com o nome)

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select
  '00000000-0000-0000-0000-000000000000', u.id::uuid, 'authenticated',
  'authenticated', u.email,
  extensions.crypt('grimorio123', extensions.gen_salt('bf')), now(),
  '{"provider": "email", "providers": ["email"]}',
  jsonb_build_object('nome', u.nome), now(), now(), '', '', '', ''
from (values
  ('00000000-0000-4000-8000-000000000001', 'gustavo@email.com', 'Gustavo'),
  ('00000000-0000-4000-8000-000000000002', 'bruno@email.com', 'Bruno'),
  ('00000000-0000-4000-8000-000000000003', 'ana@email.com', 'Ana'),
  ('00000000-0000-4000-8000-000000000004', 'caio@email.com', 'Caio'),
  ('00000000-0000-4000-8000-000000000005', 'lia@email.com', 'Lia')
) as u (id, email, nome);

insert into auth.identities (
  provider_id, user_id, identity_data, provider, last_sign_in_at,
  created_at, updated_at
)
select u.id::text, u.id,
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
  'email', now(), now(), now()
from auth.users u
where u.email like '%@email.com';

update public.perfis set papel = 'ambos', avatar = 'images/species/humano_m.webp'
where id = '00000000-0000-4000-8000-000000000001';
update public.perfis set papel = 'mestre', avatar = 'images/species/elfo_m.webp'
where id = '00000000-0000-4000-8000-000000000002';
update public.perfis set avatar = 'images/species/anao_m.webp'
where id = '00000000-0000-4000-8000-000000000003';
update public.perfis set avatar = 'images/species/tiefling_f.webp'
where id = '00000000-0000-4000-8000-000000000004';
update public.perfis set avatar = 'images/species/humano_m.webp'
where id = '00000000-0000-4000-8000-000000000005';

-- campanhas: a do Bruno (Valfenda) e a do Gustavo (Trono)

insert into public.campanhas
  (id, mestre_id, nome, capitulo, capa, progresso, sessao_atual, em_sessao)
values
  ('10000000-0000-4000-8000-000000000001',
   '00000000-0000-4000-8000-000000000002', 'Sombras de Valfenda',
   'Capítulo 3: A Floresta Sombria', 'images/bg/bg_3.webp', 0.3, 8, true),
  ('10000000-0000-4000-8000-000000000002',
   '00000000-0000-4000-8000-000000000001', 'O Trono de Cinzas',
   'Capítulo 1: Brasas no Horizonte', 'images/bg/castelo.webp', 0.05, 1, false);

-- codigos fixos para digitar no app
update public.campanhas set codigo_convite = 'VALF-0042'
where id = '10000000-0000-4000-8000-000000000001';
update public.campanhas set codigo_convite = 'TRON-0017'
where id = '10000000-0000-4000-8000-000000000002';

update public.notas_mestre
set texto = 'O culto do Galho Podre se esconde no altar antigo.'
where campanha_id = '10000000-0000-4000-8000-000000000001';

-- herois

insert into public.personagens (
  id, dono_id, campanha_id, ativo, nome, retrato, especie, antecedente,
  alinhamento, historia, xp, hp_max, hp_atual, ca, deslocamento_m, inspiracao,
  classes, atributos, salvaguardas, pericias, idiomas, magias,
  magias_preparadas, espacos_de_magia, inventario, condicoes, moedas
)
values
  -- elyndra, do gustavo, na campanha do bruno
  ('20000000-0000-4000-8000-000000000001',
   '00000000-0000-4000-8000-000000000001',
   '10000000-0000-4000-8000-000000000001', true, 'Elyndra',
   'images/species/humano_f.webp', 'Humana', 'Acólito', 'Neutro e Bom',
   'Criada no templo de Valfenda, Elyndra deixou o claustro quando as sombras chegaram às vilas do vale.',
   6500, 38, 32, 16, 9, true,
   '[{"api_key": "srd_cleric", "nome": "Clériga", "nivel": 5, "dado_de_vida": 8, "subclasse": "Domínio da Vida"}]',
   '{"forca": 12, "destreza": 10, "constituicao": 14, "inteligencia": 10, "sabedoria": 18, "carisma": 13}',
   '["sabedoria", "carisma"]',
   '["Intuição", "Medicina", "Religião"]',
   '["Comum", "Élfico", "Celestial"]',
   '["chama_sagrada", "luz", "taumaturgia", "bencao", "curar_ferimentos", "palavra_curativa", "escudo_da_fe", "comando", "raio_guia", "detectar_magia"]',
   '["bencao", "curar_ferimentos", "palavra_curativa", "escudo_da_fe", "comando", "raio_guia"]',
   '[{"circulo": 1, "total": 4, "usados": 1}, {"circulo": 2, "total": 3, "usados": 0}, {"circulo": 3, "total": 2, "usados": 2}]',
   '[
     {"id": "maca", "nome": "Maça", "imagem": "images/armas/arma_02.webp", "quantidade": 1, "peso_kg": 2, "equipado_em": "maoPrincipal", "dano": "1d6", "tipo_dano": "contundente", "consumivel": false, "descricao": "Arma simples de corpo a corpo."},
     {"id": "cota_escamas", "nome": "Cota de escamas", "imagem": "images/armaduras/medio/armadura_medio.webp", "quantidade": 1, "peso_kg": 22.5, "equipado_em": "armadura", "consumivel": false, "descricao": "Armadura média. CA 14 + DES (máx. 2)."},
     {"id": "escudo", "nome": "Escudo", "imagem": "images/armaduras/pesado/elmo_pesado.webp", "quantidade": 1, "peso_kg": 3, "equipado_em": "maoSecundaria", "consumivel": false, "descricao": "+2 na CA enquanto empunhado.", "bonus_ca": 2},
     {"id": "pocao_cura", "nome": "Poção de cura", "imagem": "images/pocoes/pocao_1.webp", "quantidade": 3, "peso_kg": 0.25, "consumivel": true, "descricao": "Cura 2d4 + 2."}
   ]',
   '[{"nome": "Envenenada", "rodadas": 2}]',
   '{"ouro": 12, "prata": 34, "cobre": 8}'),
  -- thorgar, da ana, na campanha do bruno
  ('20000000-0000-4000-8000-000000000002',
   '00000000-0000-4000-8000-000000000003',
   '10000000-0000-4000-8000-000000000001', true, 'Thorgar',
   'images/species/anao_m.webp', 'Anão', null, null, '',
   7800, 61, 52, 15, 7.5, false,
   '[{"api_key": "srd_barbarian", "nome": "Bárbaro", "nivel": 5, "dado_de_vida": 12}]',
   '{"forca": 18, "destreza": 12, "constituicao": 16, "inteligencia": 8, "sabedoria": 12, "carisma": 10}',
   '["forca", "constituicao"]', '["Atletismo", "Intimidação"]',
   '[]', '[]', '[]', '[]', '[]', '[]', '{"ouro": 0, "prata": 0, "cobre": 0}'),
  -- mirela, do caio, na campanha do bruno
  ('20000000-0000-4000-8000-000000000003',
   '00000000-0000-4000-8000-000000000004',
   '10000000-0000-4000-8000-000000000001', true, 'Mirela',
   'images/species/tiefling_f.webp', 'Tiefling', null, null, '',
   14200, 38, 23, 13, 9, false,
   '[{"api_key": "srd_warlock", "nome": "Bruxa", "nivel": 5, "dado_de_vida": 8}]',
   '{"forca": 8, "destreza": 14, "constituicao": 14, "inteligencia": 12, "sabedoria": 10, "carisma": 18}',
   '["sabedoria", "carisma"]', '["Arcanismo", "Enganação"]',
   '[]', '[]', '[]', '[{"circulo": 3, "total": 2, "usados": 1}]',
   '[{"id": "pocao_cura", "nome": "Poção de cura", "imagem": "images/pocoes/pocao_1.webp", "quantidade": 1, "peso_kg": 0.25, "consumivel": true, "descricao": "Cura 2d4 + 2."}]',
   '[]',
   '{"ouro": 0, "prata": 0, "cobre": 0}'),
  -- kael, da lia, na campanha do gustavo
  ('20000000-0000-4000-8000-000000000004',
   '00000000-0000-4000-8000-000000000005',
   '10000000-0000-4000-8000-000000000002', true, 'Kael',
   'images/species/humano_m.webp', 'Humano', null, null, '',
   0, 9, 9, 14, 9, false,
   '[{"api_key": "srd_rogue", "nome": "Ladino", "nivel": 1, "dado_de_vida": 8}]',
   '{"forca": 10, "destreza": 16, "constituicao": 12, "inteligencia": 13, "sabedoria": 12, "carisma": 14}',
   '["destreza", "inteligencia"]', '["Furtividade", "Prestidigitação"]',
   '[]', '[]', '[]', '[]', '[]', '[]', '{"ouro": 0, "prata": 0, "cobre": 0}');

insert into public.notas_heroi (personagem_id, dono_id, titulo, texto, data_ms)
values
  ('20000000-0000-4000-8000-000000000001',
   '00000000-0000-4000-8000-000000000001', 'O sino de Valfenda',
   'O sino do templo tocou sozinho à meia-noite. O velho Bram jura que viu uma silhueta na torre.',
   1794668400000),
  ('20000000-0000-4000-8000-000000000001',
   '00000000-0000-4000-8000-000000000001', 'Dívida com Kael',
   'Devo 15 PO ao Kael pela corda e pelas tochas.', 1795273200000);

-- npcs

insert into public.npcs (id, campanha_id, nome, funcao, imagem, revelado)
values
  ('40000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'Bram', 'Taverneiro', 'images/species/anao_m.webp', true),
  ('40000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   'Halvar', 'Druida', 'images/species/elfo_m.webp', true),
  ('40000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   'Sacerdotisa Ilsa', 'Sacerdotisa', 'images/species/meioelfo_f.webp', false),
  ('40000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000002',
   'Doran', 'Ferreiro', 'images/species/humano_m.webp', true);

-- missoes

insert into public.missoes (
  id, campanha_id, titulo, tipo, regiao, descricao, estado, revelada,
  recompensa_xp, recompensa_itens, npc_ids, atualizado_em
)
values
  ('30000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001',
   'O Druida Desaparecido', 'principal', 'Floresta Sombria',
   'Halvar, o guardião do bosque, sumiu. Desde então os animais da floresta andam inquietos.',
   'ativa', true, 900, '{amuleto_saude}',
   '{40000000-0000-4000-8000-000000000001,40000000-0000-4000-8000-000000000002}',
   '2026-11-25 19:45-03'),
  ('30000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001',
   'Lobos na Clareira', 'secundaria', 'Estrada Norte',
   'Uma alcateia ataca as carroças que passam pela clareira.',
   'ativa', true, 300, '{}', '{}', '2026-11-12 22:00-03'),
  ('30000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000001',
   'A Dívida de Bram', 'secundaria', 'Valfenda',
   'Bram deve 20 PO a um agiota da cidade.',
   'concluida', true, 100, '{}', '{40000000-0000-4000-8000-000000000001}',
   '2026-11-05 22:00-03'),
  ('30000000-0000-4000-8000-000000000004', '10000000-0000-4000-8000-000000000001',
   'O Mercador Sumido', 'secundaria', 'Estrada Sul',
   'Odo, o mercador de especiarias, não chegou à feira.',
   'falhou', true, 200, '{}', '{}', '2026-11-12 20:00-03'),
  ('30000000-0000-4000-8000-000000000005', '10000000-0000-4000-8000-000000000001',
   'O Altar Profanado', 'principal', 'Templo Antigo',
   'Alguém está profanando o altar esquecido do vale.',
   'ativa', false, 1200, '{}', '{40000000-0000-4000-8000-000000000003}',
   '2026-11-25 18:00-03'),
  ('30000000-0000-4000-8000-000000000006', '10000000-0000-4000-8000-000000000002',
   'A Coroa Partida', 'principal', 'Cidadela de Cinzas',
   'A coroa do último rei foi dividida em três fragmentos.',
   'ativa', true, 100, '{}', '{40000000-0000-4000-8000-000000000004}',
   '2026-11-20 20:00-03');

-- entradas (campanha_id vem da missao pelo trigger)

insert into public.entradas_missao
  (missao_id, campanha_id, texto, sessao, objetivo, concluida, revelada, criado_em)
select m::uuid, null, texto, sessao, objetivo, concluida, revelada, criado_em::timestamptz
from (values
  ('30000000-0000-4000-8000-000000000001',
   'Bram, o taverneiro, contou que Halvar sumiu há três noites.',
   6, false, true, true, '2026-11-05 20:00-03'),
  ('30000000-0000-4000-8000-000000000001',
   'Encontramos o acampamento de Halvar revirado na trilha norte.',
   7, false, true, true, '2026-11-12 21:00-03'),
  ('30000000-0000-4000-8000-000000000001',
   'Seguir os rastros até o coração da Floresta Sombria.',
   8, true, false, true, '2026-11-25 19:30-03'),
  ('30000000-0000-4000-8000-000000000001',
   'Descobrir que o culto do Galho Podre levou Halvar.',
   8, true, false, false, '2026-11-25 19:45-03'),
  ('30000000-0000-4000-8000-000000000002',
   'Afastar a alcateia antes da próxima caravana.',
   7, true, false, true, '2026-11-12 22:00-03'),
  ('30000000-0000-4000-8000-000000000003',
   'Pagamos a dívida e Bram prometeu hospedagem grátis.',
   6, true, true, true, '2026-11-05 22:00-03'),
  ('30000000-0000-4000-8000-000000000004',
   'Odo foi encontrado sem vida na beira da estrada.',
   7, false, false, true, '2026-11-12 20:00-03'),
  ('30000000-0000-4000-8000-000000000005',
   'Investigar as marcas de sangue no altar.',
   8, true, false, false, '2026-11-25 18:00-03'),
  ('30000000-0000-4000-8000-000000000006',
   'Encontrar o ferreiro que guarda o primeiro fragmento.',
   1, true, false, true, '2026-11-20 20:00-03')
) as e (m, texto, sessao, objetivo, concluida, revelada, criado_em);

-- sessoes encerradas

insert into public.sessoes (campanha_id, numero, data, resumo, xp_total)
values
  ('10000000-0000-4000-8000-000000000001', 6, '2026-11-05',
   'O grupo chegou a Valfenda e ouviu de Bram sobre o sumiço de Halvar.', 600),
  ('10000000-0000-4000-8000-000000000001', 7, '2026-11-12',
   'Na trilha norte, o grupo achou o acampamento revirado e enfrentou os lobos.', 1200),
  ('10000000-0000-4000-8000-000000000002', 1, '2026-11-20',
   'Kael chegou à cidadela e ouviu a lenda da coroa partida.', 0);

-- registros da sessao 8 de valfenda, aberta

insert into public.registros_mesa
  (campanha_id, tipo, texto, personagem_id, valor, item_key, sessao, criado_em)
values
  ('10000000-0000-4000-8000-000000000001', 'sessao', 'Sessão 8 iniciada',
   null, null, null, 8, '2026-11-25 19:00-03'),
  ('10000000-0000-4000-8000-000000000001', 'item', 'Poção de cura para Mirela',
   '20000000-0000-4000-8000-000000000003', null, 'pocao_cura', 8,
   '2026-11-25 20:05-03'),
  ('10000000-0000-4000-8000-000000000001', 'xp', '+150 XP para Thorgar',
   '20000000-0000-4000-8000-000000000002', 150, null, 8, '2026-11-25 20:10-03');
