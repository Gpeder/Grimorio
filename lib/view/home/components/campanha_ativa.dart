import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_bg.dart';
import 'package:grimorio/widgets/progress_bar.dart';

class CampanhaAtiva extends StatelessWidget {
  const CampanhaAtiva({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(color: AppColors.secondary, width: 1.5),
        ),
        child: ImageBg(
          imagePath: AppImages.bg2,
          overlayOpacity: 0.68,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Continuar campanha',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.alerta,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Sombras de valfenda',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Capítulo 3: A floresta sombria',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              const ProgressBar(
                value: 30,
                max: 100,
                height: 6,
                showText: false,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Sessão 7 - última em 12/11',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
