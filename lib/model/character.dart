import 'package:grimorio/model/hero_options_mock.dart';

enum Ability {
  forca('FOR'),
  destreza('DES'),
  constituicao('CON'),
  inteligencia('INT'),
  sabedoria('SAB'),
  carisma('CAR');

  const Ability(this.sigla);
  final String sigla;
}

// Tabela de XP mínimonível
const xpPorNivel = [
  0,
  300,
  900,
  2700,
  6500,
  14000,
  23000,
  34000,
  48000,
  64000,
  85000,
  100000,
  120000,
  140000,
  165000,
  195000,
  225000,
  265000,
  305000,
  355000,
];

int modificador(int valor) => ((valor - 10) / 2).floor();

class AbilityScores {
  const AbilityScores({
    required this.forca,
    required this.destreza,
    required this.constituicao,
    required this.inteligencia,
    required this.sabedoria,
    required this.carisma,
  });

  final int forca;
  final int destreza;
  final int constituicao;
  final int inteligencia;
  final int sabedoria;
  final int carisma;

  int valor(Ability a) => switch (a) {
    Ability.forca => forca,
    Ability.destreza => destreza,
    Ability.constituicao => constituicao,
    Ability.inteligencia => inteligencia,
    Ability.sabedoria => sabedoria,
    Ability.carisma => carisma,
  };

  int mod(Ability a) => modificador(valor(a));
}

// Classe e nivel
class CharacterClass {
  const CharacterClass({
    required this.apiKey,
    required this.nome,
    required this.nivel,
    required this.dadoDeVida,
    this.subclasse,
  });

  final String apiKey;
  final String nome;
  final int nivel;
  final int dadoDeVida;
  final String? subclasse;
}

class SpellSlot {
  const SpellSlot({
    required this.circulo,
    required this.total,
    this.usados = 0,
  });

  final int circulo;
  final int total;
  final int usados;

  int get livres => total - usados;

  SpellSlot copyWith({int? usados}) =>
      SpellSlot(circulo: circulo, total: total, usados: usados ?? this.usados);
}

enum EquipSlot {
  elmo,
  colar,
  capa,
  armadura,
  luvas,
  anel,
  botas,
  maoPrincipal,
  maoSecundaria,
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.nome,
    required this.imagem,
    this.quantidade = 1,
    this.pesoKg = 0,
    this.equipadoEm,
    this.slot,
    this.dano,
    this.tipoDano,
    this.atributoAtaque,
    this.consumivel = false,
    this.descricao,
    this.bonusCa = 0,
  });

  final String id;
  final String nome;
  final String imagem;
  final int quantidade;
  final double pesoKg;
  final EquipSlot? equipadoEm;

  final EquipSlot? slot;

  final String? dano;
  final String? tipoDano;

  final Ability? atributoAtaque;
  final bool consumivel;
  final String? descricao;

  final int bonusCa;

  bool get equipado => equipadoEm != null;
  bool get arma => dano != null;
  EquipSlot? get slotEquipavel => slot ?? equipadoEm;

  InventoryItem copyWith({
    int? quantidade,
    EquipSlot? equipadoEm,
    bool desequipar = false,
  }) => InventoryItem(
    id: id,
    nome: nome,
    imagem: imagem,
    quantidade: quantidade ?? this.quantidade,
    pesoKg: pesoKg,
    equipadoEm: desequipar ? null : equipadoEm ?? this.equipadoEm,
    slot: slotEquipavel,
    dano: dano,
    tipoDano: tipoDano,
    atributoAtaque: atributoAtaque,
    consumivel: consumivel,
    descricao: descricao,
    bonusCa: bonusCa,
  );
}

class Condition {
  const Condition({required this.nome, this.rodadas});
  final String nome;
  final int? rodadas;
}

class Nota {
  Nota({
    required String id,
    required String titulo,
    required String texto,
    required DateTime data,
  }) : this.fixa(
         id: id,
         titulo: titulo,
         texto: texto,
         dataMs: data.millisecondsSinceEpoch,
       );

  const Nota.fixa({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.dataMs,
  });

  final String id;
  final String titulo;
  final String texto;
  final int dataMs;

  DateTime get data => DateTime.fromMillisecondsSinceEpoch(dataMs);
}

const _atributoMagiaPorClasse = {
  'cleric': Ability.sabedoria,
  'druid': Ability.sabedoria,
  'ranger': Ability.sabedoria,
  'wizard': Ability.inteligencia,
  'bard': Ability.carisma,
  'sorcerer': Ability.carisma,
  'warlock': Ability.carisma,
  'paladin': Ability.carisma,
};

class Character {
  const Character({
    required this.id,
    required this.nome,
    required this.retrato,
    required this.especie,
    required this.classes,
    required this.atributos,
    required this.xp,
    required this.hpMax,
    required this.hpAtual,
    required this.ca,
    required this.deslocamentoM,
    this.hpTemp = 0,
    this.salvaguardas = const {},
    this.pericias = const {},
    this.espacosDeMagia = const [],
    this.inventario = const [],
    this.condicoes = const [],
    this.moedas = const Moedas(),
    this.campanhaId,
    this.donoId,
    this.ativo = false,
    this.antecedente,
    this.alinhamento,
    this.idiomas = const {},
    this.historia = '',
    this.magias = const {},
    this.magiasPreparadas = const {},
    this.inspiracao = false,
    this.notas = const [],
  });

