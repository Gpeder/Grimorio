import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio/app/theme/app_colors.dart';

/// Moldura com borda dourada e rótulo opcional.
/// Com [width] vira avatar em destaque; sem [width] ocupa a célula do grid.
class ImageFrame extends StatelessWidget {
  final String? imagePath;
  final String? label;
  final double? width;
  final double aspectRatio;
  final bool selected;
  final VoidCallback? onTap;

  const ImageFrame({
    super.key,
    this.imagePath,
    this.label,
    this.width,
    this.aspectRatio = 1,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: radius,
              border: Border.all(
                color: AppColors.alerta,
                width: selected ? 2.5 : 1.5,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: imagePath == null
                      ? const SizedBox.expand()
                      : Image.asset(
                          imagePath!,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, _, _) => const SizedBox.expand(),
                        ),
                ),
                if (label != null)
                  Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
