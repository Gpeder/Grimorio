import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/grimoire.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/models/hero_options_mock.dart';

// magiasMock repete magias que estão em mais de uma lista de classe.
final magiasCompendio = [
  ...{for (final m in magiasMock) m.key: m}.values,
];

const monstrosMock = [
  Monstro(
    key: 'goblin',
    nome: 'Goblin',
    tipo: 'Humanoide',
    tamanho: 'Pequeno',
    alinhamento: 'neutro e mau',
    nd: '1/4',
    xp: 50,
    ca: 15,
    caDetalhe: 'armadura de couro, escudo',
    pv: 7,
    pvDado: '2d6',
    deslocamento: '9 m',
    atributos: AbilityScores(
      forca: 8,
      destreza: 14,
      constituicao: 10,
      inteligencia: 10,
      sabedoria: 8,
      carisma: 8,
    ),
    sentidos: ['visão no escuro 18 m', 'Percepção passiva 9'],
    idiomas: ['Comum', 'Goblin'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(
        nome: 'Fuga Ágil',
        descricao:
            'Pode usar a ação Desengajar ou Esconder como ação bônus em cada '
            'um dos seus turnos.',
      ),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Cimitarra',
        descricao: 'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo.',
        ataque: '+4 para acertar',
        dano: '1d6 + 2 cortante',
      ),
      AcaoMonstro(
        nome: 'Arco Curto',
        descricao: 'Ataque à distância com arma, distância 24/96 m, um alvo.',
        ataque: '+4 para acertar',
        dano: '1d6 + 2 perfurante',
      ),
    ],
  ),
  Monstro(
    key: 'esqueleto',
    nome: 'Esqueleto',
    tipo: 'Morto-vivo',
    tamanho: 'Médio',
    alinhamento: 'leal e mau',
    nd: '1/4',
    xp: 50,
    ca: 13,
    caDetalhe: 'restos de armadura',
    pv: 13,
    pvDado: '2d8 + 4',
    deslocamento: '9 m',
    atributos: AbilityScores(
      forca: 10,
      destreza: 14,
      constituicao: 15,
      inteligencia: 6,
      sabedoria: 8,
      carisma: 5,
    ),
    sentidos: ['visão no escuro 18 m', 'Percepção passiva 9'],
    idiomas: ['entende os idiomas que sabia em vida, mas não fala'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(
        nome: 'Corpo de Ossos',
        descricao:
            'Vulnerável a dano contundente. Imune a dano de veneno, à '
            'exaustão e à condição envenenado.',
      ),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Espada Curta',
        descricao: 'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo.',
        ataque: '+4 para acertar',
        dano: '1d6 + 2 perfurante',
      ),
      AcaoMonstro(
        nome: 'Arco Curto',
        descricao: 'Ataque à distância com arma, distância 24/96 m, um alvo.',
        ataque: '+4 para acertar',
        dano: '1d6 + 2 perfurante',
      ),
    ],
  ),
  Monstro(
    key: 'lobo',
    nome: 'Lobo',
    tipo: 'Fera',
    tamanho: 'Média',
    alinhamento: 'sem alinhamento',
    nd: '1/4',
    xp: 50,
    ca: 13,
    caDetalhe: 'armadura natural',
    pv: 11,
    pvDado: '2d8 + 2',
    deslocamento: '12 m',
    atributos: AbilityScores(
      forca: 12,
      destreza: 15,
      constituicao: 12,
      inteligencia: 3,
      sabedoria: 12,
      carisma: 6,
    ),
    sentidos: ['Percepção passiva 13'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(
        nome: 'Audição e Faro Aguçados',
        descricao:
            'Tem vantagem em testes de Sabedoria (Percepção) que dependem de '
            'audição ou olfato.',
      ),
      AcaoMonstro(
        nome: 'Tática de Matilha',
        descricao:
            'Tem vantagem nas jogadas de ataque contra uma criatura se ao '
            'menos um aliado não incapacitado estiver a até 1,5 m dela.',
      ),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Mordida',
        descricao:
            'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo. Se o alvo '
            'for uma criatura, faz uma salvaguarda de Força CD 11 ou cai.',
        ataque: '+4 para acertar',
        dano: '2d4 + 2 perfurante',
      ),
    ],
  ),
  Monstro(
    key: 'zumbi',
    nome: 'Zumbi',
    tipo: 'Morto-vivo',
    tamanho: 'Médio',
    alinhamento: 'neutro e mau',
    nd: '1/4',
    xp: 50,
    ca: 8,
    caDetalhe: '',
    pv: 22,
    pvDado: '3d8 + 9',
    deslocamento: '6 m',
    atributos: AbilityScores(
      forca: 13,
      destreza: 6,
      constituicao: 16,
      inteligencia: 3,
      sabedoria: 6,
      carisma: 5,
    ),
    sentidos: ['visão no escuro 18 m', 'Percepção passiva 8'],
    idiomas: ['entende os idiomas que sabia em vida, mas não fala'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(
        nome: 'Fortitude de Morto-vivo',
        descricao:
            'Se o dano reduzir o zumbi a 0 PV, ele faz uma salvaguarda de '
            'Constituição com CD 5 + o dano sofrido, a menos que o dano seja '
            'radiante ou de um acerto crítico. Se passar, fica com 1 PV.',
      ),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Pancada',
        descricao: 'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo.',
        ataque: '+3 para acertar',
        dano: '1d6 + 1 contundente',
      ),
    ],
  ),
  Monstro(
    key: 'orc',
    nome: 'Orc',
    tipo: 'Humanoide',
    tamanho: 'Médio',
    alinhamento: 'caótico e mau',
    nd: '1/2',
    xp: 100,
    ca: 13,
    caDetalhe: 'armadura de peles',
    pv: 15,
    pvDado: '2d8 + 6',
    deslocamento: '9 m',
    atributos: AbilityScores(
      forca: 16,
      destreza: 12,
      constituicao: 16,
      inteligencia: 7,
      sabedoria: 11,
      carisma: 10,
    ),
    sentidos: ['visão no escuro 18 m', 'Percepção passiva 10'],
    idiomas: ['Comum', 'Orc'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(
        nome: 'Agressivo',
        descricao:
            'Como ação bônus, pode se mover até o seu deslocamento em direção '
            'a uma criatura hostil que possa ver.',
      ),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Machado Grande',
        descricao: 'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo.',
        ataque: '+5 para acertar',
        dano: '1d12 + 3 cortante',
      ),
      AcaoMonstro(
        nome: 'Azagaia',
        descricao:
            'Ataque corpo a corpo ou à distância com arma, alcance 1,5 m ou '
            'distância 9/36 m, um alvo.',
        ataque: '+5 para acertar',
        dano: '1d6 + 3 perfurante',
      ),
    ],
  ),
  Monstro(
    key: 'lobo_atroz',
    nome: 'Lobo Atroz',
    tipo: 'Fera',
    tamanho: 'Grande',
    alinhamento: 'sem alinhamento',
    nd: '1',
    xp: 200,
    ca: 14,
    caDetalhe: 'armadura natural',
    pv: 37,
    pvDado: '5d10 + 10',
    deslocamento: '15 m',
    atributos: AbilityScores(
      forca: 17,
      destreza: 15,
      constituicao: 15,
      inteligencia: 3,
      sabedoria: 12,
      carisma: 7,
    ),
    sentidos: ['Percepção passiva 13'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(
        nome: 'Audição e Faro Aguçados',
        descricao:
            'Tem vantagem em testes de Sabedoria (Percepção) que dependem de '
            'audição ou olfato.',
      ),
      AcaoMonstro(
        nome: 'Tática de Matilha',
        descricao:
            'Tem vantagem nas jogadas de ataque contra uma criatura se ao '
            'menos um aliado não incapacitado estiver a até 1,5 m dela.',
      ),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Mordida',
        descricao:
            'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo. Se o alvo '
            'for uma criatura, faz uma salvaguarda de Força CD 13 ou cai.',
        ataque: '+5 para acertar',
        dano: '2d6 + 3 perfurante',
      ),
    ],
  ),
  Monstro(
    key: 'ogro',
    nome: 'Ogro',
    tipo: 'Gigante',
    tamanho: 'Grande',
    alinhamento: 'caótico e mau',
    nd: '2',
    xp: 450,
    ca: 11,
    caDetalhe: 'armadura de peles',
    pv: 59,
    pvDado: '7d10 + 21',
    deslocamento: '12 m',
    atributos: AbilityScores(
      forca: 19,
      destreza: 8,
      constituicao: 16,
      inteligencia: 5,
      sabedoria: 7,
      carisma: 7,
    ),
    sentidos: ['visão no escuro 18 m', 'Percepção passiva 8'],
    idiomas: ['Comum', 'Gigante'],
    imagem: AppImages.menuBestiario,
    acoes: [
      AcaoMonstro(
        nome: 'Clava Grande',
        descricao: 'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo.',
        ataque: '+6 para acertar',
        dano: '2d8 + 4 contundente',
      ),
      AcaoMonstro(
        nome: 'Azagaia',
        descricao:
            'Ataque corpo a corpo ou à distância com arma, alcance 1,5 m ou '
            'distância 9/36 m, um alvo.',
        ataque: '+6 para acertar',
        dano: '2d6 + 4 perfurante',
      ),
    ],
  ),
  Monstro(
    key: 'jovem_dragao_verde',
    nome: 'Jovem Dragão Verde',
    tipo: 'Dragão',
    tamanho: 'Grande',
    alinhamento: 'leal e mau',
    nd: '8',
    xp: 3900,
    ca: 18,
    caDetalhe: 'armadura natural',
    pv: 136,
    pvDado: '16d10 + 48',
    deslocamento: '12 m, voo 24 m, natação 12 m',
    atributos: AbilityScores(
      forca: 19,
      destreza: 12,
      constituicao: 17,
      inteligencia: 16,
      sabedoria: 13,
      carisma: 15,
    ),
    sentidos: [
      'percepção às cegas 9 m',
      'visão no escuro 36 m',
      'Percepção passiva 17',
    ],
    idiomas: ['Comum', 'Dracônico'],
    imagem: AppImages.menuBestiario,
    tracos: [
      AcaoMonstro(nome: 'Anfíbio', descricao: 'Pode respirar ar e água.'),
    ],
    acoes: [
      AcaoMonstro(
        nome: 'Ataques Múltiplos',
        descricao: 'Faz três ataques: um com a mordida e dois com as garras.',
      ),
      AcaoMonstro(
        nome: 'Mordida',
        descricao: 'Ataque corpo a corpo com arma, alcance 3 m, um alvo.',
        ataque: '+7 para acertar',
        dano: '2d10 + 4 perfurante + 2d6 veneno',
      ),
      AcaoMonstro(
        nome: 'Garra',
        descricao: 'Ataque corpo a corpo com arma, alcance 1,5 m, um alvo.',
        ataque: '+7 para acertar',
        dano: '2d6 + 4 cortante',
      ),
      AcaoMonstro(
        nome: 'Sopro Venenoso (Recarga 5–6)',
        descricao:
            'Exala gás venenoso num cone de 9 m. Cada criatura na área faz '
            'uma salvaguarda de Constituição: sofre o dano completo se '
            'falhar, ou metade se passar.',
        ataque: 'Salv. CON CD 14',
        dano: '12d6 veneno',
      ),
    ],
  ),
];

