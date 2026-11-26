import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/button_info.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/progress_bar.dart';
import 'package:pixelarticons/pixel.dart';

class CardPersonagemAtivo extends StatelessWidget {
  const CardPersonagemAtivo({super.key, required this.personagem});

  final Character personagem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonInfo(text: 'Personagem Ativo', onPressed: () {}),
                TextButton(
                  // A Home ainda é mock: o resultado da ficha é ignorado.
                  onPressed: () => Navigator.of(context, rootNavigator: true)
                      .push<Character>(
                        MaterialPageRoute(
                          builder: (_) => Ficha(personagem: personagem),
                        ),
                      ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('detalhes'),
                      Icon(Pixel.chevronright, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImageFrame(
                    selected: true,
                    imagePath: personagem.retrato,
                    width: 110,
                    height: 150,
                  ),
                  const SizedBox(width: AppSpacing.medium),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          personagem.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                personagem.classes
                                    .map((c) => c.nome)
                                    .join(' / '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.alerta,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.small),
                            ButtonInfo(
                              text: 'Nível ${personagem.nivel}',
                              fontSize: 14,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Pixel.sparkle,
                                  size: 18,
                                  color: AppColors.alerta,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'XP',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ProgressBar(
                              value: personagem.xp - personagem.xpNivelAtual,
                              max:
                                  personagem.xpProximoNivel -
                                  personagem.xpNivelAtual,
                              textValue: personagem.xp,
                              textMax: personagem.xpProximoNivel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Divider(height: AppSpacing.medium),
            _Atributos(personagem: personagem),
          ],
        ),
      ),
    );
  }
}

class _Atributos extends StatelessWidget {
  const _Atributos({required this.personagem});

  final Character personagem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final espacos = personagem.espacosDeMagia;
    final maiorCirculo = espacos.isEmpty
        ? null
        : espacos.reduce((a, b) => a.circulo >= b.circulo ? a : b);
    final divisoria = VerticalDivider(
      width: AppSpacing.large,
      color: AppColors.secondary.withValues(alpha: 0.25),
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HP
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: _Rotulo(
                    icone: Pixel.heart,
                    cor: AppColors.vida,
                    texto: 'HP',
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                ProgressBar(
                  value: personagem.hpAtual,
                  max: personagem.hpMax,
                  color: AppColors.vida,
                ),
              ],
            ),
          ),
          divisoria,

          // CA
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Rotulo(
                icone: Pixel.shield,
                cor: AppColors.alerta,
                texto: 'CA',
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '${personagem.ca}',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
          divisoria,

          // Magia
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: _Rotulo(
                    icone: Pixel.sparkles,
                    cor: AppColors.mana,
                    texto: 'MAGIA',
                  ),
                ),
                const SizedBox(height: AppSpacing.small),
                // Uma gema por espaço do maior círculo: cheia = livre, vazia = usado.
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    if (maiorCirculo != null)
                      for (var i = 0; i < maiorCirculo.total; i++)
                        _Gema(cheia: i < maiorCirculo.livres),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  personagem.espacosDeMagia.isEmpty
                      ? 'sem magia'
                      : '${personagem.espacosLivres} espaços',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
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

class _Rotulo extends StatelessWidget {
  const _Rotulo({required this.icone, required this.cor, required this.texto});

  final IconData icone;
  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 18, color: cor),
        const SizedBox(width: 6),
        Text(
          texto,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Gema extends StatelessWidget {
  const _Gema({required this.cheia});

  final bool cheia;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Image.asset(
        cheia ? AppImages.gemaCheia : AppImages.gemaVazia,
        width: 22,
        height: 22,
        filterQuality: FilterQuality.none,
      ),
    );
  }
}
