import 'package:grimorio/model/json.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';

// especie de /species/
class Especie {
  const Especie({
    required this.key,
    required this.nome,
    this.descricao = '',
    this.tracos = const [],
    this.subespecieDe,
  });

  final String key;
  final String nome;
  final String descricao;

  // mesmo formato nome + desc das acoes
  final List<AcaoSrd> tracos;
  final String? subespecieDe;

  bool get subespecie => subespecieDe != null;

  factory Especie.fromJson(Map<String, dynamic> json) => Especie(
    key: json['key'] as String? ?? '',
    nome: json['name'] as String? ?? '—',
    descricao: json['desc'] as String? ?? '',
    tracos: [for (final t in lerLista(json['traits'])) AcaoSrd.fromJson(t)],
    subespecieDe: lerKey(json['subspecies_of']),
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'desc': descricao,
    'traits': [for (final t in tracos) t.toJson()],
    'subspecies_of': subespecieDe == null ? null : {'key': subespecieDe},
  };
}
