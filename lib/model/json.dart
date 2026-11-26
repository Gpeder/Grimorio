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
