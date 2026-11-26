import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/home/components/campaign_active.dart';
import 'package:grimorio/view/home/components/card_personagem_ativo.dart';
import 'package:grimorio/view/home/components/home_appbar.dart';
import 'package:grimorio/view/home/components/menu_actions.dart';
import 'package:grimorio/view/home/components/mission_active.dart';
import 'package:grimorio/view/home/components/not_hero.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/character_mock.dart';

class Home extends StatelessWidget {
  const Home({super.key, this.personagem = personagemAtivoMock});

  final Character? personagem;

  static const _espacoEntreSecoes = AppSpacing.large;

  @override
  Widget build(BuildContext context) {
    final personagem = this.personagem;

    final secoes = <Widget>[
      if (personagem == null)
        const NotHero()
      else ...[
        CardPersonagemAtivo(personagem: personagem),
        const MenuActions(),
        const CampaignActive(),
        const MissionActive(),
      ],
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppbar(avatarPath: personagem?.retrato),
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
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }
}
