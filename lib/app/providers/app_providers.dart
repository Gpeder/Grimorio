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
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.child,
    this.api,
    this.auth,
    this.perfis,
  });

  final Widget child;

  // teste passa um cliente com dio falso
  final ApiClient? api;

  // teste passa os falsos do supabase
  final AuthService? auth;
  final PerfilService? perfis;

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
        // herois
        ChangeNotifierProvider(create: (_) => PersonagensProvider()),
        // campanhas
        ChangeNotifierProvider(create: (_) => CampanhasProvider()),
        // usuario e preferencias, segue o login
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => UsuarioProvider(
            auth: context.read(),
            perfis: context.read(),
            aoEntrar: (id) {
              context.read<PersonagensProvider>().adotarMock(id);
              context.read<CampanhasProvider>().adotarMock(id);
            },
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
