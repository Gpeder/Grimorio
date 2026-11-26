import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/view/grimoire/components/caixa_dados.dart';
import 'package:grimorio/view/grimoire/components/tela_detalhe.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/texto_srd.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

class DetalhesClasse extends StatefulWidget {
  const DetalhesClasse({super.key, required this.srdKey});

  final String srdKey;

  @override
  State<DetalhesClasse> createState() => _DetalhesClasseState();
}

class _DetalhesClasseState extends State<DetalhesClasse> {
  bool _todosNiveis = false;
  final _abertas = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  // subclasse nao tem subclasses, a api devolve 400 para key que nao e mae
  void _carregar() {
    final c = context.read<CompendioProvider>();
    c.carregarDetalhe(TipoSrd.classe, widget.srdKey).then((_) {
      final classe = c.detalhe<ClasseSrd>(TipoSrd.classe, widget.srdKey).item;
      if (classe != null && !classe.subclasse && mounted) {
        c.carregarSubclasses(widget.srdKey);
      }
    });
  }

  void _abrir(String key) => context.pushNamed(
    Rotas.nomeDetalheCompendio,
    pathParameters: {Rotas.tipo: TipoCompendio.classes, Rotas.key: key},
  );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaDetalhe<ClasseSrd>(
      estado: c.detalhe<ClasseSrd>(TipoSrd.classe, widget.srdKey),
      onTentarDeNovo: _carregar,
      builder: (_, classe) => _conteudo(classe, c.subclasses(classe.key)),
    );
  }

  Widget _conteudo(ClasseSrd c, EstadoLista<ClasseSrd> subclasses) {
    final textTheme = Theme.of(context).textTheme;
    final ultimoNivel = _todosNiveis ? 20 : 5;
    final proficiencias = c.textoDo(CaracteristicaSrd.proficiencias);
    final equipamento = c.textoDo(CaracteristicaSrd.equipamento);
    final dado = c.dadoDeVida;
    final pv1 = c.pvPrimeiroNivel;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoltarHeader(
              titulo: c.subclasse ? 'Subclasse' : 'Classe',
              direita: Text(
                'SRD 5.1',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  0,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // nome
                    Row(
                      children: [
                        ImageFrame(
                          imagePath: VisualSrd.classe(c.key),
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Text(
                            c.nome,
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!c.subclasse) ...[
                      const SizedBox(height: AppSpacing.medium),
                      CaixaDados(
                        dados: [
                          Dado(
                            'Dado de vida',
                            dado == null
                                ? TraducaoSrd.vazio
                                : dado.toLowerCase(),
                          ),
                          Dado(
                            'Salvaguardas',
                            c.salvaguardas.isEmpty
                                ? TraducaoSrd.vazio
                                : c.salvaguardas
                                      .map(TraducaoSrd.siglaAtributo)
                                      .join(', '),
                          ),
                          if (pv1 != null) Dado('PV no 1º nível', pv1),
                          if (c.pvProximosNiveis case final pv?)
                            Dado('PV nos próximos', pv),
                        ],
                      ),
                    ],
                    if (c.descricao.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.medium),
                      TextoSrd(c.descricao),
                    ],
                    if (!c.subclasse) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Progressão'),
                      _Progressao(classe: c, ate: ultimoNivel),
                      const SizedBox(height: AppSpacing.small),
                      TextButton(
                        onPressed: () =>
                            setState(() => _todosNiveis = !_todosNiveis),
                        child: Text(
                          _todosNiveis
                              ? 'Mostrar menos'
                              : 'Ver níveis 6 a 20 ›',
                        ),
                      ),
                    ],
                    if (c.deNivel.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Características'),
                      for (final f in c.deNivel)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: _Caracteristica(
                            caracteristica: f,
                            aberta: _abertas.contains(f.nome),
                            onTap: () => setState(() {
                              if (!_abertas.remove(f.nome)) {
                                _abertas.add(f.nome);
                              }
                            }),
                          ),
                        ),
                    ],
                    if (proficiencias != null) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Proficiências'),
                      TextoSrd(proficiencias),
                    ],
                    if (equipamento != null) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Equipamento inicial'),
                      TextoSrd(equipamento),
                    ],
                    if (!c.subclasse) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Subclasses'),
                      _Subclasses(estado: subclasses, onAbrir: _abrir),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Progressao extends StatelessWidget {
  const _Progressao({required this.classe, required this.ate});

  final ClasseSrd classe;
  final int ate;

  // 4 · 3 · 2, so os circulos com espaco
  static String _espacos(List<int> e) {
    final usados = [
      for (final n in e)
        if (n > 0) '$n',
    ];
    return usados.isEmpty ? TraducaoSrd.vazio : usados.join('·');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cabecalho = textTheme.labelSmall?.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.bold,
    );
    final celula = textTheme.bodyMedium?.copyWith(color: AppColors.onSurface);
    final apagado = AppColors.onSurface.withValues(alpha: 0.5);
    final espacos = classe.temEspacos;

    Widget celulaEspacos(String t) => Text(
      t,
      textAlign: TextAlign.end,
      style: celula?.copyWith(
        color: t == TraducaoSrd.vazio ? apagado : AppColors.mana,
        fontWeight: FontWeight.bold,
      ),
    );

    Widget linha(List<Widget> celulas, {Color? fundo}) => Container(
      color: fundo,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium - 4,
        vertical: AppSpacing.small + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 36, child: celulas[0]),
          SizedBox(width: 48, child: celulas[1]),
          Expanded(child: celulas[2]),
          if (espacos) SizedBox(width: 80, child: celulas[3]),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            linha([
              Text('NV', style: cabecalho),
              Text('PROF', style: cabecalho),
              Text('CARACTERÍSTICAS', style: cabecalho),
              Text('ESPAÇOS', style: cabecalho, textAlign: TextAlign.end),
            ]),
            for (var n = 1; n <= ate; n++)
              linha(
                [
                  Text(
                    '$nº',
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.alerta,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    classe.proficienciaNoNivel(n) ?? TraducaoSrd.vazio,
                    style: celula,
                  ),
                  Text(
                    switch (classe.noNivel(n)) {
                      final nomes when nomes.isEmpty => TraducaoSrd.vazio,
                      final nomes => nomes.join(', '),
                    },
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  celulaEspacos(_espacos(classe.espacosNoNivel(n))),
                ],
                fundo: n.isOdd
                    ? AppColors.alerta.withValues(alpha: 0.08)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _Caracteristica extends StatelessWidget {
  const _Caracteristica({
    required this.caracteristica,
    required this.aberta,
    required this.onTap,
  });

  final CaracteristicaSrd caracteristica;
  final bool aberta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final f = caracteristica;

    return CaixaOpcao(
      selecionado: aberta,
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    f.nome,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Nível ${f.niveis.join(', ')}',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.alerta,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  aberta ? Pixel.chevrondown : Pixel.chevronright,
                  size: 16,
                  color: AppColors.alerta,
                ),
              ],
            ),
            if (aberta) ...[
              const SizedBox(height: 6),
              TextoSrd(
                f.descricao,
                estilo: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Subclasses extends StatelessWidget {
  const _Subclasses({required this.estado, required this.onAbrir});

  final EstadoLista<ClasseSrd> estado;
  final ValueChanged<String> onAbrir;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (estado.carregamento != Carregamento.pronto) {
      // erro aqui so esconde a secao, o detalhe ja abriu
      return estado.carregamento == Carregamento.erro
          ? const SizedBox.shrink()
          : const EstadoCarregando(compacto: true);
    }
    if (estado.itens.isEmpty) {
      return Text(
        'Nenhuma subclasse no SRD.',
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        for (final s in estado.itens)
          SizedBox(
            width: 96,
            child: Column(
              children: [
                ImageFrame(
                  imagePath: VisualSrd.classe(s.key),
                  onTap: () => onAbrir(s.key),
                ),
                const SizedBox(height: 4),
                Text(
                  s.nome,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
