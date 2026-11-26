import 'dart:math' as math;

import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/hero_options.dart';
import 'package:grimorio/model/hero_options_mock.dart';

enum ModoAtributos { rolagem, compra, array }

// rascunho do heroi passo a passo
class GerenciadorCriacao {
  static const totalPassos = 9;

  int passo = 1;

  SpeciesOption? especie;
  String? subespecieKey;
  bool feminino = true;

  ClassOption? classe;
  String? subclasseKey;

  ModoAtributos modo = ModoAtributos.rolagem;
  Map<Ability, int?> base = {for (final a in Ability.values) a: null};
  Set<Ability> bonusMeioElfo = {};

  BackgroundOption? antecedente;

  Set<String> pericias = {};
  Set<String> periciasMeioElfo = {};

  bool modoOuro = false;
  Map<int, String> equipamento = {};
  int? ouro;

  Set<String> truques = {};
  Set<String> magias = {};

  String nome = '';
  String? retrato;
  String? alinhamento;
  Set<String> idiomas = {};
  String historia = '';

  // regras

  static int bonusDeEspecie(
    Ability a, {
    SpeciesOption? especie,
    SubspeciesOption? subespecie,
    Set<Ability> livres = const {},
  }) =>
      (especie?.bonus[a] ?? 0) +
      (subespecie?.bonus[a] ?? 0) +
      (livres.contains(a) ? 1 : 0);

  // null se algum valor sai da tabela
  static int? pontosGastos(Iterable<int?> valores) {
    var total = 0;
    for (final v in valores) {
      final custo = custoCompra[v];
      if (custo == null) return null;
      total += custo;
    }
    return total;
  }

  static bool compraValida(Iterable<int?> valores) {
    final gastos = pontosGastos(valores);
    return gastos != null && gastos <= limiteCompra;
  }

  static int hpNivel1({
    required int dadoDeVida,
    required int constituicao,
    int extraPorNivel = 0,
  }) => math.max(1, dadoDeVida + modificador(constituicao) + extraPorNivel);

  static int calcularCA({
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
      // barbaro e monge somam outro atributo
      _ => switch (classeKey) {
        'srd_barbarian' => 10 + des + modificador(constituicao),
        'srd_monk' when !escudo => 10 + des + modificador(sabedoria),
        _ => 10 + des,
      },
    };
    return base + (escudo ? 2 : 0);
  }

  static int limiteDeMagias(ClassOption classe, {required int valorAtributo}) {
    if (classe.atributoPreparo == null) return classe.magias;
    return math.max(1, modificador(valorAtributo) + 1);
  }

  static int bonusPericia({
    required int valorAtributo,
    required bool proficiente,
  }) => modificador(valorAtributo) + (proficiente ? proficienciaNivel1 : 0);

  // valores do rascunho

  bool get temAlgo => especie != null || classe != null;

  SubspeciesOption? get subespecie =>
      especie?.subespecies.where((s) => s.key == subespecieKey).firstOrNull;

  SubclassOption? get subclasse =>
      classe?.subclasses.where((s) => s.key == subclasseKey).firstOrNull;

  bool get temMagia => classe?.temMagia ?? false;

  bool get usaOuro => modoOuro || !(classe?.temPacote ?? true);

  int? total(Ability a) {
    final valor = base[a];
    if (valor == null) return null;
    return valor +
        bonusDeEspecie(
          a,
          especie: especie,
          subespecie: subespecie,
          livres: bonusMeioElfo,
        );
  }

  int valor(Ability a) => total(a) ?? 10;

  String? rotuloBonus(Ability a) {
    final partes = [
      if (especie?.bonus[a] case final b?) '+$b ${especie!.nome}',
      if (subespecie?.bonus[a] case final b?) '+$b ${subespecie!.nome}',
      if (bonusMeioElfo.contains(a)) '+1 escolha',
    ];
    return partes.isEmpty ? null : partes.join(' ');
  }

  Map<String, String> get periciasTravadas => {
    for (final p in especie?.pericias ?? const <String>[]) p: especie!.nome,
    for (final p in antecedente?.pericias ?? const <String>[])
      p: antecedente!.nome,
  };

  Set<String> get proficientes => {
    ...periciasTravadas.keys,
    ...pericias,
    ...periciasMeioElfo,
  };

  int bonusPericiaDe(String nome) {
    final pericia = periciasMock.firstWhere((p) => p.nome == nome);
    return bonusPericia(
      valorAtributo: valor(pericia.atributo),
      proficiente: proficientes.contains(nome),
    );
  }

