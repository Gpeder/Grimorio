import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/models/campaign.dart' as dados;
import 'package:grimorio/models/character.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/avatar_circle.dart';
import 'package:grimorio/widgets/progress_bar.dart';

class CardCampanha extends StatelessWidget {
  const CardCampanha({
    super.key,
    required this.campanha,
    required this.papel,
    required this.herois,
    required this.onTap,
  });

  final dados.Campaign campanha;
  final dados.PapelCampanha papel;
  final List<Character> herois;
  final VoidCallback onTap;

  static const _alturaCapa = 96.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = campanha;
    final sessao = c.emSessao
        ? 'Sessão ${c.sessaoAtual} · em andamento'
        : 'Sessão ${c.sessaoAtual}';

    return Stack(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusSmall),
                ),
                child: SizedBox(
                  height: _alturaCapa,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        c.capa ?? AppImages.bg,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.none,
                      ),
                      ColoredBox(
                        color: AppColors.background.withValues(alpha: 0.55),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.small),
                          child: Etiqueta(
                            papel.label,
                            pequena: true,
                            selecionado: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.medium - 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nome,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (c.capitulo.isNotEmpty)
                      Text(
                        c.capitulo,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.small),
                    ProgressBar(
                      value: c.progresso * 100,
                      max: 100,
                      height: 6,
                      showText: false,
                    ),
                    const SizedBox(height: AppSpacing.small + 4),
                    Row(
                      children: [
                        _Avatares(herois: herois),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            sessao,
                            textAlign: TextAlign.end,
                            style: textTheme.labelMedium?.copyWith(
                              color: c.emSessao
                                  ? AppColors.sucesso
                                  : AppColors.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatares extends StatelessWidget {
  const _Avatares({required this.herois});

  final List<Character> herois;

  static const _raio = 14.0;
  static const _passo = 20.0;

  @override
  Widget build(BuildContext context) {
    if (herois.isEmpty) return const SizedBox.shrink();
    final lado = _raio * 2 + 4;

    return SizedBox(
      height: lado,
      width: lado + _passo * (herois.length - 1),
      child: Stack(
        children: [
          for (var i = 0; i < herois.length; i++)
            Positioned(
              left: _passo * i,
              child: AvatarCircle(imagePath: herois[i].retrato, radius: _raio),
            ),
        ],
      ),
    );
  }
}
