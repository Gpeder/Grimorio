// resposta paginada da open5e: count, next, previous, results
class Paginado<T> {
  const Paginado({
    required this.total,
    required this.temMais,
    required this.itens,
  });

  final int total;
  final bool temMais;
  final List<T> itens;

  factory Paginado.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) item,
  ) => Paginado(
    total: (json['count'] as num?)?.toInt() ?? 0,
    temMais: json['next'] != null,
    itens: [
      for (final r in json['results'] as List? ?? const [])
        item(r as Map<String, dynamic>),
    ],
  );
}
