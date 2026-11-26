# Renomeações

Tudo que mudou de nome na reorganização view / controller / model.

Regra: domínio em português primeiro, tipo de UI em inglês no fim (`PersonagemCard`, `PassoHeader`, `OpcoesSheet`).
Prefixos de UI em português viraram sufixo em inglês: Aba → Tab, Botao → Button, Card → Card, Cabecalho → Header, Dialogo → Dialog, Linha → Tile, Selo → Badge, Sheet → Sheet, Barra → BottomBar/Header.
A classe `_XState` de cada widget com estado acompanha o novo nome (`_SheetPerfilState` → `_PerfilSheetState`).
Com o model virando `Campanha`, o import `campaign.dart as dados` deixou de ser preciso e o prefixo `dados.` saiu.
Nomes sem tipo de UI no meio (`Etiqueta`, `TituloSecao`, `CaixaTracejada`, `GemasMagia`, `Passo*`, telas principais) ficaram como estavam.

Pastas movidas na etapa 1: `lib/<feature>/` → `lib/view/<feature>/`, `lib/models/` → `lib/model/`, `test/<feature>/` → `test/view/<feature>/`, `test/models/` → `test/model/`, `test/widget_test.dart` → `test/app/app_shell_test.dart`.

Funções de regra que saíram do model ou da tela foram para `lib/controller/` (ver `CLAUDE.md`): `bonusDeEspecie`, `pontosGastos`, `compraValida`, `hpNivel1`, `calcularCA`, `limiteDeMagias`, `bonusPericia` → métodos estáticos de `GerenciadorCriacao`; `missoesVisiveis`, `entradasVisiveis`, `objetivoAtual`, `recompensaVisivel`, `npcsVisiveis`, `podeEditarCampanha` → `GerenciadorVisibilidade`; `gerarCodigoConvite` → `GerenciadorCampanhas`; `itemDoCompendio` → `GerenciadorInventario.doCompendio`; `normalizar`, `contem` → `GerenciadorCompendio`.

## Model

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `Character` | `Personagem` | `lib/model/character.dart` | `lib/model/personagem.dart` |
| (mock) | (mock) | `lib/model/character_mock.dart` | `lib/model/personagem_mock.dart` |
| `Ability` | `Atributo` |  |  |
| `AbilityScores` | `Atributos` |  |  |
| `CharacterClass` | `ClassePersonagem` |  |  |
| `SpellSlot` | `EspacoMagia` |  |  |
| `EquipSlot` | `SlotEquipamento` |  |  |
| `InventoryItem` | `ItemInventario` |  |  |
| `Condition` | `Condicao` |  |  |
| `Campaign (model)` | `Campanha` | `lib/model/campaign.dart` | `lib/model/campanha.dart` |
| (mock) | (mock) | `lib/model/campaign_mock.dart` | `lib/model/campanha_mock.dart` |
| (compêndio) | (compêndio) | `lib/model/grimoire.dart` | `lib/model/compendio.dart` |
| (mock) | (mock) | `lib/model/grimoire_mock.dart` | `lib/model/compendio_mock.dart` |
| (opções de herói) | (opções de herói) | `lib/model/hero_options.dart` | `lib/model/opcoes_heroi.dart` |
| (mock) | (mock) | `lib/model/hero_options_mock.dart` | `lib/model/opcoes_heroi_mock.dart` |
| `SubspeciesOption` | `OpcaoSubespecie` |  |  |
| `SpeciesOption` | `OpcaoEspecie` |  |  |
| `SubclassOption` | `OpcaoSubclasse` |  |  |
| `EquipmentItem` | `ItemEquipamento` |  |  |
| `EquipmentChoice` | `EscolhaEquipamento` |  |  |
| `SpellOption` | `OpcaoMagia` |  |  |
| `ClassOption` | `OpcaoClasse` |  |  |
| `BackgroundOption` | `OpcaoAntecedente` |  |  |
| `SkillOption` | `OpcaoPericia` |  |  |

## App

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `BarraNavegacao` | `NavegacaoBottomBar` | `lib/app/components/barra_navegacao.dart` | `lib/app/components/navegacao_bottom_bar.dart` |
| `_BotaoCentral` | `_CentralButton` |  |  |

