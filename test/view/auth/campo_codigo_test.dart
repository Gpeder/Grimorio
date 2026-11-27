import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/view/auth/components/campo_codigo.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/auth_falso.dart';

void main() {
  Future<List<String>> abrir(WidgetTester tester) async {
    final completos = <String>[];
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: CampoCodigo(controller: controller, onCompleto: completos.add),
        ),
      ),
    );
    return completos;
  }

  String caixa(WidgetTester tester, int i) =>
      tester.widget<Text>(find.byKey(ValueKey('codigo-$i'))).data ?? '';

  testWidgets('colar "123456" preenche as 6 caixas e chama onCompleto', (
    tester,
  ) async {
    final completos = await abrir(tester);
    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pump();

    expect(
      [for (var i = 0; i < 6; i++) caixa(tester, i)],
      ['1', '2', '3', '4', '5', '6'],
    );
    expect(completos, ['123456']);
  });

  testWidgets('aceita só números e no máximo 6', (tester) async {
    final completos = await abrir(tester);
    await tester.enterText(find.byType(EditableText), '12a3');
    await tester.pump();
    expect(caixa(tester, 2), '3');
    expect(caixa(tester, 3), '');
    expect(completos, isEmpty);

    await tester.enterText(find.byType(EditableText), '12345678');
    await tester.pump();
    expect(caixa(tester, 5), '6');
  });

  testWidgets('apagar volta para a caixa anterior', (tester) async {
    await abrir(tester);
    await tester.enterText(find.byType(EditableText), '123');
    await tester.pump();
    await tester.enterText(find.byType(EditableText), '12');
    await tester.pump();
    expect(caixa(tester, 1), '2');
    expect(caixa(tester, 2), '');
  });

  // celular pequeno: nada estoura
  for (final rota in [Rotas.entrar, Rotas.cadastro, Rotas.recuperarSenha]) {
    testWidgets('$rota cabe numa tela de 320 x 568', (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        appDeTeste(rota, auth: AuthServiceFalso(logado: false)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
