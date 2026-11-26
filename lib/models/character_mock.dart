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
  donoId: 'u_gustavo',
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

const thorgarMock = Character(
  id: 'thorgar',
  nome: 'Thorgar',
  retrato: AppImages.especieAnaoM,
  especie: 'Anão',
  classes: [
    CharacterClass(
      apiKey: 'srd_barbarian',
      nome: 'Bárbaro',
      nivel: 5,
      dadoDeVida: 12,
    ),
  ],
  atributos: AbilityScores(
    forca: 18,
    destreza: 12,
    constituicao: 16,
    inteligencia: 8,
    sabedoria: 12,
    carisma: 10,
  ),
  xp: 7800,
  hpMax: 61,
  hpAtual: 52,
  ca: 15,
  deslocamentoM: 7.5,
  salvaguardas: {Ability.forca, Ability.constituicao},
  pericias: {'Atletismo', 'Intimidação'},
  campanhaId: 'sombras-de-valfenda',
  donoId: 'u_ana',
);

const mirelaMock = Character(
  id: 'mirela',
  nome: 'Mirela',
  retrato: AppImages.especieTieflingF,
  especie: 'Tiefling',
  classes: [
    CharacterClass(
      apiKey: 'srd_warlock',
      nome: 'Bruxa',
      nivel: 5,
      dadoDeVida: 8,
    ),
  ],
  atributos: AbilityScores(
    forca: 8,
    destreza: 14,
    constituicao: 14,
    inteligencia: 12,
    sabedoria: 10,
    carisma: 18,
  ),
  xp: 14200,
  hpMax: 38,
  hpAtual: 23,
  ca: 13,
  deslocamentoM: 9,
  salvaguardas: {Ability.sabedoria, Ability.carisma},
  pericias: {'Arcanismo', 'Enganação'},
  espacosDeMagia: [SpellSlot(circulo: 3, total: 2, usados: 1)],
  campanhaId: 'sombras-de-valfenda',
  donoId: 'u_caio',
);

const kaelMock = Character(
  id: 'kael',
  nome: 'Kael',
  retrato: AppImages.especieHumanoM,
  especie: 'Humano',
  classes: [
    CharacterClass(
      apiKey: 'srd_rogue',
      nome: 'Ladino',
      nivel: 1,
      dadoDeVida: 8,
    ),
  ],
  atributos: AbilityScores(
    forca: 10,
    destreza: 16,
    constituicao: 12,
    inteligencia: 13,
    sabedoria: 12,
    carisma: 14,
  ),
  xp: 0,
  hpMax: 9,
  hpAtual: 9,
  ca: 14,
  deslocamentoM: 9,
  salvaguardas: {Ability.destreza, Ability.inteligencia},
  pericias: {'Furtividade', 'Prestidigitação'},
  campanhaId: 'o-trono-de-cinzas',
  donoId: 'u_lia',
);

// Só os heróis do usuário (donoId 'u_gustavo'): é o que a aba Heróis mostra.
const personagensMock = [personagemAtivoMock];

// Todos os heróis das campanhas, inclusive os de outros jogadores.
const todosPersonagensMock = [
  personagemAtivoMock,
  thorgarMock,
  mirelaMock,
  kaelMock,
];
