import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/model/srd/condicao_srd.dart';
import 'package:grimorio/model/srd/especie.dart';
import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';
import 'package:grimorio/service/api/api_erro.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/classe_service.dart';
import 'package:grimorio/service/open5e/condicao_service.dart';
import 'package:grimorio/service/open5e/especie_service.dart';
import 'package:grimorio/service/open5e/item_service.dart';
import 'package:grimorio/service/open5e/magia_service.dart';
import 'package:grimorio/service/open5e/monstro_service.dart';

typedef BuscaPagina<T> = Future<Paginado<T>> Function(
  int pagina,
  String? busca,
);

// uma lista do srd com o jeito de buscar
class _Lista<T> {
  _Lista(this.nome, this.keyDe, this.buscar);

  final String nome;
  final String Function(T item) keyDe;
  final BuscaPagina<T> buscar;
  EstadoLista<T> estado = EstadoLista<T>();

  // muda a cada busca nova, resposta velha e ignorada
  int versao = 0;

  T? porKey(String key) {
    for (final i in estado.itens) {
      if (keyDe(i) == key) return i;
    }
    return null;
  }
}

// listas e detalhes do srd vindos da api
class CompendioProvider extends ChangeNotifier {
  CompendioProvider({
    required MagiaService magias,
    required MonstroService monstros,
    required ItemService itens,
    required ClasseService classes,
    required EspecieService especies,
    required CondicaoService condicoes,
  }) : _magiaService = magias,
       _monstroService = monstros,
       _itemService = itens,
       _classeService = classes,
       _especieService = especies,
       _condicaoService = condicoes,
       _magias = _Lista(
         'Magias',
         (m) => m.key,
         (p, b) => magias.listar(pagina: p, busca: b),
       ),
       _monstros = _Lista(
         'Monstros',
         (m) => m.key,
         (p, b) => monstros.listar(pagina: p, busca: b),
       ),
       _itens = _Lista(
         'Itens',
         (i) => i.key,
         (p, b) => itens.listarItens(pagina: p, busca: b),
       ),
       _itensMagicos = _Lista(
         'ItensMagicos',
         (i) => i.key,
         (p, b) => itens.listarMagicos(pagina: p, busca: b),
       ),
       _armas = _Lista(
         'Armas',
         (i) => i.key,
         (p, b) => itens.listarArmas(pagina: p, busca: b),
       ),
       _armaduras = _Lista(
         'Armaduras',
         (i) => i.key,
         (p, b) => itens.listarArmaduras(pagina: p, busca: b),
       ),
       _classes = _Lista(
         'Classes',
         (c) => c.key,
         (p, b) => classes.listar(pagina: p, busca: b),
       ),
       _especies = _Lista(
         'Especies',
         (e) => e.key,
         (p, b) => especies.listar(pagina: p, busca: b),
       ),
       _condicoes = _Lista(
         'Condicoes',
         (c) => c.key,
         (p, b) => condicoes.listar(pagina: p, busca: b),
       );

  final MagiaService _magiaService;
  final MonstroService _monstroService;
  final ItemService _itemService;
  final ClasseService _classeService;
  final EspecieService _especieService;
  final CondicaoService _condicaoService;

  final _Lista<Magia> _magias;
  final _Lista<MonstroSrd> _monstros;
  final _Lista<ItemSrd> _itens;
  final _Lista<ItemSrd> _itensMagicos;
  final _Lista<ItemSrd> _armas;
  final _Lista<ItemSrd> _armaduras;
  final _Lista<ClasseSrd> _classes;
  final _Lista<Especie> _especies;
  final _Lista<CondicaoSrd> _condicoes;

  // tipo + key
  final _detalhes = <String, EstadoDetalhe<Object>>{};

  bool _fechado = false;

  // estados

