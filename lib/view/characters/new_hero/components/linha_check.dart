import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class LinhaCheck extends StatelessWidget {
  const LinhaCheck({
    super.key,
    required this.marcado,
    required this.child,
    this.travado = false,
    this.onChanged,
    this.trailing,
  });

  final bool marcado;

  final bool travado;

  final ValueChanged<bool>? onChanged;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final habilitado = !travado && onChanged != null;

    return InkWell(
      onTap: habilitado ? () => onChanged!(!marcado) : null,
      child: Opacity(
        opacity: habilitado || travado || marcado ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: Row(
            children: [
              _Caixa(marcado: marcado || travado, travado: travado),
              const SizedBox(width: AppSpacing.medium - 4),
              Expanded(child: child),
              if (travado) ...[
                const SizedBox(width: AppSpacing.small),
                const Icon(Pixel.lock, size: 16, color: AppColors.alerta),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.small),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Caixa extends StatelessWidget {
  const _Caixa({required this.marcado, required this.travado});

  final bool marcado;
  final bool travado;

  @override
  Widget build(BuildContext context) {
    final cor = travado
        ? AppColors.alerta.withValues(alpha: 0.55)
        : AppColors.alerta;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: marcado ? cor : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: cor, width: 1.5),
      ),
      child: marcado
          ? const Icon(Pixel.check, size: 16, color: AppColors.background)
          : null,
    );
  }
}
