import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/linha_pericia.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/models/hero_options_mock.dart';

class AbaPericias extends StatelessWidget {
  const AbaPericias({super.key, required this.personagem});

  final Character personagem;

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
          LinhaPericia(
            nome: s.nome,
            sigla: s.atributo.sigla,
            bonus: p.bonusPericia(s.nome),
            proficiente: p.pericias.contains(s.nome),
          ),
      ],
    );
  }
}
