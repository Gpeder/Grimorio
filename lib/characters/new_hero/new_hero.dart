import 'package:flutter/material.dart';
import 'package:grimorio/characters/new_hero/components/passo_antecedente.dart';
import 'package:grimorio/characters/new_hero/components/passo_atributos.dart';
import 'package:grimorio/characters/new_hero/components/passo_classe.dart';
import 'package:grimorio/characters/new_hero/components/passo_equipamento.dart';
import 'package:grimorio/characters/new_hero/components/passo_especie.dart';
import 'package:grimorio/characters/new_hero/components/passo_footer.dart';
import 'package:grimorio/characters/new_hero/components/passo_header.dart';
import 'package:grimorio/characters/new_hero/components/passo_identidade.dart';
import 'package:grimorio/characters/new_hero/components/passo_magias.dart';
import 'package:grimorio/characters/new_hero/components/passo_pericias.dart';
import 'package:grimorio/characters/new_hero/components/passo_revisao.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/models/hero_options_mock.dart';
import 'package:grimorio/widgets/snack_bar.dart';

class NewHero extends StatefulWidget {
  const NewHero({super.key});

  @override
  State<NewHero> createState() => _NewHeroState();
}

class _NewHeroState extends State<NewHero> {
  static const _totalPassos = 9;
  static const _titulos = [
    'Espécie e sexo',
    'Escolha a classe',
    'Atributos',
    'Antecedente',
    'Perícias',
    'Equipamento inicial',
    'Magias',
    'Quem é seu herói?',
    'Tudo pronto?',
  ];

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

  bool _saindo = false;

  bool get _temAlgo => especie != null || classe != null;

  SubspeciesOption? get _subespecie =>
      especie?.subespecies.where((s) => s.key == subespecieKey).firstOrNull;

  SubclassOption? get _subclasse =>
      classe?.subclasses.where((s) => s.key == subclasseKey).firstOrNull;

  bool get _temMagia => classe?.temMagia ?? false;

  bool get _usaOuro => modoOuro || !(classe?.temPacote ?? true);

  int? _total(Ability a) {
    final valor = base[a];
    if (valor == null) return null;
    return valor +
        bonusDeEspecie(
          a,
          especie: especie,
          subespecie: _subespecie,
          livres: bonusMeioElfo,
        );
  }

  int _valor(Ability a) => _total(a) ?? 10;

  String? _rotuloBonus(Ability a) {
    final partes = [
      if (especie?.bonus[a] case final b?) '+$b ${especie!.nome}',
      if (_subespecie?.bonus[a] case final b?) '+$b ${_subespecie!.nome}',
      if (bonusMeioElfo.contains(a)) '+1 escolha',
    ];
    return partes.isEmpty ? null : partes.join(' ');
  }

  Map<String, String> get _periciasTravadas => {
    for (final p in especie?.pericias ?? const <String>[]) p: especie!.nome,
    for (final p in antecedente?.pericias ?? const <String>[])
      p: antecedente!.nome,
  };

  Set<String> get _proficientes => {
    ..._periciasTravadas.keys,
    ...pericias,
    ...periciasMeioElfo,
  };

  int _bonusPericia(String nome) {
    final pericia = periciasMock.firstWhere((p) => p.nome == nome);
    return bonusPericia(
      valorAtributo: _valor(pericia.atributo),
      proficiente: _proficientes.contains(nome),
    );
  }

  List<EquipmentItem> get _itens {
    final classe = this.classe;
    if (classe == null || _usaOuro) return const [];
    return [
      for (var i = 0; i < classe.equipamento.length; i++)
        ...classe.equipamento[i].opcoes.where((o) => o.key == equipamento[i]),
      ...classe.sempreIncluso,
    ];
  }

  TipoArmadura? get _armadura => _itens
      .map((i) => i.armadura)
      .where((a) => a != null && a != TipoArmadura.escudo)
      .firstOrNull;

  bool get _escudo => _itens.any((i) => i.armadura == TipoArmadura.escudo);

  int get _hp => hpNivel1(
    dadoDeVida: classe?.dadoDeVida ?? 0,
    constituicao: _valor(Ability.constituicao),
    extraPorNivel: _subespecie?.hpPorNivel ?? 0,
  );

  int get _ca => calcularCA(
    destreza: _valor(Ability.destreza),
    constituicao: _valor(Ability.constituicao),
    sabedoria: _valor(Ability.sabedoria),
    armadura: _armadura,
    escudo: _escudo,
    classeKey: classe?.key,
  );

