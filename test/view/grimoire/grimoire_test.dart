import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/view/grimoire/grimoire.dart';
import 'package:grimorio/widgets/etiqueta.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const Grimoire()),
    );
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  Finder filtro(String rotulo) => find.widgetWithText(Etiqueta, rotulo);

  testWidgets('mostra as 6 categorias com as contagens do mock', (
    tester,
  ) async {
    await abrir(tester);

    for (final nome in [
      'Classes',
      'Espécies',
      'Magias',
      'Bestiário',
      'Itens',
      'Condições',
    ]) {
      expect(find.text(nome), findsOneWidget);
    }
    expect(find.text('${classesMock.length} classes'), findsOneWidget);
    expect(find.text('${especiesMock.length} espécies'), findsOneWidget);
    expect(find.text('${magiasCompendio.length} magias'), findsOneWidget);
    expect(find.text('${monstrosMock.length} criaturas'), findsOneWidget);
    expect(find.text('${itensMock.length} itens'), findsOneWidget);
    expect(find.text('${condicoesMock.length} condições'), findsOneWidget);
  });

  testWidgets('buscar "cura" agrupa magias e itens', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextField), 'cura');
    await tester.pumpAndSettle();

    expect(find.text('Classes'), findsNothing);
    expect(find.text('Magias'), findsOneWidget);
    expect(find.text('Curar Ferimentos'), findsOneWidget);
    expect(find.text('Itens'), findsOneWidget);
    expect(find.text('Poção de Cura'), findsOneWidget);
  });

  testWidgets('Magias: filtrar Truques esconde o 1º círculo', (tester) async {
    await abrir(tester);
    await tocar(tester, find.text('Magias'));

    expect(find.text('Curar Ferimentos'), findsOneWidget);

    await tocar(tester, filtro('Truques'));
    expect(find.text('Curar Ferimentos'), findsNothing);
    expect(find.text('Luz'), findsOneWidget);
  });

  testWidgets('Bestiário: ND 2–4 mostra só o Ogro', (tester) async {
    await abrir(tester);
    await tocar(tester, find.text('Bestiário'));

    await tocar(tester, filtro('ND 2–4'));
    expect(find.text('Ogro'), findsOneWidget);
    expect(find.text('Goblin'), findsNothing);
    expect(find.text('Jovem Dragão Verde'), findsNothing);
  });

  testWidgets('ficha do Goblin mostra ND, CA e o ataque', (tester) async {
    await abrir(tester);
    await tocar(tester, find.text('Bestiário'));
    await tocar(tester, find.text('Goblin'));

    expect(find.textContaining('ND 1/4'), findsOneWidget);
    expect(find.textContaining('Classe de Armadura 15'), findsOneWidget);
    expect(find.text('+4 para acertar'), findsWidgets);

    await tocar(tester, find.bySemanticsLabel('Voltar'));
    expect(find.text('Goblin'), findsOneWidget);
  });

  testWidgets('listas e detalhes abrem sem erro de layout em 360 px', (
    tester,
  ) async {
    await abrir(tester);
    final voltar = find.bySemanticsLabel('Voltar');

    for (final (categoria, detalhe) in [
      ('Classes', 'Clérigo'),
      ('Classes', 'Bruxo'),
      ('Espécies', 'Elfo'),
      ('Magias', 'Guardiões Espirituais'),
      ('Bestiário', 'Jovem Dragão Verde'),
    ]) {
      await tocar(tester, find.text(categoria));
      await tocar(tester, find.text(detalhe).first);
      if (categoria == 'Classes') {
        await tocar(tester, find.text('Ver níveis 6 a 20 ›'));
      }
      await tocar(tester, voltar.first);
      await tocar(tester, voltar.first);
    }

    await tocar(tester, find.text('Itens'));
    await tocar(tester, find.text('Espada Vorpal'));
    expect(find.text('Requer sintonia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Condições: abre uma por vez', (tester) async {
    await abrir(tester);
    await tocar(tester, find.text('Condições'));

    const envenenado = 'Desvantagem em jogadas de ataque e testes de atributo.';
    expect(find.text(envenenado), findsNothing);

    await tocar(tester, find.text('Envenenado'));
    expect(find.text(envenenado), findsOneWidget);

    await tocar(tester, find.text('Cego'));
    expect(find.text(envenenado), findsNothing);
  });
}
