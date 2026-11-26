import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class CompendioTile extends StatelessWidget {
  const CompendioTile({
    super.key,
    required this.imagem,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.imagemUrl,
    this.tags,
    this.trailing,
    this.corBorda,
    this.lado = 40,
  });

  final String imagem;

  // da api, com a pixel art de reserva
  final String? imagemUrl;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final Widget? tags;
  final Widget? trailing;
  final Color? corBorda;
  final double lado;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tags = this.tags;
    final trailing = this.trailing;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
            child: Row(
              children: [
                ImageFrame(
                  imagePath: imagem,
                  imagemUrl: imagemUrl,
                  width: lado,
                  height: lado,
                  borderColor: corBorda,
                ),
                const SizedBox(width: AppSpacing.medium - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (tags != null) ...[const SizedBox(width: 6), tags],
                        ],
                      ),
                      Text(
                        subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.small),
                  trailing,
                ],
                const SizedBox(width: 4),
                Icon(
                  Pixel.chevronright,
                  size: 16,
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