  final String id;
  final String nome;
  final String retrato;
  final String especie;
  final List<CharacterClass> classes;
  final AbilityScores atributos;
  final int xp;
  final int hpMax;
  final int hpAtual;
  final int hpTemp;
  final int ca;
  final double deslocamentoM;
  final Set<Ability> salvaguardas;
  final Set<String> pericias;
  final List<SpellSlot> espacosDeMagia;
  final List<InventoryItem> inventario;
  final List<Condition> condicoes;
  final Moedas moedas;
  final String? campanhaId;
  final String? donoId;
  final bool ativo;
  final String? antecedente;
  final String? alinhamento;
  final Set<String> idiomas;
  final String historia;

  final Set<String> magias;
  final Set<String> magiasPreparadas;
  final bool inspiracao;
  final List<Nota> notas;

  int get nivel => classes.fold(0, (s, c) => s + c.nivel);
  int get bonusProficiencia => 2 + ((nivel - 1) ~/ 4);
  int get iniciativa => atributos.mod(Ability.destreza);
  int get xpNivelAtual => xpPorNivel[nivel - 1];
  int get xpProximoNivel => nivel >= 20 ? xpPorNivel.last : xpPorNivel[nivel];

  double get progressoXp {
    if (nivel >= 20) return 1;
    final base = xpPorNivel[nivel - 1];
    return (xp - base) / (xpProximoNivel - base);
  }

  bool get podeSubirNivel => nivel < 20 && xp >= xpProximoNivel;

  int salvaguarda(Ability a) =>
      atributos.mod(a) + (salvaguardas.contains(a) ? bonusProficiencia : 0);

  int get espacosLivres => espacosDeMagia.fold(0, (s, e) => s + e.livres);

  double get cargaKg =>
      inventario.fold(0, (s, i) => s + i.pesoKg * i.quantidade);

  double get cargaMaxKg => atributos.forca * 7.5;

  String get classeResumo =>
      classes.map((c) => '${c.nome} ${c.nivel}').join(' / ');

  Ability? get atributoMagia => classes.isEmpty
      ? null
      : _atributoMagiaPorClasse[classes.first.apiKey.replaceFirst('srd_', '')];

  int get _modMagia {
    final atributo = atributoMagia;
    return atributo == null ? 0 : atributos.mod(atributo);
  }

  int get ataqueMagico => bonusProficiencia + _modMagia;

  int get cdMagia => 8 + bonusProficiencia + _modMagia;

  int bonusPericia(String nome) {
    final pericia = periciasMock.firstWhere((p) => p.nome == nome);
    return atributos.mod(pericia.atributo) +
        (pericias.contains(nome) ? bonusProficiencia : 0);
  }

  int get percepcaoPassiva => 10 + bonusPericia('Percepção');

  int _modArma(InventoryItem item) =>
      atributos.mod(item.atributoAtaque ?? Ability.forca);

  int ataqueArma(InventoryItem item) => _modArma(item) + bonusProficiencia;

  String danoArma(InventoryItem item) {
    final dado = item.dano ?? '';
    final mod = _modArma(item);
    if (mod == 0) return dado;
    return mod > 0 ? '$dado + $mod' : '$dado − ${-mod}';
  }

  List<InventoryItem> itensEm(EquipSlot slot) => [
    for (final i in inventario)
      if (i.equipadoEm == slot) i,
  ];

  int get bonusCaEquipado =>
      inventario.fold(0, (s, i) => s + (i.equipado ? i.bonusCa : 0));

  Character copyWith({
    String? id,
    String? nome,
    String? retrato,
    String? especie,
    List<CharacterClass>? classes,
    AbilityScores? atributos,
    int? xp,
    int? hpMax,
    int? hpAtual,
    int? hpTemp,
    int? ca,
    double? deslocamentoM,
    Set<Ability>? salvaguardas,
    Set<String>? pericias,
    List<SpellSlot>? espacosDeMagia,
    List<InventoryItem>? inventario,
    List<Condition>? condicoes,
    Moedas? moedas,
    String? campanhaId,
    String? donoId,
    bool? ativo,
    String? antecedente,
    String? alinhamento,
    Set<String>? idiomas,
    String? historia,
    Set<String>? magias,
    Set<String>? magiasPreparadas,
    bool? inspiracao,
    List<Nota>? notas,
  }) => Character(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    retrato: retrato ?? this.retrato,
    especie: especie ?? this.especie,
    classes: classes ?? this.classes,
    atributos: atributos ?? this.atributos,
    xp: xp ?? this.xp,
    hpMax: hpMax ?? this.hpMax,
    hpAtual: hpAtual ?? this.hpAtual,
    hpTemp: hpTemp ?? this.hpTemp,
    ca: ca ?? this.ca,
    deslocamentoM: deslocamentoM ?? this.deslocamentoM,
    salvaguardas: salvaguardas ?? this.salvaguardas,
    pericias: pericias ?? this.pericias,
    espacosDeMagia: espacosDeMagia ?? this.espacosDeMagia,
    inventario: inventario ?? this.inventario,
    condicoes: condicoes ?? this.condicoes,
    moedas: moedas ?? this.moedas,
    campanhaId: campanhaId ?? this.campanhaId,
    donoId: donoId ?? this.donoId,
    ativo: ativo ?? this.ativo,
    antecedente: antecedente ?? this.antecedente,
    alinhamento: alinhamento ?? this.alinhamento,
    idiomas: idiomas ?? this.idiomas,
    historia: historia ?? this.historia,
    magias: magias ?? this.magias,
    magiasPreparadas: magiasPreparadas ?? this.magiasPreparadas,
    inspiracao: inspiracao ?? this.inspiracao,
    notas: notas ?? this.notas,
  );
}

class Moedas {
  const Moedas({this.ouro = 0, this.prata = 0, this.cobre = 0});

  final int ouro;
  final int prata;
  final int cobre;
}
