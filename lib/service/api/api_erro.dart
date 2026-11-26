import 'package:dio/dio.dart';

enum TipoErroApi {
  semConexao('Sem conexão. Confira a internet'),
  tempoEsgotado('O servidor demorou para responder'),
  naoEncontrado('Não encontrado'),
  naoAutorizado('Sessão expirada'),
  servidor('O servidor está com problema. Tente de novo'),
  resposta('Resposta inválida do servidor'),
  desconhecido('Algo deu errado');

  const TipoErroApi(this.mensagem);
  final String mensagem;
}

class ApiErro implements Exception {
  ApiErro(this.tipo, {this.status, String? mensagem})
    : mensagem = mensagem ?? tipo.mensagem;

  final TipoErroApi tipo;
  final int? status;

  // em portugues, pronta para o mostrarAviso
  final String mensagem;

  // traduz o erro do dio
  factory ApiErro.doDio(DioException e) {
    final status = e.response?.statusCode;
    final tipo = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => TipoErroApi.tempoEsgotado,
      DioExceptionType.connectionError => TipoErroApi.semConexao,
      DioExceptionType.badResponse => switch (status) {
        404 => TipoErroApi.naoEncontrado,
        401 || 403 => TipoErroApi.naoAutorizado,
        final s? when s >= 500 => TipoErroApi.servidor,
        _ => TipoErroApi.desconhecido,
      },
      _ => TipoErroApi.desconhecido,
    };
    return ApiErro(tipo, status: status);
  }

  // so para o log, nunca para a tela
  @override
  String toString() => 'ApiErro(${tipo.name}, status: $status)';
}
