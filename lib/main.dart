import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/config/ambiente.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/router/app_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/widgets/erro_widget_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configurarErros();
  await iniciarSupabase();
  runApp(const GrimorioApp());
}

// sem env.json o app abre, mas o login falha
Future<void> iniciarSupabase() async {
  if (!Ambiente.configurado) {
    AppLog.erro(
      TagLog.app,
      'env.json sem SUPABASE_URL/SUPABASE_ANON_KEY. '
      'rode com --dart-define-from-file=env.json',
    );
    return;
  }
  await Supabase.initialize(
    url: Ambiente.supabaseUrl,
    publishableKey: Ambiente.supabaseAnonKey,
  );
}

// todo erro vai para o log, o usuario nunca ve detalhe tecnico
void configurarErros() {
  FlutterError.onError = (details) {
    AppLog.erro(
      TagLog.flutter,
      details.exceptionAsString(),
      erro: details.exception,
      stack: details.stack,
    );
    // em debug continua o erro vermelho padrao
    if (kDebugMode) FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (erro, stack) {
    AppLog.erro(TagLog.app, 'erro fora do flutter', erro: erro, stack: stack);
    return true;
  };

  if (kReleaseMode) ErrorWidget.builder = (_) => const ErroWidgetCard();
}

class GrimorioApp extends StatefulWidget {
  const GrimorioApp({super.key, this.inicial = Rotas.inicio, this.api});

  // rota de abertura, os testes mudam
  final String inicial;

  // teste passa um cliente com dio falso
  final ApiClient? api;

  @override
  State<GrimorioApp> createState() => _GrimorioAppState();
}

class _GrimorioAppState extends State<GrimorioApp> {
  late final GoRouter appRouter = criarAppRouter(inicial: widget.inicial);

  @override
  void dispose() {
    appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      api: widget.api,
      child: MaterialApp.router(
        title: 'Grimório RPG',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
