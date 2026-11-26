import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:grimorio/service/api/api_client.dart';

// resposta pronta para um path
class RespostaFalsa {
  const RespostaFalsa({this.status = 200, this.json, this.texto, this.erro});

  // dio lanca esse tipo em vez de responder
  const RespostaFalsa.falha(DioExceptionType tipo)
    : this(erro: tipo, status: 0);

  final int status;
  final Object? json;
  final String? texto;
  final DioExceptionType? erro;
}

// adapter a mao, sem pacote de mock
class DioFalso implements HttpClientAdapter {
  DioFalso([Map<String, RespostaFalsa>? respostas])
    : respostas = respostas ?? {};

  final Map<String, RespostaFalsa> respostas;
  final pedidos = <RequestOptions>[];

  RequestOptions get ultimo => pedidos.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    pedidos.add(options);
    final r =
        respostas[options.path] ??
        const RespostaFalsa(status: 404, json: {'detail': 'Not found.'});
    if (r.erro case final tipo?) {
      throw DioException(
        requestOptions: options,
        type: tipo,
        error: tipo == DioExceptionType.connectionError
            ? const SocketException('sem rede')
            : 'falso',
      );
    }
    return ResponseBody.fromString(
      r.texto ?? jsonEncode(r.json),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiClient clienteFalso(DioFalso adapter) =>
    ApiClient(dio: Dio()..httpClientAdapter = adapter);

// lê um json de test/fixtures
Map<String, dynamic> fixture(String nome) =>
    jsonDecode(File('test/fixtures/$nome').readAsStringSync())
        as Map<String, dynamic>;
