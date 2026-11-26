import 'package:flutter/material.dart' hide Characters;
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/app_shell.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/view/campaign/campaign.dart';
import 'package:grimorio/view/campaign/heroi/campanha_heroi.dart';
import 'package:grimorio/view/campaign/mestre/campanha_mestre.dart';
import 'package:grimorio/view/campaign/missao/detalhes_missao.dart';
import 'package:grimorio/view/characters/characters.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/view/characters/new_hero/new_hero.dart';
import 'package:grimorio/view/grimoire/bestiario/bestiario.dart';
import 'package:grimorio/view/grimoire/bestiario/detalhes_monstro.dart';
import 'package:grimorio/view/grimoire/classes/classes.dart';
import 'package:grimorio/view/grimoire/classes/detalhes_classe.dart';
import 'package:grimorio/view/grimoire/condicoes/condicoes.dart';
import 'package:grimorio/view/grimoire/especies/detalhes_especie.dart';
import 'package:grimorio/view/grimoire/especies/especies.dart';
import 'package:grimorio/view/grimoire/grimoire.dart';
import 'package:grimorio/view/grimoire/itens/itens.dart';
import 'package:grimorio/view/grimoire/magias/detalhes_magia.dart';
import 'package:grimorio/view/grimoire/magias/magias.dart';
import 'package:grimorio/view/home/home.dart';
import 'package:grimorio/view/settings/settings.dart';
import 'package:grimorio/widgets/estado_nao_encontrado.dart';
import 'package:provider/provider.dart';

