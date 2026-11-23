import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:pixelarticons/pixel.dart';

class AvatarCircle extends StatelessWidget {
  final double radius;
  final String? imagePath;

  const AvatarCircle({super.key, this.radius = 35, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.alerta,
      ),
      child: ClipOval(
        child: Container(
          width: size,
          height: size,
          color: AppColors.surface,
          alignment: Alignment.center,
          child: imagePath == null
              ? _fallbackIcon()
              : Image.asset(
                  imagePath!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => _fallbackIcon(),
                ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() =>
      Icon(Pixel.user, size: radius, color: AppColors.onSurface);
}
