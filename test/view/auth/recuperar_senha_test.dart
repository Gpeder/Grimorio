import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/auth/components/campo_codigo.dart';
import 'package:grimorio/view/auth/recuperar_senha.dart';
import 'package:grimorio/view/home/home.dart';

import '../../helpers/auth_falso.dart';
import '../../helpers/auth_teste.dart';

void main() {
  Finder campoCodigo() => find.descendant(
    of: find.byType(CampoCodigo),
    matching: find.byType(EditableText),
  );

  Future<AuthServiceFalso> irParaCodigo(WidgetTester tester) async {
    final auth = await abrirAuth(tester, Rotas.recuperarSenha);
    await digitar(tester, 'recuperar-email', ' Gustavo@Email.com ');
    await tocarTexto(tester, 'Enviar código');
    return auth;
  }

  testWidgets('passo 1 valida o e-mail antes de mandar', (tester) async {
    final auth = await abrirAuth(tester, Rotas.recuperarSenha);
    expect(find.text('Passo 1 de 3'), findsOneWidget);

    await tocarTexto(tester, 'Enviar código');
    expect(find.text('E-mail inválido.'), findsOneWidget);
    expect(auth.vezes('pedirCodigoSenha'), 0);
  });

  testWidgets('passo 1 vai para o passo 2 sem contar se o e-mail existe', (
    tester,
  ) async {
    final auth = await irParaCodigo(tester);

    expect(auth.vezes('pedirCodigoSenha'), 1);
    expect(find.text('Passo 2 de 3'), findsOneWidget);
    expect(
      textoRico('Código enviado para ${usuarioMock.email}.'),
      findsOneWidget,
    );
    expect(
      find.text('Se o e-mail tiver conta, o código chega em instantes.'),
      findsOneWidget,
    );
  });

  testWidgets('código errado mostra a mensagem e fica no passo 2', (
    tester,
  ) async {
    await irParaCodigo(tester);
    await tester.enterText(campoCodigo(), '000000');
    await tester.pumpAndSettle();

    expect(find.text('Código errado ou vencido.'), findsOneWidget);
    expect(find.text('Passo 2 de 3'), findsOneWidget);
    semErroTecnico();
  });

  testWidgets('código certo fica na tela até salvar a senha nova', (
    tester,
  ) async {
    final auth = await irParaCodigo(tester);
    await tester.enterText(campoCodigo(), '123456');
    await tester.pumpAndSettle();

    // ja tem sessao, mas o router espera a senha nova
    expect(auth.usuarioId, usuarioMock.id);
    expect(find.byType(RecuperarSenha), findsOneWidget);
    expect(find.text('Passo 3 de 3'), findsOneWidget);
    expect(
      find.text('Código confirmado. Agora escolha a senha nova.'),
      findsOneWidget,
    );

    await digitar(tester, 'recuperar-senha', 'nova1234');
    await digitar(tester, 'recuperar-confirmar', 'nova1235');
    await tocarTexto(tester, 'Salvar senha');
    expect(find.text('As senhas não batem.'), findsOneWidget);

    await digitar(tester, 'recuperar-confirmar', 'nova1234');
    await tocarTexto(tester, 'Salvar senha');

    expect(find.text('Senha trocada'), findsOneWidget);
    expect(rotaAtual(tester), Rotas.inicio);
    expect(find.byType(Home), findsOneWidget);
    expect(auth.contas[usuarioMock.email]?.senha, 'nova1234');
  });

  testWidgets('senha igual à antiga mostra a mensagem', (tester) async {
    await irParaCodigo(tester);
    await tester.enterText(campoCodigo(), '123456');
    await tester.pumpAndSettle();

    await digitar(tester, 'recuperar-senha', AuthServiceFalso.senhaMock);
    await digitar(tester, 'recuperar-confirmar', AuthServiceFalso.senhaMock);
    await tocarTexto(tester, 'Salvar senha');

    expect(
      find.text('A senha nova precisa ser diferente da antiga.'),
      findsOneWidget,
    );
    expect(find.byType(RecuperarSenha), findsOneWidget);
  });

  testWidgets('voltar no passo 2 volta para o passo 1', (tester) async {
    await irParaCodigo(tester);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(RecuperarSenha), findsOneWidget);
    expect(find.text('Passo 1 de 3'), findsOneWidget);
  });

  testWidgets('voltar no passo 3 fecha a sessão do código', (tester) async {
    final auth = await irParaCodigo(tester);
    await tester.enterText(campoCodigo(), '123456');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Passo 1 de 3'), findsOneWidget);
    expect(auth.usuarioId, isNull);
    expect(rotaAtual(tester), Rotas.recuperarSenha);
  });
}
