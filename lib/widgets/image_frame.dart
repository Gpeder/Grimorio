import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class ImageFrame extends StatelessWidget {
  final String? imagePath;
  final String? label;
  final double? width;
  final double? height;
  final double aspectRatio;
  final bool selected;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ImageFrame({
    super.key,
    this.imagePath,
    this.label,
    this.width,
    this.height,
    this.aspectRatio = 1,
    this.selected = false,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radius);

    final frame = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? AppColors.alerta,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SizedBox.expand(
                  child: imagePath == null
                      ? null
                      : Image.asset(
                          imagePath!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                ),
              ),
              if (label != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (height != null) {
      return SizedBox(width: width, height: height, child: frame);
    }

    return SizedBox(
      width: width,
      child: AspectRatio(aspectRatio: aspectRatio, child: frame),
    );
  }
}
