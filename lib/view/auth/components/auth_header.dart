import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_bg.dart';
import 'package:pixelarticons/pixel.dart';

// castelo no topo; no login o logo faz o papel do titulo
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.comLogo = false,
    this.onVoltar,
  });

  final String titulo;
  final String subtitulo;
  final bool comLogo;
  final VoidCallback? onVoltar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topo = MediaQuery.paddingOf(context).top;
    final onVoltar = this.onVoltar;

    return ImageBg(
      imagePath: AppImages.bgCastelo,
      height: (comLogo ? 250 : 150) + topo,
      overlayOpacity: 0.4,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large,
        topo + AppSpacing.medium,
        AppSpacing.large,
        AppSpacing.medium,
      ),
      child: Stack(
        children: [
          if (onVoltar != null)
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: onVoltar,
                icon: const Icon(Pixel.arrowleft),
              ),
            ),
          Align(
            alignment: comLogo ? Alignment.center : Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: comLogo
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (comLogo)
                  Image.asset(
                    AppImages.logo,
                    height: 120,
                    filterQuality: FilterQuality.none,
                    semanticLabel: titulo,
                  )
                else
                  Text(
                    titulo,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
