import 'package:grimorio/app/log/app_log.dart';

// textos fixos do srd em pt-br, nome e descricao ficam em ingles
class TraducaoSrd {
  static const vazio = '—';

  // cada valor sem traducao loga uma vez so
  static final _avisados = <String>{};

  static String escola(String? valor) => _traduzir(_escolas, valor);
  static String tipoMonstro(String? valor) => _traduzir(_tiposMonstro, valor);
  static String tamanho(String? valor) => _traduzir(_tamanhos, valor);
  static String condicao(String? valor) => _traduzir(_condicoes, valor);
  static String raridade(String? valor) => _traduzir(_raridades, valor);
  static String tipoDano(String? valor) => _traduzir(_tiposDano, valor);
  static String atributo(String? valor) => _traduzir(_atributos, valor);
  static String siglaAtributo(String? valor) => _traduzir(_siglas, valor);
  static String alinhamento(String? valor) => _traduzir(_alinhamentos, valor);
  static String categoriaItem(String? valor) => _traduzir(_categorias, valor);
  // Special (Lance) traduz o comeco e mantem o resto
  static String propriedadeArma(String? valor) {
    final v = valor?.trim() ?? '';
    final i = v.indexOf(' (');
    if (i < 0) return _traduzir(_propriedades, v);
    return '${_traduzir(_propriedades, v.substring(0, i))}${v.substring(i)}';
  }

  // bludgeoning, piercing, and slashing from nonmagical attacks
  static String defesa(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return vazio;
    final exato = _tiposDano[_chave(v)] ?? _condicoes[_chave(v)];
    if (exato != null) return exato;
    var t = v;
    for (final MapEntry(:key, :value) in _frasesDefesa.entries) {
      t = t.replaceAll(key, value);
    }
    t = t.replaceAllMapped(
      RegExp(r'[a-z]+'),
      (m) => _tiposDano[m.group(0)] ?? m.group(0) ?? '',
    );
    if (t == v && _avisados.add(v)) AppLog.aviso(TagLog.ui, 'sem traducao: $v');
    return t;
  }

  static String sentido(String? valor) => _traduzir(_sentidos, valor);
  static String movimento(String? valor) => _traduzir(_movimentos, valor);
  static String pericia(String? valor) => _traduzir(_pericias, valor);
  static String idioma(String? valor) => _traduzir(_idiomas, valor);

  // 1 lb vira 0,5 kg, como no livro em portugues
  static String quilos(num? libras) =>
      libras == null || libras <= 0 ? vazio : '${_decimal(libras * 0.5)} kg';

  // 15.00 vira 15 po, 0.50 vira 5 pp, 0.01 vira 1 pc
  static String custo(String? valor) {
    final po = double.tryParse(valor ?? '');
    if (po == null || po <= 0) return vazio;
    if (po >= 1) return '${_decimal(po)} po';
    final pp = po * 10;
    if (pp >= 1 && pp == pp.roundToDouble()) return '${pp.round()} pp';
    return '${(po * 100).round()} pc';
  }

  // 14 + Dex modifier (max 2) vira 14 + mod. Des (máx. 2)
  static String caArmadura(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return vazio;
    return v.replaceAll('Dex modifier', 'mod. Des').replaceAll('max ', 'máx. ');
  }

  // action, 1minute, bonus-action
  static String tempo(String? valor) => _traduzir(_tempos, valor);

  // instantaneous, 1 minute, until dispelled
  static String duracao(String? valor) =>
      _quantidade(valor) ?? _traduzir(_duracoes, valor);

  // self, touch, 60 feet
  static String alcance(String? valor) =>
      _quantidade(valor) ?? _traduzir(_alcances, valor);

  // 30 pes viram 9 m, como no livro em portugues
  static String metros(num pes) => '${_decimal(pes * 0.3)} m';

  static String _decimal(num n) => n == n.roundToDouble()
      ? '${n.round()}'
      : n.toStringAsFixed(1).replaceAll('.', ',');

  static String _traduzir(Map<String, String> mapa, String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return vazio;
    final traducao = mapa[_chave(v)];
    if (traducao != null) return traducao;
    if (_avisados.add(v)) AppLog.aviso(TagLog.ui, 'sem traducao: $v');
    return v;
  }

