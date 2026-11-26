import 'dart:ui';

import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/models/character.dart';

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
}
