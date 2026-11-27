import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/json.dart' as json;
import 'package:grimorio/model/personagem.dart';

class GerenciadorCampanhas {
  const GerenciadorCampanhas();

  // colunas que o mestre edita direto; o resto vai pelas rpcs
  static const colunasCampanha = {'nome', 'capitulo', 'capa', 'progresso'};
  static const colunasMissao = {
    'titulo',
    'tipo',
    'regiao',
    'descricao',
    'revelada',
    'recompensa_xp',
    'recompensa_itens',
    'npc_ids',
  };
  static const colunasEntrada = {
    'texto',
    'sessao',
    'objetivo',
    'concluida',
    'revelada',
  };
  static const colunasNpc = {'nome', 'funcao', 'imagem', 'revelado'};

  List<Personagem> heroisDe(Campanha c, List<Personagem> personagens) => [
    for (final p in personagens)
      if (p.campanhaId == c.id) p,
  ];

  Personagem? heroiDoUsuario(List<Personagem> herois, String usuarioId) =>
      herois.where((h) => h.donoId == usuarioId).firstOrNull;

  // herois do usuario que podem entrar numa campanha
  List<Personagem> semCampanha(List<Personagem> meus) => [
    for (final p in meus)
      if (p.campanhaId == null) p,
  ];

  List<Campanha> trocar(List<Campanha> campanhas, Campanha nova) => [
    for (final c in campanhas) c.id == nova.id ? nova : c,
  ];

  // so o que mudou, no formato do banco

  Map<String, dynamic> camposCampanha(Campanha a, Campanha b) =>
      json.camposMudados(a.toJson(), b.toJson(), colunasCampanha);

  Map<String, dynamic> camposMissao(Missao a, Missao b) =>
      json.camposMudados(a.toJson(), b.toJson(), colunasMissao);

  Map<String, dynamic> camposEntrada(EntradaMissao a, EntradaMissao b) =>
      json.camposMudados(a.toJson(), b.toJson(), colunasEntrada);

  Map<String, dynamic> camposNpc(Npc a, Npc b) =>
      json.camposMudados(a.toJson(), b.toJson(), colunasNpc);

  // trocas locais, antes da resposta do banco

  Campanha trocarMissao(Campanha c, Missao m) => c.copyWith(
    missoes: [
      for (final x in c.missoes) x.id == m.id ? m : x,
      if (!c.missoes.any((x) => x.id == m.id)) m,
    ],
  );

  Campanha tirarMissao(Campanha c, String missaoId) => c.copyWith(
    missoes: [
      for (final x in c.missoes)
        if (x.id != missaoId) x,
    ],
  );

  Campanha trocarNpc(Campanha c, Npc n) => c.copyWith(
    npcs: [
      for (final x in c.npcs) x.id == n.id ? n : x,
      if (!c.npcs.any((x) => x.id == n.id)) n,
    ],
  );

  Missao? missao(Campanha c, String missaoId) =>
      c.missoes.where((m) => m.id == missaoId).firstOrNull;

  Campanha trocarEntrada(Campanha c, String missaoId, EntradaMissao e) {
    final m = missao(c, missaoId);
    if (m == null) return c;
    return trocarMissao(
      c,
      m.copyWith(
        entradas: [
          for (final x in m.entradas) x.id == e.id ? e : x,
          if (!m.entradas.any((x) => x.id == e.id)) e,
        ],
      ),
    );
  }

  Campanha tirarEntrada(Campanha c, String missaoId, String entradaId) {
    final m = missao(c, missaoId);
    if (m == null) return c;
    return trocarMissao(
      c,
      m.copyWith(
        entradas: [
          for (final x in m.entradas)
            if (x.id != entradaId) x,
        ],
      ),
    );
  }
}
