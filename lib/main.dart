import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/router/app_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/widgets/erro_widget_card.dart';

void main() {
  configurarErros();
  runApp(const GrimorioApp());
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
  const GrimorioApp({super.key, this.inicial = Rotas.inicio});

  // rota de abertura, os testes mudam
  final String inicial;

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
