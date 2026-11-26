import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class CaixaOpcao extends StatelessWidget {
  const CaixaOpcao({
    super.key,
    required this.child,
    this.selecionado = false,
    this.corBorda,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.medium - 4),
  });

  final Widget child;
  final bool selecionado;

  final Color? corBorda;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(AppSpacing.radius);

    return Material(
      color: selecionado
          ? Color.alphaBlend(
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.surface,
            )
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: raio,
        side: BorderSide(
          color: selecionado
              ? AppColors.alerta
              : corBorda ?? AppColors.secondary.withValues(alpha: 0.45),
          width: selecionado ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: raio,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
