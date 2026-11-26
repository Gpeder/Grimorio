import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/view/characters/characters.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/view/characters/new_hero/new_hero.dart';

void main() {
  group('tela', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first
        ..physicalSize = const Size(400, 900)
        ..devicePixelRatio = 1;
    });

    tearDown(() {
      TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });

    ElevatedButton continuar(WidgetTester tester) =>
        tester.widget(find.widgetWithText(ElevatedButton, 'Continuar'));

    testWidgets('abre no passo 1 com o Continuar desabilitado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const NewHero()),
      );

      expect(find.text('PASSO 1 DE 9'), findsOneWidget);
      expect(continuar(tester).onPressed, isNull);
    });

    testWidgets('escolher Elfo libera o Continuar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const NewHero()),
      );

      await tester.tap(find.text('Elfo'));
      await tester.pump();

      expect(continuar(tester).onPressed, isNotNull);
    });

    testWidgets('cria um Clérigo Elfo e ele aparece como ativo', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const Characters()),
      );

      Future<void> tocar(String texto) async {
        final alvo = find.text(texto).first;
        await tester.ensureVisible(alvo);
        await tester.pumpAndSettle();
        await tester.tap(alvo);
        await tester.pumpAndSettle();
      }

      Future<void> avancar() async {
        expect(continuar(tester).onPressed, isNotNull);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
        await tester.pumpAndSettle();
      }

      await tocar('Novo herói');
      expect(find.text('PASSO 1 DE 9'), findsOneWidget);

      await tocar('Elfo');
      await avancar();

      await tocar('Clérigo');
      expect(continuar(tester).onPressed, isNull);
      await tocar('Vida');
      await avancar();

      final campos = find.byType(TextFormField);
      const valores = ['10', '12', '14', '12', '17', '13'];
      for (var i = 0; i < valores.length; i++) {
        await tester.enterText(campos.at(i), valores[i]);
      }
      await tester.pumpAndSettle();
      await avancar();

      await tocar('Acólito');
      await avancar();

      await tocar('Medicina');
      await tocar('História');
      await avancar();

      await tocar('Maça');
      await tocar('Cota de escamas');
      await tocar('Besta leve + 20 virotes');
      await tocar('Pacote de sacerdote');
      await avancar();

      // sab 17 da +3, entao 4 preparadas
      for (final m in ['Chama Sagrada', 'Luz', 'Taumaturgia']) {
        await tocar(m);
      }
      for (final m in ['Comando', 'Palavra Curativa', 'Escudo da Fé']) {
        await tocar(m);
      }
      expect(continuar(tester).onPressed, isNull);
      await tocar('Raio Guia');
      await avancar();

      await tester.enterText(find.byKey(const ValueKey('nome')), 'Lyra');
      await tocar('Neutro e Bom');
      await avancar();

      expect(find.text('PASSO 9 DE 9'), findsOneWidget);
      expect(find.text('Elfa · Clériga (Vida)'), findsOneWidget);
      expect(find.textContaining('= 10. Sem rolagem.'), findsOneWidget);
      expect(
        find.textContaining(
          'cota de escamas 14 + DES (máx. 2) + escudo 2 = 18',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Despertar herói'));
      await tester.pumpAndSettle();

      expect(find.text('Lyra'), findsOneWidget);
      expect(find.text('Lyra despertou!'), findsOneWidget);
      expect(find.text('ATIVA'), findsOneWidget);

      // ficha abre com antecedente e magias
      await tester.tap(find.text('Lyra'));
      await tester.pumpAndSettle();
      expect(find.byType(Ficha), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Acólito'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(Ficha),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Neutro e Bom'), findsOneWidget);

      await tester.drag(find.text('Resumo'), const Offset(-200, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Magias'));
      await tester.pumpAndSettle();
      expect(find.text('Raio Guia'), findsOneWidget);
      expect(find.text('Bênção'), findsOneWidget);
      expect(find.text('Chama Sagrada'), findsOneWidget);
    });
  });
}
