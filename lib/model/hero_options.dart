import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/json.dart';

const nomeAtributo = {
  Ability.forca: 'Força',
  Ability.destreza: 'Destreza',
  Ability.constituicao: 'Constituição',
  Ability.inteligencia: 'Inteligência',
  Ability.sabedoria: 'Sabedoria',
  Ability.carisma: 'Carisma',
};

const proficienciaNivel1 = 2;

class SubspeciesOption {
  const SubspeciesOption({
    required this.key,
    required this.nome,
    this.bonus = const {},
    this.hpPorNivel = 0,
  });

  final String key;
  final String nome;
  final Map<Ability, int> bonus;
  final int hpPorNivel;

  factory SubspeciesOption.fromJson(Map<String, dynamic> json) =>
      SubspeciesOption(
        key: json['key'] as String? ?? '',
        nome: json['nome'] as String? ?? '',
        bonus: {
          for (final MapEntry(:key, :value)
              in (json['bonus'] as Map? ?? const {}).entries)
            ?lerEnumOuNulo(Ability.values, key): (value as num).toInt(),
        },
        hpPorNivel: (json['hp_por_nivel'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'bonus': {for (final e in bonus.entries) e.key.name: e.value},
    'hp_por_nivel': hpPorNivel,
  };

  SubspeciesOption copyWith({
    String? key,
    String? nome,
    Map<Ability, int>? bonus,
    int? hpPorNivel,
  }) => SubspeciesOption(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    bonus: bonus ?? this.bonus,
    hpPorNivel: hpPorNivel ?? this.hpPorNivel,
  );
}

class SpeciesOption {
  const SpeciesOption({
    required this.key,
    required this.nome,
    required this.descricao,
    required this.bonus,
    required this.deslocamentoM,
    required this.retratoF,
    required this.retratoM,
    required this.tracos,
    required this.idiomas,
    this.nomeF,
    this.tamanho = 'Médio',
    this.visaoNoEscuroM,
    this.pericias = const [],
    this.subespecies = const [],
    this.bonusLivres = 0,
    this.periciasLivres = 0,
    this.idiomasExtras = 0,
  });

  final String key;
  final String nome;
  final String? nomeF;
  final String descricao;
  final String tamanho;
  final Map<Ability, int> bonus;
  final double deslocamentoM;
  final int? visaoNoEscuroM;
  final List<String> pericias;
  final String retratoF;
  final String retratoM;
  final List<String> tracos;
  final List<String> idiomas;
  final List<SubspeciesOption> subespecies;

  final int bonusLivres;

  final int periciasLivres;
  final int idiomasExtras;

  String nomePara({required bool feminino}) =>
      feminino ? (nomeF ?? nome) : nome;

  String retratoPara({required bool feminino}) =>
      feminino ? retratoF : retratoM;

  factory SpeciesOption.fromJson(Map<String, dynamic> json) => SpeciesOption(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
    bonus: {
      for (final MapEntry(:key, :value)
          in (json['bonus'] as Map? ?? const {}).entries)
        ?lerEnumOuNulo(Ability.values, key): (value as num).toInt(),
    },
    deslocamentoM: (json['deslocamento_m'] as num?)?.toDouble() ?? 0,
    retratoF: json['retrato_f'] as String? ?? '',
    retratoM: json['retrato_m'] as String? ?? '',
    tracos: [
      for (final e in (json['tracos'] as List? ?? const [])) e as String,
    ],
    idiomas: [
      for (final e in (json['idiomas'] as List? ?? const [])) e as String,
    ],
    nomeF: json['nome_f'] as String?,
    tamanho: json['tamanho'] as String? ?? 'Médio',
    visaoNoEscuroM: (json['visao_no_escuro_m'] as num?)?.toInt(),
    pericias: [
      for (final e in (json['pericias'] as List? ?? const [])) e as String,
    ],
    subespecies: [
      for (final e in (json['subespecies'] as List? ?? const []))
        SubspeciesOption.fromJson(e as Map<String, dynamic>),
    ],
    bonusLivres: (json['bonus_livres'] as num?)?.toInt() ?? 0,
    periciasLivres: (json['pericias_livres'] as num?)?.toInt() ?? 0,
    idiomasExtras: (json['idiomas_extras'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'descricao': descricao,
    'bonus': {for (final e in bonus.entries) e.key.name: e.value},
    'deslocamento_m': deslocamentoM,
    'retrato_f': retratoF,
    'retrato_m': retratoM,
    'tracos': [...tracos],
    'idiomas': [...idiomas],
    'nome_f': nomeF,
    'tamanho': tamanho,
    'visao_no_escuro_m': visaoNoEscuroM,
    'pericias': [...pericias],
    'subespecies': [for (final e in subespecies) e.toJson()],
    'bonus_livres': bonusLivres,
    'pericias_livres': periciasLivres,
    'idiomas_extras': idiomasExtras,
  };

  SpeciesOption copyWith({
    String? key,
    String? nome,
    String? descricao,
    Map<Ability, int>? bonus,
    double? deslocamentoM,
    String? retratoF,
    String? retratoM,
    List<String>? tracos,
    List<String>? idiomas,
    String? nomeF,
    String? tamanho,
    int? visaoNoEscuroM,
    List<String>? pericias,
    List<SubspeciesOption>? subespecies,
    int? bonusLivres,
    int? periciasLivres,
    int? idiomasExtras,
  }) => SpeciesOption(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    descricao: descricao ?? this.descricao,
    bonus: bonus ?? this.bonus,
    deslocamentoM: deslocamentoM ?? this.deslocamentoM,
    retratoF: retratoF ?? this.retratoF,
    retratoM: retratoM ?? this.retratoM,
    tracos: tracos ?? this.tracos,
    idiomas: idiomas ?? this.idiomas,
    nomeF: nomeF ?? this.nomeF,
    tamanho: tamanho ?? this.tamanho,
    visaoNoEscuroM: visaoNoEscuroM ?? this.visaoNoEscuroM,
    pericias: pericias ?? this.pericias,
    subespecies: subespecies ?? this.subespecies,
    bonusLivres: bonusLivres ?? this.bonusLivres,
    periciasLivres: periciasLivres ?? this.periciasLivres,
    idiomasExtras: idiomasExtras ?? this.idiomasExtras,
  );
}

class SubclassOption {
  const SubclassOption({
    required this.key,
    required this.nome,
    required this.imagem,
    this.magiasTravadas = const [],
  });

  final String key;
  final String nome;
  final String imagem;

  final List<String> magiasTravadas;

  factory SubclassOption.fromJson(Map<String, dynamic> json) => SubclassOption(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    imagem: json['imagem'] as String? ?? '',
    magiasTravadas: [
      for (final e in (json['magias_travadas'] as List? ?? const []))
        e as String,
    ],
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'imagem': imagem,
    'magias_travadas': [...magiasTravadas],
  };

  SubclassOption copyWith({
    String? key,
    String? nome,
    String? imagem,
    List<String>? magiasTravadas,
  }) => SubclassOption(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    imagem: imagem ?? this.imagem,
    magiasTravadas: magiasTravadas ?? this.magiasTravadas,
  );
}

enum TipoArmadura { couro, escamas, malha, escudo }

class EquipmentItem {
  const EquipmentItem({
    required this.key,
    required this.nome,
    required this.imagem,
    this.pesoKg = 0,
    this.slot,
    this.armadura,
    this.dano,
    this.tipoDano,
    this.atributoAtaque,
    this.consumivel = false,
    this.descricao,
  });

  final String key;
  final String nome;
  final String imagem;
  final double pesoKg;
  final EquipSlot? slot;
  final TipoArmadura? armadura;
  final String? dano;
  final String? tipoDano;
  final Ability? atributoAtaque;
  final bool consumivel;
  final String? descricao;

  InventoryItem paraInventario() => InventoryItem(
    id: key,
    nome: nome,
    imagem: imagem,
    pesoKg: pesoKg,
    equipadoEm: slot,
    slot: slot ?? (dano != null ? EquipSlot.maoPrincipal : null),
    dano: dano,
    tipoDano: tipoDano,
    atributoAtaque: atributoAtaque,
    consumivel: consumivel,
    descricao: descricao,
    bonusCa: armadura == TipoArmadura.escudo ? 2 : 0,
  );

  factory EquipmentItem.fromJson(Map<String, dynamic> json) => EquipmentItem(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    imagem: json['imagem'] as String? ?? '',
    pesoKg: (json['peso_kg'] as num?)?.toDouble() ?? 0,
    slot: lerEnumOuNulo(EquipSlot.values, json['slot']),
    armadura: lerEnumOuNulo(TipoArmadura.values, json['armadura']),
    dano: json['dano'] as String?,
    tipoDano: json['tipo_dano'] as String?,
    atributoAtaque: lerEnumOuNulo(Ability.values, json['atributo_ataque']),
    consumivel: json['consumivel'] as bool? ?? false,
    descricao: json['descricao'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'imagem': imagem,
    'peso_kg': pesoKg,
    'slot': slot?.name,
    'armadura': armadura?.name,
    'dano': dano,
    'tipo_dano': tipoDano,
    'atributo_ataque': atributoAtaque?.name,
    'consumivel': consumivel,
    'descricao': descricao,
  };

  EquipmentItem copyWith({
    String? key,
    String? nome,
    String? imagem,
    double? pesoKg,
    EquipSlot? slot,
    TipoArmadura? armadura,
    String? dano,
    String? tipoDano,
    Ability? atributoAtaque,
    bool? consumivel,
    String? descricao,
  }) => EquipmentItem(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    imagem: imagem ?? this.imagem,
    pesoKg: pesoKg ?? this.pesoKg,
    slot: slot ?? this.slot,
    armadura: armadura ?? this.armadura,
    dano: dano ?? this.dano,
    tipoDano: tipoDano ?? this.tipoDano,
    atributoAtaque: atributoAtaque ?? this.atributoAtaque,
    consumivel: consumivel ?? this.consumivel,
    descricao: descricao ?? this.descricao,
  );
}

class EquipmentChoice {
  const EquipmentChoice(this.opcoes);

  final List<EquipmentItem> opcoes;

  factory EquipmentChoice.fromJson(Map<String, dynamic> json) =>
      EquipmentChoice([
        for (final e in (json['opcoes'] as List? ?? const []))
          EquipmentItem.fromJson(e as Map<String, dynamic>),
      ]);

  Map<String, dynamic> toJson() => {
    'opcoes': [for (final e in opcoes) e.toJson()],
  };

  EquipmentChoice copyWith({List<EquipmentItem>? opcoes}) =>
      EquipmentChoice(opcoes ?? this.opcoes);
}

class SpellOption {
  const SpellOption({
    required this.key,
    required this.nome,
    required this.circulo,
    required this.escola,
    required this.linha,
    this.concentracao = false,
    this.ritual = false,
    this.tempo = '',
    this.alcance = '',
    this.componentes = '',
    this.duracao = '',
    this.descricao = '',
    this.superior = '',
    this.classes = const [],
  });

  final String key;
  final String nome;
  final String tempo;
  final String alcance;
  final String componentes;
  final String duracao;
  final String descricao;
  final String superior;
  final List<String> classes;
  final int circulo;
  final String escola;

  final String linha;
  final bool concentracao;
  final bool ritual;

  String get resumo => [
    linha,
    if (concentracao) 'concentração',
    if (ritual) 'ritual',
  ].join(' · ');

  factory SpellOption.fromJson(Map<String, dynamic> json) => SpellOption(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    circulo: (json['circulo'] as num?)?.toInt() ?? 0,
    escola: json['escola'] as String? ?? '',
    linha: json['linha'] as String? ?? '',
    concentracao: json['concentracao'] as bool? ?? false,
    ritual: json['ritual'] as bool? ?? false,
    tempo: json['tempo'] as String? ?? '',
    alcance: json['alcance'] as String? ?? '',
    componentes: json['componentes'] as String? ?? '',
    duracao: json['duracao'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
    superior: json['superior'] as String? ?? '',
    classes: [
      for (final e in (json['classes'] as List? ?? const [])) e as String,
    ],
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'circulo': circulo,
    'escola': escola,
    'linha': linha,
    'concentracao': concentracao,
    'ritual': ritual,
    'tempo': tempo,
    'alcance': alcance,
    'componentes': componentes,
    'duracao': duracao,
    'descricao': descricao,
    'superior': superior,
    'classes': [...classes],
  };

  SpellOption copyWith({
    String? key,
    String? nome,
    int? circulo,
    String? escola,
    String? linha,
    bool? concentracao,
    bool? ritual,
    String? tempo,
    String? alcance,
    String? componentes,
    String? duracao,
    String? descricao,
    String? superior,
    List<String>? classes,
  }) => SpellOption(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    circulo: circulo ?? this.circulo,
    escola: escola ?? this.escola,
    linha: linha ?? this.linha,
    concentracao: concentracao ?? this.concentracao,
    ritual: ritual ?? this.ritual,
    tempo: tempo ?? this.tempo,
    alcance: alcance ?? this.alcance,
    componentes: componentes ?? this.componentes,
    duracao: duracao ?? this.duracao,
    descricao: descricao ?? this.descricao,
    superior: superior ?? this.superior,
    classes: classes ?? this.classes,
  );
}

class ClassOption {
  const ClassOption({
    required this.key,
    required this.nome,
    required this.imagem,
    required this.dadoDeVida,
    required this.principal,
    required this.salvaguardas,
    required this.qtdePericias,
    required this.proficiencias,
    this.nomeF,
    this.pericias = const [],
    this.rotuloSubclasse,
    this.subclasses = const [],
    this.truques = 0,
    this.magias = 0,
    this.atributoPreparo,
    this.espacosNivel1 = 0,
    this.listaMagias = const [],
    this.equipamento = const [],
    this.sempreIncluso = const [],
  });

  final String key;
  final String nome;
  final String? nomeF;
  final String imagem;
  final int dadoDeVida;
  final Ability principal;
  final Set<Ability> salvaguardas;
  final int qtdePericias;

  final List<String> pericias;
  final List<String> proficiencias;

  final String? rotuloSubclasse;
  final List<SubclassOption> subclasses;
  final int truques;

  final int magias;

  final Ability? atributoPreparo;
  final int espacosNivel1;
  final List<SpellOption> listaMagias;
  final List<EquipmentChoice> equipamento;
  final List<EquipmentItem> sempreIncluso;

  bool get temMagia => espacosNivel1 > 0;
  bool get escolheSubclasse => subclasses.isNotEmpty;
  bool get temPacote => equipamento.isNotEmpty;

  String nomePara({required bool feminino}) =>
      feminino ? (nomeF ?? nome) : nome;

  factory ClassOption.fromJson(Map<String, dynamic> json) => ClassOption(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    imagem: json['imagem'] as String? ?? '',
    dadoDeVida: (json['dado_de_vida'] as num?)?.toInt() ?? 0,
    principal: lerEnum(Ability.values, json['principal'], Ability.values.first),
    salvaguardas: {
      for (final e in (json['salvaguardas'] as List? ?? const []))
        ?lerEnumOuNulo(Ability.values, e),
    },
    qtdePericias: (json['qtde_pericias'] as num?)?.toInt() ?? 0,
    proficiencias: [
      for (final e in (json['proficiencias'] as List? ?? const [])) e as String,
    ],
    nomeF: json['nome_f'] as String?,
    pericias: [
      for (final e in (json['pericias'] as List? ?? const [])) e as String,
    ],
    rotuloSubclasse: json['rotulo_subclasse'] as String?,
    subclasses: [
      for (final e in (json['subclasses'] as List? ?? const []))
        SubclassOption.fromJson(e as Map<String, dynamic>),
    ],
    truques: (json['truques'] as num?)?.toInt() ?? 0,
    magias: (json['magias'] as num?)?.toInt() ?? 0,
    atributoPreparo: lerEnumOuNulo(Ability.values, json['atributo_preparo']),
    espacosNivel1: (json['espacos_nivel1'] as num?)?.toInt() ?? 0,
    listaMagias: [
      for (final e in (json['lista_magias'] as List? ?? const []))
        SpellOption.fromJson(e as Map<String, dynamic>),
    ],
    equipamento: [
      for (final e in (json['equipamento'] as List? ?? const []))
        EquipmentChoice.fromJson(e as Map<String, dynamic>),
    ],
    sempreIncluso: [
      for (final e in (json['sempre_incluso'] as List? ?? const []))
        EquipmentItem.fromJson(e as Map<String, dynamic>),
    ],
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'imagem': imagem,
    'dado_de_vida': dadoDeVida,
    'principal': principal.name,
    'salvaguardas': [for (final e in salvaguardas) e.name],
    'qtde_pericias': qtdePericias,
    'proficiencias': [...proficiencias],
    'nome_f': nomeF,
    'pericias': [...pericias],
    'rotulo_subclasse': rotuloSubclasse,
    'subclasses': [for (final e in subclasses) e.toJson()],
    'truques': truques,
    'magias': magias,
    'atributo_preparo': atributoPreparo?.name,
    'espacos_nivel1': espacosNivel1,
    'lista_magias': [for (final e in listaMagias) e.toJson()],
    'equipamento': [for (final e in equipamento) e.toJson()],
    'sempre_incluso': [for (final e in sempreIncluso) e.toJson()],
  };

  ClassOption copyWith({
    String? key,
    String? nome,
    String? imagem,
    int? dadoDeVida,
    Ability? principal,
    Set<Ability>? salvaguardas,
    int? qtdePericias,
    List<String>? proficiencias,
    String? nomeF,
    List<String>? pericias,
    String? rotuloSubclasse,
    List<SubclassOption>? subclasses,
    int? truques,
    int? magias,
    Ability? atributoPreparo,
    int? espacosNivel1,
    List<SpellOption>? listaMagias,
    List<EquipmentChoice>? equipamento,
    List<EquipmentItem>? sempreIncluso,
  }) => ClassOption(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    imagem: imagem ?? this.imagem,
    dadoDeVida: dadoDeVida ?? this.dadoDeVida,
    principal: principal ?? this.principal,
    salvaguardas: salvaguardas ?? this.salvaguardas,
    qtdePericias: qtdePericias ?? this.qtdePericias,
    proficiencias: proficiencias ?? this.proficiencias,
    nomeF: nomeF ?? this.nomeF,
    pericias: pericias ?? this.pericias,
    rotuloSubclasse: rotuloSubclasse ?? this.rotuloSubclasse,
    subclasses: subclasses ?? this.subclasses,
    truques: truques ?? this.truques,
    magias: magias ?? this.magias,
    atributoPreparo: atributoPreparo ?? this.atributoPreparo,
    espacosNivel1: espacosNivel1 ?? this.espacosNivel1,
    listaMagias: listaMagias ?? this.listaMagias,
    equipamento: equipamento ?? this.equipamento,
    sempreIncluso: sempreIncluso ?? this.sempreIncluso,
  );
}

class BackgroundOption {
  const BackgroundOption({
    required this.key,
    required this.nome,
    required this.descricao,
    required this.pericias,
    this.extras = const [],
    this.idiomasExtras = 0,
    this.srd = false,
  });

  final String key;
  final String nome;
  final String descricao;
  final List<String> pericias;
  final List<String> extras;
  final int idiomasExtras;
  final bool srd;

  factory BackgroundOption.fromJson(Map<String, dynamic> json) =>
      BackgroundOption(
        key: json['key'] as String? ?? '',
        nome: json['nome'] as String? ?? '',
        descricao: json['descricao'] as String? ?? '',
        pericias: [
          for (final e in (json['pericias'] as List? ?? const [])) e as String,
        ],
        extras: [
          for (final e in (json['extras'] as List? ?? const [])) e as String,
        ],
        idiomasExtras: (json['idiomas_extras'] as num?)?.toInt() ?? 0,
        srd: json['srd'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'descricao': descricao,
    'pericias': [...pericias],
    'extras': [...extras],
    'idiomas_extras': idiomasExtras,
    'srd': srd,
  };

  BackgroundOption copyWith({
    String? key,
    String? nome,
    String? descricao,
    List<String>? pericias,
    List<String>? extras,
    int? idiomasExtras,
    bool? srd,
  }) => BackgroundOption(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    descricao: descricao ?? this.descricao,
    pericias: pericias ?? this.pericias,
    extras: extras ?? this.extras,
    idiomasExtras: idiomasExtras ?? this.idiomasExtras,
    srd: srd ?? this.srd,
  );
}

class SkillOption {
  const SkillOption(this.nome, this.atributo);

  final String nome;
  final Ability atributo;

  factory SkillOption.fromJson(Map<String, dynamic> json) => SkillOption(
    json['nome'] as String? ?? '',
    lerEnum(Ability.values, json['atributo'], Ability.values.first),
  );

  Map<String, dynamic> toJson() => {'nome': nome, 'atributo': atributo.name};

  SkillOption copyWith({String? nome, Ability? atributo}) =>
      SkillOption(nome ?? this.nome, atributo ?? this.atributo);
}

String sinal(int v) => v >= 0 ? '+$v' : '$v';

const custoCompra = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};
const limiteCompra = 27;
const arrayPadrao = [15, 14, 13, 12, 10, 8];
