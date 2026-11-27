import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/characters/gerenciador_inventario.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';
import 'package:grimorio/service/supabase/campanha_service.dart';
import 'package:grimorio/service/supabase/mesa_service.dart';
import 'package:grimorio/service/supabase/missao_service.dart';
import 'package:grimorio/service/supabase/npc_service.dart';
import 'package:grimorio/service/supabase/perfil_service.dart';
import 'package:grimorio/service/supabase/realtime_service.dart';

// campanhas do usuario; acao no heroi de outro sempre pela rpc
class CampanhasProvider extends ChangeNotifier {
  CampanhasProvider({
    required this._campanhas,
    required this._mesa,
    required this._missoes,
    required this._npcs,
    required this._personagens,
    this._perfis,
    this._realtime,
    this.espera = PersonagensProvider.esperaToque,
  });

  final CampanhaService _campanhas;
  final MesaService _mesa;
  final MissaoService _missoes;
  final NpcService _npcs;
  final PersonagensProvider _personagens;
  final PerfilService? _perfis;
  final RealtimeService? _realtime;

  // notas do mestre esperam a digitacao parar
  final Duration espera;

  static const _gerenciador = GerenciadorCampanhas();
  static const _inventario = GerenciadorInventario();

  List<Campanha> _lista = const [];
  String? _usuarioId;
  Carregamento _carregamento = Carregamento.inicial;
  String? _mensagemErro;
  Map<String, String> _nomes = const {};
  final _recargas = <String, Timer>{};
  final _notas = <String, Timer>{};

  List<Campanha> get campanhas => List.unmodifiable(_lista);
  Carregamento get carregamento => _carregamento;
  String? get mensagemErro => _mensagemErro;

  Campanha? porId(String id) => _lista.where((c) => c.id == id).firstOrNull;

  // nome de outro usuario, vindo de perfis
  String? nomeDe(String usuarioId) => _nomes[usuarioId];

  bool _souMestre(String campanhaId) =>
      porId(campanhaId)?.mestreId == _usuarioId;

  // carga

  Future<void> carregar(String usuarioId) async {
    _usuarioId = usuarioId;
    _carregamento = Carregamento.carregando;
    _mensagemErro = null;
    notifyListeners();
    try {
      final lista = await _campanhas.minhas();
      if (_usuarioId != usuarioId) return;
      _lista = lista;
      _carregamento = Carregamento.pronto;
      await _buscarNomes();
    } catch (e, stack) {
      if (_usuarioId != usuarioId) return;
      _mensagemErro = mensagemDeErro(
        e,
        stack: stack,
        tag: TagLog.provider,
        onde: 'carregar campanhas',
      );
      _carregamento = Carregamento.erro;
    }
    notifyListeners();
  }

  Future<void> tentarDeNovo() async {
    final id = _usuarioId;
    if (id != null) await carregar(id);
  }

  // nomes dos mestres; se falhar a tela usa "Mestre"
  Future<void> _buscarNomes() async {
    final perfis = _perfis;
    if (perfis == null) return;
    try {
      _nomes = await perfis.nomes(_lista.map((c) => c.mestreId));
    } catch (e, stack) {
      AppLog.erro(TagLog.provider, 'nomes dos mestres', erro: e, stack: stack);
    }
  }

  // busca a campanha e os herois dela de novo
  Future<void> recarregar(String id) async {
    try {
      var c = await _campanhas.buscar(id, mestre: _souMestre(id));
      // campanha nova na lista: so agora sabe se e o mestre
      if (c.mestreId == _usuarioId && !_souMestre(id)) {
        c = await _campanhas.buscar(id, mestre: true);
      }
      final nova = porId(id) == null;
      _lista = nova ? [..._lista, c] : _gerenciador.trocar(_lista, c);
      if (nova) await _buscarNomes();
      notifyListeners();
    } on BancoErro catch (e) {
      // saiu ou foi removido: some da lista
      if (e.tipo == TipoErroBanco.naoEncontrado) {
        _lista = [
          for (final c in _lista)
            if (c.id != id) c,
        ];
        notifyListeners();
      }
      rethrow;
    } finally {
      await _personagens.recarregarCampanha(id);
    }
  }