## Home

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `CampaignActive` | `CampanhaAtiva` | `lib/view/home/components/campaign_active.dart` | `lib/view/home/components/campanha_ativa.dart` |
| `CardPersonagemAtivo` | `PersonagemAtivoCard` | `lib/view/home/components/card_personagem_ativo.dart` | `lib/view/home/components/personagem_ativo_card.dart` |
| `HomeAppbar` | `HomeAppBar` | `lib/view/home/components/home_appbar.dart` | `lib/view/home/components/home_app_bar.dart` |
| `MenuActions` | `AcoesMenu` | `lib/view/home/components/menu_actions.dart` | `lib/view/home/components/acoes_menu.dart` |
| `MissionActive` | `MissaoAtivaCard` | `lib/view/home/components/mission_active.dart` | `lib/view/home/components/missao_ativa_card.dart` |
| `NotHero` | `SemHeroiCard` | `lib/view/home/components/not_hero.dart` | `lib/view/home/components/sem_heroi_card.dart` |

## Personagens

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `BotaoNovoHeroi` | `NovoHeroiButton` | `lib/view/characters/components/botao_novo_heroi.dart` | `lib/view/characters/components/novo_heroi_button.dart` |
| `CardPersonagem` | `PersonagemCard` | `lib/view/characters/components/card_personagem.dart` | `lib/view/characters/components/personagem_card.dart` |
| `_SeloAtiva` | `_AtivaBadge` |  |  |
| `CharactersHeader` | `PersonagensHeader` | `lib/view/characters/components/characters_header.dart` | `lib/view/characters/components/personagens_header.dart` |

## Ficha

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `AbaCombate` | `CombateTab` | `lib/view/characters/ficha/components/aba_combate.dart` | `lib/view/characters/ficha/components/combate_tab.dart` |
| `AbaDiario` | `DiarioTab` | `lib/view/characters/ficha/components/aba_diario.dart` | `lib/view/characters/ficha/components/diario_tab.dart` |
| `AbaInventario` | `InventarioTab` | `lib/view/characters/ficha/components/aba_inventario.dart` | `lib/view/characters/ficha/components/inventario_tab.dart` |
| `AbaMagias` | `MagiasTab` | `lib/view/characters/ficha/components/aba_magias.dart` | `lib/view/characters/ficha/components/magias_tab.dart` |
| `AbaPericias` | `PericiasTab` | `lib/view/characters/ficha/components/aba_pericias.dart` | `lib/view/characters/ficha/components/pericias_tab.dart` |
| `AbaResumo` | `ResumoTab` | `lib/view/characters/ficha/components/aba_resumo.dart` | `lib/view/characters/ficha/components/resumo_tab.dart` |
| `DialogoNumero` | `NumeroDialog` | `lib/view/characters/ficha/components/dialogo_numero.dart` | `lib/view/characters/ficha/components/numero_dialog.dart` |
| `FichaAbas` | `FichaTabs` | `lib/view/characters/ficha/components/ficha_abas.dart` | `lib/view/characters/ficha/components/ficha_tabs.dart` |
| `FichaCabecalho` | `FichaHeader` | `lib/view/characters/ficha/components/ficha_cabecalho.dart` | `lib/view/characters/ficha/components/ficha_header.dart` |
| `LinhaPericia` | `PericiaTile` | `lib/view/characters/ficha/components/linha_pericia.dart` | `lib/view/characters/ficha/components/pericia_tile.dart` |
| `SlotEquipamento (widget)` | `SlotEquipamentoTile` | `lib/view/characters/ficha/components/slot_equipamento.dart` | `lib/view/characters/ficha/components/slot_equipamento_tile.dart` |
| `SlotVazio` | `SlotVazioTile` |  |  |
| `_BotaoHp` | `_HpButton` |  |  |
| `_LinhaMagia` | `_MagiaTile` |  |  |

## Novo herói

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `LinhaCheck` | `CheckTile` | `lib/view/characters/new_hero/components/linha_check.dart` | `lib/view/characters/new_hero/components/check_tile.dart` |
| `_BotaoTracejado` | `_TracejadoButton` |  |  |
| `ModoAtributos` | `ModoAtributos` | `lib/view/characters/new_hero/components/passo_atributos.dart (enum)` | `lib/controller/characters/gerenciador_criacao.dart` |