const _itensMagicos = [
  ItemCompendio(
    key: 'pocao_cura',
    nome: 'Poção de Cura',
    categoria: 'Poção',
    raridade: Raridade.comum,
    descricao: 'Você recupera 2d4 + 2 pontos de vida ao beber esta poção.',
    imagem: AppImages.pocao1,
  ),
  ItemCompendio(
    key: 'pocao_cura_maior',
    nome: 'Poção de Cura Maior',
    categoria: 'Poção',
    raridade: Raridade.incomum,
    descricao: 'Você recupera 4d4 + 4 pontos de vida ao beber esta poção.',
    imagem: AppImages.pocao5,
  ),
  ItemCompendio(
    key: 'capa_elfica',
    nome: 'Capa Élfica',
    categoria: 'Item maravilhoso',
    raridade: Raridade.incomum,
    sintonia: true,
    descricao:
        'Com o capuz levantado, testes de Sabedoria (Percepção) para ver você '
        'têm desvantagem, e você tem vantagem em testes de Destreza '
        '(Furtividade) para se esconder.',
    imagem: AppImages.capa,
  ),
  ItemCompendio(
    key: 'bolsa_devoradora',
    nome: 'Bolsa Devoradora',
    categoria: 'Item maravilhoso',
    raridade: Raridade.incomum,
    descricao:
        'O espaço interno é bem maior que o externo: cabe até 250 kg, sem '
        'passar de 1,8 m³, e a bolsa sempre pesa 7 kg. Se for rasgada, ela se '
        'destrói e o conteúdo vai parar no Plano Astral.',
    imagem: AppImages.menuBolsa,
  ),
  ItemCompendio(
    key: 'anel_protecao',
    nome: 'Anel de Proteção',
    categoria: 'Anel',
    raridade: Raridade.raro,
    sintonia: true,
    descricao: 'Você recebe +1 na CA e nas salvaguardas enquanto usa o anel.',
    imagem: AppImages.anel,
  ),
  ItemCompendio(
    key: 'amuleto_saude',
    nome: 'Amuleto de Saúde',
    categoria: 'Item maravilhoso',
    raridade: Raridade.raro,
    sintonia: true,
    descricao:
        'Sua Constituição passa a ser 19 enquanto usa o amuleto. Não tem '
        'efeito se ela já for 19 ou mais.',
    imagem: AppImages.colar,
  ),
  ItemCompendio(
    key: 'arma_mais_3',
    nome: 'Arma +3',
    categoria: 'Arma',
    raridade: Raridade.muitoRaro,
    descricao:
        'Você recebe +3 nas jogadas de ataque e de dano feitas com esta arma '
        'mágica.',
    imagem: AppImages.arma02,
  ),
  ItemCompendio(
    key: 'espada_vorpal',
    nome: 'Espada Vorpal',
    categoria: 'Arma',
    raridade: Raridade.lendario,
    sintonia: true,
    descricao:
        'Você recebe +3 nas jogadas de ataque e de dano com esta espada, que '
        'ignora resistência a dano cortante. Num 20 natural contra uma '
        'criatura com cabeça, ela é decapitada, a menos que seja imune a '
        'dano cortante ou não precise da cabeça.',
    imagem: AppImages.arma01,
  ),
];

