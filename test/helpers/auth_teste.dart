import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'app_teste.dart';
import 'auth_falso.dart';

// app deslogado aberto numa rota de login
Future<AuthServiceFalso> abrirAuth(
  WidgetTester tester,
  String rota, {
  AuthServiceFalso? auth,
}) async {
  tester.view.physicalSize = const Size(1800, 2796);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final service = auth ?? AuthServiceFalso(logado: false);
  await tester.pumpWidget(appDeTeste(rota, auth: service));
  await tester.pumpAndSettle();
  return service;
}

String rotaAtual(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Navigator).first)).state.uri.path;

Future<void> digitar(WidgetTester tester, String chave, String texto) async {
  final campo = find.descendant(
    of: find.byKey(ValueKey(chave)),
    matching: find.byType(EditableText),
  );
  await tester.ensureVisible(campo);
  await tester.enterText(campo, texto);
  await tester.pump();
}

Future<void> tocarTexto(WidgetTester tester, String texto) async {
  final alvo = find.text(texto).last;
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

// texto com o e-mail destacado e um Text.rich
Finder textoRico(String texto) => find.text(texto, findRichText: true);

// nada de erro tecnico na tela
void semErroTecnico() {
  for (final termo in ['Exception', 'AuthException', 'Supabase', 'Null']) {
    expect(find.textContaining(termo), findsNothing, reason: termo);
  }
}
