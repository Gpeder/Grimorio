import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';

class SemHeroiCard extends StatelessWidget {
  const SemHeroiCard({super.key, this.onCriarHeroi, this.onCriarCampanha});

  final VoidCallback? onCriarHeroi;
  final VoidCallback? onCriarCampanha;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              'PRIMEIRO ACESSO',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.alerta,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            const ImageFrame(imagePath: AppImages.moeda, width: 80, height: 80),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Sua jornada começa aqui.',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCriarHeroi ?? () {},
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Criar primeiro herói', maxLines: 1),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCriarCampanha ?? () {},
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Criar campanha', maxLines: 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
