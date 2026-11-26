import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/components/navegacao_bottom_bar.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/main.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/personagem_mock.dart';
import 'package:grimorio/view/characters/ficha/ficha.dart';
import 'package:grimorio/view/grimoire/magias/magias.dart';

void main() {
  Future<void> abrir(WidgetTester tester, [String rota = Rotas.inicio]) async {
    tester.view.physicalSize = const Size(1800, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GrimorioApp(inicial: rota));
    await tester.pumpAndSettle();
  }

  String rotaAtual(WidgetTester tester) =>
      GoRouter.of(tester.element(find.byType(Navigator).first)).state.uri.path;

  Finder naBarra(String texto) => find.descendant(
    of: find.byType(NavegacaoBottomBar),
    matching: find.text(texto),
  );

  testWidgets('abre em /inicio', (tester) async {
    await abrir(tester);
    expect(rotaAtual(tester), Rotas.inicio);
  });

  testWidgets('cada aba vai para a rota certa', (tester) async {
    await abrir(tester);
    const abas = {
      'Heróis': Rotas.herois,
      'Campanhas': Rotas.campanhas,
      'Grimório': Rotas.grimorio,
      'Ajustes': Rotas.ajustes,
      'Início': Rotas.inicio,
    };
    for (final MapEntry(key: aba, value: rota) in abas.entries) {
      await tester.tap(naBarra(aba));
      await tester.pumpAndSettle();
      expect(rotaAtual(tester), rota, reason: aba);
    }
  });

  testWidgets('/herois/<id> abre a ficha', (tester) async {
    await abrir(tester, '${Rotas.herois}/${personagemAtivoMock.id}');
    expect(find.byType(Ficha), findsOneWidget);
    expect(find.text('Nível 5'), findsOneWidget);
  });

  testWidgets('/herois/nao-existe mostra Não encontrado', (tester) async {
    await abrir(tester, '${Rotas.herois}/nao-existe');
    expect(find.text('Não encontrado'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(rotaAtual(tester), Rotas.herois);
  });

  testWidgets('rota que não existe mostra Não encontrado', (tester) async {
    await abrir(tester, '/nada/aqui');
    expect(find.text('Não encontrado'), findsOneWidget);
  });

  testWidgets('campanha que não existe mostra Não encontrado', (tester) async {
    await abrir(tester, '${Rotas.campanhas}/nao-existe');
    expect(find.text('Não encontrado'), findsOneWidget);
  });

  testWidgets('/campanhas/<id> abre a campanha', (tester) async {
    await abrir(tester, '${Rotas.campanhas}/${campanhasMock.first.id}');
    expect(find.text(campanhasMock.first.nome), findsWidgets);
  });

  testWidgets('trocar de aba e voltar mantém o estado da aba', (tester) async {
    await abrir(tester, Rotas.herois);
    await tester.enterText(find.byType(TextField), 'kael');
    await tester.pump();
    expect(find.text('Nenhum herói encontrado.'), findsOneWidget);

    await tester.tap(naBarra('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(naBarra('Heróis'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum herói encontrado.'), findsOneWidget);
  });

  testWidgets('voltar da ficha leva para a raiz da aba', (tester) async {
    await abrir(tester, Rotas.herois);
    await tester.tap(find.text(personagemAtivoMock.nome));
    await tester.pumpAndSettle();
    expect(rotaAtual(tester), '${Rotas.herois}/${personagemAtivoMock.id}');

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();
    expect(rotaAtual(tester), Rotas.herois);
  });

  testWidgets('grimório abre a lista pelo path', (tester) async {
    await abrir(tester, '${Rotas.grimorio}/${TipoCompendio.magias}');
    expect(find.byType(Magias), findsOneWidget);
  });

  testWidgets('item do grimório não tem tela de detalhe', (tester) async {
    await abrir(tester, '${Rotas.grimorio}/${TipoCompendio.itens}/xyz');
    expect(find.text('Não encontrado'), findsOneWidget);
  });
}
