import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/campaign/mestre/components/aba_mundo.dart'
    show LinhaNpc;
import 'package:grimorio/campaign/mestre/components/aba_sessoes.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/models/campaign.dart' as dados;
import 'package:grimorio/widgets/appcard.dart';

class AbaDiarioHeroi extends StatelessWidget {
  const AbaDiarioHeroi({super.key, required this.sessoes, required this.npcs});

  final List<dados.Sessao> sessoes;

  // Já filtrados por `npcsVisiveis`.
  final List<dados.Npc> npcs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSecao('Sessões'),
        AbaSessoes(sessoes: sessoes, mostrarXp: false),
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
                  LinhaNpc(npc: npcs[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
