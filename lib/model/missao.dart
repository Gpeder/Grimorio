import 'package:flutter/painting.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/model/json.dart';

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

  factory EntradaMissao.fromJson(Map<String, dynamic> json) => EntradaMissao(
    id: json['id'] as String? ?? '',
    texto: json['texto'] as String? ?? '',
    sessao: (json['sessao'] as num?)?.toInt() ?? 0,
    criadaEm: lerData(json['criada_em']),
    objetivo: json['objetivo'] as bool? ?? false,
    concluida: json['concluida'] as bool? ?? false,
    revelada: json['revelada'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'texto': texto,
    'sessao': sessao,
    'criada_em': criadaEm.toIso8601String(),
    'objetivo': objetivo,
    'concluida': concluida,
    'revelada': revelada,
  };

  EntradaMissao copyWith({
    String? id,
    String? texto,
    int? sessao,
    DateTime? criadaEm,
    bool? objetivo,
    bool? concluida,
    bool? revelada,
  }) => EntradaMissao(
    id: id ?? this.id,
    texto: texto ?? this.texto,
    sessao: sessao ?? this.sessao,
    criadaEm: criadaEm ?? this.criadaEm,
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

  // keys do itensMock
  final List<String> recompensaItens;
  final List<String> npcIds;
  final DateTime atualizadaEm;

  bool get ativa => estado == EstadoMissao.ativa;

  factory Missao.fromJson(Map<String, dynamic> json) => Missao(
    id: json['id'] as String? ?? '',
    campanhaId: json['campanha_id'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    atualizadaEm: lerData(json['atualizada_em']),
    tipo: lerEnum(TipoMissao.values, json['tipo'], TipoMissao.secundaria),
    regiao: json['regiao'] as String? ?? '',
    descricao: json['descricao'] as String? ?? '',
    estado: lerEnum(EstadoMissao.values, json['estado'], EstadoMissao.ativa),
    revelada: json['revelada'] as bool? ?? false,
    entradas: [
      for (final e in (json['entradas'] as List? ?? const []))
        EntradaMissao.fromJson(e as Map<String, dynamic>),
    ],
    recompensaXp: (json['recompensa_xp'] as num?)?.toInt() ?? 0,
    recompensaItens: [
      for (final e in (json['recompensa_itens'] as List? ?? const []))
        e as String,
    ],
    npcIds: [
      for (final e in (json['npc_ids'] as List? ?? const [])) e as String,
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'campanha_id': campanhaId,
    'titulo': titulo,
    'atualizada_em': atualizadaEm.toIso8601String(),
    'tipo': tipo.name,
    'regiao': regiao,
    'descricao': descricao,
    'estado': estado.name,
    'revelada': revelada,
    'entradas': [for (final e in entradas) e.toJson()],
    'recompensa_xp': recompensaXp,
    'recompensa_itens': [...recompensaItens],
    'npc_ids': [...npcIds],
  };

  Missao copyWith({
    String? id,
    String? campanhaId,
    String? titulo,
    DateTime? atualizadaEm,
    TipoMissao? tipo,
    String? regiao,
    String? descricao,
    EstadoMissao? estado,
    bool? revelada,
    List<EntradaMissao>? entradas,
    int? recompensaXp,
    List<String>? recompensaItens,
    List<String>? npcIds,
  }) => Missao(
    id: id ?? this.id,
    campanhaId: campanhaId ?? this.campanhaId,
    titulo: titulo ?? this.titulo,
    atualizadaEm: atualizadaEm ?? this.atualizadaEm,
    tipo: tipo ?? this.tipo,
    regiao: regiao ?? this.regiao,
    descricao: descricao ?? this.descricao,
    estado: estado ?? this.estado,
    revelada: revelada ?? this.revelada,
    entradas: entradas ?? this.entradas,
    recompensaXp: recompensaXp ?? this.recompensaXp,
    recompensaItens: recompensaItens ?? this.recompensaItens,
    npcIds: npcIds ?? this.npcIds,
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

  factory Npc.fromJson(Map<String, dynamic> json) => Npc(
    id: json['id'] as String? ?? '',
    campanhaId: json['campanha_id'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    funcao: json['funcao'] as String? ?? '',
    imagem: json['imagem'] as String?,
    revelado: json['revelado'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'campanha_id': campanhaId,
    'nome': nome,
    'funcao': funcao,
    'imagem': imagem,
    'revelado': revelado,
  };

  Npc copyWith({
    String? id,
    String? campanhaId,
    String? nome,
    String? funcao,
    String? imagem,
    bool? revelado,
  }) => Npc(
    id: id ?? this.id,
    campanhaId: campanhaId ?? this.campanhaId,
    nome: nome ?? this.nome,
    funcao: funcao ?? this.funcao,
    imagem: imagem ?? this.imagem,
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

  factory Sessao.fromJson(Map<String, dynamic> json) => Sessao(
    id: json['id'] as String? ?? '',
    campanhaId: json['campanha_id'] as String? ?? '',
    numero: (json['numero'] as num?)?.toInt() ?? 0,
    data: lerData(json['data']),
    resumo: json['resumo'] as String? ?? '',
    xpTotal: (json['xp_total'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'campanha_id': campanhaId,
    'numero': numero,
    'data': data.toIso8601String(),
    'resumo': resumo,
    'xp_total': xpTotal,
  };

  Sessao copyWith({
    String? id,
    String? campanhaId,
    int? numero,
    DateTime? data,
    String? resumo,
    int? xpTotal,
  }) => Sessao(
    id: id ?? this.id,
    campanhaId: campanhaId ?? this.campanhaId,
    numero: numero ?? this.numero,
    data: data ?? this.data,
    resumo: resumo ?? this.resumo,
    xpTotal: xpTotal ?? this.xpTotal,
  );
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

  factory RegistroMesa.fromJson(Map<String, dynamic> json) => RegistroMesa(
    id: json['id'] as String? ?? '',
    campanhaId: json['campanha_id'] as String? ?? '',
    tipo: lerEnum(TipoRegistro.values, json['tipo'], TipoRegistro.values.first),
    texto: json['texto'] as String? ?? '',
    criadoEm: lerData(json['criado_em']),
    personagemId: json['personagem_id'] as String?,
    valor: (json['valor'] as num?)?.toInt(),
    itemKey: json['item_key'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'campanha_id': campanhaId,
    'tipo': tipo.name,
    'texto': texto,
    'criado_em': criadoEm.toIso8601String(),
    'personagem_id': personagemId,
    'valor': valor,
    'item_key': itemKey,
  };

  RegistroMesa copyWith({
    String? id,
    String? campanhaId,
    TipoRegistro? tipo,
    String? texto,
    DateTime? criadoEm,
    String? personagemId,
    int? valor,
    String? itemKey,
  }) => RegistroMesa(
    id: id ?? this.id,
    campanhaId: campanhaId ?? this.campanhaId,
    tipo: tipo ?? this.tipo,
    texto: texto ?? this.texto,
    criadoEm: criadoEm ?? this.criadoEm,
    personagemId: personagemId ?? this.personagemId,
    valor: valor ?? this.valor,
    itemKey: itemKey ?? this.itemKey,
  );
}