  // tela de campanha aberta ouve o banco; devolve como parar
  CancelarEscuta ouvir(String campanhaId) =>
      _realtime?.ouvirCampanha(campanhaId, () => _agendarRecarga(campanhaId)) ??
      () async {};

  // varios eventos de uma rpc viram uma recarga so
  void _agendarRecarga(String id) {
    _recargas[id]?.cancel();
    _recargas[id] = Timer(const Duration(milliseconds: 300), () async {
      _recargas.remove(id);
      try {
        await recarregar(id);
      } catch (e, stack) {
        AppLog.erro(
          TagLog.provider,
          'recarga da campanha',
          erro: e,
          stack: stack,
        );
      }
    });
  }

  // apaga a conta no banco (o resto vai por cascade) e limpa a tela
  Future<void> apagarMinhaConta() async {
    await _mesa.apagarMinhaConta();
    limpar();
  }

  void limpar() {
    _cancelarTimers();
    _lista = const [];
    _usuarioId = null;
    _nomes = const {};
    _carregamento = Carregamento.inicial;
    _mensagemErro = null;
    notifyListeners();
  }

  // campanha

  Future<Campanha> criar({
    required String nome,
    required String capitulo,
  }) async {
    final nova = await _campanhas.criar(nome: nome, capitulo: capitulo);
    _lista = [..._lista, nova];
    notifyListeners();
    return nova;
  }

  // devolve a campanha em que entrou
  Future<Campanha> entrarComCodigo(String codigo, String personagemId) async {
    final id = await _mesa.entrarCampanha(codigo, personagemId);
    await recarregar(id);
    return porId(id)!;
  }

  Future<void> sairDaCampanha(String campanhaId, String personagemId) =>
      _naMesa(campanhaId, () => _mesa.sairCampanha(personagemId));

  Future<void> removerHeroi(String campanhaId, String personagemId) =>
      _naMesa(campanhaId, () => _mesa.removerHeroi(personagemId));

  Future<String> novoCodigo(String campanhaId) async {
    final codigo = await _mesa.novoCodigo(campanhaId);
    final c = porId(campanhaId);
    if (c != null) {
      _lista = _gerenciador.trocar(_lista, c.copyWith(codigoConvite: codigo));
      notifyListeners();
    }
    return codigo;
  }

  // notas do mestre: tela na hora, banco quando a digitacao para
  void editarNotas(String campanhaId, String texto) {
    final c = porId(campanhaId);
    if (c == null) return;
    _lista = _gerenciador.trocar(_lista, c.copyWith(notasMestre: texto));
    notifyListeners();
    _notas[campanhaId]?.cancel();
    _notas[campanhaId] = Timer(espera, () async {
      _notas.remove(campanhaId);
      try {
        await _campanhas.editarNotas(campanhaId, texto);
      } catch (e, stack) {
        AppLog.erro(TagLog.provider, 'notas do mestre', erro: e, stack: stack);
      }
    });
  }

  // mesa: rpc e depois a campanha de novo

  Future<int> iniciarSessao(String campanhaId) async {
    var numero = 0;
    await _naMesa(
      campanhaId,
      () async => numero = await _mesa.iniciarSessao(campanhaId),
    );
    return numero;
  }

  Future<void> encerrarSessao(String campanhaId, String resumo) =>
      _naMesa(campanhaId, () => _mesa.encerrarSessao(campanhaId, resumo));

  Future<void> darXp(String campanhaId, Set<String> heroiIds, int valor) =>
      _naMesa(campanhaId, () => _mesa.darXp(campanhaId, heroiIds, valor));

  Future<void> darItem(String campanhaId, String heroiId, ItemCompendio item) =>
      _naMesa(
        campanhaId,
        () => _mesa.darItem(
          campanhaId,
          heroiId,
          _inventario.doCompendio(item),
          itemKey: item.key,
          nome: item.nome,
        ),
      );

