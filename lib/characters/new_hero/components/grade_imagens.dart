import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/widgets/image_frame.dart';

class ItemImagem {
  const ItemImagem({
    required this.imagem,
    required this.onTap,
    this.rotulo,
    this.selecionado = false,
  });

  final String imagem;
  final String? rotulo;
  final bool selecionado;
  final VoidCallback onTap;
}

class GradeImagens extends StatelessWidget {
  const GradeImagens({super.key, required this.itens, this.colunas = 3});

  final List<ItemImagem> itens;
  final int colunas;

  @override
  Widget build(BuildContext context) {
    final linhas = (itens.length / colunas).ceil();

    return Column(
      spacing: AppSpacing.small,
      children: [
        for (var linha = 0; linha < linhas; linha++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.small,
            children: [
              for (var col = 0; col < colunas; col++)
                Expanded(
                  child: switch (linha * colunas + col) {
                    final i when i < itens.length => _Item(itens[i]),
                    _ => const SizedBox.shrink(),
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.item);

  final ItemImagem item;

  @override
  Widget build(BuildContext context) {
    final rotulo = item.rotulo;

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          ImageFrame(
            imagePath: item.imagem,
            selected: item.selecionado,
            onTap: item.onTap,
          ),
          if (rotulo != null) ...[
            const SizedBox(height: 4),
            Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: item.selecionado
                    ? AppColors.alerta
                    : AppColors.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
