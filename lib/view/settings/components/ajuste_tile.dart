import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class AjusteTile extends StatelessWidget {
  const AjusteTile({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    this.valor,
    this.trailing,
    this.onTap,
    this.perigoso = false,
  });

  AjusteTile.alternar({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    required bool ligado,
    required ValueChanged<bool> onChanged,
  }) : valor = null,
       perigoso = false,
       onTap = (() => onChanged(!ligado)),
       trailing = Switch(value: ligado, onChanged: onChanged);

  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final String? valor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool perigoso;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final corTitulo = perigoso ? AppColors.vida : AppColors.onSurface;
    final subtitulo = this.subtitulo;
    final valor = this.valor;
    final mostraChevron = trailing == null && onTap != null && !perigoso;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icone,
                size: 20,
                color: perigoso ? AppColors.vida : AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: textTheme.bodyLarge?.copyWith(
                        color: corTitulo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitulo != null)
                      Text(
                        subtitulo,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                  ],
                ),
              ),
              if (valor != null) ...[
                const SizedBox(width: AppSpacing.small),
                Flexible(
                  child: Text(
                    valor,
                    textAlign: TextAlign.end,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (trailing case final trailing?) ...[
                const SizedBox(width: AppSpacing.small),
                trailing,
              ],
              if (mostraChevron) ...[
                const SizedBox(width: 4),
                Icon(
                  Pixel.chevronright,
                  size: 18,
                  color: AppColors.onSurface.withValues(alpha: 0.45),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
