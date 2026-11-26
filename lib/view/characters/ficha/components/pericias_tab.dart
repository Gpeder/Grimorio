import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/ficha/components/pericia_tile.dart';

class PericiasTab extends StatelessWidget {
  const PericiasTab({super.key, required this.personagem});

  final Personagem personagem;

  @override
  Widget build(BuildContext context) {
    final p = personagem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bônus de proficiência ${sinal(p.bonusProficiencia)} · '
          '${p.pericias.length} perícias proficientes',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: AppSpacing.small),
        for (final s in periciasMock)
          PericiaTile(
            nome: s.nome,
            sigla: s.atributo.sigla,
            bonus: p.bonusPericia(s.nome),
            proficiente: p.pericias.contains(s.nome),
          ),
      ],
    );
  }
}
