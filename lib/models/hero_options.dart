import 'dart:math' as math;

import 'package:grimorio/models/character.dart';

const nomeAtributo = {
  Ability.forca: 'Força',
  Ability.destreza: 'Destreza',
  Ability.constituicao: 'Constituição',
  Ability.inteligencia: 'Inteligência',
  Ability.sabedoria: 'Sabedoria',
  Ability.carisma: 'Carisma',
};

const proficienciaNivel1 = 2;

class SubspeciesOption {
  const SubspeciesOption({
    required this.key,
    required this.nome,
    this.bonus = const {},
    this.hpPorNivel = 0,
  });

  final String key;
  final String nome;
  final Map<Ability, int> bonus;
  final int hpPorNivel;
}

class SpeciesOption {
  const SpeciesOption({
    required this.key,
    required this.nome,
    required this.descricao,
    required this.bonus,
    required this.deslocamentoM,
    required this.retratoF,
    required this.retratoM,
    required this.tracos,
    required this.idiomas,
    this.nomeF,
    this.tamanho = 'Médio',
    this.visaoNoEscuroM,
    this.pericias = const [],
    this.subespecies = const [],
    this.bonusLivres = 0,
    this.periciasLivres = 0,
    this.idiomasExtras = 0,
  });

  final String key;
  final String nome;
  final String? nomeF;
  final String descricao;
  final String tamanho;
  final Map<Ability, int> bonus;
  final double deslocamentoM;
  final int? visaoNoEscuroM;
  final List<String> pericias;
  final String retratoF;
  final String retratoM;
  final List<String> tracos;
  final List<String> idiomas;
  final List<SubspeciesOption> subespecies;

  final int bonusLivres;

  final int periciasLivres;
  final int idiomasExtras;

  String nomePara({required bool feminino}) =>
      feminino ? (nomeF ?? nome) : nome;

  String retratoPara({required bool feminino}) =>
      feminino ? retratoF : retratoM;
}

class SubclassOption {
  const SubclassOption({
    required this.key,
    required this.nome,
    required this.imagem,
    this.magiasTravadas = const [],
  });

  final String key;
  final String nome;
  final String imagem;

  final List<String> magiasTravadas;
}

enum TipoArmadura { couro, escamas, malha, escudo }

class EquipmentItem {
  const EquipmentItem({
    required this.key,
    required this.nome,
    required this.imagem,
    this.pesoKg = 0,
    this.slot,
    this.armadura,
    this.dano,
    this.tipoDano,
    this.atributoAtaque,
    this.consumivel = false,
    this.descricao,
  });

  final String key;
  final String nome;
  final String imagem;
  final double pesoKg;
  final EquipSlot? slot;
  final TipoArmadura? armadura;
  final String? dano;
  final String? tipoDano;
  final Ability? atributoAtaque;
  final bool consumivel;
  final String? descricao;

  InventoryItem paraInventario() => InventoryItem(
    id: key,
    nome: nome,
    imagem: imagem,
    pesoKg: pesoKg,
    equipadoEm: slot,
    slot: slot ?? (dano != null ? EquipSlot.maoPrincipal : null),
    dano: dano,
    tipoDano: tipoDano,
    atributoAtaque: atributoAtaque,
    consumivel: consumivel,
    descricao: descricao,
    bonusCa: armadura == TipoArmadura.escudo ? 2 : 0,
  );
}

class EquipmentChoice {
  const EquipmentChoice(this.opcoes);

  final List<EquipmentItem> opcoes;
}

class SpellOption {
  const SpellOption({
    required this.key,
    required this.nome,
    required this.circulo,
    required this.escola,
    required this.linha,
    this.concentracao = false,
    this.ritual = false,
    this.tempo = '',
    this.alcance = '',
    this.componentes = '',
    this.duracao = '',
    this.descricao = '',
    this.superior = '',
    this.classes = const [],
  });

  final String key;
  final String nome;
  final String tempo;
  final String alcance;
  final String componentes;
  final String duracao;
  final String descricao;
  final String superior;
  final List<String> classes;
  final int circulo;
  final String escola;

  final String linha;
  final bool concentracao;
  final bool ritual;

