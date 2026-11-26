import 'package:flutter/material.dart' hide Characters;
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/components/lista_personagens.dart';
import 'package:grimorio/view/characters/components/novo_heroi_button.dart';
import 'package:grimorio/view/characters/components/personagens_header.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/view/characters/new_hero/new_hero.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

class Characters extends StatefulWidget {
  const Characters({super.key});

  @override
  State<Characters> createState() => _CharactersState();
}

class _CharactersState extends State<Characters> {
  String _busca = '';

  static const _espacoEntreSecoes = AppSpacing.medium;
  static const _gerenciador = GerenciadorPersonagens();

  Future<void> _abrirNovoHeroi() async {
    final novo = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<Personagem>(MaterialPageRoute(builder: (_) => const NewHero()));
    if (novo == null || !mounted) return;

    context.read<PersonagensProvider>().adicionar(novo);
    mostrarAviso(
      context,
      '${novo.nome} despertou!',
      tipo: Snackbar.sucesso,
      acimaDaBarra: true,
    );
  }

  void _abrirFicha(Personagem p) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push<void>(MaterialPageRoute(builder: (_) => Ficha(personagem: p)));
  }

  @override
  Widget build(BuildContext context) {
    final personagens = context.watch<PersonagensProvider>().meus;
    final campanhas = context.watch<CampanhasProvider>().campanhas;

    final secoes = <Widget>[
      PersonagensHeader(onBusca: (v) => setState(() => _busca = v)),
      ListaPersonagens(
        personagens: _gerenciador.filtrar(personagens, _busca),
        campanhas: campanhas,
        onAbrir: _abrirFicha,
      ),
    ];

    return Scaffold(
      floatingActionButton: NovoHeroiButton(onPressed: _abrirNovoHeroi),
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
