import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/components/navegacao_bottom_bar.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

// shell das 5 abas, cada uma guarda o proprio estado
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _radius = BorderRadius.all(Radius.circular(AppSpacing.radius));

  // tocar na aba ativa volta para a raiz dela
  void _irPara(int aba) => navigationShell.goBranch(
    aba,
    initialLocation: aba == navigationShell.currentIndex,
  );

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
            centerAction: NavegacaoBottomBar.temaBotaoCentral,
          ),
        ),
        body: navigationShell,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: NavegacaoBottomBar(
            selectedIndex: navigationShell.currentIndex,
            onSelected: _irPara,
          ),
        ),
      ),
    );
  }
}
