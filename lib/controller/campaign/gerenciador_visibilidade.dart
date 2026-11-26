import 'package:grimorio/model/campanha.dart';

// quem ve o que, pensado para virar rls no supabase
class GerenciadorVisibilidade {
  const GerenciadorVisibilidade();

  bool _mestre(PapelCampanha p) => p == PapelCampanha.mestre;

  List<Missao> missoes(Campanha c, PapelCampanha p) => [
    for (final m in c.missoes)
      if (_mestre(p) || m.revelada) m,
  ];

  // mais nova primeiro
  List<EntradaMissao> entradas(Missao m, PapelCampanha p) => [
    for (final e in m.entradas)
      if (_mestre(p) || e.revelada) e,
  ]..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));

  EntradaMissao? objetivoAtual(Missao m, PapelCampanha p) =>
      entradas(m, p).where((e) => e.objetivo && !e.concluida).firstOrNull;

  bool recompensaVisivel(Missao m, PapelCampanha p) =>
      _mestre(p) || m.estado == EstadoMissao.concluida;

  List<Npc> npcs(Campanha c, PapelCampanha p) => [
    for (final n in c.npcs)
      if (_mestre(p) || n.revelado) n,
  ];

  // npcs da missao que o papel pode ver
  List<Npc> envolvidos(Missao m, List<Npc> npcs, PapelCampanha p) => [
    for (final n in npcs)
      if (m.npcIds.contains(n.id) && (_mestre(p) || n.revelado)) n,
  ];

  bool podeEditarCampanha(PapelCampanha p) => _mestre(p);
}
