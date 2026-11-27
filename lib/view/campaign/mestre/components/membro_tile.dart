import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/formatos.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/progress_bar.dart';
import 'package:pixelarticons/pixel.dart';

class MembroTile extends StatelessWidget {
  const MembroTile({
    super.key,
    required this.heroi,
    this.onXp,
    this.onItem,
    this.onRemover,
  });

  final Personagem heroi;

  // sem callback fica so leitura
  final VoidCallback? onXp;
  final VoidCallback? onItem;
  final VoidCallback? onRemover;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final h = heroi;
    final classe = h.classes.isEmpty ? '' : h.classes.first.nome;
    final onXp = this.onXp;
    final onItem = this.onItem;
    final onRemover = this.onRemover;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        children: [
          ImageFrame(imagePath: h.retrato, width: 48, height: 48),
          const SizedBox(width: AppSpacing.medium - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      h.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (h.podeSubirNivel && onXp != null)
                      const Etiqueta(
                        'pode subir!',
                        pequena: true,
                        cor: AppColors.exp,
                      ),
                  ],
                ),
                Text(
                  '$classe · Nv ${h.nivel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 4),
                ProgressBar(
                  value: h.hpAtual,
                  max: h.hpMax,
                  color: AppColors.vida,
                  height: 14,
                ),
                if (onXp != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'XP ${formatarMilhar(h.xp)} / '
                    '${formatarMilhar(h.xpProximoNivel)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.exp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onXp != null) ...[
            const SizedBox(width: AppSpacing.small),
            IconButton(
              tooltip: 'Dar XP a ${h.nome}',
              onPressed: onXp,
              icon: const Icon(Pixel.sparkle, color: AppColors.exp),
            ),
          ],
          if (onItem != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Dar item a ${h.nome}',
              onPressed: onItem,
              icon: const Icon(Pixel.gift),
            ),
          ],
          if (onRemover != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Remover ${h.nome} da campanha',
              onPressed: onRemover,
              icon: const Icon(Pixel.userminus, color: AppColors.vida),
            ),
          ],
        ],
      ),
    );
  }
}
