import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class Etiqueta extends StatelessWidget {
  const Etiqueta(
    this.texto, {
    super.key,
    this.selecionado = false,
    this.pequena = false,
    this.cor = AppColors.alerta,
    this.onTap,
  });

  final String texto;
  final bool selecionado;

  final bool pequena;
  final Color cor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final raio = BorderRadius.circular(AppSpacing.radiusSmall);
    final estilo = pequena ? textTheme.labelSmall : textTheme.labelMedium;

    return Material(
      color: selecionado
          ? AppColors.primary.withValues(alpha: 0.6)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: raio,
        side: BorderSide(color: cor.withValues(alpha: pequena ? 0.8 : 0.7)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: raio,
        child: Padding(
          padding: pequena
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            texto,
            style: estilo?.copyWith(
              color: pequena ? cor : AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class RotuloSecao extends StatelessWidget {
  const RotuloSecao(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.alerta,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
