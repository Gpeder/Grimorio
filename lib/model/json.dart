// leitura tolerante do json

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

// campos da open5e que podem vir como objeto {name, key} ou texto
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

// numero que pode vir como texto, ex "2.000"
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
