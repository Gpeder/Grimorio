import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_frame.dart';

// lista vazia ou busca sem resultado
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.titulo,
    this.mensagem,
    this.acoes = const [],
  });

  final String titulo;
  final String? mensagem;

  // botoes embaixo, ex "Criar herói"
  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mensagem = this.mensagem;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ImageFrame(
              imagePath: AppImages.menuMapa,
              width: 72,
              height: 72,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (mensagem != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (acoes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.large),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: acoes,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