  EstadoLista<Magia> get magias => _magias.estado;
  EstadoLista<MonstroSrd> get monstros => _monstros.estado;
  EstadoLista<ItemSrd> get itens => _itens.estado;
  EstadoLista<ItemSrd> get itensMagicos => _itensMagicos.estado;
  EstadoLista<ItemSrd> get armas => _armas.estado;
  EstadoLista<ItemSrd> get armaduras => _armaduras.estado;
  EstadoLista<ClasseSrd> get classes => _classes.estado;
  EstadoLista<Especie> get especies => _especies.estado;
  EstadoLista<CondicaoSrd> get condicoes => _condicoes.estado;

  // primeira pagina; mesma busca ja carregada nao chama a api

  Future<void> carregarMagias({String? busca, bool forcar = false}) =>
      _carregar(_magias, busca, forcar: forcar);
  Future<void> carregarMonstros({String? busca, bool forcar = false}) =>
      _carregar(_monstros, busca, forcar: forcar);
  Future<void> carregarItens({String? busca, bool forcar = false}) =>
      _carregar(_itens, busca, forcar: forcar);
  Future<void> carregarItensMagicos({String? busca, bool forcar = false}) =>
      _carregar(_itensMagicos, busca, forcar: forcar);
  Future<void> carregarArmas({String? busca, bool forcar = false}) =>
      _carregar(_armas, busca, forcar: forcar);
  Future<void> carregarArmaduras({String? busca, bool forcar = false}) =>
      _carregar(_armaduras, busca, forcar: forcar);
  Future<void> carregarClasses({String? busca, bool forcar = false}) =>
      _carregar(_classes, busca, forcar: forcar);
  Future<void> carregarEspecies({String? busca, bool forcar = false}) =>
      _carregar(_especies, busca, forcar: forcar);
  Future<void> carregarCondicoes({String? busca, bool forcar = false}) =>
      _carregar(_condicoes, busca, forcar: forcar);

  // proxima pagina

  Future<void> carregarMaisMagias() => _carregarMais(_magias);
  Future<void> carregarMaisMonstros() => _carregarMais(_monstros);
  Future<void> carregarMaisItens() => _carregarMais(_itens);
  Future<void> carregarMaisItensMagicos() => _carregarMais(_itensMagicos);
  Future<void> carregarMaisArmas() => _carregarMais(_armas);
  Future<void> carregarMaisArmaduras() => _carregarMais(_armaduras);
  Future<void> carregarMaisClasses() => _carregarMais(_classes);
  Future<void> carregarMaisEspecies() => _carregarMais(_especies);
  Future<void> carregarMaisCondicoes() => _carregarMais(_condicoes);

  // detalhe

  EstadoDetalhe<T> detalhe<T>(TipoSrd tipo, String key) {
    final e = _detalhes[_chave(tipo, key)];
    if (e == null) return EstadoDetalhe<T>();
    final item = e.item;
    return EstadoDetalhe<T>(
      carregamento: e.carregamento,
      item: item is T ? item : null,
      mensagemErro: e.mensagemErro,
      tipoErro: e.tipoErro,
    );
  }

  // usa o item da lista se ja veio, senao busca pela key
  Future<void> carregarDetalhe(TipoSrd tipo, String key) async {
    final chave = _chave(tipo, key);
    final atual = _detalhes[chave]?.carregamento;
    if (atual == Carregamento.pronto || atual == Carregamento.carregando) {
      return;
    }

    final daLista = _naLista(tipo, key);
    if (daLista != null) {
      _detalhes[chave] = EstadoDetalhe(
        carregamento: Carregamento.pronto,
        item: daLista,
      );
      _avisar();
      return;
    }

    _detalhes[chave] = const EstadoDetalhe(
      carregamento: Carregamento.carregando,
    );
    _avisar();
    try {
      final item = await _buscar(tipo, key);
      _detalhes[chave] = EstadoDetalhe(
        carregamento: Carregamento.pronto,
        item: item,
      );
    } catch (e, stack) {
      final msg = mensagemDeErro(
        e,
        stack: stack,
        tag: TagLog.provider,
        onde: 'CompendioProvider.carregarDetalhe ${tipo.name} $key',
      );
      _detalhes[chave] = EstadoDetalhe(
        carregamento: Carregamento.erro,
        mensagemErro: msg,
        tipoErro: e is ApiErro ? e.tipo : TipoErroApi.desconhecido,
      );
    }
    _avisar();
  }

