import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/service/api/api_erro.dart';

import '../../helpers/auth_falso.dart';
import '../../helpers/perfil_falso.dart';

void main() {
  test('sem login começa vazio', () {
    expect(UsuarioProvider().usuario.id, isEmpty);
  });

  test('atualizar troca e notifica', () {
    final u = UsuarioProvider();
    var avisos = 0;
    u.addListener(() => avisos++);
    u.atualizar(u.usuario.copyWith(magia: SistemaMagia.pontos));
    expect(u.usuario.magia, SistemaMagia.pontos);
    expect(avisos, 1);
  });

  group('com login', () {
    late AuthServiceFalso service;
    late AuthProvider auth;
    late PerfilServiceFalso perfis;
    late List<String> adotados;

    UsuarioProvider criar({bool logado = true}) {
      service = AuthServiceFalso(logado: logado);
      auth = AuthProvider(service);
      perfis = PerfilServiceFalso(
        perfis: [
          usuarioMock,
          const Usuario(id: 'u_1', nome: 'Lia', email: ''),
        ],
      );
      adotados = [];
      final u = UsuarioProvider(
        auth: auth,
        perfis: perfis,
        aoEntrar: adotados.add,
      );
      addTearDown(() {
        u.dispose();
        auth.dispose();
      });
      return u;
    }

    test('logado busca o perfil com id e e-mail do auth', () {
      final u = criar();
      expect(u.carregamento, Carregamento.pronto);
      expect(u.usuario.id, usuarioMock.id);
      expect(u.usuario.nome, usuarioMock.nome);
      expect(u.usuario.email, usuarioMock.email);
      expect(adotados, [usuarioMock.id]);
    });

    test('deslogado fica vazio e entrar carrega', () async {
      final u = criar(logado: false);
      expect(u.usuario.id, isEmpty);
      expect(perfis.buscas, 0);

      service.contas['lia@email.com'] = ContaFalsa(
        id: 'u_1',
        senha: 'abcd1234',
      );
      await auth.entrar('lia@email.com', 'abcd1234');

      expect(u.usuario.nome, 'Lia');
      expect(u.usuario.email, 'lia@email.com');
      expect(adotados, ['u_1']);
    });

    test('erro ao buscar vira estado de erro amigável', () async {
      final u = criar(logado: false);
      perfis.proximoErro = ApiErro(TipoErroApi.semConexao);
      await auth.entrar(usuarioMock.email, AuthServiceFalso.senhaMock);

      expect(u.carregamento, Carregamento.erro);
      expect(u.mensagemErro, 'Sem conexão. Confira a internet');

      await u.carregar();
      expect(u.carregamento, Carregamento.pronto);
    });

    test('atualizar manda só as colunas que mudaram', () async {
      final u = criar();
      await u.atualizar(
        u.usuario.copyWith(nome: 'Gu', vibrar: false, papel: PapelMesa.mestre),
      );
      expect(perfis.atualizacoes, [
        {'nome': 'Gu', 'papel': 'mestre'},
      ]);

      // vibrar e do aparelho, nao vai para o banco
      await u.atualizar(u.usuario.copyWith(vibrar: true));
      expect(perfis.atualizacoes, hasLength(1));
    });

    test('atualizar que falha volta o anterior e relança', () async {
      final u = criar();
      perfis.proximoErro = ApiErro(TipoErroApi.servidor);

      await expectLater(
        u.atualizar(u.usuario.copyWith(nome: 'Outro')),
        throwsA(isA<ApiErro>()),
      );
      expect(u.usuario.nome, usuarioMock.nome);
    });
  });
}
