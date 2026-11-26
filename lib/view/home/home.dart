import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/personagem_mock.dart';
import 'package:grimorio/view/home/components/acoes_menu.dart';
import 'package:grimorio/view/home/components/campanha_ativa.dart';
import 'package:grimorio/view/home/components/home_app_bar.dart';
import 'package:grimorio/view/home/components/missao_ativa_card.dart';
import 'package:grimorio/view/home/components/personagem_ativo_card.dart';
import 'package:grimorio/view/home/components/sem_heroi_card.dart';

class Home extends StatelessWidget {
  const Home({super.key, this.personagem = personagemAtivoMock});

  final Personagem? personagem;

  static const _espacoEntreSecoes = AppSpacing.large;

  @override
  Widget build(BuildContext context) {
    final personagem = this.personagem;

    final secoes = <Widget>[
      if (personagem == null)
        const SemHeroiCard()
      else ...[
        PersonagemAtivoCard(personagem: personagem),
        const AcoesMenu(),
        const CampanhaAtiva(),
        const MissaoAtivaCard(),
      ],
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppBar(avatarPath: personagem?.retrato),
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
