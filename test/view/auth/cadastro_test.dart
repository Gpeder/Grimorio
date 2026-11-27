import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/auth/components/campo_codigo.dart';
import 'package:grimorio/view/auth/confirmar_email.dart';
import 'package:grimorio/view/home/home.dart';

import '../../helpers/auth_falso.dart';
import '../../helpers/auth_teste.dart';

void main() {
  Future<void> preencher(
    WidgetTester tester, {
    String nome = 'Lia',
    String email = 'lia@email.com',
    String senha = 'abcd1234',
    String? confirmar,
  }) async {
    await digitar(tester, 'cadastro-nome', nome);
    await digitar(tester, 'cadastro-email', email);
    await digitar(tester, 'cadastro-senha', senha);
    await digitar(tester, 'cadastro-confirmar', confirmar ?? senha);
  }

  Finder campoCodigo() => find.descendant(
    of: find.byType(CampoCodigo),
    matching: find.byType(EditableText),
  );

  Future<AuthServiceFalso> irParaConfirmar(WidgetTester tester) async {
    final auth = await abrirAuth(tester, Rotas.cadastro);
    await preencher(tester);
    await tocarTexto(tester, 'Criar conta');
    return auth;
  }

  testWidgets('vazio mostra os erros de cada campo', (tester) async {
    await abrirAuth(tester, Rotas.cadastro);
    await tocarTexto(tester, 'Criar conta');

    expect(find.text('Digite seu nome.'), findsOneWidget);
    expect(find.text('E-mail inválido.'), findsOneWidget);
    expect(
      find.text('Mínimo 8 caracteres, com letra e número.'),
      findsOneWidget,
    );
  });

  testWidgets('senhas diferentes mostram "As senhas não batem."', (
    tester,
  ) async {
    final auth = await abrirAuth(tester, Rotas.cadastro);
    await preencher(tester, confirmar: 'abcd1235');
    await tocarTexto(tester, 'Criar conta');

    expect(find.text('As senhas não batem.'), findsOneWidget);
    expect(auth.vezes('cadastrar'), 0);
  });

  testWidgets('e-mail que já tem conta mostra a mensagem', (tester) async {
    await abrirAuth(tester, Rotas.cadastro);
    await preencher(tester, email: usuarioMock.email);
    await tocarTexto(tester, 'Criar conta');

    expect(
      find.text('Esse e-mail já tem conta. Tente entrar.'),
      findsOneWidget,
    );
    semErroTecnico();
  });

  testWidgets('ok abre Confirmar e-mail com o e-mail na tela', (tester) async {
    await irParaConfirmar(tester);

    expect(find.byType(ConfirmarEmail), findsOneWidget);
    expect(rotaAtual(tester), Rotas.confirmarEmailCompleto);
    expect(
      textoRico('Mandamos um código de 6 números para lia@email.com.'),
      findsOneWidget,
    );
  });

  testWidgets('código errado avisa e o certo entra no Início', (tester) async {
    await irParaConfirmar(tester);

    await tester.enterText(campoCodigo(), '000000');
    await tester.pumpAndSettle();
    expect(find.text('Código errado ou vencido.'), findsOneWidget);
    semErroTecnico();

    await tester.enterText(campoCodigo(), '123456');
    await tester.pumpAndSettle();

    expect(rotaAtual(tester), Rotas.inicio);
    expect(find.byType(Home), findsOneWidget);
    expect(find.text('Conta criada. Bem-vindo!'), findsOneWidget);
  });

  testWidgets('Reenviar fica desativado e volta depois de 60 s', (
    tester,
  ) async {
    final auth = await irParaConfirmar(tester);

    TextButton reenviar() => tester.widget<TextButton>(
      find.ancestor(
        of: find.textContaining('Reenviar'),
        matching: find.byType(TextButton),
      ),
    );
    expect(find.text('Reenviar em 1:00'), findsOneWidget);
    expect(reenviar().onPressed, isNull);

    await tester.pump(const Duration(seconds: 18));
    expect(find.text('Reenviar em 0:42'), findsOneWidget);

    await tester.pump(const Duration(seconds: 42));
    await tester.pumpAndSettle();
    expect(find.text('Reenviar código'), findsOneWidget);
    expect(reenviar().onPressed, isNotNull);

    await tocarTexto(tester, 'Reenviar código');
    expect(auth.vezes('reenviarConfirmacao'), 1);
    expect(find.text('Reenviar em 1:00'), findsOneWidget);
  });

  testWidgets('"Trocar e-mail" volta para o Cadastro', (tester) async {
    await irParaConfirmar(tester);
    await tocarTexto(tester, 'Trocar e-mail');
    expect(rotaAtual(tester), Rotas.cadastro);
  });
}
