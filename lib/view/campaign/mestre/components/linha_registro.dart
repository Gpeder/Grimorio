import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:pixelarticons/pixel.dart';

class LinhaRegistro extends StatelessWidget {
  const LinhaRegistro({super.key, required this.registro, this.onDesfazer});

  final dados.RegistroMesa registro;
  final VoidCallback? onDesfazer;

  (IconData, Color) get _icone => switch (registro.tipo) {
    dados.TipoRegistro.xp => (Pixel.sparkle, AppColors.exp),
    dados.TipoRegistro.item => (Pixel.gift, AppColors.alerta),
    dados.TipoRegistro.missao => (Pixel.flag, AppColors.sucesso),
    dados.TipoRegistro.entrada => (Pixel.notes, AppColors.secondary),
    dados.TipoRegistro.sessao => (Pixel.clock, AppColors.mana),
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