  static String _chave(TipoSrd tipo, String key) => '${tipo.name}:$key';

  Object? _naLista(TipoSrd tipo, String key) => switch (tipo) {
    TipoSrd.magia => _magias.porKey(key),
    TipoSrd.monstro => _monstros.porKey(key),
    TipoSrd.item => _itens.porKey(key),
    TipoSrd.itemMagico => _itensMagicos.porKey(key),
    TipoSrd.arma => _armas.porKey(key),
    TipoSrd.armadura => _armaduras.porKey(key),
    TipoSrd.classe => _classes.porKey(key),
    TipoSrd.especie => _especies.porKey(key),
    TipoSrd.condicao => _condicoes.porKey(key),
  };

  Future<Object> _buscar(TipoSrd tipo, String key) => switch (tipo) {
    TipoSrd.magia => _magiaService.buscar(key),
    TipoSrd.monstro => _monstroService.buscar(key),
    TipoSrd.item ||
    TipoSrd.arma ||
    TipoSrd.armadura => _itemService.buscar(key),
    TipoSrd.itemMagico => _itemService.buscarMagico(key),
    TipoSrd.classe => _classeService.buscar(key),
    TipoSrd.especie => _especieService.buscar(key),
    TipoSrd.condicao => _condicaoService.buscar(key),
  };

  // listas

  Future<void> _carregarMais<T>(_Lista<T> lista) {
    final e = lista.estado;
    if (!e.temMais) return Future.value();
    return _buscarPagina(lista, e.pagina + 1, e.busca);
  }

  Future<void> _carregar<T>(
    _Lista<T> lista,
    String? busca, {
    required bool forcar,
  }) {
    final e = lista.estado;
    final mesma = e.busca == busca;
    final ativa =
        e.carregamento == Carregamento.pronto ||
        e.carregamento == Carregamento.carregando;
    if (mesma && ativa && !forcar) return Future.value();
    return _buscarPagina(lista, 1, busca);
  }

  // todo carregamento termina em pronto ou erro
  Future<void> _buscarPagina<T>(
    _Lista<T> lista,
    int pagina,
    String? busca,
  ) async {
    final mais = pagina > 1;
    final atual = lista.estado;
    if (mais && (atual.carregandoMais || !atual.temMais)) return;
    final versao = mais ? lista.versao : ++lista.versao;

    lista.estado = mais
        ? atual.copyWith(carregandoMais: true, limparErroMais: true)
        : EstadoLista<T>(carregamento: Carregamento.carregando, busca: busca);
    _avisar();

    try {
      final r = await lista.buscar(pagina, busca);
      if (versao != lista.versao) return;
      final base = lista.estado;
      lista.estado = base.copyWith(
        carregamento: Carregamento.pronto,
        itens: mais ? [...base.itens, ...r.itens] : r.itens,
        total: r.total,
        temMais: r.temMais,
        pagina: pagina,
        carregandoMais: false,
      );
    } catch (e, stack) {
      final msg = mensagemDeErro(
        e,
        stack: stack,
        tag: TagLog.provider,
        onde: 'CompendioProvider.carregar${mais ? 'Mais' : ''}${lista.nome}',
      );
      if (versao != lista.versao) return;
      final base = lista.estado;
      lista.estado = mais
          ? base.copyWith(carregandoMais: false, erroAoCarregarMais: msg)
          : base.copyWith(carregamento: Carregamento.erro, mensagemErro: msg);
    }
    _avisar();
  }

  void _avisar() {
    if (!_fechado) notifyListeners();
  }

  @override
  void dispose() {
    _fechado = true;
    super.dispose();
  }
}
