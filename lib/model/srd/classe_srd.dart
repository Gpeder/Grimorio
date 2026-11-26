import 'package:grimorio/model/json.dart';

// classe ou subclasse de /classes/
class ClasseSrd {
  const ClasseSrd({
    required this.key,
    required this.nome,
    this.descricao = '',
    this.dadoDeVida,
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
  final List<String> salvaguardas;

  // NONE, FULL, HALF...
  final String? conjurador;

  // key da classe mae
  final String? subclasseDe;
  final List<String> caracteristicas;

  bool get subclasse => subclasseDe != null;

  factory ClasseSrd.fromJson(Map<String, dynamic> json) => ClasseSrd(
    key: json['key'] as String? ?? '',
    nome: json['name'] as String? ?? '—',
    descricao: json['desc'] as String? ?? '',
    dadoDeVida: json['hit_dice'] as String?,
    salvaguardas: [
      for (final s in lerLista(json['saving_throws'])) ?lerNome(s),
    ],
    conjurador: json['caster_type'] as String?,
    subclasseDe: lerKey(json['subclass_of']),
    caracteristicas: [for (final f in lerLista(json['features'])) ?lerNome(f)],
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'desc': descricao,
    'hit_dice': dadoDeVida,
    'saving_throws': [
      for (final s in salvaguardas) {'name': s},
    ],
    'caster_type': conjurador,
    'subclass_of': subclasseDe == null ? null : {'key': subclasseDe},
    'features': [
      for (final f in caracteristicas) {'name': f},
    ],
  };
}