String _peso(double kg) {
  final texto = kg == kg.roundToDouble()
      ? '${kg.round()}'
      : '$kg'.replaceAll('.', ',');
  return '$texto kg';
}

ItemCompendio _deEquipamento(EquipmentItem e) {
  final categoria = switch (e) {
    EquipmentItem(armadura: TipoArmadura.escudo) => 'Escudo',
    EquipmentItem(armadura: _?) => 'Armadura',
    EquipmentItem(dano: _?) => 'Arma',
    _ when e.key.startsWith('pacote') => 'Pacote',
    _ => 'Equipamento',
  };
  final regra = switch (e.armadura) {
    TipoArmadura.couro => 'Armadura leve: CA 11 + DES.',
    TipoArmadura.escamas => 'Armadura média: CA 14 + DES (máx. 2).',
    TipoArmadura.malha => 'Armadura pesada: CA 16.',
    TipoArmadura.escudo => '+2 na CA.',
    null when e.dano != null => 'Dano ${e.dano} ${e.tipoDano ?? ''}'.trim(),
    null => null,
  };
  return ItemCompendio(
    key: e.key,
    nome: e.nome,
    categoria: categoria,
    raridade: Raridade.comum,
    descricao: [?regra, 'Peso ${_peso(e.pesoKg)}.'].join(' '),
    imagem: e.imagem,
    magico: false,
  );
}

