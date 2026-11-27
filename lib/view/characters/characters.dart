import 'package:flutter/material.dart' hide Characters;
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/components/lista_personagens.dart';
import 'package:grimorio/view/characters/components/novo_heroi_button.dart';
import 'package:grimorio/view/characters/components/personagens_header.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/estado_vazio.dart';
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
    final novo = await context.pushNamed<Personagem>(Rotas.nomeNovoHeroi);
    if (novo == null || !mounted) return;

    try {
      final criado = await context.read<PersonagensProvider>().criar(novo);
      if (!mounted) return;
      mostrarAviso(
        context,
        '${criado.nome} despertou!',
        tipo: Snackbar.sucesso,
        acimaDaBarra: true,
      );
    } catch (e, stack) {
      if (mounted) {
        mostrarErro(
          context,
          e,
          stack: stack,
          onde: 'criar heroi',
          acimaDaBarra: true,
        );
      }
    }
  }

  void _abrirFicha(Personagem p) =>
      context.pushNamed(Rotas.nomeFicha, pathParameters: {Rotas.heroiId: p.id});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonagensProvider>();
    final personagens = provider.meus;
    final campanhas = context.watch<CampanhasProvider>().campanhas;

    final lista = switch (provider.carregamento) {
      Carregamento.inicial || Carregamento.carregando =>
        const SliverToBoxAdapter(child: EstadoCarregando()),
      Carregamento.erro => SliverToBoxAdapter(
        child: EstadoErro(
          mensagem: provider.mensagemErro ?? 'Algo deu errado',
          onTentarDeNovo: provider.tentarDeNovo,
        ),
      ),
      Carregamento.pronto when personagens.isEmpty => SliverToBoxAdapter(
        child: EstadoVazio(
          titulo: 'Nenhum herói ainda',
          mensagem: 'Crie o primeiro e leve para a mesa.',
          acoes: [
            ElevatedButton(
              onPressed: _abrirNovoHeroi,
              child: const Text('Criar herói'),
            ),
          ],
        ),
      ),
      Carregamento.pronto => ListaPersonagens(
        personagens: _gerenciador.filtrar(personagens, _busca),
        campanhas: campanhas,
        onAbrir: _abrirFicha,
      ),
    };

    final secoes = <Widget>[
      PersonagensHeader(onBusca: (v) => setState(() => _busca = v)),
      lista,
    ];

    return Scaffold(
      // vazio ja tem o botao no meio da tela
      floatingActionButton:
          provider.carregamento == Carregamento.pronto && personagens.isEmpty
          ? null
          : NovoHeroiButton(onPressed: _abrirNovoHeroi),
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
