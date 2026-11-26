import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/characters/gerenciador_exp.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/button_info.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/progress_bar.dart';

class FichaCabecalho extends StatelessWidget {
  const FichaCabecalho({
    super.key,
    required this.personagem,
    required this.onSubirNivel,
  });

  final Character personagem;
  final VoidCallback onSubirNivel;

  static String milhar(int n) {
    final digitos = n.abs().toString();
    final b = StringBuffer(n < 0 ? '-' : '');
    for (var i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) b.write('.');
      b.write(digitos[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;
    final classe = p.classes.isEmpty ? null : p.classes.first;
    final subclasse = classe?.subclasse;
    final faltam = const GerenciadorExp().faltaParaProximo(p);
    final suave = AppColors.onSurface.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ImageFrame(
              imagePath: p.retrato,
              width: 128,
              height: 150,
              selected: true,
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ButtonInfo(
                    text: 'Nível ${p.nivel}',
                    fontSize: 14,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    p.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [p.especie, ...p.classes.map((c) => c.nome)].join(' · '),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.alerta,
                    ),
                  ),
                  if (subclasse != null)
                    Text(
                      subclasse,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.alerta,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          p.nivel >= 20
              ? 'XP · nível máximo'
              : faltam > 0
              ? 'XP · faltam ${milhar(faltam)} para o nível ${p.nivel + 1}'
              : 'XP · pronto para o nível ${p.nivel + 1}',
          style: textTheme.labelMedium?.copyWith(
            color: suave,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ProgressBar(
          value: p.xp - p.xpNivelAtual,
          max: p.xpProximoNivel - p.xpNivelAtual,
          textValue: p.xp,
          textMax: p.xpProximoNivel,
        ),
        if (p.podeSubirNivel) ...[
          const SizedBox(height: AppSpacing.medium - 4),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.medium - 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pode subir para o nível ${p.nivel + 1}!',
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                OutlinedButton(
                  onPressed: onSubirNivel,
                  child: const Text('Subir'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
