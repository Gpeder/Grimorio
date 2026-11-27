import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';

import '../../helpers/auth_falso.dart';
import '../../helpers/perfil_falso.dart';

void main() {
  late AuthServiceFalso service;
  late AuthProvider auth;

  void criar({bool logado = false}) {
    service = AuthServiceFalso(logado: logado);
    auth = AuthProvider(service);
    addTearDown(auth.dispose);
  }

  Matcher erroDo(TipoErroAuth tipo) =>
      throwsA(isA<AuthErro>().having((e) => e.tipo, 'tipo', tipo));

  group('entrar', () {
    test('ok fica logado', () async {
      criar();
      expect(auth.logado, isFalse);

      await auth.entrar(' Gustavo@Email.com ', AuthServiceFalso.senhaMock);

      expect(auth.logado, isTrue);
      expect(auth.usuarioId, usuarioMock.id);
      expect(auth.carregando, isFalse);
    });

    test('erro relança AuthErro e carregando volta a false', () async {
      criar();
      final estados = <bool>[];
      auth.addListener(() => estados.add(auth.carregando));

      await expectLater(
        auth.entrar(usuarioMock.email, 'errada1'),
        erroDo(TipoErroAuth.credenciaisInvalidas),
      );

      expect(auth.logado, isFalse);
      expect(auth.carregando, isFalse);
      expect(estados, [true, false]);
    });

    test('e-mail sem confirmar guarda o pendente e reenvia', () async {
      criar();
      service.contas['novo@email.com'] = ContaFalsa(
        id: 'u_novo',
        senha: 'abcd1234',
        confirmada: false,
      );

      await expectLater(
        auth.entrar('novo@email.com', 'abcd1234'),
        erroDo(TipoErroAuth.emailNaoConfirmado),
      );

      expect(auth.emailPendente, 'novo@email.com');
      expect(service.vezes('reenviarConfirmacao'), 1);
    });
  });

  test('cadastrar guarda o pendente e confirmar loga', () async {
    criar();
    await auth.cadastrar(' Lia ', 'LIA@email.com ', 'abcd1234');
    expect(auth.emailPendente, 'lia@email.com');
    expect(auth.logado, isFalse);
    expect(service.contas['lia@email.com']?.nome, 'Lia');

    await expectLater(
      auth.confirmarCadastro('000000'),
      erroDo(TipoErroAuth.codigoInvalido),
    );
    expect(auth.logado, isFalse);

    await auth.confirmarCadastro(service.codigoCerto);
    expect(auth.logado, isTrue);
    expect(auth.emailPendente, isNull);
  });

  test('cadastrar e-mail que já tem conta', () async {
    criar();
    await expectLater(
      auth.cadastrar('Gu', usuarioMock.email, 'abcd1234'),
      erroDo(TipoErroAuth.emailJaUsado),
    );
    expect(auth.emailPendente, isNull);
  });

  group('recuperar senha', () {
    test('recuperandoSenha liga no código e desliga ao trocar', () async {
      criar();
      await auth.pedirCodigoSenha(usuarioMock.email);
      expect(service.vezes('pedirCodigoSenha'), 1);

      await auth.confirmarCodigoSenha(usuarioMock.email, service.codigoCerto);
      expect(auth.recuperandoSenha, isTrue);
      expect(auth.logado, isTrue);

      await auth.trocarSenha('nova1234');
      expect(auth.recuperandoSenha, isFalse);
      expect(service.contas[usuarioMock.email]?.senha, 'nova1234');
    });

    test('código errado não liga recuperandoSenha', () async {
      criar();
      await expectLater(
        auth.confirmarCodigoSenha(usuarioMock.email, '000000'),
        erroDo(TipoErroAuth.codigoInvalido),
      );
      expect(auth.recuperandoSenha, isFalse);
      expect(auth.logado, isFalse);
    });

    test('cancelar depois do código fecha a sessão', () async {
      criar();
      await auth.confirmarCodigoSenha(usuarioMock.email, service.codigoCerto);
      await auth.cancelarRecuperacao();
      expect(auth.recuperandoSenha, isFalse);
      expect(auth.logado, isFalse);
    });
  });

  test('sair desloga e limpa o perfil', () async {
    criar(logado: true);
    final usuarios = UsuarioProvider(auth: auth, perfis: PerfilServiceFalso());
    addTearDown(usuarios.dispose);
    expect(usuarios.usuario.nome, usuarioMock.nome);

    await auth.sair();

    expect(auth.logado, isFalse);
    expect(usuarios.usuario.id, Usuario.vazio.id);
    expect(usuarios.usuario.nome, isEmpty);
  });

  test('erro programado sai como AuthErro', () async {
    criar();
    service.proximoErro = TipoErroAuth.semConexao;
    await expectLater(
      auth.entrar(usuarioMock.email, AuthServiceFalso.senhaMock),
      erroDo(TipoErroAuth.semConexao),
    );
    expect(auth.carregando, isFalse);
  });
}
