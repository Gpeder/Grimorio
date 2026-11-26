import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/grimoire/components/caixa_dados.dart';
import 'package:grimorio/grimoire/components/tela_lista.dart';
import 'package:grimorio/models/grimoire_mock.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/widgets/image_frame.dart';

class ClasseDetalhe extends StatefulWidget {
  const ClasseDetalhe({super.key, required this.classe});

  final ClassOption classe;

  @override
  State<ClasseDetalhe> createState() => _ClasseDetalheState();
}

class _ClasseDetalheState extends State<ClasseDetalhe> {
  bool _todosNiveis = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = widget.classe;
    final papel = papelDaClasse[c.key];
    final doMock = {for (final s in c.subclasses) s.imagem};
    final subclasses = <(String, String, bool)>[
      for (final s in c.subclasses) (s.nome, s.imagem, false),
      for (final (nome, imagem)
          in subclassesLivro[c.key] ?? const <(String, String)>[])
        if (!doMock.contains(imagem)) (nome, imagem, true),
    ];
    final ultimoNivel = _todosNiveis ? 20 : 5;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarraVoltar(
              titulo: 'Classe',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ImageFrame(imagePath: c.imagem, width: 80, height: 80),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.nome,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                [
                                  ?papel,
                                  nomeAtributo[c.principal]!,
                                ].join(' · '),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.alerta,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CaixaDados(
                      dados: [
                        Dado('Dado de vida', 'd${c.dadoDeVida}'),
                        Dado(
                          'Salvaguardas',
                          [for (final a in c.salvaguardas) a.sigla].join(', '),
                        ),
                        Dado('Armaduras e armas', c.proficiencias.join(', ')),
                        Dado(
                          'Perícias',
                          c.pericias.isEmpty
                              ? '${c.qtdePericias} à escolha'
                              : '${c.qtdePericias} de ${c.pericias.length}',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),
                    const TituloSecao('Progressão'),
                    _Progressao(classeKey: c.key, ate: ultimoNivel),
                    const SizedBox(height: AppSpacing.small),
                    TextButton(
                      onPressed: () =>
                          setState(() => _todosNiveis = !_todosNiveis),
                      child: Text(
                        _todosNiveis ? 'Mostrar menos' : 'Ver níveis 6 a 20 ›',
                      ),
                    ),
                    if (subclasses.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.large),
                      TituloSecao(
                        c.rotuloSubclasse == null
                            ? 'Subclasses'
                            : _capitalizar(c.rotuloSubclasse!),
                      ),
                      _GradeSubclasses(subclasses: subclasses),
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

  static String _capitalizar(String s) => s[0] + s.substring(1).toLowerCase();
}

class _Progressao extends StatelessWidget {
  const _Progressao({required this.classeKey, required this.ate});

  final String classeKey;
  final int ate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cabecalho = textTheme.labelSmall?.copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.bold,
    );
    final celula = textTheme.bodyMedium?.copyWith(color: AppColors.onSurface);

    Widget linha(List<Widget> celulas, {Color? fundo}) => Container(
      color: fundo,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium - 4,
        vertical: AppSpacing.small + 2,
      ),
      child: Row(
        children: [
          SizedBox(width: 48, child: celulas[0]),
          SizedBox(width: 64, child: celulas[1]),
          Expanded(child: celulas[2]),
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
              Text('ESPAÇOS DE MAGIA', style: cabecalho),
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
                  Text('+${proficienciaNoNivel(n)}', style: celula),
                  Text(
                    espacosNoNivel(classeKey, n),
                    style: celula?.copyWith(
                      color: espacosNoNivel(classeKey, n) == '—'
                          ? AppColors.onSurface.withValues(alpha: 0.5)
                          : AppColors.mana,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

class _GradeSubclasses extends StatelessWidget {
  const _GradeSubclasses({required this.subclasses});

  // (nome, imagem, só no livro)
  final List<(String, String, bool)> subclasses;

  static const _colunas = 4;

  @override
  Widget build(BuildContext context) {
    final linhas = (subclasses.length / _colunas).ceil();

    return Column(
      spacing: AppSpacing.medium - 4,
      children: [
        for (var l = 0; l < linhas; l++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.small,
            children: [
              for (var c = 0; c < _colunas; c++)
                Expanded(
                  child: switch (l * _colunas + c) {
                    final i when i < subclasses.length => _Subclasse(
                      subclasses[i],
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _Subclasse extends StatelessWidget {
  const _Subclasse(this.dados);

  final (String, String, bool) dados;

  @override
  Widget build(BuildContext context) {
    final (nome, imagem, livro) = dados;

    return Column(
      children: [
        ImageFrame(imagePath: imagem),
        const SizedBox(height: 4),
        Text(
          nome,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (livro) ...[
          const SizedBox(height: 2),
          const Etiqueta('Livro', pequena: true),
        ],
      ],
    );
  }
}
