import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/controller/characters/gerenciador_exp.dart';
import 'package:grimorio/controller/characters/gerenciador_inventario.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/personagem.dart';

// estado da mesa do mestre
class GerenciadorMesa {
  GerenciadorMesa({required this.campanha, List<Personagem> herois = const []})
    : herois = [...herois];

  Campanha campanha;
  List<Personagem> herois;

  static const _exp = GerenciadorExp();
  static const _inventario = GerenciadorInventario();

  static RegistroMesa novoRegistro(
    String campanhaId,
    TipoRegistro tipo,
    String texto, {
    String? personagemId,
    int? valor,
    String? itemKey,
  }) => RegistroMesa(
    id: novoId('registro'),
    campanhaId: campanhaId,
    tipo: tipo,
    texto: texto,
    personagemId: personagemId,
    valor: valor,
    itemKey: itemKey,
    criadoEm: DateTime.now(),
  );

  RegistroMesa _registro(
    TipoRegistro tipo,
    String texto, {
    String? personagemId,
    int? valor,
    String? itemKey,
  }) => novoRegistro(
    campanha.id,
    tipo,
    texto,
    personagemId: personagemId,
    valor: valor,
    itemKey: itemKey,
  );

  // mais novo primeiro
  void _registrar(List<RegistroMesa> novos) => campanha = campanha.copyWith(
    registros: [...novos.reversed, ...campanha.registros],
  );

  void _trocarHeroi(String id, Personagem Function(Personagem h) f) {
    herois = [for (final h in herois) h.id == id ? f(h) : h];
  }

  String _nome(String id) => herois.firstWhere((h) => h.id == id).nome;

  // sessao

  int iniciarSessao() {
    final numero = campanha.sessaoAtual + 1;
    campanha = campanha.copyWith(emSessao: true, sessaoAtual: numero);
    _registrar([_registro(TipoRegistro.sessao, 'Sessão $numero iniciada')]);
    return numero;
  }

  // xp dado desde o registro de sessao iniciada
  int get xpDaSessao {
    var total = 0;
    for (final r in campanha.registros) {
      if (r.tipo == TipoRegistro.sessao) break;
      if (r.tipo == TipoRegistro.xp) total += r.valor ?? 0;
    }
    return total;
  }

  void encerrarSessao(String resumo) {
    final numero = campanha.sessaoAtual;
    final sessao = Sessao(
      id: novoId('sessao'),
      campanhaId: campanha.id,
      numero: numero,
      data: DateTime.now(),
      resumo: resumo,
      xpTotal: xpDaSessao,
    );
    campanha = campanha.copyWith(
      emSessao: false,
      sessoes: [...campanha.sessoes, sessao],
    );
    _registrar([_registro(TipoRegistro.sessao, 'Sessão $numero encerrada')]);
  }

  // xp e itens

  void darXp(int valor, Set<String> heroiIds) {
    final novos = <RegistroMesa>[];
    for (final id in heroiIds) {
      _trocarHeroi(id, (h) => _exp.adicionar(h, valor));
      novos.add(
        _registro(
          TipoRegistro.xp,
          '+${formatarMilhar(valor)} XP para ${_nome(id)}',
          personagemId: id,
          valor: valor,
        ),
      );
    }
    _registrar(novos);
  }

  void darItem(ItemCompendio item, String heroiId) {
    _trocarHeroi(
      heroiId,
      (h) => _inventario.receber(h, _inventario.doCompendio(item)),
    );
    _registrar([
      _registro(
        TipoRegistro.item,
        '${item.nome} para ${_nome(heroiId)}',
        personagemId: heroiId,
        itemKey: item.key,
      ),
    ]);
  }

  // so xp e item tem volta
  void desfazer(RegistroMesa r) {
    final id = r.personagemId;
    if (id == null) return;
    switch (r.tipo) {
      case TipoRegistro.xp:
        _trocarHeroi(id, (h) => _exp.adicionar(h, -(r.valor ?? 0)));
      case TipoRegistro.item:
        _trocarHeroi(
          id,
          (h) => _inventario.removerUmaUnidade(h, r.itemKey ?? ''),
        );
      default:
        return;
    }
    campanha = campanha.copyWith(
      registros: [
        for (final x in campanha.registros)
          if (x.id != r.id) x,
      ],
    );
  }

  // missoes e mundo

  void aplicarMissao(RetornoMissao r) {
    campanha = campanha.copyWith(
      missoes: [
        for (final m in campanha.missoes) m.id == r.missao.id ? r.missao : m,
      ],
    );
    _registrar(r.registros);
    herois = r.herois;
  }

  void adicionarMissao(Missao m) =>
      campanha = campanha.copyWith(missoes: [...campanha.missoes, m]);

  void adicionarNpc(Npc npc) =>
      campanha = campanha.copyWith(npcs: [...campanha.npcs, npc]);

  void revelarNpc(Npc npc, bool revelado) => campanha = campanha.copyWith(
    npcs: [
      for (final n in campanha.npcs)
        n.id == npc.id ? n.copyWith(revelado: revelado) : n,
    ],
  );

  void editarNotas(String texto) =>
      campanha = campanha.copyWith(notasMestre: texto);
}
