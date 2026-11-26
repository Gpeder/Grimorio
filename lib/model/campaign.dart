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

  Campaign copyWith({
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
    id: id,
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
