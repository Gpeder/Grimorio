enum Ability {
  forca('FOR'),
  destreza('DES'),
  constituicao('CON'),
  inteligencia('INT'),
  sabedoria('SAB'),
  carisma('CAR');

  const Ability(this.sigla);
  final String sigla;
}

// Tabela de XP mínimonível
const xpPorNivel = [
  0,
  300,
  900,
  2700,
  6500,
  14000,
  23000,
  34000,
  48000,
  64000,
  85000,
  100000,
  120000,
  140000,
  165000,
  195000,
  225000,
  265000,
  305000,
  355000,
];

int modificador(int valor) => ((valor - 10) / 2).floor();

class AbilityScores {
  const AbilityScores({
    required this.forca,
    required this.destreza,
    required this.constituicao,
    required this.inteligencia,
    required this.sabedoria,
    required this.carisma,
  });

  final int forca;
  final int destreza;
  final int constituicao;
  final int inteligencia;
  final int sabedoria;
  final int carisma;

  int valor(Ability a) => switch (a) {
    Ability.forca => forca,
    Ability.destreza => destreza,
    Ability.constituicao => constituicao,
    Ability.inteligencia => inteligencia,
    Ability.sabedoria => sabedoria,
    Ability.carisma => carisma,
  };

  int mod(Ability a) => modificador(valor(a));
}

// Classe e nivel
class CharacterClass {
  const CharacterClass({
    required this.apiKey,
    required this.nome,
    required this.nivel,
    required this.dadoDeVida,
    this.subclasse,
  });

  final String apiKey;
  final String nome;
  final int nivel;
  final int dadoDeVida;
  final String? subclasse;
}

/// Espaços de magia
class SpellSlot {
  const SpellSlot({
    required this.circulo,
    required this.total,
    this.usados = 0,
  });

  final int circulo;
  final int total;
  final int usados;

  int get livres => total - usados;

  SpellSlot copyWith({int? usados}) =>
      SpellSlot(circulo: circulo, total: total, usados: usados ?? this.usados);
}

enum EquipSlot {
  elmo,
  colar,
  capa,
  armadura,
  luvas,
  anel,
  botas,
  maoPrincipal,
  maoSecundaria,
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.nome,
    required this.imagem,
    this.quantidade = 1,
    this.pesoKg = 0,
    this.equipadoEm,
  });

  final String id;
  final String nome;
  final String imagem;
  final int quantidade;
  final double pesoKg;
  final EquipSlot? equipadoEm;

  bool get equipado => equipadoEm != null;
}

class Condition {
  const Condition({required this.nome, this.rodadas});
  final String nome;
  final int? rodadas;
}

class Character {
  const Character({
    required this.id,
    required this.nome,
    required this.retrato,
    required this.especie,
    required this.classes,
    required this.atributos,
    required this.xp,
    required this.hpMax,
    required this.hpAtual,
    required this.ca,
    required this.deslocamentoM,
    this.hpTemp = 0,
    this.salvaguardas = const {},
    this.pericias = const {},
    this.espacosDeMagia = const [],
    this.inventario = const [],
    this.condicoes = const [],
    this.moedas = const Moedas(),
    this.campanhaId,
    this.ativo = false,
  });

  final String id;
  final String nome;
  final String retrato;
  final String especie;
  final List<CharacterClass> classes;
  final AbilityScores atributos;
  final int xp;
  final int hpMax;
  final int hpAtual;
  final int hpTemp;
  final int ca;
  final double deslocamentoM;
  final Set<Ability> salvaguardas;
  final Set<String> pericias;
  final List<SpellSlot> espacosDeMagia;
  final List<InventoryItem> inventario;
  final List<Condition> condicoes;
  final Moedas moedas;
  final String? campanhaId;
  final bool ativo;

  int get nivel => classes.fold(0, (s, c) => s + c.nivel);
  int get bonusProficiencia => 2 + ((nivel - 1) ~/ 4);
  int get iniciativa => atributos.mod(Ability.destreza);
  int get xpNivelAtual => xpPorNivel[nivel - 1];
  int get xpProximoNivel => nivel >= 20 ? xpPorNivel.last : xpPorNivel[nivel];

  double get progressoXp {
    if (nivel >= 20) return 1;
    final base = xpPorNivel[nivel - 1];
    return (xp - base) / (xpProximoNivel - base);
  }

  bool get podeSubirNivel => nivel < 20 && xp >= xpProximoNivel;

  int salvaguarda(Ability a) =>
      atributos.mod(a) + (salvaguardas.contains(a) ? bonusProficiencia : 0);

  int get espacosLivres => espacosDeMagia.fold(0, (s, e) => s + e.livres);

  double get cargaKg =>
      inventario.fold(0, (s, i) => s + i.pesoKg * i.quantidade);

  double get cargaMaxKg => atributos.forca * 7.5;

  String get classeResumo =>
      classes.map((c) => '${c.nome} ${c.nivel}').join(' / ');

  Character receberDano(int valor) {
    final absorvido = valor.clamp(0, hpTemp);
    final restante = valor - absorvido;
    return copyWith(
      hpTemp: hpTemp - absorvido,
      hpAtual: (hpAtual - restante).clamp(0, hpMax),
    );
  }

  Character curar(int valor) =>
      copyWith(hpAtual: (hpAtual + valor).clamp(0, hpMax));

  Character gastarEspaco(int circulo) => copyWith(
    espacosDeMagia: [
      for (final e in espacosDeMagia)
        e.circulo == circulo && e.livres > 0
            ? e.copyWith(usados: e.usados + 1)
            : e,
    ],
  );

  Character descansoLongo() => copyWith(
    hpAtual: hpMax,
    hpTemp: 0,
    espacosDeMagia: [for (final e in espacosDeMagia) e.copyWith(usados: 0)],
  );

  Character ganharXp(int valor) => copyWith(xp: xp + valor);

  Character copyWith({
    int? xp,
    int? hpMax,
    int? hpAtual,
    int? hpTemp,
    int? ca,
    List<SpellSlot>? espacosDeMagia,
    List<InventoryItem>? inventario,
    List<Condition>? condicoes,
    Moedas? moedas,
    bool? ativo,
  }) => Character(
    id: id,
    nome: nome,
    retrato: retrato,
    especie: especie,
    classes: classes,
    atributos: atributos,
    xp: xp ?? this.xp,
    hpMax: hpMax ?? this.hpMax,
    hpAtual: hpAtual ?? this.hpAtual,
    hpTemp: hpTemp ?? this.hpTemp,
    ca: ca ?? this.ca,
    deslocamentoM: deslocamentoM,
    salvaguardas: salvaguardas,
    pericias: pericias,
    espacosDeMagia: espacosDeMagia ?? this.espacosDeMagia,
    inventario: inventario ?? this.inventario,
    condicoes: condicoes ?? this.condicoes,
    moedas: moedas ?? this.moedas,
    campanhaId: campanhaId,
    ativo: ativo ?? this.ativo,
  );
}

class Moedas {
  const Moedas({this.ouro = 0, this.prata = 0, this.cobre = 0});

  final int ouro;
  final int prata;
  final int cobre;
}
