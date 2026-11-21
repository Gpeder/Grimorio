// `Characters` do Flutter (pacote characters) colide com a tela de personagens.
import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/campaign/campaign.dart';
import 'package:grimorio/characters/characters.dart';
import 'package:grimorio/grimoire/grimoire.dart';
import 'package:grimorio/home/home.dart';
import 'package:pixelarticons/pixel.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[Home(), Characters(), Campaign(), Grimoire()];

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

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
            border: Border.all(color: AppColors.secondary, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          iconDecoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          items: BottomBarItemThemeData(
            color: AppColors.onSurface.withValues(alpha: 0.6),
            selectedColor: AppColors.alerta,
            iconSize: 24,
            labelStyle: labelStyle,
            selectedLabelStyle: labelStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
            haptics: BottomBarHaptics.selectionClick,
          ),
        ),
        body: IndexedStack(index: _index, children: _pages),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: BottomBarItems(
            selectedIndex: _index,
            onSelected: (i) => setState(() => _index = i),
            scrollToStartOnReselect: true,
            indicator: BottomBarIndicator.pill(
              color: AppColors.primary.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            children: const [
              BottomBarItem(icon: Icon(Pixel.home), label: Text('Início')),
              BottomBarItem(icon: Icon(Pixel.users), label: Text('Heróis')),
              BottomBarItem(icon: Icon(Pixel.map), label: Text('Campanhas')),
              BottomBarItem(
                icon: Icon(Pixel.bookopen),
                label: Text('Grimório'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
