import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/home/components/campaings_active.dart';
import 'package:grimorio/home/components/card_personagem_ativo.dart';
import 'package:grimorio/home/components/home_appbar.dart';
import 'package:grimorio/home/components/menu_actions.dart';
import 'package:grimorio/home/components/mission_active.dart';
import 'package:grimorio/home/components/not_hero.dart';
import 'package:grimorio/models/personagens_mock.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const _espacoEntreSecoes = AppSpacing.large;

  @override
  Widget build(BuildContext context) {
    const personagem = personagemAtivoMock;

    const secoes = <Widget>[
      CardPersonagemAtivo(personagem: personagem),
      MenuActions(),
      CampaingsActive(),
      MissionActive(),
      NotHero(),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppbar(avatarPath: personagem.retrato),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.medium,
              AppSpacing.medium,
              0,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                for (var i = 0; i < secoes.length; i++) ...[
                  if (i > 0)
                    const SliverToBoxAdapter(
                      child: SizedBox(height: _espacoEntreSecoes),
                    ),
                  secoes[i],
                ],
              ],
            ),
          ),
          const _EspacoBottomBar(),
        ],
      ),
    );
  }
}

/// Reserva no fim da rolagem a altura da bottom bar flutuante, para o último
/// card nunca ficar escondido atrás dela.
class _EspacoBottomBar extends StatelessWidget {
  const _EspacoBottomBar();

  @override
  Widget build(BuildContext context) {
    final barHeight = BottomBarScope.maybeOf(context)?.barHeight;

    if (barHeight == null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.paddingOf(context).bottom + AppSpacing.large,
        ),
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: barHeight,
      builder: (context, altura, _) => SliverToBoxAdapter(
        child: SizedBox(height: altura + AppSpacing.medium),
      ),
    );
  }
}
