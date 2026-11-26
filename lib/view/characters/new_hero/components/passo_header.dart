import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class PassoHeader extends StatelessWidget {
  const PassoHeader({
    super.key,
    required this.passo,
    required this.total,
    required this.titulo,
    required this.onVoltar,
    required this.onSalvarRascunho,
  });

  final int passo;
  final int total;
  final String titulo;
  final VoidCallback onVoltar;
  final VoidCallback onSalvarRascunho;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: onVoltar,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Pixel.chevronleft,
                    color: AppColors.onSurface,
                    semanticLabel: 'Voltar',
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'PASSO $passo DE $total',
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.alerta,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSalvarRascunho,
                child: const Text('Salvar rascunho'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            spacing: 4,
            children: [
              for (var i = 1; i <= total; i++)
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i <= passo
                          ? AppColors.alerta
                          : AppColors.onSurface.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            titulo,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
