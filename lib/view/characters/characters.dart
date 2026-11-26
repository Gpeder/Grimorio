import 'package:flutter/material.dart' hide Characters;
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';
import 'package:grimorio/view/characters/components/botao_novo_heroi.dart';
import 'package:grimorio/view/characters/components/characters_header.dart';
import 'package:grimorio/view/characters/components/lista_personagens.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/view/characters/new_hero/new_hero.dart';
import 'package:grimorio/model/campaign.dart';
import 'package:grimorio/model/campaign_mock.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/character_mock.dart';
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
  static const _gerenciador = GerenciadorPersonagens();

  Future<void> _abrirNovoHeroi() async {
    final novo = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<Character>(MaterialPageRoute(builder: (_) => const NewHero()));
    if (novo == null || !mounted) return;

    setState(() {
      _personagens = _gerenciador.adicionarNovo(_personagens, novo);
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
      _personagens = _gerenciador.trocar(_personagens, atualizado);
    });
  }

  @override
  Widget build(BuildContext context) {
    final secoes = <Widget>[
      CharactersHeader(onBusca: (v) => setState(() => _busca = v)),
      ListaPersonagens(
        personagens: _gerenciador.filtrar(_personagens, _busca),
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
