import 'package:flutter/material.dart' hide Characters;
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/components/botao_novo_heroi.dart';
import 'package:grimorio/characters/components/characters_header.dart';
import 'package:grimorio/characters/components/lista_personagens.dart';
import 'package:grimorio/characters/ficha/ficha.dart';
import 'package:grimorio/characters/new_hero/new_hero.dart';
import 'package:grimorio/models/campaign.dart';
import 'package:grimorio/models/campaign_mock.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/character_mock.dart';
import 'package:grimorio/widgets/snack_bar.dart';

class Characters extends StatefulWidget {
  const Characters({
    super.key,
    this.personagens = personagensMock,
    this.campanhas,
    this.onNovoHeroi,
  });

  final List<Character> personagens;
  final List<Campaign>? campanhas;
  final VoidCallback? onNovoHeroi;

  @override
  State<Characters> createState() => _CharactersState();
}

class _CharactersState extends State<Characters> {
  String _busca = '';
  late List<Character> _personagens = [...widget.personagens];

  static const _espacoEntreSecoes = AppSpacing.medium;

  Future<void> _abrirNovoHeroi() async {
    final novo = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<Character>(MaterialPageRoute(builder: (_) => const NewHero()));
    if (novo == null || !mounted) return;

    setState(() {
      _personagens = [
        for (final p in _personagens) p.copyWith(ativo: false),
        novo,
      ];
    });
    mostrarAviso(
      context,
      '${novo.nome} despertou!',
      tipo: Snackbar.sucesso,
      acimaDaBarra: true,
    );
  }

  Future<void> _abrirFicha(Character p) async {
    final atualizado = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<Character>(MaterialPageRoute(builder: (_) => Ficha(personagem: p)));
    if (atualizado == null || !mounted) return;

    setState(() {
      _personagens = [
        for (final c in _personagens) c.id == atualizado.id ? atualizado : c,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final busca = _busca.trim().toLowerCase();

    final secoes = <Widget>[
      CharactersHeader(onBusca: (v) => setState(() => _busca = v)),
      ListaPersonagens(
        personagens: [
          for (final p in _personagens)
            if (p.nome.toLowerCase().contains(busca)) p,
        ],
        campanhas: widget.campanhas ?? campanhasMock,
        onAbrir: _abrirFicha,
      ),
    ];

    return Scaffold(
      floatingActionButton: BotaoNovoHeroi(
        onPressed: widget.onNovoHeroi ?? _abrirNovoHeroi,
      ),
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