final itensMock = [
  ..._itensMagicos,
  ...{
    for (final c in classesMock)
      for (final e in [
        for (final escolha in c.equipamento) ...escolha.opcoes,
        ...c.sempreIncluso,
      ])
        e.key: _deEquipamento(e),
  }.values,
];

const condicoesMock = [
  CondicaoInfo(
    nome: 'Agarrado',
    descricao:
        'O deslocamento vira 0 e não recebe bônus de deslocamento. A condição '
        'acaba se quem agarra ficar incapacitado ou se um efeito tirar a '
        'criatura do alcance dele.',
  ),
  CondicaoInfo(
    nome: 'Amedrontado',
    descricao:
        'Tem desvantagem em testes de atributo e jogadas de ataque enquanto a '
        'fonte do medo estiver à vista. Não pode se aproximar dela por '
        'vontade própria.',
  ),
  CondicaoInfo(
    nome: 'Atordoado',
    descricao:
        'Fica incapacitado, não pode se mover e só fala com dificuldade. '
        'Falha em salvaguardas de Força e Destreza, e ataques contra ele têm '
        'vantagem.',
  ),
  CondicaoInfo(
    nome: 'Caído',
    descricao:
        'Só se move rastejando, a menos que se levante, e tem desvantagem nas '
        'jogadas de ataque. Ataques contra ele têm vantagem a até 1,5 m e '
        'desvantagem de mais longe.',
  ),
  CondicaoInfo(
    nome: 'Cego',
    descricao:
        'Não enxerga e falha em testes que dependem da visão. Ataques contra '
        'ele têm vantagem, e os ataques dele têm desvantagem.',
  ),
  CondicaoInfo(
    nome: 'Contido',
    descricao:
        'O deslocamento vira 0. Ataques contra ele têm vantagem, os ataques '
        'dele têm desvantagem, e ele tem desvantagem em salvaguardas de '
        'Destreza.',
  ),
  CondicaoInfo(
    nome: 'Enfeitiçado',
    descricao:
        'Não pode atacar quem o enfeitiçou nem mirá-lo com habilidades ou '
        'efeitos mágicos nocivos. Quem enfeitiçou tem vantagem em testes de '
        'atributo para interagir socialmente com ele.',
  ),
  CondicaoInfo(
    nome: 'Envenenado',
    descricao: 'Desvantagem em jogadas de ataque e testes de atributo.',
  ),
  CondicaoInfo(
    nome: 'Exausto',
    descricao:
        'A exaustão tem seis níveis, e os efeitos se acumulam. Um descanso '
        'longo, com comida e bebida, reduz um nível.',
    niveis: [
      '1 · desvantagem em testes de atributo',
      '2 · deslocamento cai pela metade',
      '3 · desvantagem em ataques e salvaguardas',
      '4 · PV máximo cai pela metade',
      '5 · deslocamento vira 0',
      '6 · morte',
    ],
  ),
  CondicaoInfo(
    nome: 'Incapacitado',
    descricao: 'Não pode realizar ações nem reações.',
  ),
  CondicaoInfo(
    nome: 'Inconsciente',
    descricao:
        'Fica incapacitado, não se move nem fala e não percebe o ambiente; '
        'larga o que segura e cai. Falha em salvaguardas de Força e Destreza, '
        'ataques contra ele têm vantagem, e acertos a até 1,5 m são críticos.',
  ),
  CondicaoInfo(
    nome: 'Invisível',
    descricao:
        'Não pode ser visto sem magia ou sentido especial; para se esconder, '
        'conta como se estivesse em escuridão densa. Ataques contra ele têm '
        'desvantagem, e os ataques dele têm vantagem.',
  ),
  CondicaoInfo(
    nome: 'Paralisado',
    descricao:
        'Fica incapacitado e não pode se mover nem falar. Falha em '
        'salvaguardas de Força e Destreza, ataques contra ele têm vantagem, e '
        'acertos a até 1,5 m são críticos.',
  ),
  CondicaoInfo(
    nome: 'Petrificado',
    descricao:
        'Vira, com o que carrega, uma substância sólida e inanimada, '
        'geralmente pedra, e fica incapacitado. Tem resistência a todo dano e '
        'é imune a veneno e doença. Falha em salvaguardas de Força e '
        'Destreza, e ataques contra ele têm vantagem.',
  ),
  CondicaoInfo(
    nome: 'Surdo',
    descricao: 'Não ouve e falha em testes que dependem da audição.',
  ),
];

