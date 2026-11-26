import 'package:dio/dio.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/service/api/api_erro.dart';
import 'package:grimorio/service/api/api_log_interceptor.dart';
import 'package:grimorio/service/api/api_rotas.dart';

typedef Conversor<T> = T Function(dynamic json);

// unico cliente http do app, nenhum DioException sai daqui
class ApiClient {
  ApiClient({Dio? dio, String baseUrl = ApiRotas.base}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers['Accept'] = 'application/json';
    _dio.interceptors.add(ApiLogInterceptor());
  }

  final Dio _dio;

  Future<T> get<T>(
    String rota, {
    Map<String, dynamic>? query,
    required Conversor<T> converter,
  }) => _enviar('GET', rota, query: query, converter: converter);

  Future<T> post<T>(
    String rota, {
    Object? body,
    Map<String, dynamic>? query,
    required Conversor<T> converter,
  }) => _enviar('POST', rota, body: body, query: query, converter: converter);

  Future<T> put<T>(
    String rota, {
    Object? body,
    Map<String, dynamic>? query,
    required Conversor<T> converter,
  }) => _enviar('PUT', rota, body: body, query: query, converter: converter);

  Future<T> patch<T>(
    String rota, {
    Object? body,
    Map<String, dynamic>? query,
    required Conversor<T> converter,
  }) => _enviar('PATCH', rota, body: body, query: query, converter: converter);

  Future<void> delete(String rota, {Map<String, dynamic>? query}) =>
      _enviar<void>('DELETE', rota, query: query, converter: (_) {});

  void fechar() => _dio.close();

  // chamada, conversao e erro num lugar so
  Future<T> _enviar<T>(
    String metodo,
    String rota, {
    Object? body,
    Map<String, dynamic>? query,
    required Conversor<T> converter,
  }) async {
    final Response<dynamic> resposta;
    try {
      resposta = await _dio.request<dynamic>(
        rota,
        data: body,
        queryParameters: query,
        options: Options(method: metodo),
      );
    } on DioException catch (e) {
      // o interceptor ja logou com a stack
      throw ApiErro.doDio(e);
    }

    try {
      return converter(resposta.data);
    } catch (e, stack) {
      AppLog.erro(
        TagLog.api,
        'resposta inesperada $metodo $rota',
        erro: e,
        stack: stack,
      );
      throw ApiErro(TipoErroApi.resposta, status: resposta.statusCode);
    }
  }
}