GoRouter criarAppRouter({String inicial = Rotas.inicio}) {
  final raiz = GlobalKey<NavigatorState>(debugLabel: 'raiz');

  return GoRouter(
    navigatorKey: raiz,
    initialLocation: inicial,
    errorBuilder: (context, state) {
      AppLog.aviso(TagLog.rota, 'rota nao existe: ${state.uri}');
      return EstadoNaoEncontrado(onVoltar: () => context.go(Rotas.inicio));
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          // inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.inicio,
                name: Rotas.nomeInicio,
                builder: (_, _) => const Home(),
              ),
            ],
          ),
          // herois
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.herois,
                name: Rotas.nomeHerois,
                builder: (_, _) => const Characters(),
                routes: [
                  GoRoute(
                    path: Rotas.novoHeroi,
                    name: Rotas.nomeNovoHeroi,
                    parentNavigatorKey: raiz,
                    builder: (_, _) => const NewHero(),
                  ),
                  GoRoute(
                    path: Rotas.ficha,
                    name: Rotas.nomeFicha,
                    parentNavigatorKey: raiz,
                    builder: _ficha,
                  ),
                ],
              ),
            ],
          ),
          // campanhas
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.campanhas,
                name: Rotas.nomeCampanhas,
                builder: (_, _) => const Campaign(),
                routes: [
                  GoRoute(
                    path: Rotas.campanha,
                    name: Rotas.nomeCampanha,
                    parentNavigatorKey: raiz,
                    builder: _campanha,
                    routes: [
                      GoRoute(
                        path: Rotas.missao,
                        name: Rotas.nomeMissao,
                        parentNavigatorKey: raiz,
                        builder: (context, state) => _missao(context, state),
                      ),
                      GoRoute(
                        path: Rotas.previa,
                        name: Rotas.nomePrevia,
                        parentNavigatorKey: raiz,
                        builder: (context, state) =>
                            _campanha(context, state, previa: true),
                        routes: [
                          GoRoute(
                            path: Rotas.missao,
                            name: Rotas.nomeMissaoPrevia,
                            parentNavigatorKey: raiz,
                            builder: (context, state) => _missao(
                              context,
                              state,
                              papel: PapelCampanha.heroi,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // grimorio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.grimorio,
                name: Rotas.nomeGrimorio,
                builder: (_, _) => const Grimoire(),
                routes: [
                  GoRoute(
                    path: Rotas.listaCompendio,
                    name: Rotas.nomeListaCompendio,
                    parentNavigatorKey: raiz,
                    builder: _listaCompendio,
                    routes: [
                      GoRoute(
                        path: Rotas.detalheCompendio,
                        name: Rotas.nomeDetalheCompendio,
                        parentNavigatorKey: raiz,
                        builder: _detalheCompendio,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // ajustes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rotas.ajustes,
                name: Rotas.nomeAjustes,
                builder: (_, _) => const Settings(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _naoEncontrado(GoRouterState state) {
  AppLog.aviso(TagLog.rota, 'id nao existe: ${state.uri}');
  return const EstadoNaoEncontrado();
}

// telas por id

Widget _ficha(BuildContext context, GoRouterState state) {
  final id = state.pathParameters[Rotas.heroiId] ?? '';
  final p = context.read<PersonagensProvider>().porId(id);
  return p == null ? _naoEncontrado(state) : Ficha(personagem: p);
}

// mestre ou heroi pelo papel do usuario
Widget _campanha(
  BuildContext context,
  GoRouterState state, {
  bool previa = false,
}) {
  final id = state.pathParameters[Rotas.campanhaId] ?? '';
  final c = context.read<CampanhasProvider>().porId(id);
  if (c == null) return _naoEncontrado(state);
  if (previa) return CampanhaHeroi(campanhaId: id, modoPrevia: true);
  final usuarioId = context.read<UsuarioProvider>().usuario.id;
  return c.papelDe(usuarioId) == PapelCampanha.mestre
      ? CampanhaMestre(campanhaId: id)
      : CampanhaHeroi(campanhaId: id);
}

Widget _missao(
  BuildContext context,
  GoRouterState state, {
  PapelCampanha? papel,
}) {
  final c = context.read<CampanhasProvider>().porId(
    state.pathParameters[Rotas.campanhaId] ?? '',
  );
  final id = state.pathParameters[Rotas.missaoId];
  final m = c?.missoes.where((x) => x.id == id).firstOrNull;
  if (c == null || m == null) return _naoEncontrado(state);
  final usuarioId = context.read<UsuarioProvider>().usuario.id;
  final p = papel ?? c.papelDe(usuarioId);
  return DetalhesMissao(
    missao: m,
    papel: p,
    npcs: c.npcs,
    herois: p == PapelCampanha.mestre
        ? context.read<PersonagensProvider>().daCampanha(c)
        : const [],
    sessaoAtual: c.sessaoAtual,
  );
}

// grimorio

Widget _listaCompendio(BuildContext context, GoRouterState state) =>
    switch (state.pathParameters[Rotas.tipo]) {
      TipoCompendio.magias => const Magias(),
      TipoCompendio.bestiario => const Bestiario(),
      TipoCompendio.itens => const Itens(),
      TipoCompendio.classes => const Classes(),
      TipoCompendio.especies => const Especies(),
      TipoCompendio.condicoes => const Condicoes(),
      _ => _naoEncontrado(state),
    };

Widget _detalheCompendio(BuildContext context, GoRouterState state) {
  final key = state.pathParameters[Rotas.key];
  final tela = switch (state.pathParameters[Rotas.tipo]) {
    TipoCompendio.magias => switch (magiasCompendio
        .where((m) => m.key == key)
        .firstOrNull) {
      final m? => DetalhesMagia(magia: m),
      null => null,
    },
    TipoCompendio.bestiario => switch (monstrosMock
        .where((m) => m.key == key)
        .firstOrNull) {
      final m? => DetalhesMonstro(monstro: m),
      null => null,
    },
    TipoCompendio.classes => switch (classesMock
        .where((c) => c.key == key)
        .firstOrNull) {
      final c? => DetalhesClasse(classe: c),
      null => null,
    },
    TipoCompendio.especies => switch (especiesMock
        .where((e) => e.key == key)
        .firstOrNull) {
      final e? => DetalhesEspecie(especie: e),
      null => null,
    },
    _ => null,
  };
  return tela ?? _naoEncontrado(state);
}
