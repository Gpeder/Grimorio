import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:pixelarticons/pixel.dart';

class RegistroTile extends StatelessWidget {
  const RegistroTile({super.key, required this.registro, this.onDesfazer});

  final RegistroMesa registro;
  final VoidCallback? onDesfazer;

  (IconData, Color) get _icone => switch (registro.tipo) {
    TipoRegistro.xp => (Pixel.sparkle, AppColors.exp),
    TipoRegistro.item => (Pixel.gift, AppColors.alerta),
    TipoRegistro.missao => (Pixel.flag, AppColors.sucesso),
    TipoRegistro.entrada => (Pixel.notes, AppColors.secondary),
    TipoRegistro.sessao => (Pixel.clock, AppColors.mana),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icone, cor) = _icone;
    final onDesfazer = this.onDesfazer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, size: 18, color: cor),
          const SizedBox(width: AppSpacing.small + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.texto,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  tempoDesde(registro.criadoEm),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (onDesfazer != null) ...[
            const SizedBox(width: AppSpacing.small),
            TextButton(onPressed: onDesfazer, child: const Text('Desfazer')),
          ],
        ],
      ),
    );
  }
}
