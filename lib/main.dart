import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/router/app_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_theme.dart';

void main() {
  runApp(const GrimorioApp());
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
