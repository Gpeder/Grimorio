import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

// mensagem ja amigavel, nunca o erro cru
class EstadoErro extends StatelessWidget {
  const EstadoErro({
    super.key,
    required this.mensagem,
    required this.onTentarDeNovo,
    this.compacto = false,
  });

  final String mensagem;
  final VoidCallback onTentarDeNovo;

  // no fim da lista, sem o icone grande
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          compacto ? AppSpacing.medium : AppSpacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compacto) ...[
              const Icon(Pixel.warningdiamond, size: 32, color: AppColors.vida),
              const SizedBox(height: AppSpacing.small),
            ],
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              onPressed: onTentarDeNovo,
              icon: const Icon(Pixel.reload),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
