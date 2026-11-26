import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/campaign/mestre/components/mundo_tab.dart'
    show NpcTile;
import 'package:grimorio/view/campaign/mestre/components/sessoes_tab.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/widgets/appcard.dart';

class DiarioHeroiTab extends StatelessWidget {
  const DiarioHeroiTab({super.key, required this.sessoes, required this.npcs});

  final List<Sessao> sessoes;

  // ja filtrados
  final List<Npc> npcs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSecao('Sessões'),
        SessoesTab(sessoes: sessoes, mostrarXp: false),
        const SizedBox(height: AppSpacing.small),
        const TituloSecao('Personagens conhecidos'),
        if (npcs.isEmpty)
          Text(
            'Ninguém conhecido ainda.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.55)),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium - 4,
              vertical: 4,
            ),
            child: Column(
              children: [
                for (var i = 0; i < npcs.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  NpcTile(npc: npcs[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
