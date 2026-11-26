import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

enum Snackbar {
  sucesso(Pixel.check, AppColors.sucesso),
  info(Pixel.infobox, AppColors.secondary),
  vida(Pixel.heart, AppColors.vida),
  magia(Pixel.sparkles, AppColors.mana),
  erro(Pixel.warningdiamond, AppColors.vida);

  const Snackbar(this.icone, this.cor);
  final IconData icone;
  final Color cor;
}

void mostrarAviso(
  BuildContext context,
  String texto, {
  Snackbar tipo = Snackbar.info,
  String? acao,
  VoidCallback? onAcao,
  bool acimaDaBarra = false,
}) {
  final textTheme = Theme.of(context).textTheme;
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: acao == null ? 3 : 5),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        acimaDaBarra ? 110 : AppSpacing.medium,
      ),
      content: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.alerta, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.background,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radius - 1.5),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: tipo.cor),
                const SizedBox(width: AppSpacing.small + 2),
                Icon(tipo.icone, color: tipo.cor, size: 22),
                const SizedBox(width: AppSpacing.small + 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      texto,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                if (acao != null) ...[
                  const SizedBox(width: AppSpacing.small),
                  TextButton(
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      onAcao?.call();
                    },
                    child: Text(acao),
                  ),
                ],
                const SizedBox(width: AppSpacing.medium),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
