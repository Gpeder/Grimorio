import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/campaign/mestre/components/membro_tile.dart';
import 'package:grimorio/widgets/appcard.dart';

// Só leitura: nome, classe/nível e HP dos outros heróis.
class GrupoTab extends StatelessWidget {
  const GrupoTab({super.key, required this.outros});

  final List<Personagem> outros;

  @override
  Widget build(BuildContext context) {
    if (outros.isEmpty) {
      return Text(
        'Você está sozinho nesta campanha por enquanto.',
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.55)),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium - 4,
        vertical: 4,
      ),
      child: Column(
        children: [
          for (var i = 0; i < outros.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            MembroTile(heroi: outros[i]),
          ],
        ],
      ),
    );
  }
}
