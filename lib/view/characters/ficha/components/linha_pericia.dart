import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/hero_options.dart';

class LinhaPericia extends StatelessWidget {
  const LinhaPericia({
    super.key,
    required this.nome,
    required this.sigla,
    required this.bonus,
    required this.proficiente,
  });

  final String nome;
  final String sigla;
  final int bonus;
  final bool proficiente;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small + 2),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: proficiente ? AppColors.alerta : Colors.transparent,
                  border: Border.all(color: AppColors.alerta, width: 1.5),
                ),
              ),
              const SizedBox(width: AppSpacing.medium - 4),
              Expanded(
                child: Text(
                  nome,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                sigla,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  sinal(bonus),
                  textAlign: TextAlign.right,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
