import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/model/srd/condicao_srd.dart';
import 'package:grimorio/model/srd/especie.dart';
import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';
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
  _Lista(this.nome, this.buscar);

  final String nome;
  final BuscaPagina<T> buscar;
  EstadoLista<T> estado = EstadoLista<T>();

  // muda a cada busca nova, resposta velha e ignorada
  int versao = 0;
}

// listas do srd vindas da api, a tela do grimorio ainda usa o mock
class CompendioProvider extends ChangeNotifier {
  CompendioProvider({
    required MagiaService magias,
    required MonstroService monstros,
    required ItemService itens,
    required ClasseService classes,
    required EspecieService especies,
    required CondicaoService condicoes,
  }) : _magias = _Lista('Magias', (p, b) => magias.listar(pagina: p, busca: b)),
       _monstros = _Lista(
         'Monstros',
         (p, b) => monstros.listar(pagina: p, busca: b),
       ),
       _itens = _Lista(
         'Itens',
         (p, b) => itens.listarItens(pagina: p, busca: b),
       ),
       _itensMagicos = _Lista(
         'ItensMagicos',
         (p, b) => itens.listarMagicos(pagina: p, busca: b),
       ),
       _armas = _Lista(
         'Armas',
         (p, b) => itens.listarArmas(pagina: p, busca: b),
       ),
       _armaduras = _Lista(
         'Armaduras',
         (p, b) => itens.listarArmaduras(pagina: p, busca: b),
       ),
       _classes = _Lista(
         'Classes',
         (p, b) => classes.listar(pagina: p, busca: b),
       ),
       _especies = _Lista(
         'Especies',
         (p, b) => especies.listar(pagina: p, busca: b),
       ),
       _condicoes = _Lista(
         'Condicoes',
         (p, b) => condicoes.listar(pagina: p, busca: b),
       );

  final _Lista<Magia> _magias;
  final _Lista<MonstroSrd> _monstros;
  final _Lista<ItemSrd> _itens;
  final _Lista<ItemSrd> _itensMagicos;
  final _Lista<ItemSrd> _armas;
  final _Lista<ItemSrd> _armaduras;
  final _Lista<ClasseSrd> _classes;
  final _Lista<Especie> _especies;
  final _Lista<CondicaoSrd> _condicoes;

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

  // primeira pagina ou outra busca

  Future<void> carregarMagias({int pagina = 1, String? busca}) =>
      _carregar(_magias, pagina, busca);
  Future<void> carregarMonstros({int pagina = 1, String? busca}) =>
      _carregar(_monstros, pagina, busca);
  Future<void> carregarItens({int pagina = 1, String? busca}) =>
      _carregar(_itens, pagina, busca);
  Future<void> carregarItensMagicos({int pagina = 1, String? busca}) =>
      _carregar(_itensMagicos, pagina, busca);
  Future<void> carregarArmas({int pagina = 1, String? busca}) =>
      _carregar(_armas, pagina, busca);
  Future<void> carregarArmaduras({int pagina = 1, String? busca}) =>
      _carregar(_armaduras, pagina, busca);
  Future<void> carregarClasses({int pagina = 1, String? busca}) =>
      _carregar(_classes, pagina, busca);
  Future<void> carregarEspecies({int pagina = 1, String? busca}) =>
      _carregar(_especies, pagina, busca);
  Future<void> carregarCondicoes({int pagina = 1, String? busca}) =>
      _carregar(_condicoes, pagina, busca);

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

  Future<void> _carregarMais<T>(_Lista<T> lista) {
    final e = lista.estado;
    if (!e.temMais) return Future.value();
    return _carregar(lista, e.pagina + 1, e.busca);
  }

  // todo carregamento termina em pronto ou erro
  Future<void> _carregar<T>(_Lista<T> lista, int pagina, String? busca) async {
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
