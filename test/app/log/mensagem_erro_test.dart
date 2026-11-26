import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/service/api/api_erro.dart';

void main() {
  test('ApiErro devolve a mensagem dele', () {
    expect(
      mensagemDeErro(ApiErro(TipoErroApi.semConexao)),
      'Sem conexão. Confira a internet',
    );
    expect(
      mensagemDeErro(ApiErro(TipoErroApi.servidor, status: 503)),
      'O servidor está com problema. Tente de novo',
    );
  });

  test('erro que não é ApiErro vira Algo deu errado', () {
    Object? tipo;
    try {
      (1 as dynamic).naoExiste();
    } catch (e) {
      tipo = e;
    }
    final erros = <Object>[
      Exception('x'),
      StateError('Bad state: estourou'),
      TypeError(),
      ?tipo,
    ];
    for (final e in erros) {
      final msg = mensagemDeErro(e);
      expect(msg, 'Algo deu errado', reason: '$e');
      expect(msg, isNot(contains('Exception')));
      expect(msg, isNot(contains('Bad state')));
    }
  });
}
