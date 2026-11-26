import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:grimorio/service/api/api_client.dart';

// resposta pronta para um path
class RespostaFalsa {
  const RespostaFalsa({
    this.status = 200,
    this.json,
    this.texto,
    this.erro,
    this.atraso = Duration.zero,
  });

  // dio lanca esse tipo em vez de responder
  const RespostaFalsa.falha(DioExceptionType tipo)
    : this(erro: tipo, status: 0);

  final int status;
  final Object? json;
  final String? texto;
  final DioExceptionType? erro;

  // demora para chegar, para testar resposta fora de ordem
  final Duration atraso;
}

// adapter a mao, sem pacote de mock
class DioFalso implements HttpClientAdapter {
  DioFalso([Map<String, RespostaFalsa>? respostas, this.responder])
    : respostas = respostas ?? {};

  final Map<String, RespostaFalsa> respostas;

  // olha a query antes do mapa por path
  final RespostaFalsa? Function(RequestOptions pedido)? responder;
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
        responder?.call(options) ??
        respostas[options.path] ??
        const RespostaFalsa(status: 404, json: {'detail': 'Not found.'});
    if (r.atraso > Duration.zero) await Future<void>.delayed(r.atraso);
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

// pagina com n copias do primeiro item, keys e nomes diferentes
Map<String, dynamic> paginaFalsa(
  String arquivo, {
  int n = 30,
  int pagina = 1,
  bool temMais = true,
  int? total,
}) {
  final base = fixture(arquivo);
  final item = (base['results'] as List).first as Map<String, dynamic>;
  return {
    'count': total ?? n * 3,
    'next': temMais ? 'pagina ${pagina + 1}' : null,
    'previous': null,
    'results': [
      for (var i = 0; i < n; i++)
        {
          ...item,
          'key': '${item['key']}-p$pagina-$i',
          'name': '${item['name']} $pagina.$i',
        },
    ],
  };
}

// lê um json de test/fixtures
Map<String, dynamic> fixture(String nome) =>
    jsonDecode(File('test/fixtures/$nome').readAsStringSync())
        as Map<String, dynamic>;
