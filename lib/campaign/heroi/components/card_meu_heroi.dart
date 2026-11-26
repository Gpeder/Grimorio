import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/progress_bar.dart';

class CardMeuHeroi extends StatelessWidget {
  const CardMeuHeroi({super.key, required this.heroi, this.onAbrirFicha});

  final Character heroi;

  // Nulo na prévia do Mestre (só leitura).
  final VoidCallback? onAbrirFicha;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final h = heroi;
    final classe = h.classes.isEmpty ? '' : h.classes.first.nome;
    final onAbrirFicha = this.onAbrirFicha;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.medium - 4),
      child: Row(
        children: [
          ImageFrame(imagePath: h.retrato, width: 64, height: 64),
          const SizedBox(width: AppSpacing.medium - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        h.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (onAbrirFicha != null)
                      TextButton(
                        onPressed: onAbrirFicha,
                        child: const Text('Abrir ficha ›'),
                      ),
                  ],
                ),
                Text(
                  '$classe · Nv ${h.nivel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 6),
                ProgressBar(
                  value: h.hpAtual,
                  max: h.hpMax,
                  color: AppColors.vida,
                  height: 16,
                ),
                if (h.espacosDeMagia.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _Gemas(espacos: h.espacosDeMagia),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Espaços de magia só para olhar: cheia = livre, vazada = gasto.
class _Gemas extends StatelessWidget {
  const _Gemas({required this.espacos});

  final List<SpellSlot> espacos;

  @override
  Widget build(BuildContext context) {
    final ordenados = [...espacos]
      ..sort((a, b) => a.circulo.compareTo(b.circulo));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final e in ordenados)
          for (var i = 0; i < e.total; i++)
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: i < e.livres ? AppColors.mana : Colors.transparent,
                  border: Border.all(color: AppColors.mana, width: 1.5),
                ),
              ),
            ),
      ],
    );
  }
}
