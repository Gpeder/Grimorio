import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/caixa_opcao.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/characters/new_hero/components/linha_check.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/widgets/image_frame.dart';

class PassoMagias extends StatelessWidget {
  const PassoMagias({
    super.key,
    required this.classe,
    required this.travadas,
    required this.truques,
    required this.magias,
    required this.limiteMagias,
    required this.origemLimite,
    required this.onTruque,
    required this.onMagia,
  });

  final ClassOption classe;

  final List<String> travadas;
  final Set<String> truques;
  final Set<String> magias;
  final int limiteMagias;

  final String origemLimite;
  final ValueChanged<String> onTruque;
  final ValueChanged<String> onMagia;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final listaTruques = [
      for (final m in classe.listaMagias)
        if (m.circulo == 0) m,
    ];
    final listaMagias = [
      for (final m in classe.listaMagias)
        if (m.circulo == 1) m,
    ];
    final secao = textTheme.titleSmall?.copyWith(
      color: AppColors.alerta,
      fontWeight: FontWeight.bold,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.small,
              children: [
                Expanded(
                  child: _Contador(
                    rotulo: 'TRUQUES',
                    atual: truques.length,
                    total: classe.truques,
                    origem: 'nível 1',
                  ),
                ),
                Expanded(
                  child: _Contador(
                    rotulo: classe.atributoPreparo == null
                        ? 'CONHECIDAS'
                        : 'PREPARADAS',
                    atual: magias.length,
                    total: limiteMagias,
                    origem: origemLimite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text('Truques', style: secao),
          for (final m in listaTruques)
            _Linha(
              magia: m,
              marcado: truques.contains(m.key),
              onChanged:
                  truques.contains(m.key) || truques.length < classe.truques
                  ? (_) => onTruque(m.key)
                  : null,
            ),
          const SizedBox(height: AppSpacing.medium),
          Text('1º círculo', style: secao),
          for (final m in listaMagias)
            _Linha(
              magia: m,
              marcado: travadas.contains(m.key) || magias.contains(m.key),
              travado: travadas.contains(m.key),
              onChanged: magias.contains(m.key) || magias.length < limiteMagias
                  ? (_) => onMagia(m.key)
                  : null,
            ),
          if (travadas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              'Magias de domínio ficam sempre preparadas e não contam no limite.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.rotulo,
    required this.atual,
    required this.total,
    required this.origem,
  });

  final String rotulo;
  final int atual;
  final int total;
  final String origem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CaixaOpcao(
      corBorda: atual == total ? AppColors.sucesso : AppColors.mana,
      padding: const EdgeInsets.all(AppSpacing.small),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rotulo,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.alerta,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$atual / $total',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            origem,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.magia,
    required this.marcado,
    this.travado = false,
    this.onChanged,
  });

  final SpellOption magia;
  final bool marcado;
  final bool travado;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: LinhaCheck(
        marcado: marcado,
        travado: travado,
        onChanged: onChanged,
        child: Row(
          children: [
            const ImageFrame(imagePath: AppImages.pergMagia, width: 32),
            const SizedBox(width: AppSpacing.medium - 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          magia.nome,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (travado) ...[
                        const SizedBox(width: 6),
                        const Etiqueta(
                          'Domínio',
                          pequena: true,
                          cor: AppColors.mana,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    magia.resumo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
