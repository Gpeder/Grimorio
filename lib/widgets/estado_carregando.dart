import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key, this.compacto = false});

  // no fim da lista so a barra
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    const barra = SizedBox(
      width: 120,
      child: LinearProgressIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.surface,
      ),
    );
    if (compacto) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Center(child: barra),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Pixel.hourglass, size: 32, color: AppColors.secondary),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Carregando',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: AppSpacing.medium),
            barra,
          ],
        ),
      ),
    );
  }
}
