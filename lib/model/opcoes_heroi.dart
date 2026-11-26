import 'package:grimorio/model/json.dart';
import 'package:grimorio/model/personagem.dart';

const nomeAtributo = {
  Atributo.forca: 'Força',
  Atributo.destreza: 'Destreza',
  Atributo.constituicao: 'Constituição',
  Atributo.inteligencia: 'Inteligência',
  Atributo.sabedoria: 'Sabedoria',
  Atributo.carisma: 'Carisma',
};

const proficienciaNivel1 = 2;

class OpcaoSubespecie {
  const OpcaoSubespecie({
    required this.key,
    required this.nome,
    this.bonus = const {},
    this.hpPorNivel = 0,
  });

  final String key;
  final String nome;
  final Map<Atributo, int> bonus;
  final int hpPorNivel;

  factory OpcaoSubespecie.fromJson(Map<String, dynamic> json) =>
      OpcaoSubespecie(
        key: json['key'] as String? ?? '',
        nome: json['nome'] as String? ?? '',
        bonus: {
          for (final MapEntry(:key, :value)
              in (json['bonus'] as Map? ?? const {}).entries)
            ?lerEnumOuNulo(Atributo.values, key): (value as num).toInt(),
        },
        hpPorNivel: (json['hp_por_nivel'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'bonus': {for (final e in bonus.entries) e.key.name: e.value},
    'hp_por_nivel': hpPorNivel,
  };

  OpcaoSubespecie copyWith({
    String? key,
    String? nome,
    Map<Atributo, int>? bonus,
    int? hpPorNivel,
  }) => OpcaoSubespecie(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    bonus: bonus ?? this.bonus,
    hpPorNivel: hpPorNivel ?? this.hpPorNivel,
  );
}

class OpcaoEspecie {
  const OpcaoEspecie({
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
  final Map<Atributo, int> bonus;
  final double deslocamentoM;
  final int? visaoNoEscuroM;
  final List<String> pericias;
  final String retratoF;
  final String retratoM;
  final List<String> tracos;
  final List<String> idiomas;
  final List<OpcaoSubespecie> subespecies;

  final int bonusLivres;

  final int periciasLivres;
  final int idiomasExtras;

  String nomePara({required bool feminino}) =>
      feminino ? (nomeF ?? nome) : nome;

  String retratoPara({required bool feminino}) =>
      feminino ? retratoF : retratoM;

  factory OpcaoEspecie.fromJson(Map<String, dynamic> json) => OpcaoEspecie(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
    bonus: {
      for (final MapEntry(:key, :value)
          in (json['bonus'] as Map? ?? const {}).entries)
        ?lerEnumOuNulo(Atributo.values, key): (value as num).toInt(),
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
        OpcaoSubespecie.fromJson(e as Map<String, dynamic>),
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

  OpcaoEspecie copyWith({
    String? key,
    String? nome,
    String? descricao,
    Map<Atributo, int>? bonus,
    double? deslocamentoM,
    String? retratoF,
    String? retratoM,
    List<String>? tracos,
    List<String>? idiomas,
    String? nomeF,
    String? tamanho,
    int? visaoNoEscuroM,
    List<String>? pericias,
    List<OpcaoSubespecie>? subespecies,
    int? bonusLivres,
    int? periciasLivres,
    int? idiomasExtras,
  }) => OpcaoEspecie(
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

class OpcaoSubclasse {
  const OpcaoSubclasse({
    required this.key,
    required this.nome,
    required this.imagem,
    this.magiasTravadas = const [],
  });

  final String key;
  final String nome;
  final String imagem;

  final List<String> magiasTravadas;

  factory OpcaoSubclasse.fromJson(Map<String, dynamic> json) => OpcaoSubclasse(
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

  OpcaoSubclasse copyWith({
    String? key,
    String? nome,
    String? imagem,
    List<String>? magiasTravadas,
  }) => OpcaoSubclasse(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    imagem: imagem ?? this.imagem,
    magiasTravadas: magiasTravadas ?? this.magiasTravadas,
  );
}

enum TipoArmadura { couro, escamas, malha, escudo }

class ItemEquipamento {
  const ItemEquipamento({
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
  final SlotEquipamento? slot;
  final TipoArmadura? armadura;
  final String? dano;
  final String? tipoDano;
  final Atributo? atributoAtaque;
  final bool consumivel;
  final String? descricao;

  ItemInventario paraInventario() => ItemInventario(
    id: key,
    nome: nome,
    imagem: imagem,
    pesoKg: pesoKg,
    equipadoEm: slot,
    slot: slot ?? (dano != null ? SlotEquipamento.maoPrincipal : null),
    dano: dano,
    tipoDano: tipoDano,
    atributoAtaque: atributoAtaque,
    consumivel: consumivel,
    descricao: descricao,
    bonusCa: armadura == TipoArmadura.escudo ? 2 : 0,
  );

  factory ItemEquipamento.fromJson(Map<String, dynamic> json) =>
      ItemEquipamento(
        key: json['key'] as String? ?? '',
        nome: json['nome'] as String? ?? '',
        imagem: json['imagem'] as String? ?? '',
        pesoKg: (json['peso_kg'] as num?)?.toDouble() ?? 0,
        slot: lerEnumOuNulo(SlotEquipamento.values, json['slot']),
        armadura: lerEnumOuNulo(TipoArmadura.values, json['armadura']),
        dano: json['dano'] as String?,
        tipoDano: json['tipo_dano'] as String?,
        atributoAtaque: lerEnumOuNulo(Atributo.values, json['atributo_ataque']),
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

  ItemEquipamento copyWith({
    String? key,
    String? nome,
    String? imagem,
    double? pesoKg,
    SlotEquipamento? slot,
    TipoArmadura? armadura,
    String? dano,
    String? tipoDano,
    Atributo? atributoAtaque,
    bool? consumivel,
    String? descricao,
  }) => ItemEquipamento(
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

class EscolhaEquipamento {
  const EscolhaEquipamento(this.opcoes);

  final List<ItemEquipamento> opcoes;

  factory EscolhaEquipamento.fromJson(Map<String, dynamic> json) =>
      EscolhaEquipamento([
        for (final e in (json['opcoes'] as List? ?? const []))
          ItemEquipamento.fromJson(e as Map<String, dynamic>),
      ]);

  Map<String, dynamic> toJson() => {
    'opcoes': [for (final e in opcoes) e.toJson()],
  };

  EscolhaEquipamento copyWith({List<ItemEquipamento>? opcoes}) =>
      EscolhaEquipamento(opcoes ?? this.opcoes);
}

class OpcaoMagia {
  const OpcaoMagia({
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

  factory OpcaoMagia.fromJson(Map<String, dynamic> json) => OpcaoMagia(
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

  OpcaoMagia copyWith({
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
  }) => OpcaoMagia(
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

class OpcaoClasse {
  const OpcaoClasse({
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
  final Atributo principal;
  final Set<Atributo> salvaguardas;
  final int qtdePericias;

  final List<String> pericias;
  final List<String> proficiencias;

  final String? rotuloSubclasse;
  final List<OpcaoSubclasse> subclasses;
  final int truques;

  final int magias;

  final Atributo? atributoPreparo;
  final int espacosNivel1;
  final List<OpcaoMagia> listaMagias;
  final List<EscolhaEquipamento> equipamento;
  final List<ItemEquipamento> sempreIncluso;

  bool get temMagia => espacosNivel1 > 0;
  bool get escolheSubclasse => subclasses.isNotEmpty;
  bool get temPacote => equipamento.isNotEmpty;

  String nomePara({required bool feminino}) =>
      feminino ? (nomeF ?? nome) : nome;

  factory OpcaoClasse.fromJson(Map<String, dynamic> json) => OpcaoClasse(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    imagem: json['imagem'] as String? ?? '',
    dadoDeVida: (json['dado_de_vida'] as num?)?.toInt() ?? 0,
    principal: lerEnum(
      Atributo.values,
      json['principal'],
      Atributo.values.first,
    ),
    salvaguardas: {
      for (final e in (json['salvaguardas'] as List? ?? const []))
        ?lerEnumOuNulo(Atributo.values, e),
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
        OpcaoSubclasse.fromJson(e as Map<String, dynamic>),
    ],
    truques: (json['truques'] as num?)?.toInt() ?? 0,
    magias: (json['magias'] as num?)?.toInt() ?? 0,
    atributoPreparo: lerEnumOuNulo(Atributo.values, json['atributo_preparo']),
    espacosNivel1: (json['espacos_nivel1'] as num?)?.toInt() ?? 0,
    listaMagias: [
      for (final e in (json['lista_magias'] as List? ?? const []))
        OpcaoMagia.fromJson(e as Map<String, dynamic>),
    ],
    equipamento: [
      for (final e in (json['equipamento'] as List? ?? const []))
        EscolhaEquipamento.fromJson(e as Map<String, dynamic>),
    ],
    sempreIncluso: [
      for (final e in (json['sempre_incluso'] as List? ?? const []))
        ItemEquipamento.fromJson(e as Map<String, dynamic>),
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

  OpcaoClasse copyWith({
    String? key,
    String? nome,
    String? imagem,
    int? dadoDeVida,
    Atributo? principal,
    Set<Atributo>? salvaguardas,
    int? qtdePericias,
    List<String>? proficiencias,
    String? nomeF,
    List<String>? pericias,
    String? rotuloSubclasse,
    List<OpcaoSubclasse>? subclasses,
    int? truques,
    int? magias,
    Atributo? atributoPreparo,
    int? espacosNivel1,
    List<OpcaoMagia>? listaMagias,
    List<EscolhaEquipamento>? equipamento,
    List<ItemEquipamento>? sempreIncluso,
  }) => OpcaoClasse(
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

class OpcaoAntecedente {
  const OpcaoAntecedente({
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

  factory OpcaoAntecedente.fromJson(Map<String, dynamic> json) =>
      OpcaoAntecedente(
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

  OpcaoAntecedente copyWith({
    String? key,
    String? nome,
    String? descricao,
    List<String>? pericias,
    List<String>? extras,
    int? idiomasExtras,
    bool? srd,
  }) => OpcaoAntecedente(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    descricao: descricao ?? this.descricao,
    pericias: pericias ?? this.pericias,
    extras: extras ?? this.extras,
    idiomasExtras: idiomasExtras ?? this.idiomasExtras,
    srd: srd ?? this.srd,
  );
}

class OpcaoPericia {
  const OpcaoPericia(this.nome, this.atributo);

  final String nome;
  final Atributo atributo;

  factory OpcaoPericia.fromJson(Map<String, dynamic> json) => OpcaoPericia(
    json['nome'] as String? ?? '',
    lerEnum(Atributo.values, json['atributo'], Atributo.values.first),
  );

  Map<String, dynamic> toJson() => {'nome': nome, 'atributo': atributo.name};

  OpcaoPericia copyWith({String? nome, Atributo? atributo}) =>
      OpcaoPericia(nome ?? this.nome, atributo ?? this.atributo);
}

String sinal(int v) => v >= 0 ? '+$v' : '$v';

const custoCompra = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};
const limiteCompra = 27;
const arrayPadrao = [15, 14, 13, 12, 10, 8];
