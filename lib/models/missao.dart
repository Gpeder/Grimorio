import 'package:flutter/painting.dart';
import 'package:grimorio/app/theme/app_colors.dart';

enum TipoMissao {
  principal('Principal'),
  secundaria('Secundária');

  const TipoMissao(this.label);
  final String label;
}

enum EstadoMissao {
  ativa('Ativa'),
  concluida('Concluída'),
  falhou('Falhou');

  const EstadoMissao(this.label);
  final String label;

  Color get cor => switch (this) {
    EstadoMissao.ativa => AppColors.alerta,
    EstadoMissao.concluida => AppColors.sucesso,
    EstadoMissao.falhou => AppColors.vida,
  };
}

class EntradaMissao {
  const EntradaMissao({
    required this.id,
    required this.texto,
    required this.sessao,
    required this.criadaEm,
    this.objetivo = false,
    this.concluida = false,
    this.revelada = true,
  });

  final String id;
  final String texto;
  final int sessao;
  final bool objetivo;
  final bool concluida;
  final bool revelada;
  final DateTime criadaEm;

  EntradaMissao copyWith({
    String? texto,
    bool? objetivo,
    bool? concluida,
    bool? revelada,
  }) => EntradaMissao(
    id: id,
    texto: texto ?? this.texto,
    sessao: sessao,
    criadaEm: criadaEm,
    objetivo: objetivo ?? this.objetivo,
    concluida: concluida ?? this.concluida,
    revelada: revelada ?? this.revelada,
  );
}

class Missao {
  const Missao({
    required this.id,
    required this.campanhaId,
    required this.titulo,
    required this.atualizadaEm,
    this.tipo = TipoMissao.secundaria,
    this.regiao = '',
    this.descricao = '',
    this.estado = EstadoMissao.ativa,
    this.revelada = false,
    this.entradas = const [],
    this.recompensaXp = 0,
    this.recompensaItens = const [],
    this.npcIds = const [],
  });

  final String id;
  final String campanhaId;
  final String titulo;
  final TipoMissao tipo;
  final String regiao;
  final String descricao;
  final EstadoMissao estado;
  final bool revelada;
  final List<EntradaMissao> entradas;
  final int recompensaXp;

  // Keys de `itensMock`.
  final List<String> recompensaItens;
  final List<String> npcIds;
  final DateTime atualizadaEm;

  bool get ativa => estado == EstadoMissao.ativa;

  Missao copyWith({
    String? titulo,
    TipoMissao? tipo,
    String? regiao,
    String? descricao,
    EstadoMissao? estado,
    bool? revelada,
    List<EntradaMissao>? entradas,
    int? recompensaXp,
    List<String>? recompensaItens,
    List<String>? npcIds,
    DateTime? atualizadaEm,
  }) => Missao(
    id: id,
    campanhaId: campanhaId,
    titulo: titulo ?? this.titulo,
    tipo: tipo ?? this.tipo,
    regiao: regiao ?? this.regiao,
    descricao: descricao ?? this.descricao,
    estado: estado ?? this.estado,
    revelada: revelada ?? this.revelada,
    entradas: entradas ?? this.entradas,
    recompensaXp: recompensaXp ?? this.recompensaXp,
    recompensaItens: recompensaItens ?? this.recompensaItens,
    npcIds: npcIds ?? this.npcIds,
    atualizadaEm: atualizadaEm ?? this.atualizadaEm,
  );
}

class Npc {
  const Npc({
    required this.id,
    required this.campanhaId,
    required this.nome,
    this.funcao = '',
    this.imagem,
    this.revelado = false,
  });

  final String id;
  final String campanhaId;
  final String nome;
  final String funcao;
  final String? imagem;
  final bool revelado;

  Npc copyWith({bool? revelado}) => Npc(
    id: id,
    campanhaId: campanhaId,
    nome: nome,
    funcao: funcao,
    imagem: imagem,
    revelado: revelado ?? this.revelado,
  );
}

class Sessao {
  const Sessao({
    required this.id,
    required this.campanhaId,
    required this.numero,
    required this.data,
    this.resumo = '',
    this.xpTotal = 0,
  });

  final String id;
  final String campanhaId;
  final int numero;
  final DateTime data;
  final String resumo;
  final int xpTotal;
}

enum TipoRegistro { xp, item, missao, entrada, sessao }

class RegistroMesa {
  const RegistroMesa({
    required this.id,
    required this.campanhaId,
    required this.tipo,
    required this.texto,
    required this.criadoEm,
    this.personagemId,
    this.valor,
    this.itemKey,
  });

  final String id;
  final String campanhaId;
  final TipoRegistro tipo;
  final String texto;
  final String? personagemId;
  final int? valor;
  final String? itemKey;
  final DateTime criadoEm;

  bool get podeDesfazer =>
      personagemId != null &&
      (tipo == TipoRegistro.xp && valor != null ||
          tipo == TipoRegistro.item && itemKey != null);
}
