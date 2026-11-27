import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/components/navegacao_bottom_bar.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:pixelarticons/pixel.dart';

import '../helpers/app_teste.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1800, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appDeTeste(Rotas.inicio));
    await tester.pumpAndSettle();
  }

  int abaAtual(WidgetTester tester) =>
      tester.widget<IndexedStack>(find.byType(IndexedStack).first).index!;

  Finder naBarra(String texto) => find.descendant(
    of: find.byType(NavegacaoBottomBar),
    matching: find.text(texto),
  );

  testWidgets('GrimorioApp usa o tema escuro', (tester) async {
    await tester.pumpWidget(appDeTeste(Rotas.inicio));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.brightness, Brightness.dark);
  });

  testWidgets('a barra tem 5 itens, com Campanhas no meio', (tester) async {
    await abrir(tester);

    for (final label in [
      'Início',
      'Heróis',
      'Campanhas',
      'Grimório',
      'Ajustes',
    ]) {
      expect(naBarra(label), findsOneWidget);
    }
    expect(
      find.descendant(
        of: find.byType(NavegacaoBottomBar),
        matching: find.byType(Expanded),
      ),
      findsNWidgets(5),
    );
    expect(abaAtual(tester), 0);
  });

  testWidgets('tocar em Campanhas troca para a página de campanhas', (
    tester,
  ) async {
    await abrir(tester);

    await tester.tap(naBarra('Campanhas'));
    await tester.pumpAndSettle();
    expect(abaAtual(tester), NavegacaoBottomBar.indiceCentral);
  });

  testWidgets('a parte do botão central acima da barra recebe o toque', (
    tester,
  ) async {
    await abrir(tester);

    // icone de 26 no centro do botao de 54, topo fica 27 acima
    final icone = tester.getRect(
      find.descendant(
        of: find.byType(BottomBarCenterAction),
        matching: find.byIcon(Pixel.map),
      ),
    );
    final pontoAcima = Offset(icone.center.dx, icone.center.dy - 20);
    expect(
      pontoAcima.dy,
      lessThan(tester.getRect(find.byType(NavegacaoBottomBar)).top - 6),
    );

    await tester.tapAt(pontoAcima);
    await tester.pumpAndSettle();
    expect(abaAtual(tester), NavegacaoBottomBar.indiceCentral);
  });

  testWidgets('tocar em Ajustes mostra a tela de Ajustes', (tester) async {
    await abrir(tester);

    await tester.tap(naBarra('Ajustes'));
    await tester.pumpAndSettle();

    expect(abaAtual(tester), 4);
    expect(find.text('Ajustes'), findsNWidgets(2));
    expect(find.text('Gustavo'), findsOneWidget);
  });

  testWidgets('o atalho da Home leva para Ajustes', (tester) async {
    await abrir(tester);

    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();

    expect(abaAtual(tester), 4);
  });
}
