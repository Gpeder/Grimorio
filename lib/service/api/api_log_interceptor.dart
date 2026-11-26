import 'package:dio/dio.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/service/api/api_erro.dart';

// ida, volta e erro de cada chamada com a tag API
class ApiLogInterceptor extends Interceptor {
  static const _inicio = 'inicio_ms';
  static const _limiteCorpo = 300;

  // chaves que nunca vao para o log
  static const _sensiveis = {'authorization', 'token', 'apikey', 'senha'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_inicio] = DateTime.now().millisecondsSinceEpoch;
    AppLog.info(
      TagLog.api,
      '→ ${options.method} ${options.path} ${_seguro(options.queryParameters)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final o = response.requestOptions;
    AppLog.info(
      TagLog.api,
      '← ${response.statusCode} ${o.path} (${_tempo(o)} ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final status = err.response?.statusCode ?? '-';
    final tipo = ApiErro.doDio(err).tipo.name;
    final corpo = _resumo(err.response?.data);
    AppLog.erro(
      TagLog.api,
      '✕ $status ${o.path} (${_tempo(o)} ms) $tipo'
      '${corpo.isEmpty ? '' : '\n$corpo'}',
      erro: err,
      stack: err.stackTrace,
    );
    handler.next(err);
  }

  static int _tempo(RequestOptions o) {
    final inicio = o.extra[_inicio];
    if (inicio is! int) return 0;
    return DateTime.now().millisecondsSinceEpoch - inicio;
  }

  static Map<String, dynamic> _seguro(Map<String, dynamic> query) => {
    for (final MapEntry(:key, :value) in query.entries)
      key: _sensiveis.contains(key.toLowerCase()) ? '***' : value,
  };

  static String _resumo(Object? corpo) {
    if (corpo == null) return '';
    final texto = corpo.toString();
    return texto.length <= _limiteCorpo
        ? texto
        : '${texto.substring(0, _limiteCorpo)}…';
  }
}
