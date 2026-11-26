import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/grimoire/filtros_srd.dart';
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

typedef BuscaPagina<T, F> = Future<Paginado<T>> Function(
  int pagina,
  String? busca,
  F filtro,
);

// uma lista do srd com o jeito de buscar e o filtro atual
class _Lista<T, F> {
  _Lista(this.nome, this.keyDe, this.filtro, this.buscar);

  final String nome;
  final String Function(T item) keyDe;
  final BuscaPagina<T, F> buscar;
  F filtro;
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
         const FiltroMagia(),
         (p, b, f) => magias.listar(
           pagina: p,
           busca: b,
           nivel: f.nivel,
           nivelMinimo: f.nivelMinimo,
           concentracao: f.concentracao ? true : null,
           classeKey: f.classeKey,
           escolaKey: f.escolaKey,
         ),
       ),
       _monstros = _Lista(
         'Monstros',
         (m) => m.key,
         const FiltroMonstro(),
         (p, b, f) => monstros.listar(
           pagina: p,
           busca: b,
           tipo: f.tipo,
           ndMinimo: f.ndMinimo,
           ndMaximo: f.ndMaximo,
         ),
       ),
       _itens = _Lista(
         'Itens',
         (i) => i.key,
         null,
         (p, b, _) => itens.listarItens(pagina: p, busca: b),
       ),
       _itensMagicos = _Lista(
         'ItensMagicos',
         (i) => i.key,
         const FiltroItemMagico(),
         (p, b, f) =>
             itens.listarMagicos(pagina: p, busca: b, raridade: f.raridade),
       ),
       _armas = _Lista(
         'Armas',
         (i) => i.key,
         null,
         (p, b, _) => itens.listarArmas(pagina: p, busca: b),
       ),
       _armaduras = _Lista(
         'Armaduras',
         (i) => i.key,
         null,
         (p, b, _) => itens.listarArmaduras(pagina: p, busca: b),
       ),
       _classes = _Lista(
         'Classes',
         (c) => c.key,
         null,
         (p, b, _) => classes.listar(pagina: p, busca: b, subclasse: false),
       ),
       _especies = _Lista(
         'Especies',
         (e) => e.key,
         null,
         (p, b, _) => especies.listar(pagina: p, busca: b, subespecie: false),
       ),
       _condicoes = _Lista(
         'Condicoes',
         (c) => c.key,
         null,
         (p, b, _) => condicoes.listar(pagina: p, busca: b),
       ),
       _buscaMagias = _Lista(
         'BuscaMagias',
         (m) => m.key,
         null,
         (p, b, _) => magias.listar(pagina: p, busca: b),
       ),
       _buscaMonstros = _Lista(
         'BuscaMonstros',
         (m) => m.key,
         null,
         (p, b, _) => monstros.listar(pagina: p, busca: b),
       ),
       _buscaItensMagicos = _Lista(
         'BuscaItensMagicos',
         (i) => i.key,
         null,
         (p, b, _) => itens.listarMagicos(pagina: p, busca: b),
       ),
       _buscaItens = _Lista(
         'BuscaItens',
         (i) => i.key,
         null,
         (p, b, _) => itens.listarTodos(pagina: p, busca: b),
       );

  final MagiaService _magiaService;
  final MonstroService _monstroService;
  final ItemService _itemService;
  final ClasseService _classeService;
  final EspecieService _especieService;
  final CondicaoService _condicaoService;

  final _Lista<Magia, FiltroMagia> _magias;
  final _Lista<MonstroSrd, FiltroMonstro> _monstros;
  final _Lista<ItemSrd, Object?> _itens;
  final _Lista<ItemSrd, FiltroItemMagico> _itensMagicos;
  final _Lista<ItemSrd, Object?> _armas;
  final _Lista<ItemSrd, Object?> _armaduras;
  final _Lista<ClasseSrd, Object?> _classes;
  final _Lista<Especie, Object?> _especies;
  final _Lista<CondicaoSrd, Object?> _condicoes;

  // busca da home do grimorio, separada das listas das telas
  final _Lista<Magia, Object?> _buscaMagias;
  final _Lista<MonstroSrd, Object?> _buscaMonstros;
  final _Lista<ItemSrd, Object?> _buscaItensMagicos;
  final _Lista<ItemSrd, Object?> _buscaItens;

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

  EstadoLista<Magia> get buscaMagias => _buscaMagias.estado;
  EstadoLista<MonstroSrd> get buscaMonstros => _buscaMonstros.estado;
  EstadoLista<ItemSrd> get buscaItensMagicos => _buscaItensMagicos.estado;
  EstadoLista<ItemSrd> get buscaItens => _buscaItens.estado;

  // filtros atuais, a tela comeca deles ao voltar

  FiltroMagia get filtroMagias => _magias.filtro;
  FiltroMonstro get filtroMonstros => _monstros.filtro;
  FiltroItemMagico get filtroItensMagicos => _itensMagicos.filtro;

  // primeira pagina; mesma busca e filtro ja carregados nao chamam a api
  // filtro omitido mantem o atual

  Future<void> carregarMagias({
    String? busca,
    FiltroMagia? filtro,
    bool forcar = false,
  }) => _carregar(_magias, busca, filtro ?? _magias.filtro, forcar: forcar);
  Future<void> carregarMonstros({
    String? busca,
    FiltroMonstro? filtro,
    bool forcar = false,
  }) => _carregar(_monstros, busca, filtro ?? _monstros.filtro, forcar: forcar);
  Future<void> carregarItens({String? busca, bool forcar = false}) =>
      _carregar(_itens, busca, null, forcar: forcar);
  Future<void> carregarItensMagicos({
    String? busca,
    FiltroItemMagico? filtro,
    bool forcar = false,
  }) => _carregar(
    _itensMagicos,
    busca,
    filtro ?? _itensMagicos.filtro,
    forcar: forcar,
  );
  Future<void> carregarArmas({String? busca, bool forcar = false}) =>
      _carregar(_armas, busca, null, forcar: forcar);
  Future<void> carregarArmaduras({String? busca, bool forcar = false}) =>
      _carregar(_armaduras, busca, null, forcar: forcar);
  Future<void> carregarClasses({String? busca, bool forcar = false}) =>
      _carregar(_classes, busca, null, forcar: forcar);
  Future<void> carregarEspecies({String? busca, bool forcar = false}) =>
      _carregar(_especies, busca, null, forcar: forcar);
  Future<void> carregarCondicoes({String? busca, bool forcar = false}) =>
      _carregar(_condicoes, busca, null, forcar: forcar);

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

  // uma pagina de cada, so quando a home busca
  Future<void> buscarTudo(String busca) => Future.wait([
    _carregar(_buscaMagias, busca, null, forcar: false),
    _carregar(_buscaMonstros, busca, null, forcar: false),
    _carregar(_buscaItensMagicos, busca, null, forcar: false),
    _carregar(_buscaItens, busca, null, forcar: false),
  ]);

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
    TipoSrd.magia => _magias.porKey(key) ?? _buscaMagias.porKey(key),
    TipoSrd.monstro => _monstros.porKey(key) ?? _buscaMonstros.porKey(key),
    TipoSrd.item => _itens.porKey(key) ?? _buscaItens.porKey(key),
    TipoSrd.itemMagico =>
      _itensMagicos.porKey(key) ?? _buscaItensMagicos.porKey(key),
    TipoSrd.arma => _armas.porKey(key) ?? _buscaItens.porKey(key),
    TipoSrd.armadura => _armaduras.porKey(key) ?? _buscaItens.porKey(key),
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

  Future<void> _carregarMais<T, F>(_Lista<T, F> lista) {
    final e = lista.estado;
    if (!e.temMais) return Future.value();
    return _buscarPagina(lista, e.pagina + 1, e.busca);
  }

  Future<void> _carregar<T, F>(
    _Lista<T, F> lista,
    String? busca,
    F filtro, {
    required bool forcar,
  }) {
    final e = lista.estado;
    final mesma = e.busca == busca && lista.filtro == filtro;
    lista.filtro = filtro;
    final ativa =
        e.carregamento == Carregamento.pronto ||
        e.carregamento == Carregamento.carregando;
    if (mesma && ativa && !forcar) return Future.value();
    return _buscarPagina(lista, 1, busca);
  }

  // todo carregamento termina em pronto ou erro
  Future<void> _buscarPagina<T, F>(
    _Lista<T, F> lista,
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
      final r = await lista.buscar(pagina, busca, lista.filtro);
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
