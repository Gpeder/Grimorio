import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

class CodigoConvite extends StatelessWidget {
  const CodigoConvite({super.key, required this.codigo});

  final String codigo;

  Future<void> _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: codigo));
    if (!context.mounted) return;
    mostrarAviso(context, 'Código copiado', tipo: Snackbar.sucesso);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final raio = BorderRadius.circular(AppSpacing.radiusSmall);

    return Material(
      color: AppColors.background.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: raio,
        side: const BorderSide(color: AppColors.alerta),
      ),
      child: InkWell(
        onTap: () => _copiar(context),
        borderRadius: raio,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CÓDIGO',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    codigo,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.small),
              const Icon(Pixel.copy, size: 18, color: AppColors.alerta),
            ],
          ),
        ),
      ),
    );
  }
}
