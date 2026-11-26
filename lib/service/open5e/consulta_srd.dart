import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';

// query de toda chamada ao srd, com o filtro do documento
Map<String, dynamic> consultaSrd({
  int? pagina,
  String? busca,
  String documento = ApiRotas.documentoSrd,
}) {
  final b = busca?.trim() ?? '';
  return {
    ApiRotas.filtroDocumento: documento,
    if (pagina != null && pagina > 1) ApiRotas.pagina: pagina,
    if (b.isNotEmpty) ApiRotas.filtroBusca: b,
  };
}

// lista e detalhe iguais para todo service da open5e
extension ConsultaOpen5e on ApiClient {
  Future<Paginado<T>> listarSrd<T>(
    String rota,
    T Function(Map<String, dynamic>) item, {
    int pagina = 1,
    String? busca,
    String documento = ApiRotas.documentoSrd,
  }) => get(
    rota,
    query: consultaSrd(pagina: pagina, busca: busca, documento: documento),
    converter: (json) => Paginado.fromJson(json as Map<String, dynamic>, item),
  );

  Future<T> buscarSrd<T>(
    String rota,
    String key,
    T Function(Map<String, dynamic>) item, {
    String documento = ApiRotas.documentoSrd,
  }) => get(
    ApiRotas.detalhe(rota, key),
    query: consultaSrd(documento: documento),
    converter: (json) => item(json as Map<String, dynamic>),
  );
}
