import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/open5e/classe_service.dart';
import 'package:grimorio/service/open5e/condicao_service.dart';
import 'package:grimorio/service/open5e/especie_service.dart';
import 'package:grimorio/service/open5e/item_service.dart';
import 'package:grimorio/service/open5e/magia_service.dart';
import 'package:grimorio/service/open5e/monstro_service.dart';
import 'package:grimorio/service/supabase/auth_service.dart';
import 'package:grimorio/service/supabase/perfil_service.dart';
import 'package:grimorio/service/supabase/servicos_banco.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.child,
    this.api,
    this.auth,
    this.perfis,
    this.banco,
  });

  final Widget child;

  // teste passa um cliente com dio falso
  final ApiClient? api;

  // teste passa os falsos do supabase
  final AuthService? auth;
  final PerfilService? perfis;
  final ServicosBanco? banco;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // cliente da api
        Provider<ApiClient>(
          create: (_) => api ?? ApiClient(),
          dispose: (_, cliente) => cliente.fechar(),
        ),
        // services open5e
        ProxyProvider<ApiClient, MagiaService>(
          update: (_, cliente, _) => MagiaService(cliente),
        ),
        ProxyProvider<ApiClient, MonstroService>(
          update: (_, cliente, _) => MonstroService(cliente),
        ),
        ProxyProvider<ApiClient, ItemService>(
          update: (_, cliente, _) => ItemService(cliente),
        ),
        ProxyProvider<ApiClient, ClasseService>(
          update: (_, cliente, _) => ClasseService(cliente),
        ),
        ProxyProvider<ApiClient, EspecieService>(
          update: (_, cliente, _) => EspecieService(cliente),
        ),
        ProxyProvider<ApiClient, CondicaoService>(
          update: (_, cliente, _) => CondicaoService(cliente),
        ),
        // supabase
        Provider<AuthService>(create: (_) => auth ?? SupabaseAuthService()),
        Provider<PerfilService>(
          create: (_) => perfis ?? SupabasePerfilService(),
        ),
        // sessao
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read()),
        ),
        // tabelas do banco
        Provider<ServicosBanco>(
          create: (_) => banco ?? ServicosBanco.supabase(),
        ),
        // herois
        ChangeNotifierProvider(
          create: (context) {
            final banco = context.read<ServicosBanco>();
            return PersonagensProvider(
              banco.personagens,
              realtime: banco.realtime,
            );
          },
        ),
        // campanhas
        ChangeNotifierProvider(
          create: (context) {
            final banco = context.read<ServicosBanco>();
            return CampanhasProvider(
              campanhas: banco.campanhas,
              mesa: banco.mesa,
              missoes: banco.missoes,
              npcs: banco.npcs,
              personagens: context.read(),
              perfis: context.read(),
              realtime: banco.realtime,
            );
          },
        ),
        // usuario e preferencias, segue o login; herois e campanhas juntos
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => UsuarioProvider(
            auth: context.read(),
            perfis: context.read(),
            // fora do build: o login pode chegar enquanto a arvore monta
            aoEntrar: (id) => scheduleMicrotask(() {
              context.read<PersonagensProvider>().carregar(id);
              context.read<CampanhasProvider>().carregar(id);
            }),
            aoSair: () => scheduleMicrotask(() {
              context.read<PersonagensProvider>().limpar();
              context.read<CampanhasProvider>().limpar();
            }),
          ),
        ),
        // listas do srd
        ChangeNotifierProvider(
          create: (context) => CompendioProvider(
            magias: context.read(),
            monstros: context.read(),
            itens: context.read(),
            classes: context.read(),
            especies: context.read(),
            condicoes: context.read(),
          ),
        ),
      ],
      child: child,
    );
  }
}
