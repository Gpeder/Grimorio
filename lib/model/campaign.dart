import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/grimoire.dart';
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

  Campaign trocarMissao(Missao missao) => copyWith(
    missoes: [for (final m in missoes) m.id == missao.id ? missao : m],
  );

  Campaign registrar(List<RegistroMesa> novos) =>
      copyWith(registros: [...novos.reversed, ...registros]);
}

// O que as telas de campanha devolvem no pop.
typedef RetornoCampanha = ({Campaign campanha, List<Character> herois});

// Regras de "quem vê o quê". Ficam puras para virar RLS no Supabase.

bool _mestre(PapelCampanha p) => p == PapelCampanha.mestre;

List<Missao> missoesVisiveis(Campaign c, PapelCampanha p) => [
  for (final m in c.missoes)
    if (_mestre(p) || m.revelada) m,
];

List<EntradaMissao> entradasVisiveis(Missao m, PapelCampanha p) => [
  for (final e in m.entradas)
    if (_mestre(p) || e.revelada) e,
]..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));

EntradaMissao? objetivoAtual(Missao m, PapelCampanha p) =>
    entradasVisiveis(m, p).where((e) => e.objetivo && !e.concluida).firstOrNull;

bool recompensaVisivel(Missao m, PapelCampanha p) =>
    _mestre(p) || m.estado == EstadoMissao.concluida;

List<Npc> npcsVisiveis(Campaign c, PapelCampanha p) => [
  for (final n in c.npcs)
    if (_mestre(p) || n.revelado) n,
];

bool podeEditarCampanha(PapelCampanha p) => _mestre(p);

// Converte um item do compêndio para o inventário do herói.
InventoryItem itemDoCompendio(ItemCompendio i) => InventoryItem(
  id: i.key,
  nome: i.nome,
  imagem: i.imagem,
  consumivel: i.categoria == 'Poção',
  descricao: i.descricao,
);

// "ABCD-12": 4 letras do nome + 2 dígitos do relógio.
String gerarCodigoConvite(String nome, DateTime agora) {
  final letras = nome
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z]'), '')
      .padRight(4, 'X')
      .substring(0, 4);
  final digitos = (agora.millisecondsSinceEpoch % 100).toString().padLeft(
    2,
    '0',
  );
  return '$letras-$digitos';
}
