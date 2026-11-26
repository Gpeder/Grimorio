import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/service/api/api_erro.dart';

import '../../helpers/dio_falso.dart';

void main() {
  Matcher erroDoTipo(TipoErroApi tipo) =>
      throwsA(isA<ApiErro>().having((e) => e.tipo, 'tipo', tipo));

  test('get 200 converte certo', () async {
    final api = clienteFalso(
      DioFalso({
        '/x/': const RespostaFalsa(json: {'nome': 'Goblin'}),
      }),
    );
    final nome = await api.get(
      '/x/',
      converter: (json) => (json as Map)['nome'] as String,
    );
    expect(nome, 'Goblin');
  });

  test('manda Accept json e os timeouts', () async {
    final dio = DioFalso({'/x/': const RespostaFalsa(json: {})});
    await clienteFalso(dio).get('/x/', converter: (_) => null);
    expect(dio.ultimo.headers['Accept'], 'application/json');
    expect(dio.ultimo.connectTimeout, const Duration(seconds: 10));
    expect(dio.ultimo.receiveTimeout, const Duration(seconds: 15));
  });

  group('erros viram ApiErro', () {
    Future<void> chamar(RespostaFalsa r) =>
        clienteFalso(DioFalso({'/x/': r})).get('/x/', converter: (j) => j);

    test('404 vira naoEncontrado', () {
      expect(
        chamar(const RespostaFalsa(status: 404, json: {})),
        erroDoTipo(TipoErroApi.naoEncontrado),
      );
    });

    test('500 vira servidor', () {
      expect(
        chamar(const RespostaFalsa(status: 500, json: {})),
        erroDoTipo(TipoErroApi.servidor),
      );
    });

    test('401 vira naoAutorizado', () {
      expect(
        chamar(const RespostaFalsa(status: 401, json: {})),
        erroDoTipo(TipoErroApi.naoAutorizado),
      );
    });

    test('timeout vira tempoEsgotado', () {
      expect(
        chamar(const RespostaFalsa.falha(DioExceptionType.receiveTimeout)),
        erroDoTipo(TipoErroApi.tempoEsgotado),
      );
    });

    test('erro de conexão vira semConexao', () {
      expect(
        chamar(const RespostaFalsa.falha(DioExceptionType.connectionError)),
        erroDoTipo(TipoErroApi.semConexao),
      );
    });

    test('json no formato errado vira resposta', () {
      final api = clienteFalso(
        DioFalso({
          '/x/': const RespostaFalsa(json: [1, 2]),
        }),
      );
      expect(
        api.get('/x/', converter: (json) => (json as Map)['nome'] as String),
        erroDoTipo(TipoErroApi.resposta),
      );
    });

    test('a mensagem é a amigável do tipo', () async {
      try {
        await chamar(
          const RespostaFalsa.falha(DioExceptionType.connectionError),
        );
        fail('devia lançar');
      } on ApiErro catch (e) {
        expect(e.mensagem, 'Sem conexão. Confira a internet');
      }
    });
  });

  group('verbos', () {
    test('post e put mandam o body', () async {
      final dio = DioFalso({
        '/x/': const RespostaFalsa(status: 201, json: {'ok': true}),
      });
      final api = clienteFalso(dio);

      await api.post('/x/', body: {'nome': 'A'}, converter: (j) => j);
      expect(dio.ultimo.method, 'POST');
      expect(dio.ultimo.data, {'nome': 'A'});

      await api.put('/x/', body: {'nome': 'B'}, converter: (j) => j);
      expect(dio.ultimo.method, 'PUT');
      expect(dio.ultimo.data, {'nome': 'B'});
    });

    test('patch e delete usam o verbo certo', () async {
      final dio = DioFalso({'/x/': const RespostaFalsa(json: {})});
      final api = clienteFalso(dio);
      await api.patch('/x/', body: {'a': 1}, converter: (j) => j);
      expect(dio.ultimo.method, 'PATCH');
      await api.delete('/x/');
      expect(dio.ultimo.method, 'DELETE');
    });
  });
}