  List<EquipmentItem> get itens {
    final classe = this.classe;
    if (classe == null || usaOuro) return const [];
    return [
      for (var i = 0; i < classe.equipamento.length; i++)
        ...classe.equipamento[i].opcoes.where((o) => o.key == equipamento[i]),
      ...classe.sempreIncluso,
    ];
  }

  TipoArmadura? get armadura => itens
      .map((i) => i.armadura)
      .where((a) => a != null && a != TipoArmadura.escudo)
      .firstOrNull;

  bool get escudo => itens.any((i) => i.armadura == TipoArmadura.escudo);

  int get hp => hpNivel1(
    dadoDeVida: classe?.dadoDeVida ?? 0,
    constituicao: valor(Ability.constituicao),
    extraPorNivel: subespecie?.hpPorNivel ?? 0,
  );

  int get ca => calcularCA(
    destreza: valor(Ability.destreza),
    constituicao: valor(Ability.constituicao),
    sabedoria: valor(Ability.sabedoria),
    armadura: armadura,
    escudo: escudo,
    classeKey: classe?.key,
  );

  Ability? get atributoMagia => classe?.atributoPreparo;

  int get limiteMagias {
    final classe = this.classe;
    if (classe == null) return 0;
    return limiteDeMagias(
      classe,
      valorAtributo: valor(classe.atributoPreparo ?? classe.principal),
    );
  }

  List<String> get magiasTravadas => subclasse?.magiasTravadas ?? const [];

  int get qtdeIdiomas =>
      (especie?.idiomasExtras ?? 0) + (antecedente?.idiomasExtras ?? 0);

  // o que falta no passo atual
  String? get pendencia {
    final especie = this.especie;
    final classe = this.classe;
    switch (passo) {
      case 1:
        if (especie == null) return 'Escolha uma espécie.';
        if (especie.subespecies.isNotEmpty && subespecie == null) {
          return 'Escolha a sub-espécie.';
        }
      case 2:
        if (classe == null) return 'Escolha uma classe.';
        if (classe.escolheSubclasse && subclasse == null) {
          return 'Escolha ${classe.rotuloSubclasse!.toLowerCase()}.';
        }
      case 3:
        final valores = base.values;
        if (valores.any((v) => v == null)) return 'Preencha os 6 atributos.';
        switch (modo) {
          case ModoAtributos.rolagem:
            if (valores.any((v) => v! < 3 || v > 18)) {
              return 'Cada rolagem vai de 3 a 18.';
            }
          case ModoAtributos.compra:
            if (!compraValida(valores)) {
              return 'A compra passou de $limiteCompra pontos.';
            }
          case ModoAtributos.array:
            if (valores.toSet().length != valores.length) {
              return 'Cada valor do array só pode ser usado uma vez.';
            }
        }
        final livres = especie?.bonusLivres ?? 0;
        if (bonusMeioElfo.length != livres) {
          return 'Escolha $livres atributos para o +1.';
        }
      case 4:
        if (antecedente == null) return 'Escolha um antecedente.';
      case 5:
        final faltam = classe!.qtdePericias - pericias.length;
        if (faltam != 0) return 'Escolha $faltam perícia(s) da classe.';
        final livres = (especie?.periciasLivres ?? 0) - periciasMeioElfo.length;
        if (livres != 0) return 'Escolha $livres perícia(s) livre(s).';
      case 6:
        if (usaOuro) {
          if ((ouro ?? 0) <= 0) return 'Digite o ouro que você rolou.';
        } else if (equipamento.length != classe!.equipamento.length) {
          return 'Faça todas as escolhas de equipamento.';
        }
      case 7:
        if (truques.length != classe!.truques) {
          return 'Escolha ${classe.truques} truques.';
        }
        if (magias.length != limiteMagias) {
          return 'Escolha $limiteMagias magias de 1º círculo.';
        }
      case 8:
        if (nome.trim().length < 2) return 'Dê um nome ao herói.';
        if (alinhamento == null) return 'Escolha um alinhamento.';
    }
    return null;
  }

  // escolhas

  void alternar<T>(Set<T> conjunto, T valor) {
    if (!conjunto.remove(valor)) conjunto.add(valor);
  }

  void escolherEspecie(SpeciesOption e) {
    if (e.key == especie?.key) return;
    especie = e;
    // uma sub-especie so ja vem escolhida
    subespecieKey = e.subespecies.length == 1 ? e.subespecies.first.key : null;
    bonusMeioElfo = {};
    periciasMeioElfo = {};
    pericias.removeAll(e.pericias);
    idiomas = {};
    retrato = e.retratoPara(feminino: feminino);
  }

