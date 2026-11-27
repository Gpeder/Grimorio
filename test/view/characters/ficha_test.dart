import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:pixelarticons/pixel.dart';

import '../../fixtures/personagem_mock.dart';
import '../../helpers/app_teste.dart';
import '../../helpers/banco_falso.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      telaDeTeste(Ficha(personagemId: personagemAtivoMock.id)),
    );
    await tester.pump();
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
    await tester.pumpWidget(appDeTeste(Rotas.herois));
    await tester.pump();

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

  group('salvar no banco', () {
    Future<BancoFalso> abrirMagias(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final banco = BancoFalso();
      await tester.pumpWidget(
        telaDeTeste(Ficha(personagemId: personagemAtivoMock.id), banco: banco),
      );
      await tester.pump();
      await tester.drag(find.text('Resumo'), const Offset(-200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Magias'));
      await tester.pumpAndSettle();
      return banco;
    }

    testWidgets('toques rápidos salvam uma vez, só a coluna que mudou', (
      tester,
    ) async {
      final banco = await abrirMagias(tester);
      for (final k in ['gema-1-0', 'gema-1-1', 'gema-1-2']) {
        await tester.tap(find.byKey(ValueKey(k)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(banco.vezes('personagens.atualizar'), 0);

      await tester.pump(PersonagensProvider.esperaToque);
      expect(banco.vezes('personagens.atualizar'), 1);
      expect(banco.atualizacoes.single.$2.keys, ['espacos_de_magia']);
    });

    testWidgets('erro ao salvar volta o valor e mostra o aviso', (
      tester,
    ) async {
      final banco = await abrirMagias(tester);
      expect(find.text('6 de 9 livres'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('gema-1-0')));
      await tester.pump();
      expect(find.text('5 de 9 livres'), findsOneWidget);

      banco.proximoErro = const BancoErro(TipoErroBanco.semConexao);
      await tester.pump(PersonagensProvider.esperaToque);
      await tester.pumpAndSettle();

      expect(find.text('6 de 9 livres'), findsOneWidget);
      expect(find.text('Sem conexão. Confira a internet.'), findsOneWidget);
    });
  });
}
