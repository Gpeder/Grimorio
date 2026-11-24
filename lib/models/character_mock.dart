import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/models/character.dart';

const personagemAtivoMock = Character(
  id: 'elyndra',
  nome: 'Elyndra',
  retrato: AppImages.especieHumanoF,
  especie: 'Humana',
  classes: [
    CharacterClass(
      apiKey: 'srd_cleric',
      nome: 'Clériga',
      nivel: 5,
      dadoDeVida: 8,
      subclasse: 'Domínio da Vida',
    ),
  ],
  atributos: AbilityScores(
    forca: 12,
    destreza: 10,
    constituicao: 14,
    inteligencia: 10,
    sabedoria: 18,
    carisma: 13,
  ),
  xp: 6500,
  hpMax: 38,
  hpAtual: 32,
  ca: 16,
  deslocamentoM: 9,
  salvaguardas: {Ability.sabedoria, Ability.carisma},
  pericias: {'Intuição', 'Medicina', 'Religião'},
  espacosDeMagia: [
    SpellSlot(circulo: 1, total: 4, usados: 1),
    SpellSlot(circulo: 2, total: 3),
    SpellSlot(circulo: 3, total: 2, usados: 2),
  ],
  inventario: [
    InventoryItem(
      id: 'maca',
      nome: 'Maça',
      imagem: AppImages.arma02,
      pesoKg: 2,
      equipadoEm: EquipSlot.maoPrincipal,
      dano: '1d6',
      tipoDano: 'contundente',
      descricao: 'Arma simples de corpo a corpo.',
    ),
    InventoryItem(
      id: 'cota_escamas',
      nome: 'Cota de escamas',
      imagem: AppImages.armaduraMedio,
      pesoKg: 22.5,
      equipadoEm: EquipSlot.armadura,
      descricao: 'Armadura média. CA 14 + DES (máx. 2).',
    ),
    InventoryItem(
      id: 'escudo',
      nome: 'Escudo',
      imagem: AppImages.elmoPesado,
      pesoKg: 3,
      equipadoEm: EquipSlot.maoSecundaria,
      bonusCa: 2,
      descricao: '+2 na CA enquanto empunhado.',
    ),
    InventoryItem(
      id: 'pocao_cura',
      nome: 'Poção de cura',
      imagem: AppImages.pocao1,
      quantidade: 3,
      pesoKg: 0.25,
      consumivel: true,
      descricao: 'Cura 2d4 + 2.',
    ),
  ],
  condicoes: [Condition(nome: 'Envenenada', rodadas: 2)],
  moedas: Moedas(ouro: 12, prata: 34, cobre: 8),
  campanhaId: 'sombras-de-valfenda',
  ativo: true,
  antecedente: 'Acólito',
  alinhamento: 'Neutro e Bom',
  idiomas: {'Comum', 'Élfico', 'Celestial'},
  historia:
      'Criada no templo de Valfenda, Elyndra deixou o claustro quando as '
      'sombras chegaram às vilas do vale.',
  magias: {
    'chama_sagrada',
    'luz',
    'taumaturgia',
    'bencao',
    'curar_ferimentos',
    'palavra_curativa',
    'escudo_da_fe',
    'comando',
    'raio_guia',
    'detectar_magia',
  },
  magiasPreparadas: {
    'bencao',
    'curar_ferimentos',
    'palavra_curativa',
    'escudo_da_fe',
    'comando',
    'raio_guia',
  },
  inspiracao: true,
  notas: [
    Nota.fixa(
      id: 'nota-1',
      titulo: 'O sino de Valfenda',
      texto:
          'O sino do templo tocou sozinho à meia-noite. O velho Bram jura '
          'que viu uma silhueta na torre.',
      dataMs: 1794668400000,
    ),
    Nota.fixa(
      id: 'nota-2',
      titulo: 'Dívida com Kael',
      texto: 'Devo 15 PO ao Kael pela corda e pelas tochas.',
      dataMs: 1795273200000,
    ),
  ],
);

const personagensMock = [personagemAtivoMock];
