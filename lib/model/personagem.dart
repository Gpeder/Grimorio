import 'package:grimorio/model/json.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';

enum Atributo {
  forca('FOR'),
  destreza('DES'),
  constituicao('CON'),
  inteligencia('INT'),
  sabedoria('SAB'),
  carisma('CAR');

  const Atributo(this.sigla);
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

class Atributos {
  const Atributos({
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

  int valor(Atributo a) => switch (a) {
    Atributo.forca => forca,
    Atributo.destreza => destreza,
    Atributo.constituicao => constituicao,
    Atributo.inteligencia => inteligencia,
    Atributo.sabedoria => sabedoria,
    Atributo.carisma => carisma,
  };

  int mod(Atributo a) => modificador(valor(a));

  factory Atributos.fromJson(Map<String, dynamic> json) => Atributos(
    forca: (json['forca'] as num?)?.toInt() ?? 0,
    destreza: (json['destreza'] as num?)?.toInt() ?? 0,
    constituicao: (json['constituicao'] as num?)?.toInt() ?? 0,
    inteligencia: (json['inteligencia'] as num?)?.toInt() ?? 0,
    sabedoria: (json['sabedoria'] as num?)?.toInt() ?? 0,
    carisma: (json['carisma'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'forca': forca,
    'destreza': destreza,
    'constituicao': constituicao,
    'inteligencia': inteligencia,
    'sabedoria': sabedoria,
    'carisma': carisma,
  };

  Atributos copyWith({
    int? forca,
    int? destreza,
    int? constituicao,
    int? inteligencia,
    int? sabedoria,
    int? carisma,
  }) => Atributos(
    forca: forca ?? this.forca,
    destreza: destreza ?? this.destreza,
    constituicao: constituicao ?? this.constituicao,
    inteligencia: inteligencia ?? this.inteligencia,
    sabedoria: sabedoria ?? this.sabedoria,
    carisma: carisma ?? this.carisma,
  );
}

// Classe e nivel
class ClassePersonagem {
  const ClassePersonagem({
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

  factory ClassePersonagem.fromJson(Map<String, dynamic> json) =>
      ClassePersonagem(
        apiKey: json['api_key'] as String? ?? '',
        nome: json['nome'] as String? ?? '',
        nivel: (json['nivel'] as num?)?.toInt() ?? 0,
        dadoDeVida: (json['dado_de_vida'] as num?)?.toInt() ?? 0,
        subclasse: json['subclasse'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'api_key': apiKey,
    'nome': nome,
    'nivel': nivel,
    'dado_de_vida': dadoDeVida,
    'subclasse': subclasse,
  };

  ClassePersonagem copyWith({
    String? apiKey,
    String? nome,
    int? nivel,
    int? dadoDeVida,
    String? subclasse,
  }) => ClassePersonagem(
    apiKey: apiKey ?? this.apiKey,
    nome: nome ?? this.nome,
    nivel: nivel ?? this.nivel,
    dadoDeVida: dadoDeVida ?? this.dadoDeVida,
    subclasse: subclasse ?? this.subclasse,
  );
}

class EspacoMagia {
  const EspacoMagia({
    required this.circulo,
    required this.total,
    this.usados = 0,
  });

  final int circulo;
  final int total;
  final int usados;

  int get livres => total - usados;

  factory EspacoMagia.fromJson(Map<String, dynamic> json) => EspacoMagia(
    circulo: (json['circulo'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? 0,
    usados: (json['usados'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'circulo': circulo,
    'total': total,
    'usados': usados,
  };

  EspacoMagia copyWith({int? circulo, int? total, int? usados}) => EspacoMagia(
    circulo: circulo ?? this.circulo,
    total: total ?? this.total,
    usados: usados ?? this.usados,
  );
}

enum SlotEquipamento {
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

class ItemInventario {
  const ItemInventario({
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
  final SlotEquipamento? equipadoEm;

  final SlotEquipamento? slot;

  final String? dano;
  final String? tipoDano;

  final Atributo? atributoAtaque;
  final bool consumivel;
  final String? descricao;

  final int bonusCa;

  bool get equipado => equipadoEm != null;
  bool get arma => dano != null;
  SlotEquipamento? get slotEquipavel => slot ?? equipadoEm;

  factory ItemInventario.fromJson(Map<String, dynamic> json) => ItemInventario(
    id: json['id'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    imagem: json['imagem'] as String? ?? '',
    quantidade: (json['quantidade'] as num?)?.toInt() ?? 1,
    pesoKg: (json['peso_kg'] as num?)?.toDouble() ?? 0,
    equipadoEm: lerEnumOuNulo(SlotEquipamento.values, json['equipado_em']),
    slot: lerEnumOuNulo(SlotEquipamento.values, json['slot']),
    dano: json['dano'] as String?,
    tipoDano: json['tipo_dano'] as String?,
    atributoAtaque: lerEnumOuNulo(Atributo.values, json['atributo_ataque']),
    consumivel: json['consumivel'] as bool? ?? false,
    descricao: json['descricao'] as String?,
    bonusCa: (json['bonus_ca'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'imagem': imagem,
    'quantidade': quantidade,
    'peso_kg': pesoKg,
    'equipado_em': equipadoEm?.name,
    'slot': slot?.name,
    'dano': dano,
    'tipo_dano': tipoDano,
    'atributo_ataque': atributoAtaque?.name,
    'consumivel': consumivel,
    'descricao': descricao,
    'bonus_ca': bonusCa,
  };

  ItemInventario copyWith({
    String? id,
    String? nome,
    String? imagem,
    int? quantidade,
    double? pesoKg,
    SlotEquipamento? equipadoEm,
    SlotEquipamento? slot,
    String? dano,
    String? tipoDano,
    Atributo? atributoAtaque,
    bool? consumivel,
    String? descricao,
    int? bonusCa,
    bool desequipar = false,
  }) => ItemInventario(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    imagem: imagem ?? this.imagem,
    quantidade: quantidade ?? this.quantidade,
    pesoKg: pesoKg ?? this.pesoKg,
    equipadoEm: desequipar ? null : equipadoEm ?? this.equipadoEm,
    slot: slot ?? slotEquipavel,
    dano: dano ?? this.dano,
    tipoDano: tipoDano ?? this.tipoDano,
    atributoAtaque: atributoAtaque ?? this.atributoAtaque,
    consumivel: consumivel ?? this.consumivel,
    descricao: descricao ?? this.descricao,
    bonusCa: bonusCa ?? this.bonusCa,
  );
}

class Condicao {
  const Condicao({required this.nome, this.rodadas});
  final String nome;
  final int? rodadas;

  factory Condicao.fromJson(Map<String, dynamic> json) => Condicao(
    nome: json['nome'] as String? ?? '',
    rodadas: (json['rodadas'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {'nome': nome, 'rodadas': rodadas};

  Condicao copyWith({String? nome, int? rodadas}) =>
      Condicao(nome: nome ?? this.nome, rodadas: rodadas ?? this.rodadas);
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

  factory Nota.fromJson(Map<String, dynamic> json) => Nota.fixa(
    id: json['id'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    texto: json['texto'] as String? ?? '',
    dataMs: (json['data_ms'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'texto': texto,
    'data_ms': dataMs,
  };

  Nota copyWith({String? id, String? titulo, String? texto, int? dataMs}) =>
      Nota.fixa(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        texto: texto ?? this.texto,
        dataMs: dataMs ?? this.dataMs,
      );
}

const _atributoMagiaPorClasse = {
  'cleric': Atributo.sabedoria,
  'druid': Atributo.sabedoria,
  'ranger': Atributo.sabedoria,
  'wizard': Atributo.inteligencia,
  'bard': Atributo.carisma,
  'sorcerer': Atributo.carisma,
  'warlock': Atributo.carisma,
  'paladin': Atributo.carisma,
};

class Personagem {
  const Personagem({
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
  final List<ClassePersonagem> classes;
  final Atributos atributos;
  final int xp;
  final int hpMax;
  final int hpAtual;
  final int hpTemp;
  final int ca;
  final double deslocamentoM;
  final Set<Atributo> salvaguardas;
  final Set<String> pericias;
  final List<EspacoMagia> espacosDeMagia;
  final List<ItemInventario> inventario;
  final List<Condicao> condicoes;
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
  int get iniciativa => atributos.mod(Atributo.destreza);
  int get xpNivelAtual => xpPorNivel[nivel - 1];
  int get xpProximoNivel => nivel >= 20 ? xpPorNivel.last : xpPorNivel[nivel];

  double get progressoXp {
    if (nivel >= 20) return 1;
    final base = xpPorNivel[nivel - 1];
    return (xp - base) / (xpProximoNivel - base);
  }

  bool get podeSubirNivel => nivel < 20 && xp >= xpProximoNivel;

  int salvaguarda(Atributo a) =>
      atributos.mod(a) + (salvaguardas.contains(a) ? bonusProficiencia : 0);

  int get espacosLivres => espacosDeMagia.fold(0, (s, e) => s + e.livres);

  double get cargaKg =>
      inventario.fold(0, (s, i) => s + i.pesoKg * i.quantidade);

  double get cargaMaxKg => atributos.forca * 7.5;

  String get classeResumo =>
      classes.map((c) => '${c.nome} ${c.nivel}').join(' / ');

  Atributo? get atributoMagia => classes.isEmpty
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

  int _modArma(ItemInventario item) =>
      atributos.mod(item.atributoAtaque ?? Atributo.forca);

  int ataqueArma(ItemInventario item) => _modArma(item) + bonusProficiencia;

  String danoArma(ItemInventario item) {
    final dado = item.dano ?? '';
    final mod = _modArma(item);
    if (mod == 0) return dado;
    return mod > 0 ? '$dado + $mod' : '$dado − ${-mod}';
  }

  List<ItemInventario> itensEm(SlotEquipamento slot) => [
    for (final i in inventario)
      if (i.equipadoEm == slot) i,
  ];

  int get bonusCaEquipado =>
      inventario.fold(0, (s, i) => s + (i.equipado ? i.bonusCa : 0));

  factory Personagem.fromJson(Map<String, dynamic> json) => Personagem(
    id: json['id'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    retrato: json['retrato'] as String? ?? '',
    especie: json['especie'] as String? ?? '',
    classes: [
      for (final e in (json['classes'] as List? ?? const []))
        ClassePersonagem.fromJson(e as Map<String, dynamic>),
    ],
    atributos: Atributos.fromJson(json['atributos'] as Map<String, dynamic>),
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    hpMax: (json['hp_max'] as num?)?.toInt() ?? 0,
    hpAtual: (json['hp_atual'] as num?)?.toInt() ?? 0,
    ca: (json['ca'] as num?)?.toInt() ?? 0,
    deslocamentoM: (json['deslocamento_m'] as num?)?.toDouble() ?? 0,
    hpTemp: (json['hp_temp'] as num?)?.toInt() ?? 0,
    salvaguardas: {
      for (final e in (json['salvaguardas'] as List? ?? const []))
        ?lerEnumOuNulo(Atributo.values, e),
    },
    pericias: {
      for (final e in (json['pericias'] as List? ?? const [])) e as String,
    },
    espacosDeMagia: [
      for (final e in (json['espacos_de_magia'] as List? ?? const []))
        EspacoMagia.fromJson(e as Map<String, dynamic>),
    ],
    inventario: [
      for (final e in (json['inventario'] as List? ?? const []))
        ItemInventario.fromJson(e as Map<String, dynamic>),
    ],
    condicoes: [
      for (final e in (json['condicoes'] as List? ?? const []))
        Condicao.fromJson(e as Map<String, dynamic>),
    ],
    moedas: json['moedas'] == null
        ? const Moedas()
        : Moedas.fromJson(json['moedas'] as Map<String, dynamic>),
    campanhaId: json['campanha_id'] as String?,
    donoId: json['dono_id'] as String?,
    ativo: json['ativo'] as bool? ?? false,
    antecedente: json['antecedente'] as String?,
    alinhamento: json['alinhamento'] as String?,
    idiomas: {
      for (final e in (json['idiomas'] as List? ?? const [])) e as String,
    },
    historia: json['historia'] as String? ?? '',
    magias: {
      for (final e in (json['magias'] as List? ?? const [])) e as String,
    },
    magiasPreparadas: {
      for (final e in (json['magias_preparadas'] as List? ?? const []))
        e as String,
    },
    inspiracao: json['inspiracao'] as bool? ?? false,
    notas: [
      for (final e in (json['notas'] as List? ?? const []))
        Nota.fromJson(e as Map<String, dynamic>),
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'retrato': retrato,
    'especie': especie,
    'classes': [for (final e in classes) e.toJson()],
    'atributos': atributos.toJson(),
    'xp': xp,
    'hp_max': hpMax,
    'hp_atual': hpAtual,
    'ca': ca,
    'deslocamento_m': deslocamentoM,
    'hp_temp': hpTemp,
    'salvaguardas': [for (final e in salvaguardas) e.name],
    'pericias': [...pericias],
    'espacos_de_magia': [for (final e in espacosDeMagia) e.toJson()],
    'inventario': [for (final e in inventario) e.toJson()],
    'condicoes': [for (final e in condicoes) e.toJson()],
    'moedas': moedas.toJson(),
    'campanha_id': campanhaId,
    'dono_id': donoId,
    'ativo': ativo,
    'antecedente': antecedente,
    'alinhamento': alinhamento,
    'idiomas': [...idiomas],
    'historia': historia,
    'magias': [...magias],
    'magias_preparadas': [...magiasPreparadas],
    'inspiracao': inspiracao,
    'notas': [for (final e in notas) e.toJson()],
  };

  Personagem copyWith({
    String? id,
    String? nome,
    String? retrato,
    String? especie,
    List<ClassePersonagem>? classes,
    Atributos? atributos,
    int? xp,
    int? hpMax,
    int? hpAtual,
    int? ca,
    double? deslocamentoM,
    int? hpTemp,
    Set<Atributo>? salvaguardas,
    Set<String>? pericias,
    List<EspacoMagia>? espacosDeMagia,
    List<ItemInventario>? inventario,
    List<Condicao>? condicoes,
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
  }) => Personagem(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    retrato: retrato ?? this.retrato,
    especie: especie ?? this.especie,
    classes: classes ?? this.classes,
    atributos: atributos ?? this.atributos,
    xp: xp ?? this.xp,
    hpMax: hpMax ?? this.hpMax,
    hpAtual: hpAtual ?? this.hpAtual,
    ca: ca ?? this.ca,
    deslocamentoM: deslocamentoM ?? this.deslocamentoM,
    hpTemp: hpTemp ?? this.hpTemp,
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

  factory Moedas.fromJson(Map<String, dynamic> json) => Moedas(
    ouro: (json['ouro'] as num?)?.toInt() ?? 0,
    prata: (json['prata'] as num?)?.toInt() ?? 0,
    cobre: (json['cobre'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'ouro': ouro,
    'prata': prata,
    'cobre': cobre,
  };

  Moedas copyWith({int? ouro, int? prata, int? cobre}) => Moedas(
    ouro: ouro ?? this.ouro,
    prata: prata ?? this.prata,
    cobre: cobre ?? this.cobre,
  );
}
