import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/models/campaign.dart' as dados;
import 'package:pixelarticons/pixel.dart';

class CabecalhoCampanha extends StatelessWidget {
  const CabecalhoCampanha({
    super.key,
    required this.campanha,
    required this.papel,
    this.trailing,
    this.semTopo = false,
  });

  final dados.Campaign campanha;
  final dados.PapelCampanha papel;
  final Widget? trailing;

  // true quando algo fixo já ocupa a barra de status (faixa de prévia).
  final bool semTopo;

  // Altura mínima: cresce se o nome quebrar em duas linhas.
  static const _altura = 190.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topo = semTopo ? 0.0 : MediaQuery.paddingOf(context).top;
    final trailing = this.trailing;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: _altura + topo),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              campanha.capa ?? AppImages.bg,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.35),
                    AppColors.background.withValues(alpha: 0.55),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium,
              topo + AppSpacing.small,
              AppSpacing.medium,
              AppSpacing.medium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Pixel.arrowleft),
                    ),
                    const Spacer(),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 40),
                Etiqueta(papel.label, pequena: true, selecionado: true),
                const SizedBox(height: 6),
                Text(
                  campanha.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (campanha.capitulo.isNotEmpty)
                  Text(
                    campanha.capitulo,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
