import 'package:grimorio/model/srd/condicao_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class CondicaoService {
  CondicaoService(this._api);

  final ApiClient _api;

  // lista paginada
  Future<Paginado<CondicaoSrd>> listar({int pagina = 1, String? busca}) =>
      _api.listarSrd(
        ApiRotas.condicoes,
        CondicaoSrd.fromJson,
        pagina: pagina,
        busca: busca,
        documento: ApiRotas.documentoCondicoes,
        ordem: ApiRotas.ordemNome,
      );

  // uma condicao pela key
  Future<CondicaoSrd> buscar(String key) => _api.buscarSrd(
    ApiRotas.condicoes,
    key,
    CondicaoSrd.fromJson,
    documento: ApiRotas.documentoCondicoes,
  );
}
