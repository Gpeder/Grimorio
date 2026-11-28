import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('cada code do supabase vira o tipo certo', () {
    const tabela = {
      'invalid_credentials': TipoErroAuth.credenciaisInvalidas,
      'email_not_confirmed': TipoErroAuth.emailNaoConfirmado,
      'user_already_exists': TipoErroAuth.emailJaUsado,
      'email_exists': TipoErroAuth.emailJaUsado,
      'email_address_invalid': TipoErroAuth.emailInvalido,
      'weak_password': TipoErroAuth.senhaFraca,
      'same_password': TipoErroAuth.senhaIgual,
      'otp_expired': TipoErroAuth.codigoInvalido,
      'over_email_send_rate_limit': TipoErroAuth.muitasTentativas,
      'over_request_rate_limit': TipoErroAuth.muitasTentativas,
    };
    for (final MapEntry(key: code, value: tipo) in tabela.entries) {
      final erro = AuthErro.de(AuthApiException('x', code: code));
      expect(erro.tipo, tipo, reason: code);
    }
  });

  test('status 429 sem code é muitas tentativas', () {
    expect(
      AuthErro.de(const AuthException('x', statusCode: '429')).tipo,
      TipoErroAuth.muitasTentativas,
    );
  });

  test('servidor antigo sem code usa o texto', () {
    expect(
      AuthErro.de(const AuthException('Token has expired or is invalid')).tipo,
      TipoErroAuth.codigoInvalido,
    );
    expect(
      AuthErro.de(const AuthException('Invalid login credentials')).tipo,
      TipoErroAuth.credenciaisInvalidas,
    );
  });

  test('senha fraca do gotrue', () {
    final e = AuthWeakPasswordException(
      message: 'x',
      statusCode: '422',
      reasons: const ['length'],
    );
    expect(AuthErro.de(e).tipo, TipoErroAuth.senhaFraca);
  });

  test('sem rede vira semConexao', () {
    expect(
      AuthErro.de(AuthRetryableFetchException(message: 'x')).tipo,
      TipoErroAuth.semConexao,
    );
    expect(
      AuthErro.de(const SocketException('sem rede')).tipo,
      TipoErroAuth.semConexao,
    );
  });

  test('desconhecido vira desconhecido', () {
    expect(
      AuthErro.de(const AuthApiException('x', code: 'nao_existe')).tipo,
      TipoErroAuth.desconhecido,
    );
    expect(AuthErro.de(StateError('x')).tipo, TipoErroAuth.desconhecido);
  });

  test('mensagemDeErro usa o texto amigável do AuthErro', () {
    expect(
      mensagemDeErro(const AuthErro(TipoErroAuth.credenciaisInvalidas)),
      'E-mail ou senha errados.',
    );
  });
}
