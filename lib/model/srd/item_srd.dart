import 'package:grimorio/model/json.dart';

// propriedade de arma, ex Versatile (1d10)
class PropriedadeSrd {
  const PropriedadeSrd({required this.nome, this.detalhe});

  final String nome;
  final String? detalhe;

  factory PropriedadeSrd.fromJson(Map<String, dynamic> json) => PropriedadeSrd(
    nome: lerNome(json['property']) ?? '—',
    detalhe: json['detail'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'property': {'name': nome},
    'detail': detalhe,
  };
}

// item
class ItemSrd {
  const ItemSrd({
    required this.key,
    required this.nome,
    this.descricao = '',
    this.categoria,
    this.raridade,
    this.sintonia = false,
    this.pesoLb,
    this.custo,
    this.dano,
    this.tipoDano,
    this.propriedades = const [],
    this.caBase,
    this.caTexto,
    this.categoriaArmadura,
    this.desvantagemFurtividade = false,
    this.forcaMinima,
  });

  final String key;
  final String nome;
  final String descricao;
  final String? categoria;
  final String? raridade;
  final bool sintonia;
  final double? pesoLb;
  final String? custo;
  final String? dano;
  final String? tipoDano;
  final List<PropriedadeSrd> propriedades;
  final int? caBase;
  final String? caTexto;

  // light, medium, heavy
  final String? categoriaArmadura;
  final bool desvantagemFurtividade;
  final int? forcaMinima;

  bool get arma => dano != null;
  bool get armadura => caBase != null || caTexto != null;

  // /items/ traz arma e armadura dentro de weapon e armor
  // /weapons/ e /armor/ trazem no topo
  factory ItemSrd.fromJson(Map<String, dynamic> json) {
    final w = switch (json['weapon']) {
      final Map<String, dynamic> m => m,
      _ => json,
    };
    final a = switch (json['armor']) {
      final Map<String, dynamic> m => m,
      _ => json,
    };
    return ItemSrd(
      key: json['key'] as String? ?? '',
      nome: json['name'] as String? ?? '—',
      descricao: json['desc'] as String? ?? '',
      categoria: lerNome(json['category']),
      raridade: lerNome(json['rarity']),
      sintonia: json['requires_attunement'] as bool? ?? false,
      pesoLb: lerNumero(json['weight']),
      custo: json['cost']?.toString(),
      dano: w['damage_dice'] as String?,
      tipoDano: lerNome(w['damage_type']),
      propriedades: [
        for (final p in lerLista(w['properties'])) PropriedadeSrd.fromJson(p),
      ],
      caBase: lerInteiro(a['ac_base']),
      caTexto: a['ac_display'] as String?,
      categoriaArmadura: identical(a, json) ? null : a['category'] as String?,
      desvantagemFurtividade:
          a['grants_stealth_disadvantage'] as bool? ?? false,
      forcaMinima: lerInteiro(a['strength_score_required']),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'desc': descricao,
    'category': categoria == null ? null : {'name': categoria},
    'rarity': raridade == null ? null : {'name': raridade},
    'requires_attunement': sintonia,
    'weight': pesoLb,
    'cost': custo,
    'weapon': arma
        ? {
            'damage_dice': dano,
            'damage_type': tipoDano == null ? null : {'name': tipoDano},
            'properties': [for (final p in propriedades) p.toJson()],
          }
        : null,
    'armor': armadura
        ? {
            'ac_base': caBase,
            'ac_display': caTexto,
            'category': categoriaArmadura,
            'grants_stealth_disadvantage': desvantagemFurtividade,
            'strength_score_required': forcaMinima,
          }
        : null,
  };
}
