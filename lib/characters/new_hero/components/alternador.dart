import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class Alternador<T> extends StatelessWidget {
  const Alternador({
    super.key,
    required this.opcoes,
    required this.valor,
    required this.onChanged,
  });

  final Map<T, String> opcoes;
  final T valor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          for (final MapEntry(key: opcao, value: texto) in opcoes.entries)
            Expanded(
              child: Material(
                color: opcao == valor ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                child: InkWell(
                  onTap: () => onChanged(opcao),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Text(
                      texto,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: opcao == valor
                            ? AppColors.onSurface
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
