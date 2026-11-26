import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:pixelarticons/pixel.dart';

class PersonagensHeader extends StatelessWidget {
  const PersonagensHeader({super.key, required this.onBusca});

  final ValueChanged<String> onBusca;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personagens',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            onChanged: onBusca,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Buscar herói',
              prefixIcon: Icon(Pixel.search),
            ),
          ),
        ],
      ),
    );
  }
}
