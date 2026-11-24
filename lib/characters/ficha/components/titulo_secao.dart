import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

 Título de seção das abas da ficha ("Salvaguardas", "Mochila"…).
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, this.trailing});

  final String texto;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.alerta,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

 Rótulo pequeno em caixa alta ("ATAQUE MÁGICO", "CARGA").
class RotuloFicha extends StatelessWidget {
  const RotuloFicha(this.texto, {super.key, this.icone, this.corIcone});

  final String texto;
  final IconData? icone;
  final Color? corIcone;

  @override
  Widget build(BuildContext context) {
    final icone = this.icone;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icone != null) ...[
          Icon(icone, size: 14, color: corIcone ?? AppColors.alerta),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            texto.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
