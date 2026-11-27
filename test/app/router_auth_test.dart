import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/app_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/auth/login.dart';
import 'package:grimorio/view/home/home.dart';

import '../helpers/app_teste.dart';
import '../helpers/auth_falso.dart';
import '../helpers/auth_teste.dart';

void main() {
  testWidgets('deslogado em /herois vai para /entrar', (tester) async {
    await abrirAuth(tester, Rotas.herois);
    expect(rotaAtual(tester), Rotas.entrar);
    expect(find.byType(Login), findsOneWidget);
  });

  testWidgets('abre no login quando ninguém está logado', (tester) async {
    await abrirAuth(tester, Rotas.inicio);
    expect(rotaAtual(tester), Rotas.entrar);
  });

  testWidgets('logado em /entrar vai para /inicio', (tester) async {
    await tester.pumpWidget(appDeTeste(Rotas.entrar));
    await tester.pumpAndSettle();
    expect(rotaAtual(tester), Rotas.inicio);
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('/cadastro/confirmar sem e-mail pendente vai para /entrar', (
    tester,
  ) async {
    await abrirAuth(tester, Rotas.confirmarEmailCompleto);
    expect(rotaAtual(tester), Rotas.entrar);
  });

  group('redirecionarAuth', () {
    test('logado recuperando senha fica em /recuperar-senha', () async {
      final service = AuthServiceFalso(logado: false);
      final auth = AuthProvider(service);
      addTearDown(auth.dispose);

      await auth.confirmarCodigoSenha(usuarioMock.email, service.codigoCerto);
      expect(auth.logado, isTrue);
      expect(redirecionarAuth(auth, Rotas.recuperarSenha), isNull);

      await auth.trocarSenha('nova1234');
      expect(redirecionarAuth(auth, Rotas.recuperarSenha), Rotas.inicio);
    });

    test('com e-mail pendente abre o confirmar', () async {
      final auth = AuthProvider(AuthServiceFalso(logado: false));
      addTearDown(auth.dispose);
      await auth.cadastrar('Lia', 'lia@email.com', 'abcd1234');
      expect(redirecionarAuth(auth, Rotas.confirmarEmailCompleto), isNull);
    });
  });
}
