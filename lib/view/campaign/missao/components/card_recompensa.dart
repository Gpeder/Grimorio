import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/campaign/components/caixa_tracejada.dart';
import 'package:grimorio/view/campaign/components/formatos.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:grimorio/model/grimoire_mock.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class CardRecompensa extends StatelessWidget {
  const CardRecompensa({
    super.key,
    required this.missao,
    required this.papel,
    this.onEditarXp,
    this.onAdicionarItem,
    this.onRemoverItem,
  });

  final dados.Missao missao;
  final dados.PapelCampanha papel;
  final VoidCallback? onEditarXp;
  final VoidCallback? onAdicionarItem;
  final ValueChanged<String>? onRemoverItem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mestre = papel == dados.PapelCampanha.mestre;
    final apagado = AppColors.onSurface.withValues(alpha: 0.6);

    if (!dados.recompensaVisivel(missao, papel)) {
      return CaixaTracejada(
        child: Row(
          children: [
            Icon(Pixel.lock, size: 18, color: apagado),
            const SizedBox(width: AppSpacing.small + 4),
            Expanded(
              child: Text(
                'Recompensa revelada ao concluir.',
                style: textTheme.bodyMedium?.copyWith(color: apagado),
              ),
            ),
          ],
        ),
      );
    }

    final itens = [
      for (final key in missao.recompensaItens)
        ?itensMock.where((i) => i.key == key).firstOrNull,
    ];
    final editavel = mestre && missao.ativa;
    final onRemoverItem = this.onRemoverItem;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.medium - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: editavel ? onEditarXp : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Pixel.sparkle, size: 20, color: AppColors.exp),
                  const SizedBox(width: AppSpacing.small + 2),
                  Expanded(
                    child: Text(
                      '${formatarMilhar(missao.recompensaXp)} XP',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.exp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (editavel) Icon(Pixel.pencil, size: 16, color: apagado),
                ],
              ),
            ),
          ),
          for (final i in itens)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.small),
              child: Row(
                children: [
                  ImageFrame(imagePath: i.imagem, width: 32, height: 32),
                  const SizedBox(width: AppSpacing.small + 2),
                  Expanded(
                    child: Text(
                      i.nome,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (editavel && onRemoverItem != null)
                    InkResponse(
                      onTap: () => onRemoverItem(i.key),
                      radius: 18,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Pixel.close, size: 16, color: apagado),
                      ),
                    ),
                ],
              ),
            ),
          if (editavel) ...[
            const SizedBox(height: AppSpacing.small),
            TextButton.icon(
              onPressed: onAdicionarItem,
              icon: const Icon(Pixel.plus, size: 16),
              label: const Text('Item'),
            ),
          ],
          if (mestre) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              'Distribuída quando você concluir. Os heróis só veem depois.',
              style: textTheme.bodySmall?.copyWith(color: apagado),
            ),
          ],
        ],
      ),
    );
  }
}