## Campanha

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `CabecalhoCampanha` | `CampanhaHeader` | `lib/view/campaign/components/cabecalho_campanha.dart` | `lib/view/campaign/components/campanha_header.dart` |
| `CardCampanha` | `CampanhaCard` | `lib/view/campaign/components/card_campanha.dart` | `lib/view/campaign/components/campanha_card.dart` |
| `CardMissao` | `MissaoCard` | `lib/view/campaign/components/card_missao.dart` | `lib/view/campaign/components/missao_card.dart` |
| `DialogoCodigo` | `CodigoDialog` | `lib/view/campaign/components/dialogo_codigo.dart` | `lib/view/campaign/components/codigo_dialog.dart` |
| `SheetMissao` | `MissaoSheet` | `lib/view/campaign/components/sheet_missao.dart` | `lib/view/campaign/components/missao_sheet.dart` |
| `SheetNovaCampanha` | `NovaCampanhaSheet` | `lib/view/campaign/components/sheet_nova_campanha.dart` | `lib/view/campaign/components/nova_campanha_sheet.dart` |
| (formatos) | (formatos) | `lib/view/campaign/components/formatos.dart` | `lib/controller/campaign/formatos.dart` |
| `AbaDiarioHeroi` | `DiarioHeroiTab` | `lib/view/campaign/heroi/components/aba_diario_heroi.dart` | `lib/view/campaign/heroi/components/diario_heroi_tab.dart` |
| `AbaGrupo` | `GrupoTab` | `lib/view/campaign/heroi/components/aba_grupo.dart` | `lib/view/campaign/heroi/components/grupo_tab.dart` |
| `AbaMissoesHeroi` | `MissoesHeroiTab` | `lib/view/campaign/heroi/components/aba_missoes_heroi.dart` | `lib/view/campaign/heroi/components/missoes_heroi_tab.dart` |
| `CardMeuHeroi` | `MeuHeroiCard` | `lib/view/campaign/heroi/components/card_meu_heroi.dart` | `lib/view/campaign/heroi/components/meu_heroi_card.dart` |
| `AbaMesa` | `MesaTab` | `lib/view/campaign/mestre/components/aba_mesa.dart` | `lib/view/campaign/mestre/components/mesa_tab.dart` |
| `AbaMissoesMestre` | `MissoesMestreTab` | `lib/view/campaign/mestre/components/aba_missoes_mestre.dart` | `lib/view/campaign/mestre/components/missoes_mestre_tab.dart` |
| `AbaMundo` | `MundoTab` | `lib/view/campaign/mestre/components/aba_mundo.dart` | `lib/view/campaign/mestre/components/mundo_tab.dart` |
| `AbaNotas` | `NotasTab` | `lib/view/campaign/mestre/components/aba_notas.dart` | `lib/view/campaign/mestre/components/notas_tab.dart` |
| `AbaSessoes` | `SessoesTab` | `lib/view/campaign/mestre/components/aba_sessoes.dart` | `lib/view/campaign/mestre/components/sessoes_tab.dart` |
| `LinhaMembro` | `MembroTile` | `lib/view/campaign/mestre/components/linha_membro.dart` | `lib/view/campaign/mestre/components/membro_tile.dart` |
| `LinhaRegistro` | `RegistroTile` | `lib/view/campaign/mestre/components/linha_registro.dart` | `lib/view/campaign/mestre/components/registro_tile.dart` |
| `LinhaNpc` | `NpcTile` |  |  |
| `_SheetNpc` | `_NpcSheet` |  |  |
| `SheetDarItem` | `DarItemSheet` | `lib/view/campaign/mestre/components/sheet_dar_item.dart` | `lib/view/campaign/mestre/components/dar_item_sheet.dart` |
| `SheetDarXp` | `DarXpSheet` | `lib/view/campaign/mestre/components/sheet_dar_xp.dart` | `lib/view/campaign/mestre/components/dar_xp_sheet.dart` |
| `_SheetEncerrar` | `_EncerrarSheet` |  |  |
| `CardRecompensa` | `RecompensaCard` | `lib/view/campaign/missao/components/card_recompensa.dart` | `lib/view/campaign/missao/components/recompensa_card.dart` |
| `LinhaEntrada` | `EntradaTile` | `lib/view/campaign/missao/components/entrada_missao.dart` | `lib/view/campaign/missao/components/entrada_tile.dart` |
| `_BotaoIcone` | `_IconeButton` |  |  |
| `SheetNovaEntrada` | `NovaEntradaSheet` | `lib/view/campaign/missao/components/sheet_nova_entrada.dart` | `lib/view/campaign/missao/components/nova_entrada_sheet.dart` |
| `MissaoDetalhe` | `DetalhesMissao` | `lib/view/campaign/missao/missao_detalhe.dart` | `lib/view/campaign/missao/detalhes_missao.dart` |
| `_DialogoConcluir` | `_ConcluirDialog` |  |  |
| `RetornoMissao` | `RetornoMissao` | `lib/view/campaign/missao/missao_detalhe.dart (typedef)` | `lib/model/campanha.dart` |

