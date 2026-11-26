import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/service/api/api_erro.dart';

enum TipoSrd {
  magia,
  monstro,
  item,
  itemMagico,
  arma,
  armadura,
  classe,
  especie,
  condicao,
}

// um item do srd aberto pela key
class EstadoDetalhe<T> {
  const EstadoDetalhe({
    this.carregamento = Carregamento.inicial,
    this.item,
    this.mensagemErro,
    this.tipoErro,
  });

  final Carregamento carregamento;
  final T? item;

  // ja amigavel
  final String? mensagemErro;

  // naoEncontrado vira a tela de nao encontrado
  final TipoErroApi? tipoErro;

  bool get naoEncontrado => tipoErro == TipoErroApi.naoEncontrado;
}