  Future<void> desfazer(String campanhaId, RegistroMesa r) =>
      _naMesa(campanhaId, () => _mesa.desfazer(r.id));

  // destinos: item_key -> heroi
  Future<void> concluirMissao(
    String campanhaId,
    String missaoId, {
    required Map<String, String> destinos,
    required List<ItemCompendio> itens,
  }) => _naMesa(
    campanhaId,
    () => _mesa.concluirMissao(
      missaoId,
      destinos: destinos,
      itens: {
        for (final i in itens)
          if (destinos.containsKey(i.key)) i.key: _inventario.doCompendio(i),
      },
    ),
  );

  Future<void> falharMissao(String campanhaId, String missaoId) =>
      _naMesa(campanhaId, () => _mesa.falharMissao(missaoId));

  Future<void> _naMesa(String campanhaId, Future<void> Function() rpc) async {
    await rpc();
    await recarregar(campanhaId);
  }

  // missoes, entradas e npcs: tela na hora, volta se o banco recusar

  Future<void> criarMissao(Missao m) async {
    final criada = await _missoes.criar(m);
    _trocar(m.campanhaId, (c) => _gerenciador.trocarMissao(c, criada));
  }

  Future<void> editarMissao(Missao antes, Missao depois) => _otimista(
    antes.campanhaId,
    (c) => _gerenciador.trocarMissao(c, depois),
    () =>
        _missoes.atualizar(antes.id, _gerenciador.camposMissao(antes, depois)),
  );

  Future<void> apagarMissao(Missao m) => _otimista(
    m.campanhaId,
    (c) => _gerenciador.tirarMissao(c, m.id),
    () => _missoes.apagar(m.id),
  );

  Future<void> criarEntrada(Missao m, EntradaMissao e) async {
    final criada = await _missoes.criarEntrada(m.id, e);
    _trocar(m.campanhaId, (c) => _gerenciador.trocarEntrada(c, m.id, criada));
  }

  Future<void> editarEntrada(
    Missao m,
    EntradaMissao antes,
    EntradaMissao depois,
  ) => _otimista(
    m.campanhaId,
    (c) => _gerenciador.trocarEntrada(c, m.id, depois),
    () => _missoes.atualizarEntrada(
      antes.id,
      _gerenciador.camposEntrada(antes, depois),
    ),
  );

  Future<void> apagarEntrada(Missao m, EntradaMissao e) => _otimista(
    m.campanhaId,
    (c) => _gerenciador.tirarEntrada(c, m.id, e.id),
    () => _missoes.apagarEntrada(e.id),
  );

  Future<void> criarNpc(Npc npc) async {
    final criado = await _npcs.criar(npc);
    _trocar(npc.campanhaId, (c) => _gerenciador.trocarNpc(c, criado));
  }

  Future<void> editarNpc(Npc antes, Npc depois) => _otimista(
    antes.campanhaId,
    (c) => _gerenciador.trocarNpc(c, depois),
    () => _npcs.atualizar(antes.id, _gerenciador.camposNpc(antes, depois)),
  );

  void _trocar(String campanhaId, Campanha Function(Campanha c) f) {
    final c = porId(campanhaId);
    if (c == null) return;
    _lista = _gerenciador.trocar(_lista, f(c));
    notifyListeners();
  }

  Future<void> _otimista(
    String campanhaId,
    Campanha Function(Campanha c) f,
    Future<void> Function() salvar,
  ) async {
    final antes = porId(campanhaId);
    _trocar(campanhaId, f);
    try {
      await salvar();
    } catch (_) {
      if (antes != null) {
        _lista = _gerenciador.trocar(_lista, antes);
        notifyListeners();
      }
      rethrow;
    }
  }

  void _cancelarTimers() {
    for (final t in [..._recargas.values, ..._notas.values]) {
      t.cancel();
    }
    _recargas.clear();
    _notas.clear();
  }

  @override
  void dispose() {
    _cancelarTimers();
    super.dispose();
  }
}
