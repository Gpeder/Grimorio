import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/missao.dart';

export 'package:grimorio/model/missao.dart';

enum PapelCampanha {
  mestre('Mestre'),
  heroi('Herói');

  const PapelCampanha(this.label);
  final String label;
}

class Campaign {
  const Campaign({
    required this.id,
    required this.nome,
    this.capitulo = '',
    this.progresso = 0,
    this.capa,
    this.mestreId = '',
    this.codigoConvite = '',
    this.sessaoAtual = 0,
    this.emSessao = false,
    this.missoes = const [],
    this.npcs = const [],
    this.sessoes = const [],
    this.registros = const [],
    this.notasMestre = '',
  });

  final String id;
  final String nome;
  final String capitulo;

  // 0..1
  final double progresso;
  final String? capa;
  final String mestreId;
  final String codigoConvite;
  final int sessaoAtual;
  final bool emSessao;
  final List<Missao> missoes;
  final List<Npc> npcs;
  final List<Sessao> sessoes;

  // Mais novo primeiro.
  final List<RegistroMesa> registros;
  final String notasMestre;

  PapelCampanha papelDe(String usuarioId) =>
      usuarioId == mestreId ? PapelCampanha.mestre : PapelCampanha.heroi;

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['id'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    capitulo: json['capitulo'] as String? ?? '',
    progresso: (json['progresso'] as num?)?.toDouble() ?? 0,
    capa: json['capa'] as String?,
    mestreId: json['mestre_id'] as String? ?? '',
    codigoConvite: json['codigo_convite'] as String? ?? '',
    sessaoAtual: (json['sessao_atual'] as num?)?.toInt() ?? 0,
    emSessao: json['em_sessao'] as bool? ?? false,
    missoes: [
      for (final e in (json['missoes'] as List? ?? const []))
        Missao.fromJson(e as Map<String, dynamic>),
    ],
    npcs: [
      for (final e in (json['npcs'] as List? ?? const []))
        Npc.fromJson(e as Map<String, dynamic>),
    ],
    sessoes: [
      for (final e in (json['sessoes'] as List? ?? const []))
        Sessao.fromJson(e as Map<String, dynamic>),
    ],
    registros: [
      for (final e in (json['registros'] as List? ?? const []))
        RegistroMesa.fromJson(e as Map<String, dynamic>),
    ],
    notasMestre: json['notas_mestre'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'capitulo': capitulo,
    'progresso': progresso,
    'capa': capa,
    'mestre_id': mestreId,
    'codigo_convite': codigoConvite,
    'sessao_atual': sessaoAtual,
    'em_sessao': emSessao,
    'missoes': [for (final e in missoes) e.toJson()],
    'npcs': [for (final e in npcs) e.toJson()],
    'sessoes': [for (final e in sessoes) e.toJson()],
    'registros': [for (final e in registros) e.toJson()],
    'notas_mestre': notasMestre,
  };

  Campaign copyWith({
    String? id,
    String? nome,
    String? capitulo,
    double? progresso,
    String? capa,
    String? mestreId,
    String? codigoConvite,
    int? sessaoAtual,
    bool? emSessao,
    List<Missao>? missoes,
    List<Npc>? npcs,
    List<Sessao>? sessoes,
    List<RegistroMesa>? registros,
    String? notasMestre,
  }) => Campaign(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    capitulo: capitulo ?? this.capitulo,
    progresso: progresso ?? this.progresso,
    capa: capa ?? this.capa,
    mestreId: mestreId ?? this.mestreId,
    codigoConvite: codigoConvite ?? this.codigoConvite,
    sessaoAtual: sessaoAtual ?? this.sessaoAtual,
    emSessao: emSessao ?? this.emSessao,
    missoes: missoes ?? this.missoes,
    npcs: npcs ?? this.npcs,
    sessoes: sessoes ?? this.sessoes,
    registros: registros ?? this.registros,
    notasMestre: notasMestre ?? this.notasMestre,
  );
}

// O que as telas de campanha devolvem no pop.
typedef RetornoCampanha = ({Campaign campanha, List<Character> herois});

typedef RetornoMissao = ({
  Missao missao,
  List<Character> herois,
  List<RegistroMesa> registros,
});
