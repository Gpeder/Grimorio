import 'package:grimorio/model/json.dart';

// item de /items/, /magicitems/, /weapons/ ou /armor/
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
    this.caBase,
    this.caTexto,
  });

  final String key;
  final String nome;
  final String descricao;
  final String? categoria;
  final String? raridade;
  final bool sintonia;
  final double? pesoLb;

  // em po, vem como texto
  final String? custo;

  // arma
  final String? dano;
  final String? tipoDano;

  // armadura
  final int? caBase;
  final String? caTexto;

  factory ItemSrd.fromJson(Map<String, dynamic> json) => ItemSrd(
    key: json['key'] as String? ?? '',
    nome: json['name'] as String? ?? '—',
    descricao: json['desc'] as String? ?? '',
    categoria: lerNome(json['category']),
    raridade: lerNome(json['rarity']),
    sintonia: json['requires_attunement'] as bool? ?? false,
    pesoLb: lerNumero(json['weight']),
    custo: json['cost']?.toString(),
    dano: json['damage_dice'] as String?,
    tipoDano: lerNome(json['damage_type']),
    caBase: lerInteiro(json['ac_base']),
    caTexto: json['ac_display'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'desc': descricao,
    'category': categoria == null ? null : {'name': categoria},
    'rarity': raridade == null ? null : {'name': raridade},
    'requires_attunement': sintonia,
    'weight': pesoLb,
    'cost': custo,
    'damage_dice': dano,
    'damage_type': tipoDano == null ? null : {'name': tipoDano},
    'ac_base': caBase,
    'ac_display': caTexto,
  };
}
