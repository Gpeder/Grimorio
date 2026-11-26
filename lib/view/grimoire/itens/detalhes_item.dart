import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/view/grimoire/components/raridade_badge.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';

// Bottom sheet com o item. O aviso sai pelo context de quem abriu, depois
// de fechar o sheet, para não ficar escondido atrás dele.
void mostrarItem(BuildContext context, ItemCompendio item) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (sheet) => DetalhesItem(
      item: item,
      onDar: () {
        Navigator.pop(sheet);
        mostrarAviso(context, 'Em breve');
      },
    ),
  );
}

class DetalhesItem extends StatelessWidget {
  const DetalhesItem({super.key, required this.item, required this.onDar});

  final ItemCompendio item;
  final VoidCallback onDar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.medium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ImageFrame(
                    imagePath: item.imagem,
                    width: 96,
                    height: 96,
                    borderColor: item.raridade.cor,
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Text(
                          item.nome,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.categoria,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                        RaridadeBadge(item.raridade),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.sintonia) ...[
                const SizedBox(height: AppSpacing.medium - 4),
                Text(
                  'Requer sintonia',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.alerta,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.medium - 4),
              Text(
                item.descricao,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              ElevatedButton(
                onPressed: onDar,
                child: const Text('Dar a um personagem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
