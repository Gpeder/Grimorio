import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

// no lugar do widget que quebrou, so em release
class ErroWidgetCard extends StatelessWidget {
  const ErroWidgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.small),
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.secondary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Pixel.warningdiamond, color: AppColors.vida),
            const SizedBox(width: AppSpacing.small),
            Flexible(
              child: Text(
                'Algo deu errado nesta parte',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
