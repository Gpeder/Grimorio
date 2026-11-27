import 'dart:convert';

T lerEnum<T extends Enum>(List<T> valores, Object? nome, T padrao) =>
    lerEnumOuNulo(valores, nome) ?? padrao;

T? lerEnumOuNulo<T extends Enum>(List<T> valores, Object? nome) {
  if (nome is! String) return null;
  try {
    return valores.byName(nome);
  } on ArgumentError {
    return null;
  }
}

DateTime lerData(Object? valor) =>
    lerDataOuNulo(valor) ?? DateTime.fromMillisecondsSinceEpoch(0);

DateTime? lerDataOuNulo(Object? valor) =>
    valor is String ? DateTime.tryParse(valor) : null;

String? lerNome(Object? valor) => switch (valor) {
  {'name': final String nome} => nome,
  final String texto => texto,
  _ => null,
};

String? lerKey(Object? valor) => switch (valor) {
  {'key': final String key} => key,
  final String texto => texto,
  _ => null,
};

double? lerNumero(Object? valor) => switch (valor) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

int? lerInteiro(Object? valor) => lerNumero(valor)?.toInt();

List<Map<String, dynamic>> lerLista(Object? valor) => [
  if (valor is List)
    for (final e in valor)
      if (e is Map<String, dynamic>) e,
];

// so as colunas que mudaram, listas e mapas comparados pelo valor
Map<String, dynamic> camposMudados(
  Map<String, dynamic> antes,
  Map<String, dynamic> depois,
  Iterable<String> colunas,
) => {
  for (final c in colunas)
    if (jsonEncode(antes[c]) != jsonEncode(depois[c])) c: depois[c],
};
