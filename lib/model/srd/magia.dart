import 'package:grimorio/model/json.dart';

// magia vinda de /spells/
class Magia {
  const Magia({
    required this.key,
    required this.nome,
    this.nivel = 0,
    this.escola,
    this.alcance,
    this.tempo,
    this.duracao,
    this.concentracao = false,
    this.ritual = false,
    this.verbal = false,
    this.somatico = false,
    this.material = false,
    this.materialDetalhe,
    this.descricao = '',
    this.superior,
    this.classes = const [],
  });

  final String key;
  final String nome;

  // 0 é truque
  final int nivel;
  final String? escola;
  final String? alcance;
  final String? tempo;
  final String? duracao;
  final bool concentracao;
  final bool ritual;
  final bool verbal;
  final bool somatico;
  final bool material;
  final String? materialDetalhe;
  final String descricao;
  final String? superior;
  final List<String> classes;

  // ex V, S, M
  String get componentes =>
      [if (verbal) 'V', if (somatico) 'S', if (material) 'M'].join(', ');

  factory Magia.fromJson(Map<String, dynamic> json) => Magia(
    key: json['key'] as String? ?? '',
    nome: json['name'] as String? ?? '—',
    nivel: lerInteiro(json['level']) ?? 0,
    escola: lerNome(json['school']),
    alcance: json['range_text'] as String?,
    tempo: json['casting_time'] as String?,
    duracao: json['duration'] as String?,
    concentracao: json['concentration'] as bool? ?? false,
    ritual: json['ritual'] as bool? ?? false,
    verbal: json['verbal'] as bool? ?? false,
    somatico: json['somatic'] as bool? ?? false,
    material: json['material'] as bool? ?? false,
    materialDetalhe: json['material_specified'] as String?,
    descricao: json['desc'] as String? ?? '',
    superior: json['higher_level'] as String?,
    classes: [for (final c in lerLista(json['classes'])) ?lerNome(c)],
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'level': nivel,
    'school': escola == null ? null : {'name': escola},
    'range_text': alcance,
    'casting_time': tempo,
    'duration': duracao,
    'concentration': concentracao,
    'ritual': ritual,
    'verbal': verbal,
    'somatic': somatico,
    'material': material,
    'material_specified': materialDetalhe,
    'desc': descricao,
    'higher_level': superior,
    'classes': [
      for (final c in classes) {'name': c},
    ],
  };
}
