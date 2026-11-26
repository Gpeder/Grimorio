import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/personagem_mock.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/settings/components/ajuste_tile.dart';
import 'package:grimorio/view/settings/components/perfil_card.dart';
import 'package:grimorio/view/settings/settings.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const Settings()),
    );
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  // A lista é preguiçosa: rola até a linha existir antes de procurar nela.
  Future<Finder> rolarAte(WidgetTester tester, String titulo) async {
    final alvo = find.widgetWithText(AjusteTile, titulo);
    await tester.scrollUntilVisible(
      alvo,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    return alvo;
  }

  Finder noPerfil(String texto) =>
      find.descendant(of: find.byType(PerfilCard), matching: find.text(texto));

  testWidgets('mostra nome, e-mail e os 3 contadores', (tester) async {
    await abrir(tester);

    expect(noPerfil(usuarioMock.nome), findsOneWidget);
    expect(noPerfil(usuarioMock.email), findsOneWidget);
    expect(noPerfil('Mestre e Jogador'), findsOneWidget);

    expect(noPerfil('HERÓIS'), findsOneWidget);
    expect(noPerfil('CAMPANHAS'), findsOneWidget);
    expect(noPerfil('SESSÕES'), findsOneWidget);
    expect(noPerfil('—'), findsOneWidget);
    expect(noPerfil('${personagensMock.length}'), findsAtLeastNWidgets(1));
    expect(noPerfil('${campanhasMock.length}'), findsAtLeastNWidgets(1));
  });

  testWidgets('escolher "Pontos de magia" muda o valor exibido', (
    tester,
  ) async {
    await abrir(tester);
    final linha = await rolarAte(tester, 'Sistema de magia');

    expect(
      find.descendant(of: linha, matching: find.text('Espaços de magia')),
      findsOneWidget,
    );

    await tocar(tester, linha);
    expect(find.text('Pontos de magia é uma regra opcional'), findsOneWidget);

    await tocar(
      tester,
      find.widgetWithText(RadioListTile<SistemaMagia>, 'Pontos de magia'),
    );

    expect(
      find.descendant(of: linha, matching: find.text('Pontos de magia')),
      findsOneWidget,
    );
    expect(find.text('Espaços de magia'), findsNothing);
  });

  testWidgets('desligar "Vibrar ao tocar" muda o Switch', (tester) async {
    await abrir(tester);

    final chave = find.descendant(
      of: await rolarAte(tester, 'Vibrar ao tocar'),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(chave).value, isTrue);

    await tocar(tester, chave);
    expect(tester.widget<Switch>(chave).value, isFalse);
  });

  testWidgets('editar perfil valida o e-mail e atualiza o nome', (
    tester,
  ) async {
    await abrir(tester);

    await tocar(tester, find.byTooltip('Editar perfil'));

    final nome = find.byKey(const ValueKey('perfil-nome'));
    final email = find.byKey(const ValueKey('perfil-email'));

    await tester.enterText(nome, 'Aragorn');
    await tester.enterText(email, 'sem-arroba');
    await tocar(tester, find.text('Salvar'));
    expect(find.text('E-mail inválido.'), findsOneWidget);
    expect(noPerfil('Aragorn'), findsNothing);

    await tester.enterText(email, 'aragorn@email.com');
    await tocar(tester, find.text('Salvar'));

    expect(noPerfil('Aragorn'), findsOneWidget);
    expect(noPerfil('aragorn@email.com'), findsOneWidget);
    expect(find.text('Perfil atualizado'), findsOneWidget);
  });
}
