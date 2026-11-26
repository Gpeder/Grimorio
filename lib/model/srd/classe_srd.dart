import 'package:grimorio/model/json.dart';

// caracteristica da classe, ou coluna da tabela de progressao
class CaracteristicaSrd {
  const CaracteristicaSrd({
    required this.nome,
    this.descricao = '',
    this.tipo,
    this.niveis = const [],
    this.tabela = const {},
  });

  final String nome;
  final String descricao;

  // CLASS_LEVEL_FEATURE, SPELL_SLOTS, PROFICIENCY_BONUS...
  final String? tipo;

  // niveis em que ganha, em ordem
  final List<int> niveis;

  // nivel -> valor da coluna
  final Map<int, String> tabela;

  static const deNivel = 'CLASS_LEVEL_FEATURE';
  static const espacos = 'SPELL_SLOTS';
  static const proficiencia = 'PROFICIENCY_BONUS';
  static const proficiencias = 'PROFICIENCIES';
  static const equipamento = 'STARTING_EQUIPMENT';

  factory CaracteristicaSrd.fromJson(Map<String, dynamic> json) =>
      CaracteristicaSrd(
        nome: json['name'] as String? ?? '—',
        descricao: json['desc'] as String? ?? '',
        tipo: json['feature_type'] as String?,
        niveis: [
          for (final g in lerLista(json['gained_at'])) ?lerInteiro(g['level']),
        ]..sort(),
        tabela: {
          for (final t in lerLista(json['data_for_class_table']))
            if ((lerInteiro(t['level']), t['column_value']) case (
              final int n,
              final String v,
            ))
              n: v,
        },
      );

  Map<String, dynamic> toJson() => {
    'name': nome,
    'desc': descricao,
    'feature_type': tipo,
    'gained_at': [
      for (final n in niveis) {'level': n},
    ],
    'data_for_class_table': [
      for (final MapEntry(:key, :value) in tabela.entries)
        {'level': key, 'column_value': value},
    ],
  };
}

// classe subclasse de /classes/
class ClasseSrd {
  const ClasseSrd({
    required this.key,
    required this.nome,
    this.descricao = '',
    this.dadoDeVida,
    this.pvPrimeiroNivel,
    this.pvProximosNiveis,
    this.salvaguardas = const [],
    this.conjurador,
    this.subclasseDe,
    this.caracteristicas = const [],
  });

  final String key;
  final String nome;
  final String descricao;

  // ex D12
  final String? dadoDeVida;

  // texto da api, ex 6 + your Constitution modifier
  final String? pvPrimeiroNivel;
  final String? pvProximosNiveis;
  final List<String> salvaguardas;

  // NONE, FULL, HALF...
  final String? conjurador;

  // key da classe mae
  final String? subclasseDe;
  final List<CaracteristicaSrd> caracteristicas;

  bool get subclasse => subclasseDe != null;

  // caracteristicas de nivel, pela ordem em que chegam
  List<CaracteristicaSrd> get deNivel =>
      [
        for (final c in caracteristicas)
          if (c.tipo == CaracteristicaSrd.deNivel && c.niveis.isNotEmpty) c,
      ]..sort((a, b) {
        final n = a.niveis.first.compareTo(b.niveis.first);
        return n != 0 ? n : a.nome.compareTo(b.nome);
      });

  // texto da caracteristica de um tipo, ex as proficiencias
  String? textoDo(String tipo) {
    for (final c in caracteristicas) {
      if (c.tipo == tipo && c.descricao.trim().isNotEmpty) return c.descricao;
    }
    return null;
  }

  // nomes ganhos no nivel
  List<String> noNivel(int nivel) => [
    for (final c in deNivel)
      if (c.niveis.contains(nivel)) c.nome,
  ];

  // +2 no nivel 1
  String? proficienciaNoNivel(int nivel) {
    for (final c in caracteristicas) {
      if (c.tipo == CaracteristicaSrd.proficiencia) return c.tabela[nivel];
    }
    return null;
  }

  // espacos por circulo no nivel, indice 0 e o 1º circulo
  List<int> espacosNoNivel(int nivel) {
    final colunas = [
      for (final c in caracteristicas)
        if (c.tipo == CaracteristicaSrd.espacos) c,
    ]..sort((a, b) => a.nome.compareTo(b.nome));
    return [for (final c in colunas) int.tryParse(c.tabela[nivel] ?? '') ?? 0];
  }

  bool get temEspacos =>
      caracteristicas.any((c) => c.tipo == CaracteristicaSrd.espacos);

  factory ClasseSrd.fromJson(Map<String, dynamic> json) {
    final pv = switch (json['hit_points']) {
      final Map<String, dynamic> m => m,
      _ => const <String, dynamic>{},
    };
    return ClasseSrd(
      key: json['key'] as String? ?? '',
      nome: json['name'] as String? ?? '—',
      descricao: json['desc'] as String? ?? '',
      dadoDeVida: json['hit_dice'] as String?,
      pvPrimeiroNivel: pv['hit_points_at_1st_level'] as String?,
      pvProximosNiveis: pv['hit_points_at_higher_levels'] as String?,
      salvaguardas: [
        for (final s in lerLista(json['saving_throws'])) ?lerNome(s),
      ],
      conjurador: json['caster_type'] as String?,
      subclasseDe: lerKey(json['subclass_of']),
      caracteristicas: [
        for (final f in lerLista(json['features']))
          CaracteristicaSrd.fromJson(f),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'desc': descricao,
    'hit_dice': dadoDeVida,
    'hit_points': {
      'hit_points_at_1st_level': pvPrimeiroNivel,
      'hit_points_at_higher_levels': pvProximosNiveis,
    },
    'saving_throws': [
      for (final s in salvaguardas) {'name': s},
    ],
    'caster_type': conjurador,
    'subclass_of': subclasseDe == null ? null : {'key': subclasseDe},
    'features': [for (final f in caracteristicas) f.toJson()],
  };
}