  String get resumo => [
    linha,
    if (concentracao) 'concentração',
    if (ritual) 'ritual',
  ].join(' · ');
}

class ClassOption {
  const ClassOption({
    required this.key,
    required this.nome,
    required this.imagem,
    required this.dadoDeVida,
    required this.principal,
    required this.salvaguardas,
    required this.qtdePericias,
    required this.proficiencias,
    this.nomeF,
    this.pericias = const [],
    this.rotuloSubclasse,
    this.subclasses = const [],
    this.truques = 0,
    this.magias = 0,
    this.atributoPreparo,
    this.espacosNivel1 = 0,
    this.listaMagias = const [],
    this.equipamento = const [],
    this.sempreIncluso = const [],
  });

  final String key;
  final String nome;
  final String? nomeF;
  final String imagem;
  final int dadoDeVida;
  final Ability principal;
  final Set<Ability> salvaguardas;
  final int qtdePericias;

  final List<String> pericias;
  final List<String> proficiencias;

  final String? rotuloSubclasse;
  final List<SubclassOption> subclasses;
  final int truques;

  final int magias;

  final Ability? atributoPreparo;
  final int espacosNivel1;
  final List<SpellOption> listaMagias;
  final List<EquipmentChoice> equipamento;
  final List<EquipmentItem> sempreIncluso;

  bool get temMagia => espacosNivel1 > 0;
  bool get escolheSubclasse => subclasses.isNotEmpty;
  bool get temPacote => equipamento.isNotEmpty;

  String nomePara({required bool feminino}) =>
      feminino ? (nomeF ?? nome) : nome;
}

class BackgroundOption {
  const BackgroundOption({
    required this.key,
    required this.nome,
    required this.descricao,
    required this.pericias,
    this.extras = const [],
    this.idiomasExtras = 0,
    this.srd = false,
  });

  final String key;
  final String nome;
  final String descricao;
  final List<String> pericias;
  final List<String> extras;
  final int idiomasExtras;
  final bool srd;
}

class SkillOption {
  const SkillOption(this.nome, this.atributo);

  final String nome;
  final Ability atributo;
}

String sinal(int v) => v >= 0 ? '+$v' : '$v';

int bonusDeEspecie(
  Ability a, {
  SpeciesOption? especie,
  SubspeciesOption? subespecie,
  Set<Ability> livres = const {},
}) =>
    (especie?.bonus[a] ?? 0) +
    (subespecie?.bonus[a] ?? 0) +
    (livres.contains(a) ? 1 : 0);

const custoCompra = {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9};
const limiteCompra = 27;
const arrayPadrao = [15, 14, 13, 12, 10, 8];

int? pontosGastos(Iterable<int?> valores) {
  var total = 0;
  for (final v in valores) {
    final custo = custoCompra[v];
    if (custo == null) return null;
    total += custo;
  }
  return total;
}

bool compraValida(Iterable<int?> valores) {
  final gastos = pontosGastos(valores);
  return gastos != null && gastos <= limiteCompra;
}

int hpNivel1({
  required int dadoDeVida,
  required int constituicao,
  int extraPorNivel = 0,
}) => math.max(1, dadoDeVida + modificador(constituicao) + extraPorNivel);

int calcularCA({
  required int destreza,
  required int constituicao,
  required int sabedoria,
  TipoArmadura? armadura,
  bool escudo = false,
  String? classeKey,
}) {
  final des = modificador(destreza);
  final int base = switch (armadura) {
    TipoArmadura.couro => 11 + des,
    TipoArmadura.escamas => 14 + math.min(des, 2),
    TipoArmadura.malha => 16,
    _ => switch (classeKey) {
      'srd_barbarian' => 10 + des + modificador(constituicao),
      'srd_monk' when !escudo => 10 + des + modificador(sabedoria),
      _ => 10 + des,
    },
  };
  return base + (escudo ? 2 : 0);
}

int limiteDeMagias(ClassOption classe, {required int valorAtributo}) {
  if (classe.atributoPreparo == null) return classe.magias;
  return math.max(1, modificador(valorAtributo) + 1);
}

int bonusPericia({required int valorAtributo, required bool proficiente}) =>
    modificador(valorAtributo) + (proficiente ? proficienciaNivel1 : 0);
