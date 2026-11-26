import 'dart:ui';

import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/json.dart';

enum Raridade {
  comum('Comum'),
  incomum('Incomum'),
  raro('Raro'),
  muitoRaro('Muito raro'),
  lendario('Lendário');

  const Raridade(this.nome);
  final String nome;

  Color get cor => switch (this) {
    Raridade.comum => AppColors.onSurface.withValues(alpha: 0.6),
    Raridade.incomum => AppColors.sucesso,
    Raridade.raro => AppColors.mana,
    Raridade.muitoRaro => AppColors.primary,
    Raridade.lendario => AppColors.exp,
  };
}

class AcaoMonstro {
  const AcaoMonstro({
    required this.nome,
    required this.descricao,
    this.ataque,
    this.dano,
  });

  final String nome;
  final String descricao;

  // "+4 para acertar" ou "Salv. CON CD 14".
  final String? ataque;

  // "1d6 + 2 cortante".
  final String? dano;

  factory AcaoMonstro.fromJson(Map<String, dynamic> json) => AcaoMonstro(
    nome: json['nome'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
    ataque: json['ataque'] as String?,
    dano: json['dano'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'ataque': ataque,
    'dano': dano,
  };

  AcaoMonstro copyWith({
    String? nome,
    String? descricao,
    String? ataque,
    String? dano,
  }) => AcaoMonstro(
    nome: nome ?? this.nome,
    descricao: descricao ?? this.descricao,
    ataque: ataque ?? this.ataque,
    dano: dano ?? this.dano,
  );
}

class Monstro {
  const Monstro({
    required this.key,
    required this.nome,
    required this.tipo,
    required this.tamanho,
    required this.alinhamento,
    required this.nd,
    required this.xp,
    required this.ca,
    required this.caDetalhe,
    required this.pv,
    required this.pvDado,
    required this.deslocamento,
    required this.atributos,
    required this.imagem,
    this.sentidos = const [],
    this.idiomas = const [],
    this.tracos = const [],
    this.acoes = const [],
    this.acoesLendarias = const [],
  });

  final String key;
  final String nome;
  final String tipo;
  final String tamanho;
  final String alinhamento;

  // "1/4", "2"…
  final String nd;
  final int xp;
  final int ca;
  final String caDetalhe;
  final int pv;
  final String pvDado;
  final String deslocamento;
  final AbilityScores atributos;
  final List<String> sentidos;
  final List<String> idiomas;
  final List<AcaoMonstro> tracos;
  final List<AcaoMonstro> acoes;
  final List<AcaoMonstro> acoesLendarias;
  final String imagem;

  double get ndValor {
    final partes = nd.split('/');
    if (partes.length == 2) {
      return int.parse(partes[0]) / int.parse(partes[1]);
    }
    return double.parse(nd);
  }

  factory Monstro.fromJson(Map<String, dynamic> json) => Monstro(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    tipo: json['tipo'] as String? ?? '',
    tamanho: json['tamanho'] as String? ?? '',
    alinhamento: json['alinhamento'] as String? ?? '',
    nd: json['nd'] as String? ?? '',
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    ca: (json['ca'] as num?)?.toInt() ?? 0,
    caDetalhe: json['ca_detalhe'] as String? ?? '',
    pv: (json['pv'] as num?)?.toInt() ?? 0,
    pvDado: json['pv_dado'] as String? ?? '',
    deslocamento: json['deslocamento'] as String? ?? '',
    atributos: AbilityScores.fromJson(
      json['atributos'] as Map<String, dynamic>,
    ),
    imagem: json['imagem'] as String? ?? '',
    sentidos: [
      for (final e in (json['sentidos'] as List? ?? const [])) e as String,
    ],
    idiomas: [
      for (final e in (json['idiomas'] as List? ?? const [])) e as String,
    ],
    tracos: [
      for (final e in (json['tracos'] as List? ?? const []))
        AcaoMonstro.fromJson(e as Map<String, dynamic>),
    ],
    acoes: [
      for (final e in (json['acoes'] as List? ?? const []))
        AcaoMonstro.fromJson(e as Map<String, dynamic>),
    ],
    acoesLendarias: [
      for (final e in (json['acoes_lendarias'] as List? ?? const []))
        AcaoMonstro.fromJson(e as Map<String, dynamic>),
    ],
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'tipo': tipo,
    'tamanho': tamanho,
    'alinhamento': alinhamento,
    'nd': nd,
    'xp': xp,
    'ca': ca,
    'ca_detalhe': caDetalhe,
    'pv': pv,
    'pv_dado': pvDado,
    'deslocamento': deslocamento,
    'atributos': atributos.toJson(),
    'imagem': imagem,
    'sentidos': [...sentidos],
    'idiomas': [...idiomas],
    'tracos': [for (final e in tracos) e.toJson()],
    'acoes': [for (final e in acoes) e.toJson()],
    'acoes_lendarias': [for (final e in acoesLendarias) e.toJson()],
  };

  Monstro copyWith({
    String? key,
    String? nome,
    String? tipo,
    String? tamanho,
    String? alinhamento,
    String? nd,
    int? xp,
    int? ca,
    String? caDetalhe,
    int? pv,
    String? pvDado,
    String? deslocamento,
    AbilityScores? atributos,
    String? imagem,
    List<String>? sentidos,
    List<String>? idiomas,
    List<AcaoMonstro>? tracos,
    List<AcaoMonstro>? acoes,
    List<AcaoMonstro>? acoesLendarias,
  }) => Monstro(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    tamanho: tamanho ?? this.tamanho,
    alinhamento: alinhamento ?? this.alinhamento,
    nd: nd ?? this.nd,
    xp: xp ?? this.xp,
    ca: ca ?? this.ca,
    caDetalhe: caDetalhe ?? this.caDetalhe,
    pv: pv ?? this.pv,
    pvDado: pvDado ?? this.pvDado,
    deslocamento: deslocamento ?? this.deslocamento,
    atributos: atributos ?? this.atributos,
    imagem: imagem ?? this.imagem,
    sentidos: sentidos ?? this.sentidos,
    idiomas: idiomas ?? this.idiomas,
    tracos: tracos ?? this.tracos,
    acoes: acoes ?? this.acoes,
    acoesLendarias: acoesLendarias ?? this.acoesLendarias,
  );
}

class ItemCompendio {
  const ItemCompendio({
    required this.key,
    required this.nome,
    required this.categoria,
    required this.raridade,
    required this.descricao,
    required this.imagem,
    this.sintonia = false,
    this.magico = true,
  });

  final String key;
  final String nome;

  // "Poção", "Anel", "Arma", "Armadura"…
  final String categoria;
  final Raridade raridade;
  final bool sintonia;
  final String descricao;
  final String imagem;
  final bool magico;

  factory ItemCompendio.fromJson(Map<String, dynamic> json) => ItemCompendio(
    key: json['key'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    categoria: json['categoria'] as String? ?? '',
    raridade: lerEnum(Raridade.values, json['raridade'], Raridade.values.first),
    descricao: json['descricao'] as String? ?? '',
    imagem: json['imagem'] as String? ?? '',
    sintonia: json['sintonia'] as bool? ?? false,
    magico: json['magico'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'nome': nome,
    'categoria': categoria,
    'raridade': raridade.name,
    'descricao': descricao,
    'imagem': imagem,
    'sintonia': sintonia,
    'magico': magico,
  };

  ItemCompendio copyWith({
    String? key,
    String? nome,
    String? categoria,
    Raridade? raridade,
    String? descricao,
    String? imagem,
    bool? sintonia,
    bool? magico,
  }) => ItemCompendio(
    key: key ?? this.key,
    nome: nome ?? this.nome,
    categoria: categoria ?? this.categoria,
    raridade: raridade ?? this.raridade,
    descricao: descricao ?? this.descricao,
    imagem: imagem ?? this.imagem,
    sintonia: sintonia ?? this.sintonia,
    magico: magico ?? this.magico,
  );
}

class CondicaoInfo {
  const CondicaoInfo({
    required this.nome,
    required this.descricao,
    this.niveis = const [],
  });

  final String nome;
  final String descricao;

  // Só para Exausto.
  final List<String> niveis;

  factory CondicaoInfo.fromJson(Map<String, dynamic> json) => CondicaoInfo(
    nome: json['nome'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
    niveis: [
      for (final e in (json['niveis'] as List? ?? const [])) e as String,
    ],
  );

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descricao': descricao,
    'niveis': [...niveis],
  };

  CondicaoInfo copyWith({
    String? nome,
    String? descricao,
    List<String>? niveis,
  }) => CondicaoInfo(
    nome: nome ?? this.nome,
    descricao: descricao ?? this.descricao,
    niveis: niveis ?? this.niveis,
  );
}
