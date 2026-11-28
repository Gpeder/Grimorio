import 'dart:async';
import 'dart:io';

import 'package:grimorio/app/log/erro_amigavel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TipoErroAuth {
  credenciaisInvalidas('E-mail ou senha errados.'),
  emailNaoConfirmado('Confirme seu e-mail para entrar.'),
  emailJaUsado('Esse e-mail já tem conta. Tente entrar.'),
  emailInvalido('Esse e-mail não é válido. Confira e tente de novo.'),
  senhaFraca('Use 8 ou mais caracteres, com letra e número.'),
  senhaIgual('A senha nova precisa ser diferente da antiga.'),
  codigoInvalido('Código errado ou vencido.'),
  muitasTentativas('Muitas tentativas. Espere um pouco.'),
  semConexao('Sem conexão. Confira a internet.'),
  semConfiguracao('O app está sem a configuração do servidor.'),
  desconhecido('Algo deu errado. Tente de novo.');

  const TipoErroAuth(this.mensagem);
  final String mensagem;
}

class AuthErro implements Exception, ErroAmigavel {
  const AuthErro(this.tipo, {this.codigo});

  final TipoErroAuth tipo;

  // code original do supabase, so para o log
  final String? codigo;

  // em portugues, pronta para o mostrarAviso
  @override
  String get mensagem => tipo.mensagem;

  // traduz qualquer erro do supabase ou da rede
  factory AuthErro.de(Object erro) => switch (erro) {
    AuthErro() => erro,
    AuthRetryableFetchException() => const AuthErro(TipoErroAuth.semConexao),
    AuthException(:final code, :final statusCode, :final message) => AuthErro(
      tipoDoCodigo(code, status: statusCode, mensagem: message),
      codigo: code ?? statusCode,
    ),
    SocketException() ||
    TimeoutException() ||
    HttpException() => const AuthErro(TipoErroAuth.semConexao),
    _ => const AuthErro(TipoErroAuth.desconhecido),
  };

  // code da api, com o texto como reserva para servidor antigo
  static TipoErroAuth tipoDoCodigo(
    String? code, {
    String? status,
    String? mensagem,
  }) {
    final porCodigo = switch (code) {
      'invalid_credentials' => TipoErroAuth.credenciaisInvalidas,
      'email_not_confirmed' => TipoErroAuth.emailNaoConfirmado,
      'user_already_exists' || 'email_exists' => TipoErroAuth.emailJaUsado,
      'email_address_invalid' => TipoErroAuth.emailInvalido,
      'weak_password' => TipoErroAuth.senhaFraca,
      'same_password' => TipoErroAuth.senhaIgual,
      'otp_expired' => TipoErroAuth.codigoInvalido,
      'over_email_send_rate_limit' ||
      'over_request_rate_limit' => TipoErroAuth.muitasTentativas,
      _ => null,
    };
    if (porCodigo != null) return porCodigo;
    if (status == '429') return TipoErroAuth.muitasTentativas;

    final texto = mensagem?.toLowerCase() ?? '';
    if (texto.contains('invalid login credentials')) {
      return TipoErroAuth.credenciaisInvalidas;
    }
    if (texto.contains('email not confirmed')) {
      return TipoErroAuth.emailNaoConfirmado;
    }
    if (texto.contains('token has expired or is invalid')) {
      return TipoErroAuth.codigoInvalido;
    }
    return TipoErroAuth.desconhecido;
  }

  // so para o log, nunca para a tela
  @override
  String toString() => 'AuthErro(${tipo.name}, codigo: $codigo)';
}
