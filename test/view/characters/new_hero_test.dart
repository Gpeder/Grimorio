import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/view/characters/characters.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/view/characters/new_hero/new_hero.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/hero_options.dart';
import 'package:grimorio/model/hero_options_mock.dart';

SpeciesOption _especie(String key) =>
    especiesMock.firstWhere((e) => e.key == key);

void main() {
  group('bônus de espécie', () {
    test('Elfo + Alto Elfo dá DES +2 e INT +1', () {
      final elfo = _especie('srd_elf');
      final alto = elfo.subespecies.single;

      int bonus(Ability a) =>
          bonusDeEspecie(a, especie: elfo, subespecie: alto);

      expect(bonus(Ability.destreza), 2);
      expect(bonus(Ability.inteligencia), 1);
      expect(bonus(Ability.forca), 0);
    });

    test('Meio-Elfo dá CAR +2 e +1 nos 2 atributos escolhidos', () {
      final meioElfo = _especie('srd_half-elf');
      const livres = {Ability.destreza, Ability.sabedoria};

      int bonus(Ability a) =>
          bonusDeEspecie(a, especie: meioElfo, livres: livres);

      expect(bonus(Ability.carisma), 2);
      expect(bonus(Ability.destreza), 1);
      expect(bonus(Ability.sabedoria), 1);
      expect(bonus(Ability.forca), 0);
    });
  });

  group('compra de pontos', () {
    test('27 pontos é válido', () {
      const valores = [15, 15, 15, 8, 8, 8];
      expect(pontosGastos(valores), 27);
      expect(compraValida(valores), isTrue);
    });

    test('28 pontos não é válido', () {
      const valores = [15, 15, 15, 9, 8, 8];
      expect(pontosGastos(valores), 28);
      expect(compraValida(valores), isFalse);
    });

    test('valor fora de 8–15 não é válido', () {
      expect(compraValida(const [16, 8, 8, 8, 8, 8]), isFalse);
    });
  });

  group('HP do nível 1', () {
    test('Clérigo com CON 14 tem 10', () {
      expect(hpNivel1(dadoDeVida: 8, constituicao: 14), 10);
    });

    test('Anão da Colina com CON 16 tem 12', () {
      expect(hpNivel1(dadoDeVida: 8, constituicao: 16, extraPorNivel: 1), 12);
    });

    test('Bárbaro com CON 14 tem 14', () {
      expect(hpNivel1(dadoDeVida: 12, constituicao: 14), 14);
    });
  });

  group('CA', () {
    test('cota de escamas + DES 14 + escudo = 18', () {
      final ca = calcularCA(
        destreza: 14,
        constituicao: 10,
        sabedoria: 10,
        armadura: TipoArmadura.escamas,
        escudo: true,
      );
      expect(ca, 18);
    });

    test('Monge com DES 16 e SAB 14 = 15', () {
      final ca = calcularCA(
        destreza: 16,
        constituicao: 10,
        sabedoria: 14,
        classeKey: 'srd_monk',
      );
      expect(ca, 15);
    });
  });

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

      // SAB 17 → +3 → 4 preparadas.
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

      // A ficha abre com o antecedente e as magias escolhidas.
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
