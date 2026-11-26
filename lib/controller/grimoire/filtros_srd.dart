// filtros que vao na query, igualdade decide se recarrega

class FiltroMagia {
  const FiltroMagia({
    this.nivel,
    this.nivelMinimo,
    this.concentracao = false,
    this.classeKey,
    this.escolaKey,
  });

  // nivel exato ou 4 e acima
  final int? nivel;
  final int? nivelMinimo;
  final bool concentracao;
  final String? classeKey;
  final String? escolaKey;

  FiltroMagia copyWith({
    int? Function()? nivel,
    int? Function()? nivelMinimo,
    bool? concentracao,
    String? Function()? classeKey,
    String? Function()? escolaKey,
  }) => FiltroMagia(
    nivel: nivel == null ? this.nivel : nivel(),
    nivelMinimo: nivelMinimo == null ? this.nivelMinimo : nivelMinimo(),
    concentracao: concentracao ?? this.concentracao,
    classeKey: classeKey == null ? this.classeKey : classeKey(),
    escolaKey: escolaKey == null ? this.escolaKey : escolaKey(),
  );

  @override
  bool operator ==(Object other) =>
      other is FiltroMagia &&
      other.nivel == nivel &&
      other.nivelMinimo == nivelMinimo &&
      other.concentracao == concentracao &&
      other.classeKey == classeKey &&
      other.escolaKey == escolaKey;

  @override
  int get hashCode =>
      Object.hash(nivel, nivelMinimo, concentracao, classeKey, escolaKey);
}

class FiltroMonstro {
  const FiltroMonstro({this.tipo, this.ndMinimo, this.ndMaximo});

  // key da api: dragon, undead
  final String? tipo;
  final double? ndMinimo;
  final double? ndMaximo;

  FiltroMonstro copyWith({
    String? Function()? tipo,
    double? Function()? ndMinimo,
    double? Function()? ndMaximo,
  }) => FiltroMonstro(
    tipo: tipo == null ? this.tipo : tipo(),
    ndMinimo: ndMinimo == null ? this.ndMinimo : ndMinimo(),
    ndMaximo: ndMaximo == null ? this.ndMaximo : ndMaximo(),
  );

  @override
  bool operator ==(Object other) =>
      other is FiltroMonstro &&
      other.tipo == tipo &&
      other.ndMinimo == ndMinimo &&
      other.ndMaximo == ndMaximo;

  @override
  int get hashCode => Object.hash(tipo, ndMinimo, ndMaximo);
}

class FiltroItemMagico {
  const FiltroItemMagico({this.raridade});

  // key da api: rare, very-rare
  final String? raridade;

  @override
  bool operator ==(Object other) =>
      other is FiltroItemMagico && other.raridade == raridade;

  @override
  int get hashCode => raridade.hashCode;
}
