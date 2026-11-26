import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class AvisoSessao extends StatelessWidget {
  const AvisoSessao({super.key, required this.sessao, required this.mestre});

  final int sessao;
  final String mestre;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium - 4,
        vertical: AppSpacing.small + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.sucesso.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.sucesso, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Pixel.play, size: 18, color: AppColors.sucesso),
          const SizedBox(width: AppSpacing.small + 2),
          Expanded(
            child: Text(
              'Sessão $sessao em andamento',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Mestre: $mestre',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
