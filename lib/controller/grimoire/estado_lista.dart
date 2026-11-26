enum Carregamento { inicial, carregando, pronto, erro }

// lista paginada e como ela esta
class EstadoLista<T> {
  const EstadoLista({
    this.carregamento = Carregamento.inicial,
    this.itens = const [],
    this.total = 0,
    this.temMais = false,
    this.pagina = 0,
    this.busca,
    this.mensagemErro,
    this.carregandoMais = false,
    this.erroAoCarregarMais,
  });

  final Carregamento carregamento;
  final List<T> itens;
  final int total;
  final bool temMais;
  final int pagina;
  final String? busca;

  // erro da primeira pagina, ja amigavel
  final String? mensagemErro;

  // carregar mais nao troca a lista pelo erro
  final bool carregandoMais;
  final String? erroAoCarregarMais;

  bool get vazia => carregamento == Carregamento.pronto && itens.isEmpty;

  EstadoLista<T> copyWith({
    Carregamento? carregamento,
    List<T>? itens,
    int? total,
    bool? temMais,
    int? pagina,
    String? mensagemErro,
    bool? carregandoMais,
    String? erroAoCarregarMais,
    bool limparErroMais = false,
  }) => EstadoLista(
    carregamento: carregamento ?? this.carregamento,
    itens: itens ?? this.itens,
    total: total ?? this.total,
    temMais: temMais ?? this.temMais,
    pagina: pagina ?? this.pagina,
    busca: busca,
    mensagemErro: mensagemErro ?? this.mensagemErro,
    carregandoMais: carregandoMais ?? this.carregandoMais,
    erroAoCarregarMais: limparErroMais
        ? null
        : erroAoCarregarMais ?? this.erroAoCarregarMais,
  );
}