  Ability? get _atributoMagia => classe?.atributoPreparo;

  int get _limiteMagias {
    final classe = this.classe;
    if (classe == null) return 0;
    return limiteDeMagias(
      classe,
      valorAtributo: _valor(classe.atributoPreparo ?? classe.principal),
    );
  }

  List<String> get _magiasTravadas => _subclasse?.magiasTravadas ?? const [];

  int get _qtdeIdiomas =>
      (especie?.idiomasExtras ?? 0) + (antecedente?.idiomasExtras ?? 0);

  String? get _pendencia {
    final especie = this.especie;
    final classe = this.classe;
    switch (passo) {
      case 1:
        if (especie == null) return 'Escolha uma espécie.';
        if (especie.subespecies.isNotEmpty && _subespecie == null) {
          return 'Escolha a sub-espécie.';
        }
      case 2:
        if (classe == null) return 'Escolha uma classe.';
        if (classe.escolheSubclasse && _subclasse == null) {
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
        if (_usaOuro) {
          if ((ouro ?? 0) <= 0) return 'Digite o ouro que você rolou.';
        } else if (equipamento.length != classe!.equipamento.length) {
          return 'Faça todas as escolhas de equipamento.';
        }
      case 7:
        if (truques.length != classe!.truques) {
          return 'Escolha ${classe.truques} truques.';
        }
        if (magias.length != _limiteMagias) {
          return 'Escolha $_limiteMagias magias de 1º círculo.';
        }
      case 8:
        if (nome.trim().length < 2) return 'Dê um nome ao herói.';
        if (alinhamento == null) return 'Escolha um alinhamento.';
    }
    return null;
  }

  void _alternar<T>(Set<T> conjunto, T valor) {
    setState(() {
      if (!conjunto.remove(valor)) conjunto.add(valor);
    });
  }

  void _escolherEspecie(SpeciesOption e) {
    if (e.key == especie?.key) return;
    setState(() {
      especie = e;
      // Com uma só sub-espécie, ela já vem escolhida.
      subespecieKey = e.subespecies.length == 1
          ? e.subespecies.first.key
          : null;
      bonusMeioElfo = {};
      periciasMeioElfo = {};
      pericias.removeAll(e.pericias);
      idiomas = {};
      retrato = e.retratoPara(feminino: feminino);
    });
  }

  void _mudarSexo(bool f) {
    setState(() {
      final padrao = especie?.retratoPara(feminino: feminino);
      feminino = f;
      if (retrato == null || retrato == padrao) {
        retrato = especie?.retratoPara(feminino: f);
      }
    });
  }

  void _escolherClasse(ClassOption c) {
    if (c.key == classe?.key) return;
    setState(() {
      classe = c;
      subclasseKey = null;
      pericias = {};
      equipamento = {};
      modoOuro = false;
      truques = {};
      magias = {};
    });
  }

  void _mudarModo(ModoAtributos m) {
    if (m == modo) return;
    setState(() {
      modo = m;
      base = {
        for (final a in Ability.values) a: m == ModoAtributos.compra ? 8 : null,
      };
    });
  }

  void _escolherAntecedente(BackgroundOption a) {
    if (a.key == antecedente?.key) return;
    setState(() {
      antecedente = a;
      pericias.removeAll(a.pericias);
      periciasMeioElfo.removeAll(a.pericias);
      idiomas = {};
    });
  }

  int _proximo(int p) => p + 1 == 7 && !_temMagia ? 8 : p + 1;
  int _anterior(int p) => p - 1 == 7 && !_temMagia ? 6 : p - 1;

  void _continuar() {
    if (passo == _totalPassos) {
      _sair(_montarPersonagem());
    } else {
      setState(() => passo = _proximo(passo));
    }
  }

  void _voltar() {
    if (passo == 1) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => passo = _anterior(passo));
    }
  }

  void _sair([Character? personagem]) {
    setState(() => _saindo = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(personagem);
    });
  }

  Future<void> _aoTentarSair(bool saiu, Object? _) async {
    if (saiu) return;
    if (passo > 1) {
      _voltar();
      return;
    }
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar herói?'),
        content: const Text('As escolhas feitas até aqui serão perdidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar editando'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (descartar ?? false) _sair();
  }

  void _avisar(String texto, {Snackbar tipo = Snackbar.info}) =>
      mostrarAviso(context, texto, tipo: tipo);

  void _mudarValor(Ability a, int? v) {
    if (modo == ModoAtributos.compra && (v ?? 8) > (base[a] ?? 8)) {
      final gastos = pontosGastos([
        for (final b in Ability.values) b == a ? v : base[b] ?? 8,
      ]);
      if (gastos == null || gastos > limiteCompra) {
        _avisar('Sem pontos disponíveis', tipo: Snackbar.erro);
        return;
      }
    }
    setState(() => base[a] = v);
  }

  Character _montarPersonagem() {
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
          subclasse: _subclasse?.nome,
        ),
      ],
      atributos: AbilityScores(
        forca: _valor(Ability.forca),
        destreza: _valor(Ability.destreza),
        constituicao: _valor(Ability.constituicao),
        inteligencia: _valor(Ability.inteligencia),
        sabedoria: _valor(Ability.sabedoria),
        carisma: _valor(Ability.carisma),
      ),
      xp: 0,
      hpMax: _hp,
      hpAtual: _hp,
      ca: _ca,
      deslocamentoM: especie.deslocamentoM,
      salvaguardas: classe.salvaguardas,
      pericias: _proficientes,
      espacosDeMagia: [
        if (classe.temMagia) SpellSlot(circulo: 1, total: classe.espacosNivel1),
      ],
      inventario: [for (final i in _itens) i.paraInventario()],
      moedas: Moedas(ouro: _usaOuro ? ouro ?? 0 : 0),
      ativo: true,
      antecedente: antecedente?.nome,
      alinhamento: alinhamento,
      idiomas: {...especie.idiomas, ...idiomas},
      historia: historia.trim(),
      magias: {...truques, ...magias, ..._magiasTravadas},
      magiasPreparadas: {...magias, ..._magiasTravadas},
    );
  }

  String get _explicacaoHp {
    final classe = this.classe!;
    final extra = _subespecie?.hpPorNivel ?? 0;
    final con = sinal(modificador(_valor(Ability.constituicao)));
    return 'dado de vida cheio (${classe.dadoDeVida}) + CON ($con)'
        '${extra > 0 ? ' + ${_subespecie!.nome} (+$extra)' : ''}'
        ' = $_hp. Sem rolagem.';
  }

  String get _explicacaoCa {
    final des = sinal(modificador(_valor(Ability.destreza)));
    final base = switch (_armadura) {
      TipoArmadura.couro => 'armadura de couro 11 + DES ($des)',
      TipoArmadura.escamas => 'cota de escamas 14 + DES (máx. 2)',
      TipoArmadura.malha => 'cota de malha 16',
      _ => switch (classe?.key) {
        'srd_barbarian' =>
          'sem armadura 10 + DES ($des) + CON '
              '(${sinal(modificador(_valor(Ability.constituicao)))})',
        'srd_monk' when !_escudo =>
          'sem armadura 10 + DES ($des) + SAB '
              '(${sinal(modificador(_valor(Ability.sabedoria)))})',
        _ => 'sem armadura 10 + DES ($des)',
      },
    };
    return '$base${_escudo ? ' + escudo 2' : ''} = $_ca.';
  }

  Widget _conteudo() {
    final especie = this.especie;
    final classe = this.classe;

    return switch (passo) {
      1 => PassoEspecie(
        especie: especie,
        subespecieKey: subespecieKey,
        feminino: feminino,
        onEspecie: _escolherEspecie,
        onSubespecie: (k) => setState(() => subespecieKey = k),
        onFeminino: _mudarSexo,
      ),
      2 => PassoClasse(
        classe: classe,
        subclasseKey: subclasseKey,
        onClasse: _escolherClasse,
        onSubclasse: (k) => setState(() => subclasseKey = k),
      ),
      3 => PassoAtributos(
        modo: modo,
        base: base,
        total: _total,
        rotuloBonus: _rotuloBonus,
        principal: classe?.principal,
        dica: classe == null
            ? null
            : 'Dica: ${classe.nome} usa '
                  '${nomeAtributo[_atributoMagia ?? classe.principal]} '
                  '${_atributoMagia != null ? 'para magias' : 'como atributo principal'}.',
        bonusLivres: especie?.bonusLivres ?? 0,
        escolhidosLivres: bonusMeioElfo,
        onModo: _mudarModo,
        onValor: _mudarValor,
        onBonusLivre: (a) => _alternar(bonusMeioElfo, a),
      ),
      4 => PassoAntecedente(
        antecedente: antecedente,
        onAntecedente: _escolherAntecedente,
        onCriar: () => _avisar('Em breve'),
      ),
      5 => PassoPericias(
        classe: classe!,
        travadas: _periciasTravadas,
        escolhidas: pericias,
        livres: especie?.periciasLivres ?? 0,
        escolhidasLivres: periciasMeioElfo,
        bonus: _bonusPericia,
        outras: [
          ...classe.proficiencias,
          (especie?.idiomas ?? const []).join(' · '),
        ],
        onPericia: (p) => _alternar(pericias, p),
        onPericiaLivre: (p) => _alternar(periciasMeioElfo, p),
      ),
      6 => PassoEquipamento(
        classe: classe!,
        modoOuro: _usaOuro,
        escolhas: equipamento,
        ouro: ouro,
        onModoOuro: (v) => setState(() => modoOuro = v),
        onEscolha: (i, k) => setState(() => equipamento[i] = k),
        onOuro: (v) => setState(() => ouro = v),
      ),
      7 => PassoMagias(
        classe: classe!,
        travadas: _magiasTravadas,
        truques: truques,
        magias: magias,
        limiteMagias: _limiteMagias,
        origemLimite: switch (_atributoMagia) {
          final a? => '${a.sigla} ${sinal(modificador(_valor(a)))} e nível 1',
          null => 'tabela do ${classe.nome}',
        },
        onTruque: (k) => _alternar(truques, k),
        onMagia: (k) => _alternar(magias, k),
      ),
      8 => PassoIdentidade(
        nome: nome,
        retrato: retrato,
        feminino: feminino,
        alinhamento: alinhamento,
        idiomas: idiomas,
        idiomasDisponiveis: [
          for (final i in idiomasMock)
            if (!(especie?.idiomas.contains(i) ?? false)) i,
        ],
        qtdeIdiomas: _qtdeIdiomas,
        origemIdiomas: [
          if ((especie?.idiomasExtras ?? 0) > 0) especie!.nome,
          if ((antecedente?.idiomasExtras ?? 0) > 0) antecedente!.nome,
        ].join(' e '),
        historia: historia,
        onNome: (v) => setState(() => nome = v),
        onFeminino: _mudarSexo,
        onRetrato: (r) => setState(() => retrato = r),
        onAlinhamento: (a) => setState(() => alinhamento = a),
        onIdioma: (i) => _alternar(idiomas, i),
        onHistoria: (v) => historia = v,
      ),
      _ => _revisao(),
    };
  }

  Widget _revisao() {
    final classe = this.classe!;
    final subclasse = _subclasse;
    final itens = _itens;
    final totalMagias = magias.length + _magiasTravadas.length;

    return PassoRevisao(
      personagem: _montarPersonagem(),
      linhaEspecieClasse:
          '${especie!.nomePara(feminino: feminino)} · '
          '${classe.nomePara(feminino: feminino)}'
          '${subclasse == null ? '' : ' (${subclasse.nome})'}',
      linhaAntecedente: '${antecedente!.nome} · $alinhamento · Nível 1',
      explicacaoHp: _explicacaoHp,
      explicacaoCa: _explicacaoCa,
      pericias: {
        for (final p in periciasMock)
          if (_proficientes.contains(p.nome)) p.nome: _bonusPericia(p.nome),
      },
      imagensItens: [for (final i in itens) i.imagem],
      resumoItens: [
        if (itens.isNotEmpty) '${itens.length} itens',
        if (_usaOuro) '${ouro ?? 0} po',
        if (classe.temMagia) ...[
          '${truques.length} truques',
          '$totalMagias magias',
        ],
      ].join(' · '),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Character>(
      canPop: _saindo || (passo == 1 && !_temAlgo),
      onPopInvokedWithResult: _aoTentarSair,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              PassoHeader(
                passo: passo,
                total: _totalPassos,
                titulo: _titulos[passo - 1],
                onVoltar: _voltar,
                onSalvarRascunho: () => _avisar('Rascunho salvo'),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  layoutBuilder: (atual, anteriores) => Stack(
                    fit: StackFit.expand,
                    children: [...anteriores, ?atual],
                  ),
                  child: KeyedSubtree(key: ValueKey(passo), child: _conteudo()),
                ),
              ),
              PassoFooter(
                primeiro: passo == 1,
                ultimo: passo == _totalPassos,
                pendencia: _pendencia,
                onVoltar: _voltar,
                onContinuar: _continuar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
