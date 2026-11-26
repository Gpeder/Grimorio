// `Characters` do Flutter (pacote characters) colide com a tela de personagens.
import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:grimorio/app/components/barra_navegacao.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/campaign/campaign.dart';
import 'package:grimorio/characters/characters.dart';
import 'package:grimorio/grimoire/grimoire.dart';
import 'package:grimorio/home/home.dart';
import 'package:grimorio/settings/settings.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const abaAjustes = 4;

  // Troca de aba a partir de qualquer tela dentro do shell.
  static void irPara(BuildContext context, int aba) {
    context.findAncestorStateOfType<_AppShellState>()?._irPara(aba);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[
    Home(),
    Characters(),
    Campaign(),
    Grimoire(),
    Settings(),
  ];

  static const _radius = BorderRadius.all(Radius.circular(AppSpacing.radius));

  void _irPara(int aba) {
    if (aba == _index) return;
    setState(() => _index = aba);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomBar(
        layout: const BottomBarLayout.adaptive(
          maxWidth: 480,
          offset: 12,
          borderRadius: _radius,
        ),
        theme: BottomBarThemeData(
          barDecoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _radius,
            border: Border.all(color: AppColors.onSecondary, width: 1.5),
          ),
          iconDecoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          items: const BottomBarItemThemeData(
            centerAction: BarraNavegacao.temaBotaoCentral,
          ),
        ),
        body: IndexedStack(index: _index, children: _pages),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: BarraNavegacao(selectedIndex: _index, onSelected: _irPara),
        ),
      ),
    );
  }
}
