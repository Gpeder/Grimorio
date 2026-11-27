import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/controller/campaign/gerenciador_campanhas.dart';
import 'package:grimorio/controller/characters/gerenciador_notas.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/supabase/personagem_service.dart';
import 'package:grimorio/service/supabase/realtime_service.dart';

// herois que o usuario enxerga: os dele e os das campanhas dele
class PersonagensProvider extends ChangeNotifier {
  PersonagensProvider(
    this._service, {
    this._realtime,
    this.espera = esperaToque,
  });

  // toques rapidos (hp, espaco, condicao) esperam isso parados para salvar
  static const esperaToque = Duration(milliseconds: 600);

  final PersonagemService _service;
  final RealtimeService? _realtime;
  final Duration espera;

  static const _personagens = GerenciadorPersonagens();
  static const _campanhas = GerenciadorCampanhas();
  static const _notas = GerenciadorNotas();

  List<Personagem> _todos = const [];
  String? _usuarioId;
  Carregamento _carregamento = Carregamento.inicial;
  String? _mensagemErro;
  CancelarEscuta? _pararEscuta;
  Timer? _recarga;

  // edicao em espera: valor que o banco tem, timer e quem espera o fim
  final _noBanco = <String, Personagem>{};
  final _timers = <String, Timer>{};
  final _pendentes = <String, Completer<void>>{};

  List<Personagem> get todos => List.unmodifiable(_todos);
  Carregamento get carregamento => _carregamento;
  String? get mensagemErro => _mensagemErro;

  // aba herois
  List<Personagem> get meus => [
    for (final p in _todos)
      if (p.donoId == _usuarioId) p,
  ];

  // heroi da home
  Personagem? get ativo =>
      meus.where((p) => p.ativo).firstOrNull ?? meus.firstOrNull;

  Personagem? porId(String id) => _todos.where((p) => p.id == id).firstOrNull;

  List<Personagem> daCampanha(Campanha c) => _campanhas.heroisDe(c, _todos);

  // carga

  Future<void> carregar(String usuarioId) async {
    _usuarioId = usuarioId;
    _carregamento = Carregamento.carregando;
    _mensagemErro = null;
    notifyListeners();
    try {
      final lista = await _service.visiveis();
      final notas = await _service.notas();
      if (_usuarioId != usuarioId) return;
      _todos = [
        for (final p in lista) p.copyWith(notas: notas[p.id] ?? const []),
      ];
      _carregamento = Carregamento.pronto;
      _ouvirMeus(usuarioId);
    } catch (e, stack) {
      if (_usuarioId != usuarioId) return;
      _mensagemErro = mensagemDeErro(
        e,
        stack: stack,
        tag: TagLog.provider,
        onde: 'carregar herois',
      );
      _carregamento = Carregamento.erro;
    }
    notifyListeners();
  }

  Future<void> tentarDeNovo() async {
    final id = _usuarioId;
    if (id != null) await carregar(id);
  }

  // busca de novo sem perder o que ainda nao foi salvo
  Future<void> recarregar() async {
    if (_usuarioId == null) return;
    final lista = await _service.visiveis();
    _mesclar(lista, (_) => true);
  }

  // herois de uma campanha, depois de uma acao da mesa
  Future<void> recarregarCampanha(String campanhaId) async {
    final lista = await _service.daCampanha(campanhaId);
    _mesclar(lista, (p) => p.campanhaId == campanhaId);
  }

  // troca os que vieram; quem era do grupo e nao veio saiu dele
  void _mesclar(List<Personagem> vindos, bool Function(Personagem) doGrupo) {
    final porId = {for (final p in vindos) p.id: p};
    final novos = <Personagem>[];
    for (final p in _todos) {
      final vindo = porId.remove(p.id);
      if (_noBanco.containsKey(p.id)) {
        novos.add(p);
      } else if (vindo != null) {
        novos.add(vindo.copyWith(notas: p.notas));
      } else if (!doGrupo(p)) {
        novos.add(p);
      } else if (p.donoId == _usuarioId) {
        novos.add(_personagens.semCampanha(p));
      }
    }
    _todos = [...novos, ...porId.values];
    notifyListeners();
  }