// Papel e atributo principal, para o cabeçalho da classe.
const papelDaClasse = {
  'srd_barbarian': 'Combatente',
  'srd_bard': 'Conjurador arcano',
  'srd_cleric': 'Conjurador divino',
  'srd_druid': 'Conjurador da natureza',
  'srd_fighter': 'Combatente',
  'srd_monk': 'Artista marcial',
  'srd_paladin': 'Guerreiro sagrado',
  'srd_ranger': 'Caçador',
  'srd_rogue': 'Especialista',
  'srd_sorcerer': 'Conjurador arcano',
  'srd_warlock': 'Conjurador de pacto',
  'srd_wizard': 'Conjurador arcano',
};

// Subclasses que existem só nos livros (têm imagem, mas não estão no mock).
const subclassesLivro = <String, List<(String, String)>>{
  'srd_barbarian': [
    ('Berserker', AppImages.barbaroBerserker),
    ('Besta', AppImages.barbaroBesta),
    ('Gigante', AppImages.barbaroGigante),
    ('Guardião Ancestral', AppImages.barbaroGuardiaoAncestral),
    ('Magia Selvagem', AppImages.barbaroMagiaSelvagem),
    ('Totem', AppImages.barbaroTotem),
    ('Zelote', AppImages.barbaroZelote),
  ],
  'srd_bard': [
    ('Bravura', AppImages.bardoBravura),
    ('Eloquência', AppImages.bardoColegioEloquencia),
    ('Glamour', AppImages.bardoColegioGlamour),
    ('Saber', AppImages.bardoColegioSaber),
    ('Valentia', AppImages.bardoColegioValentia),
    ('Conhecimento', AppImages.bardoConhecimento),
    ('Criação', AppImages.bardoCriacao),
    ('Dança', AppImages.bardoDanca),
    ('Espadas', AppImages.bardoEspadas),
    ('Sussurros', AppImages.bardoSussurros),
  ],
  'srd_cleric': [
    ('Vida', AppImages.clericoDominioVida),
    ('Luz', AppImages.clericoDominioLuz),
    ('Tempestade', AppImages.clericoTempestade),
    ('Guerra', AppImages.clericoDominioGuerra),
    ('Conhecimento', AppImages.clericoConhecimento),
    ('Trapaça', AppImages.clericoDominioTrapaca),
    ('Forja', AppImages.clericoForja),
    ('Morte', AppImages.clericoMorte),
    ('Natureza', AppImages.clericoNatureza),
    ('Ordem', AppImages.clericoOrdem),
    ('Paz', AppImages.clericoPaz),
    ('Sepultura', AppImages.clericoSepultura),
  ],
  'srd_druid': [
    ('Feras', AppImages.druidaCirculoFeras),
    ('Lua', AppImages.druidaCirculoLua),
    ('Sonhos', AppImages.druidaCirculoSonho),
    ('Terra', AppImages.druidaCirculoTerra),
    ('Esporos', AppImages.druidaEsporos),
    ('Estrelas', AppImages.druidaEstrelas),
    ('Fogo Selvagem', AppImages.druidaFogoSelvagem),
    ('Mar', AppImages.druidaMar),
    ('Pastor', AppImages.druidaPastor),
  ],
  'srd_fighter': [
    ('Campeão', AppImages.guerreiroCampeao),
    ('Cavaleiro', AppImages.guerreiroCavaleiro),
    ('Cavaleiro Místico', AppImages.guerreiroCavaleiroMistico),
    ('Dragão Púrpura', AppImages.guerreiroDragaoPurpura),
    ('Eco', AppImages.guerreiroEco),
    ('Mestre de Batalha', AppImages.guerreiroMestreBatalha),
    ('Psiônico', AppImages.guerreiroPsionico),
    ('Rúnico', AppImages.guerreiroRunico),
    ('Samurai', AppImages.guerreiroSamurai),
  ],
  'srd_monk': [
    ('Alma Solar', AppImages.mongeAlmaSolar),
    ('Astral', AppImages.mongeAstral),
    ('Dragão Ascendente', AppImages.mongeDragaoAscendente),
    ('Kensei', AppImages.mongeKensei),
    ('Mão Aberta', AppImages.mongeMaoAberta),
    ('Mestre Bêbado', AppImages.mongeMestreBebado),
    ('Misericórdia', AppImages.mongeMisericordia),
    ('Quatro Elementos', AppImages.mongeQuatroElementos),
    ('Sombra', AppImages.mongeSombra),
  ],
  'srd_paladin': [
    ('Anciões', AppImages.paladinoAncioes),
    ('Conquista', AppImages.paladinoConquista),
    ('Coroa', AppImages.paladinoCoroa),
    ('Devoção', AppImages.paladinoDevocao),
    ('Glória', AppImages.paladinoGloria),
    ('Pacto Quebrado', AppImages.paladinoPactoQuebrado),
    ('Redenção', AppImages.paladinoRedencao),
    ('Vigilantes', AppImages.paladinoVigilantes),
    ('Vingança', AppImages.paladinoVinganca),
  ],
  'srd_ranger': [
    ('Andarilho Dracônico', AppImages.patrulheiroAndarilhoDraconico),
    ('Andarilho Feérico', AppImages.patrulheiroAndarilhoFeerico),
    ('Andarilho do Horizonte', AppImages.patrulheiroAndarilhoHorizonte),
    ('Caçador', AppImages.patrulheiroCacador),
    ('Guardião do Enxame', AppImages.patrulheiroGuardiaoEnxame),
    ('Matador de Monstros', AppImages.patrulheiroMatadorMonstros),
    ('Mestre das Feras', AppImages.patrulheiroMestreFeras),
    ('Perseguidor Sombrio', AppImages.patrulheiroPerseguidorSombrio),
  ],
  'srd_rogue': [
    ('Assassino', AppImages.ladinoAssassino),
    ('Batedor', AppImages.ladinoBatedor),
    ('Espadachim', AppImages.ladinoEspadachim),
    ('Espião', AppImages.ladinoEspiao),
    ('Fantasma', AppImages.ladinoFantasma),
    ('Inquisitivo', AppImages.ladinoInquisitivo),
    ('Ladrão', AppImages.ladinoLadrao),
    ('Lâmina da Alma', AppImages.ladinoLaminaAlma),
    ('Mentor', AppImages.ladinoMentor),
    ('Trapaceiro Arcano', AppImages.ladinoTrapaceiroArcano),
  ],
  'srd_sorcerer': [
    ('Dracônica', AppImages.feiticeiroDraconica),
    ('Selvagem', AppImages.feiticeiroSelvagem),
    ('Alma Mecânica', AppImages.feiticeiroAlmaMecanica),
    ('Divina', AppImages.feiticeiroDivina),
    ('Lunar', AppImages.feiticeiroLunar),
    ('Mente Aberrante', AppImages.feiticeiroMenteAberrante),
    ('Sombras', AppImages.feiticeiroSombras),
    ('Tempestade', AppImages.feiticeiroTempestade),
  ],
  'srd_warlock': [
    ('Corruptor', AppImages.bruxoCorruptor),
    ('Arquifada', AppImages.bruxoArquifada),
    ('Grande Antigo', AppImages.bruxoGrandeAntigo),
    ('Abissal', AppImages.bruxoAbissal),
    ('Celestial', AppImages.bruxoCelestial),
    ('Gênio', AppImages.bruxoGenio),
    ('Imortal', AppImages.bruxoImortal),
    ('Lâmina Maldita', AppImages.bruxoLaminaMaldita),
    ('Morto-vivo', AppImages.bruxoMortoVivo),
  ],
  'srd_wizard': [
    ('Abjuração', AppImages.magoAbjuracao),
    ('Adivinhação', AppImages.magoAdivinhacao),
    ('Conjuração', AppImages.magoConjuracao),
    ('Encantamento', AppImages.magoEncantamento),
    ('Evocação', AppImages.magoEvocacao),
    ('Ilusão', AppImages.magoIlusao),
    ('Necromancia', AppImages.magoNecromancia),
    ('Transmutação', AppImages.magoTransmutacao),
    ('Cantor da Lâmina', AppImages.magoCantorLamina),
    ('Cronurgia', AppImages.magoCronurgia),
    ('Escribas', AppImages.magoEscribas),
    ('Graviturgia', AppImages.magoGraviturgia),
    ('Guerra', AppImages.magoGuerra),
  ],
};

