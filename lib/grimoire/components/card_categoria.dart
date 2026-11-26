import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';

class CardCategoria extends StatelessWidget {
  const CardCategoria({
    super.key,
    required this.nome,
    required this.contagem,
    required this.imagem,
    required this.onTap,
  });

  final String nome;
  final String contagem;
  final String imagem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.medium - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageFrame(imagePath: imagem, height: 72, width: double.infinity),
            const SizedBox(height: AppSpacing.medium - 4),
            Text(
              nome,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contagem,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