  void _ouvirMeus(String usuarioId) {
    _pararEscuta?.call();
    _pararEscuta = _realtime?.ouvirMeusHerois(usuarioId, _agendarRecarga);
  }

  // varios eventos juntos viram uma recarga so
  void _agendarRecarga() {
    _recarga?.cancel();
    _recarga = Timer(const Duration(milliseconds: 300), () async {
      try {
        await recarregar();
      } catch (e, stack) {
        AppLog.erro(
          TagLog.provider,
          'recarga dos herois',
          erro: e,
          stack: stack,
        );
      }
    });
  }

  void limpar() {
    _cancelarTudo();
    _todos = const [];
    _usuarioId = null;
    _carregamento = Carregamento.inicial;
    _mensagemErro = null;
    notifyListeners();
  }

  // acoes do dono

  // nasce sem campanha e vira o ativo
  Future<Personagem> criar(Personagem novo) async {
    final criado = await _service.criar(novo);
    await _service.ativar(criado.id);
    final ativo = criado.copyWith(ativo: true, notas: const []);
    _todos = [
      for (final p in _todos)
        p.donoId == _usuarioId ? p.copyWith(ativo: false) : p,
      ativo,
    ];
    notifyListeners();
    return ativo;
  }

  // a tela muda na hora; o banco recebe so o que mudou depois de [espera]
  // parado. se falhar volta o valor e o futuro termina com o erro
  Future<void> editar(Personagem novo) {
    final atual = porId(novo.id);
    if (atual == null) return Future.value();
    _noBanco.putIfAbsent(novo.id, () => atual);
    _todos = _personagens.trocar(_todos, novo);
    notifyListeners();

    _timers[novo.id]?.cancel();
    _timers[novo.id] = Timer(espera, () => _salvar(novo.id));
    return _pendentes.putIfAbsent(novo.id, Completer.new).future;
  }

  Future<void> _salvar(String id) async {
    _timers.remove(id);
    final base = _noBanco.remove(id);
    final espera = _pendentes.remove(id);
    final atual = porId(id);
    if (base == null || atual == null) {
      espera?.complete();
      return;
    }
    final campos = _personagens.camposMudados(base, atual);
    try {
      await _service.atualizar(id, campos);
      espera?.complete();
    } catch (e, stack) {
      AppLog.erro(
        TagLog.provider,
        'heroi nao salvou ${campos.keys.join(', ')}',
        erro: e,
        stack: stack,
      );
      final agora = porId(id);
      if (agora != null) {
        _todos = _personagens.trocar(
          _todos,
          _personagens.voltarCampos(agora, base, campos.keys),
        );
        notifyListeners();
      }
      espera?.completeError(e, stack);
    }
  }

  Future<void> apagar(String id) async {
    await _service.apagar(id);
    _todos = [
      for (final p in _todos)
        if (p.id != id) p,
    ];
    notifyListeners();
  }

  // diario

  Future<void> adicionarNota(String personagemId, Nota nota) async {
    final criada = await _service.criarNota(personagemId, nota);
    final p = porId(personagemId);
    if (p == null) return;
    _todos = _personagens.trocar(_todos, _notas.adicionar(p, criada));
    notifyListeners();
  }

  Future<void> removerNota(String personagemId, String notaId) async {
    await _service.apagarNota(notaId);
    final p = porId(personagemId);
    if (p == null) return;
    _todos = _personagens.trocar(_todos, _notas.remover(p, notaId));
    notifyListeners();
  }

  void _cancelarTudo() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _noBanco.clear();
    for (final c in _pendentes.values) {
      c.complete();
    }
    _pendentes.clear();
    _recarga?.cancel();
    _pararEscuta?.call();
    _pararEscuta = null;
  }

  @override
  void dispose() {
    _cancelarTudo();
    super.dispose();
  }
}
