import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';

class MedalhaoAtributo extends StatelessWidget {
  const MedalhaoAtributo({
    super.key,
    required this.atributo,
    required this.valor,
    this.destaque = false,
  });

  final Ability atributo;
  final int valor;

  final bool destaque;

  static const _vao = 4.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borda = destaque ? 2.5 : 1.5;

    return Container(
      padding: const EdgeInsets.all(_vao),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: destaque ? AppColors.alerta : AppColors.secondary,
          width: borda,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.small + 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.6),
            width: destaque ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              atributo.sigla,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sinal(modificador(valor)),
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: Border.all(color: AppColors.alerta),
              ),
              child: Text(
                '$valor',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
