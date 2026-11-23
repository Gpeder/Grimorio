import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class ImageBg extends StatelessWidget {
  final String imagePath;
  final double height;
  final Widget? child;
  final bool border;
  final EdgeInsetsGeometry padding;

  final double overlayOpacity;

  const ImageBg({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.child,
    this.border = false,
    this.padding = const EdgeInsets.all(16),
    this.overlayOpacity = 0.54,
  });

  static const double _radius = AppSpacing.radius;
  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
        ),
        ColoredBox(color: Colors.black.withValues(alpha: overlayOpacity)),
        if (child != null) Padding(padding: padding, child: child),
      ],
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: border
          ? DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(
                  color: AppColors.secondary,
                  width: _borderWidth,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius),
                child: content,
              ),
            )
          : content,
    );
  }
}
