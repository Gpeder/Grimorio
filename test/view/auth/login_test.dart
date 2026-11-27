import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/view/auth/cadastro.dart';
import 'package:grimorio/view/auth/confirmar_email.dart';
import 'package:grimorio/view/auth/recuperar_senha.dart';
import 'package:grimorio/view/home/home.dart';

import '../../helpers/auth_falso.dart';
import '../../helpers/auth_teste.dart';

void main() {
  Future<void> preencher(
    WidgetTester tester,
    String email,
    String senha,
  ) async {
    await digitar(tester, 'login-email', email);
    await digitar(tester, 'login-senha', senha);
  }

  testWidgets('Entrar vazio mostra os erros', (tester) async {
    await abrirAuth(tester, Rotas.entrar);
    expect(find.text('E-mail inválido.'), findsNothing);

    await tocarTexto(tester, 'Entrar');

    expect(find.text('E-mail inválido.'), findsOneWidget);
    expect(find.text('Digite sua senha.'), findsOneWidget);

    // depois do primeiro toque valida ao digitar
    await digitar(tester, 'login-email', usuarioMock.email);
    expect(find.text('E-mail inválido.'), findsNothing);
  });

  testWidgets('credenciais erradas mostram a mensagem amigável', (
    tester,
  ) async {
    await abrirAuth(tester, Rotas.entrar);
    await preencher(tester, usuarioMock.email, 'errada99');
    await tocarTexto(tester, 'Entrar');

    expect(find.text('E-mail ou senha errados.'), findsOneWidget);
    expect(rotaAtual(tester), Rotas.entrar);
    semErroTecnico();
  });

  testWidgets('entrar certo abre o Início', (tester) async {
    await abrirAuth(tester, Rotas.entrar);
    await preencher(tester, ' Gustavo@Email.com ', AuthServiceFalso.senhaMock);
    await tocarTexto(tester, 'Entrar');

    expect(rotaAtual(tester), Rotas.inicio);
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('tocar duas vezes rápido chama entrar uma vez', (tester) async {
    final auth = await abrirAuth(
      tester,
      Rotas.entrar,
      auth: AuthServiceFalso(
        logado: false,
        atraso: const Duration(milliseconds: 500),
      ),
    );
    await preencher(tester, usuarioMock.email, AuthServiceFalso.senhaMock);

    final botao = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(botao);
    await tester.tap(botao, warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(auth.vezes('entrar'), 1);
    expect(rotaAtual(tester), Rotas.inicio);
  });

  testWidgets('conta sem confirmar vai para Confirmar e-mail e reenvia', (
    tester,
  ) async {
    final auth = AuthServiceFalso(logado: false);
    auth.contas['novo@email.com'] = ContaFalsa(
      id: 'u_novo',
      senha: 'abcd1234',
      confirmada: false,
    );
    await abrirAuth(tester, Rotas.entrar, auth: auth);
    await preencher(tester, 'novo@email.com', 'abcd1234');
    await tocarTexto(tester, 'Entrar');

    expect(find.byType(ConfirmarEmail), findsOneWidget);
    expect(
      textoRico('Mandamos um código de 6 números para novo@email.com.'),
      findsOneWidget,
    );
    expect(auth.vezes('reenviarConfirmacao'), 1);
  });

  testWidgets('sem internet mostra a mensagem de conexão', (tester) async {
    final auth = await abrirAuth(tester, Rotas.entrar);
    auth.proximoErro = TipoErroAuth.semConexao;
    await preencher(tester, usuarioMock.email, AuthServiceFalso.senhaMock);
    await tocarTexto(tester, 'Entrar');

    expect(find.text('Sem conexão. Confira a internet.'), findsOneWidget);
    semErroTecnico();
  });

  testWidgets('"Esqueci minha senha" abre Recuperar', (tester) async {
    await abrirAuth(tester, Rotas.entrar);
    await tocarTexto(tester, 'Esqueci minha senha');
    expect(find.byType(RecuperarSenha), findsOneWidget);
  });

  testWidgets('"Criar conta" abre o Cadastro', (tester) async {
    await abrirAuth(tester, Rotas.entrar);
    await tocarTexto(tester, 'Criar conta');
    expect(find.byType(Cadastro), findsOneWidget);
  });

  testWidgets('olho mostra e esconde a senha', (tester) async {
    await abrirAuth(tester, Rotas.entrar);
    EditableText senha() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('login-senha')),
        matching: find.byType(EditableText),
      ),
    );
    expect(senha().obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();
    expect(senha().obscureText, isFalse);
  });
}
