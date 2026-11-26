import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/model/personagem_mock.dart';
import 'package:grimorio/view/characters/characters.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:pixelarticons/pixel.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Ficha(personagem: personagemAtivoMock),
      ),
    );
  }

  testWidgets('mostra nome, nível e a aba Resumo', (tester) async {
    await abrir(tester);

    expect(find.text('Elyndra'), findsWidgets);
    expect(find.text('Nível 5'), findsOneWidget);
    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('Salvaguardas'), findsOneWidget);
  });

  testWidgets('dano de 5 baixa o HP de 32 para 27', (tester) async {
    await abrir(tester);
    expect(find.text('32 / 38'), findsOneWidget);

    await tester.tap(find.byIcon(Pixel.minus));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('27 / 38'), findsOneWidget);
  });

  testWidgets('aba Magias mostra os espaços e a gema muda o contador', (
    tester,
  ) async {
    await abrir(tester);

    // em 360 a aba magias fica fora, precisa rolar
    await tester.drag(find.text('Resumo'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Magias'));
    await tester.pumpAndSettle();
    expect(find.text('Espaços de magia'), findsOneWidget);
    expect(find.text('6 de 9 livres'), findsOneWidget);

    final gema = find.byKey(const ValueKey('gema-1-0'));
    await tester.tap(gema);
    await tester.pumpAndSettle();

    expect(find.text('5 de 9 livres'), findsOneWidget);
  });

  testWidgets('todas as abas abrem sem erro de layout em 360 px', (
    tester,
  ) async {
    await abrir(tester);

    final barra = find.descendant(
      of: find.byType(FichaTabs),
      matching: find.byType(Scrollable),
    );
    final tela = find.byType(CustomScrollView);

    for (final aba in abasFicha) {
      final alvo = find.descendant(
        of: find.byType(FichaTabs),
        matching: find.text(aba),
      );
      await tester.scrollUntilVisible(alvo, 80, scrollable: barra);
      await tester.tap(alvo);
      await tester.pumpAndSettle();

      await tester.fling(tela, const Offset(0, -3000), 3000);
      await tester.pumpAndSettle();
      await tester.fling(tela, const Offset(0, 3000), 3000);
      await tester.pumpAndSettle();
    }
    expect(find.text('Nova anotação'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mudanças voltam para Personagens e continuam ao reabrir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const Characters()),
    );

    Future<void> abrirMagias() async {
      await tester.tap(find.text('Elyndra'));
      await tester.pumpAndSettle();
      await tester.drag(find.text('Resumo'), const Offset(-200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Magias'));
      await tester.pumpAndSettle();
    }

    await abrirMagias();
    await tester.tap(find.byKey(const ValueKey('gema-1-0')));
    await tester.pumpAndSettle();
    expect(find.text('5 de 9 livres'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(Ficha), findsNothing);

    await abrirMagias();
    expect(find.text('5 de 9 livres'), findsOneWidget);
  });
}
