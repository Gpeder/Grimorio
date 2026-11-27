import 'package:flutter/material.dart' hide Characters;
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/app_shell.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/view/auth/cadastro.dart';
import 'package:grimorio/view/auth/confirmar_email.dart';
import 'package:grimorio/view/auth/login.dart';
import 'package:grimorio/view/auth/recuperar_senha.dart';
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
import 'package:grimorio/view/grimoire/itens/detalhes_item.dart';
import 'package:grimorio/view/grimoire/itens/itens.dart';
import 'package:grimorio/view/grimoire/magias/detalhes_magia.dart';
import 'package:grimorio/view/grimoire/magias/magias.dart';
import 'package:grimorio/view/home/home.dart';
import 'package:grimorio/view/settings/settings.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_nao_encontrado.dart';
import 'package:provider/provider.dart';

GoRouter criarAppRouter({
  required AuthProvider auth,
  String inicial = Rotas.inicio,
}) {
  final raiz = GlobalKey<NavigatorState>(debugLabel: 'raiz');

  return GoRouter(
    navigatorKey: raiz,
    initialLocation: inicial,
    refreshListenable: auth,
    redirect: (_, state) => redirecionarAuth(auth, state.uri.path),
    errorBuilder: (context, state) {
      AppLog.aviso(TagLog.rota, 'rota nao existe: ${state.uri}');
      return EstadoNaoEncontrado(onVoltar: () => context.go(Rotas.inicio));
    },
    routes: [
      // login, sem barra
      GoRoute(
        path: Rotas.entrar,
        name: Rotas.nomeEntrar,
        builder: (_, _) => const Login(),
      ),
      GoRoute(
        path: Rotas.cadastro,
        name: Rotas.nomeCadastro,
        builder: (_, _) => const Cadastro(),
        routes: [
          GoRoute(
            path: Rotas.confirmarEmail,
            name: Rotas.nomeConfirmarEmail,
            builder: (_, _) => const ConfirmarEmail(),
          ),
        ],
      ),
      GoRoute(
        path: Rotas.recuperarSenha,
        name: Rotas.nomeRecuperarSenha,
        builder: (_, _) => const RecuperarSenha(),
      ),
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

// sem login so as telas de auth; logado nao volta para elas
// a nao ser no meio da recuperacao de senha
String? redirecionarAuth(AuthProvider auth, String rota) {
  final deAuth = Rotas.deAuth.contains(rota);
  final destino = switch (auth.logado) {
    false when !deAuth => Rotas.entrar,
    false
        when rota == Rotas.confirmarEmailCompleto &&
            auth.emailPendente == null =>
      Rotas.entrar,
    true when deAuth && !auth.recuperandoSenha => Rotas.inicio,
    _ => null,
  };
  if (destino != null) AppLog.info(TagLog.rota, 'redirect $rota -> $destino');
  return destino;
}

Widget _naoEncontrado(GoRouterState state) {
  AppLog.aviso(TagLog.rota, 'id nao existe: ${state.uri}');
  return const EstadoNaoEncontrado();
}

// telas por id; a tela busca no provider

Widget _ficha(BuildContext context, GoRouterState state) =>
    Ficha(personagemId: state.pathParameters[Rotas.heroiId] ?? '');

Widget _campanha(
  BuildContext context,
  GoRouterState state, {
  bool previa = false,
}) => _TelaCampanha(
  campanhaId: state.pathParameters[Rotas.campanhaId] ?? '',
  previa: previa,
);

Widget _missao(
  BuildContext context,
  GoRouterState state, {
  PapelCampanha? papel,
}) => _TelaMissao(
  campanhaId: state.pathParameters[Rotas.campanhaId] ?? '',
  missaoId: state.pathParameters[Rotas.missaoId] ?? '',
  papel: papel,
);

// mestre ou heroi pelo papel do usuario; espera a carga das campanhas
class _TelaCampanha extends StatelessWidget {
  const _TelaCampanha({required this.campanhaId, required this.previa});

  final String campanhaId;
  final bool previa;

  @override
  Widget build(BuildContext context) {
    final campanhas = context.watch<CampanhasProvider>();
    final c = campanhas.porId(campanhaId);
    if (c == null) return _semCampanha(campanhas, campanhaId);
    if (previa) return CampanhaHeroi(campanhaId: campanhaId, modoPrevia: true);
    final usuarioId = context.watch<UsuarioProvider>().usuario.id;
    return c.papelDe(usuarioId) == PapelCampanha.mestre
        ? CampanhaMestre(campanhaId: campanhaId)
        : CampanhaHeroi(campanhaId: campanhaId);
  }
}

class _TelaMissao extends StatelessWidget {
  const _TelaMissao({
    required this.campanhaId,
    required this.missaoId,
    this.papel,
  });

  final String campanhaId;
  final String missaoId;
  final PapelCampanha? papel;

  @override
  Widget build(BuildContext context) {
    final campanhas = context.watch<CampanhasProvider>();
    final c = campanhas.porId(campanhaId);
    if (c == null) return _semCampanha(campanhas, campanhaId);
    final usuarioId = context.watch<UsuarioProvider>().usuario.id;
    return DetalhesMissao(
      campanhaId: campanhaId,
      missaoId: missaoId,
      papel: papel ?? c.papelDe(usuarioId),
    );
  }
}

Widget _semCampanha(CampanhasProvider campanhas, String id) {
  if (campanhas.carregamento
      case Carregamento.carregando || Carregamento.inicial) {
    return const Scaffold(body: EstadoCarregando());
  }
  AppLog.aviso(TagLog.rota, 'campanha nao existe: $id');
  return const EstadoNaoEncontrado();
}

// grimorio

Widget _listaCompendio(BuildContext context, GoRouterState state) =>
    switch (state.pathParameters[Rotas.tipo]) {
      TipoCompendio.magias => const Magias(),
      TipoCompendio.bestiario => const Bestiario(),
      TipoCompendio.itens => const Itens(),
      TipoCompendio.itensMagicos => const Itens(),
      TipoCompendio.armas => const Itens(aba: AbaItem.armas),
      TipoCompendio.armaduras => const Itens(aba: AbaItem.armaduras),
      TipoCompendio.classes => const Classes(),
      TipoCompendio.especies => const Especies(),
      TipoCompendio.condicoes => const Condicoes(),
      _ => _naoEncontrado(state),
    };

// a tela busca pela key, que nao existe vira nao encontrado
Widget _detalheCompendio(BuildContext context, GoRouterState state) {
  final key = state.pathParameters[Rotas.key] ?? '';
  return switch (state.pathParameters[Rotas.tipo]) {
    TipoCompendio.magias => DetalhesMagia(srdKey: key),
    TipoCompendio.bestiario => DetalhesMonstro(srdKey: key),
    TipoCompendio.classes => DetalhesClasse(srdKey: key),
    TipoCompendio.especies => DetalhesEspecie(srdKey: key),
    TipoCompendio.itens => DetalhesItem(tipo: TipoSrd.item, srdKey: key),
    TipoCompendio.itensMagicos => DetalhesItem(
      tipo: TipoSrd.itemMagico,
      srdKey: key,
    ),
    TipoCompendio.armas => DetalhesItem(tipo: TipoSrd.arma, srdKey: key),
    TipoCompendio.armaduras => DetalhesItem(
      tipo: TipoSrd.armadura,
      srdKey: key,
    ),
    _ => _naoEncontrado(state),
  };
}
