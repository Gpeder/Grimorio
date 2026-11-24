import 'package:flutter/material.dart' hide Characters;
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/components/botao_novo_heroi.dart';
import 'package:grimorio/characters/components/characters_header.dart';
import 'package:grimorio/characters/components/lista_personagens.dart';
import 'package:grimorio/models/campaign.dart';
import 'package:grimorio/models/campaign_mock.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/character_mock.dart';

class Characters extends StatefulWidget {
  const Characters({
    super.key,
    this.personagens = personagensMock,
    this.campanhas = campanhasMock,
    this.onNovoHeroi,
  });

  final List<Character> personagens;
  final List<Campaign> campanhas;
  final VoidCallback? onNovoHeroi;

  @override
  State<Characters> createState() => _CharactersState();
}

class _CharactersState extends State<Characters> {
  String _busca = '';

  static const _espacoEntreSecoes = AppSpacing.medium;

  @override
  Widget build(BuildContext context) {
    final busca = _busca.trim().toLowerCase();

    final secoes = <Widget>[
      CharactersHeader(onBusca: (v) => setState(() => _busca = v)),
      ListaPersonagens(
        personagens: [
          for (final p in widget.personagens)
            if (p.nome.toLowerCase().contains(busca)) p,
        ],
        campanhas: widget.campanhas,
      ),
    ];

    return Scaffold(
      floatingActionButton: BotaoNovoHeroi(onPressed: widget.onNovoHeroi),
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.large,
                AppSpacing.medium,
                96,
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
          ),
        ],
      ),
    );
  }
}
