import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/controller/characters/gerenciador_criacao.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_antecedente.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_atributos.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_classe.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_equipamento.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_especie.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_footer.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_header.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_identidade.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_magias.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_pericias.dart';
import 'package:grimorio/view/characters/new_hero/components/passo_revisao.dart';
import 'package:grimorio/widgets/snack_bar.dart';

class NewHero extends StatefulWidget {
  const NewHero({super.key});

  @override
  State<NewHero> createState() => _NewHeroState();
}

class _NewHeroState extends State<NewHero> {
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

  final _criacao = GerenciadorCriacao();

  bool _saindo = false;

  void _alternar<T>(Set<T> conjunto, T valor) =>
      setState(() => _criacao.alternar(conjunto, valor));

  void _continuar() {
    if (_criacao.ultimoPasso) {
      _sair(_criacao.montarPersonagem());
    } else {
      setState(_criacao.avancar);
    }
  }

  void _voltar() {
    if (_criacao.passo == 1) {
      Navigator.of(context).maybePop();
    } else {
      setState(_criacao.recuar);
    }
  }

  void _sair([Personagem? personagem]) {
    setState(() => _saindo = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop(personagem);
    });
  }

  Future<void> _aoTentarSair(bool saiu, Object? _) async {
    if (saiu) return;
    if (_criacao.passo > 1) {
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

  void _mudarValor(Atributo a, int? v) {
    var mudou = false;
    setState(() => mudou = _criacao.mudarValor(a, v));
    if (!mudou) _avisar('Sem pontos disponíveis', tipo: Snackbar.erro);
  }

  Widget _conteudo() {
    final c = _criacao;
    final especie = c.especie;
    final classe = c.classe;
    final atributoMagia = c.atributoMagia;

    return switch (c.passo) {
      1 => PassoEspecie(
        especies: especiesMock,
        especie: especie,
        subespecieKey: c.subespecieKey,
        feminino: c.feminino,
        onEspecie: (e) => setState(() => c.escolherEspecie(e)),
        onSubespecie: (k) => setState(() => c.subespecieKey = k),
        onFeminino: (f) => setState(() => c.mudarSexo(f)),
      ),
      2 => PassoClasse(
        classes: classesMock,
        classe: classe,
        subclasseKey: c.subclasseKey,
        onClasse: (k) => setState(() => c.escolherClasse(k)),
        onSubclasse: (k) => setState(() => c.subclasseKey = k),
      ),
      3 => PassoAtributos(
        modo: c.modo,
        base: c.base,
        total: c.total,
        rotuloBonus: c.rotuloBonus,
        principal: classe?.principal,
        dica: classe == null
            ? null
            : 'Dica: ${classe.nome} usa '
                  '${nomeAtributo[atributoMagia ?? classe.principal]} '
                  '${atributoMagia != null ? 'para magias' : 'como atributo principal'}.',
        bonusLivres: especie?.bonusLivres ?? 0,
        escolhidosLivres: c.bonusMeioElfo,
        onModo: (m) => setState(() => c.mudarModo(m)),
        onValor: _mudarValor,
        onBonusLivre: (a) => _alternar(c.bonusMeioElfo, a),
      ),
      4 => PassoAntecedente(
        antecedentes: antecedentesMock,
        antecedente: c.antecedente,
        onAntecedente: (a) => setState(() => c.escolherAntecedente(a)),
        onCriar: () => _avisar('Em breve'),
      ),
      5 => PassoPericias(
        pericias: periciasMock,
        classe: classe!,
        travadas: c.periciasTravadas,
        escolhidas: c.pericias,
        livres: especie?.periciasLivres ?? 0,
        escolhidasLivres: c.periciasMeioElfo,
        bonus: c.bonusPericiaDe,
        outras: [
          ...classe.proficiencias,
          (especie?.idiomas ?? const []).join(' · '),
        ],
        onPericia: (p) => _alternar(c.pericias, p),
        onPericiaLivre: (p) => _alternar(c.periciasMeioElfo, p),
      ),
      6 => PassoEquipamento(
        classe: classe!,
        modoOuro: c.usaOuro,
        escolhas: c.equipamento,
        ouro: c.ouro,
        onModoOuro: (v) => setState(() => c.modoOuro = v),
        onEscolha: (i, k) => setState(() => c.equipamento[i] = k),
        onOuro: (v) => setState(() => c.ouro = v),
      ),
      7 => PassoMagias(
        classe: classe!,
        travadas: c.magiasTravadas,
        truques: c.truques,
        magias: c.magias,
        limiteMagias: c.limiteMagias,
        origemLimite: switch (atributoMagia) {
          final a? => '${a.sigla} ${sinal(modificador(c.valor(a)))} e nível 1',
          null => 'tabela do ${classe.nome}',
        },
        onTruque: (k) => _alternar(c.truques, k),
        onMagia: (k) => _alternar(c.magias, k),
      ),
      8 => PassoIdentidade(
        nome: c.nome,
        retrato: c.retrato,
        feminino: c.feminino,
        alinhamento: c.alinhamento,
        alinhamentos: alinhamentosMock,
        idiomas: c.idiomas,
        idiomasDisponiveis: [
          for (final i in idiomasMock)
            if (!(especie?.idiomas.contains(i) ?? false)) i,
        ],
        qtdeIdiomas: c.qtdeIdiomas,
        origemIdiomas: [
          if ((especie?.idiomasExtras ?? 0) > 0) especie!.nome,
          if ((c.antecedente?.idiomasExtras ?? 0) > 0) c.antecedente!.nome,
        ].join(' e '),
        historia: c.historia,
        onNome: (v) => setState(() => c.nome = v),
        onFeminino: (f) => setState(() => c.mudarSexo(f)),
        onRetrato: (r) => setState(() => c.retrato = r),
        onAlinhamento: (a) => setState(() => c.alinhamento = a),
        onIdioma: (i) => _alternar(c.idiomas, i),
        onHistoria: (v) => c.historia = v,
      ),
      _ => _revisao(),
    };
  }

  Widget _revisao() {
    final c = _criacao;
    final classe = c.classe!;
    final subclasse = c.subclasse;
    final itens = c.itens;
    final totalMagias = c.magias.length + c.magiasTravadas.length;

    return PassoRevisao(
      personagem: c.montarPersonagem(),
      linhaEspecieClasse:
          '${c.especie!.nomePara(feminino: c.feminino)} · '
          '${classe.nomePara(feminino: c.feminino)}'
          '${subclasse == null ? '' : ' (${subclasse.nome})'}',
      linhaAntecedente: '${c.antecedente!.nome} · ${c.alinhamento} · Nível 1',
      explicacaoHp: c.explicacaoHp,
      explicacaoCa: c.explicacaoCa,
      pericias: {
        for (final p in periciasMock)
          if (c.proficientes.contains(p.nome)) p.nome: c.bonusPericiaDe(p.nome),
      },
      imagensItens: [for (final i in itens) i.imagem],
      resumoItens: [
        if (itens.isNotEmpty) '${itens.length} itens',
        if (c.usaOuro) '${c.ouro ?? 0} po',
        if (classe.temMagia) ...[
          '${c.truques.length} truques',
          '$totalMagias magias',
        ],
      ].join(' · '),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passo = _criacao.passo;

    return PopScope<Personagem>(
      canPop: _saindo || (passo == 1 && !_criacao.temAlgo),
      onPopInvokedWithResult: _aoTentarSair,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              PassoHeader(
                passo: passo,
                total: GerenciadorCriacao.totalPassos,
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
                ultimo: _criacao.ultimoPasso,
                pendencia: _criacao.pendencia,
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