  // very-rare, Very Rare e very_rare viram a mesma chave
  static String _chave(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[-_]'), ' ').trim();

  static final _numero = RegExp(r'^(\d+)\s*([a-z]+)$');

  // 60 feet, 10 minutes, 1 round
  static String? _quantidade(String? valor) {
    final m = _numero.firstMatch(_chave(valor ?? ''));
    if (m == null) return null;
    final n = int.parse(m.group(1) ?? '0');
    final unidade = m.group(2) ?? '';
    final um = n == 1;
    return switch (unidade) {
      'foot' || 'feet' => metros(n),
      'mile' || 'miles' => '${_decimal(n * 1.5)} km',
      'round' || 'rounds' => um ? '1 rodada' : '$n rodadas',
      'minute' || 'minutes' => um ? '1 minuto' : '$n minutos',
      'hour' || 'hours' => um ? '1 hora' : '$n horas',
      'day' || 'days' => um ? '1 dia' : '$n dias',
      _ => null,
    };
  }

  // trechos fixos das resistencias do srd, do mais longo ao mais curto
  static const _frasesDefesa = {
    'from nonmagical attacks not made with adamantine weapons':
        'de ataques não mágicos sem armas de adamante',
    'from nonmagical attacks not made with silvered weapons':
        'de ataques não mágicos sem armas prateadas',
    'from nonmagical/nonsilver weapons': 'de armas não mágicas nem prateadas',
    'from nonmagical attacks': 'de ataques não mágicos',
    'from magic weapons wielded by good creatures':
        'de armas mágicas de criaturas boas',
    'damage from spells': 'dano de magias',
    'non magical': 'não mágico',
    '(from stoneskin)': '(de pele de pedra)',
    'and ': 'e ',
  };

  static const _escolas = {
    'abjuration': 'Abjuração',
    'conjuration': 'Conjuração',
    'divination': 'Adivinhação',
    'enchantment': 'Encantamento',
    'evocation': 'Evocação',
    'illusion': 'Ilusão',
    'necromancy': 'Necromancia',
    'transmutation': 'Transmutação',
  };

  static const _tiposMonstro = {
    'aberration': 'Aberração',
    'beast': 'Fera',
    'celestial': 'Celestial',
    'construct': 'Constructo',
    'dragon': 'Dragão',
    'elemental': 'Elemental',
    'fey': 'Fada',
    'fiend': 'Ínfero',
    'giant': 'Gigante',
    'humanoid': 'Humanoide',
    'monstrosity': 'Monstruosidade',
    'ooze': 'Limo',
    'plant': 'Planta',
    'undead': 'Morto-vivo',
  };

  static const _tamanhos = {
    'tiny': 'Miúdo',
    'small': 'Pequeno',
    'medium': 'Médio',
    'large': 'Grande',
    'huge': 'Enorme',
    'gargantuan': 'Imenso',
  };

  static const _condicoes = {
    'blinded': 'Cego',
    'charmed': 'Enfeitiçado',
    'deafened': 'Surdo',
    'exhaustion': 'Exaustão',
    'frightened': 'Amedrontado',
    'grappled': 'Agarrado',
    'incapacitated': 'Incapacitado',
    'invisible': 'Invisível',
    'paralyzed': 'Paralisado',
    'petrified': 'Petrificado',
    'poisoned': 'Envenenado',
    'prone': 'Caído',
    'restrained': 'Impedido',
    'stunned': 'Atordoado',
    'unconscious': 'Inconsciente',
  };

  static const _raridades = {
    'common': 'Comum',
    'uncommon': 'Incomum',
    'rare': 'Raro',
    'very rare': 'Muito raro',
    'legendary': 'Lendário',
    'artifact': 'Artefato',
    'varies': 'Variada',
  };

  static const _tiposDano = {
    'acid': 'ácido',
    'bludgeoning': 'concussão',
    'cold': 'frio',
    'fire': 'fogo',
    'force': 'energia',
    'lightning': 'elétrico',
    'necrotic': 'necrótico',
    'piercing': 'perfurante',
    'poison': 'veneno',
    'psychic': 'psíquico',
    'radiant': 'radiante',
    'slashing': 'cortante',
    'thunder': 'trovejante',
  };

  static const _atributos = {
    'strength': 'Força',
    'dexterity': 'Destreza',
    'constitution': 'Constituição',
    'intelligence': 'Inteligência',
    'wisdom': 'Sabedoria',
    'charisma': 'Carisma',
  };

  static const _siglas = {
    'strength': 'FOR',
    'dexterity': 'DES',
    'constitution': 'CON',
    'intelligence': 'INT',
    'wisdom': 'SAB',
    'charisma': 'CAR',
  };

  static const _alinhamentos = {
    'lawful good': 'Leal e Bom',
    'neutral good': 'Neutro e Bom',
    'chaotic good': 'Caótico e Bom',
    'lawful neutral': 'Leal e Neutro',
    'neutral': 'Neutro',
    'chaotic neutral': 'Caótico e Neutro',
    'lawful evil': 'Leal e Mau',
    'neutral evil': 'Neutro e Mau',
    'chaotic evil': 'Caótico e Mau',
    'unaligned': 'Sem alinhamento',
    'any alignment': 'Qualquer alinhamento',
    'any non good alignment': 'Qualquer um não bom',
    'any non lawful alignment': 'Qualquer um não leal',
    'any chaotic alignment': 'Qualquer caótico',
    'any evil alignment': 'Qualquer mau',
    'neutral good (50%) or neutral evil (50%)': 'Neutro e Bom ou Neutro e Mau',
  };

  static const _categorias = {
    'adventuring gear': 'Equipamento de aventura',
    'ammunition': 'Munição',
    'armor': 'Armadura',
    'land vehicle': 'Veículo terrestre',
    'poison': 'Veneno',
    'potion': 'Poção',
    'ring': 'Anel',
    'rod': 'Bastão',
    'scroll': 'Pergaminho',
    'shield': 'Escudo',
    'staff': 'Cajado',
    'tools': 'Ferramentas',
    'trade good': 'Mercadoria',
    'wand': 'Varinha',
    'waterborne vehicle': 'Veículo aquático',
    'weapon': 'Arma',
    'wondrous item': 'Item maravilhoso',
    'light': 'Leve',
    'medium': 'Média',
    'heavy': 'Pesada',
  };

  static const _propriedades = {
    'ammunition': 'Munição',
    'finesse': 'Acuidade',
    'heavy': 'Pesada',
    'light': 'Leve',
    'loading': 'Recarga',
    'reach': 'Alcance',
    'special': 'Especial',
    'thrown': 'Arremesso',
    'two handed': 'Duas mãos',
    'versatile': 'Versátil',
  };

  static const _sentidos = {
    'darkvision': 'Visão no escuro',
    'blindsight': 'Percepção às cegas',
    'tremorsense': 'Sentido sísmico',
    'truesight': 'Visão verdadeira',
  };

  static const _movimentos = {
    'walk': 'Andar',
    'fly': 'Voo',
    'swim': 'Natação',
    'climb': 'Escalada',
    'burrow': 'Escavação',
  };

  static const _pericias = {
    'acrobatics': 'Acrobacia',
    'animal handling': 'Adestrar Animais',
    'arcana': 'Arcanismo',
    'athletics': 'Atletismo',
    'deception': 'Enganação',
    'history': 'História',
    'insight': 'Intuição',
    'intimidation': 'Intimidação',
    'investigation': 'Investigação',
    'medicine': 'Medicina',
    'nature': 'Natureza',
    'perception': 'Percepção',
    'performance': 'Atuação',
    'persuasion': 'Persuasão',
    'religion': 'Religião',
    'sleight of hand': 'Prestidigitação',
    'stealth': 'Furtividade',
    'survival': 'Sobrevivência',
  };

  static const _idiomas = {
    'common': 'Comum',
    'dwarvish': 'Anão',
    'elvish': 'Élfico',
    'giant': 'Gigante',
    'gnomish': 'Gnômico',
    'goblin': 'Goblin',
    'halfling': 'Halfling',
    'orc': 'Orc',
    'abyssal': 'Abissal',
    'celestial': 'Celestial',
    'draconic': 'Dracônico',
    'deep speech': 'Dialeto Obscuro',
    'infernal': 'Infernal',
    'primordial': 'Primordial',
    'sylvan': 'Silvestre',
    'undercommon': 'Dialeto Subterrâneo',
    'aquan': 'Aquan',
    'auran': 'Auran',
    'ignan': 'Ignan',
    'terran': 'Terran',
    'gnoll': 'Gnoll',
    'sahuagin': 'Sahuagin',
    'druidic': 'Druídico',
    "thieves' cant": 'Gíria dos Ladrões',
  };

  static const _tempos = {
    'action': '1 ação',
    'bonus action': '1 ação bônus',
    'reaction': '1 reação',
    '1minute': '1 minuto',
    '10minutes': '10 minutos',
    '1hour': '1 hora',
    '8hours': '8 horas',
    '12hours': '12 horas',
    '24hours': '24 horas',
  };

  static const _duracoes = {
    'instantaneous': 'Instantânea',
    'until dispelled': 'Até ser dissipada',
    'until dispelled or triggered': 'Até ser dissipada ou ativada',
    'special': 'Especial',
  };

  static const _alcances = {
    'self': 'Pessoal',
    'touch': 'Toque',
    'sight': 'Visão',
    'unlimited': 'Ilimitado',
    'special': 'Especial',
  };
}