## Grimório

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `MonstroDetalhe` | `DetalhesMonstro` | `lib/view/grimoire/bestiario/monstro_detalhe.dart` | `lib/view/grimoire/bestiario/detalhes_monstro.dart` |
| `ClasseDetalhe` | `DetalhesClasse` | `lib/view/grimoire/classes/classe_detalhe.dart` | `lib/view/grimoire/classes/detalhes_classe.dart` |
| `EspecieDetalhe` | `DetalhesEspecie` | `lib/view/grimoire/especies/especie_detalhe.dart` | `lib/view/grimoire/especies/detalhes_especie.dart` |
| `ItemDetalhe` | `DetalhesItem` | `lib/view/grimoire/itens/item_detalhe.dart` | `lib/view/grimoire/itens/detalhes_item.dart` |
| `MagiaDetalhe` | `DetalhesMagia` | `lib/view/grimoire/magias/magia_detalhe.dart` | `lib/view/grimoire/magias/detalhes_magia.dart` |
| `CardCategoria` | `CategoriaCard` | `lib/view/grimoire/components/card_categoria.dart` | `lib/view/grimoire/components/categoria_card.dart` |
| `LinhaCompendio` | `CompendioTile` | `lib/view/grimoire/components/linha_compendio.dart` | `lib/view/grimoire/components/compendio_tile.dart` |
| `SeloRaridade` | `RaridadeBadge` | `lib/view/grimoire/components/selo_raridade.dart` | `lib/view/grimoire/components/raridade_badge.dart` |
| `BarraVoltar` | `VoltarHeader` |  |  |
| `BotaoRodape` | `RodapeButton` |  |  |
| `_CardCondicao` | `_CondicaoCard` |  |  |

## Ajustes

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `CardPerfil` | `PerfilCard` | `lib/view/settings/components/card_perfil.dart` | `lib/view/settings/components/perfil_card.dart` |
| `LinhaAjuste` | `AjusteTile` | `lib/view/settings/components/linha_ajuste.dart` | `lib/view/settings/components/ajuste_tile.dart` |
| `SheetOpcoes` | `OpcoesSheet` | `lib/view/settings/components/sheet_opcoes.dart` | `lib/view/settings/components/opcoes_sheet.dart` |
| `SheetPerfil` | `PerfilSheet` | `lib/view/settings/components/sheet_perfil.dart` | `lib/view/settings/components/perfil_sheet.dart` |
| `_SheetCreditos` | `_CreditosSheet` |  |  |
| `mostrarSheetOpcoes` | `mostrarOpcoesSheet` |  |  |
| `mostrarSheetPerfil` | `mostrarPerfilSheet` |  |  |

## Widgets compartilhados

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
| `Etiqueta` | `Etiqueta` | `lib/view/characters/new_hero/components/etiqueta.dart` | `lib/widgets/etiqueta.dart` |

## Testes

| antigo | novo | arquivo antigo | arquivo novo |
| --- | --- | --- | --- |
|  |  | `test/model/character_test.dart` | `test/model/personagem_test.dart` |
|  |  | `test/model/campaign_test.dart` | `test/model/campanha_test.dart` |
|  |  | `test/model/campaign_mock_test.dart` | `test/model/campanha_mock_test.dart` |
|  |  | `test/model/grimoire_test.dart` | `test/model/compendio_test.dart` |
|  |  | `test/model/hero_options_test.dart` | `test/model/opcoes_heroi_test.dart` |