  // troca o retrato so se ainda for o padrao
  void mudarSexo(bool f) {
    final padrao = especie?.retratoPara(feminino: feminino);
    feminino = f;
    if (retrato == null || retrato == padrao) {
      retrato = especie?.retratoPara(feminino: f);
    }
  }

  void escolherClasse(ClassOption c) {
    if (c.key == classe?.key) return;
    classe = c;
    subclasseKey = null;
    pericias = {};
    equipamento = {};
    modoOuro = false;
    truques = {};
    magias = {};
  }

  void mudarModo(ModoAtributos m) {
    if (m == modo) return;
    modo = m;
    base = {
      for (final a in Ability.values) a: m == ModoAtributos.compra ? 8 : null,
    };
  }

  void escolherAntecedente(BackgroundOption a) {
    if (a.key == antecedente?.key) return;
    antecedente = a;
    pericias.removeAll(a.pericias);
    periciasMeioElfo.removeAll(a.pericias);
    idiomas = {};
  }

  // false quando a compra passa do limite
  bool mudarValor(Ability a, int? v) {
    if (modo == ModoAtributos.compra && (v ?? 8) > (base[a] ?? 8)) {
      final gastos = pontosGastos([
        for (final b in Ability.values) b == a ? v : base[b] ?? 8,
      ]);
      if (gastos == null || gastos > limiteCompra) return false;
    }
    base[a] = v;
    return true;
  }

  // navegacao, pula magias se a classe nao tem

  bool get ultimoPasso => passo == totalPassos;

  void avancar() => passo = passo + 1 == 7 && !temMagia ? 8 : passo + 1;

  void recuar() => passo = passo - 1 == 7 && !temMagia ? 6 : passo - 1;

  // heroi pronto

  Character montarPersonagem() {
    final classe = this.classe!;
    final especie = this.especie!;
    return Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome.trim(),
      retrato: retrato ?? especie.retratoPara(feminino: feminino),
      especie: especie.nomePara(feminino: feminino),
      classes: [
        CharacterClass(
          apiKey: classe.key,
          nome: classe.nomePara(feminino: feminino),
          nivel: 1,
          dadoDeVida: classe.dadoDeVida,
          subclasse: subclasse?.nome,
        ),
      ],
      atributos: AbilityScores(
        forca: valor(Ability.forca),
        destreza: valor(Ability.destreza),
        constituicao: valor(Ability.constituicao),
        inteligencia: valor(Ability.inteligencia),
        sabedoria: valor(Ability.sabedoria),
        carisma: valor(Ability.carisma),
      ),
      xp: 0,
      hpMax: hp,
      hpAtual: hp,
      ca: ca,
      deslocamentoM: especie.deslocamentoM,
      salvaguardas: classe.salvaguardas,
      pericias: proficientes,
      espacosDeMagia: [
        if (classe.temMagia) SpellSlot(circulo: 1, total: classe.espacosNivel1),
      ],
      inventario: [for (final i in itens) i.paraInventario()],
      moedas: Moedas(ouro: usaOuro ? ouro ?? 0 : 0),
      ativo: true,
      antecedente: antecedente?.nome,
      alinhamento: alinhamento,
      idiomas: {...especie.idiomas, ...idiomas},
      historia: historia.trim(),
      magias: {...truques, ...magias, ...magiasTravadas},
      magiasPreparadas: {...magias, ...magiasTravadas},
    );
  }

  String get explicacaoHp {
    final classe = this.classe!;
    final extra = subespecie?.hpPorNivel ?? 0;
    final con = sinal(modificador(valor(Ability.constituicao)));
    return 'dado de vida cheio (${classe.dadoDeVida}) + CON ($con)'
        '${extra > 0 ? ' + ${subespecie!.nome} (+$extra)' : ''}'
        ' = $hp. Sem rolagem.';
  }

  String get explicacaoCa {
    final des = sinal(modificador(valor(Ability.destreza)));
    final base = switch (armadura) {
      TipoArmadura.couro => 'armadura de couro 11 + DES ($des)',
      TipoArmadura.escamas => 'cota de escamas 14 + DES (máx. 2)',
      TipoArmadura.malha => 'cota de malha 16',
      _ => switch (classe?.key) {
        'srd_barbarian' =>
          'sem armadura 10 + DES ($des) + CON '
              '(${sinal(modificador(valor(Ability.constituicao)))})',
        'srd_monk' when !escudo =>
          'sem armadura 10 + DES ($des) + SAB '
              '(${sinal(modificador(valor(Ability.sabedoria)))})',
        _ => 'sem armadura 10 + DES ($des)',
      },
    };
    return '$base${escudo ? ' + escudo 2' : ''} = $ca.';
  }
}
