import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class PassoFooter extends StatelessWidget {
  const PassoFooter({
    super.key,
    required this.primeiro,
    required this.ultimo,
    required this.pendencia,
    required this.onVoltar,
    required this.onContinuar,
  });

  final bool primeiro;
  final bool ultimo;

  final String? pendencia;
  final VoidCallback onVoltar;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    final pendencia = this.pendencia;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (pendencia != null) ...[
                Text(
                  pendencia,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
              ],
              Row(
                spacing: AppSpacing.medium - 4,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onVoltar,
                      child: Text(primeiro ? 'Cancelar' : 'Voltar'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: pendencia == null ? onContinuar : null,
                      child: Text(ultimo ? 'Despertar herói' : 'Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
