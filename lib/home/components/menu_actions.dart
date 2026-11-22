import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_frame.dart';

class MenuActions extends StatelessWidget {
  const MenuActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MenuItem(
              imagePath: AppImages.menuBolsa,
              label: 'Bolsa',
              onTap: () {},
            ),
            _MenuItem(
              imagePath: AppImages.menuMapa,
              label: 'Mapa',
              onTap: () {},
            ),
            _MenuItem(
              imagePath: AppImages.menuGrimorio,
              label: 'Magias',
              onTap: () {},
            ),
            _MenuItem(
              imagePath: AppImages.menuBestiario,
              label: 'Bestiário',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.imagePath, required this.label, this.onTap});

  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          ImageFrame(
            selected: true,
            imagePath: imagePath,
            width: 80,
            onTap: onTap,
          ),
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.alerta,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