// Espaços por nível (índice 0 = nível 1), do 1º ao 9º círculo.
const _conjuradorCompleto = [
  [2],
  [3],
  [4, 2],
  [4, 3],
  [4, 3, 2],
  [4, 3, 3],
  [4, 3, 3, 1],
  [4, 3, 3, 2],
  [4, 3, 3, 3, 1],
  [4, 3, 3, 3, 2],
  [4, 3, 3, 3, 2, 1],
  [4, 3, 3, 3, 2, 1],
  [4, 3, 3, 3, 2, 1, 1],
  [4, 3, 3, 3, 2, 1, 1],
  [4, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 2, 1, 1, 1, 1],
  [4, 3, 3, 3, 3, 1, 1, 1, 1],
  [4, 3, 3, 3, 3, 2, 1, 1, 1],
  [4, 3, 3, 3, 3, 2, 2, 1, 1],
];

const _meioConjurador = [
  <int>[],
  [2],
  [3],
  [3],
  [4, 2],
  [4, 2],
  [4, 3],
  [4, 3],
  [4, 3, 2],
  [4, 3, 2],
  [4, 3, 3],
  [4, 3, 3],
  [4, 3, 3, 1],
  [4, 3, 3, 1],
  [4, 3, 3, 2],
  [4, 3, 3, 2],
  [4, 3, 3, 3, 1],
  [4, 3, 3, 3, 1],
  [4, 3, 3, 3, 2],
  [4, 3, 3, 3, 2],
];

// Magia de pacto: (quantidade, círculo).
const _pacto = [
  (1, 1),
  (2, 1),
  (2, 2),
  (2, 2),
  (2, 3),
  (2, 3),
  (2, 4),
  (2, 4),
  (2, 5),
  (2, 5),
  (3, 5),
  (3, 5),
  (3, 5),
  (3, 5),
  (3, 5),
  (3, 5),
  (4, 5),
  (4, 5),
  (4, 5),
  (4, 5),
];

const _completos = {
  'srd_bard',
  'srd_cleric',
  'srd_druid',
  'srd_sorcerer',
  'srd_wizard',
};
const _meios = {'srd_paladin', 'srd_ranger'};

String espacosNoNivel(String classeKey, int nivel) {
  final i = nivel - 1;
  if (classeKey == 'srd_warlock') {
    final (qtde, circulo) = _pacto[i];
    return '$qtde × $circuloº';
  }
  final espacos = _completos.contains(classeKey)
      ? _conjuradorCompleto[i]
      : _meios.contains(classeKey)
      ? _meioConjurador[i]
      : const <int>[];
  return espacos.isEmpty ? '—' : espacos.join(' · ');
}

int proficienciaNoNivel(int nivel) => 2 + (nivel - 1) ~/ 4;
