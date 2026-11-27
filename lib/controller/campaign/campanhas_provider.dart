import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/campaign/gerenciador_mesa.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/usuario_mock.dart';

class CampanhasProvider extends ChangeNotifier {
  CampanhasProvider({List<Campanha>? campanhas})
    : _campanhas = [...campanhas ?? campanhasMock];

  List<Campanha> _campanhas;

  // mestre atual das campanhas do mock
  String _mestreMock = usuarioMock.id;

  static const _gerenciador = GerenciadorCampanhas();

  List<Campanha> get campanhas => List.unmodifiable(_campanhas);

  Campanha? porId(String id) => _campanhas.where((c) => c.id == id).firstOrNull;

  Campanha? buscarPorCodigo(String codigo) =>
      _gerenciador.buscarPorCodigo(_campanhas, codigo);

  Campanha criar({
    required String nome,
    required String capitulo,
    required String mestreId,
  }) {
    final nova = _gerenciador.criar(
      nome: nome,
      capitulo: capitulo,
      mestreId: mestreId,
      agora: DateTime.now(),
    );
    adicionar(nova);
    return nova;
  }

  void adicionar(Campanha c) {
    _campanhas = [..._campanhas, c];
    notifyListeners();
  }

  void atualizar(Campanha c) {
    _campanhas = _gerenciador.trocar(_campanhas, c);
    notifyListeners();
  }

  // ponte ate as campanhas irem para o banco: o mestre do mock vira o logado
  void adotarMock(String usuarioId) {
    if (usuarioId == _mestreMock) return;
    final antigo = _mestreMock;
    _mestreMock = usuarioId;
    if (!_campanhas.any((c) => c.mestreId == antigo)) return;
    _campanhas = [
      for (final c in _campanhas)
        c.mestreId == antigo ? c.copyWith(mestreId: usuarioId) : c,
    ];
    notifyListeners();
  }

  // roda a acao na mesa e grava campanha e herois
  void naMesa(
    String campanhaId,
    PersonagensProvider personagens,
    void Function(GerenciadorMesa mesa) acao,
  ) {
    final c = porId(campanhaId);
    if (c == null) {
      AppLog.aviso(TagLog.provider, 'naMesa: campanha nao existe $campanhaId');
      return;
    }
    final mesa = GerenciadorMesa(
      campanha: c,
      herois: personagens.daCampanha(c),
    );
    acao(mesa);
    atualizar(mesa.campanha);
    personagens.atualizarVarios(mesa.herois);
  }
}
